local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

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
		-- {Spell ID, Conjured Item Usage Level}, -- Conjured Item
		{ 11730, 48 }, -- Major Healthstone
		{ 11729, 36 }, -- Greater Healthstone
		{ 5699, 24 }, -- Healthstone
		{ 6202, 12 }, -- Lesser Healthstone
		{ 6201, 1 }, -- Minor Healthstone
	},
	WarlockCreateSoulstone = {
		-- {Spell ID, Spell Learn Level}, -- Conjured Item (Max Target Level)
		{ 20757, 60 }, -- Major Soulstone (max target level 70)
		{ 20756, 50 }, -- Greater Soulstone (max target level 60)
		{ 20755, 40 }, -- Soulstone (max target level 50)
		{ 20752, 30 }, -- Lesser Soulstone (max target level 40)
		{ 693, 18 }, -- Minor Soulstone (max target level 30)
	},
}

ns.MISSING_SPELL_MESSAGE_IDS = {
	-- Mage conjures
	noConjureWater = 5504, -- Conjure Water (rank 1)
	noConjureFood = 587, -- Conjure Food (rank 1)
	noConjureManaGem = 759, -- Conjure Mana Agate
	-- Warlock conjures
	noCreateHealthstone = 6201, -- Create Healthstone (Minor)
	noCreateSoulstone = 693, -- Create Soulstone (Minor)
	-- Rogue poisons
	noPoisonsSkill = 2842, -- Poisons (the rogue poison-crafting skill)
}

--[[
How We Got the Data

Last Validated
	2026-10-16, Classic Era 1.15.9.70003

Notes
	- The mage and warlock conjure spells the macros cast, one list per conjure, read by Features/Macros/Smart-Spell.lua (GetSmartSpell), the Food and Water macros, the class tools, the Readiness Report and the mini-map tooltip. Smart-Spell sorts each list by its level column, highest first, at load, so row order carries no meaning.
	- The level column is the level needed to use the conjured item, not the level the spell is learned (Create Healthstone rank 1 is learned at 10, but its stone is usable at level 1). GetSmartSpell compares it against the player's level, or a friendly target's, so the macro downranks to an item the recipient can use. For lists that never downrank by target (Mana Gems, Soulstones) and the rituals (Ritual of Refreshment, Ritual of Souls), it is simply the spell's learn level.
	- The rank column, where present, is the spell's own rank, not its position in the list: the /cast line becomes "Spell Name(Rank N)" with the client's own rank text, pinning that rank. It is left off where every row already has a unique spell name, as each Mana Gem tier does.
	- RECURRING BUG (WarlockCreateHealthstone and WarlockCreateSoulstone; it has broken Era three times). On the Classic Era client each warlock stone tier is its own distinctly-named spell, so C_Spell.GetSpellName already returns the full name ("Create Healthstone (Minor)"). It must be cast bare: appending "(Rank N)" yields "Create Healthstone (Minor)(Rank 1)", a spell that does not exist, and the /cast silently does nothing. That is why these stone rows carry no rank, while the TBC and WoW Forever folders' rows do. Mage Conjure Water and Food ARE numeric-rank on every client, so their rank column is right everywhere: never "simplify" the two spell families together, and never copy stone rows between folders without adding or dropping the rank.
	- Soulstone rows name their max target level in the trailing comment: a soulstone can't be used on a player above that level. It needs no selection logic, since the caps rise with rank and casting the best known rank always satisfies the cap. The Soulstone resolver passes ignoreTarget, which is why that list's level column is the learn level.
	- ns.MISSING_SPELL_MESSAGE_IDS holds the spells ConnoisseurTip names at print time (Features/Macros/Runtime.lua): one per conjure list that has rows, taken from its rank-1 entry, plus the rogue's Poisons skill, which is not a conjure.
	- Conjure Water rank 8 (468766), which makes Season of Discovery's Mountain Spring Water, is left out; it lives only in Data/Discovery/.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=1.15.9.70003
	https://wago.tools/db2/Spell?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
	https://wago.tools/db2/SpellLevels?build=1.15.9.70003
	https://wago.tools/db2/SkillLineAbility?build=1.15.9.70003

QuestieDB
	None.
]]
