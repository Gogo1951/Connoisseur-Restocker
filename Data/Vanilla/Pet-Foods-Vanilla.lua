local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- [itemID] = { itemLevel, dietID, sellPrice, questIDs or nil }, -- Name
ns.PET_FOOD_DATA = {
	-- Meat
	[4739] = { 1, 1, 0, { 747 } }, -- Plainstrider Meat
	[5051] = { 1, 1, 1, { 862 } }, -- Dig Rat
	[117] = { 5, 1, 1, nil }, -- Tough Jerky
	[769] = { 5, 1, 3, { 86, 317 } }, -- Chunk of Boar Meat
	[2672] = { 5, 1, 4, nil }, -- Stringy Wolf Meat
	[2679] = { 5, 1, 5, nil }, -- Charred Wolf Meat
	[2886] = { 5, 1, 5, { 384 } }, -- Crag Boar Rib
	[5465] = { 5, 1, 3, { 4161 } }, -- Small Spider Leg
	[7097] = { 5, 1, 1, nil }, -- Leg Meat
	[12223] = { 5, 1, 4, nil }, -- Meaty Bat Wing
	[19223] = { 5, 1, 1, nil }, -- Darkmoon Dog
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
	-- Bread
	[4540] = { 5, 3, 1, nil }, -- Tough Hunk of Bread
	[5349] = { 5, 3, 0, nil }, -- Conjured Muffin
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
	-- Cheese
	[2070] = { 5, 4, 1, nil }, -- Darnassian Bleu
	[414] = { 15, 4, 6, nil }, -- Dalaran Sharp
	[17406] = { 15, 4, 6, nil }, -- Holiday Cheesewheel
	[422] = { 25, 4, 25, nil }, -- Dwarven Mild
	[1707] = { 35, 4, 62, nil }, -- Stormwind Brie
	[3927] = { 45, 4, 150, nil }, -- Fine Aged Cheddar
	[8932] = { 55, 4, 200, { 6610 } }, -- Alterac Swiss
	-- Fruit
	[4536] = { 5, 5, 1, nil }, -- Shiny Red Apple
	[4656] = { 5, 5, 1, nil }, -- Small Pumpkin
	[5057] = { 5, 5, 1, nil }, -- Ripe Watermelon
	[4537] = { 15, 5, 6, nil }, -- Tel'Abim Banana
	[4538] = { 25, 5, 25, nil }, -- Snapvine Watermelon
	[4539] = { 35, 5, 50, nil }, -- Goldenbark Apple
	[4602] = { 45, 5, 100, nil }, -- Moon Harvest Pumpkin
	[16168] = { 45, 5, 100, nil }, -- Heaven Peach
	[21030] = { 45, 5, 100, nil }, -- Darnassus Kimchi Pie
	[8950] = { 55, 3, 200, nil }, -- Homemade Cherry Pie (bread, diet 3: the database files it as fruit)
	[8953] = { 55, 5, 200, nil }, -- Deep Fried Plantains
	[21031] = { 55, 5, 200, nil }, -- Cabbage Kimchi
	[21033] = { 55, 5, 200, nil }, -- Radish Kimchi
	-- Fungus
	[4604] = { 5, 6, 1, nil }, -- Forest Mushroom Cap
	[3448] = { 15, 6, 6, nil }, -- Senggin Root
	[4605] = { 15, 6, 6, nil }, -- Red-speckled Mushroom
	[4606] = { 25, 6, 25, nil }, -- Spongy Morel
	[4607] = { 35, 6, 50, nil }, -- Delicious Cave Mold
	[4608] = { 45, 6, 100, nil }, -- Raw Black Truffle
	[8948] = { 55, 6, 200, nil }, -- Dried King Bolete
}

--[[
How We Got the Data

Last Validated
	2026-10-16, Classic Era 1.15.9.70003

Notes
	- The foods a hunter's pet eats, for Feed Pet support (Features/Macros/Tools-Hunters-Pet-Food.lua). Diet IDs follow ns.PET_DIET_MAP in Data/Data.lua: 1 Meat, 2 Fish, 3 Bread, 4 Cheese, 5 Fruit, 6 Fungus.
	- itemLevel is the item level, which decides how happy the food keeps a pet of a given level: Feed Pet takes the lowest-level food that still gives full happiness, then the cheapest, then the one with the fewest in the bags. sellPrice is the vendor sell value per unit in copper. questIDs lists the quests that take the item as an objective, or nil; every row's list matches QuestieDB's Classic quest table.
	- Left out on purpose: foods Feed Pet would waste, even where the client gives them a pet diet. That is special foods that sell for nothing (Whipper Root Tuber, Essence Mango, holiday foods) and battleground or zone rations. Feed Pet feeds the cheapest food first, so it would spend those before ordinary food.
	- Foods that give the player a Well Fed buff are left out on purpose, on every client: they are cooked or bought for the player, and Feed Pet must never eat them. Raw meat and fish and plain food feed the pet. Pet buff foods (Sporeling Snack, Kibler's Bits) are a separate list, ns.PET_BUFF_FOODS in Game-IDs-Vanilla.lua; no client capped at level 60 has any.
	- This client's tables carry no pet diet, so diets come from the database query below (with ns.PET_DIET_MAP's numbering, not FoodType's) and can't be checked against the client.
	- Season of Discovery items are left out even though this client knows their IDs: they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

SQL (CMaNGOS)
	Database not recorded.

	SELECT entry, name, ItemLevel, FoodType, SellPrice
	FROM item_template
	WHERE class = 0 AND subclass = 5 AND FoodType > 0
	ORDER BY FoodType, ItemLevel, entry;

	Quest objective IDs come from quest_template (RequiredItemId1-6).

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.15.9.70003
	https://wago.tools/db2/ItemSparse?build=1.15.9.70003
	https://wago.tools/db2/ItemEffect?build=1.15.9.70003
	https://wago.tools/db2/Spell?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
	https://wago.tools/db2/SpellMisc?build=1.15.9.70003
	https://wago.tools/db2/SpellDuration?build=1.15.9.70003

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/Classic/classicQuestDB.lua
]]
