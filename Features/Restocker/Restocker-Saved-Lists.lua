local _, ns = ...
local L = ns.L

--------------------------------------------------------------------------------
-- Restock Lists
--------------------------------------------------------------------------------

--[[
    The player's named shopping lists; the compact form they are saved in lives
    in Restocker-Saved-Format.lua. These are not AceDB profiles: each is a list
    of items shared by the whole account, and the stock Reset Profile control
    never reaches them. What a profile holds is the name of the list it uses
    (ns.db.profile.restockList), so each character shops from the list its
    profile picked.
]]

--------------------------------------------------------------------------------
-- Characters
--------------------------------------------------------------------------------

-- "-Realm" as it ends a character's key, the realm's spaces closed up; empty where the client names no realm.
local function RealmSuffix()
	local realm = ((GetRealmName() or ""):gsub("%s+", ""))
	if realm == "" then
		return ""
	end
	return "-" .. realm
end

--[[
    Stable per-character identity: the Starter List dismissal flags and the
    Inventory Report's records key on it. The character's whole name, which on
    Forever is its first name and surname (ns.GetPlayerFullName in
    Features/Utilities.lua), then its realm.
]]
function ns.GetCharacterKey()
	return (ns.GetPlayerFullName() or "Unknown") .. RealmSuffix()
end

--[[
    Every recorded character's class token, by the name AceDB keys the
    character under (ns.ProfileNameForCharacter). Read off the records the
    Inventory Report keeps (ns.db.global.inventory, refreshed at every login
    by Features/Inventory-Report.lua), so a character's class is known from its
    first login on a build that keeps that record.
]]
local function ClassesByProfileName()
	local classes = {}
	for _, record in pairs(ns.db.global.inventory) do
		if type(record) == "table" and record.name and record.realm then
			classes[ns.ProfileNameForCharacter(record.name, record.realm)] = record.class
		end
	end
	return classes
end

--------------------------------------------------------------------------------
-- Add List
--------------------------------------------------------------------------------

function ns.AddRestockList(newListName)
	local settings = ns.restockSettings

	--[[
	    Never overwrite an existing list: an unguarded add replaced it with an empty
	    one and the items were unrecoverable. Same refusal ns.RenameCurrentRestockList makes.
	    ns.CreateRestockList picks a free name before calling in; ns.CloneCurrentRestockList
	    picks one too and writes its copy itself.
	]]
	if settings.lists[newListName] ~= nil then
		ns.PrintMessage(string.format(L["RESTOCKER_PROFILE_EXISTS"], newListName))
		return
	end

	settings.lists[newListName] = {}
	ns.UseRestockList(newListName)

	local menu = ns.restockWindow or ns.CreateRestockWindow()
	menu:Show()
	ns.UpdateRestockList()

	ns.UpdateRestockListWidgets()
end

--------------------------------------------------------------------------------
-- Default List Names
--------------------------------------------------------------------------------

--[[
    The name a brand-new list gets: the character's class, because class is
    what actually decides a shopping list -- every Warlock wants shards and
    stones, whichever alt is holding the bags. The localized class name, since
    this is a player-facing, player-editable name like any the player could
    type themselves.

    An existing list with that name is NEVER joined automatically: it is some
    other character's curated list, and quietly attaching a new character to it
    would let that character's Starter List picks and level-up upgrades write
    into it uninvited. The new list takes a numbered variant instead
    ("Warrior (2)"), and whether to reuse the other list stays the player's own
    call (Copy replaces the current list with a copy of it; nothing merges).
    Login calls this only for a profile that has chosen no list, so nobody's
    existing setup is renamed or moved. The New List entry calls it
    too, and so does deleting the very last list, which has to leave the
    character on something (see Delete List below).
]]

--[[
    Is this name spoken for? By a list, or by another profile still pointed at
    a list of that name which has since been deleted. A character on that
    profile makes the list again, empty, at its next login
    (ns.InitCharacterRestockList), so a fresh list that took the name first
    would be joined by it uninvited -- the very thing a fresh name exists to
    prevent, arrived at by the back door.
]]
local function IsListNameTaken(settings, name)
	if settings.lists[name] ~= nil then
		return true
	end
	-- Read first: it makes AceDB build the profile in use, and the saved table that holds them all.
	local ownProfile = ns.db.profile
	for _, profile in pairs(ns.db.sv.profiles) do
		if profile ~= ownProfile and type(profile) == "table" and profile.restockList == name then
			return true
		end
	end
	return false
end

local function FreeClassListName(settings)
	local className = UnitClass("player")
	local name = className
	local suffix = 2
	while IsListNameTaken(settings, name) do
		name = className .. " (" .. suffix .. ")"
		suffix = suffix + 1
	end
	return name
end

--------------------------------------------------------------------------------
-- List Order
--------------------------------------------------------------------------------

--[[
    Every list's name in the one order the add-on shows them in: A to Z, the
    order the selector's menu draws. pairs() order is arbitrary, and "the top
    list" has to be the same list to the menu and to a delete.
]]
function ns.GetRestockListNames()
	local names = {}
	for name in pairs(ns.restockSettings.lists) do
		names[#names + 1] = name
	end
	table.sort(names)
	return names
end

--------------------------------------------------------------------------------
-- List Users
--------------------------------------------------------------------------------

--[[
    The characters on a list, A to Z, each as { key, name, class }: every
    character whose profile uses it. name is what to show: the bare name for a
    character on this realm, Name-Realm for one elsewhere. class is the token
    its name is colored by, or nil when the add-on has not recorded it
    (ClassesByProfileName above). othersOnly leaves this character out, for the
    delete confirm, which names who else loses the list.

    Read from AceDB's own record of which profile each character is on
    (profileKeys), so a character counts from its first login and goes on
    counting after it is deleted: nothing tells an add-on that a character is
    gone. This character is read from the client instead, so it is listed even
    in a session where AceDB could not name it (Features/Core.lua), and the
    entry AceDB wrote for it then names nobody and is passed over.
]]
function ns.GetRestockListUsers(listName, othersOnly)
	local users = {}

	-- Read first: it makes AceDB build the profile in use, and the saved table that holds them all.
	local ownProfile = ns.db.profile
	if not othersOnly and ownProfile.restockList == listName then
		local _, classToken = UnitClass("player")
		users[1] = { key = ns.db.keys.char, name = ns.GetPlayerFullName() or "Unknown", class = classToken }
	end

	local ownProfileKey = ns.GetCharacterProfileName() or ns.db.keys.char
	local ownRealm = GetRealmName()
	local profiles = ns.db.sv.profiles
	local classes = ClassesByProfileName()
	for profileKey, profileName in pairs(ns.db.sv.profileKeys) do
		local name, realm = ns.SplitCharacterProfileName(profileKey)
		local profile = profiles[profileName]
		if
			name
			and profileKey ~= ownProfileKey
			and profileKey ~= ns.db.keys.char
			and type(profile) == "table"
			and profile.restockList == listName
		then
			if realm and realm ~= ownRealm then
				name = name .. "-" .. (realm:gsub("%s+", ""))
			end
			users[#users + 1] = { key = profileKey, name = name, class = classes[profileKey] }
		end
	end
	-- By the name shown; the key only settles two characters shown alike.
	table.sort(users, function(a, b)
		if a.name ~= b.name then
			return a.name < b.name
		end
		return a.key < b.key
	end)
	return users
end

--------------------------------------------------------------------------------
-- Delete List
--------------------------------------------------------------------------------

--[[
    Where deleting the list in use leaves this character: on the top list, the
    first of those that remain in the selector's own order. nil when the list is
    the last one and there is nothing left to land on.

    The maintainer's ruling (README-Notes): a delete never makes a list while
    another one exists. It used to start a fresh class-named list every time,
    so deleting "Druid (2)" made "Druid (3)" and deleting that made "Druid (2)"
    again -- a list could be renamed by deleting it, but never got rid of.

    The top list can be another character's. That is part of the ruling, and it
    is why the confirm names the list before the player agrees
    (Restocker-Window-List-Bar.lua reads this too).
]]
function ns.GetRestockListAfterDelete(listName)
	for _, name in ipairs(ns.GetRestockListNames()) do
		if name ~= listName then
			return name
		end
	end
	return nil
end

function ns.DeleteRestockList(listName)
	local settings = ns.restockSettings
	if listName == nil or settings.lists[listName] == nil then
		return
	end
	--[[
	    Deleting the CURRENT list clears via ns.UseRestockList below; this covers
	    deleting any other list, which ns.UseRestockList never sees.
	]]
	ns.ClearRestockNewItems()

	local wasCurrent = settings.currentList == listName
	local landing = ns.GetRestockListAfterDelete(listName)
	settings.lists[listName] = nil

	if wasCurrent then
		if not landing then
			--[[
			    The last list is gone, and a character always has to be on some
			    list, so this is the one delete that makes one: empty, and named
			    for the class like any fresh list. Named now that the deleted
			    list has given its name up, so deleting an only list called
			    "Druid" leaves an empty "Druid", not a "Druid (2)".
			]]
			landing = FreeClassListName(settings)
			settings.lists[landing] = {}
		end
		--[[
		    Landed on, not picked: ns.UseRestockList rather than
		    ns.SwitchRestockList, which reruns the bank restock and the merchant
		    buy while either window is open. A bank run already under way is
		    stopped as well, since it re-reads the list in use at every step and
		    would carry straight on against this one.
		]]
		ns.StopBankRestock()
		ns.UseRestockList(landing)
	end

	if not ns.restockWindow then
		ns.CreateRestockWindow()
	end
	ns.UpdateRestockListWidgets()
end

--------------------------------------------------------------------------------
-- List Widgets
--------------------------------------------------------------------------------

--[[
    Sync the window's list bar with the active list: its name, the characters
    on it, and an end to any rename in progress. A no-op until the window is
    built, which the login path reaches only after the character's list is set.
]]
function ns.UpdateRestockListWidgets()
	if ns.restockWindow then
		ns.RefreshRestockListBar()
	end
end

--------------------------------------------------------------------------------
-- Rename List
--------------------------------------------------------------------------------

function ns.RenameCurrentRestockList(newName)
	local settings = ns.restockSettings
	local currentListName = settings.currentList

	-- Trim; ignore empty names and no-ops, and never clobber an existing list.
	newName = (newName or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if newName == "" or newName == currentListName then
		ns.UpdateRestockListWidgets()
		return
	end
	if settings.lists[newName] ~= nil then
		ns.PrintMessage(string.format(L["RESTOCKER_PROFILE_EXISTS"], newName))
		ns.UpdateRestockListWidgets()
		return
	end

	settings.lists[newName] = settings.lists[currentListName]
	settings.lists[currentListName] = nil

	--[[
	    Every profile following the old name keeps following it under the new
	    name (otherwise its choice would dangle and its characters would get a
	    fresh empty list with the old name on next login).
	]]
	for _, profile in pairs(ns.db.sv.profiles) do
		if type(profile) == "table" and profile.restockList == currentListName then
			profile.restockList = newName
		end
	end

	ns.UseRestockList(newName)
	ns.UpdateRestockListWidgets()
	--[[
	    ns.UseRestockList just retired the "New" flags and any undo on offer, and
	    both are drawn: the rows still sit in the New group and the status line
	    still offers the undo until the window is repainted.
	]]
	ns.UpdateRestockList()
end

--[[
    The "New List" entry, on the list selector's menu and the Manage Lists menu. Starts a
    fresh list seeded with the class name (numbered on collision, like every
    new list), switches to it, then opens the rename over it so a different
    name is one line of typing away.
]]
function ns.CreateRestockList()
	ns.AddRestockList(FreeClassListName(ns.restockSettings))
	ns.BeginRestockListRename()
end

--[[
    The Manage Lists menu's Copy entry. Clones the active list into a new, uniquely named one
    ("<name> Copy", then "<name> Copy 2", ...), switches to the clone, and opens
    the rename over it so the real name can be typed immediately.
]]
function ns.CloneCurrentRestockList()
	local settings = ns.restockSettings
	local sourceName = settings.currentList
	local source = sourceName and settings.lists[sourceName]
	if not source then
		return
	end

	local base = string.format(L["RESTOCKER_PROFILE_COPY_NAME"], sourceName)
	local name = base
	local suffix = 2
	while settings.lists[name] ~= nil do
		name = base .. " " .. suffix
		suffix = suffix + 1
	end

	settings.lists[name] = CopyTable(source)
	ns.UseRestockList(name)

	local menu = ns.restockWindow or ns.CreateRestockWindow()
	menu:Show()
	ns.UpdateRestockList()
	ns.UpdateRestockListWidgets()
	ns.BeginRestockListRename()
end

--------------------------------------------------------------------------------
-- Change List
--------------------------------------------------------------------------------

function ns.SwitchRestockList(newListName)
	if newListName == nil or newListName == "" then
		return
	end
	-- A typed `/crs profile use` name can miss; pointing the character at no list breaks every list read.
	if ns.restockSettings.lists[newListName] == nil then
		return
	end
	ns.UseRestockList(newListName)

	ns.UpdateRestockListWidgets()
	ns.UpdateRestockList()

	if ns.bankIsOpen then
		ns.OnRestockerBankOpen()
	end

	if ns.merchantIsOpen and not ns.merchantBuyingSkipped then
		ns.OnRestockerMerchantShow()
	end
end

--------------------------------------------------------------------------------
-- Copy List
--------------------------------------------------------------------------------

function ns.CopyIntoCurrentRestockList(listToCopy)
	local settings = ns.restockSettings

	if listToCopy == nil or settings.lists[listToCopy] == nil then
		return
	end

	local copiedList = CopyTable(settings.lists[listToCopy])
	settings.lists[settings.currentList] = copiedList

	--[[
	    The copy replaced this list's contents wholesale, so the "New" notes no
	    longer describe anything in it -- and no ns.UseRestockList runs to clear them.
	]]
	ns.ClearRestockNewItems()
	ns.UpdateRestockList()
end

--------------------------------------------------------------------------------
-- This Profile's List
--------------------------------------------------------------------------------

--[[
    Switch the active list AND remember the choice on the profile in use, so
    each character returns to its profile's list next login. Use this instead
    of writing settings.currentList directly.
]]
function ns.UseRestockList(name)
	if name == nil or name == "" then
		return
	end
	--[[
	    Any list event stales the "New" group, and every one of them --
	    create, switch, clone, delete-with-fallback, login init -- passes
	    through here. (A rename lands here too and clears; a note about "what
	    I just added" does not outrank keeping this the single choke point.)
	]]
	ns.ClearRestockNewItems()
	local settings = ns.restockSettings
	settings.currentList = name
	ns.db.profile.restockList = name
end

--[[
    Pick the list this character uses on login: its profile's choice, or -- for
    a profile that has made none, which is any character seen for the first
    time -- a fresh class-named list (FreeClassListName above). Only those get
    the class scheme, so no existing setup is renamed or moved.

    The pointed-at list is created when missing, because another character can
    delete it between logins. No character is given an eponymous "Name-Realm"
    list, so hand-deleting one of those legacy lists sticks.
]]
function ns.InitCharacterRestockList()
	local settings = ns.restockSettings
	local listName = ns.db.profile.restockList or FreeClassListName(settings)

	if settings.lists[listName] == nil then
		settings.lists[listName] = {}
	end
	ns.UseRestockList(listName)
end

--[[
    Core's profile callbacks end up here: the player switched this character
    to another profile, copied one over it, or reset it, and the profile's list
    choice went with the rest of its settings.

    A profile that names a list puts the character on it, as picking it from
    the selector would, and a list deleted since is made again, as at login. A
    profile that names none, a new one or one just reset, takes the list in
    use: Reset Profile is not a reason to start a character on an empty list,
    and must never reach the lists themselves.
]]
function ns.ApplyProfileRestockList()
	if not ns.restockerLoaded then
		return
	end
	local settings = ns.restockSettings
	local listName = ns.db.profile.restockList
	if listName == nil or listName == settings.currentList then
		ns.db.profile.restockList = settings.currentList
		-- The list stands, but who else is on it changed with the profile.
		ns.UpdateRestockListWidgets()
		return
	end

	if settings.lists[listName] == nil then
		settings.lists[listName] = {}
	end
	ns.SwitchRestockList(listName)
end
