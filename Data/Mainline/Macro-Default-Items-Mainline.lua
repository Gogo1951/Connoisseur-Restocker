local _, ns = ...

--------------------------------------------------------------------------------
-- Macro Default Items
--------------------------------------------------------------------------------

--[[
    The item each macro shows (#showtooltip) while the bags hold nothing it
    can use, keyed by ns.MACRO_CONFIG's macro type (Data/Data.lua).
]]

--[[
    Source: copied from Data/TBC/Macro-Default-Items-TBC.lua until Validate Data
    passes on this client.
]]
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
