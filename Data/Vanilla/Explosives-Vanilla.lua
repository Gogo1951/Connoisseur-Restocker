local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- [ID] = {Min Damage, Max Damage, Engineering Skill, Required Spell ID}, -- Name
ns.EXPLOSIVES = {
	[4380] = { 85, 115, 140 }, -- Big Bronze Bomb
	[4394] = { 149, 201, 190 }, -- Big Iron Bomb
	[4365] = { 51, 69, 75 }, -- Coarse Dynamite
	[16005] = { 225, 675, 285 }, -- Dark Iron Bomb
	[18641] = { 340, 460, 250 }, -- Dense Dynamite
	[6714] = { 51, 69, 0 }, -- Ez-Thro Dynamite
	[18588] = { 213, 287, 0 }, -- Ez-Thro Dynamite II
	[10646] = { 450, 750, 205 }, -- Goblin Sapper Charge
	[4378] = { 128, 172, 125 }, -- Heavy Dynamite
	[10562] = { 255, 345, 235 }, -- Hi-Explosive Bomb
	[4390] = { 132, 218, 175 }, -- Iron Grenade
	[4370] = { 43, 57, 105 }, -- Large Copper Bomb
	[10514] = { 149, 201, 205 }, -- Mithril Frag Bomb
	[4360] = { 22, 28, 30 }, -- Rough Copper Bomb
	[4358] = { 26, 34, 1 }, -- Rough Dynamite
	[4374] = { 73, 97, 120 }, -- Small Bronze Bomb
	[10507] = { 213, 287, 175 }, -- Solid Dynamite
	[10586] = { 340, 460, 225 }, -- The Big One
	[15993] = { 300, 500, 260 }, -- Thorium Grenade
}

--[[
How We Got the Data

Last Validated
	2026-10-23, Classic Era 1.15.9.70003

Notes
	- Every Engineering explosive this client knows that deals damage, read by the item cache (Features/Item-Cache.lua) for the Explosive macro. The family is the items sharing Coarse Dynamite's (4365) use category and its class and subclass (Trade Goods, Explosives).
	- Min Damage and Max Damage are the use spell's damage range. Engineering Skill is the rank the tooltip requires (0 for none). Required Spell ID, where present, is the Goblin or Gnomish specialization the item needs; no row on this client carries one.
	- Items that share the explosive cooldown but aren't crafted explosives are left out: the Portable Bronze Mortar (a reusable device), Goblin Fishing Pole, Flash Bundle, Explosive Rocket, Magic Candle, Brimstone, Fertile Bulb, M73 Frag Grenade, and the quest items (Crystal Charge, the Holy Waters). Test Sapper Charge (23418) fits the family but is a test item nothing drops, sells or makes.
	- Season of Discovery items are left out even though this client knows their IDs: they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

SQL (CMaNGOS)
	Database not recorded.

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

QuestieDB
	https://raw.githubusercontent.com/Questie/QuestieDB/master/data/Classic/classicItemDB.lua
]]
