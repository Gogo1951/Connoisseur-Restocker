-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the staples pop-up's stack counts (no WoW client needed).

    Run it with:   lua Tests/Restocker-Starter-List-Test.lua        (from Features/Restocker/)

    Like the upgrade test, this does NOT model the feature. Every scenario loads the REAL
    enUS strings, ladders, category rows, Restocker-Starter-List.lua and the pop-up that
    draws it, the options helpers' icon checkbox (Options-Utilities.lua), plus the item memo
    (Item-Cache.lua) and the GET_ITEM_INFO_RECEIVED handler
    (Restocker-List.lua). Only the client is simulated: C_Item.GetItemInfo answers for an item
    once it has resolved, asking about any other item queues a server query, and deliver()
    answers the queue, firing GET_ITEM_INFO_RECEIVED only while the event is registered,
    which is all a real frame hears.

    THE BUG THIS PINS DOWN. The builder measured a stack in constants per category, 20 for
    every class reagent, so "1 Stack" of Symbol of Divinity put 20 on a paladin's list: four
    bag slots of an item that stacks to 5. A stack is now whatever the item reports.
    Scenario 1 is that report. Scenarios 2-5 are sizes that broke the same way (Symbol of
    Kings stacks to 100) or differ by client (Ankh and Rune of Teleportation are bigger on
    TBC), which no table of constants could get right on both.

    Scenario 9 pins a second bug found beside it. The memo remembered a miss until
    GET_ITEM_INFO_RECEIVED was heard, and the event is only registered while something is
    waiting on it. The login route's warm-up and every checkbox tooltip asked the memo
    about cold staples, so the answers arrived unheard and the misses were never
    forgotten: ticking such a row afterwards parked it in pendingStarterAdds for good, the
    box ticked and nothing added. Restocker-Cold-Item-Test.lua pins the memo's own fix.

    Scenario 11 pins the intro. The login trigger writes the class's pre-ticked staples
    onto the list just before the window opens, so a builder that asked the list whether it
    was empty greeted a new character with the line meant for a list that already had items.
    It also pins the words: one paragraph from the Pick Staples button, and the way back in
    as a second at login.

    Scenario 12 pins the names. Poison and reagent rows carry no strings of their own: each
    is named by the client -- a poison type for its ladder's first item, any other row for the
    item a tick adds -- shows loading text until that item resolves, and sorts by the name.

    Scenario 13 pins the window's shape: the sections in their order, Water as the last cell
    of the food grid, one set of cell widths from the first section to the last, each row's
    icon, and the /crs hint kept for the login route.

    Scenario 14 pins the icon checkbox a staple row is drawn with: the stock one under a name
    of its own, its label a gap off its icon wherever the stock code would have put it back
    against it.

    Scenario 15 pins what the pop-up does to the frame the dialog hands it: drawn in to the
    height of its rows, up to a cap, over a solid fill that sits in the strata under it, and
    both handed back when the frame hides.
]]

local ROOT = arg[1] or "../.."

-- The items these scenarios resolve: { name, item type }.
local ITEMS = {
	[8766] = { "Morning Glory Dew", "Consumable" },
	[8950] = { "Homemade Cherry Pie", "Consumable" },
	[6265] = { "Soul Shard", "Reagent" },
	[6948] = { "Hearthstone", "Miscellaneous" },
	[17030] = { "Ankh", "Reagent" },
	[17031] = { "Rune of Teleportation", "Reagent" },
	[17033] = { "Symbol of Divinity", "Reagent" },
	[21177] = { "Symbol of Kings", "Reagent" },
	[2892] = { "Deadly Poison", "Consumable" },
	[3775] = { "Crippling Poison", "Consumable" },
	[5237] = { "Mind-numbing Poison", "Consumable" },
	[6947] = { "Instant Poison", "Consumable" },
	[8928] = { "Instant Poison VI", "Consumable" },
	[10918] = { "Wound Poison", "Consumable" },
	[17034] = { "Maple Seed", "Reagent" },
	[17038] = { "Ironwood Seed", "Reagent" },
	[5060] = { "Thieves' Tools", "Miscellaneous" },
	[5140] = { "Flash Powder", "Reagent" },
	[5530] = { "Blinding Powder", "Reagent" },
}

--[[
    Max stack by client, from each item's Wowhead tooltip on classic and tbc; the poison and
    seed rows, which only the Era scenarios ask about, from the Classic Era item table.
]]
local STACKS = {
	era = {
		[8766] = 20,
		[8950] = 20,
		[6265] = 1,
		[6948] = 1,
		[17030] = 5,
		[17031] = 10,
		[17033] = 5,
		[21177] = 100,
		[2892] = 20,
		[3775] = 20,
		[5237] = 20,
		[6947] = 20,
		[8928] = 20,
		[10918] = 20,
		[17034] = 20,
		[17038] = 20,
		[5060] = 1,
		[5140] = 20,
		[5530] = 20,
	},
	tbc = {
		[8766] = 20,
		[8950] = 20,
		[6265] = 1,
		[6948] = 1,
		[17030] = 10,
		[17031] = 20,
		[17033] = 5,
		[21177] = 100,
	},
}
local FOLDER = { era = "Vanilla", tbc = "TBC" }

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
    memo, the pending adds and the pop-up's caches are all file locals, so a scenario
    only starts clean by reloading them.
]]
local function session(classToken, level, client, noStockCheckBox)
	client = client or "era"
	local resolved, queued, registered, warmed = {}, {}, {}, {}
	local ns = {}

	C_Item = {
		GetItemInfo = function(itemID)
			local item = ITEMS[itemID]
			if not (item and resolved[itemID]) then
				queued[itemID] = true
				return nil
			end
			local link = "|cffffffff|Hitem:" .. itemID .. "|h[" .. item[1] .. "]|h|r"
			return item[1], link, 1, 1, 1, item[2], "", STACKS[client][itemID]
		end,
		-- The icon comes off the client's own item table, so it answers for a cold item too.
		GetItemIconByID = function(itemID)
			return "icon:" .. itemID
		end,
	}
	function UnitLevel()
		return level
	end
	function UnitClass()
		return classToken, classToken
	end
	function InCombatLockdown()
		return false
	end
	-- The client's table-emptying global.
	function wipe(target)
		for key in pairs(target) do
			target[key] = nil
		end
		return target
	end
	-- A timer is kept, not run: s.nextFrame() is the frame after.
	local timers = {}
	C_Timer = {
		After = function(_, callback)
			timers[#timers + 1] = callback
		end,
	}

	--[[
	    The frames the pop-up touches once the dialog has built its window: the host it is
	    handed, and the fill and the checkbox it hangs on that host. A frame here is only what
	    the pop-up sets on it, kept to be read back. A frame takes its parent's strata when it
	    is parented, as in the client, which is what makes the order of those two calls matter.
	]]
	local created = {}
	local function frame(kind, parent)
		local new = { kind = kind, parent = parent, shown = true, points = {}, hooks = {} }
		function new:SetParent(to)
			self.parent = to
			self.strata, self.level = to.strata, (to.level or 0) + 1
		end
		function new:GetParent()
			return self.parent
		end
		function new:ClearAllPoints()
			self.points = {}
		end
		function new:SetPoint(point, _, _, x, y)
			self.points[point] = (x or 0) .. "," .. (y or 0)
		end
		function new:SetFrameStrata(strata)
			self.strata = strata
		end
		function new:GetFrameStrata()
			return self.strata
		end
		function new:SetFrameLevel(frameLevel)
			self.level = frameLevel
		end
		function new:GetFrameLevel()
			return self.level
		end
		function new:Show()
			self.shown = true
		end
		function new:Hide()
			if self.shown then
				self.shown = false
				for _, hook in ipairs(self.hooks) do
					hook(self)
				end
			end
		end
		function new:HookScript(_, handler)
			self.hooks[#self.hooks + 1] = handler
		end
		function new:SetSize() end
		function new:SetScript() end
		function new:SetChecked() end
		function new.CreateTexture()
			local texture = {}
			function texture.SetAllPoints() end
			function texture.SetColorTexture(_, r, g, b, a)
				new.fill = table.concat({ r, g, b, a }, " ")
			end
			return texture
		end
		function new.CreateFontString()
			local fontString = {}
			function fontString.SetPoint() end
			function fontString.SetText() end
			return fontString
		end
		return new
	end
	UIParent = frame("Frame")
	function CreateFrame(kind, _, parent)
		created[kind] = frame(kind, parent)
		return created[kind]
	end

	--[[
	    The AceGUI Frame widget the dialog builds the window in, pooled and handed back on
	    every Open: its host frame, where AceGUI puts every such frame, and the scroll
	    container that is its one child, whose content is as tall as the rows laid out in it.
	]]
	local host = frame("Frame", UIParent)
	host.strata, host.level = "FULLSCREEN_DIALOG", 100
	host.backdropInfo = { insets = { left = 8, right = 8, top = 8, bottom = 8 } }
	local contentHeight = 300
	local window = {
		frame = host,
		children = { {
			content = {
				GetHeight = function()
					return contentHeight
				end,
			},
		} },
	}
	function window:EnableResize(enabled)
		self.resizable = enabled
	end
	function window:SetHeight(height)
		self.height = height
	end

	-- AceLocale hands enUS its table; AceConfigDialog builds the window on Open, as the real one does.
	local L = {}
	local opened -- the build the last Open drew
	local status = {} -- the dialog's status table for the window, which every repaint reopens it from
	local dialog = { OpenFrames = {} }
	function dialog.SetDefaultSize(_, _, width, height)
		status.defaultSize = width .. "x" .. height
	end
	function dialog.GetStatusTable()
		return status
	end
	function dialog:Open(registryName)
		opened = ns.BuildStarterListPopupOptions()
		self.OpenFrames[registryName] = window
		host:Show()
	end

	--[[
	    AceGUI's widget registry, holding the stock checkbox as far as its label goes: where
	    AceGUI's own code anchors it, and when. With an image the label hangs a pixel off it;
	    a press nudges it a pixel right and down, and the release puts it back.
	]]
	local aceGUI = { WidgetRegistry = {} }
	local function stockCheckBox()
		local texture
		local stock = { type = "CheckBox", frame = frame("Button") }
		stock.frame.obj = stock
		stock.image = {
			GetTexture = function()
				return texture
			end,
		}
		stock.text = {
			SetPoint = function(_, _, to, _, x, y)
				stock.label = (to == stock.image and "image" or "box") .. " " .. (x or 0) .. " " .. (y or 0)
			end,
		}
		local function align(nudge)
			if texture then
				stock.text:SetPoint("LEFT", stock.image, "RIGHT", 1 + nudge, -nudge)
			else
				stock.text:SetPoint("LEFT", stock.checkbg, "RIGHT", nudge, -nudge)
			end
		end
		function stock:SetImage(path)
			texture = path
			align(0)
		end
		-- The stock handlers first, then whatever was hooked behind them.
		local function mouse(nudge)
			if not stock.disabled then
				align(nudge)
			end
			for _, hook in ipairs(stock.frame.hooks) do
				if hook.script == (nudge == 1 and "OnMouseDown" or "OnMouseUp") then
					hook.handler(stock.frame)
				end
			end
		end
		function stock.frame:HookScript(script, handler)
			self.hooks[#self.hooks + 1] = { script = script, handler = handler }
		end
		function stock.press()
			mouse(1)
		end
		function stock.release()
			mouse(0)
		end
		return stock
	end
	-- noStockCheckBox: an AceGUI with no checkbox registered, which the add-on must survive.
	if not noStockCheckBox then
		aceGUI.WidgetRegistry.CheckBox = stockCheckBox
	end
	function aceGUI:RegisterWidgetType(name, constructor)
		self.WidgetRegistry[name] = constructor
	end

	function LibStub(name)
		if name == "AceLocale-3.0" then
			return {
				NewLocale = function()
					return L
				end,
				GetLocale = function()
					return L
				end,
			}
		end
		if name == "AceGUI-3.0" then
			return aceGUI
		end
		return dialog
	end

	function ns.SetEventRegistered(event, enabled)
		registered[event] = enabled or nil
	end
	function ns.UpdateRestockList() end
	-- The Restock List window the login route opens behind the pop-up, counted.
	local restockWindowShown = 0
	function ns.ShowRestockWindow()
		restockWindowShown = restockWindowShown + 1
	end
	function ns.SetupRestockerTooltip() end
	-- Whether Escape would close the Restock List window (Restocker-Window.lua), as last set.
	local windowClosesOnEscape = true
	function ns.SetRestockWindowClosesOnEscape(closes)
		windowClosesOnEscape = closes
	end
	-- The icon-to-name gap of a Restock List row, from Restocker-Window-Columns.lua.
	ns.RESTOCK_ICON_TEXT_GAP = 4
	function ns.GetCharacterKey()
		return "Tester - Realm"
	end
	ns.pendingRecipes = {}
	-- MIGRATION (remove after 2026-10-18): the Blinding Powder name wait, which Restocker-Saved-Migration-Test covers.
	function ns.NameBlindingPowderRows()
		return false
	end
	ns.restockerLoaded = true
	ns.restockSettings = { currentList = "Test", lists = { Test = {} }, starterListDismissed = {} }

	function ns.GetColor()
		return ""
	end

	local function loadAddonFile(path)
		-- Add-on files are chunks taking (addonName, ns) as varargs, the way WoW loads them.
		return assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
	end
	loadAddonFile("Locales/enUS.lua")
	ns.L = L
	loadAddonFile("Data/Data.lua")
	loadAddonFile("Features/Item-Cache.lua")

	--[[
	    Options-Utilities.lua is loaded for the icon checkbox it registers. The row helpers
	    the pop-up also takes from it are then swapped for plain ones, so a layout reads as
	    the text it was given, and the warmer for one that only remembers what it was handed.
	]]
	loadAddonFile("Options/Options-Utilities.lua")
	function ns.OptionsHeader(text, order)
		return { type = "header", name = text, order = order }
	end
	function ns.OptionsDesc(text, order)
		return { type = "description", name = text, order = order }
	end
	function ns.OptionsSpacer(order)
		return { type = "description", name = " ", order = order }
	end
	function ns.WarmItemCache(itemIDs)
		for _, itemID in ipairs(itemIDs) do
			warmed[itemID] = true
		end
	end
	loadAddonFile("Data/" .. FOLDER[client] .. "/Consumable-Upgrade-Paths-" .. FOLDER[client] .. ".lua")
	loadAddonFile("Features/Restocker/Restocker-Upgrade.lua")
	loadAddonFile("Features/Restocker/Restocker-List.lua")
	loadAddonFile("Features/Restocker/Restocker-Starter-List.lua")
	loadAddonFile("Options/Options-Starter-List-Popup.lua")

	-- The real ClearRestockNewItems (Restocker-List.lua), counted: a closing window calls it once.
	local newFlagsCleared = 0
	local ClearRestockNewItems = ns.ClearRestockNewItems
	function ns.ClearRestockNewItems()
		newFlagsCleared = newFlagsCleared + 1
		ClearRestockNewItems()
	end

	-- Core's dispatcher, reduced to the one event in play.
	ns.restockerEventHandlers = { GET_ITEM_INFO_RECEIVED = ns.OnRestockerItemInfoReceived }

	local s = { ns = ns, L = L, list = ns.restockSettings.lists.Test, warmed = warmed }
	function s.restockWindowShown()
		return restockWindowShown
	end
	s.host, s.window, s.status, s.created = host, window, status, created

	-- How tall the rows the dialog laid out came to.
	function s.rowsCameTo(height)
		contentHeight = height
	end

	-- The frame after: every timer set so far runs.
	function s.nextFrame()
		local due = timers
		timers = {}
		for _, callback in ipairs(due) do
			callback()
		end
	end

	function s.windowClosesOnEscape()
		return windowClosesOnEscape
	end

	-- How many times a closing window has retired the list's New flags.
	function s.newFlagsCleared()
		return newFlagsCleared
	end

	-- An icon checkbox as AceGUI would build one, or nil where the type was never registered.
	function s.newIconCheckBox(typeName)
		local constructor = aceGUI.WidgetRegistry[typeName]
		return constructor and constructor()
	end

	function s.resolve(...)
		for _, itemID in ipairs({ ... }) do
			resolved[itemID] = true
		end
	end

	-- The server answers every query so far; returns how many answers the handler heard.
	function s.deliver()
		local answered = {}
		for itemID in pairs(queued) do
			answered[#answered + 1] = itemID
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

	-- One staple's checkbox and stacks dropdown, from a fresh build of the window.
	function s.controls(key)
		for _, option in pairs(ns.BuildStarterListPopupOptions().args) do
			if option.type == "group" and option.args["toggle" .. key] then
				return option.args["toggle" .. key], option.args["stacks" .. key]
			end
		end
		error("no staple " .. key)
	end

	-- The given staples' keys in the order a fresh build of the window shows them.
	function s.order(keys)
		local wanted = {}
		for _, key in ipairs(keys) do
			wanted[key] = true
		end
		local rows = {}
		for _, option in pairs(ns.BuildStarterListPopupOptions().args) do
			if option.type == "group" then
				rows[#rows + 1] = option
			end
		end
		table.sort(rows, function(a, b)
			return a.order < b.order
		end)
		local shown = {}
		for _, row in ipairs(rows) do
			local toggles = {}
			for name, control in pairs(row.args) do
				local key = name:match("^toggle(.+)$")
				if key and wanted[key] then
					toggles[#toggles + 1] = { key = key, order = control.order }
				end
			end
			table.sort(toggles, function(a, b)
				return a.order < b.order
			end)
			for _, toggle in ipairs(toggles) do
				shown[#shown + 1] = toggle.key
			end
		end
		return table.concat(shown, ",")
	end

	function s.amount(itemID)
		return s.list[itemID] and s.list[itemID].amount
	end

	--[[
	    A fresh build of the window, top to bottom, one word per widget: a heading by its
	    text, a row by the staples in it, anything else by its kind. A blank description is
	    the line break the sections are spaced with.
	]]
	function s.layout()
		local widgets = {}
		for key, option in pairs(ns.BuildStarterListPopupOptions().args) do
			widgets[#widgets + 1] = { key = key, option = option }
		end
		table.sort(widgets, function(a, b)
			return a.option.order < b.option.order
		end)
		local words = {}
		for index, widget in ipairs(widgets) do
			local option = widget.option
			if option.type == "header" then
				words[index] = "[" .. option.name .. "]"
			elseif option.type == "group" then
				local cells = {}
				for name, control in pairs(option.args) do
					local key = name:match("^toggle(.+)$")
					if key then
						cells[#cells + 1] = { key = key, order = control.order }
					end
				end
				table.sort(cells, function(a, b)
					return a.order < b.order
				end)
				for cell = 1, #cells do
					cells[cell] = cells[cell].key
				end
				words[index] = table.concat(cells, "+")
			elseif option.name == " " then
				words[index] = "-"
			else
				words[index] = widget.key
			end
		end
		return table.concat(words, " ")
	end

	-- The distinct widths a fresh build gives its checkboxes beside a dropdown, its lone checkboxes, and its dropdowns.
	function s.cellWidths()
		local seen = { paired = {}, alone = {}, stacks = {} }
		for _, option in pairs(ns.BuildStarterListPopupOptions().args) do
			if option.type == "group" then
				for name, control in pairs(option.args) do
					local key = name:match("^toggle(.+)$")
					if key then
						seen[option.args["stacks" .. key] and "paired" or "alone"][control.width] = true
					elseif name:match("^stacks") then
						seen.stacks[control.width] = true
					end
				end
			end
		end
		local function list(widths)
			local sorted = {}
			for width in pairs(widths) do
				sorted[#sorted + 1] = width
			end
			table.sort(sorted)
			return table.concat(sorted, ",")
		end
		return list(seen.paired), list(seen.alone), list(seen.stacks)
	end

	-- Whether the window the last Open drew carries the given text in its intro.
	function s.introSays(text)
		return opened ~= nil and opened.args.descIntro.name:find(text, 1, true) ~= nil
	end

	-- Whether the window the last Open drew leads with the given intro line.
	function s.openedWithIntro(key)
		return opened ~= nil and opened.args.descIntro.name:find(L[key], 1, true) == 1
	end

	-- The intro the last Open drew, as it is written.
	function s.intro()
		return opened.args.descIntro.name
	end

	return s
end

--------------------------------------------------------------------------------

print("1. The report: 1 Stack of Symbol of Divinity is 5, not 20")
local s = session("PALADIN", 60)
s.resolve(17033)
local toggle, stacks = s.controls("divinitysymbol")
check("dropdown opens on", stacks.get(), 1)
toggle.set(nil, true)
check("amount", s.amount(17033), 5)
check("dropdown tooltip", stacks.desc(), s.L["STARTER_POPUP_STACKS_DESCRIPTION"]:format(5))
check(
	"checkbox tooltip",
	toggle.desc(),
	s.L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"]:format("|cffffffff|Hitem:17033|hSymbol of Divinity|h|r", 5)
)

print("2. Symbol of Kings stacks to 100, and a count picked before the tick scales by it")
s = session("PALADIN", 60)
s.resolve(21177)
toggle, stacks = s.controls("kingssymbol")
stacks.set(nil, 3)
check("picking a count adds the staple", toggle.get(), true)
check("amount", s.amount(21177), 300)

print("3. Food keeps its 20")
s = session("PALADIN", 60)
s.resolve(8950)
s.controls("bread").set(nil, true)
check("Homemade Cherry Pie", s.amount(8950), 20)

print("4. The size is the client's: Ankh and Rune of Teleportation are bigger on TBC")
for _, client in ipairs({ "era", "tbc" }) do
	s = session("SHAMAN", 60, client)
	s.resolve(17030)
	s.controls("ankh").set(nil, true)
	check(client .. " Ankh", s.amount(17030), STACKS[client][17030])

	s = session("MAGE", 60, client)
	s.resolve(17031)
	s.controls("teleportrunes").set(nil, true)
	check(client .. " Rune of Teleportation", s.amount(17031), STACKS[client][17031])
end

print("5. A listed entry reads and writes in its own item's stacks")
s = session("PALADIN", 60)
s.resolve(21177, 17033)
s.list[21177] = { itemID = 21177, amount = 200 }
s.list[17033] = { itemID = 17033, amount = 12 }
local _, kings = s.controls("kingssymbol")
local _, divinity = s.controls("divinitysymbol")
check("200 Symbols of Kings read as", kings.get(), 2)
check("a hand-edited 12 Symbols of Divinity round to", divinity.get(), 2)
kings.set(nil, 4)
check("4 stacks of Kings write", s.amount(21177), 400)
divinity.set(nil, 3)
check("3 stacks of Divinity write", s.amount(17033), 15)

print("6. Soul Shards count shards, whatever a stack would be")
s = session("WARLOCK", 60)
s.resolve(6265)
_, stacks = s.controls("soulshards")
check("offers bare counts", stacks.values[28], "28")
check("opens on", stacks.get(), 20)
check("tooltip", stacks.desc(), s.L["STARTER_POPUP_COUNT_DESCRIPTION"])
stacks.set(nil, 28)
check("28 shards", s.amount(6265), 28)
s.list[6265].amount = 30
check("a hand-edited 30 reads as", stacks.get(), 32)

print("7. A fixed amount stays fixed")
s = session("PALADIN", 60)
s.resolve(6948)
s.controls("hearthstone").set(nil, true)
check("Hearthstone", s.amount(6948), 1)

print("8. A cold item: the window warms it and says so, and a tick waits for the answer")
s = session("PALADIN", 60)
toggle, stacks = s.controls("kingssymbol")
local loading = s.L["LOADING_ITEM"]:format(21177) .. "|r"
check("handed to the warmer", s.warmed[21177], true)
check("checkbox tooltip", toggle.desc(), loading)
check("dropdown tooltip", stacks.desc(), loading)
toggle.set(nil, true)
check("no row before the answer", s.list[21177], nil)
check("box reads ticked meanwhile", toggle.get(), true)
check("answer heard", s.deliver() > 0, true)
check("amount once resolved", s.amount(21177), 100)
check("dropdown tooltip once resolved", stacks.desc(), s.L["STARTER_POPUP_STACKS_DESCRIPTION"]:format(100))

print("9. A tooltip hovered, then a tick after the answer landed unheard, still adds")
s = session("PALADIN", 60)
s.resolve(8950, 8766) -- the pre-ticked pie and dew are already in bags, so nothing waits
s.ns.MaybeShowStarterListPopup()
check("defaults added", s.amount(8950) ~= nil and s.amount(8766) ~= nil, true)
toggle = s.controls("kingssymbol")
toggle.desc()
check("nothing was listening", s.deliver(), 0)
toggle.set(nil, true)
s.deliver()
check("Symbol of Kings added", s.amount(21177), 100)
check("nothing left pending", s.ns.HasPendingStarterAdds(), false)

print("10. A listed entry whose item has not resolved takes no guessed write")
s = session("PALADIN", 60)
s.list[21177] = { itemID = 21177, amount = 200 }
_, kings = s.controls("kingssymbol")
check("reads as the opening offer", kings.get(), 1)
kings.set(nil, 3)
check("amount untouched", s.amount(21177), 200)
check("reads as the choice meanwhile", kings.get(), 3)
s.resolve(21177)
check("reads the entry once resolved", kings.get(), 2)

print("11. The login route opens on the empty-list intro, even after its pre-ticks land")
s = session("PALADIN", 60)
s.resolve(8950, 8766) -- the pre-ticked pie and dew resolve, so both land before the window opens
s.ns.MaybeShowStarterListPopup()
check("pre-ticks already on the list", s.amount(8950) ~= nil and s.amount(8766) ~= nil, true)
check("the Restock List window opens behind it", s.restockWindowShown(), 1)
check("login route leads with the empty-list intro", s.openedWithIntro("STARTER_POPUP_INTRO_EMPTY"), true)
check(
	"what a check does follows in the same paragraph, and the way back in is a second",
	s.intro(),
	"Your Restock List is empty, so let's add some items to get you started. "
		.. "Anything you check is automatically restocked whenever you open a merchant or your bank. "
		.. "Commodity items upgrade themselves as you level, so you'll always have the best available."
		.. "\n\nYou can always adjust this list, or add more items later, by typing /crs|r.|r"
)
s.ns.ShowStarterListPopup()
check("the Pick Staples button over the same list", s.openedWithIntro("STARTER_POPUP_INTRO_STOCKED"), true)
check("which opens from inside that window, so leaves it be", s.restockWindowShown(), 1)
check(
	"which is one paragraph, word for word",
	s.intro(),
	"Pick the staples you want kept stocked. "
		.. "Anything you check is automatically restocked whenever you open a merchant or your bank. "
		.. "Commodity items upgrade themselves as you level, so you'll always have the best available.|r"
)

print("12. Poison and reagent rows are named by the client, and sort by that name")
s = session("ROGUE", 60)
local instant = s.controls("instant")
check("a cold name shows loading text", instant.name(), s.L["LOADING_ITEM"]:format(6947) .. "|r")
check("the first item is handed to the warmer", s.warmed[6947], true)
check("so is the item a tick adds", s.warmed[8928], true)
s.resolve(6947)
check("named for the ladder's first item", instant.name(), "Instant Poison")
local POISONS = { "crippling", "deadly", "instant", "mindnumbing", "wound" }
check("named rows first, cold ones by item ID", s.order(POISONS), "instant,deadly,crippling,mindnumbing,wound")
s.resolve(2892, 3775, 5237, 10918)
check("then A to Z by name", s.order(POISONS), "crippling,deadly,instant,mindnumbing,wound")

s = session("DRUID", 60)
s.resolve(17038)
check("a reagent ladder is named for what a tick adds", s.controls("seeds").name(), "Ironwood Seed")
s = session("DRUID", 20)
s.resolve(17034)
check("which follows the character's level", s.controls("seeds").name(), "Maple Seed")

print("13. One grid from the first section to the last, and each row wears its item's icon")
s = session("ROGUE", 60)
s.resolve(6947, 2892, 3775, 5237, 10918, 5060, 5140, 5530, 6948)
check(
	"the sections in order, Water the food grid's last cell, a line break around each",
	s.layout(),
	"descIntro - [Food & Water] - bread+cheese fish+fruit fungus+meat water - "
		.. "[Poisons] - descPoisonsNote - crippling+deadly instant+mindnumbing wound - "
		.. "[Ammo] - arrows+bullets - "
		.. "[Reagents & Tools] - blindingpowder+flashpowder hearthstone+thievestools -"
)
local paired, alone, dropdowns = s.cellWidths()
check("every checkbox beside a dropdown is one width", paired, "1.1")
check("every dropdown is one width", dropdowns, "0.65")
check("a staple with no dropdown spans the pair", alone, "1.75")
toggle = s.controls("bread")
check("a food row wears the icon of the item a tick adds", toggle.image(), "icon:8950")
check("cropped to lose the stock border", table.concat(toggle.imageCoords, " "), "0.08 0.92 0.08 0.92")
check("a poison row wears its own tier's", s.controls("instant").image(), "icon:8928")
s = session("WARRIOR", 60)
check(
	"a class with no section of its own: food and water, ammo, then the Hearthstone",
	s.layout(),
	"descIntro - [Food & Water] - bread+cheese fish+fruit fungus+meat water - "
		.. "[Ammo] - arrows+bullets - [Reagents & Tools] - hearthstone -"
)
s.resolve(8950, 8766)
s.ns.ShowStarterListPopup()
check("from the Pick Staples button the intro leaves /crs out", s.introSays(s.L["RESTOCKER_COMMAND"]), false)
s = session("WARRIOR", 60)
s.resolve(8950)
s.ns.MaybeShowStarterListPopup()
check("at login it says the way back in", s.introSays(s.L["RESTOCKER_COMMAND"]), true)

print("14. A staple row's name stands a gap off its icon, through a press and back")
s = session("WARRIOR", 60)
local iconCheckBox = s.controls("bread").dialogControl
check("a staple's checkbox is the options' icon checkbox", iconCheckBox, "Consumable-Connoisseur_IconCheckBox")
check("and the Hearthstone's, which has no dropdown", s.controls("hearthstone").dialogControl, iconCheckBox)
local box = s.newIconCheckBox(iconCheckBox)
check("built by the stock constructor, under its own name", box.type, iconCheckBox)
box:SetImage("icon:8950")
check("the name stands the list rows' gap off the icon", box.label, "image 4 0")
box.press()
check("a press nudges it from there", box.label, "image 5 -1")
box.release()
check("and the release puts it back", box.label, "image 4 0")
box.disabled = true
box.press()
check("a disabled row does not move", box.label, "image 4 0")
box.disabled = false
box:SetImage(nil)
check("with no icon it is the stock checkbox's label", box.label, "box 0 0")
box.press()
check("through a press", box.label, "box 1 -1")
box.release()
check("and back", box.label, "box 0 0")
s = session("WARRIOR", 60, "era", true)
check("with no stock checkbox to build on, the type's name is cleared", s.ns.ICON_CHECKBOX_WIDGET_TYPE, nil)
check("and a staple asks for no control of its own", s.controls("bread").dialogControl, nil)
check("while keeping its icon", s.controls("bread").image(), "icon:8950")

print("15. The window is drawn in to its rows, over a solid fill")
s = session("WARRIOR", 60)
s.rowsCameTo(300)
s.ns.ShowStarterListPopup()
check("opens at its cap, for the rows to be laid out in", s.status.defaultSize, "690x640")
check("then takes the rows' height and the frame's own title and footer", s.window.height, 371)
check("which every repaint reopens it at", s.status.height, 371)
check("and cannot be dragged bigger", s.window.resizable, false)
s.rowsCameTo(312)
s.nextFrame()
check("fitted again a frame later, once wrapped lines have settled", s.window.height, 383)
local fill = s.created.Frame
check("the fill is solid black", fill.fill, "0 0 0 1")
check("hung on the host", fill:GetParent() == s.host, true)
check("in the strata under it, whatever its parent gave it", fill:GetFrameStrata(), "FULLSCREEN")
check("inside the host backdrop's insets", fill.points.TOPLEFT .. " " .. fill.points.BOTTOMRIGHT, "8,-8 -8,8")
check("and showing", fill.shown, true)
check("the don't-show-again checkbox rides the same host", s.created.CheckButton:GetParent() == s.host, true)
check("Escape closes this window alone while it is open", s.windowClosesOnEscape(), false)
s.host:Hide()
check("closing hands the fill back, hidden", fill:GetParent() == UIParent and not fill.shown, true)
check("and the checkbox", s.created.CheckButton:GetParent() == UIParent and not s.created.CheckButton.shown, true)
check("and retires the list's New flags", s.newFlagsCleared(), 1)
check("and hands Escape back to the Restock List window", s.windowClosesOnEscape(), true)
s.rowsCameTo(500)
s.nextFrame()
check("a timer that outlives the window fits nothing", s.window.height, 383)
s.host:Show()
s.host:Hide()
check("the pooled frame hiding for some other window clears nothing", s.newFlagsCleared(), 1)
s.ns.ShowStarterListPopup()
check("opened again, the rows fit as they are now", s.window.height, 571)
check("the same fill is hung again", s.created.Frame == fill and fill:GetParent() == s.host and fill.shown, true)
check("and the hide hook is not stacked", #s.host.hooks, 1)
s.host:Hide()
check("so one close retires the flags once", s.newFlagsCleared(), 2)
s.rowsCameTo(900)
s.ns.ShowStarterListPopup()
check("more rows than the cap holds keep the cap, and scroll", s.window.height, 640)
s.host:Hide()
s.host.backdropInfo = { edgeSize = 1 }
s.ns.ShowStarterListPopup()
check(
	"a skin's flat backdrop, with no insets, is filled edge to edge",
	fill.points.TOPLEFT .. " " .. fill.points.BOTTOMRIGHT,
	"0,0 0,0"
)
s.host:Hide()
s.host.backdropInfo = nil
s.ns.ShowStarterListPopup()
check(
	"a host with no backdrop to read takes the stock insets",
	fill.points.TOPLEFT .. " " .. fill.points.BOTTOMRIGHT,
	"8,-8 -8,8"
)
s.host:Hide()
s.host.strata, s.host.level = "BACKGROUND", 3
s.ns.ShowStarterListPopup()
check("a host in the lowest strata keeps the fill there", fill:GetFrameStrata(), "BACKGROUND")
check("a level under it", fill:GetFrameLevel(), 2)

print("")
if failures == 0 then
	print("ALL STARTER LIST SCENARIOS PASSED")
else
	print(("%d STARTER LIST CHECK(S) FAILED"):format(failures))
	os.exit(1)
end
