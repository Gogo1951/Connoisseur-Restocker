local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- What The List Shows
--------------------------------------------------------------------------------

--[[
    Which items the window draws, in what order, under which category heading.
    Pure data: nothing here touches a frame.

    Both walks below take a `view` built once per redraw by ns.BuildRestockView --
    each item's group resolved a single time, and the filter text lowered a single
    time. That matters because the sort comparator asks for a group on every
    comparison: resolving it there made an item-cache lookup O(n log n) per
    keystroke in the filter box, on a path that already runs on every keystroke.
]]

--[[
    Case folding for the filter. string.lower folds ASCII only, so the capital
    letters of the supported Latin and Cyrillic locales (2-byte UTF-8: U+00C0 to
    U+00DE, U+0401 and U+0410 to U+042F) are mapped to their lowercase forms here.
    Built once; gsub leaves any sequence the table doesn't name as it is.
]]
local FOLD_UPPER = {}
for code = 0xC0, 0xDE do
	if code ~= 0xD7 then
		FOLD_UPPER[string.char(0xC3, code - 0x40)] = string.char(0xC3, code - 0x20)
	end
end
for code = 0x10, 0x1F do
	FOLD_UPPER[string.char(0xD0, 0x80 + code)] = string.char(0xD0, 0xA0 + code)
end
for code = 0x20, 0x2F do
	FOLD_UPPER[string.char(0xD0, 0x80 + code)] = string.char(0xD1, 0x60 + code)
end
FOLD_UPPER[string.char(0xD0, 0x81)] = string.char(0xD1, 0x91)

local function Fold(text)
	return (text:lower():gsub("[\195\208][\128-\191]", FOLD_UPPER))
end

-- Was this item added during the current viewing of the window? See ns.restockNewItems.
local function IsNewItem(item)
	return (item.itemID ~= nil) and (ns.restockNewItems[item.itemID] == true)
end

--[[
    The client's name for an item's class ("Consumable", "Trade Goods"), read by
    itemID from C_Item.GetItemInfoInstant, which answers without the item cache,
    so a cold row files under its real group. Nil for an ID the client has no item for.
]]
function ns.GetRestockItemTypeName(itemID)
	if not itemID then
		return nil
	end
	local _, itemType = C_Item.GetItemInfoInstant(itemID)
	if itemType and itemType ~= "" then
		return itemType
	end
	return nil
end

--[[
    The item-type group used for sorting and the category pane: the client's
    item class name, or "Other" for an ID the client has no item for.
    Just-added items report the "New" group instead, until the window closes.
]]
local function ItemGroupOf(item)
	if IsNewItem(item) then
		return L["RESTOCKER_GROUP_NEW"]
	end
	return ns.GetRestockItemTypeName(item.itemID) or L["RESTOCKER_GROUP_OTHER"]
end

--[[
    One pass over the list, resolving per item what both walks below would
    otherwise resolve repeatedly. Rebuilt on every redraw rather than cached
    across them, because an item's group moves the moment its data arrives or it
    leaves the "New" set.
]]
function ns.BuildRestockView(items)
	local filter = ns.restockListFilter
	local view = {
		groups = {},
		filter = (filter and #filter >= 2) and Fold(filter) or nil,
	}
	for _, item in ipairs(items) do
		view.groups[item] = ItemGroupOf(item)
	end
	return view
end

--[[
    Does this item pass the text filter? Empty and one-character filters pass
    everything, and so does a New item: a row must never vanish the moment it is added.
]]
local function PassesTextFilter(view, item)
	if not view.filter or view.groups[item] == L["RESTOCKER_GROUP_NEW"] then
		return true
	end
	return (Fold(item.itemName or ""):find(view.filter, 1, true) ~= nil)
		or (Fold(view.groups[item]):find(view.filter, 1, true) ~= nil)
		or (tostring(item.itemID or ""):find(view.filter, 1, true) ~= nil)
end

--[[
    The category pane's contents: every group present in the list, with how many
    items each holds, plus the total.

    Counts are taken AFTER the text filter, so typing in the filter box narrows the
    categories along with the list and a category that no longer matches anything
    disappears rather than promising items it cannot show. The counts are the whole
    reason the pane earns its width, so they have to agree with what clicking one
    actually produces.

    New sorts ahead of everything else here: it is where the item just added went,
    and it is the one group that must never be filed alphabetically.
]]
function ns.BuildRestockGroupList(items, view)
	local counts, order = {}, {}
	local total = 0
	for _, item in ipairs(items) do
		if PassesTextFilter(view, item) then
			local group = view.groups[item]
			if not counts[group] then
				counts[group] = 0
				order[#order + 1] = group
			end
			counts[group] = counts[group] + 1
			total = total + 1
		end
	end

	local newLabel = L["RESTOCKER_GROUP_NEW"]
	table.sort(order, function(a, b)
		if (a == newLabel) ~= (b == newLabel) then
			return a == newLabel
		end
		return a < b
	end)

	local groups = {}
	for _, name in ipairs(order) do
		groups[#groups + 1] = { name = name, count = counts[name] }
	end
	return groups, total
end

--[[
    Apply the text filter and the selected category, then sort into a flat render list.
    The category pane names the groups, so the list holds nothing but items.
]]
function ns.BuildRestockRenderList(items, view)
	local selected = ns.restockSelectedGroup
	local kept = {}
	for _, item in ipairs(items) do
		if PassesTextFilter(view, item) and (selected == nil or view.groups[item] == selected) then
			kept[#kept + 1] = item
		end
	end

	--[[
	    Grouped by item type, name-sorted within each group -- except New, which is
	    ranked ahead of every other group rather than sorted with them. Sorting on
	    the group name alone would file "New" alphabetically, landing it somewhere
	    in the middle of the list, which is the one place it must not be.

	    The type sort matters when no category is selected, because "All items" is
	    the default view and is the one that has to stay legible without headers.
	]]
	local newLabel = L["RESTOCKER_GROUP_NEW"]
	local groups = view.groups
	table.sort(kept, function(a, b)
		local groupA, groupB = groups[a], groups[b]
		local newA, newB = groupA == newLabel, groupB == newLabel
		if newA ~= newB then
			return newA
		end
		if groupA ~= groupB then
			return groupA < groupB
		end
		return (a.itemName or "") < (b.itemName or "")
	end)

	local renderList = {}
	for _, item in ipairs(kept) do
		renderList[#renderList + 1] = { item = item }
	end
	return renderList
end
