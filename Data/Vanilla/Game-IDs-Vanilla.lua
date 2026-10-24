local _, ns = ...

if ns.IS_DISCOVERY then
	return
end

-- Stealth Abilities
ns.SHADOWMELD_SPELL_ID = 20580

ns.STEALTH_SPELL_ID = 1784

-- Cannibalize (Forsaken)
ns.CANNIBALIZE_SPELL_ID = 20577
ns.CANNIBALIZE_CREATURE_TYPE_IDS = { 6, 7 }
ns.CANNIBALIZE_RESTORES_MANA = false

-- Races
ns.NIGHT_ELF_RACE_ID = 4

-- Druid Forms
ns.DRUID_DIRE_BEAR_FORM_SPELL_ID = 9634
ns.DRUID_BEAR_FORM_SPELL_ID = 5487
ns.DRUID_CAT_FORM_SPELL_ID = 768

-- Rogue Poisons Skill
ns.POISONS_SPELL_ID = 2842

-- Hunter Pet Spells
ns.CALL_PET_SPELL_ID = 883
ns.DISMISS_PET_SPELL_ID = 2641
ns.FEED_PET_SPELL_ID = 6991
ns.MEND_PET_SPELL_ID = 136
ns.REVIVE_PET_SPELL_ID = 982

-- Well Fed Buff
-- A "Well Fed" food buff, read for the buff's name; it is named Well Fed in every locale on every client.
ns.WELL_FED_SPELL_ID = 19705

-- Mana Runes
-- The two runes the Mana Gem panel names, read for their names.
ns.DEMONIC_RUNE_ITEM_ID = 12662
ns.DARK_RUNE_ITEM_ID = 20520

-- Pet Buff Food
-- [itemID] = { buffSpellID, rank, settingKey, requiredLevel }, -- Item Name
ns.PET_BUFF_FOODS = {}

-- Professions
-- The profession skill lines the usability gates read ranks from. Each is found
-- in the skill list by the name the client gives its ID.
ns.FIRST_AID_SKILL_LINE_ID = 129
ns.ALCHEMY_SKILL_LINE_ID = 171
ns.ENGINEERING_SKILL_LINE_ID = 202

-- The Engineering specialization Diagnostics checks the player for.
ns.GOBLIN_ENGINEER_SPELL_ID = 20222

--[[
How We Got the Data

Last Validated
	2026-10-23, Classic Era 1.15.9.70003

Notes
	- Single spell, item, race and skill-line IDs the feature code reads by name, grouped by use. The client supplies every name the player sees from these IDs.
	- Shadowmeld and Stealth are the spells the Food and Water macros cast for Stealth Eating and Shadowmeld Drinking. Stealth is rank 1: C_Spell.GetSpellName resolves the base name "Stealth", which a bare /cast fires at the highest rank the rogue knows.
	- Cannibalize is the Forsaken racial, which channels off a corpse of the creature types listed (6 Undead, 7 Humanoid). It restores health only on this client, so CANNIBALIZE_RESTORES_MANA decides whether the Water macro may cast it.
	- Poisons (2842) is the rogue poison-crafting skill, the same ID on Era and TBC. Knowing it gates the Poisons macro (a rogue without it can't apply poisons at all) and provides the middle-click crafting branch.
	- Well Fed (19705) is read for the buff's name, which is Well Fed in every locale on every client. The two mana runes are read for the names the Mana Gem panel shows.
	- ns.PET_BUFF_FOODS holds the Hunter and Warlock pet buff foods: the pet-buff override offers the highest rank the bags hold, settingKey names each food's petBuffTypes toggle, and requiredLevel is the level a player needs before the food is offered. This client has none.
	- The profession skill lines are the ones the usability gates read ranks from; each is found in the skill list by the name the client gives its ID. The Goblin Engineer specialization is what Diagnostics checks the player for.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/SpellName?build=1.15.9.70003
	https://wago.tools/db2/ItemSparse?build=1.15.9.70003

QuestieDB
	None.
]]
