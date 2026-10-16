-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the Restock List consumable upgrader (no WoW client needed).

    Run it with:   lua Tests/Restocker/Restocker-Upgrade-Level-Test.lua        (from the add-on root)

    Unlike the other tests in this folder, this one does NOT model the algorithm: it
    loads the REAL Data/Vanilla/Consumable-Upgrade-Paths-Vanilla.lua and Restocker-Upgrade.lua and drives
    ns.UpgradeRestockList directly, behind the thinnest stubs that will hold them up
    (an item cache, a chat sink, and UnitLevel). A model would have re-implemented the
    very line the bug below lived on.

    THE BUG THIS PINS DOWN. PLAYER_LEVEL_UP carries the new level as its first
    argument, and UnitLevel("player") still reads the OLD level while that event is
    being handled -- the unit field updates a moment later. The upgrader used to
    ignore the payload and ask UnitLevel, so a ding to 45 was planned against 44, found
    no strictly later tier, and left the list on its level-35 water. Nothing re-checked
    afterwards, so that miss was permanent: relogging never fixed it. Scenario 1 is
    that exact sequence, and scenarios 2-3 are the two halves of the fix -- the level
    handed through from the event, and the login catch-up that repairs a list which
    fell behind for any other reason.
]]

local ROOT = arg[1] or "."

local ns = { L = {} }
ns.L["RESTOCKER_UPGRADED"] = "Your Restock List has been upgraded."
ns.L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d upgrade to %sx%d."

--[[
    Only the ladder rungs these scenarios touch. Anything absent from `cached` models an
    item the client has not resolved yet, which is what the deferral path is for.
]]
local names = {
	[1645] = "Moonberry Juice",
	[8766] = "Morning Glory Dew",
	[4601] = "Soft Banana Bread",
	[8950] = "Homemade Cherry Pie",
}
local cached = {}
for id in pairs(names) do
	cached[id] = true
end

local prints = {}
local updates = 0

-- The Restocker hangs off ns directly, so the stubs go there too.
function ns.PrintMessage(text)
	prints[#prints + 1] = tostring(text)
end

function ns.UpdateRestockList()
	updates = updates + 1
end

--[[
    Restocker-Upgrade.lua asks Core to listen for item lookups whenever it defers a tier
    move; offline there is no Core, and the deferral itself is what is tested.
]]
function ns.SyncRestockItemInfoSubscription() end

-- The session item memo moved to Features/Item-Cache.lua and hangs off ns.
function ns.GetItemData(id)
	if not cached[id] then
		return nil
	end
	return { itemName = names[id] or ("Item" .. id), itemType = "Consumable" }
end

function ns.GetItemHyperlink(id, fallbackName)
	return "[" .. (names[id] or fallbackName or id) .. "]"
end

local settings = { currentList = "Test", lists = { Test = {} } }
ns.restockSettings = settings

--[[
    What the client reports AFTER the level has settled. Held one behind the ding in the
    scenarios that reproduce the bug.
]]
local playerLevel = 1
function UnitLevel(_)
	return playerLevel
end

local function loadAddonFile(path)
	-- Add-on files are chunks taking (addonName, ns) as varargs, the way WoW loads them.
	return assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
end

loadAddonFile("Data/Vanilla/Consumable-Upgrade-Paths-Vanilla.lua")
loadAddonFile("Features/Restocker/Restocker-Upgrade.lua")

--------------------------------------------------------------------------------

local failures = 0

local function check(label, got, want)
	if got == want then
		print(("  ok    %s = %s"):format(label, tostring(got)))
	else
		failures = failures + 1
		print(("  FAIL  %s: got %s, want %s"):format(label, tostring(got), tostring(want)))
	end
end

---A fresh Restock List, with the chat log cleared so each scenario counts its own lines.
local function setList(entries)
	settings.lists.Test = entries
	prints = {}
	return entries
end

---One list row, in the inflated in-memory form rsInflate leaves behind at login.
local function row(amount, extra)
	local item = { itemID = 0, itemName = "", itemType = "Consumable", amount = amount }
	for k, v in pairs(extra or {}) do
		item[k] = v
	end
	return item
end

--------------------------------------------------------------------------------

print("1. THE BUG: ding to 45, level read back off the player (still 44)")
local list = setList({ [1645] = row(20), [4601] = row(20) })
playerLevel = 44
ns.UpgradeRestockList() -- no payload: what the old handler did
check("water stuck on the level-35 tier", list[1645] ~= nil, true)
check("no level-45 water", list[8766] == nil, true)
check("bread stuck too", list[4601] ~= nil, true)
check("and no message to say so", #prints, 0)

print("2. THE FIX: same ding, new level handed through from the event")
list = setList({ [1645] = row(20), [4601] = row(20) })
playerLevel = 44 -- UnitLevel is STILL behind; the payload is what carries
ns.UpgradeRestockList(45)
check("Morning Glory Dew listed", list[8766] ~= nil, true)
check("Moonberry Juice gone", list[1645] == nil, true)
check("Homemade Cherry Pie listed", list[8950] ~= nil, true)
check("amount carried across", list[8766].amount, 20)
check("name rewritten to the new tier", list[8766].itemName, "Morning Glory Dew")
check("itemID follows the key", list[8766].itemID, 8766)
check("headline plus one line per swap", #prints, 3)

print("3. LOGIN CATCH-UP: a list that fell behind, repaired without a ding")
list = setList({ [1645] = row(20) })
playerLevel = 45
ns.UpgradeRestockList()
check("upgraded on arrival", list[8766] ~= nil, true)

print("4. Silent no-op once nothing is behind")
list = setList({ [8766] = row(20) })
playerLevel = 45
ns.UpgradeRestockList()
check("untouched", list[8766] ~= nil, true)
check("no chat", #prints, 0)

print("5. An item ABOVE the player's level is left alone, never moved down")
list = setList({ [8766] = row(20) })
playerLevel = 40
ns.UpgradeRestockList()
check("still the level-45 water", list[8766] ~= nil, true)
check("no chat", #prints, 0)

print("6. upgrade = false opts a row out")
list = setList({ [1645] = row(20, { upgrade = false }) })
playerLevel = 45
ns.UpgradeRestockList()
check("old tier kept", list[1645] ~= nil, true)
check("new tier not added", list[8766] == nil, true)

print("7. Target tier already listed: rows merge and amounts sum")
list = setList({ [1645] = row(20), [8766] = row(5) })
playerLevel = 45
ns.UpgradeRestockList()
check("old row gone", list[1645] == nil, true)
check("amounts summed", list[8766].amount, 25)

print("8. Unresolved target defers, then rides GET_ITEM_INFO_RECEIVED")
cached[8766] = nil
list = setList({ [1645] = row(20) })
playerLevel = 44
ns.UpgradeRestockList(45)
check("nothing half-written", list[1645] ~= nil, true)
check("no new row", list[8766] == nil, true)
check("pending", ns.HasPendingUpgrade(), true)
check("silent while deferred", #prints, 0)
cached[8766] = true -- the item info arrives
playerLevel = 45 -- by now UnitLevel has caught up, which is why the retry needs no payload
ns.UpgradeRestockList()
check("upgraded on the retry", list[8766] ~= nil, true)
check("pending cleared", ns.HasPendingUpgrade(), false)

print("9. Era client stops at the last Classic tier, whatever the level")
list = setList({ [1645] = row(20) })
playerLevel = 70
ns.UpgradeRestockList()
check("Morning Glory Dew", list[8766] ~= nil, true)
check("not Filtered Draenic Water", list[28399] == nil, true)

print("10. Row order carries no meaning: a reversed Wrath ladder still picks by rank")
local wrath = { L = {} }
assert(loadfile(ROOT .. "/Data/Wrath/Consumable-Upgrade-Paths-Wrath.lua"))("Consumable-Connoisseur", wrath)
local wrathWater
for _, chain in ipairs(wrath.CONSUMABLE_UPGRADE_CHAINS) do
	local reversed = {}
	for index = #chain.tiers, 1, -1 do
		reversed[#reversed + 1] = chain.tiers[index]
	end
	chain.tiers = reversed
	if chain.kind == "water" then
		wrathWater = chain
	end
end
assert(loadfile(ROOT .. "/Features/Restocker/Restocker-Upgrade.lua"))("Consumable-Connoisseur", wrath)
check("level 65 takes the Wrath water over TBC's", wrath.BestChainItemID(wrathWater, 65), 35954)
check("level 60 takes Filtered Draenic Water", wrath.BestChainItemID(wrathWater, 60), 28399)
check("level 75 takes Honeymint Tea", wrath.BestChainItemID(wrathWater, 75), 33445)

print("")
if failures == 0 then
	print("ALL UPGRADE SCENARIOS PASSED")
else
	print(("%d UPGRADE CHECK(S) FAILED"):format(failures))
	os.exit(1)
end
