local _, ns = ...

--[[
    The player's own bags, read by the merchant restock to refuse a purchase with
    nowhere to put it. The bank orderings below are only ever walked in here.
]]
ns.restockPlayerBags = {}

local BagDefinition = {}
BagDefinition.__index = BagDefinition

local bankBags = {} -- filled by ns.LoadRestockBankBags
local bankBagsReversed = {} -- filled by ns.LoadRestockBankBags

-- Defined near the end of this file; forward-declared for the slot scans that call it first.
local GetRestockContainerItemInfo

--------------------------------------------------------------------------------
-- Bag Definitions
--------------------------------------------------------------------------------

--[[
    A container the restocker moves items through. `location` is a label for the debug
    log only -- every container is filled the same way, by naming an empty slot (see
    BagDefinition:PutCursorItem). No inventory-slot id is kept: its only use would be
    PutItemInBag, which this file must never call.
]]
local function NewBagDefinition(location, bagID)
	local result = {}
	result.location = location
	result.bagID = bagID
	setmetatable(result, BagDefinition)
	return result
end

local function CreateBackpack()
	return NewBagDefinition("backpack", BACKPACK_CONTAINER)
end

local function CreateBag(bag)
	return NewBagDefinition("bag", bag)
end

local function CreateBankMainBag()
	return NewBagDefinition("bank", BANK_CONTAINER)
end

local function CreateBankBag(bag)
	-- Bank bag ids follow the player's own, offset by NUM_BAG_SLOTS: 5..10 on Classic Era (six slots), 5..11 on TBC.
	return NewBagDefinition("bank", bag + NUM_BAG_SLOTS)
end

--[[
    Forever has no BANK_CONTAINER and no bank bags: its character bank is the
    C_Bank tabs the player has bought, which can change at any visit, so the
    bank open handler calls this again. Era and TBC rebuild the same fixed
    layout each time.
]]
function ns.LoadRestockBankBags()
	local tabIDs = ns.FetchPurchasedBankTabIDs()
	if tabIDs then
		bankBags = {}
		bankBagsReversed = {}
		for index, bagID in ipairs(tabIDs) do
			bankBags[index] = NewBagDefinition("bank", bagID)
			bankBagsReversed[#tabIDs - index + 1] = bankBags[index]
		end
		return
	end

	bankBags = {
		CreateBankMainBag(),
		CreateBankBag(1),
		CreateBankBag(2),
		CreateBankBag(3),
		CreateBankBag(4),
		CreateBankBag(5),
		CreateBankBag(6),
		CreateBankBag(7),
	}
	bankBagsReversed = {
		CreateBankBag(7),
		CreateBankBag(6),
		CreateBankBag(5),
		CreateBankBag(4),
		CreateBankBag(3),
		CreateBankBag(2),
		CreateBankBag(1),
		CreateBankMainBag(),
	}
end

function ns.InitRestockBagDefinitions()
	ns.LoadRestockBankBags()

	ns.restockPlayerBags = { CreateBackpack(), CreateBag(1), CreateBag(2), CreateBag(3), CreateBag(4) }
end

--[[
    Whether a container of this type may hold the item. A free-slot count alone is not
    enough: a specialty bag (quiver, soul/herb/enchanting bag) reports free slots that a
    regular item can never occupy.
]]
local function BagTypeAccepts(bagType, itemInfo)
	if not bagType or bagType == 0 then
		return true -- regular container takes anything
	end
	if not itemInfo then
		return false -- unknown item: only trust regular containers
	end
	if itemInfo.itemEquipLoc == "INVTYPE_BAG" then
		return false -- equippable bags can only be stored in regular containers
	end
	local itemFamily = C_Item.GetItemFamily(itemInfo.itemID)
	return itemFamily ~= nil and itemFamily ~= 0 and bit.band(itemFamily, bagType) ~= 0
end

--[[
    True if this container has a free slot AND is allowed to hold the given item.

    A shortcut, not a safety net: placement names the slot itself, so a container that
    refuses the item leaves it on the cursor and the caller simply tries the next one;
    skipping the bags that were never going to take it just saves the trip.
]]
function BagDefinition:CanAcceptItem(itemInfo)
	local numberOfFreeSlots, bagType = C_Container.GetContainerNumFreeSlots(self.bagID)
	if numberOfFreeSlots <= 0 then
		return false
	end
	return BagTypeAccepts(bagType, itemInfo)
end

--[[
    Drop into the first genuinely-empty slot of this container, naming the slot
    ourselves. Detect empty with GetContainerItemInfo -- it returns nil ONLY when the
    slot is truly empty, whereas GetContainerItemLink is also nil for a not-yet-cached
    item, which made us "place" onto an occupied slot and strand the item.

    EVERY container goes through this, player bags included. The two APIs that let the
    SERVER pick the slot -- PutItemInBackpack and PutItemInBag(invslot) -- clear the
    cursor the moment they are called, whether or not the drop is accepted. That makes
    the caller's "did it land?" test (CursorHasItem) answer "yes" even when the server
    refused and bounced the item back to its source, so the caller stops early, never
    tries the remaining bags, and the re-scan finds the item still missing. Naming the
    slot keeps the item on the cursor on a refusal, which is what makes that test true.
]]
function BagDefinition:PutCursorItem()
	for slot = 1, C_Container.GetContainerNumSlots(self.bagID) do
		if not C_Container.GetContainerItemInfo(self.bagID, slot) then
			ns.RestockerDebug("TRACE_PUT_CURSOR_ITEM", self.location, self.bagID, slot)
			C_Container.PickupContainerItem(self.bagID, slot)
			return
		end
	end

	--[[
	    No empty slot, so nothing was attempted and the cursor still holds the item --
	    deliberately, so the caller can try the next bag. Never ClearCursor here.
	]]
	ns.RestockerDebug("TRACE_PUT_CURSOR_NO_SLOT", self.location, self.bagID)
end

--------------------------------------------------------------------------------
-- Scanning
--------------------------------------------------------------------------------

--[[
    True if any slot we care about is still mid-move (locked). A locked slot means the last
    move hasn't settled on the server yet -- issuing the next one now is exactly what gets a
    split rejected with "Couldn't split those items".

    `list` narrows "we care about" to the items on the current list. Only OUR items may
    stall a restock: an unrelated locked item, something
    the player is equipping or a pending trade, would otherwise hold it up forever.
]]
local function AnyRestockItemLocked(bags, list)
	for _, bag in ipairs(bags) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			local itemInfo = C_Container.GetContainerItemInfo(bag.bagID, slot)
			if
				itemInfo
				and itemInfo.isLocked
				and (list == nil or (itemInfo.itemID and list[itemInfo.itemID] ~= nil))
			then
				return true
			end
		end
	end
	return false
end

function ns.IsRestockItemLocked(list)
	return AnyRestockItemLocked(ns.restockPlayerBags, list) or AnyRestockItemLocked(bankBagsReversed, list)
end

function ns.GetRestockItemsInBags(predicate)
	local result = ns.NewRestockInventory()

	for _, bag in ipairs(ns.restockPlayerBags) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			local itemInfo = C_Container.GetContainerItemInfo(bag.bagID, slot)

			-- Keyed by itemID: unambiguous, locale-proof, and matches the list's keys
			if itemInfo and itemInfo.itemID then
				local id = itemInfo.itemID

				-- Allow filtering by predicate
				if predicate == nil or predicate(id) == true then
					result.summary[id] = (result.summary[id] or 0) + itemInfo.stackCount

					result.slots[id] = result.slots[id] or {}
					table.insert(result.slots[id], ns.NewRestockInventorySlot(bag.bagID, slot, itemInfo.stackCount))
				end
			end
		end
	end

	result:SortSlots()
	return result
end

--[[
    Every different item in the player's bags, once each, as the Add Item From
    Bags menu draws them (Restocker-Window-Bag-Menu.lua): the first slot's
    record for each, which carries the name, link and icon. A slot whose item
    the client has not resolved has no link to name it by and is left out; it
    is there the next time the menu opens.
]]
function ns.GetRestockBagItems()
	local items, seen = {}, {}
	for _, bag in ipairs(ns.restockPlayerBags) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			local containerItemInfo = GetRestockContainerItemInfo(bag.bagID, slot)
			if containerItemInfo and containerItemInfo.itemID and not seen[containerItemInfo.itemID] then
				seen[containerItemInfo.itemID] = true
				items[#items + 1] = containerItemInfo
			end
		end
	end
	return items
end

function ns.GetRestockItemsInBank(predicate)
	local result = ns.NewRestockInventory()

	for _, bag in ipairs(bankBagsReversed) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			local itemInfo = C_Container.GetContainerItemInfo(bag.bagID, slot)
			-- Keyed by itemID (no hyperlink/name parsing needed)
			if itemInfo and itemInfo.itemID then
				local id = itemInfo.itemID

				-- Allow filtering by predicate
				if predicate == nil or predicate(id) == true then
					result.summary[id] = (result.summary[id] or 0) + itemInfo.stackCount

					result.slots[id] = result.slots[id] or {}
					table.insert(result.slots[id], ns.NewRestockInventorySlot(bag.bagID, slot, itemInfo.stackCount))
				end
			end
		end
	end

	result:SortSlots()
	return result
end

-- Takes cursor item. Drops it into the bank, preferring a free slot.
local function PutItemInBank(bankInventory, itemInfo, amount)
	if not CursorHasItem() then
		return false
	end

	--[[
	    Drop into a FREE slot first -- that is the reliable move. Only stop once it has ACTUALLY
	    landed: a container's free-slot COUNT can disagree with its per-slot contents -- on Era
	    and TBC the main bank container reports free slots the slot scan can't find -- so a
	    bag may claim room yet fail to take the item. Keep trying the rest; giving up after the
	    first strands the item on the cursor.
	]]
	for _, bag in ipairs(bankBags) do
		if bag:CanAcceptItem(itemInfo) then
			bag:PutCursorItem()
			if not CursorHasItem() then
				break -- landed
			end
		end
	end

	--[[
	    No free slot took it (bank effectively full). LAST resort: merge into the best partial
	    stack. We AVOID doing this first because merging a just-split cursor item onto an
	    occupied same-item slot can be rejected and BOUNCE the item back to its source, emptying
	    the cursor without it ever landing (that's what left "9 need 10" stuck). When the bank
	    is full it's the only chance to land the item; if it still bounces, the next re-scan and
	    the watchdog report it honestly.
	]]
	if CursorHasItem() and itemInfo then
		local bestFit = bankInventory:FindBestFit(itemInfo, amount)
		if bestFit then
			C_Container.PickupContainerItem(bestFit.bag, bestFit.slot)
		end
	end

	--[[
	    CRITICAL: never leave an item stranded on the cursor. A stranded item is what makes
	    the NEXT SplitContainerItem throw "Couldn't split those items".
	]]
	if CursorHasItem() then
		ns.RestockerDebug("TRACE_BANK_NO_ROOM")
		ClearCursor()
		return false
	end

	return true
end

-- Takes cursor item. Drops it into the player bags, preferring a free slot.
local function PutItemInPlayerBag(playerInventory, itemInfo, amount)
	if not CursorHasItem() then
		return false
	end

	--[[
	    Drop into a FREE slot first -- reliable. Keep trying bags until it actually lands
	    (a bag can claim room it won't grant this item), don't give up after the first.
	]]
	for _, bag in ipairs(ns.restockPlayerBags) do
		if bag:CanAcceptItem(itemInfo) then
			bag:PutCursorItem()
			if not CursorHasItem() then
				break -- landed
			end
		end
	end

	--[[
	    No free slot took it (bags effectively full). LAST resort: merge into the best partial
	    stack. We AVOID doing this first because merging a just-split cursor item onto an
	    occupied same-item slot can be rejected and BOUNCE the item back to the bank, emptying
	    the cursor without it ever landing -- exactly what left the final unit stuck at "9 need
	    10". When bags are full it's the only way to top off a stack; a bounce is caught by the
	    next re-scan and the watchdog.
	]]
	if CursorHasItem() and itemInfo then
		local bestFit = playerInventory:FindBestFit(itemInfo, amount)
		if bestFit then
			C_Container.PickupContainerItem(bestFit.bag, bestFit.slot)
		end
	end

	--[[
	    CRITICAL: never leave an item stranded on the cursor. A stranded item is what makes
	    the NEXT SplitContainerItem throw "Couldn't split those items".
	]]
	if CursorHasItem() then
		ns.RestockerDebug("TRACE_BAG_NO_ROOM")
		ClearCursor()
		return false
	end

	return true
end

function ns.HasFreeBagSlot(bags)
	for _, bag in ipairs(bags) do
		local numberOfFreeSlots = C_Container.GetContainerNumFreeSlots(bag.bagID)
		if numberOfFreeSlots > 0 then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------
-- Purchase Space
--------------------------------------------------------------------------------

--[[
    The room a merchant run can spend, read once when the run starts: each player bag's
    free slots and type, plus the room left in partial stacks of each item bought so far.
    A purchase only lands on BAG_UPDATE, after the whole run has been sent, so the live
    counts never move mid-run; ns.ClaimBagSpace spends this copy down instead.
]]
function ns.NewBagSpace(bags)
	local space = { bags = {}, partialRoom = {} }
	for _, bag in ipairs(bags) do
		local numberOfFreeSlots, bagType = C_Container.GetContainerNumFreeSlots(bag.bagID)
		space.bags[#space.bags + 1] = { bagID = bag.bagID, free = numberOfFreeSlots, bagType = bagType or 0 }
	end
	return space
end

local function PartialStackRoom(space, itemID, stackSize)
	local room = 0
	for _, bag in ipairs(space.bags) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID) do
			local containerItemInfo = GetRestockContainerItemInfo(bag.bagID, slot)
			if containerItemInfo and containerItemInfo.itemID == itemID and containerItemInfo.count < stackSize then
				room = room + stackSize - containerItemInfo.count
			end
		end
	end
	return room
end

-- A matching specialty bag first (a quiver for arrows), so the regular slots stay free for the rest.
local function FindFreeBag(space, itemInfo)
	for _, bag in ipairs(space.bags) do
		if bag.free > 0 and bag.bagType ~= 0 and BagTypeAccepts(bag.bagType, itemInfo) then
			return bag
		end
	end
	for _, bag in ipairs(space.bags) do
		if bag.free > 0 and bag.bagType == 0 then
			return bag
		end
	end
	return nil
end

--[[
    Spends the room one purchase of `count` units takes, `count` never exceeding a stack.
    The game tops up partial stacks of the item first, and only the overflow takes a free
    slot, which then becomes a partial stack of its own. False when nothing can take it.
    An item with no cached record has no stack size to go on, so each purchase of it takes
    a whole slot.
]]
function ns.ClaimBagSpace(space, itemInfo, count)
	local itemID = itemInfo and itemInfo.itemID
	local stackSize = itemInfo and itemInfo.itemStackCount or 1
	local room = 0
	if itemID then
		room = space.partialRoom[itemID] or PartialStackRoom(space, itemID, stackSize)
	end
	if count <= room then
		space.partialRoom[itemID] = room - count
		return true
	end

	local bag = FindFreeBag(space, itemInfo)
	if not bag then
		return false
	end
	bag.free = bag.free - 1
	if itemID then
		space.partialRoom[itemID] = stackSize - (count - room)
	end
	return true
end

-- From bags list, retrieve the items matching predicate, or none while any of them is locked
local function ScanBagsFor(bags, predicate)
	local itemCandidates = {}

	for _, bag in ipairs(bags) do
		for slot = 1, C_Container.GetContainerNumSlots(bag.bagID), 1 do
			local containerItemInfo = GetRestockContainerItemInfo(bag.bagID, slot)
			if containerItemInfo and predicate(containerItemInfo) then
				if containerItemInfo.locked then
					return {}
				end

				table.insert(itemCandidates, containerItemInfo)
			end
		end
	end

	return itemCandidates
end

--------------------------------------------------------------------------------
-- Moving Items
--------------------------------------------------------------------------------

--[[
    Filter function for ScanBagsFor, matching a specific itemID (locale-proof, and never
    confuses two different items that share a localized name).
]]
local function ContainerItemInfoMatchID(id)
	return function(itemInfo)
		return itemInfo.itemID == id
	end
end

--[[
    Issue at most one bank->bag move from the given candidates. No plan bookkeeping is
    deducted here on purpose: the caller re-scans real inventory next step, so a move that
    the server rejected or only partially placed simply shows up as "still short" and is
    retried -- rather than being counted as done (which silently left items short).

    `overshoot` is the escape hatch for a split that keeps being rejected
    ("Couldn't split those items") -- pull a WHOLE stack instead and go over
    target. UseContainerItem is the one move the server never bounces; overshooting past the
    target is what guarantees it gets reached, and the stash-back pass returns the excess for
    items that stash to bank. Going a little over beats stopping short.
]]
local function MoveOneStackBankToPlayer(playerInventory, candidates, moveAmount, overshoot)
	for _, moveCandidate in ipairs(candidates) do
		-- A whole stack that fits within what we still need
		if moveCandidate.count <= moveAmount then
			ns.RestockerDebug("TRACE_USE_FROM_BANK", moveCandidate.name, moveCandidate.bag, moveCandidate.slot)
			C_Container.UseContainerItem(moveCandidate.bag, moveCandidate.slot, nil, nil)
			return true -- issued one move; next step re-scans and continues
		end

		-- Stack is bigger than the remainder: split off exactly what's left to do
		if moveCandidate.count > moveAmount then
			if overshoot then
				ns.RestockerDebug(
					"TRACE_OVERSHOOT_FROM_BANK",
					moveCandidate.name,
					moveCandidate.bag,
					moveCandidate.slot
				)
				C_Container.UseContainerItem(moveCandidate.bag, moveCandidate.slot, nil, nil)
				return true -- issued one move; next step re-scans and continues
			end

			local itemInfo = ns.GetItemData(moveCandidate.itemID)
			ns.RestockerDebug("TRACE_SPLIT_FROM_BANK", moveCandidate.name, moveCandidate.bag, moveCandidate.slot)
			C_Container.SplitContainerItem(moveCandidate.bag, moveCandidate.slot, moveAmount)
			PutItemInPlayerBag(playerInventory, itemInfo, moveAmount)
			return true -- issued one move; next step re-scans and continues
		end
	end

	return false
end

function ns.MoveRestockItemFromBank(playerInventory, moveItemID, moveAmount, overshoot)
	--[[
	    Bank bags in reverse: the deepest bag is emptied first. On Era and TBC that
	    keeps the main bank container's free slots for a later stash-back; on
	    Forever it simply empties the last tab first.
	]]
	for _, bag in ipairs(bankBagsReversed) do
		-- Build list of move candidates (matched by itemID), smallest stacks first
		local moveCandidates = ScanBagsFor({ bag }, ContainerItemInfoMatchID(moveItemID))
		table.sort(moveCandidates, ns.CompareByStackSizeAscending)

		if MoveOneStackBankToPlayer(playerInventory, moveCandidates, moveAmount, overshoot) then
			return true
		end
	end

	return false -- did not move
end

--[[
    Issue at most one bag->bank move. As with ns.MoveRestockItemFromBank, nothing is deducted --
    the next step's re-scan reflects what actually moved.
]]
local function MoveOneStackPlayerToBank(bankInventory, candidates, moveAmount)
	for _, containerItemInfo in ipairs(candidates) do
		-- Found something to move and its smaller than what we need to move
		if containerItemInfo.count <= moveAmount then
			C_Container.UseContainerItem(containerItemInfo.bag, containerItemInfo.slot, nil, nil)
			return true -- issued one move; next step re-scans and continues
		end

		-- Found something to move, but its bigger than how many we need to move
		if containerItemInfo.count > moveAmount then
			-- May be nil if the item isn't cached; PutItemInBank then drops it in a free slot
			local itemInfo = ns.GetItemData(containerItemInfo.itemID)

			C_Container.SplitContainerItem(containerItemInfo.bag, containerItemInfo.slot, moveAmount)
			PutItemInBank(bankInventory, itemInfo, moveAmount)
			return true -- issued one move; next step re-scans and continues
		end
	end

	return false
end

function ns.MoveRestockItemToBank(bankInventory, moveItemID, moveAmount)
	--[[
	    Candidates come from ALL player bags at once, sorted smallest stack first GLOBALLY.
	    Scanning bag-by-bag made an early bag's big stack get SPLIT (the flaky cursor move)
	    even when a later bag held a loose stack of exactly the excess that a whole-stack
	    UseContainerItem -- the reliable, server-side deposit -- could have moved instead.
	]]
	local moveCandidates = ScanBagsFor(ns.restockPlayerBags, ContainerItemInfoMatchID(moveItemID))

	table.sort(moveCandidates, ns.CompareByStackSizeAscending)

	return MoveOneStackPlayerToBank(bankInventory, moveCandidates, moveAmount)
end

--[[
    Where a restock still has room, as (bags, bank). The caller decides what an
    answer means; this only reports it.
]]
function ns.GetRestockSpace()
	return ns.HasFreeBagSlot(ns.restockPlayerBags), ns.HasFreeBagSlot(bankBags)
end

function GetRestockContainerItemInfo(bagID, slot)
	local itemInfo = C_Container.GetContainerItemInfo(bagID, slot)
	--[[
	    hyperlink can be nil for a not-yet-cached item; skip the slot rather than erroring
	    on string.match(nil, ...). Matching is done by itemID, so a skipped slot is harmless.
	]]
	if not itemInfo or not itemInfo.hyperlink then
		return nil
	end
	local itemName = string.match(itemInfo.hyperlink, "%[(.*)%]")

	return {
		bag = bagID,
		slot = slot,
		icon = itemInfo.iconFileID,
		count = itemInfo.stackCount,
		locked = itemInfo.isLocked,
		link = itemInfo.hyperlink,
		itemID = itemInfo.itemID,
		name = itemName,
	}
end

function ns.CompareByStackSizeAscending(a, b)
	return a.count < b.count
end
