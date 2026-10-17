local _, ns = ...

-- [scrollType] = { items = { ... }, conflictSpells = { ... } }
ns.SCROLL_DATA = {
	Agility = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 10309, 12174, 55, 17 }, -- Scroll of Agility IV
			{ 4425, 8117, 40, 13 }, -- Scroll of Agility III
			{ 1477, 8116, 25, 9 }, -- Scroll of Agility II
			{ 3012, 8115, 10, 5 }, -- Scroll of Agility
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {},
	},
	Intellect = {
		-- {itemID, buffID, requiredLevel, amount, class token or nil}, -- Name
		items = {
			{ 10308, 12176, 50, 16 }, -- Scroll of Intellect IV
			{ 4419, 8098, 35, 12 }, -- Scroll of Intellect III
			{ 277493, 1302303, 25, 12, "MAGE" }, -- Scroll of Cat Familiar
			{ 2290, 8097, 20, 8 }, -- Scroll of Intellect II
			{ 277483, 1302285, 16, 6, "MAGE" }, -- Scroll of Frog Familiar
			{ 955, 8096, 5, 4 }, -- Scroll of Intellect
			{ 275069, 1296202, 5, 2, "MAGE" }, -- Scroll of Rat Familiar
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[23028] = 31, -- Arcane Brilliance
			[10157] = 31, -- Arcane Intellect (Rank 5)
			[10156] = 22, -- Arcane Intellect (Rank 4)
			[1461] = 15, -- Arcane Intellect (Rank 3)
			[1460] = 7, -- Arcane Intellect (Rank 2)
			[1459] = 2, -- Arcane Intellect (Rank 1)
		},
	},
	Protection = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 10305, 12175, 45, 240 }, -- Scroll of Protection IV
			{ 4421, 8095, 30, 180 }, -- Scroll of Protection III
			{ 1478, 8094, 15, 120 }, -- Scroll of Protection II
			{ 3013, 8091, 1, 60 }, -- Scroll of Protection
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {},
	},
	Stamina = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 10307, 12178, 50, 16 }, -- Scroll of Stamina IV
			{ 4422, 8101, 35, 12 }, -- Scroll of Stamina III
			{ 1711, 8100, 20, 8 }, -- Scroll of Stamina II
			{ 1180, 8099, 5, 4 }, -- Scroll of Stamina
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[10938] = 70, -- Power Word: Fortitude (Rank 6)
			[21564] = 70, -- Prayer of Fortitude (Rank 2)
			[10937] = 56, -- Power Word: Fortitude (Rank 5)
			[21562] = 56, -- Prayer of Fortitude (Rank 1)
			[2791] = 42, -- Power Word: Fortitude (Rank 4)
			[1245] = 26, -- Power Word: Fortitude (Rank 3)
			[1244] = 10, -- Power Word: Fortitude (Rank 2)
			[1243] = 4, -- Power Word: Fortitude (Rank 1)
		},
	},
	Spirit = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 10306, 12177, 45, 15 }, -- Scroll of Spirit IV
			{ 4424, 8114, 30, 11 }, -- Scroll of Spirit III
			{ 1712, 8113, 15, 7 }, -- Scroll of Spirit II
			{ 1181, 8112, 1, 3 }, -- Scroll of Spirit
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[27841] = 40, -- Divine Spirit (Rank 4)
			[27681] = 40, -- Prayer of Spirit (Rank 1)
			[14819] = 33, -- Divine Spirit (Rank 3)
			[14818] = 23, -- Divine Spirit (Rank 2)
			[14752] = 17, -- Divine Spirit (Rank 1)
		},
	},
	Strength = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 10310, 12179, 55, 17 }, -- Scroll of Strength IV
			{ 4426, 8120, 40, 13 }, -- Scroll of Strength III
			{ 2289, 8119, 25, 9 }, -- Scroll of Strength II
			{ 954, 8118, 10, 5 }, -- Scroll of Strength
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {},
	},
}

--[[
How We Got the Data

Last Validated
	2026-10-16, WoW Forever 1.60.1.70450

Notes
	- The stat scrolls, read by Features/Scanner-Auras.lua (FindBestScroll) to pick a scroll whose buff the player lacks. Each type lists its scrolls as { itemID, buffID, requiredLevel, amount }: the buff is the aura the scroll leaves, requiredLevel the level the tooltip requires, amount the stat it grants.
	- conflictSpells lists the class buffs a scroll can't stack with, keyed by spell ID, with the amount each grants; a scroll is skipped while the player has a conflicting buff at least as strong. Agility, Protection and Strength list none: Agility stacks with everything on the Classic and TBC clients, and Protection with Devotion Aura, Stoneskin and the like.
	- The three Mage familiar scrolls carry a fifth column, the class that can use them (MAGE), because they don't bind and another class could carry one. Each one's buff is its use spell, which summons the familiar and puts the Intellect aura on the caster. Whether that aura stacks with Scroll of Intellect or Arcane Intellect is unchecked in game; counting them as one Intellect buff never builds a line that fails.
	- WoW Forever raised Power Word: Fortitude and Prayer of Fortitude (4/10/26/42/56/70 by rank); the conflict amounts follow.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.60.1.70450
	https://wago.tools/db2/ItemSparse?build=1.60.1.70450
	https://wago.tools/db2/ItemEffect?build=1.60.1.70450
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70450
	https://wago.tools/db2/Spell?build=1.60.1.70450
	https://wago.tools/db2/SpellEffect?build=1.60.1.70450
	https://wago.tools/db2/SpellMisc?build=1.60.1.70450
	https://wago.tools/db2/SpellDuration?build=1.60.1.70450

QuestieDB
	None.
]]
