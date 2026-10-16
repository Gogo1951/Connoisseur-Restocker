local _, ns = ...

--------------------------------------------------------------------------------
-- Keying Forever Characters By Their Whole Names
--------------------------------------------------------------------------------

-- MIGRATION (remove after 2026-10-30)
--[[
    One-time upgrade shim. Delete on the first code pass after that date, all
    five pieces together:
      1. this file
      2. its line in all three flavor TOCs (Consumable-Connoisseur_Vanilla.toc,
         _TBC.toc and _Camelot.toc)
      3. the ns.RekeyCharactersByFullName() call in Features/Core.lua
      4. Tests/Character-Key-Migration-Test.lua
      5. this file's tagged line in Tests/Character-Profile-Test.lua's load list
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

    Only the character playing moves, by what the client says its names are,
    and every other character moves at its own login. A logged-out character's
    entries wait under its first name: nothing tells an add-on its surname, and
    profileKeys holds no realm for a Forever character, so a first name alone
    could belong to a namesake on another realm, and matching by it would hand
    one character's list and bags to the other.

    Era and TBC characters have the one name, so their keys do not change and
    this returns at once.

    Called from InitializeSavedVariables in Features/Core.lua, after the
    Restocker's saved-key rename and before ns.MoveCharactersOntoOwnProfiles
    reads listsByCharacter. Once it has run this character's first-name key is
    gone, so a second login changes nothing.
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
end
