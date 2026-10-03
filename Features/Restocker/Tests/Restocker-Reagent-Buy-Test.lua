-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the crafting-reagent purchase order (no WoW API needed).

    Run it with:   lua Tests/Restocker-Reagent-Buy-Test.lua

    It models the SAME two steps the live add-on uses:
      * Restocker-Crafting-Reagents.lua BuildCraftingPurchaseOrder -- how many reagents the shortfall needs
      * Restocker-Merchant.lua PurchaseMerchantItem       -- how many of those a vendor slot delivers

    The reported bug lives in the first: 40 Instant Poison VI wanted, 18 sitting in the
    BANK, and the order came out at 22 crafts (22 Crystal Vial, 88 Dust of Deterioration)
    because the shortfall counted bank stock -- which a tradeskill at a vendor cannot reach.
    The half-target gate in the same block was worse: it bought NOTHING, silently, whenever
    anything was banked and the shortfall was under half the target.

    The second is independent and hits the same reagents: BuyMerchantItem will not sell more
    than one stack per call, and the limited-stock branch passed the vendor's whole count in
    a single call, so a poison supplier holding several stacks sold nothing while the add-on
    reported the order filled.
]]

-- Classic Instant Poison VI: 4x Dust of Deterioration + 1x Crystal Vial (Data/Vanilla/Poison-Recipes-Vanilla.lua).
local RECIPE = { { name = "Dust of Deterioration", count = 4 }, { name = "Crystal Vial", count = 1 } }

local pass = 0

--[[
  CraftingPurchaseOrder, as shipped after the fix: bags only, no threshold, reagents
  already held come off the order and never go negative, and a row with Buy off
  orders nothing. A reagent the list also keeps with Buy on counts only the bags past
  that row's Keep, since the row orders its Keep against the same bags.
]]
---@param wanted number List amount for the crafted item
---@param inBags number Crafted items in BAGS
---@param _inBank number Crafted items in the BANK (must not affect the result)
---@param reagentsInBags table<string, number>
---@param buyFromMerchant boolean|nil The row's Buy toggle (nil means on)
---@param listKeeps table<string, number>|nil Keep amounts of the list's own Buy-on rows for the reagents
local function craftingPurchaseOrder(wanted, inBags, _inBank, reagentsInBags, buyFromMerchant, listKeeps)
	local order = {}
	if buyFromMerchant == false then
		return order
	end
	local missing = wanted - inBags -- _inBank is deliberately unused
	if missing > 0 then
		for _, ing in ipairs(RECIPE) do
			order[ing.name] = (order[ing.name] or 0) + ing.count * missing
		end
	end
	for reagent in pairs(order) do
		local have = math.max(0, ((reagentsInBags or {})[reagent] or 0) - ((listKeeps or {})[reagent] or 0))
		if have > 0 then
			local remaining = order[reagent] - have
			order[reagent] = remaining > 0 and remaining or 0
		end
	end
	return order
end

---@param label string
local function orderScenario(label, wanted, inBags, inBank, reagentsInBags, wantDust, wantVial)
	local order = craftingPurchaseOrder(wanted, inBags, inBank, reagentsInBags)
	local dust = order["Dust of Deterioration"] or 0
	local vial = order["Crystal Vial"] or 0
	assert(dust == wantDust, ("%s: dust want %d got %d"):format(label, wantDust, dust))
	assert(vial == wantVial, ("%s: vial want %d got %d"):format(label, wantVial, vial))
	print(("  ok  %-46s -> %3d dust, %3d vial"):format(label, dust, vial))
	pass = pass + 1
end

print("CRAFTING PURCHASE ORDER")
--[[
    THE REPORTED BUG. 40 wanted, none in bags, 18 banked. The old code counted the bank,
    got a shortfall of 22, and bought 88 dust / 22 vial -- enough to craft 22, not 40.
]]
orderScenario("40 wanted, 0 bags, 18 bank (the report)", 40, 0, 18, nil, 160, 40)
-- Same shortfall, same answer, wherever the bank sits. Bank stock is simply not an input.
orderScenario("40 wanted, 0 bags, 0 bank", 40, 0, 0, nil, 160, 40)
orderScenario("40 wanted, 0 bags, 500 bank", 40, 0, 500, nil, 160, 40)
--[[
    THE SILENT-ZERO CLIFF. Old rule: anything banked raised the floor to half the target,
    so 19 short of 40 bought nothing at all. Any shortfall is worth buying for now.
]]
orderScenario("40 wanted, 21 bags, 21 bank (under old floor)", 40, 21, 21, nil, 76, 19)
-- Bags DO count -- this is the case that always worked, and must keep working.
orderScenario("40 wanted, 18 bags, 0 bank", 40, 18, 0, nil, 88, 22)
-- Fully stocked in bags: buy nothing.
orderScenario("40 wanted, 40 bags", 40, 40, 0, nil, 0, 0)
orderScenario("40 wanted, 55 bags (over target)", 40, 55, 0, nil, 0, 0)
-- Reagents already held come off the order.
orderScenario("40 wanted, 0 bags, 60 dust held", 40, 0, 0, { ["Dust of Deterioration"] = 60 }, 100, 40)
--[[
    A reagent SURPLUS floors at zero. It must never go negative: Restock() folds these
    numbers into purchaseOrders under the same localized name as a merchant restock line,
    where a negative would quietly shrink an order the player actually asked for.
]]
orderScenario("40 wanted, 400 dust held (surplus)", 40, 0, 0, { ["Dust of Deterioration"] = 400 }, 0, 40)
-- A row with Buy off orders no reagents: its Buy toggle governs every purchase it makes.
do
	local order = craftingPurchaseOrder(40, 0, 0, nil, false)
	assert(next(order) == nil, "40 wanted, Buy off: want no reagent order")
	print(("  ok  %-46s -> %3d dust, %3d vial"):format("40 wanted, Buy off", 0, 0))
	pass = pass + 1
end
--[[
    A reagent that is also a list row with Buy on. The row orders its Keep less the bags,
    the merchant restock adds the reagent line to that same order, and the bags count once
    across the two: Keep plus what the crafts need, less the bags. Subtracting the bags from
    both used to buy 10 vials here, and the Rogue came up short at the next craft.
]]
local function mergedVialScenario(label, vialsInBags, keep, wantBought)
	local order = craftingPurchaseOrder(20, 0, 0, { ["Crystal Vial"] = vialsInBags }, nil, { ["Crystal Vial"] = keep })
	local rowOrder = math.max(0, keep - vialsInBags)
	local bought = rowOrder + order["Crystal Vial"]
	assert(bought == wantBought, ("%s: want %d vials bought, got %d"):format(label, wantBought, bought))
	print(("  ok  %-46s -> %3d vial"):format(label, bought))
	pass = pass + 1
end
mergedVialScenario("20 crafts, 15 vials held, Keep 20", 15, 20, 25)
mergedVialScenario("20 crafts, 30 vials held, Keep 20", 30, 20, 10)
mergedVialScenario("20 crafts, 45 vials held, Keep 20", 45, 20, 0)

--[[
  PurchaseMerchantItem, as shipped after the fix: cap what the order still owes to the
  vendor's stock, then walk it in stackCount chunks, sending a chunk only while the run's
  budget covers it and adding what was sent to the order. Returns the units and the calls;
  the fill test runs once per order, after every slot. budget models the run's own: money,
  unitPrice, and claim(chunk) standing in for ns.ClaimBagSpace. Left out, it is unlimited.
  A chunk refused for money sets budget.outOfGold and one refused for room
  budget.outOfSpace, which is what the run's chat lines read.
]]
---@param order table { amount, remaining, bought }
---@param merchantAvailable number Vendor stock; -1 is unlimited, 0 is sold out
---@param stackCount number Item stack size
---@param budget table|nil { money, unitPrice, claim }
local function purchaseMerchantItem(order, merchantAvailable, stackCount, budget)
	budget = budget or { money = math.huge, unitPrice = 0 }
	local calls = {}
	local unitsOrdered = 0
	if stackCount < 1 then
		stackCount = 1
	end

	local wanted = order.remaining
	if merchantAvailable > 0 and wanted > merchantAvailable then
		wanted = merchantAvailable
	end

	if merchantAvailable ~= 0 then
		for n = wanted, 1, -stackCount do
			local chunk = (n > stackCount) and stackCount or n
			local cost = math.ceil(budget.unitPrice * chunk)
			if cost > budget.money then
				budget.outOfGold = true
				break
			end
			if budget.claim and not budget.claim(chunk) then
				budget.outOfSpace = true
				break
			end
			budget.money = budget.money - cost
			calls[#calls + 1] = chunk
			unitsOrdered = unitsOrdered + chunk
		end
	end

	order.remaining = math.max(0, order.remaining - unitsOrdered)
	order.bought = order.bought + unitsOrdered
	return unitsOrdered, calls
end

local function newOrder(amount)
	return { amount = amount, remaining = amount, bought = 0 }
end

local function orderFilled(order)
	return order.bought > 0 and order.bought >= order.amount
end

local function buyScenario(label, amount, avail, stack, wantUnits, wantFilled)
	local order = newOrder(amount)
	local units, calls = purchaseMerchantItem(order, avail, stack)
	local filled = orderFilled(order)
	assert(units == wantUnits, ("%s: units want %d got %d"):format(label, wantUnits, units))
	assert(filled == wantFilled, ("%s: filled want %s got %s"):format(label, tostring(wantFilled), tostring(filled)))
	-- The invariant the old limited-stock branch broke: no single call may exceed a stack.
	for _, chunk in ipairs(calls) do
		assert(chunk <= stack, ("%s: call of %d exceeds stack %d"):format(label, chunk, stack))
		assert(chunk > 0, label .. ": non-positive call")
	end
	print(("  ok  %-46s -> %3d units in %d calls, filled=%s"):format(label, units, #calls, tostring(filled)))
	pass = pass + 1
end

print("\nMERCHANT PURCHASE")
--[[
    THE STACK BUG. A poison supplier stocking 40 dust against an order of 160 used to make
    ONE call for 40 -- four stacks in a single buy, which the server refuses -- and still
    credited 40 units and claimed the order filled.
]]
buyScenario("160 dust, vendor has 40, stacks of 10", 160, 40, 10, 40, false)
-- Unlimited stock (-1) is the common case and is unchanged.
buyScenario("160 dust, unlimited, stacks of 10", 160, -1, 10, 160, true)
-- Limited but sufficient.
buyScenario("40 vial, vendor has 100, stacks of 5", 40, 100, 5, 40, true)
-- Exactly enough.
buyScenario("40 vial, vendor has 40, stacks of 5", 40, 40, 5, 40, true)
-- Sold out buys nothing and claims nothing.
buyScenario("160 dust, sold out", 160, 0, 10, 0, false)
-- Uncached item falls back to single-unit buys.
buyScenario("7 dust, unlimited, uncached stack of 1", 7, -1, 1, 7, true)
-- A zero-amount order (the reagent path can produce one) must never read as filled.
buyScenario("0 dust, unlimited", 0, -1, 10, 0, false)

--[[
    THE FALSE FILL. Every chunk used to count as bought the moment it was sent, so a run the
    purse or the bags could not cover still reported its orders filled. A chunk the budget
    cannot cover is now never sent, and the order reads partly filled.
]]
do
	local order = newOrder(40)
	local units, calls = purchaseMerchantItem(order, -1, 10, { money = 25, unitPrice = 1 })
	assert(units == 20 and #calls == 2, ("money for 25: want 20 units in 2 calls, got %d in %d"):format(units, #calls))
	assert(not orderFilled(order), "money for 25: the order must not read filled")
	print(
		("  ok  %-46s -> %3d units in %d calls, filled=false"):format(
			"40 dust, money for 25, stacks of 10",
			units,
			#calls
		)
	)
	pass = pass + 1
end
do
	local order = newOrder(40)
	local slotsLeft = 2
	local claim = function()
		if slotsLeft < 1 then
			return false
		end
		slotsLeft = slotsLeft - 1
		return true
	end
	local units, calls = purchaseMerchantItem(order, -1, 10, { money = math.huge, unitPrice = 0, claim = claim })
	assert(
		units == 20 and #calls == 2,
		("two free slots: want 20 units in 2 calls, got %d in %d"):format(units, #calls)
	)
	assert(not orderFilled(order), "two free slots: the order must not read filled")
	print(
		("  ok  %-46s -> %3d units in %d calls, filled=false"):format("40 dust, room for 2 stacks of 10", units, #calls)
	)
	pass = pass + 1
end

-- A poison supplier listing dust in two slots: the second buys only what the first left owed.
do
	local order = newOrder(160)
	local first = purchaseMerchantItem(order, 40, 10)
	local second = purchaseMerchantItem(order, -1, 10)
	assert(first == 40 and second == 120, ("two slots: want 40 + 120 got %d + %d"):format(first, second))
	assert(orderFilled(order), "two slots: the order is filled once, across both slots")
	print(("  ok  %-46s -> %3d + %3d units, filled once"):format("160 dust, limited 40 then unlimited", first, second))
	pass = pass + 1
end

--[[
    THE GOLD RESERVE. ns.RestockFromMerchant takes the reserve off the purse before the
    first slot, so the run can spend only what sits above it, and a purse at or below the
    reserve has nothing to spend. Either way a chunk gold turned away sets outOfGold, the
    one flag behind "Not enough gold to finish restocking." -- the reserve and an empty
    purse are the same line, and room running out is not.
]]
local COPPER_PER_GOLD = 10000

-- The run's opening money, as shipped.
local function runMoney(purse, settings)
	local money = purse
	if settings.goldReserve then
		local reserve = (settings.goldReserveAmount or 0) * COPPER_PER_GOLD
		money = math.max(0, money - reserve)
	end
	return money
end

---@param label string
---@param purse number Copper on hand
---@param settings table { goldReserve, goldReserveAmount }
---@param unitPrice number Copper per unit
---@param wantUnits number
---@param wantOutOfGold boolean
local function reserveScenario(label, purse, settings, unitPrice, wantUnits, wantOutOfGold)
	local budget = { money = runMoney(purse, settings), unitPrice = unitPrice }
	local units = purchaseMerchantItem(newOrder(40), -1, 10, budget)
	assert(units == wantUnits, ("%s: want %d units got %d"):format(label, wantUnits, units))
	assert(
		(budget.outOfGold == true) == wantOutOfGold,
		("%s: outOfGold want %s got %s"):format(label, tostring(wantOutOfGold), tostring(budget.outOfGold))
	)
	assert(budget.money >= 0, ("%s: the run spent into the reserve"):format(label))
	print(("  ok  %-46s -> %3d units, outOfGold=%s"):format(label, units, tostring(wantOutOfGold)))
	pass = pass + 1
end

print("\nGOLD RESERVE")
-- 40 dust at 50 silver each is 20 gold.
reserveScenario("21g, reserve 1g, 20g order", 210000, { goldReserve = true, goldReserveAmount = 1 }, 5000, 40, false)
reserveScenario("20g, reserve 1g, 20g order", 200000, { goldReserve = true, goldReserveAmount = 1 }, 5000, 30, true)
reserveScenario("20g, reserve off, 20g order", 200000, { goldReserve = false, goldReserveAmount = 1 }, 5000, 40, false)
reserveScenario(
	"13g, reserve 13g: buying paused",
	130000,
	{ goldReserve = true, goldReserveAmount = 13 },
	5000,
	0,
	true
)
reserveScenario("5g, reserve 55g: buying paused", 50000, { goldReserve = true, goldReserveAmount = 55 }, 5000, 0, true)
reserveScenario("broke, reserve off", 0, { goldReserve = false, goldReserveAmount = 1 }, 5000, 0, true)
-- A free slot costs nothing, so even a paused run takes it and says nothing about gold.
reserveScenario("broke, reserve 1g, free item", 0, { goldReserve = true, goldReserveAmount = 1 }, 0, 40, false)

-- Full bags are their own line: room running out must not read as gold running out.
do
	local budget = { money = runMoney(1000000, { goldReserve = true, goldReserveAmount = 1 }), unitPrice = 5000 }
	budget.claim = function()
		return false
	end
	local units = purchaseMerchantItem(newOrder(40), -1, 10, budget)
	assert(units == 0 and budget.outOfSpace and not budget.outOfGold, "full bags: want outOfSpace alone")
	print(("  ok  %-46s -> %3d units, outOfSpace only"):format("100g, reserve 1g, bags full", units))
	pass = pass + 1
end

--[[
  END TO END: the reported case, all the way to units in the bag. 40 wanted, 18 banked,
  nothing held, an unlimited poison supplier. The order must cover 40 crafts, not 22.
]]
print("\nEND TO END")
local order = craftingPurchaseOrder(40, 0, 18, nil)
local dustUnits = purchaseMerchantItem(newOrder(order["Dust of Deterioration"]), -1, 10)
local vialUnits = purchaseMerchantItem(newOrder(order["Crystal Vial"]), -1, 5)
local craftable = math.min(math.floor(dustUnits / 4), math.floor(vialUnits / 1))
assert(craftable == 40, ("end to end: craftable want 40 got %d"):format(craftable))
print(("  ok  bought %d dust + %d vial -> %d crafts (was 22)"):format(dustUnits, vialUnits, craftable))
pass = pass + 1

print(("\nALL %d REAGENT BUY SCENARIOS PASSED"):format(pass))
