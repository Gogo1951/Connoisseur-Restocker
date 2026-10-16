-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for Validate Data (no WoW client needed).

    Run it with:   lua Tests/Diagnostics-Validate-Data-Test.lua        (from the add-on root)

    Like Diagnostics-Event-Log-Test, this does NOT model the logic: it loads the
    REAL Features/Utilities.lua for its tooltip reader and the REAL
    Diagnostics/ files for ns:StartDataValidation and the report runner, behind
    stubs that model a client answering a load request a few timer ticks after
    it is made, with C_Timer.After queued and pumped by hand.

    WHAT IS PINNED HERE. The IDs go through a hundred at a time, and no ID of the
    next batch is requested until every row of this one has settled. A row is OK
    only once its item or spell, its text and its tooltip have all loaded; one
    that never loads is NOT ON CLIENT, one that loaded partway is INCOMPLETE, and
    a reader that throws settles an ERROR row without stopping the run. Every
    row carries one cell per header column, and the tooltip reader returns one
    plain line per tooltip line, a right-hand text after " >> ".
]]

local ROOT = arg[1] or "."

local realPrint = io.write
local function say(text)
	realPrint(text .. "\n")
end

local failures = 0

local function check(label, got, want)
	if got == want then
		say(("  ok    %s = %s"):format(label, tostring(got)))
	else
		failures = failures + 1
		say(("  FAIL  %s: got %s, want %s"):format(label, tostring(got), tostring(want)))
	end
end

local function Load(path, ns)
	assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
end

--------------------------------------------------------------------------------
-- Tooltip Reader (Features/Utilities.lua)
--------------------------------------------------------------------------------

C_Item = {}

say("1. Forever reads C_TooltipInfo's lines as plain text, a right-hand text after >>")
C_TooltipInfo = {
	GetItemByID = function()
		return {
			lines = {
				{ leftText = "Linen Bandage" },
				{ leftText = "|cff00ff00Use: Heals 66 damage over 6 sec.|r" },
				{ leftText = "Main Hand", rightText = "Sword" },
			},
		}
	end,
	GetSpellByID = function()
		return nil
	end,
}
local foreverNs = { PALETTE = {} }
Load("Features/Utilities.lua", foreverNs)
local lines = foreverNs.GetTooltipLines("item", 1251)
check("item lines", #lines, 3)
check("first line", lines[1], "Linen Bandage")
check("color escapes stripped", lines[2], "Use: Heals 66 damage over 6 sec.")
check("right-hand text", lines[3], "Main Hand >> Sword")
check("no data reads as no lines", #foreverNs.GetTooltipLines("spell", 746), 0)
C_TooltipInfo = nil

say("2. Era and TBC fill one hidden tooltip, reused, and skip a hidden right-hand text")
local SCAN_NAME = "ConnoisseurScanTooltip"
local SCAN_LINES = {
	item = { { "Linen Bandage" }, { "Main Hand", "Sword" } },
	spell = { { "First Aid" } },
}
local framesCreated, owned, hyperlinks = 0, false, {}

for index = 1, 3 do
	for _, side in ipairs({ "Left", "Right" }) do
		local fontString = { shown = false }
		function fontString:GetText()
			return self.text
		end
		function fontString:IsShown()
			return self.shown
		end
		_G[SCAN_NAME .. "Text" .. side .. index] = fontString
	end
end
-- Left over from an earlier, wider tooltip, and hidden since.
_G[SCAN_NAME .. "TextRight1"].text = "Stale"

function CreateFrame(_, name)
	framesCreated = framesCreated + 1
	assert(name == SCAN_NAME, "the scan tooltip is named for its font strings")
	local tooltip = {}
	function tooltip:SetOwner()
		owned = true
	end
	function tooltip:ClearLines()
		self.lineCount = 0
	end
	function tooltip:SetHyperlink(link)
		assert(owned, "a setter ran before SetOwner")
		hyperlinks[#hyperlinks + 1] = link
		local kind = link:match("^(%a+):")
		self.lineCount = #SCAN_LINES[kind]
		for index, line in ipairs(SCAN_LINES[kind]) do
			_G[SCAN_NAME .. "TextLeft" .. index].text = line[1]
			local right = _G[SCAN_NAME .. "TextRight" .. index]
			right.shown = line[2] ~= nil
			right.text = line[2] or right.text
		end
	end
	function tooltip:NumLines()
		return self.lineCount
	end
	function tooltip:Hide()
		owned = false
	end
	return tooltip
end
WorldFrame = {}

local eraNs = { PALETTE = {} }
Load("Features/Utilities.lua", eraNs)
check("nothing created at load", framesCreated, 0)
lines = eraNs.GetTooltipLines("item", 1251)
check("item lines", #lines, 2)
check("hidden right-hand text skipped", lines[1], "Linen Bandage")
check("right-hand text", lines[2], "Main Hand >> Sword")
check("item hyperlink", hyperlinks[1], "item:1251")
lines = eraNs.GetTooltipLines("spell", 746)
check("spell line", lines[1], "First Aid")
check("spell hyperlink", hyperlinks[2], "spell:746")
check("one tooltip, reused", framesCreated, 1)
check("hidden after reading", owned, false)

--------------------------------------------------------------------------------
-- The Client
--------------------------------------------------------------------------------

--[[
    tick counts the timer callbacks run. A requested ID loads delay ticks after
    the request it answers; dropFirst loses the first request, so only a retry
    loads it.
]]
local tick = 0
local timers = {}

-- Seconds the clock moves per pumped timer: one by default, so every step is past the repaint throttle.
local secondsPerTick = 1

function GetTime()
	return tick * secondsPerTick
end

C_Timer = {
	After = function(_, callback)
		timers[#timers + 1] = callback
	end,
}

local function Pump()
	local callback = table.remove(timers, 1)
	if callback then
		tick = tick + 1
		callback()
	end
	return callback ~= nil
end

local function PumpAll()
	local guard = 0
	while Pump() do
		guard = guard + 1
		assert(guard < 2000, "the run never finished")
	end
end

function GetBuildInfo()
	return "1.60.1", "69977", "Sep 1 2026", 16001
end
function GetLocale()
	return "enUS"
end

local spells = {
	[746] = { name = "First Aid", description = "Heals 66 damage over 6 sec.", cached = true },
	[7001] = { name = "Use 7001", description = "Restores 100 health.", cached = true },
	[7007] = { name = "Use 7007", description = "Restores 200 mana.", delay = 2 },
	[7101] = { name = "Aura 7101", description = "", cached = true }, -- has no text of its own, and says so
	[7102] = { name = "Use 7102", description = "", neverCached = true }, -- its data never arrives
}

local items = {}
for id = 1001, 1250 do
	items[id] = { exists = true, delay = 1 }
end
items[1001].spellID = 7001
items[1002].delay = math.huge -- in the client's data, but the server never answers
items[1003].exists = false -- not on this client at all
items[1004].tooltipStuck = true -- loads, but its tooltip never draws a line
items[1005].dropFirst = true
items[1006].throws = true
items[1007].spellID = 7007 -- its spell text loads only once asked for
items[1008].tooltip = { "Tab\there", "Two\nlines" }
items[1009].tooltip = { "Weapon", "Main Hand >> Sword" }
items[1050].delay = 8 -- the slow row that holds the first batch open
for id = 2001, 2003 do
	items[id] = { exists = true, delay = 3 }
end
for id = 3001, 3003 do
	items[id] = { exists = true, delay = 3 }
end
items[4001] = { exists = true, delay = 1, spellID = 7102 } -- loads, but its spell's data never arrives

local requests, firstRequestTick, lastRequestTick, spellRequests = {}, {}, {}, {}

local function Loaded(item)
	return item.loadedAt ~= nil and tick >= item.loadedAt
end

local function SpellLoaded(spell)
	return spell.cached or (spell.loadedAt ~= nil and tick >= spell.loadedAt)
end

C_Item = {
	DoesItemExistByID = function(id)
		return items[id] ~= nil and items[id].exists
	end,
	RequestLoadItemDataByID = function(id)
		local item = items[id]
		requests[id] = (requests[id] or 0) + 1
		firstRequestTick[id] = firstRequestTick[id] or tick
		lastRequestTick[id] = tick
		if not (item.dropFirst and requests[id] == 1) then
			item.loadedAt = item.loadedAt or tick + item.delay
		end
	end,
	GetItemInfo = function(id)
		if not Loaded(items[id]) then
			return
		end
		local link = "|cffffffff|Hitem:" .. id .. "|h[Item " .. id .. "]|h|r"
		return "Item " .. id,
			link,
			1,
			5,
			0,
			"Consumable",
			"Bandages",
			20,
			"INVTYPE_NON_EQUIP_IGNORE",
			133685,
			10,
			0,
			7,
			0,
			0,
			nil,
			false,
			""
	end,
	GetItemInfoInstant = function(id)
		if items[id] and items[id].exists then
			return id, "Consumable", "Bandages", "INVTYPE_NON_EQUIP_IGNORE", 133685, 0, 7
		end
	end,
	GetItemSpell = function(id)
		local item = items[id]
		if Loaded(item) and item.spellID then
			return spells[item.spellID].name, item.spellID
		end
	end,
	GetItemInventoryTypeByID = function()
		return 0
	end,
	GetItemFamily = function()
		return 0
	end,
	GetItemUniquenessByID = function(id)
		if items[id].throws then
			error("uniqueness exploded")
		end
		return false
	end,
	GetDetailedItemLevelInfo = function()
		return 5, false, 5
	end,
	GetItemStats = function()
		return { ITEM_MOD_STAMINA_SHORT = 1 }
	end,
	IsConsumableItem = function()
		return true
	end,
	IsEquippableItem = function()
		return false
	end,
}

C_Spell = {
	DoesSpellExist = function(id)
		return spells[id] ~= nil
	end,
	GetSpellName = function(id)
		return spells[id] and spells[id].name
	end,
	RequestLoadSpellData = function(id)
		spellRequests[id] = (spellRequests[id] or 0) + 1
		local spell = spells[id]
		if spell and not spell.cached and spell.delay then
			spell.loadedAt = spell.loadedAt or tick + spell.delay
		end
	end,
	IsSpellDataCached = function(id)
		local spell = spells[id]
		return spell ~= nil and SpellLoaded(spell)
	end,
	GetSpellInfo = function(id)
		local spell = spells[id]
		if spell then
			return { name = spell.name, iconID = 135966, castTime = 0, spellID = id }
		end
	end,
	-- Nil until the spell loads, as on WoW Forever; a loaded spell with no text answers "".
	GetSpellDescription = function(id)
		local spell = spells[id]
		if spell and SpellLoaded(spell) then
			return spell.description
		end
	end,
	GetSpellSubtext = function()
		return ""
	end,
	GetSpellPowerCost = function(id)
		if id == 746 then
			return { { name = "MANA", cost = 10 } }
		end
		return {}
	end,
	GetSpellLink = function(id)
		return "|cff71d5ff|Hspell:" .. id .. "|h[Spell]|h|r"
	end,
	-- Throws on an unknown ID, as a reader may.
	IsSelfBuff = function(id)
		if not spells[id] then
			error("not a spell")
		end
		return false
	end,
}

C_QuestLog = {}

function IsPlayerSpell()
	return false
end
function IsSpellKnown()
	return false
end

-- The panel repaint every run asks for, counted, with the progress it would draw.
local repaints = {}
local function NotifyChange(_, appName)
	repaints[#repaints + 1] = { appName = appName, tick = tick }
end
function LibStub(name)
	assert(name == "AceConfigRegistry-3.0", "unexpected library " .. tostring(name))
	return { NotifyChange = NotifyChange }
end

--------------------------------------------------------------------------------
-- The Run (Diagnostics/)
--------------------------------------------------------------------------------

local ns = {
	PALETTE = {},
	L = setmetatable({}, {
		__index = function(_, key)
			return key
		end,
	}),
	ADDON_TITLE = "ADDON_TITLE",
	Version = "Test",
	FLAVOR = "Camelot",
	DATA_FOLDER = "Camelot",
	OPTIONS_REGISTRY = { Diagnostics = "Test_Diagnostics" },
}
Load("Features/Utilities.lua", ns)

function ns.GetTooltipLines(kind, id)
	if kind == "spell" then
		local spell = spells[id]
		return { spell.name, SpellLoaded(spell) and spell.description or "" }
	end
	local item = items[id]
	if not Loaded(item) or item.tooltipStuck then
		return {}
	end
	return item.tooltip or { "Item " .. id, "Requires First Aid (1)" }
end

ns.TEST_SPELLS = { [746] = true, [999999] = true }
ns.TEST_ITEMS = {}
for id = 1001, 1250 do
	ns.TEST_ITEMS[id] = true
end
ns.TEST_OTHER = { first = 1, second = 2, third = 3 }
ns.TEST_SMALL = { [2001] = true, [2002] = true, [2003] = true }
ns.TEST_RESTART = { [3001] = true, [3002] = true, [3003] = true }
ns.TEST_TEXTLESS_SPELLS = { [7101] = true }
ns.TEST_TEXTLESS_ITEMS = { [4001] = true }

local function KeyIsId(key)
	return key
end

ns.DIAGNOSTIC_API_CHECKS = {}
ns.DIAGNOSTIC_DATA_SOURCES = {
	{
		label = "Test",
		sources = {
			{ table = "TEST_SPELLS", kind = "spell", rowId = KeyIsId },
			{ table = "TEST_ITEMS", kind = "item", rowId = KeyIsId },
			{ table = "TEST_NEVER_BUILT", kind = "item", rowId = KeyIsId },
			{ table = "TEST_OTHER", kind = "other" },
		},
	},
	{ label = "Small", sources = { { table = "TEST_SMALL", kind = "item", rowId = KeyIsId } } },
	{ label = "Restart", sources = { { table = "TEST_RESTART", kind = "item", rowId = KeyIsId } } },
	{
		label = "Textless",
		sources = {
			{ table = "TEST_TEXTLESS_SPELLS", kind = "spell", rowId = KeyIsId },
			{ table = "TEST_TEXTLESS_ITEMS", kind = "item", rowId = KeyIsId },
		},
	},
}

Load("Diagnostics/Diagnostics-Core.lua", ns)
Load("Diagnostics/Event-Log.lua", ns)
Load("Diagnostics/Validate-Data.lua", ns)
Load("Diagnostics/Report-Runner.lua", ns)
ns:SetDiagnosticsEnabled(true)

local function HasApiCheck(label)
	for _, apiCheck in ipairs(ns.DIAGNOSTIC_API_CHECKS) do
		if apiCheck[1] == label then
			return true
		end
	end
	return false
end

-- The report's TSV blocks, each its header's columns and its rows' cells.
local function Blocks(report)
	local blocks, current = {}, nil
	for line in (report .. "\n"):gmatch("(.-)\n") do
		local cells = {}
		for cell in (line .. "\t"):gmatch("(.-)\t") do
			cells[#cells + 1] = cell
		end
		if cells[1] == "STATUS" then
			current = { columns = cells, rows = {} }
			blocks[#blocks + 1] = current
		elseif current and line ~= "" then
			current.rows[#current.rows + 1] = cells
		end
	end
	return blocks
end

-- STATUS, SOURCE, then the id.
local function Find(block, idColumnValue)
	for _, cells in ipairs(block.rows) do
		if cells[3] == idColumnValue then
			return cells
		end
	end
	return {}
end

local function Column(block, name)
	for index, column in ipairs(block.columns) do
		if column == name then
			return index
		end
	end
end

say("3. Each batch of a hundred settles before the next is requested")
check("a spell source adds its API rows", HasApiCheck("C_Spell.GetSpellName (Validate Data)"), true)
check("no area source, no area row", HasApiCheck("C_Map.GetAreaInfo (Validate Data)"), false)
local finished = {}
local progress = {}
repaints = {}
ns:StartDataValidation(1, function(text, counts, problem)
	finished[#finished + 1] = { text = text, counts = counts, problem = problem }
end)
local guard = 0
while Pump() do
	guard = guard + 1
	assert(guard < 2000, "the run never finished")
	local resolved, total = ns:GetDataValidationProgress(1)
	if resolved then
		progress[#progress + 1] = { resolved = resolved, total = total }
	end
end
check("the slow row loaded before the next batch was asked for", firstRequestTick[1101] > items[1050].loadedAt, true)
check("the last retry of a straggler came first too", firstRequestTick[1101] > lastRequestTick[1002], true)
check("the third batch waited on the second", firstRequestTick[1201] > firstRequestTick[1200], true)
check("progress counts every id", progress[1] and progress[1].total, 252)
check("progress passed the second batch", progress[#progress].resolved >= 200, true)
check("no progress once finished", ns:GetDataValidationProgress(1), nil)
check("finished once", #finished, 1)
check("no problem", finished[1].problem, nil)

local report = finished[1].text
local blocks = Blocks(report)
check(
	"report opens with the client header",
	report:match("^[^\n]+"),
	"ADDON_TITLE Test // Client 1.60.1 // Build 69977 // TOC 16001 // Locale enUS // Flavor Camelot // Data Camelot"
)
check("three blocks", #blocks, 3)
local itemBlock, spellBlock, otherBlock = blocks[1], blocks[2], blocks[3]
check("item block first", itemBlock.columns[3], "ITEM_ID")
check("spell block second", spellBlock.columns[3], "SPELL_ID")
check("other block last", otherBlock.columns[3], "ROWS")

say("4. A spell row carries its text, its tooltip and its costs")
local firstAid = Find(spellBlock, "746")
check("status", firstAid[1], "OK")
check("source", firstAid[2], "TEST_SPELLS")
check("cells", #firstAid, #spellBlock.columns)
check("name", firstAid[4], "First Aid")
check("is player spell", firstAid[Column(spellBlock, "IS_PLAYER_SPELL")], "false")
check("description", firstAid[Column(spellBlock, "SPELL_DESCRIPTION")], "Heals 66 damage over 6 sec.")
check("tooltip", firstAid[Column(spellBlock, "SPELL_TOOLTIP")], "First Aid // Heals 66 damage over 6 sec.")
check("power cost", firstAid[Column(spellBlock, "SPELL_POWER_COST")], "1={cost=10; name=MANA}")
check("link pipes escaped", firstAid[Column(spellBlock, "SPELL_LINK")], "||cff71d5ff||Hspell:746||h[Spell]||h||r")
local unknownSpell = Find(spellBlock, "999999")
check("unknown spell flagged", unknownSpell[1], "NOT ON CLIENT")
check("still printed in full", #unknownSpell, #spellBlock.columns)

say("5. An item row carries its spell, the spell's text and its tooltip")
local bandage = Find(itemBlock, "1001")
check("status", bandage[1], "OK")
check("cells", #bandage, #itemBlock.columns)
check("link pipes escaped", bandage[Column(itemBlock, "LINK")], "||cffffffff||Hitem:1001||h[Item 1001]||h||r")
check("item description", bandage[Column(itemBlock, "DESCRIPTION")], "")
check("item spell", bandage[Column(itemBlock, "SPELL_NAME")], "Use 7001")
check("item spell ID", bandage[Column(itemBlock, "SPELL_ID")], "7001")
check("item spell text", bandage[Column(itemBlock, "SPELL_DESCRIPTION")], "Restores 100 health.")
check("tooltip", bandage[Column(itemBlock, "TOOLTIP")], "Item 1001 // Requires First Aid (1)")
check("tooltip is the last column", Column(itemBlock, "TOOLTIP"), #itemBlock.columns)
check("instant type", bandage[Column(itemBlock, "INSTANT_TYPE")], "Consumable")
check("detailed item level", bandage[Column(itemBlock, "ILVL_BASE")], "5")
check("stats through ns.GetItemStats", bandage[Column(itemBlock, "STATS")], "ITEM_MOD_STAMINA_SHORT=1")
check("consumable", bandage[Column(itemBlock, "IS_CONSUMABLE")], "true")
check("a reader this client lacks leaves its cell blank", bandage[Column(itemBlock, "IS_HELPFUL")], "")
local slowSpell = Find(itemBlock, "1007")
check("spell text waited for", slowSpell[Column(itemBlock, "SPELL_DESCRIPTION")], "Restores 200 mana.")
check("its spell was asked for", (spellRequests[7007] or 0) >= 1, true)
check("tabs and newlines flattened", Find(itemBlock, "1008")[Column(itemBlock, "TOOLTIP")], "Tab here // Two lines")
check("right-hand text", Find(itemBlock, "1009")[Column(itemBlock, "TOOLTIP")], "Weapon // Main Hand >> Sword")

say("6. Stragglers, missing IDs and a throwing reader settle without stopping the run")
local neverAnswered = Find(itemBlock, "1002")
check("never answered", neverAnswered[1], "NOT ON CLIENT")
check("still printed in full", #neverAnswered, #itemBlock.columns)
check("with what the client's own data knows", neverAnswered[Column(itemBlock, "INSTANT_TYPE")], "Consumable")
check("asked again while it waited", requests[1002] > 1, true)
check("missing from the client", Find(itemBlock, "1003")[1], "NOT ON CLIENT")
check("never requested", requests[1003], nil)
local stuck = Find(itemBlock, "1004")
check("loaded partway", stuck[1], "INCOMPLETE")
check("showing how far it got", stuck[4], "Item 1004")
check("lost request retried", Find(itemBlock, "1005")[1], "OK")
check("requested twice", requests[1005], 2)
check("retried only after idle polls", lastRequestTick[1005] - firstRequestTick[1005] >= 3, true)
local thrown = Find(itemBlock, "1006")
check("reader threw", thrown[1], "ERROR")
check("error where the name goes", thrown[4]:find("uniqueness exploded", 1, true) ~= nil, true)
check("the row after it still settled", Find(itemBlock, "1010")[1], "OK")
local counts = {}
for _, cells in ipairs(itemBlock.rows) do
	counts[cells[1]] = (counts[cells[1]] or 0) + 1
	assert(#cells == #itemBlock.columns, "row " .. tostring(cells[3]) .. " has " .. #cells .. " cells")
end
check("OK rows", counts.OK, 246)
check("table never built", counts["TABLE MISSING"], 1)
check("TABLE MISSING names the table", itemBlock.rows[1][2], "TEST_NEVER_BUILT")
check("other table counted", otherBlock.rows[1][3], "3")
check("tallies count OK (items, the spell and the other table)", finished[1].counts.OK, 248)
check("tallies count NOT ON CLIENT", finished[1].counts["NOT ON CLIENT"], 3)

say("7. Turning the tools off stops a run and clears its report")
ns:RunDiagnosticReport("data", "data2")
check("the run is going", ns.diagnostics.running, "data")
check("its progress shows", ns:GetDataValidationProgress(2) ~= nil, true)
ns:SetDiagnosticsEnabled(false)
local requestsAtStop = requests[2001]
PumpAll()
check("no run left", ns.diagnostics.running, nil)
check("no progress left", ns:GetDataValidationProgress(2), nil)
check("no report left", ns.diagnostics.outputs.data, nil)
check("nothing asked for after the stop", requests[2001], requestsAtStop)
ns:SetDiagnosticsEnabled(true)

say("8. A second press restarts the file, and the first run goes quiet")
local firstRunFinishes, secondRunText = 0, nil
ns:StartDataValidation(3, function()
	firstRunFinishes = firstRunFinishes + 1
end)
ns:StartDataValidation(3, function(text)
	secondRunText = text
end)
PumpAll()
check("first run quiet after the restart", firstRunFinishes, 0)
check("second run finished", secondRunText and secondRunText:find("STATUS\tSOURCE\tITEM_ID", 1, true) ~= nil, true)
check("run cleared", ns:GetDataValidationProgress(3), nil)

say("9. Progress repaints at most once a second, and the finished report always does")
secondsPerTick = 0.2
repaints = {}
local finishedAt
local startTick = tick
ns:StartDataValidation(1, function()
	finishedAt = #repaints
end)
PumpAll()
local seconds = (tick - startTick) * secondsPerTick
check("fewer repaints than polls", #repaints < tick - startTick, true)
check("no more than one a second, plus the first and the last", #repaints <= math.floor(seconds) + 2, true)
check("the last repaint follows the finished report", finishedAt, #repaints - 1)
check("repaints the Diagnostics panel", repaints[#repaints].appName, "Test_Diagnostics")
secondsPerTick = 1

say("10. A spell whose data never arrives holds its batch until the idle cap, then settles INCOMPLETE")
local textlessStart = tick
local textlessReport
ns:StartDataValidation(4, function(text)
	textlessReport = text
end)
PumpAll()
local textlessBlocks = Blocks(textlessReport)
local textlessItems, textlessSpells = textlessBlocks[1], textlessBlocks[2]
local auraRow = Find(textlessSpells, "7101")
check("a cached spell with no text of its own is OK", auraRow[1], "OK")
check("spell printed in full", #auraRow, #textlessSpells.columns)
check("spell description", auraRow[Column(textlessSpells, "SPELL_DESCRIPTION")], "")
local textlessItem = Find(textlessItems, "4001")
check("item status", textlessItem[1], "INCOMPLETE")
check("item printed in full", #textlessItem, #textlessItems.columns)
check("item spell ID", textlessItem[Column(textlessItems, "SPELL_ID")], "7102")
check("item spell text", textlessItem[Column(textlessItems, "SPELL_DESCRIPTION")], "")
-- The idle cap is 12 polls, one timer each.
check("held open for the idle cap", tick - textlessStart >= 12, true)
check("the item's spell data asked for again", (spellRequests[7102] or 0) > 1, true)

say("")
if failures == 0 then
	say("ALL VALIDATE DATA SCENARIOS PASSED")
else
	say(failures .. " VALIDATE DATA SCENARIOS FAILED")
	os.exit(1)
end
