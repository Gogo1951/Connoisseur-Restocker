local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
    Readiness -- the Readiness Report. When a ready check starts, prints a
    private list of what still needs fixing. Nothing is ever sent to group chat;
    this add-on has no sent-chat path at all (see Features/Announcements.lua).

    SILENCE IS THE DEFAULT OUTPUT. A section with nothing wrong is not printed,
    and a report with no sections is not printed at all -- there is no all-clear
    line. That is the whole reason the report can afford to cover this much: a
    prepared player sees nothing, so the only reports anyone reads are the ones
    that need reading. Never add a line that fires when something is FINE.

    Shape, one print per line, each dropped when empty:

        Connoisseur // Readiness Report
        Connoisseur // Missing Buffs : ... . Expiring Soon : ...
        Connoisseur // Missing Items : ... . Damaged Gear : ...
        Connoisseur // Character : ... . Non-combat Gear Equipped : ...

    Every line goes through ns.PrintMessage, so every line carries the brand --
    the same shape the Restock List's own reports print in, where a headline is
    followed by branded detail lines. A report is several prints rather than one
    message, and a chat window interleaves other add-ons between them, so a body
    line with no brand on it reads as coming from somewhere else.

    Each category answers to its own account-wide switch, all of them dead while
    the master switch is off; see Data/Default-Settings.lua for the defaults.

    Inside a PvP Arena the report drops its buff, expiring and missing-item
    clauses and keeps what the prep room can still fix; see
    ns.BuildReadinessLines.
]]

--------------------------------------------------------------------------------
-- Line Assembly
--------------------------------------------------------------------------------

--[[
    One "Label : a, b, c" clause. Line joins clauses with
    READINESS_CLAUSE_SEPARATOR, so a clause never carries its own trailing stop.
]]
local function Clause(label, values)
	if #values == 0 then
		return nil
	end
	return string.format(
		L["READINESS_CLAUSE_FORMAT"],
		GetColor("TITLE") .. label .. "|r",
		GetColor("TEXT") .. table.concat(values, L["LIST_SEPARATOR"]) .. "|r"
	)
end

--[[
    A report line from its clauses, or nil when every one of them was empty.

    The clause colours sit INSIDE what ns.PrintMessage wraps in C_TEXT. A |r
    resets to the default rather than to the enclosing colour, which is why each
    clause re-opens C_TEXT after its label instead of relying on the wrapper's.
]]
local function Line(...)
	local clauses = {}
	for index = 1, select("#", ...) do
		local clause = select(index, ...)
		if clause then
			clauses[#clauses + 1] = clause
		end
	end
	if #clauses == 0 then
		return nil
	end
	return table.concat(clauses, GetColor("SEPARATOR") .. L["READINESS_CLAUSE_SEPARATOR"] .. "|r")
end

--------------------------------------------------------------------------------
-- Missing Buffs
--------------------------------------------------------------------------------

--[[
    Walks every group member, the player included. Raid unit ids already cover
    the player, party ids do not, so the player is tested up front and the loop
    length differs between the two.
]]
local function AnyGroupMember(test)
	if test("player") then
		return true
	end

	local members = GetNumGroupMembers() or 0
	local inRaid = IsInRaid()
	local prefix = inRaid and "raid" or "party"
	local count = inRaid and members or (members - 1)

	for index = 1, count do
		if test(prefix .. index) then
			return true
		end
	end

	return false
end

--[[
    Whether anyone present is of a class, the player included -- AnyGroupMember
    tests "player" first, so "in the group" always covers "is you".

    Two entries ask this. A Warlock is who produces a Healthstone, so with none
    present it is not actionable. A Shaman is who makes the weapon-buff line
    moot; see its caller.
]]
local function GroupHasClass(classToken)
	return AnyGroupMember(function(unit)
		return select(2, UnitClass(unit)) == classToken
	end)
end

--[[
    The soulstone aura's own localized name, resolved once from whichever id in
    ns.SOULSTONE_BUFF_SPELL_IDS the client answers for. Every rank shares one name,
    so this single string covers them all -- including a rank whose id is wrong
    or missing from that list, which is why the name pass exists at all. `false`
    is the cached "asked and got nothing" answer, so a cold spell cache costs
    one lookup rather than one per aura per unit.
]]
local soulstoneBuffName

local function SoulstoneBuffName()
	if soulstoneBuffName == nil then
		soulstoneBuffName = false
		for _, spellID in ipairs(ns.SOULSTONE_BUFF_SPELL_IDS) do
			local name = C_Spell.GetSpellName(spellID)
			if name then
				soulstoneBuffName = name
				break
			end
		end
	end
	return soulstoneBuffName or nil
end

local SOULSTONE_BUFF_LOOKUP = {}
for _, spellID in ipairs(ns.SOULSTONE_BUFF_SPELL_IDS) do
	SOULSTONE_BUFF_LOOKUP[spellID] = true
end

local function UnitHasSoulstone(unit)
	if not UnitExists(unit) then
		return false
	end

	local wantedName = SoulstoneBuffName()
	for index = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex(unit, index, "HELPFUL")
		if not aura then
			return false
		end
		if SOULSTONE_BUFF_LOOKUP[aura.spellId] or (wantedName and aura.name == wantedName) then
			return true
		end
	end

	return false
end

--[[
    Whether a soulstone is UP on anyone in the group, which is the only thing a
    raid actually cares about. Deliberately NOT "does someone hold a stone":
    seven unused stones in seven bags resurrect nobody, and one deployed on the
    healer covers the pull.

    LIMITATION: the aura APIs only answer for members the client can see.
    Someone in another room or out of range reports no auras at all, so a stone
    on them reads as absent. That makes the failure a false "missing", never a
    false "all clear" -- and at a ready check the group is normally stacked up
    for the pull, which is the one moment this runs.
]]
local function GroupHasSoulstone()
	return AnyGroupMember(UnitHasSoulstone)
end

--[[
    Whether the stones' shared use cooldown is running, which is when no stone
    can go up however many the Warlock carries: after a stoned player rose, for
    the rest of the half hour since the stone was used. The stones share the
    one cooldown, so any of them on it answers. A cooldown the client keeps
    secret (Forever) counts as over, and the entry reports as it always has.
]]
local function SoulstonesOnCooldown()
	if C_Secrets.ShouldCooldownsBeSecret() then
		return false
	end
	for itemID in pairs(ns.SOULSTONES) do
		local _, duration = C_Container.GetItemCooldown(itemID)
		-- A stone on the global cooldown alone reads as on cooldown too: close enough, as it is ready by the next check.
		if duration and duration > 0 then
			return true
		end
	end
	return false
end

--[[
    Every buff answers to TWO switches: the profile's macro switch saying
    the character uses the thing at all, and the account-wide report switch
    saying to mention it. Both must be on, because reporting a buff the
    character never applies would be noise whatever the report is set to.
    Flask, weapon buffs and the group soulstone have no macro behind them, so
    they answer to their report switch alone.
]]
local function BuildMissingBuffs(settings, reports)
	local missing = {}

	--[[
	    TBC and later, which is a maintainer decision rather than a data one: Era
	    and Forever have flasks and elixirs, but they are not what an Era raid
	    runs on, so the line would be wrong for most of the people it fired at.
	    The option hides itself on Era and Forever to match
	    (Options/Options-Readiness-Report.lua).
	]]
	if reports.readinessFlask and ns.EXPANSION >= 2 and not ns.HasFlaskOrElixirs() then
		missing[#missing + 1] = L["READINESS_FLASK"]
	end

	if reports.readinessWellFed and settings.useBuffFood and ns.IsModeActive(settings.buffFoodMode) then
		local snapshot = ns.GetPlayerBuffSnapshot()
		if snapshot.wellFedExpiration == nil then
			missing[#missing + 1] = ns.GetWellFedName()
		end
	end

	--[[
	    The same gate the macro uses, so the report can only ask for a buff the
	    add-on would actually apply -- never from a Hunter too low for the food
	    to exist, and never for a dead pet, which is a resurrection problem
	    rather than a feeding one.
	]]
	if reports.readinessPetWellFed and ns.ShouldTrackPetFood() and ns.GetPetFoodBuffExpiration() == nil then
		missing[#missing + 1] = string.format(L["READINESS_PET_FORMAT"], ns.GetWellFedName())
	end

	--[[
	    Coverage is settled from the aura snapshot, never from
	    ns.scrollOverrideIDs alone: that list holds only scrolls the player has
	    in bags, so someone missing the buffs with no scrolls to fire would read
	    as covered. A type counts as covered by its own scroll buff or by a
	    conflicting class buff.
	]]
	if reports.readinessScrolls and settings.useScrolls and ns.IsModeActive(settings.scrollsMode) then
		local snapshot = ns.GetPlayerBuffSnapshot()
		local uncovered = false
		for scrollType, enabled in pairs(settings.scrollTypes or {}) do
			if enabled then
				local entry = snapshot.scrolls[scrollType]
				if not (entry and (entry.expiration or entry.conflictAmount)) then
					uncovered = true
				end
			end
		end
		if uncovered or (ns.scrollOverrideIDs and #ns.scrollOverrideIDs > 0) then
			missing[#missing + 1] = L["READINESS_SCROLLS"]
		end
	end

	--[[
	    The one entry that asks the GROUP rather than the player: is a stone up
	    on anyone. Only a Warlock who knows Create Soulstone sees it, because
	    only they can put one up, and only while the stones' cooldown lets them.
	    Anyone else would be reading a nag they cannot clear.
	]]
	if
		reports.readinessSoulstone
		and ns.isWarlock
		and ns.KnowsAny(ns.CONJURE_SPELLS.WarlockCreateSoulstone)
		and not GroupHasSoulstone()
		and not SoulstonesOnCooldown()
	then
		missing[#missing + 1] = L["READINESS_SOULSTONE"]
	end

	--[[
	    Any temporary enchant counts -- a stone, an oil, a poison, a shaman
	    imbue -- because GetWeaponEnchantInfo answers whether the slot carries
	    one without caring which.

	    A SHAMAN IN THE GROUP SATISFIES THE MAIN HAND, and only the main hand:
	    that is the slot their buff answers for, so with one present the line
	    stops being a thing the player has to act on. The off hand asks the
	    same question with no such exemption. Resolved once for the pair rather
	    than per slot, so the group walk runs at most once per report.
	]]
	if reports.readinessMainHandBuff or reports.readinessOffHandBuff then
		local mainHandMissing, offHandMissing = ns.GetMissingWeaponBuffs()
		if reports.readinessMainHandBuff and mainHandMissing and not GroupHasClass("SHAMAN") then
			missing[#missing + 1] = MAINHANDSLOT
		end
		if reports.readinessOffHandBuff and offHandMissing then
			missing[#missing + 1] = SECONDARYHANDSLOT
		end
	end

	return missing
end

--[[
    Buffs about to lapse, named with whole minutes left. Under a minute reads as
    its own phrase rather than "0 min", which would look like a bug.
]]
local function BuildExpiring(reports)
	local expiring = {}

	if not reports.readinessExpiring then
		return expiring
	end

	local threshold = reports.readinessExpiringThreshold
	for _, entry in ipairs(ns.GetExpiringBuffs(threshold)) do
		if entry.remaining < 60 then
			expiring[#expiring + 1] = string.format(L["READINESS_TIME_EXPIRING"], entry.name)
		else
			expiring[#expiring + 1] =
				string.format(L["READINESS_TIME_MINUTES"], entry.name, math.floor(entry.remaining / 60))
		end
	end

	return expiring
end

--------------------------------------------------------------------------------
-- Missing Items
--------------------------------------------------------------------------------

--[[
    Reads the winners from the last ScanBags pass (ns.bestSelection) rather than
    rescanning: the scan re-runs on every bag change under its own throttle, so
    the result is already current. A nil id means nothing usable was found.

    ScanBags fills every category whether or not its macro is enabled -- the
    enabled check lives in the macro writer, not the scanner -- so these read
    real bag contents, and a player who turned a macro off still gets a truthful
    answer about what they are carrying. An item on either Ignore List counts as
    carried too (ns.scannedIgnoredTypes): the report never names something the
    player has in their bags.
]]
local function CarryingNone(typeName)
	local selection = ns.bestSelection
	local entry = selection and selection[typeName]
	return entry ~= nil and entry.id == nil and not ns.scannedIgnoredTypes[typeName]
end

--[[
    The Mana Gem category can be won by a rune once the player adds runes to
    that macro, and a rune is not the gem this line asks a Mage to conjure, while
    enough runes can push a held gem out of the ranked slots. So the line looks
    for any gem in the last scan's bag counts instead. Silent before the first
    scan, like every item line.
]]
local function CarryingNoManaGem()
	local selection = ns.bestSelection
	if not (selection and selection["Mana Gem"]) then
		return false
	end
	local counts = ns.scannedItemCounts
	for gemID in pairs(ns.MANA_GEMS) do
		if (counts[gemID] or 0) > 0 then
			return false
		end
	end
	return true
end

local function BuildMissingItems(reports)
	local missing = {}

	--[[
	    The Healthstone carries a Warlock gate on top of its switch: with no Warlock
	    present to ask, a missing stone is not something the player can act on.
	]]
	if reports.readinessHealthstone and CarryingNone("Healthstone") and GroupHasClass("WARLOCK") then
		missing[#missing + 1] = L["READINESS_HEALTHSTONE"]
	end

	-- A Mage who can conjure one: anyone else could only ever read "missing".
	if
		reports.readinessManaGem
		and ns.isMage
		and ns.KnowsAny(ns.CONJURE_SPELLS.MageCreateManaGem)
		and CarryingNoManaGem()
	then
		missing[#missing + 1] = L["READINESS_MANA_GEM"]
	end

	if reports.readinessHealingPotion and CarryingNone("Health Potion") then
		missing[#missing + 1] = L["READINESS_HEALING_POTION"]
	end

	if reports.readinessManaPotion and ns.PlayerUsesMana() and CarryingNone("Mana Potion") then
		missing[#missing + 1] = L["READINESS_MANA_POTION"]
	end

	if reports.readinessBandages and CarryingNone("Bandage") then
		missing[#missing + 1] = L["READINESS_BANDAGES"]
	end

	return missing
end

--------------------------------------------------------------------------------
-- Character
--------------------------------------------------------------------------------

local function BuildCharacter(reports, inArena)
	local entries = {}

	if reports.readinessSpec then
		local spec = ns.GetCurrentSpecLabel()
		if spec then
			entries[#entries + 1] = spec
		end
		local unspent = ns.GetUnspentTalentPoints()
		if unspent == 1 then
			entries[#entries + 1] = L["READINESS_UNSPENT_TALENTS_ONE"]
		elseif unspent then
			entries[#entries + 1] = string.format(L["READINESS_UNSPENT_TALENTS_MANY"], unspent)
		end
	end

	-- Arenas and battlegrounds flag everyone, so the warning would be one nobody can clear.
	if reports.readinessPvP and not inArena and select(2, IsInInstance()) ~= "pvp" and ns.IsPvPFlagged() then
		entries[#entries + 1] = L["READINESS_PVP_ON"]
	end

	return entries
end

--------------------------------------------------------------------------------
-- Readiness Report
--------------------------------------------------------------------------------

--[[
    The report's body lines, or nil when there is nothing to say.

    Split from the printing so Diagnostic Tools can render the same answer on
    demand, without waiting for a ready check. That is the only way to tell the
    report's two silences apart -- "you are ready" and "it never ran" look
    identical in a chat window, which is exactly how long a silent failure can
    hide.

    Deliberately ignores the master switch: this answers what the report WOULD
    say, and the caller decides whether it is allowed to say it.

    inArena applies the arena rule. Arenas block potions, buff food and
    scrolls, and flag every player for PvP. The Missing Buffs, Expiring Soon
    and Missing Items clauses and the PvP entry drop there; damaged gear, the
    spec and unspent points, and non-combat gear stay, because the prep room
    can still fix them.
]]
function ns.BuildReadinessLines(inArena)
	local reports = ns.db and ns.db.global
	local settings = ns.db and ns.db.profile
	if not (reports and settings) then
		return nil
	end

	local buffsLine
	local missingItems = {}
	if not inArena then
		buffsLine = Line(
			Clause(L["READINESS_MISSING_BUFFS"], BuildMissingBuffs(settings, reports)),
			Clause(L["READINESS_EXPIRING"], BuildExpiring(reports))
		)
		missingItems = BuildMissingItems(reports)
	end

	local damaged = reports.readinessDurability and ns.GetDamagedGear(reports.readinessDurabilityThreshold) or {}
	local itemsLine =
		Line(Clause(L["READINESS_MISSING_ITEMS"], missingItems), Clause(L["READINESS_DAMAGED_GEAR"], damaged))

	local questionable = reports.readinessQuestionableGear and ns.GetQuestionableEquipment() or {}
	local characterLine = Line(
		Clause(L["READINESS_CHARACTER"], BuildCharacter(reports, inArena)),
		Clause(L["READINESS_QUESTIONABLE_GEAR"], questionable)
	)

	--[[
	    Nothing wrong, nothing said. nil rather than an empty table, so a caller
	    cannot accidentally print a header over no lines -- a prepared player
	    gets no output at all rather than an all-clear. See the note at the top
	    of this file before adding one.
	]]
	if not (buffsLine or itemsLine or characterLine) then
		return nil
	end

	--[[
	    Appended one at a time, never gathered with ipairs over a literal holding
	    all three: any of them can be nil, and ipairs stops dead at the first
	    hole -- so a report whose Buffs line was empty would return the Items and
	    Character lines as an EMPTY list, print its header, and say nothing under
	    it. The guard above already guarantees at least one survives.
	]]
	local lines = {}
	if buffsLine then
		lines[#lines + 1] = buffsLine
	end
	if itemsLine then
		lines[#lines + 1] = itemsLine
	end
	if characterLine then
		lines[#lines + 1] = characterLine
	end
	return lines
end

--[[
    Routed from Core's dispatcher on READY_CHECK. Owns the master switch, the
    gate that decides whether the report is allowed to speak at all, and hands
    ns.BuildReadinessLines the live arena test; what it would say is that
    function's business.

    THERE IS NO GROUP TEST, deliberately: a ready check cannot be STARTED outside
    a group, so the event never arrives solo and such a test could never be false
    here. Every group-dependent entry already gates on the relevant class being
    present.

    While the client restricts aura data (Forever, typically a ready check
    fired mid-pull), every aura field comes back secret and comparing one
    errors, so the report stays silent and the next ready check reports.
]]
function ns.OnReadyCheck()
	local reports = ns.db and ns.db.global
	if not (reports and reports.readinessReportEnabled) then
		return
	end
	if C_Secrets.ShouldAurasBeSecret() then
		return
	end

	local lines = ns.BuildReadinessLines(select(2, IsInInstance()) == "arena")
	if not lines then
		return
	end

	ns.PrintMessage(L["READINESS_TITLE"])
	for _, line in ipairs(lines) do
		ns.PrintMessage(line)
	end
end
