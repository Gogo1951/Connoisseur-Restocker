local _, ns = ...

-- { [buffSpellID] = true }, -- Flask Name
ns.FLASK_BUFF_IDS = {
	[17629] = true, -- Flask of Chromatic Resistance
	[17627] = true, -- Flask of Distilled Wisdom
	[17624] = true, -- Flask of Petrification
	[17628] = true, -- Flask of Supreme Power
	[17626] = true, -- Flask of the Titans
	[1293740] = true, -- Flask of Natural Accuracy
	[1293741] = true, -- Flask of Natural Aggression
	[1293742] = true, -- Flask of Natural Precision
	[1293743] = true, -- Flask of Natural Swiftness
}

-- { [buffSpellID] = true }, -- Elixir Name
ns.ELIXIR_BUFF_IDS = {
	[11390] = true, -- Arcane Elixir
	[27653] = true, -- Bloodkelp Elixir of Dodging
	[27652] = true, -- Bloodkelp Elixir of Resistance
	[10692] = true, -- Cerebral Cortex Compound
	[15231] = true, -- Crystal Force
	[15233] = true, -- Crystal Ward
	[11328] = true, -- Elixir of Agility
	[17537] = true, -- Elixir of Brute Force
	[3220] = true, -- Elixir of Lesser Defense
	[11406] = true, -- Potion of Demon Slaying
	[7844] = true, -- Elixir of Fire Power
	[3593] = true, -- Elixir of Lesser Fortitude
	[21920] = true, -- Elixir of Frost Power
	[8212] = true, -- Elixir of Giant Growth
	[11405] = true, -- Elixir of Greater Strength
	[11334] = true, -- Elixir of Greater Agility
	[11349] = true, -- Elixir of Defense
	[26276] = true, -- Greater Firepower (no Forever item grants it: Elixir of Greater Firepower became Elixir of Holy Power)
	[11396] = true, -- Elixir of Greater Intellect
	[3160] = true, -- Elixir of Lesser Agility
	[2367] = true, -- Elixir of Minor Strength
	[2374] = true, -- Elixir of Minor Agility
	[673] = true, -- Elixir of Minor Defense
	[2378] = true, -- Elixir of Minor Fortitude
	[3164] = true, -- Elixir of Ogre Strength
	[11474] = true, -- Elixir of Shadow Power
	[11348] = true, -- Elixir of Greater Defense
	[17538] = true, -- Elixir of the Mongoose
	[17535] = true, -- Elixir of the Sages
	[11319] = true, -- Draught of Water Walking
	[3166] = true, -- Elixir of Wisdom
	[11371] = true, -- Gift of Arthas
	[10693] = true, -- Gizzard Gum
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
	[3223] = true, -- Troll's Blood Elixir
	[24361] = true, -- Major Troll's Blood Elixir
	[2380] = true, -- Minor Magic Resistance Potion
	[10667] = true, -- R.O.I.D.S.
	[24417] = true, -- Sheen of Zanza
	[24382] = true, -- Spirit of Zanza
	[3222] = true, -- Lesser Troll's Blood Elixir
	[24383] = true, -- Swiftness of Zanza
	[3219] = true, -- Minor Troll's Blood Elixir
	[17038] = true, -- Winterfall Firewater
	[1245244] = true, -- Minor Arcane Elixir
	[1245249] = true, -- Elixir of Minor Force
	[1250918] = true, -- Elixir of Cunning
	[1250920] = true, -- Elixir of the Phalanx
	[1250922] = true, -- Minor Cleric's Elixir
	[1250924] = true, -- Lesser Cleric's Elixir
	[1250925] = true, -- Cleric's Elixir
	[1250926] = true, -- Greater Cleric's Elixir
	[1250928] = true, -- Elixir of Fortitude
	[1250931] = true, -- Elixir of Greater Fortitude
	[1250932] = true, -- Elixir of Wicked Regeneration
	[1250940] = true, -- Elixir of the Owl
	[1250941] = true, -- Elixir of Sages
	[1250942] = true, -- Minor Mageblood Elixir
	[1250944] = true, -- Lesser Mageblood Elixir
	[1250948] = true, -- Greater Mageblood Elixir
	[1250971] = true, -- Lesser Arcane Elixir
	[1250972] = true, -- Elixir of Nature Power
	[1250974] = true, -- Elixir of Minor Spirit
	[1250976] = true, -- Elixir of Lesser Spirit
	[1250978] = true, -- Elixir of Spirit
	[1250979] = true, -- Elixir of Greater Spirit
	[1250981] = true, -- Elixir of the Whale
	[1250984] = true, -- Elixir of Strength
	[1250985] = true, -- Elixir of Ferocity
	[1250986] = true, -- Elixir of the Grizzly
	[1250988] = true, -- Elixir of Lesser Intellect
	[1250989] = true, -- Elixir of Intellect
	[1310077] = true, -- Elixir of Holy Power
}

--[[
How We Got the Data

Last Validated
	2026-10-16, WoW Forever 1.60.1.70425

Notes
	- What counts as being flasked, for the Readiness Report's Flask or 2x Elixirs check (Features/Readiness-Report-Probes.lua): a flask, OR two different elixirs. Two different elixirs is the whole test, and it is enough because the client enforces the rest: from TBC on, a character may carry one battle and one guardian elixir at a time, so any two elixir auras up together are already one of each. Nothing here needs to know which kind an elixir is, which is why neither table carries that column; it can't be read off an aura at runtime.
	- Keyed by the BUFF's spell ID, not the item's: the report reads the player's auras, and several items share one buff while a few grant a buff whose ID doesn't match the item. That is also why the source query is deduped by spell on the way in. Each row's comment names the item that grants the buff.
	- The source is the server's spell_elixir table, not the item tables: its mask is the only thing that separates a battle or guardian elixir (masks 1 and 2, both collected) from a utility one. Water Breathing and Noggenfogger are elixirs by item subclass but appear in no mask, which is right: they occupy no elixir slot, and counting them would call a player with water breathing and Noggenfogger fully flasked.
	- Flasks are masks 3, 7 and 11 (plain, Unstable, Shattrath), unioned with the flask items the item pass found. The union errs toward silence on purpose: an ID here that isn't really a flask only keeps the report quiet, while a missing one nags a player who IS flasked, the failure that gets a switch turned off for good.
	- The buffs of WoW Forever's own elixirs and flasks (IDs above 1240000) are each item's use spell in this client's tables on wago.tools. Flask of Petrification (17624) is here because this client's text for it says only one flask works at a time. Elixir of Greater Firepower became Elixir of Holy Power (buff 1310077) on this client.
	- Lesser Arcane Elixir (217398) is left out: it is a Season of Discovery item this client also knows.
	- Season of Discovery items are left out even though this client knows many of their IDs (any ID of 200000 or more that the Classic Era tables also hold): they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

SQL (CMaNGOS)
	Database not recorded.

	SELECT se.mask, se.entry AS buffSpellId, it.name
	FROM spell_elixir se
	LEFT JOIN item_template it ON it.spellid_1 = se.entry
	ORDER BY se.mask, it.name;

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
	https://wago.tools/db2/SpellCategories?build=1.60.1.70425
]]
