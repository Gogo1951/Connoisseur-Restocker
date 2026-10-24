local _, ns = ...
local GetColor = ns.GetColor
local L = ns.L

--------------------------------------------------------------------------------
-- Macro Writing
--------------------------------------------------------------------------------

--[[
    CreateMacro wrapper, used by ns.WriteMacroBody. The perCharacter
    argument is deliberately omitted: Connoisseur macros always live in
    the General (account-wide) tab. Every character shares those macros,
    and each character's first update pass after login rewrites the
    shared bodies to its own best items, so the macros self-heal on every
    character switch.

    Do NOT pass a numeric 1 here to "mean" General — this client
    boolean-checks the argument (verified in-game: true lands in the
    character-specific tab, 1 lands in General), so a number only
    produces a General macro by accident and would silently flip tabs if
    a future build starts accepting numbers as true. Omitting the
    argument is the unambiguous spelling of "General tab" on every
    client.

    Creation is skipped entirely when it would dip into the player's last
    ns.MACRO_SLOT_CUSHION free General slots — those stay reserved for
    the player's own macros. pcall plus the nil-check still covers both
    failure modes of a truly full macro book (some client builds raise an
    error, others return nil), in case another add-on races us past the
    cushion. Either way the warning prints once per session, and callers
    leave their state key unset on failure so creation retries — and
    resumes automatically — once slots free up.
]]
local macroSlotsWarned = false

local function WarnMacroSlots()
	if not macroSlotsWarned then
		macroSlotsWarned = true
		ns.PrintMessage(L["MESSAGE_MACRO_SLOTS_FULL"])
	end
end

--[[
    Nothing in the game tells a player the macros exist: they appear silently
    in a macro tab most players never open. So every creation says where they
    are, once per update pass however many it made, which in practice is the
    first login and a macro switched back on. A timer rather than the end of
    the pass, because the pass is spread across the engine and the custom
    definitions with no single place that knows it is over.
]]
local readyMessagePending = false

local function AnnounceMacrosReady()
	if readyMessagePending then
		return
	end
	readyMessagePending = true
	C_Timer.After(1, function()
		readyMessagePending = false
		ns.PrintMessage(string.format(L["MESSAGE_MACROS_READY"], GetColor("INFO") .. "/m|r" .. GetColor("TEXT")))
	end)
end

function ns.TryCreateMacro(macroName, icon, body)
	local numGeneral = GetNumMacros()
	local cap = MAX_ACCOUNT_MACROS or 120
	if (cap - numGeneral) <= ns.MACRO_SLOT_CUSHION then
		WarnMacroSlots()
		return false
	end

	local ok, newIndex = pcall(CreateMacro, macroName, icon, body)
	if ok and newIndex then
		AnnounceMacrosReady()
		return true
	end
	WarnMacroSlots()
	return false
end

--[[
    The one writer every macro goes through, the engine's and the custom
    definitions' alike. Creates the macro when it is missing and edits it only
    when the body differs, always with the question-mark icon. Returns true when
    the macro now holds `body`; on a failed create the caller leaves its state
    unset so the next update cycle retries -- the macro then appears
    automatically once the player frees a slot, no /reload needed.
]]
function ns.WriteMacroBody(macroName, body)
	local index = GetMacroIndexByName(macroName)
	if index == 0 then
		return ns.TryCreateMacro(macroName, ns.QUESTION_MARK_ICON, body)
	end
	if GetMacroBody(macroName) ~= body then
		EditMacro(index, macroName, ns.QUESTION_MARK_ICON, body)
	end
	return true
end

function ns.DeleteMacroByName(macroName)
	local index = GetMacroIndexByName(macroName)
	if index and index > 0 then
		DeleteMacro(index)
	end
end
