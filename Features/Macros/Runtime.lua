local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Macro Runtime Globals
--------------------------------------------------------------------------------

--[[
    Macro-callback globals.

    These are intentionally GLOBAL — macro bodies invoke them through `/run`,
    which executes in the global environment and cannot see the add-on
    namespace. The names a written macro body reaches through /run are among
    the globals the house rules allow; each carries the distinctive
    "Connoisseur" prefix to keep collision risk negligible.

    They are the runtime half of the macro system: the macro builders emit
    `/run ConnoisseurFire / ConnoisseurTip / ConnoisseurTipIf /
    ConnoisseurNoItem` lines, and these functions run when the player presses
    the macro. This file loads after Announcements (ConnoisseurTip and
    ConnoisseurNoItem call ns.PrintMessage) and after Data (reads
    ns.TIP_MESSAGES, ns.MISSING_SPELL_MESSAGE_IDS, ns.MACRO_CONFIG).
]]

--[[
    Transport between the /run snippet in consumable macros and
    ns.OnMacroUiErrorMessage below, which Core routes UI_ERROR_MESSAGE to. The
    macro writes lastID and lastTime so a zone-restriction error can be
    correlated back to its triggering item.
]]
local macroFireState = {}

--[[
    Records the firing item with `/run ConnoisseurFire(itemID)` instead of inlining a
    longer snippet: every standard body with an item in bags carries the call, so the
    saved bytes count against the 255 macro-body ceiling in every consumable macro.

    A potion body that eats or drinks out of combat (Body-Builder's
    OutOfCombatBlock) passes that food or water as outOfCombatID, and the same
    [combat] test the body's own lines use picks which of the two the press
    fires. With no potion in bags the body passes the food alone.
]]
function ConnoisseurFire(itemID, outOfCombatID)
	if outOfCombatID and not UnitAffectingCombat("player") then
		itemID = outOfCombatID
	end
	macroFireState.lastID = itemID
	macroFireState.lastTime = GetTime()
end

--[[
    Consumer half of the macroFireState transport: when a consumable macro
    fires, ConnoisseurFire() above stamps lastID/lastTime. If ERR_ITEM_WRONG_ZONE
    arrives within one second, we know which item to blame and print a bug
    report naming it. Core's dispatcher routes UI_ERROR_MESSAGE here ahead of
    its combat-lockdown guard, since a zone-locked potion is usually pressed
    mid-fight.
]]
function ns.OnMacroUiErrorMessage(message)
	if not (macroFireState.lastTime and (GetTime() - macroFireState.lastTime) < 1.0) then
		return
	end
	if message ~= ERR_ITEM_WRONG_ZONE then
		return
	end

	local mapID = C_Map.GetBestMapForUnit("player") or "0"
	local zone = GetZoneText() or "?"
	local subzone = GetSubZoneText() or ""
	if subzone == "" then
		subzone = zone
	end

	local itemID = macroFireState.lastID or 0
	local link = ns.GetItemHyperlink(itemID)

	ns.PrintMessage(string.format(L["MESSAGE_BUG_REPORT"], link, itemID, zone, subzone, mapID, ns.DISCORD_URL))
	macroFireState.lastTime = 0
end

--[[
    Resolves a ConnoisseurTip key to its display text. Static messages come from
    ns.TIP_MESSAGES; "you don't know <spell>" keys come from
    ns.MISSING_SPELL_MESSAGE_IDS and are rendered with the localized spell name via
    C_Spell.GetSpellName at print time, as is noPetSkills from the four pet spells it
    names. A spell that doesn't exist on the current client returns nil here so
    ConnoisseurTip silently skips rather than naming a spell the player will never see.
]]
local PET_SKILL_SPELL_IDS = {
	ns.CALL_PET_SPELL_ID,
	ns.DISMISS_PET_SPELL_ID,
	ns.FEED_PET_SPELL_ID,
	ns.REVIVE_PET_SPELL_ID,
}

local function ResolvePetSkillsTip()
	local names = {}
	for index = 1, 4 do
		local spellID = PET_SKILL_SPELL_IDS[index]
		names[index] = spellID and C_Spell.GetSpellName(spellID)
		if not names[index] then
			return nil
		end
	end
	return string.format(L["TIP_PET_NO_SKILLS_FORMAT"], unpack(names))
end

local function ResolveTipText(key)
	if ns.TIP_MESSAGES[key] then
		return ns.TIP_MESSAGES[key]
	end
	if key == "noPetSkills" then
		return ResolvePetSkillsTip()
	end
	if ns.MISSING_SPELL_MESSAGE_IDS[key] then
		local name = C_Spell.GetSpellName(ns.MISSING_SPELL_MESSAGE_IDS[key])
		if not name then
			return nil
		end
		return string.format(L["TIP_DONT_KNOW_SPELL"], name)
	end
	return nil
end

function ConnoisseurTip(key)
	local text = ResolveTipText(key)
	if text then
		ns.PrintMessage(text)
	end
end

--[[
    Conditional sibling of ConnoisseurTip — fires the tip only when the macro
    conditional `condition` matches. The conjure block uses it for a click whose
    spell is not learned yet, the Poisons macro for a hand with no poison, and
    the Feed Pet macro for level-10/11 hunters who don't know Mend Pet yet, so
    those clicks print an explanation instead of silently doing nothing useful. We append a
    sentinel " 1" so SecureCmdOptionParse returns "1" on match and nil on miss —
    clean truthy/falsy semantics regardless of how the API treats an empty
    action body.
]]
function ConnoisseurTipIf(condition, key)
	if SecureCmdOptionParse(condition .. " 1") then
		ConnoisseurTip(key)
	end
end

--[[
    Prints the standardized "no suitable <type> found" chat line. Macro bodies
    call this with the internal type key (`/run ConnoisseurNoItem("Food")`). The key
    stays English inside the macro body (keeps bodies and state keys
    locale-independent) and resolves to the localized LABEL_* string via
    ns.MACRO_CONFIG at print time. Unknown keys fall back to the raw key so a stale
    macro body from an older version still prints something sensible.
]]
function ConnoisseurNoItem(typeName)
	local config = ns.MACRO_CONFIG[typeName]
	local label = config and config.label or typeName
	ns.PrintMessage(string.format(L["MESSAGE_NO_ITEM"], label))
end

-- MIGRATION (remove after 2026-10-18)
--[[
    A macro body saved by an older build still calls the short names with the
    short tip keys until the add-on next rewrites it, so the short names stay
    callable and translate their keys.
]]
local RENAMED_TIP_KEYS = {
	nofood = "noPetFood",
	noskills = "noPetSkills",
	nomend = "noMendPet",
	nopois = "noHandPoison",
	ncwater = "noConjureWater",
	ncfood = "noConjureFood",
	ncgem = "noConjureManaGem",
	nctable = "noRitualOfRefreshment",
	nchs = "noCreateHealthstone",
	ncss = "noCreateSoulstone",
	ncsw = "noRitualOfSouls",
	npois = "noPoisonsSkill",
}

ConnFire = ConnoisseurFire
ConnNoItem = ConnoisseurNoItem

function ConnTip(key)
	ConnoisseurTip(RENAMED_TIP_KEYS[key] or key)
end

function ConnIf(condition, key)
	ConnoisseurTipIf(condition, RENAMED_TIP_KEYS[key] or key)
end
