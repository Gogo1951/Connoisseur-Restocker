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
local function StateWriteLine(itemID, outOfCombatID)
	if outOfCombatID then
		return "/run ConnoisseurFire(" .. itemID .. "," .. outOfCombatID .. ")\n"
	end
	return "/run ConnoisseurFire(" .. itemID .. ")\n"
end

--[[
    Food or water out of combat (the potion macros' outOfCombatTypeName, behind
    potionsUseFoodAndWater): the body eats or drinks and stops there while the
    player is out of combat, and only a press in combat reaches the lines
    below. A /stopmacro costs fewer bytes than a [combat] guard on each of up
    to six /use lines, and leaves those lines, and the trim that sheds them,
    as they are without it.
]]
function ns.OutOfCombatBlock(outOfCombatID)
	return "/use [nocombat] item:" .. outOfCombatID .. "\n/stopmacro [nocombat]\n"
end

-- The tooltip line of a body with an out-of-combat item: the potion in combat, the food or water out of it.
function ns.OutOfCombatTooltipLine(itemID, outOfCombatID)
	return "#showtooltip [combat] item:" .. itemID .. "; item:" .. outOfCombatID
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
      /use [nocombat] item:<id>  -- definition.outOfCombatTypeName's best item with
      /stopmacro [nocombat]      its stop, above the action (the potion macros'
                                 food or water, behind potionsUseFoodAndWater);
                                 the tooltip line then shows it out of combat
                                 and ConnoisseurFire takes it as a second id
      <appended block>        -- definition.appendBlock text (Water's Shadowmeld line)

    With no item in bags the action line becomes /run ConnoisseurTip("<noItemMiss>")
    when the class can learn the conjure, else /run ConnoisseurNoItem("<typeName>");
    an out-of-combat item still goes above it, so that line is only reached in
    combat.
    Ends with the macro-length trim, which sheds stacked healthstone lines and
    then ranked fallback /use lines from the bottom up.
]]
function ns.BuildStandardBody(definition, itemID, useIDs, stackIDs, conjureInfo, appendText, outOfCombatID)
	local tooltipLine, actionBlock

	-- Everything above the /use lines; the macro-length trim rebuilds only what follows it.
	local actionHead = ""
	if itemID then
		actionHead = StateWriteLine(itemID, outOfCombatID)
	elseif outOfCombatID then
		actionHead = StateWriteLine(outOfCombatID)
	end
	if outOfCombatID then
		actionHead = actionHead .. ns.OutOfCombatBlock(outOfCombatID)
	end

	if itemID then
		tooltipLine = "#showtooltip item:" .. itemID .. "\n"

		local customLine = definition.buildUseLine and definition.buildUseLine(itemID) or nil
		if customLine then
			actionBlock = actionHead .. customLine
		elseif useIDs then
			actionBlock = actionHead .. BuildUseBlock(useIDs)
		else
			actionBlock = actionHead .. "/use item:" .. itemID
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
		actionBlock = actionHead .. '/run ConnoisseurTip("' .. conjureInfo.noItemMiss .. '")'
	else
		tooltipLine = "#showtooltip item:" .. ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName] .. "\n"
		actionBlock = actionHead .. '/run ConnoisseurNoItem("' .. definition.typeName .. '")'
	end

	if outOfCombatID then
		tooltipLine = ns.OutOfCombatTooltipLine(itemID or ns.MACRO_DEFAULT_ITEM_IDS[definition.typeName], outOfCombatID)
			.. "\n"
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
			actionBlock = actionHead .. BuildUseBlock(trimmed)
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
      ITEMIDS(+HS:stackIDs)?(_C(_M:mid)?(_R:rid)?(_MR:key)?(_MM:key)?(_NI:key)?)?(_EX:mode)?(_SM|_SE)?(_OOC:id)?
    where ITEMIDS is the single itemID, or a comma-joined ranked list for
    multi-use types so a change in any fallback rank also triggers a
    rewrite. +HS: carries the stacked Healthstone ids (Health Potion's
    getStackIDs hook). _EX:mode comes from Explosive's stateExtras hook (its
    click layout), so flipping the dropdown rewrites the macro; _SM and _SE
    are the append-block flags (Water's Shadowmeld line and Food's Stealth
    Eating line). _OOC:id is the food or water a potion macro uses out of
    combat. Mode overrides use their own prefix
    ("SCROLLS:...") instead, so the key spaces never collide and a
    transition between modes always triggers a rewrite. Every input that
    affects the body MUST appear in the key — a lossy key causes stale
    macros.
]]
function ns.BuildStateKey(definition, itemID, useIDs, stackIDs, conjureInfo, appendFlag, outOfCombatID)
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
	if outOfCombatID then
		stateParts[#stateParts + 1] = "OOC:" .. outOfCombatID
	end
	return table.concat(stateParts, "_")
end
