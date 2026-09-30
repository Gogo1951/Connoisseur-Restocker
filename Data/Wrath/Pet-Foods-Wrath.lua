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
    Source: copied from Data/TBC/Pet-Foods-TBC.lua until Validate Data passes on
    this client.

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
	[4739] = { 1, 1, 0, { 747 } }, -- Plainstrider Meat
	[5051] = { 1, 1, 1, { 862 } }, -- Dig Rat
	[23676] = { 1, 1, 5, { 9454 } }, -- Moongraze Stag Tenderloin
	[117] = { 5, 1, 1, nil }, -- Tough Jerky
	[769] = { 5, 1, 3, { 86, 317 } }, -- Chunk of Boar Meat
	[2672] = { 5, 1, 4, nil }, -- Stringy Wolf Meat
	[2679] = { 5, 1, 5, nil }, -- Charred Wolf Meat
	[2886] = { 5, 1, 5, { 384 } }, -- Crag Boar Rib
	[5465] = { 5, 1, 3, { 4161 } }, -- Small Spider Leg
	[7097] = { 5, 1, 1, nil }, -- Leg Meat
	[12223] = { 5, 1, 4, nil }, -- Meaty Bat Wing
	[19223] = { 5, 1, 1, nil }, -- Darkmoon Dog
	[23495] = { 5, 1, 0, nil }, -- Springpaw Appetizer
	[27668] = { 5, 1, 5, nil }, -- Lynx Meat
	[27669] = { 5, 1, 5, nil }, -- Bat Flesh
	[2681] = { 7, 1, 6, nil }, -- Roasted Boar Meat
	[729] = { 10, 1, 17, { 38 } }, -- Stringy Vulture Meat
	[2673] = { 10, 1, 10, nil }, -- Coyote Meat
	[5467] = { 10, 1, 7, nil }, -- Kodo Meat
	[5469] = { 10, 1, 9, { 2178 } }, -- Strider Meat
	[3173] = { 11, 1, 15, { 418 } }, -- Bear Meat
	[723] = { 12, 1, 15, { 22 } }, -- Goretusk Liver
	[731] = { 12, 1, 27, { 38 } }, -- Goretusk Snout
	[2677] = { 14, 1, 15, nil }, -- Boar Ribs
	[2924] = { 14, 1, 16, { 385 } }, -- Crocolisk Meat
	[733] = { 15, 1, 100, nil }, -- Westfall Stew
	[1081] = { 15, 1, 50, { 92 } }, -- Crisp Spider Meat
	[2287] = { 15, 1, 6, nil }, -- Haunch of Meat
	[6890] = { 15, 1, 6, nil }, -- Smoked Bear Meat
	[17119] = { 15, 1, 6, nil }, -- Deeprun Rat Kabob
	[19304] = { 15, 1, 6, nil }, -- Spiced Beef Jerky
	[22644] = { 15, 1, 12, { 9171 } }, -- Crunchy Spider Leg
	[1015] = { 19, 1, 24, { 90 } }, -- Lean Wolf Flank
	[2685] = { 20, 1, 75, nil }, -- Succulent Pork Ribs
	[5478] = { 20, 1, 70, nil }, -- Dig Rat Stew
	[3730] = { 21, 1, 45, nil }, -- Big Bear Meat
	[5470] = { 22, 1, 28, nil }, -- Thunder Lizard Tail
	[3667] = { 23, 1, 25, nil }, -- Tender Crocolisk Meat
	[3731] = { 23, 1, 55, nil }, -- Lion Meat
	[5471] = { 23, 1, 30, nil }, -- Stag Meat
	[3770] = { 25, 1, 25, nil }, -- Mutton Chop
	[19305] = { 25, 1, 25, nil }, -- Pickled Kodo Foot
	[3712] = { 30, 1, 87, { 555, 7321 } }, -- Turtle Meat
	[12037] = { 30, 1, 87, nil }, -- Mystery Meat
	[12184] = { 30, 1, 87, nil }, -- Raptor Flesh
	[12202] = { 30, 1, 87, nil }, -- Tiger Meat
	[12203] = { 30, 1, 87, nil }, -- Red Wolf Meat
	[3404] = { 35, 1, 181, { 703 } }, -- Buzzard Wing
	[3771] = { 35, 1, 50, nil }, -- Wild Hog Shank
	[12204] = { 35, 1, 112, nil }, -- Heavy Kodo Meat
	[19224] = { 35, 1, 50, nil }, -- Red Hot Wings
	[12205] = { 40, 1, 112, nil }, -- White Spider Meat
	[12208] = { 40, 1, 150, nil }, -- Tender Wolf Meat
	[4599] = { 45, 1, 100, nil }, -- Cured Ham Steak
	[9681] = { 45, 1, 50, nil }, -- Grilled King Crawler Legs
	[19306] = { 45, 1, 100, nil }, -- Crunchy Frog
	[8952] = { 55, 1, 200, nil }, -- Roasted Quail
	[11444] = { 55, 1, 200, nil }, -- Grim Guzzler Boar
	[20424] = { 55, 1, 175, nil }, -- Sandworm Meat
	[27671] = { 60, 1, 200, nil }, -- Buzzard Meat
	[27674] = { 60, 1, 200, nil }, -- Ravager Flesh
	[27677] = { 60, 1, 200, nil }, -- Chunk o' Basilisk
	[27678] = { 60, 1, 200, nil }, -- Clefthoof Meat
	[27681] = { 60, 1, 200, nil }, -- Warped Flesh
	[27682] = { 60, 1, 200, nil }, -- Talbuk Venison
	[27854] = { 65, 1, 280, nil }, -- Smoked Talbuk Venison
	[30610] = { 65, 1, 280, nil }, -- Smoked Black Bear Meat
	[29451] = { 75, 1, 400, nil }, -- Clefthoof Ribs
	-- Fish
	[15924] = { 1, 2, 0, { 6142 } }, -- Soft-shelled Clam Meat
	[787] = { 5, 2, 1, nil }, -- Slitherskin Mackerel
	[6290] = { 5, 2, 1, nil }, -- Brilliant Smallfish
	[6291] = { 5, 2, 1, nil }, -- Raw Brilliant Smallfish
	[6303] = { 5, 2, 1, nil }, -- Raw Slitherskin Mackerel
	[2675] = { 13, 2, 11, nil }, -- Crawler Claw
	[5503] = { 14, 2, 16, nil }, -- Clam Meat
	[1326] = { 15, 2, 10, nil }, -- Sauteed Sunfish
	[2682] = { 15, 2, 25, nil }, -- Cooked Crab Claw
	[4592] = { 15, 2, 1, nil }, -- Longjaw Mud Snapper
	[5095] = { 15, 2, 3, { 8524, 8525 } }, -- Rainbow Fin Albacore
	[5468] = { 15, 2, 12, nil }, -- Soft Frenzy Flesh
	[6289] = { 15, 2, 1, nil }, -- Raw Longjaw Mud Snapper
	[6316] = { 15, 2, 3, nil }, -- Loch Frenzy Delight
	[6317] = { 15, 2, 2, nil }, -- Raw Loch Frenzy
	[6361] = { 15, 2, 2, nil }, -- Raw Rainbow Fin Albacore
	[6458] = { 15, 2, 1, nil }, -- Oil Covered Fish
	[12238] = { 15, 2, 2, { 1141 } }, -- Darkshore Grouper
	[5526] = { 20, 2, 75, nil }, -- Clam Chowder
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
	[12206] = { 40, 2, 112, nil }, -- Tender Crab Meat
	[21153] = { 40, 2, 125, nil }, -- Raw Greater Sagefish
	[4603] = { 45, 2, 4, nil }, -- Raw Spotted Yellowtail
	[6887] = { 45, 2, 5, { 8614, 8529, 8613, 8528 } }, -- Spotted Yellowtail
	[7974] = { 45, 2, 50, { 6610 } }, -- Zesty Clam Meat
	[13754] = { 45, 2, 6, nil }, -- Raw Glossy Mightfish
	[13755] = { 45, 2, 7, nil }, -- Winter Squid
	[13756] = { 45, 2, 9, nil }, -- Raw Summer Bass
	[13758] = { 45, 2, 4, nil }, -- Raw Redgill
	[13759] = { 45, 2, 10, nil }, -- Raw Nightfin Snapper
	[13760] = { 45, 2, 10, nil }, -- Raw Sunscale Salmon
	[13930] = { 45, 2, 5, nil }, -- Filet of Redgill
	[16766] = { 45, 2, 100, nil }, -- Undermine Clam Chowder
	[21552] = { 45, 2, 5, nil }, -- Striped Yellowtail
	[8957] = { 55, 2, 200, nil }, -- Spinefin Halibut
	[8959] = { 55, 2, 160, nil }, -- Raw Spinefin Halibut
	[13888] = { 55, 2, 12, nil }, -- Darkclaw Lobster
	[13889] = { 55, 2, 5, nil }, -- Raw Whitescale Salmon
	[13893] = { 55, 2, 15, nil }, -- Large Raw Mightfish
	[13933] = { 55, 2, 14, nil }, -- Lobster Stew
	[13935] = { 55, 2, 10, { 8615, 8616 } }, -- Baked Salmon
	[27422] = { 60, 2, 8, nil }, -- Barbed Gill Trout
	[27425] = { 60, 2, 8, nil }, -- Spotted Feltail
	[27429] = { 60, 2, 8, nil }, -- Zangarian Sporefish
	[27435] = { 60, 2, 8, nil }, -- Figluster's Mudfish
	[27437] = { 60, 2, 8, nil }, -- Icefin Bluefish
	[27438] = { 60, 2, 8, nil }, -- Golden Darter
	[27439] = { 60, 2, 8, nil }, -- Furious Crawdad
	[24477] = { 65, 2, 100, nil }, -- Jaggal Clam Meat
	[27661] = { 65, 2, 150, nil }, -- Blackened Trout
	[27858] = { 65, 2, 280, nil }, -- Sunspring Carp
	[29452] = { 75, 2, 400, nil }, -- Zangar Trout
	[33048] = { 75, 2, 200, nil }, -- Stewed Trout
	[33053] = { 75, 2, 200, nil }, -- Hot Buttered Trout
	-- Bread
	[4540] = { 5, 3, 1, nil }, -- Tough Hunk of Bread
	[5349] = { 5, 3, 0, nil }, -- Conjured Muffin
	[20857] = { 5, 3, 1, nil }, -- Honey Bread
	[30816] = { 5, 3, 5, nil }, -- Spice Bread
	[30817] = { 5, 3, 1, nil }, -- Simple Flour
	[1113] = { 15, 3, 0, nil }, -- Conjured Bread
	[4541] = { 15, 3, 6, nil }, -- Freshly Baked Bread
	[1114] = { 25, 3, 0, nil }, -- Conjured Rye
	[4542] = { 25, 3, 25, nil }, -- Moist Cornbread
	[1487] = { 35, 3, 0, nil }, -- Conjured Pumpernickel
	[4544] = { 35, 3, 50, nil }, -- Mulgore Spice Bread
	[16169] = { 35, 3, 62, nil }, -- Wild Ricecake
	[4601] = { 45, 3, 100, nil }, -- Soft Banana Bread
	[8075] = { 45, 3, 0, nil }, -- Conjured Sourdough
	[8076] = { 55, 3, 0, nil }, -- Conjured Sweet Roll
	[23160] = { 55, 3, 200, nil }, -- Friendship Bread
	[22895] = { 65, 3, 0, nil }, -- Conjured Cinnamon Roll
	[27855] = { 65, 3, 280, nil }, -- Mag'har Grainbread
	[28486] = { 65, 3, 280, nil }, -- Moser's Magnificent Muffin
	[22019] = { 75, 3, 0, nil }, -- Conjured Croissant
	[29394] = { 75, 3, 400, nil }, -- Lyribread
	[29449] = { 75, 3, 400, nil }, -- Bladespire Bagel
	-- Cheese
	[2070] = { 5, 4, 1, nil }, -- Darnassian Bleu
	[414] = { 15, 4, 6, nil }, -- Dalaran Sharp
	[17406] = { 15, 4, 6, nil }, -- Holiday Cheesewheel
	[422] = { 25, 4, 25, nil }, -- Dwarven Mild
	[1707] = { 35, 4, 62, nil }, -- Stormwind Brie
	[3927] = { 45, 4, 150, nil }, -- Fine Aged Cheddar
	[8932] = { 55, 4, 200, { 6610 } }, -- Alterac Swiss
	[27857] = { 65, 4, 280, nil }, -- Garadar Sharp
	[30458] = { 65, 4, 280, nil }, -- Stromgarde Muenster
	[29448] = { 75, 4, 400, nil }, -- Mag'har Mild Cheese
	-- Fruit
	[4536] = { 5, 5, 1, nil }, -- Shiny Red Apple
	[4656] = { 5, 5, 1, nil }, -- Small Pumpkin
	[5057] = { 5, 5, 1, nil }, -- Ripe Watermelon
	[4537] = { 15, 5, 6, nil }, -- Tel'Abim Banana
	[24072] = { 15, 5, 6, nil }, -- Sand Pear Pie
	[4538] = { 25, 5, 25, nil }, -- Snapvine Watermelon
	[4539] = { 35, 5, 50, nil }, -- Goldenbark Apple
	[4602] = { 45, 5, 100, nil }, -- Moon Harvest Pumpkin
	[16168] = { 45, 5, 100, nil }, -- Heaven Peach
	[21030] = { 45, 5, 100, nil }, -- Darnassus Kimchi Pie
	[8950] = { 55, 3, 200, nil }, -- Homemade Cherry Pie (bread, diet 3: the database files it as fruit)
	[8953] = { 55, 5, 200, nil }, -- Deep Fried Plantains
	[21031] = { 55, 5, 200, nil }, -- Cabbage Kimchi
	[21033] = { 55, 5, 200, nil }, -- Radish Kimchi
	[27856] = { 65, 5, 280, nil }, -- Skethyl Berries
	[29393] = { 65, 5, 280, nil }, -- Diamond Berries
	[29450] = { 75, 5, 400, nil }, -- Telaari Grapes
	-- Fungus
	[4604] = { 5, 6, 1, nil }, -- Forest Mushroom Cap
	[3448] = { 15, 6, 6, nil }, -- Senggin Root
	[4605] = { 15, 6, 6, nil }, -- Red-speckled Mushroom
	[4606] = { 25, 6, 25, nil }, -- Spongy Morel
	[4607] = { 35, 6, 50, nil }, -- Delicious Cave Mold
	[4608] = { 45, 6, 100, nil }, -- Raw Black Truffle
	[8948] = { 55, 6, 200, nil }, -- Dried King Bolete
	[27859] = { 65, 6, 280, nil }, -- Zangar Caps
	[29453] = { 75, 6, 400, nil }, -- Sporeggar Mushroom
	-- Underspore Pod (28112) is deliberately absent; it sells for nothing, so Feed Pet would spend it before ordinary food.
}
