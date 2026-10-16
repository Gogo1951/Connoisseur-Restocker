local _, ns = ...

-- [ID] = {Healthstone Amount, Required Level}, -- Name
ns.HEALTHSTONES = {
	[9421] = { 1440, 48 }, -- Major Healthstone
	[15723] = { 1050, 50 }, -- Tea with Sugar
	[5510] = { 960, 36 }, -- Greater Healthstone
	[11951] = { 700, 45 }, -- Whipper Root Tuber
	[5509] = { 600, 24 }, -- Healthstone
	-- Lily Root (14894) is deliberately absent; on this client it needs Lei of Lilies equipped to be eaten, which this table can't express.
	[5511] = { 300, 12 }, -- Lesser Healthstone
	[5512] = { 120, 1 }, -- Minor Healthstone
	[5205] = { 86, 5 }, -- Sprouted Frond
	-- The Improved Healthstone copies of each stone (19004 to 19013) are deliberately absent; Forever removed that talent and raised each base stone to its top copy's amount, though Validate Data still reports the copies OK.
}

--[[
How We Got the Data

Last Validated
	2026-10-16, WoW Forever 1.60.1.70425

Notes
	- Every item that heals instantly on the healthstone cooldown, keyed by the cooldown category Charged Crystal Focus (32578) uses, read by the item cache (Features/Item-Cache.lua) for the Healthstone and Health Potion macros. Healthstone Amount is the low end of the heal; Required Level is the level the tooltip requires (0 for none).
	- Alexander's Test Healthstone (30347) and Royal Guide of Escape Routes (43657) are left out, as the query below shows.
	- Mana gems and runes share the category but restore mana; they live in Mana-Gems-Camelot.lua. The Minor and Major Recombobulators restore health as a side effect of dispelling Polymorph and are reusable devices, so they are left out.
	- Night Dragon's Breath (11952) is left out on purpose, an oddball that shares the cooldown.
	- WoW Forever has no Improved Healthstone talent, so the talent stones (19004-19013) are left out; their deliberately-absent line in the table says so.
	- Lily Root (14894) is left out: its heal rose to 700 to 900, but its tooltip now says it needs Lei of Lillies equipped to be eaten, and the table has no column for that requirement. Lei of Lilies (1315) isn't in this client's item table on wago.tools (build 1.60.1.70425), so players almost certainly can't get it, and a macro offering Lily Root would do nothing. Every other folder keeps its Lily Root row; their clients state no such requirement.
	- Sprouted Frond's heal scales with the player's level; its row holds the heal at the spell's base level, which on this client is the base points times one minus half the variance (wago.tools, build 1.60.1.70425).
	- Season of Discovery items are left out even though this client knows many of their IDs (any ID of 200000 or more that the Classic Era tables also hold): they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

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
	https://wago.tools/db2/Item?build=1.60.1.70425
	https://wago.tools/db2/ItemSparse?build=1.60.1.70425
	https://wago.tools/db2/ItemEffect?build=1.60.1.70425
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70425
	https://wago.tools/db2/Spell?build=1.60.1.70425
	https://wago.tools/db2/SpellEffect?build=1.60.1.70425
	https://wago.tools/db2/SpellMisc?build=1.60.1.70425
	https://wago.tools/db2/SpellDuration?build=1.60.1.70425
	https://wago.tools/db2/SpellLevels?build=1.60.1.70425
]]
