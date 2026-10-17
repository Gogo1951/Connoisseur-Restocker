local _, ns = ...

--------------------------------------------------------------------------------
-- Pet Food Scanning
--------------------------------------------------------------------------------

ns.bestPetFoodID = nil
ns.bestPetFoodLink = nil

--[[
    Builds a set of quest IDs the player currently has in their quest log.
    Used by ScanPetFood to skip foods that are objectives for active quests.
]]

local activeQuestIDs = {}

local function BuildActiveQuestSet()
	wipe(activeQuestIDs)
	for questIndex = 1, ns.GetNumQuestLogEntries() do
		local questID = ns.GetQuestLogQuestID(questIndex)
		-- Include completed-but-not-turned-in quests too: turn-in still consumes the items.
		if questID then
			activeQuestIDs[questID] = true
		end
	end
end

--[[
    Every quest some pet food is an objective for, gathered from ns.PET_FOOD_DATA
    on first use. Only those quests joining or leaving the log can change which
    food the Feed Pet macro picks.
]]
local petFoodQuestIDs

--[[
    The pet-food quests active at the last call and at this one, [questID] =
    true, and the last call's count. Two tables swapped on every call, so the
    comparison allocates nothing on QUEST_LOG_UPDATE's many firings. The last
    set starts nil, so the first call counts as a change.
]]
local lastActiveFoodQuests, lastActiveFoodQuestCount
local currentActiveFoodQuests = {}

--[[
    Whether the active quests that matter to pet food changed since the last
    call, so the dispatcher can skip the rebuild for QUEST_LOG_UPDATE's many
    firings that change nothing. ns.ScanPetFood calls it too, discarding the
    answer, whenever it reads the quest log, so the signature always matches
    the quests the last food pick was made from.
]]
function ns.PetFoodQuestsChanged()
	if not petFoodQuestIDs then
		petFoodQuestIDs = {}
		for _, foodData in pairs(ns.PET_FOOD_DATA) do
			for _, questID in ipairs(foodData[4] or {}) do
				petFoodQuestIDs[questID] = true
			end
		end
	end

	BuildActiveQuestSet()
	wipe(currentActiveFoodQuests)
	local count = 0
	for questID in pairs(activeQuestIDs) do
		if petFoodQuestIDs[questID] then
			currentActiveFoodQuests[questID] = true
			count = count + 1
		end
	end

	local changed = lastActiveFoodQuests == nil or count ~= lastActiveFoodQuestCount
	if not changed then
		for questID in pairs(currentActiveFoodQuests) do
			if not lastActiveFoodQuests[questID] then
				changed = true
				break
			end
		end
	end

	lastActiveFoodQuests, currentActiveFoodQuests = currentActiveFoodQuests, lastActiveFoodQuests or {}
	lastActiveFoodQuestCount = count
	return changed
end

local function IsNeededForQuest(questIDs)
	for _, questID in ipairs(questIDs) do
		if activeQuestIDs[questID] then
			return true
		end
	end
	return false
end

--[[
    Selects the lowest-itemLevel food that still gives maximum happiness
    (petLevel - foodItemLevel between 0 and 10). Ties broken by sell price
    (lower wins), then total count in bags (fewer wins).

    If no food sits in the max-happiness bracket, falls back to the food
    closest to (but above) the pet's level. Pets eat above-level food, just
    wastefully — better than letting the pet go hungry.

    Note: there is no upper cap on how far above pet level the fallback can
    reach. Confirmed empirically on Classic Era (1.15.x): a level-8 cat will
    happily eat level-70 meat. The fallback ranks by lowest food level first,
    so the *least* wasteful option still wins when multiple are available.

    Every food's own facts (itemLevel, dietID, sellPrice, questIDs) come from
    the stored ns.PET_FOOD_DATA table, and what is in the bags comes from
    ns.scannedItemCounts / ns.scannedItemLinks -- the walk ns.ScanBags just
    finished in this same update pass. Walking the containers again here would
    cost a second full pass per rebuild on every Hunter with a pet out. No
    server queries are needed.

    Quest objective foods are skipped whenever the player has that quest in
    their log (including completed-but-not-turned-in), since turn-in consumes
    the items.
]]

function ns.ScanPetFood()
	ns.bestPetFoodID = nil
	ns.bestPetFoodLink = nil

	if not UnitExists("pet") or UnitIsDead("pet") or UnitIsGhost("pet") then
		return
	end

	local petLevel = UnitLevel("pet")
	if not petLevel or petLevel < 1 then
		return
	end

	local petDiets = ns.GetPetFoodTypes()
	if not petDiets or #petDiets == 0 then
		return
	end

	local dietSet = {}
	for _, dietName in ipairs(petDiets) do
		local dietID = ns.PET_DIET_MAP[dietName]
		if dietID then
			dietSet[dietID] = true
		end
	end

	--[[
	    Empty bags, so there is nothing to pick from: this runs only inside the
	    update pass, right after ns.ScanBags refilled the snapshot. Leave both
	    published fields nil, exactly as the no-pet path above does, and skip the
	    quest-log walk with them.
	]]
	if next(ns.scannedItemCounts) == nil then
		return
	end

	--[[
	    Snapshot the player's active quests once per scan, through
	    ns.PetFoodQuestsChanged so the scan also records the signature the
	    QUEST_LOG_UPDATE diff compares against. The dispatcher skips that diff in
	    combat, so a quest change made mid-fight and undone after it would
	    otherwise read as no change against a pre-fight signature.
	]]
	ns.PetFoodQuestsChanged()

	-- Both halves of the Ignore List hide an item from every macro's selection.
	local characterIgnoreList = ns.GetIgnoreList() or {}
	local globalIgnoreList = ns.GetGlobalIgnoreList() or {}

	local bestID, bestLink
	local bestLevel = 999
	local bestPrice = 999999
	local bestCount = 999999

	--[[
	    Wasteful fallback: pets will eat food above their level when no in-bracket
	    option is available. Prefer the food closest to pet level (lowest waste).
	]]
	local fallbackID, fallbackLink
	local fallbackLevel = 999
	local fallbackPrice = 999999
	local fallbackCount = 999999

	for id, totalCount in pairs(ns.scannedItemCounts) do
		local foodData = ns.PET_FOOD_DATA[id]

		if foodData and not (characterIgnoreList[id] or globalIgnoreList[id]) then
			local foodLevel = foodData[1]
			local foodDiet = foodData[2]
			local sellPrice = foodData[3]
			local questIDs = foodData[4]

			if dietSet[foodDiet] then
				local levelDelta = petLevel - foodLevel
				local inHappyBracket = (levelDelta >= 0 and levelDelta <= 10)
				local isAbovePet = (levelDelta < 0)

				if inHappyBracket or isAbovePet then
					local skipQuest = false
					if questIDs then
						skipQuest = IsNeededForQuest(questIDs)
					end

					if not skipQuest then
						if inHappyBracket then
							-- Prefer: lowest itemLevel, then lowest sell price, then fewest in bags
							local isBetter
							if not bestID then
								isBetter = true
							elseif foodLevel ~= bestLevel then
								isBetter = foodLevel < bestLevel
							elseif sellPrice ~= bestPrice then
								isBetter = sellPrice < bestPrice
							elseif totalCount ~= bestCount then
								isBetter = totalCount < bestCount
							else
								--[[
								    Never-equal last resort. The scan snapshot is
								    walked with pairs(), whose order is not stable
								    between passes, so two foods matching on every
								    field above would otherwise swap the pick from
								    one rebuild to the next and churn a macro
								    rewrite. Same reason RANKING_PRIORITY in
								    Scanner-Inventory.lua ends on itemID.
								]]
								isBetter = id < bestID
							end

							if isBetter then
								bestID = id
								bestLink = ns.scannedItemLinks[id]
								bestLevel = foodLevel
								bestPrice = sellPrice
								bestCount = totalCount
							end
						else
							--[[
							    Fallback (food above pet level). No upper cap:
							    pets will eat food at any level higher than their
							    own (confirmed: lvl-8 cat eats lvl-70 meat). Prefer
							    closest to pet level (lowest), then cheapest, then
							    fewest in bags.
							]]
							local isBetter
							if not fallbackID then
								isBetter = true
							elseif foodLevel ~= fallbackLevel then
								isBetter = foodLevel < fallbackLevel
							elseif sellPrice ~= fallbackPrice then
								isBetter = sellPrice < fallbackPrice
							elseif totalCount ~= fallbackCount then
								isBetter = totalCount < fallbackCount
							else
								-- Deterministic last resort; see the note on the bracket chain above.
								isBetter = id < fallbackID
							end

							if isBetter then
								fallbackID = id
								fallbackLink = ns.scannedItemLinks[id]
								fallbackLevel = foodLevel
								fallbackPrice = sellPrice
								fallbackCount = totalCount
							end
						end
					end
				end
			end
		end
	end

	if bestID then
		ns.bestPetFoodID = bestID
		ns.bestPetFoodLink = bestLink
	else
		ns.bestPetFoodID = fallbackID
		ns.bestPetFoodLink = fallbackLink
	end
end

--------------------------------------------------------------------------------
-- Pet Buff Override
--------------------------------------------------------------------------------

--[[
    Written by ScanBags on every rescan (forced nil in a PvP Arena); Food.lua's
    macro hooks read it to splice the pet-buff-food line into the Food macro.
]]
ns.petBuffOverrideID = nil

--[[
    ns.PET_BUFF_FOODS best-first (highest rank), sorted once from the flavor
    folder's Game-IDs file, which loads before this file, since row order there
    carries no meaning.
]]
local PET_BUFF_FOODS_BY_RANK = {}
for itemID, row in pairs(ns.PET_BUFF_FOODS) do
	PET_BUFF_FOODS_BY_RANK[#PET_BUFF_FOODS_BY_RANK + 1] =
		{ itemID = itemID, rank = row[2], settingKey = row[3], requiredLevel = row[4] }
end
table.sort(PET_BUFF_FOODS_BY_RANK, function(a, b)
	return a.rank > b.rank
end)

--[[
    Returns the item ID of the pet food buff that should be used, or nil.
    Called by ScanBags with its per-scan bag item counts. The aura probe it
    consults, ns.HasPetFoodBuff, stays in Scanner-Auras.lua: it shares
    that file's private early-reapply helper (BuffCountsAsActive) with the
    Well Fed and scroll probes.
]]
function ns.FindPetBuffOverride(bagItemCounts)
	--[[
	    A pet buff food on this flavor, the feature toggle, group restriction,
	    level, and a live pet all live in ns.ShouldTrackPetFood
	    (Scanner-Auras.lua) so the readiness report applies exactly the same
	    gate.
	]]
	if not ns.ShouldTrackPetFood() then
		return nil
	end

	if ns.HasPetFoodBuff() then
		return nil
	end

	local petTypes = ns.db.profile.petBuffTypes

	--[[
	    The pet-buff override path never passes the scanner's ignore filter
	    (it reads the raw bag counts), so it honors the Ignore List itself.
	]]
	local playerLevel = ns.cachedPlayerLevel or 1
	for _, food in ipairs(PET_BUFF_FOODS_BY_RANK) do
		local itemID = food.itemID
		if
			petTypes[food.settingKey]
			and playerLevel >= food.requiredLevel
			and bagItemCounts[itemID]
			and bagItemCounts[itemID] > 0
			and not ns.IsIgnored(itemID)
		then
			return itemID
		end
	end

	return nil
end
