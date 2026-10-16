local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

-- [groupID] = base item of the series (the group's runtime display name)
ns.POISON_GROUP_BASE_ITEMS = {
	[2] = 3775, -- Crippling Poison
	[3] = 2892, -- Deadly Poison
	[4] = 6947, -- Instant Poison
	[5] = 5237, -- Mind-numbing Poison
	[6] = 10918, -- Wound Poison
	[7] = 217345, -- Sebacious Poison
	[8] = 217346, -- Numbing Poison
	[9] = 217347, -- Atrophic Poison
	[10] = 226374, -- Occult Poison I
}

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
	[5654] = { 24, 4 }, -- Instant Toxin
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
	[217345] = { 60, 7 }, -- Sebacious Poison
	[217346] = { 60, 8 }, -- Numbing Poison
	[217347] = { 60, 9 }, -- Atrophic Poison
	[226374] = { 54, 10 }, -- Occult Poison I
	[234444] = { 60, 10 }, -- Occult Poison II
}

--[[
How We Got the Data

Last Validated
	2026-10-16, Season of Discovery 1.15.9.70003

Notes
	- ns.POISON_DATA holds every rogue poison the Poisons macro can apply, read by Features/Macros/Tools-Rogues.lua: Required Level is the level the tooltip requires, and Poison Group is ns.POISON_GROUPS' numbering (Data/Data.lua), which carries no game IDs and so lives there.
	- ns.POISON_GROUP_BASE_ITEMS names the base (rank 1) item of each group. A group's display name is that item's name from C_Item.GetItemInfo, so the client's own localization does the work, with the options panels' loading text standing in until the item is cached (ns.GetPoisonGroupName).
	- Anesthetic Poison is a TBC poison, so this client has no group 1.
	- Instant Toxin (5654) is a Classic Era item the Classic Era report confirms, copied in.
	- Season of Discovery's own poisons are groups 7 to 10 (Sebacious, Numbing, Atrophic, Occult), which only this folder fills; Occult has two ranks (I at 54, II at 60). Their rows came from the Classic Era tables on wago.tools (build 1.15.9.70003, ItemSparse and the Poisons skill line), pending a Season of Discovery Validate Data run. Whether a rogue must have the matching rune engraved to apply them is unchecked in game.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=1.15.9.70003
	https://wago.tools/db2/SkillLineAbility?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
]]
