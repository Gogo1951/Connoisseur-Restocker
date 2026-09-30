local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Sub-Option Rows
--------------------------------------------------------------------------------

--[[
    A sub-option is a control that only means anything while the toggle above it
    is on. A dropdown never takes this row: it shares its toggle's line instead
    (the Options Layout Grid in Data/Data.lua). What remains is a dependent
    checkbox with no line to share, such as the Restock reminder's Play Sound,
    and it is marked two ways at once. This panel is the only one that builds
    these rows; the helpers move to Options-Utilities.lua once a second does.

    The row leads with a blank indent cell, which moves the checkbox itself.
    Padding the label instead would indent only the caption -- AceConfig pins a
    checkbox at the left edge of its own widget -- leaving the box lined up with
    its parent's and the words drifting away from it.

    SubLabel then colors the caption HELP silver against the parent's white, so
    the row reads as subordinate rather than merely shifted.

    The whole row is wrapped in an inline group with no name, which AceConfig
    renders as a bare SimpleGroup -- no border, no title, no padding -- at
    "fill" width. That wrapper is load-bearing, not decoration. Laid out flat,
    the indent and its control are just two more widgets in the panel's flow,
    kept together only by their widths happening to fill the line; the pair
    after them then packs onto whatever space is left and its indent stops
    indenting anything. A fill widget always gets a line to itself, so one group
    per sub-option pins one row per sub-option no matter what the pane is doing.

    Inside the group the controls need slack rather than an exact fit: a row
    summing to the full pane width sits on the wrap boundary, where a pass that
    measures a control before its width is applied tips the control onto its own
    line and strands the indent above it.

    Hiding belongs on the group, never on the controls inside it -- hiding only
    the control would leave its indent cell behind as a blank line.
]]
local function SubRow(order, hidden, controls)
	local args = {
		indent = {
			type = "description",
			name = " ",
			width = ns.OPTIONS_SUB_INDENT_WIDTH,
			order = 1,
		},
	}

	for index, control in ipairs(controls) do
		control.order = index + 1
		args["control" .. index] = control
	end

	return {
		type = "group",
		name = "",
		inline = true,
		order = order,
		hidden = hidden,
		args = args,
	}
end

local function SubLabel(text)
	return GetColor("HELP") .. text .. "|r"
end

--[[
    Speaker control beside the Play Sound toggle, matching Thanks for the Buff's
    DefineSoundPreview exactly -- same texture, same size, same width. An
    execute carrying an image renders as an AceGUI Icon rather than a captioned
    button, so it reads as a play control instead of a second setting. name
    stays empty so the Icon draws no caption; the label rides in desc, which
    AceConfigDialog shows on hover. The texture is the client's own voice-chat
    speaker, so it matches the UI in every locale without shipping art.

    It is deliberately not hidden when the toggle is off -- hearing the alert
    before turning it on is the point.

    Its Play Sound toggle must NOT be full-width, or the speaker is pushed onto
    a line of its own.
]]
local SOUND_ICON = "Interface\\Common\\VoiceChat-Speaker"
local SOUND_ICON_SIZE = 18
local SOUND_ICON_WIDTH = 0.15

--------------------------------------------------------------------------------
-- Restocker Panel
--------------------------------------------------------------------------------

--[[
    The Restocker's settings live on ns.db.global.restocker, bound to
    ns.restockSettings at PLAYER_LOGIN. They are account-wide rather than
    per-character, which is why these controls read through this accessor
    instead of ns.db.profile -- each character still defaults to its own
    restock list, but the toggles below are one choice for the account.
]]
local function GetRestockerSettings()
	return ns.restockSettings
end

-- The sound row only means anything while the in-town reminder itself is on.
local function RemindHidden()
	local settings = GetRestockerSettings()
	return not (settings and settings.restockReminderChat)
end

-- Repaint the panel so a toggle's dependent rows appear without a reopen.
local function Refresh()
	LibStub("AceConfigRegistry-3.0"):NotifyChange(ns.OPTIONS_REGISTRY.Restocker)
end

local function PlayAlert()
	if ns.RESTOCK_ALERT_SOUND then
		PlaySoundFile(ns.RESTOCK_ALERT_SOUND, "Master")
	end
end

--[[
    Each reminder is a toggle with the dropdown choosing how much it says on
    the same line, sized like every other toggle-and-dropdown row (the Options
    Layout Grid in Data/Data.lua) so the three rows end together.
]]
local function ReminderModes()
	return {
		[ns.REMINDER_SIMPLE] = L["OPTIONS_RESTOCKER_MODE_SIMPLE"],
		[ns.REMINDER_VERBOSE] = L["OPTIONS_RESTOCKER_MODE_VERBOSE"],
	}
end

local REMINDER_MODE_ORDER = { ns.REMINDER_SIMPLE, ns.REMINDER_VERBOSE }

-- A reminder's on/off toggle.
local function ReminderToggle(labelKey, descKey, settingKey, order, onSet)
	return {
		type = "toggle",
		name = L[labelKey],
		desc = L[descKey],
		order = order,
		width = ns.OPTIONS_LABEL_WIDTH,
		get = function()
			local settings = GetRestockerSettings()
			return settings and settings[settingKey]
		end,
		set = function(_, value)
			local settings = GetRestockerSettings()
			if settings then
				settings[settingKey] = value
			end
			if onSet then
				onSet()
			end
		end,
	}
end

--[[
    The Simple/Verbose dropdown beside a reminder toggle. Hidden with the
    reminder off -- how loudly a silent reminder speaks is not a question.
]]
local function ReminderModeSelect(settingKey, enabledKey, order)
	return {
		type = "select",
		name = "",
		desc = L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"],
		order = order,
		width = ns.OPTIONS_CONTROL_WIDTH,
		hidden = function()
			local settings = GetRestockerSettings()
			return not (settings and settings[enabledKey])
		end,
		values = ReminderModes,
		sorting = REMINDER_MODE_ORDER,
		get = function()
			local settings = GetRestockerSettings()
			return (settings and settings[settingKey]) or ns.REMINDER_VERBOSE
		end,
		set = function(_, value)
			local settings = GetRestockerSettings()
			if settings then
				settings[settingKey] = value
			end
		end,
	}
end

--[[
    Page order: the three reminders (the only things here that speak up on
    their own, so they lead), then the staples pop-up's toggle, then the window's
    auto-open behavior, then the Inventory Report's switch, then Praise.

    The three reminders are peers at the top level, each a toggle with the
    dropdown choosing how much it reports on the same line; the in-town
    reminder adds a sub-row for its sound.
]]
function ns.BuildRestockerOptions()
	return {
		type = "group",
		name = L["TAB_RESTOCKER"],
		args = {
			descRestocker = Desc(
				GetColor("BODY")
					.. string.format(
						L["OPTIONS_RESTOCKER_DESCRIPTION"],
						GetColor("INFO") .. L["RESTOCKER_COMMAND"] .. "|r" .. GetColor("BODY")
					)
					.. "|r",
				1
			),
			spaceRemind0 = Spacer(2),

			--[[
			    In-Town Reminders. Both the chat line and the sound fire on the
			    same signal -- the game's resting status, which turns on in inns
			    and cities -- and only when the Restock List is actually short
			    of something. All three reminders ship on; this one defaults to
			    Verbose and the other two to Simple (Data/Default-Settings.lua).
			]]
			toggleRestockerRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_REMIND",
				"OPTIONS_RESTOCKER_REMIND_DESCRIPTION",
				"restockReminderChat",
				3,
				-- Reveal or hide its dropdown and sound row without a reopen.
				Refresh
			),
			modeRestockerRemind = ReminderModeSelect("restockReminderMode", "restockReminderChat", 4),

			--[[
			    The speaker shares this row, so the toggle takes a plain unit
			    width -- full-width would push the speaker onto a line of its
			    own.

			    Only the in-town reminder gets a sound: it arrives while you are
			    running around, where a chat line is easy to miss. The merchant
			    and bank reminders fire on a window you just closed, so you are
			    already looking at the screen.
			]]
			soundRow = SubRow(5, RemindHidden, {
				{
					type = "toggle",
					name = SubLabel(L["OPTIONS_RESTOCKER_REMIND_SOUND"]),
					desc = L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"],
					get = function()
						local settings = GetRestockerSettings()
						return settings and settings.restockReminderSound
					end,
					set = function(_, value)
						local settings = GetRestockerSettings()
						if settings then
							settings.restockReminderSound = value
						end
					end,
				},
				{
					type = "execute",
					name = "",
					desc = L["OPTIONS_RESTOCKER_SOUND_PREVIEW"],
					image = SOUND_ICON,
					imageWidth = SOUND_ICON_SIZE,
					imageHeight = SOUND_ICON_SIZE,
					width = SOUND_ICON_WIDTH,
					func = PlayAlert,
				},
			}),

			--[[
			    Closing-window reminders. Peers of the in-town one, not children
			    of it -- each answers a different moment, and turning off the
			    nudge you get walking into town should not silence the report
			    you get walking away from a vendor. Both stay quiet unless
			    something is actually short.
			]]
			spaceMerchant0 = Spacer(8),
			toggleRestockerMerchantRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_MERCHANT_REMIND",
				"OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION",
				"merchantReminder",
				9,
				Refresh
			),
			modeRestockerMerchantRemind = ReminderModeSelect("merchantReminderMode", "merchantReminder", 10),

			spaceBank0 = Spacer(11),
			toggleRestockerBankRemind = ReminderToggle(
				"OPTIONS_RESTOCKER_BANK_REMIND",
				"OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION",
				"bankReminder",
				12,
				Refresh
			),
			modeRestockerBankRemind = ReminderModeSelect("bankReminderMode", "bankReminder", 13),

			--[[
			    The staples pop-up. Reads the same per-character flag the
			    pop-up's own dismiss box writes, inverted: this row says
			    "enable", that box says "don't show again", and one shipping on
			    against one shipping off is what makes each read naturally where
			    it sits.

			    Not a Restocker settings key like its neighbours -- the flag is
			    keyed per character under ns.db.global.restocker, so it goes
			    through its own accessors rather than the shared settings one.
			]]
			spaceStarter0 = Spacer(14),
			toggleStarterList = {
				type = "toggle",
				name = L["OPTIONS_RESTOCKER_STARTER_LIST"],
				desc = L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"],
				order = 15,
				width = "full",
				get = function()
					return not ns.IsStarterPopupDismissed()
				end,
				set = function(_, value)
					ns.SetStarterPopupDismissed(not value)
				end,
			},

			-- Restocker Window
			spaceWindow0 = Spacer(20),
			headerWindow = Header(L["OPTIONS_RESTOCKER_WINDOW_HEADER"], 21),
			spaceWindow1 = Spacer(22),
			descWindow = Desc(GetColor("BODY") .. L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] .. "|r", 23),
			spaceWindow2 = Spacer(24),
			toggleRestockerBank = {
				type = "toggle",
				name = L["OPTIONS_RESTOCKER_OPEN_BANK"],
				desc = L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"],
				order = 25,
				width = "full",
				get = function()
					local settings = GetRestockerSettings()
					return settings and settings.autoOpenAtBank
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.autoOpenAtBank = value
					end
				end,
			},
			spaceWindow3 = Spacer(26),
			toggleRestockerMerchant = {
				type = "toggle",
				name = L["OPTIONS_RESTOCKER_OPEN_MERCHANT"],
				desc = L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"],
				order = 27,
				width = "full",
				get = function()
					local settings = GetRestockerSettings()
					return settings and settings.autoOpenAtMerchant
				end,
				set = function(_, value)
					local settings = GetRestockerSettings()
					if settings then
						settings.autoOpenAtMerchant = value
					end
				end,
			},

			--[[
			    Inventory Report: the counts Features/Inventory-Report.lua adds to
			    item tooltips. It sits on this panel because the block carries
			    the Restocker's name and its Bags line is the Restock List's own
			    have/keep count. The header is the block's title, so the panel
			    and the tooltip cannot name it two ways.

			    Read at every tooltip, so switching it takes effect on the next
			    one without a reload. Not a Restocker settings key: it sits on
			    ns.db.global itself (Data/Default-Settings.lua), so it goes
			    through the database rather than the settings accessor.
			]]
			spaceInventory0 = Spacer(30),
			headerInventory = Header(L["INVENTORY_REPORT_TITLE"], 31),
			spaceInventory1 = Spacer(32),
			descInventory = Desc(GetColor("BODY") .. L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] .. "|r", 33),
			spaceInventory2 = Spacer(34),
			toggleInventoryReport = {
				type = "toggle",
				name = L["OPTIONS_INVENTORY_REPORT"],
				desc = L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"],
				order = 35,
				width = "full",
				get = function()
					return ns.db and ns.db.global.inventoryReport
				end,
				set = function(_, value)
					if ns.db then
						ns.db.global.inventoryReport = value
					end
				end,
			},

			--[[
			    Praise. Restocker is not original work -- the feature is adopted
			    code, and the people who wrote it and kept it alive are named
			    here rather than only in the README, because the players using
			    it are the ones who should see it. This credit names all
			    three authors; README.md's History section lists only the two
			    whose projects are still reachable, since ChiliFajita's Auto
			    Restocker is gone from both CurseForge and GitHub. The two lists
			    are deliberately different and must not be synchronised.

			    Names are proper nouns and stay as written in every locale
			    (localization allowlist), like the service names on General.
			]]
			spacePraise0 = Spacer(900),
			headerPraise = Header(L["OPTIONS_RESTOCKER_PRAISE_HEADER"], 901),
			spacePraise1 = Spacer(902),
			descPraise = Desc(GetColor("BODY") .. L["OPTIONS_RESTOCKER_PRAISE"] .. "|r", 903),
		},
	}
end
