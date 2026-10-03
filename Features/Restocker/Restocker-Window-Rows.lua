local _, ns = ...
local L = ns.L
local AceGUI = LibStub("AceGUI-3.0")

--[[
    The controls that fill the Restock List grid: the Keep box, the toggle cells,
    the reputation and column menus, the remove button and its undo, and the
    pooled rows holding them, plus the render loop that lays those rows out.

    The grid itself -- column definitions, widths, shared colors and the header --
    is Restocker-Window-Columns.lua, which loads first.
]]
local COLUMNS = ns.RESTOCK_COLUMNS
local REPUTATION_STANDINGS = ns.REPUTATION_STANDINGS
local BUTTON_FONT = ns.RESTOCK_BUTTON_FONT
local REMOVE_ICON_SIZE = ns.RESTOCK_REMOVE_ICON_SIZE
local COLUMN_MIN_WIDTH = ns.RESTOCK_COLUMN_MIN_WIDTH
local ROW_INSET = ns.RESTOCK_ROW_INSET
local ICON_SIZE = ns.RESTOCK_ICON_SIZE
local ICON_TEXT_GAP = ns.RESTOCK_ICON_TEXT_GAP
local NAME_COLUMN_GAP = ns.RESTOCK_NAME_COLUMN_GAP
local KEEP_GAP = ns.RESTOCK_KEEP_GAP
local GOLD = ns.RESTOCK_CELL_GOLD
local WHITE = ns.RESTOCK_CELL_WHITE
local DASH_OFF = ns.RESTOCK_CELL_DASH_OFF
local DASH_NOT_APPLICABLE = ns.RESTOCK_CELL_DASH_NOT_APPLICABLE
local REPUTATION_SET = ns.RESTOCK_CELL_REPUTATION_SET
local KEEP_SHORT = ns.RESTOCK_CELL_KEEP_SHORT
local CELL_HIGHLIGHT = ns.RESTOCK_CELL_HIGHLIGHT
local CELL_HIGHLIGHT_ALPHA = ns.RESTOCK_CELL_HIGHLIGHT_ALPHA
local LayoutColumns = ns.LayoutRestockColumns
local ApplyColumnWidths = ns.ApplyRestockColumnWidths
local TooltipBody = ns.RestockColumnTooltipBody
local ReputationStandingByValue = ns.RestockReputationStandingByValue
local ReputationMenuText = ns.RestockReputationMenuText

--[[
    Zebra stripe alpha. Deliberately faint: the row already carries quality-coloured
    item names and gold check glyphs, and a stripe strong enough to notice on its own
    competes with both. It only has to make the eye's path across seven cells hold
    its line.
]]
local ROW_STRIPE_ALPHA = 0.045

-- Scratch list rebuilt on every render; never escapes this file.
local restockItemList = {}

--[[
    The items the last render drew, in order. A column heading's menu acts on
    exactly these -- "every item shown" has to mean what the player is looking
    at, category and filter included -- so it is kept from the render rather than
    rebuilt when the menu opens.
]]
local shownItems = {}

--[[
    An item carried onto a row is being dropped on the list, not aimed at the
    control under it, so every control on a row hands the cursor to the add path
    (ns.AddRestockItemFromCursor in Restocker-Window.lua) and acts as itself only
    when the cursor holds no item. This is the drag-release half; each click
    handler makes the same call first.
]]
local function TakeCursorItem()
	ns.AddRestockItemFromCursor()
end

--[[
    The standings menu, built on AceGUI's own pullout rather than Blizzard's
    UIDropDownMenu. Blizzard's version drives shared global frames that its own
    secure code also uses, so an add-on running through them leaves taint behind;
    AceGUI's pullout owns its frames outright. It also raises itself to TOOLTIP
    strata, which keeps it in front of the window.

    A hand-created pullout closes only when we close it. The widget installs no
    OnHide script, and SetHideOnLeave writes a flag AceGUI-3.0 never reads, so
    every close path is one of ours: opening another menu, clicking the open
    menu's own cell again, picking a standing, the window hiding, and
    ns.UpdateRestockList.

    Update is the load-bearing one. Rows come from a pool, so any redraw can put a
    different item under an open menu -- and the menu has to be gone before that
    row is rebound, or a pick lands on an item the player never opened.

    The callback is pinned to the item the menu was opened for as a second guard,
    so a close that is ever missed writes nothing rather than writing to whatever
    row drifted underneath.
]]
local openReputationPullout = nil
local openReputationCell = nil

local function CloseReputationMenu()
	if not openReputationPullout then
		return
	end
	local pullout = openReputationPullout
	openReputationPullout = nil
	openReputationCell = nil
	pullout:Close()
	AceGUI:Release(pullout)
end

ns.CloseReputationMenu = CloseReputationMenu

local function OpenReputationMenu(cell, row)
	-- A click on the open menu's own cell closes it rather than reopening it.
	if openReputationPullout and openReputationCell == cell then
		CloseReputationMenu()
		return
	end
	-- One menu at a time: none of them closes on a click elsewhere, so each open clears the rest.
	ns.CloseRestockMenus()

	local openedForItem = cell.item
	if not openedForItem then
		return
	end

	local pullout = AceGUI:Create("Dropdown-Pullout")
	openReputationPullout = pullout
	openReputationCell = cell

	local title = AceGUI:Create("Dropdown-Item-Header")
	title:SetText(L["RESTOCKER_REPUTATION_MENU_TITLE"])
	pullout:AddItem(title)

	for _, standing in ipairs(REPUTATION_STANDINGS) do
		local entry = AceGUI:Create("Dropdown-Item-Toggle")
		entry:SetText(ReputationMenuText(standing))
		entry:SetValue((openedForItem.reaction or 0) == standing.value)
		entry:SetCallback("OnValueChanged", function()
			if cell.item == openedForItem then
				-- Store nil for "Any" so nothing is persisted; otherwise the standing code.
				openedForItem.reaction = (standing.value > 0) and standing.value or nil
				ns.UpdateRestockListRow(row, openedForItem)
			end
			-- A toggle item does not close its own pullout, unlike an execute item.
			CloseReputationMenu()
		end)
		pullout:AddItem(entry)
	end

	pullout:SetCallback("OnClose", function()
		openReputationPullout = nil
		openReputationCell = nil
	end)
	pullout:Open("TOPLEFT", cell, "BOTTOMLEFT", 0, 0)
end

--[[
    A Keep amount is yellow while the bags hold fewer: the grocery list's line
    not yet crossed off. ns.IsRestockItemShort (Restocker-Merchant.lua) is the
    test, so the mark goes by the same bag count the merchant restock and the
    orders under the list do -- and by nothing else: a row with Buy off, which
    the bank is meant to fill, is just as short until it has been. The orders
    count under the list is drawn in the same yellow (Restocker-Window-Footer.lua).
]]
local function PaintKeep(editBox, item)
	local tone = ns.IsRestockItemShort(item) and KEEP_SHORT or WHITE
	editBox:SetTextColor(tone.r, tone.g, tone.b)
end

--[[
    The Keep box: how many of this item the list keeps in the bags. The caller
    places it and sets its width, since the row lays its controls out from the
    right edge inward and this one hangs off the leftmost column.
]]
local function CreateAmountEditBox(frame)
	local editBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")

	editBox:SetHeight(ns.restockButtonHeight - 2)
	editBox:SetAutoFocus(false)
	--[[
	    Digits only, and every read still falls back to 0: item.amount is compared
	    against bag counts by the bank restock loop, where a nil target throws and
	    aborts the whole run.
	]]
	editBox:SetNumeric(true)
	--[[
	    Both handlers read self.item, rebound by ns.UpdateRestockListRow like every
	    other row control -- never GetParent().item, which is the trap that once
	    broke removal silently.
	]]
	editBox:SetScript("OnEnterPressed", function(self)
		local amount = tonumber(self:GetText()) or 0

		if self.item then
			self.item.amount = amount
		end
		editBox:ClearFocus()
		self:SetText(tostring(amount))
		ns.UpdateRestockList()
		if ns.bankIsOpen then
			ns.OnRestockerBankOpen()
		end
	end)
	editBox:SetScript("OnKeyUp", function(self)
		if self.item then
			self.item.amount = tonumber(self:GetText()) or 0
			-- The amount is live from here, so its mark and the count under the list follow it.
			PaintKeep(self, self.item)
			ns.UpdateRestockStatus()
		end
	end)
	--[[
	    An item carried onto the box joins the list, like one dropped anywhere
	    else on the window. The click that dropped it also focused the box, and
	    the redraw may have handed the box a different row, so the focus goes.
	]]
	local function TakeDroppedItem(self)
		if ns.AddRestockItemFromCursor() then
			self:ClearFocus()
		end
	end
	editBox:SetScript("OnMouseUp", TakeDroppedItem)
	editBox:SetScript("OnReceiveDrag", TakeDroppedItem)

	-- No "press Enter" line: OnKeyUp above has already saved the amount.
	ns.SetupRestockerTooltip(editBox, L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"], L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"])

	return editBox
end

--[[
    The row a remove click just took off the list, kept so the status line can
    offer it back (ns.UndoRestockRemove): the button sits beside the last
    column, and a row's Keep amount and flags go with it. One step deep -- a
    second removal replaces it -- and dropped with the "New" flags, whenever the
    window closes or the list changes (ns.ClearRestockNewItems).
]]
ns.restockLastRemoved = nil

--[[
    A remove redraws the list at once, so by a double-click's second click the
    pooled button under the cursor belongs to the next row. A remove this soon
    after the last one is that second click, and is ignored.
]]
local DOUBLE_CLICK_GUARD_SECONDS = 0.4
local lastRemoveTime = -math.huge

-- Reads self.item, which UpdateRestockListRow rebinds like every other row control, never GetParent().item.
local function OnDeleteButtonClick(self)
	-- An item carried onto the button is being dropped on the list, not aimed at this row.
	if ns.AddRestockItemFromCursor() then
		return
	end

	local now = GetTime()
	if now - lastRemoveTime < DOUBLE_CLICK_GUARD_SECONDS then
		return
	end

	local settings = ns.restockSettings
	local list = settings.lists[settings.currentList]
	local item = self.item

	if item and item.itemID then
		-- Lists are keyed by itemID, so removal is a direct delete
		list[item.itemID] = nil
		lastRemoveTime = now
		ns.restockLastRemoved = { item = item, listName = settings.currentList }
		ns.UpdateRestockList()
	end
end

--[[
    Put the last removed row back exactly as it was. Refused quietly when the
    list it came from is gone or already holds that item again -- added back by
    hand, which is the newer intent -- and either way the offer is spent.
]]
function ns.UndoRestockRemove()
	local removed = ns.restockLastRemoved
	ns.restockLastRemoved = nil
	if not removed then
		return
	end

	local list = ns.restockSettings.lists[removed.listName]
	if list and list[removed.item.itemID] == nil then
		list[removed.item.itemID] = removed.item
	end
	ns.UpdateRestockList()
end

--[[
    The group-loot pass mark is the game's own "get rid of this" icon, and the
    same texture Connoisseur's and MagicEraser's option-panel item lists use for
    their remove column -- so removal looks the same everywhere. Never a
    UIPanelCloseButton: its red X reads as "close the window" on a row, and its
    30px frame is mostly transparent padding.

    The highlight is the normal texture blended additively rather than a separate
    file, which glows on hover without depending on a second art path.
]]
local REMOVE_ICON = "Interface\\Buttons\\UI-GroupLoot-Pass-Up"
local REMOVE_ICON_DOWN = "Interface\\Buttons\\UI-GroupLoot-Pass-Down"

local function CreateDeleteButton(frame)
	local button = CreateFrame("Button", nil, frame)

	button:SetPoint("RIGHT", frame, "RIGHT", -ROW_INSET, 0)
	button:SetSize(REMOVE_ICON_SIZE, REMOVE_ICON_SIZE)
	button:SetNormalTexture(REMOVE_ICON)
	button:SetPushedTexture(REMOVE_ICON_DOWN)
	button:SetHighlightTexture(REMOVE_ICON, "ADD")
	button:SetScript("OnClick", OnDeleteButtonClick)
	button:SetScript("OnReceiveDrag", TakeCursorItem)
	ns.SetupRestockerTooltip(button, L["RESTOCKER_REMOVE_TOOLTIP"], L["RESTOCKER_REMOVE_TOOLTIP_UNDO"])
	return button
end

--------------------------------------------------------------------------------
-- Cell States
--------------------------------------------------------------------------------

local CELL_ON, CELL_OFF, CELL_NOT_APPLICABLE = "on", "off", "na"

local CHECK_TEXTURE = "Interface\\Buttons\\UI-CheckBox-Check"
local CHECK_SIZE = 16
local DASH_WIDTH = 7
local DASH_HEIGHT = 2

--[[
    Reading and writing one item flag per column, so a cell needs no knowledge of
    which one it is beyond its key.

    The nil defaults are load-bearing and differ per flag: buyFromMerchant and
    upgrade default ON when unset, buyExtra defaults OFF. A plain `not` on the
    first two would read nil as false and switch them on, which is backwards.
]]
local COLUMN_STATE = {
	withdraw = function(item)
		return item.restockFromBank and CELL_ON or CELL_OFF
	end,
	deposit = function(item)
		return item.stashToBank and CELL_ON or CELL_OFF
	end,
	buy = function(item)
		return (item.buyFromMerchant == nil or item.buyFromMerchant) and CELL_ON or CELL_OFF
	end,
	extra = function(item)
		--[[
		    Extra rides on top of Buy: ns.RestockFromMerchant never reaches an item
		    with Buy off, so the cell says "not applicable" rather than "off".
		]]
		if not (item.buyFromMerchant == nil or item.buyFromMerchant) then
			return CELL_NOT_APPLICABLE
		end
		return item.buyExtra and CELL_ON or CELL_OFF
	end,
	upgrade = function(item)
		--[[
		    Only vendor-sold staples sit on a ladder; most of a real list cannot
		    upgrade at all, which is not the same as choosing not to.
		]]
		if not ns.CanUpgradeRestockItem(item.itemID) then
			return CELL_NOT_APPLICABLE
		end
		return (item.upgrade ~= false) and CELL_ON or CELL_OFF
	end,
}

local COLUMN_TOGGLE = {
	withdraw = function(item)
		item.restockFromBank = not item.restockFromBank
	end,
	deposit = function(item)
		item.stashToBank = not item.stashToBank
	end,
	buy = function(item)
		if item.buyFromMerchant == nil then
			item.buyFromMerchant = false -- nil defaults to true, so toggle to false
		else
			item.buyFromMerchant = not item.buyFromMerchant
		end
	end,
	extra = function(item)
		item.buyExtra = not item.buyExtra -- nil defaults to false
	end,
	upgrade = function(item)
		if item.upgrade == nil then
			item.upgrade = false -- nil defaults to true, so toggle to false
		else
			item.upgrade = not item.upgrade
		end
	end,
}

--[[
    Writing one flag outright, for the column menus, which set a whole column
    rather than flipping each row. Always an explicit boolean: the nil defaults
    above mean "unset", and a column the player just set is not unset.
]]
local COLUMN_SET = {
	withdraw = function(item, isOn)
		item.restockFromBank = isOn
	end,
	deposit = function(item, isOn)
		item.stashToBank = isOn
	end,
	buy = function(item, isOn)
		item.buyFromMerchant = isOn
	end,
	extra = function(item, isOn)
		item.buyExtra = isOn
	end,
	upgrade = function(item, isOn)
		item.upgrade = isOn
	end,
}

-- Attach the shared hover highlight used by every clickable cell.
local function AddCellHighlight(cell)
	cell:SetHighlightTexture(CELL_HIGHLIGHT, "ADD")
	local highlight = cell:GetHighlightTexture()
	if highlight then
		highlight:SetVertexColor(GOLD.r, GOLD.g, GOLD.b, CELL_HIGHLIGHT_ALPHA)
	end
end

--------------------------------------------------------------------------------
-- Column Menus
--------------------------------------------------------------------------------

--[[
    A toggle column's heading opens this: switch the column on, or off, for every
    row shown. With a category picked or the filter typed in, that is "stop
    buying every quest item" in two clicks rather than one per row.

    Rows where the column cannot apply are left alone and left out of the count,
    so the number on the menu is the number of rows it will change the state of
    or confirm: an item with no upgrade ladder has nothing to switch, and Extra
    rides on Buy.

    An AceGUI pullout like the reputation menu's, for the same reason (no shared
    Blizzard dropdown frames, so no taint), and closed by the same events: a
    second click on its heading, a pick, the window hiding, and any redraw.

    ONE pullout, built on first use and cleared at each open, as the list menu
    does (Restocker-Window-List-Bar.lua) and for its reason: these entries are
    Execute items, which close their own pullout after their OnClick returns, so
    a pullout released by the redraw that OnClick causes would be freed with its
    own item's handler still running.
]]
local COLUMN_MENU_WIDTH = 200 -- holds the longer of the two lines, whatever the heading's width

local columnPullout
local columnPulloutAnchor = nil

local function CloseColumnMenu()
	if columnPullout and columnPulloutAnchor then
		columnPulloutAnchor = nil
		columnPullout:Close()
	end
end

ns.CloseRestockColumnMenu = CloseColumnMenu

-- How many of the rows shown this column can be set on.
local function CountSettableRows(key)
	local count = 0
	for _, item in ipairs(shownItems) do
		if COLUMN_STATE[key](item) ~= CELL_NOT_APPLICABLE then
			count = count + 1
		end
	end
	return count
end

--[[
    Set one column on every row shown. Each column writes only its own flag, and
    whether it applies is read from the row as it stands before the write: Extra
    applies only where Buy is already on.
]]
local function SetColumnOnShownRows(key, isOn)
	for _, item in ipairs(shownItems) do
		if COLUMN_STATE[key](item) ~= CELL_NOT_APPLICABLE then
			COLUMN_SET[key](item, isOn)
		end
	end
	ns.UpdateRestockList()
end

function ns.OpenRestockColumnMenu(column, anchor)
	-- A click on the open menu's own heading closes it rather than reopening it.
	if columnPulloutAnchor == anchor then
		CloseColumnMenu()
		return
	end
	ns.CloseRestockMenus()

	if not columnPullout then
		columnPullout = AceGUI:Create("Dropdown-Pullout")
		columnPullout:SetCallback("OnClose", function()
			columnPulloutAnchor = nil
		end)
	end
	columnPullout:Clear()

	local title = AceGUI:Create("Dropdown-Item-Header")
	title:SetText(L[column.title])
	columnPullout:AddItem(title)

	local count = CountSettableRows(column.key)
	local choices = {
		{ label = "RESTOCKER_BULK_ON", isOn = true },
		{ label = "RESTOCKER_BULK_OFF", isOn = false },
	}
	for _, choice in ipairs(choices) do
		local entry = AceGUI:Create("Dropdown-Item-Execute")
		entry:SetText(string.format(L[choice.label], count))
		entry:SetDisabled(count == 0)
		entry:SetCallback("OnClick", function()
			SetColumnOnShownRows(column.key, choice.isOn)
		end)
		columnPullout:AddItem(entry)
	end

	columnPulloutAnchor = anchor
	columnPullout:SetWidth(COLUMN_MENU_WIDTH)
	columnPullout:Open("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
end

--[[
    Why a cell cannot be set on its row, by column. A dead cell's tooltip says
    this in place of the column's general explanation, which would describe a
    switch the row does not have.
]]
local NOT_APPLICABLE_REASON = {
	extra = "RESTOCKER_EXTRA_NOT_APPLICABLE",
	reputation = "RESTOCKER_REPUTATION_NOT_APPLICABLE",
	upgrade = "RESTOCKER_UPGRADE_NOT_APPLICABLE",
}

--[[
    The part of a cell's state every column shares: whether it takes clicks, and
    the dash's tone. The cell's tooltip reads the same flag, to give the reason
    above in place of the column's explanation (SetupCellTooltip).

    Alpha rather than Disable() on the highlight: a dead cell still has to answer
    "why can this not be set?", and Disable() would take the tooltip away with the
    clicks.
]]
local function SetCellActive(cell, isActive)
	cell.isActive = isActive
	local tone = isActive and DASH_OFF or DASH_NOT_APPLICABLE
	cell.dash:SetColorTexture(tone.r, tone.g, tone.b, 1)
	local highlight = cell:GetHighlightTexture()
	if highlight then
		highlight:SetAlpha(isActive and 1 or 0)
	end
end

-- Paint a glyph cell for one of the three states.
local function SetCell(cell, state)
	cell.check:SetShown(state == CELL_ON)
	cell.dash:SetShown(state ~= CELL_ON)
	SetCellActive(cell, state ~= CELL_NOT_APPLICABLE)
end

--[[
    Paint the reputation cell. It names its standing only when one is set, in
    amber so a gated row stands out. With none it draws the dash every other
    column draws for off, rather than a word: "Any" is the absence of a
    requirement, and a column of thirty identical words buries the one row that
    sets one.

    It rides on Buy the way Extra does -- a standing only gates buying -- so with
    Buy off it is not applicable: the dimmer dash, and no menu. The standing
    itself stays on the row, and shows again when Buy comes back on.
]]
local function SetReputationCell(cell, item)
	local buys = item.buyFromMerchant == nil or item.buyFromMerchant
	local isSet = buys and (item.reaction or 0) > 0
	cell.text:SetShown(isSet)
	cell.dash:SetShown(not isSet)
	if isSet then
		cell.text:SetText(ns.GetStandingLabel(ReputationStandingByValue(item.reaction).value))
		cell.text:SetTextColor(REPUTATION_SET.r, REPUTATION_SET.g, REPUTATION_SET.b)
	end
	SetCellActive(cell, buys)
end

--[[
    A cell's tooltip: its column's title and explanation, or -- on a row where the
    cell cannot be set -- the title and the reason why not.
]]
local function SetupCellTooltip(cell, column)
	local reason = NOT_APPLICABLE_REASON[column.key]
	cell:SetScript("OnEnter", function(self)
		if reason and not self.isActive then
			ns.ShowRestockerTooltip(self, L[column.title], L[reason])
		else
			ns.ShowRestockerTooltip(self, L[column.title], unpack(TooltipBody(column)))
		end
	end)
	cell:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

local function CreateGlyphCell(row, column)
	local cell = CreateFrame("Button", nil, row)
	cell:SetSize(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH, ns.restockButtonHeight)

	local check = cell:CreateTexture(nil, "ARTWORK")
	check:SetTexture(CHECK_TEXTURE)
	check:SetSize(CHECK_SIZE, CHECK_SIZE)
	check:SetPoint("CENTER")
	check:SetVertexColor(GOLD.r, GOLD.g, GOLD.b)
	cell.check = check

	local dash = cell:CreateTexture(nil, "ARTWORK")
	dash:SetSize(DASH_WIDTH, DASH_HEIGHT)
	dash:SetPoint("CENTER")
	cell.dash = dash

	AddCellHighlight(cell)

	local toggle = COLUMN_TOGGLE[column.key]
	cell:SetScript("OnClick", function(self)
		if ns.AddRestockItemFromCursor() then
			return
		end
		-- Reads self.item, rebound by UpdateRestockListRow like every other control
		if not (self.isActive and self.item) then
			return
		end
		toggle(self.item)
		ns.UpdateRestockListRow(row, self.item)
		-- Buy decides whether a short row is an order, so the count under the list can move.
		ns.UpdateRestockStatus()
	end)
	cell:SetScript("OnReceiveDrag", TakeCursorItem)

	SetupCellTooltip(cell, column)
	return cell
end

--[[
    The reputation cell. A menu, not a toggle, so it names the standing it
    requires and opens the standings list on click. SetReputationCell above
    paints it.
]]
local function CreateReputationCell(row, column)
	local cell = CreateFrame("Button", nil, row)
	cell:SetSize(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH, ns.restockButtonHeight)
	cell.isActive = true

	local fontString = cell:CreateFontString(nil, "ARTWORK", BUTTON_FONT)
	fontString:SetPoint("CENTER")
	cell.text = fontString

	local dash = cell:CreateTexture(nil, "ARTWORK")
	dash:SetSize(DASH_WIDTH, DASH_HEIGHT)
	dash:SetPoint("CENTER")
	cell.dash = dash

	AddCellHighlight(cell)

	cell:SetScript("OnClick", function(self)
		if ns.AddRestockItemFromCursor() then
			return
		end
		if not (self.isActive and self.item) then
			return
		end
		OpenReputationMenu(self, row)
	end)
	cell:SetScript("OnReceiveDrag", TakeCursorItem)

	SetupCellTooltip(cell, column)
	return cell
end

function ns.CreateRestockListRow(item)
	--[[
	    Born parented to the hidden frame and positioned by ns.UpdateRestockList, which
	    places every row by absolute index rather than chaining them to each other.
	]]
	local frame = CreateFrame("Frame", nil, ns.restockHiddenFrame)
	frame:SetSize(ns.restockWindow.scrollChild:GetWidth(), ns.restockRowHeight)
	frame.item = item

	--[[
	    The stripe belongs to the POSITION, not the item: rows come from a pool and
	    are reused at whatever index the next render puts them at, so every row owns
	    a stripe and ns.UpdateRestockList decides which ones show.
	]]
	local stripe = frame:CreateTexture(nil, "BACKGROUND")
	stripe:SetAllPoints(frame)
	stripe:SetColorTexture(WHITE.r, WHITE.g, WHITE.b, ROW_STRIPE_ALPHA)
	frame.stripe = stripe

	-- ICON, with an invisible button over it that shows the item tooltip on hover
	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetSize(ICON_SIZE, ICON_SIZE)
	icon:SetPoint("LEFT", frame, "LEFT", ROW_INSET, 0)
	icon:SetTexCoord(0.07, 0.93, 0.07, 0.93) -- trim the default icon border
	frame.icon = icon

	-- RIGHT EDGE: the remove control, then the columns walking left from it.
	frame.removeButton = CreateDeleteButton(frame)
	frame.cells, frame.firstCell = LayoutColumns(frame.removeButton, function(column)
		if column.isText then
			return CreateReputationCell(frame, column)
		end
		return CreateGlyphCell(frame, column)
	end)

	-- The Keep box hangs off the leftmost column, beside the name it belongs to.
	frame.amountBox = CreateAmountEditBox(frame)
	frame.amountBox:SetPoint("RIGHT", frame.firstCell, "LEFT", -KEEP_GAP, 0)
	frame.amountBox:SetWidth(ns.restockAmountWidth)

	--[[
	    ITEM NAME fills whatever the controls leave. Anchored on both sides with no
	    word wrap, so a long name truncates instead of running under the Keep box.
	]]
	local text = frame:CreateFontString(nil, "OVERLAY", nil)
	text:SetFontObject("GameFontHighlight")
	text:SetJustifyH("LEFT")
	text:SetWordWrap(false)
	text:SetPoint("LEFT", icon, "RIGHT", ICON_TEXT_GAP, 0)
	text:SetPoint("RIGHT", frame.amountBox, "LEFT", -NAME_COLUMN_GAP, 0)
	frame.text = text

	--[[
	    The icon and the name together are the row's tooltip target: a FontString
	    takes no mouse, so an invisible button covers both. It shows the item
	    tooltip, and takes an item dropped on it like the rest of the window does;
	    there is nothing else for a row click to open.
	]]
	local nameButton = CreateFrame("Button", nil, frame)
	nameButton:SetPoint("TOPLEFT", icon, "TOPLEFT", 0, 0)
	nameButton:SetPoint("BOTTOMRIGHT", text, "BOTTOMRIGHT", 0, 0)
	nameButton:SetScript("OnClick", TakeCursorItem)
	nameButton:SetScript("OnReceiveDrag", TakeCursorItem)
	nameButton:SetScript("OnEnter", function(button)
		local rowItem = frame.item
		if not (rowItem and rowItem.itemID) then
			return
		end
		GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
		-- Prefer the cached colored link; fall back to a bare item: link (always valid)
		local info = ns.GetItemData(rowItem.itemID)
		GameTooltip:SetHyperlink((info and info.itemLink) or ("item:" .. rowItem.itemID))
		GameTooltip:Show()
	end)
	nameButton:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	frame.nameButton = nameButton

	table.insert(ns.restockRowPool, frame)
	return frame
end

--[[
    The client's name for the item whenever it has one, written onto the row so the
    filter and the sort read it too; the saved name stands in only while the item
    is still loading. Returns the client's item data, or nil while it loads.
]]
local function RefreshItemName(item)
	local info = ns.GetItemData(item.itemID)
	if info and info.itemName and info.itemName ~= "" then
		item.itemName = info.itemName
	end
	return info
end

function ns.UpdateRestockListRow(row, item)
	row.item = item
	-- Every control carries its own item rather than resolving through a parent.
	row.removeButton.item = item
	row.amountBox.item = item
	for _, cell in pairs(row.cells) do
		cell.item = item
	end

	--[[
	    Column widths can resolve after a row was built (see
	    ns.RefreshRestockColumnHeader), so re-read them here rather than only at
	    creation -- the Keep box's too, since the item name stops at its left
	    edge. Guarded on a serial, which makes this seven SetWidth calls once and
	    a single comparison thereafter.
	]]
	if row.columnSerial ~= ns.restockColumnWidthSerial then
		row.columnSerial = ns.restockColumnWidthSerial
		row.amountBox:SetWidth(ns.restockAmountWidth)
		ApplyColumnWidths(row.cells)
	end

	for _, column in ipairs(COLUMNS) do
		if not column.isText then
			SetCell(row.cells[column.key], COLUMN_STATE[column.key](item))
		end
	end
	SetReputationCell(row.cells.reputation, item)

	-- Icon + quality-colored name (from the item cache; falls back until it is known)
	local info = RefreshItemName(item)
	if info then
		row.icon:SetTexture(info.itemTexture)
		local quality = ITEM_QUALITY_COLORS[info.itemRarity or 1]
		if quality then
			row.text:SetTextColor(quality.r, quality.g, quality.b)
		else
			row.text:SetTextColor(WHITE.r, WHITE.g, WHITE.b)
		end
	else
		row.icon:SetTexture("Interface\\ICONS\\INV_Misc_QuestionMark")
		row.text:SetTextColor(WHITE.r, WHITE.g, WHITE.b)
	end

	row.text:SetText(item.itemName)
	row.amountBox:SetText(tostring(item.amount or 0))
	PaintKeep(row.amountBox, item)
end

--------------------------------------------------------------------------------
-- Update
--------------------------------------------------------------------------------

--[[
    Repaint what the bags decide and nothing else: each shown row's Keep box, and
    the orders counted under the list. For the moments the bags change with the
    window open -- a merchant or bank visit filling them, a Keep amount being
    typed -- where the rows themselves have not moved and a full redraw would
    close an open menu for nothing.
]]
function ns.RefreshRestockShortfall()
	for _, row in ipairs(ns.restockRowPool) do
		if row.isInUse then
			PaintKeep(row.amountBox, row.item)
		end
	end
	ns.UpdateRestockStatus()
end

--[[
    Use Restock List Food & Water Last reads which items the list in use holds,
    so a redraw that changed them asks for a macro rebuild. Most redraws change
    nothing: a filter keystroke, a category click, the window opening.
]]
local lastListName
local lastListMembers = {}

local function ListMembershipChanged(listName, list)
	local changed = listName ~= lastListName
	local count = 0
	for itemID in pairs(list) do
		count = count + 1
		if not lastListMembers[itemID] then
			changed = true
		end
	end
	for _ in pairs(lastListMembers) do
		count = count - 1
	end
	if not changed and count == 0 then
		return false
	end

	lastListName = listName
	wipe(lastListMembers)
	for itemID in pairs(list) do
		lastListMembers[itemID] = true
	end
	return true
end

-- A row drawn before the client had its item, repainted in place once the answer lands.
function ns.RepaintRestockRows(itemID)
	for _, row in ipairs(ns.restockRowPool) do
		if row.isInUse and row.item and row.item.itemID == itemID then
			ns.UpdateRestockListRow(row, row.item)
		end
	end
end

function ns.UpdateRestockList()
	--[[
	    Rows are about to be released to the pool and rebound to different items, so
	    an open reputation menu has to go first -- it is anchored to a cell, and its
	    pick would land on whatever item that cell ends up holding. A column menu
	    goes with it: its count is of the rows shown, which are about to change.
	    So does the bag menu, which offers what the list lacks and would go on
	    offering it after the list, or the list in use, has changed.
	]]
	ns.CloseReputationMenu()
	ns.CloseRestockColumnMenu()
	ns.CloseRestockBagMenu()

	local settings = ns.restockSettings
	local currentList = settings.lists[settings.currentList]

	-- Every list edit redraws through here.
	if ListMembershipChanged(settings.currentList, currentList) and ns.db.profile.useRestockLast then
		ns.RequestUpdate()
	end

	--[[
	    Gather items (the list is keyed by itemID, so walk it with pairs), each
	    under the client's current name. A row the client cannot name yet is
	    watched while the window is open, and repainted as its answer arrives.
	]]
	local watchColdRows = ns.restockWindow and ns.restockWindow:IsShown()
	local wasWatching = next(ns.restockColdRows) ~= nil
	wipe(ns.restockColdRows)
	wipe(restockItemList)
	for _, item in pairs(currentList) do
		if not RefreshItemName(item) and watchColdRows then
			ns.restockColdRows[item.itemID] = true
		end
		table.insert(restockItemList, item)
	end
	if wasWatching ~= (next(ns.restockColdRows) ~= nil) then
		ns.SyncRestockItemInfoSubscription()
	end

	--[[
	    One view per redraw: each item's group resolved once and the filter lowered
	    once, shared by the category pane and the render list.
	]]
	local view = ns.BuildRestockView(restockItemList)
	ns.UpdateRestockGroupPane(restockItemList, view)
	local renderList = ns.BuildRestockRenderList(restockItemList, view)

	-- Release every pooled item row back to the hidden frame
	for _, row in ipairs(ns.restockRowPool) do
		row.isInUse = false
		row:SetParent(ns.restockHiddenFrame)
		row:Hide()
	end

	--[[
	    Every entry is one row tall, so the running offset is just an accumulator.
	    It also gives the scroll child its height, which is what keeps the scroll
	    bar's range honest.
	]]
	local scrollChild = ns.restockWindow.scrollChild
	local offset = 0
	-- A late column measurement lands here first; the rows pick it up below.
	ns.RefreshRestockColumnHeader()
	wipe(shownItems)
	for index, entry in ipairs(renderList) do
		local row = ns.AcquireRestockListRow(entry.item)

		shownItems[index] = entry.item
		row.isInUse = true
		row:SetParent(scrollChild)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -offset)
		row:SetSize(scrollChild:GetWidth(), ns.restockRowHeight)
		-- Every second row, counting the first as bare so the list starts flush.
		row.stripe:SetShown(index % 2 == 0)
		ns.UpdateRestockListRow(row, entry.item)
		row:Show()
		offset = offset + ns.restockRowHeight
	end

	scrollChild:SetHeight(math.max(1, offset))

	--[[
	    What stands in for the rows when there are none to draw: the empty list's
	    invitation, or one line saying why a list that has items is showing none of
	    them -- the filter, or a category whose last item just left.
	]]
	local nothingShown = nil
	if #renderList == 0 and #restockItemList > 0 then
		nothingShown = view.filter and L["RESTOCKER_NO_MATCH_FILTER"] or L["RESTOCKER_NO_MATCH_GROUP"]
	end
	ns.UpdateRestockEmptyState(#restockItemList == 0, nothingShown)
	ns.UpdateRestockStatus()
end

--------------------------------------------------------------------------------
-- Row Pool
--------------------------------------------------------------------------------

function ns.AcquireRestockListRow(item)
	for _, frame in ipairs(ns.restockRowPool) do
		if not frame.isInUse then
			return frame
		end
	end
	return ns.CreateRestockListRow(item)
end
