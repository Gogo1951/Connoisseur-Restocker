-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the Restock List window (no WoW client needed).

    Run it with:   lua Tests/Restocker-Window-Test.lua        (from Features/Restocker/)

    Like the Starter List test, this does NOT model the feature. Every scenario builds the
    REAL window from the real files -- Restocker-Window.lua and its Columns, Filter, Rows,
    Categories, List-Bar, Bag-Menu and Footer parts, over the real list code, bag scan, grocery
    list, ladders and enUS strings -- and then drives it the way a player does: it clicks the
    buttons the window created, types in its boxes, hovers its cells and picks from its menus.
    Only the client is simulated: a frame is a table whose state (its scripts, its text, its
    color, whether it is shown) is kept beside it, the bags are a table of counts, and an
    AceGUI pullout is a list of entries that can be picked.

    The widget mock is strict on purpose. It answers the methods the window is known to call
    and raises on any other, so a misspelt method fails here rather than in the client, where
    it would take the whole window down at login.

    What each scenario pins:

      1. The row's shape: the Keep box hangs off the first column and the name stops at the
         Keep box, which is what puts the number beside the item it belongs to.
      2. The yellow Keep mark follows the bags, bags only, and follows them live. It is
         never the red an error is drawn in.
      3. The status line says what the reminders say, and says it three ways: orders
         outstanding, in the Keep marks' own yellow; no orders while a Buy-off row is still
         short; and fully stocked.
      4. The orders tooltip lists what the mini-map's Restocker Report lists, capped.
      5. Rep rides on Buy, and draws a dash rather than the word "Any".
      6. A cell that cannot be set says why, and a one-tier ladder cannot upgrade.
      7. A column heading sets its column for the rows shown, and only those.
      8. Remove can be undone, once, until the list changes, from a button and not a word.
      9. An empty list shows its invitation instead of an empty grid.
     10. The list bar names the list's characters, each in its class color, and Manage
         Lists renames, copies and starts lists.
     11. Delete lands the character on the top list and says so first, names who else loses
         the list, and makes a list only when it deleted the last one.
     12. An item dropped anywhere on the window is added, never aimed at what is under it:
         a row, a heading, a category, the control row, the list bar or the status line.
     13. An add that fails says why in the add box, or in chat with the window closed.
     14. Pick Staples leaves the window open.
     15. One menu at a time, and none outlives the window.
     16. Add Item from Bags lists what the bags hold that the list lacks, and a pick adds it.
     17. On Forever a character is its first name and surname, everywhere it is named or kept.
     18. A double-click on Remove takes off one row, not also the one that moves up under it.
     19. The filter lets go of the keyboard on Enter, and the add box after a drop.
]]

local ROOT = arg[1] or "../.."

-- The add-on is written for the client's Lua 5.1; a newer interpreter has moved unpack.
unpack = unpack or table.unpack

-- The items these scenarios name: { name, item type, max stack }.
local ITEMS = {
	[4306] = { "Silk Cloth", "Trade Goods", 20 },
	[6948] = { "Hearthstone", "Miscellaneous", 1 },
	[8766] = { "Morning Glory Dew", "Consumable", 20 },
	[8950] = { "Homemade Cherry Pie", "Consumable", 20 },
	[12840] = { "Minion's Scourgestone", "Quest", 250 },
	[13444] = { "Major Mana Potion", "Consumable", 5 },
	[13928] = { "Grilled Squid", "Consumable", 20 },
	[14530] = { "Heavy Runecloth Bandage", "Consumable", 20 },
}

local failures = 0

local function check(label, got, want)
	if got == want then
		print(("  ok    %s = %s"):format(label, tostring(got)))
	else
		failures = failures + 1
		print(("  FAIL  %s: got %s, want %s"):format(label, tostring(got), tostring(want)))
	end
end

-- Text as the player reads it, without its color escapes.
local function plain(text)
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
end

--------------------------------------------------------------------------------
-- Widgets
--------------------------------------------------------------------------------

--[[
    What the mock remembers about each widget, kept BESIDE the widget rather than on it:
    the window's own code hangs fields on its frames (frame.text is a row's name string,
    frame.width its saved width), and a mock that kept its state under the same names would
    be reading the add-on's fields back as its own.
]]
local state = setmetatable({}, { __mode = "k" })

-- Widget methods the window calls that have nothing to remember: accepted and ignored.
local IGNORED = {}
for name in
	([[
	EnableKeyboard EnableMouse EnableMouseWheel HighlightText RegisterForDrag SetAllPoints SetAlpha
	SetAutoFocus SetClampedToScreen SetCursorPosition SetFrameStrata
	SetHighlightFontObject SetJustifyH SetMovable SetNormalFontObject SetNormalTexture SetNumeric
	SetPushedTexture SetResizable SetResizeBounds SetTexCoord SetTextInsets SetTexture
	SetVertexColor SetWordWrap StartMoving StartSizing StopMovingOrSizing
]]):gmatch("%S+")
do
	IGNORED[name] = true
end

local focus -- the edit box holding the keyboard

local function fire(widget, script, ...)
	local handler = state[widget].scripts[script]
	if handler then
		return handler(widget, ...)
	end
end

local methods = {}
local WidgetMeta = {
	__index = function(_, key)
		if methods[key] then
			return methods[key]
		end
		if IGNORED[key] then
			return function() end
		end
		-- The add-on's own fields are lower case; an upper-case miss is a method the client may lack too.
		if type(key) == "string" and key:match("^%u") then
			error("the widget mock has no method " .. key, 2)
		end
	end,
}

local function widget(kind, parent)
	local new = setmetatable({}, WidgetMeta)
	state[new] = { kind = kind, parent = parent, scripts = {}, points = {}, shown = true, width = 0, height = 0 }
	return new
end

function methods:SetScript(name, handler)
	state[self].scripts[name] = handler
end
function methods:Show()
	if not state[self].shown then
		state[self].shown = true
		fire(self, "OnShow")
	end
end
function methods:Hide()
	if state[self].shown then
		state[self].shown = false
		-- A hidden edit box cannot keep the keyboard, as in the client.
		if focus == self then
			self:ClearFocus()
		end
		fire(self, "OnHide")
	end
end
function methods:SetShown(shown)
	if shown then
		self:Show()
	else
		self:Hide()
	end
end
function methods:IsShown()
	return state[self].shown
end
function methods:SetParent(parent)
	state[self].parent = parent
end
function methods:GetParent()
	return state[self].parent
end
function methods:SetText(text)
	state[self].text = text
	if state[self].fontString then
		state[state[self].fontString].text = text
	end
	-- The client reports a scripted change too, which is what the window's placeholders rely on.
	if state[self].kind == "EditBox" then
		fire(self, "OnTextChanged", false)
	end
end
function methods:GetText()
	return state[self].text or (state[self].kind == "EditBox" and "" or nil)
end
function methods:SetTextColor(r, g, b)
	state[self].tone = { r = r, g = g, b = b }
end
function methods:GetTextColor()
	local tone = state[self].tone or { r = 0.5, g = 0.5, b = 0.5 }
	return tone.r, tone.g, tone.b, 1
end
-- Six pixels a character: enough that every measured width resolves to something.
function methods:GetStringWidth()
	return #(state[self].text or "") * 6
end
function methods:GetStringHeight()
	return 12
end
function methods:SetWidth(width)
	state[self].width = width
end
function methods:GetWidth()
	return state[self].width
end
function methods:SetHeight(height)
	state[self].height = height
end
function methods:GetHeight()
	return state[self].height
end
function methods:SetSize(width, height)
	state[self].width, state[self].height = width, height
end
function methods:SetPoint(...)
	local points = state[self].points
	points[#points + 1] = { ... }
end
function methods:ClearAllPoints()
	state[self].points = {}
end
function methods:GetNumPoints()
	return #state[self].points
end
function methods:GetPoint(index)
	return unpack(state[self].points[index] or {})
end
function methods:CreateFontString(_, _, fontObject)
	local new = widget("FontString", self)
	state[new].font = fontObject
	return new
end
-- The font a string is drawn in, which is all that tells a hint from a value.
function methods:SetFontObject(fontObject)
	state[self].font = fontObject
end
function methods:CreateTexture()
	return widget("Texture", self)
end
function methods:SetColorTexture(r, g, b)
	state[self].color = { r = r, g = g, b = b }
end
function methods:SetHighlightTexture()
	state[self].highlight = state[self].highlight or widget("Texture", self)
end
function methods:GetHighlightTexture()
	return state[self].highlight
end
function methods:GetFontString()
	if not state[self].fontString then
		state[self].fontString = widget("FontString", self)
		state[state[self].fontString].text = state[self].text
	end
	return state[self].fontString
end
function methods:SetScrollChild(child)
	state[self].scrollChild = child
end
function methods:GetScrollChild()
	return state[self].scrollChild
end
function methods:SetVerticalScroll(offset)
	state[self].scroll = offset
end
function methods:GetVerticalScroll()
	return state[self].scroll or 0
end
function methods:SetFocus()
	if focus and focus ~= self then
		focus:ClearFocus()
	end
	focus = self
	fire(self, "OnEditFocusGained")
end
function methods:ClearFocus()
	if focus == self then
		focus = nil
		fire(self, "OnEditFocusLost")
	end
end

-- What a widget shows, for the checks below.
local function shown(target)
	return state[target].shown
end
local function text(target)
	return state[target].text
end
local function font(target)
	return state[target].font
end
-- The frame a widget's given anchor point is hung from.
local function anchor(target, index)
	return state[target].points[index][2]
end
-- Is the widget's text in the red an add notice is drawn in? It has a low green.
local function isRed(target)
	return state[target].tone.g < 0.5
end
-- A widget's text color as the hex it was chosen as, which is how Data/Data.lua keeps the window's colors.
local function toneHex(target)
	local tone = state[target].tone
	return ("%02X%02X%02X"):format(
		math.floor(tone.r * 255 + 0.5),
		math.floor(tone.g * 255 + 0.5),
		math.floor(tone.b * 255 + 0.5)
	)
end
-- The template a frame was created from, which is what draws a button as a button.
local function template(target)
	return state[target].template
end

--------------------------------------------------------------------------------
-- The Session
--------------------------------------------------------------------------------

--[[
    One login: a fresh namespace with every file loaded again, the window built, and
    Mossbark's list on screen. The window's menus, its undo and its notices are all file
    locals, so a scenario only starts clean by reloading them.
]]
local function session(opts)
	opts = opts or {}
	local ns = {}
	local bags, printed, pullouts = {}, {}, {}
	local cursor, popup
	local staplesOpened, bankStops = 0, 0
	focus = nil

	--[[
	    A character's name as this client gives it. On Forever (opts.forever) each has a
	    surname, which the client hands back apart from the first name; everywhere else the
	    three globals behind that do not exist, and are cleared here because globals outlive
	    a session.
	]]
	local SURNAMES =
		{ Mossbark = "Greenleaf", Thornhoof = "Oakheart", Fernwhisper = "Dawnmist", Coinpurse = "Goldweigh" }
	local function nameOf(first)
		return opts.forever and (first .. " " .. SURNAMES[first]) or first
	end
	if opts.forever then
		function RegionalUniqueNamesEnabled()
			return true
		end
		function UnitNameUnmodified()
			return "Mossbark", SURNAMES.Mossbark
		end
		Constants = { CharacterNameSeparatorConsts = { CHARACTERNAME_SURNAME_SEPARATOR = " " } }
	else
		RegionalUniqueNamesEnabled, UnitNameUnmodified, Constants = nil, nil, nil
	end

	function CreateFrame(kind, _, parent, templateName)
		local frame = widget(kind, parent)
		state[frame].template = templateName
		if templateName == "BasicFrameTemplate" then
			frame.TitleBg = widget("Texture", frame)
		end
		return frame
	end
	UIParent = widget("Frame")
	UISpecialFrames = {}
	ITEM_QUALITY_COLORS = { [1] = { r = 1, g = 1, b = 1 } }
	YES, NO, CANCEL = "Yes", "No", "Cancel"

	-- The tooltip remembers its lines: a title or a line is a string, a double line a pair.
	GameTooltip = { lines = {} }
	function GameTooltip:SetOwner()
		self.lines = {}
	end
	function GameTooltip:SetText(line)
		self.lines = { line }
	end
	function GameTooltip:AddLine(line)
		self.lines[#self.lines + 1] = line
	end
	function GameTooltip:AddDoubleLine(left, right)
		self.lines[#self.lines + 1] = { left, right }
	end
	function GameTooltip:SetHyperlink(link)
		self.lines = { link }
	end
	function GameTooltip:Show() end
	function GameTooltip:Hide()
		self.lines = {}
	end

	-- Every item is resolved; IDs from 900000 up stand in for a typo, with no item behind them.
	local function itemOf(itemID)
		return ITEMS[itemID] or { "Item " .. itemID, "Trade Goods", 20 }
	end
	local function linkOf(itemID)
		return "|cffffffff|Hitem:" .. itemID .. "|h[" .. itemOf(itemID)[1] .. "]|h|r"
	end
	C_Item = {
		DoesItemExistByID = function(itemID)
			return itemID < 900000
		end,
		GetItemInfo = function(request)
			local itemID = type(request) == "number" and request or tonumber(tostring(request):match("item:(%d+)"))
			if not itemID then
				-- Text naming no item the client knows.
				return nil
			end
			local item = itemOf(itemID)
			return item[1], linkOf(itemID), 1, 1, 1, item[2], "", item[3], "", "icon:" .. itemID, 0
		end,
		GetItemIconByID = function(itemID)
			return "icon:" .. itemID
		end,
		GetItemCount = function(itemID)
			return bags[itemID] or 0
		end,
	}
	--[[
	    The bags as containers: everything sits in the backpack, one slot to an item, in
	    itemID order so a scan reads the same every time.
	]]
	BACKPACK_CONTAINER, BANK_CONTAINER, NUM_BAG_SLOTS = 0, -1, 4
	local function backpack()
		local slots = {}
		for itemID, count in pairs(bags) do
			if count > 0 then
				slots[#slots + 1] = itemID
			end
		end
		table.sort(slots)
		return slots
	end
	C_Container = {
		GetContainerNumSlots = function(bagID)
			return bagID == BACKPACK_CONTAINER and #backpack() or 0
		end,
		GetContainerItemInfo = function(bagID, slot)
			local itemID = bagID == BACKPACK_CONTAINER and backpack()[slot]
			if itemID then
				return {
					itemID = itemID,
					stackCount = bags[itemID],
					hyperlink = linkOf(itemID),
					iconFileID = "icon:" .. itemID,
					isLocked = false,
				}
			end
		end,
	}
	function GetCursorInfo()
		if cursor then
			return "item", cursor, linkOf(cursor)
		end
	end
	function ClearCursor()
		cursor = nil
	end
	function UnitClass()
		return "Druid", "DRUID"
	end
	function UnitName()
		return "Mossbark"
	end
	function GetRealmName()
		return "Whitemane"
	end
	function UnitLevel()
		return 60
	end
	-- The client's clock, which stands still until a scenario lets time pass (s.wait).
	local clock = 0
	function GetTime()
		return clock
	end
	function wipe(t)
		for key in pairs(t) do
			t[key] = nil
		end
		return t
	end
	function CopyTable(source)
		local copy = {}
		for key, value in pairs(source) do
			copy[key] = type(value) == "table" and CopyTable(value) or value
		end
		return copy
	end

	StaticPopupDialogs = {}
	function StaticPopup_Show(which, message, _, data)
		popup = { which = which, text = message, data = data }
	end

	--[[
	    AceGUI's pullout and its items, as far as the window uses them. Clear lets go of the
	    items it held, as the real one releases them, so an entry picked from a menu that has
	    since been rebuilt no longer knows its pullout.
	]]
	local function newPullout()
		local pullout = { items = {}, callbacks = {}, open = false, slider = {} }
		-- The scroll bar, which the bag menu winds back to the top on every open.
		function pullout.slider:SetValue(value)
			pullout.scroll = value
		end
		function pullout:SetMaxHeight() end
		function pullout:SetCallback(name, handler)
			self.callbacks[name] = handler
		end
		function pullout:Clear()
			for _, item in ipairs(self.items) do
				item.pullout = nil
			end
			self.items = {}
		end
		function pullout:AddItem(item)
			self.items[#self.items + 1] = item
			item.pullout = self
		end
		function pullout:SetWidth() end
		function pullout:Open()
			self.open = true
		end
		function pullout:Close()
			self.open = false
			if self.callbacks.OnClose then
				self.callbacks.OnClose()
			end
		end
		pullouts[#pullouts + 1] = pullout
		return pullout
	end
	local function newItem(kind)
		local item = { kind = kind, callbacks = {} }
		function item:SetText(label)
			self.text = label
		end
		function item:SetValue(value)
			self.value = value
		end
		function item:SetCallback(name, handler)
			self.callbacks[name] = handler
		end
		function item:SetDisabled(disabled)
			self.disabled = disabled
		end
		return item
	end
	local AceGUI = {
		Create = function(_, kind)
			if kind == "Dropdown-Pullout" then
				return newPullout()
			end
			return newItem(kind)
		end,
		Release = function(_, released)
			released.open = false
		end,
	}

	local L = {}
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
		return AceGUI
	end

	-- What the window's files take from the rest of the add-on.
	function ns.PrintMessage(message)
		printed[#printed + 1] = message
	end
	function ns.SetEventRegistered() end
	-- The macro rebuild a redraw requests (Core.lua), for Use Restock List Food & Water Last.
	function ns.RequestUpdate() end
	function ns.HasPendingStarterAdds()
		return false
	end
	-- MIGRATION (remove after 2026-10-18): the Blinding Powder name wait, which Restocker-Saved-Migration-Test covers.
	function ns.NameBlindingPowderRows()
		return false
	end
	function ns.ShowStarterListPopup()
		staplesOpened = staplesOpened + 1
	end
	-- The bank run (Restocker-Bank.lua), which a delete of the list in use abandons.
	function ns.StopBankRestock()
		bankStops = bankStops + 1
	end
	ns.pendingRecipes = {}

	local function loadAddonFile(path)
		-- Add-on files are chunks taking (addonName, ns) as varargs, the way WoW loads them.
		return assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
	end
	loadAddonFile("Locales/enUS.lua")
	loadAddonFile("Data/Data.lua")
	loadAddonFile("Features/Utilities.lua")
	loadAddonFile("Features/Item-Cache.lua")
	loadAddonFile("Data/Vanilla/Consumable-Upgrade-Paths-Vanilla.lua")
	loadAddonFile("Features/Restocker/Restocker-List.lua")
	loadAddonFile("Features/Restocker/Restocker-Saved-Lists.lua")
	loadAddonFile("Features/Restocker/Restocker-Bags.lua")
	loadAddonFile("Features/Restocker/Restocker-Merchant.lua")
	loadAddonFile("Features/Restocker/Restocker-Upgrade.lua")
	loadAddonFile("Features/Restocker/Restocker-Window.lua")
	loadAddonFile("Features/Restocker/Restocker-Window-Columns.lua")
	loadAddonFile("Features/Restocker/Restocker-Window-Filter.lua")
	loadAddonFile("Features/Restocker/Restocker-Window-Rows.lua")
	loadAddonFile("Features/Restocker/Restocker-Window-Categories.lua")
	loadAddonFile("Features/Restocker/Restocker-Window-List-Bar.lua")
	loadAddonFile("Features/Restocker/Restocker-Window-Bag-Menu.lua")
	loadAddonFile("Features/Restocker/Restocker-Window-Footer.lua")
	loadAddonFile("Features/Restocker/Restocker-Reminders.lua")
	-- Before the settings below: this file puts an empty table in their place as it loads.
	loadAddonFile("Features/Restocker/Restocker-Events.lua")

	-- A row as ns.AddRestockItem writes one, with the given Keep amount and any flags to change.
	local function row(itemID, keep, flags)
		local item = itemOf(itemID)
		local entry = {
			itemID = itemID,
			itemName = item[1],
			itemType = item[2],
			amount = keep,
			buyFromMerchant = true,
			stashToBank = true,
			restockFromBank = true,
		}
		for key, value in pairs(flags or {}) do
			entry[key] = value
		end
		return entry
	end

	--[[
	    Mossbark's setup: "Druid (2)", shared with Thornhoof, beside a "Druid" another druid
	    uses and a "Bank" list that belongs to a character on another realm.

	    The Inventory Report's records are where a logged-out character's class comes from.
	    Thornhoof and Coinpurse have logged in on a build that keeps one; Fernwhisper has not.
	]]
	ns.db = {
		global = {
			inventory = {
				[nameOf("Thornhoof") .. "-Whitemane"] = {
					name = nameOf("Thornhoof"),
					realm = "Whitemane",
					class = "DRUID",
				},
				[nameOf("Coinpurse") .. "-OldBlanchy"] = {
					name = nameOf("Coinpurse"),
					realm = "Old Blanchy",
					class = "MAGE",
				},
			},
		},
		sv = { profileKeys = {}, profiles = {} },
	}
	--[[
	    Each character is on a profile of its own, named as AceDB names the character, and
	    the profile holds the list it uses.
	]]
	local function profileNameOf(first, realm)
		return opts.forever and nameOf(first) or (first .. " - " .. realm)
	end
	local function addCharacter(first, realm, listName)
		local profileName = profileNameOf(first, realm)
		ns.db.sv.profileKeys[profileName] = profileName
		ns.db.sv.profiles[profileName] = { restockList = listName }
		return ns.db.sv.profiles[profileName]
	end
	ns.db.profile = addCharacter("Mossbark", "Whitemane", "Druid (2)")
	ns.db.keys = { char = profileNameOf("Mossbark", "Whitemane") }
	addCharacter("Thornhoof", "Whitemane", "Druid (2)")
	addCharacter("Fernwhisper", "Whitemane", "Druid")
	addCharacter("Coinpurse", "Old Blanchy", "Bank")
	ns.restockSettings = {
		currentList = "Druid (2)",
		lists = {
			["Bank"] = { [12840] = row(12840, 0) },
			["Druid"] = { [8766] = row(8766, 20) },
			["Druid (2)"] = {
				[6948] = row(6948, 1),
				[8766] = row(8766, 40),
				[8950] = row(8950, 40),
				[12840] = row(12840, 0),
				[13444] = row(13444, 10),
				[13928] = row(13928, 20, { buyFromMerchant = false }),
			},
		},
		framePosition = {},
	}
	ns.restockRowPool = {}
	ns.restockCategoryRowPool = {}
	ns.restockHiddenFrame = CreateFrame("Frame")
	ns.restockerLoaded = true
	ns.InitRestockerEvents()
	ns.InitRestockBagDefinitions()

	-- Bags: the Hearthstone, a full 40 water, 22 of 40 pies, 4 of 10 potions, 6 of 20 squid.
	bags[6948], bags[8766], bags[8950], bags[13444], bags[13928] = 1, 40, 22, 4, 6

	local window = ns.CreateRestockWindow()
	ns.ShowRestockWindow()

	local s = {
		ns = ns,
		L = L,
		window = window,
		settings = ns.restockSettings,
		bags = bags,
		printed = printed,
		row = row,
	}

	function s.list()
		return ns.restockSettings.lists[ns.restockSettings.currentList]
	end

	s.addCharacter = addCharacter

	-- The profile a character is on, which holds the list it uses.
	function s.profileOf(first, realm)
		return ns.db.sv.profiles[profileNameOf(first, realm or "Whitemane")]
	end

	-- The drawn row holding an item; raises when the view is not showing it.
	function s.rowOf(itemID)
		for _, frame in ipairs(ns.restockRowPool) do
			if frame.isInUse and frame.item.itemID == itemID then
				return frame
			end
		end
		error("no row is drawn for item " .. itemID, 2)
	end

	function s.shownCount()
		local count = 0
		for _, frame in ipairs(ns.restockRowPool) do
			if frame.isInUse then
				count = count + 1
			end
		end
		return count
	end

	-- BAG_UPDATE_DELAYED, as Core's dispatcher hands it on.
	function s.bagsChanged()
		ns.restockerEventHandlers.BAG_UPDATE_DELAYED()
	end

	function s.click(target)
		fire(target, "OnClick", "LeftButton")
	end

	-- What a hover draws: the tooltip's lines, a double line flattened to "left | right".
	function s.hover(target)
		GameTooltip.lines = {}
		fire(target, "OnEnter")
		local lines = {}
		for index, line in ipairs(GameTooltip.lines) do
			lines[index] = plain(type(line) == "table" and (line[1] .. " | " .. line[2]) or line)
		end
		fire(target, "OnLeave")
		return lines
	end

	-- Is the row's Keep number in the yellow that marks a short amount?
	function s.keepIsMarked(itemID)
		return toneHex(s.rowOf(itemID).amountBox) == ns.RESTOCKER_WINDOW_COLORS.KEEP_SHORT
	end

	-- The status line as it is written, colors and all.
	function s.statusWritten()
		return text(window.footer.statusText)
	end

	-- A cell as the player reads it: "on", "off", "na", or the standing the Rep cell names.
	function s.cell(itemID, key)
		local cell = s.rowOf(itemID).cells[key]
		if cell.text and shown(cell.text) then
			return text(cell.text)
		end
		if cell.check and shown(cell.check) then
			return "on"
		end
		return cell.isActive and "off" or "na"
	end

	function s.status()
		return plain(text(window.footer.statusText))
	end

	-- The one pullout that is open, or nil; two open at once is itself a failure.
	function s.menu()
		local open
		for _, pullout in ipairs(pullouts) do
			if pullout.open then
				assert(not open, "two menus are open at once")
				open = pullout
			end
		end
		return open
	end

	-- The open menu's entries, top to bottom, rules left out.
	function s.menuTexts()
		local texts = {}
		for _, item in ipairs(s.menu().items) do
			if item.kind ~= "Dropdown-Item-Separator" then
				texts[#texts + 1] = plain(item.text)
			end
		end
		return table.concat(texts, " / ")
	end

	--[[
	    Pick the open menu's entry whose text starts with the given words, running what
	    the real item runs: an Execute fires OnClick and then closes whatever pullout still
	    holds it, a Toggle fires OnValueChanged and leaves closing to its handler.
	]]
	function s.pick(label)
		for _, item in ipairs(s.menu().items) do
			if item.text and item.text:sub(1, #label) == label then
				if item.kind == "Dropdown-Item-Toggle" then
					item.value = not item.value
					item.callbacks.OnValueChanged(item, "OnValueChanged", item.value)
				elseif not item.disabled then
					item.callbacks.OnClick(item, "OnClick")
					if item.pullout then
						item.pullout:Close()
					end
				end
				return
			end
		end
		error("the open menu has no entry " .. label, 2)
	end

	-- One entry of the open menu as it is written, colors and all: the one starting with the given words.
	function s.menuEntry(label)
		for _, item in ipairs(s.menu().items) do
			if item.text and item.text:sub(1, #label) == label then
				return item.text
			end
		end
		error("the open menu has no entry " .. label, 2)
	end

	function s.pickUp(itemID)
		cursor = itemID
	end

	function s.wait(seconds)
		clock = clock + seconds
	end

	function s.holding()
		return cursor
	end

	function s.staplesOpened()
		return staplesOpened
	end

	function s.bankStops()
		return bankStops
	end

	-- Every list's name, in the selector's order.
	function s.listNames()
		return table.concat(ns.GetRestockListNames(), ", ")
	end

	function s.popupText()
		return plain(popup.text)
	end

	-- The same text as it is written, colors and all.
	function s.popupWritten()
		return popup.text
	end

	function s.acceptPopup()
		StaticPopupDialogs[popup.which].OnAccept(nil, popup.data)
	end

	-- Type into a box as the keyboard would: the text lands, then the box hears about it.
	function s.type(box, typed)
		state[box].text = typed
		fire(box, "OnTextChanged", true)
		fire(box, "OnKeyUp")
	end

	return s
end

--------------------------------------------------------------------------------

print("1. The Keep box sits beside the name, ahead of the columns")
local s = session()
local pie = s.rowOf(8950)
local header = s.ns.restockColumnHeader
check("six rows drawn", s.shownCount(), 6)
check("the first column is Take", pie.firstCell, pie.cells.withdraw)
check("the Keep box hangs off it", anchor(pie.amountBox, 1), pie.firstCell)
check("the name stops at the Keep box", anchor(pie.text, 2), pie.amountBox)
check("the columns walk in from the remove control", anchor(pie.cells.upgrade, 1), pie.removeButton)
check("the heading reads", s.L["RESTOCKER_COLUMN_AMOUNT"], "Keep")
local keepTip = s.hover(pie.amountBox)
check("the box's tooltip is its title", keepTip[1], "Keep in Your Bags")
check("and what the number means, the yellow mark included", keepTip[3], s.L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"])
check("with no line asking for Enter, which the box never needed", #keepTip, 3)
check(
	"the heading carries the same tooltip",
	table.concat(s.hover(header.amountCaption), "|"),
	table.concat(keepTip, "|")
)
check("and hangs off the header's own first column", anchor(header.amountCaption, 1), header.cells.withdraw)
check("the title bar names the list", text(s.window.title), "Connoisseur Restock List")

print("2. The Keep number is yellow while the bags hold fewer, and follows the bags")
check("22 of 40 pies is short", s.keepIsMarked(8950), true)
check("which is not an error, so not red", isRed(s.rowOf(8950).amountBox), false)
check("40 of 40 water is not", s.keepIsMarked(8766), false)
check("a Keep of 0 asks for nothing", s.keepIsMarked(12840), false)
check("short with Buy off is still short", s.keepIsMarked(13928), true)
s.bags[8950] = 40
s.bagsChanged()
check("the bags filling clears the mark", s.keepIsMarked(8950), false)
s.window:Hide()
s.bags[8950] = 22
s.bagsChanged()
s.window:Show()
check("a closed window catches up on the way back in", s.keepIsMarked(8950), true)
s.type(s.rowOf(8950).amountBox, "20")
check("typing a Keep the bags already hold clears it", s.keepIsMarked(8950), false)
check("and the amount is live", s.list()[8950].amount, 20)

print("3. The status line counts restocking orders, in the reminders' words")
s = session()
local MARKED = "|cff" .. s.ns.RESTOCKER_WINDOW_COLORS.KEEP_SHORT
check("pies and potions", s.status(), "2 restocking orders outstanding.")
check("in the yellow of the Keep marks it counts", s.statusWritten(), MARKED .. "2 restocking orders outstanding.|r")
s.bags[8950] = 40
s.bagsChanged()
check("potions", s.status(), "1 restocking order outstanding.")
s.bags[13444] = 10
s.bagsChanged()
check("none, but the squid is short with Buy off", s.status(), "No restocking orders outstanding.")
check("which is said plainly, with no color of its own", s.statusWritten(), "No restocking orders outstanding.")
s.click(s.rowOf(13928).cells.buy)
check("switching its Buy on makes it an order", s.status(), "1 restocking order outstanding.")
check("and the line yellow again", s.statusWritten():sub(1, #MARKED), MARKED)
s.bags[13928] = 20
s.bagsChanged()
check("nothing short at all", s.status(), "Congratulations, you're fully stocked up!")
check("in the green of a thing that is on", s.statusWritten():sub(1, 10), s.ns.GetColor("ON"))

print("4. Hovering the count lists the orders, like the mini-map's Restocker Report, capped at 20")
s = session()
local lines = s.hover(s.window.footer.status)
check("the report's title", lines[1], "Restocker Report")
check(
	"the first order, by icon and bare name",
	lines[2],
	"|Ticon:8950:14:14|t |Hitem:8950|hHomemade Cherry Pie|h | 22/40"
)
check("the second", lines[3], "|Ticon:13444:14:14|t |Hitem:13444|hMajor Mana Potion|h | 4/10")
check("and no more", lines[4], nil)
for itemID = 50001, 50025 do
	s.list()[itemID] = s.row(itemID, 5)
end
s.ns.UpdateRestockList()
check("27 orders", s.status(), "27 restocking orders outstanding.")
lines = s.hover(s.window.footer.status)
check("a title and 20 rows, then a closing line", #lines, 22)
check("which counts the rest", lines[22], "and 7 more")
for itemID in pairs(s.list()) do
	s.bags[itemID] = 1000
end
s.bagsChanged()
check("nothing outstanding draws no tooltip", #s.hover(s.window.footer.status), 0)

print("5. Rep draws a dash for no standing, names one that is set, and rides on Buy")
s = session()
check("no standing", s.cell(8950, "reputation"), "off")
s.click(s.rowOf(8950).cells.reputation)
check(
	"the standings menu",
	s.menuTexts(),
	"Required Reputation / Any / Friendly (5% off) / Honored (10% off) / Revered (15% off) / Exalted (20% off)"
)
s.pick("Honored")
check("the cell names the standing", s.cell(8950, "reputation"), "Honored")
check("and the menu is gone", s.menu(), nil)
s.click(s.rowOf(8950).cells.buy)
check("with Buy off it is not applicable", s.cell(8950, "reputation"), "na")
s.click(s.rowOf(8950).cells.reputation)
check("and opens no menu", s.menu(), nil)
check("but keeps the standing", s.list()[8950].reaction, 6)
s.click(s.rowOf(8950).cells.buy)
check("which shows again with Buy back on", s.cell(8950, "reputation"), "Honored")

print("6. A cell that cannot be set says why")
s = session()
check("Extra with Buy off", s.cell(13928, "extra"), "na")
check("says so", s.hover(s.rowOf(13928).cells.extra)[3], s.L["RESTOCKER_EXTRA_NOT_APPLICABLE"])
check("so does Rep", s.hover(s.rowOf(13928).cells.reputation)[3], s.L["RESTOCKER_REPUTATION_NOT_APPLICABLE"])
check("Extra with Buy on explains itself", s.hover(s.rowOf(8950).cells.extra)[3], s.L["RESTOCKER_EXTRA_TOOLTIP_STOCK"])
check("the Hearthstone's ladder has one tier", s.cell(6948, "upgrade"), "na")
check("and says so", s.hover(s.rowOf(6948).cells.upgrade)[3], s.L["RESTOCKER_UPGRADE_NOT_APPLICABLE"])
check("a quest item is on no ladder", s.cell(12840, "upgrade"), "na")
check("water is on a ladder with somewhere to go", s.cell(8766, "upgrade"), "on")
s.click(s.rowOf(6948).cells.upgrade)
check("a dead cell takes no click", s.list()[6948].upgrade, nil)

print("7. A column heading sets its column for every row shown")
s = session()
local headings = s.ns.restockColumnHeader.cells
check("the heading's tooltip ends with the hint", s.hover(headings.buy)[5], s.L["RESTOCKER_COLUMN_BULK_HINT"])
check("Rep's heading only explains", #s.hover(headings.reputation), 3)
s.click(headings.buy)
check("Buy can be set on all six", s.menuTexts(), "Buy from Merchant / Turn On for 6 Shown / Turn Off for 6 Shown")
s.click(headings.buy)
check("a second click closes it", s.menu(), nil)
s.click(headings.upgrade)
check(
	"Upgrade on the three with a ladder to climb",
	s.menuTexts(),
	"Upgrade as You Level / Turn On for 3 Shown / Turn Off for 3 Shown"
)
s.pick("Turn Off")
check("water's Upgrade is off", s.cell(8766, "upgrade"), "off")
check("the Hearthstone's was never written", s.list()[6948].upgrade, nil)
check("and the menu closed", s.menu(), nil)
s.ns.SelectRestockGroup("Quest")
check("Quest shows one row", s.shownCount(), 1)
s.click(headings.buy)
check("the count is of the rows shown", s.menuTexts(), "Buy from Merchant / Turn On for 1 Shown / Turn Off for 1 Shown")
s.pick("Turn Off")
check("the quest row's Buy is off", s.list()[12840].buyFromMerchant, false)
check("the rows not shown are untouched", s.list()[8950].buyFromMerchant, true)
s.click(headings.extra)
check(
	"Extra has nothing to set where Buy is off",
	s.menuTexts(),
	"Buy Extra / Turn On for 0 Shown / Turn Off for 0 Shown"
)
s.pick("Turn On")
check("so its entries do nothing", s.list()[12840].buyExtra, nil)

print("8. Remove can be undone")
s = session()
local footer = s.window.footer
s.list()[8950].reaction = 6
s.click(s.rowOf(8950).removeButton)
check("the row is gone", s.list()[8950], nil)
check(
	"the offer names it, by its icon and its bare name",
	plain(text(footer.removedText)),
	"Removed |Ticon:8950:14:14|t |Hitem:8950|hHomemade Cherry Pie|h."
)
check("beside the count, not in its place", s.status(), "1 restocking order outstanding.")
check("Undo is showing", shown(footer.undo), true)
check("as a panel button, like the window's others", template(footer.undo), template(s.window.listBar.manageButton))
check("captioned", text(footer.undo), "Undo")
check("and sized to that caption", state[footer.undo].width, #"Undo" * 6 + 16)
check("which says what it does on hover", s.hover(footer.undo)[1], "Put This Item Back on the List")
s.click(footer.undo)
check("the row is back", s.list()[8950].amount, 40)
check("with everything set on it", s.list()[8950].reaction, 6)
check("and the offer is spent", shown(footer.undo), false)
s.wait(1)
s.click(s.rowOf(8950).removeButton)
s.wait(1)
s.click(s.rowOf(13444).removeButton)
s.click(footer.undo)
check("one step deep: the later removal comes back", s.list()[13444] ~= nil, true)
check("the earlier one does not", s.list()[8950], nil)
s.wait(1)
s.click(s.rowOf(13444).removeButton)
s.ns.SwitchRestockList("Druid")
check("switching lists withdraws the offer", shown(footer.undo), false)
s.ns.UndoRestockRemove()
check("and a late undo restores nothing", s.settings.lists["Druid (2)"][13444], nil)

print("9. An empty list shows its invitation instead of an empty grid")
s = session()
check("a list with items shows the grid", shown(s.window.emptyState), false)
for itemID in pairs(s.list()) do
	s.list()[itemID] = nil
end
s.ns.UpdateRestockList()
check("the invitation", shown(s.window.emptyState), true)
check("no column header", shown(s.ns.restockColumnHeader), false)
check("no category pane", shown(s.ns.restockGroupPane), false)
check("no list", shown(s.window.scrollFrame), false)
check("and nothing to say under it", s.status(), "")
s.ns.AddRestockItem("8950")
check("adding an item brings the grid back", shown(s.window.emptyState), false)
check("with its header", shown(s.ns.restockColumnHeader), true)
s.ns.AddRestockItem("12840")
s.type(s.window.filterBox, "zzz")
check("a New item passes any filter", s.shownCount(), 2)
s.window:Hide()
s.window:Show()
check("New is over once the window has closed, and the filter matches nothing", s.shownCount(), 0)
check("which the list says", text(s.window.nothingShownText), s.L["RESTOCKER_NO_MATCH_FILTER"])
check("where its rows would be", shown(s.window.nothingShownText), true)
s.type(s.window.filterBox, "")
check("clearing the filter clears it", shown(s.window.nothingShownText), false)
s.ns.SelectRestockGroup("Quest")
s.click(s.rowOf(12840).removeButton)
check("a category that lost its last item", text(s.window.nothingShownText), s.L["RESTOCKER_NO_MATCH_GROUP"])

print("10. The list bar names the list's characters, and Manage Lists acts on the list")
s = session()
local bar = s.window.listBar
check("the selector names the list", text(bar.selector), "Druid (2)")
check("its characters, A to Z, this realm's names bare", plain(text(bar.users)), "Used by Mossbark, Thornhoof")
check(
	"each in its class color, on a muted line",
	text(bar.users),
	"|cff808080Used by |cffFF7C0AMossbark|r|cffFFFFFF, |r|cffFF7C0AThornhoof|r|cff808080|r"
)
fire(bar.selector, "OnMouseDown")
check(
	"the selector's menu says whose each list is",
	s.menuTexts(),
	"Bank  Coinpurse-OldBlanchy / Druid  Fernwhisper / Druid (2)  Mossbark, Thornhoof / New List"
)
check("there too a name wears its class color", s.menuEntry("Bank"), "Bank  |cff3FC7EBCoinpurse-OldBlanchy|r")
check("and is muted until its class is known", s.menuEntry("Druid  "), "Druid  |cff808080Fernwhisper|r")
s.pick("Druid  ")
check("picking a list switches to it", s.settings.currentList, "Druid")
check("and the bar follows", plain(text(bar.users)), "Used by Fernwhisper, Mossbark")
check(
	"a name of unknown class is white there, never the label's grey",
	text(bar.users),
	"|cff808080Used by |cffFFFFFFFernwhisper|r|cffFFFFFF, |r|cffFF7C0AMossbark|r|cff808080|r"
)
s.ns.SwitchRestockList("Druid (2)")
s.click(bar.manageButton)
check("the button reads", text(bar.manageButton), "Manage Lists")
check(
	"the Manage Lists menu",
	s.menuTexts(),
	"New List / Copy This List into a New One / Rename This List / Delete This List"
)
s.pick("Rename")
check("renaming swaps the selector for a field", shown(bar.renameBox) and not shown(bar.selector), true)
check("holding the name", text(bar.renameBox), "Druid (2)")
fire(bar.renameBox, "OnEscapePressed")
check("Escape puts the selector back", shown(bar.selector) and not shown(bar.renameBox), true)
s.ns.BeginRestockListRename()
state[bar.renameBox].text = "Raiding"
s.click(bar.renameButton)
check("the Rename button commits", s.settings.currentList, "Raiding")
check("for every profile on the list", s.profileOf("Thornhoof").restockList, "Raiding")
check("and the rename is over", shown(bar.selector), true)
check("the selector shows the new name", text(bar.selector), "Raiding")
s.ns.BeginRestockListRename()
state[bar.renameBox].text = "Druid"
fire(bar.renameBox, "OnEnterPressed")
check("a name already taken is refused", s.settings.currentList, "Raiding")
check("and says so", s.printed[#s.printed], s.L["RESTOCKER_PROFILE_EXISTS"]:format("Druid"))
s.ns.BeginRestockListRename()
bar.renameBox:ClearFocus()
check("clicking away discards the edit", shown(bar.renameBox), false)
s.click(bar.manageButton)
s.pick("New List")
check("New List starts a class-named list", s.settings.currentList, "Druid (2)")
check("and opens the rename over it", shown(bar.renameBox), true)
check("it is this character's alone", plain(text(bar.users)), "Used by Mossbark")
s.ns.SwitchRestockList("Raiding")
s.click(bar.manageButton)
s.pick("Copy")
check("Copy names the clone after its source", s.settings.currentList, "Raiding Copy")
check("with the source's rows", s.list()[8950].amount, 40)
check("and opens the rename over it", shown(bar.renameBox), true)

print("11. Delete lands on the top list, says so first, and makes a list only when it was the last")
s = session()
s.click(s.window.listBar.manageButton)
s.pick("Delete")
check(
	"the confirm names who else loses the list and where this character lands",
	s.popupText(),
	"Are you sure you want to delete this list?|n|nDruid (2)|n|n"
		.. "Thornhoof uses it too, and will log in to an empty list with the same name. "
		.. "You'll switch to Bank.|n|nThis can't be undone."
)
check(
	"with the other character in its class color",
	s.popupWritten():find("|cffFF7C0AThornhoof|r", 1, true) ~= nil,
	true
)
s.ns.SwitchRestockList("Druid")
s.acceptPopup()
check("it deletes the list it asked about", s.settings.lists["Druid (2)"], nil)
check("not the one switched to since", s.settings.currentList, "Druid")
check("and makes no list in its place", s.listNames(), "Bank, Druid")
check("a list that was not in use stops no bank run", s.bankStops(), 0)
s.click(s.window.listBar.manageButton)
s.pick("Delete")
s.acceptPopup()
check("deleting the list in use lands on the top list", s.settings.currentList, "Bank")
check("which the bar shows", text(s.window.listBar.selector), "Bank")
check("with this character on it", plain(text(s.window.listBar.users)), "Used by Coinpurse-OldBlanchy, Mossbark")
check("and its rows drawn", s.shownCount(), 1)
check("still making no list", s.listNames(), "Bank")
check("a bank run under way is stopped, not carried on against the list landed on", s.bankStops(), 1)
s.click(s.window.listBar.manageButton)
s.pick("Delete")
check(
	"the last list says a new one will be started",
	s.popupText(),
	"Are you sure you want to delete this list?|n|nBank|n|n"
		.. "Coinpurse-OldBlanchy uses it too, and will log in to an empty list with the same name. "
		.. "It's the only list left, so you'll start on a new, empty one.|n|nThis can't be undone."
)
s.acceptPopup()
check("and one is: named for the class, past the names other characters point at", s.listNames(), "Druid (3)")
check("with this character on it", s.settings.currentList, "Druid (3)")
check("empty", next(s.list()), nil)
check("and the invitation showing", shown(s.window.emptyState), true)
s.click(s.window.listBar.manageButton)
s.pick("Delete")
s.acceptPopup()
check("deleting an only list leaves an empty list of the same name", s.listNames(), "Druid (3)")

-- The report: alone on "Druid (2)", beside the "Druid" it was numbered after.
s = session()
s.settings.lists["Bank"] = nil
s.profileOf("Coinpurse", "Old Blanchy").restockList = nil
s.profileOf("Thornhoof").restockList = nil
s.click(s.window.listBar.manageButton)
s.pick("Delete")
check(
	"a list nobody else is on says only where this character lands",
	s.popupText(),
	"Are you sure you want to delete this list?|n|nDruid (2)|n|nYou'll switch to Druid.|n|nThis can't be undone."
)
s.acceptPopup()
check("deleting Druid (2) lands on Druid", s.settings.currentList, "Druid")
check("and makes no Druid (3)", s.listNames(), "Druid")
s.addCharacter("Wildpaw", "Whitemane", "Druid")
s.click(s.window.listBar.manageButton)
s.pick("Delete")
check(
	"two others are named together",
	s.popupText(),
	"Are you sure you want to delete this list?|n|nDruid|n|n"
		.. "Fernwhisper, Wildpaw use it too, and will each log in to an empty list with the same name. "
		.. "It's the only list left, so you'll start on a new, empty one.|n|nThis can't be undone."
)

print("12. An item dropped anywhere on the window joins the list")
s = session()
s.pickUp(14530)
s.click(s.rowOf(8950).cells.buy)
check("dropped on a cell, it is added", s.list()[14530] ~= nil, true)
check("at one stack", s.list()[14530].amount, 20)
check("and the cell is not clicked", s.list()[8950].buyFromMerchant, true)
check("the cursor is emptied", s.holding(), nil)
s.list()[14530] = nil
s.ns.SelectRestockGroup(nil)
s.pickUp(14530)
s.click(s.rowOf(8950).removeButton)
check("dropped on a remove button, nothing is removed", s.list()[8950] ~= nil, true)
check("and it is added", s.list()[14530] ~= nil, true)
s.list()[14530] = nil
s.ns.SelectRestockGroup(nil)
s.pickUp(14530)
fire(s.window, "OnMouseUp", "LeftButton")
check("dropped on the window itself", s.list()[14530] ~= nil, true)
s.ns.SelectRestockGroup(nil)
s.pickUp(8950)
fire(s.rowOf(8766).nameButton, "OnReceiveDrag")
check("an item already listed is left as it was", s.list()[8950].amount, 40)
check("and still leaves the cursor", s.holding(), nil)
fire(s.rowOf(8950).removeButton, "OnReceiveDrag")
check("a drag that carried no item removes nothing", s.list()[8950] ~= nil, true)
-- Every other control takes a drop the same way, and a click that brought one does nothing else.
local function dropOn(control, script)
	s.list()[14530] = nil
	s.ns.SelectRestockGroup(nil)
	s.pickUp(14530)
	fire(control, script or "OnClick", "LeftButton")
	return s.list()[14530] ~= nil and s.holding() == nil
end
check("dropped on a toggle heading, it is added", dropOn(s.ns.restockColumnHeader.cells.buy), true)
check("and the heading's menu stays shut", s.menu(), nil)
check("dropped on the Rep heading", dropOn(s.ns.restockColumnHeader.cells.reputation), true)
check("dropped on the Keep heading", dropOn(s.ns.restockColumnHeader.amountCaption), true)
-- An add shows the New group; a click that also selected the category would end on the category instead.
s.list()[14530] = nil
s.ns.SelectRestockGroup(nil)
local categoryRow
for _, row in ipairs(s.ns.restockCategoryRowPool) do
	if row.isInUse and row.group and row.group ~= s.L["RESTOCKER_GROUP_NEW"] then
		categoryRow = row
		break
	end
end
s.pickUp(14530)
s.click(categoryRow)
check("dropped on a category", s.list()[14530] ~= nil, true)
check("which is not selected by it", s.ns.restockSelectedGroup, s.L["RESTOCKER_GROUP_NEW"])
check("dropped on the filter", dropOn(s.window.filterBox, "OnMouseUp"), true)
check("or on its clear button", dropOn(s.window.filterClearButton), true)
check("dropped on Add", dropOn(s.window.addButton), true)
check("which does not try the empty add box", text(s.window.addPlaceholder), s.L["RESTOCKER_ADD_PLACEHOLDER"])
check("dropped on Pick Staples", dropOn(s.window.staplesButton), true)
check("which does not open the staples", s.staplesOpened(), 0)
check("dropped on the list selector", dropOn(s.window.listBar.selector, "OnMouseDown"), true)
check("which opens no menu", s.menu(), nil)
check("dropped on Manage Lists", dropOn(s.window.listBar.manageButton), true)
check("dropped on the status line", dropOn(s.window.footer.status), true)
s.ns.SelectRestockGroup(nil)
s.wait(1)
s.click(s.rowOf(13444).removeButton)
check("dropped on Undo", dropOn(s.window.footer.undo), true)
check("which puts nothing back", s.list()[13444], nil)
check("a drag let go over Undo is taken too", dropOn(s.window.footer.undo, "OnReceiveDrag"), true)

print("13. An add that fails says why in the add box")
s = session()
local placeholder = s.window.addPlaceholder
check("the placeholder", text(placeholder), s.L["RESTOCKER_ADD_PLACEHOLDER"])
state[s.window.editBox].text = "999999"
s.click(s.window.addButton)
check("an ID with no item behind it", text(placeholder), "No item has ID 999999.")
check("in red", isRed(placeholder), true)
check("not in chat", #s.printed, 0)
check("the box is emptied for the next try", text(s.window.editBox), "")
s.type(s.window.editBox, "8")
check("typing again puts the placeholder back", text(placeholder), s.L["RESTOCKER_ADD_PLACEHOLDER"])
check("in its own grey", isRed(placeholder), false)
state[s.window.editBox].text = "a pie"
fire(s.window.editBox, "OnEnterPressed")
check("text that names no item", text(placeholder), s.L["RESTOCKER_ADD_NOT_FOUND"])
s.window:Hide()
s.window:Show()
check("closing the window clears the notice", text(placeholder), s.L["RESTOCKER_ADD_PLACEHOLDER"])
s.window:Hide()
s.ns.AddRestockItem("999999")
check("with the window closed it goes to chat", s.printed[1], "No item has ID 999999.")

print("14. Pick Staples opens over the list and leaves it open")
s = session()
s.click(s.window.staplesButton)
check("the staples open", s.staplesOpened(), 1)
check("the window stays", shown(s.window), true)

print("15. One menu at a time, and none outlives the window")
s = session()
s.click(s.window.listBar.manageButton)
s.click(s.ns.restockColumnHeader.cells.buy)
check("a column menu replaces the Manage Lists menu", s.menuTexts():match("^[^/]+"), "Buy from Merchant ")
s.click(s.rowOf(8950).cells.reputation)
check("the standings menu replaces it", s.menuTexts():match("^[^/]+"), "Required Reputation ")
fire(s.window.listBar.selector, "OnMouseDown")
check("the list menu replaces that", s.menuTexts():match("^[^/]+"), "Bank  Coinpurse-OldBlanchy ")
fire(s.window.bagMenu, "OnMouseDown")
check("the bag menu replaces that", s.menuTexts(), "Nothing in Your Bags to Add")
s.click(s.window.listBar.manageButton)
check("and the Manage Lists menu replaces the bag menu", s.menuTexts():match("^[^/]+"), "New List ")
fire(s.window.bagMenu, "OnMouseDown")
s.window:Hide()
check("closing the window closes it", s.menu(), nil)
s.window:Show()
s.click(s.ns.restockColumnHeader.cells.buy)
s.ns.UpdateRestockList()
check("a redraw closes a column menu, whose count it would stale", s.menu(), nil)

print("16. Add Item from Bags lists what the bags hold that the list lacks, and a pick adds it")
s = session()
local bagMenu = s.window.bagMenu
-- A menu line as the player reads it: the icon, then the item's name, with none of a link's brackets.
local function bagEntry(itemID, name)
	return ("|Ticon:%d:14:14|t |Hitem:%d|h%s|h"):format(itemID, itemID, name)
end
local BANDAGE = bagEntry(14530, "Heavy Runecloth Bandage")
local SILK = bagEntry(4306, "Silk Cloth")
check("the closed menu wears its caption", s.hover(bagMenu)[1], "Add Item from Bags")
check("drawn as the hints beside it are", font(bagMenu.caption), font(s.window.addPlaceholder))
check("small and grey", font(bagMenu.caption), "GameFontDisableSmall")
fire(bagMenu, "OnMouseDown")
check("with everything in the bags already listed, it says so", s.menuTexts(), "Nothing in Your Bags to Add")
s.pick("Nothing")
check("on a line that cannot be picked", s.menuTexts(), "Nothing in Your Bags to Add")
s.click(bagMenu.arrow)
check("a second click, on the field or its arrow, closes it", s.menu(), nil)
s.bags[4306], s.bags[14530] = 40, 12
s.click(bagMenu.arrow)
check("what the list lacks, by name, as the reports draw an item", s.menuTexts(), BANDAGE .. " / " .. SILK)
s.pick("|Ticon:4306")
check("a pick adds the item", s.list()[4306] ~= nil, true)
check("at one stack, whatever the bags hold", s.list()[4306].amount, 20)
check("into the New group", s.ns.restockNewItems[4306], true)
check("and closes the menu", s.menu(), nil)
fire(bagMenu, "OnMouseDown")
check("the next opening no longer offers it", s.menuTexts(), BANDAGE)
s.click(s.rowOf(4306).removeButton)
check("a change to the list closes a menu it would stale", s.menu(), nil)
fire(bagMenu, "OnMouseDown")
check("and the item removed is on offer again", s.menuTexts(), BANDAGE .. " / " .. SILK)
s.ns.SwitchRestockList("Bank")
fire(bagMenu, "OnMouseDown")
check(
	"the menu answers to the list in use",
	s.menuTexts(),
	table.concat({
		bagEntry(13928, "Grilled Squid"),
		bagEntry(6948, "Hearthstone"),
		BANDAGE,
		bagEntry(8950, "Homemade Cherry Pie"),
		bagEntry(13444, "Major Mana Potion"),
		bagEntry(8766, "Morning Glory Dew"),
		SILK,
	}, " / ")
)
fire(bagMenu, "OnMouseDown")
s.pickUp(14530)
fire(bagMenu, "OnMouseDown")
check("with an item in hand a click is a drop, and opens nothing", s.menu(), nil)
check("which adds the item", s.list()[14530] ~= nil, true)
check("and empties the cursor", s.holding(), nil)
s.list()[14530] = nil
s.pickUp(14530)
fire(bagMenu, "OnReceiveDrag")
check("so does a drag let go over it", s.list()[14530] ~= nil, true)

print("17. On Forever a character is its first name and surname")
s = session({ forever = true })
bar = s.window.listBar
check("the key is the whole name and the realm", s.ns.GetCharacterKey(), "Mossbark Greenleaf-Whitemane")
check("the bar names each character in full", plain(text(bar.users)), "Used by Mossbark Greenleaf, Thornhoof Oakheart")
fire(bar.selector, "OnMouseDown")
check(
	"and so does the selector's menu",
	s.menuTexts(),
	"Bank  Coinpurse Goldweigh / Druid  Fernwhisper Dawnmist / "
		.. "Druid (2)  Mossbark Greenleaf, Thornhoof Oakheart / New List"
)
check("in its class color", s.menuEntry("Bank"), "Bank  |cff3FC7EBCoinpurse Goldweigh|r")
s.pick("Druid  ")
check("a list picked is kept on this character's profile", s.profileOf("Mossbark").restockList, "Druid")
check("and on nobody else's", s.profileOf("Thornhoof").restockList, "Druid (2)")
s.ns.SwitchRestockList("Druid (2)")
s.click(bar.manageButton)
s.pick("Delete")
check(
	"the delete confirm names the other character in full",
	s.popupText():match("|n|n(Thornhoof Oakheart uses it too)"),
	"Thornhoof Oakheart uses it too"
)

print("18. A double-click on Remove takes off one row, not the one that moves up under it")
s = session()
local firstRow = s.ns.restockRowPool[1]
local removeButton, removedID = firstRow.removeButton, firstRow.item.itemID
s.click(removeButton)
check("the first click removes its row", s.list()[removedID], nil)
local movedUpID = removeButton.item.itemID
check("and the button now belongs to the next row", movedUpID ~= removedID, true)
s.click(removeButton)
check("the second click, inside the guard, removes nothing", s.list()[movedUpID] ~= nil, true)
s.wait(0.5)
s.click(removeButton)
check("a click after it removes the row under it", s.list()[movedUpID], nil)

print("19. The filter and the add box let go of the keyboard when they are done with it")
s = session()
s.window.filterBox:SetFocus()
s.type(s.window.filterBox, "pie")
fire(s.window.filterBox, "OnEnterPressed")
check("Enter in the filter lets go of the keyboard", focus, nil)
check("and keeps the filter", text(s.window.filterBox), "pie")
s.type(s.window.filterBox, "")
-- The click that drops an item on the add box is the click that focuses it.
s.window.editBox:SetFocus()
s.pickUp(14530)
fire(s.window.editBox, "OnMouseUp", "LeftButton")
check("an item dropped on the add box is added", s.list()[14530] ~= nil, true)
check("and the box lets go of the keyboard", focus, nil)
s.list()[14530] = nil
s.window.editBox:SetFocus()
s.pickUp(14530)
fire(s.window.editBox, "OnReceiveDrag")
check("so does a drag let go over it", focus, nil)
s.window.editBox:SetFocus()
fire(s.window.editBox, "OnMouseUp", "LeftButton")
check("a click with nothing in hand keeps the keyboard, to type an ID", focus == s.window.editBox, true)

print("")
if failures == 0 then
	print("ALL RESTOCK WINDOW SCENARIOS PASSED")
else
	print(("%d RESTOCK WINDOW CHECK(S) FAILED"):format(failures))
	os.exit(1)
end
