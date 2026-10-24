local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys
local D = ns.DiagnosticsStrings

--------------------------------------------------------------------------------
-- Locale Context
--------------------------------------------------------------------------------

function ns:BuildLocaleContextReport()
	local lines = { GetClientHeader(), "" }
	lines[#lines + 1] = string.format("GetLocale: %s", tostring(GetLocale()))
	lines[#lines + 1] = string.format("textLocale CVar: %s", tostring(GetCVar("textLocale")))
	lines[#lines + 1] = string.format("audioLocale CVar: %s", tostring(GetCVar("audioLocale")))
	lines[#lines + 1] = string.format("Locale keys (ns.L): %d", CountKeys(ns.L))
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Game Names
--------------------------------------------------------------------------------

--[[
    One line per ns.DIAGNOSTIC_NAME_LOOKUPS row: the name this client returns
    through the row's own lookup, or NIL. A row with a request function names
    something that loads late, so the report asks for it and polls with
    Validate Data's cadence before settling it as NIL. Every timer carries the
    run's generation, so Stop retires the chain.
]]
local NAME_POLL_SECONDS = 0.5
local NAME_REASK_POLLS = 3
local NAME_MAX_IDLE_POLLS = 12

local nameRun = { generation = 0 }

-- The row's name, or nil and the message when its lookup throws.
local function ReadName(row)
	local ok, name = pcall(row.lookup)
	if not ok then
		return nil, tostring(name)
	end
	if name == nil or tostring(name) == "" then
		return nil, nil
	end
	return tostring(name), nil
end

-- Line breaks shown as a literal \n, and pipes escaped so links paste as text.
local function ShownText(text)
	local shown = text:gsub("\r?\n", "\\n")
	shown = shown:gsub("|", "||")
	return shown
end

local function PendingRows()
	local pending = {}
	for _, row in ipairs(ns.DIAGNOSTIC_NAME_LOOKUPS) do
		if row.request and not ReadName(row) then
			pending[#pending + 1] = row
		end
	end
	return pending
end

local function RequestRows(rows)
	for _, row in ipairs(rows) do
		pcall(row.request)
	end
end

local function FinishNames(run)
	local lines = { GetClientHeader(), "" }
	local missing = 0
	for _, row in ipairs(ns.DIAGNOSTIC_NAME_LOOKUPS) do
		local name, problem = ReadName(row)
		if not name then
			missing = missing + 1
		end
		lines[#lines + 1] = string.format(
			"[%s] %s (%s %s): %s",
			name and "OK" or "NIL",
			row.constant,
			row.kind,
			tostring(row.id),
			ShownText(name or problem or "")
		)
	end
	local onFinish = run.onFinish
	run.onFinish = nil
	if onFinish then
		onFinish(
			table.concat(lines, "\n"),
			missing == 0 and D.NAMES_ALL_FOUND or string.format(D.NAMES_SOME_NIL, missing)
		)
	end
end

local function ScheduleNames(run, delay, step)
	local generation = run.generation
	C_Timer.After(delay, function()
		if run.generation ~= generation then
			return
		end
		local ok, problem = pcall(step, run)
		if not ok then
			local onFinish = run.onFinish
			run.onFinish = nil
			run.generation = run.generation + 1
			if onFinish then
				onFinish(nil, nil, tostring(problem))
			end
		end
	end)
end

local function PollNames(run)
	local pending = PendingRows()
	if #pending == 0 then
		FinishNames(run)
		return
	end
	if #pending < run.pendingCount then
		run.pendingCount = #pending
		run.idlePolls = 0
	else
		run.idlePolls = run.idlePolls + 1
	end
	if run.idlePolls >= NAME_MAX_IDLE_POLLS then
		FinishNames(run)
		return
	end
	if run.idlePolls > 0 and run.idlePolls % NAME_REASK_POLLS == 0 then
		RequestRows(pending)
	end
	ScheduleNames(run, NAME_POLL_SECONDS, PollNames)
end

--[[
    onFinish(text, note) receives the finished report and its status note, or
    onFinish(nil, nil, problem) when a step threw. A stopped run never calls it.
]]
function ns:StartNameLookupReport(onFinish)
	nameRun.generation = nameRun.generation + 1
	nameRun.onFinish = onFinish
	nameRun.idlePolls = 0
	local pending = PendingRows()
	nameRun.pendingCount = #pending
	if #pending == 0 then
		ScheduleNames(nameRun, 0, FinishNames)
		return
	end
	RequestRows(pending)
	ScheduleNames(nameRun, NAME_POLL_SECONDS, PollNames)
end

function ns:StopNameLookupReport()
	nameRun.generation = nameRun.generation + 1
	nameRun.onFinish = nil
end

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

--[[
    The add-on sends no chat, so Message Length is the macros alone, against
    ns.MACRO_BODY_MAX_LENGTH in bytes. First every macro as it stands in the
    General tab now. Then each standard macro built through
    ns.BuildStandardBody at its longest, nothing written: the longest item ID
    this data folder holds in every /use line, every ranked and stacked line,
    each shape its conjure clicks can take, and the stealth, Cannibalize and
    out-of-combat food or water lines, all with this client's spell names, and
    again with none of the item in bags, whose tip line can outgrow one /use
    line. The
    longest of three characters wins: a Mage or Warlock (conjures), a Rogue
    (Stealth) and a Night Elf (Shadowmeld), the first two Forsaken
    (Cannibalize). The builder trims its own body, so a length over the
    ceiling is one the trim could not fit, and every line it shed is counted.
    Feed Pet, Poisons and the Druid Macro Helper bodies come from builders that
    read the character's own state, so they show only as written.
]]
local ConjureCastName = ns.DiagnosticConjureCastName
local SortedKeys = ns.DiagnosticSortedKeys

-- Each macro's conjure clicks: the right- and middle-click ladders and their not-yet-learned tips.
local CONJURE_SHAPES = {
	["Food"] = {
		right = "MageCreateFood",
		rightMiss = "noConjureFood",
		middle = "MageCreateTable",
		middleMiss = "noRitualOfRefreshment",
	},
	["Water"] = {
		right = "MageCreateWater",
		rightMiss = "noConjureWater",
		middle = "MageCreateTable",
		middleMiss = "noRitualOfRefreshment",
	},
	["Mana Gem"] = { right = "MageCreateManaGem", rightMiss = "noConjureManaGem" },
	["Healthstone"] = {
		right = "WarlockCreateHealthstone",
		rightMiss = "noCreateHealthstone",
		middle = "WarlockCreateSoulwell",
		middleMiss = "noRitualOfSouls",
	},
	["Soulstone"] = { right = "WarlockCreateSoulstone", rightMiss = "noCreateSoulstone" },
}

-- Which stealths each macro's own appended line can cast (Food's Stealth Eating, Water's Shadowmeld Drinking).
local STEALTHS_BY_TYPE = {
	["Food"] = { STEALTH_SPELL_ID = true, SHADOWMELD_SPELL_ID = true },
	["Water"] = { SHADOWMELD_SPELL_ID = true },
}

-- Which macros cast Cannibalize (Water only where it restores mana).
local function CastsCannibalize(typeName)
	return typeName == "Food" or (typeName == "Water" and ns.CANNIBALIZE_RESTORES_MANA)
end

local LENGTH_CHARACTERS = {
	{ label = "Mage or Warlock, Forsaken", conjure = true, corpse = true },
	{ label = "Rogue, Forsaken", stealth = "STEALTH_SPELL_ID", corpse = true },
	{ label = "Night Elf", stealth = "SHADOWMELD_SPELL_ID" },
}

-- The item ID with the most digits among every item the data folder holds.
local function LongestItemID()
	local longest
	local function Consider(id)
		if type(id) == "number" and (not longest or #tostring(id) > #tostring(longest)) then
			longest = id
		end
	end
	for _, entry in ipairs(ns.DIAGNOSTIC_DATA_SOURCES) do
		for _, source in ipairs(entry.sources) do
			local tbl = ns[source.table]
			if source.kind == "item" and type(tbl) == "table" then
				if source.collect then
					for _, found in ipairs(source.collect(tbl)) do
						Consider(found.id)
					end
				else
					for key, row in pairs(tbl) do
						Consider(source.rowId(key, row))
					end
				end
			end
		end
	end
	return longest
end

local function LongestCastName(listName)
	local longest
	for _, row in ipairs(ns.CONJURE_SPELLS[listName] or {}) do
		local name = ConjureCastName(row)
		if name and (not longest or #name > #longest) then
			longest = name
		end
	end
	return longest
end

-- Every conjure info the macro's resolver can return for a character who conjures, longest names in.
local function ConjureVariants(typeName)
	local shape = CONJURE_SHAPES[typeName]
	if not shape then
		return { false }
	end
	-- A conjure not yet learned also takes the empty-bags left-click, as every resolver sets it.
	local rights = { { miss = shape.rightMiss } }
	local rightName = LongestCastName(shape.right)
	if rightName then
		rights[#rights + 1] = { name = rightName, id = 0 }
	end
	local middles = { {} }
	if shape.middle and #(ns.CONJURE_SPELLS[shape.middle] or {}) > 0 then
		middles = { { miss = shape.middleMiss } }
		local middleName = LongestCastName(shape.middle)
		if middleName then
			middles[#middles + 1] = { name = middleName, id = 0 }
		end
	end
	local variants = {}
	for _, right in ipairs(rights) do
		for _, middle in ipairs(middles) do
			variants[#variants + 1] = {
				rightName = right.name,
				rightID = right.id,
				rightMiss = right.miss,
				noItemMiss = right.miss,
				middleName = middle.name,
				middleID = middle.id,
				middleMiss = middle.miss,
			}
		end
	end
	return variants
end

local function StealthName(typeName, character)
	local constant = character.stealth
	if constant and STEALTHS_BY_TYPE[typeName] and STEALTHS_BY_TYPE[typeName][constant] and ns[constant] then
		return C_Spell.GetSpellName(ns[constant])
	end
	return nil
end

local function CorpseName(typeName, character)
	if character.corpse and CastsCannibalize(typeName) and ns.CANNIBALIZE_SPELL_ID then
		return C_Spell.GetSpellName(ns.CANNIBALIZE_SPELL_ID)
	end
	return nil
end

local function Repeat(value, count)
	local list = {}
	for index = 1, count do
		list[index] = value
	end
	return list
end

local function CountUseLines(body)
	local _, count = string.gsub(body, "/use item:", "")
	return count
end

--[[
    One macro's longest body for one character, as (body, shed): shed counts
    the /use lines the trim dropped, plus one when it dropped Cannibalize.
    Every conjure shape is built with the item in bags and with none, where
    the out-of-combat food or water still is.
]]
local function LongestBodyFor(definition, character, itemID)
	local typeName = definition.typeName
	local useIDs = ns.MULTI_USE_MACRO_TYPES[typeName] and Repeat(itemID, ns.MULTI_USE_MAX_ITEMS) or nil
	local stackIDs = definition.getStackIDs and Repeat(itemID, ns.MULTI_USE_MAX_ITEMS) or nil
	local stealth = StealthName(typeName, character)
	local appendText = stealth and ("\n/cast [nostealth] " .. stealth) or nil
	local corpse = CorpseName(typeName, character)

	local outOfCombatID, outOfCombatStealth, outOfCombatCorpse
	local source = definition.outOfCombatTypeName
	if source then
		outOfCombatID = itemID
		outOfCombatStealth = StealthName(source, character)
		outOfCombatCorpse = CorpseName(source, character)
	end

	local fills = {
		{
			itemID = itemID,
			useIDs = useIDs,
			stackIDs = stackIDs,
			wantedUses = (useIDs and #useIDs or 1) + (stackIDs and #stackIDs or 0),
		},
		{ wantedUses = 0 },
	}
	local best, bestShed
	local variants = character.conjure and ConjureVariants(typeName) or { false }
	for _, conjureInfo in ipairs(variants) do
		for _, fill in ipairs(fills) do
			local body = ns.BuildStandardBody(
				definition,
				fill.itemID,
				fill.useIDs,
				fill.stackIDs,
				conjureInfo or nil,
				appendText,
				outOfCombatID,
				outOfCombatStealth,
				corpse,
				outOfCombatCorpse
			)
			local shed = fill.wantedUses - CountUseLines(body)
			if (corpse or outOfCombatCorpse) and not string.find(body, "dead]", 1, true) then
				shed = shed + 1
			end
			if not best or #body > #best then
				best, bestShed = body, shed
			end
		end
	end
	return best, bestShed
end

local function AppendWrittenMacros(lines)
	lines[#lines + 1] = "-- As written now --"
	for _, typeName in ipairs(SortedKeys(ns.MACRO_CONFIG)) do
		local macroName = ns.MACRO_CONFIG[typeName].macro
		if (GetMacroIndexByName(macroName) or 0) > 0 then
			local length = #(GetMacroBody(macroName) or "")
			lines[#lines + 1] = string.format(
				"[%s] %s: %d / %d bytes",
				length > ns.MACRO_BODY_MAX_LENGTH and "OVER" or "OK  ",
				typeName,
				length,
				ns.MACRO_BODY_MAX_LENGTH
			)
		else
			lines[#lines + 1] = string.format("[--  ] %s: not written", typeName)
		end
	end
end

function ns:BuildMessageLengthReport()
	local lines = { GetClientHeader(), "" }
	AppendWrittenMacros(lines)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Longest build in this locale --"
	local itemID = LongestItemID()
	if not itemID then
		lines[#lines + 1] = "(this data folder holds no items)"
		return table.concat(lines, "\n")
	end
	lines[#lines + 1] = string.format("Longest item ID: %d", itemID)

	local definitions = {}
	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
		definitions[#definitions + 1] = definition
	end
	table.sort(definitions, function(a, b)
		return a.typeName < b.typeName
	end)
	--[[
	    The worst character is the one whose body sheds the most, then the
	    longest: a trimmed body always fits, so its length alone hides the trim.
	]]
	for _, definition in ipairs(definitions) do
		local longest, longestShed, longestLabel
		local differs = false
		for _, character in ipairs(LENGTH_CHARACTERS) do
			local body, shed = LongestBodyFor(definition, character, itemID)
			if longest and #body ~= #longest then
				differs = true
			end
			if not longest or shed > longestShed or (shed == longestShed and #body > #longest) then
				longest, longestShed, longestLabel = body, shed, character.label
			end
		end
		if not differs then
			longestLabel = "any character"
		end
		lines[#lines + 1] = string.format(
			"[%s] %s: %d / %d bytes (%s)%s",
			#longest > ns.MACRO_BODY_MAX_LENGTH and "OVER" or "OK  ",
			definition.typeName,
			#longest,
			ns.MACRO_BODY_MAX_LENGTH,
			longestLabel,
			longestShed > 0 and string.format(", trim shed %d line(s)", longestShed) or ""
		)
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] =
		"Feed Pet, Poisons and Druid Macro Helper bodies read this character's state; see them as written above."
	return table.concat(lines, "\n")
end
