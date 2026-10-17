local _, ns = ...
local L = ns.L

local AceConfig = LibStub("AceConfig-3.0")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

local REGISTRY = ns.OPTIONS_REGISTRY

--[[
    Registration is deferred to ns.RegisterOptionsPanels, called once from
    Features/Core.lua after AceDB creates ns.db. It has to wait for ns.db
    because the Profiles panel's tree label is read from the stock
    AceDBOptions-3.0 table (ns.BuildProfilesOptions().name), which needs the
    database to exist. Child-panel order in Blizzard's settings tree is the
    order of the AddToBlizOptions calls: General (root) -> Macros (-> Class &
    Race -> Ignore List) -> Restocker -> Readiness Report -> Profiles -> Feedback & Support ->
    Diagnostic Tools. The
    third AddToBlizOptions argument is the parent: the root's display name
    (L["ADDON_TITLE"]) by default, or a child's category ID to nest a panel a
    level deeper. AceConfigDialog maps only root names to IDs, so a nested
    panel passes the ID its parent's registration returned; Settings.GetCategory
    searches subcategories, and the tree draws each level indented.
]]
local function RegisterChild(appName, builder, displayName, parentID)
	AceConfig:RegisterOptionsTable(appName, builder)
	local _, categoryID = AceConfigDialog:AddToBlizOptions(appName, displayName, parentID or L["ADDON_TITLE"])
	return categoryID
end

function ns.RegisterOptionsPanels()
	AceConfig:RegisterOptionsTable(REGISTRY.General, ns.BuildGeneralOptions)
	local mainPanel, mainCategoryID = AceConfigDialog:AddToBlizOptions(REGISTRY.General, L["ADDON_TITLE"])
	ns.optionsFrames = { main = mainPanel, categoryID = mainCategoryID }

	--[[
	    Macros panel (Options-Macros.lua) -- every macro setting, led by the
	    Macros master switch. Its tree label is TAB_MACROS rather than the
	    "Enable Macros" section's header.
	]]
	local macrosCategoryID = RegisterChild(REGISTRY.Macros, ns.BuildMacrosOptions, L["TAB_MACROS"])

	--[[
	    Class & Race panel (Options-Class-Race.lua), nested under Macros above
	    the Ignore List: the options that shape the macros for one class or
	    race.
	]]
	RegisterChild(REGISTRY.ClassRace, ns.BuildClassRaceOptions, L["TAB_CLASS_RACE"], macrosCategoryID)

	--[[
	    Ignore List panel (Options-Ignore-List.lua), nested under Macros: the
	    list only says what the macros may offer. The builder function, not a
	    built table: its rows are the ignore lists themselves, so AceConfig
	    re-invokes it on every open and every NotifyChange and the panel never
	    renders a stale list.
	]]
	RegisterChild(REGISTRY.IgnoreList, ns.BuildIgnoreListOptions, L["TAB_IGNORE_LIST"], macrosCategoryID)

	--[[
	    Widen the Ignore List tree. AceGUI defaults it to 175px, which truncates
	    a long character name, and its SetStatusTable fills
	    treewidth in only when the key is absent -- so seeding it here wins,
	    while a player dragging the splitter still overwrites it from then on.
	]]
	local ignoreStatus = AceConfigDialog:GetStatusTable(REGISTRY.IgnoreList)
	ignoreStatus.groups = ignoreStatus.groups or {}
	ignoreStatus.groups.treewidth = ns.OPTIONS_TREE_WIDTH

	--[[
	    Restocker panel (Options-Restocker.lua). The tree label routes through
	    the locale table like every player-facing string, but stays "Restocker"
	    in every locale (brand fragment, localization allowlist).
	]]
	RegisterChild(REGISTRY.Restocker, ns.BuildRestockerOptions, L["TAB_RESTOCKER"])

	--[[
	    Starter List pop-up (Options-Starter-List-Popup.lua): registered only,
	    never added to the Blizzard tree -- it opens as its own AceConfigDialog
	    window over an empty Restock List (Features/Restocker/Restocker-Starter-List.lua).
	]]
	AceConfig:RegisterOptionsTable(REGISTRY.StarterListPopup, ns.BuildStarterListPopupOptions)

	--[[
	    Readiness Report panel (Options-Readiness-Report.lua) -- what Connoisseur
	    says when a ready check starts.
	]]
	RegisterChild(REGISTRY.ReadinessReport, ns.BuildReadinessReportOptions, L["TAB_READINESS_REPORT"])

	--[[
	    Profiles panel: the stock AceDBOptions-3.0 table, unmodified
	    (Options-Profiles.lua). Its display name comes already-localized from
	    AceDBOptions, read off the built table so we neither hardcode it nor add
	    a locale key for a stock widget.
	]]
	RegisterChild(REGISTRY.Profiles, ns.BuildProfilesOptions, ns.BuildProfilesOptions().name)

	-- Feedback & Support panel (Options-Feedback-Support.lua): the tree lists it as OPTIONS_FEEDBACK.
	RegisterChild(REGISTRY.FeedbackSupport, ns.BuildFeedbackSupportOptions, L["OPTIONS_FEEDBACK"])

	--[[
	    Diagnostic Tools last so it sits at the bottom of the tree. Its display
	    name is a plain English string (ns.DiagnosticsStrings.TAB), not a locale
	    key -- diagnostics text is never localized.
	]]
	RegisterChild(REGISTRY.Diagnostics, ns.BuildDiagnosticsOptions, ns.DiagnosticsStrings.TAB)
end

--------------------------------------------------------------------------------
-- Panel Navigation
--------------------------------------------------------------------------------

function ns.OpenOptionsPanel()
	--[[
	    Combat first: Blizzard's Settings panel is protected in combat, so every
	    route below is blocked and the player would get an
	    ADDON_ACTION_BLOCKED error naming the add-on instead of an answer. The
	    gate sits at this single entry point, so the slash command and the
	    mini-map button's Shift + Middle-Click answer identically. It returns --
	    never queues the open for when combat ends.
	]]
	if InCombatLockdown() then
		ns.PrintMessage(L["CHAT_OPTIONS_IN_COMBAT"])
		return
	end

	if not ns.optionsFrames then
		return
	end
	if Settings and Settings.OpenToCategory and ns.optionsFrames.categoryID then
		Settings.OpenToCategory(ns.optionsFrames.categoryID)
		return
	end
	AceConfigDialog:Open(REGISTRY.General)
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

SLASH_CONNOISSEUR1 = "/foodie"
SlashCmdList["CONNOISSEUR"] = function()
	ns.OpenOptionsPanel()
end

--[[
    The Restock List's own command, registered here with the options command
    rather than inside the feature: slash registration is this file's job, and
    the handler stays with the feature that answers it.
]]
SLASH_CONNOISSEURRESTOCKER1 = "/crs"
SlashCmdList["CONNOISSEURRESTOCKER"] = function(message)
	ns.HandleRestockerCommand(message)
end
