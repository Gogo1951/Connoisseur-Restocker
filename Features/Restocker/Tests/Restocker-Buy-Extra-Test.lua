-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the Buy Extra vendor toggle (no WoW API needed).

    Run it with:   lua Tests/Restocker-Buy-Extra-Test.lua

    It models the SAME two steps the live add-on uses:
      * Restocker-Merchant.lua BuildPurchaseOrder    -- whether an order exists, and for how much
      * Restocker-Merchant.lua PurchaseMerchantItem  -- how many units a vendor slot actually delivers
    plus the once-per-order fill count ns.RestockFromMerchant makes after the last slot.

    Buy Extra empties a LIMITED vendor slot instead of buying the shortfall. Classic sells
    its scarce consumables (Major Mana Potion and friends) a few at a time from a slot that
    trickles back, so the useful behaviour is to clear the slot every time you walk past
    rather than to top up to a number.

    Three properties carry the whole feature, and each has a way to go wrong that would not
    be obvious in game:

      1. UNLIMITED STOCK IS NEVER TOUCHED. A slot with numAvailable -1 never runs out, so
         "buy every one they have" has no end there. If Extra ever read -1 as a count, the
         buy loop would run backwards (harmless) or, with the sign flipped anywhere, spend
         the player's whole purse. Extra must be a no-op on unlimited slots.

      2. AN ORDER EXISTS EVEN WHEN NOTHING IS OWED. An Extra row that is already at or over
         its target still has to reach the vendor, which means BuildPurchaseOrder cannot use
         its usual "shortfall > 0" gate. The order's amount stays the real shortfall (0 here)
         so partial-fill reporting keeps working; it is never a guess at the vendor's stock,
         which is unknown until the slot is read.

      3. A ZERO TARGET STILL BUYS. Amount 0 with Extra on means "no stockpile, but grab any
         you see" -- a deliberate choice, and the one case where a 0-amount row spends gold.
         An amount of 0 with Extra OFF must still buy nothing.

    The chunked-buy scenarios at the end guard the same trap Restocker-Reagent-Buy-Test
    documents: BuyMerchantItem will not sell more than one stack per call, so a limited
    slot holding several stacks has to be chunked, not passed through in one call.
]]

local pass = 0

--[[
  BuildPurchaseOrder, as shipped. Returns the order for this item, or nil when the item
  never makes it onto the list. Orders are keyed by name and merge, so this takes the
  table the way the real one does.
]]
---@param orders table
---@param record table { amount, itemName, reaction, buyExtra }
---@param haveInBag number
---@param vendorReaction number
local function buildPurchaseOrder(orders, record, haveInBag, vendorReaction)
	local amount = record.amount or 0
	local requiredReaction = record.reaction or 0
	local buyExtra = record.buyExtra == true

	if requiredReaction > vendorReaction then -- luacheck: ignore 542
	-- Deliberately silent, same as the shipped code.
	elseif amount > 0 or buyExtra then
		local toBuy = math.max(0, amount - haveInBag)

		if toBuy > 0 or buyExtra then
			local order = orders[record.itemName]
			if not order then
				orders[record.itemName] = { amount = toBuy, remaining = toBuy, bought = 0, itemName = record.itemName }
			else
				order.amount = order.amount + toBuy
				order.remaining = order.remaining + toBuy
			end
			if buyExtra then
				orders[record.itemName].buyExtra = true
			end
		end
	end

	return orders[record.itemName]
end

--[[
  PurchaseMerchantItem, as shipped. merchantAvailable is the raw numAvailable reading:
  -1 unlimited, 0 sold out, positive is a limited slot. Buys against what the order still
  owes, sending a chunk only while the run's budget covers it, and adds what it sent to the
  order; returns the units and the calls for the checks. budget models the run's own:
  money, unitPrice, and claim(chunk) standing in for ns.ClaimBagSpace. Left out, it is
  unlimited. slot is what the merchant reports about the slot besides its stock; left out,
  it sells for gold to anyone. One the character cannot buy from, or one that costs
  something besides gold, is passed over whole.
]]
---@param buyItem table { amount, remaining, bought, buyExtra }
---@param merchantAvailable number
---@param stackCount number
---@param budget table|nil { money, unitPrice, claim }
---@param slot table|nil { isPurchasable, hasExtendedCost }
local function purchaseMerchantItem(buyItem, merchantAvailable, stackCount, budget, slot)
	budget = budget or { money = math.huge, unitPrice = 0 }
	slot = slot or { isPurchasable = true, hasExtendedCost = false }
	local calls = {}
	local unitsOrdered = 0
	if not slot.isPurchasable or slot.hasExtendedCost then
		return unitsOrdered, calls
	end
	if stackCount < 1 then
		stackCount = 1
	end

	local wanted = buyItem.remaining
	if merchantAvailable > 0 then
		if buyItem.buyExtra then
			wanted = merchantAvailable
		elseif wanted > merchantAvailable then
			wanted = merchantAvailable
		end
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

	buyItem.remaining = math.max(0, buyItem.remaining - unitsOrdered)
	buyItem.bought = buyItem.bought + unitsOrdered
	return unitsOrdered, calls
end

-- The fill test ns.RestockFromMerchant runs once per order, after the last slot.
local function orderFilled(order)
	return order.bought > 0 and order.bought >= order.amount
end

local function newOrder(buyItem)
	return { amount = buyItem.amount, remaining = buyItem.amount, bought = 0, buyExtra = buyItem.buyExtra }
end

--------------------------------------------------------------------------------
-- ORDER BUILDING
--------------------------------------------------------------------------------

---@param label string
---@param record table
---@param haveInBag number
---@param wantOrdered number|nil Expected order amount, or nil for "no order at all"
local function orderScenario(label, record, haveInBag, wantOrdered, vendorReaction)
	local orders = {}
	record.itemName = "Major Mana Potion"
	local order = buildPurchaseOrder(orders, record, haveInBag, vendorReaction or 4)

	if wantOrdered == nil then
		assert(order == nil, ("%s: expected no order, got one for %d"):format(label, order and order.amount or -1))
		print(("  ok  %-52s -> no order"):format(label))
	else
		assert(order ~= nil, ("%s: expected an order for %d, got none"):format(label, wantOrdered))
		assert(
			order.amount == wantOrdered,
			("%s: order amount want %d got %d"):format(label, wantOrdered, order.amount)
		)
		assert(order.amount >= 0, ("%s: order amount went negative (%d)"):format(label, order.amount))
		print(("  ok  %-52s -> order for %d"):format(label, order.amount))
	end
	pass = pass + 1
end

print("ORDER BUILDING")

-- Extra off: unchanged from before the feature.
orderScenario("off, want 35 have 0", { amount = 35 }, 0, 35)
orderScenario("off, want 35 have 30", { amount = 35 }, 30, 5)
orderScenario("off, want 35 have 35", { amount = 35 }, 35, nil)
orderScenario("off, want 35 have 40", { amount = 35 }, 40, nil)
orderScenario("off, want 0", { amount = 0 }, 0, nil)

-- Extra on: an order exists whatever the bags hold, and never goes negative.
orderScenario("on,  want 35 have 0", { amount = 35, buyExtra = true }, 0, 35)
orderScenario("on,  want 35 have 30", { amount = 35, buyExtra = true }, 30, 5)
orderScenario("on,  want 35 have 35", { amount = 35, buyExtra = true }, 35, 0)
orderScenario("on,  want 35 have 40", { amount = 35, buyExtra = true }, 40, 0)
-- The "works at 0 too" case: no stockpile target, but still worth grabbing.
orderScenario("on,  want 0 have 0", { amount = 0, buyExtra = true }, 0, 0)

-- Reputation still gates everything. Extra is not a way around a vendor standing.
orderScenario("on,  want 35 have 0, rep gate fails", { amount = 35, buyExtra = true, reaction = 8 }, 0, nil, 4)
orderScenario("on,  want 0, rep gate fails", { amount = 0, buyExtra = true, reaction = 7 }, 0, nil, 5)
orderScenario("on,  want 35 have 0, rep gate passes", { amount = 35, buyExtra = true, reaction = 5 }, 0, 35, 6)

--------------------------------------------------------------------------------
-- BUYING
--------------------------------------------------------------------------------

---@param label string
local function buyScenario(label, buyItem, merchantAvailable, stackCount, wantUnits, wantFilled)
	local order = newOrder(buyItem)
	local units, calls = purchaseMerchantItem(order, merchantAvailable, stackCount)
	local filled = orderFilled(order)
	assert(units == wantUnits, ("%s: units want %d got %d"):format(label, wantUnits, units))
	assert(filled == wantFilled, ("%s: filled want %s got %s"):format(label, tostring(wantFilled), tostring(filled)))
	for _, chunk in ipairs(calls) do
		assert(chunk <= stackCount, ("%s: a call asked for %d, over one stack of %d"):format(label, chunk, stackCount))
	end
	print(("  ok  %-52s -> %3d units, filled=%-5s (%d calls)"):format(label, units, tostring(filled), #calls))
	pass = pass + 1
end

print("\nBUYING")

-- Extra off: cap DOWN to the slot, exactly as before.
buyScenario("off, need 5, limited 12, stack 20", { amount = 5 }, 12, 20, 5, true)
buyScenario("off, need 35, limited 5, stack 20", { amount = 35 }, 5, 20, 5, false)
buyScenario("off, need 35, unlimited, stack 20", { amount = 35 }, -1, 20, 35, true)

-- Extra on, LIMITED slot: cap UP to the slot. This is the feature.
buyScenario("on,  need 5, limited 12, stack 20", { amount = 5, buyExtra = true }, 12, 20, 12, true)
buyScenario("on,  need 0, limited 5, stack 20", { amount = 0, buyExtra = true }, 5, 20, 5, true)
buyScenario("on,  need 35, limited 5, stack 20", { amount = 35, buyExtra = true }, 5, 20, 5, false)

--[[
  Extra on, UNLIMITED slot: a no-op. The order falls back to its own amount, so a topped-up
  or zero-target row buys nothing at all rather than emptying an endless shelf.
]]
buyScenario("on,  need 0, UNLIMITED, stack 20", { amount = 0, buyExtra = true }, -1, 20, 0, false)
buyScenario("on,  need 35, UNLIMITED, stack 20", { amount = 35, buyExtra = true }, -1, 20, 35, true)

-- Extra on, sold out: buys nothing and claims nothing.
buyScenario("on,  need 0, SOLD OUT, stack 20", { amount = 0, buyExtra = true }, 0, 20, 0, false)
buyScenario("on,  need 35, SOLD OUT, stack 20", { amount = 35, buyExtra = true }, 0, 20, 0, false)

-- Chunking: a limited slot holding several stacks must be split across calls.
buyScenario("on,  need 0, limited 25, stack 5", { amount = 0, buyExtra = true }, 25, 5, 25, true)
buyScenario("on,  need 0, limited 3, stack 1", { amount = 0, buyExtra = true }, 3, 1, 3, true)
buyScenario("on,  need 0, limited 7, uncached stack", { amount = 0, buyExtra = true }, 7, 1, 7, true)

--[[
  The purse runs out mid-slot: Extra clears only what the money covers, and the chunk it
  cannot pay for is never sent, so it is never counted either.
]]
do
	local order = newOrder({ amount = 0, buyExtra = true })
	local units, calls = purchaseMerchantItem(order, 12, 5, { money = 7, unitPrice = 1 })
	assert(units == 5 and #calls == 1, ("money runs out: want 5 units in 1 call, got %d in %d"):format(units, #calls))
	print(("  ok  %-52s -> %3d units (%d call)"):format("on,  need 0, limited 12, stack 5, money for 7", units, #calls))
	pass = pass + 1
end

--[[
  A slot priced in honor, tokens or items besides gold is passed over, and so is one the
  character cannot buy from (a reputation item without the standing): nothing is sent and
  nothing counted, so the order stays open for a slot that sells for gold.
]]
do
	local order = newOrder({ amount = 20 })
	local tokenUnits = purchaseMerchantItem(order, -1, 20, nil, { isPurchasable = true, hasExtendedCost = true })
	local refusedUnits = purchaseMerchantItem(order, -1, 20, nil, { isPurchasable = false, hasExtendedCost = false })
	assert(tokenUnits == 0, ("a token slot bought %d, must buy 0"):format(tokenUnits))
	assert(refusedUnits == 0, ("a slot the character cannot buy from bought %d, must buy 0"):format(refusedUnits))
	assert(not orderFilled(order), "a passed-over slot must not report a fill")
	local goldUnits = purchaseMerchantItem(order, -1, 20)
	assert(goldUnits == 20 and orderFilled(order), ("then a gold slot: want 20 and filled, got %d"):format(goldUnits))
	print(
		("  ok  %-52s -> %3d units, then %d from gold"):format(
			"off, need 20, token slot and refused slot",
			0,
			goldUnits
		)
	)
	pass = pass + 1
end

--------------------------------------------------------------------------------
-- END TO END
--------------------------------------------------------------------------------

--[[
  The case the feature was asked for. 35 Major Mana Potion on the list, 35 already in the
  bags, and a vendor holding a limited 5. Before Extra this bought nothing at all: the
  shortfall was zero, so no order was ever built.
]]
print("\nEND TO END")

local orders = {}
local record = { itemName = "Major Mana Potion", amount = 35, buyExtra = true }
local order = buildPurchaseOrder(orders, record, 35, 4)
assert(order ~= nil, "end to end: a topped-up Extra row must still reach the vendor")
local units = purchaseMerchantItem(order, 5, 20)
assert(units == 5, ("end to end: want 5 units got %d"):format(units))
assert(orderFilled(order), "end to end: clearing the slot covers a zero target")
print(("  ok  topped up at 35, vendor holds 5 -> bought %d (was 0)"):format(units))
pass = pass + 1

-- Same row at a vendor with an endless supply: nothing bought, nothing claimed.
local unlimitedOrder = buildPurchaseOrder({}, record, 35, 4)
local unlimitedUnits = purchaseMerchantItem(unlimitedOrder, -1, 20)
assert(unlimitedUnits == 0, ("end to end: unlimited slot bought %d, must buy 0"):format(unlimitedUnits))
assert(not orderFilled(unlimitedOrder), "end to end: an unlimited slot must not report a fill")
print(("  ok  topped up at 35, vendor unlimited  -> bought %d"):format(unlimitedUnits))
pass = pass + 1

--------------------------------------------------------------------------------
-- ONE ITEM, TWO SLOTS
--------------------------------------------------------------------------------

--[[
  A merchant listing the same item twice (or two items sharing a name, since orders are
  keyed by name) used to buy the whole order once per slot and count it filled twice.
  Every slot now buys only what the order still owes, and the order is counted once.
]]
print("\nONE ITEM, TWO SLOTS")

---@param label string
---@param slots table merchantAvailable per slot, in merchant order
local function twoSlotScenario(label, buyItem, slots, wantUnits, wantFilled, wantPartial)
	local slotOrder = newOrder(buyItem)
	local total = 0
	for _, available in ipairs(slots) do
		total = total + purchaseMerchantItem(slotOrder, available, 20)
	end
	local filled = orderFilled(slotOrder) and 1 or 0
	local partial = (slotOrder.bought > 0 and not orderFilled(slotOrder)) and 1 or 0
	assert(total == wantUnits, ("%s: units want %d got %d"):format(label, wantUnits, total))
	assert(filled == wantFilled, ("%s: filled count want %d got %d"):format(label, wantFilled, filled))
	assert(partial == wantPartial, ("%s: partial count want %d got %d"):format(label, wantPartial, partial))
	print(("  ok  %-52s -> %3d units, %d filled, %d partial"):format(label, total, filled, partial))
	pass = pass + 1
end

twoSlotScenario("off, need 20, two unlimited slots", { amount = 20 }, { -1, -1 }, 20, 1, 0)
twoSlotScenario("off, need 20, limited 6 then unlimited", { amount = 20 }, { 6, -1 }, 20, 1, 0)
twoSlotScenario("off, need 20, limited 6 then limited 5", { amount = 20 }, { 6, 5 }, 11, 0, 1)
twoSlotScenario("off, need 20, sold out then unlimited", { amount = 20 }, { 0, -1 }, 20, 1, 0)
-- Extra still clears every limited slot it passes, and still counts once.
twoSlotScenario("on,  need 0, limited 5 then limited 3", { amount = 0, buyExtra = true }, { 5, 3 }, 8, 1, 0)
twoSlotScenario("on,  need 10, limited 4 then unlimited", { amount = 10, buyExtra = true }, { 4, -1 }, 10, 1, 0)

--------------------------------------------------------------------------------
-- THE FLAG SURVIVES A LOGOUT
--------------------------------------------------------------------------------

--[[
  Models the one-line saved format in Restocker-Saved-Format.lua (ItemToString /
  rsItemFromString). Extra reaches the vendor logic only if it reaches the saved
  file first: the flag is set in the window, written at logout, and read back at
  login, and a field the writer never emits is silently off on every future
  session no matter what the buy logic does with it.

  The old-line case is the one worth pinning. Every list on disk today was
  written before this field existed, so the parser meets eight-field lines
  forever. It has to read those as Extra OFF -- the inverse of how reaction and
  upgrade default -- because absent means "this row never asked for a buyout",
  not "buy out every limited shelf you pass".
]]
local FIELD_COUNT = 9

---@param item table
---@return string
local function itemToString(item)
	local parts = {}
	parts[#parts + 1] = item.itemType or ""
	parts[#parts + 1] = item.itemName or ""
	parts[#parts + 1] = item.amount or 0
	parts[#parts + 1] = item.stashToBank and 1 or 0
	parts[#parts + 1] = item.restockFromBank and 1 or 0
	parts[#parts + 1] = (item.buyFromMerchant == false) and 0 or 1
	parts[#parts + 1] = (item.reaction and item.reaction > 0) and item.reaction or 0
	parts[#parts + 1] = (item.upgrade == false) and 0 or 1
	parts[#parts + 1] = item.buyExtra and 1 or 0
	return table.concat(parts, ", ")
end

---@param s string
---@return table
local function itemFromString(s)
	local f = {}
	for part in s:gmatch("[^,]+") do
		f[#f + 1] = (part:gsub("^%s+", ""):gsub("%s+$", ""))
	end

	local dataStart
	for j = 1, #f do
		if tonumber(f[j]) ~= nil then
			dataStart = j
			break
		end
	end
	dataStart = dataStart or (#f + 1)

	local upg = tonumber(f[dataStart + 5])
	local extra = tonumber(f[dataStart + 6])

	--[[
	    Never "(upg == 0) and false or nil": false is falsy, so the or takes over and
	    the expression yields nil for every input, losing the off state entirely.
	]]
	local upgrade = nil
	if upg == 0 then
		upgrade = false
	end

	return {
		amount = tonumber(f[dataStart]) or 0,
		upgrade = upgrade,
		buyExtra = (extra == 1) or nil,
	}
end

---@param label string
local function roundTripScenario(label, item, wantExtra, wantUpgradeOff)
	local line = itemToString(item)
	local fields = 0
	for _ in line:gmatch("[^,]+") do
		fields = fields + 1
	end
	assert(fields == FIELD_COUNT, ("%s: wrote %d fields, want %d"):format(label, fields, FIELD_COUNT))

	local back = itemFromString(line)
	assert(
		(back.buyExtra == true) == (wantExtra == true),
		("%s: buyExtra came back %s, want %s"):format(label, tostring(back.buyExtra), tostring(wantExtra))
	)
	assert(back.amount == item.amount, ("%s: amount came back %d, want %d"):format(label, back.amount, item.amount))
	--[[
		A flag whose default is ON is the one that can be lost silently: it writes
		as 0 and, read back through the wrong idiom, comes home as nil -- which
		reads as ON, so the setting quietly undoes itself at the next login.
	]]
	assert(
		(back.upgrade == false) == (wantUpgradeOff == true),
		("%s: upgrade came back %s, want %s"):format(label, tostring(back.upgrade), wantUpgradeOff and "false" or "nil")
	)
	print(("  ok  %-52s -> %s"):format(label, line))
	pass = pass + 1
end

print("\nTHE FLAG SURVIVES A LOGOUT")

roundTripScenario("Extra on, round trip", {
	itemType = "Consumable",
	itemName = "Major Mana Potion",
	amount = 35,
	stashToBank = true,
	restockFromBank = true,
	buyExtra = true,
}, true)

roundTripScenario("Extra off, round trip", {
	itemType = "Consumable",
	itemName = "Major Healing Potion",
	amount = 10,
	stashToBank = true,
	restockFromBank = true,
}, false)

roundTripScenario("Extra on with every other flag off", {
	itemType = "Consumable",
	itemName = "Free Action Potion",
	amount = 10,
	buyFromMerchant = false,
	upgrade = false,
	reaction = 6,
	buyExtra = true,
}, true, true)

--[[
	The reported bug: a mana potion kept on its own tier with Upgrade switched off
	came back upgradeable after a logout, and the login catch-up then merged it
	into the tier above.
]]
roundTripScenario("Upgrade off survives a logout", {
	itemType = "Consumable",
	itemName = "Superior Mana Potion",
	amount = 10,
	stashToBank = true,
	restockFromBank = true,
	upgrade = false,
}, false, true)

--[[
  An eight-field line, as every list on disk is written today. It must read
  as Extra off and leave the fields before it untouched.
]]
local legacyLine = "Consumable, Major Mana Potion, 35, 1, 1, 1, 0, 1"
local legacy = itemFromString(legacyLine)
assert(legacy.buyExtra == nil, ("old eight-field line read buyExtra %s, want nil"):format(tostring(legacy.buyExtra)))
assert(legacy.amount == 35, ("old line lost its amount: got %d"):format(legacy.amount))
assert(legacy.upgrade == nil, "old line's upgrade default must be unchanged by the new field")
print(("  ok  %-52s -> Extra off, amount %d intact"):format("old eight-field line", legacy.amount))
pass = pass + 1

print(("\nALL %d BUY EXTRA SCENARIOS PASSED"):format(pass))
