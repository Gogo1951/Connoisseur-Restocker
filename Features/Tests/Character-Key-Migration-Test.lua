-- luacheck: allow defined, ignore 121 122 131 143
-- MIGRATION (remove after 2026-10-30)
--[[
    Headless test for keying WoW Forever characters by their whole names
    (no WoW client needed).

    Run it with:   lua Features/Tests/Character-Key-Migration-Test.lua        (from the add-on root)

    This does NOT model the key or the migration. Every login loads the REAL
    Features/Utilities.lua (ns.GetPlayerFullName), the REAL
    Features/Restocker/Restocker-Saved-Lists.lua (ns.GetCharacterKey) and the
    REAL Features/Character-Key-Migration.lua, and runs
    ns.RekeyCharactersByFullName as Core does. Only the client is simulated --
    the name readers, which differ by client -- and the saved tables are handed
    over the way AceDB holds them. The step Core runs next,
    ns.MoveCharactersOntoOwnProfiles, takes each list choice from the entry
    re-keyed here onto the character's profile; Character-Profile-Test.lua
    pins the two in one login.

    WHAT IS PINNED HERE. Releases through 2026.09.24.A keyed a Forever
    character by its first name and realm. After one login of the new build
    that character is keyed by first name and surname, in all three tables
    keyed by character (the list it uses, its staples answer, its Inventory
    Report record), so the list it was using is found under its name. Every
    other character AceDB has written a whole name for
    moves in the same login, realm kept and its record named in full, and a
    key an earlier beta build left
    under the whole name gives way to the first-name key that replaced it. A
    first name two characters share waits for each one's own login, and so does
    every other character when AceDB cannot vouch for this one's name. An Era
    or TBC character's key does not change. A second login changes nothing.

    This file retires with the migration (remove after 2026-10-30).
]]

local ROOT = arg[1] or "."

local failures = 0

local function check(label, got, want)
	if got == want then
		print(("  ok    %s = %s"):format(label, tostring(got)))
	else
		failures = failures + 1
		print(("  FAIL  %s: got %s, want %s"):format(label, tostring(got), tostring(want)))
	end
end

---A table as one comparable string, keys sorted, so two saved shapes can be checked for equality.
local function dump(value)
	if type(value) ~= "table" then
		return type(value) == "string" and ("%q"):format(value) or tostring(value)
	end
	local keys = {}
	for key in pairs(value) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	local parts = {}
	for _, key in ipairs(keys) do
		parts[#parts + 1] = "[" .. dump(key) .. "]=" .. dump(value[key])
	end
	return "{" .. table.concat(parts, ",") .. "}"
end

local function count(keyed)
	local total = 0
	for _ in pairs(keyed) do
		total = total + 1
	end
	return total
end

--------------------------------------------------------------------------------
-- The Client
--------------------------------------------------------------------------------

local REALM = "Classic Beta PvE"

--[[
    One login. `character` is { first, surname, class, realm, era, wholeNameFirst }:

      surname          a Forever character's, which the client gives apart
                       from the first name; nil for a character without one
      era              an Era or TBC client, which has neither of the two
                       readers Forever's surnames come through
      wholeNameFirst   the early beta build, whose first value was the whole
                       name

    `saved` is the AceDB object as the add-on sees it: sv.profileKeys, and
    global with the Restocker's tables and the Inventory Report's. The files
    are loaded again for every login, because Utilities picks its name reader
    as it loads.
]]
local function login(character, saved)
	local first = character.first
	local whole = character.surname and (first .. " " .. character.surname) or first

	function UnitName()
		return character.wholeNameFirst and whole or first, character.surname
	end
	function GetRealmName()
		return character.realm or REALM
	end
	function UnitClass()
		local class = character.class or "Druid"
		return class, class:upper()
	end
	if character.era then
		RegionalUniqueNamesEnabled, UnitNameUnmodified, Constants = nil, nil, nil
	else
		function RegionalUniqueNamesEnabled()
			return true
		end
		UnitNameUnmodified = UnitName
		Constants = { CharacterNameSeparatorConsts = { CHARACTERNAME_SURNAME_SEPARATOR = " " } }
	end

	local ns = { L = {}, PALETTE = {}, CLASS_COLORS = {}, db = saved }
	for _, path in ipairs({
		"Features/Utilities.lua",
		"Features/Restocker/Restocker-Saved-Lists.lua",
		"Features/Character-Key-Migration.lua",
	}) do
		-- Add-on files are chunks taking (addonName, ns) as varargs, the way WoW loads them.
		assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
	end
	ns.RekeyCharactersByFullName()
	return ns
end

local DRUID = { first = "Gogodruid", surname = "Forever", class = "Druid" }
local HUNTER = { first = "Gogohunter", surname = "Classic", class = "Hunter" }
local WARRIOR = { first = "Gogowarrior", surname = "Classic", class = "Warrior" }

---The names AceDB 3.0 minor 39 keys Forever characters by, with the entry it leaves when a name was not ready.
local function wholeNames()
	return {
		["Gogodruid Forever"] = "Default",
		["Gogohunter Classic"] = "Default",
		["Gogomage Classic"] = "Default",
		["Gogorogue Classic"] = "Default",
		["Gogowarrior Classic"] = "Default",
		["Unknown"] = "Default",
	}
end

--[[
    A beta tester's file, as the release left it: every character under its
    first name, and the warrior under its whole name as well, from the early
    build. That stale entry points at a list of its own here, so which of the
    two keys wins can be told apart.
]]
local function betaFile(profileKeys)
	return {
		sv = { profileKeys = profileKeys or wholeNames() },
		global = {
			restocker = {
				lists = {
					Druid = { [8766] = "Consumable, Morning Glory Dew, 40, 0, 1, 1, 0, 1, 0" },
					Hunter = {},
					Mage = {},
					Rogue = {},
					Warrior = {},
					["Warrior (old)"] = {},
				},
				listsByCharacter = {
					["Gogodruid-ClassicBetaPvE"] = "Druid",
					["Gogohunter-ClassicBetaPvE"] = "Hunter",
					["Gogomage-ClassicBetaPvE"] = "Mage",
					["Gogorogue-ClassicBetaPvE"] = "Rogue",
					["Gogowarrior-ClassicBetaPvE"] = "Warrior",
					["Gogowarrior Classic-ClassicBetaPvE"] = "Warrior (old)",
				},
				starterListDismissed = {
					["Gogodruid-ClassicBetaPvE"] = true,
					["Gogomage-ClassicBetaPvE"] = true,
				},
			},
			inventory = {
				["Gogodruid-ClassicBetaPvE"] = { name = "Gogodruid", realm = REALM, class = "DRUID", bags = "8766:20" },
				["Gogomage-ClassicBetaPvE"] = { name = "Gogomage", realm = REALM, class = "MAGE", bags = "" },
			},
		},
	}
end

--------------------------------------------------------------------------------

print("1. One Forever login re-keys this character and every other one AceDB has a whole name for")
local saved = betaFile()
local druidRecord = saved.global.inventory["Gogodruid-ClassicBetaPvE"]
local ns = login(DRUID, saved)
local restocker = saved.global.restocker
check("this character's key", ns.GetCharacterKey(), "Gogodruid Forever-ClassicBetaPvE")
check(
	"every character under its whole name, once",
	dump(restocker.listsByCharacter),
	dump({
		["Gogodruid Forever-ClassicBetaPvE"] = "Druid",
		["Gogohunter Classic-ClassicBetaPvE"] = "Hunter",
		["Gogomage Classic-ClassicBetaPvE"] = "Mage",
		["Gogorogue Classic-ClassicBetaPvE"] = "Rogue",
		["Gogowarrior Classic-ClassicBetaPvE"] = "Warrior",
	})
)
check(
	"the staples answers follow",
	dump(restocker.starterListDismissed),
	dump({ ["Gogodruid Forever-ClassicBetaPvE"] = true, ["Gogomage Classic-ClassicBetaPvE"] = true })
)
check("the Inventory Report record follows", saved.global.inventory["Gogodruid Forever-ClassicBetaPvE"], druidRecord)
check(
	"a logged-out character's record is named in full too",
	(saved.global.inventory["Gogomage Classic-ClassicBetaPvE"] or {}).name,
	"Gogomage Classic"
)
check("and nothing is left behind", count(saved.global.inventory), 2)
check("the list it was using is under its key", restocker.listsByCharacter[ns.GetCharacterKey()], "Druid")

print("2. A second login changes nothing")
local before = dump(saved.global)
login(DRUID, saved)
check("same saved shape", dump(saved.global), before)

print("3. A character re-keyed while logged out comes back to its own list")
ns = login(WARRIOR, saved)
check("the first-name key's list, not the early build's", restocker.listsByCharacter[ns.GetCharacterKey()], "Warrior")
check("still one entry for it", count(restocker.listsByCharacter), 5)

print("4. An older AceDB knows no surnames, so only this character moves")
saved = betaFile({ ["Gogodruid - PvE"] = "Default", ["Gogohunter - PvE"] = "Default" })
restocker = saved.global.restocker
login(DRUID, saved)
check("this character moved", restocker.listsByCharacter["Gogodruid Forever-ClassicBetaPvE"], "Druid")
check("its old key is gone", restocker.listsByCharacter["Gogodruid-ClassicBetaPvE"], nil)
check("the hunter waits", restocker.listsByCharacter["Gogohunter-ClassicBetaPvE"], "Hunter")
check("under no made-up name", restocker.listsByCharacter["Gogohunter - PvE-ClassicBetaPvE"], nil)
login(HUNTER, saved)
check("and moves at its own login", restocker.listsByCharacter["Gogohunter Classic-ClassicBetaPvE"], "Hunter")
check("the early build's key for the warrior is still there", count(restocker.listsByCharacter), 6)

print("5. AceDB's names are believed only while this character's own is among them")
local unvouched = wholeNames()
unvouched["Gogodruid Forever"] = nil
saved = betaFile(unvouched)
restocker = saved.global.restocker
login(DRUID, saved)
check(
	"this character moved by what the client says",
	restocker.listsByCharacter["Gogodruid Forever-ClassicBetaPvE"],
	"Druid"
)
check("nobody else did", restocker.listsByCharacter["Gogohunter-ClassicBetaPvE"], "Hunter")

print("6. A first name two characters share waits for each one's own login")
local shared = wholeNames()
shared["Gogohunter Forever"] = "Default"
saved = betaFile(shared)
restocker = saved.global.restocker
login(DRUID, saved)
check("the shared first name is left alone", restocker.listsByCharacter["Gogohunter-ClassicBetaPvE"], "Hunter")
check("the others still move", restocker.listsByCharacter["Gogomage Classic-ClassicBetaPvE"], "Mage")
login(HUNTER, saved)
check("the one that logs in takes it", restocker.listsByCharacter["Gogohunter Classic-ClassicBetaPvE"], "Hunter")
check("and the first-name key is gone", restocker.listsByCharacter["Gogohunter-ClassicBetaPvE"], nil)

print("7. A character on another realm keeps its realm")
saved = betaFile()
restocker = saved.global.restocker
restocker.listsByCharacter["Gogomage-ClassicBetaPvP"] = "Mage"
login(DRUID, saved)
check("re-keyed there", restocker.listsByCharacter["Gogomage Classic-ClassicBetaPvP"], "Mage")
check("beside its namesake here", restocker.listsByCharacter["Gogomage Classic-ClassicBetaPvE"], "Mage")

print("8. A new Forever character has nothing to move, and takes nobody's entry")
saved = betaFile()
restocker = saved.global.restocker
before = dump(saved.global)
login({ first = "Gogopriest", surname = "Forever", class = "Priest" }, saved)
check("no entry under its name", restocker.listsByCharacter["Gogopriest Forever-ClassicBetaPvE"], nil)
check("same saved shape", dump(saved.global), before)

print("9. The early beta build gave the whole name first: the surname is never said twice")
saved = betaFile()
restocker = saved.global.restocker
ns = login({ first = "Gogowarrior", surname = "Classic", class = "Warrior", wholeNameFirst = true }, saved)
check("the key", ns.GetCharacterKey(), "Gogowarrior Classic-ClassicBetaPvE")
check("which is the key that build wrote", restocker.listsByCharacter[ns.GetCharacterKey()], "Warrior (old)")
check("and nothing is moved on its say", restocker.listsByCharacter["Gogodruid-ClassicBetaPvE"], "Druid")

print("10. A Forever character with no surname keeps its one name")
saved = betaFile()
restocker = saved.global.restocker
ns = login({ first = "Gogodruid", class = "Druid" }, saved)
check("the key", ns.GetCharacterKey(), "Gogodruid-ClassicBetaPvE")
check("with its list under it", restocker.listsByCharacter[ns.GetCharacterKey()], "Druid")
check("with nothing moved", restocker.listsByCharacter["Gogohunter-ClassicBetaPvE"], "Hunter")

print("11. Era and TBC: a character has the one name, and nothing changes")
saved = {
	sv = { profileKeys = { ["Mossbark - Old Blanchy"] = "Default", ["Thornhoof - Old Blanchy"] = "Default" } },
	global = {
		restocker = {
			lists = { Druid = {}, ["Druid (2)"] = {} },
			listsByCharacter = { ["Mossbark-OldBlanchy"] = "Druid (2)", ["Thornhoof-OldBlanchy"] = "Druid" },
			starterListDismissed = { ["Mossbark-OldBlanchy"] = true },
		},
		inventory = { ["Mossbark-OldBlanchy"] = { name = "Mossbark", realm = "Old Blanchy", class = "DRUID" } },
	},
}
before = dump(saved.global.restocker.listsByCharacter) .. dump(saved.global.inventory)
ns = login({ first = "Mossbark", realm = "Old Blanchy", era = true }, saved)
check("the key, the realm's space closed up", ns.GetCharacterKey(), "Mossbark-OldBlanchy")
check("with its list under it", saved.global.restocker.listsByCharacter[ns.GetCharacterKey()], "Druid (2)")
check("same keys", dump(saved.global.restocker.listsByCharacter) .. dump(saved.global.inventory), before)

print("")
if failures == 0 then
	print("ALL CHARACTER KEY MIGRATION SCENARIOS PASSED")
else
	print(("%d CHARACTER KEY MIGRATION CHECK(S) FAILED"):format(failures))
	os.exit(1)
end
