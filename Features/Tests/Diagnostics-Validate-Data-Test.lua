-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for Validate Data (no WoW client needed).

    Run it with:   lua Features/Tests/Diagnostics-Validate-Data-Test.lua        (from the add-on root)

    Like Diagnostics-Event-Log-Test, this does NOT model the logic: it loads the
    REAL Features/Utilities.lua for its tooltip readers and the REAL
    Features/Diagnostics.lua for ns.RunDataValidation, behind stubs that model a
    client answering a load request a few timer ticks after it is made, with
    C_Timer.After queued and pumped by hand.

    WHAT IS PINNED HERE. The IDs go through a hundred at a time, and no ID of the
    next batch is requested until every row of this one has settled. A row is OK
    only once its item or spell, its text and its tooltip have all loaded; one
    that never loads is NOT ON CLIENT, one that loaded partway is INCOMPLETE, and
    a reader that throws settles an ERROR row without stopping the run. Every
    row carries one cell per header column, and both tooltip readers return
    { left, right } pairs.
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
-- Tooltip Readers (Features/Utilities.lua)
--------------------------------------------------------------------------------

say("1. Forever reads C_TooltipInfo's lines as { left, right } pairs")
C_TooltipInfo = {
	GetItemByID = function()
		return {
			lines = {
				{ leftText = "Linen Bandage" },
				{ leftText = "Use: Heals 66 damage over 6 sec." },
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
local lines = foreverNs.GetItemTooltipLines(1251)
check("item lines", #lines, 3)
check("first line", lines[1][1], "Linen Bandage")
check("right-hand text", lines[3][2], "Sword")
check("no data reads as no lines", #foreverNs.GetSpellTooltipLines(746), 0)
C_TooltipInfo = nil

say("2. Era and TBC fill one hidden tooltip, reused, and skip a hidden right-hand text")
local SCAN_NAME = "ConnoisseurScanTooltip"
local SCAN_LINES = {
	SetItemByID = { { "Linen Bandage" }, { "Main Hand", "Sword" } },
	SetSpellByID = { { "First Aid" } },
}
local framesCreated, owned = 0, false

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

local function Fill(tooltip, setter)
	assert(owned, "a setter ran before SetOwner")
	tooltip.lineCount = #SCAN_LINES[setter]
	for index, line in ipairs(SCAN_LINES[setter]) do
		_G[SCAN_NAME .. "TextLeft" .. index].text = line[1]
		local right = _G[SCAN_NAME .. "TextRight" .. index]
		right.shown = line[2] ~= nil
		right.text = line[2] or right.text
	end
end

function CreateFrame()
	framesCreated = framesCreated + 1
	local tooltip = {}
	function tooltip:SetOwner()
		owned = true
	end
	function tooltip:SetItemByID()
		Fill(self, "SetItemByID")
	end
	function tooltip:SetSpellByID()
		Fill(self, "SetSpellByID")
	end
	function tooltip:NumLines()
		return self.lineCount
	end
	function tooltip:Hide()
		owned = false
	end
	return tooltip
end
UIParent = {}

local eraNs = { PALETTE = {} }
Load("Features/Utilities.lua", eraNs)
check("nothing created at load", framesCreated, 0)
lines = eraNs.GetItemTooltipLines(1251)
check("item lines", #lines, 2)
check("hidden right-hand text skipped", lines[1][2], nil)
check("right-hand text", lines[2][2], "Sword")
lines = eraNs.GetSpellTooltipLines(746)
check("spell line", lines[1][1], "First Aid")
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

RETRIEVING_ITEM_INFO = "Retrieving item information"

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
	[7101] = { name = "Aura 7101", description = "", cached = true }, -- its record is at hand, its text never arrives
	[7102] = { name = "Use 7102", description = "", cached = true },
}

local items = {}
for id = 1001, 1250 do
	items[id] = { exists = true, delay = 1 }
end
items[1001].spellID = 7001
items[1002].delay = math.huge -- in the client's data, but the server never answers
items[1003].exists = false -- not on this client at all
items[1004].tooltipStuck = true -- loads, but its tooltip never gets past the retrieving line
items[1005].dropFirst = true
items[1006].throws = true
items[1007].spellID = 7007 -- its spell text loads only once asked for
items[1008].tooltip = { { "Tab\there" }, { "Two\nlines" } }
items[1009].tooltip = { { "Weapon" }, { "Main Hand", "Sword" } }
items[1050].delay = 8 -- the slow row that holds the first batch open
for id = 2001, 2003 do
	items[id] = { exists = true, delay = 3 }
end
for id = 3001, 3003 do
	items[id] = { exists = true, delay = 3 }
end
items[4001] = { exists = true, delay = 1, spellID = 7102 } -- loads, but its spell's text never arrives

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
	GetItemSetInfo = function()
		return nil
	end,
	IsConsumableItem = function()
		return true
	end,
	IsEquippableItem = function()
		return false
	end,
	IsHelpfulItem = function()
		return true
	end,
	IsHarmfulItem = function()
		return false
	end,
	ItemHasRange = function()
		return false
	end,
	IsUsableItem = function()
		return true, false
	end,
	GetItemCount = function()
		return 0
	end,
}

C_Spell = {
	DoesSpellExist = function(id)
		return spells[id] ~= nil
	end,
	RequestLoadSpellData = function(id)
		spellRequests[id] = (spellRequests[id] or 0) + 1
		local spell = spells[id]
		if spell and not spell.cached then
			spell.loadedAt = spell.loadedAt or tick + spell.delay
		end
	end,
	GetSpellInfo = function(id)
		local spell = spells[id]
		if spell then
			return {
				name = spell.name,
				iconID = 135966,
				originalIconID = 135966,
				castTime = 0,
				minRange = 0,
				maxRange = 0,
				spellID = id,
			}
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
			return { { name = "MANA", cost = 10, minCost = 10, costPercent = 0, costPerSec = 0, requiredAuraID = 0 } }
		end
		return {}
	end,
	GetSpellLink = function(id)
		return "|cff71d5ff|Hspell:" .. id .. "|h[Spell]|h|r"
	end,
	GetSpellLevelLearned = function()
		return 1
	end,
	GetSpellMaxCumulativeAuraApplications = function()
		return 0
	end,
	IsSpellPassive = function()
		return false
	end,
	IsSpellHelpful = function()
		return true
	end,
	IsSpellHarmful = function()
		return false
	end,
	SpellHasRange = function()
		return false
	end,
	-- Throws on an unknown ID, as a reader may.
	IsSelfBuff = function(id)
		if not spells[id] then
			error("not a spell")
		end
		return false
	end,
	IsConsumableSpell = function()
		return false
	end,
}

--------------------------------------------------------------------------------
-- The Run (Features/Diagnostics.lua)
--------------------------------------------------------------------------------

local ns = {
	L = setmetatable({}, {
		__index = function(_, key)
			return key
		end,
	}),
	Version = "Test",
	FLAVOR = "Camelot",
	DATA_FOLDER = "Camelot",
	MISSING_SPELL_MESSAGE_IDS = {},
}
Load("Features/Diagnostics.lua", ns)
ns.diagnostics.enabled = true

function ns.IsPlayerSpell()
	return false
end
function ns.IsSpellKnown()
	return false
end
function ns.GetItemTooltipLines(id)
	local item = items[id]
	if not Loaded(item) or item.tooltipStuck then
		return { { RETRIEVING_ITEM_INFO } }
	end
	return item.tooltip or { { "Item " .. id }, { "Requires First Aid (1)" } }
end
function ns.GetSpellTooltipLines(id)
	local spell = spells[id]
	return { { spell.name }, { SpellLoaded(spell) and spell.description or "" } }
end

local function Keys(source)
	local ids = {}
	for id in pairs(source) do
		ids[#ids + 1] = id
	end
	return ids
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
ns.DIAGNOSTIC_DATA_SOURCES = {
	{
		label = "Test",
		tables = {
			{ table = "TEST_SPELLS", kind = "spell", idsOf = Keys },
			{ table = "TEST_ITEMS", kind = "item", idsOf = Keys },
			{ table = "TEST_NEVER_BUILT", kind = "item", idsOf = Keys },
			{ table = "TEST_OTHER", kind = "other", idsOf = Keys },
		},
	},
	{ label = "Small", tables = { { table = "TEST_SMALL", kind = "item", idsOf = Keys } } },
	{ label = "Restart", tables = { { table = "TEST_RESTART", kind = "item", idsOf = Keys } } },
	{
		label = "Textless",
		tables = {
			{ table = "TEST_TEXTLESS_SPELLS", kind = "spell", idsOf = Keys },
			{ table = "TEST_TEXTLESS_ITEMS", kind = "item", idsOf = Keys },
		},
	},
}

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

local function Find(block, idColumnValue)
	for _, cells in ipairs(block.rows) do
		if cells[2] == idColumnValue then
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
local updates = {}
ns.RunDataValidation(1, "testReport", function()
	updates[#updates + 1] = ns.diagnostics.testReport
end)
PumpAll()
check("the slow row loaded before the next batch was asked for", firstRequestTick[1099] > items[1050].loadedAt, true)
check("the last retry of a straggler came first too", firstRequestTick[1099] > lastRequestTick[1002], true)
check("the third batch waited on the second", firstRequestTick[1199] > firstRequestTick[1198], true)
local sawBatch = {}
for _, text in ipairs(updates) do
	local batch = text:match("Validated [%d,]+ / 253 IDs %(batch (%d) of 3%)%.%.%.")
	if batch then
		sawBatch[batch] = true
	end
end
check("progress named batch 1", sawBatch["1"], true)
check("progress named batch 2", sawBatch["2"], true)
check("progress named batch 3", sawBatch["3"], true)

local report = ns.diagnostics.testReport
local blocks = Blocks(report)
check(
	"report opens with the client header",
	report:match("^[^\n]+"),
	"ADDON_TITLE Test // Client 1.60.1 // Build 69977 // TOC 16001 // Locale enUS // Flavor Camelot // Data Camelot"
)
check("three blocks", #blocks, 3)
local spellBlock, itemBlock, otherBlock = blocks[1], blocks[2], blocks[3]
check("spell columns", #spellBlock.columns, 24)
check("item columns", #itemBlock.columns, 49)

say("4. A spell row carries its text, its tooltip and its costs")
local firstAid = Find(spellBlock, "746")
check("status", firstAid[1], "OK")
check("cells", #firstAid, #spellBlock.columns)
check("description", firstAid[Column(spellBlock, "Description")], "Heals 66 damage over 6 sec.")
check("tooltip", firstAid[Column(spellBlock, "Tooltip")], "First Aid // Heals 66 damage over 6 sec.")
check("power cost", firstAid[Column(spellBlock, "Power Cost")], "MANA 10")
check("link pipes escaped", firstAid[Column(spellBlock, "Link")], "||cff71d5ff||Hspell:746||h[Spell]||h||r")
local unknownSpell = Find(spellBlock, "999999")
check("unknown spell flagged", unknownSpell[1], "NOT ON CLIENT")
check("a reader that threw on it left the flag", #unknownSpell, 3)

say("5. An item row carries its spell, the spell's text and its tooltip")
local bandage = Find(itemBlock, "1001")
check("status", bandage[1], "OK")
check("cells", #bandage, #itemBlock.columns)
check("link pipes escaped", bandage[Column(itemBlock, "Link")], "||cffffffff||Hitem:1001||h[Item 1001]||h||r")
check("item description", bandage[Column(itemBlock, "Item Description")], "")
check("item spell", bandage[Column(itemBlock, "Item Spell")], "Use 7001")
check("item spell ID", bandage[Column(itemBlock, "Item Spell ID")], "7001")
check("item spell text", bandage[Column(itemBlock, "Item Spell Description")], "Restores 100 health.")
check("tooltip", bandage[Column(itemBlock, "Tooltip")], "Item 1001 // Requires First Aid (1)")
check("instant type", bandage[Column(itemBlock, "Instant Type")], "Consumable")
check("detailed item level", bandage[Column(itemBlock, "Sparse Item Level")], "5")
check("usable", bandage[Column(itemBlock, "IsUsableItem")], "true")
check("no mana", bandage[Column(itemBlock, "No Mana")], "false")
check("last column filled", bandage[Column(itemBlock, "Count In Bags")], "0")
local slowSpell = Find(itemBlock, "1007")
check("spell text waited for", slowSpell[Column(itemBlock, "Item Spell Description")], "Restores 200 mana.")
check("its spell was asked for", (spellRequests[7007] or 0) >= 1, true)
check("tabs and newlines flattened", Find(itemBlock, "1008")[Column(itemBlock, "Tooltip")], "Tab here // Two lines")
check("right-hand text", Find(itemBlock, "1009")[Column(itemBlock, "Tooltip")], "Weapon // Main Hand >> Sword")

say("6. Stragglers, missing IDs and a throwing reader settle without stopping the run")
local neverAnswered = Find(itemBlock, "1002")
check("never answered", neverAnswered[1], "NOT ON CLIENT")
check("still printed in full", #neverAnswered, #itemBlock.columns)
check("with what the client's own data knows", neverAnswered[Column(itemBlock, "Instant Type")], "Consumable")
check("asked again while it waited", requests[1002] > 1, true)
check("missing from the client", Find(itemBlock, "1003")[1], "NOT ON CLIENT")
check("never requested", requests[1003], nil)
local stuck = Find(itemBlock, "1004")
check("loaded partway", stuck[1], "INCOMPLETE")
check("showing how far it got", stuck[Column(itemBlock, "Tooltip")], "Retrieving item information")
check("lost request retried", Find(itemBlock, "1005")[1], "OK")
check("requested twice", requests[1005], 2)
check("retried only once the batch stopped moving", lastRequestTick[1005] > items[1050].loadedAt, true)
local thrown = Find(itemBlock, "1006")
check("reader threw", thrown[1], "ERROR")
check("error where the name goes", thrown[4]:find("uniqueness exploded", 1, true) ~= nil, true)
check("the row after it still settled", Find(itemBlock, "1010")[1], "OK")
local counts = {}
for _, cells in ipairs(itemBlock.rows) do
	counts[cells[1]] = (counts[cells[1]] or 0) + 1
	if cells[1] == "OK" or cells[1] == "INCOMPLETE" then
		assert(#cells == #itemBlock.columns, "row " .. cells[2] .. " has " .. #cells .. " cells")
	end
end
check("OK rows", counts.OK, 246)
check("table never built", counts["TABLE MISSING"], 1)
check("TABLE MISSING names the table", itemBlock.rows[#itemBlock.rows][3], "ns.TEST_NEVER_BUILT")
check("other table counted", otherBlock.rows[1][3], "3")

say("7. Turning the tools off stops a run and clears its progress line")
ns.RunDataValidation(2, "smallReport", function() end)
ns.diagnostics.enabled = false
PumpAll()
check("no progress line left", ns.diagnostics.smallReport, nil)
check("run stopped", ns.diagnostics.validationRuns[2], nil)
ns.diagnostics.enabled = true

say("8. A second press restarts the section, and the first run goes quiet")
local firstRunUpdates, secondRunUpdates = 0, 0
ns.RunDataValidation(3, "restartReport", function()
	firstRunUpdates = firstRunUpdates + 1
end)
local before = firstRunUpdates
ns.RunDataValidation(3, "restartReport", function()
	secondRunUpdates = secondRunUpdates + 1
end)
PumpAll()
check("first run quiet after the restart", firstRunUpdates, before)
check("second run finished", ns.diagnostics.restartReport:find("STATUS\tItem ID", 1, true) ~= nil, true)
check("run cleared", ns.diagnostics.validationRuns[3], nil)

say("9. Progress repaints at most once a second, and the finished report always does")
secondsPerTick = 0.2
local paints = {}
local startTick = tick
ns.RunDataValidation(1, "throttledReport", function()
	paints[#paints + 1] = ns.diagnostics.throttledReport
end)
PumpAll()
local seconds = (tick - startTick) * secondsPerTick
check("fewer repaints than polls", #paints < tick - startTick, true)
check("no more than one a second, plus the first and the last", #paints <= math.floor(seconds) + 2, true)
check("the last repaint is the finished report", paints[#paints], ns.diagnostics.throttledReport)
check("finished report", paints[#paints]:find("STATUS\tItem ID", 1, true) ~= nil, true)
secondsPerTick = 1

say("10. Text that never arrives holds its batch until the idle cap, then settles INCOMPLETE")
local textlessStart = tick
ns.RunDataValidation(4, "textlessReport", function() end)
PumpAll()
local textlessBlocks = Blocks(ns.diagnostics.textlessReport)
local textlessSpells, textlessItems = textlessBlocks[1], textlessBlocks[2]
local auraRow = Find(textlessSpells, "7101")
check("spell status", auraRow[1], "INCOMPLETE")
check("spell printed in full", #auraRow, #textlessSpells.columns)
check("spell description", auraRow[Column(textlessSpells, "Description")], "")
local textlessItem = Find(textlessItems, "4001")
check("item status", textlessItem[1], "INCOMPLETE")
check("item printed in full", #textlessItem, #textlessItems.columns)
check("item spell ID", textlessItem[Column(textlessItems, "Item Spell ID")], "7102")
check("item spell text", textlessItem[Column(textlessItems, "Item Spell Description")], "")
-- The idle cap is 25 polls, and the first poll runs at once rather than on a timer.
check("held open for the idle cap", tick - textlessStart >= 24, true)
check("the spell's text asked for again", (spellRequests[7101] or 0) > 1, true)
check("the item's spell text asked for again", (spellRequests[7102] or 0) > 1, true)

say("")
if failures == 0 then
	say("ALL VALIDATE DATA SCENARIOS PASSED")
else
	say(failures .. " VALIDATE DATA SCENARIOS FAILED")
	os.exit(1)
end
