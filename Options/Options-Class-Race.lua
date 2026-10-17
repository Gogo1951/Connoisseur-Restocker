local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer

--------------------------------------------------------------------------------
-- Active-State Predicates
--------------------------------------------------------------------------------

--[[
    Every setting here lives on the AceDB profile, which is the character's own
    unless the player put it on another, and reads the settings table that
    InitializeSavedVariables guarantees.
]]

local function GetSettings()
	return ns.db and ns.db.profile
end

local function DruidMacroHelperActive()
	local settings = GetSettings()
	return settings and settings.enableDruidMacroHelper
end

-- Cannibalize restores health only on Classic Era and TBC Anniversary, so drinking is offered where it restores mana.
local function NoCannibalizeDrinking()
	return not ns.CANNIBALIZE_RESTORES_MANA
end

--------------------------------------------------------------------------------
-- Shared Widget Factories
--------------------------------------------------------------------------------

-- A label or hover text that names a spell, read from the client when it shows.
local function SpellDescription(formatKey, spellID)
	return function()
		return string.format(L[formatKey], C_Spell.GetSpellName(spellID) or "")
	end
end

-- A checkbox for one profile setting the macros read, written through ns.ToggleMacroSetting.
local function MacroSettingToggle(settingKey, label, description, order, hidden)
	return {
		type = "toggle",
		name = label,
		desc = description,
		order = order,
		width = "full",
		hidden = hidden,
		get = function()
			local settings = GetSettings()
			return settings and settings[settingKey]
		end,
		set = function(_, value)
			ns.ToggleMacroSetting(settingKey, value)
		end,
	}
end

--[[
    Poison-group dropdown shared by the Main Hand and Off Hand rows. Values
    resolve through ns.GetPoisonGroupName each time the dialog renders, and any
    base item still uncached is warmed so the panel repaints with the client's
    own names. The order and the values both come from
    ns.POISON_GROUP_BASE_ITEMS, so a group the loaded data folder has no base
    item for is never offered.
]]
local function PoisonHandDropdown(description, settingKey, order)
	local sorting = {}
	for groupID in pairs(ns.POISON_GROUP_BASE_ITEMS) do
		sorting[#sorting + 1] = groupID
	end
	table.sort(sorting)

	return {
		type = "select",
		name = "",
		desc = description,
		order = order,
		width = ns.OPTIONS_CONTROL_WIDTH,
		values = function()
			local values = {}
			local coldItemIDs = {}
			for groupID, baseItem in pairs(ns.POISON_GROUP_BASE_ITEMS) do
				values[groupID] = ns.GetPoisonGroupName(groupID) or ns.GetItemDisplayName(baseItem)
				if not C_Item.GetItemInfo(baseItem) then
					coldItemIDs[#coldItemIDs + 1] = baseItem
				end
			end
			ns.WarmItemCache(coldItemIDs, ns.OPTIONS_REGISTRY.ClassRace)
			return values
		end,
		sorting = sorting,
		get = function()
			return ns.db.profile[settingKey]
		end,
		set = function(_, value)
			ns.db.profile[settingKey] = value
			ns.ResetMacroState()
			ns.RequestUpdate()
		end,
	}
end

--------------------------------------------------------------------------------
-- Class & Race Panel
--------------------------------------------------------------------------------

--[[
    The macro options that belong to one class or race, nested under Macros
    (Options/Options.lua): the Druid, Rogue, Forsaken and Night Elf sections,
    alphabetical within class and within race. Every character sees every
    section, the maintainer's choice, so nothing here is gated on the
    character playing; the only gate is a flavor one (Cannibalize drinking).

    Order values are spaced blocks so a section can be reordered or extended
    without renumbering its neighbors. Registered as this builder function
    rather than a built table (see Options/Options.lua), so AceConfig
    re-invokes it on every open and every NotifyChange, matching how every
    panel here registers.
]]

function ns.BuildClassRaceOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_CLASS_RACE_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),

		-- Druids
		headerDruid = Header(L["OPTIONS_CLASS_HEADER_FORMAT"]:format(LOCALIZED_CLASS_NAMES_MALE.DRUID), 10),
		spaceDruid1 = Spacer(11),
		descDruid = Desc(GetColor("BODY") .. L["OPTIONS_DRUID_DESCRIPTION"] .. "|r", 12),
		spaceDruid2 = Spacer(13),
		toggleDruidMacroHelper = {
			type = "toggle",
			name = L["OPTIONS_DRUID_MACRO_HELPER"],
			desc = L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"],
			order = 14,
			width = ns.OPTIONS_LABEL_WIDTH,
			get = function()
				return DruidMacroHelperActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("enableDruidMacroHelper", value)
			end,
		},
		druidReturnForm = {
			type = "select",
			name = "",
			desc = L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"],
			order = 15,
			width = ns.OPTIONS_CONTROL_WIDTH,
			hidden = function()
				return not DruidMacroHelperActive()
			end,
			values = {
				bear = L["DRUID_FORM_BEAR"],
				cat = L["DRUID_FORM_CAT"],
			},
			sorting = { "bear", "cat" },
			get = function()
				return ns.db.profile.druidReturnForm
			end,
			set = function(_, value)
				ns.db.profile.druidReturnForm = value
				ns.ResetMacroState()
				ns.RequestUpdate()
			end,
		},

		--[[
		    Rogues -- poison group per weapon slot plus Stealth Eating.
		    Group names come from the client's own item names
		    (ns.GetPoisonGroupName), so the dropdown labels localize for
		    free. Its Stealth Eating and the Night Elves one write the same
		    setting, which the Food macro reads as Stealth or Shadowmeld.
		]]
		spaceRogue0 = Spacer(20),
		headerRogue = Header(L["OPTIONS_CLASS_HEADER_FORMAT"]:format(LOCALIZED_CLASS_NAMES_MALE.ROGUE), 21),
		spaceRogue1 = Spacer(22),
		descPoisons = Desc(GetColor("BODY") .. L["OPTIONS_POISONS_DESCRIPTION"] .. "|r", 23),
		spaceRogue2 = Spacer(24),
		-- Label-beside-control rows: the label cell, then the unlabeled dropdown, one row wide together.
		labelMainHandPoison = ns.OptionsRowLabel(GetColor("BODY") .. L["OPTIONS_POISON_MAIN_HAND"] .. "|r", 25),
		mainHandPoison = PoisonHandDropdown(L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"], "mainHandPoisonGroup", 26),
		spaceRogue3 = Spacer(27),
		labelOffHandPoison = ns.OptionsRowLabel(GetColor("BODY") .. L["OPTIONS_POISON_OFF_HAND"] .. "|r", 28),
		offHandPoison = PoisonHandDropdown(L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"], "offHandPoisonGroup", 29),
		spaceRogue4 = Spacer(30),
		toggleStealthEatingRogue = MacroSettingToggle(
			"enableStealthEating",
			L["OPTIONS_STEALTH_EATING"],
			SpellDescription("OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION", ns.STEALTH_SPELL_ID),
			31
		),

		--[[
		    Forsaken -- Cannibalize in the Food macro, and in the Water macro
		    where it restores mana. Headed "Forsaken", the maintainer's choice,
		    though the client names the race Undead.
		]]
		spaceForsaken0 = Spacer(40),
		headerForsaken = Header(L["OPTIONS_RACE_HEADER_FORMAT"]:format(L["OPTIONS_FORSAKEN_HEADER"]), 41),
		spaceForsaken1 = Spacer(42),
		descCannibalize = Desc(function()
			return GetColor("BODY")
				.. SpellDescription("OPTIONS_CANNIBALIZE_DESCRIPTION", ns.CANNIBALIZE_SPELL_ID)()
				.. "|r"
		end, 43),
		spaceForsaken2 = Spacer(44),
		toggleCannibalizeEating = MacroSettingToggle(
			"enableCannibalizeEating",
			SpellDescription("OPTIONS_CANNIBALIZE_EATING", ns.CANNIBALIZE_SPELL_ID),
			SpellDescription("OPTIONS_CANNIBALIZE_EATING_DESCRIPTION", ns.CANNIBALIZE_SPELL_ID),
			45
		),
		toggleCannibalizeDrinking = MacroSettingToggle(
			"enableCannibalizeDrinking",
			SpellDescription("OPTIONS_CANNIBALIZE_DRINKING", ns.CANNIBALIZE_SPELL_ID),
			SpellDescription("OPTIONS_CANNIBALIZE_DRINKING_DESCRIPTION", ns.CANNIBALIZE_SPELL_ID),
			46,
			NoCannibalizeDrinking
		),

		-- Night Elves
		spaceNightElf0 = Spacer(50),
		headerNightElf = Header(
			L["OPTIONS_RACE_HEADER_FORMAT"]:format(C_CreatureInfo.GetRaceInfo(ns.NIGHT_ELF_RACE_ID).raceName),
			51
		),
		spaceNightElf1 = Spacer(52),
		descStealthPickOne = Desc(GetColor("HELP") .. L["OPTIONS_STEALTH_PICK_ONE"] .. "|r", 53),
		spaceNightElf2 = Spacer(54),
		toggleShadowmeldDrinking = MacroSettingToggle(
			"enableShadowmeldDrinking",
			L["OPTIONS_STEALTH_DRINKING"],
			SpellDescription("OPTIONS_STEALTH_DRINKING_SPELL_DESCRIPTION", ns.SHADOWMELD_SPELL_ID),
			55
		),
		toggleStealthEatingNightElf = MacroSettingToggle(
			"enableStealthEating",
			L["OPTIONS_STEALTH_EATING"],
			SpellDescription("OPTIONS_STEALTH_EATING_SPELL_DESCRIPTION", ns.SHADOWMELD_SPELL_ID),
			56
		),
	}

	return {
		type = "group",
		name = L["TAB_CLASS_RACE"],
		args = args,
	}
end
