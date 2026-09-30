local _, ns = ...

--[[
    Source: copied from Data/Wrath/Explosives-Wrath.lua: the rows a Wrath
    client loaded from the pre-split shared tables, until a Mainline TOC ships
    and Validate Data runs there.

    SELECT CONCAT(
        '[', entry, '] = {',
        MinDamage, ', ', MaxDamage, ', ', RequiredSkillRank,
        CASE WHEN requiredspell <> 0 THEN CONCAT(', ', requiredspell) ELSE '' END,
        '}, -- ', name
    ) AS LuaLine
    FROM (
        SELECT
          i.entry, i.name, i.RequiredSkillRank, i.requiredspell,
          CASE
            WHEN s.Effect1 = 2 THEN s.EffectBasePoints1 + 1
            WHEN s.Effect2 = 2 THEN s.EffectBasePoints2 + 1
            WHEN s.Effect3 = 2 THEN s.EffectBasePoints3 + 1
          END AS MinDamage,
          CASE
            WHEN s.Effect1 = 2 THEN s.EffectBasePoints1 + s.EffectDieSides1
            WHEN s.Effect2 = 2 THEN s.EffectBasePoints2 + s.EffectDieSides2
            WHEN s.Effect3 = 2 THEN s.EffectBasePoints3 + s.EffectDieSides3
          END AS MaxDamage
        FROM item_template i
        JOIN spell_template s ON s.Id = i.spellid_1
        JOIN (
            SELECT spellcategory_1 AS cat, class AS cls, subclass AS sub
            FROM item_template WHERE entry = 4365
        ) ref
          ON i.spellcategory_1 = ref.cat AND i.class = ref.cls AND i.subclass = ref.sub
        WHERE i.name NOT LIKE '%Test%'
          AND i.name NOT LIKE '%[PH]%'
          AND (s.Effect1 = 2 OR s.Effect2 = 2 OR s.Effect3 = 2)
    ) t
    ORDER BY name;
]]
-- [ID] = {Min Damage, Max Damage, Engineering Skill, Required Spell ID}, -- Name
ns.EXPLOSIVES = {
	[23737] = { 450, 750, 325 }, -- Adamantite Grenade
	[4380] = { 85, 115, 140 }, -- Big Bronze Bomb
	[4394] = { 149, 201, 190 }, -- Big Iron Bomb
	[4365] = { 51, 69, 75 }, -- Coarse Dynamite
	[40771] = { 750, 1000, 330 }, -- Cobalt Frag Bomb
	[50422] = { 225, 675, 0 }, -- Crafty Bomb
	[16005] = { 225, 675, 285 }, -- Dark Iron Bomb
	[18641] = { 340, 460, 250 }, -- Dense Dynamite
	[6714] = { 51, 69, 0 }, -- Ez-Thro Dynamite
	[18588] = { 213, 287, 0 }, -- Ez-Thro Dynamite II
	[23736] = { 330, 770, 300 }, -- Fel Iron Bomb
	[32413] = { 75, 125, 325 }, -- Frost Grenade
	[42641] = { 2188, 2812, 400, 20222 }, -- Global Thermal Sapper Charge
	[10646] = { 450, 750, 205 }, -- Goblin Sapper Charge
	[4378] = { 128, 172, 125 }, -- Heavy Dynamite
	[10562] = { 255, 345, 235 }, -- Hi-Explosive Bomb
	[4390] = { 132, 218, 175 }, -- Iron Grenade
	[4370] = { 43, 57, 105 }, -- Large Copper Bomb
	[10514] = { 149, 201, 205 }, -- Mithril Frag Bomb
	[4360] = { 22, 28, 30 }, -- Rough Copper Bomb
	[4358] = { 26, 34, 1 }, -- Rough Dynamite
	[41119] = { 1150, 1500, 350 }, -- Saronite Bomb
	[44598] = { 75, 125, 375 }, -- Shrapnel Grenade
	[4374] = { 73, 97, 120 }, -- Small Bronze Bomb
	[10507] = { 213, 287, 175 }, -- Solid Dynamite
	[23827] = { 900, 1500, 340 }, -- Super Sapper Charge
	[10586] = { 340, 460, 225 }, -- The Big One
	[23826] = { 600, 1000, 325 }, -- The Bigger One
	[15993] = { 300, 500, 260 }, -- Thorium Grenade
}
