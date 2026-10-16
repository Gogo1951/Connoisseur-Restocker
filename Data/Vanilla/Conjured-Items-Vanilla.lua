local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- [conjureSpellID] = { itemID, ... }, -- Conjured item
ns.CONJURED_ITEM_IDS_BY_SPELL = {
	[11730] = { 9421, 19012, 19013 }, -- Major Healthstone
	[11729] = { 5510, 19010, 19011 }, -- Greater Healthstone
	[5699] = { 5509, 19008, 19009 }, -- Healthstone
	[6202] = { 5511, 19006, 19007 }, -- Lesser Healthstone
	[6201] = { 5512, 19004, 19005 }, -- Minor Healthstone
	[10054] = { 8008 }, -- Conjure Mana Ruby
	[10053] = { 8007 }, -- Conjure Mana Citrine
	[3552] = { 5513 }, -- Conjure Mana Jade
	[759] = { 5514 }, -- Conjure Mana Agate
}

--[[
How We Got the Data

Last Validated
	2026-10-16, Classic Era 1.15.9.70003

Notes
	- Conjure spell ID to the items it makes, read by GetSmartSpell (Features/Macros/Smart-Spell.lua) when it is called with checkUnique. Conjured stones are unique in bags, so a rank whose item the player already holds is skipped and the macro conjures the next rank down instead of failing on a duplicate.
	- Each Create Healthstone rank makes one of three items, depending on the warlock's Improved Healthstone talent (0, 1 or 2 points), and a tier counts as held when any of them is present. Each Mana Gem spell makes exactly one item.
	- Soulstones have no rows here on purpose: they share a 30-minute use cooldown that matches the buff duration, so only one stone can ever be deployed at a time, and conjuring a lower rank while holding the best one would just waste a soul shard. The Soulstone resolver runs with checkUnique off and always offers the best known conjure.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
	https://wago.tools/db2/ItemSparse?build=1.15.9.70003
]]
