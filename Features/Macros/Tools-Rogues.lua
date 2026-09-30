local _, ns = ...
local MACRO_CONFIG = ns.MACRO_CONFIG

--------------------------------------------------------------------------------
-- Poisons Macro (Rogue)
--------------------------------------------------------------------------------

--[[
    Rogue-only, and like Feed Pet it owns its whole update cycle: the body
    doesn't fit the engine's standard tooltip+conjure+/use shape.

    Click layout (the Poisons Macro rows of the mini-map tooltip's class notes):
      Left-Click   → apply the Off Hand poison group's best rank to slot 17
      Right-Click  → apply the Main Hand poison group's best rank to slot 16
      Middle-Click → open the Poisons crafting window (if known)

    The body applies in two steps — /use the poison item, then /use the
    inventory slot number — and then clicks StaticPopup1Button1 to confirm
    the client's "replace your current enchant/poison" popup, so pressing the
    macro overwrites whatever poison is already on the weapon. The trailing
    UIErrorsFrame:Clear() swallows the noise from clicking with no off-hand
    weapon equipped or a poison already pending.

    The player picks a poison GROUP per hand (Options → Poisons, Rogues
    only); the scan resolves each group to the best rank the rogue can use
    and actually has in bags. Poisons aren't soulbound, so a twink can carry
    ranks above their level — the required-level column in ns.POISON_DATA
    gates those out.

    The tooltip/icon always tracks the Main Hand pick (falling back to the
    Off Hand item, then the config default) so the button reads as "your
    main poison."
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local currentPoisonState = nil

function ns.ResetPoisonMacroState()
	currentPoisonState = nil
end

--------------------------------------------------------------------------------
-- Derived Poison Lookups
--------------------------------------------------------------------------------

--[[
    Per-group candidate lists sorted best-first (highest required level =
    highest rank), precomputed once from ns.POISON_DATA (Data/{Game}/Poisons-{Game}.lua, which
    loads before this file) so the per-update scan is a plain walk. Same pattern
    as the derived scroll lookups in Features/Scanner-Auras.lua. Only
    FindBestPoison below reads it.
]]
local POISONS_BY_GROUP = {}
for itemID, row in pairs(ns.POISON_DATA) do
	local group = row[2]
	local list = POISONS_BY_GROUP[group]
	if not list then
		list = {}
		POISONS_BY_GROUP[group] = list
	end
	list[#list + 1] = { itemID, row[1] }
end
for _, list in pairs(POISONS_BY_GROUP) do
	table.sort(list, function(a, b)
		if a[2] ~= b[2] then
			return a[2] > b[2]
		end
		return a[1] > b[1]
	end)
end

--------------------------------------------------------------------------------
-- Poison Resolution
--------------------------------------------------------------------------------

--[[
    Localized group name for the Options dropdowns: the base (rank 1) item's
    client-localized name. Nil while C_Item.GetItemInfo is still cold -- the
    call itself starts the async load -- and the dropdown shows the panels'
    loading text until ns.WarmItemCache repaints it.
]]
function ns.GetPoisonGroupName(groupID)
	local baseItem = ns.POISON_GROUP_BASE_ITEMS[groupID]
	return baseItem and (C_Item.GetItemInfo(baseItem))
end

--[[
    Best usable poison for a group: the lists in POISONS_BY_GROUP are sorted
    best-first, so the first entry the rogue meets the level requirement for,
    has in bags AND has not ignored wins. Returns nil when the group has nothing
    usable.
]]
local function FindBestPoison(groupID)
	local list = POISONS_BY_GROUP[groupID]
	if not list then
		return nil
	end
	local playerLevel = ns.cachedPlayerLevel or 1
	for _, entry in ipairs(list) do
		if entry[2] <= playerLevel and C_Item.GetItemCount(entry[1]) > 0 and not ns.IsIgnored(entry[1]) then
			return entry[1]
		end
	end
	return nil
end

--[[
    The player's group pick for one hand, resolved to its best usable item.
    hand is "main" or "off"; the group falls back to Instant Poison (4),
    matching ns.DATABASE_DEFAULTS.
]]
local function BestPoisonForHand(hand)
	local settings = ns.db and ns.db.profile
	local key = (hand == "off") and "offHandPoisonGroup" or "mainHandPoisonGroup"
	return FindBestPoison((settings and settings[key]) or 4)
end

--[[
    Resolved poison for one hand as (itemID, itemLink), for the minimap
    tooltip. Resolved on demand rather than published the way ns.bestPetFoodID
    is: the answer tracks bag contents, which change without a macro rebuild,
    and there is no rebuild at all while the Poisons macro is disabled.
]]
function ns.GetBestPoisonForHand(hand)
	local id = BestPoisonForHand(hand)
	if not id then
		return nil, nil
	end
	return id, select(2, C_Item.GetItemInfo(id))
end

local function KnowsPoisons()
	return ns.IsSpellKnown(ns.POISONS_SPELL_ID) or ns.IsPlayerSpell(ns.POISONS_SPELL_ID)
end

--------------------------------------------------------------------------------
-- Poisons Macro Body
--------------------------------------------------------------------------------

--[[
    Four body shapes:

      no Poisons skill → tip-only stub ("You don't currently know Poisons.")
      neither hand     → crafting middle-click + "no suitable Poison found"
      one hand missing → working hand keeps its branch; the missing hand's
                         click prints TIP_NO_HAND_POISON via ConnoisseurTipIf and halts
      both hands       → the full dual-apply body

    [btn:2] is the Main Hand branch; everything that isn't btn:2/btn:3 —
    left-click and keybind presses (which register as left-click, see
    Macros/Explosive.lua) — is the Off Hand branch, tested as [btn:1].
]]
local function BuildPoisonsBody(knows, mainID, offID)
	local tooltipID = mainID or offID or ns.MACRO_DEFAULT_ITEM_IDS["Poisons"]
	local lines = { "#showtooltip item:" .. tooltipID }

	if not knows then
		lines[#lines + 1] = '/run ConnoisseurTip("noPoisonsSkill")'
		return table.concat(lines, "\n")
	end

	local poisonsName = C_Spell.GetSpellName(ns.POISONS_SPELL_ID)
	if poisonsName then
		lines[#lines + 1] = "/cast [btn:3] " .. poisonsName
		lines[#lines + 1] = "/stopmacro [btn:3]"
	end

	if not mainID and not offID then
		lines[#lines + 1] = '/run ConnoisseurNoItem("Poisons")'
		return table.concat(lines, "\n")
	end

	if not mainID then
		lines[#lines + 1] = '/run ConnoisseurTipIf("[btn:2]","noHandPoison")'
		lines[#lines + 1] = "/stopmacro [btn:2]"
	elseif not offID then
		lines[#lines + 1] = '/run ConnoisseurTipIf("[btn:1]","noHandPoison")'
		lines[#lines + 1] = "/stopmacro [btn:1]"
	end

	if mainID and offID then
		lines[#lines + 1] = "/use [btn:2] item:" .. mainID .. "; item:" .. offID
		lines[#lines + 1] = "/use [btn:2] 16; 17"
	elseif mainID then
		lines[#lines + 1] = "/use item:" .. mainID
		lines[#lines + 1] = "/use 16"
	else
		lines[#lines + 1] = "/use item:" .. offID
		lines[#lines + 1] = "/use 17"
	end

	lines[#lines + 1] = "/click StaticPopup1Button1"
	lines[#lines + 1] = "/run UIErrorsFrame:Clear()"

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Poisons Update
--------------------------------------------------------------------------------

local function UpdatePoisonsMacro(forced)
	if forced then
		currentPoisonState = nil
	end

	local config = MACRO_CONFIG["Poisons"]
	if not config then
		return
	end

	local knows = KnowsPoisons()
	local mainID = knows and BestPoisonForHand("main") or nil
	local offID = knows and BestPoisonForHand("off") or nil

	--[[
	    Every input that affects the body: skill knowledge, and the resolved
	    item per hand (which already encodes the group picks and bag
	    contents). Same lossless-key rule as the engine's standard keys.
	]]
	local stateID = (knows and "K" or "NK")
		.. "_"
		.. (mainID and tostring(mainID) or "none")
		.. "_"
		.. (offID and tostring(offID) or "none")

	if currentPoisonState == stateID and not forced then
		return
	end

	local body = BuildPoisonsBody(knows, mainID, offID)

	-- On a failed create, leave the state unset so the next update retries.
	if not ns.WriteMacroBody(config.macro, body) then
		currentPoisonState = nil
		return
	end

	currentPoisonState = stateID
end

--------------------------------------------------------------------------------
-- Definition
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Poisons",

	customUpdate = function(forced)
		if not ns.isRogue then
			return
		end
		if ns.IsMacroEnabled("Poisons") then
			UpdatePoisonsMacro(forced)
		else
			local config = MACRO_CONFIG["Poisons"]
			if config then
				ns.DeleteMacroByName(config.macro)
				ns.ResetPoisonMacroState()
			end
		end
	end,
})
