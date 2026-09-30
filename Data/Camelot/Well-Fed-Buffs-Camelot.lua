local _, ns = ...

--------------------------------------------------------------------------------
-- Additional "Well Fed" Buffs
--------------------------------------------------------------------------------

--[[
    Source: Validate Data on the WoW Forever client (1.60.1, build 69977).
    Increased Stamina (25661) and Fizzy Energy Drink (29040) come from WoW
    Forever's own tables on wago.tools (build 1.60.1.70124), pending Validate
    Data; 29040 is the buff Fizzy Energy Drink (23176) leaves, on icon 132489,
    which no ns.WELL_FED_ICON_IDS entry matches. Forever's reworked foods give
    "Well Fed" buffs on icon 133943, which ns.WELL_FED_ICON_IDS already covers.
]]

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
