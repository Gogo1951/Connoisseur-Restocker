local _, ns = ...

--------------------------------------------------------------------------------
-- Pet Foods
--------------------------------------------------------------------------------

--[[
    Pet food data for Hunter Feed Pet support. Diet IDs follow ns.PET_DIET_MAP
    in Data/Data.lua: 1 = Meat, 2 = Fish, 3 = Bread, 4 = Cheese, 5 = Fruit,
    6 = Fungus.
]]

--[[
    Source: Validate Data on the WoW Forever client (1.60.1, build 70124).
    Tough Condor Meat and Crawler Meat were added from WoW Forever's own tables
    on wago.tools (build 1.60.1.70124, ItemPetFoodID), and those tables carry
    no quest objectives, so their questIDs are unchecked. Grilled King Crawler
    Legs' and Tender Crab Meat's diets also come from those tables, as do 45
    more foods, pending Validate Data, with their questIDs likewise unchecked.
    Whipper Root Tuber, Essence Mango, the holiday foods and the battleground
    and Darkspear Islands rations are left out on purpose: Feed Pet feeds the
    cheapest food first, and those sell for nothing or are kept for their zone.

    SELECT entry, name, ItemLevel, FoodType, SellPrice
    FROM item_template
    WHERE class = 0 AND subclass = 5 AND FoodType > 0
    ORDER BY FoodType, ItemLevel, entry;

    Quest objective IDs come from quest_template (RequiredItemId1-6).

    sellPrice is in copper (vendor sell value per unit).
    questIDs is a table of quest IDs that use this item as an objective,
    or nil when the item is not a quest objective.
]]
-- [itemID] = { itemLevel, dietID, sellPrice, questIDs or nil }, -- Name
ns.PET_FOOD_DATA = {
	-- Meat
	[5051] = { 1, 1, 1, { 862 } }, -- Dig Rat
	[117] = { 5, 1, 1, nil }, -- Tough Jerky
	[769] = { 5, 1, 3, { 86, 317 } }, -- Chunk of Boar Meat
	[2672] = { 5, 1, 4, nil }, -- Stringy Wolf Meat
	[252022] = { 5, 1, 1, nil }, -- Galestrider Jerky
	[2679] = { 10, 1, 5, nil }, -- Charred Wolf Meat
	[2886] = { 5, 1, 5, { 384 } }, -- Crag Boar Rib
	[5465] = { 5, 1, 3, { 4161 } }, -- Small Spider Leg
	[7097] = { 5, 1, 1, nil }, -- Leg Meat
	[19223] = { 5, 1, 1, nil }, -- Darkmoon Dog
	[2681] = { 10, 1, 6, nil }, -- Roasted Boar Meat
	[729] = { 10, 1, 17, { 38 } }, -- Stringy Vulture Meat
	[2673] = { 10, 1, 10, nil }, -- Coyote Meat
	[5467] = { 10, 1, 7, nil }, -- Kodo Meat
	[5469] = { 10, 1, 9, { 2178 } }, -- Strider Meat
	[3173] = { 11, 1, 15, { 418 } }, -- Bear Meat
	[723] = { 12, 1, 15, { 22 } }, -- Goretusk Liver
	[2677] = { 14, 1, 15, nil }, -- Boar Ribs
	[2924] = { 14, 1, 16, { 385 } }, -- Crocolisk Meat
	[733] = { 15, 1, 100, nil }, -- Westfall Stew
	[1081] = { 15, 1, 50, { 92 } }, -- Crisp Spider Meat
	[2287] = { 15, 1, 6, nil }, -- Haunch of Meat
	[6890] = { 10, 1, 6, nil }, -- Smoked Bear Meat
	[17119] = { 15, 1, 6, nil }, -- Deeprun Rat Kabob
	[19304] = { 15, 1, 6, nil }, -- Spiced Beef Jerky
	[1080] = { 15, 1, 78, nil }, -- Tough Condor Meat
	[18633] = { 15, 1, 6, nil }, -- Styleen's Sour Suckerpop
	[252029] = { 15, 1, 30, nil }, -- Hippogryph Flank
	[278117] = { 15, 1, 6, nil }, -- Hard Boiled Eggs
	[1015] = { 19, 1, 24, { 90 } }, -- Lean Wolf Flank
	[2685] = { 25, 1, 75, nil }, -- Succulent Pork Ribs
	[5478] = { 25, 1, 70, nil }, -- Dig Rat Stew
	[3730] = { 21, 1, 45, nil }, -- Big Bear Meat
	[5470] = { 22, 1, 28, nil }, -- Thunder Lizard Tail
	[3667] = { 23, 1, 25, nil }, -- Tender Crocolisk Meat
	[3731] = { 23, 1, 55, nil }, -- Lion Meat
	[5471] = { 23, 1, 30, nil }, -- Stag Meat
	[3770] = { 25, 1, 25, nil }, -- Mutton Chop
	[19305] = { 25, 1, 25, nil }, -- Pickled Kodo Foot
	[278121] = { 25, 1, 25, nil }, -- Smoked Sausage
	[3712] = { 30, 1, 87, { 555, 7321 } }, -- Turtle Meat
	[12037] = { 30, 1, 87, nil }, -- Mystery Meat
	[12184] = { 30, 1, 87, nil }, -- Raptor Flesh
	[12202] = { 30, 1, 87, nil }, -- Tiger Meat
	[12203] = { 30, 1, 87, nil }, -- Red Wolf Meat
	[3404] = { 35, 1, 181, { 703 } }, -- Buzzard Wing
	[3771] = { 35, 1, 50, nil }, -- Wild Hog Shank
	[12204] = { 35, 1, 112, nil }, -- Heavy Kodo Meat
	[19224] = { 35, 1, 50, nil }, -- Red Hot Wings
	[17407] = { 35, 1, 50, nil }, -- Graccu's Homemade Meat Pie
	[278118] = { 35, 1, 62, nil }, -- Rich Broth
	[12205] = { 40, 1, 112, nil }, -- White Spider Meat
	[12206] = { 40, 1, 112, nil }, -- Tender Crab Meat
	[12208] = { 40, 1, 150, nil }, -- Tender Wolf Meat
	[4599] = { 45, 1, 100, nil }, -- Cured Ham Steak
	[19306] = { 45, 1, 100, nil }, -- Crunchy Frog
	[17408] = { 45, 1, 100, nil }, -- Spicy Beefstick
	[18635] = { 45, 1, 100, nil }, -- Bellara's Nutterbar
	[8952] = { 55, 1, 200, nil }, -- Roasted Quail
	[11444] = { 55, 1, 200, nil }, -- Grim Guzzler Boar
	[20424] = { 55, 1, 175, nil }, -- Sandworm Meat
	[262433] = { 60, 1, 200, nil }, -- Ketharas' Hyjal Stew
	-- Fish
	[6299] = { 5, 2, 1, nil }, -- Sickly Looking Fish
	[787] = { 10, 2, 1, nil }, -- Slitherskin Mackerel
	[6290] = { 10, 2, 1, nil }, -- Brilliant Smallfish
	[6291] = { 5, 2, 1, nil }, -- Raw Brilliant Smallfish
	[6303] = { 5, 2, 1, nil }, -- Raw Slitherskin Mackerel
	[5525] = { 10, 2, 20, nil }, -- Boiled Clams
	[251525] = { 10, 2, 5, nil }, -- Savory Whimsyfin Delight
	[2675] = { 13, 2, 11, nil }, -- Crawler Claw
	[2674] = { 13, 2, 12, nil }, -- Crawler Meat
	[5503] = { 14, 2, 16, nil }, -- Clam Meat
	[1326] = { 15, 2, 10, nil }, -- Sauteed Sunfish
	[2682] = { 10, 2, 25, nil }, -- Cooked Crab Claw
	[4592] = { 15, 2, 1, nil }, -- Longjaw Mud Snapper
	[5095] = { 15, 2, 3, { 8524, 8525 } }, -- Rainbow Fin Albacore
	[5468] = { 15, 2, 12, nil }, -- Soft Frenzy Flesh
	[6289] = { 15, 2, 1, nil }, -- Raw Longjaw Mud Snapper
	[6316] = { 15, 2, 3, nil }, -- Loch Frenzy Delight
	[6317] = { 15, 2, 2, nil }, -- Raw Loch Frenzy
	[6361] = { 15, 2, 2, nil }, -- Raw Rainbow Fin Albacore
	[6458] = { 15, 2, 1, nil }, -- Oil Covered Fish
	[12238] = { 15, 2, 2, { 1141 } }, -- Darkshore Grouper
	[5526] = { 15, 2, 75, nil }, -- Clam Chowder
	[21071] = { 20, 2, 25, nil }, -- Raw Sagefish
	[5504] = { 23, 2, 22, nil }, -- Tangy Clam Meat
	[4593] = { 25, 2, 4, nil }, -- Bristle Whisker Catfish
	[6308] = { 25, 2, 2, nil }, -- Raw Bristle Whisker Catfish
	[4594] = { 35, 2, 6, nil }, -- Rockscale Cod
	[4655] = { 35, 2, 71, nil }, -- Giant Clam Meat
	[6362] = { 35, 2, 4, nil }, -- Raw Rockscale Cod
	[8364] = { 35, 2, 6, nil }, -- Mithril Head Trout
	[8365] = { 35, 2, 4, nil }, -- Raw Mithril Head Trout
	[13546] = { 35, 2, 62, { 5386 } }, -- Bloodbelly Fish
	[21153] = { 40, 2, 125, nil }, -- Raw Greater Sagefish
	[4603] = { 45, 2, 4, nil }, -- Raw Spotted Yellowtail
	[6887] = { 45, 2, 5, { 8614, 8529, 8613, 8528 } }, -- Spotted Yellowtail
	[7974] = { 45, 2, 50, { 6610 } }, -- Zesty Clam Meat
	[13754] = { 45, 2, 6, nil }, -- Raw Glossy Mightfish
	[13755] = { 45, 2, 7, nil }, -- Raw Winter Squid
	[13756] = { 45, 2, 9, nil }, -- Raw Summer Bass
	[13758] = { 45, 2, 4, nil }, -- Raw Redgill
	[13759] = { 45, 2, 10, nil }, -- Raw Nightfin Snapper
	[13760] = { 45, 2, 10, nil }, -- Raw Sunscale Salmon
	[13930] = { 45, 2, 5, nil }, -- Filet of Redgill
	[16766] = { 45, 2, 100, nil }, -- Undermine Clam Chowder
	[21552] = { 45, 2, 5, nil }, -- Striped Yellowtail
	[9681] = { 45, 2, 50, nil }, -- Grilled King Crawler Legs
	[8957] = { 55, 2, 200, nil }, -- Spinefin Halibut
	[8959] = { 55, 2, 160, nil }, -- Raw Spinefin Halibut
	[13888] = { 55, 2, 12, nil }, -- Darkclaw Lobster
	[13889] = { 55, 2, 5, nil }, -- Raw Whitescale Salmon
	[13893] = { 55, 2, 15, nil }, -- Large Raw Mightfish
	[13933] = { 55, 2, 14, nil }, -- Lobster Stew
	[13935] = { 55, 2, 10, { 8615, 8616 } }, -- Baked Salmon
	[18255] = { 55, 2, 15, nil }, -- Runn Tum Tuber
	[250081] = { 55, 2, 10, nil }, -- Clam Linguine
	-- Bread
	[4540] = { 5, 3, 1, nil }, -- Tough Hunk of Bread
	[5349] = { 5, 3, 0, nil }, -- Conjured Muffin
	[11109] = { 5, 3, 6, nil }, -- Special Chicken Feed
	[16166] = { 5, 3, 1, nil }, -- Bean Soup
	[17344] = { 5, 3, 1, nil }, -- Candy Cane
	[252028] = { 5, 3, 1, nil }, -- Fresh Gustberry Bread
	[278119] = { 5, 3, 1, nil }, -- Bread with Butter
	[1113] = { 15, 3, 0, nil }, -- Conjured Bread
	[4541] = { 15, 3, 6, nil }, -- Freshly Baked Bread
	[252026] = { 15, 3, 6, nil }, -- Gustberry Pie
	[1114] = { 25, 3, 0, nil }, -- Conjured Rye
	[4542] = { 25, 3, 25, nil }, -- Moist Cornbread
	[1487] = { 35, 3, 0, nil }, -- Conjured Pumpernickel
	[4544] = { 35, 3, 50, nil }, -- Mulgore Spice Bread
	[16169] = { 35, 3, 62, nil }, -- Wild Ricecake
	[18632] = { 35, 3, 50, nil }, -- Moonbrook Riot Taffy
	[260623] = { 35, 3, 62, nil }, -- Candied Fruit Sampler
	[4601] = { 45, 3, 100, nil }, -- Soft Banana Bread
	[8075] = { 45, 3, 0, nil }, -- Conjured Sourdough
	[8076] = { 55, 3, 0, nil }, -- Conjured Sweet Roll
	[23160] = { 55, 3, 200, nil }, -- Friendship Bread
	[13724] = { 55, 3, 300, nil }, -- Enriched Manna Biscuit
	[19301] = { 60, 3, 350, nil }, -- Alterac Manna Biscuit
	[22895] = { 65, 3, 0, nil }, -- Conjured Cinnamon Roll
	-- Cheese
	[2070] = { 5, 4, 1, nil }, -- Darnassian Bleu
	[252023] = { 5, 4, 1, nil }, -- Zaalanarr Sharp
	[278569] = { 5, 4, 1, nil }, -- Yesterday's Leftovers
	[414] = { 15, 4, 6, nil }, -- Dalaran Sharp
	[17406] = { 15, 4, 6, nil }, -- Holiday Cheesewheel
	[16167] = { 15, 4, 6, nil }, -- Versicolor Treat
	[252030] = { 15, 4, 6, nil }, -- Pungent Skycheddar
	[422] = { 25, 4, 25, nil }, -- Dwarven Mild
	[1707] = { 35, 4, 62, nil }, -- Stormwind Brie
	[3927] = { 45, 4, 150, nil }, -- Fine Aged Cheddar
	[8932] = { 55, 4, 200, { 6610 } }, -- Alterac Swiss
	-- Fruit
	[4536] = { 5, 5, 1, nil }, -- Shiny Red Apple
	[4656] = { 5, 5, 1, nil }, -- Small Pumpkin
	[5057] = { 5, 5, 1, nil }, -- Ripe Watermelon
	[251917] = { 5, 5, 1, nil }, -- Falorne's Homemade Tart
	[4537] = { 15, 5, 6, nil }, -- Tel'Abim Banana
	[252032] = { 15, 5, 30, nil }, -- Red Delicious Stormapple
	[4538] = { 25, 5, 25, nil }, -- Snapvine Watermelon
	[16170] = { 25, 5, 25, nil }, -- Steamed Mandu
	[4539] = { 35, 5, 50, nil }, -- Goldenbark Apple
	[278120] = { 35, 5, 50, nil }, -- Fruit Platter
	[4602] = { 45, 5, 100, nil }, -- Moon Harvest Pumpkin
	[16168] = { 45, 5, 100, nil }, -- Heaven Peach
	[21030] = { 45, 5, 100, nil }, -- Darnassus Kimchi Pie
	[260624] = { 45, 5, 100, nil }, -- Pristine Peach
	[260625] = { 45, 5, 100, nil }, -- Garnished Rice Cake
	[8950] = { 55, 3, 200, nil }, -- Homemade Cherry Pie (bread, diet 3: the database files it as fruit)
	[8953] = { 55, 5, 200, nil }, -- Deep Fried Plantains
	[21031] = { 55, 5, 200, nil }, -- Cabbage Kimchi
	[21033] = { 55, 5, 200, nil }, -- Radish Kimchi
	[11415] = { 55, 5, 200, nil }, -- Mixed Berries
	[12763] = { 55, 5, 200, nil }, -- Un'Goro Etherfruit
	[16171] = { 55, 5, 200, nil }, -- Shinsollo
	[22324] = { 55, 5, 200, nil }, -- Winter Kimchi
	[249796] = { 55, 5, 150, nil }, -- Hyjal Berries
	[260627] = { 55, 5, 200, nil }, -- Savory Shen'dralar Steak
	[260628] = { 55, 5, 200, nil }, -- Stuffed Pumpkin
	[278122] = { 55, 5, 200, nil }, -- Carrot Salad
	-- Fungus
	[4604] = { 5, 6, 1, nil }, -- Forest Mushroom Cap
	[267474] = { 5, 6, 1, nil }, -- Galeswept Forestshroom
	[4605] = { 15, 6, 6, nil }, -- Red-speckled Mushroom
	[4606] = { 25, 6, 25, nil }, -- Spongy Morel
	[4607] = { 35, 6, 50, nil }, -- Delicious Cave Mold
	[4608] = { 45, 6, 100, nil }, -- Raw Black Truffle
	[17747] = { 50, 6, 500, nil }, -- Razorlash Root
	[8948] = { 55, 6, 200, nil }, -- Dried King Bolete
	-- Goretusk Snout (731), Senggin Root (3448), Plainstrider Meat (4739), Meaty Bat Wing (12223) and Soft-shelled Clam Meat (15924) are deliberately absent; WoW Forever gives them no pet diet (ItemPetFoodID, wago.tools build 1.60.1.70124).
}
