local _, ns = ...

--------------------------------------------------------------------------------
-- Moving Every Character Off Default
--------------------------------------------------------------------------------

-- MIGRATION (remove after 2026-10-30)
--[[
    One-time upgrade shim. Delete on the first code pass after that date, all
    four pieces together:
      1. this file
      2. its line in all three flavor TOCs (Consumable-Connoisseur_Vanilla.toc,
         _TBC.toc and _Camelot.toc)
      3. the ns.MoveCharactersOntoOwnProfiles() call in Features/Core.lua
      4. the MIGRATION block that ends Features/Tests/Character-Profile-Test.lua,
         and this file's line in that suite's load list
]]

--[[
    Every character has a profile of its own, named as AceDB names the
    character (the maintainer's ruling, README-Notes.md): scrolls, buff food
    and the rest of the Macros panel differ from one character to the next.
    Three things a release saved have to be carried into that shape.

    Characters on the shared Default profile. Releases before 2026-07-25 put
    every character there, and AceDB remembers a character's profile for good,
    so those characters never left it. Each of them gets its own profile now,
    starting as a copy of Default, so nothing a character was using changes on
    the day it moves. They all move in the first login, the logged-out ones
    too: AceDB keeps every character's name in profileKeys, and a character's
    profile is named exactly that. Default is deleted once nobody is left on
    it. A profile the player named, and every character on it, is left as it
    is.

    The list each character uses. The Restock Lists are shared by the account,
    and each profile picks the one it uses (profile.restockList), where
    releases through 2026.09.24.A kept that choice by character in
    global.restocker.listsByCharacter. The character playing takes its entry
    onto its profile, and so does every other character profileKeys names. An
    entry nobody can be matched to waits for its character to log in and claim
    it, and the table goes when its last entry does.

    A WoW Forever character's settings. An AceDB before minor 39 named one by
    its first name and the realm's rule set ("Gogodruid - PvE"), and releases
    through 2026.09.24.A kept its settings and Ignore List on the profile that
    name points at. The character playing takes a copy onto its own profile.

    Nothing here is for the builds between two releases that put every
    character on Default on purpose: no player ever had one. Their characters
    are on Default all the same, so the first of these moves them too.

    Called from InitializeSavedVariables in Features/Core.lua before the
    profile callbacks are wired, so the switch fires no handler halfway through
    login, and after ns.RekeyCharactersByFullName, so a Forever character's
    list choice is already under its whole name. Once it has run nobody is on
    Default, no entry is left for this character and its profile holds
    settings, so a second login changes nothing.

    A player who makes a profile called Default inside the window and puts a
    character on it is moved off it again at the next login, onto a copy.
]]

local DEFAULT_PROFILE = "Default"

-- Derived data rather than a choice: everything else a profile holds, the player set.
local DERIVED_KEYS = {
	itemCache = true,
	itemCacheFolder = true,
	itemCacheVersion = true,
}

local function HoldsSettings(profile)
	if type(profile) ~= "table" then
		return false
	end
	for key in pairs(profile) do
		if not DERIVED_KEYS[key] then
			return true
		end
	end
	return false
end

-- Everything the player set, the profile's Ignore List included.
local function CopySettings(profile)
	local copy = {}
	for key, value in pairs(profile or {}) do
		if not DERIVED_KEYS[key] then
			copy[key] = type(value) == "table" and CopyTable(value) or value
		end
	end
	return copy
end

-- A saved table under one key, made when there is none.
local function SubTable(parent, key)
	if type(parent[key]) ~= "table" then
		parent[key] = {}
	end
	return parent[key]
end

--------------------------------------------------------------------------------
-- Characters
--------------------------------------------------------------------------------

--[[
    This character's name in profileKeys. AceDB's own reading of it is wrong in
    a session where the library loaded before the client had named the
    character, so the client is asked again first.
]]
local function OwnProfileKey()
	return ns.GetCharacterProfileName() or ns.db.keys.char
end

--[[
    The entry that belongs to a logged-out character in a table keyed the
    add-on's way (ns.GetCharacterKey: the whole name, then "-Realm" with the
    realm's spaces closed up), found from the character's name in profileKeys.
    An Era or TBC character's key is built from its name and realm. A Forever
    character's name is unique across the region and profileKeys holds no
    realm for it, so its entry is the one that begins with the whole name.
]]
local function FindCharacterEntry(keyed, profileKey)
	local name, realm = ns.SplitCharacterProfileName(profileKey)
	if not name then
		return nil
	end
	if realm then
		local characterKey = name .. "-" .. (realm:gsub("%s+", ""))
		return keyed[characterKey] ~= nil and characterKey or nil
	end

	local prefix = name .. "-"
	for characterKey in pairs(keyed) do
		if type(characterKey) == "string" and characterKey:sub(1, #prefix) == prefix then
			return characterKey
		end
	end
	return nil
end

--[[
    Entries in profileKeys that name no character: the one AceDB writes when
    the client has not named the character yet ("Unknown", or "Unknown -
    Realm"). Nobody logs in as it, and one left pointing at Default would stop
    Default being deleted below. On Forever a first name and rule set names a
    character to an older AceDB, and stays (see below).
]]
local function DropUnnamedCharacters(profileKeys, ownProfileKey)
	for profileKey in pairs(profileKeys) do
		if
			profileKey ~= ownProfileKey
			and profileKey ~= ns.db.keys.char
			and not ns.SplitCharacterProfileName(profileKey)
		then
			local name = profileKey:match("^(.-) %- ")
			if name == nil or name == UNKNOWNOBJECT then
				profileKeys[profileKey] = nil
			end
		end
	end
end

--------------------------------------------------------------------------------
-- Forever's Older Names
--------------------------------------------------------------------------------

--[[
    An AceDB before minor 39 named a WoW Forever character by its first name
    and the realm's rule set ("Gogodruid - PvE"). The vendored copy still reads
    the rule set that way (ns.db.keys.realm), so this character's older name is
    rebuilt exactly, and the profile it points at holds the settings and Ignore
    List the character used through 2026.09.24.A. The character's own profile
    takes a copy while it holds no settings. Nothing has read that profile yet,
    or its defaults would count as settings, so AceDB reads the copy.

    The older name and its profile both stay: characters sharing a first name
    on one rule set shared the name, and each takes its copy at its own login.
    No logged-out character is carried, because its whole name reaches
    profileKeys only at its own login.
]]
local function CarryOlderForeverSettings(profiles, profileKeys, ownProfileKey)
	local firstName = UnitName("player")
	-- Era and TBC characters have the one name, which AceDB has always written the same way.
	if not firstName or ns.GetPlayerFullName() == firstName then
		return
	end

	local olderProfileName = profileKeys[firstName .. " - " .. ns.db.keys.realm]
	local olderProfile = olderProfileName and profiles[olderProfileName]
	if HoldsSettings(olderProfile) and not HoldsSettings(profiles[ownProfileKey]) then
		profiles[ownProfileKey] = CopySettings(olderProfile)
	end
end

--------------------------------------------------------------------------------
-- Off Default
--------------------------------------------------------------------------------

local function MoveCharactersOffDefault(profiles, profileKeys, ownProfileKey)
	local default = profiles[DEFAULT_PROFILE]

	-- Collected before anything moves, because a table cannot take new keys while it is being walked.
	local moving = {}
	for profileKey, profileName in pairs(profileKeys) do
		if profileName == DEFAULT_PROFILE and ns.SplitCharacterProfileName(profileKey) then
			moving[#moving + 1] = profileKey
		end
	end

	for _, profileKey in ipairs(moving) do
		-- A profile already saved under the character's name keeps what it holds.
		if not HoldsSettings(profiles[profileKey]) then
			profiles[profileKey] = CopySettings(default)
		end

		profileKeys[profileKey] = profileKey
		if profileKey == ownProfileKey then
			ns.db:SetProfile(profileKey)
		end
	end

	--[[
	    Default goes once nobody is on it, when this emptied it or it held
	    nothing a player set. One the player emptied by hand, with settings
	    still in it, is theirs to keep. Read again, because the switch above
	    makes AceDB build a Default that was not in the file.
	]]
	default = profiles[DEFAULT_PROFILE]
	if type(default) ~= "table" or not (#moving > 0 or not HoldsSettings(default)) then
		return
	end
	for _, profileName in pairs(profileKeys) do
		if profileName == DEFAULT_PROFILE then
			return
		end
	end
	ns.db:DeleteProfile(DEFAULT_PROFILE, true)
end

--------------------------------------------------------------------------------
-- Restock List Choices
--------------------------------------------------------------------------------

--[[
    The first character placed on a profile decides its list, and the character
    playing is placed first. Two characters sharing a profile the player named
    share its list from here on, which is what picking a list per profile
    means.
]]
local function CarryListChoices(profiles, profileKeys, ownProfileKey)
	local restocker = ns.db.global.restocker
	local listsByCharacter = restocker.listsByCharacter
	if listsByCharacter == nil then
		return
	end

	if type(listsByCharacter) == "table" then
		local ownKey = ns.GetCharacterKey()
		if listsByCharacter[ownKey] ~= nil then
			if ns.db.profile.restockList == nil then
				ns.db.profile.restockList = listsByCharacter[ownKey]
			end
			listsByCharacter[ownKey] = nil
		end

		for profileKey, profileName in pairs(profileKeys) do
			local characterKey = profileKey ~= ownProfileKey and FindCharacterEntry(listsByCharacter, profileKey)
			if characterKey then
				local profile = SubTable(profiles, profileName)
				if profile.restockList == nil then
					profile.restockList = listsByCharacter[characterKey]
				end
				listsByCharacter[characterKey] = nil
			end
		end

		if next(listsByCharacter) ~= nil then
			return
		end
	end

	restocker.listsByCharacter = nil
end

--------------------------------------------------------------------------------
-- Migration
--------------------------------------------------------------------------------

function ns.MoveCharactersOntoOwnProfiles()
	local profileKeys = ns.db.sv.profileKeys
	if type(profileKeys) ~= "table" then
		return
	end
	local profiles = SubTable(ns.db.sv, "profiles")
	local ownProfileKey = OwnProfileKey()

	CarryOlderForeverSettings(profiles, profileKeys, ownProfileKey)
	DropUnnamedCharacters(profileKeys, ownProfileKey)
	MoveCharactersOffDefault(profiles, profileKeys, ownProfileKey)
	CarryListChoices(profiles, profileKeys, ownProfileKey)
end
