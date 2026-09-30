local _, ns = ...

--------------------------------------------------------------------------------
-- Keying Forever Characters By Their Whole Names
--------------------------------------------------------------------------------

-- MIGRATION (remove after 2026-10-30)
--[[
    One-time upgrade shim. Delete on the first code pass after that date, all
    four pieces together:
      1. this file
      2. its line in all three flavor TOCs (Consumable-Connoisseur_Vanilla.toc,
         _TBC.toc and _Camelot.toc)
      3. the ns.RekeyCharactersByFullName() call in Features/Core.lua
      4. Features/Tests/Character-Key-Migration-Test.lua
]]

--[[
    A WoW Forever character has a first name and a surname. Every release up
    to and including 2026.09.24.A keyed a character by UnitName's first value
    and its realm, which on Forever is the first name alone
    ("Gogodruid-ClassicBetaPvE"). The Restock List then showed every character
    by half its name, and two characters sharing a first name shared one key.
    ns.GetCharacterKey (Features/Restocker/Restocker-Saved-Lists.lua) now takes
    the whole name ("Gogodruid Forever-ClassicBetaPvE"), and this moves what
    was saved under the old key to the new one, in each table keyed by
    character:

      ns.db.global.restocker.listsByCharacter       the list a character uses
      ns.db.global.restocker.starterListDismissed   its staples pop-up answer
      ns.db.global.inventory                        its Inventory Report record

    The first of those is itself on its way out: the list a character uses is
    kept on its profile now, and ns.MoveCharactersOntoOwnProfiles
    (Features/Default-Profile-Migration.lua) carries each entry there right
    after this. It finds a character's entry by its whole name, which is why
    this runs first.

    Without it a character would log in as one the add-on has never seen: onto
    a fresh, empty class-named list, with its real list still in the file.

    The old key's entry replaces one already under the new key. That one can
    only be a leftover: an early beta build's UnitName gave the whole name, so
    a file that has been through it holds the same character under both keys,
    and the first-name key is the one the add-on has been writing since.

    This character moves by what the client says its names are. The others are
    logged out, and nothing tells an add-on a logged-out character's surname --
    but AceDB has written each one's whole name down, because from minor 39 it
    keys profileKeys on Forever by first name and surname with a space between.
    So a first name that exactly one of those names begins with takes that
    name, and a first name two of them share is left for each character's own
    login to settle. AceDB's names are believed only while this character's own
    is among them, spelled the way the client gives it; an older AceDB keys by
    first name and rule set, which says nothing about surnames and so moves
    nobody but this character.

    Era and TBC characters have the one name, so their keys do not change and
    this returns at once.

    Called from InitializeSavedVariables in Features/Core.lua, after the
    Restocker's saved-key rename and before ns.MoveCharactersOntoOwnProfiles
    reads listsByCharacter. Once it has run no first-name key is left, so a
    second login changes nothing.
]]

-- Every saved table keyed by character, handed to `visit` one at a time.
local function ForEachCharacterTable(visit)
	local global = ns.db.global
	local restocker = global.restocker
	-- pairs, not ipairs: a table missing from a hand-edited file must not hide the ones after it.
	for _, keyed in pairs({ restocker.listsByCharacter, restocker.starterListDismissed, global.inventory }) do
		if type(keyed) == "table" then
			visit(keyed)
		end
	end
end

local function MoveCharacter(oldKey, newKey)
	ForEachCharacterTable(function(keyed)
		if keyed[oldKey] ~= nil then
			keyed[newKey] = keyed[oldKey]
			keyed[oldKey] = nil
		end
	end)
end

--[[
    The whole names AceDB has written down, by first name, and the set of them.
    A first name that two of them share maps to false: it stands for neither.
]]
local function FullNamesByFirstName()
	local fullNames, known = {}, {}
	for characterKey in pairs(ns.db.sv.profileKeys or {}) do
		-- Before minor 39 AceDB added " - " and the realm's rule set to the name, and knew no surname.
		if type(characterKey) == "string" and not characterKey:find(" - ", 1, true) then
			known[characterKey] = true
			local firstName = characterKey:match("^(%S+) %S")
			if firstName then
				fullNames[firstName] = fullNames[firstName] == nil and characterKey or false
			end
		end
	end
	return fullNames, known
end

function ns.RekeyCharactersByFullName()
	local firstName = UnitName("player")
	local fullName = ns.GetPlayerFullName()
	-- Era and TBC, where the two are the same name. Or a name the client has not given yet, which moves nothing.
	if not firstName or not fullName or fullName == firstName then
		return
	end

	-- This character's old key is its new one with the surname taken back out.
	local newKey = ns.GetCharacterKey()
	MoveCharacter(firstName .. newKey:sub(#fullName + 1), newKey)

	local fullNames, known = FullNamesByFirstName()
	if not known[fullName] then
		return
	end

	--[[
	    Every other key still on a first name AceDB can complete. The realm
	    rides along as it is: everything from the key's first hyphen on.
	    Collected before anything moves, because a table cannot take new keys
	    while it is being walked.
	]]
	local moves = {}
	ForEachCharacterTable(function(keyed)
		for characterKey in pairs(keyed) do
			if type(characterKey) == "string" and not moves[characterKey] then
				local name, realmSuffix = characterKey:match("^([^%-]+)(%-.*)$")
				local otherFullName = fullNames[name or characterKey]
				if otherFullName then
					moves[characterKey] = { name = otherFullName, key = otherFullName .. (realmSuffix or "") }
				end
			end
		end
	end)

	local inventory = ns.db.global.inventory
	for oldKey, whole in pairs(moves) do
		MoveCharacter(oldKey, whole.key)
		--[[
		    An Inventory Report record carries the name its character is listed
		    by, which only that character's own login refreshes. Completed here,
		    so the report and the Restock List name a character alike meanwhile.
		]]
		local record = type(inventory) == "table" and inventory[whole.key]
		if type(record) == "table" then
			record.name = whole.name
		end
	end
end
