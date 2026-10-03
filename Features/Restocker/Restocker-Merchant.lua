local _, ns = ...
local L = ns.L

--[[
    Read by the bank restock as a hard gate: C_Container.UseContainerItem SELLS
    while a merchant window is open, so anything that moves an item has to know.
]]
ns.merchantIsOpen = false
ns.merchantBuyingSkipped = false

-- Restock throttle: the client can fire MERCHANT_SHOW more than once per visit.
local lastTimeRestocked = GetTime()

local COPPER_PER_GOLD = 10000

-- Defined just above ns.RestockFromMerchant; forward-declared for the order builders that call it first.
local NewPurchaseOrder

local function CountTableItems(theTable)
	if not theTable then
		return 0
	end

	local count = 0
	for _, _ in pairs(theTable) do
		count = count + 1
	end
	return count
end

--[[
    NOTE: this add-on must NEVER sell at a merchant. Having too many of an item is fine and is
    left untouched. There is no sell path at all: only BuildPurchaseOrder (buy when too few).
]]

--------------------------------------------------------------------------------
-- Buy Extra
--------------------------------------------------------------------------------

--[[
    A normal order asks for the shortfall and stops there. An Extra row asks for
    whatever a LIMITED vendor slot is holding, however much of it the player
    already has: the scarce Classic consumables (Major Mana Potions and the like)
    sit behind a few-at-a-time slot that trickles back, so the useful behaviour is
    to clear the slot every time you walk past rather than to top up to a number.

    That means an Extra row needs an order even when the shortfall is zero, which
    is why the amount gate below is skipped for it. The order still carries the
    ordinary shortfall as its amount -- never a guess at what the vendor holds,
    which is unknown until PurchaseMerchantItem reads the slot -- so partial-fill
    reporting keeps working off the real target. An amount of 0 is a legitimate
    Extra order: nothing is owed, so anything bought fills it.

    Extra rides on top of Buy rather than beside it. ns.RestockFromMerchant already skips
    records with buyFromMerchant off before calling this, so an Extra row with Buy
    switched off never reaches here.
]]
local function BuildPurchaseOrder(purchaseOrders, eachRestockRecord, vendorReaction)
	--[[
	    Counted by itemID, the same key BuildGroceryList and the crafting order use,
	    so all three agree on what the bags hold. A name-keyed count reads 0 for a
	    saved line whose name never resolved, and the order then buys a full stack
	    of something the bags are already carrying.
	]]
	local haveInBag = C_Item.GetItemCount(eachRestockRecord.itemID or eachRestockRecord.itemName, false, false) or 0
	local amount = eachRestockRecord.amount or 0
	local requiredReaction = eachRestockRecord.reaction or 0
	local buyExtra = eachRestockRecord.buyExtra == true

	--[[
	    A vendor below the item's required standing is skipped in silence:
	    announcing every gated item at every vendor would flood chat.
	]]
	if requiredReaction <= vendorReaction and (amount > 0 or buyExtra) then
		--[[
		    Clamped at zero: an already over-stocked Extra row owes nothing, and a
		    negative amount would shrink the order it merges into below.
		]]
		local toBuy = math.max(0, amount - haveInBag)

		if toBuy > 0 or buyExtra then
			-- Keyed by the client's current name, which is what the merchant lists; a saved name can be stale.
			local info = eachRestockRecord.itemID and ns.GetItemData(eachRestockRecord.itemID)
			local itemName = (info and info.itemName and info.itemName ~= "" and info.itemName)
				or eachRestockRecord.itemName
			local purchaseOrder = purchaseOrders[itemName]
			if not purchaseOrder then
				-- add new
				purchaseOrders[itemName] =
					NewPurchaseOrder(toBuy, itemName, eachRestockRecord.itemID, eachRestockRecord.itemLink)
			else
				-- update amount, add more
				purchaseOrder.amount = purchaseOrder.amount + toBuy
				purchaseOrder.remaining = purchaseOrder.remaining + toBuy
			end

			--[[
			    Flagged on the ORDER, not re-read from the record later: orders are keyed
			    by item name and a crafting reagent can merge into this same entry, so
			    the buy loop needs the flag on the thing it actually holds.
			]]
			if buyExtra then
				purchaseOrders[itemName].buyExtra = true
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Grocery List
--------------------------------------------------------------------------------

--[[
    What the current list is short of right now: the same shortfall
    BuildPurchaseOrder computes, minus the vendor. Used by the mini-map tooltip,
    the entering-town reminder and the reminders after a merchant or bank window
    closes, none of which reads a vendor's stock.

    Two differences from a real purchase order, both because there is no vendor:
    the required-reputation gate is skipped (it depends on which vendor you walk
    up to), and crafting reagents are left out (ns.BuildCraftingPurchaseOrder
    resolves those against the merchant's stock). So this answers "what am I low on", which is
    what a shopping list is, rather than "what will this vendor sell me".

    Counts are bags only -- C_Item.GetItemCount(id, false, false) -- matching what the
    merchant restock compares against, so the list agrees with what would
    actually be bought.
]]
function ns.BuildGroceryList()
	local settings = ns.restockSettings
	local restockList = settings and settings.lists and settings.lists[settings.currentList]
	local list = {}
	if not restockList then
		return list
	end

	for _, record in pairs(restockList) do
		local wanted = record.amount or 0
		local key = record.itemID or record.itemName
		-- nil buyFromMerchant defaults to true, the same rule ns.RestockFromMerchant uses
		if key and wanted > 0 and (record.buyFromMerchant == nil or record.buyFromMerchant) then
			local have = C_Item.GetItemCount(key, false, false) or 0
			local short = wanted - have
			if short > 0 then
				--[[
				    have/wanted ride along for the verbose town reminder, which reports
				    the ratio rather than the shortfall.
				]]
				list[#list + 1] = {
					itemID = record.itemID,
					itemName = record.itemName,
					have = have,
					wanted = wanted,
					needed = short,
				}
			end
		end
	end

	table.sort(list, function(a, b)
		return (a.itemName or "") < (b.itemName or "")
	end)
	return list
end

--[[
    Do the bags hold fewer of this row's item than its Keep amount? The grocery
    list's own shortfall, asked of one row and without its Buy gate: the Restock
    window marks every short row, not only the ones a merchant would be asked
    for, so a row the bank is meant to fill is marked too.

    Bags only and counted by the same key, so a row this calls short with Buy on
    is always an order on the list above. A Keep of 0 asks for nothing and is
    never short; with Store on it sends the whole stock to the bank.
]]
function ns.IsRestockItemShort(record)
	local wanted = record.amount or 0
	local key = record.itemID or record.itemName
	return key ~= nil and wanted > 0 and (C_Item.GetItemCount(key, false, false) or 0) < wanted
end

local function UpdatePurchaseOrdersWithCraftingReagents(purchaseOrders, ingredientName, toBuy)
	if not purchaseOrders[ingredientName] then
		purchaseOrders[ingredientName] = NewPurchaseOrder(toBuy, ingredientName, nil, nil)
	else
		local purchase = purchaseOrders[ingredientName]
		purchase.amount = purchase.amount + toBuy
		purchase.remaining = purchase.remaining + toBuy
	end
end

--------------------------------------------------------------------------------
-- All or Nothing Reagents
--------------------------------------------------------------------------------

--[[
    Crafting reagents (rogue poison ingredients) are bought only at a vendor
    that stocks EVERY reagent the crafting order still needs. Half a recipe is
    worse than none: a trade-goods vendor carrying Crystal Vials but no Dust of
    Deterioration would fill the bags with vials that cannot become poisons until
    some other vendor supplies the rest. A poison supplier carries the full set,
    so this gate simply keeps the reagent buying at poison suppliers.

    "Needs" means an amount still to buy after bags were counted -- a reagent
    the bags already cover is not required of the vendor, so dust-only is fine
    when the vials are in the bags. "Stocks" means the slot can be bought from
    right now, for gold alone: unlimited (-1) or a limited count above zero,
    and a slot PurchaseMerchantItem would not pass over. A sold-out limited
    slot counts as NOT stocked -- buying the others would strand the player
    exactly the way this rule forbids.

    Quantity coverage is deliberately not required: a limited slot holding 4
    of the 6 dust wanted still crafts 4 poisons, and the chunked buy loop
    already caps to vendor stock. The rule is about missing reagent TYPES.

    This gate covers the crafting order only. An item the player put on the
    Restock List directly (vials included) is their explicit ask and buys
    exactly as before.
]]
local function VendorStocksAllReagents(craftingPurchaseOrder)
	local needed = {}
	local neededCount = 0
	for reagentName, amount in pairs(craftingPurchaseOrder) do
		if amount > 0 then
			needed[reagentName] = true
			neededCount = neededCount + 1
		end
	end

	-- Nothing left to buy: the gate passes and no reagent line is at stake.
	if neededCount == 0 then
		return true, false
	end

	local stockedCount = 0
	for i = 1, GetMerchantNumItems() do
		local itemName, _, _, _, numAvailable, isPurchasable, _, hasExtendedCost = ns.GetMerchantItemInfo(i)
		if
			itemName
			and needed[itemName]
			and isPurchasable
			and not hasExtendedCost
			and (numAvailable == -1 or numAvailable > 0)
		then
			needed[itemName] = nil -- count each reagent once, however many slots carry it
			stockedCount = stockedCount + 1
			if stockedCount == neededCount then
				return true, true
			end
		end
	end

	return false, stockedCount > 0
end

--[[
    Buys one merchant slot if it is on the purchase order, against what the
    order still owes, and adds the UNITS it bought to the order. Count UNITS,
    never BuyMerchantItem calls: forty juice bought in stacks of twenty is two
    calls, and "2" is not a number any player can interpret.

    A merchant can list one item in more than one slot, and orders are keyed by
    name, so two items sharing a name share an order too. Each slot therefore
    buys from remaining, not from the order's whole amount, or a second slot
    would buy the order again. Whether an order was filled is decided once,
    after the last slot (ns.RestockFromMerchant): the order is the only place
    that knows what was asked for and what arrived, and bag counts cannot
    settle it, since they do not update until BAG_UPDATE.

    budget is the run's money and bag space (ns.RestockFromMerchant), spent down
    chunk by chunk: a chunk the player cannot pay for or carry is never sent, so
    the order stops there and counts only what was. A chunk refused for money
    sets budget.outOfGold and one refused for room budget.outOfSpace, so the run
    can say why it fell short.

    A slot this character cannot buy from (a reputation item without the
    standing) is passed over, since the server refuses every call, and so is
    one that costs honor, tokens or items besides gold, which the run has no
    business spending.
]]
local function PurchaseMerchantItem(i, purchaseOrders, budget)
	local itemName, _, price, batchQuantity, merchantAvailable, isPurchasable, _, hasExtendedCost =
		ns.GetMerchantItemInfo(i)
	if not isPurchasable or hasExtendedCost then
		return
	end
	local itemLink = GetMerchantItemLink(i)

	local buyItem = purchaseOrders[itemName]
	local unitsOrdered = 0

	if buyItem then
		--[[
		    Link and cached record are both missing until the client resolves the item, so fall
		    back to single-unit buys, which BuyMerchantItem accepts for anything.
		]]
		local itemInfo = itemLink and ns.GetItemData(itemLink)
		local stackCount = itemInfo and itemInfo.itemStackCount or 1
		if stackCount < 1 then
			stackCount = 1
		end

		--[[
		    HOW MUCH TO ASK FOR

		    BuyMerchantItem will not sell more than one stack per call, which is what
		    the stackCount loop below is for. Every purchase must go through that
		    loop, capped ones included: a single call for a limited slot holding more
		    than one stack -- a poison supplier's reagents, exactly the case this path
		    exists for -- is rejected, yet would still credit the full amount and
		    report an order filled that never arrived. Settling the target first lets
		    one chunked loop serve every case.

		    A positive numAvailable is a LIMITED slot: a fixed few units that trickle
		    back over time. Unlimited stock reports -1 and sold out reports 0, so that
		    is the only reading either rule below can act on.

		    Ordinary orders ask for what they still owe, capped DOWN to what the slot
		    holds. An Extra order takes the slot's whole count instead, up or down: that is the feature, buying past
		    the target amount when the vendor holds more than is owed, and buying at
		    all when nothing is owed. Unlimited slots fall through untouched by
		    design -- "buy every one they have" has no end on a slot that never runs
		    out, so Extra deliberately does nothing there.
		]]
		local wanted = buyItem.remaining
		if merchantAvailable > 0 then
			if buyItem.buyExtra then
				wanted = merchantAvailable
			elseif wanted > merchantAvailable then
				wanted = merchantAvailable
			end
		end

		--[[
		    A sold-out slot reports numAvailable 0; unlimited stock reports -1, which
		    is why the cap above tests for a POSITIVE count. Nothing can be bought
		    from an empty slot, so the loop is skipped rather than run into a server
		    that rejects every call -- and skipping it adds nothing to the order, which
		    is what stops a slot that gave us nothing from announcing a partial fill.
		]]
		if merchantAvailable ~= 0 then
			-- The slot's price buys its batch quantity (arrows come by the 200).
			local unitPrice = (price or 0) / math.max(batchQuantity or 1, 1)
			for n = wanted, 1, -stackCount do
				local chunk = (n > stackCount) and stackCount or n
				local cost = math.ceil(unitPrice * chunk)
				if cost > budget.money then
					budget.outOfGold = true
					break
				end
				if not ns.ClaimBagSpace(budget.space, itemInfo, chunk) then
					budget.outOfSpace = true
					break
				end
				BuyMerchantItem(i, chunk)
				budget.money = budget.money - cost
				unitsOrdered = unitsOrdered + chunk
			end
		end

		buyItem.remaining = math.max(0, buyItem.remaining - unitsOrdered)
		buyItem.bought = buyItem.bought + unitsOrdered
	end
end

--[[
    One vendor's worth of an item to buy. Transient: a purchase order lives for
    the length of one merchant visit and is never saved, which is why itemLink can
    be carried here when the list row that produced it does not store one.
    remaining is what it still owes as its slots are bought, and bought is what
    they delivered.
]]
function NewPurchaseOrder(amount, itemName, itemID, itemLink)
	return {
		amount = amount,
		remaining = amount,
		bought = 0,
		itemName = itemName,
		itemID = itemID or 0,
		itemLink = itemLink or "",
	}
end

function ns.RestockFromMerchant()
	local settings = ns.restockSettings
	if CountTableItems(settings.lists[settings.currentList]) == 0 then
		return
	end

	if GetTime() - lastTimeRestocked < 1 then
		return
	end

	lastTimeRestocked = GetTime()

	if settings.autoOpenAtMerchant then
		ns.ShowRestockWindowForVisit()
	end

	local craftingPurchaseOrder = ns.BuildCraftingPurchaseOrder() or {}

	--[[
	    All-or-nothing (see VendorStocksAllReagents above): a vendor missing any
	    needed reagent buys NO reagents. The print fires only when this vendor
	    stocked some of them, which is the case worth reporting, and stays silent
	    at vendors that stock none, where a skipped reagent order is not news.
	]]
	local allReagentsStocked, anyReagentStocked = VendorStocksAllReagents(craftingPurchaseOrder)
	if not allReagentsStocked then
		if anyReagentStocked then
			ns.PrintMessage(L["RESTOCKER_REAGENTS_SKIPPED"])
		end
		craftingPurchaseOrder = {}
	end

	local purchaseOrders = {}
	local restockList = settings.lists[settings.currentList]
	-- "npc" is the unit we are actually interacting with; the vendor is usually not targeted.
	local vendorReaction = UnitReaction("npc", "player") or UnitReaction("target", "player") or 0

	-- Build the Purchase Orders table used for buying items
	for _, eachRestockRecord in pairs(restockList) do
		if eachRestockRecord.buyFromMerchant or eachRestockRecord.buyFromMerchant == nil then -- nil defaults to true
			BuildPurchaseOrder(purchaseOrders, eachRestockRecord, vendorReaction)
		end
	end

	-- Insert craft reagents for missing items into purchase orders, or add
	for ingredientName, toBuy in pairs(craftingPurchaseOrder) do
		UpdatePurchaseOrdersWithCraftingReagents(purchaseOrders, ingredientName, toBuy)
	end

	--[[
	    Neither the purse nor the bags change until the server answers, which is after this
	    whole run has been sent, so both are read once here and spent down as purchases go
	    out. That is what keeps the run from ordering what the player cannot pay for or
	    carry, and then counting it as bought.
	]]
	local budget = { money = GetMoney(), space = ns.NewBagSpace(ns.restockPlayerBags) }

	--[[
	    The Gold Reserve comes off the top, so the run can spend only what sits
	    above it. A purse already at or below the reserve leaves nothing, which
	    pauses buying at every vendor until the player is richer, while the bank
	    restock, which costs nothing, carries on. Either way the shortfall reads
	    as running out of gold, so one chat line covers the reserve and the
	    empty purse alike.
	]]
	if settings.goldReserve then
		local reserve = (settings.goldReserveAmount or 0) * COPPER_PER_GOLD
		budget.money = math.max(0, budget.money - reserve)
	end

	-- Loop through vendor items
	for i = 1, GetMerchantNumItems() do
		if not ns.restockBuying then
			return
		end

		PurchaseMerchantItem(i, purchaseOrders, budget)
	end

	--[[
	    Each order counts once, however many slots it bought from. The > 0 half
	    matters for a zero-amount order, which both the crafting-reagent path and a
	    fully stocked Extra row can create: nothing bought must never read as an
	    order filled. An Extra row that did clear a slot passes on the same test,
	    since anything at all covers a zero target.
	]]
	local ordersFilled = 0
	local ordersPartlyFilled = 0
	for _, order in pairs(purchaseOrders) do
		if order.bought > 0 then
			if order.bought >= order.amount then
				ordersFilled = ordersFilled + 1
			else
				ordersPartlyFilled = ordersPartlyFilled + 1
			end
		end
	end

	--[[
	    Report what happened, and nothing more. Anything this vendor did not stock
	    is still outstanding, but the mini-map's Restocker Report already says so --
	    the chat line covers the event, the tooltip covers the outstanding state,
	    and neither repeats the other.

	    Filled and partly filled are counted apart and printed apart, so a mixed run
	    needs no combined string and a clean one never mentions partials. Both are
	    silent at zero, which keeps a vendor that stocked nothing on our list quiet.
	]]
	if ordersFilled == 1 then
		ns.PrintMessage(L["RESTOCKER_RESTOCKED_ONE"])
	elseif ordersFilled > 1 then
		ns.PrintMessage(string.format(L["RESTOCKER_RESTOCKED_MANY"], ordersFilled))
	end

	if ordersPartlyFilled == 1 then
		ns.PrintMessage(L["RESTOCKER_RESTOCKED_PARTIAL_ONE"])
	elseif ordersPartlyFilled > 1 then
		ns.PrintMessage(string.format(L["RESTOCKER_RESTOCKED_PARTIAL_MANY"], ordersPartlyFilled))
	end

	--[[
	    Silent unless gold actually turned a chunk away, so a vendor that stocks
	    nothing on the list says nothing however poor the player is. With the
	    Gold Reserve on, the line goes on to say buying waits on the reserve,
	    naming it, so a player who forgot setting it knows why the vendor was
	    skipped.
	]]
	if budget.outOfGold then
		if settings.goldReserve then
			local reserve = (settings.goldReserveAmount or 0) .. ns.GOLD_ICON
			ns.PrintMessage(string.format(L["RESTOCKER_OUT_OF_GOLD_RESERVE"], reserve))
		else
			ns.PrintMessage(L["RESTOCKER_OUT_OF_GOLD"])
		end
	end

	if budget.outOfSpace then
		ns.PrintMessage(L["RESTOCKER_BAGS_FULL_PARTIAL"])
	end
end
