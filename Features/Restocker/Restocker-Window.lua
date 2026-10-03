local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Window Geometry
--------------------------------------------------------------------------------

--[[
    Size and position both live in ns.db.global.restocker.framePosition. That is the
    account-wide half of the AceDB database, so one window layout follows the
    player across every character and no profile switch can move it.

    Both width numbers are set by the LIST, not the rows above and below it, and
    they are the sum of two things that each have their own floor:

      the category pane   its widest ALLOWED width (180) plus the gap (8)
      the table           591, which holds the item name at its readable floor
      window chrome       the inset (2 + 4), its padding (8), the scroll bar (26)

    which is where MIN_WIDTH comes from. (The name now has 14 pixels over that
    floor: the Keep box narrowed when its heading shortened from "Amount", and
    the window's floor was left where players' saved sizes already respect it.) The pane sizes itself to the longest type
    name it actually has to draw (see ns.ResolveRestockGroupPaneWidth) and is capped so this
    number stays honest: MIN_WIDTH is set against the CAP rather than the usual
    width, so the item name keeps its floor even on a client whose type names run
    long. Raising that cap means raising this. The list bar's own floor (the
    selector and the Manage Lists button, with the line between them free to truncate)
    sits well under it. The control row's (three fields and two buttons) sits
    under it by about 65 pixels in English, which is the room a longer Pick
    Staples caption has before the bag menu meets the filter.

    DEFAULT_WIDTH is a step above the floor so a fresh window opens with room for
    a long consumable name rather than at the edge of truncation. MAX_* is a
    sanity ceiling for a corrupt saved value, not a real limit.

    Both height numbers went up by the list bar's own span when it moved to the
    top of the window, so the list shows as many rows at each as it did before.
]]
local DEFAULT_WIDTH = 870
local DEFAULT_HEIGHT = 430
local MIN_WIDTH = 819
local MIN_HEIGHT = 290
local MAX_WIDTH = 1600
local MAX_HEIGHT = 1200

local function Clamp(value, minimum, maximum, fallback)
	value = tonumber(value)
	if not value then
		return fallback
	end
	return math.max(minimum, math.min(maximum, value))
end

-- Written whole: AceDB can clear an empty framePosition at logout before this runs.
function ns.SaveRestockWindowGeometry()
	local frame = ns.restockWindow
	if not frame then
		return
	end
	local point, _, relativePoint, xOffset, yOffset = frame:GetPoint(frame:GetNumPoints())
	ns.restockSettings.framePosition = {
		point = point,
		relativePoint = relativePoint,
		xOffset = xOffset,
		yOffset = yOffset,
		width = math.floor(frame:GetWidth() + 0.5),
		height = math.floor(frame:GetHeight() + 0.5),
	}
end

--[[
    Forward-declared: CreateAddonFrame's OnSizeChanged closure names it, and a
    local that is not yet in scope on that line compiles as a nil global instead.
]]
local RelayoutFrame

local function CreateAddonFrame()
	local settings = ns.restockSettings
	local addonFrame = CreateFrame("Frame", "ConnoisseurRestockerFrame", UIParent, "BasicFrameTemplate")
	addonFrame.width = Clamp(settings.framePosition.width, MIN_WIDTH, MAX_WIDTH, DEFAULT_WIDTH)
	addonFrame.height = Clamp(settings.framePosition.height, MIN_HEIGHT, MAX_HEIGHT, DEFAULT_HEIGHT)
	addonFrame:SetSize(addonFrame.width, addonFrame.height)
	addonFrame:SetPoint(
		settings.framePosition.point or "RIGHT",
		UIParent,
		settings.framePosition.relativePoint or "RIGHT",
		settings.framePosition.xOffset or -5,
		settings.framePosition.yOffset or 0
	)
	addonFrame:SetFrameStrata("HIGH")
	-- A saved position from another resolution or UI scale must not open off-screen.
	addonFrame:SetClampedToScreen(true)
	addonFrame:SetMovable(true)
	addonFrame:SetResizable(true)
	addonFrame:EnableMouse(true)
	addonFrame:RegisterForDrag("LeftButton")
	addonFrame:SetScript("OnDragStart", addonFrame.StartMoving)
	addonFrame:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		ns.SaveRestockWindowGeometry()
	end)

	addonFrame:SetResizeBounds(MIN_WIDTH, MIN_HEIGHT, MAX_WIDTH, MAX_HEIGHT)

	--[[
	    Children are anchored to two corners rather than given a size, so the whole
	    layout follows the window on its own. Only the scroll child and the pooled
	    rows need telling -- a scroll child is sized, not anchored -- which is what
	    RelayoutFrame does.
	]]
	addonFrame:SetScript("OnSizeChanged", function(self)
		RelayoutFrame(self)
	end)

	--[[
	    Redrawn on the way in, whichever route opened it (the slash command, the
	    mini-map button, a bank or merchant visit): the yellow Keep marks and the
	    orders under the list are read from the bags, which nothing repaints while
	    the window is hidden.
	]]
	addonFrame:SetScript("OnShow", function()
		ns.UpdateRestockList()
	end)

	--[[
	    The "New" group lasts exactly as long as the window is open, and an open
	    menu is parented to UIParent rather than to the window, so it would outlive
	    it. Hooked on OnHide rather than in ns.HideRestockWindow because the frame
	    also closes by routes that never reach it -- the title bar's X, and Escape
	    via UISpecialFrames.
	]]
	addonFrame:SetScript("OnHide", function()
		ns.CloseRestockMenus()
		ns.EndRestockListRename()
		ns.ClearRestockAddNotice()
		ns.ClearRestockNewItems()
		ns.ClearRestockGroupSelection()
		ns.restockWindowOpenedByVisit = false
		if next(ns.restockColdRows) ~= nil then
			wipe(ns.restockColdRows)
			ns.SyncRestockItemInfoSubscription()
		end
	end)

	--[[
	    An item dropped on any bare part of the window joins the list, so the add
	    box is one target rather than the only one. Every control takes the mouse
	    before the window does, and each makes this same call: the rows' own
	    (Restocker-Window-Rows.lua), and the rest through ns.SetRestockControlClick
	    below.
	]]
	local function TakeCursorItem()
		ns.AddRestockItemFromCursor()
	end
	addonFrame:SetScript("OnMouseUp", TakeCursorItem)
	addonFrame:SetScript("OnReceiveDrag", TakeCursorItem)
	return addonFrame
end

--[[
    Every menu in the window is an AceGUI pullout we opened by hand, and none of
    them closes on a click elsewhere, so each closes the others as it opens and
    the window closes them all as it hides.
]]
function ns.CloseRestockMenus()
	ns.CloseReputationMenu()
	ns.CloseRestockColumnMenu()
	ns.CloseRestockListMenus()
	ns.CloseRestockBagMenu()
end

--[[
    Add the item on the cursor to the list, and say whether there was one.
    Shared by the add box, the window and every control on a row, so a drop
    lands the same way wherever it falls. The cursor is cleared either way the
    add goes: a duplicate is already on the list, and leaving it on the cursor
    would read as the drop having missed.
]]
function ns.AddRestockItemFromCursor()
	local infoType, _, itemLink = GetCursorInfo()
	if infoType ~= "item" then
		return false
	end
	ns.AddRestockItem(itemLink)
	ClearCursor()
	return true
end

--[[
    A control's click, or the script standing in for one, set so that an item
    carried onto the control is dropped on the list instead, as it would be on
    any bare part of the window; a drag let go over the control is taken the
    same way. onClick runs only for a click that brought no item, and a control
    that only explains itself on hover passes none.
]]
function ns.SetRestockControlClick(control, onClick, script)
	control:SetScript(script or "OnClick", function(...)
		if not ns.AddRestockItemFromCursor() and onClick then
			onClick(...)
		end
	end)
	control:SetScript("OnReceiveDrag", function()
		ns.AddRestockItemFromCursor()
	end)
end

--[[
    The same for a text box, which reports no click: the mouse-up of the click
    that brought the item, or a drag let go over it. That click also focused the
    box, so once the drop is taken the keyboard goes back to the game.
]]
local function SetBoxTakesDrops(box)
	local function TakeDroppedItem(self)
		if ns.AddRestockItemFromCursor() then
			self:ClearFocus()
		end
	end
	box:SetScript("OnMouseUp", function(self, button)
		if button == "LeftButton" then
			TakeDroppedItem(self)
		end
	end)
	box:SetScript("OnReceiveDrag", TakeDroppedItem)
end

--[[
    Push the current window size down into the parts that cannot follow it by
    anchoring alone. Cheap enough to run on every frame of a resize drag: it
    sets widths and never rebuilds the list.
]]
function RelayoutFrame(addonFrame)
	local scrollChild = addonFrame.scrollChild
	if not scrollChild then
		return -- still being built; ns.CreateRestockWindow lays out once at the end
	end

	addonFrame.width = addonFrame:GetWidth()
	addonFrame.height = addonFrame:GetHeight()
	addonFrame.listInset.width = addonFrame.listInset:GetWidth()
	addonFrame.listInset.height = addonFrame.listInset:GetHeight()

	--[[
	    Only the table's rows follow the window: the category pane is a fixed width
	    (see WINDOW GEOMETRY), so nothing in it needs resizing on a drag.
	]]
	local rowWidth = addonFrame.scrollFrame:GetWidth()
	scrollChild:SetWidth(rowWidth)
	for _, row in ipairs(ns.restockRowPool) do
		row:SetWidth(rowWidth)
	end
end

--[[
    The corner grip that resizes the window. A child button, so it takes the
    mouse before the frame-wide drag-to-move handler sees it.
]]
local function CreateResizeGrip(addonFrame)
	local grip = CreateFrame("Button", nil, addonFrame)
	grip:SetSize(16, 16)
	grip:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -4, 4)
	grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
	grip:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
	grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
	grip:SetScript("OnMouseDown", function()
		addonFrame:StartSizing("BOTTOMRIGHT")
	end)
	grip:SetScript("OnMouseUp", function()
		addonFrame:StopMovingOrSizing()
		RelayoutFrame(addonFrame)
		ns.SaveRestockWindowGeometry()
	end)
	addonFrame.resizeGrip = grip
	return grip
end

local function CreateListInset(addonFrame)
	local listInset = CreateFrame("Frame", nil, addonFrame, "InsetFrameTemplate3")
	-- Two corners instead of a size: the inset then tracks the window by itself.
	listInset:SetPoint("TOPLEFT", addonFrame, "TOPLEFT", 2, -22)
	listInset:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -4, 38)
	listInset.width = listInset:GetWidth()
	listInset.height = listInset:GetHeight()
	addonFrame.listInset = listInset
	return listInset
end

--[[
    The filter box and the add row each sit in clear space rather than tight
    against the inset edge and the list -- a control the player types into reads
    as its own thing, not as the first or last row of the table.
]]
local CONTROL_ROW_HEIGHT = 25 -- sized to the Add button, the tallest thing on it
local CONTROL_ROW_GAP = 10 -- clear space above and below the row
local EDIT_BOX_HEIGHT = 18 -- all three fields, shorter than the row so they centre in it
--[[
    Three fields share the row, so each is only as wide as its job takes. The
    filter holds a word or two of an item's name. The bag menu holds its
    caption and its arrow. The add box holds its hint, the longest text on the
    row, and an add notice is written in that same space; both are kept to a
    phrase (see their locale keys), because the row cannot pay for a field the
    width of a sentence.

    None of them absorbs a wider window. The slack collects between the filter
    and the bag menu, which is also the line between narrowing the list and
    adding to it.

    A placeholder is a FontString rather than editbox content, so nothing clips
    it for you: with only a left anchor, the add hint runs out over the Add
    button. Each is anchored on both sides, so a hint that outgrows its field
    truncates inside it instead of over its neighbour.
]]
local FILTER_BOX_WIDTH = 150
local BAG_MENU_WIDTH = 170
local ADD_BOX_WIDTH = 190
local CONTROL_GROUP_GAP = 16 -- between the add pair and the Pick Staples button
--[[
    Between the bag menu and the add box: the same space as the one above, as
    it is drawn (the maintainer's ruling). Neither gap is the distance between
    its two frames. An InputBoxTemplate field draws its border some 4px left
    of its own edge, which eats into this gap, and a GameMenuButtonTemplate
    button's art stops about 2px short of each end, which adds to that one.
    Measured in the Forever client: 16 between Add and Pick Staples draws as
    20, and the two fields need 25 between them to draw the same.
]]
local CONTROL_ITEM_GAP = CONTROL_GROUP_GAP + 9
local ADD_BUTTON_WIDTH = 60
--[[
    A starting width for the Pick Staples button, set before it is fitted to
    its caption. GameMenuButtonTemplate carries no size of its own, and
    ns.FitRestockButton declines to size a button whose font has not resolved
    yet -- which would leave this one zero-wide and invisible rather than merely
    the wrong width. Fitting then sets the caption's own width, which in English
    is narrower than this.
]]
local STAPLES_BUTTON_WIDTH = 100
local LIST_BOTTOM_MARGIN = 8 -- no control row shares the list's inset

--[[
    The magnifying glass beside the filter, saying what that box is for without
    spending row width on a caption. Decoration only -- it takes no mouse, so
    there is no dead click target sitting beside a box you type into.

    The add box carries no matching glyph on purpose: the Add button bolted to
    its right already names what it does, so an icon there would be a second
    label on a control that has one.

    The gap clears InputBoxTemplate's border art, which hangs off the box's left
    edge, so an icon set flush against it would touch the frame rather than the
    field. The path is the client's own art; if it renders blank, that is the
    thing to check first.
]]
local ROW_ICON_SIZE = 16
local ROW_ICON_GAP = 8
local FILTER_ICON = "Interface\\Common\\UI-Searchbox-Icon"

--[[
    The filter's clear button, inside the field's right edge where a search box's
    is conventionally looked for. Shown only while there is text to clear, since
    a clear control on an empty field is a button that does nothing.

    The mark is the group-loot pass the item rows and the options item lists
    already use for "get rid of this", so removal looks the same everywhere in
    the add-on -- and, unlike a new path, it is art this window is already known
    to load.
]]
local CLEAR_BUTTON_SIZE = 14
local CLEAR_BUTTON_INSET = 4
local CLEAR_ICON = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local CLEAR_ICON_DOWN = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"

--[[
    The side insets of the control row, which holds the filter box at its left end
    and the controls that add at the right. Asymmetric because InputBoxTemplate
    hangs its border art off the left edge -- the numbers are what make the row's
    two ends look evenly inset, not what makes them measure evenly.
]]
local CONTROL_ROW_INSET_LEFT = 16
local CONTROL_ROW_INSET_RIGHT = 12

--[[
    How far below the inset's top edge the control row starts: under the list
    bar (Restocker-Window-List-Bar.lua, which owns that span), in its own clear
    space.
]]
local function ControlRowTop()
	return ns.RESTOCK_LIST_BAR_SPAN + CONTROL_ROW_GAP
end

--[[
    How far below the inset's top edge the list area starts, and with it the
    empty list's invitation, which takes that whole area over.
]]
local function ListAreaTop()
	return ControlRowTop() + CONTROL_ROW_HEIGHT + CONTROL_ROW_GAP
end

--[[
    How far below the inset's top edge both panes start: the top of the list
    area, then the column header's own height. Shared so the category rows and
    the item rows sit on the same baseline.
]]
local function ListTopInset()
	return ListAreaTop() + ns.restockColumnHeaderHeight + 4
end

--[[
    How far above the inset's bottom edge both panes stop. Everything the player
    types into now shares one row at the top, so this is a plain margin rather
    than a reserved band. Read by the category pane too
    (Restocker-Window-Categories.lua), so the two halves end on the same line.
]]
ns.RESTOCK_LIST_BOTTOM_INSET = LIST_BOTTOM_MARGIN

local function CreateScrollFrame(addonFrame, listInset)
	local scrollFrame = CreateFrame("ScrollFrame", nil, addonFrame, "UIPanelScrollFrameTemplate")
	--[[
	    The category pane owns the left of the inset, so the table starts past it.
	    26 on the right for the scroll bar, and the plain bottom margin
	    (ns.RESTOCK_LIST_BOTTOM_INSET). The column header is anchored to this
	    frame's top corners rather than measured against the inset, so it
	    inherits the same right edge the rows lay out from.
	]]
	local left = 8 + ns.restockGroupPaneWidth + ns.RESTOCK_GROUP_PANE_GAP
	scrollFrame:SetPoint("TOPLEFT", listInset, "TOPLEFT", left, -ListTopInset())
	scrollFrame:SetPoint("BOTTOMRIGHT", listInset, "BOTTOMRIGHT", -26, ns.RESTOCK_LIST_BOTTOM_INSET)
	scrollFrame.width = scrollFrame:GetWidth()
	scrollFrame.height = scrollFrame:GetHeight()
	addonFrame.scrollFrame = scrollFrame
	return scrollFrame
end

--[[
    One row under the list bar: the filter at its left end, and at the right
    every way of adding to the list -- the bag menu, the add box with its Add
    button, and Pick Staples.

    The filter looks like the fields beside it but does the opposite thing --
    they change the list, it only narrows the view -- so it is kept apart from
    them by a wider gap than anything else on the row. Add is bolted to the add
    box so that pair reads as one control rather than one more field.

    Left to right the adders run from the least typing to the most: pick what
    is already in the bags, then drop or type anything else. Pick Staples ends
    the row because it opens a window of its own.
]]
local function CreateControlRow(addonFrame, listInset)
	local row = CreateFrame("Frame", nil, addonFrame)
	row:SetPoint("TOPLEFT", listInset, "TOPLEFT", CONTROL_ROW_INSET_LEFT, -ControlRowTop())
	row:SetPoint("TOPRIGHT", listInset, "TOPRIGHT", -CONTROL_ROW_INSET_RIGHT, -ControlRowTop())
	row:SetHeight(CONTROL_ROW_HEIGHT)
	addonFrame.controlRow = row
	return row
end

--[[
    A text filter at the left end of the row. Once 2+ characters are typed, the list
    shows only items whose name, type or item ID contains the text; clearing it shows
    everything.
]]
local function CreateFilterBox(addonFrame, controlRow)
	local box = CreateFrame("EditBox", nil, controlRow, "InputBoxTemplate")
	--[[
	    The row's left end, past its own icon. A LEFT-to-LEFT anchor centres the
	    box vertically against the taller buttons at the other end of the row.

	    The filter leads the row because it narrows the whole view under it: the
	    category pane's counts answer to it as well as the item rows, so at this
	    end it sits over everything it changes rather than over half of it.
	]]
	box:SetPoint("LEFT", controlRow, "LEFT", ROW_ICON_SIZE + ROW_ICON_GAP, 0)
	box:SetWidth(FILTER_BOX_WIDTH)
	box:SetHeight(EDIT_BOX_HEIGHT)
	box:SetAutoFocus(false)
	-- Keep typed text off the clear button below; the placeholder never meets it.
	box:SetTextInsets(0, CLEAR_BUTTON_SIZE + CLEAR_BUTTON_INSET, 0, 0)

	local icon = controlRow:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ROW_ICON_SIZE, ROW_ICON_SIZE)
	icon:SetPoint("LEFT", controlRow, "LEFT", 0, 0)
	icon:SetTexture(FILTER_ICON)
	addonFrame.filterIcon = icon

	local clearButton = CreateFrame("Button", nil, box)
	clearButton:SetSize(CLEAR_BUTTON_SIZE, CLEAR_BUTTON_SIZE)
	clearButton:SetPoint("RIGHT", box, "RIGHT", -CLEAR_BUTTON_INSET, 0)
	clearButton:SetNormalTexture(CLEAR_ICON)
	clearButton:SetPushedTexture(CLEAR_ICON_DOWN)
	clearButton:SetHighlightTexture(CLEAR_ICON, "ADD")
	clearButton:Hide()
	--[[
	    Clearing the box fires OnTextChanged below, which is what empties the
	    filter and repaints the list -- so this handler only has to blank the
	    text, and the two paths out of a filter cannot drift apart.
	]]
	ns.SetRestockControlClick(clearButton, function()
		box:SetText("")
		box:ClearFocus()
	end)
	ns.SetupRestockerTooltip(clearButton, L["RESTOCKER_FILTER_CLEAR_TOOLTIP"])
	addonFrame.filterClearButton = clearButton

	--[[
	    Greyed-out placeholder, shown only while the box is empty. Anchored on
	    both sides with no word wrap, the same way a row's item name is, so a
	    string longer than the field truncates inside it instead of running out
	    over whatever sits to the right. A placeholder is a FontString rather
	    than editbox content, so nothing clips it otherwise.
	]]
	local placeholder = box:CreateFontString(nil, "OVERLAY")
	placeholder:SetFontObject("GameFontDisableSmall")
	placeholder:SetPoint("LEFT", box, "LEFT", 4, 0)
	placeholder:SetPoint("RIGHT", box, "RIGHT", -4, 0)
	placeholder:SetJustifyH("LEFT")
	placeholder:SetWordWrap(false)
	placeholder:SetText(L["RESTOCKER_FILTER_PLACEHOLDER"])

	box:SetScript("OnTextChanged", function(self)
		local text = self:GetText() or ""
		placeholder:SetShown(text == "")
		clearButton:SetShown(text ~= "")
		ns.restockListFilter = text
		ns.UpdateRestockList()
	end)
	box:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)
	box:SetScript("OnEscapePressed", function(self)
		self:SetText("")
		self:ClearFocus()
	end)
	SetBoxTakesDrops(box)

	addonFrame.filterBox = box
	return box
end

local function CreateScrollChild(scrollFrame, addonFrame)
	local scrollChild = CreateFrame("Frame", nil, scrollFrame)
	scrollChild.width = scrollFrame:GetWidth()
	scrollChild.height = scrollFrame:GetHeight()
	scrollChild:SetWidth(scrollChild.width)
	scrollChild:SetHeight(scrollChild.height - 10)
	addonFrame.scrollChild = scrollChild

	scrollFrame:SetScrollChild(scrollChild)
	return scrollChild
end

local function CreateTitle(addonFrame)
	local title = addonFrame:CreateFontString(nil, "OVERLAY")
	title:SetFontObject("GameFontHighlightLarge")
	title:SetPoint("CENTER", addonFrame.TitleBg, "CENTER", 0, 0)
	title:SetText(L["RESTOCKER_WINDOW_TITLE"])
	addonFrame.title = title
	return title
end

local function CreateAddButton(addonFrame, controlRow)
	local addButton = CreateFrame("Button", nil, controlRow, "GameMenuButtonTemplate")
	--[[
	    Sits against the Pick Staples button's left edge, closing the add pair off
	    from it. The add box then hangs off THIS button's left edge, so the pair
	    still reads as one control rather than a field and a button that happen
	    to be adjacent.
	]]
	addButton:SetPoint("RIGHT", addonFrame.staplesButton, "LEFT", -CONTROL_GROUP_GAP, 0)
	addButton:SetSize(ADD_BUTTON_WIDTH, CONTROL_ROW_HEIGHT)
	addButton:SetText(L["RESTOCKER_ADD_BUTTON"])
	addButton:SetNormalFontObject("GameFontNormal")
	addButton:SetHighlightFontObject("GameFontHighlight")
	--[[
	    The add box is captured, never resolved through GetParent: this button is
	    parented to controlRow and the box is not its child, so walking the chain
	    is both fragile and exactly the trap the row controls warn about.
	]]
	ns.SetRestockControlClick(addButton, function()
		local editBox = addonFrame.editBox
		local text = editBox:GetText()

		ns.AddRestockItem(text)

		editBox:SetText("")
		editBox:ClearFocus()
	end)
	--[[
	    The same tooltip the edit box shows: the button and the box are two
	    halves of one control, and either is a fair place to hover.
	]]
	ns.SetupRestockerTooltip(addButton, L["RESTOCKER_ADD_TOOLTIP_TITLE"], L["RESTOCKER_ADD_TOOLTIP_BODY"])

	addonFrame.addButton = addButton
	return addButton
end

--[[
    The add box's placeholder doubles as its notice line (see Add Notices
    below): these are the tone a notice takes, and the placeholder's own, read
    back from its font when the box is built.
]]
local NOTICE_TONE = ns.HexToRGB(ns.RESTOCKER_WINDOW_COLORS.ADD_NOTICE)
local placeholderTone

local function CreateEditBox(addonFrame, controlRow)
	local editBox = CreateFrame("EditBox", nil, controlRow, "InputBoxTemplate")
	--[[
	    One end anchored and a fixed width, like the filter box on the far side
	    of the row. It hangs off the Add button rather than off the row, so the
	    whole right-hand group keeps its shared right edge and a wider window
	    opens the gap between that group and the filter instead.

	    The 3px overlap tucks the box's right border art under the button, which
	    is what makes the two read as one control.
	]]
	editBox:SetPoint("RIGHT", addonFrame.addButton, "LEFT", 3, 0)
	editBox:SetWidth(ADD_BOX_WIDTH)
	editBox:SetAutoFocus(false)
	editBox:SetHeight(EDIT_BOX_HEIGHT)
	editBox:SetScript("OnEnterPressed", function(self)
		local text = self:GetText()
		ns.AddRestockItem(text)
		self:SetText("")
		self:ClearFocus()
	end)
	SetBoxTakesDrops(editBox)

	--[[
	    Greyed-out placeholder, shown only while the box is empty -- the same
	    arrangement as the filter box, both ends anchored and no wrap included.
	    This is the longest hint on the row and the one ADD_BOX_WIDTH is sized
	    to, so it is also the one that overran the field and drew under the Add
	    button when it had only a left anchor to hold it.
	]]
	local placeholder = editBox:CreateFontString(nil, "OVERLAY")
	placeholder:SetFontObject("GameFontDisableSmall")
	placeholder:SetPoint("LEFT", editBox, "LEFT", 4, 0)
	placeholder:SetPoint("RIGHT", editBox, "RIGHT", -4, 0)
	placeholder:SetJustifyH("LEFT")
	placeholder:SetWordWrap(false)
	placeholder:SetText(L["RESTOCKER_ADD_PLACEHOLDER"])
	addonFrame.addPlaceholder = placeholder
	-- The grey its font object draws in, kept for ns.ClearRestockAddNotice to put back.
	placeholderTone = { placeholder:GetTextColor() }
	editBox:SetScript("OnTextChanged", function(self)
		local isEmpty = (self:GetText() or "") == ""
		--[[
		    Typing again answers a notice, so it goes. Emptying the box does not:
		    both add paths clear the box right after the add that raised it.
		]]
		if not isEmpty then
			ns.ClearRestockAddNotice()
		end
		placeholder:SetShown(isEmpty)
	end)

	ns.SetupRestockerTooltip(editBox, L["RESTOCKER_ADD_TOOLTIP_TITLE"], L["RESTOCKER_ADD_TOOLTIP_BODY"])

	addonFrame.editBox = editBox
	return editBox
end

--[[
    The Add Item From Bags menu (Restocker-Window-Bag-Menu.lua builds it), set
    against the add box's left edge: the next link leftward in the chain that
    hangs off the row's right end.
]]
local function PlaceBagMenu(addonFrame, controlRow)
	local bagMenu = ns.CreateRestockBagMenu(addonFrame, controlRow)
	bagMenu:SetPoint("RIGHT", addonFrame.editBox, "LEFT", -CONTROL_ITEM_GAP, 0)
	bagMenu:SetSize(BAG_MENU_WIDTH, EDIT_BOX_HEIGHT)
	return bagMenu
end

--------------------------------------------------------------------------------
-- Add Notices
--------------------------------------------------------------------------------

--[[
    An add that did not go through says why in the add box itself, in place of
    its placeholder: the box has just been emptied, it is where the player is
    looking, and a chat line is easy to miss behind the window. The notice stays
    until the player types again or the window closes.

    With the window shut there is no box to write in, so the same line goes to
    chat instead.
]]
local addNoticeShown = false

function ns.ShowRestockAddNotice(message)
	local window = ns.restockWindow
	if not (window and window:IsShown()) then
		ns.PrintMessage(message)
		return
	end
	addNoticeShown = true
	window.addPlaceholder:SetText(message)
	window.addPlaceholder:SetTextColor(NOTICE_TONE.r, NOTICE_TONE.g, NOTICE_TONE.b)
end

function ns.ClearRestockAddNotice()
	if not addNoticeShown then
		return
	end
	addNoticeShown = false
	local placeholder = ns.restockWindow.addPlaceholder
	placeholder:SetText(L["RESTOCKER_ADD_PLACEHOLDER"])
	placeholder:SetTextColor(unpack(placeholderTone))
end

--[[
    Pick Staples, the same staples window a fresh character is offered at login
    (Options/Options-Starter-List-Popup.lua). Reachable from here as well so it
    is a tool the player can come back to rather than a one-off greeting they
    either caught or missed.

    It opens OVER this window, which stays open: each staple checked lands in
    the New group behind it, and closing it leaves the player where they were.
    That is why the button no longer hides the list first -- a list hidden for
    the staples never came back by itself.

    Sized to its caption like the list bar's buttons rather than to a number, so
    a longer word in another locale widens the button instead of clipping it;
    the height is then set back to the row's, since FitRestockButton sizes for
    a list row and this one shares a line with Add.
]]
local function CreateStaplesButton(addonFrame, controlRow)
	local button = CreateFrame("Button", nil, controlRow, "GameMenuButtonTemplate")
	-- The row's right end; the add pair chains leftward off it.
	button:SetPoint("RIGHT", controlRow, "RIGHT", 0, 0)
	button:SetSize(STAPLES_BUTTON_WIDTH, CONTROL_ROW_HEIGHT)
	button:SetText(L["RESTOCKER_LIST_BUILDER_BUTTON"])
	button:SetNormalFontObject("GameFontNormal")
	button:SetHighlightFontObject("GameFontHighlight")
	ns.FitRestockButton(button)
	button:SetHeight(CONTROL_ROW_HEIGHT)

	ns.SetRestockControlClick(button, function()
		ns.ShowStarterListPopup()
	end)

	ns.SetupRestockerTooltip(button, L["RESTOCKER_LIST_BUILDER_BUTTON"], L["RESTOCKER_LIST_BUILDER_TOOLTIP"])

	addonFrame.staplesButton = button
	return button
end

--------------------------------------------------------------------------------
-- Empty List
--------------------------------------------------------------------------------

--[[
    What an empty list shows in place of the grid: a short body and one button.
    A bare header over no rows, with "All Items 0" beside it, reads as a window
    that failed to load; this says the list is empty and what to do about it.

    The block is centred on the list area as a stack hung from its title, so a
    body that wraps to another line in another locale pushes the button down
    rather than running under it. The body is capped in width for the same
    reason a paragraph is: a sentence spanning the whole window is hard to read.
    In English it wraps to three lines, which is what the title's offset
    centres the stack for.

    It takes no mouse, so an item dropped on it falls through to the window's
    own drop handler like a drop on any other bare part of the window.
]]
local EMPTY_BODY_WIDTH = 440
local EMPTY_TITLE_OFFSET = 48 -- the title's foot above the area's centre, which centres the stack
local EMPTY_GAP = 10
local EMPTY_BUTTON_WIDTH = 140
local EMPTY_BUTTON_HEIGHT = 28

local function CreateEmptyState(addonFrame, listInset)
	local panel = CreateFrame("Frame", nil, addonFrame)
	panel:SetPoint("TOPLEFT", listInset, "TOPLEFT", 8, -ListAreaTop())
	panel:SetPoint("BOTTOMRIGHT", listInset, "BOTTOMRIGHT", -8, ns.RESTOCK_LIST_BOTTOM_INSET)
	panel:Hide()

	local title = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
	title:SetPoint("BOTTOM", panel, "CENTER", 0, EMPTY_TITLE_OFFSET)
	title:SetText(L["RESTOCKER_EMPTY_TITLE"])

	local body = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	body:SetPoint("TOP", title, "BOTTOM", 0, -EMPTY_GAP)
	body:SetWidth(EMPTY_BODY_WIDTH)
	body:SetJustifyH("CENTER")
	body:SetText(L["RESTOCKER_EMPTY_BODY"])

	local button = CreateFrame("Button", nil, panel, "GameMenuButtonTemplate")
	button:SetPoint("TOP", body, "BOTTOM", 0, -EMPTY_GAP - 4)
	button:SetSize(EMPTY_BUTTON_WIDTH, EMPTY_BUTTON_HEIGHT)
	button:SetText(L["RESTOCKER_LIST_BUILDER_BUTTON"])
	button:SetNormalFontObject("GameFontNormal")
	button:SetHighlightFontObject("GameFontHighlight")
	ns.FitRestockButton(button)
	-- FitRestockButton sizes for a list row; this one is the screen's one action, so it stays larger.
	button:SetSize(math.max(EMPTY_BUTTON_WIDTH, button:GetWidth()), EMPTY_BUTTON_HEIGHT)
	ns.SetRestockControlClick(button, function()
		ns.ShowStarterListPopup()
	end)

	local hint = panel:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
	hint:SetPoint("TOP", button, "BOTTOM", 0, -EMPTY_GAP)
	hint:SetText(L["RESTOCKER_EMPTY_DROP_HINT"])

	addonFrame.emptyState = panel
	return panel
end

--[[
    The one line a list with items shows when none of them is drawn: the filter
    matches nothing, or the selected category just lost its last item. On the
    scroll frame, so it sits where the first row would.
]]
local function CreateNothingShownText(addonFrame)
	local text = addonFrame.scrollFrame:CreateFontString(nil, "OVERLAY", "GameFontDisable")
	text:SetPoint("TOP", addonFrame.scrollFrame, "TOP", 0, -16)
	text:Hide()
	addonFrame.nothingShownText = text
	return text
end

--[[
    Swap the grid for the empty list's invitation and back, and set the
    nothing-shown line. Called by ns.UpdateRestockList at the end of every
    redraw, with what it just found: whether the list holds anything at all,
    and the line to show when it does but no row was drawn (nil otherwise).

    The column header and the category pane are siblings of the scroll frame
    rather than children of it, so each is switched by name.
]]
function ns.UpdateRestockEmptyState(listIsEmpty, nothingShown)
	local window = ns.restockWindow
	window.emptyState:SetShown(listIsEmpty)
	window.scrollFrame:SetShown(not listIsEmpty)
	ns.restockColumnHeader:SetShown(not listIsEmpty)
	ns.restockGroupPane:SetShown(not listIsEmpty)

	window.nothingShownText:SetShown(nothingShown ~= nil)
	if nothingShown then
		window.nothingShownText:SetText(nothingShown)
	end
end

--[[
    Escape closes the window through UISpecialFrames. The staples pop-up takes
    the window off that list while it is open: AceConfigDialog answers Escape by
    running Blizzard's CloseSpecialWindows first, so one press would otherwise
    close both windows.
]]
function ns.SetRestockWindowClosesOnEscape(closes)
	for index = #UISpecialFrames, 1, -1 do
		if UISpecialFrames[index] == "ConnoisseurRestockerFrame" then
			table.remove(UISpecialFrames, index)
		end
	end
	if closes then
		table.insert(UISpecialFrames, "ConnoisseurRestockerFrame")
	end
end

function ns.CreateRestockWindow()
	-- Row and button heights come from the font, so measure before anything is built.
	ns.RefreshRestockRowMetrics()
	-- The table's left edge is anchored past the category pane, so size it first.
	ns.ResolveRestockGroupPaneWidth()

	local addonFrame = CreateAddonFrame()
	local listInset = CreateListInset(addonFrame)
	local scrollFrame = CreateScrollFrame(addonFrame, listInset)
	CreateScrollChild(scrollFrame, addonFrame)
	ns.CreateRestockColumnHeader(addonFrame, scrollFrame)
	ns.CreateRestockGroupPane(addonFrame, listInset, ListTopInset())
	CreateEmptyState(addonFrame, listInset)
	CreateNothingShownText(addonFrame)
	CreateTitle(addonFrame)
	ns.CreateRestockListBar(addonFrame, listInset)

	--[[
	    Order matters, and the row chains right to left: the Pick Staples button
	    anchors to the row's right edge, Add to that button, the add box to Add,
	    and the bag menu to the add box. The filter is independent -- it hangs
	    off the row's LEFT edge -- so where it is built in the sequence does not
	    matter.
	]]
	local controlRow = CreateControlRow(addonFrame, listInset)
	CreateFilterBox(addonFrame, controlRow)
	CreateStaplesButton(addonFrame, controlRow)
	CreateAddButton(addonFrame, controlRow)
	CreateEditBox(addonFrame, controlRow)
	PlaceBagMenu(addonFrame, controlRow)
	--[[
	    Settings live in Connoisseur's options panel (minimap tooltip / /foodie);
	    the frame deliberately has no Settings button.
	]]
	ns.CreateRestockWindowFooter(addonFrame)
	CreateResizeGrip(addonFrame)

	ns.SetRestockWindowClosesOnEscape(true)
	addonFrame:Hide()

	ns.restockWindow = addonFrame
	-- Now that scrollChild exists, settle the sizes the anchors could not carry.
	RelayoutFrame(addonFrame)
	return ns.restockWindow
end

function ns.ShowRestockWindow()
	if ns.restockerLoaded then
		local menu = ns.restockWindow or ns.CreateRestockWindow()
		-- Opening redraws by itself (OnShow); a window already open is redrawn here.
		if menu:IsShown() then
			return ns.UpdateRestockList()
		end
		menu:Show()
	end
end

function ns.HideRestockWindow()
	if ns.restockerLoaded then
		local menu = ns.restockWindow or ns.CreateRestockWindow()
		return menu:Hide()
	end
end

--[[
    A merchant or bank visit closes the window only when that visit opened it:
    a window the player opened stays open, and a loading screen, which fires the
    _CLOSED events with nothing open, never closes it. OnHide clears the flag.
]]
ns.restockWindowOpenedByVisit = false

function ns.ShowRestockWindowForVisit()
	if ns.restockWindow and ns.restockWindow:IsShown() then
		return
	end
	ns.ShowRestockWindow()
	ns.restockWindowOpenedByVisit = ns.restockWindow ~= nil and ns.restockWindow:IsShown()
end

function ns.HideRestockWindowAfterVisit()
	if ns.restockWindowOpenedByVisit then
		ns.HideRestockWindow()
	end
end

function ns.ToggleRestockWindow()
	if ns.restockerLoaded then
		local menu = ns.restockWindow or ns.CreateRestockWindow()
		return menu:SetShown(not menu:IsShown()) or false
	end
end

--------------------------------------------------------------------------------
-- Menu Fields
--------------------------------------------------------------------------------

--[[
    A closed menu, as the list selector and the bag menu both draw one: an
    InputBoxTemplate field with a menu arrow inside its right edge, calling
    onToggle with the field when either is clicked with nothing in hand; with
    an item in hand the click is a drop. The caller places it, sizes it, and
    says what it shows.

    Read-only -- keyboard is off and focus bounces straight back out, so it
    renders as a field but behaves as a button. Why a field and not an AceGUI
    Dropdown is in Restocker-Window-List-Bar.lua.

    The arrow is the same three textures Blizzard's own UIDropDownMenuTemplate
    puts on its button, so the control opens with the chevron players already
    read as "this is a menu" rather than a generic arrow painted into a text
    field. A real Button rather than a texture, so it presses and highlights
    like one.
]]
function ns.CreateRestockMenuField(parent, arrowSize, onToggle)
	local field = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	field:SetAutoFocus(false)
	field:EnableKeyboard(false)
	field:SetScript("OnEditFocusGained", function(self)
		self:ClearFocus()
	end)
	ns.SetRestockControlClick(field, onToggle, "OnMouseDown")

	local arrow = CreateFrame("Button", nil, field)
	arrow:SetSize(arrowSize, arrowSize)
	arrow:SetPoint("RIGHT", field, "RIGHT", -4, 0)
	arrow:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up")
	arrow:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down")
	arrow:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight", "ADD")
	ns.SetRestockControlClick(arrow, function()
		onToggle(field)
	end)
	field.arrow = arrow
	return field
end

--------------------------------------------------------------------------------
-- Tooltips
--------------------------------------------------------------------------------

--[[
    Every explanatory tooltip in the Restocker window routes through here, so the
    colors, the spacing, and the wrap all live in one place.

    Shape: a gold title, then white body lines with a blank line before each, so
    a multi-line tooltip reads as paragraphs instead of one wall. Same spacing
    idiom as AddSpacedLines in Minimap-Button.lua. Single-body tooltips are
    unaffected -- they get the one spacer under the title either way.

    Colors are passed explicitly rather than left to default: the two defaults
    disagree, SetText falling back to gold and AddLine to white, so a tooltip that
    leaves them out gets its title and body the wrong way round. Both come from the
    shared numeric palette. Callers pass plain strings; no |cff escapes.

    The trailing `true` on each line is the textWrap argument. Without it a
    tooltip is exactly as wide as its longest line, and the longer strings here
    (the reputation control's discount line especially) rendered a tooltip wider
    than the game window. With it the client breaks each line at its standard
    tooltip width -- which is also why we do not hand-measure a pixel budget: the
    client's own break points are correct in locales that don't put spaces
    between words.

    A one-argument call is a whole tooltip in one line, and renders as the title.

    Two entry points. ns.SetupRestockerTooltip wires a control whose tooltip
    never changes. ns.ShowRestockerTooltip draws one on the spot, for the
    controls whose text depends on their state when hovered -- a cell that
    cannot be set on its row says why instead.
]]
local TOOLTIP_TITLE = ns.COLORS_RGB.TITLE
local TOOLTIP_BODY = ns.COLORS_RGB.TEXT

function ns.ShowRestockerTooltip(owner, title, ...)
	GameTooltip:SetOwner(owner, "ANCHOR_TOP")
	GameTooltip:SetText(title, TOOLTIP_TITLE.r, TOOLTIP_TITLE.g, TOOLTIP_TITLE.b, 1, true)
	for i = 1, select("#", ...) do
		GameTooltip:AddLine(" ") -- blank line under the title, then between each pair
		GameTooltip:AddLine((select(i, ...)), TOOLTIP_BODY.r, TOOLTIP_BODY.g, TOOLTIP_BODY.b, true)
	end
	GameTooltip:Show()
end

function ns.SetupRestockerTooltip(control, title, ...)
	local body = { ... }
	control:SetScript("OnEnter", function(self)
		ns.ShowRestockerTooltip(self, title, unpack(body))
	end)
	control:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end
