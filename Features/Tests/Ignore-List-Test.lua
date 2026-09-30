-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the Ignore List (no WoW client needed).

    Run it with:   lua Features/Tests/Ignore-List-Test.lua        (from the add-on root)

    Like the other headless tests, this does NOT model the feature. Every login
    loads the REAL LibStub, CallbackHandler-1.0, AceDB-3.0 and AceLocale-3.0
    from Includes/Libraries, the REAL Locales/enUS.lua,
    Data/Default-Settings.lua, Features/Ignore-List.lua and
    Options/Options-Ignore-List.lua, then creates the database the way
    Features/Core.lua does. Each login reloads them all, because AceDB reads
    the character's name and realm once, as it loads.

    WHAT IS PINNED HERE. Every character has a profile of its own, so a
    character's Ignore List is its profile's, and the Global list sits outside
    every profile.

    An item ignored on one character is not ignored on another. An item on the
    Global list is ignored on every character, whatever profile it is on. Two
    characters the player put on one profile share that profile's list.

    The mini-map clicks act on the character playing alone. Right-Click only
    ever adds; Middle-Click clears that one list and leaves Global and every
    other character's list as they were.

    The panel's Global button moves an item rather than copying it: onto
    Global, off every character's list. Taking an item off Global puts it back
    on nobody.

    No empty list is saved, and the logout prune drops only items this client
    does not know, from the two lists that cover the character logging out.

    The panel's tree: Global first, then the profile in use and every other
    profile with something ignored, A to Z, each under its profile's name.
    Each pane acts on its own list, and every pane but Global's carries the
    Global button. Its copy is the shipped English.

    Every change rebuilds the macros, and a mini-map click repaints the panel.
]]

local ROOT = arg[1] or "."

local failures = 0

local function check(label, got, want)
	if got == want then
		print("  ok    " .. label)
	else
		failures = failures + 1
		print(("  FAIL  %s: got %s, want %s"):format(label, tostring(got), tostring(want)))
	end
end

-- A list's item IDs, sorted, so a scenario can pin the whole list at once; "" for an empty or missing one.
local function items(ignoreList)
	local itemIDs = {}
	for itemID in pairs(ignoreList or {}) do
		itemIDs[#itemIDs + 1] = itemID
	end
	table.sort(itemIDs)
	return table.concat(itemIDs, ", ")
end

--------------------------------------------------------------------------------
-- Stubs
--------------------------------------------------------------------------------

--[[
    What the libraries and the two files call at load or at login. The
    character is swapped per login through `character`, since AceDB builds its
    keys from these once, when the library loads. A character with a surname
    is a WoW Forever one, whose client has the regional-name reader.
]]
local character

function UnitNameUnmodified()
	return character.name, character.surname
end
UnitName = UnitNameUnmodified
function GetRealmName()
	return character.realm
end
function UnitClass()
	return "Druid", "DRUID"
end
function UnitRace()
	return "Tauren", "Tauren"
end
function UnitFactionGroup()
	return "Horde"
end
function GetLocale()
	return "enUS"
end
function GetCurrentRegion()
	return 1
end
function GetCurrentRegionName()
	return "US"
end
-- A PvE realm: no ruleset flag is set.
C_GameRules = {
	IsGameRuleActive = function()
		return false
	end,
}
Enum = { GameRule = { HardcoreRuleset = 1, RPRuleset = 2, PvPRuleset = 3 } }
strmatch = string.match
function strlenutf8(text)
	return #text
end
function securecallfunction(func, ...)
	return func(...)
end
function wipe(keyed)
	for key in pairs(keyed) do
		keyed[key] = nil
	end
	return keyed
end
-- AceLocale reports a key enUS does not define through the error handler; here that fails the suite.
function geterrorhandler()
	return function(message)
		error(message, 0)
	end
end
function CreateFrame()
	local frame = { scripts = {} }
	function frame:RegisterEvent() end
	function frame:SetScript(scriptType, handler)
		self.scripts[scriptType] = handler
	end
	return frame
end

local BREAD, MILK, CHEESE, JERKY, APPLE = 4601, 1179, 414, 117, 4536
-- Items a later client build no longer has, which the logout prune drops.
local GONE, GONE_TOO, GONE_AS_WELL = 99901, 99902, 99903
local UNKNOWN_ITEMS = { [GONE] = true, [GONE_TOO] = true, [GONE_AS_WELL] = true }

C_Item = {
	DoesItemExistByID = function(itemID)
		return not UNKNOWN_ITEMS[itemID]
	end,
}

local GLOBAL = "**global**"
local PANEL = "Connoisseur_IgnoreList"
local DRUID, WARRIOR = "Gogodruid - Stitches", "Gogowarrior - Stitches"

local ns, calls

--[[
    One login as Features/Core.lua runs it: a fresh set of libraries (so AceDB
    reads this character's keys), the real files loaded into a fresh namespace,
    the saved table handed back, and AceDB:New with no profile named, so the
    character lands on its own. who gives another realm than "Stitches" or,
    for a WoW Forever character, a surname.
]]
local function login(name, saved, who)
	who = who or {}
	character = { name = name, realm = who.realm or "Stitches", surname = who.surname }
	if who.surname then
		function RegionalUniqueNamesEnabled()
			return true
		end
	else
		RegionalUniqueNamesEnabled = nil
	end
	calls = { refresh = 0, notify = {} }

	_G.LibStub = nil
	for _, path in ipairs({
		"Includes/Libraries/LibStub/LibStub.lua",
		"Includes/Libraries/CallbackHandler-1.0/CallbackHandler-1.0.lua",
		"Includes/Libraries/AceDB-3.0/AceDB-3.0.lua",
		"Includes/Libraries/AceLocale-3.0/AceLocale-3.0.lua",
		"Locales/enUS.lua",
	}) do
		assert(loadfile(ROOT .. "/" .. path))()
	end

	-- The one call the Ignore List makes on the options registry.
	local registry = LibStub:NewLibrary("AceConfigRegistry-3.0", 1)
	function registry:NotifyChange(panelName)
		calls.notify[#calls.notify + 1] = panelName
	end

	ns = {
		L = LibStub("AceLocale-3.0"):GetLocale("Connoisseur"),
		IGNORE_SCOPE_GLOBAL = GLOBAL,
		OPTIONS_REGISTRY = { IgnoreList = PANEL },
		OPTIONS_TREE_ROW_WIDTH = 2,
		OPTIONS_PROMOTE_WIDTH = 0.5,
	}
	-- The macro rebuild every change ends in: the state wipe, then the forced update.
	local stateWiped = false
	function ns.ResetMacroState()
		stateWiped = true
	end
	function ns.UpdateMacros(forced)
		if stateWiped and forced then
			calls.refresh = calls.refresh + 1
		end
		stateWiped = false
	end
	-- The panel's widgets, reduced to what it hands them; the shared list builder keeps its spec for the scenarios to drive.
	function ns.OptionsDesc(text, order)
		return { type = "description", name = text, order = order }
	end
	function ns.OptionsSpacer(order)
		return { type = "description", name = " ", order = order }
	end
	function ns.BuildItemListOptions(spec)
		return { spec = spec }
	end

	for _, path in ipairs({
		"Data/Default-Settings.lua",
		"Features/Ignore-List.lua",
		"Options/Options-Ignore-List.lua",
	}) do
		-- Add-on files are chunks taking (addonName, ns) as varargs, the way WoW loads them.
		assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
	end

	ConnoisseurDB = saved
	ns.db = LibStub("AceDB-3.0"):New("ConnoisseurDB", ns.DATABASE_DEFAULTS)
	return ConnoisseurDB
end

-- The add-on's own logout step, then AceDB's, which strips every value equal to its default, as the client's save does.
local function logout()
	ns.OnIgnoreListPlayerLogout()
	local frame = LibStub("AceDB-3.0").frame
	frame.scripts.OnEvent(frame, "PLAYER_LOGOUT")
end

-- The panel's tree as the player reads it down the left: each scope's name, in order.
local function treeNames(panel)
	local groups = {}
	for _, option in pairs(panel.args) do
		if option.type == "group" then
			groups[#groups + 1] = option
		end
	end
	table.sort(groups, function(a, b)
		return a.order < b.order
	end)
	local names = {}
	for index, group in ipairs(groups) do
		names[index] = group.name
	end
	return table.concat(names, ", ")
end

--------------------------------------------------------------------------------

print("1. An item ignored on one character is not ignored on another")
local saved = login("Gogodruid")
ns.IgnoreItem(BREAD)
check("ignored on the character that ignored it", ns.IsIgnored(BREAD), true)
check("on the Druid's own list", items(ns.GetIgnoreList()), "4601")
check("not on Global", items(ns.GetGlobalIgnoreList()), "")
logout()
saved = login("Gogowarrior", saved)
check("not ignored on the Warrior", ns.IsIgnored(BREAD), false)
check("the Warrior starts with nothing ignored", items(ns.GetIgnoreList()), "")
ns.IgnoreItem(MILK)
check("the Warrior's own item", ns.IsIgnored(MILK), true)
logout()
saved = login("Gogodruid", saved)
check("the Druid's list as it was", items(ns.GetIgnoreList()), "4601")
check("the Warrior's item not ignored on the Druid", ns.IsIgnored(MILK), false)
check("the Druid's list is saved on the Druid's profile", items(saved.profiles[DRUID].ignoreList), "4601")
check("and the Warrior's on the Warrior's", items(saved.profiles[WARRIOR].ignoreList), "1179")
check("nothing is on Global", items(saved.global and saved.global.ignoreList), "")

print("2. An item on Global is ignored on every character")
ns.SetIgnoredInScope(GLOBAL, CHEESE, true)
check("ignored on the Druid", ns.IsIgnored(CHEESE), true)
check("on no character's own list", items(ns.GetIgnoreList()), "4601")
logout()
check("saved outside every profile", items(saved.global.ignoreList), "414")
saved = login("Gogowarrior", saved)
check("ignored on the Warrior", ns.IsIgnored(CHEESE), true)

print("3. A profile the player made has a list of its own, and Global still reaches it")
ns.db:SetProfile("Raid")
check("Global covers it", ns.IsIgnored(CHEESE), true)
check("the Warrior's own list does not follow", ns.IsIgnored(MILK), false)
ns.IgnoreItem(JERKY)
check("an item ignored there is on that profile's list", items(ns.GetIgnoreList()), "117")
ns.db:SetProfile(WARRIOR)
check("and is not ignored back on the Warrior's own", ns.IsIgnored(JERKY), false)
check("whose list is as it was", items(ns.GetIgnoreList()), "1179")
check("Raid's list is saved on Raid", items(saved.profiles.Raid.ignoreList), "117")

print("4. Right-Click only ever adds; Middle-Click clears this character's list alone")
calls.refresh, calls.notify = 0, {}
ns.IgnoreItem(MILK)
check("a second Right-Click takes nothing back", items(ns.GetIgnoreList()), "1179")
check("and rebuilds nothing", calls.refresh, 0)
ns.IgnoreItem(JERKY)
check("a Right-Click adds", items(ns.GetIgnoreList()), "117, 1179")
check("rebuilds the macros", calls.refresh, 1)
check("and repaints the panel", table.concat(calls.notify, ", "), PANEL)
ns.ClearIgnoreList()
check("Middle-Click: the Warrior's list is empty", items(ns.GetIgnoreList()), "")
check("nothing of the Warrior's is ignored", ns.IsIgnored(MILK) or ns.IsIgnored(JERKY), false)
check("Global is left alone", items(ns.GetGlobalIgnoreList()), "414")
check("the Druid's list is left alone", items(ns.GetIgnoreListForScope(DRUID)), "4601")
check("the macros rebuilt again", calls.refresh, 2)
check("the panel repainted again", table.concat(calls.notify, ", "), PANEL .. ", " .. PANEL)
ns.ClearIgnoreList()
check("a Middle-Click with nothing to clear is harmless", items(ns.GetIgnoreList()), "")

print("5. The Global button moves an item: onto Global, off every character's list")
ns.SetIgnoredInScope(WARRIOR, BREAD, true)
ns.SetIgnoredInScope(WARRIOR, MILK, true)
calls.refresh = 0
ns.SetIgnoredInScope(GLOBAL, BREAD, true)
check("on Global", items(ns.GetGlobalIgnoreList()), "414, 4601")
check("off the Warrior's list", items(ns.GetIgnoreList()), "1179")
check("off the Druid's, a character that is logged out", items(ns.GetIgnoreListForScope(DRUID)), "")
check("still ignored on the Warrior", ns.IsIgnored(BREAD), true)
check("the macros rebuilt", calls.refresh, 1)
ns.SetIgnoredInScope(GLOBAL, BREAD, false)
check("taken off Global, it is ignored on nobody", ns.IsIgnored(BREAD), false)
check(
	"and goes back on no list",
	items(ns.GetIgnoreList()) .. " / " .. items(ns.GetIgnoreListForScope(DRUID)),
	"1179 / "
)

print("6. No empty list is saved, and the logout prune drops only items this client does not know")
ns.IgnoreItem(GONE)
ns.SetIgnoredInScope(DRUID, GONE_TOO, true)
ns.SetIgnoredInScope(DRUID, APPLE, true)
ns.SetIgnoredInScope(GLOBAL, GONE_AS_WELL, true)
logout()
check("the Warrior keeps the item the client knows", items(saved.profiles[WARRIOR].ignoreList), "1179")
check("Global keeps the item the client knows", items(saved.global.ignoreList), "414")
check("a logged-out character's list waits for its own logout", items(saved.profiles[DRUID].ignoreList), "4536, 99902")
saved = login("Gogodruid", saved)
logout()
check("where it is pruned in turn", items(saved.profiles[DRUID].ignoreList), "4536")
saved = login("Gogowarrior", saved)
ns.ClearIgnoreList()
ns.SetIgnoredInScope(GLOBAL, CHEESE, false)
logout()
check("with nothing ignored, the Warrior saves no list", saved.profiles[WARRIOR].ignoreList, nil)
check("nor is a Global list saved", saved.global and saved.global.ignoreList, nil)
saved = login("Gogowarrior", saved)
check("a pane for a character with no saved list reads as empty", ns.GetIgnoreListForScope(WARRIOR) ~= nil, true)
ns.SetIgnoredInScope("Nobody - Stitches", APPLE, false)
check("taking an item off a list that is not there makes no profile", saved.profiles["Nobody - Stitches"], nil)

print("7. The panel's tree: Global, then the profile in use and every profile with something ignored")
login("Gogodruid", {
	profiles = {
		[WARRIOR] = { ignoreList = { [MILK] = true } },
		["Alt - Defias Pillager"] = { ignoreList = { [JERKY] = true } },
		["Quiet - Stitches"] = { useScrolls = true },
		Raid = { ignoreList = { [APPLE] = true } },
	},
	global = { ignoreList = { [CHEESE] = true } },
})
local panel = ns.BuildIgnoreListOptions()
check("the tab's name", panel.name, "Ignore List")
check("a tree", panel.childGroups, "tree")
check(
	"the description",
	panel.args.descIntro.name,
	"Ignored items are never picked by any macro. Food, water, potions, anything. The Global list covers every character; a character's list covers only that one. Right-Click the mini-map button to ignore your current best food."
)
check(
	"the tree, a profile with nothing ignored left out",
	treeNames(panel),
	"Global, Alt - Defias Pillager, Gogodruid - Stitches, Gogowarrior - Stitches, Raid"
)
check("the character playing is listed with nothing ignored", items(ns.GetIgnoreList()), "")
check("the tree's keys are the scope keys", panel.args[GLOBAL] ~= nil and panel.args[WARRIOR] ~= nil, true)

local globalPane = panel.args[GLOBAL].args.spec
local warriorPane = panel.args[WARRIOR].args.spec
local druidPane = panel.args[DRUID].args.spec
check("Global's pane lists Global", items(globalPane.getSourceTable()), "414")
check("the Warrior's pane lists the Warrior's", items(warriorPane.getSourceTable()), "1179")
check("the Druid's pane is empty", items(druidPane.getSourceTable()), "")
check("Global's pane has no Global button", globalPane.actionColumn, nil)
check("a character's pane has one", warriorPane.actionColumn.name, "Global")
check(
	"which says what it does",
	warriorPane.actionColumn.desc,
	"Moves this item to the Global list, so it is ignored on every character."
)
check("the empty-list line", druidPane.labels.empty, "This list is empty.")
check("the panel each pane repaints", warriorPane.notifyKey, PANEL)

warriorPane.onAdd(BREAD)
check("an add on the Warrior's pane lands on the Warrior", items(ns.GetIgnoreListForScope(WARRIOR)), "1179, 4601")
check("and is not ignored on the Druid, who is playing", ns.IsIgnored(BREAD), false)
druidPane.onAdd(APPLE)
check("an add on the Druid's pane lands on the Druid", items(ns.GetIgnoreList()), "4536")
warriorPane.actionColumn.func(MILK)
check("the Global button moves the item onto Global", items(ns.GetGlobalIgnoreList()), "414, 1179")
check("and off the Warrior's list", items(ns.GetIgnoreListForScope(WARRIOR)), "4601")
warriorPane.actionColumn.func(APPLE)
check("moving an item two lists hold takes it off both", items(ns.GetIgnoreList()), "")
check("the other profile's included", items(ns.GetIgnoreListForScope("Raid")), "")
warriorPane.onRemove(BREAD)
globalPane.onRemove(CHEESE)
check("a remove on Global's pane", items(ns.GetGlobalIgnoreList()), "1179, 4536")
check(
	"a profile whose last item was removed leaves the tree, the one in use stays",
	treeNames(ns.BuildIgnoreListOptions()),
	"Global, Alt - Defias Pillager, Gogodruid - Stitches"
)

print("8. A WoW Forever character's list is on the profile named for its whole name")
saved = login("Gogodruid", nil, { surname = "Forever" })
ns.IgnoreItem(BREAD)
check("the tree shows the whole name", treeNames(ns.BuildIgnoreListOptions()), "Global, Gogodruid Forever")
logout()
check("and the list is saved there", items(saved.profiles["Gogodruid Forever"].ignoreList), "4601")

print("9. Before the database exists, nothing is ignored and nothing breaks")
ns.db = nil
check("no list", ns.GetIgnoreList(), nil)
check("no Global list", ns.GetGlobalIgnoreList(), nil)
check("nothing ignored", ns.IsIgnored(BREAD), false)
ns.IgnoreItem(BREAD)
ns.ClearIgnoreList()
ns.SetIgnoredInScope(GLOBAL, BREAD, true)
ns.OnIgnoreListPlayerLogout()
check("still nothing ignored", ns.IsIgnored(BREAD), false)
check("a panel with Global alone", treeNames(ns.BuildIgnoreListOptions()), "Global")

print("")
if failures == 0 then
	print("ALL IGNORE LIST SCENARIOS PASSED")
else
	print(failures .. " IGNORE LIST CHECK(S) FAILED")
	os.exit(1)
end
