local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader

--------------------------------------------------------------------------------
-- Event Log
--------------------------------------------------------------------------------

local EVENT_LOG_SIZE = 500
local EVENT_LOG_MAX_ARGS = 8
local EVENT_LOG_MAX_ARG_LENGTH = 255

--[[
    Events ns:LogEvent can only count, never classify: kept out of the buffer
    and folded into the suppressed-traffic summary, keyed by their first
    argument, so the report still shows the event fired and how often.

    UNIT_AURA is the one entry. It is a firehose whose signal firings can't be
    told apart at capture: LogEvent runs from Core's dispatcher before the real
    handler, so nothing yet knows whether this aura change moved anything the
    add-on tracks. ns.OnUnitAura (Features/Scanner-Auras.lua) writes the
    firings it acted on through ns:LogEventNow once it has decided.
]]
ns.DIAGNOSTIC_EVENT_EXCLUDE = {
	UNIT_AURA = true,
}

--[[
    Events ns:SuppressUncorrelatedMessage classifies per firing, and the
    argument position of the field it classifies by. UI_ERROR_MESSAGE fires as
    (messageType, message), and every handler that acts on it compares the
    message text, so position 2 is the field the filter reads.
]]
ns.MESSAGE_ID_FILTERED_EVENTS = {
	UI_ERROR_MESSAGE = 2,
}

--[[
    The allowlist: the messages the add-on acts on, each the exact global its
    live handler compares against, read on every call so the filter can't
    drift from the handlers: ERR_ITEM_WRONG_ZONE (Features/Macros/Runtime.lua),
    SPELL_FAILED_TARGETS_DEAD (Features/Macros/Tools-Hunters.lua), and
    ERR_INV_FULL and ERR_BANK_FULL (Features/Restocker/Restocker-Events.lua).
]]
local function IsCorrelatedMessage(text)
	return text == ERR_ITEM_WRONG_ZONE
		or text == SPELL_FAILED_TARGETS_DEAD
		or text == ERR_INV_FULL
		or text == ERR_BANK_FULL
end

--[[
    One argument as report text. A secret argument (Forever, while the client
    restricts the data, such as a cast's spell id mid-fight) is written as
    <secret> before any string work touches it, since string work on a secret
    value can throw or hand back another secret. Pipes are escaped (| -> ||)
    after the length cut, so the cut can never leave a dangling pipe.
]]
local function ArgumentText(value)
	if ns.IsSecretValue(value) then
		return "<secret>"
	end
	local raw = string.sub(tostring(value), 1, EVENT_LOG_MAX_ARG_LENGTH)
	return (raw:gsub("|", "||"))
end

-- One firing folded into the suppressed-traffic counters, keyed by its event and id.
local function CountSuppressed(event, messageID, text)
	local suppressed = ns.diagnostics.suppressed
	if not suppressed then
		return
	end
	local key = event .. "\0" .. tostring(messageID)
	local entry = suppressed[key]
	if entry then
		entry.count = entry.count + 1
		return
	end
	suppressed[key] = { event = event, id = messageID, text = text, count = 1 }
end

--[[
    Per-firing filter for the events above. A firing whose message the add-on
    does not correlate folds into a per-message counter (first-seen text plus
    a count) rendered as one block at the end of the report, so firehose
    traffic can't evict the entries the log exists to carry. A firing carrying
    no message text in the filtered position is unclassifiable, and
    unclassifiable is signal: it logs verbatim.

    Returns true when the firing was counted and must not reach the buffer.
]]
function ns:SuppressUncorrelatedMessage(event, ...)
	local idPosition = ns.MESSAGE_ID_FILTERED_EVENTS[event]
	if not idPosition then
		return false
	end
	local messageID = select(idPosition, ...)
	if ns.IsSecretValue(messageID) or type(messageID) ~= "string" then
		return false
	end
	if IsCorrelatedMessage(messageID) then
		return false
	end
	local text = ""
	if select("#", ...) > idPosition then
		text = ArgumentText((select(idPosition + 1, ...)))
	end
	CountSuppressed(event, ArgumentText(messageID), text)
	return true
end

function ns:StartEventLog()
	ns.diagnostics.log = {}
	ns.diagnostics.suppressed = {}
	ns.diagnostics.logging = true
end

function ns:StopEventLog()
	ns.diagnostics.logging = false
end

--[[
    One entry in the buffer, for ns:LogEvent and ns:LogEventNow below.
    Snapshots arguments to strings immediately -- never retain references, since
    some events carry frames or tables that would leak memory or go stale. Caps
    the arg count and per-argument byte length so a single entry can't run away.

    Pipes are escaped (| -> ||) AFTER the length cut so each argument shows
    verbatim in the report editbox instead of rendering as a clickable item
    swatch. Escaping last also means the cut can never leave a dangling pipe that
    would eat the following ", " separator.
]]
local function AppendEntry(event, ...)
	local log = ns.diagnostics.log
	if not log then
		return
	end
	local parts = {}
	for index = 1, select("#", ...) do
		if index > EVENT_LOG_MAX_ARGS then
			break
		end
		parts[index] = ArgumentText((select(index, ...)))
	end
	log[#log + 1] = string.format("%.3f %s(%s)", GetTime(), event, table.concat(parts, ", "))
	if #log > EVENT_LOG_SIZE then
		table.remove(log, 1)
	end
end

-- Called by Core's central dispatcher for every event while logging is active.
function ns:LogEvent(event, ...)
	if ns.DIAGNOSTIC_EVENT_EXCLUDE[event] then
		CountSuppressed(event, select("#", ...) > 0 and ArgumentText((select(1, ...))) or "", "")
		return
	end
	if ns:SuppressUncorrelatedMessage(event, ...) then
		return
	end
	AppendEntry(event, ...)
end

--[[
    The way back in for an excluded firehose that is sometimes signal: the
    handler that decides a firing mattered calls this with the event and its
    arguments, and it is recorded as the dispatcher would have, past the
    exclude list. Feature code calls it, so it carries the dispatcher's own
    single boolean check before any work.
]]
function ns:LogEventNow(event, ...)
	if not ns.diagnostics.logging then
		return
	end
	AppendEntry(event, ...)
end

--[[
    Renders the suppressed-traffic counters as one compact block, biggest
    offender first. This is also how a tester discovers a message id the add-on
    should be correlating but isn't.
]]
local function AppendSuppressedSummary(lines)
	local suppressed = ns.diagnostics.suppressed
	if not suppressed then
		return
	end
	local rows = {}
	for _, entry in pairs(suppressed) do
		rows[#rows + 1] = { id = entry.id, entry = entry }
	end
	if #rows == 0 then
		return
	end
	table.sort(rows, function(a, b)
		if a.entry.count ~= b.entry.count then
			return a.entry.count > b.entry.count
		end
		return tostring(a.id) < tostring(b.id)
	end)
	lines[#lines + 1] = ""
	lines[#lines + 1] = "Suppressed uncorrelated traffic:"
	for _, row in ipairs(rows) do
		local fields = row.entry.text ~= "" and (tostring(row.id) .. ", " .. row.entry.text) or tostring(row.id)
		lines[#lines + 1] = string.format("%s(%s) x%d", row.entry.event, fields, row.entry.count)
	end
end

function ns:BuildEventLogReport()
	local lines = { GetClientHeader(), "" }
	local log = ns.diagnostics.log
	if not log or #log == 0 then
		lines[#lines + 1] = "(no events captured)"
	else
		for _, entry in ipairs(log) do
			lines[#lines + 1] = entry
		end
	end
	AppendSuppressedSummary(lines)
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Taint Log
--------------------------------------------------------------------------------

--[[
    The taintLog CVar controls UI taint logging to Logs\taint.log. Level 2 logs
    both blocked actions and accesses to tainted globals; 0 is off. This is the
    only state the diagnostics panel ever writes.
]]

function ns:GetTaintLogState()
	return tonumber(GetCVar("taintLog")) or 0
end

function ns:SetTaintLog(enabled)
	SetCVar("taintLog", enabled and 2 or 0)
end
