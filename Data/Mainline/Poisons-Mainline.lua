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
    Source: copied from Data/Wrath/Poisons-Wrath.lua: the rows a Wrath
    client loaded from the pre-split shared tables, until a Mainline TOC ships
    and Validate Data runs there.
]]

-- [groupID] = base item of the series (the group's runtime display name)
ns.POISON_GROUP_BASE_ITEMS = {
	[1] = 21835, -- Anesthetic Poison
	[2] = 3775, -- Crippling Poison
	[3] = 2892, -- Deadly Poison
	[4] = 6947, -- Instant Poison
	[5] = 5237, -- Mind-numbing Poison
	[6] = 10918, -- Wound Poison
}

-- TODO: Add SQL Query
-- [ID] = {Required Level, Poison Group}, -- Item Name
ns.POISON_DATA = {
	[21835] = { 68, 1 }, -- Anesthetic Poison
	[43237] = { 77, 1 }, -- Anesthetic Poison II
	[3775] = { 20, 2 }, -- Crippling Poison
	[3776] = { 50, 2 }, -- Crippling Poison II
	[2892] = { 30, 3 }, -- Deadly Poison
	[2893] = { 38, 3 }, -- Deadly Poison II
	[8984] = { 46, 3 }, -- Deadly Poison III
	[8985] = { 54, 3 }, -- Deadly Poison IV
	[20844] = { 60, 3 }, -- Deadly Poison V
	[22053] = { 62, 3 }, -- Deadly Poison VI
	[22054] = { 70, 3 }, -- Deadly Poison VII
	[43232] = { 76, 3 }, -- Deadly Poison VIII
	[43233] = { 80, 3 }, -- Deadly Poison IX
	[6947] = { 20, 4 }, -- Instant Poison
	[6949] = { 28, 4 }, -- Instant Poison II
	[6950] = { 36, 4 }, -- Instant Poison III
	[8926] = { 44, 4 }, -- Instant Poison IV
	[8927] = { 52, 4 }, -- Instant Poison V
	[8928] = { 60, 4 }, -- Instant Poison VI
	[21927] = { 68, 4 }, -- Instant Poison VII
	[43230] = { 73, 4 }, -- Instant Poison VIII
	[43231] = { 79, 4 }, -- Instant Poison IX
	[5237] = { 24, 5 }, -- Mind-numbing Poison
	[6951] = { 38, 5 }, -- Mind-numbing Poison II
	[9186] = { 52, 5 }, -- Mind-numbing Poison III
	[10918] = { 32, 6 }, -- Wound Poison
	[10920] = { 40, 6 }, -- Wound Poison II
	[10921] = { 48, 6 }, -- Wound Poison III
	[10922] = { 56, 6 }, -- Wound Poison IV
	[22055] = { 64, 6 }, -- Wound Poison V
	[43234] = { 72, 6 }, -- Wound Poison VI
	[43235] = { 78, 6 }, -- Wound Poison VII
}
