local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Player Prints
--------------------------------------------------------------------------------

--[[
    Player-only chat print: the add-on's short name, separator, then the
    message body ("C & R // ..."). BuildPrintLine returns the line without
    printing it, so the options panels' Example lines draw exactly what chat
    shows. This add-on sends no cross-player chat, so there is no
    whisper/group announce path here.
]]
function ns.BuildPrintLine(text)
	return GetColor("INFO")
		.. L["ADDON_SHORT_NAME"]
		.. "|r "
		.. GetColor("SEPARATOR")
		.. "//"
		.. "|r "
		.. GetColor("TEXT")
		.. text
		.. "|r"
end

function ns.PrintMessage(text)
	print(ns.BuildPrintLine(text))
end

--------------------------------------------------------------------------------
-- Welcome Message
--------------------------------------------------------------------------------

--[[
    PLAYER_ENTERING_WORLD fires on instance transitions and reloads, not just
    initial login, so a flag keeps the welcome to once per session. Reads
    ns.db.global.showWelcome (default on, toggled in Options).
]]
local welcomePrinted = false

function ns.PrintWelcome()
	if welcomePrinted then
		return
	end
	if not (ns.db and ns.db.global.showWelcome) then
		return
	end
	welcomePrinted = true
	ns.PrintMessage(L["CHAT_LOADED"]:format(ns.Version))
end

--------------------------------------------------------------------------------
-- End of Support
--------------------------------------------------------------------------------

--[[
    Printed once per session, straight after the welcome, with no setting of
    its own: it never reads showWelcome, so a player who turned the welcome
    off still learns that Connoisseur & Restocker now lives on inside Good to
    Go. Its own flag, because the welcome's flag stays unset while the
    welcome is off.
]]
local endOfSupportPrinted = false

function ns.PrintEndOfSupport()
	if endOfSupportPrinted then
		return
	end
	endOfSupportPrinted = true
	ns.PrintMessage(L["CHAT_END_OF_SUPPORT"])
end
