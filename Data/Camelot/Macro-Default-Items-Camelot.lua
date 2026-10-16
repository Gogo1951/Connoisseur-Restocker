local _, ns = ...

-- [macroType] = itemID, -- Item Name
ns.MACRO_DEFAULT_ITEM_IDS = {
	["Bandage"] = 1251, -- Linen Bandage
	["Explosive"] = 4358, -- Rough Dynamite
	["Food"] = 5349, -- Conjured Muffin
	["Health Potion"] = 118, -- Minor Healing Potion
	["Healthstone"] = 5512, -- Minor Healthstone
	["Mana Gem"] = 5514, -- Mana Agate
	["Mana Potion"] = 2455, -- Minor Mana Potion
	["Soulstone"] = 5232, -- Minor Soulstone
	["Water"] = 5350, -- Conjured Water
	["Feed Pet"] = 117, -- Tough Jerky
	["Poisons"] = 6947, -- Instant Poison
}

--[[
How We Got the Data

Last Validated
	2026-10-16, WoW Forever 1.60.1.70425

Notes
	- The item each macro shows (#showtooltip) while the bags hold nothing it can use, keyed by ns.MACRO_CONFIG's macro type (Data/Data.lua). Read by the macro body builder, the mini-map tooltip, the rogue tools and the Macros options panel.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=1.60.1.70425
]]
