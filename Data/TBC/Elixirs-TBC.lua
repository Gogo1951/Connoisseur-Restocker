local _, ns = ...

-- { [buffSpellID] = true }, -- Flask Name
ns.FLASK_BUFF_IDS = {
	[28521] = true, -- Flask of Blinding Light
	[17629] = true, -- Flask of Chromatic Resistance
	[42735] = true, -- Flask of Chromatic Wonder
	[17627] = true, -- Flask of Distilled Wisdom
	[28518] = true, -- Flask of Fortification
	[28519] = true, -- Flask of Mighty Restoration
	[17624] = true, -- Flask of Petrification
	[28540] = true, -- Flask of Pure Death
	[28520] = true, -- Flask of Relentless Assault
	[17628] = true, -- Flask of Supreme Power
	[17626] = true, -- Flask of the Titans
	[46839] = true, -- Shattrath Flask of Blinding Light
	[41609] = true, -- Shattrath Flask of Fortification
	[41610] = true, -- Shattrath Flask of Mighty Restoration
	[46837] = true, -- Shattrath Flask of Pure Death
	[41608] = true, -- Shattrath Flask of Relentless Assault
	[41611] = true, -- Shattrath Flask of Supreme Power
	[40567] = true, -- Unstable Flask of the Bandit
	[40572] = true, -- Unstable Flask of the Beast
	[40568] = true, -- Unstable Flask of the Elder
	[40573] = true, -- Unstable Flask of the Physician
	[40575] = true, -- Unstable Flask of the Soldier
	[40576] = true, -- Unstable Flask of the Sorcerer
	[33053] = true, -- (buff with no matching item)
}

-- { [buffSpellID] = true }, -- Elixir Name
ns.ELIXIR_BUFF_IDS = {
	[11390] = true, -- Arcane Elixir
	[45373] = true, -- Bloodberry Elixir
	[27653] = true, -- Bloodkelp Elixir of Dodging
	[27652] = true, -- Bloodkelp Elixir of Resistance
	[10692] = true, -- Cerebral Cortex Compound
	[15231] = true, -- Crystal Force
	[15233] = true, -- Crystal Ward
	[11328] = true, -- Deprecated Alchemy Elixir Template
	[39626] = true, -- Earthen Elixir
	[17537] = true, -- Elixir of Brute Force
	[3220] = true, -- Elixir of Defense
	[11406] = true, -- Elixir of Demonslaying
	[39627] = true, -- Elixir of Draenic Wisdom
	[28514] = true, -- Elixir of Empowerment
	[7844] = true, -- Elixir of Firepower
	[3593] = true, -- Elixir of Fortitude
	[21920] = true, -- Elixir of Frost Power
	[8212] = true, -- Elixir of Giant Growth
	[11405] = true, -- Elixir of Giants
	[11334] = true, -- Elixir of Greater Agility
	[11349] = true, -- Elixir of Greater Defense
	[26276] = true, -- Elixir of Greater Firepower
	[11396] = true, -- Elixir of Greater Intellect
	[28491] = true, -- Elixir of Healing Power
	[39628] = true, -- Elixir of Ironskin
	[3160] = true, -- Elixir of Lesser Agility
	[2367] = true, -- Elixir of Lion's Strength
	[28502] = true, -- Elixir of Major Defense
	[28501] = true, -- Elixir of Major Firepower
	[39625] = true, -- Elixir of Major Fortitude
	[28493] = true, -- Elixir of Major Frost Power
	[28509] = true, -- Elixir of Major Mageblood
	[28503] = true, -- Elixir of Major Shadow Power
	[28490] = true, -- Elixir of Major Strength
	[33726] = true, -- Elixir of Mastery
	[28497] = true, -- Elixir of Mighty Agility
	[2374] = true, -- Elixir of Minor Agility
	[673] = true, -- Elixir of Minor Defense
	[2378] = true, -- Elixir of Minor Fortitude
	[3164] = true, -- Elixir of Ogre's Strength
	[11474] = true, -- Elixir of Shadow Power
	[11348] = true, -- Elixir of Superior Defense
	[17538] = true, -- Elixir of the Mongoose
	[17535] = true, -- Elixir of the Sages
	[11319] = true, -- Elixir of Water Walking
	[3166] = true, -- Elixir of Wisdom
	[38954] = true, -- Fel Strength Elixir
	[11371] = true, -- Gift of Arthas
	[10693] = true, -- Gizzard Gum
	[29348] = true, -- Goldenmist Special Brew
	[17539] = true, -- Greater Arcane Elixir
	[10669] = true, -- Ground Scorpok Assay
	[16325] = true, -- Juju Chill
	[16326] = true, -- Juju Ember
	[16321] = true, -- Juju Escape
	[16322] = true, -- Juju Flurry
	[16327] = true, -- Juju Guile
	[16329] = true, -- Juju Might
	[16323] = true, -- Juju Power
	[10668] = true, -- Lung Juice Cocktail
	[24363] = true, -- Mageblood Elixir
	[11364] = true, -- Magic Resistance Potion
	[3223] = true, -- Major Troll's Blood Elixir
	[24361] = true, -- Mighty Troll's Blood Elixir
	[2380] = true, -- Minor Magic Resistance Potion
	[33720] = true, -- Onslaught Elixir
	[10667] = true, -- R.O.I.D.S.
	[28486] = true, -- Scourgebane Draught
	[28488] = true, -- Scourgebane Infusion
	[24417] = true, -- Sheen of Zanza
	[33721] = true, -- Adept's Elixir
	[24382] = true, -- Spirit of Zanza
	[3222] = true, -- Strong Troll's Blood Elixir
	[24383] = true, -- Swiftness of Zanza
	[3219] = true, -- Weak Troll's Blood Elixir
	[17038] = true, -- Winterfall Firewater
}

--[[
How We Got the Data

Last Validated
	2026-10-23, TBC Anniversary 2.5.6.70006

Notes
	- What counts as being flasked, for the Readiness Report's Flask or 2x Elixirs check (Features/Readiness-Report-Probes.lua): a flask, OR two different elixirs. Two different elixirs is the whole test, and it is enough because the client enforces the rest: from TBC on, a character may carry one battle and one guardian elixir at a time, so any two elixir auras up together are already one of each. Nothing here needs to know which kind an elixir is, which is why neither table carries that column; it can't be read off an aura at runtime.
	- Keyed by the BUFF's spell ID, not the item's: the report reads the player's auras, and several items share one buff while a few grant a buff whose ID doesn't match the item. That is also why the source query is deduped by spell on the way in. Each row's comment names the item that grants the buff.
	- The source is the server's spell_elixir table, not the item tables: its mask is the only thing that separates a battle or guardian elixir (masks 1 and 2, both collected) from a utility one. Water Breathing and Noggenfogger are elixirs by item subclass but appear in no mask, which is right: they occupy no elixir slot, and counting them would call a player with water breathing and Noggenfogger fully flasked.
	- Flasks are masks 3, 7 and 11 (plain, Unstable, Shattrath), unioned with the flask items the item pass found. The union errs toward silence on purpose: an ID here that isn't really a flask only keeps the report quiet, while a missing one nags a player who IS flasked, the failure that gets a switch turned off for good.
	- Season of Discovery items are left out; this client doesn't know them. They live only in Data/Discovery/.

SQL (CMaNGOS)
	Database not recorded.

	SELECT se.mask, se.entry AS buffSpellId, it.name
	FROM spell_elixir se
	LEFT JOIN item_template it ON it.spellid_1 = se.entry
	ORDER BY se.mask, it.name;

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=2.5.6.70006
	https://wago.tools/db2/ItemSparse?build=2.5.6.70006
	https://wago.tools/db2/ItemEffect?build=2.5.6.70006
	https://wago.tools/db2/Spell?build=2.5.6.70006
	https://wago.tools/db2/SpellEffect?build=2.5.6.70006
	https://wago.tools/db2/SpellMisc?build=2.5.6.70006
	https://wago.tools/db2/SpellDuration?build=2.5.6.70006
	https://wago.tools/db2/SpellCategories?build=2.5.6.70006

QuestieDB
	None.
]]
