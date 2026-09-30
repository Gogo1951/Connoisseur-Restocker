local _, ns = ...

--------------------------------------------------------------------------------
-- Use Lines
--------------------------------------------------------------------------------

--[[
    Builds the line that records macro-fire context through the global
    helper defined in Features/Macros/Runtime.lua, whose
    ns.OnMacroUiErrorMessage (Core routes UI_ERROR_MESSAGE to it) reads lastID
    and lastTime to correlate a zone-restriction error with the item that
    triggered it.

    Using the global helper instead of an inline /run snippet keeps the line
    short, and every standard body with an item in bags carries it, so the
    saved bytes count against the 255 macro-body ceiling in every consumable
    macro. The helper name carries the distinctive Connoisseur prefix to keep
    collision risk with other add-ons negligible.
]]
local function StateWriteLine(itemID)
	return "/run ConnoisseurFire(" .. itemID .. ")\n"
end

--[[
    Builds the stacked /use block for a multi-use macro type
    (ns.MULTI_USE_MACRO_TYPES): one line per ranked item, best first. Items
    within each such category share an item cooldown, so a press consumes
    exactly one item — the first /use whose item is in bags fires and its
    cooldown blocks the rest. The extra lines exist for combat, where
    macros cannot be rewritten: once the best item is depleted its line
    becomes a silent no-op and the press falls through to the next-best
    item. On presses where the first line fires, the blocked lines emit a
    harmless "Item is not ready yet" UI error.
]]
local function BuildUseBlock(useIDs)
	local lines = {}
	for _, id in ipairs(useIDs) do
		lines[#lines + 1] = "/use item:" .. id
	end
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Conjure Block Builder
--------------------------------------------------------------------------------

--[[
    Composes the conjure portion of a standard macro body. Handles both
    learned and not-yet-learned spells: known spells emit /cast lines, and
    not-yet-learned spells emit /run ConnoisseurTipIf calls that print a "you'll get
    this later" tip when the user actually presses the click that would
    have used the spell.

    Returns the block string (may be empty).
]]
local function BuildConjureBlock(info)
	if not info then
		return ""
	end

	local rightName, middleName = info.rightName, info.middleName
	local rightMiss, middleMiss = info.rightMiss, info.middleMiss

	if not (rightName or middleName or rightMiss or middleMiss) then
		return ""
	end

	local lines = {}

	--[[
	    Miss prints come first so an early /stopmacro can halt before the
	    /cast line, avoiding a wasted cast attempt on a button the user
	    expected to do something else.
	]]
	if rightMiss then
		lines[#lines + 1] = '/run ConnoisseurTipIf("[btn:2]","' .. rightMiss .. '")'
	end
	if middleMiss then
		lines[#lines + 1] = '/run ConnoisseurTipIf("[btn:3]","' .. middleMiss .. '")'
	end

	local missStop = ""
	if rightMiss then
		missStop = missStop .. "[btn:2]"
	end
	if middleMiss then
		missStop = missStop .. "[btn:3]"
	end
	if missStop ~= "" then
		lines[#lines + 1] = "/stopmacro " .. missStop
	end

	if rightName or middleName then
		local castLine = ""
		local stopConditions = ""
		if middleName then
			castLine = castLine .. "[btn:3] " .. middleName .. "; "
			stopConditions = stopConditions .. "[btn:3]"
		end
		if rightName then
			castLine = castLine .. "[btn:2] " .. rightName .. "; "
			stopConditions = stopConditions .. "[btn:2]"
		end
		lines[#lines + 1] = "/cast " .. castLine
		lines[#lines + 1] = "/stopmacro " .. stopConditions
	end

	return table.concat(lines, "\n") .. "\n"
end

--------------------------------------------------------------------------------
-- Standard Body Builder
--------------------------------------------------------------------------------

--[[
    Assembles a standard macro body — the single answer to "what does a
    Connoisseur macro body look like." The canonical emitted macro is:

      #showtooltip item:13446
      /run ConnoisseurFire(13446)
      /use item:13446

    Every other line is contributed by a definition hook:

      #showtooltip item:<id>  -- always first; ns.MACRO_DEFAULT_ITEM_IDS when no item
      <conjure block>         -- definition.conjure, via BuildConjureBlock: /run ConnoisseurTipIf
                                 miss tips with their /stopmacro guard, then the
                                 /cast [btn:3]/[btn:2] line and its /stopmacro
      /run ConnoisseurFire(<id>)     -- StateWriteLine (macro-fire context for the
                                 zone-error handler); only when an item exists
      /use item:<id>          -- the action: definition.buildUseLine's custom line(s)
                                 (Explosive's click layout, Food's [@pet] line),
                                 else one line per ranked id for multi-use
                                 types, else this plain single /use
      /use item:<stackID>     -- definition.getStackIDs ids appended below the main
                                 block (Health Potion's healthstone stacking)
      <appended block>        -- definition.appendBlock text (Water's Shadowmeld line)

    With no item in bags the action line becomes /run ConnoisseurTip("<noItemMiss>")
    when the class can learn the conjure, else /run ConnoisseurNoItem("<typeName>").
    Ends with the macro-length trim, which sheds stacked healthstone lines and
    then ranked fallback /use lines from the bottom up.
]]
function ns.BuildStandardBody(definition, itemID, useIDs, stackIDs, conjureInfo, appendText)
	local tooltipLine, actionBlock

	if itemID then
		tooltipLine = "#showtooltip item:" .. itemID .. "\n"

		local customLine = definition.buildUseLine and definition.buildUseLine(itemID) or nil
		if customLine then
			actionBlock = StateWriteLine(itemID) .. customLine
		elseif useIDs then
			actionBlock = StateWriteLine(itemID) .. BuildUseBlock(useIDs)
		else
			actionBlock = StateWriteLine(itemID) .. "/use item:" .. itemID
		end

		-- Append the stacked ranked lines (Health Potion stacking).
		if stackIDs then
			actionBlock = actionBlock .. "\n" .. BuildUseBlock(stackIDs)
		end
	elseif conjureInfo and conjureInfo.noItemMiss then
		--[[
		    The player's class can conjure this category but hasn't learned
		    the spell yet. Replace the generic "no item in bags" message
		    with the more useful "you don't know X" message so the player
		    understands the macro will gain functionality at the right
		    level.
		]]
		tooltipLine = "#showtooltip item:" .. ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName] .. "\n"
		actionBlock = '/run ConnoisseurTip("' .. conjureInfo.noItemMiss .. '")'
	else
		tooltipLine = "#showtooltip item:" .. ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName] .. "\n"
		actionBlock = '/run ConnoisseurNoItem("' .. definition.typeName .. '")'
	end

	local conjureBlock = ""
	if conjureInfo then
		conjureBlock = BuildConjureBlock(conjureInfo)
	end

	local appendedBlock = appendText or ""

	local body = tooltipLine .. conjureBlock .. actionBlock .. appendedBlock

	--[[
	    Measured in bytes against ns.MACRO_BODY_MAX_LENGTH (Data/Data.lua),
	    which carries the reason the unit is bytes.

	    Overflow corrupts the last /use line: the warlock Healthstone conjure
	    block plus three /use lines can overflow in multibyte locales (e.g.
	    ruRU spell names), and Health Potion stacking adds the Healthstone
	    lines on top. Shed the stacked Healthstone lines from the bottom
	    first, then potion fallback lines; the rank-1 potion line is never
	    dropped.
	]]
	if useIDs then
		local keepUse = #useIDs
		local keepStack = stackIDs and #stackIDs or 0
		while #body > ns.MACRO_BODY_MAX_LENGTH and (keepStack > 0 or keepUse > 1) do
			if keepStack > 0 then
				keepStack = keepStack - 1
			else
				keepUse = keepUse - 1
			end
			local trimmed = {}
			for rank = 1, keepUse do
				trimmed[rank] = useIDs[rank]
			end
			actionBlock = StateWriteLine(itemID) .. BuildUseBlock(trimmed)
			if keepStack > 0 then
				local stackTrimmed = {}
				for rank = 1, keepStack do
					stackTrimmed[rank] = stackIDs[rank]
				end
				actionBlock = actionBlock .. "\n" .. BuildUseBlock(stackTrimmed)
			end
			body = tooltipLine .. conjureBlock .. actionBlock .. appendedBlock
		end
	end

	return body
end

--------------------------------------------------------------------------------
-- State Key Builder
--------------------------------------------------------------------------------

--[[
    State encoding — captures every input that affects the written body.
    Format:
      ITEMIDS(+HS:stackIDs)?(_C(_M:mid)?(_R:rid)?(_MR:key)?(_MM:key)?(_NI:key)?)?(_EX:mode)?(_SM|_SE)?
    where ITEMIDS is the single itemID, or a comma-joined ranked list for
    multi-use types so a change in any fallback rank also triggers a
    rewrite. +HS: carries the stacked Healthstone ids (Health Potion's
    getStackIDs hook). _EX:mode comes from Explosive's stateExtras hook (its
    click layout), so flipping the dropdown rewrites the macro; _SM and _SE
    are the append-block flags (Water's Shadowmeld line and Food's Stealth
    Eating line). Mode overrides use their own prefix
    ("SCROLLS:...") instead, so the key spaces never collide and a
    transition between modes always triggers a rewrite. Every input that
    affects the body MUST appear in the key — a lossy key causes stale
    macros.
]]
function ns.BuildStateKey(definition, itemID, useIDs, stackIDs, conjureInfo, appendFlag)
	local itemKey = itemID and tostring(itemID) or "none"
	if useIDs then
		itemKey = table.concat(useIDs, ",")
	end
	if stackIDs then
		itemKey = itemKey .. "+HS:" .. table.concat(stackIDs, ",")
	end
	local stateParts = { itemKey }
	if
		conjureInfo
		and (
			conjureInfo.rightName
			or conjureInfo.middleName
			or conjureInfo.rightMiss
			or conjureInfo.middleMiss
			or conjureInfo.noItemMiss
		)
	then
		stateParts[#stateParts + 1] = "C"
		if conjureInfo.middleName then
			stateParts[#stateParts + 1] = "M:" .. tostring(conjureInfo.middleID)
		end
		if conjureInfo.rightName then
			stateParts[#stateParts + 1] = "R:" .. tostring(conjureInfo.rightID)
		end
		if conjureInfo.rightMiss then
			stateParts[#stateParts + 1] = "MR:" .. conjureInfo.rightMiss
		end
		if conjureInfo.middleMiss then
			stateParts[#stateParts + 1] = "MM:" .. conjureInfo.middleMiss
		end
		if conjureInfo.noItemMiss then
			stateParts[#stateParts + 1] = "NI:" .. conjureInfo.noItemMiss
		end
	end
	if definition.stateExtras then
		definition.stateExtras(stateParts, itemID)
	end
	if appendFlag then
		stateParts[#stateParts + 1] = appendFlag
	end
	return table.concat(stateParts, "_")
end

--------------------------------------------------------------------------------
-- Combo Body Builder
--------------------------------------------------------------------------------

--[[
    Composes a combo body with one /use [combat] line per combat id. Either
    half with nothing in bags becomes a ConnoisseurNoItemIf line for its own
    combat state, and a body with neither keeps the rest type's default icon.
]]
local function ComposeComboBody(restType, combatType, combatIDs, restID)
	local combatID = combatIDs[1]
	local lines = {}

	if combatID or restID then
		lines[1] = "#showtooltip"
	else
		lines[1] = "#showtooltip item:" .. ns.MACRO_DEFAULT_ITEM_IDS[restType]
	end

	if combatID and restID then
		lines[#lines + 1] = '/run ConnoisseurFireIf("[combat]",' .. combatID .. "," .. restID .. ")"
	elseif combatID or restID then
		lines[#lines + 1] = "/run ConnoisseurFire(" .. (combatID or restID) .. ")"
	end

	if combatID then
		for _, id in ipairs(combatIDs) do
			lines[#lines + 1] = "/use [combat] item:" .. id
		end
	else
		lines[#lines + 1] = '/run ConnoisseurNoItemIf("[combat]","' .. combatType .. '")'
	end

	if restID then
		lines[#lines + 1] = "/use [nocombat] item:" .. restID
	else
		lines[#lines + 1] = '/run ConnoisseurNoItemIf("[nocombat]","' .. restType .. '")'
	end

	return table.concat(lines, "\n")
end

--[[
    Builds the body and state key of a combo macro (Food & Potion, Water &
    Potion): the restType winner out of combat, and in combat the combatType
    macro's ranked lines followed by stackIDs. The canonical emitted macro is:

      #showtooltip
      /run ConnoisseurFireIf("[combat]",13446,8932)
      /use [combat] item:13446
      /use [combat] item:3928
      /use [nocombat] item:8932

    Bare #showtooltip shows the potion in combat and the food out of it. The
    state key uses its own "COMBO:" prefix, since the definitions write it
    through buildModeOverride.
]]
function ns.BuildComboBody(best, restType, combatType, stackIDs)
	local combatIDs = {}
	for _, id in ipairs(best[combatType].topIDs) do
		combatIDs[#combatIDs + 1] = id
	end
	if stackIDs then
		for _, id in ipairs(stackIDs) do
			combatIDs[#combatIDs + 1] = id
		end
	end
	local restID = best[restType].id

	local combatKey = #combatIDs > 0 and table.concat(combatIDs, ",") or "none"
	local stateKey = "COMBO:" .. combatKey .. ":" .. (restID and tostring(restID) or "none")

	local body = ComposeComboBody(restType, combatType, combatIDs, restID)

	--[[
	    Measured in bytes against ns.MACRO_BODY_MAX_LENGTH (Data/Data.lua).
	    Shed the combat lines from the bottom, stacked lines first; the first
	    combat line is never dropped. combatIDs is this function's own copy,
	    so dropping its tail leaves the scan's lists untouched.
	]]
	while #body > ns.MACRO_BODY_MAX_LENGTH and #combatIDs > 1 do
		combatIDs[#combatIDs] = nil
		body = ComposeComboBody(restType, combatType, combatIDs, restID)
	end

	return body, stateKey
end
