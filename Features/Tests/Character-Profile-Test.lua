-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for character profiles (no WoW client needed).

    Run it with:   lua Features/Tests/Character-Profile-Test.lua        (from the add-on root)

    This does NOT model the login. Every login loads the REAL LibStub,
    CallbackHandler-1.0 and AceDB-3.0 from Includes/Libraries, the REAL
    Data/Default-Settings.lua and the REAL Features/Core.lua, Utilities.lua,
    Ignore-List.lua and the Restocker's Saved-Lists, Saved-Format and Events
    files, then fires PLAYER_LOGIN at Core's own dispatcher, so the database
    is created, repaired and migrated in the order Core runs it. A logout fires
    PLAYER_LOGOUT at Core and then at AceDB, which strips every value equal to
    its default, as the client's save does. Every login reloads the lot,
    because AceDB reads the character's name once, as it loads. Only the
    client is simulated, and the parts of the add-on a login reaches that
    draw or scan.

    WHAT IS PINNED HERE. The maintainer's ruling (README-Notes.md): every
    character has a profile of its own, named "Name - Realm" on Era and TBC
    and by first name and surname on WoW Forever, so two Forever characters
    sharing a first name never share one. What one character sets, another
    does not get, while what is saved on global reaches them all.

    The Restock Lists are shared by the account and each profile picks the one
    it uses. A new character starts on a list named for its class, and never
    joins one that is there already. "Used by" names every character whose
    profile uses a list. Two characters the player put on one profile share
    its list, a profile with no choice of its own (a new one, or one just
    reset) keeps the list in use, and neither Reset Profile nor a copy ever
    touches the lists themselves.

    A login where AceDB loaded before the client had named the character still
    lands on the character's own profile, or the one it chose, and the choice
    it leaves with is saved under its real name.

    The last block is the migration that carries older saved files into this
    shape, and retires with it.
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

-- A table's keys, sorted and joined, so a scenario can pin a whole set at once.
local function keysOf(keyed)
	local keys = {}
	for key in pairs(keyed or {}) do
		keys[#keys + 1] = tostring(key)
	end
	table.sort(keys)
	return table.concat(keys, ", ")
end

--------------------------------------------------------------------------------
-- The Client
--------------------------------------------------------------------------------

UNKNOWNOBJECT = "Unknown"

--[[
    The character logging in: { first, surname, realm, class }. A surname makes
    it a WoW Forever character, whose client has the regional-name readers.
    `named` is false while the libraries load in a login where the client has
    not named the character yet.
]]
local character
local named = true

function UnitNameUnmodified()
	if not named then
		return UNKNOWNOBJECT
	end
	return character.first, character.surname
end
UnitName = UnitNameUnmodified
function GetRealmName()
	return character.realm
end
function UnitClass()
	return character.class, character.class:upper()
end
function UnitRace()
	return "Human", "Human"
end
function UnitFactionGroup()
	return "Alliance"
end
function UnitLevel()
	return 60
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
function InCombatLockdown()
	return false
end
-- A PvE realm: no ruleset flag is set.
C_GameRules = {
	IsGameRuleActive = function()
		return false
	end,
}
Enum = { GameRule = { HardcoreRuleset = 1, RPRuleset = 2, PvPRuleset = 3 } }
C_Map = {
	GetBestMapForUnit = function()
		return 1
	end,
}
C_AddOns = {
	GetAddOnMetadata = function()
		return "@project-version@"
	end,
}
C_Item = {
	DoesItemExistByID = function()
		return true
	end,
}
strmatch = string.match
function strlenutf8(text)
	return #text
end
function strsplit(delimiter, text)
	local parts = {}
	for part in (text .. delimiter):gmatch("(.-)" .. delimiter) do
		parts[#parts + 1] = part
	end
	return (table.unpack or unpack)(parts)
end
function strtrim(text)
	return (text:gsub("^%s+", ""):gsub("%s+$", ""))
end
function securecallfunction(func, ...)
	return func(...)
end
function CopyTable(source)
	local copy = {}
	for key, value in pairs(source) do
		copy[key] = type(value) == "table" and CopyTable(value) or value
	end
	return copy
end
function wipe(keyed)
	for key in pairs(keyed) do
		keyed[key] = nil
	end
	return keyed
end

-- Every frame made since the libraries were last loaded, in order: AceDB's, then Core's.
local frames = {}

function CreateFrame()
	local frame = { scripts = {} }
	function frame:RegisterEvent() end
	function frame:RegisterUnitEvent() end
	function frame:UnregisterEvent() end
	function frame:Hide() end
	function frame:SetScript(scriptType, handler)
		self.scripts[scriptType] = handler
	end
	frames[#frames + 1] = frame
	return frame
end

local ns, coreFrame

--[[
    One login. opts.unnamedAtLoad is the login where the newest AceDB among the
    enabled add-ons loads before the client has named the character.
]]
local function login(who, saved, opts)
	character = who
	if who.surname then
		function RegionalUniqueNamesEnabled()
			return true
		end
		Constants = { CharacterNameSeparatorConsts = { CHARACTERNAME_SURNAME_SEPARATOR = " " } }
	else
		RegionalUniqueNamesEnabled, Constants = nil, nil
	end

	named = not (opts and opts.unnamedAtLoad)
	_G.LibStub = nil
	frames = {}
	for _, path in ipairs({
		"Includes/Libraries/LibStub/LibStub.lua",
		"Includes/Libraries/CallbackHandler-1.0/CallbackHandler-1.0.lua",
		"Includes/Libraries/AceDB-3.0/AceDB-3.0.lua",
	}) do
		assert(loadfile(ROOT .. "/" .. path))()
	end
	named = true

	-- The one call the add-on makes on the options registry here: a repaint.
	local registry = LibStub:NewLibrary("AceConfigRegistry-3.0", 1)
	function registry:NotifyChange() end

	ns = {
		-- A locale key stands for its own text; nothing here reads one.
		L = setmetatable({}, {
			__index = function(_, key)
				return key
			end,
		}),
		PALETTE = {},
		CLASS_COLORS = {},
		OPTIONS_REGISTRY = {},
		IGNORE_SCOPE_GLOBAL = "**global**",
		FLAVOR = "Vanilla",
	}
	-- What a login and a profile change reach that draws, scans or writes macros.
	for _, name in ipairs({
		"RegisterOptionsPanels",
		"EnsureItemCache",
		"InitCharacterConstants",
		"RegisterMinimapIcon",
		"ResetMacroState",
		"UpdateAuraTracking",
		"ApplyMacroNameVisibility",
		"ToggleMinimapButton",
		"UpdateMacros",
		"ClearRestockNewItems",
		"UpdateRestockList",
		"SyncRestockItemInfoSubscription",
		"InitRestockBagDefinitions",
		"SetupCraftingRecipes",
		"CreateRestockWindow",
		"SaveRestockWindowGeometry",
		"GetItemData",
	}) do
		ns[name] = function() end
	end

	local firstFrame = #frames + 1
	for _, path in ipairs({
		"Data/Default-Settings.lua",
		"Features/Core.lua",
		-- MIGRATION (remove after 2026-10-30)
		"Features/Default-Profile-Migration.lua",
		-- MIGRATION (remove after 2026-10-30)
		"Features/Character-Key-Migration.lua",
		"Features/Utilities.lua",
		"Features/Ignore-List.lua",
		"Features/Restocker/Restocker-Saved-Lists.lua",
		"Features/Restocker/Restocker-Saved-Format.lua",
		-- MIGRATION (remove after 2026-10-18)
		"Features/Restocker/Restocker-Saved-Migration.lua",
		"Features/Restocker/Restocker-Events.lua",
	}) do
		-- Add-on files are chunks taking (addonName, ns) as varargs, the way WoW loads them.
		assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
	end
	coreFrame = frames[firstFrame]

	ConnoisseurDB = saved
	coreFrame.scripts.OnEvent(coreFrame, "PLAYER_LOGIN")
	return ConnoisseurDB
end

-- The add-on's logout, then AceDB's.
local function logout()
	coreFrame.scripts.OnEvent(coreFrame, "PLAYER_LOGOUT")
	local frame = LibStub("AceDB-3.0").frame
	frame.scripts.OnEvent(frame, "PLAYER_LOGOUT")
end

-- The characters on a list, as the Restock List window names them.
local function usersOf(listName, othersOnly)
	local names = {}
	for index, user in ipairs(ns.GetRestockListUsers(listName, othersOnly)) do
		names[index] = user.name
	end
	return table.concat(names, ", ")
end

local function era(first, class, realm)
	return { first = first, class = class or "Mage", realm = realm or "Stitches" }
end

local function forever(first, surname, class)
	return { first = first, surname = surname, class = class or "Mage", realm = "Classic Beta PvE" }
end

--------------------------------------------------------------------------------

print("1. Every character gets a profile of its own, and what one sets the other does not get")
local saved = login(era("Alice", "Mage"))
check("named for the character and its realm", ns.db:GetCurrentProfile(), "Alice - Stitches")
ns.db.profile.useScrolls = true
ns.db.profile.scrollTypes.Spirit = false
ns.db.global.showWelcome = false
ns.db.global.minimap.hide = true
logout()
saved = login(era("Bob", "Warrior"), saved)
check("the second character's own", ns.db:GetCurrentProfile(), "Bob - Stitches")
check("with its own scrolls switch", ns.db.profile.useScrolls, false)
check("and its own scroll types", ns.db.profile.scrollTypes.Spirit, true)
check("the welcome message is one choice for the account", ns.db.global.showWelcome, false)
check("and so is the mini-map button", ns.db.global.minimap.hide, true)
check("the first character's settings, saved on its profile", saved.profiles["Alice - Stitches"].useScrolls, true)
check("nobody is on a shared profile", keysOf(saved.profiles), "Alice - Stitches, Bob - Stitches")
logout()
login(era("Alice", "Mage"), saved)
check("the first character's scrolls, a login later", ns.db.profile.useScrolls, true)
check("and its scroll types", ns.db.profile.scrollTypes.Spirit, false)

print("2. A WoW Forever character's profile is its first name and surname")
saved = login(forever("Gogodruid", "Forever", "Druid"))
check("the whole name, and no realm", ns.db:GetCurrentProfile(), "Gogodruid Forever")
ns.db.profile.useBuffFood = true
logout()
saved = login(forever("Gogodruid", "Classic", "Druid"), saved)
check("a character sharing its first name gets its own", ns.db:GetCurrentProfile(), "Gogodruid Classic")
check("and none of its settings", ns.db.profile.useBuffFood, false)
check("two profiles", keysOf(saved.profiles), "Gogodruid Classic, Gogodruid Forever")

print("3. The Restock Lists are shared, and each profile picks the one it uses")
saved = login(era("Alice", "Mage"))
check("a new character starts on a list named for its class", ns.restockSettings.currentList, "Mage")
check("which its profile remembers", ns.db.profile.restockList, "Mage")
check("and nothing is kept by character", rawget(ns.db.global.restocker, "listsByCharacter"), nil)
logout()
saved = login(era("Amy", "Mage"), saved)
check("a second Mage never joins the first one's list", ns.restockSettings.currentList, "Mage (2)")
check("both lists are the account's", keysOf(saved.global.restocker.lists), "Mage, Mage (2)")
check("each used by its own character", usersOf("Mage") .. " / " .. usersOf("Mage (2)"), "Alice / Amy")
ns.SwitchRestockList("Mage")
check("picking the other list puts this profile on it", ns.db.profile.restockList, "Mage")
check("and both characters use it", usersOf("Mage"), "Alice, Amy")
check("the other character, for the delete confirm", usersOf("Mage", true), "Alice")
check("the first profile's choice is its own", saved.profiles["Alice - Stitches"].restockList, "Mage")
ns.RenameCurrentRestockList("Casters")
check("a rename follows on every profile using the list", saved.profiles["Alice - Stitches"].restockList, "Casters")
check("this one included", ns.db.profile.restockList, "Casters")
logout()
saved = login(era("Alice", "Mage"), saved)
check("so the first character logs in on the renamed list", ns.restockSettings.currentList, "Casters")
check(
	"no list is made for it, and the empty one nobody uses is pruned",
	keysOf(saved.global.restocker.lists),
	"Casters"
)
logout()
saved = login(era("Zed", "Rogue", "Defias Pillager"), saved)
ns.SwitchRestockList("Casters")
check("characters on another realm are named with it", usersOf("Casters"), "Alice-Stitches, Amy-Stitches, Zed")
logout()
saved = login(era("Alice", "Mage"), saved)
check("whichever realm that is", usersOf("Casters"), "Alice, Amy, Zed-DefiasPillager")

print("4. Two characters the player put on one profile share its settings and its list")
ns.db:SetProfile("Raid")
check("a new profile keeps the list in use", ns.restockSettings.currentList, "Casters")
check("and takes it as its choice", ns.db.profile.restockList, "Casters")
ns.db.profile.useBuffFood = true
ns.restockSettings.lists["Raid Mats"] = { [8766] = "Consumable, Morning Glory Dew, 40, 0, 1, 1, 0, 1, 0" }
ns.SwitchRestockList("Raid Mats")
logout()
saved = login(era("Bob", "Warrior"), saved)
check("a character elsewhere starts on its own list", ns.restockSettings.currentList, "Warrior")
ns.db:SetProfile("Raid")
check("moving onto the shared profile brings its settings", ns.db.profile.useBuffFood, true)
check("and its list", ns.restockSettings.currentList, "Raid Mats")
check("which both characters use", usersOf("Raid Mats"), "Alice, Bob")
check("the list it left is still there", saved.global.restocker.lists.Warrior ~= nil, true)
logout()
saved = login(era("Bob", "Warrior"), saved)
check("it logs back in on the shared profile", ns.db:GetCurrentProfile(), "Raid")
check("and its list", ns.restockSettings.currentList, "Raid Mats")

print("5. Reset Profile resets the settings and never reaches the lists")
ns.db:ResetProfile()
check("the settings are back to their defaults", ns.db.profile.useBuffFood, false)
check("the character stays on the list it was using", ns.restockSettings.currentList, "Raid Mats")
check("which the profile picks again", ns.db.profile.restockList, "Raid Mats")
check("with its rows", ns.restockSettings.lists["Raid Mats"][8766] ~= nil, true)
check("and no list was made", keysOf(saved.global.restocker.lists), "Casters, Raid Mats, Warrior")

print("6. Copying a profile brings its list choice with its settings")
ns.db:SetProfile("Bob - Stitches")
check("back on its own profile and list", ns.restockSettings.currentList, "Warrior")
saved.profiles["Alice - Stitches"].useScrolls = true
ns.db:CopyProfile("Alice - Stitches")
check("the copied profile's list", ns.restockSettings.currentList, "Casters")
check("and its settings", ns.db.profile.useScrolls, true)
check("the list it copied from is untouched", saved.profiles["Alice - Stitches"].restockList, "Casters")

print("7. A profile whose list was deleted gets an empty one of the same name, as at login")
saved.profiles["Alice - Stitches"].restockList = "Gone"
ns.db:SetProfile("Alice - Stitches")
check("made again", ns.restockSettings.lists.Gone ~= nil and next(ns.restockSettings.lists.Gone) == nil, true)
check("and in use", ns.restockSettings.currentList, "Gone")

print("8. A login AceDB could not name still lands on the character's own profile")
saved = login(forever("Gogomage", "Classic"), nil, { unnamedAtLoad = true })
check("AceDB read the client's placeholder", ns.db.keys.char, "Unknown")
check("the character is on its own profile all the same", ns.db:GetCurrentProfile(), "Gogomage Classic")
ns.db.profile.useScrolls = true
check("and is named on its list", usersOf("Mage"), "Gogomage Classic")
logout()
check("its choice is saved under its real name", saved.profileKeys["Gogomage Classic"], "Gogomage Classic")
check("and the placeholder is gone", saved.profileKeys.Unknown, nil)
saved = login(forever("Gogodruid", "Forever", "Druid"), saved, { unnamedAtLoad = true })
check("the next unnamed login is another character's own", ns.db:GetCurrentProfile(), "Gogodruid Forever")
check("with none of the first one's settings", ns.db.profile.useScrolls, false)
check("and a list of its own", ns.restockSettings.currentList, "Druid")
ns.db:SetProfile("Raid")
logout()
check("a profile picked in that session is saved for the character", saved.profileKeys["Gogodruid Forever"], "Raid")
check("with no placeholder left", keysOf(saved.profileKeys), "Gogodruid Forever, Gogomage Classic")
login(forever("Gogodruid", "Forever", "Druid"), saved, { unnamedAtLoad = true })
check("and an unnamed login honors it", ns.db:GetCurrentProfile(), "Raid")
check("naming the character once on its list", usersOf(ns.restockSettings.currentList), "Gogodruid Forever")
logout()
login(forever("Gogomage", "Classic"), saved)
check("a named login is left to AceDB", ns.db:GetCurrentProfile(), "Gogomage Classic")
check("with the settings saved while unnamed", ns.db.profile.useScrolls, true)
saved = login(era("Alice", "Mage"), nil, { unnamedAtLoad = true })
check("Era and TBC: the placeholder carries the realm", ns.db.keys.char, "Unknown - Stitches")
check("and the character still gets its own profile", ns.db:GetCurrentProfile(), "Alice - Stitches")
logout()
check("saved under its real name", keysOf(saved.profileKeys), "Alice - Stitches")

--------------------------------------------------------------------------------
-- MIGRATION (remove after 2026-10-30)
--------------------------------------------------------------------------------

--[[
    Features/Default-Profile-Migration.lua, run in Core's order behind the
    saved-key rename and Features/Character-Key-Migration.lua. This block, the
    lines above it that carry the tag, and the two helpers below retire with
    it.
]]

-- An Ignore List's item IDs, sorted; "" for an empty or missing one.
local function items(ignoreList)
	local itemIDs = {}
	for itemID in pairs(ignoreList or {}) do
		itemIDs[#itemIDs + 1] = itemID
	end
	table.sort(itemIDs)
	return table.concat(itemIDs, ", ")
end

-- The list each profile uses, as "profile=list" pairs, sorted.
local function choices(savedFile)
	local pairsOut = {}
	for profileName, profile in pairs(savedFile.profiles or {}) do
		if profile.restockList then
			pairsOut[#pairsOut + 1] = profileName .. "=" .. profile.restockList
		end
	end
	table.sort(pairsOut)
	return table.concat(pairsOut, ", ")
end

print("M1. Characters on the shared Default profile each get their own, starting as a copy of it")
saved = login(era("Alice", "Mage"), {
	profileKeys = {
		["Alice - Stitches"] = "Default",
		["Bob - Stitches"] = "Default",
		["Carol - Stitches"] = "Carol - Stitches",
	},
	profiles = {
		Default = {
			useScrolls = true,
			scrollTypes = { Spirit = false },
			ignoreList = { [4601] = true },
			itemCache = { [4601] = {} },
			itemCacheVersion = "2026.09.24.A",
		},
		["Carol - Stitches"] = { useBuffFood = true },
	},
	global = {
		showWelcome = false,
		ignoreList = { [117] = true },
		restocker = {
			lists = {
				Mage = { [8766] = "Consumable, Morning Glory Dew, 40, 0, 1, 1, 0, 1, 0" },
				Warrior = {},
				Priest = {},
			},
			listsByCharacter = {
				["Alice-Stitches"] = "Mage",
				["Bob-Stitches"] = "Warrior",
				["Carol-Stitches"] = "Priest",
			},
		},
	},
})
check("the character playing is on its own profile", ns.db:GetCurrentProfile(), "Alice - Stitches")
check("with Default's scrolls switch", ns.db.profile.useScrolls, true)
check("and its scroll types", ns.db.profile.scrollTypes.Spirit, false)
check("and the items Default ignored", items(ns.db.profile.ignoreList), "4601")
check("the item cache is left behind", rawget(ns.db.profile, "itemCacheVersion"), nil)
check("the logged-out character moved too", saved.profileKeys["Bob - Stitches"], "Bob - Stitches")
check("with the same copy", saved.profiles["Bob - Stitches"].useScrolls, true)
check("which is its own table", saved.profiles["Bob - Stitches"].scrollTypes ~= ns.db.profile.scrollTypes, true)
check("its ignored items too", items(saved.profiles["Bob - Stitches"].ignoreList), "4601")
check("a character already on its own profile is untouched", saved.profiles["Carol - Stitches"].useScrolls, nil)
check("Default is gone", keysOf(saved.profiles), "Alice - Stitches, Bob - Stitches, Carol - Stitches")
check("the Global Ignore List is left as it was", items(ns.db.global.ignoreList), "117")
check("account-wide settings are untouched", ns.db.global.showWelcome, false)
check(
	"every list choice is on its character's profile",
	choices(saved),
	"Alice - Stitches=Mage, Bob - Stitches=Warrior, Carol - Stitches=Priest"
)
check("the by-character table is retired", rawget(ns.db.global.restocker, "listsByCharacter"), nil)
check("this character is on the list it was using", ns.restockSettings.currentList, "Mage")
check("with its rows", next(ns.restockSettings.lists.Mage) ~= nil, true)
check("and no list was made", keysOf(saved.global.restocker.lists), "Mage, Priest, Warrior")
check("each list names its character", usersOf("Warrior") .. " / " .. usersOf("Priest"), "Bob / Carol")
ns.db.profile.useScrolls = false
logout()
saved = login(era("Bob", "Warrior"), saved)
check("the second character logs in on its own profile", ns.db:GetCurrentProfile(), "Bob - Stitches")
check("still with the scrolls the first one since turned off", ns.db.profile.useScrolls, true)
check("and on its own list", ns.restockSettings.currentList, "Warrior")
check("with no list made", keysOf(saved.global.restocker.lists), "Mage, Priest, Warrior")
check("a second login changes nothing", keysOf(saved.profiles), "Alice - Stitches, Bob - Stitches, Carol - Stitches")

print("M2. A profile the player named is left alone, and its characters share its list")
saved = login(era("Dave", "Druid"), {
	profileKeys = { ["Dave - Stitches"] = "Raid", ["Erin - Stitches"] = "Raid" },
	profiles = { Raid = { useBuffFood = true, ignoreList = { [5] = true } } },
	global = {
		restocker = {
			lists = { Druid = {}, Shaman = {} },
			listsByCharacter = { ["Dave-Stitches"] = "Druid", ["Erin-Stitches"] = "Shaman" },
		},
	},
})
check("still on it", ns.db:GetCurrentProfile(), "Raid")
check("with its settings", ns.db.profile.useBuffFood, true)
check("and its Ignore List", items(ns.db.profile.ignoreList), "5")
check("the profile takes the list of the character playing", ns.db.profile.restockList, "Druid")
check("which the other character shares from here on", usersOf("Druid"), "Dave, Erin")
check("both entries are spent", rawget(ns.db.global.restocker, "listsByCharacter"), nil)
check("no profile was made", keysOf(saved.profiles), "Raid")

print("M3. A Default nobody is on goes when it holds only the cache, and stays when it holds settings")
saved = login(era("Fay", "Priest"), {
	profileKeys = { ["Fay - Stitches"] = "Fay - Stitches" },
	profiles = { Default = { itemCache = {}, itemCacheVersion = "Dev" }, ["Fay - Stitches"] = { useScrolls = true } },
})
check("the empty one is gone", keysOf(saved.profiles), "Fay - Stitches")
saved = login(era("Fay", "Priest"), {
	profileKeys = { ["Fay - Stitches"] = "Fay - Stitches" },
	profiles = { Default = { useBuffFood = true }, ["Fay - Stitches"] = { useScrolls = true } },
})
check("one the player left settings on is theirs to keep", keysOf(saved.profiles), "Default, Fay - Stitches")
check("and nobody is put on it", ns.db:GetCurrentProfile(), "Fay - Stitches")

print("M4. A profile already saved under the character's name keeps what it holds")
saved = login(era("Gus", "Hunter"), {
	profileKeys = { ["Gus - Stitches"] = "Default" },
	profiles = { Default = { useScrolls = true }, ["Gus - Stitches"] = { useBuffFood = true } },
})
check("on its own profile", ns.db:GetCurrentProfile(), "Gus - Stitches")
check("with what that profile held", ns.db.profile.useBuffFood, true)
check("and nothing copied over it", ns.db.profile.useScrolls, false)
check("Default is gone", keysOf(saved.profiles), "Gus - Stitches")

print("M5. A realm with a space in its name, and a character on another realm")
saved = login(era("Lee", "Paladin"), {
	profileKeys = { ["Kim - Defias Pillager"] = "Default", ["Lee - Stitches"] = "Default" },
	profiles = { Default = { useScrolls = true } },
	global = {
		restocker = {
			lists = { Rogue = {}, Paladin = {} },
			listsByCharacter = { ["Kim-DefiasPillager"] = "Rogue", ["Lee-Stitches"] = "Paladin" },
		},
	},
})
check("profiles", keysOf(saved.profiles), "Kim - Defias Pillager, Lee - Stitches")
check("list choices", choices(saved), "Kim - Defias Pillager=Rogue, Lee - Stitches=Paladin")
check("the by-character table is retired", rawget(ns.db.global.restocker, "listsByCharacter"), nil)

print("M6. WoW Forever: whole names, the placeholder AceDB left, and a profile the player named")
saved = login(forever("Gogodruid", "Forever", "Druid"), {
	profileKeys = {
		["Gogodruid Forever"] = "Default",
		["Gogohunter Classic"] = "Default",
		["Gogowarrior Classic"] = "Default",
		["Unknown"] = "Default",
	},
	profiles = {
		Default = { useBuffFood = true, useScrolls = true, scrollTypes = { Agility = false } },
		ROGUE = { itemCacheVersion = "2026.09.24.A" },
	},
	global = {
		restocker = {
			lists = { Druid = {}, Hunter = {}, Warrior = {} },
			listsByCharacter = {
				["Gogodruid Forever-ClassicBetaPvE"] = "Druid",
				["Gogohunter Classic-ClassicBetaPvE"] = "Hunter",
				["Gogowarrior Classic-ClassicBetaPvE"] = "Warrior",
			},
		},
	},
})
check("the character playing", ns.db:GetCurrentProfile(), "Gogodruid Forever")
check("with Default's settings", ns.db.profile.useScrolls and ns.db.profile.scrollTypes.Agility == false, true)
check(
	"a profile per character, and the player's own left alone",
	keysOf(saved.profiles),
	"Gogodruid Forever, Gogohunter Classic, Gogowarrior Classic, ROGUE"
)
check(
	"the placeholder names nobody and gets no profile",
	keysOf(saved.profileKeys),
	"Gogodruid Forever, Gogohunter Classic, Gogowarrior Classic"
)
check(
	"list choices, found by whole name",
	choices(saved),
	"Gogodruid Forever=Druid, Gogohunter Classic=Hunter, Gogowarrior Classic=Warrior"
)
check("the by-character table is retired", rawget(ns.db.global.restocker, "listsByCharacter"), nil)
check("on its list", ns.restockSettings.currentList, "Druid")

print("M7. WoW Forever, as the last release left it: first-name keys, and an older AceDB's names")
saved = login(forever("Gogodruid", "Forever", "Druid"), {
	profileKeys = { ["Gogodruid - PvE"] = "Gogodruid - PvE", ["Gogohunter - PvE"] = "Gogohunter - PvE" },
	profiles = {
		["Gogodruid - PvE"] = { useScrolls = true, ignoreList = { [4601] = true } },
		["Gogohunter - PvE"] = { useBuffFood = true },
	},
	global = {
		restocker = {
			lists = { Druid = {}, Hunter = { [8766] = "Consumable, Morning Glory Dew, 40, 0, 1, 1, 0, 1, 0" } },
			listsByCharacter = { ["Gogodruid-ClassicBetaPvE"] = "Druid", ["Gogohunter-ClassicBetaPvE"] = "Hunter" },
		},
	},
})
check("this character's settings come onto its own profile", ns.db.profile.useScrolls, true)
check("and its Ignore List", items(ns.db.profile.ignoreList), "4601")
check("this character's choice follows it onto its profile", ns.db.profile.restockList, "Druid")
check("so it is on its list, with none made", keysOf(saved.global.restocker.lists), "Druid, Hunter")
check(
	"the older names stay, for every character that shared one",
	keysOf(saved.profileKeys),
	"Gogodruid - PvE, Gogodruid Forever, Gogohunter - PvE"
)
check("a profile is never deleted for it", saved.profiles["Gogohunter - PvE"].useBuffFood, true)
check(
	"the other character's choice waits for its own login",
	keysOf(ns.db.global.restocker.listsByCharacter),
	"Gogohunter-ClassicBetaPvE"
)
ns.db.profile.useScrolls = false
logout()
login(forever("Gogohunter", "Classic", "Hunter"), saved)
check("which claims it", ns.db.profile.restockList, "Hunter")
check("and finds its rows", next(ns.restockSettings.lists.Hunter) ~= nil, true)
check("and retires the table", rawget(ns.db.global.restocker, "listsByCharacter"), nil)
check("and carries its settings", ns.db.profile.useBuffFood, true)
logout()
login(forever("Gogodruid", "Forever", "Druid"), saved)
check("a second login copies nothing over what the character changed since", ns.db.profile.useScrolls, false)

print("M8. A choice whose character AceDB has no record of waits, and a second login changes nothing")
saved = login(era("Mia", "Mage"), {
	profileKeys = { ["Mia - Stitches"] = "Mia - Stitches" },
	global = {
		restocker = {
			lists = { Mage = {}, Bank = {} },
			listsByCharacter = { ["Mia-Stitches"] = "Mage", ["Ned-Stitches"] = "Bank" },
		},
	},
})
check("this character's moved", ns.db.profile.restockList, "Mage")
check("the other's is kept", keysOf(ns.db.global.restocker.listsByCharacter), "Ned-Stitches")
logout()
saved = login(era("Mia", "Mage"), saved)
check("still kept a login later", keysOf(ns.db.global.restocker.listsByCharacter), "Ned-Stitches")
check("and this character is where it was", ns.restockSettings.currentList, "Mage")
logout()
login(era("Ned", "Priest"), saved)
check("until its character logs in", ns.restockSettings.currentList, "Bank")
check("and the table goes with its last entry", rawget(ns.db.global.restocker, "listsByCharacter"), nil)

print("M9. The saved-key rename runs first, so a file two releases old is carried in one login")
saved = login(era("Olga", "Shaman"), {
	profileKeys = { ["Olga - Stitches"] = "Default" },
	profiles = { Default = { useScrolls = true } },
	global = { restocker = { profiles = { Totems = {} }, profileKeys = { ["Olga-Stitches"] = "Totems" } } },
})
check("on its own profile", ns.db:GetCurrentProfile(), "Olga - Stitches")
check("on the list it was using", ns.restockSettings.currentList, "Totems")
check("with none made", keysOf(saved.global.restocker.lists), "Totems")

print("M10. A brand-new install has nothing to carry")
saved = login(era("Sam", "Warlock"))
check("its own profile", ns.db:GetCurrentProfile(), "Sam - Stitches")
check("one profile", keysOf(saved.profiles), "Sam - Stitches")
check("a class-named list", ns.restockSettings.currentList, "Warlock")

print("")
if failures == 0 then
	print("ALL CHARACTER PROFILE SCENARIOS PASSED")
else
	print(failures .. " CHARACTER PROFILE CHECK(S) FAILED")
	os.exit(1)
end
