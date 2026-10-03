local _, ns = ...
local GetColor = ns.GetColor
local L = ns.L

local LibDataBroker = LibStub("LibDataBroker-1.1")
local LibDBIcon = LibStub("LibDBIcon-1.0")

--------------------------------------------------------------------------------
-- Registration
--------------------------------------------------------------------------------

-- Called once at login, after ns.db exists, so LibDBIcon gets the saved button position.
function ns.RegisterMinimapIcon()
	if ns.dataBrokerObject and not ns.minimapIconRegistered then
		LibDBIcon:Register(ns.LOCALE_NAME, ns.dataBrokerObject, ns.db.global.minimap)
		ns.minimapIconRegistered = true

		-- On the Retail engine LibDBIcon leaves the square icon off-center in its ring.
		if ns.FLAVOR == "Camelot" or ns.FLAVOR == "Mainline" then
			LibDBIcon:SetButtonIcon(ns.LOCALE_NAME, nil, 20, "CENTER", 1, -0.35)
			local button = LibDBIcon:GetMinimapButton(ns.LOCALE_NAME)
			local mask = button:CreateMaskTexture()
			mask:SetTexture(130924, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE") -- Interface\CharacterFrame\TempPortraitAlphaMask
			mask:SetAllPoints(button.icon)
			button.icon:AddMaskTexture(mask)
		end
	end
end

--------------------------------------------------------------------------------
-- Minimap Icon Update
--------------------------------------------------------------------------------

local UpdateTooltip

function ns.UpdateMinimapIcon()
	if not ns.dataBrokerObject then
		return
	end

	local iconID = ns.bestFoodID or ns.MACRO_DEFAULT_ITEM_IDS["Food"]
	local newIcon = C_Item.GetItemIconByID(iconID) or "Interface\\Icons\\INV_Misc_Food_02"
	ns.dataBrokerObject.icon = newIcon

	local button = LibDBIcon:GetMinimapButton(ns.LOCALE_NAME)
	if button then
		if button.icon then
			button.icon:SetTexture(newIcon)
		end
		if GameTooltip:GetOwner() == button then
			UpdateTooltip(button)
		end
	end
end

--------------------------------------------------------------------------------
-- Visibility Toggle
--------------------------------------------------------------------------------

--[[
    Show or hide the minimap button. Like the other feature toggles, no argument
    flips the current state and a boolean sets it directly (options-panel path).
    State lives in ns.db.global.minimap.hide — the same field LibDBIcon reads at
    registration — so the choice persists across reloads with no extra wiring.
]]
function ns.ToggleMinimapButton(value)
	local show
	if value == nil then
		show = ns.db.global.minimap.hide
	else
		show = value
	end
	ns.db.global.minimap.hide = not show
	LibDBIcon:Refresh(ns.LOCALE_NAME, ns.db.global.minimap)
end

--------------------------------------------------------------------------------
-- Tooltip Blocks
--------------------------------------------------------------------------------

local KnowsAny = ns.KnowsAny

-- The most rows the Restocker Report or the Ignore List lists, one item each; a longer list shows only its count.
local LIST_MAX_ROWS = 8

--[[
    A switch's state. One that is on while its when-to-use choice does not hold
    (When in a Raid, and the player is solo) shows the choice instead of
    Enabled: the Food macro is not acting on it, and the label says what it is
    waiting for. ns.MODE_VALUES is read here rather than aliased at load,
    because Options/Options-Utilities.lua builds it after this file.
]]
local function SwitchState(enabled, mode)
	if not enabled then
		return GetColor("OFF") .. L["MINIMAP_DISABLED"] .. "|r"
	end
	if ns.IsModeActive(mode) then
		return GetColor("ON") .. L["MINIMAP_ENABLED"] .. "|r"
	end
	return GetColor("SEPARATOR") .. ns.MODE_VALUES[mode] .. "|r"
end

-- A feature block: name and state, one description, click and action. A block that only opens something has no state.
local function AddFeatureBlock(tooltip, name, state, description, keybind, action)
	tooltip:AddLine(" ")
	if state then
		tooltip:AddDoubleLine(GetColor("TITLE") .. name .. "|r", state)
	else
		tooltip:AddLine(GetColor("TITLE") .. name .. "|r")
	end
	tooltip:AddLine(GetColor("BODY") .. description .. "|r", 1, 1, 1, true)
	tooltip:AddDoubleLine(GetColor("INFO") .. keybind .. "|r", GetColor("INFO") .. action .. "|r")
end

--[[
    A title with its item right-aligned on the row beneath. The item gets a row
    of its own so a long name never adds its width to the title's, and it is
    its icon and its name in the link's own quality color, without the link's
    brackets (ns.UnbracketItemLink), like every item this tooltip names. With nothing resolved -- or an item
    cache still cold -- the "no suitable item" sentence takes that row on a
    wrapping line, since the right column never wraps. Returns whether an item
    was shown.
]]
local function AddItemBlock(tooltip, title, itemID, itemLink, missingLabel)
	tooltip:AddLine(GetColor("TITLE") .. title .. "|r")
	if itemID and itemLink then
		tooltip:AddDoubleLine(
			" ",
			format("|T%s:14:14|t %s", C_Item.GetItemIconByID(itemID), ns.UnbracketItemLink(itemLink))
		)
		return true
	end
	tooltip:AddLine(GetColor("BODY") .. format(L["MESSAGE_NO_ITEM"], missingLabel) .. "|r", 1, 1, 1, true)
	return false
end

--[[
    Restocker Report -- the orders themselves while they fit, only their count
    past LIST_MAX_ROWS: spelling out every shortfall made the tooltip taller
    than the screen on a real Restock List, and at that length the only
    question this block answers is "do I need to shop?".

    A row is the item and have/wanted, the ratio the verbose reminder prints.
    ns.GetItemLabel names the item even while the cache is cold; a
    name-only row has no ID to look an icon up by, so it shows the question
    mark the Restock List window uses.

    Read straight off ns.BuildGroceryList so the tooltip and the entering-town
    reminder can never disagree, and rendered even with nothing to buy: "fully
    stocked" is an answer, a missing block is not. That answer is the green
    congratulation on its own, in place of the header row -- a "Fully Stocked"
    value above it would only say it twice. A list with no rows at all is not
    stocked, so it says so under the header instead.
]]
local function AddRestockerReport(tooltip)
	tooltip:AddLine(" ")
	if ns.IsRestockListEmpty() then
		tooltip:AddLine(GetColor("TITLE") .. L["MINIMAP_RESTOCKER_REPORT"] .. "|r")
		tooltip:AddLine(GetColor("BODY") .. L["MINIMAP_RESTOCKER_EMPTY"] .. "|r", 1, 1, 1, true)
		return
	end

	local groceries = ns.BuildGroceryList()
	if #groceries == 0 then
		tooltip:AddLine(GetColor("ON") .. L["MINIMAP_RESTOCKER_STOCKED"] .. "|r", 1, 1, 1, true)
	elseif #groceries <= LIST_MAX_ROWS then
		tooltip:AddLine(GetColor("TITLE") .. L["MINIMAP_RESTOCKER_REPORT"] .. "|r")
		for _, entry in ipairs(groceries) do
			local icon = entry.itemID and C_Item.GetItemIconByID(entry.itemID)
				or "Interface\\ICONS\\INV_Misc_QuestionMark"
			tooltip:AddDoubleLine(
				format("|T%s:14:14|t %s", icon, ns.GetItemLabel(entry.itemID, entry.itemName)),
				GetColor("BODY") .. format(L["MINIMAP_RESTOCKER_ITEM_COUNT"], entry.have, entry.wanted) .. "|r"
			)
		end
	else
		tooltip:AddDoubleLine(
			GetColor("TITLE") .. L["MINIMAP_RESTOCKER_REPORT"] .. "|r",
			GetColor("BODY") .. format(L["MINIMAP_RESTOCKER_NEEDED"], #groceries) .. "|r"
		)
	end
end

--[[
    Ignore List -- this character's own list, the one Right-Click adds to and
    Middle-Click clears; the Global list lives in the Ignore List panel. It is
    the one block a player can grow without limit, so past LIST_MAX_ROWS it
    shows only its count, and it sits last before Options so that nothing above
    it moves as it grows.
]]
local function AddIgnoreList(tooltip)
	local ignoreList = ns.GetIgnoreList()
	if not ignoreList or next(ignoreList) == nil then
		return
	end

	local count = 0
	for _ in pairs(ignoreList) do
		count = count + 1
	end

	tooltip:AddLine(" ")
	if count > LIST_MAX_ROWS then
		tooltip:AddDoubleLine(
			GetColor("TITLE") .. L["MINIMAP_IGNORE_LIST"] .. "|r",
			GetColor("BODY") .. format(L["MINIMAP_IGNORE_COUNT"], count) .. "|r"
		)
	else
		tooltip:AddLine(GetColor("TITLE") .. L["MINIMAP_IGNORE_LIST"] .. "|r")

		local sortedIgnoreList = {}
		for itemID in pairs(ignoreList) do
			local name, _, quality, _, _, _, _, _, _, texture = C_Item.GetItemInfo(itemID)
			if name then
				tinsert(sortedIgnoreList, { id = itemID, name = name, quality = quality, texture = texture })
			else
				tinsert(sortedIgnoreList, { id = itemID, name = "ZZZ_Unknown", quality = 0, texture = nil })
			end
		end

		table.sort(sortedIgnoreList, function(a, b)
			return a.name < b.name
		end)

		for _, item in ipairs(sortedIgnoreList) do
			if item.texture then
				local _, _, _, colorHex = C_Item.GetItemQualityColor(item.quality)
				tooltip:AddLine(format("|T%s:14:14|t |c%s%s|r", item.texture, colorHex, item.name))
			else
				tooltip:AddLine(GetColor("MUTED") .. format(L["LOADING_ITEM"], item.id) .. "|r")
			end
		end
	end

	tooltip:AddDoubleLine(
		GetColor("INFO") .. L["MINIMAP_MIDDLE_CLICK"] .. "|r",
		GetColor("INFO") .. L["MENU_CLEAR_IGNORE"] .. "|r"
	)
end

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    One macro's notes: its name, a row per click (the click on the left, what
    it does on the right), then an optional closing line. HELP rather than
    INFO: these are clicks on a macro, and blue marks a click on the mini-map
    button.
]]
local function AddMacroNotes(tooltip, macroName, rows, closingNote)
	tooltip:AddLine(GetColor("TITLE") .. macroName .. "|r")
	for _, row in ipairs(rows) do
		tooltip:AddDoubleLine(GetColor("HELP") .. row[1] .. "|r", GetColor("HELP") .. row[2] .. "|r")
	end
	if closingNote then
		tooltip:AddLine(GetColor("HELP") .. closingNote .. "|r", 1, 1, 1, true)
	end
end

-- The client's own name for the first spell on the list the player knows; nil when they know none.
local function KnownSpellName(spellList)
	for _, data in ipairs(spellList) do
		if ns.IsSpellKnown(data[1]) or ns.IsPlayerSpell(data[1]) then
			return C_Spell.GetSpellName(data[1])
		end
	end
	return nil
end

--[[
    Each builder returns its class's blocks in order, or nothing while the
    character has none: an item block ({ title, itemID, itemLink,
    missingLabel }) for each item the class's own macro will use, then a notes
    block ({ title, rows, note }) per macro. A row is listed only for a spell
    the character knows.
]]
local function HunterNotes()
	if not ns.feedPetSpellName then
		return nil
	end

	local rows = { { L["MINIMAP_LEFT_CLICK"], L["NOTE_PET_CALL_FEED_REVIVE"] } }
	if ns.mendPetSpellName then
		tinsert(rows, { L["NOTE_PET_MEND_CLICK"], ns.mendPetSpellName })
	end
	tinsert(rows, { L["NOTE_HOLD_SHIFT"], L["NOTE_PET_FORCE_REVIVE"] })
	tinsert(rows, { L["NOTE_HOLD_CONTROL"], L["NOTE_PET_DISMISS"] })

	return {
		{
			title = L["MINIMAP_BEST_PET_FOOD"],
			itemID = ns.bestPetFoodID,
			itemLink = ns.bestPetFoodLink,
			missingLabel = L["LABEL_PET_FOOD"],
		},
		{ title = L["NOTE_MACRO_FEED_PET"], rows = rows },
	}
end

local function MageNotes()
	local spells = ns.CONJURE_SPELLS
	local knowsFoodOrWater = KnowsAny(spells.MageCreateFood) or KnowsAny(spells.MageCreateWater)
	local ritualName = KnownSpellName(spells.MageCreateTable)
	local blocks = {}

	if knowsFoodOrWater or ritualName then
		local rows = {}
		if knowsFoodOrWater then
			tinsert(rows, { L["MINIMAP_RIGHT_CLICK"], L["NOTE_CONJURE"] })
		end
		if ritualName then
			tinsert(rows, { L["MINIMAP_MIDDLE_CLICK"], ritualName })
		end
		tinsert(blocks, {
			title = L["NOTE_MACRO_FOOD_WATER"],
			rows = rows,
			note = knowsFoodOrWater and L["NOTE_MAGE_TARGET_LEVEL"] or nil,
		})
	end

	if KnowsAny(spells.MageCreateManaGem) then
		tinsert(blocks, {
			title = L["NOTE_MACRO_MANA_GEM"],
			rows = {
				{ L["MINIMAP_RIGHT_CLICK"], L["NOTE_CONJURE"] },
				{ L["NOTE_RIGHT_CLICK_AGAIN"], L["NOTE_LOWER_RANK_BACKUP"] },
			},
		})
	end

	return blocks
end

local function WarlockNotes()
	local spells = ns.CONJURE_SPELLS
	local knowsHealthstone = KnowsAny(spells.WarlockCreateHealthstone)
	local ritualName = KnownSpellName(spells.WarlockCreateSoulwell)
	local blocks = {}

	if knowsHealthstone or ritualName then
		local rows = {}
		if knowsHealthstone then
			tinsert(rows, { L["MINIMAP_RIGHT_CLICK"], L["NOTE_CREATE"] })
			tinsert(rows, { L["NOTE_RIGHT_CLICK_AGAIN"], L["NOTE_LOWER_RANK_BACKUP"] })
		end
		if ritualName then
			tinsert(rows, { L["MINIMAP_MIDDLE_CLICK"], ritualName })
		end
		tinsert(blocks, {
			title = L["NOTE_MACRO_HEALTHSTONE"],
			rows = rows,
			note = knowsHealthstone and L["NOTE_WARLOCK_TARGET_LEVEL"] or nil,
		})
	end

	if KnowsAny(spells.WarlockCreateSoulstone) then
		tinsert(blocks, {
			title = L["NOTE_MACRO_SOULSTONE"],
			rows = { { L["MINIMAP_RIGHT_CLICK"], L["NOTE_CREATE"] } },
		})
	end

	return blocks
end

local function RogueNotes()
	if not (ns.IsSpellKnown(ns.POISONS_SPELL_ID) or ns.IsPlayerSpell(ns.POISONS_SPELL_ID)) then
		return nil
	end

	local mainID, mainLink = ns.GetBestPoisonForHand("main")
	local offID, offLink = ns.GetBestPoisonForHand("off")

	return {
		{
			title = L["MINIMAP_MAIN_HAND_POISON"],
			itemID = mainID,
			itemLink = mainLink,
			missingLabel = L["LABEL_POISONS"],
		},
		{
			title = L["MINIMAP_OFF_HAND_POISON"],
			itemID = offID,
			itemLink = offLink,
			missingLabel = L["LABEL_POISONS"],
		},
		{
			title = L["NOTE_MACRO_POISONS"],
			rows = {
				{ L["MINIMAP_LEFT_CLICK"], SECONDARYHANDSLOT },
				{ L["MINIMAP_RIGHT_CLICK"], MAINHANDSLOT },
				{ L["MINIMAP_MIDDLE_CLICK"], L["NOTE_POISONS_WINDOW"] },
			},
			note = L["NOTE_POISONS_REPLACED"],
		},
	}
end

local CLASS_NOTES = {
	HUNTER = HunterNotes,
	MAGE = MageNotes,
	ROGUE = RogueNotes,
	WARLOCK = WarlockNotes,
}

--[[
    The class-colored header, the client's name for the player's class, then
    the class's blocks with a blank line between
    them; the first follows the header directly. The blocks are collected before
    anything is drawn, so a gated-out block leaves no doubled gap, and a
    character with none gets no header.
]]
local function AddClassNotes(tooltip)
	local className, playerClass = UnitClass("player")
	local buildNotes = CLASS_NOTES[playerClass]
	local blocks = buildNotes and buildNotes()
	if not blocks or #blocks == 0 then
		return
	end

	tooltip:AddLine(" ")
	tooltip:AddLine((ns.GetClassColor(playerClass) or GetColor("TEXT")) .. className .. "|r")
	for index, block in ipairs(blocks) do
		if index > 1 then
			tooltip:AddLine(" ")
		end
		if block.rows then
			AddMacroNotes(tooltip, block.title, block.rows, block.note)
		else
			AddItemBlock(tooltip, block.title, block.itemID, block.itemLink, block.missingLabel)
		end
	end
end

--------------------------------------------------------------------------------
-- Tooltip
--------------------------------------------------------------------------------

UpdateTooltip = function(anchor)
	if not (ns.db and ns.db.profile) then
		return
	end
	local settings = ns.db.profile
	local tooltip = GameTooltip

	tooltip:SetOwner(anchor, "ANCHOR_BOTTOMLEFT")
	tooltip:ClearLines()

	tooltip:AddDoubleLine(GetColor("TITLE") .. L["ADDON_TITLE"] .. "|r", GetColor("MUTED") .. ns.Version .. "|r")
	tooltip:AddLine(" ")
	tooltip:AddLine(" ")

	-- Current Food leads, since the button's icon shows it. The Ignore hint needs an item to ignore.
	if AddItemBlock(tooltip, L["MINIMAP_BEST_FOOD"], ns.bestFoodID, ns.bestFoodLink, L["LABEL_FOOD"]) then
		tooltip:AddDoubleLine(
			GetColor("INFO") .. L["MINIMAP_RIGHT_CLICK"] .. "|r",
			GetColor("INFO") .. L["MENU_IGNORE"] .. "|r"
		)
	end

	AddFeatureBlock(
		tooltip,
		L["FEATURE_BUFF_FOOD"],
		SwitchState(settings.useBuffFood, settings.buffFoodMode),
		string.format(L["MENU_BUFF_FOOD_DESCRIPTION_FORMAT"], ns.GetWellFedName()),
		L["MINIMAP_LEFT_CLICK"],
		L["MINIMAP_TOGGLE"]
	)
	AddFeatureBlock(
		tooltip,
		L["FEATURE_SCROLL_BUFFS"],
		SwitchState(settings.useScrolls, settings.scrollsMode),
		L["MENU_SCROLL_BUFFS_DESCRIPTION"],
		L["MINIMAP_SHIFT_LEFT"],
		L["MINIMAP_TOGGLE"]
	)
	AddFeatureBlock(
		tooltip,
		L["MENU_RESTOCKER"],
		nil,
		L["MENU_RESTOCKER_DESCRIPTION"],
		L["MENU_RESTOCKER_KEYBIND"],
		L["MINIMAP_OPEN"]
	)

	AddClassNotes(tooltip)
	AddRestockerReport(tooltip)
	AddIgnoreList(tooltip)

	-- Options: always the last block, with no hint line below it.
	tooltip:AddLine(" ")
	tooltip:AddLine(GetColor("TITLE") .. L["MENU_OPTIONS"] .. "|r")
	tooltip:AddLine(GetColor("INFO") .. L["MENU_OPTIONS_KEYBIND"] .. "|r")

	tooltip:Show()
end

--------------------------------------------------------------------------------
-- LDB Data Object
--------------------------------------------------------------------------------

ns.dataBrokerObject = LibDataBroker:NewDataObject(ns.LOCALE_NAME, {
	type = "data source",
	text = L["ADDON_TITLE"],
	icon = "Interface\\Icons\\INV_Misc_Food_02",
	OnClick = function(_, button)
		-- Shift + Middle-Click always opens the options panel; checked first (matches every Gogo1951 add-on).
		if button == "MiddleButton" and IsShiftKeyDown() then
			ns.OpenOptionsPanel()
			return
		end
		-- Shift + Right-Click toggles the Restocker window, the same as a bare /crs.
		if button == "RightButton" and IsShiftKeyDown() then
			ns.ToggleRestockWindow()
		elseif button == "RightButton" and ns.bestFoodID then
			ns.IgnoreItem(ns.bestFoodID)
		elseif button == "LeftButton" and IsShiftKeyDown() then
			ns.ToggleMacroSetting("useScrolls")
		elseif button == "LeftButton" then
			ns.ToggleMacroSetting("useBuffFood")
		elseif button == "MiddleButton" then
			ns.ClearIgnoreList()
		end

		ns.UpdateMinimapIcon()
	end,
	OnEnter = function(self)
		UpdateTooltip(self)
	end,
	OnLeave = function()
		GameTooltip:Hide()
	end,
})
