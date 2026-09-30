local _, ns = ...
local L = ns.L

--[[
    The grid the Restock List is drawn on: which columns exist, how wide each one
    has to be, where every cell sits, and the header above them.

    Restocker-Window-Rows.lua builds the controls that fill this grid. The split is
    deliberate: the header and the rows have to line up exactly, so the widths, the
    gaps and the colors they share are defined once here, and the layout walk that
    places them is called by both.
]]

--------------------------------------------------------------------------------
-- Reputation Standings
--------------------------------------------------------------------------------

-- The standings themselves are Data/Data.lua's; these two format them.
local REPUTATION_STANDINGS = ns.REPUTATION_STANDINGS

local function ReputationStandingByValue(value)
	value = value or 0
	for _, standing in ipairs(REPUTATION_STANDINGS) do
		if standing.value == value then
			return standing
		end
	end
	return REPUTATION_STANDINGS[1] -- default to "Any"
end

-- Menu label, e.g. "Honored  (10% off)"
local function ReputationMenuText(standing)
	if standing.discount and standing.discount > 0 then
		return string.format(L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"], standing.label, standing.discount)
	end
	return standing.label
end

--------------------------------------------------------------------------------
-- Row Metrics
--------------------------------------------------------------------------------

--[[
    Nothing in a row carries a hardcoded size: a caption that outgrows its button
    is clipped, not wrapped. Every control measures the font it actually draws
    with, so a larger UI font, or a longer word in another locale, widens the
    control instead of overflowing it.

    ns.restockRowHeight and ns.restockButtonHeight start at the values the fixed layout used
    and are recomputed by ns.RefreshRestockRowMetrics when the window is built. With the
    stock font the measurement lands back on exactly these numbers.
]]
ns.restockRowHeight = 26
ns.restockButtonHeight = 22

--[[
    A row is one line and shows everything about its item: the six toggles are lit
    or dim glyphs in fixed columns under a header that names them, so the list
    answers "which of these buy from vendors?" by being looked at. Never hide a
    row's state behind an expander -- with only the open row showing anything, the
    list needs a marker to say which rows are worth opening and a panel to say
    where an open one stops, and it still cannot be read at a glance.
]]
--[[
    The font every control in the window measures itself against, shared with the
    category pane so the two halves cannot drift apart. On ns rather than a
    file-local for that reason alone.
]]
ns.RESTOCK_BUTTON_FONT = "GameFontNormalSmall"
local BUTTON_FONT = ns.RESTOCK_BUTTON_FONT
local BUTTON_PAD_X = 16 -- caption to button edge, both sides together
local BUTTON_PAD_Y = 8
local BUTTON_MIN_WIDTH = 28
local ROW_PAD_Y = 4 -- breathing room above and below the tallest control

-- Scratch FontString used only to measure BUTTON_FONT; never shown.
local measureFontString

local function MeasureFontString()
	if not measureFontString then
		measureFontString = (ns.restockHiddenFrame or UIParent):CreateFontString(nil, "ARTWORK", BUTTON_FONT)
		measureFontString:Hide()
	end
	return measureFontString
end

local function FontLineHeight()
	local fontString = MeasureFontString()
	fontString:SetText("Wg")
	local lineHeight = fontString:GetStringHeight()
	--[[
	    GetStringHeight reads 0 before the font is resolved; fall back to the
	    height that produces today's 22px button.
	]]
	if not lineHeight or lineHeight <= 0 then
		return 14
	end
	return lineHeight
end

--------------------------------------------------------------------------------
-- Columns
--------------------------------------------------------------------------------

--[[
    One definition drives the header and every row, so the two cannot drift apart:
    each walks this list from the right edge inward, and a column is as wide as
    its own header caption. A longer word in another locale widens that column and
    takes the room out of the item name, which is the only thing on the row that
    can absorb it.

    `gapBefore` opens a wider space where the meaning changes, and `group` names
    the band of columns it opens, drawn once above them. That band is what buys
    the short captions: "Take" and "Store" would be vague on their own and are
    exact under "Bank", and the width they save is width the item name gets. Six
    full-length captions do not fit beside a readable name at the minimum window
    width -- the name was down to 58 pixels -- so this is load-bearing, not taste.

    Every column carries its tooltip keys, so the header cell and the row cell
    explain themselves from one place.
]]
local COLUMNS = {
	{
		key = "withdraw",
		caption = "RESTOCKER_COLUMN_WITHDRAW",
		group = "RESTOCKER_ROW_BANK",
		title = "RESTOCKER_WITHDRAW_TOOLTIP_TITLE",
		body = { "RESTOCKER_WITHDRAW_TOOLTIP_BODY" },
	},
	{
		key = "deposit",
		caption = "RESTOCKER_COLUMN_DEPOSIT",
		title = "RESTOCKER_DEPOSIT_TOOLTIP_TITLE",
		body = { "RESTOCKER_DEPOSIT_TOOLTIP_BODY" },
	},
	{
		key = "buy",
		caption = "RESTOCKER_BUY_LABEL",
		group = "RESTOCKER_ROW_MERCHANT",
		title = "RESTOCKER_BUY_TOOLTIP_TITLE",
		body = { "RESTOCKER_BUY_TOOLTIP_BODY" },
		gapBefore = true,
	},
	{
		key = "extra",
		caption = "RESTOCKER_EXTRA_LABEL",
		title = "RESTOCKER_EXTRA_TOOLTIP_TITLE",
		body = { "RESTOCKER_EXTRA_TOOLTIP_STOCK" },
	},
	{
		--[[
		    The only column that draws text rather than a glyph: reputation has five
		    states, not two, so the cell has to name the one it is in.
		]]
		key = "reputation",
		caption = "RESTOCKER_COLUMN_REPUTATION",
		title = "RESTOCKER_REPUTATION_TOOLTIP_TITLE",
		body = { "RESTOCKER_REPUTATION_TOOLTIP_STANDING" },
		isText = true,
	},
	{
		key = "upgrade",
		caption = "RESTOCKER_ROW_UPGRADE",
		title = "RESTOCKER_UPGRADE_TOOLTIP_TITLE",
		body = { "RESTOCKER_UPGRADE_TOOLTIP_BODY" },
		gapBefore = true,
	},
}

local COLUMN_GAP = 5 -- between columns inside a group
local COLUMN_GROUP_GAP = 12 -- where the grouping changes
local COLUMN_PAD_X = 8 -- caption to column edge, both sides together
local COLUMN_MIN_WIDTH = 24

--[[
    A starting width, replaced once the font resolves (see ResolveColumns).
    The Keep box -- the row's amount, which is the name the code and the saved
    rows still use for it -- is measured like every other column: against its
    own caption AND against a four-digit count, since the edit box under it has
    to hold what the caption names. A fixed width truncates a longer locale's
    heading, so this one is measured too.

    The count is measured in the font the box DRAWS in, not the captions': an
    InputBoxTemplate field writes in ChatFontNormal, a good deal larger than the
    heading font, and "Keep" is too short a caption to cover for the difference
    the way "Amount" once did. Four digits is what a hunter's ammunition needs.
    The box's own padding is wider than a column's too: the template's border
    art sits inside its right edge.
]]
ns.restockAmountWidth = 44
local AMOUNT_DIGITS_SAMPLE = "8888"
local AMOUNT_BOX_FONT = "ChatFontNormal"
local AMOUNT_BOX_PAD_X = 14 -- digits to box edge, both sides together

--[[
    Starting widths are the English measurement, replaced once the font
    resolves (see ResolveColumns). Cells re-read them on every update (see
    UpdateRestockListRow), and because each cell is anchored to its
    neighbour's edge rather than to a fixed x, setting a new width is all it
    takes to reflow the whole chain.
]]
ns.restockColumnWidths = {
	withdraw = 38,
	deposit = 42,
	buy = 32,
	extra = 40,
	reputation = 54,
	upgrade = 60,
}
ns.restockColumnWidthSerial = 0 -- bumped when the widths change, so rows notice

local columnsResolved = false

-- Scratch FontString used only to measure the Keep box's own font; never shown.
local digitsFontString

local function MeasureDigitsFontString()
	if not digitsFontString then
		digitsFontString = (ns.restockHiddenFrame or UIParent):CreateFontString(nil, "ARTWORK", AMOUNT_BOX_FONT)
		digitsFontString:Hide()
	end
	return digitsFontString
end

-- Measure every column from its caption, or nil while the font is unresolved.
local function MeasureColumns()
	local fontString = MeasureFontString()
	local widths = {}
	for _, column in ipairs(COLUMNS) do
		fontString:SetText(L[column.caption])
		local width = fontString:GetStringWidth() or 0
		if column.isText then
			--[[
			    A text column has to hold its widest VALUE, not just its caption:
			    "Rep" is three letters and "Exalted" is seven.
			]]
			for _, standing in ipairs(REPUTATION_STANDINGS) do
				fontString:SetText(standing.label)
				local standingWidth = fontString:GetStringWidth() or 0
				if standingWidth > width then
					width = standingWidth
				end
			end
		end
		if width <= 0 then
			return nil -- font not resolved yet; the next list refresh measures again
		end
		widths[column.key] = math.max(COLUMN_MIN_WIDTH, math.ceil(width) + COLUMN_PAD_X)
	end

	fontString:SetText(L["RESTOCKER_COLUMN_AMOUNT"])
	local captionWidth = fontString:GetStringWidth() or 0
	local digits = MeasureDigitsFontString()
	digits:SetText(AMOUNT_DIGITS_SAMPLE)
	local digitsWidth = digits:GetStringWidth() or 0
	if captionWidth <= 0 or digitsWidth <= 0 then
		return nil
	end

	return widths,
		math.max(COLUMN_MIN_WIDTH, math.ceil(captionWidth) + COLUMN_PAD_X, math.ceil(digitsWidth) + AMOUNT_BOX_PAD_X)
end

--[[
    A column's tooltip body, resolved from its locale keys. Cached on the column:
    the strings never change after load, and both the header cell and every pooled
    row cell ask for the same list.
]]
local function TooltipBody(column)
	if not column.bodyText then
		local lines = {}
		for _, key in ipairs(column.body) do
			lines[#lines + 1] = L[key]
		end
		column.bodyText = lines
	end
	return column.bodyText
end

--[[
    Measure the column widths. Until the font resolves this measures again on
    every call (each list refresh makes one); a cheap no-op after that.
]]
local function ResolveColumns()
	if columnsResolved then
		return
	end
	local widths, amountWidth = MeasureColumns()
	if widths then
		ns.restockColumnWidths = widths
		ns.restockAmountWidth = amountWidth
		ns.restockColumnWidthSerial = ns.restockColumnWidthSerial + 1
		columnsResolved = true
	end
end

--[[
    Recompute the row and button heights from the font currently in use. Called
    when the window is built; safe to call again if a font add-on swaps fonts.
]]
function ns.RefreshRestockRowMetrics()
	local line = FontLineHeight()
	ns.restockButtonHeight = math.max(22, math.ceil(line + BUTTON_PAD_Y))
	ns.restockRowHeight = ns.restockButtonHeight + ROW_PAD_Y
	ns.restockColumnHeaderHeight = ns.restockButtonHeight + math.ceil(line) + 2
	ResolveColumns()
end

ns.restockColumnHeaderHeight = 38

--[[
    Size a button to the caption it is currently showing. The button keeps its
    anchor, so a row's controls chain from the right edge and simply push the
    item name's cutoff further left as they grow.
]]
local function FitButton(button)
	local fontString = button:GetFontString()
	if not fontString then
		return
	end
	local width = fontString:GetStringWidth()
	if not width or width <= 0 then
		return -- font not resolved yet; the button keeps the width it already has
	end
	button:SetWidth(math.max(BUTTON_MIN_WIDTH, math.ceil(width) + BUTTON_PAD_X))
	button:SetHeight(ns.restockButtonHeight)
end

ns.FitRestockButton = FitButton

--------------------------------------------------------------------------------
-- Row Shape
--------------------------------------------------------------------------------

--[[
    [icon] Item Name ....  [40]  [Take][Store]  [Buy][Extra][Rep]  [Upgrade] [x]

    The Keep box leads the strip, beside the name it belongs to. It is the one
    number that defines a row, and it turns yellow when the bags hold fewer, so it
    has to sit where the eye already is rather than six columns away.

    Everything right of it is laid out by walking COLUMNS from the remove
    control inward, which is exactly what the header does, so the two line up by
    construction rather than by matching offsets in two places. The Keep box
    then hangs off the leftmost column.

    Each cell anchors to its neighbour's edge, never to a fixed x. That is what
    lets a late column measurement reflow the row with nothing but SetWidth calls,
    and what lets the item name -- anchored on both sides -- absorb whatever the
    columns leave.
]]
local REMOVE_ICON_SIZE = 16
-- The row's inset from both its edges: the icon on the left, this on the right.
local ROW_INSET = 6

local ICON_SIZE = 18
local ICON_TEXT_GAP = 4
local NAME_INSET = ROW_INSET + ICON_SIZE + ICON_TEXT_GAP
local NAME_COLUMN_GAP = 10 -- name to the Keep box

local REMOVE_GAP = 6 -- last column to the remove control

--------------------------------------------------------------------------------
-- Cell States
--------------------------------------------------------------------------------

--[[
    On is the game's own check glyph in the gold every other lit control uses. Off
    is a short dash rather than an empty cell, so a row reads as a row of answers
    instead of a row of holes, and so the click target is visible before it is
    hovered.

    Not-applicable is a third state, and it is the reason off cannot simply be
    blank: an item with no upgrade ladder and an item with upgrading switched off
    are different facts. It draws the same dash, dimmer, and takes no clicks.
]]
--[[
    Every lit control in the window is the palette's TITLE gold and every plain
    body string its TEXT white. The greys below are not palette roles: they are
    this window's own UI states, and each says something a palette colour does not.
]]
local GOLD = ns.COLORS_RGB.TITLE
local WHITE = ns.COLORS_RGB.TEXT
local WINDOW_COLORS = ns.RESTOCKER_WINDOW_COLORS

local DASH_OFF = ns.HexToRGB(WINDOW_COLORS.DASH_OFF)
local DASH_NOT_APPLICABLE = ns.HexToRGB(WINDOW_COLORS.DASH_NOT_APPLICABLE)
local KEEP_SHORT = ns.HexToRGB(WINDOW_COLORS.KEEP_SHORT)

-- The hover highlight every clickable cell and toggle heading shares.
local CELL_HIGHLIGHT = "Interface\\Buttons\\UI-Listbox-Highlight2"
local CELL_HIGHLIGHT_ALPHA = 0.30
--[[
    Column headings are coloured by the band they belong to, so the eye can see
    where Bank stops and Merchant starts without a rule between them. The three
    columns in no band -- Item, Keep, Upgrade -- take the brand gold every
    other heading in the add-on already uses. Gold on the outside is what lets
    the two coloured bands read as a pair set into ordinary chrome rather than as
    three groups competing with one another.

    Each band carries TWO tones: the brighter `label` for the band's own name,
    the softer `caption` for the column headings under it. That step down is what
    makes the label read as the parent of the columns it spans instead of as one
    more heading sitting in the same row as them.

    Neither band uses a brand colour. ns.COLORS_RGB.INFO and .ON already mean
    something everywhere else -- interactive, and on -- and a static heading must
    not borrow it; the brand green directly above a column of on/off ticks read
    as a state rather than as a label. They stay clear of the item-quality
    colours the list draws names in (uncommon 1eff00, rare 0070dd) for the same
    reason. These are chrome, and have to look like it.
]]
local HEADER_CAPTION_UNGROUPED = ns.COLORS_RGB.TITLE -- Item, Keep, Upgrade

local GROUP_TONE = {
	RESTOCKER_ROW_BANK = {
		label = ns.HexToRGB(WINDOW_COLORS.BANK_LABEL),
		caption = ns.HexToRGB(WINDOW_COLORS.BANK_CAPTION),
	},
	RESTOCKER_ROW_MERCHANT = {
		label = ns.HexToRGB(WINDOW_COLORS.MERCHANT_LABEL),
		caption = ns.HexToRGB(WINDOW_COLORS.MERCHANT_CAPTION),
	},
}
local REPUTATION_SET = ns.HexToRGB(WINDOW_COLORS.REPUTATION_SET) -- amber, to stand out

--[[
    Lay the cells out right to left from the remove control, and hand back the
    leftmost one, which the Keep box hangs off (ns.RESTOCK_KEEP_GAP). Used by both
    the rows and the header, which is the whole point: one walk, one set of gaps,
    so a column can never sit in two different places.
]]
local function LayoutColumns(anchorTo, build)
	local cells = {}
	local anchor = anchorTo
	local gap = REMOVE_GAP
	for i = #COLUMNS, 1, -1 do
		local column = COLUMNS[i]
		local cell = build(column)
		cell:SetPoint("RIGHT", anchor, "LEFT", -gap, 0)
		cells[column.key] = cell
		anchor = cell
		gap = column.gapBefore and COLUMN_GROUP_GAP or COLUMN_GAP
	end
	return cells, anchor
end

-- Push the current column widths into a set of cells. Cheap and idempotent.
local function ApplyColumnWidths(cells)
	for _, column in ipairs(COLUMNS) do
		local cell = cells[column.key]
		if cell then
			cell:SetWidth(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH)
		end
	end
end

--[[
    Which tone each column's caption takes, and which its band label takes. A
    column carrying `group` opens a band and every column after it inherits that
    band's caption tone until the next boundary; `gapBefore` without a `group`
    closes the band and falls back to the ungrouped gold, which is how Upgrade,
    sitting alone after Merchant, gets its colour.

    BAND_LABEL_TONE is keyed by the column that OPENS each band, because that is
    the key the band-drawing loop below already has in hand.

    Both are derived from GROUP_TONE rather than declared per column, so the Bank
    columns and the "Bank" label over them read from one entry and cannot drift
    apart. A band added to COLUMNS with no tone comes out gold rather than
    silently inheriting its neighbour's colour.
]]
local COLUMN_TONE = {}
local BAND_LABEL_TONE = {}
do
	local tone = HEADER_CAPTION_UNGROUPED
	for _, column in ipairs(COLUMNS) do
		if column.group then
			local band = GROUP_TONE[column.group]
			tone = (band and band.caption) or HEADER_CAPTION_UNGROUPED
			BAND_LABEL_TONE[column.key] = (band and band.label) or HEADER_CAPTION_UNGROUPED
		elseif column.gapBefore then
			tone = HEADER_CAPTION_UNGROUPED
		end
		COLUMN_TONE[column.key] = tone
	end
end

--------------------------------------------------------------------------------
-- Column Header
--------------------------------------------------------------------------------

--[[
    Anchored to the scroll frame's top corners so it inherits the same width and,
    crucially, the same RIGHT edge as the rows inside it -- rows are sized to the
    scroll frame, and both lay out from that edge. Nothing here knows an x
    coordinate.

    It sits outside the scroll frame rather than at the top of the list, so it
    stays put while the list scrolls under it.
]]
function ns.CreateRestockColumnHeader(parent, scrollFrame)
	local header = CreateFrame("Frame", nil, parent)
	header:SetPoint("BOTTOMLEFT", scrollFrame, "TOPLEFT", 0, 2)
	header:SetPoint("BOTTOMRIGHT", scrollFrame, "TOPRIGHT", 0, 2)
	header:SetHeight(ns.restockColumnHeaderHeight)

	local rule = header:CreateTexture(nil, "ARTWORK")
	rule:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 0)
	rule:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 0)
	rule:SetHeight(1)
	rule:SetColorTexture(GOLD.r, GOLD.g, GOLD.b, 0.20)

	--[[
	    The lower tier is its own frame so everything in it centres vertically by
	    itself, exactly the way a row does. The group bands then have the whole
	    remaining height above it and never have to be positioned against a
	    caption's baseline.
	]]
	local captionRow = CreateFrame("Frame", nil, header)
	captionRow:SetPoint("BOTTOMLEFT", header, "BOTTOMLEFT", 0, 2)
	captionRow:SetPoint("BOTTOMRIGHT", header, "BOTTOMRIGHT", 0, 2)
	captionRow:SetHeight(ns.restockButtonHeight)

	local function Caption(parentFrame, text, tone, width)
		local fontString = parentFrame:CreateFontString(nil, "OVERLAY")
		fontString:SetFontObject(BUTTON_FONT)
		fontString:SetTextColor(tone.r, tone.g, tone.b)
		fontString:SetText(text)
		if width then
			fontString:SetWidth(width)
			fontString:SetJustifyH("CENTER")
		end
		return fontString
	end

	--[[
	    A stand-in for the remove control, which has no caption but does take up the
	    width the rows give it. Without it every heading would sit one icon too far
	    right.
	]]
	local removeSpacer = CreateFrame("Frame", nil, captionRow)
	removeSpacer:SetSize(REMOVE_ICON_SIZE, 1)
	removeSpacer:SetPoint("RIGHT", captionRow, "RIGHT", -ROW_INSET, 0)

	--[[
	    Captions ride on buttons of their column's width: a FontString takes no
	    mouse, and hovering a heading has to give the same explanation as hovering a
	    cell under it. That is what lets the cells be glyphs instead of repeating
	    the words on every row.

	    A toggle column's heading also acts: a click offers to switch that column
	    on or off for every row shown (ns.OpenRestockColumnMenu in
	    Restocker-Window-Rows.lua), so its tooltip ends with a line saying so and
	    it lights on hover like the cells under it. Reputation names one of five
	    standings rather than on or off, so its heading only explains.
	]]
	local firstCell
	header.cells, firstCell = LayoutColumns(removeSpacer, function(column)
		local button = CreateFrame("Button", nil, captionRow)
		button:SetSize(ns.restockColumnWidths[column.key] or COLUMN_MIN_WIDTH, ns.restockButtonHeight)
		local fontString = button:CreateFontString(nil, "OVERLAY")
		fontString:SetFontObject(BUTTON_FONT)
		local tone = COLUMN_TONE[column.key]
		fontString:SetTextColor(tone.r, tone.g, tone.b)
		fontString:SetText(L[column.caption])
		fontString:SetPoint("CENTER")

		if column.isText then
			ns.SetupRestockerTooltip(button, L[column.title], unpack(TooltipBody(column)))
			ns.SetRestockControlClick(button)
			return button
		end

		local body = { unpack(TooltipBody(column)) }
		body[#body + 1] = L["RESTOCKER_COLUMN_BULK_HINT"]
		ns.SetupRestockerTooltip(button, L[column.title], unpack(body))

		button:SetHighlightTexture(CELL_HIGHLIGHT, "ADD")
		local highlight = button:GetHighlightTexture()
		if highlight then
			highlight:SetVertexColor(GOLD.r, GOLD.g, GOLD.b, CELL_HIGHLIGHT_ALPHA)
		end
		ns.SetRestockControlClick(button, function(self)
			ns.OpenRestockColumnMenu(column, self)
		end)
		return button
	end)

	--[[
	    The Keep heading, over the box that leads the strip. A button for the same
	    reason the column headings are: it carries the box's own tooltip.
	]]
	local amount = CreateFrame("Button", nil, captionRow)
	amount:SetSize(ns.restockAmountWidth, ns.restockButtonHeight)
	amount:SetPoint("RIGHT", firstCell, "LEFT", -COLUMN_GROUP_GAP, 0)
	Caption(amount, L["RESTOCKER_COLUMN_AMOUNT"], HEADER_CAPTION_UNGROUPED):SetPoint("CENTER")
	ns.SetupRestockerTooltip(amount, L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"], L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"])
	ns.SetRestockControlClick(amount)
	header.amountCaption = amount

	--[[
	    GROUP BANDS

	    Each band anchors to the LEFT of its group's first column and the RIGHT of
	    its last, so it centres itself over exactly the columns it covers and
	    re-spans on its own whenever those columns are re-measured. No band is ever
	    told a width.

	    A column with no `group` (Upgrade) gets no band -- its own caption is
	    already the whole word.
	]]
	for i, column in ipairs(COLUMNS) do
		if column.group then
			--[[
			    A band runs until the next column STARTS one. `gapBefore` is that signal
			    as much as `group` is -- Upgrade opens its own band and carries no label,
			    and stopping only at the next labelled column swallowed it into
			    Merchant, which drew "Merchant" over the Upgrade column.
			]]
			local last = column
			for j = i + 1, #COLUMNS do
				if COLUMNS[j].group or COLUMNS[j].gapBefore then
					break
				end
				last = COLUMNS[j]
			end
			local band = Caption(header, L[column.group], BAND_LABEL_TONE[column.key])
			band:SetJustifyH("CENTER")
			band:SetPoint("LEFT", header.cells[column.key], "LEFT", 0, 0)
			band:SetPoint("RIGHT", header.cells[last.key], "RIGHT", 0, 0)
			band:SetPoint("TOP", header, "TOP", 0, -1)
		end
	end

	local item = Caption(captionRow, L["RESTOCKER_COLUMN_ITEM"], HEADER_CAPTION_UNGROUPED)
	item:SetPoint("LEFT", captionRow, "LEFT", NAME_INSET, 0)

	ns.restockColumnHeader = header
	return header
end

--[[
    Re-sync the header to the current column widths, measuring first if the
    font had not resolved when the window was built. Called from
    ns.UpdateRestockList, which is where a late measurement first shows up.
]]
function ns.RefreshRestockColumnHeader()
	ResolveColumns()
	local header = ns.restockColumnHeader
	if header and header.cells then
		ApplyColumnWidths(header.cells)
		-- The Keep heading is not one of the laid-out cells, so it re-widths here.
		header.amountCaption:SetWidth(ns.restockAmountWidth)
	end
end

--------------------------------------------------------------------------------
-- Shared With The Rows
--------------------------------------------------------------------------------

--[[
    The grid's surface for Restocker-Window-Rows.lua. Everything else above is
    private to this file: the measurement, the resolved widths, and the header.
]]
ns.RESTOCK_COLUMNS = COLUMNS
ns.RESTOCK_REMOVE_ICON_SIZE = REMOVE_ICON_SIZE
ns.RESTOCK_COLUMN_MIN_WIDTH = COLUMN_MIN_WIDTH
ns.RESTOCK_ROW_INSET = ROW_INSET
ns.RESTOCK_ICON_SIZE = ICON_SIZE
ns.RESTOCK_ICON_TEXT_GAP = ICON_TEXT_GAP
ns.RESTOCK_NAME_COLUMN_GAP = NAME_COLUMN_GAP
ns.RESTOCK_KEEP_GAP = COLUMN_GROUP_GAP -- leftmost column to the Keep box
ns.RESTOCK_CELL_GOLD = GOLD
ns.RESTOCK_CELL_WHITE = WHITE
ns.RESTOCK_CELL_DASH_OFF = DASH_OFF
ns.RESTOCK_CELL_DASH_NOT_APPLICABLE = DASH_NOT_APPLICABLE
ns.RESTOCK_CELL_KEEP_SHORT = KEEP_SHORT
ns.RESTOCK_CELL_HIGHLIGHT = CELL_HIGHLIGHT
ns.RESTOCK_CELL_HIGHLIGHT_ALPHA = CELL_HIGHLIGHT_ALPHA
ns.RESTOCK_CELL_REPUTATION_SET = REPUTATION_SET
ns.LayoutRestockColumns = LayoutColumns
ns.ApplyRestockColumnWidths = ApplyColumnWidths
ns.RestockColumnTooltipBody = TooltipBody
ns.RestockReputationStandingByValue = ReputationStandingByValue
ns.RestockReputationMenuText = ReputationMenuText
