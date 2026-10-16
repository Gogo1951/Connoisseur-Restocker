local _, ns = ...

-- { buffID = true }
ns.WELL_FED_BUFF_IDS = {
	[18125] = true, -- Blessed Sunfruit
	[18141] = true, -- Blessed Sunfruit Juice
	[18191] = true, -- Increased Stamina
	[18192] = true, -- Increased Agility
	[18193] = true, -- Increased Spirit
	[18194] = true, -- Mana Regeneration
	[18222] = true, -- Health Regeneration
	[22730] = true, -- Increased Intellect
	[23697] = true, -- Alterac Spring Water
	[25661] = true, -- Increased Stamina (Dirge's Kickin' Chimaerok Chops)
	[29040] = true, -- Fizzy Energy Drink
	[44097] = true, -- "Well Fed" (Barleybrew Clear, Small Step Brew)
	[44098] = true, -- "Well Fed" (Barleybrew Light, Long Stride Brew)
	[44099] = true, -- "Well Fed" (Barleybrew Dark, Path of Brew)
	[44100] = true, -- "Well Fed" (Thunder 45, Jungle River Water)
	[44101] = true, -- "Well Fed" (Thunderbrew Ale, Brewdoo Magic)
	[44102] = true, -- "Well Fed" (Thunderbrew Stout, Stout Shrunken Head)
	[44104] = true, -- "Well Fed" (Gordok Grog)
	[44105] = true, -- "Well Fed" (Ogre Mead)
	[44106] = true, -- "Well Fed" (Mudder's Milk)
	[45245] = true, -- Well Fed (Hot Apple Cider)
}

-- Icons the Well Fed buffs show, matched on the aura's icon when its spell ID is in no table.
-- { [iconFileID] = true }
ns.WELL_FED_ICON_IDS = {
	[136000] = true, -- Well Fed
	[133943] = true, -- Well Fed
}

--[[
How We Got the Data

Last Validated
	2026-10-16, TBC Anniversary 2.5.6.70006

Notes
	- ns.WELL_FED_BUFF_IDS lists food buffs Features/Scanner-Auras.lua must count as Well Fed although they aren't named "Well Fed" or show another icon, so the buff-food check doesn't nag a player who already has one.
	- ns.WELL_FED_ICON_IDS lists the icons Well Fed buffs show (136000, and 133943 for the reworked foods), matched on the aura's icon when its spell ID is in no table.
	- Fizzy Energy Drink's buff (29040) shows icon 132489, which no icon entry matches, so it is listed by ID.
	- The Brewfest drinks apply a separate buff named "Well Fed" (with quotes) on icon 133696, which "Completely Hammered" also uses, so they are listed by ID rather than matched by icon.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=2.5.6.70006
	https://wago.tools/db2/SpellMisc?build=2.5.6.70006
	https://wago.tools/db2/SpellEffect?build=2.5.6.70006
	https://wago.tools/db2/ItemEffect?build=2.5.6.70006
]]
