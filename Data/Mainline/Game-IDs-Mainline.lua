local _, ns = ...

--[[
    Source: copied from Data/TBC/Game-IDs-TBC.lua until Validate Data passes on
    this client.
]]

--------------------------------------------------------------------------------
-- Stealth Abilities
--------------------------------------------------------------------------------

ns.SHADOWMELD_SPELL_ID = 20580

--[[
    Rogue Stealth, rank 1. C_Spell.GetSpellName resolves the base name "Stealth", which
    a bare /cast fires at the highest rank the rogue knows (Stealth Eating).
]]
ns.STEALTH_SPELL_ID = 1784

--------------------------------------------------------------------------------
-- Druid Forms
--------------------------------------------------------------------------------

ns.DRUID_DIRE_BEAR_FORM_SPELL_ID = 9634
ns.DRUID_BEAR_FORM_SPELL_ID = 5487
ns.DRUID_CAT_FORM_SPELL_ID = 768

--------------------------------------------------------------------------------
-- Rogue Poisons Skill
--------------------------------------------------------------------------------

--[[
    "Poisons" (spell 2842) — the rogue poison-crafting skill; the same ID on
    Era and TBC. Knowing it gates the Poisons macro (a rogue without it can't
    apply poisons at all) and provides the middle-click crafting branch.
]]
ns.POISONS_SPELL_ID = 2842

--------------------------------------------------------------------------------
-- Hunter Pet Spells
--------------------------------------------------------------------------------

ns.CALL_PET_SPELL_ID = 883
ns.DISMISS_PET_SPELL_ID = 2641
ns.FEED_PET_SPELL_ID = 6991
ns.MEND_PET_SPELL_ID = 136
ns.REVIVE_PET_SPELL_ID = 982

--------------------------------------------------------------------------------
-- Well Fed Buff
--------------------------------------------------------------------------------

-- A "Well Fed" food buff, read for the buff's name; it is named Well Fed in every locale on every client.
ns.WELL_FED_SPELL_ID = 19705

--------------------------------------------------------------------------------
-- Mana Runes
--------------------------------------------------------------------------------

-- The two runes the Mana Gem panel names, read for their names.
ns.DEMONIC_RUNE_ITEM_ID = 12662
ns.DARK_RUNE_ITEM_ID = 20520

--------------------------------------------------------------------------------
-- Pet Buff Food
--------------------------------------------------------------------------------

--[[
    Hunter and Warlock pet buff foods. The pet-buff override offers the highest
    rank the bags hold, settingKey names each food's petBuffTypes toggle, and
    requiredLevel is the level a player needs before the food is offered.
]]
-- [itemID] = { buffSpellID, rank, settingKey, requiredLevel }, -- Item Name
ns.PET_BUFF_FOODS = {
	[33874] = { 43771, 2, "KiblersBits", 55 }, -- Kibler's Bits
	[27656] = { 33272, 1, "SporelingSnacks", 55 }, -- Sporeling Snacks
}

--------------------------------------------------------------------------------
-- Professions
--------------------------------------------------------------------------------

-- The profession skill lines the usability gates read ranks from. Each is found
-- in the skill list by the name the client gives its ID.
ns.FIRST_AID_SKILL_LINE_ID = 129
ns.ALCHEMY_SKILL_LINE_ID = 171
ns.ENGINEERING_SKILL_LINE_ID = 202

-- The Engineering specialization Diagnostics checks the player for.
ns.GOBLIN_ENGINEER_SPELL_ID = 20222
