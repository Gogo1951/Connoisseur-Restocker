local _, ns = ...

-- [ID] = {Healing Amount, Mana Amount, {Allowed Zones} or nil, requiredAlchemy or nil}, -- Name
ns.POTIONS = {
	[32947] = { 1500, 0 }, -- Auchenai Healing Potion
	[32948] = { 0, 1800 }, -- Auchenai Mana Potion
	[32783] = { 0, 1800, { 1949, 330 } }, -- Blue Ogre Brew
	[32909] = { 0, 1800, { 1949, 330 } }, -- Blue Ogre Brew Special
	[32902] = { 0, 1800, { 1555, 266, 267, 268, 269, 270, 271, 334 } }, -- Bottled Nethergon Energy
	[32905] = { 1500, 0, { 1555, 266, 267, 268, 269, 270, 271, 334 } }, -- Bottled Nethergon Vapor
	[32904] = { 1500, 0, { 332, 1554, 263, 264, 262, 265 } }, -- Cenarion Healing Salve
	[32903] = { 0, 1800, { 332, 1554, 263, 264, 262, 265 } }, -- Cenarion Mana Salve
	[18839] = { 700, 0 }, -- Combat Healing Potion
	[18841] = { 0, 900 }, -- Combat Mana Potion
	[33934] = { 1500, 0 }, -- Crystal Healing Potion
	[33935] = { 0, 1800 }, -- Crystal Mana Potion
	[23578] = { 0, 1350 }, -- Diet McWeaksauce
	[4596] = { 140, 0 }, -- Discolored Healing Potion
	-- Enriched Lasher Root (23329) is absent on purpose: its live row is in Healthstones-TBC.lua, sharing the Healthstone cooldown category.
	[1072] = { 0, 280 }, -- Full Moonshine
	[1710] = { 455, 0 }, -- Greater Healing Potion
	[6149] = { 0, 700 }, -- Greater Mana Potion
	[929] = { 280, 0 }, -- Healing Potion
	[23822] = { 1500, 0 }, -- Healing Potion Injector
	[33092] = { 1500, 0 }, -- Healing Potion Injector
	[858] = { 140, 0 }, -- Lesser Healing Potion
	[3385] = { 0, 280 }, -- Lesser Mana Potion
	-- Luminous Bluetail (35287) is absent on purpose: its live row is in Mana-Gems-TBC.lua, sharing the Mana Gem cooldown category.
	[31853] = { 1050, 0 }, -- Major Combat Healing Potion
	[31838] = { 1050, 0 }, -- Major Combat Healing Potion
	[31839] = { 1050, 0 }, -- Major Combat Healing Potion
	[31852] = { 1050, 0 }, -- Major Combat Healing Potion
	[31855] = { 0, 1350 }, -- Major Combat Mana Potion
	[31840] = { 0, 1350 }, -- Major Combat Mana Potion
	[31841] = { 0, 1350 }, -- Major Combat Mana Potion
	[31854] = { 0, 1350 }, -- Major Combat Mana Potion
	[17348] = { 980, 0, { 1459, 1460, 1461, 1956 } }, -- Major Healing Draught
	[13446] = { 1050, 0 }, -- Major Healing Potion
	[17351] = { 0, 980, { 1459, 1460, 1461, 1956 } }, -- Major Mana Draught
	[13444] = { 0, 1350 }, -- Major Mana Potion
	[18253] = { 1440, 1440 }, -- Major Rejuvenation Potion
	[3827] = { 0, 455 }, -- Mana Potion
	[23823] = { 0, 1800 }, -- Mana Potion Injector
	[33093] = { 0, 1800 }, -- Mana Potion Injector
	[118] = { 70, 0 }, -- Minor Healing Potion
	[2455] = { 0, 140 }, -- Minor Mana Potion
	[2456] = { 90, 90 }, -- Minor Rejuvenation Potion
	[3087] = { 0, 140 }, -- Mug of Shimmer Stout
	[32784] = { 1050, 0, { 1949, 330 } }, -- Red Ogre Brew
	[32910] = { 1050, 0, { 1949, 330 } }, -- Red Ogre Brew Special
	[32762] = { 0, 1800 }, -- Rulkster's Brain Juice
	[32763] = { 1500, 0 }, -- Rulkster's Secret Sauce
	[22829] = { 1500, 0 }, -- Super Healing Potion
	[22832] = { 0, 1800 }, -- Super Mana Potion
	[22850] = { 1650, 1650 }, -- Super Rejuvenation Potion
	[17349] = { 560, 0, { 1459, 1460, 1461, 1956 } }, -- Superior Healing Draught
	[3928] = { 700, 0 }, -- Superior Healing Potion
	[17352] = { 0, 560, { 1459, 1460, 1461, 1956 } }, -- Superior Mana Draught
	[13443] = { 0, 900 }, -- Superior Mana Potion
	[23579] = { 1050, 0 }, -- The McWeaksauce Classic
	[28101] = { 0, 1350 }, -- Unstable Mana Potion
	[28100] = { 1050, 0 }, -- Volatile Healing Potion
	[9144] = { 1, 1 }, -- Wildvine Potion
	[34440] = { 1650, 1650, nil, 315 }, -- Mad Alchemist's Potion
	-- Whipper Root Tuber (11951) is absent on purpose: its live row is in Healthstones-TBC.lua, sharing the Healthstone cooldown category.
}

--[[
How We Got the Data

Last Validated
	2026-10-16, TBC Anniversary 2.5.6.70006

Notes
	- Every potion this client knows that restores health or mana instantly on the potion cooldown, read by the item cache (Features/Item-Cache.lua) for the Health Potion and Mana Potion macros. Healing Amount and Mana Amount are each effect's low end; requiredAlchemy is the Alchemy rank the tooltip requires.
	- Allowed Zones are uiMapIDs. The draughts' text says they work only in PvP battlegrounds: 1459 Alterac Valley, 1460 Warsong Gulch, 1461 Arathi Basin, 1956 Eye of the Storm.
	- Holy Spring Water (737) is left out on purpose, an oddball on the potion cooldown. Potions that do something else (rage, speed, protection, invisibility) are not in this table.
	- The TBC zone potions have no area requirement in this client's tables; their zones come from their text. The Ogre Brews say only the Blade's Edge Plateaus (1949), and keep Gruul's Lair (330) too: they work there. Bottled Nethergon Energy and Vapor work inside Tempest Keep's four wings, and the Cenarion salves inside Coilfang's four.
	- Season of Discovery items are left out; this client doesn't know them. They live only in Data/Discovery/.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=2.5.6.70006
	https://wago.tools/db2/ItemSparse?build=2.5.6.70006
	https://wago.tools/db2/ItemEffect?build=2.5.6.70006
	https://wago.tools/db2/Spell?build=2.5.6.70006
	https://wago.tools/db2/SpellEffect?build=2.5.6.70006
	https://wago.tools/db2/SpellMisc?build=2.5.6.70006
	https://wago.tools/db2/SpellDuration?build=2.5.6.70006
	https://wago.tools/db2/SpellCastingRequirements?build=2.5.6.70006
	https://wago.tools/db2/AreaGroupMember?build=2.5.6.70006
	https://wago.tools/db2/UiMapAssignment?build=2.5.6.70006
]]
