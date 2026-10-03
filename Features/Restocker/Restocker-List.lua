local _, ns = ...
local L = ns.L

--[[
    Items added during this viewing of the window, keyed by itemID.

    A long Restock List buries a just-added item in whatever type group it
    belongs to, so newly added items are pulled into a "New" group at the top
    where their Withdraw/Deposit/Buy/reputation controls can be set straight
    away.

    "New" is a note about THIS list, THIS sitting -- so it clears the moment
    either becomes untrue: when the Restocker window closes (Restocker-Window.lua's
    OnHide), when the Starter List popup closes (its host's OnHide in
    Options-Starter-List-Popup.lua), and on every list event -- create,
    switch, clone, copy, delete -- via ns.UseRestockList plus the two direct sites
    in ns.DeleteRestockList and ns.CopyIntoCurrentRestockList that never pass through it.

    Deliberately a plain field on ns rather than anything under settings: this is
    view state for one sitting and must never reach SavedVariables. A selected
    New category goes with the items, or the window would show an empty list.

    The offer to undo the last removal (ns.restockLastRemoved, in
    Restocker-Window-Rows.lua) is the same kind of note and ends at the same
    moments, so it is dropped here with the flags.
]]
ns.restockNewItems = {}

function ns.ClearRestockNewItems()
	wipe(ns.restockNewItems)
	ns.restockLastRemoved = nil
	if ns.restockSelectedGroup == L["RESTOCKER_GROUP_NEW"] then
		ns.ClearRestockGroupSelection()
	end
end

--------------------------------------------------------------------------------
-- Item Lookups
--------------------------------------------------------------------------------

--[[
    Adds parked on a cold item cache, keyed by itemID. Drained by
    ns.OnRestockerItemInfoReceived below when the client answers.
]]
ns.restockItemWait = {}

--[[
    Rows the open Restock List window drew before the client had their item,
    keyed by itemID. Filled by ns.UpdateRestockList, each repainted as its answer
    arrives, and emptied when the window hides.
]]
ns.restockColdRows = {}

--[[
    Five things here can be waiting on the client to resolve an item: a pending
    add, a crafting recipe, a deferred upgrade, a deferred Starter List tick and
    a row the open window drew without its item.
    The client answers GET_ITEM_INFO_RECEIVED once per item it resolves, which
    during a login is a flood, so Core is asked to listen only while at least one
    of the five is outstanding, and released the moment they all drain.

    Called after anything that adds to those queues, and at the end of the handler
    that drains them.
]]
function ns.SyncRestockItemInfoSubscription()
	local waiting = next(ns.restockItemWait) ~= nil
		or next(ns.pendingRecipes) ~= nil
		or ns.HasPendingUpgrade()
		or ns.HasPendingStarterAdds()
		or next(ns.restockColdRows) ~= nil

	-- MIGRATION (remove after 2026-10-18): a repaired Blinding Powder row waiting for its name (Restocker-Saved-Migration.lua)
	waiting = ns.NameBlindingPowderRows() or waiting

	if waiting then
		ns.RequestItemInfoEvents("restocker")
	else
		ns.ReleaseItemInfoEvents("restocker")
	end
end

function ns.OnRestockerItemInfoReceived(itemID, success)
	if success == nil then
		return
	end

	--[[
	    This event IS the answer, so the remembered miss has to go first: every
	    retry below asks ns.GetItemData again and would otherwise still be told
	    the item is missing.
	]]
	ns.ForgetItemDataMiss(itemID)

	if ns.restockColdRows[itemID] then
		ns.restockColdRows[itemID] = nil
		ns.RepaintRestockRows(itemID)
	end

	--[[
	    If this was an autobuy item setup item request. Tested with next(), not #:
	    ns.pendingRecipes is keyed by itemID (Restocker-Crafting-Reagents.lua), so it is a sparse
	    table and the length operator reads 0 no matter how many recipes are waiting.
	]]
	if next(ns.pendingRecipes) ~= nil then
		ns.RetryWaitingRecipes()
	end

	-- If this was an item add request for an unknown item
	if ns.restockItemWait[itemID] then
		ns.restockItemWait[itemID] = nil
		ns.AddRestockItem(itemID)
	end

	--[[
	    An upgrade deferred because its target had not resolved yet. C_Item.GetItemInfo
	    asked the server on that miss, so this event is the answer arriving; the
	    retry is free once nothing is pending.
	]]
	if ns.HasPendingUpgrade() then
		ns.UpgradeRestockList()
	end

	--[[
	    A Starter List tick deferred the same way (Restocker-Starter-List.lua): its item had
	    not resolved when the box was ticked, and this event is the answer arriving.
	]]
	if ns.HasPendingStarterAdds() then
		ns.RetryPendingStarterAdds()
	end

	ns.SyncRestockItemInfoSubscription()
end

--------------------------------------------------------------------------------
-- Adding An Item
--------------------------------------------------------------------------------

function ns.AddRestockItem(text)
	local settings = ns.restockSettings
	local currentList = settings.lists[settings.currentList]

	if type(text) == "string" and text:match("^%s*$") then
		return
	end

	if tonumber(text) then
		text = tonumber(text)
	end

	--[[
	    A typed ID with no item behind it is never answered, so parking it below
	    would hold the event all session. Said in the add box while the window is
	    open, and in chat otherwise (ns.ShowRestockAddNotice).
	]]
	if type(text) == "number" and not C_Item.DoesItemExistByID(text) then
		ns.ShowRestockAddNotice(string.format(L["RESTOCKER_UNKNOWN_ITEM"], text))
		return
	end

	local itemInfo = ns.GetItemData(text)
	if itemInfo == nil then
		--[[
		    Park the pending add under its itemID: the retry in
		    ns.OnRestockerItemInfoReceived looks up by the numeric itemID the event
		    hands it, so an add keyed by a raw item link (what a drag from the bags
		    hands in) would never be found again and the item would silently never
		    arrive. Input carrying no itemID is dropped rather than parked: no answer
		    can ever clear its key, and a parked key would hold GET_ITEM_INFO_RECEIVED
		    registered for the rest of the session. It is answered, though: a typed
		    name the client cannot place used to do nothing at all, which read as
		    the box being broken.
		]]
		local waitKey = text
		if type(text) == "string" then
			waitKey = tonumber(text:match("item:(%d+)"))
		end
		if waitKey == nil then
			ns.ShowRestockAddNotice(L["RESTOCKER_ADD_NOT_FOUND"])
			return
		end
		ns.restockItemWait[waitKey] = true
		ns.SyncRestockItemInfoSubscription()
		return
	end

	local itemID = (itemInfo).itemID

	-- Lists are keyed by itemID, so a duplicate is a simple lookup
	if currentList[itemID] ~= nil then
		return
	end

	local buyItem = {}

	buyItem.itemName = (itemInfo).itemName
	buyItem.itemType = (itemInfo).itemType
	buyItem.itemID = itemID
	--[[
	    One stack of the item, not one unit: a fresh row asking for a single
	    juice reads as a typo, and a stack is the amount everything actually
	    trades in. Items that do not stack report a max of 1, so gear and tools
	    land at exactly one with no special case.
	]]
	buyItem.amount = math.max(1, (itemInfo).itemStackCount or 1)
	-- New items default to everything ON: buy from merchant, stash to bank, restock from bank
	buyItem.buyFromMerchant = true
	buyItem.stashToBank = true
	buyItem.restockFromBank = true

	currentList[itemID] = buyItem

	--[[
	    Flag it for the "New" group and jump the list back to the top, so the row
	    you just created is on screen rather than filed away in its type group
	    somewhere down a long list. Its toggles are already visible on the row, so
	    there is nothing left to open.
	]]
	ns.restockNewItems[itemID] = true
	--[[
	    Select New, which the row above just joined. Whatever category the pane
	    was showing, the item is not in it -- and a row that vanishes the moment
	    it is added is the one way this pane can lie about what is on the list.
	    Selecting the group the item IS in beats falling back to All: it puts the
	    new row on screen alone rather than somewhere in a list of thirty-seven.
	]]
	ns.restockSelectedGroup = L["RESTOCKER_GROUP_NEW"]

	ns.UpdateRestockList()

	local scrollFrame = ns.restockWindow and ns.restockWindow.scrollFrame
	if scrollFrame then
		scrollFrame:SetVerticalScroll(0)
	end
end
