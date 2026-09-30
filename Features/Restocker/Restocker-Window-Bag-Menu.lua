local _, ns = ...
local L = ns.L
local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- Add Item From Bags
--------------------------------------------------------------------------------

--[[
    [Add Item From Bags      v]

    The control row's menu: everything in the character's bags that the list
    does not hold yet, by name, and a click adds it. What a player is already
    carrying is most of what a list starts from, and this puts it on the list
    without dragging it out of a bag or looking up its item ID.

    A pick lands like any other add (ns.AddRestockItem in Restocker-List.lua):
    one stack to keep, every switch on, first in the New group. The menu closes
    on the pick, as a menu does, and the item is not in it the next time.

    Built on every open rather than kept, from the bags as they are then and
    the list in use, so nothing has to be kept in step with either.

    A field and a pullout, like the list selector above it: the field is the
    window's own (ns.CreateRestockMenuField in Restocker-Window.lua), and
    Restocker-Window-List-Bar.lua says why the menu is an AceGUI pullout.
    Restocker-Window.lua places the field on the row and sizes it.
]]
local ARROW_SIZE = 16 -- two under the row's 18px fields
local MENU_WIDTH = 280 -- an icon and an item's whole name
local MENU_MAX_HEIGHT = 360 -- about twenty items, and the pullout scrolls past that
local ICON_SIZE = 14
local UNKNOWN_ICON = "Interface\\ICONS\\INV_Misc_QuestionMark" -- the list's own stand-in for an icon it cannot name

--------------------------------------------------------------------------------
-- Items
--------------------------------------------------------------------------------

-- What the menu lists: each item in the bags that is not on the list in use, in the order the list's own rows take.
local function ItemsToAdd()
	local settings = ns.restockSettings
	local list = settings.lists[settings.currentList]

	local items = {}
	for _, item in ipairs(ns.GetRestockBagItems()) do
		if list[item.itemID] == nil then
			items[#items + 1] = item
		end
	end

	table.sort(items, function(a, b)
		local left, right = a.name or "", b.name or ""
		if left ~= right then
			return left < right
		end
		return a.itemID < b.itemID
	end)
	return items
end

--------------------------------------------------------------------------------
-- Menu
--------------------------------------------------------------------------------

--[[
    One pullout, built on first use and reused, like the list bar's two and for
    the same reason: an Execute item closes its own pullout from inside its
    OnClick, so items are cleared at the next open, never at close.
]]
local bagPullout
local bagPulloutOpen = false

local function CloseBagMenu()
	if bagPullout and bagPulloutOpen then
		bagPulloutOpen = false
		bagPullout:Close()
	end
end

ns.CloseRestockBagMenu = CloseBagMenu

local function OpenBagMenu(anchor)
	if not bagPullout then
		bagPullout = AceGUI:Create("Dropdown-Pullout")
		bagPullout:SetMaxHeight(MENU_MAX_HEIGHT)
		bagPullout:SetCallback("OnClose", function()
			bagPulloutOpen = false
		end)
	end
	bagPullout:Clear()
	--[[
	    A reused pullout keeps its scroll position, and this one opens on a
	    different list of items every time, so each open starts at the top. The
	    slider is what AceGUI itself scrolls a pullout through.
	]]
	bagPullout.slider:SetValue(0)

	local items = ItemsToAdd()
	for _, item in ipairs(items) do
		local entry = AceGUI:Create("Dropdown-Item-Execute")
		-- The item's icon and its name in its quality color, without the link's brackets, as the orders tooltip shows one.
		local name = ns.UnbracketItemLink(item.link)
		entry:SetText(string.format("|T%s:%d:%d|t %s", item.icon or UNKNOWN_ICON, ICON_SIZE, ICON_SIZE, name))
		entry:SetCallback("OnClick", function()
			ns.AddRestockItem(item.itemID)
		end)
		bagPullout:AddItem(entry)
	end

	--[[
	    Empty bags, or bags holding nothing the list lacks. The menu still opens,
	    on one line that cannot be picked, so the click is answered instead of
	    looking like a control that did not work.
	]]
	if #items == 0 then
		local nothing = AceGUI:Create("Dropdown-Item-Execute")
		nothing:SetText(L["RESTOCKER_ADD_FROM_BAGS_NONE"])
		nothing:SetDisabled(true)
		bagPullout:AddItem(nothing)
	end

	bagPulloutOpen = true
	bagPullout:SetWidth(MENU_WIDTH)
	bagPullout:Open("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
end

--[[
    The field and its arrow open the menu, and close it again when it is already
    open. With an item in hand a click there is a drop instead, which the field
    itself takes (ns.CreateRestockMenuField).
]]
local function ToggleBagMenu(anchor)
	if bagPulloutOpen then
		CloseBagMenu()
		return
	end
	-- One menu at a time: none of them closes on a click elsewhere, so each open clears the rest.
	ns.CloseRestockMenus()
	OpenBagMenu(anchor)
end

--------------------------------------------------------------------------------
-- Widget
--------------------------------------------------------------------------------

function ns.CreateRestockBagMenu(addonFrame, controlRow)
	local field = ns.CreateRestockMenuField(controlRow, ARROW_SIZE, ToggleBagMenu)

	--[[
	    The caption is all the field ever shows: a pick is carried out, never
	    held, so there is no chosen value for it to give way to. It is drawn as
	    the placeholders either side of it are, in their font and their grey
	    (the maintainer's ruling): the row's three fields then read alike, each
	    saying what it is for, and the arrow is what says this one opens.
	    Anchored on both sides with no wrap, as they are, so a longer caption
	    in another locale truncates inside the field instead of running under
	    the arrow.
	]]
	local caption = field:CreateFontString(nil, "OVERLAY")
	caption:SetFontObject("GameFontDisableSmall")
	caption:SetPoint("LEFT", field, "LEFT", 4, 0)
	caption:SetPoint("RIGHT", field.arrow, "LEFT", -2, 0)
	caption:SetJustifyH("LEFT")
	caption:SetWordWrap(false)
	caption:SetText(L["RESTOCKER_ADD_FROM_BAGS"])
	field.caption = caption

	ns.SetupRestockerTooltip(field, L["RESTOCKER_ADD_FROM_BAGS"], L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"])

	addonFrame.bagMenu = field
	return field
end
