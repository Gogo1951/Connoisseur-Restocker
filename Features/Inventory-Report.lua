local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
    Inventory Report -- the block item tooltips gain under the game's own lines:
    the total across every character on the realm, this character on top, then
    one line per other character holding some, each with its bags and bank
    apart.

        C & R // Inventory Report                 Total 82
         Gogodruid                         Bag 7, Bank 18

         Coinpurse                                Bank 30
         Thornhoof                          Bag 7, Bank 20

    The shape is the house one for a branded block: the add-on's short name, the
    separator and a title in the chat prints' own colors (Announcements.lua),
    then double lines, each a space in from the header so the rows read as the
    block's own. The total rides on the header's right, so the block costs one
    line per character and one spacer, and every name wears its class color.

    Two halves. The recording half keeps a snapshot of every character's bags
    and bank on ns.db.global.inventory, so an alt's counts can show while it is
    logged out. Both are read while the character is playing -- the bags
    whenever they change, the bank whenever its window is open, which is the
    only time an add-on can read it -- and written down at logout. The
    reporting half adds the lines.

    Snapshots, then, for everything but the current character's bags, which are
    read live: an alt's counts are as of its last logout, and a bank's as of its
    last visit. A bank not seen yet, this character's or an alt's, counts as 0
    until it has been opened once.

    Only characters on the current realm are listed, and only those holding the
    item. Items cannot be mailed across realms, so a count there answers nothing
    the player can act on from here.

    Switched off from the Restocker panel or the General page's Features
    section (ns.db.global.inventoryReport): most auction add-ons put their own
    counts on the same tooltips, and two sets of numbers under one item is
    noise.
]]

-- Bank bag ids follow the player's own: 5..10 on Classic Era (six slots), 5..11 on TBC, as in Restocker-Bags.lua.
local BANK_BAG_COUNT = 7

-- The bank's contents can still be arriving when BANKFRAME_OPENED fires; one late look catches them.
local BANK_SETTLE_DELAY = 0.5

--[[
    How long after login the tooltips are hooked, in seconds. A tooltip's add-on
    lines appear in the order their hooks were installed, and this block belongs
    under the others', so it goes in after the add-ons that hook at load, at
    login, or a few staged seconds into it have all had their turn. The cost is
    that an item hovered in the first moments of a session shows no report.
    Best effort: an add-on that loads on demand later still lands below.
]]
local TOOLTIP_HOOK_DELAY = 5

-- Leading pad on each row under the header, matching the other add-ons' tooltip blocks (Water Dispenser's).
local ROW_INDENT = " "

--------------------------------------------------------------------------------
-- Saved Format
--------------------------------------------------------------------------------

--[[
    One saved line per character per place: "itemID:count" pairs, space
    separated and in itemID order. WoW's serializer spreads a table over a line
    per key, and a character's bank can hold a few hundred different items, so
    this keeps the file to one short line each -- the same habit the Restock
    List keeps for its rows (Restocker-Saved-Format.lua).
]]
local function Pack(counts)
	local itemIDs = {}
	for itemID in pairs(counts) do
		itemIDs[#itemIDs + 1] = itemID
	end
	table.sort(itemIDs)

	local parts = {}
	for index, itemID in ipairs(itemIDs) do
		parts[index] = itemID .. ":" .. counts[itemID]
	end
	return table.concat(parts, " ")
end

local function Unpack(text)
	local counts = {}
	for itemID, count in string.gmatch(text or "", "(%d+):(%d+)") do
		counts[tonumber(itemID)] = tonumber(count)
	end
	return counts
end

--------------------------------------------------------------------------------
-- Containers
--------------------------------------------------------------------------------

local function PlayerBagIDs()
	local bagIDs = {}
	for bagID = 0, NUM_BAG_SLOTS do
		bagIDs[#bagIDs + 1] = bagID
	end
	return bagIDs
end

--[[
    Forever's character bank is the tabs the player has bought (C_Bank); Era and
    TBC have BANK_CONTAINER and the bank bags. The seventh bank bag exists only
    on TBC, and asking Era about it just reads as empty.
]]
local function BankBagIDs()
	local tabIDs = ns.FetchPurchasedBankTabIDs()
	if tabIDs then
		return tabIDs
	end

	local bagIDs = { BANK_CONTAINER }
	for index = 1, BANK_BAG_COUNT do
		bagIDs[#bagIDs + 1] = NUM_BAG_SLOTS + index
	end
	return bagIDs
end

local function CountItems(bagIDs)
	local counts = {}
	for _, bagID in ipairs(bagIDs) do
		for slot = 1, C_Container.GetContainerNumSlots(bagID) or 0 do
			local info = C_Container.GetContainerItemInfo(bagID, slot)
			if info and info.itemID then
				counts[info.itemID] = (counts[info.itemID] or 0) + (info.stackCount or 1)
			end
		end
	end
	return counts
end

--------------------------------------------------------------------------------
-- Recording
--------------------------------------------------------------------------------

-- This character's saved entry, bound at login.
local record

--[[
    This character's bags as last read, which is what a logout saves. They are
    read while the character is playing -- on arriving in the world, and at
    every change after that -- and never at the logout itself: on the Forever
    beta a read made at PLAYER_LOGOUT found nothing, and every character's bags
    were saved as empty. nil until a read has been made, so a session that never
    saw its bags leaves the file's last snapshot alone.
]]
local bagCounts

-- A bag change arrived mid-fight; the read it asked for is owed when the fight ends.
local bagsChangedInCombat = false

--[[
    This character's bank: the last visit's snapshot at login, then each scan
    while the window is open. nil until the bank has been seen at all: the
    report counts that as 0, and a logout writes no bank line over it.
]]
local bankCounts

local bankIsOpen = false

--[[
    The other characters on this realm, unpacked once on first use. They are
    logged out, so nothing can change them during this session.
]]
local others

--[[
    The backpack has slots whenever the bags can be read at all, so a backpack
    with none is the client not answering, and the last read stands. Bags that
    are empty still have their slots, and are recorded as empty.
]]
local function ScanBags()
	if (C_Container.GetContainerNumSlots(BACKPACK_CONTAINER) or 0) > 0 then
		bagCounts = CountItems(PlayerBagIDs())
	end
end

local function ScanBank()
	bankCounts = CountItems(BankBagIDs())
end

-- Defined further down; forward-declared for the login call below.
local HookTooltips

--[[
    Called by Core's PLAYER_LOGIN branch, after the saved variables are loaded.
    Name, realm and class are refreshed every login. A renamed or transferred
    character gets a new key, so its old record, found by the GUID a rename
    keeps, is dropped here; a record saved before the GUID was stored goes only
    once its character logs in under the old key again. The name is the whole
    one, a Forever character's surname included (ns.GetPlayerFullName in
    Utilities).

    The class is read by the Restock List as well, which colors the characters
    on a list by it (Features/Restocker/Restocker-Saved-Lists.lua).
]]
function ns.InitializeInventoryReport()
	local inventory = ns.db.global.inventory
	local key = ns.GetCharacterKey()
	record = inventory[key] or {}
	inventory[key] = record

	local _, classToken = UnitClass("player")
	record.name = ns.GetPlayerFullName()
	record.realm = GetRealmName()
	record.class = classToken

	local guid = UnitGUID("player")
	if guid and not ns.IsSecretValue(guid) then
		record.guid = guid
		for otherKey, entry in pairs(inventory) do
			if otherKey ~= key and entry.guid == guid then
				inventory[otherKey] = nil
			end
		end
	end

	bagCounts = nil
	bagsChangedInCombat = false
	bankCounts = record.bank and Unpack(record.bank) or nil
	others = nil

	C_Timer.After(TOOLTIP_HOOK_DELAY, HookTooltips)
end

--[[
    Handlers keyed by event name, read by Core's dispatcher (Features/Core.lua)
    ahead of its combat guard: every one only reads containers or writes saved
    variables, and a logout mid-combat must still save this character's bags.
]]
ns.inventoryEventHandlers = {
	-- Login and every loading screen after it: the first read, for a session in which the bags never change.
	PLAYER_ENTERING_WORLD = function()
		ScanBags()
	end,
	BANKFRAME_OPENED = function()
		bankIsOpen = true
		ScanBank()
		C_Timer.After(BANK_SETTLE_DELAY, function()
			if bankIsOpen then
				ScanBank()
			end
		end)
	end,
	--[[
	    The client also fires this on loading screens with no bank open, which
	    is harmless here: the last scan simply stands.
	]]
	BANKFRAME_CLOSED = function()
		bankIsOpen = false
	end,
	--[[
	    Every change to the bags is read as it lands, so the snapshot is current
	    whenever the session ends. Not mid-fight: a hunter's every shot changes
	    the bags, so a fight's changes are read once, when it is over. A logout
	    taken mid-fight saves the bags as they were when it began.

	    While the bank is open, every move in or out of it -- the Restocker's own
	    or the player's -- lands here too, so the bank's snapshot ends the visit
	    current.
	]]
	BAG_UPDATE_DELAYED = function()
		if InCombatLockdown() then
			bagsChangedInCombat = true
		else
			ScanBags()
		end
		if bankIsOpen then
			ScanBank()
		end
	end,
	PLAYER_REGEN_ENABLED = function()
		if bagsChangedInCombat then
			bagsChangedInCombat = false
			ScanBags()
		end
	end,
	-- Writes down what was last read: nothing is asked of the client here (see bagCounts).
	PLAYER_LOGOUT = function()
		if not record then
			return
		end
		if bagCounts then
			record.bags = Pack(bagCounts)
		end
		if bankCounts then
			record.bank = Pack(bankCounts)
		end
	end,
}

--------------------------------------------------------------------------------
-- Report
--------------------------------------------------------------------------------

local function OtherCharacters()
	if others then
		return others
	end

	others = {}
	local realm = GetRealmName()
	for key, entry in pairs(ns.db.global.inventory) do
		if entry ~= record and entry.realm == realm and entry.name then
			others[#others + 1] = {
				key = key,
				name = entry.name,
				class = entry.class,
				bags = Unpack(entry.bags),
				bank = entry.bank and Unpack(entry.bank) or nil,
			}
		end
	end

	-- Alphabetical by name; the key only settles two characters that share one.
	table.sort(others, function(a, b)
		local left, right = a.name:lower(), b.name:lower()
		if left ~= right then
			return left < right
		end
		return a.key < b.key
	end)
	return others
end

-- The Keep amount of this item on the current Restock List, or nil when it is not on it or keeps none.
local function KeepAmount(itemID)
	local settings = ns.restockSettings
	local list = settings and settings.lists and settings.lists[settings.currentList]
	local row = list and list[itemID]
	if type(row) == "table" and (row.amount or 0) > 0 then
		return row.amount
	end
end

local TEXT_COLOR = GetColor("TEXT")

--[[
    The header line, built once: it says the same thing on every tooltip. It is
    the chat prints' branded shape (ns.PrintMessage): tooltips carry the
    add-on's short name.
]]
local REPORT_HEADER = GetColor("INFO")
	.. L["ADDON_SHORT_NAME"]
	.. "|r "
	.. GetColor("SEPARATOR")
	.. "//"
	.. "|r "
	.. TEXT_COLOR
	.. L["INVENTORY_REPORT_TITLE"]
	.. "|r"

--[[
    The right-hand values put their words (Total, Bag, Bank) in the header's
    separator gray and every count in white, so the numbers stand out. The gray
    picks up again after each count, for a locale that puts more words behind
    it.
]]
local LABEL_COLOR = GetColor("SEPARATOR")

local function Count(value)
	return TEXT_COLOR .. value .. "|r" .. LABEL_COLOR
end

-- Only the places holding some: "Bag 7, Bank 18", "Bag 7" or "Bank 18", and nil when both are 0.
local function Counts(bags, bank)
	if bags > 0 and bank > 0 then
		return format(L["INVENTORY_REPORT_COUNTS"], Count(bags), Count(bank))
	elseif bags > 0 then
		return format(L["INVENTORY_REPORT_BAG"], Count(bags))
	elseif bank > 0 then
		return format(L["INVENTORY_REPORT_BANK"], Count(bank))
	end
end

--[[
    A character's row: its name one space in and in its class color, its
    counts at the right edge. A character holding none (this one can lead the
    block that way) is the name alone.
]]
local function CharacterRow(name, class, bags, bank)
	local counts = Counts(bags, bank)
	return {
		ROW_INDENT .. (ns.GetClassColor(class) or TEXT_COLOR) .. name .. "|r",
		counts and (LABEL_COLOR .. counts .. "|r"),
	}
end

--[[
    The report's lines, ready to add, or nil when there is nothing to say: the
    report is off, or nobody on the realm holds the item and it is not on the
    Restock List either. An item on the list always reports, so a list item
    nobody holds says so rather than saying nothing.

    Each line is { left, right }. A line with both goes in as a double line, a
    label with its count at the tooltip's right edge; one with only a left is a
    plain line (a spacer).

    This character always leads, holding any or not, so the list reads top to
    bottom against the total; the others follow under a spacer, and only those
    holding some.

    Published for the tooltip hooks below and the headless test.
]]
function ns.GetInventoryReportLines(itemID)
	if not (record and ns.db and ns.db.global.inventoryReport) then
		return nil
	end

	local bags = C_Item.GetItemCount(itemID, false) or 0
	local bank = bankCounts and bankCounts[itemID] or 0
	local total = bags + bank

	local holders = {}
	for _, other in ipairs(OtherCharacters()) do
		local otherBags = other.bags[itemID] or 0
		local otherBank = other.bank and other.bank[itemID] or 0
		if otherBags + otherBank > 0 then
			holders[#holders + 1] = { character = other, bags = otherBags, bank = otherBank }
			total = total + otherBags + otherBank
		end
	end

	local keep = KeepAmount(itemID)
	if total == 0 and not keep then
		return nil
	end

	local lines = { { REPORT_HEADER, LABEL_COLOR .. format(L["INVENTORY_REPORT_TOTAL"], Count(total)) .. "|r" } }

	lines[#lines + 1] = CharacterRow(record.name, record.class, bags, bank)

	if #holders > 0 then
		lines[#lines + 1] = { " " }
		for _, holder in ipairs(holders) do
			lines[#lines + 1] = CharacterRow(holder.character.name, holder.character.class, holder.bags, holder.bank)
		end
	end

	return lines
end

--------------------------------------------------------------------------------
-- Tooltip Hooks
--------------------------------------------------------------------------------

--[[
    Which tooltips already carry a report for what they are showing. Era can
    fire OnTooltipSetItem more than once for one item (a recipe and the item it
    makes), and a second block under the first is the bug this prevents.
    Cleared with the tooltip's lines. Weak-keyed, though only the two tooltips
    below ever land in it.
]]
local reported = setmetatable({}, { __mode = "k" })

local function AddReport(tooltip, itemID)
	if not itemID or reported[tooltip] or ns.IsSecretValue(itemID) then
		return
	end
	if tooltip.IsForbidden and tooltip:IsForbidden() then
		return
	end

	local lines = ns.GetInventoryReportLines(itemID)
	if not lines then
		return
	end

	reported[tooltip] = true
	tooltip:AddLine(" ")
	for _, line in ipairs(lines) do
		if line[2] then
			tooltip:AddDoubleLine(line[1], line[2], 1, 1, 1, 1, 1, 1)
		else
			tooltip:AddLine(line[1], 1, 1, 1)
		end
	end
end

local function OnTooltipCleared(tooltip)
	reported[tooltip] = nil
end

local function ItemIDFromLink(link)
	return link and tonumber(link:match("item:(%d+)"))
end

-- A hook cannot be removed, so it is installed once however often login runs.
local tooltipsHooked = false

--[[
    Forever runs Retail's tooltip pipeline, where OnTooltipSetItem is gone and
    TooltipDataProcessor hands every item tooltip to a post-call; Era and TBC
    have no TooltipDataProcessor and still fire OnTooltipSetItem. Only the main
    tooltip and the clicked-link one are reported on: the comparison tooltips
    beside them would only repeat the same block.
]]
function HookTooltips()
	if tooltipsHooked then
		return
	end
	tooltipsHooked = true

	local tooltips = { GameTooltip, ItemRefTooltip }
	for _, tooltip in ipairs(tooltips) do
		tooltip:HookScript("OnTooltipCleared", OnTooltipCleared)
	end

	if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum.TooltipDataType then
		TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
			if tooltip == GameTooltip or tooltip == ItemRefTooltip then
				AddReport(tooltip, data and data.id)
			end
		end)
		return
	end

	local function OnTooltipSetItem(tooltip)
		local _, link = tooltip:GetItem()
		AddReport(tooltip, ItemIDFromLink(link))
	end
	for _, tooltip in ipairs(tooltips) do
		tooltip:HookScript("OnTooltipSetItem", OnTooltipSetItem)
	end
end
