local _, ns = ...

--------------------------------------------------------------------------------
-- Consumable Upgrade Paths
--------------------------------------------------------------------------------

--[[
    The staple ladders. Each family goes up in fixed steps, so a Restock List
    entry can follow the player instead of going stale: at level 45 "Soft
    Banana Bread" is what you want, at 55 it is not.

    Deliberately a table of its own rather than columns on
    ns.FOOD_AND_WATER or ns.POTIONS. Those answer "what does this
    item restore?" for hundreds of items; this one answers "what should replace
    this on a shopping list?" for a curated few. Bolting the second onto the
    first would nil-pad most rows, push an already-positional row wider, and
    leave each tier's rank nowhere to live -- the ranks are the data here, and
    Restocker-Upgrade.lua sorts every ladder by them at load.

    WHICH FOLDERS HOLD A TIER IS DECIDED BY HAND, and has to be. A Wrath
    database cannot say when an item was added: the ID blocks interleave (the
    Northrend food staples are 33443-33454, below TBC's Naaru Ration at 34780),
    and vendorMaps describes 3.3.5, where Azeroth vendors already stock
    Northrend food. It only changes an outcome in a few places -- reqLevel
    55-60, where Classic Era would otherwise reach for Outland goods, and 65,
    where TBC and Wrath offer equivalents -- but there it is the only thing
    that is right.

    minLevel is item_template.RequiredLevel, the level the item becomes USABLE,
    which for food runs ten below the ItemLevel ladder of the same items.
]]

--[[
    Source: copied from Data/TBC/Consumable-Upgrade-Paths-TBC.lua until Validate
    Data passes on this client.

    SOURCE, food and water (CMaNGoS, Wrath). Ammo is the same query with
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

    Every food, water and ammo tier below is gold-buyable and unlimited stock:
    extCost = 0, minStock = 0, BuyPrice > 0. That filter is what drops the
    arena and token foods (Star's Tears, Marsh Lichen) and the limited-stock
    ones (Blackened Basilisk, Steaming Chicken Soup) -- none of which a restock
    list can rely on. Where a tier had several candidates the one on the most
    vendors won.

    POTIONS ARE THE EXCEPTION TO ALL OF THAT. Past the first tier or two they
    are Alchemy goods off the auction house, not vendor stock, so no
    npc_vendor query produces them and the "sold by a merchant" rule does not
    apply. Their ladder is still real -- Greater becomes Superior at 35 the
    same way bread becomes pie at 45 -- and the Restocker still moves them to
    and from the bank. It only means their Buy toggle has nothing to buy from.
]]

--[[
    diet uses ns.PET_DIET_MAP's numbering (Data/Data.lua), NOT
    item_template.FoodType. The two disagree on four of six values -- the
    database calls cheese 3 and bread 4, Connoisseur calls bread 3 and cheese
    4, and it swaps fruit and fungus too -- so a FoodType pasted in raw from
    SQL would silently mislabel most of this file. Water is 0: drinks have no
    FoodType at all, which is also why they are absent from Pet-Foods-Mainline.lua.
]]
local WATER, MEAT, FISH, BREAD, CHEESE, FRUIT, FUNGUS = 0, 1, 2, 3, 4, 5, 6

--[[
    kind is what the ladder is, for anything that needs to tell them apart;
    diet is carried on the food chains only, where it ties to ns.PET_DIET_MAP.

    Arrows and bullets are separate ladders on purpose. A hunter's weapon
    decides which they can fire, so upgrading an arrow into a bullet would
    leave them holding ammo they cannot use.

    Each tier carries its rank, the third field: the higher rank is the better
    tier, whatever the row's position, and the tiers are sorted by rank at load
    (Features/Restocker/Restocker-Upgrade.lua). Ranks follow minLevel, and where
    two tiers share one (the Wrath folder's level-65 food and water) the Wrath
    item carries the higher rank.
]]
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
			{ 60, 28399, 7 }, -- Filtered Draenic Water
			{ 65, 27860, 8 }, -- Purified Draenic Water
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
			{ 55, 27854, 7 }, -- Smoked Talbuk Venison
			{ 65, 29451, 8 }, -- Clefthoof Ribs
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
			{ 55, 27858, 7 }, -- Sunspring Carp
			{ 65, 29452, 8 }, -- Zangar Trout
		},
	},
	{
		--[[
		    Homemade Cherry Pie is BREAD, not fruit. item_template files it
		    under FoodType 6 and the database is simply wrong -- Pet-Foods-Mainline.lua
		    already carries the same correction (diet 3) and says so. Taking
		    the SQL at its word would have left bread with no tier at 45 and
		    given fruit two.
		]]
		kind = "food",
		diet = BREAD,
		tiers = {
			{ 1, 4540, 1 }, -- Tough Hunk of Bread
			{ 5, 4541, 2 }, -- Freshly Baked Bread
			{ 15, 4542, 3 }, -- Moist Cornbread
			{ 25, 4544, 4 }, -- Mulgore Spice Bread
			{ 35, 4601, 5 }, -- Soft Banana Bread
			{ 45, 8950, 6 }, -- Homemade Cherry Pie
			{ 55, 27855, 7 }, -- Mag'har Grainbread
			{ 65, 29449, 8 }, -- Bladespire Bagel
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
			{ 55, 27857, 7 }, -- Garadar Sharp
			{ 65, 29448, 8 }, -- Mag'har Mild Cheese
		},
	},
	{
		--[[
		    Deep Fried Plantains takes 45, not Homemade Cherry Pie: see the bread
		    chain above for why the database's fruit label on the pie is wrong.
		]]
		kind = "food",
		diet = FRUIT,
		tiers = {
			{ 1, 4536, 1 }, -- Shiny Red Apple
			{ 5, 4537, 2 }, -- Tel'Abim Banana
			{ 15, 4538, 3 }, -- Snapvine Watermelon
			{ 25, 4539, 4 }, -- Goldenbark Apple
			{ 35, 4602, 5 }, -- Moon Harvest Pumpkin
			{ 45, 8953, 6 }, -- Deep Fried Plantains
			{ 55, 27856, 7 }, -- Skethyl Berries
			{ 65, 29450, 8 }, -- Telaari Grapes
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
			{ 55, 27859, 7 }, -- Zangar Caps
			{ 65, 29453, 8 }, -- Sporeggar Mushroom
		},
	},

	--[[
	    AMMO

	    Rep ammo is excluded, and the intended filter did not work:
	    npc_vendor's condition_id is empty in the source database, so the Halaa
	    token ammo and the Sha'tari / Ogri'la / Shattered Sun rep ammo all came
	    back looking unconditional. Vendor count separates them instead, and
	    cleanly -- the staples sit on 54 to 120 vendors and every rep, token or
	    quartermaster line on 1 to 4, with nothing in between. Excluded on that
	    basis: Scout's Arrow, Halaani Razorshaft, Halaani Grimshot, Warden's
	    Arrow, Hellfire Shot, Felbane Slugs, Mysterious Arrow, Mysterious
	    Shell, Timeless Arrow, Timeless Shell.

	    That an item leaves the ladder is the whole behaviour the exclusion
	    buys: a player who switches to rep ammo holds something with no chain
	    entry, so its Upgrade button greys out and Connoisseur leaves it alone.

	    The two ladders mirror each other exactly, tier for tier and damage for
	    damage. Engineering ammo (Thorium Headed Arrow, Mithril Gyro-Shot) beats
	    both and appears in neither, because none of it is sold by a vendor.
	]]
	{
		kind = "arrow",
		tiers = {
			{ 1, 2512, 1 }, -- Rough Arrow
			{ 10, 2515, 2 }, -- Sharp Arrow
			{ 25, 3030, 3 }, -- Razor Arrow
			{ 40, 11285, 4 }, -- Jagged Arrow
			{ 55, 28053, 5 }, -- Wicked Arrow
			{ 65, 28056, 6 }, -- Blackflight Arrow
		},
	},
	{
		kind = "bullet",
		tiers = {
			{ 1, 2516, 1 }, -- Light Shot
			{ 10, 2519, 2 }, -- Heavy Shot
			{ 25, 3033, 3 }, -- Solid Shot
			{ 40, 11284, 4 }, -- Accurate Slugs
			{ 55, 28060, 5 }, -- Impact Shot
			{ 65, 28061, 6 }, -- Ironbite Shell
		},
	},

	--[[
	    ROGUE POISONS

	    The tier rows mirror ns.POISON_DATA (Poisons-Mainline.lua), which the
	    Poisons macro already ships -- keep the two in step. group is
	    ns.POISON_GROUPS' numbering (Data/Data.lua), which is how the Starter
	    List popup finds each ladder.

	    Poisons are crafted, not bought: on every client a Rogue makes
	    every rank, no vendor sells one, and the Restocker buys the reagents for
	    a listed rank instead (Features/Restocker/Restocker-Crafting-Reagents.lua).
	    Like the potions above, the ladder is real without the "sold by a
	    merchant" rule. List the ranks with the food query up top, filtered by
	    name instead of class/subclass (the poison subclass moved between client
	    generations):

	        SELECT it.entry, it.name, it.ItemLevel, it.RequiredLevel, it.BuyPrice,
	               COUNT(DISTINCT nv.entry) AS vendors, MIN(nv.maxcount) AS minStock,
	               MAX(nv.ExtendedCost) AS extCost
	        FROM item_template it
	        LEFT JOIN npc_vendor nv ON nv.item = it.entry
	        WHERE it.name REGEXP '^(Anesthetic|Crippling|Deadly|Instant|Mind-numbing|Wound) Poison'
	        GROUP BY it.entry
	        ORDER BY it.name, it.RequiredLevel;

	    LEFT JOIN rather than the header query's inner join, so a rank with
	    no vendor row still shows up and an exclusion is a decision instead
	    of an accident.

	    Which folders hold a rank is decided by hand here too, from release
	    history: Anesthetic is TBC's new poison, so the Classic Era folders hold
	    its chain empty; the 22xxx ranks came with TBC, and the 43xxx ranks are
	    Wrath's, carried by the Wrath folder alone, like the Runic potions below.
	]]
	{
		kind = "poison",
		group = 1,
		tiers = {
			{ 68, 21835, 1 }, -- Anesthetic Poison
		},
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
			{ 62, 22053, 6 }, -- Deadly Poison VI
			{ 70, 22054, 7 }, -- Deadly Poison VII
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
			{ 68, 21927, 7 }, -- Instant Poison VII
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
			{ 64, 22055, 5 }, -- Wound Poison V
		},
	},

	--[[
	    CLASS REAGENTS

	    One chain per Starter List reagent checkbox, keyed by the reagent
	    string; single-tier chains are deliberate -- a one-rung ladder gives
	    a reagent the same level gate every real ladder gets, for free. (Their Upgrade toggle in the Restocker window is
	    active but inert: there is never a later tier to move to.) The
	    multi-tier groups here -- Seeds, Wilds, Candles -- upgrade exactly
	    like the food ladders above.

	    EVERY minLevel BELOW IS AN ESTIMATE of the level the reagent's spell
	    is first trainable, awaiting hand-adjustment -- unlike the rest of
	    this file these are NOT item_template.RequiredLevel, because reagents
	    carry no required level of their own; the spell is the gate.

	    Blinding Powder left the game after Classic, so only the Classic Era
	    folders carry its tier and every later folder holds its chain empty.

	    Soul Shards are the potions of this block: no vendor sells them, so
	    their Buy toggle has nothing to buy from, while the bank half of the
	    Restocker still moves them. Corpse Dust is Wrath vendor stock, so only
	    the Wrath folder carries its tier.
	]]
	{
		--[[
		    The worked example, offered to every class: nothing sells it and
		    everyone already owns one, so it demonstrates that the Restock
		    List tracks anything at all -- the bank half still applies, and
		    the Buy toggle simply has nothing to buy, like the Alchemy
		    potions below.
		]]
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
			{ 70, 22148, 3 }, -- Wild Quillvine
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
			{ 69, 22147, 6 }, -- Flintweed Seed
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
		--[[
		    Slow Fall at 12; the priest's Levitate trains at 34. One chain
		    serves both classes, so the earlier level opens it.
		]]
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
		--[[
		    Prayer of Fortitude by rank; TBC's prayers reuse the Sacred Candle,
		    so no TBC tier exists.
		]]
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
		-- Removed after Classic (Blind lost its reagent), so only the Classic Era folders carry its tier.
		kind = "reagent",
		reagent = "blinding-powder",
		tiers = {},
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

	--[[
	    POTIONS -- HAND-CURATED

	    The standard Alchemy ladders, taken from ns.POTIONS (the
	    restore amounts there confirm the ordering: 70/140/280/455/700/1050/
	    1500 healing, 140/280/455/700/900/1350/1800 mana). Every non-standard
	    potion in that table is deliberately absent -- the Combat, Auchenai,
	    Crystal, Ogre Brew, Nethergon, Salve, Draught and Injector variants are
	    zone-locked, quest-locked or reward items, and none belongs on a
	    ladder a shopping list follows automatically.

	    minLevel is item_template.RequiredLevel like every other ladder here,
	    but it had to be asked for directly -- potions never appear in an
	    npc_vendor query, so the source query above does not reach them:

	        SELECT entry, name, ItemLevel, RequiredLevel
	        FROM item_template
	        WHERE entry IN (118,858,929,1710,3928,13446,22829,33447,
	                        2455,3385,3827,6149,13443,13444,22832,33448)
	        ORDER BY entry;

	    Note the two ladders do NOT step together -- healing goes
	    1/3/12/21/35/45/55/70 and mana 5/14/22/31/41/49/55/70 -- so a character
	    carrying both will often upgrade one and not the other on the same
	    level. That is correct, not a rounding error in this table.

	    Runic Healing and Runic Mana are Wrath items: only the Wrath folder's
	    ladders carry them, and ns.POTIONS has no row for either yet.
	]]
	{
		kind = "healing-potion",
		tiers = {
			{ 1, 118, 1 }, -- Minor Healing Potion
			{ 3, 858, 2 }, -- Lesser Healing Potion
			{ 12, 929, 3 }, -- Healing Potion
			{ 21, 1710, 4 }, -- Greater Healing Potion
			{ 35, 3928, 5 }, -- Superior Healing Potion
			{ 45, 13446, 6 }, -- Major Healing Potion
			{ 55, 22829, 7 }, -- Super Healing Potion
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
			{ 55, 22832, 7 }, -- Super Mana Potion
		},
	},
}
