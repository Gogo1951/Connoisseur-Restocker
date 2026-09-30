local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
    Read across files as the "a bank window is open" gate; everything else about a
    restock run is private to this file.
]]
ns.bankIsOpen = false

local currentlyRestocking = false
local restockState = nil
-- The OnUpdate timer's frame, created below once OnBankRestockUpdate exists.
local restockUpdateFrame
local updateTimer = 0
--[[
    Starts at the floor so the OnUpdate handler never compares against nil; the real
    connection-paced value is seeded in ns.RestartBankRestock.
]]
local updateInterval = 0.140

--[[
    After this many consecutive steps that fail to reduce the outstanding work (a move that
    keeps being rejected, or an item stuck locked), stop and report what's still short --
    instead of retrying forever. Retrying a handful of times first rides out transient
    "Couldn't split those items" races without ever bothering the user.
]]
local MAX_STUCK_STEPS = 5

--[[
    A maintained item's bag+bank TOTAL can only drop while a move is in transit: the source
    slot is already empty but the destination hasn't been credited yet, and NOTHING is locked
    in that window, so the lock gate in OnBankRestockUpdate can't see it. A scan taken there
    under-counts and must not be acted on. Wait at most this many steps for the total to
    recover before accepting it as the new reality (item genuinely consumed or destroyed).
]]
local MAX_INFLIGHT_STEPS = 3

--[[
    The bank restock's step-by-step trace. Gated on the Diagnostic Tools panel's
    runtime flag, which lives in memory and starts false at every login, so a
    player can never leave this on -- and the boolean is read before any string
    work, so a run with diagnostics off pays one comparison per call.

    Developer-facing, so the text stays plain English and out of Locales/: each
    message is a TRACE_* format in ns.DiagnosticsStrings (Features/Diagnostics.lua),
    passed here by key and looked up only once the gate is open.

    Restocker-Bags.lua calls this too and loads first, which is fine: every call is
    made at runtime, long after all the Restocker files have loaded.

    Takes the format's arguments rather than a pre-concatenated string, so the
    (potentially expensive) build only happens when the gate is open: prefer
    ns.RestockerDebug("TRACE_X", v) over building the text at the call site.
]]
function ns.RestockerDebug(key, ...)
	if not (ns.diagnostics and ns.diagnostics.enabled) then
		return
	end
	local message = ns.DiagnosticsStrings[key]
	if select("#", ...) > 0 then
		message = string.format(message, ...)
	end
	ns.PrintMessage(tostring(message))
end

--------------------------------------------------------------------------------
-- Inventory Model
--------------------------------------------------------------------------------

-- Collection of items in the inventory or bank with their precise slot locations and counts, and summaries
local Inventory = {}
Inventory.__index = Inventory

function ns.NewRestockInventorySlot(bag, slot, itemCount)
	return {
		bag = bag,
		slot = slot,
		count = itemCount,
	}
end

local function NewSlotNumber(bag, slot)
	return {
		bag = bag,
		slot = slot,
	}
end

function ns.NewRestockInventory()
	return setmetatable({
		summary = {},
		slots = {},
	}, Inventory)
end

-- Sorts bag slots for each item, with smallest stacks first
function Inventory:SortSlots()
	for _, eachItemSlots in pairs(self.slots) do
		table.sort(eachItemSlots, ns.CompareByStackSizeAscending)
	end
end

function Inventory:FindBestFit(cachedItem, amount)
	local containingSlots = self.slots[cachedItem.itemID]
	if not containingSlots then
		ns.RestockerDebug("TRACE_BEST_FIT_NO_STACKS", cachedItem.itemName, amount)
		return nil
	end

	local mergeDestinations = {}

	for _, inventorySlot in ipairs(containingSlots) do
		local remainingAfterMerge = cachedItem.itemStackCount - (inventorySlot.count + amount)

		-- If can merge into this slot
		if remainingAfterMerge >= 0 then
			local candidate = ns.NewRestockInventorySlot(inventorySlot.bag, inventorySlot.slot, remainingAfterMerge)
			table.insert(mergeDestinations, candidate)
		end
	end

	if #mergeDestinations == 0 then
		ns.RestockerDebug("TRACE_BEST_FIT_NO_CANDIDATES", cachedItem.itemName, amount)
		return nil
	end

	-- Pick smallest remaining
	table.sort(mergeDestinations, ns.CompareByStackSizeAscending)

	-- First element should be lowest, i.e. closest to the perfection of a full stack
	local bestDestination = mergeDestinations[1]
	ns.RestockerDebug(
		"TRACE_BEST_FIT_CANDIDATE",
		cachedItem.itemName,
		amount,
		bestDestination.bag,
		bestDestination.slot
	)
	return NewSlotNumber(bestDestination.bag, bestDestination.slot)
end

--------------------------------------------------------------------------------
-- Restock State
--------------------------------------------------------------------------------

local RestockState = {}
RestockState.__index = RestockState

local function NewRestockState()
	local state = {}
	state.lastRemainingWork = math.huge
	state.stuckSteps = 0
	state.consolidating = false
	state.lastStackCount = math.huge
	state.tidySteps = 0
	state.lastTotals = nil
	state.suspectSteps = 0
	state.cursorSteps = 0
	state.lockedTicks = 0
	state.overshotItems = {}
	state.amounts = {}

	setmetatable(state, RestockState)

	state:Rescan()
	for itemID, eachItem in pairs(state.currentList) do
		state:Wanted(itemID, eachItem)
	end

	return state
end

--[[
    The Keep amount this run works to, read once per row: as the run starts, or
    when a row added since first turns up. The Keep box saves every keystroke,
    so a live read would act on a number half typed (clearing the box reads 0,
    which stores the whole stack); Enter restarts the run with the new number
    (Restocker-Window-Rows.lua).

    A hand-edited save can leave amount nil; comparing that against a count
    throws inside the coroutine and kills the whole run, so it reads as 0.
]]
function RestockState:Wanted(itemID, eachItem)
	local wanted = self.amounts[itemID]
	if wanted == nil then
		wanted = eachItem.amount or 0
		self.amounts[itemID] = wanted
	end
	return wanted
end

--[[
    Whether the cursor is clear enough to snapshot over, clearing it where that is ours to do.

    An item on the cursor is uncounted, so a scan taken across one reads short and moves
    things that are already fine. Only OUR strays are cleared outright: every move this file
    issues is of a maintained item, so a cursor holding anything else belongs to the player --
    picked up to move it by hand -- and clearing that snapped their drag back within a tick.
    A foreign item is waited out for the same MAX_STUCK_STEPS budget the watchdog spends, then
    cleared anyway, so a parked cursor can never hold a run open forever.
]]
function RestockState:ClearCursorForScan()
	if not CursorHasItem() then
		self.cursorSteps = 0
		return true
	end

	local infoType, cursorItemID = GetCursorInfo()
	local isOurs = infoType == "item"
		and cursorItemID ~= nil
		and self.currentList ~= nil
		and self.currentList[cursorItemID] ~= nil

	if not isOurs and self.cursorSteps < MAX_STUCK_STEPS then
		self.cursorSteps = self.cursorSteps + 1
		ns.RestockerDebug("TRACE_CURSOR_FOREIGN_ITEM", self.cursorSteps, MAX_STUCK_STEPS)
		return false
	end

	self.cursorSteps = 0
	ClearCursor()
	return true
end

--[[
    Refresh the list and re-scan bags + bank. Called at the START OF EVERY restock step,
    so the plan is always derived from what is actually in the containers right now. That way
    a move the server rejected or only partially placed shows up as "still short" on the
    next step and gets retried, instead of being assumed done. Never
    deduct from a plan optimistically: a move that does not fully land leaves the item short
    in silence. Recomputing every step is safe only because the watchdog in RunRestockLogic
    stops the run once it stops making progress; without that guard it spins on "Couldn't
    split those items" forever.

    Returns false when the cursor made this step unsafe to read, which is the caller's cue to
    do nothing this tick. The list is resolved before that test, because deciding whose
    item is on the cursor needs it -- and it leaves the inventories from the previous scan
    untouched rather than half-updated.
]]
function RestockState:Rescan()
	local settings = ns.restockSettings
	self.currentList = settings.lists[settings.currentList]

	if not self:ClearCursorForScan() then
		return false
	end

	self:UpdateInventory()
	return true
end

--[[
    How much moving is still owed: shortfalls the bank can supply, plus excesses to stash.
    Zero means done -- either everything is at target, or the only gaps left are items the
    bank has none of (nothing more we can do).
]]
function RestockState:RemainingWork()
	local work = 0
	for itemID, eachItem in pairs(self.currentList) do
		local haveInBag = self.playerInventory.summary[itemID] or 0
		local haveInBank = self.bankInventory.summary[itemID] or 0
		local wanted = self:Wanted(itemID, eachItem)

		if eachItem.restockFromBank and wanted > haveInBag and haveInBank > 0 then
			work = work + math.min(wanted - haveInBag, haveInBank)
		end
		--[[
		    Overshoot excess counts as stash work even without stashToBank: the add-on created it
		    (whole-stack fallback pull), so the add-on returns it.
		]]
		if (eachItem.stashToBank or self.overshotItems[itemID]) and haveInBag > wanted then
			work = work + (haveInBag - wanted)
		end
	end
	return work
end

--[[
    Bag+bank total for each maintained item, from this step's scan. Used by the in-flight
    gate in RunRestockLogic: a DROP versus the last accepted scan means an item is mid-move.
]]
function RestockState:ComputeTotals()
	local totals = {}
	for itemID in pairs(self.currentList) do
		totals[itemID] = (self.playerInventory.summary[itemID] or 0) + (self.bankInventory.summary[itemID] or 0)
	end
	return totals
end

--[[
    The largest stack an item allows, or nil when it doesn't stack (or isn't cached yet),
    which the tidy phase reads as "leave it alone".
]]
local function MaxStackOf(itemID)
	local info = ns.GetItemData(itemID)
	local maxStack = info and info.itemStackCount
	if maxStack and maxStack > 1 then
		return maxStack
	end
	return nil
end

--[[
    How many PARTIAL stacks of maintained items the bags and the bank hold, used as the
    tidy-phase progress signal. Every tidy move leaves at least one fewer partial stack
    behind -- a whole-stack merge empties one, a top-off fills one -- so this strictly
    decreases while consolidation is making headway and plateaus when done (or if a merge
    bounces), which the tidy watchdog uses to stop. Counting all stacks would miss a top-off,
    which fills one stack without removing any.
]]
function RestockState:CountPartialStacks()
	local partials = 0
	for _, inventory in ipairs({ self.playerInventory, self.bankInventory }) do
		for itemID, slots in pairs(inventory.slots) do
			local maxStack = MaxStackOf(itemID)
			if maxStack then
				for _, slot in ipairs(slots) do
					if slot.count < maxStack then
						partials = partials + 1
					end
				end
			end
		end
	end
	return partials
end

--[[
    A user-facing message for why we stopped when work still remains. Blames a full
    bag or bank only for a direction that has a stuck row (a withdrawal needs bag
    room, a deposit needs bank room); otherwise lists exactly what we couldn't move.
]]
function RestockState:StuckMessage()
	local parts = {}
	local withdrawStuck, depositStuck = false, false
	for itemID, eachItem in pairs(self.currentList) do
		local haveInBag = self.playerInventory.summary[itemID] or 0
		local haveInBank = self.bankInventory.summary[itemID] or 0
		local wanted = self:Wanted(itemID, eachItem)

		if eachItem.restockFromBank and wanted > haveInBag and haveInBank > 0 then
			withdrawStuck = true
			parts[#parts + 1] = string.format(
				L["RESTOCKER_STUCK_ITEM_FORMAT"],
				math.min(wanted - haveInBag, haveInBank),
				eachItem.itemName
			)
		elseif (eachItem.stashToBank or self.overshotItems[itemID]) and haveInBag > wanted then
			depositStuck = true
			parts[#parts + 1] =
				string.format(L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"], haveInBag - wanted, eachItem.itemName)
		end
	end

	local bagHasSpace, bankHasSpace = ns.GetRestockSpace()
	local bagBlocked = withdrawStuck and not bagHasSpace
	local bankBlocked = depositStuck and not bankHasSpace
	if bagBlocked and bankBlocked then
		return L["RESTOCKER_STOPPED_BOTH_FULL"]
	elseif bankBlocked then
		return L["RESTOCKER_STOPPED_BANK_FULL"]
	elseif bagBlocked then
		return L["RESTOCKER_STOPPED_BAG_FULL"]
	end

	if #parts == 0 then
		return L["RESTOCKER_STOPPED_NO_PROGRESS"]
	end
	return string.format(L["RESTOCKER_STOPPED_COULD_NOT_MOVE"], table.concat(parts, L["LIST_SEPARATOR"]))
end

--[[
    Issue one stash move: find the first over-stocked item and send some to the bank. The
    excess is computed fresh from this step's scan, not from a running tally.
]]
local function StashToBank()
	local state = restockState

	for itemID, eachItem in pairs(state.currentList) do
		if eachItem.stashToBank or state.overshotItems[itemID] then
			local haveInBag = state.playerInventory.summary[itemID] or 0
			local wanted = state:Wanted(itemID, eachItem)
			local excess = haveInBag - wanted
			if excess > 0 then
				ns.RestockerDebug("TRACE_TOO_MANY", eachItem.itemName, haveInBag, wanted)
				if ns.MoveRestockItemToBank(state.bankInventory, itemID, excess) then
					return true -- issued one move; caller yields and re-scans next step
				end
			end
		end
	end

	return false
end

--[[
    Issue one restock move: find the first under-stocked item the bank can supply and pull
    some in. The shortfall is computed fresh from this step's scan.
]]
local function RestockFromBank()
	local state = restockState

	for itemID, eachItem in pairs(state.currentList) do
		if eachItem.restockFromBank then
			local haveInBag = state.playerInventory.summary[itemID] or 0
			local haveInBank = state.bankInventory.summary[itemID] or 0
			local wanted = state:Wanted(itemID, eachItem)
			local short = wanted - haveInBag
			if short > 0 and haveInBank > 0 then
				ns.RestockerDebug("TRACE_TOO_FEW", eachItem.itemName, haveInBag, wanted)
				--[[
				    stuckSteps > 0 means the previous step's move never landed -- in practice the
				    flaky exact split. Switch to whole-stack overshoot, which always lands; the
				    watchdog would otherwise burn its retries on the same bounced split and give up
				    short (the "couldn't move: 2x ..." stop).
				]]
				local overshoot = state.stuckSteps > 0
				if
					ns.MoveRestockItemFromBank(state.playerInventory, itemID, math.min(short, haveInBank), overshoot)
				then
					if overshoot then
						--[[
						    The whole-stack pull may go past the target. That excess is the add-on's
						    doing, not the player's stock -- trim it back even without stashToBank.
						]]
						state.overshotItems[itemID] = true
					end
					return true -- issued one move; caller yields and re-scans next step
				end
			end
		end
	end

	return false
end

--[[
    Merge one pair of partial stacks of a maintained item within one inventory (the player
    bags or the bank, never across), to undo the fragmentation that free-slot-first placement
    and exact splits leave behind -- in the bags 10 + 9 + 1 -> 20, and in the bank the
    5 + 5 + 4 + 2 a run of small pulls carves out of full stacks.

    The smallest partial stack is the source. A whole-stack merge comes first: pick it all up
    and drop it onto the largest partial that has room for ALL of it, no split involved --
    the reliable manual consolidation move. Only when no stack can take it whole (4 + 2 with
    a stack size of 5) does it top off the largest partial with an exact split, which the
    server can bounce; a bounce is caught by the tidy watchdog, and the cursor is never left
    holding the split.
]]
local function ConsolidateOne(inventory)
	for itemID, slots in pairs(inventory.slots) do
		local maxStack = MaxStackOf(itemID)
		if maxStack then
			-- slots are sorted smallest-first (SortSlots), so partials are too
			local partials = {}
			for _, slot in ipairs(slots) do
				if slot.count < maxStack then
					partials[#partials + 1] = slot
				end
			end

			if #partials >= 2 then
				local source = partials[1]
				for i = #partials, 2, -1 do
					local destination = partials[i]
					if source.count + destination.count <= maxStack then
						ns.RestockerDebug(
							"TRACE_CONSOLIDATE",
							tostring(itemID),
							source.count,
							source.bag,
							source.slot,
							destination.bag,
							destination.slot
						)
						C_Container.PickupContainerItem(source.bag, source.slot) -- pick up whole stack
						C_Container.PickupContainerItem(destination.bag, destination.slot) -- drop onto it -> merges
						return true
					end
				end

				local destination = partials[#partials]
				local room = maxStack - destination.count
				ns.RestockerDebug(
					"TRACE_TOP_OFF",
					tostring(itemID),
					room,
					source.bag,
					source.slot,
					destination.bag,
					destination.slot
				)
				C_Container.SplitContainerItem(source.bag, source.slot, room)
				C_Container.PickupContainerItem(destination.bag, destination.slot)
				if CursorHasItem() then
					ClearCursor() -- a bounced drop must not strand the split for the next move
				end
				return true
			end
		end
	end

	return false
end

--[[
    Is this bag/bank item one we maintain? Lists are keyed by itemID, so this is
    an O(1) lookup instead of scanning the whole list by name for every bag
    slot. Hoisted out of UpdateInventory, which runs on every restock step: it
    reads the list off this upvalue rather than closing over a fresh one each time.
]]
local maintainedList

local function IsMaintainedItem(itemID)
	return maintainedList[itemID] ~= nil
end

function RestockState:UpdateInventory()
	local settings = ns.restockSettings
	maintainedList = settings.lists[settings.currentList]

	self.playerInventory = ns.GetRestockItemsInBags(IsMaintainedItem)
	self.bankInventory = ns.GetRestockItemsInBank(IsMaintainedItem)
end

--------------------------------------------------------------------------------
-- Restock Steps
--------------------------------------------------------------------------------

local function FinishRestocking(message)
	currentlyRestocking = false
	restockUpdateFrame:Hide() -- stop the periodic OnUpdate timer
	if message then
		ns.PrintMessage(message)
	end
end

--[[
    The bank window closing, from outside this file. The run is abandoned rather
    than finished, so it says nothing: the closing handler reports the shortfall.
]]
function ns.StopBankRestock()
	FinishRestocking(nil)
end

--[[
    Run a single restock step: re-scan reality, then issue at most one move. The coroutine
    calls this once per eligible tick (only after the previous move has settled -- see the
    lock gate in OnBankRestockUpdate) and yields between calls.
]]
local function RunRestockLogic()
	local state = restockState

	if not ns.bankIsOpen then
		FinishRestocking(L["RESTOCKER_BANK_NOT_OPEN"])
		return true
	end

	--[[
	    HARD SAFETY INVARIANT: never sell at a merchant. The moves below use
	    C_Container.UseContainerItem to shift whole stacks, and that call SELLS the item when a
	    merchant window is open (it only moves to the bank when a BANK is open). A bank and a
	    merchant can't normally both be open, but if the merchant flag is set -- a stale flag, or
	    an odd BANKFRAME/MERCHANT event order -- issuing a stash here would vendor the player's
	    "too many" excess. Refuse to act: bail cleanly, and the next real bank visit restarts.
	]]
	if ns.merchantIsOpen then
		ns.RestockerDebug("TRACE_MERCHANT_OPEN")
		FinishRestocking(nil)
		return true
	end

	--[[
	    Reconcile against reality every step: re-derive the outstanding work from what's
	    actually in the bags/bank right now. A move that was rejected or only partially placed
	    simply reappears as remaining work and gets retried; a move that worked shrinks the
	    work for real.

	    A declined rescan (the player is holding something of their own) is a skipped tick,
	    not a stalled run: nothing below has read this step's inventories yet, and the step
	    is deliberately not counted against the watchdog, since no move was attempted.
	]]
	if not state:Rescan() then
		return false
	end

	--[[
	    In-flight gate: a maintained item's bag+bank total can only DROP while a move is in
	    transit (source slot already empty, destination not yet credited -- and nothing is
	    locked in that window, so the lock gate in OnBankRestockUpdate can't hold us back). A scan
	    taken there under-counts: acting on it is what pulled a duplicate stack ("8 -> 28"),
	    and when the in-transit stack was the bank's LAST one, printed "Finished restocking"
	    with the pull still in the air -- skipping the stash-back. Don't move and don't finish
	    off a scan like that; wait for the total to recover. If it stays down past
	    MAX_INFLIGHT_STEPS, the item really left (consumed/destroyed) -- accept the new
	    baseline and continue.
	]]
	local totals = state:ComputeTotals()
	if state.lastTotals ~= nil and state.suspectSteps < MAX_INFLIGHT_STEPS then
		for itemID, previousTotal in pairs(state.lastTotals) do
			if (totals[itemID] or 0) < previousTotal then
				state.suspectSteps = state.suspectSteps + 1
				local listItem = state.currentList[itemID]
				ns.RestockerDebug(
					"TRACE_IN_TRANSIT",
					listItem and listItem.itemName or tostring(itemID),
					totals[itemID] or 0,
					previousTotal
				)
				return false
			end
		end
	end
	state.suspectSteps = 0
	state.lastTotals = totals

	local remaining = state:RemainingWork()

	if remaining > 0 then
		state.consolidating = false -- still moving; tidy phase (below) hasn't started

		--[[
		    Watchdog. We normally get here with locks already settled (OnBankRestockUpdate gates on
		    that, until one of ours has stayed locked for MAX_STUCK_STEPS ticks), so if the
		    outstanding work did NOT shrink since last step, the last move genuinely didn't land --
		    a rejected split, an item stuck locked, or something we can't place. Retry a few times to absorb
		    transient races, then give up with a clear message. With it the run neither spins
		    forever on a move that never lands nor reports success while still short.
		]]
		if remaining < state.lastRemainingWork then
			state.stuckSteps = 0
		else
			state.stuckSteps = state.stuckSteps + 1
			if state.stuckSteps >= MAX_STUCK_STEPS then
				FinishRestocking(state:StuckMessage())
				return true
			end
		end
		state.lastRemainingWork = remaining

		--[[
		    ONE move per tick: stash an over-stocked item or pull an under-stocked one. Doing
		    only one keeps a stash and a restock from firing in the same tick and fighting over
		    the cursor. ALWAYS keep going (return false) even if nothing was issued -- a slot may
		    still be locked from the previous move; the watchdog above is what stops us if we're
		    genuinely stuck. Stashing runs first so it can free a bag slot for restocking, except
		    while the bank has no free slot: a stash cannot land then, and retrying it would
		    starve every pull, so restocking runs first, and a whole stack taken out frees the
		    slot the stash needs.
		]]
		local _, bankHasSpace = ns.GetRestockSpace()
		if bankHasSpace then
			if not StashToBank() then
				RestockFromBank()
			end
		elseif not RestockFromBank() then
			StashToBank()
		end
		return false
	end

	--[[
	    All items are at target. TIDY PHASE (best-effort): merge the partial stacks that
	    free-slot-first placement and exact splits leave behind, in the bags and then the bank. This can never leave an item short (totals are
	    already correct) -- the worst case is that a merge doesn't take and we simply stop.
	]]
	if not state.consolidating then
		state.consolidating = true -- entering tidy phase; start its watchdog fresh
		state.lastStackCount = math.huge
		state.tidySteps = 0
	end

	--[[
	    Tidy watchdog: each successful merge leaves one fewer partial stack, so the partial
	    stack count strictly drops while we're making progress. If it stops dropping (fully
	    consolidated, or a merge got bounced), finish cleanly -- restocking already succeeded,
	    so this is a normal "Finished", not a problem to report.
	]]
	local stacks = state:CountPartialStacks()
	if stacks < state.lastStackCount then
		state.tidySteps = 0
	else
		state.tidySteps = state.tidySteps + 1
		if state.tidySteps >= MAX_STUCK_STEPS then
			FinishRestocking(
				string.format(
					L["RESTOCKER_COMPLETE"],
					GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("TEXT")
				)
			)
			return true
		end
	end
	state.lastStackCount = stacks

	if ConsolidateOne(state.playerInventory) or ConsolidateOne(state.bankInventory) then
		return false -- merged a pair; re-scan next tick and keep tidying
	end

	-- Nothing left to merge: genuinely done.
	FinishRestocking(
		string.format(L["RESTOCKER_COMPLETE"], GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("TEXT"))
	)
	return true
end

local function RunRestockCoroutine()
	while RunRestockLogic() == false and ns.bankIsOpen do
		coroutine.yield()
	end
end

local restockCoroutine = coroutine.create(RunRestockCoroutine)

local function MaintainAndResumeCoroutine()
	if restockCoroutine == nil or coroutine.status(restockCoroutine) == "dead" then
		ns.RestockerDebug("TRACE_CREATE_COROUTINE")
		restockCoroutine = coroutine.create(RunRestockCoroutine)
	end

	if coroutine.status(restockCoroutine) == "running" then
		ns.RestockerDebug("TRACE_COROUTINE_RUNNING")
		return
	end

	local ok, errorMessage = coroutine.resume(restockCoroutine)

	if not ok then
		--[[
		    Surface the error to the user instead of letting it vanish, then stop so we don't
		    respawn the coroutine and re-trigger the same error every tick. Reopening the bank
		    (ns.RestartBankRestock) creates a fresh coroutine and retries.
		]]
		ns.PrintMessage(string.format(L["RESTOCKER_STOPPED_ERROR"], tostring(errorMessage)))
		FinishRestocking(nil)
		restockCoroutine = nil
	end
end

--------------------------------------------------------------------------------
-- Move Timer
--------------------------------------------------------------------------------

--[[
    One move is issued per tick. Pace ticks to the connection so a move has time to be
    confirmed by the server before the next one: wait ~3x the round-trip, but never faster
    than 0.140s. GetNetStats only refreshes its figures every ~30s, so this is called once
    per tick (and once at restock start) rather than on every OnUpdate frame.
]]
local function ComputeUpdateInterval()
	local _, _, pingHome, pingWorld = GetNetStats()
	local maxPing = math.max(pingHome, pingWorld)
	return math.max(0.140, (maxPing * 3) / 1000)
end

local function OnBankRestockUpdate(_frame, elapsed)
	if ns.bankIsOpen == false then
		restockUpdateFrame:Hide() -- stop the periodic timer in the update frame
		return -- nope
	end

	updateTimer = updateTimer + elapsed

	if updateTimer >= updateInterval then
		updateTimer = 0
		updateInterval = ComputeUpdateInterval() -- pace the NEXT tick

		if currentlyRestocking then
			--[[
			    Wait until the previous move has FULLY settled (no slot still locked) before
			    issuing the next one. Firing a split while the server is still consolidating the
			    item from a move ~140ms ago is what gets rejected with "Couldn't split those
			    items". The fixed tick interval alone isn't enough on a laggy connection. Only wait
			    on OUR items -- an unrelated locked slot must not stall the restock forever.

			    One of ours can stay locked too (held on the cursor, or a lock the server never
			    clears). After MAX_STUCK_STEPS locked ticks the gate stops waiting and resumes, so
			    ClearCursorForScan can clear our own stray and the watchdog can count the steps
			    that land nothing and stop with StuckMessage.
			]]
			if restockState and ns.IsRestockItemLocked(restockState.currentList) then
				restockState.lockedTicks = restockState.lockedTicks + 1
				if restockState.lockedTicks < MAX_STUCK_STEPS then
					return
				end
			elseif restockState then
				restockState.lockedTicks = 0
			end
			MaintainAndResumeCoroutine()
		end
	end
end

function ns.RestartBankRestock()
	restockState = NewRestockState()
	currentlyRestocking = true
	updateInterval = ComputeUpdateInterval() -- pace the first tick off a fresh reading
	restockCoroutine = coroutine.create(RunRestockCoroutine) -- fresh run for this bank visit
	restockUpdateFrame:Show() -- start the periodic timer in the update frame
end

restockUpdateFrame = CreateFrame("Frame")
restockUpdateFrame:SetScript("OnUpdate", OnBankRestockUpdate)

--[[
    There is no manual re-trigger for a restock, and there must not be one on the
    Diagnostic Tools panel: that panel is read-only by rule, and a restock moves
    the player's items. Closing and reopening the bank restarts a run, and the
    step-by-step trace behind ns.RestockerDebug is what actually explains a stuck
    one. For the logic with no game running, see
    Tests/Restocker-Restock-Planner-Test.lua.
]]
