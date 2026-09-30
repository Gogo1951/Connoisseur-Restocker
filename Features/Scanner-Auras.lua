local _, ns = ...

--[[
    Scanner-Auras -- reads live player/pet auras and decides which buffs the
    character still needs: aura probes (Well Fed, scroll, and pet-food buffs),
    early re-application, the scroll override resolver, and the UNIT_AURA
    handler.
]]

--------------------------------------------------------------------------------
-- Derived Scroll Lookups
--------------------------------------------------------------------------------

--[[
    Built once at load from ns.SCROLL_DATA (Data/{Game}/Scrolls-{Game}.lua, which
    loads before this file). ns.SCROLL_ITEM_LOOKUP maps each scroll itemID to its
    scroll type so the bag scanners route scroll items away from normal
    consumable processing. Each type's items are sorted by required level,
    highest first, so FindBestScroll's first usable hit is the best scroll
    whatever the data's row order. Every consumer reads these from inside a
    function (runtime), so the build only needs to finish before the first scan.
]]
ns.SCROLL_ITEM_LOOKUP = {}

local function ByRequiredLevelDescending(a, b)
	if a[3] ~= b[3] then
		return a[3] > b[3]
	end
	return a[4] > b[4]
end

--[[
    Reverse maps from a spell ID back to the scroll type(s) it covers, so the
    aura walk below resolves each aura in one lookup instead of testing every
    type. Both hold lists: no spell covers two stats in the current data, but a
    group buff that did (a Gift of the Wild style spell) has to register
    against every type it covers rather than silently claiming one.
]]
local scrollBuffOwners = {}
local scrollConflictOwners = {}

for scrollType, data in pairs(ns.SCROLL_DATA) do
	table.sort(data.items, ByRequiredLevelDescending)
	local buffIDs = {}
	for _, entry in ipairs(data.items) do
		ns.SCROLL_ITEM_LOOKUP[entry[1]] = scrollType
		buffIDs[entry[2]] = true
	end

	for spellID in pairs(buffIDs) do
		local owners = scrollBuffOwners[spellID] or {}
		owners[#owners + 1] = scrollType
		scrollBuffOwners[spellID] = owners
	end
	for spellID, amount in pairs(data.conflictSpells) do
		local owners = scrollConflictOwners[spellID] or {}
		owners[#owners + 1] = { scrollType = scrollType, amount = amount }
		scrollConflictOwners[spellID] = owners
	end
end

--------------------------------------------------------------------------------
-- Early Re-Application
--------------------------------------------------------------------------------

--[[
    With Re-Apply Expiring Buffs on, a tracked buff whose remaining time is
    under the profile threshold counts as already expired, so the macros offer
    a fresh application before the pull. Auras without a duration
    (expirationTime 0) never count as expiring.

    Crossing the threshold fires no UNIT_AURA event, so when a scan finds a
    buff still above it, a one-shot timer requests a rebuild for the moment
    the buff crosses. C_Timer.After cannot be cancelled, so nextRecheckAt
    tracks the earliest pending fire time and later-firing stale timers
    no-op; a duplicate rebuild within the epsilon is harmless (RequestUpdate
    is throttled).
]]
local nextRecheckAt

local function ScheduleExpiryRecheck(delay)
	local fireAt = GetTime() + delay
	if nextRecheckAt and nextRecheckAt <= fireAt then
		return
	end
	nextRecheckAt = fireAt
	C_Timer.After(delay, function()
		if not nextRecheckAt or GetTime() + 0.5 < nextRecheckAt then
			return
		end
		nextRecheckAt = nil
		ns.RequestUpdate()
	end)
end

local function BuffCountsAsActive(expirationTime)
	local settings = ns.db and ns.db.profile
	if not (settings and settings.earlyReapply) then
		return true
	end
	if not expirationTime or expirationTime == 0 then
		return true
	end
	local remaining = expirationTime - GetTime()
	local threshold = settings.earlyReapplyThreshold or 120
	if remaining < threshold then
		return false
	end
	ScheduleExpiryRecheck(remaining - threshold + 1)
	return true
end

--------------------------------------------------------------------------------
-- Player Aura Snapshot
--------------------------------------------------------------------------------

--[[
    One walk of the player's helpful auras, shared by the Well Fed and scroll
    probes below and by the readiness report (Features/Readiness-Report.lua).
    The snapshot holds raw expiration times, never a verdict: the probes apply
    BuffCountsAsActive, which owns the early re-application threshold and its
    rebuild timer, while the report reads the same numbers with no side
    effects of its own.

    Expiration convention, shared with the pet probe below: nil means the buff
    is absent, 0 means the aura carries no duration.

    Per buff we keep the longest-lasting match, and a 0 outranks any timed one.
    BuffCountsAsActive is monotonic in remaining time, so testing the longest
    match answers "does any match count as active" exactly as testing every
    match would. Neither Well Fed nor a scroll buff stacks with itself, so in
    practice there is only ever one match to choose from.

    Scroll entries also keep the largest conflicting class-buff amount seen, so
    the scroll probe can settle "is a class buff already at least as good as
    the scroll I would use" without a second pass; that comparison needs the
    scroll's own amount, which is per-call.

    The table is reused in place rather than rebuilt, because UNIT_AURA is a
    firehose and the Well Fed probe runs on every tick. That makes the return
    value a single shared buffer, not a private copy: a caller must not hold it
    across another call to this function, and one that needs several answers
    takes one snapshot and passes it down (see ns.FindScrollOverrides).

    While the client restricts aura data (Forever, which is Retail's engine),
    every field read comes back secret and comparing one errors, so the walk is
    skipped and the previous snapshot is returned untouched. An unchanged
    snapshot reads as "nothing moved"; a reset one would read as "no buffs"
    and rebuild the macros around a buff the player still has.
]]
local snapshot = { scrolls = {} }
for scrollType in pairs(ns.SCROLL_DATA) do
	snapshot.scrolls[scrollType] = {}
end

local function IsLongerExpiration(candidate, current)
	if current == nil then
		return true
	end
	if current == 0 then
		return false
	end
	return candidate == 0 or candidate > current
end

function ns.GetPlayerBuffSnapshot()
	if C_Secrets.ShouldAurasBeSecret() then
		return snapshot
	end

	snapshot.wellFedExpiration = nil
	for _, entry in pairs(snapshot.scrolls) do
		entry.expiration = nil
		entry.conflictAmount = nil
	end

	for i = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("player", i, "HELPFUL")
		if not aura then
			break
		end
		local icon, spellID = aura.icon, aura.spellId
		local expirationTime = aura.expirationTime or 0

		if ns.WELL_FED_ICON_IDS[icon] or ns.WELL_FED_BUFF_IDS[spellID] then
			if IsLongerExpiration(expirationTime, snapshot.wellFedExpiration) then
				snapshot.wellFedExpiration = expirationTime
			end
		end

		local buffOwners = scrollBuffOwners[spellID]
		if buffOwners then
			for _, scrollType in ipairs(buffOwners) do
				local entry = snapshot.scrolls[scrollType]
				if IsLongerExpiration(expirationTime, entry.expiration) then
					entry.expiration = expirationTime
				end
			end
		end

		local conflictOwners = scrollConflictOwners[spellID]
		if conflictOwners then
			for _, owner in ipairs(conflictOwners) do
				local entry = snapshot.scrolls[owner.scrollType]
				if not entry.conflictAmount or owner.amount > entry.conflictAmount then
					entry.conflictAmount = owner.amount
				end
			end
		end
	end

	return snapshot
end

--------------------------------------------------------------------------------
-- Well Fed
--------------------------------------------------------------------------------

--[[
    Takes a snapshot rather than walking the auras, so the aura handler and
    ns.UpdateAuraTracking settle Well Fed from the same pass they use for
    scrolls.
]]
local function WellFedFromSnapshot(currentSnapshot)
	local expiration = currentSnapshot.wellFedExpiration
	return expiration ~= nil and BuffCountsAsActive(expiration)
end

--------------------------------------------------------------------------------
-- Scroll Buffs
--------------------------------------------------------------------------------

--[[
    A scroll buff of any rank counts as covered. A conflict spell (e.g. Fort)
    only counts as covered if its base amount is at least as large as the
    scroll we would use — otherwise the scroll would still improve the stat.

    callerSnapshot is an optional snapshot from ns.GetPlayerBuffSnapshot.
    Callers asking about more than one scroll type pass one in, so a single
    walk of the player's auras serves the whole set; omitting it takes a
    fresh one.
]]
function ns.HasScrollBuff(scrollType, scrollAmount, callerSnapshot)
	if not ns.SCROLL_DATA[scrollType] then
		return true
	end

	local entry = (callerSnapshot or ns.GetPlayerBuffSnapshot()).scrolls[scrollType]

	-- Already have a scroll buff active for this stat
	if entry.expiration ~= nil and BuffCountsAsActive(entry.expiration) then
		return true
	end

	--[[
	    Check conflict spells — only block the scroll if the class buff
	    provides at least as much stat as our best scroll would. Exempt
	    from the early re-application threshold: a still-active stronger
	    class buff cannot be overwritten, so treating it as expired would
	    build a scroll line that errors on use.
	]]
	return entry.conflictAmount ~= nil and entry.conflictAmount >= (scrollAmount or 0)
end

--[[
    Finds the best available scroll for a type from bag contents.
    Scroll entries: {[1] itemID, [2] buffID, [3] requiredLevel, [4] amount,
    [5] class token or nil}; a scroll with a class token is skipped for every
    other class, since anyone can carry one but only that class can read it.
    Returns itemID, amount (or nil, nil if nothing usable is found).
]]
local function FindBestScroll(scrollType, bagItemCounts)
	if not ns.SCROLL_DATA[scrollType] then
		return nil, nil
	end

	local playerLevel = ns.cachedPlayerLevel or 1
	local _, playerClass = UnitClass("player")
	local items = ns.SCROLL_DATA[scrollType].items
	for _, entry in ipairs(items) do
		--[[
		    The scroll override path never passes the scanner's ignore filter
		    (it reads the raw bag counts), so it honors the Ignore List itself.
		]]
		if entry[3] <= playerLevel and (entry[5] == nil or entry[5] == playerClass) and not ns.IsIgnored(entry[1]) then
			if bagItemCounts[entry[1]] and bagItemCounts[entry[1]] > 0 then
				return entry[1], entry[4]
			end
		end
	end

	return nil, nil
end

--[[
    Written by ScanBags on every rescan (forced nil in a PvP Arena); the Food
    macro's scroll-only mode, the Readiness Report and Diagnostics read it.
]]
ns.scrollOverrideIDs = nil

--[[
    Returns an ordered list of scroll item IDs the player should use, or nil
    if none apply. Order follows ns.SCROLL_CHECK_ORDER, which is the order the
    scroll-only body fires them in. currentSnapshot is the player snapshot the
    caller already took this pass, when it has one.
]]
function ns.FindScrollOverrides(bagItemCounts, currentSnapshot)
	local settings = ns.db and ns.db.profile
	if not settings or not settings.useScrolls then
		return nil
	end
	if not ns.IsModeActive(settings.scrollsMode) then
		return nil
	end

	local scrollTypes = settings.scrollTypes
	if not scrollTypes then
		return nil
	end

	local results

	--[[
	    One aura walk for the whole set, and none at all when the bag scan
	    already took one. Letting each ns.HasScrollBuff call take its own
	    snapshot re-reads the player's 40 aura slots once per enabled scroll
	    type, on a path that re-runs with every bag scan.
	]]
	currentSnapshot = currentSnapshot or ns.GetPlayerBuffSnapshot()

	for _, scrollType in ipairs(ns.SCROLL_CHECK_ORDER) do
		if scrollTypes[scrollType] then
			local scrollItemID, scrollAmount = FindBestScroll(scrollType, bagItemCounts)
			if scrollItemID and not ns.HasScrollBuff(scrollType, scrollAmount, currentSnapshot) then
				results = results or {}
				results[#results + 1] = scrollItemID
			end
		end
	end

	return results
end

--------------------------------------------------------------------------------
-- Pet Food Buffs
--------------------------------------------------------------------------------

--[[
    The buffs ns.PET_BUFF_FOODS grant, matched against the pet's auras, and the
    lowest level any of the foods can be used at.
]]
local PET_BUFF_FOOD_SPELL_IDS = {}
local PET_BUFF_FOOD_MIN_LEVEL
for _, row in pairs(ns.PET_BUFF_FOODS) do
	PET_BUFF_FOOD_SPELL_IDS[row[1]] = true
	PET_BUFF_FOOD_MIN_LEVEL = math.min(PET_BUFF_FOOD_MIN_LEVEL or row[4], row[4])
end

-- A flavor whose data folder has no pet buff food runs none of this feature.
local HAS_PET_BUFF_FOODS = next(ns.PET_BUFF_FOODS) ~= nil

--[[
    Whether pet buff food applies to this character right now: this flavor has
    one, the feature is on, its group restriction is satisfied, the player is
    high enough level for the food to exist, and there is a live pet to feed.

    Single source of truth on purpose. Both ns.FindPetBuffOverride
    (Macros/Tools-Hunters.lua), which decides whether to splice the feed line
    into the Food macro, and the readiness report (Features/Readiness-Report.lua)
    have to agree -- when they drifted, the report asked a level-30 Hunter for a
    buff its own macro would never apply, with no way to satisfy it.
]]
function ns.ShouldTrackPetFood()
	if not HAS_PET_BUFF_FOODS then
		return false
	end
	local settings = ns.db and ns.db.profile
	if not settings or not settings.usePetBuffFood then
		return false
	end
	if not ns.IsModeActive(settings.petBuffFoodMode) then
		return false
	end
	if (ns.cachedPlayerLevel or 1) < PET_BUFF_FOOD_MIN_LEVEL then
		return false
	end
	if not UnitExists("pet") or UnitIsDead("pet") or UnitIsGhost("pet") then
		return false
	end
	return true
end

--[[
    The pet is a separate unit and so a separate walk from the player snapshot
    above, but it follows the same expiration convention: nil when the buff is
    absent, 0 when the aura carries no duration. Consumed by
    ns.FindPetBuffOverride (Macros/Tools-Hunters.lua) and by the readiness
    report; the probe lives here because BuffCountsAsActive is private to this
    file. Like the player snapshot, it answers with its last reading while the
    client restricts aura data.
]]
local lastPetFoodBuffExpiration

function ns.GetPetFoodBuffExpiration()
	if not UnitExists("pet") then
		lastPetFoodBuffExpiration = nil
		return nil
	end
	if C_Secrets.ShouldAurasBeSecret() then
		return lastPetFoodBuffExpiration
	end
	local best
	for i = 1, 40 do
		local aura = C_UnitAuras.GetBuffDataByIndex("pet", i, "HELPFUL")
		if not aura then
			break
		end
		if PET_BUFF_FOOD_SPELL_IDS[aura.spellId] then
			local expirationTime = aura.expirationTime or 0
			if IsLongerExpiration(expirationTime, best) then
				best = expirationTime
			end
		end
	end
	lastPetFoodBuffExpiration = best
	return best
end

function ns.HasPetFoodBuff()
	local expiration = ns.GetPetFoodBuffExpiration()
	return expiration ~= nil and BuffCountsAsActive(expiration)
end

--------------------------------------------------------------------------------
-- Scroll Aura Baseline
--------------------------------------------------------------------------------

--[[
    Last-seen aura inputs to the scroll decision, one entry per scroll type.
    ns.HasScrollBuff answers from exactly two snapshot fields -- the scroll's own
    expiration and the largest conflicting class-buff amount -- so tracking those
    two is what separates an aura change that could flip a scroll line from the
    firehose of unrelated ones. The verdict itself is deliberately not recomputed
    here: it needs the scroll amount from the bag scan, which this path has no
    access to, and the early-reapply threshold it applies moves with time rather
    than with any event (ScheduleExpiryRecheck owns that case).

    Every scan records these through ns.UpdateAuraTracking, not only the aura
    handler. The dispatcher never calls the handler in combat, so a baseline the
    handler alone wrote would still hold the pre-fight reading after the
    post-combat rebuild, and a buff that changed mid-fight and changed back
    afterwards would read as no change, leaving the macros built for the fight.
]]
local lastScrollExpiration = {}
local lastScrollConflict = {}
local scrollStateKnown = false

--[[
    Called from ns.ResetMacroState: a forced rebuild drops the baseline so
    nothing is compared against readings taken under the old settings. The next
    scan records a fresh one, and an aura event that arrives first counts as a
    change.
]]
function ns.ResetScrollBuffTracking()
	wipe(lastScrollExpiration)
	wipe(lastScrollConflict)
	scrollStateKnown = false
end

--[[
    Records this pass's values and reports whether any moved. The loop always
    runs to completion -- returning early on the first difference would leave the
    remaining types holding stale values and report a phantom change next call.
]]
local function ScrollAurasChanged(currentSnapshot, scrollTypes)
	local changed = not scrollStateKnown
	scrollStateKnown = true

	for _, scrollType in ipairs(ns.SCROLL_CHECK_ORDER) do
		local entry = scrollTypes[scrollType] and currentSnapshot.scrolls[scrollType]
		local expiration = entry and entry.expiration or nil
		local conflictAmount = entry and entry.conflictAmount or nil
		if expiration ~= lastScrollExpiration[scrollType] or conflictAmount ~= lastScrollConflict[scrollType] then
			changed = true
		end
		lastScrollExpiration[scrollType] = expiration
		lastScrollConflict[scrollType] = conflictAmount
	end

	return changed
end

--------------------------------------------------------------------------------
-- Aura Tracking
--------------------------------------------------------------------------------

local auraEventRegistered

--[[
    Whether each player-side aura feature is live: its switch is on and its
    group mode holds. ns.UpdateAuraTracking and ns.OnUnitAura both ask, so what
    the scan tracks and what the aura handler diffs can never disagree.
]]
local function PlayerAuraFeaturesActive(settings)
	local buffFoodActive = (settings.useBuffFood and ns.IsModeActive(settings.buffFoodMode)) and true or false
	local scrollsActive = (settings.useScrolls and ns.IsModeActive(settings.scrollsMode)) and true or false
	return buffFoodActive, scrollsActive
end

--[[
    Returns the player snapshot it took, or nil when neither player-side
    feature is active, so ns.ScanBags can hand it on to ns.FindScrollOverrides
    instead of walking the auras a second time. While scrolls are live it also
    records the scroll baseline from that same snapshot, so the aura handler
    compares against what the latest scan saw (see Scroll Aura Baseline).
    UNIT_AURA is only re-registered when the wanted state flips, since every
    bag scan passes through here.
]]
function ns.UpdateAuraTracking()
	local settings = ns.db.profile

	local buffFoodActive, scrollsActive = PlayerAuraFeaturesActive(settings)
	local petBuffActive = HAS_PET_BUFF_FOODS and settings.usePetBuffFood and ns.IsModeActive(settings.petBuffFoodMode)

	local currentSnapshot
	if buffFoodActive or scrollsActive then
		currentSnapshot = ns.GetPlayerBuffSnapshot()
		ns.wellFedState = WellFedFromSnapshot(currentSnapshot)
		if scrollsActive and settings.scrollTypes then
			ScrollAurasChanged(currentSnapshot, settings.scrollTypes)
		end
	else
		ns.wellFedState = false
	end

	local wantAuraEvent = (buffFoodActive or scrollsActive or petBuffActive) and true or false
	if wantAuraEvent ~= auraEventRegistered then
		auraEventRegistered = wantAuraEvent
		ns.SetEventRegistered("UNIT_AURA", wantAuraEvent, "player", "pet")
	end

	return currentSnapshot
end

--------------------------------------------------------------------------------
-- Aura Event Handler
--------------------------------------------------------------------------------

--[[
    UNIT_AURA handler routed from Core's dispatcher. One snapshot pass settles
    both player-side features, and each requests a rebuild only on a real change
    while it is live: Well Fed diffs its own state, scrolls diff the two inputs
    above. UNIT_AURA is a firehose and a rebuild is a full bag rescan, so an
    unconditional request here costs one of those per unrelated buff; and a diff
    against a feature ns.UpdateAuraTracking is not tracking reads as a change on
    every firing, since the scan resets that state. The pet branch keeps its
    unconditional request: pet auras change rarely and carry no such traffic.
]]
function ns.OnUnitAura(unit)
	local needsUpdate = false
	--[[
	    What made this firing worth acting on. UNIT_AURA is a firehose, so the
	    diagnostics capture tap can only count it -- it runs before this handler
	    and cannot yet know. This is the end that does know, so the signal
	    firings are logged from here (see ns.LogEventNow in
	    Features/Diagnostics.lua), which keeps the event log from disagreeing
	    with what the add-on actually reacted to.
	]]
	local reason

	if unit == "player" then
		local settings = ns.db and ns.db.profile
		local buffFoodActive, scrollsActive = false, false
		if settings then
			buffFoodActive, scrollsActive = PlayerAuraFeaturesActive(settings)
		end

		if buffFoodActive or scrollsActive then
			local currentSnapshot = ns.GetPlayerBuffSnapshot()

			local wellFedState = WellFedFromSnapshot(currentSnapshot)
			if wellFedState ~= ns.wellFedState then
				ns.wellFedState = wellFedState
				needsUpdate = true
				reason = "wellfed"
			end

			if scrollsActive and settings.scrollTypes then
				if ScrollAurasChanged(currentSnapshot, settings.scrollTypes) then
					needsUpdate = true
					reason = reason and (reason .. "+scrolls") or "scrolls"
				end
			end
		end
	elseif unit == "pet" then
		if HAS_PET_BUFF_FOODS and ns.db and ns.db.profile and ns.db.profile.usePetBuffFood then
			needsUpdate = true
			reason = "petbuff"
		end
	end

	if needsUpdate then
		ns.LogEventNow("UNIT_AURA", unit, reason)
		ns.RequestUpdate()
	end
end
