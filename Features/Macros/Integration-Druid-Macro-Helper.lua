local _, ns = ...

--------------------------------------------------------------------------------
-- DruidMacroHelper Integration
--------------------------------------------------------------------------------

--[[
    When the Druid toggle is on, HP/MP/HS macros are rewritten to use DMH
    syntax so the druid powershifts out of form, /uses the consumable, and
    shifts back into the form chosen by settings.druidReturnForm (bear or
    cat). Hard-coded rather than auto-tracked: macros can't be edited
    during combat, so a mid-combat form swap on an auto-tracking macro
    could return the druid to the wrong form.

    Eligible macro types and guard prefixes both live in Data.lua
    (ns.DRUID_MACRO_HELPER_TYPES, ns.DRUID_MACRO_HELPER_GUARDS) so the data is shared and not buried
    here.
]]

local function ShouldUseDruidMacroHelper(typeName)
	if not ns.isDruid then
		return false
	end
	if not ns.DRUID_MACRO_HELPER_TYPES[typeName] then
		return false
	end
	local settings = ns.db and ns.db.profile
	return settings and settings.enableDruidMacroHelper and true or false
end

--[[
    Best first. The client names every one of these spells whether or not the
    druid has learned it, so the return form is picked from what the druid
    knows each time a body is built.
]]
local RETURN_FORM_SPELL_IDS = {
	bear = { ns.DRUID_DIRE_BEAR_FORM_SPELL_ID, ns.DRUID_BEAR_FORM_SPELL_ID },
	cat = { ns.DRUID_CAT_FORM_SPELL_ID },
}

-- The chosen return form as (key, spellID, name), with no spell or name until the druid knows one.
local function GetDruidReturnForm()
	local settings = ns.db and ns.db.profile
	local key = settings and settings.druidReturnForm
	if key ~= "cat" then
		key = "bear"
	end
	for _, spellID in ipairs(RETURN_FORM_SPELL_IDS[key]) do
		if ns.KnowsAny({ { spellID } }) then
			return key, spellID, C_Spell.GetSpellName(spellID)
		end
	end
	return key, nil, nil
end

local function BuildDruidMacroHelperBody(typeName, useIDs, stackIDs, formName, outOfCombatID, outOfCombatStealth)
	local lines = {
		"#showtooltip item:" .. useIDs[1],
		"/run ConnoisseurFire(" .. useIDs[1] .. ")",
	}
	--[[
	    Food or water out of combat (potionsUseFoodAndWater): the same lines
	    the standard body carries, above the guards so an out-of-combat press
	    never starts a powershift. A druid in a form has to leave it to eat,
	    as with the Food and Water macros. A Night Elf druid's Shadowmeld,
	    with Stealth Eating or Stealth Drinking on, comes along too.
	]]
	if outOfCombatID then
		lines[1] = ns.OutOfCombatTooltipLine(useIDs[1], outOfCombatID)
		lines[2] = "/run ConnoisseurFire(" .. useIDs[1] .. "," .. outOfCombatID .. ")"
		lines[3] = "/use [nocombat] item:" .. outOfCombatID
		if outOfCombatStealth then
			lines[#lines + 1] = "/cast [nocombat,nostealth] " .. outOfCombatStealth
		end
		lines[#lines + 1] = "/stopmacro [nocombat]"
	end
	for _, guard in ipairs(ns.DRUID_MACRO_HELPER_GUARDS[typeName]) do
		lines[#lines + 1] = guard
	end
	--[[
	    Stacked ranked /use lines, best item first — combat fallback when
	    the best item is depleted. See BuildUseBlock in
	    Body-Builder.lua for the shared-cooldown reasoning.
	]]
	local firstUse = #lines + 1
	for _, id in ipairs(useIDs) do
		lines[#lines + 1] = "/use item:" .. id
	end
	--[[
	    Healthstone stacking (Health Potion only): the best Healthstone's
	    ranked /use lines go below the potion lines but still inside the
	    powershift, before the return /cast — separate cooldown category, so
	    the press fires a potion and a stone in one shift. nil for every
	    other type.
	]]
	if stackIDs then
		for _, id in ipairs(stackIDs) do
			lines[#lines + 1] = "/use item:" .. id
		end
	end
	lines[#lines + 1] = "/cast !" .. formName
	lines[#lines + 1] = "/dmh end"
	local body = table.concat(lines, "\n") .. "\n"

	--[[
	    Measured in bytes against ns.MACRO_BODY_MAX_LENGTH (Data/Data.lua),
	    which carries the reason the unit is bytes. Overflow here would chop
	    the trailing /dmh end line and leave DMH guards dangling.
	    Drop /use lines from the bottom until the body fits — stacked
	    Healthstone lines go first since they sit lowest, then potion
	    fallbacks; the rank-1 potion line is never dropped. Mirrors the
	    trim in Body-Builder.lua.
	]]
	while #body > ns.MACRO_BODY_MAX_LENGTH and #lines > firstUse + 2 do
		table.remove(lines, #lines - 2)
		body = table.concat(lines, "\n") .. "\n"
	end
	return body
end

--------------------------------------------------------------------------------
-- Public Hook
--------------------------------------------------------------------------------

--[[
    ns.UpdateMacros consults this for every macro type/itemID pair it is
    about to write, passing the ranked multi-use id list when one applies
    (best item first; falls back to the single itemID). Returns
    (body, stateID) when the DMH override applies; returns nil to mean
    "use the standard macro body."

    A druid who hasn't learned the chosen return form yet also gets nil, so
    the standard body wins rather than a "/cast !" line for a form they
    cannot shift into.

    The state ID carries the form's spell ID, so learning Dire Bear Form
    rewrites a body that still returns to Bear Form.
]]

function ns.BuildDruidMacroOverride(typeName, itemID, rankedIDs, stackIDs, outOfCombatID, outOfCombatStealth)
	if not itemID then
		return nil
	end
	if not ShouldUseDruidMacroHelper(typeName) then
		return nil
	end

	local formKey, formSpellID, formName = GetDruidReturnForm()
	if not formName then
		return nil
	end

	local useIDs = rankedIDs
	if not useIDs or #useIDs == 0 then
		useIDs = { itemID }
	end

	local body = BuildDruidMacroHelperBody(typeName, useIDs, stackIDs, formName, outOfCombatID, outOfCombatStealth)
	local stateID = "DMH:" .. formKey .. ":" .. formSpellID .. ":" .. table.concat(useIDs, ",")
	if stackIDs then
		stateID = stateID .. "+HS:" .. table.concat(stackIDs, ",")
	end
	if outOfCombatID then
		stateID = stateID .. "+OOC:" .. outOfCombatID .. (outOfCombatStealth and ":S" or "")
	end
	return body, stateID
end
