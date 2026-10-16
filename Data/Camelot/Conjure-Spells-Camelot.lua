local _, ns = ...

ns.CONJURE_SPELLS = {
	MageCreateTable = {
		-- {Spell ID, Spell Learn Level}
	},
	MageCreateWater = {
		-- {Spell ID, Conjured Item Usage Level, Spell Rank}, -- Conjured Item
		{ 10140, 55, 7 }, -- Conjured Crystal Water
		{ 10139, 45, 6 }, -- Conjured Sparkling Water
		{ 10138, 35, 5 }, -- Conjured Mineral Water
		{ 6127, 25, 4 }, -- Conjured Spring Water
		{ 5506, 15, 3 }, -- Conjured Purified Water
		{ 5505, 5, 2 }, -- Conjured Fresh Water
		{ 5504, 1, 1 }, -- Conjured Water
	},
	MageCreateFood = {
		-- {Spell ID, Conjured Item Usage Level, Spell Rank}, -- Conjured Item
		{ 28612, 55, 7 }, -- Conjured Cinnamon Roll
		{ 10145, 45, 6 }, -- Conjured Sweet Roll
		{ 10144, 35, 5 }, -- Conjured Sourdough
		{ 6129, 25, 4 }, -- Conjured Pumpernickel
		{ 990, 15, 3 }, -- Conjured Rye
		{ 597, 5, 2 }, -- Conjured Bread
		{ 587, 1, 1 }, -- Conjured Muffin
	},
	MageCreateManaGem = {
		-- {Spell ID, Spell Learn Level}, -- Spell Name
		{ 10054, 58 }, -- Conjure Mana Ruby
		{ 10053, 48 }, -- Conjure Mana Citrine
		{ 3552, 38 }, -- Conjure Mana Jade
		{ 759, 28 }, -- Conjure Mana Agate
	},
	WarlockCreateSoulwell = {
		-- {Spell ID, Spell Learn Level}
	},
	WarlockCreateHealthstone = {
		-- {Spell ID, Conjured Item Usage Level, Spell Rank}, -- Conjured Item
		{ 11730, 48, 5 }, -- Major Healthstone
		{ 11729, 36, 4 }, -- Greater Healthstone
		{ 5699, 24, 3 }, -- Healthstone
		{ 6202, 12, 2 }, -- Lesser Healthstone
		{ 6201, 1, 1 }, -- Minor Healthstone
	},
	WarlockCreateSoulstone = {
		-- {Spell ID, Spell Learn Level}, -- Conjured Item
		{ 20757, 60 }, -- Major Soulstone
		{ 20756, 50 }, -- Greater Soulstone
		{ 20755, 40 }, -- Soulstone
		{ 20752, 30 }, -- Lesser Soulstone
		{ 693, 18 }, -- Minor Soulstone
	},
}

ns.MISSING_SPELL_MESSAGE_IDS = {
	-- Mage conjures
	noConjureWater = 5504, -- Conjure Water (rank 1)
	noConjureFood = 587, -- Conjure Food (rank 1)
	noConjureManaGem = 759, -- Conjure Mana Agate
	-- Warlock conjures
	noCreateHealthstone = 6201, -- Create Healthstone (rank 1)
	noCreateSoulstone = 693, -- Create Soulstone (rank 1)
	-- Rogue poisons
	noPoisonsSkill = 2842, -- Poisons (the rogue poison-crafting skill)
}

--[[
How We Got the Data

Last Validated
	2026-10-16, WoW Forever 1.60.1.70425

Notes
	- The mage and warlock conjure spells the macros cast, one list per conjure, read by Features/Macros/Smart-Spell.lua (GetSmartSpell), the Food and Water macros, the class tools, the Readiness Report and the mini-map tooltip. Smart-Spell sorts each list by its level column, highest first, at load, so row order carries no meaning.
	- The level column is the level needed to use the conjured item, not the level the spell is learned (Create Healthstone rank 1 is learned at 10, but its stone is usable at level 1). GetSmartSpell compares it against the player's level, or a friendly target's, so the macro downranks to an item the recipient can use. For lists that never downrank by target (Mana Gems, Soulstones) and the rituals (Ritual of Refreshment, Ritual of Souls), it is simply the spell's learn level.
	- The rank column, where present, is the spell's own rank, not its position in the list: the /cast line becomes "Spell Name(Rank N)" with the client's own rank text, pinning that rank. It is left off where every row already has a unique spell name, as each Mana Gem tier does.
	- RECURRING BUG (WarlockCreateHealthstone; it has broken Era three times). On WoW Forever the warlock stones are one spell with numeric ranks, as in the TBC folder: every rank is named "Create Healthstone" and is cast as "Create Healthstone(Rank N)", so these rows carry the rank. The Classic Era folders' rows carry none: there each tier is its own distinctly-named spell ("Create Healthstone (Minor)") that must be cast bare, because appending "(Rank N)" builds a spell that does not exist and the /cast silently does nothing. Never copy rows between the two without adding or dropping the rank column. Mage Conjure Water and Food ARE numeric-rank on every client: never "simplify" the two spell families together.
	- The Soulstone list carries no rank, though this client also numbers Create Soulstone's ranks: the resolver ignores the target and always wants the best stone, and a bare /cast already fires the best rank the warlock knows. Its level column is the learn level.
	- ns.MISSING_SPELL_MESSAGE_IDS holds the spells ConnoisseurTip names at print time (Features/Macros/Runtime.lua): one per conjure list that has rows, taken from its rank-1 entry, plus the rogue's Poisons skill, which is not a conjure.
	- Conjure Water rank 8 (468766), which makes Season of Discovery's Mountain Spring Water, is left out; it lives only in Data/Discovery/.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=1.60.1.70425
	https://wago.tools/db2/Spell?build=1.60.1.70425
	https://wago.tools/db2/SpellEffect?build=1.60.1.70425
	https://wago.tools/db2/SpellLevels?build=1.60.1.70425
	https://wago.tools/db2/SkillLineAbility?build=1.60.1.70425
]]
