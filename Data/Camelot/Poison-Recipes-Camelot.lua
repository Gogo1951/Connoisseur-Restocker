local _, ns = ...

--------------------------------------------------------------------------------
-- Poison Recipes
--------------------------------------------------------------------------------

--[[
    What a rogue poison costs to craft. Read by
    Features/Restocker/Restocker-Crafting-Reagents.lua: when the Restock List is short of a
    poison, the shortfall is turned into an order for these reagents, and the
    vendor has to stock every one of them before any is bought.

    Blizzard rebalanced most of these counts in TBC, so each folder carries
    its own client's counts: the Classic Era folders the original ones, and
    TBC and later the rebalanced ones.

    Vials are listed like any other reagent rather than special-cased: a recipe
    needs one, the vendor has to sell it, and the all-or-nothing gate treats it
    as it treats the rest.
]]

--[[
    Reagents by ID, so the rows below stay one line each:
      2928 Dust of Decay          8924 Dust of Deterioration
      2930 Essence of Pain        8923 Essence of Agony
      2931 Maiden's Anguish       5173 Deathweed
      3371 Empty Vial             3372 Leaded Vial            8925 Crystal Vial
]]

--[[
    Source: Validate Data on the WoW Forever client (1.60.1, build 70124).
]]
-- TODO: Add SQL Query
-- { craftedItemID, { { reagentID, count }, ... } }, -- Crafted item
ns.POISON_RECIPES = {
	-- Instant Poisons
	{ 8928, { { 8924, 4 }, { 8925, 1 } } }, -- Instant Poison VI
	{ 8927, { { 8924, 3 }, { 8925, 1 } } }, -- Instant Poison V
	{ 8926, { { 8924, 2 }, { 8925, 1 } } }, -- Instant Poison IV
	{ 6950, { { 8924, 1 }, { 3372, 1 } } }, -- Instant Poison III
	{ 6949, { { 2928, 3 }, { 3372, 1 } } }, -- Instant Poison II
	{ 6947, { { 2928, 1 }, { 3371, 1 } } }, -- Instant Poison

	-- Crippling Poisons
	{ 3776, { { 8923, 3 }, { 8925, 1 } } }, -- Crippling Poison II
	{ 3775, { { 2930, 1 }, { 3371, 1 } } }, -- Crippling Poison

	-- Deadly Poisons
	{ 20844, { { 5173, 7 }, { 8925, 1 } } }, -- Deadly Poison V
	{ 8985, { { 5173, 5 }, { 8925, 1 } } }, -- Deadly Poison IV
	{ 8984, { { 5173, 3 }, { 8925, 1 } } }, -- Deadly Poison III
	{ 2893, { { 5173, 2 }, { 3372, 1 } } }, -- Deadly Poison II
	{ 2892, { { 5173, 1 }, { 3372, 1 } } }, -- Deadly Poison

	-- Mind-numbing Poisons
	{ 9186, { { 8924, 2 }, { 8923, 2 }, { 8925, 1 } } }, -- Mind-numbing Poison III
	{ 6951, { { 2928, 4 }, { 2930, 4 }, { 3372, 1 } } }, -- Mind-numbing Poison II
	{ 5237, { { 2928, 1 }, { 2930, 1 }, { 3371, 1 } } }, -- Mind-numbing Poison

	-- Wound Poisons
	{ 10922, { { 8923, 2 }, { 5173, 2 }, { 8925, 1 } } }, -- Wound Poison IV
	{ 10921, { { 8923, 1 }, { 5173, 2 }, { 8925, 1 } } }, -- Wound Poison III
	{ 10920, { { 2930, 1 }, { 5173, 2 }, { 3372, 1 } } }, -- Wound Poison II
	{ 10918, { { 2930, 1 }, { 5173, 1 }, { 3372, 1 } } }, -- Wound Poison
}
