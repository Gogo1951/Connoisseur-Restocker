local _, ns = ...

--[[
    Source: copied from Data/Wrath/Mana-Gems-Wrath.lua: the rows a Wrath
    client loaded from the pre-split shared tables, until a Mainline TOC ships
    and Validate Data runs there.

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

]]
-- [ID] = {Mana Amount}, -- Name
ns.MANA_GEMS = {
	[33312] = { 3330 }, -- Mana Sapphire
	[22044] = { 2340 }, -- Mana Emerald
	[8008] = { 1073 }, -- Mana Ruby
	[8007] = { 829 }, -- Mana Citrine
	[5513] = { 585 }, -- Mana Jade
	[5514] = { 390 }, -- Mana Agate
}

-- TODO: Add SQL Query
--[[
    Demonic and Dark Runes restore 900 to 1500 mana at the cost of 600 to 1000
    life, and they share the Mana Gems' cooldown. The Mana Gem macro ranks
    them in with the gems when the player opts in (see
    Features/Macros/Mana-Gem.lua). The mana column is the low end of the
    restore, the same convention as the gems above.

    The two restore the same amount, so the selection ladder's isSoulbound step
    burns the soulbound Demonic Rune before the tradeable Dark Rune.
]]
-- [ID] = {Mana Amount}, -- Name
ns.MANA_RUNES = {
	[20520] = { 900 }, -- Dark Rune
	[12662] = { 900 }, -- Demonic Rune
}
