local _, ns = ...

local WATER, MEAT, FISH, BREAD, CHEESE, FRUIT, FUNGUS = 0, 1, 2, 3, 4, 5, 6

-- { kind, diet / group / reagent, tiers = { { minLevel, itemID, rank }, -- Name } }
ns.CONSUMABLE_UPGRADE_CHAINS = {
	{
		kind = "water",
		diet = WATER,
		tiers = {
			{ 1, 159, 1 }, -- Refreshing Spring Water
			{ 5, 1179, 2 }, -- Ice Cold Milk
			{ 15, 1205, 3 }, -- Melon Juice
			{ 25, 1708, 4 }, -- Sweet Nectar
			{ 35, 1645, 5 }, -- Moonberry Juice
			{ 45, 8766, 6 }, -- Morning Glory Dew
		},
	},
	{
		kind = "food",
		diet = MEAT,
		tiers = {
			{ 1, 117, 1 }, -- Tough Jerky
			{ 5, 2287, 2 }, -- Haunch of Meat
			{ 15, 3770, 3 }, -- Mutton Chop
			{ 25, 3771, 4 }, -- Wild Hog Shank
			{ 35, 4599, 5 }, -- Cured Ham Steak
			{ 45, 8952, 6 }, -- Roasted Quail
		},
	},
	{
		kind = "food",
		diet = FISH,
		tiers = {
			{ 1, 787, 1 }, -- Slitherskin Mackerel
			{ 5, 4592, 2 }, -- Longjaw Mud Snapper
			{ 15, 4593, 3 }, -- Bristle Whisker Catfish
			{ 25, 4594, 4 }, -- Rockscale Cod
			{ 35, 21552, 5 }, -- Striped Yellowtail
			{ 45, 8957, 6 }, -- Spinefin Halibut
		},
	},
	{
		kind = "food",
		diet = BREAD,
		tiers = {
			{ 1, 4540, 1 }, -- Tough Hunk of Bread
			{ 5, 4541, 2 }, -- Freshly Baked Bread
			{ 15, 4542, 3 }, -- Moist Cornbread
			{ 25, 4544, 4 }, -- Mulgore Spice Bread
			{ 35, 4601, 5 }, -- Soft Banana Bread
			{ 45, 8950, 6 }, -- Homemade Cherry Pie
		},
	},
	{
		kind = "food",
		diet = CHEESE,
		tiers = {
			{ 1, 2070, 1 }, -- Darnassian Bleu
			{ 5, 414, 2 }, -- Dalaran Sharp
			{ 15, 422, 3 }, -- Dwarven Mild
			{ 25, 1707, 4 }, -- Stormwind Brie
			{ 35, 3927, 5 }, -- Fine Aged Cheddar
			{ 45, 8932, 6 }, -- Alterac Swiss
		},
	},
	{
		kind = "food",
		diet = FRUIT,
		tiers = {
			{ 1, 4536, 1 }, -- Shiny Red Apple
			{ 5, 4537, 2 }, -- Tel'Abim Banana
			{ 15, 4538, 3 }, -- Snapvine Watermelon
			{ 25, 4539, 4 }, -- Goldenbark Apple
			{ 35, 4602, 5 }, -- Moon Harvest Pumpkin
			{ 45, 8953, 6 }, -- Deep Fried Plantains
		},
	},
	{
		kind = "food",
		diet = FUNGUS,
		tiers = {
			{ 1, 4604, 1 }, -- Forest Mushroom Cap
			{ 5, 4605, 2 }, -- Red-speckled Mushroom
			{ 15, 4606, 3 }, -- Spongy Morel
			{ 25, 4607, 4 }, -- Delicious Cave Mold
			{ 35, 4608, 5 }, -- Raw Black Truffle
			{ 45, 8948, 6 }, -- Dried King Bolete
		},
	},

	{
		kind = "arrow",
		tiers = {
			{ 1, 2512, 1 }, -- Rough Arrow
			{ 10, 2515, 2 }, -- Sharp Arrow
			{ 25, 3030, 3 }, -- Razor Arrow
			{ 40, 11285, 4 }, -- Jagged Arrow
		},
	},
	{
		kind = "bullet",
		tiers = {
			{ 1, 2516, 1 }, -- Light Shot
			{ 10, 2519, 2 }, -- Heavy Shot
			{ 25, 3033, 3 }, -- Solid Shot
			{ 40, 11284, 4 }, -- Accurate Slugs
		},
	},

	{
		kind = "poison",
		group = 1,
		tiers = {},
	},
	{
		kind = "poison",
		group = 2,
		tiers = {
			{ 20, 3775, 1 }, -- Crippling Poison
			{ 50, 3776, 2 }, -- Crippling Poison II
		},
	},
	{
		kind = "poison",
		group = 3,
		tiers = {
			{ 30, 2892, 1 }, -- Deadly Poison
			{ 38, 2893, 2 }, -- Deadly Poison II
			{ 46, 8984, 3 }, -- Deadly Poison III
			{ 54, 8985, 4 }, -- Deadly Poison IV
			{ 60, 20844, 5 }, -- Deadly Poison V
		},
	},
	{
		kind = "poison",
		group = 4,
		tiers = {
			{ 20, 6947, 1 }, -- Instant Poison
			{ 28, 6949, 2 }, -- Instant Poison II
			{ 36, 6950, 3 }, -- Instant Poison III
			{ 44, 8926, 4 }, -- Instant Poison IV
			{ 52, 8927, 5 }, -- Instant Poison V
			{ 60, 8928, 6 }, -- Instant Poison VI
		},
	},
	{
		kind = "poison",
		group = 5,
		tiers = {
			{ 24, 5237, 1 }, -- Mind-numbing Poison
			{ 38, 6951, 2 }, -- Mind-numbing Poison II
			{ 52, 9186, 3 }, -- Mind-numbing Poison III
		},
	},
	{
		kind = "poison",
		group = 6,
		tiers = {
			{ 32, 10918, 1 }, -- Wound Poison
			{ 40, 10920, 2 }, -- Wound Poison II
			{ 48, 10921, 3 }, -- Wound Poison III
			{ 56, 10922, 4 }, -- Wound Poison IV
		},
	},

	{
		kind = "reagent",
		reagent = "hearthstone",
		tiers = {
			{ 1, 6948, 1 }, -- Hearthstone
		},
	},
	{
		kind = "reagent",
		reagent = "corpse-dust",
		tiers = {},
	},
	{
		-- Gift of the Wild by rank.
		kind = "reagent",
		reagent = "wilds",
		tiers = {
			{ 50, 17021, 1 }, -- Wild Berries
			{ 60, 17026, 2 }, -- Wild Thornroot
		},
	},
	{
		-- Rebirth by rank.
		kind = "reagent",
		reagent = "seeds",
		tiers = {
			{ 20, 17034, 1 }, -- Maple Seed
			{ 30, 17035, 2 }, -- Stranglethorn Seed
			{ 40, 17036, 3 }, -- Ashwood Seed
			{ 50, 17037, 4 }, -- Hornbeam Seed
			{ 60, 17038, 5 }, -- Ironwood Seed
		},
	},
	{
		kind = "reagent",
		reagent = "arcane-powder",
		tiers = {
			{ 56, 17020, 1 }, -- Arcane Powder (Arcane Brilliance)
		},
	},
	{
		kind = "reagent",
		reagent = "light-feather",
		tiers = {
			{ 12, 17056, 1 }, -- Light Feather
		},
	},
	{
		kind = "reagent",
		reagent = "rune-of-teleportation",
		tiers = {
			{ 20, 17031, 1 }, -- Rune of Teleportation
		},
	},
	{
		kind = "reagent",
		reagent = "rune-of-portals",
		tiers = {
			{ 40, 17032, 1 }, -- Rune of Portals
		},
	},
	{
		kind = "reagent",
		reagent = "symbol-of-divinity",
		tiers = {
			{ 30, 17033, 1 }, -- Symbol of Divinity (Divine Intervention)
		},
	},
	{
		kind = "reagent",
		reagent = "symbol-of-kings",
		tiers = {
			{ 52, 21177, 1 }, -- Symbol of Kings (Greater Blessings)
		},
	},
	{
		kind = "reagent",
		reagent = "candles",
		tiers = {
			{ 48, 17028, 1 }, -- Holy Candle
			{ 60, 17029, 2 }, -- Sacred Candle
		},
	},
	{
		kind = "reagent",
		reagent = "thieves-tools",
		tiers = {
			{ 16, 5060, 1 }, -- Thieves' Tools (Pick Lock)
		},
	},
	{
		kind = "reagent",
		reagent = "flash-powder",
		tiers = {
			{ 22, 5140, 1 }, -- Flash Powder (Vanish)
		},
	},
	{
		kind = "reagent",
		reagent = "blinding-powder",
		tiers = {
			{ 34, 5530, 1 }, -- Blinding Powder (Blind)
		},
	},
	{
		kind = "reagent",
		reagent = "ankh",
		tiers = {
			{ 30, 17030, 1 }, -- Ankh (Reincarnation)
		},
	},
	{
		kind = "reagent",
		reagent = "fish-scales",
		tiers = {
			{ 22, 17057, 1 }, -- Shiny Fish Scales (Water Breathing)
		},
	},
	{
		kind = "reagent",
		reagent = "fish-oil",
		tiers = {
			{ 28, 17058, 1 }, -- Fish Oil (Water Walking)
		},
	},
	{
		kind = "reagent",
		reagent = "earth-totem",
		tiers = {
			{ 4, 5175, 1 }, -- Earth Totem
		},
	},
	{
		kind = "reagent",
		reagent = "fire-totem",
		tiers = {
			{ 10, 5176, 1 }, -- Fire Totem
		},
	},
	{
		kind = "reagent",
		reagent = "water-totem",
		tiers = {
			{ 20, 5177, 1 }, -- Water Totem
		},
	},
	{
		kind = "reagent",
		reagent = "air-totem",
		tiers = {
			{ 30, 5178, 1 }, -- Air Totem
		},
	},
	{
		kind = "reagent",
		reagent = "demonic-figurine",
		tiers = {
			{ 60, 16583, 1 }, -- Demonic Figurine (Ritual of Doom)
		},
	},
	{
		kind = "reagent",
		reagent = "infernal-stone",
		tiers = {
			{ 50, 5565, 1 }, -- Infernal Stone (Inferno)
		},
	},
	{
		kind = "reagent",
		reagent = "soul-shard",
		tiers = {
			{ 10, 6265, 1 }, -- Soul Shard (Drain Soul)
		},
	},

	{
		kind = "healing-potion",
		tiers = {
			{ 1, 118, 1 }, -- Minor Healing Potion
			{ 3, 858, 2 }, -- Lesser Healing Potion
			{ 12, 929, 3 }, -- Healing Potion
			{ 21, 1710, 4 }, -- Greater Healing Potion
			{ 35, 3928, 5 }, -- Superior Healing Potion
			{ 45, 13446, 6 }, -- Major Healing Potion
		},
	},
	{
		kind = "mana-potion",
		tiers = {
			{ 5, 2455, 1 }, -- Minor Mana Potion
			{ 14, 3385, 2 }, -- Lesser Mana Potion
			{ 22, 3827, 3 }, -- Mana Potion
			{ 31, 6149, 4 }, -- Greater Mana Potion
			{ 41, 13443, 5 }, -- Superior Mana Potion
			{ 49, 13444, 6 }, -- Major Mana Potion
		},
	},
}

--[[
How We Got the Data

Last Validated
	2026-10-16, WoW Forever 1.60.1.70425

Notes
	- The staple ladders, read by Features/Restocker/Restocker-Upgrade.lua and the Starter List (Restocker-Starter-List.lua). Each family goes up in fixed steps, so a Restock List entry can follow the player instead of going stale: at level 45 "Soft Banana Bread" is what you want, at 55 it is not.
	- A table of its own on purpose, not columns on ns.FOOD_AND_WATER or ns.POTIONS: those answer "what does this item restore?" for hundreds of items, while this answers "what should replace this on a shopping list?" for a curated few. Bolting one onto the other would nil-pad most rows, widen an already-positional row, and leave each tier's rank nowhere to live.
	- Each tier is { minLevel, itemID, rank }. minLevel is the level the item becomes usable (its required level), which for food runs ten below the item level of the same items. rank is the third field: the higher rank is the better tier whatever the row's position, and Restocker-Upgrade.lua sorts every ladder by rank at load. Ranks follow minLevel; where two tiers share one (the Wrath folder's level-65 food and water) the Wrath item carries the higher rank.
	- kind says what the ladder is. diet is carried on the food chains only and uses ns.PET_DIET_MAP's numbering (Data/Data.lua), NOT the database's FoodType: the two disagree on four of six values (the database calls cheese 3 and bread 4 and swaps fruit and fungus), so a FoodType pasted in raw would mislabel most of this file. Water is 0: drinks have no FoodType, which is also why they are absent from the pet-food table.
	- Which folders hold a tier is decided by hand, and has to be. A Wrath database can't say when an item was added: the ID blocks interleave (the Northrend food staples are 33443-33454, below TBC's Naaru Ration at 34780), and vendor maps describe 3.3.5, where Azeroth vendors already stock Northrend food. It changes an outcome only at required levels 55-60, where Classic Era would otherwise reach for Outland goods, and at 65, where TBC and Wrath offer equivalents.
	- Every food, water and ammo tier is gold-buyable and unlimited stock (no extended cost, no stock limit, a buy price). That drops the arena and token foods (Star's Tears, Marsh Lichen) and the limited-stock ones (Blackened Basilisk, Steaming Chicken Soup), none of which a restock list can rely on. Where a tier had several candidates the one on the most vendors won.
	- Homemade Cherry Pie is bread, not fruit: the database files it under FoodType 6 and is simply wrong, and the pet-food table carries the same correction. Taking the SQL at its word would leave bread with no tier at 45 and give fruit two, so Deep Fried Plantains takes fruit's 45.
	- Arrows and bullets are separate ladders on purpose: a hunter's weapon decides which they can fire, so upgrading an arrow into a bullet would leave them holding ammo they can't use. The two mirror each other tier for tier and damage for damage. Engineering ammo (Thorium Headed Arrow, Mithril Gyro-Shot) beats both and appears in neither, since no vendor sells it.
	- Reputation and token ammo is left out. The intended filter, npc_vendor's condition_id, is empty in the source database, so vendor count separates them instead, and cleanly: the staples sit on 54 to 120 vendors and every rep, token or quartermaster line on 1 to 4. Left out on that basis: Scout's Arrow, Halaani Razorshaft, Halaani Grimshot, Warden's Arrow, Hellfire Shot, Felbane Slugs, Mysterious Arrow, Mysterious Shell, Timeless Arrow, Timeless Shell. A player who switches to rep ammo holds something with no chain entry, so its Upgrade button greys out and Connoisseur leaves it alone.
	- The poison ladders mirror ns.POISON_DATA (Poisons-Camelot.lua), which the Poisons macro ships: keep the two in step. group is ns.POISON_GROUPS' numbering (Data/Data.lua), which is how the Starter List finds each ladder. Poisons are crafted, never sold, so the Restocker buys the reagents for a listed rank instead (Restocker-Crafting-Reagents.lua). Which folders hold a rank is decided by hand from release history: Anesthetic is TBC's new poison, so the Classic Era folders hold its chain empty; the 22xxx ranks came with TBC, and the 43xxx ranks are Wrath's, carried by the Wrath folder alone.
	- The class reagent chains are one per Starter List reagent checkbox, keyed by the reagent string. Single-tier chains are deliberate: a one-rung ladder gives a reagent the same level gate every real ladder gets (its Upgrade toggle is active but inert). Seeds (Rebirth by rank), Wilds (Gift of the Wild by rank) and Candles (Prayer of Fortitude by rank) upgrade like the food ladders. TBC's prayers reuse the Sacred Candle, so no TBC candle tier exists.
	- Every reagent minLevel is an estimate of the level the reagent's spell is first trainable, awaiting hand-adjustment, and is NOT the item's required level: reagents carry none of their own, the spell is the gate. Light Feather opens at 12 for Slow Fall (the priest's Levitate trains at 34; one chain serves both). Blinding Powder left the game after Classic (Blind lost its reagent), so only the Classic Era folders carry its tier. Corpse Dust is Wrath vendor stock, so only the Wrath folder carries its tier.
	- The Hearthstone chain is the worked example offered to every class: nothing sells it and everyone owns one, so it shows that the Restock List tracks anything at all. Like it, Soul Shards and the Alchemy potions have no vendor, so their Buy toggle has nothing to buy while the bank half of the Restocker still moves them.
	- The potion ladders are hand-curated from ns.POTIONS, whose amounts confirm the order (healing 70/140/280/455/700/1050/1500, mana 140/280/455/700/900/1350/1800). Every non-standard potion there is left out: the Combat, Auchenai, Crystal, Ogre Brew, Nethergon, Salve, Draught and Injector variants are zone-locked, quest-locked or reward items. The two ladders don't step together (healing at 1/3/12/21/35/45/55/70, mana at 5/14/22/31/41/49/55/70), so a character carrying both often upgrades one and not the other at the same level; that is correct. Runic Healing and Runic Mana are Wrath items, carried only by the Wrath folder's ladders.
	- WoW Forever's level-1 copies of Roasted Quail, Morning Glory Dew and the low potions (IDs 287963-287977) are not tiers; the ladders are curated by hand.

SQL (CMaNGOS)
	Food and water, wotlk-db (CMaNGOS). Ammo is the same query with
	`class = 6 AND subclass IN (2, 3)` (2 arrow, 3 bullet) plus dmg_min1 and
	dmg_max1 to confirm the ordering.

	    SELECT it.entry, it.name, it.ItemLevel, it.RequiredLevel, it.FoodType,
	           it.spellid_1, it.BuyPrice, COUNT(DISTINCT nv.entry) AS vendors,
	           MIN(nv.maxcount) AS minStock, MAX(nv.ExtendedCost) AS extCost,
	           GROUP_CONCAT(DISTINCT c.map ORDER BY c.map) AS vendorMaps
	    FROM item_template it
	    JOIN npc_vendor nv        ON nv.item  = it.entry
	    JOIN creature_template ct ON ct.Entry = nv.entry
	    LEFT JOIN creature c      ON c.id     = ct.Entry
	    WHERE it.class = 0 AND it.subclass = 5
	    GROUP BY it.entry
	    ORDER BY it.FoodType, it.ItemLevel, it.entry;

	Poisons, the same database, filtered by name instead of class and subclass
	(the poison subclass moved between client generations). A LEFT JOIN rather
	than the food query's inner join, so a rank with no vendor row still shows
	up and an exclusion is a decision instead of an accident:

	    SELECT it.entry, it.name, it.ItemLevel, it.RequiredLevel, it.BuyPrice,
	           COUNT(DISTINCT nv.entry) AS vendors, MIN(nv.maxcount) AS minStock,
	           MAX(nv.ExtendedCost) AS extCost
	    FROM item_template it
	    LEFT JOIN npc_vendor nv ON nv.item = it.entry
	    WHERE it.name REGEXP '^(Anesthetic|Crippling|Deadly|Instant|Mind-numbing|Wound) Poison'
	    GROUP BY it.entry
	    ORDER BY it.name, it.RequiredLevel;

	Potions, the same database, asked for directly because potions never appear
	in an npc_vendor query:

	    SELECT entry, name, ItemLevel, RequiredLevel
	    FROM item_template
	    WHERE entry IN (118,858,929,1710,3928,13446,22829,33447,
	                    2455,3385,3827,6149,13443,13444,22832,33448)
	    ORDER BY entry;

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=1.60.1.70425
]]
