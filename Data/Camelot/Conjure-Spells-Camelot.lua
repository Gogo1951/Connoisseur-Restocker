local _, ns = ...

--------------------------------------------------------------------------------
-- Mage and Warlock Spells
--------------------------------------------------------------------------------

--[[
    Source: copied from Data/Vanilla/Conjure-Spells-Vanilla.lua until Validate
    Data passes on this client.
]]

--[[
    Conjure spell lists. Features/Macros/Smart-Spell.lua sorts each by requiredLevel,
    highest first, at load, so row order carries no meaning. Each entry is:

        { spellID, requiredLevel[, rankNumber] }

    spellID        The conjure spell the macro /casts.
    requiredLevel  The level needed to USE the conjured item — not the
                   level the spell is learned (Create Healthstone Rank 1
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
                   where every entry already has a unique spell name (each
                   Mana Gem tier is its own spell) and where the best known
                   rank is always wanted (see the note on
                   WarlockCreateSoulstone).
]]
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
		--[[
		    RECURRING BUG — this has broken Era three times; read before
		    touching this table, WarlockCreateSoulstone, or GetSmartSpell.
		    On WoW Forever the warlock stones are one spell with numeric
		    ranks, as in the TBC folder: every rank is named "Create
		    Healthstone" and is cast as "Create Healthstone(Rank N)", so
		    these rows carry the rank. The Classic Era folders' rows carry
		    none: there each tier is its own distinctly-named spell
		    ("Create Healthstone (Minor)") that must be cast bare, because
		    appending "(Rank N)" builds a spell that does not exist and the
		    /cast silently no-ops. Never copy rows between the two without
		    adding or dropping the rank column. Mage Conjure Water/Food ARE
		    numeric-rank on every client, so their rank column is correct
		    everywhere — do not "simplify" the two spell families together.
		]]
		-- {Spell ID, Conjured Item Usage Level, Spell Rank}, -- Conjured Item
		{ 11730, 48, 5 }, -- Major Healthstone
		{ 11729, 36, 4 }, -- Greater Healthstone
		{ 5699, 24, 3 }, -- Healthstone
		{ 6202, 12, 2 }, -- Lesser Healthstone
		{ 6201, 1, 1 }, -- Minor Healthstone
	},
	WarlockCreateSoulstone = {
		--[[
		    The resolver passes ignoreTarget=true, which is why the second
		    column is the learn level rather than an item usage level.

		    No rank column: the resolver ignores the target, and a bare
		    /cast already fires the best rank the warlock knows.
		]]
		-- {Spell ID, Spell Learn Level}, -- Conjured Item
		{ 20757, 60 }, -- Major Soulstone
		{ 20756, 50 }, -- Greater Soulstone
		{ 20755, 40 }, -- Soulstone
		{ 20752, 30 }, -- Lesser Soulstone
		{ 693, 18 }, -- Minor Soulstone
	},
}

--[[
    Spell IDs that ConnoisseurTip resolves at print time: one per conjure table
    in ns.CONJURE_SPELLS above that has rows, taken from its rank-1 entry, plus
    the Rogue's Poisons skill, which is not a conjure.
]]
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
