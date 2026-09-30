local _, ns = ...

-- TODO: Add SQL Query
--[[
    Source: copied from Data/Vanilla/Potions-Vanilla.lua until Validate Data
    passes on this client. Every row was checked against WoW Forever's own
    tables on wago.tools (build 1.60.1.70124): Minor Discolored Healing
    Potion's 150 and the Discolored, Perishable and Tessa's Tonic rows come
    from there, pending Validate Data. Amounts are each effect's low end.
    Windstone comes from the same tables, pending Validate Data; its spell
    requires area 16593 (Zephras Isle), which UiMapAssignment maps to uiMap
    2521. Wildvine Potion comes from Validate Data (build 1.60.1.70124); its
    0 to 1,500 health and mana is entered as 1 and 1, as in Vanilla and TBC,
    so it ranks below every other potion.

    Healing/Mana amounts derived from item_template.spellid_1 spell
    effects; Allowed Zones from Map/Area restrictions where present.
]]
-- [ID] = {Healing Amount, Mana Amount, {Allowed Zones} or nil, requiredAlchemy or nil}, -- Name
ns.POTIONS = {
	[18839] = { 700, 0 }, -- Combat Healing Potion
	[18841] = { 0, 900 }, -- Combat Mana Potion
	[23578] = { 0, 1350 }, -- Diet McWeaksauce
	[247240] = { 600, 0 }, -- Discolored Healing Potion
	[1072] = { 0, 280 }, -- Full Moonshine
	[247241] = { 975, 0 }, -- Greater Discolored Healing Potion
	[1710] = { 455, 0 }, -- Greater Healing Potion
	[6149] = { 0, 700 }, -- Greater Mana Potion
	[929] = { 280, 0 }, -- Healing Potion
	[247239] = { 300, 0 }, -- Lesser Discolored Healing Potion
	[858] = { 140, 0 }, -- Lesser Healing Potion
	[3385] = { 0, 280 }, -- Lesser Mana Potion
	[17348] = { 980, 0, { 1459, 1460, 1461 } }, -- Major Healing Draught
	[13446] = { 1050, 0 }, -- Major Healing Potion
	[17351] = { 0, 980, { 1459, 1460, 1461 } }, -- Major Mana Draught
	[13444] = { 0, 1350 }, -- Major Mana Potion
	[18253] = { 1440, 1440 }, -- Major Rejuvenation Potion
	[3827] = { 0, 455 }, -- Mana Potion
	[4596] = { 150, 0 }, -- Minor Discolored Healing Potion
	[118] = { 70, 0 }, -- Minor Healing Potion
	[2455] = { 0, 140 }, -- Minor Mana Potion
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
