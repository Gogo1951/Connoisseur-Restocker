local _, ns = ...

--------------------------------------------------------------------------------
-- Scroll Data
--------------------------------------------------------------------------------

--[[
    Source: copied from Data/TBC/Scrolls-TBC.lua until Validate Data passes on
    this client.
]]
-- TODO: Add SQL Query
-- [scrollType] = { items = { ... }, conflictSpells = { ... } }
ns.SCROLL_DATA = {
	Agility = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27498, 33077, 60, 20 }, -- Scroll of Agility V
			{ 10309, 12174, 55, 17 }, -- Scroll of Agility IV
			{ 4425, 8117, 40, 13 }, -- Scroll of Agility III
			{ 1477, 8116, 25, 9 }, -- Scroll of Agility II
			{ 3012, 8115, 10, 5 }, -- Scroll of Agility
		},
		-- Stacks with everything in Classic/TBC
		-- [spellID] = amount, -- Name
		conflictSpells = {},
	},
	Intellect = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27499, 33078, 60, 20 }, -- Scroll of Intellect V
			{ 10308, 12176, 50, 16 }, -- Scroll of Intellect IV
			{ 4419, 8098, 35, 12 }, -- Scroll of Intellect III
			{ 2290, 8097, 20, 8 }, -- Scroll of Intellect II
			{ 955, 8096, 5, 4 }, -- Scroll of Intellect
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[27127] = 40, -- Arcane Brilliance (Rank 2)
			[27126] = 40, -- Arcane Intellect (Rank 6)
			[23028] = 31, -- Arcane Brilliance (Rank 1)
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
			{ 27500, 33079, 60, 300 }, -- Scroll of Protection V
			{ 10305, 12175, 45, 240 }, -- Scroll of Protection IV
			{ 4421, 8095, 30, 180 }, -- Scroll of Protection III
			{ 1478, 8094, 15, 120 }, -- Scroll of Protection II
			{ 3013, 8091, 1, 60 }, -- Scroll of Protection
		},
		-- Stacks with Devotion Aura, Stoneskin, etc. in Classic/TBC
		-- [spellID] = amount, -- Name
		conflictSpells = {},
	},
	Stamina = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27502, 33081, 60, 20 }, -- Scroll of Stamina V
			{ 10307, 12178, 50, 16 }, -- Scroll of Stamina IV
			{ 4422, 8101, 35, 12 }, -- Scroll of Stamina III
			{ 1711, 8100, 20, 8 }, -- Scroll of Stamina II
			{ 1180, 8099, 5, 4 }, -- Scroll of Stamina
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[25389] = 79, -- Power Word: Fortitude (Rank 7)
			[25392] = 79, -- Prayer of Fortitude (Rank 3)
			[10938] = 54, -- Power Word: Fortitude (Rank 6)
			[21564] = 54, -- Prayer of Fortitude (Rank 2)
			[10937] = 43, -- Power Word: Fortitude (Rank 5)
			[21562] = 43, -- Prayer of Fortitude (Rank 1)
			[2791] = 32, -- Power Word: Fortitude (Rank 4)
			[1245] = 20, -- Power Word: Fortitude (Rank 3)
			[1244] = 8, -- Power Word: Fortitude (Rank 2)
			[1243] = 3, -- Power Word: Fortitude (Rank 1)
		},
	},
	Spirit = {
		-- {itemID, buffID, requiredLevel, amount}, -- Name
		items = {
			{ 27501, 33080, 60, 30 }, -- Scroll of Spirit V
			{ 10306, 12177, 45, 15 }, -- Scroll of Spirit IV
			{ 4424, 8114, 30, 11 }, -- Scroll of Spirit III
			{ 1712, 8113, 15, 7 }, -- Scroll of Spirit II
			{ 1181, 8112, 1, 3 }, -- Scroll of Spirit
		},
		-- [spellID] = amount, -- Name
		conflictSpells = {
			[25312] = 50, -- Divine Spirit (Rank 5)
			[32999] = 50, -- Prayer of Spirit (Rank 2)
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
			{ 27503, 33082, 60, 20 }, -- Scroll of Strength V
			{ 10310, 12179, 55, 17 }, -- Scroll of Strength IV
			{ 4426, 8120, 40, 13 }, -- Scroll of Strength III
			{ 2289, 8119, 25, 9 }, -- Scroll of Strength II
			{ 954, 8118, 10, 5 }, -- Scroll of Strength
		},
		-- Stacks with everything in Classic/TBC
		-- [spellID] = amount, -- Name
		conflictSpells = {},
	},
}
