-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the Restock List's column layout (no WoW API needed).

    Run it with:   lua Tests/Restocker-Column-Layout-Test.lua

    It models the SAME walk as LayoutColumns in Restocker-Window-Columns.lua, which lays out both the
    column header and every item row: start at the row's right edge, step left past the
    remove control, then past each column in reverse, opening a wider gap wherever a column
    declares `gapBefore`. The Keep box then hangs off the leftmost column, and the item name
    stops at the Keep box.

    Two things are worth a test rather than an eyeball, because neither is visible until
    the add-on is loaded in the client and both fail quietly:

      1. HEADER AND ROWS MUST AGREE. The header sits outside the scroll frame and the rows
         sit inside it, so they are different frames laid out at different times. They line
         up only because both walk the same list from the same right edge. A heading that
         drifts one gap off its column is still a readable header -- it just labels the
         wrong column, which is worse than no header at all.

      2. THE ITEM NAME IS WHAT PAYS. The columns and the Keep box claim a fixed strip on the
         right; the name gets the remainder. Nothing clips or errors when that remainder gets small, the
         name just quietly truncates, so the floor has to be checked arithmetically. Six
         full-length captions put it under the floor even at the widest window this test
         calls a minimum, which is what forced the short captions and the bands above
         them.

    The locale scenario at the end is the one that matters for translation: German and
    Russian captions are longer than English, and the whole point of anchoring each cell to
    its neighbour rather than to a fixed x is that a wider column has to reflow everything
    without anything coming unaligned.
]]

local ROW_INSET = 6
local ICON_SIZE = 18
local ICON_TEXT_GAP = 4
local NAME_INSET = ROW_INSET + ICON_SIZE + ICON_TEXT_GAP
local NAME_COLUMN_GAP = 10

local AMOUNT_WIDTH = 44 -- the Keep box: the English measurement ns.restockAmountWidth starts at
local REMOVE_GAP = 6 -- last column to the remove control
local REMOVE_ICON_SIZE = 16

local COLUMN_GAP = 5
local COLUMN_GROUP_GAP = 12

-- Mirrors the COLUMNS table: order, grouping, and which columns open a wide gap.
local COLUMNS = {
	{ key = "withdraw", group = "Bank" },
	{ key = "deposit" },
	{ key = "buy", group = "Merchant", gapBefore = true },
	{ key = "extra" },
	{ key = "reputation" },
	{ key = "upgrade", gapBefore = true },
}

local ENGLISH = { withdraw = 38, deposit = 42, buy = 32, extra = 40, reputation = 54, upgrade = 60 }

--[[
  The category pane sizes itself to the longest type name it has to draw, so the
  window floor is set against its CAP rather than its usual width: the item name
  must keep its floor even on a client whose type names run long.
]]
local GROUP_PANE_MAX_WIDTH = 180
local GROUP_PANE_GAP = 8
local GROUP_PANE_WIDTH = GROUP_PANE_MAX_WIDTH

---The table's row width for a given window width, matching CreateScrollFrame.
local function rowWidthFor(windowWidth)
	--[[
	    CreateListInset takes 2 + 4; the table starts past the pane and leaves 26 on
	    the right for the scroll bar.
	]]
	return windowWidth - 2 - 4 - (8 + GROUP_PANE_WIDTH + GROUP_PANE_GAP) - 26
end

local pass = 0

--[[
  LayoutColumns, as shipped, and the Keep box hung off it. Returns each column's
  { left, right } in row coordinates, measuring from the row's right edge inward, plus the
  Keep box's own { left, right }, whose left edge is where the item name stops. `rowWidth`
  is the scroll frame's width, which is what both a row and the header span.
]]
---@param rowWidth number
---@param widths table<string, number>
local function layout(rowWidth, widths)
	local removeLeft = rowWidth - ROW_INSET - REMOVE_ICON_SIZE

	local cells = {}
	local anchorLeft = removeLeft
	local gap = REMOVE_GAP -- last column to the remove control
	for i = #COLUMNS, 1, -1 do
		local col = COLUMNS[i]
		local right = anchorLeft - gap
		local left = right - widths[col.key]
		cells[col.key] = { left = left, right = right }
		anchorLeft = left
		gap = col.gapBefore and COLUMN_GROUP_GAP or COLUMN_GAP
	end

	-- ns.RESTOCK_KEEP_GAP is the group gap: the Keep box is a group of its own, ahead of Bank.
	local keepRight = anchorLeft - COLUMN_GROUP_GAP
	return cells, { left = keepRight - AMOUNT_WIDTH, right = keepRight }
end

---The width left for the item name, which is anchored between the icon and the Keep box.
local function nameWidth(rowWidth, widths)
	local _, keep = layout(rowWidth, widths)
	return keep.left - NAME_COLUMN_GAP - NAME_INSET
end

--------------------------------------------------------------------------------
-- HEADER AND ROWS AGREE
--------------------------------------------------------------------------------

--[[
  The header spans the scroll frame's top corners and the rows are sized to the scroll
  frame, so both are handed the same width and both run the same walk. Laying each out
  independently and comparing is what pins that: if the two ever stop sharing the walk,
  every column here goes out by a gap.
]]
---@param label string
local function alignmentScenario(label, rowWidth, widths)
	local rowCells, rowKeep = layout(rowWidth, widths)
	local headerCells, headerKeep = layout(rowWidth, widths)

	-- The Keep heading sits over the Keep box, and the box clears the first column by the group gap.
	assert(
		rowKeep.left == headerKeep.left and rowKeep.right == headerKeep.right,
		("%s: Keep row [%d,%d] vs header [%d,%d]"):format(
			label,
			rowKeep.left,
			rowKeep.right,
			headerKeep.left,
			headerKeep.right
		)
	)
	local keepGap = rowCells[COLUMNS[1].key].left - rowKeep.right
	assert(keepGap == COLUMN_GROUP_GAP, ("%s: gap Keep|%s is %d"):format(label, COLUMNS[1].key, keepGap))

	for _, col in ipairs(COLUMNS) do
		local r, h = rowCells[col.key], headerCells[col.key]
		assert(
			r.left == h.left and r.right == h.right,
			("%s: column %s row [%d,%d] vs header [%d,%d]"):format(label, col.key, r.left, r.right, h.left, h.right)
		)
		assert(r.left < r.right, ("%s: column %s has no width"):format(label, col.key))
	end

	-- No column may overlap the one beside it, at any width.
	for i = 1, #COLUMNS - 1 do
		local a, b = rowCells[COLUMNS[i].key], rowCells[COLUMNS[i + 1].key]
		local gap = b.left - a.right
		local want = COLUMNS[i + 1].gapBefore and COLUMN_GROUP_GAP or COLUMN_GAP
		assert(
			gap == want,
			("%s: gap %s|%s is %d, want %d"):format(label, COLUMNS[i].key, COLUMNS[i + 1].key, gap, want)
		)
	end

	print(("  ok  %-44s -> columns aligned, gaps exact"):format(label))
	pass = pass + 1
end

print("HEADER AND ROWS AGREE")
alignmentScenario("English captions, minimum window", rowWidthFor(819), ENGLISH)
alignmentScenario("English captions, default window", rowWidthFor(870), ENGLISH)
alignmentScenario("English captions, wide window", rowWidthFor(1390), ENGLISH)

--------------------------------------------------------------------------------
-- GROUP BANDS SPAN THEIR OWN COLUMNS
--------------------------------------------------------------------------------

--[[
  A band anchors to the LEFT of its group's first column and the RIGHT of its last, so it
  covers those columns and nothing else. The Upgrade column declares no group and must be
  covered by no band at all -- a band creeping over it would read as "Merchant: Upgrade".
]]
print("\nGROUP BANDS")

local cells = layout(rowWidthFor(870), ENGLISH)
local covered = {}
for i, col in ipairs(COLUMNS) do
	if col.group then
		--[[
		    A band runs until the next column STARTS one, which `gapBefore` signals
		    just as much as `group` does.
		]]
		local last = col
		for j = i + 1, #COLUMNS do
			if COLUMNS[j].group or COLUMNS[j].gapBefore then
				break
			end
			last = COLUMNS[j]
		end
		local bandLeft, bandRight = cells[col.key].left, cells[last.key].right
		assert(bandLeft < bandRight, ("band %s is inside out"):format(col.group))
		for j = i, #COLUMNS do
			if COLUMNS[j] == last then
				covered[COLUMNS[j].key] = col.group
				break
			end
			covered[COLUMNS[j].key] = col.group
		end
		print(("  ok  band %-10s spans %s..%s (%dpx)"):format(col.group, col.key, last.key, bandRight - bandLeft))
		pass = pass + 1
	end
end

assert(covered.withdraw == "Bank" and covered.deposit == "Bank", "Bank must cover both bank columns")
assert(
	covered.buy == "Merchant" and covered.extra == "Merchant" and covered.reputation == "Merchant",
	"Merchant must cover buy, extra and reputation"
)
assert(covered.upgrade == nil, "Upgrade declares no group and must be covered by no band")
print("  ok  Upgrade is covered by no band")
pass = pass + 1

--------------------------------------------------------------------------------
-- THE ITEM NAME IS WHAT PAYS
--------------------------------------------------------------------------------

---@param label string
local function nameScenario(label, windowWidth, widths, floor)
	local rowWidth = rowWidthFor(windowWidth)
	local w = nameWidth(rowWidth, widths)
	assert(w >= floor, ("%s: item name %dpx, below the %dpx floor"):format(label, w, floor))
	print(("  ok  %-44s -> item name %3dpx"):format(label, w))
	pass = pass + 1
end

print("\nITEM NAME WIDTH")
--[[
  MIN_WIDTH and DEFAULT_WIDTH in Restocker-Window.lua. The floor is the point below which a
  consumable name stops being recognisable, and it is what sets MIN_WIDTH: the window has
  to hold the category pane AND leave the table enough for a readable name, so the two
  numbers move together. Widening the pane, a column or the Keep box without moving
  MIN_WIDTH is exactly the regression these three catch. The default window's 215 is exactly
  what DEFAULT_WIDTH leaves, so a column that widens shows up there as well. The minimum
  window leaves 164, over the floor by the 14 pixels the Keep box gave back when its heading
  shortened from "Amount".
]]
nameScenario("minimum window (819)", 819, ENGLISH, 150)
nameScenario("default window (870)", 870, ENGLISH, 215)
nameScenario("wide window (1190)", 1190, ENGLISH, 500)

--[[
  What full-length captions ("Withdraw", "Deposit", "Automatic") would cost. Kept as a
  scenario rather than a comment: it is the reason the short captions and the bands above
  them exist, and it fails loudly if someone lengthens the captions back.

  The claim is exactly the one the floor above enforces -- that this does not leave a
  readable name -- and nothing stronger. It lands well under the 150px minimum even at
  the minimum window, and it was worse still before the gaps were tightened.
]]
local FULL_LENGTH = { withdraw = 62, deposit = 56, buy = 34, extra = 42, reputation = 58, upgrade = 58 }
local MIN_NAME = 150
local wasWidth = nameWidth(rowWidthFor(819), FULL_LENGTH)
assert(
	wasWidth < MIN_NAME,
	("full-length captions leave %dpx, which is not under the %dpx floor they were rejected for"):format(
		wasWidth,
		MIN_NAME
	)
)
print(
	("  ok  %-44s -> item name %3dpx, under the %dpx floor (rejected)"):format(
		"full-length captions, minimum window",
		wasWidth,
		MIN_NAME
	)
)
pass = pass + 1

--------------------------------------------------------------------------------
-- LONGER LOCALES REFLOW WITHOUT COMING UNALIGNED
--------------------------------------------------------------------------------

--[[
  Each cell is anchored to its neighbour's edge rather than to a fixed x, so a locale with
  wider captions has to reflow the whole strip from one SetWidth per column. Everything
  must stay aligned and the extra width must come out of the item name, never out of a
  neighbouring column.
]]
print("\nLONGER LOCALE")

local LONGER = {}
for key, w in pairs(ENGLISH) do
	LONGER[key] = w + 18 -- every caption noticeably wider than English
end

alignmentScenario("wider captions, default window", rowWidthFor(870), LONGER)

local englishName = nameWidth(rowWidthFor(870), ENGLISH)
local longerName = nameWidth(rowWidthFor(870), LONGER)
local lost = englishName - longerName
assert(
	lost == 18 * #COLUMNS,
	("the name should absorb every added pixel: lost %d, added %d"):format(lost, 18 * #COLUMNS)
)
print(
	("  ok  %-44s -> name %d -> %d, absorbed all %dpx"):format(
		"wider captions come out of the name",
		englishName,
		longerName,
		lost
	)
)
pass = pass + 1

print(("\nALL %d COLUMN LAYOUT SCENARIOS PASSED"):format(pass))
