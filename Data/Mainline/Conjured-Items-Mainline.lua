local _, ns = ...

--------------------------------------------------------------------------------
-- Conjured Items
--------------------------------------------------------------------------------

--[[
    Conjure-spell ID to conjured-item IDs. Conjured stones are unique in bags,
    so GetSmartSpell consults this when called with checkUnique and skips a rank
    whose item the player already holds: the macro then conjures the next rank
    down instead of failing on a duplicate. Each Create Healthstone rank makes
    one of three items, depending on the warlock's Improved Healthstone talent
    (0/1/2 points), and a tier counts as held when any of them is present. Each
    Mana Gem spell makes exactly one item.

    Source: copied from Data/Wrath/Conjured-Items-Wrath.lua: the rows a Wrath
    client loaded from the pre-split shared tables, until a Mainline TOC ships
    and Validate Data runs there.
]]
-- TODO: Add SQL Query
-- [conjureSpellID] = { itemID, ... }, -- Conjured item
ns.CONJURED_ITEM_IDS_BY_SPELL = {
	[47878] = { 36892, 36893, 36894 }, -- Fel Healthstone
	[47871] = { 36889, 36890, 36891 }, -- Demonic Healthstone
	[27230] = { 22103, 22104, 22105 }, -- Master Healthstone
	[11730] = { 9421, 19012, 19013 }, -- Major Healthstone
	[11729] = { 5510, 19010, 19011 }, -- Greater Healthstone
	[5699] = { 5509, 19008, 19009 }, -- Healthstone
	[6202] = { 5511, 19006, 19007 }, -- Lesser Healthstone
	[6201] = { 5512, 19004, 19005 }, -- Minor Healthstone
	[42985] = { 33312 }, -- Conjure Mana Sapphire
	[27101] = { 22044 }, -- Conjure Mana Emerald
	[10054] = { 8008 }, -- Conjure Mana Ruby
	[10053] = { 8007 }, -- Conjure Mana Citrine
	[3552] = { 5513 }, -- Conjure Mana Jade
	[759] = { 5514 }, -- Conjure Mana Agate
}
