local _, ns = ...

--------------------------------------------------------------------------------
-- Menus and Drops
--------------------------------------------------------------------------------

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
    a multi-line tooltip reads as paragraphs instead of one wall. Single-body
    tooltips are unaffected -- they get the one spacer under the title either way.

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
