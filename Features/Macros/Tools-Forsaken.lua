local _, ns = ...

--------------------------------------------------------------------------------
-- Cannibalize (Forsaken)
--------------------------------------------------------------------------------

--[[
    Cannibalize channels for 10 sec off a Humanoid or Undead corpse within 5
    yards, on a 2 min cooldown. A macro can test neither the corpse's creature
    type nor the cooldown, so the add-on decides those at write time and leaves
    only the corpse's death to the macro:

      Cannibalize off cooldown and the target Humanoid or Undead
          /cast [dead] Cannibalize   above the usual eat or drink lines
      anything else
          the usual body

    So a press on the corpse just killed cannibalizes, and a press that cannot,
    on a corpse out of reach or one Cannibalize does not work on, falls through
    and eats or drinks as every other press does. Scrolls come first (scroll-only mode replaces the
    body), and so does buff food: a buff food or drink pick keeps the usual
    body, since only eating it gives Well Fed.

    What keeps the body current: the target's creature type is part of the
    target signature (Signatures.lua), the cast itself rebuilds through
    UNIT_SPELLCAST_SUCCEEDED (Core.lua), and the end of the cooldown rebuilds
    through the timer set here. The target dying needs no rewrite, because
    [dead] reads it as the press happens.
]]

--------------------------------------------------------------------------------
-- Target
--------------------------------------------------------------------------------

local CANNIBALIZE_CREATURE_TYPES = {}
for _, creatureTypeID in ipairs(ns.CANNIBALIZE_CREATURE_TYPE_IDS) do
	CANNIBALIZE_CREATURE_TYPES[creatureTypeID] = true
end

--[[
    True when the target is a creature type Cannibalize can eat, by the
    creature type ID UnitCreatureType gives as its second value. Nil when the
    client hides the target's identity (Forever can restrict unit data
    mid-fight), asked of C_Secrets before the read, which the target signature
    keeps as unchanged.
]]
function ns.TargetIsCannibalizable()
	if not UnitExists("target") then
		return false
	end
	if C_Secrets.ShouldUnitIdentityBeSecret("target") then
		return nil
	end
	local _, creatureTypeID = UnitCreatureType("target")
	return CANNIBALIZE_CREATURE_TYPES[creatureTypeID] == true
end

-- Whether a Cannibalize switch that can apply on this client is on, so the target is worth reading.
function ns.CannibalizeSwitchedOn()
	local settings = ns.db and ns.db.profile
	if not (ns.isForsaken and settings) then
		return false
	end
	return settings.enableCannibalizeEating
		or (settings.enableCannibalizeDrinking and ns.CANNIBALIZE_RESTORES_MANA)
		or false
end

--------------------------------------------------------------------------------
-- Cooldown
--------------------------------------------------------------------------------

-- When the pending rebuild timer fires, so a second read of the same cooldown never stacks another.
local rebuildAt

local function RebuildWhenReady(readyAt)
	if rebuildAt == readyAt then
		return
	end
	rebuildAt = readyAt
	C_Timer.After(math.max(readyAt - GetTime(), 0) + 0.1, function()
		if rebuildAt == readyAt then
			rebuildAt = nil
			ns.RequestUpdate()
		end
	end)
end

--[[
    True when Cannibalize is off cooldown. While it is on one, a rebuild is
    timed for the moment it comes off, which is when the body should gain the
    cast again. A hidden reading, asked of C_Secrets before the read, counts
    as on cooldown: the usual body is always safe.
]]
local function CannibalizeReady()
	if C_Secrets.ShouldSpellCooldownBeSecret(ns.CANNIBALIZE_SPELL_ID) then
		return false
	end
	local cooldown = C_Spell.GetSpellCooldown(ns.CANNIBALIZE_SPELL_ID)
	if not cooldown then
		return true
	end
	local startTime, duration = cooldown.startTime, cooldown.duration
	-- A global-cooldown reading counts as on cooldown, which only times the line for when the GCD ends: ready within one GCD is close enough.
	if not duration or duration <= 0 then
		return true
	end
	local readyAt = startTime + duration
	if readyAt <= GetTime() then
		return true
	end
	RebuildWhenReady(readyAt)
	return false
end

--------------------------------------------------------------------------------
-- Cast
--------------------------------------------------------------------------------

--[[
    The Cannibalize name a Food or Water body tries first on a dead target, or
    nil while it should only eat or drink. settingKey is the macro's switch
    (enableCannibalizeEating or enableCannibalizeDrinking); entry is the
    scanned pick for that macro's type, or nil when the bags hold none, in
    which case the body still cannibalizes above its no-item line.

    The target and cooldown are read last, so the cooldown timer is only set
    for a body that would carry the cast.
]]
function ns.CannibalizeCast(settingKey, entry)
	if not ns.isForsaken or not ns.cannibalizeSpellName then
		return nil
	end
	local settings = ns.db and ns.db.profile
	if not settings or not settings[settingKey] then
		return nil
	end
	if entry and entry.id and entry.isBuffFood then
		return nil
	end
	if not ns.TargetIsCannibalizable() then
		return nil
	end
	if not CannibalizeReady() then
		return nil
	end
	return ns.cannibalizeSpellName
end
