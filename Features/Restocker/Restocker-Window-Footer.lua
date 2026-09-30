local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Status Line
--------------------------------------------------------------------------------

--[[
    7 restocking orders outstanding.     Removed (icon) Major Mana Potion.  [Undo]

    The window's bottom line, under the list. Two things live on it.

    The left is the answer the list exists to give: how many restocking orders
    are outstanding, in the words the merchant and bank reminders print
    (ns.RestockShortfallHeadline). Hovering it lists the orders the way the
    mini-map's Restocker Report does -- icon, name, have/wanted -- capped, so a
    long list cannot run the tooltip off the screen.

    It is read straight off ns.BuildGroceryList, like the mini-map tooltip and
    every reminder, so none of them can disagree about what is outstanding. An
    order is a row with Buy on that the bags are short of, and the count is
    drawn in the yellow of the Keep marks it counts (KEEP_SHORT in
    Data/Data.lua): the line is where a player learns what a yellow Keep
    number means. Red is kept for errors, and being short of something is not
    one.

    The Keep marks in the list are every short row, Buy or not, so with Buy
    off on a short row there is a mark and no order -- and the line says "no
    orders", in plain white, rather than congratulating a list that is visibly
    short of something. The congratulation is kept for a list with no mark on
    it at all.

    An empty list says nothing here: the invitation in its place already does.

    The right is the offer to take back the last removal (ns.UndoRestockRemove
    in Restocker-Window-Rows.lua): a sentence naming what went, by its icon
    and its name, and an Undo button. It sits beside the count rather than in its place, so removing a
    row never costs the player the answer on the left.

    Anchor footer controls to the row, never to the WINDOW: a control anchored
    to the window lands at its middle and disappears behind the list.
]]
local FOOTER_X = 10
local FOOTER_Y = 12
local FOOTER_RIGHT_INSET = 26 -- clear of the resize grip
local FOOTER_ROW_HEIGHT = 22
local STATUS_GAP = 24 -- the count to the undo offer
local UNDO_GAP = 10 -- "Removed [item]." to the Undo button

-- The most orders the hover lists one per row; past it, one closing line counts the rest.
local ORDERS_TOOLTIP_MAX_ROWS = 20

local TITLE = ns.COLORS_RGB.TITLE
-- The Keep marks' own color, as an escape for the orders count. Append |r at the point of use.
local SHORT = "|cff" .. ns.RESTOCKER_WINDOW_COLORS.KEEP_SHORT

--------------------------------------------------------------------------------
-- Orders Tooltip
--------------------------------------------------------------------------------

--[[
    An item as this line and its tooltip name one: its icon, then its name in
    its quality color, with no brackets (ns.GetItemLabel, which names an item
    even while the cache is cold). A name-only row has no ID to look an icon up
    by, so it shows the question mark the list itself uses.
]]
local UNKNOWN_ICON = "Interface\\ICONS\\INV_Misc_QuestionMark"

local function ItemWithIcon(itemID, itemName)
	local icon = itemID and C_Item.GetItemIconByID(itemID) or UNKNOWN_ICON
	return string.format("|T%s:14:14|t %s", icon, ns.GetItemLabel(itemID, itemName))
end

--[[
    The orders themselves, in the mini-map Restocker Report's own form and under
    its own title: the item, then have/wanted, the ratio the verbose reminder
    prints.

    Built on hover rather than kept, so it is as current as the bags are.
    Nothing to list draws no tooltip: the line above has already said so.
]]
local function ShowOrdersTooltip(owner)
	local groceries = ns.BuildGroceryList()
	if #groceries == 0 then
		return
	end

	GameTooltip:SetOwner(owner, "ANCHOR_TOPLEFT")
	GameTooltip:SetText(L["MINIMAP_RESTOCKER_REPORT"], TITLE.r, TITLE.g, TITLE.b)
	for index = 1, math.min(#groceries, ORDERS_TOOLTIP_MAX_ROWS) do
		local entry = groceries[index]
		GameTooltip:AddDoubleLine(
			ItemWithIcon(entry.itemID, entry.itemName),
			GetColor("BODY") .. string.format(L["MINIMAP_RESTOCKER_ITEM_COUNT"], entry.have, entry.wanted) .. "|r"
		)
	end
	if #groceries > ORDERS_TOOLTIP_MAX_ROWS then
		GameTooltip:AddLine(
			GetColor("MUTED") .. string.format(L["RESTOCKER_REPORT_MORE"], #groceries - ORDERS_TOOLTIP_MAX_ROWS) .. "|r"
		)
	end
	GameTooltip:Show()
end

--------------------------------------------------------------------------------
-- Status Text
--------------------------------------------------------------------------------

-- Is any row on the list short in the bags, Buy or not? The rows' Keep marks ask the same of each row.
local function AnyRowShort(list)
	for _, item in pairs(list) do
		if ns.IsRestockItemShort(item) then
			return true
		end
	end
	return false
end

local function StatusText(list)
	if next(list) == nil then
		return ""
	end

	local orders = #ns.BuildGroceryList()
	if orders > 0 then
		return SHORT .. ns.RestockShortfallHeadline(orders) .. "|r"
	end
	if AnyRowShort(list) then
		return L["RESTOCKER_NO_ORDERS"]
	end
	return GetColor("ON") .. L["MINIMAP_RESTOCKER_STOCKED"] .. "|r"
end

--[[
    Repaint the line. Called at the end of every redraw, and on its own wherever
    the count can move without the rows moving: a Buy cell clicked, a Keep amount
    typed, the bags changing with the window open.

    The count's button is sized to its text, so the hover is over the words and
    not over the empty run of footer beside them, and the undo offer closes up
    against the left edge when there is no count to sit beside. Undo is sized
    here too, to its caption.
]]
function ns.UpdateRestockStatus()
	local footer = ns.restockWindow.footer
	local settings = ns.restockSettings

	local text = StatusText(settings.lists[settings.currentList])
	footer.statusText:SetText(text)
	footer.status:SetWidth(math.max(1, footer.statusText:GetStringWidth()))

	local removed = ns.restockLastRemoved
	footer.removedText:SetShown(removed ~= nil)
	footer.undo:SetShown(removed ~= nil)
	if removed then
		footer.removedText:SetText(
			string.format(L["RESTOCKER_REMOVED_ITEM"], ItemWithIcon(removed.item.itemID, removed.item.itemName))
		)
		footer.removedText:ClearAllPoints()
		footer.removedText:SetPoint("LEFT", footer.status, "RIGHT", (text ~= "") and STATUS_GAP or 0, 0)
		-- Sized here rather than when built: a font not yet resolved at login measures as nothing.
		ns.FitRestockButton(footer.undo)
	end
end

--------------------------------------------------------------------------------
-- Assembly
--------------------------------------------------------------------------------

function ns.CreateRestockWindowFooter(addonFrame)
	local footer = CreateFrame("Frame", nil, addonFrame)
	footer:SetPoint("BOTTOMLEFT", addonFrame, "BOTTOMLEFT", FOOTER_X, FOOTER_Y)
	footer:SetPoint("BOTTOMRIGHT", addonFrame, "BOTTOMRIGHT", -FOOTER_RIGHT_INSET, FOOTER_Y)
	footer:SetHeight(FOOTER_ROW_HEIGHT)

	--[[
	    A button only so it can be hovered: a FontString takes no mouse. A click
	    does nothing but take an item dropped on it.
	]]
	local status = CreateFrame("Button", nil, footer)
	status:SetPoint("LEFT", footer, "LEFT", 0, 0)
	status:SetHeight(FOOTER_ROW_HEIGHT)
	local statusText = status:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	statusText:SetPoint("LEFT", status, "LEFT", 0, 0)
	status:SetScript("OnEnter", ShowOrdersTooltip)
	status:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)
	ns.SetRestockControlClick(status)

	local removedText = footer:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	removedText:Hide()

	--[[
	    Undo is a panel button, as everything a click acts on in this window is.
	    A word in the interaction blue reads as information, not as something to
	    press.
	]]
	local undo = CreateFrame("Button", nil, footer, "UIPanelButtonTemplate")
	undo:SetPoint("LEFT", removedText, "RIGHT", UNDO_GAP, 0)
	undo:SetHeight(FOOTER_ROW_HEIGHT)
	undo:SetText(L["RESTOCKER_UNDO"])
	ns.FitRestockButton(undo)
	ns.SetRestockControlClick(undo, function()
		-- The click hides the button under the mouse, which would leave its tooltip up.
		GameTooltip:Hide()
		ns.UndoRestockRemove()
	end)
	ns.SetupRestockerTooltip(undo, L["RESTOCKER_UNDO_TOOLTIP"])
	undo:Hide()

	footer.status = status
	footer.statusText = statusText
	footer.removedText = removedText
	footer.undo = undo
	addonFrame.footer = footer
	return footer
end
