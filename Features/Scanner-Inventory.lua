local _, ns = ...

--[[
    Scanner-Inventory -- scans the player's bags and selects the best item per
    macro category, applying scoring, ranking, and usability gates. WHAT each
    category consumes and HOW it scores is declared by the macro definitions
    themselves (itemTypes / accepts / score / ranked / ... — see the
    definition protocol in Features/Macros/Engine.lua); this file owns the
    shared machinery: the usability gates, the RANKING_PRIORITY tiebreak
    ladder, and the scan loop that dispatches each bag item to every matching
    definition.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

ns.bestFoodID = nil
ns.bestFoodLink = nil

--------------------------------------------------------------------------------
-- Best Item Tracking
--------------------------------------------------------------------------------

--[[
    Per-category winner records and ranked-candidate lists, built from the
    definition registry (ns.REGISTERED_MACRO_DEFINITIONS) instead of hardcoded here:
    every registered definition with an itemTypes set gets a winner record,
    and ranked definitions also get a topIDs list plus a candidate
    collector. Definitions register from Features/Macros/*.lua, which load
    after this file, so the tables are built lazily on the first scan
    (BuildSelectionTables below) — every scan happens long after load.
]]
local best = {}

--[[
    Expose the scanner's live best table for diagnostics. ScanBags resets and
    repopulates these entries in place every pass, so the reference always
    reflects the last scan. Read-only for consumers (Diagnostics' context
    report); the scanner itself owns all writes. This is what lets the context
    report show the per-category winner for every type, not just bestFoodID.
]]
ns.bestSelection = best

local rankedCandidates = {}

local function ResetBest(entry)
	entry.id = nil
	entry.value = 0
	entry.price = 0
	entry.count = 0
	entry.link = nil
	entry.isBuffFood = false
	entry.isPercent = false
	entry.isHybrid = false
	entry.isConjured = false
	entry.hasZones = false
	entry.isSoulbound = false
	entry.isHighStack = false
	entry.isOffRestockList = false
	if entry.topIDs then
		wipe(entry.topIDs)
	end
end

local selectionTablesBuilt = false

local function BuildSelectionTables()
	if selectionTablesBuilt then
		return
	end
	selectionTablesBuilt = true
	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
		if definition.itemTypes then
			local entry = {}
			if definition.ranked then
				entry.topIDs = {}
				rankedCandidates[definition.typeName] = {}
			end
			ResetBest(entry)
			best[definition.typeName] = entry
		end
	end
end

--------------------------------------------------------------------------------
-- Comparison Logic
--------------------------------------------------------------------------------

--[[
    RANKING_PRIORITY is the single source of truth for how consumables are
    ranked. Both comparator forms — IsBetter's single-winner test and the
    ranked lists' pairwise sort (CompareRankedCandidates) — are generated from
    this one ordered list by CompareRecords, so reordering a step here is the
    only edit needed to change the ranking everywhere.

    Step shape:
      field — record field to compare
      kind  — "bool" (truthy side wins), "higher", or "lower"
      gatedOnAllowBuffFood       — step runs only when the caller allows buff
                                   food (the Food macro path)
      gatedOnAllowConjuredFirst  — step runs only when the caller allows
                                   conjured-first (Food and Water, while Use
                                   Conjured Food & Water First holds)
      gatedOnAllowRestockLast    — step runs only when the caller allows
                                   restock-last (Food and Water, while Use
                                   Restock List Food & Water Last holds)
      truthyWinsWhenPreferHybrid — direction flag for the hybrid step: truthy
                                   wins when the caller prefers hybrids (Food);
                                   falsy wins otherwise (Water, ranked potions)

    Boolean fields are compared RAW (~=), never coerced. Both sides are
    FillRecord output, built from the item cache's own true/false flags, so a
    nil never reaches a step; a new flag has to keep that true.
]]

local RANKING_PRIORITY = {
	-- Buff food first when the Food macro wants one.
	{ field = "isBuffFood", kind = "bool", gatedOnAllowBuffFood = true },

	--[[
	    Conjured food and water next, when the player asked for it (Use
	    Conjured Food & Water First, on Food and Water only). The one place
	    a burn-first reason outranks the restore steps, and only by that
	    choice: conjured items cost nothing and vanish at logout, so a player
	    handed a weaker conjured water would rather drink it than buy the
	    vendor one. Buff food stays above it so Buff Food still lands Well
	    Fed. Gated off, the ordinary isConjured tiebreak below still applies.
	]]
	{ field = "isConjured", kind = "bool", gatedOnAllowConjuredFirst = true },

	-- Percent-based restores beat flat values.
	{ field = "isPercent", kind = "bool" },

	--[[
	    Higher restore/damage, raw from the item data. No bonuses are folded
	    in, so this compares exactly what the item restores.
	]]
	{ field = "value", kind = "higher" },

	--[[
	    Off the Restock List next, when the player asked for it (Use Restock
	    List Food & Water Last, on Food and Water only): of two items that
	    restore the same amount, eat the one not on the Restock List, and
	    keep the list's stock for later. Below value, so it never picks
	    the weaker item.
	]]
	{ field = "isOffRestockList", kind = "bool", gatedOnAllowRestockLast = true },

	--[[
	    THE BURN-FIRST LADDER. Three tiebreaks among items that restore the
	    SAME amount, ordered by SHELF LIFE -- spend the copy that will be
	    worth the least to you soonest:

	      isConjured  -- gone at logout, so its shelf life is this session
	                     and nothing else on the list expires on a timer.
	                     Free to replace, too, so spending it costs nothing.
	      hasZones    -- survives logout, but is dead weight the moment you
	                     leave the zone. Spend it while it still does
	                     something.
	      isSoulbound -- keeps its value indefinitely, but only for THIS
	                     character: it cannot be mailed to an alt, traded,
	                     or sold.

	    Then price, then isHighStack -- both below, with their own notes. They
	    rank lower because neither is about shelf life: an item that vendors
	    for nothing has simply already lost its gold value, and stack size is
	    pure bag economy.

	    This ORDER is the whole specification. Moving a line changes the
	    preference; nothing else needs to change with it.

	    They sit BELOW value deliberately. Promote any of them above it and a
	    zone-locked Superior Mana Draught (560) beats a Super Mana Potion
	    (1800) in a battleground -- "worthless elsewhere" is a reason to spend
	    a tie, never a reason to drink the weaker potion.

	    The three above plus isHighStack are ladder steps, never numeric
	    bonuses added into value: a bonus can outweigh a genuine restore
	    difference of 1 or 2, and two equal bonuses cancel each other instead
	    of ranking.

	    Uniform inside a category is a no-op, which covers most of them:
	    zones and binding only really vary across the potion and bandage
	    families. Note isConjured is set from the food/water data alone, so
	    every healthstone, soulstone and mana gem candidate reads false,
	    conjured or not -- harmless, because a step that reads the same for
	    every candidate in a category never separates two of them.
	]]
	{ field = "isConjured", kind = "bool" },
	{ field = "hasZones", kind = "bool" },
	{ field = "isSoulbound", kind = "bool" },

	--[[
	    Cheaper wins, and it sits ABOVE isHighStack because a 0 here does not
	    mean "cheap", it means the item has NO vendor price at all: drinking
	    it forgoes nothing, which outweighs any bag-space argument. The
	    Auchenai potions are the live case -- they vendor for nothing, so
	    they burn ahead of the injectors.

	    A separate "has no sell price" step would be redundant. Ascending
	    price already sorts the zero-price items to the front; the only thing
	    that ever kept them behind was isHighStack outranking this step.
	]]
	{ field = "price", kind = "lower" },

	--[[
	    Bag economy, and the weakest reason on the list: injectors (stack 20)
	    ahead of the potions they are made from spares the reagents and the
	    slot. Last of the burn-first steps, so it only separates items already
	    equal on restore, shelf life AND price.
	]]
	{ field = "isHighStack", kind = "bool" },

	--[[
	    Hybrid food/water: the Food macro prefers hybrids; Water and the
	    ranked potion lists prefer dedicated items.
	]]
	{ field = "isHybrid", kind = "bool", truthyWinsWhenPreferHybrid = true },

	-- Fewer copies in bags: burn the smaller pile first.
	{ field = "count", kind = "lower" },

	--[[
	    Final, never-equal tiebreak. Without it, two items that match on every
	    other field compare equal, so the winner is whichever the pairs() scan
	    over slotItems happened to reach first. That order is not stable
	    between an in-session rescan (a wiped-and-rebuilt table) and a fresh
	    table after /reload, so the selection could flip for identical bags —
	    the item would only "update" after a reload. Comparing itemID last
	    makes the pick deterministic, so a buy-triggered rescan and a reload
	    always agree; it also keeps table.sort's instability from reordering
	    equal ranks between scans and churning macro rewrites.
	]]
	{ field = "id", kind = "lower" },
}

--[[
    Returns true when record `a` outranks record `b` under RANKING_PRIORITY,
    plus the field name of the step that decided it (nil when every step
    compared equal). Only the diagnostics Selection Report reads the second
    value -- it is what turns "this item lost" into "it lost on price" -- and
    returning it costs nothing on the hot path, but every other caller must
    take the first value alone so the extra return can never leak into a
    boolean or a table constructor.
]]
local function CompareRecords(a, b, allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
	for i = 1, #RANKING_PRIORITY do
		local step = RANKING_PRIORITY[i]
		if
			not (step.gatedOnAllowBuffFood and not allowBuffFood)
			and not (step.gatedOnAllowConjuredFirst and not allowConjuredFirst)
			and not (step.gatedOnAllowRestockLast and not allowRestockLast)
		then
			local valueA, valueB = a[step.field], b[step.field]
			if valueA ~= valueB then
				if step.kind == "higher" then
					return valueA > valueB, step.field
				elseif step.kind == "lower" then
					return valueA < valueB, step.field
				elseif step.truthyWinsWhenPreferHybrid and not preferHybrid then
					return not valueA, step.field
				else
					return (valueA and true or false), step.field
				end
			end
		end
	end
	return false, nil
end

--[[
    THE one place a comparison field is derived. The running winner, the
    ranked candidate lists and the diagnostics retention all fill through
    here, so both sides of every comparison are built the same way by
    construction -- there is no second reading of an item to drift from the
    first. A new ladder step goes in the step list above, this function,
    ResetBest and CopyCandidateRecord; README-Technical.md's "Adding a New
    Ranking Step" has the whole checklist.

    score arrives as a parameter rather than being read off the item because
    each category picks its own field (health, mana, damage) in its score()
    hook. isOffRestockList reads scanRestockList, the current Restock List
    ScanBags captures before its bag walk.
]]
local scanRestockList = {}

local function FillRecord(record, candidate, candidateCount, candidatePrice, score)
	record.isBuffFood = candidate.isBuffFood
	record.isPercent = candidate.isPercent
	record.value = score
	record.isConjured = candidate.isConjured
	record.hasZones = (candidate.zones ~= nil)
	record.isSoulbound = candidate.isSoulbound
	record.isHighStack = (candidate.maxStack or 1) > 10
	record.isOffRestockList = (scanRestockList[candidate.itemID] == nil)
	record.price = candidatePrice
	record.isHybrid = (candidate.healthValue > 0 and candidate.manaValue > 0)
	record.count = candidateCount
	record.id = candidate.itemID
	return record
end

--[[
    Single-winner form: does this bag item beat the current best entry? Both
    sides are FillRecord output, so CompareRecords reads the same field names
    on each. The scratch record is reused across the whole scan -- FillRecord
    writes every field, so nothing leaks from one candidate to the next.
]]
local candidateRecord = {}

local function IsBetter(
	candidate,
	candidateCount,
	candidatePrice,
	currentBest,
	score,
	allowBuffFood,
	preferHybrid,
	allowConjuredFirst,
	allowRestockLast
)
	if not currentBest.id then
		return true
	end

	-- First value only: CompareRecords also returns the deciding field.
	local better = CompareRecords(
		FillRecord(candidateRecord, candidate, candidateCount, candidatePrice, score),
		currentBest,
		allowBuffFood,
		preferHybrid,
		allowConjuredFirst,
		allowRestockLast
	)
	return better
end

--------------------------------------------------------------------------------
-- Ranked Candidates (Multi-Use Macros)
--------------------------------------------------------------------------------

--[[
    The ranked definitions (ranked = true — the ns.MULTI_USE_MACRO_TYPES
    categories) stack up to ns.MULTI_USE_MAX_ITEMS /use lines per macro, so
    instead of tracking a single running winner they collect every usable
    candidate during the scan into rankedCandidates (declared above, keyed
    by typeName from the registry) and are ranked once it completes. The
    other categories keep the single-winner IsBetter path.
]]

local function AddRankedCandidate(typeName, data, score, count)
	local list = rankedCandidates[typeName]
	list[#list + 1] = FillRecord({}, data, count, data.price, score)
end

--[[
    Pairwise sort form for the ranked categories — the same RANKING_PRIORITY
    chain with allowBuffFood, preferHybrid, allowConjuredFirst and
    allowRestockLast always false: percent heals first, then higher value,
    the burn-first steps, price, non-hybrid, fewer copies, itemID. Ranked
    records come from FillRecord like every other record, so the isBuffFood,
    conjured-first and restock-last steps are gated off rather than absent.
]]
local function CompareRankedCandidates(a, b)
	-- First value only: table.sort must see a plain boolean comparator.
	local outranks = CompareRecords(a, b, false, false, false, false)
	return outranks
end

local function RankCandidates()
	for typeName, list in pairs(rankedCandidates) do
		table.sort(list, CompareRankedCandidates)

		local entry = best[typeName]
		local winner = list[1]
		if winner then
			entry.id = winner.id
			entry.value = winner.value
			entry.price = winner.price
			entry.count = winner.count
		end
		for rank = 1, math.min(#list, ns.MULTI_USE_MAX_ITEMS) do
			entry.topIDs[rank] = list[rank].id
		end
	end
end

--------------------------------------------------------------------------------
-- Diagnostic Candidate Retention
--------------------------------------------------------------------------------

--[[
    Feeds the Diagnostic Tools Selection Report, which answers "why that item
    and not this one." Every category keeps its top few candidates with the
    RANKING_PRIORITY step that separated each from the winner.

    Retention runs only while ns.diagnostics.enabled is true, so normal play
    pays one boolean test per candidate and nothing else. The table is runtime
    only: it hangs off ns, is wiped at the start of every scan, and is never
    declared in the defaults or written to SavedVariables.

    Ranked categories need no retention of their own -- RankCandidates already
    sorts their full candidate list into final order, so the runners-up are the
    entries below the winner and CaptureDiagnosticCandidates just copies them.
    Only the single-winner categories, which keep no list, retain as they scan.

    Retention ranks candidates against each other, while the selection ranks
    each candidate against the winner record in `best`. The two agree because
    FillRecord populates both, so no definition has to remember to copy a
    comparison field onto its winner for the two views to stay in step.
]]
local DIAGNOSTIC_CANDIDATE_LIMIT = 5

local diagnosticCandidates = {}
ns.diagnosticCandidates = diagnosticCandidates

--[[
    Carries EVERY field RANKING_PRIORITY compares. A field left out does not
    make its step neutral -- it makes the step decide: a real boolean tests
    unequal to a missing one, so the retained ordering tips on the gap, and two
    copies compared against each other skip the step entirely and report a
    lower one as the decider. Add a ladder step, add it here.
]]
local function CopyCandidateRecord(record)
	return {
		id = record.id,
		value = record.value,
		price = record.price,
		count = record.count,
		isBuffFood = record.isBuffFood,
		isPercent = record.isPercent,
		isConjured = record.isConjured,
		hasZones = record.hasZones,
		isSoulbound = record.isSoulbound,
		isHighStack = record.isHighStack,
		isHybrid = record.isHybrid,
		isOffRestockList = record.isOffRestockList,
	}
end

local function GetCandidateList(typeName)
	local list = diagnosticCandidates[typeName]
	if not list then
		list = {}
		diagnosticCandidates[typeName] = list
	end
	return list
end

--[[
    Ordered insert capped at DIAGNOSTIC_CANDIDATE_LIMIT, ranked by the same
    comparator the selection ran, so entry 1 is always the category's winner
    and the entries below it are the real runners-up rather than whichever
    items the bag walk happened to reach first.
]]
local function RetainCandidate(typeName, record, allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
	local list = GetCandidateList(typeName)

	local position = #list + 1
	for i = 1, #list do
		local outranks =
			CompareRecords(record, list[i], allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
		if outranks then
			position = i
			break
		end
	end

	if position > DIAGNOSTIC_CANDIDATE_LIMIT then
		return
	end

	table.insert(list, position, CopyCandidateRecord(record))
	list[DIAGNOSTIC_CANDIDATE_LIMIT + 1] = nil
end

--[[
    Runs once per scan, after RankCandidates has settled the ranked lists:
    copies the ranked categories' runners-up, then annotates every retained
    runner-up with the step that separated it from its category's winner.
    Ranked categories always compare with buff food, hybrid preference,
    conjured-first and restock-last off, matching CompareRankedCandidates.
]]
local function CaptureDiagnosticCandidates()
	if not ns.diagnostics.enabled then
		return
	end

	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
		local list
		local allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast

		if definition.ranked then
			local source = rankedCandidates[definition.typeName]
			list = GetCandidateList(definition.typeName)
			for i = 1, math.min(#source, DIAGNOSTIC_CANDIDATE_LIMIT) do
				list[i] = CopyCandidateRecord(source[i])
			end
			allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast = false, false, false, false
		else
			list = diagnosticCandidates[definition.typeName]
			allowBuffFood = definition.allowBuffFood and ns.allowBuffFood
			preferHybrid = definition.preferHybrid
			allowConjuredFirst = definition.allowConjuredFirst and ns.allowConjuredFirst
			allowRestockLast = definition.allowRestockLast and ns.allowRestockLast
		end

		if list then
			local winner = list[1]
			for i = 2, #list do
				local _, decidedBy =
					CompareRecords(winner, list[i], allowBuffFood, preferHybrid, allowConjuredFirst, allowRestockLast)
				list[i].decidedBy = decidedBy
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Bag Scanning
--------------------------------------------------------------------------------

local itemCounts = {}
local slotItems = {}
local ignoredTypes = {}

--[[
    The bag walk, published so a second consumer does not have to repeat it.
    itemCounts is stack totals by itemID across bags 0..NUM_BAG_SLOTS; slotItems
    is one hyperlink per itemID, from the first slot holding it; ignoredTypes
    names every category a usable item on either Ignore List would have
    competed in, so the Readiness Report can count it as carried.

    Assigned once here, and wiped-and-refilled in place by every scan, so the
    reference stays valid while the contents do not: these are the LAST scan's
    snapshot and are only current inside the update pass that produced them.
    Read them, never retain them, and never write to them from outside ScanBags.
]]
ns.scannedItemCounts = itemCounts
ns.scannedItemLinks = slotItems
ns.scannedIgnoredTypes = ignoredTypes

function ns.ScanBags()
	--[[
	    Refresh the zone at scan time. A zone change during combat is gated out
	    by the lockdown guard in Core's dispatcher, so ZONE_CHANGED_NEW_AREA
	    never updates the cache mid-fight; reading it here keeps zone-restricted
	    item filtering from running against a stale map after combat drops.
	]]
	ns.cachedMapID = C_Map.GetBestMapForUnit("player")

	--[[
	    Party/raid-restricted Buff Food, Scrolls, and Pet Food go stale when
	    group composition or the mode dropdown changes — those flip whether a
	    feature is active but have no dedicated UpdateAuraTracking call, so
	    ns.wellFedState and UNIT_AURA registration would otherwise drift.
	    ScanBags is the single point every rescan passes through, so reconcile
	    aura tracking here, before allowBuffFood reads ns.wellFedState below.
	    The snapshot it takes is handed on to ns.FindScrollOverrides, so a scan
	    walks the player's auras once. Nothing between here and that call may
	    take another snapshot: the buffer is shared (see ns.GetPlayerBuffSnapshot).
	]]
	local buffSnapshot = ns.UpdateAuraTracking()

	local playerLevel = ns.cachedPlayerLevel
	local currentMap = ns.cachedMapID
	--[[
	    Arena-only consumables (e.g. Star's Tears) are gated on the live
	    instance type instead of a zone-ID list, so every arena is covered with
	    no map IDs to maintain. IsInInstance is safe on Era (returns "none").
	    ScanBags re-runs on PLAYER_ENTERING_WORLD and ZONE_CHANGED_NEW_AREA, so
	    this refreshes on every arena entry and exit.
	]]
	local inArena = select(2, IsInInstance()) == "arena"
	local firstAidSkill = ns.currentFirstAidSkill or 0
	local alchemySkill = ns.currentAlchemySkill or 0
	local engineeringSkill = ns.currentEngineeringSkill or 0
	local settings = (ns.db and ns.db.profile) or {}
	local itemCache = (ns.db and ns.db.profile.itemCache) or {}

	--[[
	    Testing aid: targeting yourself forces the Food macro into plain-food
	    mode — no scrolls, no buff food, just the best non-buff food. Useful
	    for verifying what the macro picks without re-toggling settings.
	    Scrolls are already suppressed on any friendly-player target (including
	    self) in UpdateMacros, so we only need to disable buff-food here. On
	    Forever the comparison can come back secret, so C_Secrets is asked first
	    and a restricted read counts as not targeting yourself.
	]]
	local targetingSelf = C_Secrets.CanCompareUnitTokens("target", "player")
		and UnitExists("target")
		and UnitIsUnit("target", "player")

	--[[
	    Arena rule: scrolls, pet buff food, and buff food cannot be consumed in
	    a PvP Arena, so the Food macro must stay in plain (non-buff) food mode
	    there. Buff-food preference is gated here; the scroll and pet-buff
	    override resolvers are gated below.
	]]
	ns.allowBuffFood = settings.useBuffFood
		and ns.IsModeActive(settings.buffFoodMode)
		and not ns.wellFedState
		and not targetingSelf
		and not inArena

	--[[
	    Use Conjured Food & Water First: the setting and its mode, from the
	    list Buff Food's shares (the default "leveling" means below max level).
	    Group reads join the group signature and a level-up rebuilds every
	    macro, so a mode flipping always rescans. It needs no arena or self-target exception: an arena already
	    leaves only conjured food and water and the arena drinks, and
	    targeting yourself is the buff-food testing aid.
	]]
	ns.allowConjuredFirst = settings.useConjuredFirst and ns.IsModeActive(settings.conjuredFirstMode)

	--[[
	    Use Restock List Food & Water Last: no mode, on whenever ticked. The
	    current list is captured here for FillRecord; every list edit redraws
	    through ns.UpdateRestockList, which requests a rescan while it is on.
	]]
	ns.allowRestockLast = settings.useRestockLast
	local restockSettings = ns.restockSettings
	scanRestockList = restockSettings and restockSettings.lists and restockSettings.lists[restockSettings.currentList]
		or {}

	BuildSelectionTables()

	for _, entry in pairs(best) do
		ResetBest(entry)
	end

	for _, list in pairs(rankedCandidates) do
		wipe(list)
	end

	--[[
	    Wiped unconditionally, not just while diagnostics are enabled, so
	    turning the panel off leaves no stale candidate list behind for the
	    next report to present as current.
	]]
	for _, list in pairs(diagnosticCandidates) do
		wipe(list)
	end

	local dataRetry = false
	wipe(itemCounts)
	wipe(slotItems)
	wipe(ignoredTypes)

	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, C_Container.GetContainerNumSlots(bag) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			if info and info.itemID then
				local id = info.itemID
				itemCounts[id] = (itemCounts[id] or 0) + info.stackCount
				if not slotItems[id] then
					slotItems[id] = info.hyperlink
				end
			end
		end
	end

	--[[
	    Overrides check happens before standard consumable scan. Skipped
	    entirely in a PvP Arena (see the arena rule above): scroll mode and pet
	    buff food can't be used there, so both stay nil and the Food macro keeps
	    its plain food/conjure form.
	]]
	if inArena then
		ns.scrollOverrideIDs = nil
		ns.petBuffOverrideID = nil
	else
		ns.scrollOverrideIDs = ns.FindScrollOverrides(itemCounts, buffSnapshot)
		ns.petBuffOverrideID = ns.FindPetBuffOverride(itemCounts)
	end

	--[[
	    Both halves of the Ignore List hide an item from every macro's selection.
	    An ignored item is still resolved like any other, but where it would
	    compete it only marks its categories in ignoredTypes.
	]]
	local characterIgnoreList = ns.GetIgnoreList() or {}
	local globalIgnoreList = ns.GetGlobalIgnoreList() or {}

	for id, hyperlink in pairs(slotItems) do
		local ignored = characterIgnoreList[id] or globalIgnoreList[id]
		--[[
		    Scroll items skip normal consumable processing; the scroll
		    override system handles them.
		]]
		if not (ns.SCROLL_ITEM_LOOKUP and ns.SCROLL_ITEM_LOOKUP[id]) then
			local data = itemCache[id]
			--[[
			    The cache holds consumables only, so a stored "IGNORE" is
			    stale: clear it and let ns.CacheItemData answer from the
			    consumable tables. Version-stamp invalidation only wipes the
			    cache on a release bump, never on a dev copy, whose version
			    is always "Dev".
			]]
			if data == "IGNORE" then
				data = nil
				itemCache[id] = nil
			end
			--[[
			    Drop cache entries from an older schema so CacheItemData
			    re-derives them below. Test the NEWEST cached field, not an
			    old one: version-stamp invalidation only fires on a release
			    bump, so a same-version update (dev edit) that adds a field
			    would otherwise keep stale entries missing it. The newest
			    field is itemID (CacheItemData always writes it, so == nil
			    only ever means "older schema"); the older fields are kept
			    in the test to also catch pre-maxStack/-arenaUsable/
			    -isConjured/-damageValue/-isSoulbound entries.
			]]
			if
				data
				and (
					data.maxStack == nil
					or data.arenaUsable == nil
					or data.isConjured == nil
					or data.damageValue == nil
					or data.isSoulbound == nil
					or data.itemID == nil
				)
			then
				data = nil
				itemCache[id] = nil
			end
			if not data then
				data = ns.CacheItemData(id)
			end

			if not data then
				dataRetry = true
			elseif data ~= "IGNORE" then
				local usable = true

				if data.requiredLevel > playerLevel then
					usable = false
				end

				if usable and data.requiredFirstAid > 0 and data.requiredFirstAid > firstAidSkill then
					usable = false
				end

				if usable and (data.requiredAlchemy or 0) > 0 and (data.requiredAlchemy or 0) > alchemySkill then
					usable = false
				end

				if
					usable
					and (data.requiredEngineering or 0) > 0
					and (data.requiredEngineering or 0) > engineeringSkill
				then
					usable = false
				end

				--[[
				    Engineering specialization gate (Global Thermal Sapper
				    Charge requires Goblin Engineer). Checked live rather
				    than cached at login because the specialization can be
				    learned mid-session; SPELLS_CHANGED triggers the rescan.
				    Same ns.IsSpellKnown + ns.IsPlayerSpell pair as
				    GetSmartSpell — profession passives can live on either
				    surface depending on client.
				]]
				if usable and data.requiredSpellID then
					local spellID = data.requiredSpellID
					if not (ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID)) then
						usable = false
					end
				end

				if usable and data.zones then
					usable = (currentMap ~= nil) and (data.zones[currentMap] == true)
				end

				if usable and data.arenaOnly and not inArena then
					usable = false
				end

				--[[
				    A PvP Arena blocks potions and regular food and drink: of
				    the food and drink, only conjured food/water and the
				    arena-only drinks (Star's Tears/Lament) can be consumed.
				    Healthstones, Mana Gems, bandages and explosives still work.
				    Gate the blocked ones out so the macro never selects an item
				    that fails on press in the arena. Ranking within what
				    survives is unchanged (RANKING_PRIORITY).
				]]
				if usable and inArena then
					local itemType = data.itemType
					local isFoodOrWater = (itemType == "food" or itemType == "water" or itemType == "foodwater")
					if itemType == "potion" or (isFoodOrWater and not data.arenaUsable) then
						usable = false
					end
				end

				if usable then
					local totalCount = itemCounts[id]

					--[[
					    Dispatch the item to every registered definition
					    whose itemTypes set claims its cached itemType.
					    Deliberately not first-match-wins: more than one
					    category may consume the same item — a potion
					    with both health and mana values feeds Health
					    Potion and Mana Potion, and a foodwater hybrid
					    feeds Food and Water.
					]]
					for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
						if
							definition.itemTypes
							and definition.itemTypes[data.itemType]
							and (not definition.accepts or definition.accepts(data))
						then
							local score = definition.score(data)
							if ignored then
								ignoredTypes[definition.typeName] = true
							elseif definition.ranked then
								AddRankedCandidate(definition.typeName, data, score, totalCount)
							else
								local entry = best[definition.typeName]
								--[[
								    allowBuffFood, allowConjuredFirst and
								    allowRestockLast defs track the live
								    scan preferences;
								    everyone else compares with those
								    steps gated off.
								]]
								local allowBuffFood = definition.allowBuffFood and ns.allowBuffFood
								local allowConjuredFirst = definition.allowConjuredFirst and ns.allowConjuredFirst
								local allowRestockLast = definition.allowRestockLast and ns.allowRestockLast
								if
									IsBetter(
										data,
										totalCount,
										data.price,
										entry,
										score,
										allowBuffFood,
										definition.preferHybrid,
										allowConjuredFirst,
										allowRestockLast
									)
								then
									FillRecord(entry, data, totalCount, data.price, score)
									if definition.winnerExtras then
										definition.winnerExtras(entry, data, hyperlink)
									end
								end

								if ns.diagnostics.enabled then
									RetainCandidate(
										definition.typeName,
										FillRecord(candidateRecord, data, totalCount, data.price, score),
										allowBuffFood,
										definition.preferHybrid,
										allowConjuredFirst,
										allowRestockLast
									)
								end
							end
						end
					end
				end
			end
		end
	end

	RankCandidates()
	CaptureDiagnosticCandidates()

	ns.bestFoodID = best["Food"].id
	ns.bestFoodLink = best["Food"].link

	return best, dataRetry
end
