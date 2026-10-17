local _, ns = ...

-- [ID] = {Healing Amount, Mana Amount, {Allowed Zones} or nil, requiredAlchemy or nil}, -- Name
ns.POTIONS = {
	[18839] = { 700, 0 }, -- Combat Healing Potion
	[18841] = { 0, 900 }, -- Combat Mana Potion
	[23578] = { 0, 1350 }, -- Diet McWeaksauce
	[247240] = { 600, 0 }, -- Discolored Healing Potion
	[1072] = { 0, 280 }, -- Full Moonshine
	[247241] = { 975, 0 }, -- Greater Discolored Healing Potion
	[1710] = { 455, 0 }, -- Greater Healing Potion
	[287977] = { 455, 0 }, -- Greater Healing Potion
	[6149] = { 0, 700 }, -- Greater Mana Potion
	[929] = { 280, 0 }, -- Healing Potion
	[247239] = { 300, 0 }, -- Lesser Discolored Healing Potion
	[858] = { 140, 0 }, -- Lesser Healing Potion
	[287967] = { 140, 0 }, -- Lesser Healing Potion
	[3385] = { 0, 280 }, -- Lesser Mana Potion
	[287969] = { 0, 280 }, -- Lesser Mana Potion
	[17348] = { 980, 0, { 1459, 1460, 1461 } }, -- Major Healing Draught
	[13446] = { 1050, 0 }, -- Major Healing Potion
	[17351] = { 0, 980, { 1459, 1460, 1461 } }, -- Major Mana Draught
	[13444] = { 0, 1350 }, -- Major Mana Potion
	[18253] = { 1440, 1440 }, -- Major Rejuvenation Potion
	[3827] = { 0, 455 }, -- Mana Potion
	[4596] = { 150, 0 }, -- Minor Discolored Healing Potion
	[118] = { 70, 0 }, -- Minor Healing Potion
	[287966] = { 70, 0 }, -- Minor Healing Potion
	[2455] = { 0, 140 }, -- Minor Mana Potion
	[287968] = { 0, 140 }, -- Minor Mana Potion
	[2456] = { 90, 90 }, -- Minor Rejuvenation Potion
	[3087] = { 0, 140 }, -- Mug of Shimmer Stout
	[268883] = { 280, 0 }, -- Perishable Healing Potion
	[268882] = { 140, 0 }, -- Perishable Lesser Healing Potion
	[268881] = { 70, 0 }, -- Perishable Minor Healing Potion
	[247242] = { 1500, 0 }, -- Superior Discolored Healing Potion
	[17349] = { 560, 0, { 1459, 1460, 1461 } }, -- Superior Healing Draught
	[3928] = { 700, 0 }, -- Superior Healing Potion
	[17352] = { 0, 560, { 1459, 1460, 1461 } }, -- Superior Mana Draught
	[13443] = { 0, 900 }, -- Superior Mana Potion
	[274935] = { 720, 720 }, -- Tessa's Tonic
	[23579] = { 1050, 0 }, -- The McWeaksauce Classic
	[9144] = { 1, 1 }, -- Wildvine Potion
	[255663] = { 32, 21, { 2521 } }, -- Windstone
	-- Whipper Root Tuber (11951) is absent on purpose: its live row is in Healthstones-Camelot.lua, sharing the Healthstone cooldown category.
	-- Major Discolored Healing Potion (241650) is deliberately absent; it is a Season of Discovery item the Forever client still knows.
}

--[[
How We Got the Data

Last Validated
	2026-10-16, WoW Forever 1.60.1.70450

Notes
	- Every potion this client knows that restores health or mana instantly on the potion cooldown, read by the item cache (Features/Item-Cache.lua) for the Health Potion and Mana Potion macros. Healing Amount and Mana Amount are each effect's low end; requiredAlchemy is the Alchemy rank the tooltip requires.
	- Allowed Zones are uiMapIDs. The draughts' text says they work only in PvP battlegrounds: 1459 Alterac Valley, 1460 Warsong Gulch, 1461 Arathi Basin.
	- Holy Spring Water (737) is left out on purpose, an oddball on the potion cooldown. Potions that do something else (rage, speed, protection, invisibility) are not in this table.
	- Windstone's spell requires area 16593 (Zephras Isle), which UiMapAssignment maps to uiMap 2521; its text says it can't be used outside Skywall. Wildvine Potion's 0 to 1,500 health and mana is entered as 1 and 1, as in Vanilla and TBC, so it ranks below every other potion.
	- Minor and Lesser Healing, Minor and Lesser Mana, and Greater Healing (287966-287969, 287977) are WoW Forever's level-1 copies of the originals, with the same use spells and the originals' values, which Validate Data confirmed on build 1.60.1.70450.
	- Season of Discovery items are left out even though this client knows many of their IDs (any ID of 200000 or more that the Classic Era tables also hold): they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

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
	https://wago.tools/db2/SpellCastingRequirements?build=1.60.1.70450
	https://wago.tools/db2/AreaGroupMember?build=1.60.1.70450
	https://wago.tools/db2/UiMapAssignment?build=1.60.1.70450

QuestieDB
	None.
]]
