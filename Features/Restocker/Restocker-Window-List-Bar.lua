local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor
local AceGUI = LibStub("AceGUI-3.0")

--------------------------------------------------------------------------------
-- List Bar
--------------------------------------------------------------------------------

--[[
    List  [selector.........v]  Used by Mossbark, Thornhoof ... [Manage Lists]

    The window's top row: which Restock List this character is on, who else is
    on it, and the things done to a whole list. It leads the window because
    everything under it -- the filter, the rows, the orders counted at the
    bottom -- belongs to the list it names.

    "Used by" is the line that makes a shared list visible. Lists are shared on
    purpose (one Druid list for every Druid), and sharing is silent everywhere
    else: nothing on a row says an edit here lands on another character too.

    New, Copy, Rename and Delete sit behind one Manage Lists button rather than
    out as four. They are rare, they act on the whole list, and Delete in
    particular should not be one stray click from the controls used every
    visit.

    The list selector is an InputBoxTemplate field, not an AceGUI Dropdown.
    Every other control in this window is a Blizzard template, so the one
    AceGUI widget read as foreign -- and skins that restyle AceGUI globally
    (ElvUI ships one) restyle it and nothing around it, which made the mismatch
    worse and moved the geometry its neighbours were positioned against.

    It opens an AceGUI Dropdown-Pullout on click, the same way the reputation
    column in Restocker-Window-Rows.lua does: Blizzard's UIDropDownMenu drives
    shared global frames its own secure code uses and leaves taint behind, so
    the pullout stays. Manage Lists opens one the same way.
]]
local BAR_HEIGHT = 22
local BAR_GAP = 8 -- clear space between the inset's top edge and the bar
local BAR_INSET_LEFT = 16 -- the control row's own insets, so the two rows share their edges
local BAR_INSET_RIGHT = 12
local BAR_RULE_DROP = 5 -- the hairline under the bar, halfway to the control row
local LIST_SELECTOR_WIDTH = 190 -- holds a full Name-Realm, which an old list can be named
local SELECTOR_ARROW_SIZE = 18
local BAR_ITEM_GAP = 12
local BUTTON_GAP = 4
local LIST_MENU_WIDTH = 300 -- a list's name with its characters beside it
local MANAGE_MENU_WIDTH = 230

--[[
    What the bar takes off the top of the inset, its clear space included.
    Restocker-Window.lua starts the control row under it.
]]
ns.RESTOCK_LIST_BAR_SPAN = BAR_GAP + BAR_HEIGHT

local GOLD = ns.COLORS_RGB.TITLE

--------------------------------------------------------------------------------
-- Used By
--------------------------------------------------------------------------------

--[[
    A list's characters as one run of text, each name in its class color, or
    nil when no character is on it. A character is its class color wherever the
    add-on names one (the Inventory Report does the same), which is what lets a
    list's line be read at a glance.

    plain is the color the run sits in. It draws the separators, and any name
    whose class the add-on has not recorded yet (ns.GetRestockListUsers), so
    each caller says what an uncolored name looks like beside its own text.
]]
local function JoinUsers(users, plain)
	if #users == 0 then
		return nil
	end
	local names = {}
	for index, user in ipairs(users) do
		names[index] = (ns.GetClassColor(user.class) or plain) .. user.name .. "|r"
	end
	return table.concat(names, plain .. L["LIST_SEPARATOR"] .. "|r")
end

--[[
    The bar's "Used by" line for the list in use. Never empty: the window only
    shows the list this character is on, so the character is always among them.
]]
local function UsedByText(listName)
	local names = JoinUsers(ns.GetRestockListUsers(listName), GetColor("TEXT"))
	-- Muted is opened again behind the names, for whatever a locale's wording puts after them.
	return GetColor("MUTED") .. string.format(L["RESTOCKER_USED_BY"], names .. GetColor("MUTED")) .. "|r"
end

--------------------------------------------------------------------------------
-- Menus
--------------------------------------------------------------------------------

--[[
    Two pullouts, each built on first use and reused, which is how AceGUI's own
    Dropdown treats its pullout. Creating and releasing one per open would leak
    here: an Execute item closes its own pullout from inside its OnClick, so a
    release driven off OnClose would free the very item whose handler is still
    running. Reuse sidesteps that entirely -- items are cleared at open, not at
    close.

    Both live as long as the window, which is built once per session and only
    ever hidden.
]]
local listPullout
local listPulloutOpen = false
local managePullout
local managePulloutOpen = false

local function CloseListMenus()
	if listPullout and listPulloutOpen then
		listPulloutOpen = false
		listPullout:Close()
	end
	if managePullout and managePulloutOpen then
		managePulloutOpen = false
		managePullout:Close()
	end
end

ns.CloseRestockListMenus = CloseListMenus

--[[
    The selector's menu: every saved list with the characters on it, then a
    rule, then New List.

    Rebuilt on every open rather than cached, so a rename or a delete needs
    nothing kept in sync -- the next open reads the lists as they now are.

    The characters ride beside each name because they are what a list's name
    leaves out: "Druid" and "Druid (2)" say nothing about whose each one is,
    and switching onto a list another character uses means editing theirs.
    Each is in its class color, and muted until its class is known, so a name
    never reads as part of the list's own, which is white.
]]
local function OpenListPullout(anchor)
	local settings = ns.restockSettings

	if not listPullout then
		listPullout = AceGUI:Create("Dropdown-Pullout")
		listPullout:SetCallback("OnClose", function()
			listPulloutOpen = false
		end)
	end
	listPullout:Clear()

	-- In the shared A-to-Z order, whose first entry is also where a delete lands (ns.GetRestockListAfterDelete).
	for _, name in ipairs(ns.GetRestockListNames()) do
		local entry = AceGUI:Create("Dropdown-Item-Toggle")
		local users = JoinUsers(ns.GetRestockListUsers(name), GetColor("MUTED"))
		entry:SetText(users and (name .. "  " .. users) or name)
		entry:SetValue(name == settings.currentList)
		entry:SetCallback("OnValueChanged", function()
			-- A toggle item does not close its own pullout, unlike an execute item.
			CloseListMenus()
			-- The list already in use only closes the menu: a switch would clear New and rerun the restock.
			if name ~= ns.restockSettings.currentList then
				ns.SwitchRestockList(name)
			end
		end)
		listPullout:AddItem(entry)
	end

	--[[
	    A rule between the lists and the action under them. Inert by construction:
	    AceGUI's ItemBase gives every item only OnEnter and OnLeave, and Separator
	    is the one item type that never adds an OnClick, so the line cannot be
	    picked and needs no handler of its own.
	]]
	listPullout:AddItem(AceGUI:Create("Dropdown-Item-Separator"))

	--[[
	    New List is an Execute, not a Toggle: it performs an action rather than
	    selecting a value, so it draws no tick beside it and closes the menu itself.
	]]
	local newList = AceGUI:Create("Dropdown-Item-Execute")
	newList:SetText(L["RESTOCKER_NEW_PROFILE"])
	newList:SetCallback("OnClick", function()
		ns.CreateRestockList()
	end)
	listPullout:AddItem(newList)

	listPulloutOpen = true
	listPullout:SetWidth(LIST_MENU_WIDTH)
	listPullout:Open("TOPLEFT", anchor, "BOTTOMLEFT", 0, 0)
end

-- The selector and its arrow open the menu, and close it again when it is already open.
local function ToggleListPullout(anchor)
	if listPulloutOpen then
		CloseListMenus()
		return
	end
	-- One menu at a time: none of them closes on a click elsewhere, so each open clears the rest.
	ns.CloseRestockMenus()
	OpenListPullout(anchor)
end

--------------------------------------------------------------------------------
-- Delete
--------------------------------------------------------------------------------

--[[
    Confirmation for the Manage Lists menu's Delete. The whole message is composed at show
    time and handed in as text_arg1, because how much it has to say depends on
    the list: who else is on it, and the list this character lands on
    afterwards. StaticPopup_Show's fourth argument carries the list's name
    through as the dialog's data, and OnAccept deletes THAT name rather than
    re-reading currentList.

    Load-bearing: the dialog does not lock the window behind it, so a list
    switched in the selector while the confirm is open would otherwise redirect
    the delete onto a list the player was never asked about -- and a Restock
    List has no undo. ns.DeleteRestockList ignores a nil or already-deleted
    name, and moves the character only when the list deleted is the one in use.
]]
-- luacheck: globals StaticPopupDialogs
StaticPopupDialogs["CONNOISSEUR_RESTOCKER_DELETE_LIST"] = {
	text = "%s",
	button1 = YES,
	button2 = NO,
	OnAccept = function(_self, data)
		ns.DeleteRestockList(data)
		ns.UpdateRestockList()
	end,
	timeout = 0,
	whileDead = true,
	hideOnEscape = true,
	preferredIndex = 3,
}

--[[
    What the confirm says, a paragraph to a fact: the question, the list's name
    in gold, what happens next, and that it is final.

    "What happens next" is the part a delete used to keep to itself. Every other
    character pointed at the list starts its next login on an empty list of the
    same name (ns.InitCharacterRestockList recreates a missing one), so they are
    named here while the player can still say no. This character's own landing
    place is named with them: the top list, which may be one another character
    uses and so is worth seeing before agreeing, or -- when this is the last
    list -- a new, empty one.
]]
local function DeleteConfirmText(listName)
	local consequences = {}
	local others = ns.GetRestockListUsers(listName, true)
	if #others > 0 then
		local key = (#others == 1) and "RESTOCKER_DELETE_LIST_SHARED_ONE" or "RESTOCKER_DELETE_LIST_SHARED_MANY"
		consequences[#consequences + 1] = string.format(L[key], JoinUsers(others, GetColor("TEXT")))
	end
	local landing = ns.GetRestockListAfterDelete(listName)
	if landing then
		consequences[#consequences + 1] =
			string.format(L["RESTOCKER_DELETE_LIST_SWITCH"], GetColor("TITLE") .. landing .. "|r")
	else
		consequences[#consequences + 1] = L["RESTOCKER_DELETE_LIST_LAST"]
	end

	return table.concat({
		L["RESTOCKER_DELETE_LIST_QUESTION"],
		GetColor("TITLE") .. listName .. "|r",
		table.concat(consequences, " "),
		L["RESTOCKER_DELETE_LIST_FINAL"],
	}, "|n|n")
end

local function ConfirmDeleteCurrentList()
	local listName = ns.restockSettings.currentList
	if not listName then
		return
	end
	StaticPopup_Show("CONNOISSEUR_RESTOCKER_DELETE_LIST", DeleteConfirmText(listName), nil, listName)
end

--------------------------------------------------------------------------------
-- Manage Lists Menu
--------------------------------------------------------------------------------

--[[
    Every entry is an Execute: each performs an action and closes the menu.
    Delete sits under a rule of its own, the way a destructive entry does in
    the game's own menus.
]]
local MANAGE_ENTRIES = {
	{
		label = "RESTOCKER_NEW_PROFILE",
		run = function()
			ns.CreateRestockList()
		end,
	},
	{
		label = "RESTOCKER_COPY_PROFILE_TOOLTIP",
		run = function()
			ns.CloneCurrentRestockList()
		end,
	},
	{
		label = "RESTOCKER_RENAME_PROFILE",
		run = function()
			ns.BeginRestockListRename()
		end,
	},
	{ isRule = true },
	{ label = "RESTOCKER_DELETE_PROFILE_TOOLTIP", run = ConfirmDeleteCurrentList },
}

local function OpenManagePullout(anchor)
	if not managePullout then
		managePullout = AceGUI:Create("Dropdown-Pullout")
		managePullout:SetCallback("OnClose", function()
			managePulloutOpen = false
		end)
	end
	managePullout:Clear()

	for _, entry in ipairs(MANAGE_ENTRIES) do
		if entry.isRule then
			managePullout:AddItem(AceGUI:Create("Dropdown-Item-Separator"))
		else
			local item = AceGUI:Create("Dropdown-Item-Execute")
			item:SetText(L[entry.label])
			item:SetCallback("OnClick", entry.run)
			managePullout:AddItem(item)
		end
	end

	managePulloutOpen = true
	managePullout:SetWidth(MANAGE_MENU_WIDTH)
	-- Hung from the button's right edge, so the menu opens inward instead of off the window.
	managePullout:Open("TOPRIGHT", anchor, "BOTTOMRIGHT", 0, 0)
end

local function ToggleManagePullout(anchor)
	if managePulloutOpen then
		CloseListMenus()
		return
	end
	ns.CloseRestockMenus()
	OpenManagePullout(anchor)
end

--------------------------------------------------------------------------------
-- Rename
--------------------------------------------------------------------------------

--[[
    Renaming swaps the selector for a field holding the list's name, selected
    and ready to type over, with Rename and Cancel beside it. The field exists
    only while a rename is under way, so text sitting in it can never be
    mistaken for the name the list actually has -- which is what the old
    always-present rename box, showing the same name as the selector beside it,
    kept inviting.

    Enter and the Rename button commit. Escape, Cancel and clicking away
    discard, and so does any list event, since ns.RefreshRestockListBar ends
    the rename before it repaints. A Button click does not pull keyboard focus
    off an EditBox, so pressing Rename does not trip the discard -- its OnClick
    reads what was typed.

    New List and Copy both land here: each makes a list under a generated name
    and opens the rename over it, so the real name is one line of typing away.
]]
local isRenaming = false

local function SetRenameShown(bar, shown)
	bar.selector:SetShown(not shown)
	bar.users:SetShown(not shown)
	bar.renameBox:SetShown(shown)
	bar.renameButton:SetShown(shown)
	bar.cancelButton:SetShown(shown)
end

local function EndRename()
	if not isRenaming then
		return
	end
	isRenaming = false
	SetRenameShown(ns.restockWindow.listBar, false)
end

ns.EndRestockListRename = EndRename

function ns.BeginRestockListRename()
	local bar = ns.restockWindow.listBar
	ns.CloseRestockMenus()
	isRenaming = true
	SetRenameShown(bar, true)
	bar.renameBox:SetText(ns.restockSettings.currentList or "")
	bar.renameBox:SetFocus()
	bar.renameBox:HighlightText()
end

-- Every path through ns.RenameCurrentRestockList repaints the bar, which ends the rename.
local function CommitRename()
	ns.RenameCurrentRestockList(ns.restockWindow.listBar.renameBox:GetText())
end

--------------------------------------------------------------------------------
-- Widgets
--------------------------------------------------------------------------------

--[[
    The closed selector: the window's menu field (ns.CreateRestockMenuField in
    Restocker-Window.lua), showing the active list as its text.
]]
local function CreateListSelector(bar)
	local label = bar:CreateFontString(nil, "OVERLAY")
	label:SetPoint("LEFT", bar, "LEFT", 0, 0)
	label:SetFontObject("GameFontNormal")
	label:SetText(L["RESTOCKER_PROFILE_LABEL"])
	bar.label = label

	local selector = ns.CreateRestockMenuField(bar, SELECTOR_ARROW_SIZE, ToggleListPullout)
	selector:SetPoint("LEFT", label, "RIGHT", BAR_ITEM_GAP, 0)
	selector:SetWidth(LIST_SELECTOR_WIDTH)
	selector:SetHeight(20)

	ns.SetupRestockerTooltip(selector, L["RESTOCKER_PROFILE_LABEL"], L["RESTOCKER_PROFILE_TOOLTIP"])
	bar.selector = selector
end

local function CreateManageButton(bar)
	local button = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
	button:SetHeight(BAR_HEIGHT)
	button:SetPoint("RIGHT", bar, "RIGHT", 0, 0)
	button:SetText(L["RESTOCKER_MANAGE"])
	ns.FitRestockButton(button)
	ns.SetRestockControlClick(button, function(self)
		ToggleManagePullout(self)
	end)
	ns.SetupRestockerTooltip(button, L["RESTOCKER_MANAGE"], L["RESTOCKER_MANAGE_TOOLTIP"])
	bar.manageButton = button
end

--[[
    Anchored on both sides with no wrap, the way a row's item name is: the line
    takes the room between the selector and Manage Lists, and a list with more
    characters than fit truncates instead of running under the button.
]]
local function CreateUsersLine(bar)
	local users = bar:CreateFontString(nil, "OVERLAY")
	users:SetFontObject("GameFontHighlightSmall")
	users:SetJustifyH("LEFT")
	users:SetWordWrap(false)
	users:SetPoint("LEFT", bar.selector, "RIGHT", BAR_ITEM_GAP, 0)
	users:SetPoint("RIGHT", bar.manageButton, "LEFT", -BAR_ITEM_GAP, 0)
	bar.users = users
end

-- The rename field and its two buttons, in the selector's place; hidden until a rename begins.
local function CreateRenameControls(bar)
	local box = CreateFrame("EditBox", nil, bar, "InputBoxTemplate")
	box:SetPoint("LEFT", bar.label, "RIGHT", BAR_ITEM_GAP, 0)
	box:SetWidth(LIST_SELECTOR_WIDTH)
	box:SetHeight(20)
	box:SetAutoFocus(false)
	box:SetScript("OnEnterPressed", CommitRename)
	box:SetScript("OnEscapePressed", EndRename)
	box:SetScript("OnEditFocusLost", EndRename)

	local renameButton = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
	renameButton:SetHeight(BAR_HEIGHT)
	renameButton:SetPoint("LEFT", box, "RIGHT", BUTTON_GAP + 4, 0)
	renameButton:SetText(L["RESTOCKER_RENAME_LABEL"])
	ns.FitRestockButton(renameButton)
	ns.SetRestockControlClick(renameButton, CommitRename)
	ns.SetupRestockerTooltip(renameButton, L["RESTOCKER_RENAME_LABEL"], L["RESTOCKER_RENAME_TOOLTIP"])

	local cancelButton = CreateFrame("Button", nil, bar, "UIPanelButtonTemplate")
	cancelButton:SetHeight(BAR_HEIGHT)
	cancelButton:SetPoint("LEFT", renameButton, "RIGHT", BUTTON_GAP, 0)
	cancelButton:SetText(CANCEL)
	ns.FitRestockButton(cancelButton)
	ns.SetRestockControlClick(cancelButton, EndRename)

	bar.renameBox = box
	bar.renameButton = renameButton
	bar.cancelButton = cancelButton
end

--[[
    Show the active list and its characters, ending any rename in progress.
    Called whenever a list is added, renamed, copied, deleted or switched
    (ns.UpdateRestockListWidgets in Restocker-Saved-Lists.lua).
]]
function ns.RefreshRestockListBar()
	local bar = ns.restockWindow.listBar
	local listName = ns.restockSettings.currentList or ""
	EndRename()
	bar.selector:SetText(listName)
	bar.selector:SetCursorPosition(0)
	bar.users:SetText(UsedByText(listName))
end

--------------------------------------------------------------------------------
-- Assembly
--------------------------------------------------------------------------------

--[[
    The whole bar in one call, so Restocker-Window.lua assembles the window from
    parts. Order matters: the "Used by" line anchors between the selector and
    the Manage Lists button, and the rename field takes the selector's place.

    Every control is a child of the bar, never of the window: a control
    anchored to the window lands at its middle and disappears behind the list.
]]
function ns.CreateRestockListBar(addonFrame, listInset)
	local bar = CreateFrame("Frame", nil, addonFrame)
	bar:SetPoint("TOPLEFT", listInset, "TOPLEFT", BAR_INSET_LEFT, -BAR_GAP)
	bar:SetPoint("TOPRIGHT", listInset, "TOPRIGHT", -BAR_INSET_RIGHT, -BAR_GAP)
	bar:SetHeight(BAR_HEIGHT)

	-- A hairline between the list's own row and the rows that act on its items.
	local rule = bar:CreateTexture(nil, "ARTWORK")
	rule:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -BAR_RULE_DROP)
	rule:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -BAR_RULE_DROP)
	rule:SetHeight(1)
	rule:SetColorTexture(GOLD.r, GOLD.g, GOLD.b, 0.12)

	CreateListSelector(bar)
	CreateManageButton(bar)
	CreateUsersLine(bar)
	CreateRenameControls(bar)
	SetRenameShown(bar, false)

	--[[
	    Painted by hand this once: ns.RefreshRestockListBar reads the bar back off
	    ns.restockWindow, which is not set until the whole window is assembled.
	]]
	local listName = ns.restockSettings.currentList or ""
	bar.selector:SetText(listName)
	bar.selector:SetCursorPosition(0)
	bar.users:SetText(UsedByText(listName))

	addonFrame.listBar = bar
	return bar
end
