local _, ns = ...

--[[
    Source: copied from Data/Vanilla/Bandages-Vanilla.lua until Validate Data
    passes on this client. Every row was checked against WoW Forever's own
    tables on wago.tools (build 1.60.1.70124), and the Crystal Infused and
    Darkspear Islands rows come from there, pending Validate Data. Darkspear
    Islands is area 16606, uiMapID 2524; the query below predates it.

    SELECT
        CONCAT(
            '    [',
            it.entry, '] = {',

            -- Dynamically calculates the Total Heal amount!
            (st.EffectBasePoints1 + 1) *
            CASE
                WHEN it.RequiredSkillRank < 50 THEN 6   -- Linen (6 ticks)
                WHEN it.RequiredSkillRank < 100 THEN 7  -- Wool (7 ticks)
                ELSE 8                                  -- Silk and above (8 ticks)
            END,

            ', ', it.RequiredSkillRank,
            ', ', it.SellPrice,

            -- Appends the optional Zone restrictions for Battlegrounds
            CASE
                WHEN it.entry IN (19307) THEN ', {1459}'
                WHEN it.entry IN (20065, 20066, 20067, 20232, 20234, 20235, 20237, 20243, 20244) THEN ', {1461}'
                WHEN it.entry IN (19066, 19067, 19068) THEN ', {1460}'
                ELSE ''
            END,

            '}, -- ', it.name
        ) AS `ns.RAW_DATA.Bandage`
    FROM item_template it
    JOIN spell_template st ON it.spellid_1 = st.Id
    WHERE it.class = 0
      AND it.subclass = 7
      AND it.spellid_1 > 0
      AND st.EffectBasePoints1 > 0
      AND it.entry NOT IN (38640, 44646)
    ORDER BY
      it.RequiredSkillRank DESC,
      it.entry DESC;

]]
-- [ID] = {Bandage Amount, First Aid Skill, Vendor Value, {Allowed Zones}}, -- Name
ns.BANDAGES = {
	[19307] = { 2000, 225, 100, { 1459 } }, -- Alterac Heavy Runecloth Bandage
	[20065] = { 1104, 175, 75, { 1461 } }, -- Arathi Basin Mageweave Bandage
	[20066] = { 2000, 225, 100, { 1461 } }, -- Arathi Basin Runecloth Bandage
	[20067] = { 640, 125, 50, { 1461 } }, -- Arathi Basin Silk Bandage
	[23684] = { 2500, 225, 1500 }, -- Crystal Infused Bandage
	[272057] = { 1104, 175, 75, { 2524 } }, -- Darkspear Islands Mageweave Bandage
	[272058] = { 2000, 225, 100, { 2524 } }, -- Darkspear Islands Runecloth Bandage
	[272056] = { 640, 125, 50, { 2524 } }, -- Darkspear Islands Silk Bandage
	[20232] = { 1104, 175, 75, { 1461 } }, -- Defiler's Mageweave Bandage
	[20234] = { 2000, 225, 100, { 1461 } }, -- Defiler's Runecloth Bandage
	[20235] = { 640, 125, 50, { 1461 } }, -- Defiler's Silk Bandage
	-- Dense Runecloth Bandage (232433) is deliberately absent; it is a Season of Discovery item that Validate Data still reports OK on Forever.
	[2581] = { 114, 20, 20 }, -- Heavy Linen Bandage
	[8545] = { 1104, 175, 600 }, -- Heavy Mageweave Bandage
	[14530] = { 2000, 225, 1000 }, -- Heavy Runecloth Bandage
	[6451] = { 640, 125, 400 }, -- Heavy Silk Bandage
	[3531] = { 301, 75, 57 }, -- Heavy Wool Bandage
	[20237] = { 1104, 175, 75, { 1461 } }, -- Highlander's Mageweave Bandage
	[20243] = { 2000, 225, 100, { 1461 } }, -- Highlander's Runecloth Bandage
	[20244] = { 640, 125, 50, { 1461 } }, -- Highlander's Silk Bandage
	[1251] = { 66, 1, 10 }, -- Linen Bandage
	[8544] = { 800, 150, 400 }, -- Mageweave Bandage
	[14529] = { 1360, 200, 500 }, -- Runecloth Bandage
	[6450] = { 400, 100, 200 }, -- Silk Bandage
	[19067] = { 1104, 175, 75, { 1460 } }, -- Warsong Gulch Mageweave Bandage
	[19066] = { 2000, 225, 100, { 1460 } }, -- Warsong Gulch Runecloth Bandage
	[19068] = { 640, 125, 50, { 1460 } }, -- Warsong Gulch Silk Bandage
	[3530] = { 161, 50, 28 }, -- Wool Bandage
	-- Dense Frostweave Bandage (38640) and Dalaran Bandage (44646) are deliberately absent; the query above excludes them too, so a regeneration will not bring them back.
}
