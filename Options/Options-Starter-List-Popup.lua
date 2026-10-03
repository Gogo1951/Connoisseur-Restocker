local _, ns = ...

--------------------------------------------------------------------------------
-- Starter List Pop-up
--------------------------------------------------------------------------------

--[[
    The window that opens after login when a level-6+ character has nothing on
    their Restock List, offering the staples -- foods, water, class reagents,
    ammo -- as one-tick suggestions, a few of them pre-ticked for the class.
    The categories are rows in Data/Data.lua (ns.STARTER_LIST_CATEGORIES); the
    trigger, the defaults and what every tick does live in
    Features/Restocker/Restocker-Starter-List.lua. This file draws them, and
    clears the Restock window's New flags when it closes.

    This is an AceConfigDialog standalone window rather than a hand-built
    frame, the same arrangement as GogoLoot's master-looter pop-up: registered
    with AceConfigRegistry like any other panel (Options.lua) but never passed
    to AddToBlizOptions, so it takes the add-on's existing widget styling,
    gets the stock Close button, and stays out of the Blizzard settings tree.
    Nothing here is protected.
]]
local L = ns.L
local GetColor = ns.GetColor
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--[[
    Sized to what THIS character is offered. The sections are decided by class
    and level the moment the window opens, and how tall they come out depends
    on the locale's wording and whatever skin is drawing the widgets, so no
    constant can be right: the window opens at its cap, the rows are laid out,
    and the frame is then drawn in to the height they came to (FitPopupHeight
    below). Only a build taller than the cap keeps it and scrolls a little -- a
    level-60 rogue's, with poisons, ammo and reagents under the food.

    The width holds two staples side by side with the scroll bar showing, so
    the capped case reflows nothing (see the cell widths below). The
    don't-show-again checkbox adds no height: it rides the frame's own footer
    line, beside Close.
]]
local POPUP_WIDTH = 690
local POPUP_MAX_HEIGHT = 640
-- What the AceGUI Frame widget keeps for its title and footer: its content is anchored 27 under the top and 40 over the bottom.
local POPUP_CHROME_HEIGHT = 67
-- The scroll container shows its bar once the content comes within 2px of the view, so the fit leaves a little air.
local POPUP_FIT_MARGIN = 4

--[[
    Each staple is a checkbox-plus-stacks-dropdown pair, two pairs to a row
    with a gutter between them. One grid serves every section, so the two
    columns line up from Food & Water down through Reagents & Tools rather than
    each section keeping widths of its own. The unit is AceConfig's 170px width
    step.

    The checkbox cell is sized to the longest name a row shows beside its
    icon: reagent and poison rows carry the client's own item names, and "Rune
    of Teleportation" is the yardstick. The dropdown holds "18 Stacks", the
    ammo rows' longest (the counting ones, Soul Shards, stop at a bare "40"),
    which fits because the AceGUI dropdown renders its text in the small
    highlight font. A staple with a fixed amount draws no dropdown; its
    checkbox spans the whole pair, so the columns keep their rhythm. A locale
    whose item name overruns its cell wraps that row onto another line.

    Two pairs and the gutter come to 3.65 units, 621px, which is inside the
    window's content width with the scroll bar showing (690, less 34 of frame
    and 20 of bar).
]]
local STAPLE_TOGGLE_WIDTH = 1.1
local STAPLE_STACKS_WIDTH = 0.65
local COLUMN_GUTTER_WIDTH = 0.15

--------------------------------------------------------------------------------
-- Options Table Builder
--------------------------------------------------------------------------------

-- Every category argument below is one entry from ns.GetStarterCategories().

--[[
    "1 Stack" .. "N Stacks" choice lists, one per distinct cap -- the food
    dropdowns stop at 4 stacks where the ammo ones run to 18, so the lists
    are built per category.maxStacks and cached by that cap. The label is
    unit-agnostic on purpose, because a stack is whatever its item stacks to
    and the dropdown's tooltip is what says how many.

    A category that counts items instead (countsItems: Soul Shards) gets a
    bare-number list: "1 Stack" of a thing that cannot stack reads as a bug,
    and the row's own label already says what is being counted.

    A category carrying a choices list offers exactly those counts rather than
    every number to a cap -- Restocker-Starter-List.lua owns which, and why. Same
    machinery either way, so the cache keys on the style and on the run of
    counts, and two categories offering the same run share one list.
]]
local stackOptionsByCap = {}

local function StackOptions(category)
	local counting = category.countsItems
	local choices = category.choices
	local cacheKey = (counting and "count:" or "stacks:")
		.. (choices and table.concat(choices, ",") or category.maxStacks)

	local cached = stackOptionsByCap[cacheKey]
	if not cached then
		cached = { values = {}, sorting = {} }
		--[[
		    Keys are the counts themselves. The explicit sorting array is what
		    keeps AceConfig from ordering them "1, 10, 11, .." by label, so it
		    is filled in offered order rather than keyed like the values.
		]]
		local offered = choices
		if not offered then
			offered = {}
			for stacks = 1, category.maxStacks do
				offered[stacks] = stacks
			end
		end

		for index, stacks in ipairs(offered) do
			if counting then
				cached.values[stacks] = tostring(stacks)
			elseif stacks == 1 then
				cached.values[stacks] = L["STARTER_POPUP_STACK_ONE"]
			else
				cached.values[stacks] = string.format(L["STARTER_POPUP_STACK_MANY"], stacks)
			end
			cached.sorting[index] = stacks
		end
		stackOptionsByCap[cacheKey] = cached
	end
	return cached.values, cached.sorting
end

--[[
    Stands in for text built from an item the client has not resolved yet --
    a row's name, or the stack size and count a tooltip needs -- as the
    panels' own loading placeholder, until ns.WarmItemCache repaints.
]]
local function LoadingText(itemID)
	return GetColor("MUTED") .. string.format(L["LOADING_ITEM"], itemID) .. "|r"
end

--[[
    One staple checkbox. Ticking adds the item -- Restocker-Starter-List.lua picks the
    tier for the character's level -- and unticking removes it, whichever tier
    the list is holding by then. The tooltip names the exact item and count a
    tick adds right now.

    The row wears that item's icon between the box and the name, so a staple
    reads as an item rather than as a setting, and a food row, which is named
    for its kind, still shows which bread that is today. The icon comes off the
    client's own item table, so it never waits on the server as a name can.
    The checkbox is the icon checkbox every item-like toggle in the options
    shares (Options-Utilities.lua), for the gap between the two.
]]
local function StapleToggle(category, order, width)
	return {
		type = "toggle",
		name = function()
			return ns.GetStarterCategoryName(category) or LoadingText(ns.GetStarterCategoryNameItemID(category))
		end,
		desc = function()
			return ns.DescribeStarterCategory(category) or LoadingText(ns.GetStarterCategoryItemID(category))
		end,
		image = function()
			local itemID = ns.GetStarterCategoryItemID(category)
			return itemID and C_Item.GetItemIconByID(itemID) or nil
		end,
		imageCoords = ns.OPTIONS_ICON_TEXCOORDS,
		dialogControl = ns.ICON_CHECKBOX_WIDGET_TYPE,
		order = order,
		width = width,
		get = function()
			return ns.IsStarterCategoryChecked(category)
		end,
		set = function(_, value)
			ns.SetStarterCategory(category, value)
		end,
	}
end

--[[
    The stacks dropdown beside a staple's checkbox. Live either way round:
    picked first, it decides what a later tick adds; changed after, it rewrites
    the listed entry's amount on the spot. Captionless like every
    beside-a-control dropdown in the options panels.
]]
local function StapleStacks(category, order, width)
	local values, sorting = StackOptions(category)
	return {
		type = "select",
		name = "",
		desc = function()
			if category.countsItems then
				return L["STARTER_POPUP_COUNT_DESCRIPTION"]
			end
			local stackSize = ns.GetStarterCategoryStackSize(category)
			if not stackSize then
				return LoadingText(ns.GetStarterCategoryItemID(category))
			end
			return string.format(L["STARTER_POPUP_STACKS_DESCRIPTION"], stackSize)
		end,
		order = order,
		width = width,
		values = values,
		sorting = sorting,
		get = function()
			return ns.GetStarterCategoryStacks(category)
		end,
		set = function(_, value)
			ns.SetStarterCategoryStacks(category, value)
		end,
	}
end

--[[
    Adds one staple's checkbox-and-dropdown pair to args; returns the next
    order. A fixedAmount category has no stack choice to offer, so its
    checkbox takes the dropdown's width too and the pair stays one cell wide
    to its neighbors.
]]
local function AddStaplePair(args, category, order)
	if category.fixedAmount then
		args["toggle" .. category.key] = StapleToggle(category, order, STAPLE_TOGGLE_WIDTH + STAPLE_STACKS_WIDTH)
		return order + 1
	end
	args["toggle" .. category.key] = StapleToggle(category, order, STAPLE_TOGGLE_WIDTH)
	args["stacks" .. category.key] = StapleStacks(category, order + 1, STAPLE_STACKS_WIDTH)
	return order + 2
end

--[[
    Lays a section's staples out two pairs to a row -- each row WRAPPED IN AN
    INLINE GROUP of its own. The wrapper is load-bearing, exactly as
    the sub-option rows document: laid out flat, a row holds together only
    because its widths happen to fill the line, and any skin that changes
    the arithmetic -- ElvUI's Ace3 skin did -- lets the next checkbox float
    up into the leftover slack and shear every column after it. A fill-width
    group always gets a line to itself, so one group per row pins one row
    per row no matter whose skin is running; a row that still overflows
    wraps INSIDE its own group instead of corrupting its neighbors.

    The gutter is a blank cell between the columns, not after them -- the
    right column's air comes from the window edge -- so a row with a single
    pair takes no gutter at all. The categories arrive already in the display
    order the caller worked out.
]]
local function AddStapleRows(args, categories, order)
	for index = 1, #categories, 2 do
		local first = categories[index]
		local second = categories[index + 1]

		local rowArgs = {}
		local rowOrder = AddStaplePair(rowArgs, first, 1)
		if second then
			rowArgs["gutter" .. second.key] = {
				type = "description",
				name = " ",
				width = COLUMN_GUTTER_WIDTH,
				order = rowOrder,
			}
			rowOrder = rowOrder + 1
			AddStaplePair(rowArgs, second, rowOrder)
		end

		args["row" .. first.key] = {
			type = "group",
			name = "",
			inline = true,
			order = order,
			args = rowArgs,
		}
		order = order + 1
	end
	return order
end

--[[
    One section's categories in display order, holding only the ones this
    class is offered right now -- Restocker-Starter-List.lua's class and availability
    rules keep another class's reagents, a not-yet-trained spell's reagent,
    and items this client's folder does not carry out of the window.
]]
local function SectionCategories(section)
	local categories = {}
	for _, category in ipairs(ns.GetStarterCategories()) do
		if
			category.section == section
			and ns.IsStarterCategoryForClass(category)
			and ns.IsStarterCategoryAvailable(category)
		then
			categories[#categories + 1] = category
		end
	end

	--[[
	    Display order is computed, never authored: the staples with a stacks
	    dropdown lead, the fixed-amount singles follow, and each run sorts
	    alphabetically by the name it shows -- so the dropdown column stays
	    a solid block instead of gap-toothing around the single items, and
	    every locale reads A to Z without re-authoring the spec. A row whose
	    name is still loading sorts after the named ones, by item ID, and
	    takes its place when the window repaints with the name. The names are
	    read once, before sorting, so the order cannot shift mid-sort.
	]]
	local names = {}
	for _, category in ipairs(categories) do
		names[category] = ns.GetStarterCategoryName(category) or false
	end
	table.sort(categories, function(a, b)
		local aFixed = a.fixedAmount ~= nil
		local bFixed = b.fixedAmount ~= nil
		if aFixed ~= bFixed then
			return bFixed
		end
		local aName, bName = names[a], names[b]
		if aName and bName then
			return aName < bName
		end
		if aName or bName then
			return aName ~= false
		end
		return ns.GetStarterCategoryNameItemID(a) < ns.GetStarterCategoryNameItemID(b)
	end)
	return categories
end

--[[
    Every item an offered staple needs that the client has not resolved yet --
    the one a tick adds, for its stack size, and the one the row is named for
    -- handed to ns.WarmItemCache so the window repaints as the answers land.
    Called on every build, like the other item panels. It is the only warming
    the window gets from either way in (the login trigger and the Pick
    Staples button), and a resolved item is simply not cold.
]]
local function WarmOfferedItems()
	local coldItemIDs, seen = {}, {}
	local function Cold(itemID)
		if not seen[itemID] then
			seen[itemID] = true
			coldItemIDs[#coldItemIDs + 1] = itemID
		end
	end
	for _, category in ipairs(ns.GetStarterCategories()) do
		if ns.IsStarterCategoryForClass(category) and ns.IsStarterCategoryAvailable(category) then
			if not ns.GetStarterCategoryStackSize(category) then
				Cold(ns.GetStarterCategoryItemID(category))
			end
			if not ns.GetStarterCategoryName(category) then
				Cold(ns.GetStarterCategoryNameItemID(category))
			end
		end
	end
	ns.WarmItemCache(coldItemIDs, ns.OPTIONS_REGISTRY.StarterListPopup)
end

--[[
    True while the window the login trigger opened is up, from
    ns.ShowStarterListPopup until the host frame's OnHide below.
]]
local openedFromLogin = false

function ns.BuildStarterListPopupOptions()
	local args = {}
	local order = 1

	--[[
	    The intro, one widget: a paragraph saying why the window opened and
	    what a check does, and on the login route a second, after a blank
	    line, with the way back in. The /crs literal is colored as an
	    interaction, the same way the Restocker panel's own description colors
	    it.

	    The opening sentence answers to how the window was reached, because both
	    routes are real: the login trigger only fires over an empty list, while
	    the Restock window's Pick Staples button opens it over whatever the
	    player already has. The login route is read from openedFromLogin rather than
	    from the list, because the trigger writes the class's pre-ticked
	    staples onto the list just before the window opens. Resolved per build
	    rather than once, since AceConfig re-invokes this builder on every open.
	    It and the sentences on what a check does are run together with a
	    space, the way the delete confirmation runs its own.

	    The way back in is said only at login. The list is open behind this
	    window on both routes, but only from the Pick Staples button has the
	    player already found their own way to it; at login it opened for them,
	    and the command is how they get it back once both are closed.
	]]
	local introKey = (openedFromLogin or ns.IsRestockListEmpty()) and "STARTER_POPUP_INTRO_EMPTY"
		or "STARTER_POPUP_INTRO_STOCKED"
	local paragraphs = { L[introKey] .. " " .. L["STARTER_POPUP_INTRO_HOW"] }
	if openedFromLogin then
		paragraphs[#paragraphs + 1] = string.format(
			L["STARTER_POPUP_COMMAND_HINT"],
			GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("BODY")
		)
	end
	args.descIntro = Desc(GetColor("BODY") .. table.concat(paragraphs, "\n\n") .. "|r", order)
	order = order + 1
	args.spacerIntro = Spacer(order)
	order = order + 1

	--[[
	    Every section is drawn only when it has something to offer this
	    character right now -- another class's section, or one whose every
	    item is still level-locked, is omitted outright rather than shown
	    empty. Class and level are fixed for the sitting, so there is no
	    state change for a hidden-function to answer.

	    Top to bottom they run from what everyone stocks to what one class
	    does: food and water, the rogue's poisons, ammo, then the class
	    reagents and tools, where the Hearthstone closes the window as the
	    one row that is nobody's consumable.
	]]

	--[[
	    Food, then Water as the grid's last cell: the heading names both, so the
	    drink sits in the same block as the six foods rather than on a line of
	    its own under a gap. The foods sort A to Z among themselves, and Water
	    follows whatever a locale calls it. For a class with no Water row the
	    heading names only what is there.
	]]
	local provisions = SectionCategories("food")
	local waterCategories = SectionCategories("water")
	for _, category in ipairs(waterCategories) do
		provisions[#provisions + 1] = category
	end
	if #provisions > 0 then
		local foodHeaderText = (#waterCategories > 0) and L["STARTER_POPUP_FOOD_AND_WATER_HEADER"]
			or L["STARTER_POPUP_FOOD_HEADER"]
		args.headerFood = Header(foodHeaderText, order)
		order = order + 1
		-- A section header is always followed by a line break (house rhythm).
		args.spacerFoodHeader = Spacer(order)
		order = order + 1
		order = AddStapleRows(args, provisions, order)
		args.spacerFood = Spacer(order)
		order = order + 1
	end

	--[[
	    Poisons, the rogue's own section, led by a note that the ingredients
	    take care of themselves -- the crafting-reagent half of the Restocker
	    already shops for a listed poison's makings, and a fresh rogue has no
	    way to know that. The note follows the canonical section rhythm
	    (header, line break, description, line break, controls), opening with
	    the class-colored class name the minimap tooltip's notes open with.
	]]
	local poisonCategories = SectionCategories("poisons")
	if #poisonCategories > 0 then
		args.headerPoisons = Header(L["STARTER_POPUP_POISONS_HEADER"], order)
		order = order + 1
		-- A section header is always followed by a line break (house rhythm).
		args.spacerPoisonsHeader = Spacer(order)
		order = order + 1
		args.descPoisonsNote = Desc(
			GetColor("BODY")
				.. string.format(
					L["STARTER_POPUP_POISONS_NOTE"],
					"|cff" .. ns.CLASS_COLORS.ROGUE .. UnitClass("player") .. "|r" .. GetColor("BODY")
				)
				.. "|r",
			order
		)
		order = order + 1
		args.spacerPoisonsNote = Spacer(order)
		order = order + 1
		order = AddStapleRows(args, poisonCategories, order)
		args.spacerPoisons = Spacer(order)
		order = order + 1
	end

	-- Ammo, above the reagents: for the classes that shoot it is a staple in the way food is.
	local ammoCategories = SectionCategories("ammo")
	if #ammoCategories > 0 then
		args.headerAmmo = Header(L["STARTER_POPUP_AMMO_HEADER"], order)
		order = order + 1
		-- A section header is always followed by a line break (house rhythm).
		args.spacerAmmoHeader = Spacer(order)
		order = order + 1
		order = AddStapleRows(args, ammoCategories, order)
		args.spacerAmmo = Spacer(order)
		order = order + 1
	end

	-- Class reagents and tools -- a rogue's powders and picks, a druid's seeds, a priest's candles -- and the Hearthstone.
	local reagentCategories = SectionCategories("reagents")
	if #reagentCategories > 0 then
		args.headerReagents = Header(L["STARTER_POPUP_REAGENTS_HEADER"], order)
		order = order + 1
		-- A section header is always followed by a line break (house rhythm).
		args.spacerReagentsHeader = Spacer(order)
		order = order + 1
		order = AddStapleRows(args, reagentCategories, order)
		-- The last section's spacer is the air between the final row and the footer the frame fits up against.
		args.spacerReagents = Spacer(order)
	end

	WarmOfferedItems()

	--[[
	    A title of its own, not the Restock window's: the two are open at once,
	    this one over the other, and a borrowed title would give both windows
	    the same name.
	]]
	return {
		type = "group",
		name = L["STARTER_POPUP_TITLE"],
		args = args,
	}
end

--------------------------------------------------------------------------------
-- Window
--------------------------------------------------------------------------------

--[[
    True from Open until the host frame's next OnHide -- which is how the
    hook below tells THIS window's close apart from a later hide of the same
    pooled frame serving some other AceGUI window.
]]
local starterPopupOpen = false

--[[
    Two things this window adds to the frame AceConfigDialog hands it: a solid
    fill behind it, and the don't-show-again checkbox on its footer.

    AceConfigDialog.OpenFrames hands back a POOLED widget: after this window
    closes, the same underlying frame can be recycled for any other AceGUI
    window. So both are re-adopted on every open, orphaned again the moment
    their host hides, and the hide-hook is installed once per recycled frame --
    a HookScript can never be removed, so it is flagged rather than stacked.
    The host passed in is that widget's underlying WoW frame, not the widget
    itself.
]]

--[[
    The AceGUI Frame widget's own background is the game's dialog texture,
    which is see-through by design. Over the game world that is fine. Over the
    Restock List window, which is where the Pick Staples button opens this
    one, the list's rows and headings showed through between the staples and
    neither could be read. So a solid fill goes underneath, exactly where the
    host draws its own background: inset by the host backdrop's insets, which
    keeps it inside the border whatever backdrop a skin has given the frame.

    It is a frame of its own in the strata under the host's, never a texture
    on the host: strata order is absolute, so the fill draws behind the host's
    backdrop and border whatever their frame levels are doing. AceGUI puts
    every Frame widget at FULLSCREEN_DIALOG, which puts the fill at FULLSCREEN,
    still above the Restock List window at HIGH. The strata is read off the
    host rather than assumed, because a fill that landed above its host would
    black the whole window out.
]]
local BACKING_DEFAULT_INSET = 8 -- the AceGUI Frame backdrop's own, used when a host has no backdrop to read
local STRATA_BELOW = {
	LOW = "BACKGROUND",
	MEDIUM = "LOW",
	HIGH = "MEDIUM",
	DIALOG = "HIGH",
	FULLSCREEN = "DIALOG",
	FULLSCREEN_DIALOG = "FULLSCREEN",
	TOOLTIP = "FULLSCREEN_DIALOG",
}

local backing

local function AttachBacking(host)
	if not backing then
		backing = CreateFrame("Frame", nil, UIParent)
		local fill = backing:CreateTexture(nil, "BACKGROUND")
		fill:SetAllPoints()
		fill:SetColorTexture(0, 0, 0, 1)
	end

	-- A backdrop that names no insets, as a skin's flat one does, is drawn edge to edge.
	local backdrop = host.backdropInfo
	local insets = backdrop and backdrop.insets
	local unstated = backdrop and 0 or BACKING_DEFAULT_INSET
	local left = insets and insets.left or unstated
	local right = insets and insets.right or unstated
	local top = insets and insets.top or unstated
	local bottom = insets and insets.bottom or unstated

	backing:SetParent(host)
	backing:ClearAllPoints()
	backing:SetPoint("TOPLEFT", host, "TOPLEFT", left, -top)
	backing:SetPoint("BOTTOMRIGHT", host, "BOTTOMRIGHT", -right, bottom)
	-- After SetParent, which hands a frame its new parent's strata and a level above it.
	local hostStrata = host:GetFrameStrata()
	local strataBelow = STRATA_BELOW[hostStrata]
	if strataBelow then
		backing:SetFrameStrata(strataBelow)
	else
		-- A host already in the lowest strata: the same one, a level down.
		backing:SetFrameStrata(hostStrata)
		backing:SetFrameLevel(math.max(0, host:GetFrameLevel() - 1))
	end
	backing:Show()
end

--[[
    The don't-show-again checkbox sits on the frame's own footer line, beside
    the stock Close button, rather than in the scrolling content above -- the
    two ways of ending this conversation belong on one row. The AceGUI Frame
    widget draws a status bar there that AceConfigDialog leaves empty, so the
    checkbox borrows that dead space.

    The offsets are pinned to the bundled AceGUI Frame widget's own footer
    geometry (AceGUIContainer-Frame.lua: Close at BOTTOMRIGHT -27,17 and 20
    tall, the status bar at BOTTOMLEFT 15,15 and 24 tall -- both centered on
    y 27), so the row can only drift if the bundled library does.
]]
local DISMISS_CHECKBOX_SIZE = 24
local DISMISS_CHECKBOX_X = 18
local DISMISS_CHECKBOX_Y = 15
local DISMISS_LABEL_GAP = 2

local dismissCheckbox

local function AttachDismissCheckbox(host)
	if not dismissCheckbox then
		dismissCheckbox = CreateFrame("CheckButton", nil, UIParent, "UICheckButtonTemplate")
		dismissCheckbox:SetSize(DISMISS_CHECKBOX_SIZE, DISMISS_CHECKBOX_SIZE)

		local label = dismissCheckbox:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		label:SetPoint("LEFT", dismissCheckbox, "RIGHT", DISMISS_LABEL_GAP, 0)
		label:SetText(L["STARTER_POPUP_DISMISS"])

		dismissCheckbox:SetScript("OnClick", function(self)
			local checked = self:GetChecked() and true or false
			PlaySound(checked and SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON or SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
			ns.SetStarterPopupDismissed(checked)
		end)

		-- The same tooltip helper every Restocker-window control routes through.
		ns.SetupRestockerTooltip(dismissCheckbox, L["STARTER_POPUP_DISMISS"], L["STARTER_POPUP_DISMISS_DESCRIPTION"])
	end

	dismissCheckbox:SetParent(host)
	dismissCheckbox:ClearAllPoints()
	dismissCheckbox:SetPoint("BOTTOMLEFT", host, "BOTTOMLEFT", DISMISS_CHECKBOX_X, DISMISS_CHECKBOX_Y)
	-- Above the status bar it overlays, which is itself a Button.
	dismissCheckbox:SetFrameLevel(host:GetFrameLevel() + 10)
	dismissCheckbox:SetChecked(ns.IsStarterPopupDismissed())
	dismissCheckbox:Show()
end

-- Hands one of the two back to UIParent, hidden, when the host it was serving goes away.
local function Orphan(adornment, host)
	if adornment and adornment:GetParent() == host then
		adornment:Hide()
		adornment:SetParent(UIParent)
	end
end

local function AdornHost(host)
	AttachBacking(host)
	AttachDismissCheckbox(host)

	if not host.connoisseurStarterDismissHooked then
		host.connoisseurStarterDismissHooked = true
		host:HookScript("OnHide", function()
			Orphan(backing, host)
			Orphan(dismissCheckbox, host)
			--[[
			    Closing this window retires its "New" flags: the group is a
			    note about items just added HERE, and once the window is gone
			    the note is stale -- the same rule as the Restocker window's
			    own OnHide, and as true with that window still open behind
			    this one, where the repaint below files the new rows under
			    their own types. The flag guard keeps a recycled frame's later
			    hides (serving some other AceGUI window) from clearing flags
			    that belong to a sitting still in progress.
			]]
			if starterPopupOpen then
				starterPopupOpen = false
				openedFromLogin = false
				ns.SetRestockWindowClosesOnEscape(true)
				ns.ClearRestockNewItems()
				ns.UpdateRestockList()
			end
		end)
	end
end

--[[
    Draw the frame in to its content. By the time Open returns AceConfigDialog
    has laid the rows out in a scroll container, the frame's only child, whose
    content frame is exactly as tall as what it holds; the frame takes that
    plus its own title and footer, up to the cap.

    The height goes into the dialog's status table as well as onto the frame,
    because AceConfigDialog reopens the window from that table at every
    repaint -- each tick, and each item whose name arrives.

    With nothing to measure (a library that builds the window some other way)
    the window simply stays at the cap it opened at.
]]
local function FitPopupHeight(openFrame)
	local scroll = openFrame.children and openFrame.children[1]
	local content = scroll and scroll.content
	local contentHeight = content and content:GetHeight()
	if not contentHeight or contentHeight <= 0 then
		return
	end

	local height = math.min(POPUP_MAX_HEIGHT, math.ceil(contentHeight) + POPUP_CHROME_HEIGHT + POPUP_FIT_MARGIN)
	AceConfigDialog:GetStatusTable(ns.OPTIONS_REGISTRY.StarterListPopup).height = height
	openFrame:SetHeight(height)
end

-- fromLogin: true only from the login trigger, and set before Open, which builds the window.
function ns.ShowStarterListPopup(fromLogin)
	local registryName = ns.OPTIONS_REGISTRY.StarterListPopup
	openedFromLogin = fromLogin == true
	AceConfigDialog:SetDefaultSize(registryName, POPUP_WIDTH, POPUP_MAX_HEIGHT)
	AceConfigDialog:Open(registryName)
	starterPopupOpen = true

	--[[
	    Fixed size, same reasoning and same post-Open timing as GogoLoot's
	    master-looter pop-up: nothing here benefits from being dragged bigger,
	    and the AceGUI Frame widget only exists once Open has built it.
	]]
	local openFrame = AceConfigDialog.OpenFrames[registryName]
	if not openFrame then
		return
	end
	if openFrame.EnableResize then
		openFrame:EnableResize(false)
	end
	if openFrame.frame then
		AdornHost(openFrame.frame)
		-- So Escape closes this window alone; the host's OnHide hands Escape back.
		ns.SetRestockWindowClosesOnEscape(false)
	end

	--[[
	    Fitted now, so the window never shows at the wrong height, and once more
	    on the next frame, when every wrapped line has settled at its final
	    height.
	]]
	FitPopupHeight(openFrame)
	C_Timer.After(0, function()
		local stillOpen = starterPopupOpen and AceConfigDialog.OpenFrames[registryName]
		if stillOpen then
			FitPopupHeight(stillOpen)
		end
	end)
end
