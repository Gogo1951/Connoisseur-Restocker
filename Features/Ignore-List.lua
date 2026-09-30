local _, ns = ...

local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--------------------------------------------------------------------------------
-- Ignore List
--------------------------------------------------------------------------------

--[[
    Two ignore lists, and ignoring is additive: an item on either one is
    invisible to every macro's item selection -- food, water, potions, pet food,
    scrolls, all of it. The character's own list is profile-scoped -- each
    character has its own AceDB profile (ns.db is created without the
    shared-Default flag, so a fresh character lands on a profile named for
    it), so it lives directly in the profile as a flat table. Two characters
    the player put on one profile share that list with the rest of its
    settings. The Global list is its mirror in global, shared by every
    character whatever profile it is on.

    Both are declared in ns.DATABASE_DEFAULTS, so a brand-new character simply
    starts empty, and both return nil only before the database exists.
]]
function ns.GetIgnoreList()
	if not ns.db then
		return nil
	end
	return ns.db.profile.ignoreList
end

function ns.GetGlobalIgnoreList()
	if not ns.db then
		return nil
	end
	return ns.db.global.ignoreList
end

--[[
    True when either list hides the item. Neither list can override the other:
    adding an item anywhere hides it, and it stays hidden until it is off both
    lists.
]]
function ns.IsIgnored(itemID)
	local ignoreList = ns.GetIgnoreList()
	if ignoreList and ignoreList[itemID] then
		return true
	end
	local globalIgnoreList = ns.GetGlobalIgnoreList()
	return (globalIgnoreList and globalIgnoreList[itemID]) and true or false
end

--[[
    Every mutation ends here. The lists are a scan input: an item ignored while
    its macro already names it has to be written out of that body, not just out
    of the list -- so the macro state is wiped and the rebuild is forced.
    UpdateMacros defers itself in combat or while the Blizzard Macro UI is
    open, so forcing here is safe everywhere.
]]
local function RefreshMacros()
	ns.ResetMacroState()
	ns.UpdateMacros(true)
end

--[[
    The mini-map button's Right-Click (ignore the food it is currently offering)
    and Middle-Click (clear) act on the current character's list only, which is
    exactly what the mini-map tooltip's Ignore List section shows -- so both
    keep meaning what the player just read. The Global list is edited from the
    Ignore List panel instead, through ns.SetIgnoredInScope below.

    Both repaint that panel as well. It is registered as a builder function, so
    a repaint rebuilds its rows straight off the live lists -- but something has
    to ask for one, and a mini-map click while the panel is already on screen is
    the one edit path with nothing that does. NotifyChange costs nothing while
    nothing is displaying the table.

    Right-Click only ever adds: in combat or with the Macro UI open the rebuild
    waits, so the tooltip still offers the same food, and a second click must not
    take it back off the list.
]]
function ns.IgnoreItem(itemID)
	if not itemID then
		return
	end
	local ignoreList = ns.GetIgnoreList()
	if not ignoreList or ignoreList[itemID] then
		return
	end
	ignoreList[itemID] = true
	RefreshMacros()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.IgnoreList)
end

function ns.ClearIgnoreList()
	local ignoreList = ns.GetIgnoreList()
	if ignoreList then
		wipe(ignoreList)
	end
	RefreshMacros()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.IgnoreList)
end

--------------------------------------------------------------------------------
-- Ignore List Scopes
--------------------------------------------------------------------------------

--[[
    One list looked up by the scope key the Ignore List panel uses: the global
    sentinel (ns.IGNORE_SCOPE_GLOBAL), the profile the player is on right now,
    or any other AceDB profile on the account.

    The current profile resolves through ns.db.profile rather than the raw saved
    table, so an edit lands on the very list the scanner reads and applies live.
    Every other profile is read straight out of ns.db.sv.profiles, because AceDB
    only materializes the profile you are on -- and it strips default-valued
    tables at logout, so a character who never added an entry has no stored
    ignoreList. A read returns nil in that case; a write passes createIfMissing
    and builds what it needs on the spot.
]]
function ns.GetIgnoreListForScope(scopeKey, createIfMissing)
	if not (ns.db and scopeKey) then
		return nil
	end

	if scopeKey == ns.IGNORE_SCOPE_GLOBAL then
		return ns.GetGlobalIgnoreList()
	end

	if scopeKey == ns.db:GetCurrentProfile() then
		return ns.GetIgnoreList()
	end

	local profiles = ns.db.sv and ns.db.sv.profiles
	if not profiles then
		return nil
	end

	local profile = profiles[scopeKey]
	if type(profile) ~= "table" then
		if not createIfMissing then
			return nil
		end
		profile = {}
		profiles[scopeKey] = profile
	end

	local ignoreList = profile.ignoreList
	if type(ignoreList) ~= "table" then
		if not createIfMissing then
			return nil
		end
		ignoreList = {}
		profile.ignoreList = ignoreList
	end

	return ignoreList
end

--[[
    Drop one item from every character's list. Called when the item joins the
    Global list, which already hides it everywhere: ignoring is additive, so a
    character's entry for a globally ignored item can no longer change any
    outcome, and all it does is clutter that character's pane with a row that
    does nothing. Clearing them is what makes "add to Global" mean the item
    lives in exactly one place.

    The live table behind ns.db.profile is the same table as its sv.profiles
    entry, so the loop covers the current character too -- but only once AceDB
    has materialized that profile, hence the direct pass afterwards.
]]
local function ClearFromAllProfiles(itemID)
	local profiles = ns.db.sv and ns.db.sv.profiles
	if profiles then
		for _, profile in pairs(profiles) do
			if type(profile) == "table" and type(profile.ignoreList) == "table" then
				profile.ignoreList[itemID] = nil
			end
		end
	end

	local ignoreList = ns.GetIgnoreList()
	if ignoreList then
		ignoreList[itemID] = nil
	end
end

--[[
    Add or remove one item in one scope. The macro refresh runs for every scope,
    not just the current character's: an edit to the Global list changes what
    this character's macros may pick, and an edit to another character's list
    is cheap enough that checking which scope it was is not worth the branch.

    Removing from the Global list deliberately does not put the item back on
    anyone: there is no record of who held it, and re-adding to a list the
    player did not ask for would be a surprise.
]]
function ns.SetIgnoredInScope(scopeKey, itemID, isIgnored)
	if not itemID then
		return
	end

	local ignoreList = ns.GetIgnoreListForScope(scopeKey, isIgnored and true or false)
	if not ignoreList then
		return
	end

	ignoreList[itemID] = isIgnored and true or nil

	if isIgnored and scopeKey == ns.IGNORE_SCOPE_GLOBAL then
		ClearFromAllProfiles(itemID)
	end

	RefreshMacros()
end

--------------------------------------------------------------------------------
-- Pruning
--------------------------------------------------------------------------------

--[[
    On logout, drop entries that can no longer hide anything, so neither list
    accumulates stale item IDs. Routed from Core's PLAYER_LOGOUT handler.

    Both lists drop only items this client does not know at all. Classic Era
    and Season of Discovery characters share one saved-variables file, and so
    the Global list and any profile the player put characters from both on,
    while their realms build different data folders -- so pruning against one
    folder's consumable data would erase the other folder's entries. Another
    character's list is pruned when that character logs out.
]]
local function PruneOneList(ignoreList)
	if not ignoreList then
		return
	end
	for itemID in pairs(ignoreList) do
		if not C_Item.DoesItemExistByID(itemID) then
			ignoreList[itemID] = nil
		end
	end
end

function ns.OnIgnoreListPlayerLogout()
	PruneOneList(ns.GetIgnoreList())
	PruneOneList(ns.GetGlobalIgnoreList())
end
