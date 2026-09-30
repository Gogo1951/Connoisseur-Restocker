local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Consumable Upgrades
--------------------------------------------------------------------------------

--[[
    Keeps staple consumables on the Restock List current with the player's
    level, walking the ladders in Data/{Game}/Consumable-Upgrade-Paths-{Game}.lua.

    Only ever forward. An item ABOVE the player's level is left alone -- someone
    who stocked Morning Glory Dew at 30 meant to, and gets moved on only once
    they outgrow it -- so the rule is "a strictly later tier", never "the tier
    matching my level".
]]

--[[
    A tier's third field is its rank, and the higher rank is the better tier;
    row order carries no meaning. Each chain is sorted by rank once here, so
    every other walker of chain.tiers sees them lowest to highest.
]]
local function ByRank(a, b)
	return a[3] < b[3]
end

-- [itemID] = { chain = <chain>, rank = <the tier's rank> }
local UPGRADE_INDEX = {}
for _, chain in ipairs(ns.CONSUMABLE_UPGRADE_CHAINS) do
	table.sort(chain.tiers, ByRank)
	for _, tier in ipairs(chain.tiers) do
		UPGRADE_INDEX[tier[2]] = { chain = chain, rank = tier[3] }
	end
end

--[[
    Is this item on a ladder with somewhere to go? Everything else shows a
    disabled Upgrade cell: an item on no ladder, and an item on a ladder of one
    tier (the Hearthstone, Arcane Powder, the mage runes), which the Starter List
    offers but which has no later tier to move to. A live tick there would be a
    switch that can never do anything.
]]
function ns.CanUpgradeRestockItem(itemID)
	local entry = itemID ~= nil and UPGRADE_INDEX[itemID]
	return (entry and #entry.chain.tiers > 1) or false
end

--[[
    The best tier this character can reach right now: the highest-ranked tier at
    or below the level. Rank, not level, settles tiers that share a level (the
    Wrath folder's level-65 food and water), so the Northrend item wins there.
]]
local function BestTier(chain, level)
	local best
	for _, tier in ipairs(chain.tiers) do
		if tier[1] <= level and (best == nil or tier[3] > best[3]) then
			best = tier
		end
	end
	return best
end

--[[
    The item a ladder yields for this character right now: the furthest tier at
    or below the level, on this client. The Starter List popup (Restocker-Starter-List.lua)
    adds through this, so a ticked staple starts on the same tier the upgrader
    would otherwise move it to.
]]
function ns.BestChainItemID(chain, level)
	local tier = BestTier(chain, level)
	return tier and tier[2]
end

--[[
    Move one list entry onto a later tier, keeping everything the player set on
    it -- amount, the three toggles, required reputation, and the Upgrade flag
    itself. Lists are keyed by itemID, so this is a delete plus an insert.

    When the target tier is ALREADY on the list the two entries merge: the
    amounts add up and the old row goes. Anything else would either drop what
    the player asked for or leave two rows for the same shopping trip.
]]
local function MoveToTier(list, fromID, toID)
	local item = list[fromID]
	local existing = list[toID]

	if existing then
		existing.amount = (existing.amount or 0) + (item.amount or 0)
	else
		local info = ns.GetItemData(toID)
		item.itemID = toID
		item.itemName = info and info.itemName or ""
		item.itemType = (info and info.itemType) or item.itemType
		list[toID] = item
	end

	list[fromID] = nil
end

--[[
    True when an upgrade was deferred because the client had not resolved the
    target item yet. C_Item.GetItemInfo asks the server on a miss, so the retry rides
    on GET_ITEM_INFO_RECEIVED (Restocker-List.lua) rather than a timer.
]]
local pendingUpgrade = false

--[[
    Bring every eligible entry on the current Restock List up to date.
    Safe to call repeatedly: it is a no-op once nothing is behind.

    PLAYER_LEVEL_UP passes its new level straight through, because
    UnitLevel("player") still reads the OLD level while that event is being
    handled -- the unit field updates a moment later -- and planning against
    it would miss any tier that opens at the new level. Callers that run clear
    of the ding -- the deferred retry, the login catch-up -- pass nothing and
    read the level themselves.
]]
function ns.UpgradeRestockList(newLevel)
	local settings = ns.restockSettings
	local list = settings and settings.lists and settings.lists[settings.currentList]
	if not list then
		return
	end

	local level = newLevel or UnitLevel("player") or 1
	pendingUpgrade = false

	--[[
	    Collected before anything moves: MoveToTier both inserts and deletes
	    keys, and mutating a table while pairs() walks it is undefined.
	]]
	local planned = {}
	for itemID, item in pairs(list) do
		-- nil means on, matching how buyFromMerchant reads its default
		if item.upgrade ~= false then
			local entry = UPGRADE_INDEX[itemID]
			if entry then
				local best = BestTier(entry.chain, level)
				if best and best[3] > entry.rank then
					local targetID = best[2]
					if ns.GetItemData(targetID) then
						planned[#planned + 1] = { from = itemID, to = targetID }
					else
						--[[
						    Target not cached. Skipping now and retrying on
						    GET_ITEM_INFO_RECEIVED keeps a half-named row out of
						    the list entirely -- the alternative is writing the
						    old item's name against the new item's ID.
						]]
						pendingUpgrade = true
						ns.SyncRestockItemInfoSubscription()
					end
				end
			end
		end
	end

	if #planned == 0 then
		return
	end

	--[[
	    Headline first, then one line per swap naming both tiers and their
	    amounts. Naming what changed beats counting it: the add-on just rewrote
	    a shopping list, and "2 items upgraded" does not say which two. The
	    headline makes the Restock List the subject, so there is no item plural
	    to agree with and one string covers any number of swaps.

	    The outgoing amount is read BEFORE MoveToTier and the incoming one
	    after, because the two differ whenever the target tier was already on
	    the list: that path merges the rows and sums the amounts rather than
	    carrying the old one across.
	]]
	ns.PrintMessage(L["RESTOCKER_UPGRADED"])
	for _, move in ipairs(planned) do
		local from = list[move.from]
		local fromLink = ns.GetItemHyperlink(move.from, from and from.itemName)
		local fromAmount = (from and from.amount) or 0
		MoveToTier(list, move.from, move.to)
		local moved = list[move.to]
		ns.PrintMessage(
			string.format(
				L["RESTOCKER_UPGRADED_ITEM"],
				fromLink,
				fromAmount,
				ns.GetItemHyperlink(move.to, moved and moved.itemName),
				(moved and moved.amount) or fromAmount
			)
		)
	end

	ns.UpdateRestockList()
end

function ns.HasPendingUpgrade()
	return pendingUpgrade
end
