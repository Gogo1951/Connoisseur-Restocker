-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the Diagnostics event-log filter (no WoW client needed).

    Run it with:   lua Tests/Diagnostics-Event-Log-Test.lua        (from the add-on root)

    Like Readiness-Report-Test, this does NOT model the logic: it loads the REAL
    Diagnostics/Diagnostics-Core.lua and Diagnostics/Event-Log.lua and drives
    ns:LogEvent, ns:LogEventNow and ns:BuildEventLogReport behind the thinnest
    stubs that will hold them up.

    WHAT IS PINNED HERE. A bounded log that fills with noise evicts the entries a
    bug report needs, so uncorrelated UI_ERROR_MESSAGE traffic folds into one
    counted row. The filter must never swallow what the add-on acts on, and a
    firing it cannot classify is signal, so it logs verbatim. UNIT_AURA is only
    counted at capture, and its handler writes the firings that mattered.
]]

local ROOT = arg[1] or "."

-- Locale keys resolve to their own name, and the add-on's title is Data/Data.lua's copy of ADDON_TITLE.
local ns = {
	L = setmetatable({}, {
		__index = function(_, key)
			return key
		end,
	}),
	ADDON_TITLE = "ADDON_TITLE",
	Version = "Test",
	FLAVOR = "Vanilla",
	DATA_FOLDER = "Vanilla",
}

--------------------------------------------------------------------------------
-- Stubs
--------------------------------------------------------------------------------

ERR_ITEM_WRONG_ZONE = "You can't use that item in this zone."
SPELL_FAILED_TARGETS_DEAD = "Your target is dead."

function GetTime()
	return 1000
end
function GetBuildInfo()
	return "1.15.9", "69109", "Sep 1 2026", 11509
end
function GetLocale()
	return "enUS"
end

-- A stand-in for a Forever secret value: any attempt to turn it into text throws.
local SECRET = setmetatable({}, {
	__tostring = function()
		error("attempt to use a secret value")
	end,
})
function ns.IsSecretValue(value)
	return value == SECRET
end

local realPrint = io.write
local function say(text)
	realPrint(text .. "\n")
end

assert(loadfile(ROOT .. "/Diagnostics/Diagnostics-Core.lua"))("Consumable-Connoisseur", ns)
assert(loadfile(ROOT .. "/Diagnostics/Event-Log.lua"))("Consumable-Connoisseur", ns)

--------------------------------------------------------------------------------

local failures = 0

local function check(label, got, want)
	if got == want then
		say(("  ok    %s = %s"):format(label, tostring(got)))
	else
		failures = failures + 1
		say(("  FAIL  %s: got %s, want %s"):format(label, tostring(got), tostring(want)))
	end
end

-- The report's log lines (timestamped entries), without the header or summary.
local function logLines(report)
	local lines = {}
	for line in (report .. "\n"):gmatch("(.-)\n") do
		if line:find("^%d+%.%d%d%d ") then
			lines[#lines + 1] = line
		end
	end
	return lines
end

local function hasLine(report, wanted)
	for line in (report .. "\n"):gmatch("(.-)\n") do
		if line == wanted then
			return true
		end
	end
	return false
end

--------------------------------------------------------------------------------

say("1. Fifty uncorrelated UI_ERROR_MESSAGE firings fold into one counted row")
ns:StartEventLog()
for _ = 1, 50 do
	ns:LogEvent("UI_ERROR_MESSAGE", 56, "Ability is not ready yet.")
end
local report = ns:BuildEventLogReport()
check("no log lines", #logLines(report), 0)
check("counted row", hasLine(report, "UI_ERROR_MESSAGE(Ability is not ready yet.) x50"), true)

say("2. A message the add-on acts on still logs as a full line")
ns:StartEventLog()
ns:LogEvent("UI_ERROR_MESSAGE", 3, ERR_ITEM_WRONG_ZONE)
report = ns:BuildEventLogReport()
check("one log line", #logLines(report), 1)
check("full line", logLines(report)[1], "1000.000 UI_ERROR_MESSAGE(3, You can't use that item in this zone.)")
check("nothing suppressed", report:find("Suppressed", 1, true), nil)

say("3. A firing without a string message logs verbatim and is not counted")
ns:StartEventLog()
ns:LogEvent("UI_ERROR_MESSAGE", 56, 12)
report = ns:BuildEventLogReport()
check("one log line", #logLines(report), 1)
check("verbatim", logLines(report)[1], "1000.000 UI_ERROR_MESSAGE(56, 12)")
check("nothing suppressed", report:find("Suppressed", 1, true), nil)

say("4. UNIT_AURA is counted at capture, and ns:LogEventNow writes the firing that mattered")
ns:StartEventLog()
for _ = 1, 3 do
	ns:LogEvent("UNIT_AURA", "player")
end
report = ns:BuildEventLogReport()
check("no log lines", #logLines(report), 0)
check("counted row", hasLine(report, "UNIT_AURA(player) x3"), true)
ns:LogEventNow("UNIT_AURA", "player")
report = ns:BuildEventLogReport()
check("one log line", #logLines(report), 1)
check("full line", logLines(report)[1], "1000.000 UNIT_AURA(player)")

say("5. A secret argument is written as <secret>, never turned into text")
ns:StartEventLog()
ns:LogEvent("UNIT_SPELLCAST_SUCCEEDED", "player", SECRET, SECRET)
report = ns:BuildEventLogReport()
check("one log line", #logLines(report), 1)
check("full line", logLines(report)[1], "1000.000 UNIT_SPELLCAST_SUCCEEDED(player, <secret>, <secret>)")

say("")
if failures == 0 then
	say("ALL EVENT LOG SCENARIOS PASSED")
else
	say(failures .. " EVENT LOG SCENARIOS FAILED")
	os.exit(1)
end
