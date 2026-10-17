local _, ns = ...

--------------------------------------------------------------------------------
-- Recipe Resolution
--------------------------------------------------------------------------------

--[[
    The craftable items the Restock List buys reagents for, keyed by the crafted
    item's itemID, which is how BuildCraftingPurchaseOrder finds a list row's
    recipe. Merchants never list the crafted item; the orders it produces are
    for its reagents, by their own item IDs, so a recipe needs no item data.

    Recipe rows live in Data/{Game}/Poison-Recipes-{Game}.lua.
]]
local buyIngredients = {}

-- Turns the data rows into the runtime shape, once, at login.
function ns.SetupCraftingRecipes()
	if next(buyIngredients) then
		return
	end

	for _, row in ipairs(ns.POISON_RECIPES) do
		local reagents = {}
		for _, reagent in ipairs(row[2]) do
			reagents[#reagents + 1] = { itemID = reagent[1], count = reagent[2] }
		end
		buyIngredients[row[1]] = { itemID = row[1], reagents = reagents }
	end
end

--------------------------------------------------------------------------------
-- Reagent Purchases
--------------------------------------------------------------------------------

function ns.BuildCraftingPurchaseOrder()
	local purchaseOrder = {}
	local settings = ns.restockSettings

	local list = settings.lists[settings.currentList]

	for _, item in pairs(list) do
		-- A row's Buy toggle governs every purchase it makes, its ingredients included (nil means on).
		local recipe = item.buyFromMerchant ~= false and buyIngredients[item.itemID]
		if recipe then
			--[[
			    Bags only, matching BuildPurchaseOrder and BuildGroceryList. Bank stock
			    deliberately does not count: you are standing at a vendor, and the
			    tradeskill can only consume what is in your bags, so poisons sitting in
			    the bank must not cancel reagents for crafts you still have to make.

			    Counting it was self-defeating as well. That bank pile is one this add-on
			    creates -- Restocker-Bank.lua stashes everything above `amount` -- so a full run
			    would bank the excess and then refuse to buy reagents for it. It also
			    made the same vendor visit buy different amounts depending on whether
			    the bank had been opened that session, which is when the client learns
			    bank contents.

			    Any shortfall is worth buying for, with no minimum threshold: a floor
			    such as half the target silently buys nothing for a list 19 short of
			    40.
			]]
			local haveCrafted = C_Item.GetItemCount(item.itemID, false, false) or 0
			local craftedMissing = (item.amount or 0) - haveCrafted

			if craftedMissing > 0 then
				for _, reagent in ipairs(recipe.reagents) do
					local amountToGet = reagent.count * craftedMissing
					purchaseOrder[reagent.itemID] = (purchaseOrder[reagent.itemID] or 0) + amountToGet
				end
			end
		end
	end

	--[[
	    Reagents already in the bags come off the order. The floor matters because
	    these numbers do not stay in this table: ns.RestockFromMerchant folds them into
	    purchaseOrders alongside the merchant restock amounts, keyed by the same
	    itemID. A surplus of vials left a negative here, and a negative added to a
	    vial line the player actually asked for would quietly shrink it.

	    A reagent the list also keeps, with Buy on, has an order of its own for
	    its Keep amount less the same bags (BuildPurchaseOrder), and the two are
	    added together. The bags up to that Keep are the row's, so only the rest
	    comes off here, and the merged order is Keep plus what the crafts need,
	    less the bags once.
	]]
	for reagentID, _ in pairs(purchaseOrder) do
		local inBags = C_Item.GetItemCount(reagentID, false) or 0
		local row = list[reagentID]
		if row and row.buyFromMerchant ~= false then
			inBags = math.max(0, inBags - (row.amount or 0))
		end
		if inBags > 0 then
			local remaining = purchaseOrder[reagentID] - inBags
			purchaseOrder[reagentID] = remaining > 0 and remaining or 0
		end
	end

	return purchaseOrder
end
