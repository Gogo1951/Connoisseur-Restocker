local _, ns = ...

-- [ID] = {Mana Amount}, -- Name
ns.MANA_GEMS = {
	[8008] = { 1000 }, -- Mana Ruby
	[8007] = { 775 }, -- Mana Citrine
	[5513] = { 550 }, -- Mana Jade
	[5514] = { 375 }, -- Mana Agate
}

-- [ID] = {Mana Amount}, -- Name
ns.MANA_RUNES = {
	[20520] = { 900 }, -- Dark Rune
	[12662] = { 900 }, -- Demonic Rune
}

--[[
How We Got the Data

Last Validated
	2026-10-16, WoW Forever 1.60.1.70425

Notes
	- ns.MANA_GEMS holds the mage's mana gems, read by the item cache (Features/Item-Cache.lua) for the Mana Gem macro and by the Readiness Report. Mana Amount is the low end of the restore.
	- ns.MANA_RUNES holds the Demonic and Dark Runes, which restore mana at the cost of life and share the mana gems' cooldown. The Mana Gem macro ranks them in with the gems when the player opts in (Features/Macros/Mana-Gem.lua). The mana column is the low end, as for the gems. The two restore the same amount, so the selection ladder's isSoulbound step burns the soulbound Demonic Rune before the tradeable Dark Rune.
	- WoW Forever raised the gems: Agate 375 to 425, Jade 550 to 650, Citrine 775 to 925, Ruby 1000 to 1200.

SQL (CMaNGOS)
	ns.MANA_GEMS, database not recorded:

	SELECT
	    CONCAT(
	        '    [', it.entry, '] = {',

	        -- Calculates the instant mana restore amount
	        (st.EffectBasePoints1 + 1),

	        '}, -- ', it.name
	    ) AS `ns.RAW_DATA.ManaGem`
	FROM item_template it
	-- Failsafe: Joins on spellid_1, but seamlessly falls back to spellid_2 if slot 1 is blank
	JOIN spell_template st ON st.Id = COALESCE(NULLIF(it.spellid_1, 0), NULLIF(it.spellid_2, 0))
	WHERE it.name IN (
	    'Mana Agate',
	    'Mana Jade',
	    'Mana Citrine',
	    'Mana Ruby',
	    'Mana Emerald',
	    'Mana Sapphire'
	)
	  -- Garbage collector for any weird [PH] or test server gems
	  AND st.EffectBasePoints1 > 0
	ORDER BY
	    (st.EffectBasePoints1 + 1) DESC,
	    it.entry DESC;

	ns.MANA_RUNES: TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.60.1.70425
	https://wago.tools/db2/ItemSparse?build=1.60.1.70425
	https://wago.tools/db2/ItemEffect?build=1.60.1.70425
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70425
	https://wago.tools/db2/Spell?build=1.60.1.70425
	https://wago.tools/db2/SpellEffect?build=1.60.1.70425
	https://wago.tools/db2/SpellMisc?build=1.60.1.70425
	https://wago.tools/db2/SpellDuration?build=1.60.1.70425
]]
