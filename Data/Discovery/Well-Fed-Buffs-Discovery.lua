local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

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
	2026-10-16, Season of Discovery 1.15.9.70003

Notes
	- ns.WELL_FED_BUFF_IDS lists food buffs Features/Scanner-Auras.lua must count as Well Fed although they aren't named "Well Fed" or show another icon, so the buff-food check doesn't nag a player who already has one.
	- ns.WELL_FED_ICON_IDS lists the icons Well Fed buffs show (136000, and 133943 for the reworked foods), matched on the aura's icon when its spell ID is in no table.
	- Fizzy Energy Drink's buff (29040) shows icon 132489, which no icon entry matches, so it is listed by ID.
	- Increased Stamina (25661) and Fizzy Energy Drink (29040) are Classic Era buffs the Classic Era report confirms, copied in. Season of Discovery's own buff foods show icon 136000 or 133943 and need no rows.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=1.15.9.70003
	https://wago.tools/db2/SpellMisc?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
	https://wago.tools/db2/ItemEffect?build=1.15.9.70003
]]
