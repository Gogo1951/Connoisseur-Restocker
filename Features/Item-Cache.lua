local _, ns = ...
local GetColor = ns.GetColor

--[[
    Item-Cache -- derives and caches per-item consumable data in
    ns.db.profile.itemCache (the stateful item-metadata layer).
]]

--------------------------------------------------------------------------------
-- Item Cache
--------------------------------------------------------------------------------

--[[
    The derived item cache lives on the profile and is never declared in
    defaults, so a reset or a brand-new profile arrives without one. Core calls
    this at login and after every profile change. It invalidates on a version
    change, and on a change of data folder: Classic Era and Season of Discovery
    characters share one saved file, and so one profile, while their realms
    build different folders' tables, so a record one of them derived can be
    wrong for the other. The scanner's stale-schema nil-test catches
    same-version (dev) field additions.
]]
function ns.EnsureItemCache()
	local profile = ns.db.profile
	if
		type(profile.itemCache) ~= "table"
		or profile.itemCacheVersion ~= ns.Version
		or profile.itemCacheFolder ~= ns.DATA_FOLDER
	then
		profile.itemCache = {}
		profile.itemCacheVersion = ns.Version
		profile.itemCacheFolder = ns.DATA_FOLDER
	end
end

-- Whether any consumable table carries the item: the test that decides what ns.CacheItemData caches.
function ns.HasRawData(itemID)
	return ns.FOOD_AND_WATER[itemID] ~= nil
		or ns.POTIONS[itemID] ~= nil
		or ns.HEALTHSTONES[itemID] ~= nil
		or ns.SOULSTONES[itemID] ~= nil
		or ns.BANDAGES[itemID] ~= nil
		or ns.MANA_GEMS[itemID] ~= nil
		or ns.MANA_RUNES[itemID] ~= nil
		or ns.EXPLOSIVES[itemID] ~= nil
end

--------------------------------------------------------------------------------
-- Cold Item Retry
--------------------------------------------------------------------------------

-- Budget for the cold-item retry below, sized to cover a slow login.
local DATA_RETRY_MAX_ATTEMPTS = 10
local dataRetryAttempts = 0

--[[
    An id the server never answers for would spin the rescan forever: every
    scan that ends with an unresolved bag item calls this, and the timer walks
    straight back into another scan, so the pair is self-sustaining with no
    outside signal to stop it. The timer therefore gets a budget of
    DATA_RETRY_MAX_ATTEMPTS and then stops arming.

    GET_ITEM_INFO_RECEIVED stays registered past the budget: the event is the
    real signal, it costs nothing while idle, and an answer arriving late still
    rebuilds. UnregisterDataRetry refunds the budget, so the next cold item
    starts from a full one rather than inheriting an exhausted one.
]]
function ns.RegisterDataRetry()
	ns.RequestItemInfoEvents("scan")

	if dataRetryAttempts >= DATA_RETRY_MAX_ATTEMPTS then
		return
	end
	dataRetryAttempts = dataRetryAttempts + 1

	C_Timer.After(2, function()
		ns.RequestUpdate()
	end)
end

function ns.UnregisterDataRetry()
	dataRetryAttempts = 0
	ns.ReleaseItemInfoEvents("scan")
end

--[[
    GET_ITEM_INFO_RECEIVED has more than one waiter -- the bag scan above; the
    Restock List, which defers an add, an upgrade or a Starter List tick on the
    same cold-cache miss; and each options panel showing items that have not
    loaded yet (ns.WarmItemCache). The client answers this event once per item it
    resolves, which during a login is a flood, so it is registered only while
    somebody is actually waiting.

    Keyed rather than counted: a waiter that asks twice must not need to release
    twice, and the last one out is what unregisters.
]]
local itemInfoWaiters = {}

--[[
    The misses ns.GetItemData is remembering, [itemID] = true. Kept beside the
    waiters because the waiters decide how long a miss can be trusted, and the
    last one out drops them all: see Session Item Data below.
]]
local rememberedMisses = {}

function ns.RequestItemInfoEvents(key)
	itemInfoWaiters[key] = true
	ns.SetEventRegistered("GET_ITEM_INFO_RECEIVED", true)
end

function ns.ReleaseItemInfoEvents(key)
	itemInfoWaiters[key] = nil
	if next(itemInfoWaiters) == nil then
		ns.SetEventRegistered("GET_ITEM_INFO_RECEIVED", false)
		rememberedMisses = {}
	end
end

--------------------------------------------------------------------------------
-- Zone Helpers
--------------------------------------------------------------------------------

local function BuildZoneSet(rawZoneArray)
	if not rawZoneArray then
		return nil
	end
	local set = {}
	for _, mapID in ipairs(rawZoneArray) do
		set[mapID] = true
	end
	return set
end

--------------------------------------------------------------------------------
-- Item Data Caching
--------------------------------------------------------------------------------

--[[
    Looks up an item in the consumable tables, derives a canonical shape
    (type, health/mana values, requirements, zones), and caches it under
    ns.db.profile.itemCache. An item no consumable table carries returns "IGNORE"
    without calling C_Item.GetItemInfo or writing to the cache, so the cache holds
    consumables only and a cold non-consumable never arms a rescan.
]]
function ns.CacheItemData(itemID)
	local itemCache = ns.db and ns.db.profile.itemCache
	if not itemCache then
		return nil
	end

	if not ns.HasRawData(itemID) then
		return "IGNORE"
	end

	local name, _, _, _, minLevel, _, _, maxStack, _, _, vendorPrice, _, _, bindType = C_Item.GetItemInfo(itemID)
	if not name then
		return nil
	end

	local rawFoodAndWater = ns.FOOD_AND_WATER[itemID]
	local rawPotion = ns.POTIONS[itemID]
	local rawHealthstone = ns.HEALTHSTONES[itemID]
	local rawSoulstone = ns.SOULSTONES[itemID]
	local rawBandage = ns.BANDAGES[itemID]
	local rawManaGem = ns.MANA_GEMS[itemID]
	local rawManaRune = ns.MANA_RUNES[itemID]
	local rawExplosive = ns.EXPLOSIVES[itemID]

	local data = {
		itemID = itemID,
		itemType = "",
		healthValue = 0,
		manaValue = 0,
		damageValue = 0,
		requiredLevel = minLevel or 0,
		requiredFirstAid = 0,
		requiredAlchemy = 0,
		requiredEngineering = 0,
		requiredSpellID = nil,
		price = vendorPrice or 0,
		maxStack = maxStack or 1,
		--[[
		    bindType 1 is Enum.ItemBind.OnAcquire. For a consumable that is
		    the exact test for "the stack in the bag is soulbound": you can
		    only be holding one by having acquired it, so the item's binding
		    rule and the state of this copy always agree, and no per-slot
		    lookup is needed. Bind-on-use (3) is deliberately NOT soulbound
		    -- it stays tradeable right up until it is consumed.
		]]
		isSoulbound = (bindType == 1),
		isBuffFood = false,
		isPercent = false,
		zones = nil,
		arenaOnly = false,
		arenaUsable = false,
		isConjured = false,
	}

	if rawFoodAndWater then
		local isBuffFoodType = (rawFoodAndWater[1] == 1)
		data.isBuffFood = isBuffFoodType
		data.zones = BuildZoneSet(rawFoodAndWater[6])

		--[[
		    Arena usability (column 7), a static per-item property so it caches
		    like the other fields. 1 = usable ONLY inside a PvP Arena (Star's
		    Tears/Lament); 2 = conjured, so ALSO usable inside an arena. The
		    scanner gates on the live instance type (IsInInstance) rather than a
		    zone-ID list, so every arena is covered with no map IDs to maintain.
		]]
		local arenaFlag = rawFoodAndWater[7]
		data.arenaOnly = (arenaFlag == 1)
		data.arenaUsable = (arenaFlag ~= nil)
		--[[
		    Conjured (flag 2) is a distinct selection axis from arena usability:
		    arenaUsable is true for BOTH the arena-only drinks (flag 1) and
		    conjured items (flag 2), so it can't tell them apart. isConjured
		    records the conjured status on its own so the scanner can prefer a
		    free, infinite conjured ration over an equal-value purchased,
		    quested, or arena-only item (see IsBetter in Scanner-Inventory).
		]]
		data.isConjured = (arenaFlag == 2)

		local hasFood = false
		local hasWater = false

		if rawFoodAndWater[2] > 0 then
			hasFood = true
			data.healthValue = 99999
			data.isPercent = true
		elseif rawFoodAndWater[3] > 0 then
			hasFood = true
			data.healthValue = rawFoodAndWater[3]
		end

		if rawFoodAndWater[4] > 0 then
			hasWater = true
			data.manaValue = 99999
			data.isPercent = true
		elseif rawFoodAndWater[5] > 0 then
			hasWater = true
			data.manaValue = rawFoodAndWater[5]
		end

		if isBuffFoodType and not hasFood and not hasWater then
			hasFood = true
		end

		if hasFood and hasWater then
			data.itemType = "foodwater"
		elseif hasFood then
			data.itemType = "food"
		else
			data.itemType = "water"
		end
	elseif rawPotion then
		data.itemType = "potion"
		data.healthValue = rawPotion[1]
		data.manaValue = rawPotion[2]
		data.zones = BuildZoneSet(rawPotion[3])
		data.requiredAlchemy = rawPotion[4] or 0
	elseif rawHealthstone then
		data.itemType = "healthstone"
		data.healthValue = rawHealthstone[1]
		--[[
		    Required level for the bag-scan usable gate comes from the curated
		    ns.HEALTHSTONES column (static over API), falling back to
		    C_Item.GetItemInfo's minLevel. (Conjure downranking uses a separate table.)
		]]
		data.requiredLevel = rawHealthstone[2] or data.requiredLevel
	elseif rawSoulstone then
		data.itemType = "soulstone"
		data.healthValue = rawSoulstone[1]
	elseif rawBandage then
		-- Bandage row shape: {healAmount, requiredSkill, sellPrice, {zones}}
		data.itemType = "bandage"
		data.healthValue = rawBandage[1]
		data.requiredFirstAid = rawBandage[2] or 0
		data.zones = BuildZoneSet(rawBandage[4])
	elseif rawManaGem then
		data.itemType = "managem"
		data.manaValue = rawManaGem[1]
	elseif rawManaRune then
		data.itemType = "manarune"
		data.manaValue = rawManaRune[1]
	elseif rawExplosive then
		-- Explosive row shape: {minDamage, maxDamage, requiredSkill, requiredSpellID}
		data.itemType = "explosive"
		data.damageValue = rawExplosive[1]
		data.requiredEngineering = rawExplosive[3] or 0
		--[[
		    Engineering specialization gate (e.g. 20222 = Goblin Engineer for
		    the Global Thermal Sapper Charge). The scanner treats the item as
		    unusable until the player knows this spell.
		]]
		data.requiredSpellID = rawExplosive[4]
	end

	itemCache[itemID] = data
	return data
end

--------------------------------------------------------------------------------
-- Session Item Data
--------------------------------------------------------------------------------

--[[
    A plain memo over C_Item.GetItemInfo, and the link builder that rides on it. Distinct
    from the consumable cache above and deliberately kept beside it: that one is
    persisted, enriched from the consumable tables, and only ever holds consumables, while
    this one is thrown away at logout and answers for any item at all. Reach for
    the consumable cache when a consumable's own facts are wanted, and for this
    when a name, an icon or a link is.
]]

-- Every C_Item.GetItemInfo answer this session, keyed by whatever was asked for.
local getItemInfoCache = {}

--[[
    A miss is remembered too, but only while somebody is waiting on
    GET_ITEM_INFO_RECEIVED, which is when the same cold item gets asked about
    over and over. Every answer that arrives re-runs the parked upgrades,
    recipes and Starter List ticks, and each of those asks again about whatever
    is still cold. During a login that is a flood, and without the remembered
    miss every one of those asks would be a fresh C_Item.GetItemInfo call.

    A miss taken while nobody is listening is never remembered. The client
    announces its answer once, and with the event unregistered that answer
    lands unheard, so a remembered miss would outlive it for the rest of the
    session: a Restock List row stuck on a question-mark icon, and a later add,
    upgrade or recipe for that item parked for an answer that already came.
    The last waiter out drops every remembered miss for the same reason
    (ns.ReleaseItemInfoEvents above). While somebody listens a miss is safe to
    keep, because every answer heard reaches ns.OnRestockerItemInfoReceived
    (Restocker-List.lua), which forgets that item's miss before it retries
    anything. The one answer it skips is for an item that does not exist,
    whose miss stays true. The price is a fresh call for every ask while
    nothing waits, which a Restock List redraw pays once or twice per cold row.

    Not scoped to a frame by GetTime() instead. That clock can read the same
    across consecutive frames, so a frame's miss can still be trusted after
    its answer has landed unheard, and a deferral that reads it then is
    stranded just the same.

    Only ID-keyed misses are remembered. This cache is keyed by whatever the
    caller asked with -- an id on the hot paths, an item link at a merchant --
    and GET_ITEM_INFO_RECEIVED reports an id, so an id is the only key
    ns.ForgetItemDataMiss can clear when the answer arrives.
]]
function ns.ForgetItemDataMiss(itemID)
	rememberedMisses[itemID] = nil
end

-- Calls C_Item.GetItemInfo and saves the results; an ID-keyed miss is remembered only while a waiter listens.
function ns.GetItemData(request)
	local cached = getItemInfoCache[request]
	if cached ~= nil then
		return cached
	end
	if rememberedMisses[request] then
		return nil
	end

	local itemName, itemLink, itemRarity, itemLevel, itemMinLevel, itemType, itemSubType, itemStackCount, itemEquipLoc, itemTexture, itemSellPrice =
		C_Item.GetItemInfo(request)
	if itemName == nil then
		if type(request) == "number" and next(itemInfoWaiters) ~= nil then
			rememberedMisses[request] = true
		end
		return nil
	end

	local cacheItem = {
		itemID = tonumber(string.match(itemLink, "item:(%d+)")),
		itemName = itemName,
		itemLink = itemLink,
		itemRarity = itemRarity,
		itemLevel = itemLevel,
		itemMinLevel = itemMinLevel,
		itemType = itemType,
		itemSubType = itemSubType,
		itemStackCount = itemStackCount,
		itemEquipLoc = itemEquipLoc,
		itemTexture = itemTexture,
		itemSellPrice = itemSellPrice,
	}
	getItemInfoCache[request] = cacheItem
	return cacheItem
end

--[[
    A printable, hoverable, shift-clickable link for an item, always.

    C_Item.GetItemInfo returns nothing until the client has resolved an item, and on a
    fresh login that is exactly when the Restocker wants to name things -- so a
    bare-name fallback would print plain text most of the time. A link built by
    hand from the id works the moment it is printed: the
    client resolves |Hitem:| on hover, so the tooltip is correct even while the
    cache behind it is still cold.

    The colour on the hand-built form is white rather than the item's quality
    colour, which is the one thing that cannot be known without the cache. The
    cached link is preferred whenever it exists, and it carries the real colour.
]]
function ns.GetItemHyperlink(itemID, fallbackName)
	local info = itemID and ns.GetItemData(itemID) or nil
	if info and info.itemLink then
		return info.itemLink
	end

	if itemID then
		local label = (fallbackName and fallbackName ~= "") and fallbackName or ("item:" .. itemID)
		return GetColor("TEXT") .. "|Hitem:" .. itemID .. "|h[" .. label .. "]|h|r"
	end

	return fallbackName or "?"
end

--[[
    An item's name for the add-on's own windows, panels and tooltips: the
    link's text in its quality color, with the square brackets taken off.
    Brackets are how chat marks a link, so everything printed to chat keeps
    them (ns.GetItemHyperlink above). Beside the item's icon they are clutter,
    and the Restock List's own rows have never worn them.

    ns.UnbracketItemLink takes a link the caller already holds. ns.GetItemLabel
    names an item from its ID the way ns.GetItemHyperlink does, cold cache
    included.
]]
function ns.UnbracketItemLink(link)
	return (link:gsub("|h%[(.-)%]|h", "|h%1|h"))
end

function ns.GetItemLabel(itemID, fallbackName)
	return ns.UnbracketItemLink(ns.GetItemHyperlink(itemID, fallbackName))
end
