local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Starter Restock List
--------------------------------------------------------------------------------

--[[
    First-run suggestions for the Restock List. A character past level 5 who
    logs in with nothing on their list gets a small window of staples
    (Options/Options-Starter-List-Popup.lua): tick one and the best tier for
    the character's level goes on the list with the same everything-on
    defaults as a hand-added item. From there the normal machinery owns it --
    merchants top it up, and Restocker-Upgrade.lua walks it up its ladder on level-up.

    Every offering -- foods, water, ammo, poisons, class reagents -- is drawn
    from the ladders in ns.CONSUMABLE_UPGRADE_CHAINS rather than a list of its own,
    so the popup can never offer a staple the upgrader would not then
    maintain. Single-tier "ladders" (most reagents) ride the same rails and
    simply never move.

    A few staples arrive PRE-TICKED for the class (defaultFor below): the
    window opens with bread already on the list for everyone, water for the
    mana classes, meat for hunters. Closing the window untouched keeps them,
    so it does not return; unticking them all before closing leaves the list
    empty, so the window returns next login.
]]

--[[
    Ladders keyed for the category list below: food by diet number, poisons
    by group number, reagents by their reagent string, the single-ladder kinds
    by kind. Potions are deliberately absent -- past the first tiers they are
    Alchemy goods no vendor restock can rely on.
]]
local CHAINS_BY_KEY = {}
for _, chain in ipairs(ns.CONSUMABLE_UPGRADE_CHAINS) do
	if chain.kind == "food" then
		CHAINS_BY_KEY["food:" .. chain.diet] = chain
	elseif chain.kind == "poison" then
		CHAINS_BY_KEY["poison:" .. chain.group] = chain
	elseif chain.kind == "reagent" then
		CHAINS_BY_KEY["reagent:" .. chain.reagent] = chain
	else
		CHAINS_BY_KEY[chain.kind] = chain
	end
end

--[[
    Resolve every data row (ns.STARTER_LIST_CATEGORIES, in Data/Data.lua) to the ladder its
    chainKey names. A row whose ladder this client's folder does not carry is dropped here
    rather than crashing the popup open.
]]
local STARTER_CATEGORIES = {}
for _, row in ipairs(ns.STARTER_LIST_CATEGORIES) do
	local chain = CHAINS_BY_KEY[row.chainKey]
	if chain then
		row.chain = chain
		row.chainKey = nil
		STARTER_CATEGORIES[#STARTER_CATEGORIES + 1] = row
	end
end

function ns.GetStarterCategories()
	return STARTER_CATEGORIES
end

-- Is this category for this character's class? No classes set means everyone.
function ns.IsStarterCategoryForClass(category)
	if category.classes == nil then
		return true
	end
	local _, classToken = UnitClass("player")
	return category.classes[classToken] == true
end

--[[
    A category is offerable only when its ladder yields an item right now:
    this hides reagents whose spell the character has not trained toward yet
    (their ladders open at the spell's level), and the chains this client's
    folder holds empty -- Anesthetic on an Era client, and Blinding Powder
    anywhere past Classic. Food, water and ammo
    all open at level 1, so it never hides them.
]]
function ns.IsStarterCategoryAvailable(category)
	return ns.BestChainItemID(category.chain, UnitLevel("player") or 1) ~= nil
end

--------------------------------------------------------------------------------
-- Ticking a Staple
--------------------------------------------------------------------------------

local function CurrentList()
	local settings = ns.restockSettings
	return settings and settings.lists and settings.lists[settings.currentList]
end

--[[
    Whether this character's Restock List holds nothing. The login trigger below
    trades on it, and so does the pop-up's opening line: the window is also
    reachable from the Restock window's Pick Staples button, where the list it
    opens over is usually not empty at all.
]]
function ns.IsRestockListEmpty()
	local list = CurrentList()
	return list == nil or next(list) == nil
end

--[[
    Any tier of this ladder already on the list? The whole chain is checked
    rather than today's best tier, so the box stays ticked after a level-up
    moves the entry, and unticking removes whichever tier is actually there.
]]
local function ChainItemOnList(list, chain)
	for _, tier in ipairs(chain.tiers) do
		if list[tier[2]] ~= nil then
			return tier[2]
		end
	end
	return nil
end

--[[
    Ticked staples whose item had not resolved yet, [itemID] = category.
    C_Item.GetItemInfo asks the server on a miss, so the retry rides on
    GET_ITEM_INFO_RECEIVED (Restocker-List.lua) -- the same arrangement as
    Restocker-Upgrade.lua's deferred moves, and for the same reason: inserting
    before the answer arrives would write a nameless row. The box reads as
    ticked while an add is pending, so the click visibly takes.
]]
local pendingStarterAdds = {}

function ns.HasPendingStarterAdds()
	return next(pendingStarterAdds) ~= nil
end

function ns.RetryPendingStarterAdds()
	local retry = pendingStarterAdds
	pendingStarterAdds = {}
	for _, category in pairs(retry) do
		ns.AddStarterCategory(category)
	end
end

-- Items per dropdown step: one stack of the item (nil until it resolves), or one item where the category counts.
local function StepSize(category, stackSize)
	if category.countsItems then
		return 1
	end
	return stackSize
end

-- What a tick of this category puts on the list right now; nil while its stack size is unknown.
local function CategoryAmount(category, stackSize)
	if category.fixedAmount then
		return category.fixedAmount
	end
	local step = StepSize(category, stackSize)
	return step and ns.GetStarterCategoryStacks(category) * step
end

function ns.AddStarterCategory(category)
	local list = CurrentList()
	if not list or ChainItemOnList(list, category.chain) then
		return
	end

	local itemID = ns.BestChainItemID(category.chain, UnitLevel("player") or 1)
	if not itemID then
		return
	end

	local info = ns.GetItemData(itemID)
	if not info then
		pendingStarterAdds[itemID] = category
		ns.SyncRestockItemInfoSubscription()
		return
	end

	--[[
	    Same shape and same everything-on defaults as a hand-added item
	    (ns.AddRestockItem in Restocker-List.lua); only the amount differs.
	]]
	list[itemID] = {
		itemName = info.itemName,
		itemType = info.itemType,
		itemID = itemID,
		amount = CategoryAmount(category, math.max(1, info.itemStackCount or 1)),
		buyFromMerchant = true,
		stashToBank = true,
		restockFromBank = true,
	}

	--[[
	    Into the window's "New" group, so the rows this popup creates show
	    together with their controls ready -- live, when the Restock window is
	    open behind the popup. Closing the popup clears the group, so they sit
	    in New only while it is open.
	]]
	ns.restockNewItems[itemID] = true

	ns.UpdateRestockList()
end

function ns.RemoveStarterCategory(category)
	-- A pending add must be cancelled too, or it would land after the untick.
	for itemID, pending in pairs(pendingStarterAdds) do
		if pending == category then
			pendingStarterAdds[itemID] = nil
		end
	end

	local list = CurrentList()
	if not list then
		return
	end

	local removed = false
	for _, tier in ipairs(category.chain.tiers) do
		local itemID = tier[2]
		if list[itemID] ~= nil then
			list[itemID] = nil
			ns.restockNewItems[itemID] = nil
			removed = true
		end
	end
	if removed then
		ns.UpdateRestockList()
	end
end

-- The popup checkbox handler: ticking adds, unticking removes.
function ns.SetStarterCategory(category, checked)
	if checked then
		ns.AddStarterCategory(category)
	else
		ns.RemoveStarterCategory(category)
	end
end

function ns.IsStarterCategoryChecked(category)
	local list = CurrentList()
	if list and ChainItemOnList(list, category.chain) then
		return true
	end
	for _, pending in pairs(pendingStarterAdds) do
		if pending == category then
			return true
		end
	end
	return false
end

--[[
    The stack count each dropdown shows and writes, clamped to
    1..category.maxStacks. fixedAmount categories have no dropdown; they
    answer 1 and ignore writes, so no caller needs its own guard.

    Two homes, and the list wins: while the staple is ON the list the count is
    derived from the entry's real amount and its item's own stack size
    (rounded to the nearest whole stack, so a hand-edited amount in the
    Restocker window still reads sensibly here), and writing pushes straight
    back onto that entry. While it is off the list the choice is view state in
    selectedStacks -- one sitting only, never saved -- so a stack count can be
    picked BEFORE ticking the box, and survives an untick-retick without a row
    ever existing to carry it. A listed entry whose item has not resolved has
    no stack size to scale by, so until it does it reads as that remembered
    choice and takes no write; the pop-up repaints once it resolves.

    An untouched dropdown opens on defaultStacks where the category sets one,
    and on one stack otherwise -- the opening offer, not a saved choice, so it
    reads the same on a fresh character as on a fifth one.
]]
local selectedStacks = {} -- [category.key] = stacks, while the staple is not on the list

--[[
    What a raw count reads as in the dropdown. The every-number categories
    simply clamp; one that offers a handful (Soul Shards) snaps up to the
    smallest offer that still covers the count, so an amount the dropdown could
    not have produced -- hand-edited in the Restocker window, or left behind by
    a shorter choices list -- lands on a real entry instead of blanking it.
]]
local function SnapStacks(category, count)
	local choices = category.choices
	if not choices then
		return math.max(1, math.min(category.maxStacks, count))
	end
	for _, offered in ipairs(choices) do
		if count <= offered then
			return offered
		end
	end
	return choices[#choices]
end

--[[
    The item a category's stacks are measured in: the tier on the list while
    the staple is ticked, since that entry's amount is what the dropdown reads
    and writes, and otherwise the tier a tick would add right now.
]]
function ns.GetStarterCategoryItemID(category)
	local list = CurrentList()
	return (list and ChainItemOnList(list, category.chain))
		or ns.BestChainItemID(category.chain, UnitLevel("player") or 1)
end

--[[
    The item a row is named for: the one above for most rows, and for a
    namesFirstTier row (the poison types) its ladder's first item, whose name
    is the type's own ("Instant Poison").
]]
function ns.GetStarterCategoryNameItemID(category)
	if category.namesFirstTier then
		return category.chain.tiers[1][2]
	end
	return ns.GetStarterCategoryItemID(category)
end

--[[
    What the row's checkbox says: its label where the data gives one (a kind of
    item, like Bread), otherwise the client's own name for the item it is named
    for, so the row needs no translation. Nil while that item is still cold; the
    pop-up shows loading text until ns.WarmItemCache repaints it.
]]
function ns.GetStarterCategoryName(category)
	if category.label then
		return category.label
	end
	return (C_Item.GetItemInfo(ns.GetStarterCategoryNameItemID(category)))
end

--[[
    One stack of that item, as the item itself reports it, or nil until the
    client has resolved the item. Read from C_Item.GetItemInfo directly; the pop-up
    repaints when ns.WarmItemCache hears the item's answer.
]]
function ns.GetStarterCategoryStackSize(category)
	local itemID = ns.GetStarterCategoryItemID(category)
	local stackSize = itemID and select(8, C_Item.GetItemInfo(itemID))
	return stackSize and math.max(1, stackSize)
end

function ns.GetStarterCategoryStacks(category)
	if category.fixedAmount then
		return 1
	end
	local list = CurrentList()
	local listedID = list and ChainItemOnList(list, category.chain)
	local step = listedID and StepSize(category, ns.GetStarterCategoryStackSize(category))
	if step then
		local amount = list[listedID].amount or step
		return SnapStacks(category, math.floor(amount / step + 0.5))
	end
	return selectedStacks[category.key] or category.defaultStacks or 1
end

function ns.SetStarterCategoryStacks(category, stacks)
	if category.fixedAmount then
		return
	end
	stacks = SnapStacks(category, math.floor(stacks))
	selectedStacks[category.key] = stacks

	local list = CurrentList()
	local listedID = list and ChainItemOnList(list, category.chain)
	if listedID then
		local step = StepSize(category, ns.GetStarterCategoryStackSize(category))
		if step then
			list[listedID].amount = stacks * step
			ns.UpdateRestockList()
		end
		return
	end

	--[[
	    Off the list, picking a count IS asking for the staple. The dropdown
	    beside an unticked box otherwise does nothing you can see -- it only
	    pre-loads what a later tick would add -- so setting one to 28 and
	    watching the Restock List stay empty reads as the add being broken.
	    The tick goes through the same add path the checkbox uses, and
	    AceConfigDialog's post-set NotifyChange is what makes the box opposite
	    show itself ticked.
	]]
	ns.AddStarterCategory(category)
end

--[[
    The checkbox tooltip: the exact item a tick adds right now, with the
    count the current stack choice (or fixed amount) works out to. Ladder
    items mention the upgrading; single-tier reagents, which never move, get
    the plain form.

    Nil until the item has resolved, which the pop-up shows as loading text.
    That is checked with C_Item.GetItemInfo because ns.GetItemLabel never says
    so: it names an item from a hand-built link while the item is still cold.
    The name wears no brackets, like every item the add-on's own windows name.
]]
function ns.DescribeStarterCategory(category)
	local itemID = ns.BestChainItemID(category.chain, UnitLevel("player") or 1)
	local amount = CategoryAmount(category, ns.GetStarterCategoryStackSize(category))
	if not (amount and itemID and C_Item.GetItemInfo(itemID)) then
		return nil
	end
	local template = (#category.chain.tiers > 1) and L["STARTER_POPUP_ITEM_DESCRIPTION"]
		or L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"]
	return string.format(template, ns.GetItemLabel(itemID, nil), amount)
end

--------------------------------------------------------------------------------
-- Don't-Show-Again
--------------------------------------------------------------------------------

--[[
    Per character, keyed by ns.GetCharacterKey, and stored under
    ns.db.global.restocker rather than on an AceDB profile -- a profile can be
    switched, copied or reset, and none of those should resurrect (or suppress)
    a login window a character already answered.

    A cleared flag is stored as nil rather than false, so the table only ever
    carries the characters that opted out.
]]

function ns.IsStarterPopupDismissed()
	local settings = ns.restockSettings
	local dismissed = settings and settings.starterListDismissed
	return dismissed ~= nil and dismissed[ns.GetCharacterKey()] == true
end

function ns.SetStarterPopupDismissed(value)
	local settings = ns.restockSettings
	if not settings then
		return
	end
	settings.starterListDismissed[ns.GetCharacterKey()] = value and true or nil
end

--------------------------------------------------------------------------------
-- Login Trigger
--------------------------------------------------------------------------------

--[[
    "After level 5": a level-5 character is still on starter-zone money; by 6
    they have met vendors worth a shopping list.
]]
local STARTER_MIN_LEVEL = 6

-- Matches Core.lua's post-login settle timer: past the loading-screen flurry.
local STARTER_POPUP_DELAY = 3

local function IsDefaultCategory(category)
	local defaultFor = category.defaultFor
	if defaultFor == nil then
		return false
	end
	if defaultFor == "all" then
		return true
	end
	local _, classToken = UnitClass("player")
	return defaultFor[classToken] == true
end

function ns.MaybeShowStarterListPopup()
	if not ns.restockerLoaded or ns.IsStarterPopupDismissed() then
		return
	end
	if (UnitLevel("player") or 1) < STARTER_MIN_LEVEL then
		return
	end

	local list = CurrentList()
	if not list or next(list) ~= nil then
		return
	end

	--[[
	    Nothing OFFERABLE means nothing to show -- with bread open to every
	    class at level 1 that is a formality today, but it keeps a future
	    class or data change from opening an empty window. Logging in
	    mid-combat skips this login -- the empty list is still empty
	    tomorrow.

	    No item warming here: the pop-up warms its own items as it draws,
	    for this route and the Pick Staples button alike.
	]]
	local level = UnitLevel("player") or 1
	local anyOffered = false
	for _, category in ipairs(STARTER_CATEGORIES) do
		if ns.IsStarterCategoryForClass(category) and ns.BestChainItemID(category.chain, level) then
			anyOffered = true
			break
		end
	end
	if not anyOffered or InCombatLockdown() then
		return
	end

	--[[
	    The pre-ticked staples go on the list just before the window opens,
	    through the same add path a hand-tick uses -- so the window opens
	    with those boxes genuinely checked, and unticking one takes it
	    straight back off. Only ever from here: the popup is the only place
	    the defaults exist, so a player who never sees it never has a list
	    written for them.
	]]
	for _, category in ipairs(STARTER_CATEGORIES) do
		if
			IsDefaultCategory(category)
			and ns.IsStarterCategoryForClass(category)
			and ns.IsStarterCategoryAvailable(category)
		then
			ns.AddStarterCategory(category)
		end
	end

	--[[
	    The Restock List window opens first and the staples over it, so a new
	    character sees both: the pre-ticks above already on the list, and each
	    tick landing on it. Every other route to the staples is the Pick Staples
	    button, which is in that window, so it is already open behind them.
	]]
	ns.ShowRestockWindow()
	-- Told it is the login route: the pre-ticks above mean the list no longer reads as empty.
	ns.ShowStarterListPopup(true)
end

--[[
    Fresh logins only. isInitialLogin is false on /reload and on every
    mid-session loading screen, and both would otherwise re-open a window the
    player already closed this sitting -- the "don't spam them" half of the
    feature is this one argument. Called from ns.OnRestockerEnteringWorld
    (Restocker-Reminders.lua), which is the handler Restocker-Events.lua
    registers for PLAYER_ENTERING_WORLD.
]]
function ns.OnStarterListEnteringWorld(isInitialLogin, _isReloadingUi)
	if not isInitialLogin then
		return
	end
	C_Timer.After(STARTER_POPUP_DELAY, ns.MaybeShowStarterListPopup)
end
