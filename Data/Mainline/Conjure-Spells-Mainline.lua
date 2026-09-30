local _, ns = ...

--------------------------------------------------------------------------------
-- Mage and Warlock Spells
--------------------------------------------------------------------------------

--[[
    Source: copied from Data/Wrath/Conjure-Spells-Wrath.lua: the rows a Wrath
    client loaded from the pre-split shared tables, until a Mainline TOC ships
    and Validate Data runs there.
]]

--[[
    Conjure spell lists. Features/Macros/Smart-Spell.lua sorts each by requiredLevel,
    highest first, at load, so row order carries no meaning. Each entry is:

        { spellID, requiredLevel[, rankNumber][, maxTargetLevel] }

    spellID        The conjure spell the macro /casts.
    requiredLevel  The level needed to USE the conjured item — not the
                   level the spell is learned (Create Healthstone (Minor)
                   is learned at 6, but its stone is usable at level 1).
                   GetSmartSpell compares this against the player's level
                   — or a friendly target's level — so the macro downranks
                   to conjure an item the recipient can actually use. For
                   lists that never downrank by target (Mana Gems,
                   Soulstones) and the ritual utilities (Refreshment
                   Table, Ritual of Souls), it is simply the spell's
                   learn level.
    rankNumber     Optional. When present, the /cast line is written as
                   "Spell Name(Rank N)" to pin that exact rank. Omitted
                   where every entry already has a unique spell name
                   (each Mana Gem tier is its own spell). The warlock
                   stones carry it here and in none of the Classic Era
                   folders: see the RECURRING BUG note on
                   WarlockCreateHealthstone.
    maxTargetLevel Optional, documentation only (Soulstones) — every
                   consumer (GetSmartSpell, KnowsAny, the conjure-spell
                   cache) reads only the first three fields.
]]
ns.CONJURE_SPELLS = {
	MageCreateTable = {
		-- {Spell ID, Spell Learn Level}
		{ 58659, 80 }, -- Ritual of Refreshment, Rank 2
		{ 43987, 70 }, -- Ritual of Refreshment, Rank 1
	},
	MageCreateWater = {
		-- {Spell ID, Conjured Item Usage Level, Spell Rank}, -- Conjured Item
		--[[
		    Conjure Refreshment (Wrath) makes items that are food AND water,
		    so its two ranks lead both lists. The rank column is the spell's
		    own rank, not its position here.
		]]
		{ 42956, 80, 2 }, -- Conjured Mana Strudel (Conjure Refreshment, Rank 2)
		{ 42955, 74, 1 }, -- Conjured Mana Pie (Conjure Refreshment, Rank 1)
		{ 27090, 65, 9 }, -- Conjured Glacier Water
		{ 37420, 60, 8 }, -- Conjured Mountain Spring Water
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
		--[[
		    Conjure Refreshment (Wrath) makes items that are food AND water,
		    so its two ranks lead both lists. The rank column is the spell's
		    own rank, not its position here.
		]]
		{ 42956, 80, 2 }, -- Conjured Mana Strudel (Conjure Refreshment, Rank 2)
		{ 42955, 74, 1 }, -- Conjured Mana Pie (Conjure Refreshment, Rank 1)
		{ 33717, 65, 8 }, -- Conjured Croissant
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
		{ 42985, 77 }, -- Conjure Mana Sapphire
		{ 27101, 68 }, -- Conjure Mana Emerald
		{ 10054, 58 }, -- Conjure Mana Ruby
		{ 10053, 48 }, -- Conjure Mana Citrine
		{ 3552, 38 }, -- Conjure Mana Jade
		{ 759, 28 }, -- Conjure Mana Agate
	},
	WarlockCreateSoulwell = {
		-- {Spell ID, Spell Learn Level}
		{ 58887, 80 }, -- Ritual of Souls, Rank 2
		{ 29893, 68 }, -- Ritual of Souls, Rank 1
	},
	WarlockCreateHealthstone = {
		--[[
		    RECURRING BUG — this has broken Era three times; read before
		    touching this table, WarlockCreateSoulstone, or GetSmartSpell.
		    On TBC the warlock stones are one spell with numeric ranks, cast
		    as "Create Healthstone(Rank N)", so these rows carry the rank.
		    The Classic Era folders' rows carry none: there each tier is its
		    own distinctly-named spell ("Create Healthstone (Minor)") that
		    must be cast bare, because appending "(Rank N)" builds a spell
		    that does not exist and the /cast silently no-ops. Never copy
		    rows between the two without adding or dropping the rank column.
		    Mage Conjure Water/Food ARE numeric-rank on every client — do not
		    "simplify" the two spell families together.
		]]
		-- {Spell ID, Conjured Item Usage Level, Spell Rank}, -- Conjured Item
		{ 47878, 69, 8 }, -- Fel Healthstone
		{ 47871, 63, 7 }, -- Demonic Healthstone
		{ 27230, 60, 6 }, -- Master Healthstone
		{ 11730, 48, 5 }, -- Major Healthstone
		{ 11729, 36, 4 }, -- Greater Healthstone
		{ 5699, 24, 3 }, -- Healthstone
		{ 6202, 12, 2 }, -- Lesser Healthstone
		{ 6201, 1, 1 }, -- Minor Healthstone
	},
	WarlockCreateSoulstone = {
		--[[
		    Max Target Level: a soulstone cannot be used on players ABOVE
		    that level. It needs no selection logic — the caps rise with
		    rank, so casting the best known rank always satisfies the cap.
		    The resolver passes ignoreTarget=true, which is why the second
		    column is the learn level rather than an item usage level.

		    The rank column follows the same split as Healthstones: see the
		    RECURRING BUG note on WarlockCreateHealthstone above.
		]]
		-- {Spell ID, Spell Learn Level, Spell Rank, Max Target Level}, -- Conjured Item
		{ 47884, 76, 7, 80 }, -- Demonic Soulstone
		{ 27238, 70, 6, 80 }, -- Master Soulstone
		{ 20757, 60, 5, 70 }, -- Major Soulstone
		{ 20756, 50, 4, 60 }, -- Greater Soulstone
		{ 20755, 40, 3, 50 }, -- Soulstone
		{ 20752, 30, 2, 40 }, -- Lesser Soulstone
		{ 693, 18, 1, 30 }, -- Minor Soulstone
	},
}

--[[
    Spell IDs that ConnoisseurTip resolves at print time: one per conjure table
    in ns.CONJURE_SPELLS above, taken from its rank-1 entry, plus the Rogue's
    Poisons skill, which is not a conjure.
]]
ns.MISSING_SPELL_MESSAGE_IDS = {
	-- Mage conjures
	noConjureWater = 5504, -- Conjure Water (rank 1)
	noConjureFood = 587, -- Conjure Food (rank 1)
	noConjureManaGem = 759, -- Conjure Mana Agate
	noRitualOfRefreshment = 43987, -- Ritual of Refreshment
	-- Warlock conjures
	noCreateHealthstone = 6201, -- Create Healthstone (Minor)
	noCreateSoulstone = 693, -- Create Soulstone (Minor)
	noRitualOfSouls = 29893, -- Ritual of Souls
	-- Rogue poisons
	noPoisonsSkill = 2842, -- Poisons (the rogue poison-crafting skill)
}
