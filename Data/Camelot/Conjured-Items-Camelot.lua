local _, ns = ...

--------------------------------------------------------------------------------
-- Conjured Items
--------------------------------------------------------------------------------

--[[
    Conjure-spell ID to conjured-item IDs. Conjured stones are unique in bags,
    so GetSmartSpell consults this when called with checkUnique and skips a rank
    whose item the player already holds: the macro then conjures the next rank
    down instead of failing on a duplicate. Each Create Healthstone rank and
    each Mana Gem spell makes exactly one item: Forever has no Improved
    Healthstone talent, whose ranks made two stronger copies of each stone.

    Source: Validate Data on the WoW Forever client (1.60.1, build 70124).
]]
-- TODO: Add SQL Query
-- [conjureSpellID] = { itemID, ... }, -- Conjured item
ns.CONJURED_ITEM_IDS_BY_SPELL = {
	[11730] = { 9421 }, -- Major Healthstone
	[11729] = { 5510 }, -- Greater Healthstone
	[5699] = { 5509 }, -- Healthstone
	[6202] = { 5511 }, -- Lesser Healthstone
	[6201] = { 5512 }, -- Minor Healthstone
	[10054] = { 8008 }, -- Conjure Mana Ruby
	[10053] = { 8007 }, -- Conjure Mana Citrine
	[3552] = { 5513 }, -- Conjure Mana Jade
	[759] = { 5514 }, -- Conjure Mana Agate
}
