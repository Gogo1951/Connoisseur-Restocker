local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local format = string.format

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- Shared Option Widgets
--------------------------------------------------------------------------------

--[[
    Dot-defined widget constructors shared by every options panel. Callers use
    dot invocation (ns.OptionsHeader(...)), matching the panel builders.
]]

function ns.OptionsHeader(text, order, hidden)
	return {
		type = "header",
		name = GetColor("TITLE") .. text .. "|r",
		order = order,
		hidden = hidden,
	}
end

--[[
    The header and the spacer take `hidden`, so a gated section collapses whole
    instead of leaving a stray gap behind. A gated description or row label is
    written inline as its own widget with a `hidden` function.
]]
function ns.OptionsDesc(text, order)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		order = order,
	}
end

function ns.OptionsSpacer(order, hidden)
	return {
		type = "description",
		name = " ",
		order = order,
		hidden = hidden,
	}
end

--[[
    An Example line: the chat prints a feature makes, each built by
    ns.BuildPrintLine, under a silver "Example:" label. linesFunction returns
    the print bodies and runs at every draw, so the Example follows the
    settings the moment they change. A blank line parts the lines so each
    reads on its own. Silver opens again after the lines, for a locale whose
    label continues past its %s.
]]
function ns.OptionsExample(order, linesFunction, hidden)
	return {
		type = "description",
		name = function()
			local lines = {}
			for index, body in ipairs(linesFunction()) do
				lines[index] = ns.BuildPrintLine(body)
			end
			return GetColor("HELP")
				.. format(L["SAMPLE_EXAMPLE"], table.concat(lines, "\n\n") .. GetColor("HELP"))
				.. "|r"
		end,
		fontSize = "medium",
		order = order,
		hidden = hidden,
	}
end

--[[
    The left half of a label-beside-control row: this cell, then the control
    with name = "" ordered immediately after it. A caption left on the control
    would put the label back above the widget and break the row.
]]
function ns.OptionsRowLabel(text, order, width)
	return {
		type = "description",
		name = text,
		fontSize = "medium",
		width = width or ns.OPTIONS_LABEL_WIDTH,
		order = order,
	}
end

--------------------------------------------------------------------------------
-- Feature Switches
--------------------------------------------------------------------------------

--[[
    Each feature's master switch, drawn twice: in the General panel's Features
    section and on the feature's own panel. Both copies come from here and
    share one setter, and a change repaints both panels, so neither shows a
    stale box.
]]
local FEATURE_SWITCHES = {
	Macros = {
		key = "macrosEnabled",
		name = "OPTIONS_MACROS_ENABLE",
		desc = "OPTIONS_MACROS_ENABLE_DESCRIPTION",
		registry = "Macros",
		set = function(value)
			ns.SetMacrosEnabled(value)
		end,
	},
	Restocker = {
		key = "restockerEnabled",
		name = "OPTIONS_RESTOCKER_ENABLE",
		desc = "OPTIONS_RESTOCKER_ENABLE_DESCRIPTION",
		registry = "Restocker",
		set = function(value)
			ns.SetRestockerEnabled(value)
			ns.UpdateMinimapIcon()
		end,
	},
	ReadinessReport = {
		key = "readinessReportEnabled",
		name = "OPTIONS_READINESS_ENABLE",
		desc = "OPTIONS_READINESS_ENABLE_DESCRIPTION",
		registry = "ReadinessReport",
	},
	InventoryReport = {
		key = "inventoryReport",
		name = "OPTIONS_INVENTORY_REPORT",
		desc = "OPTIONS_INVENTORY_REPORT_DESCRIPTION",
		registry = "Restocker",
	},
}

function ns.OptionsFeatureSwitch(feature, order, width)
	local switch = FEATURE_SWITCHES[feature]
	return {
		type = "toggle",
		name = L[switch.name],
		desc = L[switch.desc],
		order = order,
		width = width or "full",
		get = function()
			return ns.db and ns.db.global[switch.key]
		end,
		set = function(_, value)
			if switch.set then
				switch.set(value)
			else
				ns.db.global[switch.key] = value
			end
			AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.General)
			AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY[switch.registry])
		end,
	}
end

--------------------------------------------------------------------------------
-- Shared Values
--------------------------------------------------------------------------------

--[[
    When-to-use mode labels, by group or by level, shared by every mode
    dropdown: Buff Food, Scroll Buffs, Pet Food Buffs, and Use Conjured Food &
    Water First. Every dropdown offers all six in this order, none trimmed per
    feature even where one reads oddly, and one choice is one condition:
    group and level never combine.
]]
ns.MODE_VALUES = {
	always = L["MODE_ALWAYS"],
	solo = L["MODE_SOLO"],
	party = L["MODE_PARTY"],
	raid = L["MODE_RAID"],
	leveling = L["MODE_LEVELING"],
	maxlevel = L["MODE_MAX_LEVEL"],
}

--------------------------------------------------------------------------------
-- Item Cache Warming
--------------------------------------------------------------------------------

--[[
    C_Item.GetItemInfo answers nil for an item the client has not cached yet, which is
    the normal state for a list of item ids on a fresh login -- nothing has put
    those items in front of the player, so nothing has pulled their data. A panel
    that lists items renders those rows as L["LOADING_ITEM"] and hands the cold
    ids here.

    Each id is requested from the server, and the panel's registry name holds a
    GET_ITEM_INFO_RECEIVED waiter (ns.RequestItemInfoEvents) while any id it
    handed in is still outstanding. Core passes every answer to
    ns.OnOptionsItemInfoReceived below, which repaints the panels waiting on
    that id and releases a panel's waiter once nothing it asked about is left.
    A repaint that re-enters with still-cold ids, or a row added mid-load, just
    adds to the panel's pending set. An id the client has no item for, or one
    whose answer already failed, is never requested: its answer never comes, so
    a wait on it would hold the event for the rest of the session.
]]

-- registryName -> { [itemID] = true }, the ids each panel still waits on.
local warming = {}

-- [itemID] = true for every id whose answer came back failed this session.
local failedItemIDs = {}

local function WaiterKey(registryName)
	return "options:" .. registryName
end

function ns.WarmItemCache(itemIDs, registryName)
	if not (itemIDs and itemIDs[1] and registryName) then
		return
	end

	local pending = warming[registryName] or {}
	local requested = false
	for _, itemID in ipairs(itemIDs) do
		if not failedItemIDs[itemID] and C_Item.DoesItemExistByID(itemID) then
			pending[itemID] = true
			C_Item.RequestLoadItemDataByID(itemID)
			requested = true
		end
	end
	if requested then
		warming[registryName] = pending
		ns.RequestItemInfoEvents(WaiterKey(registryName))
	end
end

--[[
    One GET_ITEM_INFO_RECEIVED answer, handed on by Core after the Restocker
    handler has forgotten the item's remembered miss. A failed answer settles
    the wait too, and is remembered so the repaint that follows does not ask
    again: its row keeps its loading text.
]]
function ns.OnOptionsItemInfoReceived(itemID, success)
	if success ~= true then
		failedItemIDs[itemID] = true
	end
	for registryName, pending in pairs(warming) do
		if pending[itemID] then
			pending[itemID] = nil
			AceConfigRegistry:NotifyChange(registryName)
			if next(pending) == nil then
				warming[registryName] = nil
				ns.ReleaseItemInfoEvents(WaiterKey(registryName))
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Item Input Parsing
--------------------------------------------------------------------------------

--[[
    Two shapes reach an add box: a bare id the player looked up, and a whole item
    link, which is what shift-clicking an item link in chat drops into a focused
    edit box. Anything else is rejected, so a stray word never becomes a row that
    renders as an unresolvable id forever.
]]
function ns.ParseItemInput(rawInput)
	if type(rawInput) ~= "string" then
		return nil
	end

	local itemID = tonumber(rawInput:match("item:(%d+)") or rawInput:match("^%s*(%d+)%s*$"))
	if itemID and itemID > 0 then
		return itemID
	end
	return nil
end

--------------------------------------------------------------------------------
-- Item Identifier Sort
--------------------------------------------------------------------------------

--[[
    Sorted by name, because a list ordered by id reads as random to the player.
    Items the client has not cached yet have no name to sort on, so they fall to
    the bottom by id rather than clustering under an empty string at the top;
    they re-sort into place as the panel repaints. Equal names tie-break on id,
    which makes the comparator a total order -- without it two identically named
    items compare equal and their rows reshuffle on every repaint.
]]
function ns.SortItemIdentifiersByName(identifiers)
	table.sort(identifiers, function(a, b)
		local nameA = C_Item.GetItemInfo(a) or ""
		local nameB = C_Item.GetItemInfo(b) or ""
		if nameA == nameB then
			return a < b
		end
		if nameA == "" then
			return false
		end
		if nameB == "" then
			return true
		end
		return nameA < nameB
	end)
end

--------------------------------------------------------------------------------
-- Item Display
--------------------------------------------------------------------------------

--[[
    One row's item, rendered for the ItemLink widget below: icon plus the item's
    name in its link's own color, so quality reads at a glance, and without the
    link's brackets (ns.UnbracketItemLink), which the icon makes redundant. An
    id the client has not answered for yet shows as loading text instead --
    ns.WarmItemCache repaints the panel as the data lands.
]]
function ns.GetItemDisplayName(itemID)
	local _, itemLink, _, _, _, _, _, _, _, icon = C_Item.GetItemInfo(itemID)

	if itemLink and icon then
		return format("|T%s:16|t %s", icon, ns.UnbracketItemLink(itemLink))
	elseif itemLink then
		return ns.UnbracketItemLink(itemLink)
	end

	return GetColor("MUTED") .. format(L["LOADING_ITEM"], itemID) .. "|r"
end

--------------------------------------------------------------------------------
-- Shared Item List Builder
--------------------------------------------------------------------------------

--[[
    Every player-managed item list renders through here, so lists add and remove
    the same way in every panel. The caller supplies the labels, the source
    table, and the callbacks; this owns the shape. Spec:

      getSourceTable: function returning the table of itemID keys to list
      onAdd: function(itemID) adding an item to that source
      onRemove: function(itemID) removing one
      notifyKey: AceConfigRegistry name to NotifyChange on every mutation
      labels: { addName, addHelp, addInvalid, removeDesc, empty }
      rowWidth: optional total row budget, default ns.OPTIONS_ROW_WIDTH
      startOrder: optional first order, so a panel can seat its own head above
      actionColumn: optional per-row button, { width, name, desc, func(itemID) }
        (the Ignore List's Global button)
      addFromBags: optional true to put an Add from Bags picker above the add
        box, listing what the player carries that isn't on the list yet
        (labels then carry fromBagsName and fromBagsDesc)
      onClear: optional function emptying the list, for a Clear List button
        under the rows (labels then carry clearName, clearDesc, clearConfirm)

    Restore Defaults is deliberately absent: it belongs to lists that ship
    defaults, and every list here starts empty, so Clear List is what returns
    one to its default.
]]

--[[
    Remove is an icon, not a labeled button. An execute carrying an image renders
    as an AceGUI Icon; the stock Button insets its font string 15px from each
    edge, which in a column this narrow clips a caption to a sliver. The
    group-loot pass texture is already the game's own "get rid of this" mark, and
    name stays empty so the Icon draws no caption -- the label rides in desc,
    which AceConfigDialog shows on hover.
]]
local REMOVE_ICON = "Interface/Buttons/UI-GroupLoot-Pass-Up"
local REMOVE_ICON_SIZE = 16

--[[
    The Add from Bags picker's choices: one entry per distinct item in the
    carried bags that the list doesn't hold yet, as icon and link, sorted by
    name. Built on every repaint, which the list panels get after each edit; an
    item looted while the panel stays open shows up on the next one. The game
    closes the bags when the options open, so this is the only way to pick an
    item without knowing its id.
]]
local function GetCarriedItemChoices(sourceTable)
	local values, sorting, seen = {}, {}, {}

	for bag = 0, NUM_BAG_SLOTS do
		for slot = 1, (C_Container.GetContainerNumSlots(bag) or 0) do
			local info = C_Container.GetContainerItemInfo(bag, slot)
			local itemID = info and info.itemID
			if itemID and not seen[itemID] and not (sourceTable and sourceTable[itemID]) then
				seen[itemID] = true
				values[itemID] = ns.GetItemDisplayName(itemID)
				sorting[#sorting + 1] = itemID
			end
		end
	end

	ns.SortItemIdentifiersByName(sorting)
	return values, sorting
end

function ns.BuildItemListOptions(spec)
	local labels = spec.labels
	local rowWidth = spec.rowWidth or ns.OPTIONS_ROW_WIDTH
	local args = {}
	local order = spec.startOrder or 1

	--[[
	    Clear List goes last, under the rows, at normal width: the top of a list
	    is for finding and adding, and a rarely used reset shouldn't be the first
	    thing there. Ordered far past any row so it lands last however long the
	    list is, and shown only while the list holds something.
	]]
	if spec.onClear and next(spec.getSourceTable() or {}) ~= nil then
		args.spacerClear = ns.OptionsSpacer(9998)
		args.clearList = {
			type = "execute",
			name = labels.clearName,
			desc = labels.clearDesc,
			confirm = true,
			confirmText = labels.clearConfirm,
			order = 10000,
			func = function()
				spec.onClear()
				AceConfigRegistry:NotifyChange(spec.notifyKey)
			end,
		}
	end

	--[[
	    The add rows' controls keep the standard control width, as Magic Eraser's
	    do, so a picked item's name has room; the label takes what the list's own
	    row budget leaves, so each row still ends where the item rows below it end.
	]]
	local addLabelWidth = rowWidth - ns.OPTIONS_CONTROL_WIDTH

	if spec.addFromBags then
		local values, sorting = GetCarriedItemChoices(spec.getSourceTable())

		args.addFromBagsLabel = ns.OptionsRowLabel(labels.fromBagsName, order, addLabelWidth)
		order = order + 1

		-- get returns nil so the picker reads empty again after each add.
		args.addFromBagsSelect = {
			type = "select",
			name = "",
			desc = labels.fromBagsDesc,
			width = ns.OPTIONS_CONTROL_WIDTH,
			order = order,
			values = values,
			sorting = sorting,
			disabled = function()
				return sorting[1] == nil
			end,
			get = function()
				return nil
			end,
			set = function(_, itemID)
				spec.onAdd(itemID)
				AceConfigRegistry:NotifyChange(spec.notifyKey)
			end,
		}
		order = order + 1
	end

	args.addItemLabel = ns.OptionsRowLabel(labels.addName, order, addLabelWidth)
	order = order + 1

	--[[
	    get returns empty so the box clears itself on the repaint that follows
	    each add. validate rejects anything ParseItemInput cannot read and any id
	    this client has no item for, which is what keeps a typo out of the list
	    rather than into it as a dead row.
	]]
	args.addItemInput = {
		type = "input",
		name = "",
		desc = labels.addHelp,
		width = ns.OPTIONS_CONTROL_WIDTH,
		order = order,
		validate = function(_, value)
			local itemID = ns.ParseItemInput(value)
			return (itemID and C_Item.DoesItemExistByID(itemID)) and true or labels.addInvalid
		end,
		get = function()
			return ""
		end,
		set = function(_, value)
			local itemID = ns.ParseItemInput(value)
			if not itemID then
				return
			end
			spec.onAdd(itemID)
			AceConfigRegistry:NotifyChange(spec.notifyKey)
		end,
	}
	order = order + 1

	args.spacerRows = ns.OptionsSpacer(order)
	order = order + 1

	local identifiers = {}
	for itemID in pairs(spec.getSourceTable() or {}) do
		identifiers[#identifiers + 1] = itemID
	end

	if #identifiers == 0 then
		args.descEmpty = ns.OptionsDesc(GetColor("HELP") .. labels.empty .. "|r", order)
		return args
	end

	ns.SortItemIdentifiersByName(identifiers)

	local actionColumn = spec.actionColumn
	local itemWidth = rowWidth - ns.OPTIONS_REMOVE_ICON_WIDTH
	if actionColumn then
		itemWidth = itemWidth - actionColumn.width
	end

	local coldItemIDs = {}

	for _, itemID in ipairs(identifiers) do
		local capturedID = itemID

		if not C_Item.GetItemInfo(capturedID) then
			coldItemIDs[#coldItemIDs + 1] = capturedID
		end

		--[[
		    AceGUI's flow layout has no notion of a row: it packs widgets left to
		    right and wraps only when the next will not fit, so laid out flat,
		    cells from different items run together the moment the leftover space
		    takes the next item's name. An inline group with an empty name renders
		    as a bare SimpleGroup -- no border, no title, no padding -- at "fill"
		    width, and the flow layout always gives a fill widget its own line. The
		    cells then flow inside it, so every row breaks at the same points.
		]]
		local cells = {
			item = {
				type = "input",
				name = "",
				dialogControl = ns.ITEM_LINK_WIDGET_TYPE,
				width = itemWidth,
				order = 1,
				get = function()
					return tostring(capturedID)
				end,
				set = function() end,
			},
		}

		if actionColumn then
			cells.action = {
				type = "execute",
				name = actionColumn.name,
				desc = actionColumn.desc,
				width = actionColumn.width,
				order = 2,
				func = function()
					actionColumn.func(capturedID)
					AceConfigRegistry:NotifyChange(spec.notifyKey)
				end,
			}
		end

		-- Removing one row takes one click and no confirm.
		cells.remove = {
			type = "execute",
			name = "",
			desc = labels.removeDesc,
			image = REMOVE_ICON,
			imageWidth = REMOVE_ICON_SIZE,
			imageHeight = REMOVE_ICON_SIZE,
			width = ns.OPTIONS_REMOVE_ICON_WIDTH,
			order = 3,
			func = function()
				spec.onRemove(capturedID)
				AceConfigRegistry:NotifyChange(spec.notifyKey)
			end,
		}

		args["item_" .. tostring(capturedID)] = {
			type = "group",
			name = "",
			inline = true,
			order = order,
			args = cells,
		}
		order = order + 1
	end

	ns.WarmItemCache(coldItemIDs, spec.notifyKey)

	return args
end

--------------------------------------------------------------------------------
-- Item Link Widget
--------------------------------------------------------------------------------

--[[
    A label that draws an item and shows that item's own tooltip on hover, used
    via dialogControl on the rows the builder above emits. AceConfig renders a
    description as a plain Label, which has no mouse scripts at all and so never
    fires an OnEnter; this is that same widget with mouse handling, so the row
    can carry a real GameTooltip. The option's get returns the item id as a
    string and SetText resolves it through ns.GetItemDisplayName.
]]
local ITEM_LINK_WIDGET_VERSION = 1

local function OnItemLinkEnter(frame)
	local widget = frame.obj
	if not widget.itemID then
		return
	end
	--[[
	    The bare "item:id" form rather than the link off C_Item.GetItemInfo, so a row
	    still waiting on its item data gets a tooltip too -- and hovering it pulls
	    the very data the row is waiting for.
	]]
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetHyperlink("item:" .. widget.itemID)
	GameTooltip:Show()
end

local function OnItemLinkLeave()
	GameTooltip:Hide()
end

local itemLinkMethods = {}

function itemLinkMethods:OnAcquire()
	self.itemID = nil
	self:SetHeight(20)
end

function itemLinkMethods:OnRelease()
	self.itemID = nil
end

function itemLinkMethods:SetText(text)
	local itemID = tonumber(text)
	if itemID then
		self.itemID = itemID
		self.label:SetText(ns.GetItemDisplayName(itemID))
	else
		self.label:SetText(text or "")
	end
end

function itemLinkMethods:GetText()
	return self.itemID and tostring(self.itemID) or ""
end

-- AceConfigDialog drives every input control through these; a row is read-only.
function itemLinkMethods:SetLabel() end

function itemLinkMethods:SetMaxLetters() end

function itemLinkMethods:SetDisabled() end

local function ItemLinkWidgetConstructor()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetHeight(20)
	frame:EnableMouse(true)
	frame:SetScript("OnEnter", OnItemLinkEnter)
	frame:SetScript("OnLeave", OnItemLinkLeave)

	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
	label:SetJustifyH("LEFT")
	label:SetPoint("TOPLEFT")
	label:SetPoint("BOTTOMRIGHT")

	local widget = {
		label = label,
		frame = frame,
		type = ns.ITEM_LINK_WIDGET_TYPE,
	}

	for method, func in pairs(itemLinkMethods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(ns.ITEM_LINK_WIDGET_TYPE, ItemLinkWidgetConstructor, ITEM_LINK_WIDGET_VERSION)

--------------------------------------------------------------------------------
-- Icon Checkbox Widget
--------------------------------------------------------------------------------

--[[
    The stock AceGUI checkbox with air between its icon and its label, for a
    toggle that stands for an item: a staple in the staples pop-up, a macro on
    the Macros panel. The stock widget sets the label a pixel off the image,
    which suits a status glyph and crowds an item icon, so these rows take the
    gap the Restock List's own rows put between an icon and its name.

    AceConfig has no setting for that gap, so this is a widget type of its own:
    the stock checkbox, built by the stock constructor and handed back with its
    label put where the row wants it every time the stock code places it --
    when the image is set, and on the press and the release, which nudge the
    label and put it back. It is registered under a name of ours, so the shared
    CheckBox type, and every other add-on's checkboxes, stay exactly as they
    were.

    A skin that restyles checkboxes does so as the stock constructor registers
    the widget, before it is renamed here, so these rows are skinned like any
    other checkbox.

    A toggle wears it with three fields: image (the item's icon), imageCoords
    (ns.OPTIONS_ICON_TEXCOORDS) and dialogControl (ns.ICON_CHECKBOX_WIDGET_TYPE).
]]
local ICON_CHECKBOX_WIDGET_VERSION = 1
local ICON_LABEL_GAP = ns.RESTOCK_ICON_TEXT_GAP
-- The stock press: the label a pixel right and a pixel down while the mouse is held.
local PRESS_NUDGE = 1

-- The stock icon border, cropped away so an icon sits clean beside its checkbox.
ns.OPTIONS_ICON_TEXCOORDS = { 0.08, 0.92, 0.08, 0.92 }

-- Only a row showing an icon: without one the label sits against the box, where the stock code left it.
local function PlaceIconLabel(widget, nudge)
	if widget.image:GetTexture() then
		widget.text:SetPoint("LEFT", widget.image, "RIGHT", ICON_LABEL_GAP + nudge, -nudge)
	end
end

local function IconCheckBoxConstructor()
	local widget = AceGUI.WidgetRegistry.CheckBox()
	widget.type = ns.ICON_CHECKBOX_WIDGET_TYPE

	local SetImage = widget.SetImage
	function widget:SetImage(...)
		SetImage(self, ...)
		PlaceIconLabel(self, 0)
	end
	-- Hooked, so each runs after the stock handler has placed the label its own way.
	widget.frame:HookScript("OnMouseDown", function(frame)
		if not frame.obj.disabled then
			PlaceIconLabel(frame.obj, PRESS_NUDGE)
		end
	end)
	widget.frame:HookScript("OnMouseUp", function(frame)
		if not frame.obj.disabled then
			PlaceIconLabel(frame.obj, 0)
		end
	end)
	return widget
end

--[[
    The name is cleared where there is no stock checkbox to build on, and a
    toggle then asks for no control of its own: AceConfigDialog reports a
    control type it cannot create as an error on every repaint before it falls
    back.
]]
if AceGUI.WidgetRegistry and AceGUI.WidgetRegistry.CheckBox then
	AceGUI:RegisterWidgetType(ns.ICON_CHECKBOX_WIDGET_TYPE, IconCheckBoxConstructor, ICON_CHECKBOX_WIDGET_VERSION)
else
	ns.ICON_CHECKBOX_WIDGET_TYPE = nil
end
