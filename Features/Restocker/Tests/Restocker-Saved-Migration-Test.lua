-- luacheck: allow defined, ignore 121 122 131 143
-- MIGRATION (remove after 2026-10-18)
--[[
    Headless test for the Restocker's saved-variable bridges (no WoW client needed).

    Run it with:   lua Tests/Restocker-Saved-Migration-Test.lua        (from Features/Restocker/)

    Like Restocker-Upgrade-Level-Test, this does NOT model the logic: it loads
    the REAL Restocker-Saved-Migration.lua and logs in the way Features/Core.lua
    does, ns.RenameRestockerSavedKeys and then ns.RepairBlindingPowderRows,
    against saved tables shaped like the ones older releases wrote.

    WHAT IS PINNED HERE. The saved keys were renamed (profiles to lists, profileKeys
    to listsByCharacter, currentProfile to currentList, framePos to framePosition
    with its xOfs and yOfs as xOffset and yOffset). No list, no character's list
    assignment and no window position value may be lost. A new name that already
    holds data is never overwritten, and a second login changes nothing.

    The Blinding Powder ladder saved Infantry Gauntlets (6510) for Blinding Powder
    (5530). On an Era client every such row becomes Blinding Powder with its amount
    and flags intact, and what login unpacks from it (through the REAL
    Restocker-Saved-Format.lua) never carries the gauntlets' name, which the
    merchant buys by. A row unpacked before the client has loaded Blinding Powder
    is named when the client answers, in the same session (through the REAL item
    memo and item-info handler). A list that already holds Blinding Powder keeps
    its own row, and off Era a 6510 row is left alone.

    This file retires with the rename bridge and the Blinding Powder repair, which
    share a date.
]]

local ROOT = arg[1] or "../.."

local ns = { db = { global = {} }, FLAVOR = "Vanilla" }

local function loadAddonFile(path)
	-- Add-on files are chunks taking (addonName, ns) as varargs, the way WoW loads them.
	return assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
end

loadAddonFile("Features/Restocker/Restocker-Saved-Migration.lua")

--[[
    The Blinding Powder scenarios unpack lines the way ns.InitializeRestocker does,
    through the REAL Restocker-Saved-Format.lua. Its parser calls two WoW string
    helpers, and it names rows from the item memo, which here knows only the items
    in `cached` -- so a scenario can log in on a cold item cache.
]]
function strsplit(delimiter, text)
	local parts = {}
	for part in (text .. delimiter):gmatch("(.-)" .. delimiter) do
		parts[#parts + 1] = part
	end
	return table.unpack(parts)
end

function strtrim(text)
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end

local ITEM_DATA = { [5530] = { itemName = "Blinding Powder", itemType = "Reagent" } }
local cached = {}

function ns.GetItemData(itemID)
	return cached[itemID] and ITEM_DATA[itemID] or nil
end

loadAddonFile("Features/Restocker/Restocker-Saved-Format.lua")

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

---A table as one comparable string, keys sorted, so two saved shapes can be checked for equality.
local function dump(value)
	if type(value) ~= "table" then
		return type(value) == "string" and ("%q"):format(value) or tostring(value)
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	local parts = {}
	for _, key in ipairs(keys) do
		parts[#parts + 1] = "[" .. dump(key) .. "]=" .. dump(value[key])
	end
	return "{" .. table.concat(parts, ",") .. "}"
end

---One login, in Core's order: the rename, then the Blinding Powder repair.
local function login(settings)
	ns.db.global.restocker = settings
	ns.RenameRestockerSavedKeys()
	ns.RepairBlindingPowderRows()
	return settings
end

---What AceDB leaves under global.restocker from Data/Default-Settings.lua before anything runs.
local function currentDefaults()
	return {
		lists = {},
		starterListDismissed = {},
		framePosition = {},
		restockReminderChat = true,
	}
end

--[[
    Every fixture below is built fresh on each call: the bridges move tables by
    reference, so a shared fixture would already be renamed by the time the
    next scenario read it. Item lines are the saved one-line form, keyed by
    itemID; neither bridge reads inside them.
]]
local function oldLists()
	return {
		Mage = {
			[8079] = "Consumable, Conjured Crystal Water, 40, 0, 1, 1, 0, 1, 0",
			[8076] = "Consumable, Conjured Sweet Roll, 20, 0, 1, 1, 0, 1, 0",
		},
		["Bank Run"] = { [13444] = "Consumable, Major Mana Potion, 10, 0, 1, 1, 0, 1, 1" },
	}
end

local function oldAssignments()
	return { ["Frostbolt - Whitemane"] = "Mage", ["Bankalt - Whitemane"] = "Bank Run" }
end

-- xOfs is 0 on purpose: the window's fallback is -5, so a dropped zero would move it.
local function oldPosition()
	return { point = "TOPLEFT", relativePoint = "TOPLEFT", xOfs = 0, yOfs = -212.5, width = 720, height = 540 }
end

---Adds the four old-named keys, as the previous release saved them, to a table.
local function withOldKeys(saved)
	saved.profiles = oldLists()
	saved.profileKeys = oldAssignments()
	saved.currentProfile = "Mage"
	saved.framePos = oldPosition()
	return saved
end

---The checks every successful rename shares: everything under its new name, nothing left under the old one.
local function checkRenamed(settings)
	check("lists carried in full", dump(settings.lists), dump(oldLists()))
	check("character assignments carried", dump(settings.listsByCharacter), dump(oldAssignments()))
	check("current list carried", settings.currentList, "Mage")
	check("position point", settings.framePosition.point, "TOPLEFT")
	check("position relativePoint", settings.framePosition.relativePoint, "TOPLEFT")
	check("position xOffset (zero kept)", settings.framePosition.xOffset, 0)
	check("position yOffset", settings.framePosition.yOffset, -212.5)
	check("position width", settings.framePosition.width, 720)
	check("position height", settings.framePosition.height, 540)
	check("no xOfs left", settings.framePosition.xOfs, nil)
	check("no yOfs left", settings.framePosition.yOfs, nil)
	check("profiles cleared", settings.profiles, nil)
	check("profileKeys cleared", settings.profileKeys, nil)
	check("currentProfile cleared", settings.currentProfile, nil)
	check("framePos cleared", settings.framePos, nil)
end

--[[
    The Blinding Powder lines are strings, so they can be shared. The six flags on
    the gauntlets line (stash on, bank off, Buy off, Friendly, Upgrade off, Extra
    on) make a pattern no dropped or shifted field could reproduce.
]]
local GAUNTLETS_LINE = "Armor, Infantry Gauntlets, 40, 1, 0, 0, 5, 0, 1"
local FLASH_POWDER_LINE = "Reagent, Flash Powder, 20, 0, 1, 1, 0, 1, 0"

---The rows ns.InitializeRestocker would unpack from a saved list, taken from a copy so the lines stay saved.
local function unpacked(list)
	local rows = {}
	for key, line in pairs(list) do
		rows[key] = line
	end
	ns.InflateSavedRestockItems({ lists = { Unpacked = rows } })
	return rows
end

--------------------------------------------------------------------------------

print("1. Old names in ConnoisseurDB move to the new names")
local settings = login(withOldKeys(currentDefaults()))
checkRenamed(settings)
check("unrelated setting untouched", settings.restockReminderChat, true)

print("2. A second login changes nothing")
local before = dump(settings)
login(settings)
check("same saved shape", dump(settings), before)

print("3. A new name that already holds data is never overwritten")
settings = withOldKeys(currentDefaults())
settings.lists = { Main = { [8079] = "Consumable, Conjured Crystal Water, 60, 0, 1, 1, 0, 1, 0" } }
settings.listsByCharacter = { ["Frostbolt - Whitemane"] = "Main" }
settings.currentList = "Main"
settings.framePosition = { point = "CENTER", relativePoint = "CENTER", xOffset = 10, yOffset = 20 }
local newShape = dump({
	lists = settings.lists,
	listsByCharacter = settings.listsByCharacter,
	currentList = settings.currentList,
	framePosition = settings.framePosition,
})
login(settings)
check(
	"new names unchanged",
	dump({
		lists = settings.lists,
		listsByCharacter = settings.listsByCharacter,
		currentList = settings.currentList,
		framePosition = settings.framePosition,
	}),
	newShape
)
check("old lists kept, not lost", dump(settings.profiles), dump(oldLists()))
check("old assignments kept, not lost", dump(settings.profileKeys), dump(oldAssignments()))
check("old current list kept", settings.currentProfile, "Mage")
check("old position kept, not lost", dump(settings.framePos), dump(oldPosition()))

print("4. Empty old keys are cleared rather than left in the file")
settings = currentDefaults()
settings.profiles = {}
settings.profileKeys = {}
settings.framePos = {}
login(settings)
check("profiles cleared", settings.profiles, nil)
check("profileKeys cleared", settings.profileKeys, nil)
check("framePos cleared", settings.framePos, nil)
check("lists still a table", type(settings.lists), "table")
check("framePosition still a table", type(settings.framePosition), "table")

print("5. Every list's gauntlets row becomes Blinding Powder, its numbers kept")
settings = currentDefaults()
settings.lists = {
	Rogue = { [6510] = GAUNTLETS_LINE, [5140] = FLASH_POWDER_LINE },
	["Bank Run"] = { [6510] = "Armor, Infantry Gauntlets, 20, 0, 1, 1, 0, 1, 0" },
}
login(settings)
check("gauntlets row gone", settings.lists.Rogue[6510], nil)
check("Blinding Powder line, label dropped", settings.lists.Rogue[5530], "40, 1, 0, 0, 5, 0, 1")
check("other rows untouched", settings.lists.Rogue[5140], FLASH_POWDER_LINE)
check("second list's gauntlets row gone", settings.lists["Bank Run"][6510], nil)
check("second list repaired too", settings.lists["Bank Run"][5530], "20, 0, 1, 1, 0, 1, 0")
before = dump(settings)
login(settings)
check("a second login changes nothing", dump(settings), before)

print("6. Login unpacks it as Blinding Powder, with the gauntlets row's own settings")
cached[5530] = true
local row = unpacked(settings.lists.Rogue)[5530]
local asSaved = unpacked({ [6510] = GAUNTLETS_LINE })[6510]
check("itemID", row.itemID, 5530)
check("named from the item cache", row.itemName, "Blinding Powder")
check("typed from the item cache", row.itemType, "Reagent")
check("amount", row.amount, 40)
for _, field in ipairs({ "stashToBank", "restockFromBank", "buyFromMerchant", "reaction", "upgrade", "buyExtra" }) do
	check(field .. " as saved", row[field], asSaved[field])
end

print("7. Unpacked on a cold item cache it has no name, never the gauntlets', and saves that way")
cached[5530] = nil
row = unpacked(settings.lists.Rogue)[5530]
check("blank, never the gauntlets' name", row.itemName, "")
ns.restockSettings = { lists = { Rogue = { [5530] = row } } }
ns.DeflateRestockItemsForSave()
cached[5530] = true
check(
	"a blank saved line is named at a warm login",
	unpacked(ns.restockSettings.lists.Rogue)[5530].itemName,
	"Blinding Powder"
)

print("8. A list that already holds Blinding Powder keeps its own row")
settings = currentDefaults()
settings.lists = { Rogue = { [6510] = GAUNTLETS_LINE, [5530] = "Reagent, Blinding Powder, 10, 0, 1, 1, 0, 1, 0" } }
login(settings)
check("gauntlets row gone", settings.lists.Rogue[6510], nil)
check("player's own row untouched", settings.lists.Rogue[5530], "Reagent, Blinding Powder, 10, 0, 1, 1, 0, 1, 0")

print("9. A table left by a crash moves the same way, gauntlets name and link cleared")
settings = currentDefaults()
settings.lists = {
	Rogue = {
		[6510] = {
			itemID = 6510,
			itemName = "Infantry Gauntlets",
			itemType = "Armor",
			itemLink = "[Infantry Gauntlets]",
			amount = 40,
			buyFromMerchant = false,
			buyExtra = true,
		},
	},
}
login(settings)
row = settings.lists.Rogue[5530] or {}
check("gauntlets row gone", settings.lists.Rogue[6510], nil)
check("itemID follows the key", row.itemID, 5530)
check("name cleared", row.itemName, "")
check("type cleared", row.itemType, nil)
check("link cleared", row.itemLink, nil)
check("amount kept", row.amount, 40)
check("Buy off kept", row.buyFromMerchant, false)
check("Extra kept", row.buyExtra, true)

print("10. A list still under its old name is repaired in the same login")
settings = currentDefaults()
settings.profiles = { Rogue = { [6510] = GAUNTLETS_LINE } }
login(settings)
check("renamed and repaired", (settings.lists.Rogue or {})[5530], "40, 1, 0, 0, 5, 0, 1")
check("no gauntlets row", (settings.lists.Rogue or {})[6510], nil)

print("11. Off Era, a 6510 row is one the player added, and it stays")
ns.FLAVOR = "TBC"
settings = currentDefaults()
settings.lists = { Main = { [6510] = GAUNTLETS_LINE } }
login(settings)
check("gauntlets row kept", settings.lists.Main[6510], GAUNTLETS_LINE)
check("no Blinding Powder row added", settings.lists.Main[5530], nil)
ns.FLAVOR = "Vanilla"

--[[
    Scenarios 12 to 14 log in for real on a fresh namespace. The REAL item memo
    (Features/Item-Cache.lua) and item-info handler (Restocker-List.lua) join the
    migration and the unpacking, in the order InitializeSavedVariables and
    ns.InitializeRestocker run them: repair, unpack, the first sync, then the
    window. Only the client is simulated, as Restocker-Cold-Item-Test does it:
    C_Item.GetItemInfo answers once an item has loaded and otherwise queues a query, and
    deliver() answers the queue, firing GET_ITEM_INFO_RECEIVED only while the
    event is registered.
]]
local client

C_Item = {
	GetItemInfo = function(itemID)
		if not client.loaded[itemID] then
			client.queued[itemID] = true
			return nil
		end
		local item = ITEM_DATA[itemID] or { itemName = "Item " .. itemID, itemType = "Consumable" }
		return item.itemName, "|Hitem:" .. itemID .. "|h[" .. item.itemName .. "]|h", 1, 1, 1, item.itemType
	end,
}

local function loginOnClient(lists, loadedItemIDs)
	client = { loaded = {}, queued = {}, registered = false, redraws = 0 }
	for _, itemID in ipairs(loadedItemIDs) do
		client.loaded[itemID] = true
	end

	local session = { db = { global = { restocker = { lists = lists } } }, FLAVOR = "Vanilla" }
	for _, path in ipairs({
		"Features/Item-Cache.lua",
		"Features/Restocker/Restocker-Saved-Format.lua",
		"Features/Restocker/Restocker-Saved-Migration.lua",
		"Features/Restocker/Restocker-List.lua",
	}) do
		assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", session)
	end

	-- The other waiters Restocker-List.lua syncs with, idle here; their own tests cover them.
	session.pendingRecipes = {}
	function session.HasPendingUpgrade()
		return false
	end
	function session.HasPendingStarterAdds()
		return false
	end
	function session.SetEventRegistered(event, enabled)
		if event == "GET_ITEM_INFO_RECEIVED" then
			client.registered = enabled
		end
	end
	function session.UpdateRestockList()
		client.redraws = client.redraws + 1
	end

	session.RepairBlindingPowderRows()
	session.restockSettings = session.db.global.restocker
	session.InflateSavedRestockItems(session.restockSettings)
	session.SyncRestockItemInfoSubscription()
	session.restockWindow = {}

	-- The server answers every query so far, heard only while the event is registered.
	function client.deliver()
		local answered = {}
		for itemID in pairs(client.queued) do
			answered[#answered + 1] = itemID
		end
		for _, itemID in ipairs(answered) do
			client.queued[itemID] = nil
			client.loaded[itemID] = true
			if client.registered then
				session.OnRestockerItemInfoReceived(itemID, true)
			end
		end
	end

	return session
end

print("12. Cold at login: the row waits without a name and is named when the client answers")
local session = loginOnClient({ Rogue = { [6510] = GAUNTLETS_LINE } }, {})
row = session.restockSettings.lists.Rogue[5530]
check("no name yet", row.itemName, "")
check("listening for Blinding Powder", client.registered, true)
client.deliver()
check("named in the same session", row.itemName, "Blinding Powder")
check("typed too", row.itemType, "Reagent")
check("window redrawn", client.redraws, 1)
check("event released", client.registered, false)

print("13. Warm at login: named straight away, a crash-left table included, and nothing listens")
session = loginOnClient({
	Rogue = { [6510] = GAUNTLETS_LINE },
	Bank = { [6510] = { itemID = 6510, itemName = "Infantry Gauntlets", amount = 5 } },
}, { 5530 })
check("named by the unpacking", session.restockSettings.lists.Rogue[5530].itemName, "Blinding Powder")
check("table named at the first sync", session.restockSettings.lists.Bank[5530].itemName, "Blinding Powder")
check("no redraw before the window exists", client.redraws, 0)
check("nothing listening", client.registered, false)

print("14. A crash-left table on a cold client asks for Blinding Powder itself")
session = loginOnClient({ Rogue = { [6510] = { itemID = 6510, itemName = "Infantry Gauntlets", amount = 40 } } }, {})
row = session.restockSettings.lists.Rogue[5530]
check("asked the client", client.queued[5530], true)
check("listening for it", client.registered, true)
client.deliver()
check("named when it arrives", row.itemName, "Blinding Powder")
check("event released", client.registered, false)

print("")
if failures == 0 then
	print("ALL SAVED MIGRATION SCENARIOS PASSED")
else
	print(("%d SAVED MIGRATION CHECK(S) FAILED"):format(failures))
	os.exit(1)
end
