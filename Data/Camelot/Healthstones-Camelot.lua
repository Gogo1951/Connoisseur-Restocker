local _, ns = ...

--[[
    Source: copied from Data/Vanilla/Healthstones-Vanilla.lua until Validate
    Data passes on this client. The five Healthstone amounts came from the
    wago.tools tables for build 1.60.1.69977, and Validate Data on build
    1.60.1.70124 confirmed them.

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

]]
-- [ID] = {Healthstone Amount, Required Level}, -- Name
ns.HEALTHSTONES = {
	[9421] = { 1440, 48 }, -- Major Healthstone
	[15723] = { 1050, 50 }, -- Tea with Sugar
	[5510] = { 960, 36 }, -- Greater Healthstone
	[11951] = { 700, 45 }, -- Whipper Root Tuber
	[5509] = { 600, 24 }, -- Healthstone
	[14894] = { 525, 0 }, -- Lily Root
	[5511] = { 300, 12 }, -- Lesser Healthstone
	[5512] = { 120, 1 }, -- Minor Healthstone
	[5205] = { 71, 5 }, -- Sprouted Frond
	-- The Improved Healthstone copies of each stone (19004 to 19013) are deliberately absent; Forever removed that talent and raised each base stone to its top copy's amount, though Validate Data still reports the copies OK.
}
