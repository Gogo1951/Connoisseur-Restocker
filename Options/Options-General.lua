local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- General Panel
--------------------------------------------------------------------------------

--[[
    The root page holds add-on-level behavior only -- nothing here shapes what
    a macro holds. In order: intro, Welcome Message, Mini-map Button, Features
    (each feature's master switch, also on its own panel) and /Commands.

    Everything that shapes a macro lives on the Macros panel
    (Options-Macros.lua), Restocker on its own (Options-Restocker.lua), and the
    Readiness Report on its own (Options-Readiness-Report.lua), beside the
    Ignore List, Profiles, Feedback & Support and Diagnostic Tools.

    Every toggle on this page is account-wide (ns.db.global) -- see
    Data/Default-Settings.lua for why each one stays there.

    Order values are grouped in spaced blocks so sections can be reordered or
    extended without renumbering their neighbors.
]]

function ns.BuildGeneralOptions()
	return {
		name = L["ADDON_TITLE"],
		type = "group",
		args = {
			descIntro = Desc(L["OPTIONS_DESCRIPTION"], 1),

			-- Welcome Message
			spaceWelcome0 = Spacer(10),
			toggleWelcomeMessage = {
				type = "toggle",
				name = L["OPTIONS_WELCOME_MESSAGE"],
				desc = L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"],
				order = 11,
				width = "full",
				get = function()
					return ns.db and ns.db.global.showWelcome
				end,
				set = function(_, value)
					if ns.db then
						ns.db.global.showWelcome = value
					end
				end,
			},

			-- Minimap Button
			toggleMinimapButton = {
				type = "toggle",
				name = L["OPTIONS_MINIMAP_BUTTON"],
				desc = L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"],
				order = 13,
				width = "full",
				get = function()
					return not (ns.db and ns.db.global.minimap and ns.db.global.minimap.hide)
				end,
				set = function(_, value)
					ns.ToggleMinimapButton(value)
				end,
			},

			-- Features: every feature's master switch, two to a line.
			spaceFeatures0 = Spacer(14),
			headerFeatures = Header(L["OPTIONS_FEATURES_HEADER"], 15),
			spaceFeatures1 = Spacer(16),
			toggleMacros = ns.OptionsFeatureSwitch("Macros", 17, ns.OPTIONS_ROW_WIDTH / 2),
			toggleRestocker = ns.OptionsFeatureSwitch("Restocker", 17.1, ns.OPTIONS_ROW_WIDTH / 2),
			toggleReadinessReport = ns.OptionsFeatureSwitch("ReadinessReport", 17.2, ns.OPTIONS_ROW_WIDTH / 2),
			toggleInventoryReport = ns.OptionsFeatureSwitch("InventoryReport", 17.3, ns.OPTIONS_ROW_WIDTH / 2),

			-- /Commands
			spaceCommands0 = Spacer(20),
			headerCommands = Header(L["OPTIONS_COMMANDS_HEADER"], 21),
			spaceCommands1 = Spacer(22),
			descCommands = Desc(
				GetColor("INFO") .. L["OPTIONS_COMMAND"] .. "|r" .. "  " .. L["OPTIONS_COMMAND_DESCRIPTION"],
				23
			),
			spaceCommands2 = Spacer(24),
			descCommandsRestocker = Desc(
				GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. "  " .. L["RESTOCKER_COMMAND_DESCRIPTION"],
				25
			),
		},
	}
end
