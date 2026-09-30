local _, ns = ...
local L = ns.L
local BUTTON_FONT = ns.RESTOCK_BUTTON_FONT

--------------------------------------------------------------------------------
-- Category Pane
--------------------------------------------------------------------------------

--[[
    The list's item types down the left of the window, one per line with a count,
    and "All items" above them. It names every type at once and says how many of
    each there are, which no in-list section band can do: a band costs a row per
    group and only describes the stretch of list on screen.

    Rows are pooled like the item rows, because the set of types is whatever the
    lists currently hold -- adding a bandage can bring a category into being, and
    removing the last one takes it away again.
]]

--------------------------------------------------------------------------------
-- Category Selection
--------------------------------------------------------------------------------

--[[
    Which item type the list is showing, or nil for all of them. View state for one
    sitting, like ns.restockNewItems: never persisted, and reset when the window closes,
    so a session that ended filtered down to Quest items does not open on an
    apparently half-empty list days later.

    Held as the group's own display name rather than an index, because the list of
    groups is derived from whatever the list happens to contain and changes as
    items are added and removed.
]]
ns.restockSelectedGroup = nil

function ns.SelectRestockGroup(group)
	ns.restockSelectedGroup = group
	ns.UpdateRestockList()
	local scrollFrame = ns.restockWindow and ns.restockWindow.scrollFrame
	if scrollFrame then
		scrollFrame:SetVerticalScroll(0) -- a new selection starts at its top
	end
end

function ns.ClearRestockGroupSelection()
	ns.restockSelectedGroup = nil
end

--[[
    The two greys are this pane's own states, not palette roles: an unselected
    type, and its count, a step quieter than its label.
]]
local GOLD = ns.COLORS_RGB.TITLE
local ROW_LABEL = ns.HexToRGB(ns.RESTOCKER_WINDOW_COLORS.ROW_LABEL)
local ROW_COUNT = ns.HexToRGB(ns.RESTOCKER_WINDOW_COLORS.ROW_COUNT)

local GROUP_ROW_HEIGHT = 20
local GROUP_ROW_INSET = 8
local GROUP_COUNT_WIDTH = 30

--[[
    The pane is as wide as the longest type name it actually has to show, because
    a guessed width truncates the moment it is wrong: type names come from
    C_Item.GetItemInfo and are localized by the CLIENT, so no fixed number is right in
    every locale, and "Miscellaneous" already overruns a guess that looked generous
    in English.

    Clamped at both ends. The floor keeps a short list from drawing a sliver of a
    pane; the ceiling is what MIN_WIDTH is set against, so the table below always
    keeps enough room for a readable item name however long a type name gets. See
    WINDOW GEOMETRY in Restocker-Window.lua.
]]
local GROUP_PANE_MIN_WIDTH = 132
local GROUP_PANE_MAX_WIDTH = 180

ns.restockGroupPaneWidth = GROUP_PANE_MIN_WIDTH
ns.RESTOCK_GROUP_PANE_GAP = 8 -- pane to table

-- Scratch FontString used only to measure the row font; never shown.
local measureFontString

--[[
    Size the pane to the widest label it will draw. Called once before the window
    is laid out, since the table's left edge is anchored past the pane.

    Types are read from the saved rows rather than from C_Item.GetItemInfo: this runs at
    window build time, when the item cache may still be cold, and the stored label
    is the same string the pane goes on to display.
]]
function ns.ResolveRestockGroupPaneWidth()
	if not measureFontString then
		measureFontString = (ns.restockHiddenFrame or UIParent):CreateFontString(nil, "ARTWORK", BUTTON_FONT)
		measureFontString:Hide()
	end

	local labels = {
		[L["RESTOCKER_GROUP_ALL"]] = true,
		[L["RESTOCKER_GROUP_NEW"]] = true,
		[L["RESTOCKER_GROUP_OTHER"]] = true,
	}
	local settings = ns.restockSettings
	for _, list in pairs((settings and settings.lists) or {}) do
		for _, item in pairs(list) do
			if type(item) == "table" and item.itemType and item.itemType ~= "" then
				labels[item.itemType] = true
			end
		end
	end

	local widest = 0
	for label in pairs(labels) do
		measureFontString:SetText(label)
		local width = measureFontString:GetStringWidth() or 0
		if width > widest then
			widest = width
		end
	end

	-- Name column, then the gap and the count column, then both insets.
	local needed = math.ceil(widest) + 4 + GROUP_COUNT_WIDTH + (GROUP_ROW_INSET * 2)
	ns.restockGroupPaneWidth = math.max(GROUP_PANE_MIN_WIDTH, math.min(GROUP_PANE_MAX_WIDTH, needed))
end

local function GetCategoryRow()
	for _, row in ipairs(ns.restockCategoryRowPool) do
		if not row.isInUse then
			return row
		end
	end

	local row = CreateFrame("Button", nil, ns.restockHiddenFrame)
	row:SetHeight(GROUP_ROW_HEIGHT)

	local selection = row:CreateTexture(nil, "BACKGROUND")
	selection:SetAllPoints(row)
	selection:SetColorTexture(GOLD.r, GOLD.g, GOLD.b, 0.14)
	selection:Hide()
	row.selected = selection

	row:SetHighlightTexture("Interface\\Buttons\\UI-Listbox-Highlight2", "ADD")
	local highlight = row:GetHighlightTexture()
	if highlight then
		highlight:SetVertexColor(GOLD.r, GOLD.g, GOLD.b, 0.25)
	end

	local count = row:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(BUTTON_FONT)
	count:SetWidth(GROUP_COUNT_WIDTH)
	count:SetJustifyH("RIGHT")
	count:SetPoint("RIGHT", row, "RIGHT", -GROUP_ROW_INSET, 0)
	row.count = count

	--[[
	    Anchored on both sides with no wrap, so a long type name truncates inside
	    the pane instead of running under its own count.
	]]
	local name = row:CreateFontString(nil, "OVERLAY")
	name:SetFontObject(BUTTON_FONT)
	name:SetJustifyH("LEFT")
	name:SetWordWrap(false)
	name:SetPoint("LEFT", row, "LEFT", GROUP_ROW_INSET, 0)
	name:SetPoint("RIGHT", count, "LEFT", -4, 0)
	row.name = name

	ns.SetRestockControlClick(row, function(self)
		ns.SelectRestockGroup(self.group)
	end)

	table.insert(ns.restockCategoryRowPool, row)
	return row
end

-- Paint one category row. `group` is nil for the "All items" entry.
local function SetCategoryRow(row, label, count, group, isSelected)
	row.group = group
	row.name:SetText(label)
	row.count:SetText(tostring(count))
	row.selected:SetShown(isSelected)
	--[[
	    The selected row goes gold and the rest stay muted, which is the same
	    on/off vocabulary the toggle columns use. Zero-count categories never
	    render, so there is no third state to draw here.
	]]
	if isSelected then
		row.name:SetTextColor(GOLD.r, GOLD.g, GOLD.b)
		row.count:SetTextColor(GOLD.r, GOLD.g, GOLD.b)
	else
		row.name:SetTextColor(ROW_LABEL.r, ROW_LABEL.g, ROW_LABEL.b)
		row.count:SetTextColor(ROW_COUNT.r, ROW_COUNT.g, ROW_COUNT.b)
	end
end

function ns.CreateRestockGroupPane(parent, listInset, topInset)
	local pane = CreateFrame("Frame", nil, parent)
	-- The same top and bottom insets the table uses, so the two line up row for row.
	pane:SetPoint("TOPLEFT", listInset, "TOPLEFT", 8, -topInset)
	pane:SetPoint("BOTTOMLEFT", listInset, "BOTTOMLEFT", 8, ns.RESTOCK_LIST_BOTTOM_INSET)
	pane:SetWidth(ns.restockGroupPaneWidth)

	--[[
	    Its own scroll frame, but a bare one driven by the wheel rather than
	    UIPanelScrollFrameTemplate. That template's bar would take 22px off a
	    132px pane, and it would take it permanently: the type list only overflows
	    at the smallest window heights, so the bar would be reserving a fifth of
	    the pane's width to be invisible almost all of the time.
	]]
	local scroll = CreateFrame("ScrollFrame", nil, pane)
	scroll:SetAllPoints(pane)

	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(scroll:GetWidth(), 1)
	scroll:SetScrollChild(child)

	scroll:EnableMouseWheel(true)
	scroll:SetScript("OnMouseWheel", function(self, delta)
		--[[
		    Clamped both ends: an unclamped SetVerticalScroll happily scrolls a short
		    list off the top and leaves the pane looking empty.
		]]
		local maxScroll = math.max(0, self:GetScrollChild():GetHeight() - self:GetHeight())
		local target = self:GetVerticalScroll() - (delta * GROUP_ROW_HEIGHT * 2)
		self:SetVerticalScroll(math.max(0, math.min(maxScroll, target)))
	end)
	pane.scrollFrame = scroll
	pane.scrollChild = child

	-- A hairline down the right edge, separating the pane from the table.
	local edge = pane:CreateTexture(nil, "ARTWORK")
	edge:SetPoint("TOPRIGHT", pane, "TOPRIGHT", 0, 0)
	edge:SetPoint("BOTTOMRIGHT", pane, "BOTTOMRIGHT", 0, 0)
	edge:SetWidth(1)
	edge:SetColorTexture(GOLD.r, GOLD.g, GOLD.b, 0.12)

	ns.restockGroupPane = pane
	return pane
end

--[[
    Refill the pane from the current list. Called by ns.UpdateRestockList, so the counts
    and the set of categories track every add, remove and keystroke in the filter
    box without anything else having to remember to ask.
]]
function ns.UpdateRestockGroupPane(items, view)
	local pane = ns.restockGroupPane
	if not pane then
		return
	end

	for _, row in ipairs(ns.restockCategoryRowPool) do
		row.isInUse = false
		row:SetParent(ns.restockHiddenFrame)
		row:Hide()
	end

	local groups, total = ns.BuildRestockGroupList(items, view)
	local child = pane.scrollChild
	--[[
	    GetWidth reads 0 until the frame has been laid out, which the very first
	    Update can beat. Falling back to the pane's own fixed width keeps that first
	    pass from building a column of zero-width rows that never get re-measured,
	    since a row is only resized when the pane is refilled.
	]]
	local width = pane.scrollFrame:GetWidth()
	if not width or width <= 0 then
		width = ns.restockGroupPaneWidth
	end
	local offset = 0

	local function Place(label, count, group)
		local row = GetCategoryRow()
		row.isInUse = true
		row:SetParent(child)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -offset)
		row:SetWidth(width)
		SetCategoryRow(row, label, count, group, ns.restockSelectedGroup == group)
		row:Show()
		offset = offset + GROUP_ROW_HEIGHT
	end

	Place(L["RESTOCKER_GROUP_ALL"], total, nil)
	offset = offset + 6 -- a break under All, which is not one of the types

	local selectedShown = (ns.restockSelectedGroup == nil)
	for _, group in ipairs(groups) do
		Place(group.name, group.count, group.name)
		if group.name == ns.restockSelectedGroup then
			selectedShown = true
		end
	end

	--[[
	    A category only appears while it holds something, so filtering everything out
	    of the SELECTED one would take its row away with it -- leaving an empty list,
	    no visible selection, and nothing on screen explaining either. Keep it,
	    showing the zero: the list is empty because this category is selected and the
	    filter matches none of it, and the row is still there to click away from.
	]]
	if not selectedShown then
		Place(ns.restockSelectedGroup, 0, ns.restockSelectedGroup)
	end

	child:SetWidth(width)
	child:SetHeight(math.max(1, offset))
end
