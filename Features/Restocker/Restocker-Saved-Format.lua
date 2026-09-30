local _, ns = ...

--------------------------------------------------------------------------------
-- Saved Item Format
--------------------------------------------------------------------------------

-- Keep a saved item's itemID synced to its key.
local function CleanItem(item, itemID)
	item.itemID = itemID
	return item
end

--[[
    One-line saved format. Each item is stored as a single comma-separated string
    so the SavedVariables file has exactly one physical line per item (a real Lua
    table would be expanded across many lines by WoW's serializer).
    Field order: itemType, itemName, amount, stashToBank, restockFromBank,
                 buyFromMerchant, reaction, upgrade, buyExtra.  Booleans are 1 / 0.
    Every trailing field is always written. A new one can be appended without a
    version bump because the parser treats a missing trailing field as absent, and
    absent reads as each flag's own default: a line written before buyExtra
    existed reads Extra off, which is what a row that never asked for it means.
    itemType is the human-readable class from C_Item.GetItemInfo (e.g. "Consumable",
    "Quest", "Trade Goods") and leads so the file sorts into groups. It also files the
    row in the window's category pane and filter while the item itself is still cold.
    The itemID is NOT stored -- the table key IS the itemID (single source of truth).
    A comma splits the label, so a name containing one reads back cut short; the
    client's own name replaces it at login whenever the client knows the item.
    There is no version stamp, and none is needed: the parser also reads a line with
    no leading type, and the next save rewrites it in the current form.
]]

--[[
    Resolve an item's human-readable type, preferring the live game data and falling
    back to whatever was saved (so it survives even when the item isn't cached yet).
]]
local function ItemTypeOf(item)
	local info = ns.GetItemData(item.itemID)
	if info and info.itemType and info.itemType ~= "" then
		return info.itemType
	end
	return item.itemType
end

local function ItemToString(item)
	local parts = {}
	local itemType = ItemTypeOf(item)
	if itemType and itemType ~= "" then
		parts[#parts + 1] = itemType
	end
	parts[#parts + 1] = item.itemName or ""
	parts[#parts + 1] = item.amount or 0
	parts[#parts + 1] = item.stashToBank and 1 or 0
	parts[#parts + 1] = item.restockFromBank and 1 or 0
	-- buyFromMerchant defaults to true (nil), so only false is "off"
	parts[#parts + 1] = (item.buyFromMerchant == false) and 0 or 1
	--[[
	    Both trailing fields go out every time. Upgrade sits behind reaction, so
	    writing reaction only when set would shift upgrade into its position.
	]]
	parts[#parts + 1] = (item.reaction and item.reaction > 0) and item.reaction or 0
	-- upgrade defaults to true (nil), so only false is "off"
	parts[#parts + 1] = (item.upgrade == false) and 0 or 1
	-- buyExtra defaults to false (nil), so only true is "on"
	parts[#parts + 1] = item.buyExtra and 1 or 0
	return table.concat(parts, ", ")
end

local function ItemFromString(line, key)
	local itemID = tonumber(key)
	local fields = {}
	for _, part in ipairs({ strsplit(",", line) }) do
		fields[#fields + 1] = strtrim(part)
	end

	--[[
	    The label (type and/or name) is the leading run of non-numeric fields; the
	    numeric data (amount, flags, [reaction]) follows. This lets the parser read
	    both "type, name, ..." and a line with no type, "name, ...".
	]]
	local dataStart
	for j = 1, #fields do
		if tonumber(fields[j]) ~= nil then
			dataStart = j
			break
		end
	end
	dataStart = dataStart or (#fields + 1)
	local labelEnd = dataStart - 1

	local amount = tonumber(fields[dataStart]) or 0
	local stash = tonumber(fields[dataStart + 1])
	local fromBank = tonumber(fields[dataStart + 2])
	local buy = tonumber(fields[dataStart + 3])
	local reaction = tonumber(fields[dataStart + 4]) or 0
	local upgradeFlag = tonumber(fields[dataStart + 5])
	local extra = tonumber(fields[dataStart + 6])

	-- Name is the last label field; an optional type leads it.
	local itemName = (labelEnd >= 1) and fields[labelEnd] or ""
	local itemType = (labelEnd >= 2) and fields[1] or nil

	--[[
	    Flags that default to ON are stored as nil, so only an explicit 0 means off.

	    Never fold these into "x and false or nil". false is falsy, so the `or`
	    takes over and the expression yields nil for EVERY input -- the off state
	    is silently unstorable, and the setting comes back on at the next login.
	]]
	local buyFromMerchant = nil
	if buy == 0 then
		buyFromMerchant = false
	end

	local upgrade = nil
	if upgradeFlag == 0 then
		upgrade = false
	end

	return {
		itemName = itemName,
		itemType = itemType,
		itemID = itemID,
		amount = amount,
		stashToBank = (stash == 1) or nil,
		restockFromBank = (fromBank == 1) or nil,
		buyFromMerchant = buyFromMerchant,
		reaction = reaction > 0 and reaction or nil,
		upgrade = upgrade,
		--[[
		    Inverted default: Extra is off unless a 1 says otherwise, so a line from
		    before this field existed reads as off rather than switching itself on.
		]]
		buyExtra = (extra == 1) or nil,
	}
end

--[[
    Convert every saved item to its in-memory table form (called on login). Tolerates
    tables left behind by a crash/reload and hand-edited entries; keeps itemID synced
    to the table key. Idempotent.
]]
function ns.InflateSavedRestockItems(db)
	for _, list in pairs(db.lists or {}) do
		for key, item in pairs(list) do
			if type(item) == "string" then
				local inflated = ItemFromString(item, key)
				--[[
				    Refresh name and type from the client whenever it knows the item: a
				    saved name goes stale after a client language switch or a rename,
				    and the merchant matches orders by name.
				]]
				local info = ns.GetItemData(inflated.itemID)
				if info then
					if info.itemName and info.itemName ~= "" then
						inflated.itemName = info.itemName
					end
					if info.itemType and info.itemType ~= "" then
						inflated.itemType = info.itemType
					end
				end
				list[key] = inflated
			elseif type(item) == "table" then
				CleanItem(item, tonumber(key) or item.itemID)
			end
		end
	end
end

--[[
    Convert every in-memory item table to its one-line saved string (called on logout
    so WoW writes the compact format to disk). Idempotent.
]]
local function DeflateSavedItems(db)
	for _, list in pairs(db.lists or {}) do
		for key, item in pairs(list) do
			if type(item) == "table" then
				list[key] = ItemToString(item)
			end
		end
	end
end

--[[
    Remove empty lists that no profile points at and no character owns (e.g.
    a leftover "default" from an older version). Two kinds are kept: the list a
    stored profile uses, and any legacy "Name-Realm" list still named for a
    character AceDB knows -- older versions created one per character, and a
    player who kept theirs must not lose it to a prune. New characters get
    class-named lists and no eponymous one (see ns.InitCharacterRestockList).
]]
function ns.PruneEmptyOrphanRestockLists(db)
	local keep = {}
	for _, profile in pairs(ns.db.sv.profiles or {}) do
		if type(profile) == "table" and profile.restockList then
			keep[profile.restockList] = true
		end
	end
	for profileKey in pairs(ns.db.sv.profileKeys or {}) do
		local name, realm = ns.SplitCharacterProfileName(profileKey)
		if name and realm then
			keep[name .. "-" .. (realm:gsub("%s+", ""))] = true
		end
	end
	if db.currentList then
		keep[db.currentList] = true
	end
	for name, list in pairs(db.lists or {}) do
		if not keep[name] and next(list) == nil then
			db.lists[name] = nil
		end
	end
end

--[[
    Pack all in-memory item tables back into the one-line saved strings. Called from
    ns.OnRestockerLogout right before WoW writes the SavedVariables file. On the
    namespace rather than file-local, because the only caller is in another file.
]]
function ns.DeflateRestockItemsForSave()
	DeflateSavedItems(ns.restockSettings)
end
