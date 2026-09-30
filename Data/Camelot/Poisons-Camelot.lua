local _, ns = ...

--------------------------------------------------------------------------------
-- Rogue Poisons
--------------------------------------------------------------------------------

--[[
    Poison items grouped by type. Each group's display name is resolved at
    runtime via C_Item.GetItemInfo on the base (rank 1) item of the series, so the
    client's own item localization does the work, with the options panels'
    loading text standing in until that item is cached (see
    ns.GetPoisonGroupName in Features/Macros/Tools-Rogues.lua).

    The group numbering (ns.POISON_GROUPS) carries no game IDs, so it lives in
    Data/Data.lua.
]]

--[[
    Source: Validate Data on the WoW Forever client (1.60.1, build 70124).
]]

-- [groupID] = base item of the series (the group's runtime display name)
ns.POISON_GROUP_BASE_ITEMS = {
	[2] = 3775, -- Crippling Poison
	[3] = 2892, -- Deadly Poison
	[4] = 6947, -- Instant Poison
	[5] = 5237, -- Mind-numbing Poison
	[6] = 10918, -- Wound Poison
}

-- TODO: Add SQL Query
-- [ID] = {Required Level, Poison Group}, -- Item Name
ns.POISON_DATA = {
	[3775] = { 20, 2 }, -- Crippling Poison
	[3776] = { 50, 2 }, -- Crippling Poison II
	[2892] = { 30, 3 }, -- Deadly Poison
	[2893] = { 38, 3 }, -- Deadly Poison II
	[8984] = { 46, 3 }, -- Deadly Poison III
	[8985] = { 54, 3 }, -- Deadly Poison IV
	[20844] = { 60, 3 }, -- Deadly Poison V
	[6947] = { 20, 4 }, -- Instant Poison
	[6949] = { 28, 4 }, -- Instant Poison II
	[6950] = { 36, 4 }, -- Instant Poison III
	[8926] = { 44, 4 }, -- Instant Poison IV
	[8927] = { 52, 4 }, -- Instant Poison V
	[8928] = { 60, 4 }, -- Instant Poison VI
	[5237] = { 24, 5 }, -- Mind-numbing Poison
	[6951] = { 38, 5 }, -- Mind-numbing Poison II
	[9186] = { 52, 5 }, -- Mind-numbing Poison III
	[10918] = { 32, 6 }, -- Wound Poison
	[10920] = { 40, 6 }, -- Wound Poison II
	[10921] = { 48, 6 }, -- Wound Poison III
	[10922] = { 56, 6 }, -- Wound Poison IV
}
