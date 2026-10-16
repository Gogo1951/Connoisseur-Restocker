local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

-- [ID] = {Healthstone Amount, Required Level}, -- Name
ns.HEALTHSTONES = {
	[19013] = { 1440, 48 }, -- Major Healthstone
	[19012] = { 1320, 48 }, -- Major Healthstone
	[9421] = { 1200, 48 }, -- Major Healthstone
	[15723] = { 1050, 50 }, -- Tea with Sugar
	[19011] = { 960, 36 }, -- Greater Healthstone
	[19010] = { 880, 36 }, -- Greater Healthstone
	[5510] = { 800, 36 }, -- Greater Healthstone
	[11951] = { 700, 45 }, -- Whipper Root Tuber
	[23683] = { 450, 45 }, -- Crystal Flake Throat Lozenge
	[19009] = { 600, 24 }, -- Healthstone
	[19008] = { 550, 24 }, -- Healthstone
	[14894] = { 525, 0 }, -- Lily Root
	[5509] = { 500, 24 }, -- Healthstone
	[19007] = { 300, 12 }, -- Lesser Healthstone
	[19006] = { 275, 12 }, -- Lesser Healthstone
	[5511] = { 250, 12 }, -- Lesser Healthstone
	[19005] = { 120, 1 }, -- Minor Healthstone
	[19004] = { 110, 1 }, -- Minor Healthstone
	[5512] = { 100, 1 }, -- Minor Healthstone
	[5205] = { 71, 5 }, -- Sprouted Frond
}

--[[
How We Got the Data

Last Validated
	2026-10-16, Season of Discovery 1.15.9.70003

Notes
	- Every item that heals instantly on the healthstone cooldown, keyed by the cooldown category Charged Crystal Focus (32578) uses, read by the item cache (Features/Item-Cache.lua) for the Healthstone and Health Potion macros. Healthstone Amount is the low end of the heal; Required Level is the level the tooltip requires (0 for none).
	- Alexander's Test Healthstone (30347) and Royal Guide of Escape Routes (43657) are left out, as the query below shows.
	- Mana gems and runes share the category but restore mana; they live in Mana-Gems-Discovery.lua. The Minor and Major Recombobulators restore health as a side effect of dispelling Polymorph and are reusable devices, so they are left out.
	- Night Dragon's Breath (11952) is left out on purpose, an oddball that shares the cooldown.
	- Sprouted Frond's heal scales with the player's level; its row holds the heal at the spell's base level, so the client's text for a higher character reads more.
	- Crystal Flake Throat Lozenge (23683) is a Classic Era item the Classic Era report confirms, copied in.

SQL (CMaNGOS)
	Database not recorded.

	SELECT
	    CONCAT('    [', s.entry, '] = {', (st.EffectBasePoints1 + 1),
	           ', ', s.RequiredLevel, '}, -- ', s.name) AS `RAW_DATA`
	FROM (
	    SELECT entry, name, RequiredLevel, spellid_1 AS spellid, spellcategory_1 AS cat FROM item_template
	    UNION ALL SELECT entry, name, RequiredLevel, spellid_2, spellcategory_2 FROM item_template
	    UNION ALL SELECT entry, name, RequiredLevel, spellid_3, spellcategory_3 FROM item_template
	    UNION ALL SELECT entry, name, RequiredLevel, spellid_4, spellcategory_4 FROM item_template
	    UNION ALL SELECT entry, name, RequiredLevel, spellid_5, spellcategory_5 FROM item_template
	) s
	JOIN spell_template st ON st.Id = s.spellid
	WHERE s.cat > 0
	  AND s.cat IN (
	        SELECT cat FROM (
	            SELECT spellcategory_1 AS cat FROM item_template WHERE entry = 32578
	            UNION ALL SELECT spellcategory_2 FROM item_template WHERE entry = 32578
	            UNION ALL SELECT spellcategory_3 FROM item_template WHERE entry = 32578
	            UNION ALL SELECT spellcategory_4 FROM item_template WHERE entry = 32578
	            UNION ALL SELECT spellcategory_5 FROM item_template WHERE entry = 32578
	        ) src WHERE cat > 0
	  )
	  AND st.Effect1 = 10            -- SPELL_EFFECT_HEAL (flat direct heal)
	  AND st.EffectBasePoints1 > 0
	  AND s.entry NOT IN (
	        30347,   -- Alexander's Test Healthstone
	        43657    -- Royal Guide of Escape Routes
	  )
	ORDER BY (st.EffectBasePoints1 + 1) DESC, s.RequiredLevel DESC, s.entry DESC;

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.15.9.70003
	https://wago.tools/db2/ItemSparse?build=1.15.9.70003
	https://wago.tools/db2/ItemEffect?build=1.15.9.70003
	https://wago.tools/db2/Spell?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
	https://wago.tools/db2/SpellMisc?build=1.15.9.70003
	https://wago.tools/db2/SpellDuration?build=1.15.9.70003
	https://wago.tools/db2/SpellLevels?build=1.15.9.70003
]]
