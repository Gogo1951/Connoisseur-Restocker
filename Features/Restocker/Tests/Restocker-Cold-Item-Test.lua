-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the item memo's remembered misses (no WoW client needed).

    Run it with:   lua Tests/Restocker-Cold-Item-Test.lua        (from Features/Restocker/)

    Like the Starter List test, this does NOT model the feature. Every scenario loads the REAL
    item memo (Features/Item-Cache.lua), the GET_ITEM_INFO_RECEIVED handler and the add box
    (Restocker-List.lua), the ladders and the upgrader, the poison recipes, the login inflate
    (Restocker-Saved-Format.lua) and the Restocker window's own redraw
    (Restocker-Window-Filter.lua and Restocker-Window-Rows.lua). Only the client is simulated:
    C_Item.GetItemInfo answers for an item once it has resolved, asking about any other item queues
    a server query, and deliver() answers the queue, firing GET_ITEM_INFO_RECEIVED only while
    the event is registered, which is all a real frame hears.

    THE BUG THIS PINS DOWN. ns.GetItemData remembered every ID-keyed miss until
    GET_ITEM_INFO_RECEIVED was heard, and that event is only registered while something is
    waiting on it. A miss taken while nothing waited -- a window redraw, the login inflate of
    every saved list -- still sent the query, the answer landed unheard, and the memo said
    "missing" for the rest of the session without asking again. Scenario 1 is a listed item
    drawn with a question mark all session. Scenario 2 is an item typed back in by id that
    never arrived and kept the event registered for good. Scenario 3 is the login catch-up
    upgrade parked forever, which only happened when no cold poison recipe was holding the
    event through the load -- the reason it went unnoticed.

    A miss is now remembered only while something waits, and the last waiter letting go
    drops them all (scenario 6). Scenarios 4 and 5 pin what remembering is still for: a wait
    asks the client about a cold item once rather than at every answer, and an item asked
    about during a wait still arrives when its answer is heard.

    Scenario 7 pins add-box input that names no item (an empty box, a typo): it is dropped
    rather than parked, because no answer can ever clear such a key and a parked one held the
    event registered for the rest of the session. A typo is answered, though, where an empty
    box is not: the add box says what it takes.
]]

local ROOT = arg[1] or "../.."

-- The items these scenarios name: { name, item type }. Anything else answers as "Item <id>".
local ITEMS = {
	[1179] = { "Ice Cold Milk", "Consumable" },
	[1205] = { "Melon Juice", "Consumable" },
	[5530] = { "Blinding Powder", "Reagent" },
	[6948] = { "Hearthstone", "Miscellaneous" },
	[21177] = { "Symbol of Kings", "Reagent" },
}

local QUESTION_MARK = "Interface\\ICONS\\INV_Misc_QuestionMark"

local failures = 0

local function check(label, got, want)
	if got == want then
		print(("  ok    %s = %s"):format(label, tostring(got)))
	else
		failures = failures + 1
		print(("  FAIL  %s: got %s, want %s"):format(label, tostring(got), tostring(want)))
	end
end

--[[
    One login: a fresh namespace with every file loaded again and nothing resolved. The
    memo, the waiters and the pending retries are all file locals, so a scenario only
    starts clean by reloading them.
]]
local function session(level)
	local resolved, queued, registered, calls = {}, {}, {}, {}
	local ns = {
		L = setmetatable({}, {
			__index = function(_, key)
				return key
			end,
		}),
	}

	C_Item = {
		-- IDs from 900000 up stand in for a typo: no item behind them on this client.
		DoesItemExistByID = function(itemID)
			return itemID < 900000
		end,
		GetItemInfo = function(request)
			local itemID = type(request) == "number" and request or tonumber(tostring(request):match("item:(%d+)"))
			if not itemID then
				-- Text naming no item the client knows: no answer, and nothing to query.
				return nil
			end
			calls[itemID] = (calls[itemID] or 0) + 1
			if not resolved[itemID] then
				queued[itemID] = true
				return nil
			end
			local item = ITEMS[itemID] or { "Item " .. itemID, "Consumable" }
			local link = "|cffffffff|Hitem:" .. itemID .. "|h[" .. item[1] .. "]|h|r"
			return item[1], link, 1, 1, 1, item[2], "", 20, "", "icon:" .. itemID, 0
		end,
	}
	function UnitLevel()
		return level or 60
	end
	function LibStub()
		return {}
	end
	function wipe(t)
		for key in pairs(t) do
			t[key] = nil
		end
		return t
	end
	function strsplit(separator, text)
		local parts = {}
		for part in (text .. separator):gmatch("(.-)" .. separator) do
			parts[#parts + 1] = part
		end
		return table.unpack(parts)
	end
	function strtrim(text)
		return (text:gsub("^%s+", ""):gsub("%s+$", ""))
	end
	ITEM_QUALITY_COLORS = { [1] = { r = 1, g = 1, b = 1 } }

	function ns.SetEventRegistered(event, enabled)
		registered[event] = enabled or nil
	end
	local printed = {}
	function ns.PrintMessage(message)
		printed[#printed + 1] = message
	end
	-- The add box's notice line (Restocker-Window.lua), which falls back to chat with the window shut, as here.
	ns.ShowRestockAddNotice = ns.PrintMessage
	-- The Starter List's retry queue, which its own test covers.
	function ns.HasPendingStarterAdds()
		return false
	end
	-- MIGRATION (remove after 2026-10-18): the Blinding Powder name wait, which Restocker-Saved-Migration-Test covers.
	function ns.NameBlindingPowderRows()
		return false
	end

	-- What Restocker-Window-Rows.lua takes from Restocker-Window-Columns.lua as it loads.
	ns.RESTOCK_COLUMNS = {}
	ns.RESTOCK_CELL_WHITE = { r = 1, g = 1, b = 1 }
	ns.RESTOCK_CELL_DASH_OFF = { r = 0.5, g = 0.5, b = 0.5 }
	ns.RESTOCK_CELL_DASH_NOT_APPLICABLE = { r = 0.3, g = 0.3, b = 0.3 }
	ns.RESTOCK_CELL_REPUTATION_SET = { r = 0, g = 1, b = 0 }
	ns.RESTOCK_CELL_KEEP_SHORT = { r = 1, g = 0, b = 0 }
	function ns.RestockReputationStandingByValue()
		return { label = "Any" }
	end
	-- The bag count a row's Keep mark goes by (Restocker-Merchant.lua); no scenario here reads the mark.
	function ns.IsRestockItemShort()
		return false
	end

	local function loadAddonFile(path)
		-- Add-on files are chunks taking (addonName, ns) as varargs, the way WoW loads them.
		return assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
	end
	loadAddonFile("Features/Item-Cache.lua")
	loadAddonFile("Data/Vanilla/Consumable-Upgrade-Paths-Vanilla.lua")
	loadAddonFile("Data/Vanilla/Poison-Recipes-Vanilla.lua")
	loadAddonFile("Features/Restocker/Restocker-Saved-Format.lua")
	loadAddonFile("Features/Restocker/Restocker-Crafting-Reagents.lua")
	loadAddonFile("Features/Restocker/Restocker-Upgrade.lua")
	loadAddonFile("Features/Restocker/Restocker-List.lua")
	loadAddonFile("Features/Restocker/Restocker-Window-Filter.lua")
	loadAddonFile("Features/Restocker/Restocker-Window-Rows.lua")

	-- Core's dispatcher, reduced to the one event in play.
	ns.restockerEventHandlers = { GET_ITEM_INFO_RECEIVED = ns.OnRestockerItemInfoReceived }

	--[[
	    The window, cut down to what the real redraw touches: a pool of rows that record
	    the icon they were given, and a category pane that records each item's group.
	]]
	local function row()
		local frame = {
			icon = {
				SetTexture = function(self, texture)
					self.texture = texture
				end,
			},
			stripe = { SetShown = function() end },
			text = {
				SetText = function(self, text)
					self.shown = text
				end,
				SetTextColor = function() end,
			},
			amountBox = { SetText = function() end, SetTextColor = function() end },
			removeButton = {},
			cells = {
				reputation = {
					text = { SetText = function() end, SetTextColor = function() end, SetShown = function() end },
					dash = { SetShown = function() end, SetColorTexture = function() end },
					GetHighlightTexture = function() end,
				},
			},
			columnSerial = 1,
		}
		for _, method in ipairs({ "SetParent", "Hide", "Show", "ClearAllPoints", "SetPoint", "SetSize" }) do
			frame[method] = function() end
		end
		return frame
	end
	ns.restockColumnWidthSerial = 1
	ns.restockRowHeight = 20
	ns.restockHiddenFrame = {}
	ns.restockRowPool = { row(), row(), row(), row() }
	ns.restockWindow = {
		scrollChild = {
			GetWidth = function()
				return 400
			end,
			SetHeight = function() end,
		},
		scrollFrame = { SetVerticalScroll = function() end },
		IsShown = function()
			return true
		end,
	}
	function ns.RefreshRestockColumnHeader() end
	-- The start of a redraw closes the bag menu (Restocker-Window-Bag-Menu.lua), which is never open here.
	function ns.CloseRestockBagMenu() end
	-- The macro rebuild a redraw requests (Core.lua), for Use Restock List Food & Water Last.
	function ns.RequestUpdate() end
	ns.db = { profile = {} }
	-- The end of a redraw: the empty list's panel (Restocker-Window.lua) and the status line (Restocker-Window-Footer.lua).
	function ns.UpdateRestockEmptyState() end
	function ns.UpdateRestockStatus() end
	local groups = {}
	function ns.UpdateRestockGroupPane(_, view)
		groups = {}
		for item, group in pairs(view.groups) do
			groups[item.itemID] = group
		end
	end

	ns.restockSettings = { currentList = "Test", lists = { Test = {} } }

	local s = {
		ns = ns,
		settings = ns.restockSettings,
		list = ns.restockSettings.lists.Test,
		calls = calls,
		printed = printed,
	}

	function s.resolve(...)
		for _, itemID in ipairs({ ... }) do
			resolved[itemID] = true
		end
	end

	function s.registered()
		return registered.GET_ITEM_INFO_RECEIVED == true
	end

	-- The server answers the given queries, or every query so far; returns how many the handler heard.
	function s.deliver(...)
		local answered = { ... }
		if #answered == 0 then
			for itemID in pairs(queued) do
				answered[#answered + 1] = itemID
			end
			table.sort(answered)
		end
		local heard = 0
		for _, itemID in ipairs(answered) do
			queued[itemID] = nil
			resolved[itemID] = true
			if registered.GET_ITEM_INFO_RECEIVED then
				heard = heard + 1
				ns.restockerEventHandlers.GET_ITEM_INFO_RECEIVED(itemID, true)
			end
		end
		return heard
	end

	-- The window's real redraw; returns what each drawn row shows, by itemID.
	function s.redraw()
		ns.UpdateRestockList()
		local drawn = {}
		for _, frame in ipairs(ns.restockRowPool) do
			if frame.isInUse then
				drawn[frame.item.itemID] =
					{ icon = frame.icon.texture, group = groups[frame.item.itemID], name = frame.text.shown }
			end
		end
		return drawn
	end

	return s
end

--------------------------------------------------------------------------------

print("1. The report: a cold row drawn in the open window gets its icon the moment the answer lands")
local s = session()
s.list[21177] = { itemID = 21177, itemName = "Symbol of Kings", itemType = "Reagent", amount = 100 }
s.list[6948] = { itemID = 6948, itemName = "Hearthstone", amount = 1 } -- a line saved without a type
local drawn = s.redraw()
check("drawn while cold", drawn[21177].icon, QUESTION_MARK)
check("the open window listens for its rows", s.registered(), true)
check("both answers heard", s.deliver(), 2)
local function rowOf(itemID)
	for _, frame in ipairs(s.ns.restockRowPool) do
		if frame.isInUse and frame.item.itemID == itemID then
			return frame
		end
	end
end
check("repainted in place, with no redraw", rowOf(21177).icon.texture, "icon:21177")
check("and the event let go", s.registered(), false)
drawn = s.redraw()
check("the untyped line files under its real type", drawn[6948].group, "Miscellaneous")

print("2. A cold row removed and typed back in by id is added, and nothing stays subscribed")
s = session()
s.list[1179] = { itemID = 1179, itemName = "Ice Cold Milk", itemType = "Consumable", amount = 20 }
s.redraw()
s.list[1179] = nil
s.redraw()
check("a row gone from the list is no longer watched", s.registered(), false)
s.ns.AddRestockItem("1179")
s.deliver()
check("Ice Cold Milk added", s.list[1179] and s.list[1179].itemName, "Ice Cold Milk")
check("nothing left parked", s.ns.restockItemWait[1179], nil)
check("event released", s.registered(), false)

print("3. Login: the catch-up upgrade goes through after the inflate asked about its target")
s = session(20)
for _, recipe in ipairs(s.ns.POISON_RECIPES) do
	s.resolve(recipe[1])
	for _, reagent in ipairs(recipe[2]) do
		s.resolve(reagent[1])
	end
end
s.resolve(5530)
s.settings.currentList = "Warrior"
s.settings.lists = {
	Warrior = { [1179] = "Consumable, Ice Cold Milk, 20, 1, 1, 1, 0, 1, 0" },
	Mage = { [1205] = "Consumable, Melon Juice, 60, 1, 1, 1, 0, 1, 0" }, -- an alt already on the next tier
	Rogue = { [5530] = "20, 1, 1, 1, 0, 1, 0" }, -- a line saved without a name
}
-- PLAYER_LOGIN, in ns.InitializeRestocker's order.
s.ns.InflateSavedRestockItems(s.settings)
s.ns.SyncRestockItemInfoSubscription()
s.ns.SetupCraftingRecipes()
check("every recipe known, so nothing holds the event through the load", s.registered(), false)
check("answers heard during the load", s.deliver(), 0)
-- PLAYER_ENTERING_WORLD
s.ns.UpgradeRestockList()
local warrior = s.settings.lists.Warrior
check("upgraded to Melon Juice", warrior[1205] and warrior[1205].itemName, "Melon Juice")
check("Ice Cold Milk moved off", warrior[1179], nil)
check("nothing pending", s.ns.HasPendingUpgrade(), false)
check("event released", s.registered(), false)
check("a warm line saved without a name is named", s.settings.lists.Rogue[5530].itemName, "Blinding Powder")

print("4. While something waits, a cold item is asked about once, not at every answer")
s = session(20)
s.resolve(1179)
s.list[1179] = { itemID = 1179, itemName = "Ice Cold Milk", itemType = "Consumable", amount = 20 }
s.ns.UpgradeRestockList()
check("Melon Juice cold, so the upgrade waits", s.ns.HasPendingUpgrade() and s.registered(), true)
s.calls[1205] = 0
local others = {}
for itemID = 90001, 90050 do
	C_Item.GetItemInfo(itemID) -- other items the client is asked about during the login
	others[#others + 1] = itemID
end
check("fifty unrelated answers heard", s.deliver(table.unpack(others)), 50)
check("Melon Juice asked about at most once", s.calls[1205] <= 1, true)
check("still waiting on it", s.ns.HasPendingUpgrade(), true)

print("5. An item asked about while something waits still arrives when its answer is heard")
s = session(20)
s.resolve(1179)
s.list[1179] = { itemID = 1179, itemName = "Ice Cold Milk", itemType = "Consumable", amount = 20 }
s.ns.UpgradeRestockList()
s.ns.AddRestockItem("21177")
check("both answers heard", s.deliver(), 2)
check("Symbol of Kings added", s.list[21177] and s.list[21177].itemName, "Symbol of Kings")
check("Melon Juice upgrade done", s.list[1205] and s.list[1205].itemName, "Melon Juice")
check("event released", s.registered(), false)

print("6. The last waiter letting go drops what was remembered while it waited")
s = session(20)
s.resolve(1179)
s.list[1179] = { itemID = 1179, itemName = "Ice Cold Milk", itemType = "Consumable", amount = 20 }
s.list[21177] = { itemID = 21177, itemName = "Symbol of Kings", itemType = "Reagent", amount = 100 }
s.ns.UpgradeRestockList()
-- A redraw with the window shut, so the upgrade is the only waiter.
s.ns.restockWindow.IsShown = function()
	return false
end
drawn = s.redraw()
check("Symbol of Kings drawn cold while the upgrade waits", drawn[21177].icon, QUESTION_MARK)
check("the upgrade's answer heard", s.deliver(1205), 1)
check("upgrade done", s.list[1205] ~= nil, true)
check("event released", s.registered(), false)
check("Symbol of Kings' answer lands after", s.deliver(21177), 0)
drawn = s.redraw()
check("icon on the next redraw", drawn[21177].icon, "icon:21177")

print("7. Add-box input that names no item is dropped, not parked, and holds nothing registered")
s = session()
s.ns.AddRestockItem("")
check("an empty box parks nothing", next(s.ns.restockItemWait), nil)
check("an empty box leaves the event unregistered", s.registered(), false)
s.ns.AddRestockItem("   ")
check("an empty or blank box says nothing", s.printed[1], nil)
s.ns.AddRestockItem("not an item")
check("blank and unparseable text park nothing", next(s.ns.restockItemWait), nil)
check("the event is still unregistered", s.registered(), false)
check("unparseable text is told what the box takes", s.printed[1], "RESTOCKER_ADD_NOT_FOUND")
s.ns.AddRestockItem("21177")
check("a cold id still parks", s.ns.restockItemWait[21177], true)
check("and holds the event while it waits", s.registered(), true)
check("its answer is heard", s.deliver(), 1)
check("Symbol of Kings added", s.list[21177] and s.list[21177].itemName, "Symbol of Kings")
check("event released", s.registered(), false)

print("8. A typed id the client has no item for is refused, not parked")
s = session()
s.ns.AddRestockItem("999999")
check("nothing parked", next(s.ns.restockItemWait), nil)
check("the event stays unregistered", s.registered(), false)
check("the player is told", s.printed[1], "RESTOCKER_UNKNOWN_ITEM")

print("9. A poison row with no saved name still orders its reagents: recipes are found by item ID")
s = session()
s.resolve(8924, 8925) -- Dust of Deterioration and Crystal Vial; the poison itself stays cold
C_Item.GetItemCount = function()
	return 0
end
s.settings.currentList = "Rogue"
s.settings.lists = { Rogue = { [8928] = { itemID = 8928, itemName = "", amount = 2 } } }
s.ns.SetupCraftingRecipes()
local order = s.ns.BuildCraftingPurchaseOrder()
check("Dust of Deterioration for two Instant Poison VI", order["Item 8924"], 8)
check("Crystal Vial for two Instant Poison VI", order["Item 8925"], 2)

print("10. A row shows the client's name for its item, not the name saved with it")
s = session()
s.resolve(1179)
s.list[1179] = { itemID = 1179, itemName = "Eiskalte Milch", itemType = "Consumable", amount = 20 }
check("the client's name", s.redraw()[1179].name, "Ice Cold Milk")
check("written onto the row, so the filter and sort read it too", s.list[1179].itemName, "Ice Cold Milk")

print("")
if failures == 0 then
	print("ALL COLD ITEM SCENARIOS PASSED")
else
	print(("%d COLD ITEM CHECK(S) FAILED"):format(failures))
	os.exit(1)
end
