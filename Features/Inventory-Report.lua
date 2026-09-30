local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--[[
    Inventory Report -- the block item tooltips gain under the game's own lines:
    how many of the item this character carries (against the Restock List's Keep
    amount when the item is on it), how many sit in its bank, one line per other
    character holding some, and the total across them all.

        Connoisseur & Restocker // Inventory Report
         Bags                                  7/10
         Bank                                    18

         Coinpurse                               30
         Thornhoof                               27

         Total                                   82

    The shape is the house one for a branded block: the add-on's name, the
    separator and a title in the chat prints' own colors (Announcements.lua),
    then label-and-value pairs as double lines, each a space in from the header
    so the rows read as the block's own.

    Two halves. The recording half keeps a snapshot of every character's bags
    and bank on ns.db.global.inventory, so an alt's counts can show while it is
    logged out. Both are read while the character is playing -- the bags
    whenever they change, the bank whenever its window is open, which is the
    only time an add-on can read it -- and written down at logout. The
    reporting half adds the lines.

    Snapshots, then, for everything but the current character's bags, which are
    read live: an alt's counts are as of its last logout, and a bank's as of its
    last visit. That is why this character's bank reads Unknown until the bank
    has been opened once.

    Only characters on the current realm are listed, and only those holding the
    item. Items cannot be mailed across realms, so a count there answers nothing
    the player can act on from here.

    Switched off from the Restocker panel (ns.db.global.inventoryReport): most
    auction add-ons put their own counts on the same tooltips, and two sets of
    numbers under one item is noise.
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
    while the window is open. nil until the bank has been seen at all, which the
    report says rather than printing a 0 it cannot vouch for.
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
    Name, realm and class are refreshed every login, so a renamed or transferred
    character reports under what it is now. The name is the whole one, a Forever
    character's surname included (ns.GetPlayerFullName in Utilities).

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
	PLAYER_ENTERING_WORLD = ScanBags,
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

--[[
    The report's lines, ready to add, or nil when there is nothing to say: the
    report is off, or nobody on the realm holds the item and it is not on the
    Restock List either. An item on the list always reports, because "Bags
    0/20" is exactly what a list item's tooltip should be able to say.

    Each line is { left, right }. A line with both goes in as a double line, a
    label with its count at the tooltip's right edge; one with only a left is a
    plain line (the header, a spacer).

    A character's line carries one number, its bags and bank together: how much
    that character holds is the question, and where it keeps it only matters
    once you are on it.

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
		local held = (other.bags[itemID] or 0) + (other.bank and other.bank[itemID] or 0)
		if held > 0 then
			holders[#holders + 1] = { character = other, held = held }
			total = total + held
		end
	end

	local keep = KeepAmount(itemID)
	if total == 0 and not keep then
		return nil
	end

	local text = GetColor("TEXT")
	local function Pair(label, value)
		return { ROW_INDENT .. text .. label .. "|r", text .. value .. "|r" }
	end

	--[[
	    The chat prints' branded shape (ns.PrintMessage), with the add-on's full
	    name: both halves are proper nouns that stay as written in every locale,
	    so the name is composed from their keys, joined the way each locale's
	    INVENTORY_REPORT_BRAND joins them.
	]]
	local lines = {
		{
			GetColor("INFO")
				.. string.format(L["INVENTORY_REPORT_BRAND"], L["ADDON_TITLE"], L["TAB_RESTOCKER"])
				.. "|r "
				.. GetColor("SEPARATOR")
				.. "//"
				.. "|r "
				.. text
				.. L["INVENTORY_REPORT_TITLE"]
				.. "|r",
		},
	}

	-- Against the Keep amount for a list item, the ratio the Restocker Report prints.
	lines[#lines + 1] =
		Pair(L["INVENTORY_REPORT_BAGS"], keep and format(L["MINIMAP_RESTOCKER_ITEM_COUNT"], bags, keep) or bags)

	if bankCounts then
		lines[#lines + 1] = Pair(L["INVENTORY_REPORT_BANK"], bank)
	else
		-- Muted, and a word rather than a 0 the add-on cannot vouch for.
		lines[#lines + 1] = {
			ROW_INDENT .. text .. L["INVENTORY_REPORT_BANK"] .. "|r",
			GetColor("MUTED") .. L["INVENTORY_REPORT_BANK_UNKNOWN"] .. "|r",
		}
	end

	if #holders > 0 then
		lines[#lines + 1] = { " " }
		for _, holder in ipairs(holders) do
			lines[#lines + 1] = {
				ROW_INDENT .. (ns.GetClassColor(holder.character.class) or text) .. holder.character.name .. "|r",
				text .. holder.held .. "|r",
			}
		end
	end

	lines[#lines + 1] = { " " }
	lines[#lines + 1] = Pair(L["INVENTORY_REPORT_TOTAL"], total)

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
