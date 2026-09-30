-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the bank restock planner (no WoW API needed).

    Run it with:   lua Tests/Restocker-Restock-Planner-Test.lua

    It models the SAME algorithm the live add-on uses (Restocker-Bank.lua + Restocker-Bags.lua):
      * re-scan the CURRENT bag/bank contents every step and re-derive the outstanding work
        (RunRestockLogic -> RestockState:Rescan / RemainingWork)
      * issue at most one move per step, then re-scan
      * stash before pulling, to free bag room, except while the bank has no free slot, when a
        pull goes first and frees one
      * whole-stack moves auto-merge into existing partial stacks, overflow to a free slot
      * a partial need is split off and best-fit merged; an "uncached" item skips the merge
      * NOTHING is deducted from a running tally -- a move that gets rejected or can't be
        placed simply leaves the item still short next scan, and is retried
      * a WATCHDOG stops the run if MAX_STUCK_STEPS pass with no reduction in outstanding
        work (a rejected split, or no room), reporting what's left -- instead of looping
        forever (the old recompute-every-step spam) or claiming success while short (the old
        optimistic-deduct bug)
      * if an exact bank->bag split keeps being bounced ("Couldn't split those items"), fall
        back to pulling the WHOLE stack -- overshoot the target, then stash the excess back.
        Whole-stack moves always land, so the target is reached instead of stopping short
      * overshoot excess is stashed back even for items that don't normally stash to bank --
        the add-on created that excess, so it returns it (bag ends exactly on target)
      * a scan where an item's bag+bank TOTAL dropped is never acted on: the item is mid-move
        between containers (and nothing is locked in that window). Acting on the under-count
        is what pulled duplicate stacks and printed "Finished" with a pull still in the air

    The rejection/watchdog scenarios below are the ones the shipped code previously got
    wrong: an occasional failed move was counted as done, leaving "37 of 40" and a cheerful
    "Finished restocking".
]]

local STACK = 20
local WATCHDOG_LIMIT = 5 -- mirrors MAX_STUCK_STEPS in Restocker-Bank.lua

-- A container is { stacks = {counts...}, free = <free slot count> }
local function total(c)
	local t = 0
	for _, n in ipairs(c.stacks) do
		t = t + n
	end
	return t
end

local function compact(c)
	local r = {}
	for _, n in ipairs(c.stacks) do
		if n > 0 then
			r[#r + 1] = n
		end
	end
	c.stacks = r
end

local function smallestIndex(c)
	local bi, bv = nil, math.huge
	for i, n in ipairs(c.stacks) do
		if n > 0 and n < bv then
			bi, bv = i, n
		end
	end
	return bi
end

--[[
    Add `count` to a container, merging into existing partial stacks first (fullest first),
    then into new slots while free slots remain. `merge` false (uncached item) skips the
    partial-stack merge. Returns how many actually landed -- the caller removes ONLY that
    much from the source, so an item that can't be placed stays put (mirrors the live code
    returning a split item to its slot rather than losing it).
]]
local function addToContainer(c, count, merge)
	local landed = 0
	if merge then
		table.sort(c.stacks, function(a, b)
			return a > b
		end)
		for i = 1, #c.stacks do
			if count <= 0 then
				break
			end
			local room = STACK - c.stacks[i]
			if room > 0 then
				local add = math.min(room, count)
				c.stacks[i] = c.stacks[i] + add
				count, landed = count - add, landed + add
			end
		end
	end
	while count > 0 and c.free > 0 do
		local add = math.min(STACK, count)
		c.stacks[#c.stacks + 1] = add
		c.free = c.free - 1
		count, landed = count - add, landed + add
	end
	return landed
end

--[[
    Outstanding work we can actually act on: shortfalls the bank can supply + excess to stash.
    stashOn is the stash flag OR "this run overshot the item" -- overshoot excess is trimmed
    back even when the item does not normally stash to bank.
]]
local function remainingWork(bag, bank, target, fromBank, stashOn)
	local haveBag, haveBank = total(bag), total(bank)
	local work = 0
	if fromBank and haveBag < target and haveBank > 0 then
		work = work + math.min(target - haveBag, haveBank)
	end
	if stashOn and haveBag > target then
		work = work + (haveBag - target)
	end
	return work
end

--[[
    Why the watchdog gave up, matching RestockState:StuckMessage: a full bag or bank is
    blamed only for a direction with a stuck row (a withdrawal needs bag room, a deposit
    needs bank room), else a plain "stuck" -- a move that keeps being rejected.
]]
local function stuckStatus(bag, bank, target, fromBank, stashOn)
	local haveBag, haveBank = total(bag), total(bank)
	local bagBlocked = fromBank and haveBag < target and haveBank > 0 and bag.free == 0
	local bankBlocked = stashOn and haveBag > target and bank.free == 0
	if bagBlocked and bankBlocked then
		return "both full"
	end
	if bankBlocked then
		return "bank full"
	end
	if bagBlocked then
		return "bag full"
	end
	return "stuck"
end

--[[
    Run a restock to `target`, returning the final bag/bank and a status string.
    opts: { fromBank=bool, stash=bool, uncached=bool, failFirst=N, failAll=bool,
            failBankSplits=bool, landDelay=N }
      failFirst=N        -> the first N move attempts are rejected (transient race), then succeed
      failAll=true       -> every move attempt is rejected (permanently stuck)
      failBankSplits=true -> every EXACT bank->bag split bounces (the flaky server op), but
                             whole-stack moves land -- the case the overshoot fallback covers
      landDelay=N        -> bank->bag pulls land N steps late: meanwhile the moved amount is
                            in NEITHER container and nothing is locked -- the blind window
                            where an unguarded scan under-counts and finished mid-flight
]]
local function runRestock(label, bag, bank, target, opts)
	compact(bag)
	compact(bank)
	local steps = 0
	local lastRemaining = math.huge
	local stuck = 0
	local failsLeft = opts.failAll and math.huge or (opts.failFirst or 0)
	local overshot = false -- this run pulled a whole stack past target; trim the excess back
	local pending = nil -- a bank->bag pull still in transit: { amount, ticks }
	local lastTotal = nil -- bag+bank at the last ACCEPTED scan (conservation baseline)
	local suspects = 0 -- consecutive scans skipped waiting for a pull to land

	while true do
		steps = steps + 1
		assert(steps < 2000, label .. ": did not terminate")

		-- Time passes: an in-transit pull lands (scenarios leave room, so all of it fits)
		if pending then
			pending.ticks = pending.ticks - 1
			if pending.ticks <= 0 then
				addToContainer(bag, pending.amount, not opts.uncached)
				pending = nil
			end
		end

		--[[
		    In-flight gate, mirrors RunRestockLogic: the bag+bank total can only DROP while a
		    move is in transit, and nothing is locked in that window -- the scan under-counts
		    and must not be acted on (acting on it is what printed "Finished" with a pull still
		    in the air). Wait for the total to recover; accept after a few steps if it stays down.
		]]
		local totalNow = total(bag) + total(bank)
		if lastTotal ~= nil and totalNow < lastTotal and suspects < 3 then
			suspects = suspects + 1
		else
			suspects = 0
			lastTotal = totalNow

			local stashOn = opts.stash or overshot
			local remaining = remainingWork(bag, bank, target, opts.fromBank, stashOn)
			if remaining == 0 then
				table.sort(bag.stacks, function(a, b)
					return a > b
				end)
				return bag, bank, "done", steps
			end

			--[[
			    Watchdog: locks are settled by the time we re-scan (BankUpdateFn gates on that), so
			    no reduction means the last move did not land. Retry a few times, then give up.
			]]
			if remaining < lastRemaining then
				stuck = 0
			else
				stuck = stuck + 1
				if stuck >= WATCHDOG_LIMIT then
					table.sort(bag.stacks, function(a, b)
						return a > b
					end)
					return bag, bank, stuckStatus(bag, bank, target, opts.fromBank, stashOn), steps
				end
			end
			lastRemaining = remaining

			-- Issue one move, computed fresh from current contents.
			local rejected = false
			if failsLeft > 0 then
				failsLeft = failsLeft - 1
				rejected = true -- the server rejected it / nothing could be placed: no change
			end

			if not rejected then
				local haveBag, haveBank = total(bag), total(bank)
				if stashOn and haveBag > target then
					local si = smallestIndex(bag)
					local moveAmt = math.min(bag.stacks[si], haveBag - target)
					local landed = addToContainer(bank, moveAmt, not opts.uncached)
					bag.stacks[si] = bag.stacks[si] - landed
				elseif opts.fromBank and haveBag < target and haveBank > 0 then
					local want = math.min(target - haveBag, haveBank)
					local si = smallestIndex(bank)
					local moveAmt = math.min(bank.stacks[si], want)
					local isSplit = moveAmt < bank.stacks[si]
					--[[
					    Mirrors ns.MoveRestockItemFromBank's overshoot fallback: a no-progress step means
					    the exact split is being bounced, so pull the whole stack instead -- that
					    always lands. The excess is remembered (overshot) and trimmed back above.
					]]
					if isSplit and stuck > 0 then
						moveAmt = bank.stacks[si]
						isSplit = false
						overshot = true
					end
					if not (isSplit and opts.failBankSplits) then
						bank.stacks[si] = bank.stacks[si] - moveAmt
						if (opts.landDelay or 0) > 0 then
							pending = { amount = moveAmt, ticks = opts.landDelay }
						else
							local landed = addToContainer(bag, moveAmt, not opts.uncached)
							bank.stacks[si] = bank.stacks[si] + (moveAmt - landed) -- unplaceable part stays
						end
					end
				end
			end
		end

		compact(bag)
		compact(bank)
	end
end

local function fmt(c)
	return "{" .. table.concat(c.stacks, ",") .. "} free=" .. c.free
end

local pass = 0
local function scenario(label, bag, bank, target, opts, check)
	local b, k, status, steps = runRestock(label, bag, bank, target, opts)
	print(("%-26s -> bag %-18s bank %-14s [%s, %d steps]"):format(label, fmt(b), fmt(k), status, steps))
	check(b, k, status)
	pass = pass + 1
end

-- 1. Split needed: bank has one big stack, pull a partial to hit an odd target
scenario(
	"split needed",
	{ stacks = { 5 }, free = 10 },
	{ stacks = { 20 }, free = 10 },
	17,
	{ fromBank = true },
	function(bag)
		assert(total(bag) == 17, "want 17")
	end
)

-- 2. Multi-stack consolidation: messy bank stacks merge into fewest bag stacks
scenario(
	"multi-stack consolidate",
	{ stacks = { 17 }, free = 10 },
	{ stacks = { 5, 5, 5, 8 }, free = 10 },
	40,
	{ fromBank = true },
	function(bag)
		assert(total(bag) == 40, "want 40")
		assert(#bag.stacks == 2, "want 2 stacks, got " .. #bag.stacks)
	end
)

-- 3. Bank full: stashing excess but the bank has no room -> stops, reports bank full
scenario(
	"bank full",
	{ stacks = { 20, 20, 20 }, free = 5 },
	{ stacks = { 20, 20 }, free = 0 },
	40,
	{ stash = true },
	function(_, _, status)
		assert(status == "bank full", "want bank full, got " .. status)
	end
)

-- 4. Bag full: pulling from bank but bags are packed -> stops, reports bag full
scenario(
	"bag full",
	{ stacks = { 20, 20 }, free = 0 },
	{ stacks = { 20 }, free = 5 },
	60,
	{ fromBank = true },
	function(_, _, status)
		assert(status == "bag full", "want bag full, got " .. status)
	end
)

-- 4a. A withdrawal that stalls while the bank happens to be full: the bank is not to blame
scenario(
	"withdraw stuck, bank full",
	{ stacks = { 5 }, free = 5 },
	{ stacks = { 20 }, free = 0 },
	17,
	{ fromBank = true, failAll = true },
	function(_, _, status)
		assert(status == "stuck", "want stuck, got " .. status)
	end
)

-- 5. Uncached item: still reaches target, just without best-fit merging
scenario(
	"uncached item",
	{ stacks = {}, free = 10 },
	{ stacks = { 20, 20 }, free = 10 },
	40,
	{ fromBank = true, uncached = true },
	function(bag)
		assert(total(bag) == 40, "want 40 even when uncached")
	end
)

-- 6. Already correct: no work, terminates immediately
scenario(
	"already correct",
	{ stacks = { 20, 20 }, free = 5 },
	{ stacks = { 10 }, free = 5 },
	40,
	{ fromBank = true, stash = true },
	function(bag, _, _)
		assert(total(bag) == 40, "stay at 40")
	end
)

--[[
    7. Transient rejection: the first 2 split attempts are refused ("Couldn't split those
       items"), then they go through. The old optimistic-deduct code counted the refused
       moves as done and finished short; the watchdog-driven retry reaches the target.
]]
scenario(
	"transient rejection",
	{ stacks = {}, free = 10 },
	{ stacks = { 20, 20 }, free = 10 },
	40,
	{ fromBank = true, failFirst = 2 },
	function(bag, _, status)
		assert(status == "done", "want done, got " .. status)
		assert(total(bag) == 40, "want 40 after recovering from rejects, got " .. total(bag))
	end
)

--[[
    8. Permanent rejection: every move is refused though there's plenty of room. Must NOT
       loop forever and must NOT report success -- it gives up as "stuck", still short.
]]
scenario(
	"permanent rejection",
	{ stacks = {}, free = 10 },
	{ stacks = { 20, 20 }, free = 10 },
	40,
	{ fromBank = true, failAll = true },
	function(bag, _, status)
		assert(status == "stuck", "want stuck, got " .. status)
		assert(total(bag) == 0, "should have moved nothing, got " .. total(bag))
	end
)

--[[
    9. Partial bank: the bank simply doesn't have enough. Pull all it has and finish
       honestly at 26/40 -- this is a clean "done", not a stuck/error.
]]
scenario(
	"partial bank supply",
	{ stacks = {}, free = 10 },
	{ stacks = { 20, 6 }, free = 10 },
	40,
	{ fromBank = true },
	function(bag, _, status)
		assert(status == "done", "want done, got " .. status)
		assert(total(bag) == 26, "want all 26 the bank had, got " .. total(bag))
	end
)

--[[
    10. Flaky last-unit split, stash flag OFF: the exact split of the final 2 bounces every
        time (the "8 need 10" log). The fallback pulls the whole stack, going over target --
        and because the OVERSHOOT created that excess, it is stashed back even though the
        item does not normally stash to bank. Ends exactly on target.
]]
scenario(
	"flaky split overshoots",
	{ stacks = { 5, 2, 1 }, free = 10 },
	{ stacks = { 18 }, free = 10 },
	10,
	{ fromBank = true, failBankSplits = true },
	function(bag, _, status)
		assert(status == "done", "want done, got " .. status)
		assert(total(bag) == 10, "want exactly 10 after overshoot trim, got " .. total(bag))
	end
)

--[[
    11. Flaky split WITH stash-back: overshoot pulls the whole stack, then the stash pass
        returns the excess, landing exactly on target. (Bag->bank splits still work here --
        it's the bank->bag split that's the flaky op.)
]]
scenario(
	"flaky split + stash back",
	{ stacks = { 5, 2, 1 }, free = 10 },
	{ stacks = { 18 }, free = 10 },
	10,
	{ fromBank = true, stash = true, failBankSplits = true },
	function(bag, _, status)
		assert(status == "done", "want done, got " .. status)
		assert(total(bag) == 10, "want exactly 10 after stash-back, got " .. total(bag))
	end
)

--[[
    12. In-flight blind spot: the overshoot pull takes 2 steps to land, and it was the
        bank's LAST stack. Meanwhile the item is in NEITHER container and nothing is locked:
        an unguarded scan reads 9/10 with an empty bank -- zero actionable work -- and prints
        "Finished restocking" with the stack still in the air, skipping the stash-back (the
        "Finished right after Overshoot" log). The in-flight gate must wait out the dip and
        end exactly on target with the excess back in the bank.
]]
scenario(
	"in-flight pull, no early finish",
	{ stacks = { 9 }, free = 10 },
	{ stacks = { 5 }, free = 10 },
	10,
	{ fromBank = true, failBankSplits = true, landDelay = 2 },
	function(bag, bank2, status)
		assert(status == "done", "want done, got " .. status)
		assert(total(bag) == 10, "want exactly 10, got " .. total(bag))
		assert(total(bank2) == 4, "want the 4 excess back in bank, got " .. total(bank2))
	end
)

--[[
    Rows sharing one bag and one bank: each container is { free = <free slots>, items =
    { [row name] = {counts...} } }, and rows is a list of { name, target, fromBank, stash }.
    Only whole stacks move here, which is all scenario 13 needs. It mirrors the move order in
    RunRestockLogic: a stash first, so it can free bag room for a pull, except while the bank
    has no free slot, when a pull goes first to free one. A move is issued whether or not it
    can land, as ns.MoveRestockItemToBank's is, so a stash into a full bank lands nothing.
]]
local function itemView(container, name)
	container.items[name] = container.items[name] or {}
	return { stacks = container.items[name], free = container.free }
end

local function moveWholeStack(from, to, name, index)
	local source, destination = itemView(from, name), itemView(to, name)
	local count = source.stacks[index]
	local landed = addToContainer(destination, count, true)
	to.free = destination.free
	source.stacks[index] = count - landed
	if source.stacks[index] == 0 then
		table.remove(source.stacks, index)
		from.free = from.free + 1
	end
end

local function runRows(label, bag, bank, rows)
	local steps, stuck, lastRemaining = 0, 0, math.huge
	while true do
		steps = steps + 1
		assert(steps < 200, label .. ": did not terminate")

		local remaining = 0
		for _, row in ipairs(rows) do
			local inBag, inBank = itemView(bag, row.name), itemView(bank, row.name)
			remaining = remaining + remainingWork(inBag, inBank, row.target, row.fromBank, row.stash)
		end
		if remaining == 0 then
			return "done", steps
		end
		if remaining < lastRemaining then
			stuck = 0
		else
			stuck = stuck + 1
			if stuck >= WATCHDOG_LIMIT then
				return "stuck", steps
			end
		end
		lastRemaining = remaining

		-- The first row owed a move in this direction moves its smallest stack.
		local function issue(from, to, owed)
			for _, row in ipairs(rows) do
				local amount = owed(row, total(itemView(bag, row.name)), total(itemView(bank, row.name)))
				if amount > 0 then
					local stacks = itemView(from, row.name).stacks
					local index = smallestIndex({ stacks = stacks })
					assert(stacks[index] <= amount, label .. ": this model moves whole stacks only")
					moveWholeStack(from, to, row.name, index)
					return true
				end
			end
			return false
		end
		local function stash()
			return issue(bag, bank, function(row, haveBag)
				return row.stash and haveBag - row.target or 0
			end)
		end
		local function pull()
			return issue(bank, bag, function(row, haveBag, haveBank)
				return row.fromBank and haveBank > 0 and row.target - haveBag or 0
			end)
		end

		if bank.free > 0 then
			if not stash() then
				pull()
			end
		elseif not pull() then
			stash()
		end
	end
end

--[[
    13. A full bank, one row with extras to store and another short with stock in the bank.
        A stash cannot land in a full bank, so stashing first retried it until the watchdog
        stopped the run as "bank full" with nothing taken out. The pull goes first and frees
        the slot the stash needs, and both rows end on target.
]]
do
	local label = "full bank, store and take"
	local bag = { free = 5, items = { stored = { 20, 20 }, taken = {} } }
	local bank = { free = 0, items = { taken = { 20 } } }
	local status, steps = runRows(label, bag, bank, {
		{ name = "stored", target = 20, stash = true },
		{ name = "taken", target = 20, fromBank = true },
	})
	print(("%-26s -> [%s, %d steps]"):format(label, status, steps))
	assert(status == "done", "want done, got " .. status)
	assert(total(itemView(bag, "stored")) == 20, "want the stored row on 20")
	assert(total(itemView(bag, "taken")) == 20, "want the taken row on 20")
	pass = pass + 1
end

--[[
    ---------------------------------------------------------------------------------------
    Consolidation (tidy phase) -- mirrors ConsolidateOne in Restocker-Bank.lua, one item's
    stacks at a time: take the SMALLEST partial stack and pour it whole into the largest
    partial that has room for ALL of it; when none has, split just enough off it to top the
    largest partial up to full. Every step leaves one partial stack fewer, and it stops once
    at most one is left.
]]
local function consolidate(stacks, maxStack)
	local steps = 0
	while true do
		steps = steps + 1
		assert(steps < 1000, "consolidate did not terminate")
		table.sort(stacks, function(a, b)
			return a < b
		end) -- smallest first
		local partials = {}
		for index, count in ipairs(stacks) do
			if count < maxStack then
				partials[#partials + 1] = index
			end
		end
		if #partials < 2 then
			break
		end
		local source = partials[1]
		local merged = false
		for i = #partials, 2, -1 do
			local destination = partials[i]
			if stacks[source] + stacks[destination] <= maxStack then
				stacks[destination] = stacks[destination] + stacks[source]
				table.remove(stacks, source)
				merged = true
				break
			end
		end
		if not merged then
			local destination = partials[#partials]
			stacks[source] = stacks[source] - (maxStack - stacks[destination])
			stacks[destination] = maxStack
		end
	end
	table.sort(stacks, function(a, b)
		return a > b
	end)
	return stacks
end

local function consolidateScenario(label, stacks, maxStack, wantStacks)
	local got = consolidate(stacks, maxStack)
	print(("consolidate %-16s -> {%s} (max %d)"):format(label, table.concat(got, ","), maxStack))
	assert(#got == #wantStacks, label .. ": want " .. #wantStacks .. " stacks, got " .. #got)
	for i = 1, #wantStacks do
		assert(got[i] == wantStacks[i], label .. ": stack " .. i .. " want " .. wantStacks[i] .. " got " .. got[i])
	end
	pass = pass + 1
end

print("")
-- The reported case: 10 + 9 + 1 should collapse to a single full stack.
consolidateScenario("10+9+1", { 10, 9, 1 }, 20, { 20 })
-- Many small stacks fully combine.
consolidateScenario("5+5+5+5", { 5, 5, 5, 5 }, 20, { 20 })
-- Already tidy: nothing to do.
consolidateScenario("single full", { 20 }, 20, { 20 })
--[[
    No whole stack fits into another, so the largest partial is topped up by a split: the
    stack count holds, and every stack but one ends full.
]]
consolidateScenario("11+11", { 11, 11 }, 20, { 20, 2 })
consolidateScenario("11+11+11", { 11, 11, 11 }, 20, { 20, 13 })

print(("\nALL %d RESTOCK PLANNER SCENARIOS PASSED"):format(pass))
