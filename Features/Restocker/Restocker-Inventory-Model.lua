local _, ns = ...

--------------------------------------------------------------------------------
-- Restock Trace
--------------------------------------------------------------------------------

--[[
    The bank restock's step-by-step trace. Gated on the Diagnostic Tools panel's
    runtime flag, which lives in memory and starts false at every login, so a
    player can never leave this on -- and the boolean is read before any string
    work, so a run with diagnostics off pays one comparison per call.

    Developer-facing, so the text stays plain English and out of Locales/: each
    message is a TRACE_* format in ns.DiagnosticsStrings (Diagnostics/Diagnostics-Core.lua),
    passed here by key and looked up only once the gate is open.

    Restocker-Bags.lua and Restocker-Bank.lua both call it.

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
