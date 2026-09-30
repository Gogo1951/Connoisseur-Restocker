local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

local Header = ns.OptionsHeader
local Desc = ns.OptionsDesc
local Spacer = ns.OptionsSpacer
local RowLabel = ns.OptionsRowLabel

--------------------------------------------------------------------------------
-- Active-State Predicates
--------------------------------------------------------------------------------

--[[
    Every sub-option hides until its toggle is on. A dropdown then appears on
    its toggle's line (see the Options Layout Grid in Data/Data.lua); a block
    of checkboxes, the scroll and pet food types, has no line to share, so it
    appears beneath its toggle instead. These read the per-character settings
    table that InitializeSavedVariables guarantees.

    Settings live on the AceDB profile, so every character configures its own
    consumables. The exceptions on this panel are account-wide and read
    ns.db.global directly: Macro Names on Buttons and the Enable Macros
    toggles (see Data/Default-Settings.lua for why each one stays there).
]]

local function GetSettings()
	return ns.db and ns.db.profile
end

local function ConjuredFirstActive()
	local settings = GetSettings()
	return settings and settings.useConjuredFirst
end

local function BuffFoodActive()
	local settings = GetSettings()
	return settings and settings.useBuffFood
end

local function ScrollsActive()
	local settings = GetSettings()
	return settings and settings.useScrolls
end

-- A flavor whose data folder has no pet buff food shows no Pet Food Buffs section.
local function NoPetBuffFoods()
	return next(ns.PET_BUFF_FOODS) == nil
end

local function PetBuffActive()
	local settings = GetSettings()
	return not NoPetBuffFoods() and settings and settings.usePetBuffFood
end

local function ReapplyActive()
	local settings = GetSettings()
	return settings and settings.earlyReapply
end

local function DruidMacroHelperActive()
	local settings = GetSettings()
	return settings and settings.enableDruidMacroHelper
end

local function NotDruid()
	return not ns.isDruid
end

local function NotRogue()
	return not ns.isRogue
end

--[[
    Night Elf Rogues see the Rogues section instead, which carries Stealth
    Eating. They get no Shadowmeld drinking: the Water macro skips its
    Shadowmeld line for Rogues.
]]
local function NotNightElf()
	return not ns.isNightElf or ns.isRogue
end

--------------------------------------------------------------------------------
-- Shared Widget Factories
--------------------------------------------------------------------------------

--[[
    The when-to-use dropdown behind every mode setting -- Buff Food, Scroll
    Buffs, Pet Food Buffs, and conjured food and water first -- so all four
    offer the one list, ns.MODE_VALUES in ns.MODE_ORDER. It sits on its
    toggle's line and hides until the toggle is on. Pet Food Buffs' isActive
    already folds in its section's gate, so a flavor with no pet buff food
    hides this along with the rest of the section. Selecting a mode rewrites
    the macros under the throttle.
]]
local function FeatureModeSelect(settingKey, description, isActive, order)
	return {
		type = "select",
		name = "",
		desc = description,
		order = order,
		width = ns.OPTIONS_CONTROL_WIDTH,
		hidden = function()
			return not isActive()
		end,
		values = ns.MODE_VALUES,
		sorting = ns.MODE_ORDER,
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

-- Hover text for a mode dropdown choosing when the Food macro offers a feature.
local function ModeDescription(featureName)
	return string.format(L["OPTIONS_MODE_DESCRIPTION"], featureName)
end

-- Toggle for one entry inside a per-character settings subtable (scroll/pet types).
local function SubsetToggle(subtableKey, key, label, order)
	return {
		type = "toggle",
		name = label,
		desc = string.format(L["OPTIONS_BUFF_TYPE_DESCRIPTION"], label),
		order = order,
		get = function()
			local subtable = ns.db.profile[subtableKey]
			return subtable and subtable[key]
		end,
		set = function(_, value)
			ns.db.profile[subtableKey][key] = value
			ns.ResetMacroState()
			ns.RequestUpdate()
		end,
	}
end

--[[
    One pet food toggle per row of the flavor folder's ns.PET_BUFF_FOODS, best
    rank first, each named with the client's own item name. A name still
    uncached shows as loading text and is warmed so the panel repaints.
]]
local function PetBuffTypeToggles()
	local foods = {}
	for itemID, row in pairs(ns.PET_BUFF_FOODS) do
		foods[#foods + 1] = { itemID = itemID, rank = row[2], settingKey = row[3] }
	end
	table.sort(foods, function(a, b)
		return a.rank > b.rank
	end)

	local toggles = {}
	local coldItemIDs = {}
	for order, food in ipairs(foods) do
		local name = C_Item.GetItemInfo(food.itemID)
		if not name then
			coldItemIDs[#coldItemIDs + 1] = food.itemID
			name = ns.GetItemDisplayName(food.itemID)
		end
		toggles["pet" .. food.settingKey] = SubsetToggle("petBuffTypes", food.settingKey, name, order)
	end
	ns.WarmItemCache(coldItemIDs, ns.OPTIONS_REGISTRY.Macros)
	return toggles
end

--[[
    Poison-group dropdown shared by the Main Hand and Off Hand rows. Values
    resolve through ns.GetPoisonGroupName each time the dialog renders, and any
    base item still uncached is warmed so the panel repaints with the client's
    own names. Rogue-only, like the section that hosts it. The order and the
    values both come from ns.POISON_GROUP_BASE_ITEMS, so a group the loaded
    data folder has no base item for is never offered.
]]
local function PoisonHandDropdown(label, description, settingKey, order)
	local sorting = {}
	for groupID in pairs(ns.POISON_GROUP_BASE_ITEMS) do
		sorting[#sorting + 1] = groupID
	end
	table.sort(sorting)

	return {
		type = "select",
		name = label,
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
			ns.WarmItemCache(coldItemIDs, ns.OPTIONS_REGISTRY.Macros)
			return values
		end,
		sorting = sorting,
		hidden = NotRogue,
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

--[[
    One factory for the Enable Macros toggles. isHidden is optional --
    Feed Pet and Poisons use it to stay hidden on the wrong class.

    macroName is the macro's own MACRO_* name, shown without the "- " every
    locale leads it with: the macros keep the dash, the panel drops it. The
    LABEL_* strings can't stand in, since three of them name the item rather
    than the macro (Explosive, Pet Food, Poison).
]]
local function MacroToggle(macroName, key, order, isHidden)
	return {
		type = "toggle",
		name = (macroName:gsub("^%- ", "")),
		desc = L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"],
		order = order,
		width = "normal",
		hidden = isHidden,
		get = function()
			return ns.IsMacroEnabled(key)
		end,
		set = function(_, value)
			ns.db.global.enabledMacros[key] = value
			ns.ResetMacroState()
			ns.RequestUpdate()
		end,
	}
end

--------------------------------------------------------------------------------
-- Macros Panel
--------------------------------------------------------------------------------

--[[
    Everything that shapes the macros Connoisseur builds, in one page: which
    macros exist, then how each behaves. Page order is Macro Names on Buttons,
    Enable Macros, Food & Water (Buff Food, Scroll Buffs, and conjured food
    and water first), Potions & Healthstones, Mana Gems & Runes, Buff
    Re-Application, Pet Food Buffs, Explosives, then the class/race-gated
    Druids, Rogues, and Night Elves sections, which hide themselves for
    characters they do not apply to. The Ignore List has its own panel
    (Options-Ignore-List.lua).

    Order values are spaced blocks so a section can be reordered or extended
    without renumbering its neighbors. The General page keeps the add-on-level
    behavior that does not touch a macro: the welcome message, the mini-map
    button, and /Commands.

    Registered as this builder function rather than a built table (see
    Options/Options.lua), so AceConfig re-invokes it on every open and every
    NotifyChange, matching how every panel here registers.
]]

function ns.BuildMacrosOptions()
	local args = {
		descIntro = Desc(L["OPTIONS_MACROS_DESCRIPTION"], 1),
		spaceIntro = Spacer(2),

		-- Macro Names on Buttons
		toggleMacroNames = {
			type = "toggle",
			name = L["OPTIONS_MACRO_NAMES"],
			desc = L["OPTIONS_MACRO_NAMES_DESCRIPTION"],
			order = 3,
			width = "full",
			get = function()
				return ns.db and ns.db.global.showMacroNames
			end,
			set = function(_, value)
				ns.ToggleMacroNames(value)
			end,
		},

		-- Enable Macros
		spaceEnable0 = Spacer(10),
		headerEnableMacros = Header(L["OPTIONS_ENABLE_MACROS_HEADER"], 11),
		spaceEnable1 = Spacer(12),
		descEnableMacros = Desc(GetColor("BODY") .. L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] .. "|r", 13),
		spaceEnable2 = Spacer(14),
		enableMacrosGroup = {
			type = "group",
			name = "",
			order = 15,
			inline = true,
			args = {
				enableBandage = MacroToggle(L["MACRO_BANDAGE"], "Bandage", 1),
				enableExplosive = MacroToggle(L["MACRO_EXPLOSIVES"], "Explosive", 2),
				enableFeedPet = MacroToggle(L["MACRO_FEED_PET"], "Feed Pet", 3, function()
					return not ns.isHunter
				end),
				enableFood = MacroToggle(L["MACRO_FOOD"], "Food", 4),
				enableFoodAndPotion = MacroToggle(L["MACRO_FOOD_AND_POTION"], "Food & Potion", 5),
				enableHealthPotion = MacroToggle(L["MACRO_HEALTH_POTION"], "Health Potion", 6),
				enableHealthstone = MacroToggle(L["MACRO_HEALTHSTONE"], "Healthstone", 7),
				enableManaGem = MacroToggle(L["MACRO_MANA_GEM"], "Mana Gem", 8),
				enableManaPotion = MacroToggle(L["MACRO_MANA_POTION"], "Mana Potion", 9),
				enablePoisons = MacroToggle(L["MACRO_POISONS"], "Poisons", 10, NotRogue),
				enableSoulstone = MacroToggle(L["MACRO_SOULSTONE"], "Soulstone", 11),
				enableWater = MacroToggle(L["MACRO_WATER"], "Water", 12),
				enableWaterAndPotion = MacroToggle(L["MACRO_WATER_AND_POTION"], "Water & Potion", 13),
			},
		},

		--[[
		    Food & Water -- what the Food and Water macros put ahead of your
		    best food and drink: buff food, scrolls, then conjured food and
		    water. One description serves the section, so each option's own
		    hover text says what it does. Each mode dropdown shows on its
		    toggle's line while the toggle is on, and a break follows every
		    row, the house rhythm the Rogue, Restocker and Readiness rows
		    keep. The scroll-type checks sit beneath Scroll Buffs, after its
		    break, while it is on, with a break of their own below them.
		]]
		spaceFoodWater0 = Spacer(20),
		headerFoodWater = Header(L["OPTIONS_FOOD_WATER_HEADER"], 21),
		spaceFoodWater1 = Spacer(22),
		descFoodWater = Desc(GetColor("BODY") .. L["OPTIONS_FOOD_WATER_DESCRIPTION"] .. "|r", 23),
		spaceFoodWater2 = Spacer(24),
		toggleBuffFood = {
			type = "toggle",
			name = L["OPTIONS_BUFF_FOOD"],
			desc = L["OPTIONS_BUFF_FOOD_DESCRIPTION"],
			order = 25,
			width = ns.OPTIONS_LABEL_WIDTH,
			get = function()
				return BuffFoodActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("useBuffFood", value)
			end,
		},
		buffFoodMode = FeatureModeSelect("buffFoodMode", ModeDescription(L["FEATURE_BUFF_FOOD"]), BuffFoodActive, 26),
		spaceBuffFood = Spacer(27),
		toggleScrolls = {
			type = "toggle",
			name = L["OPTIONS_USE_SCROLLS"],
			desc = L["OPTIONS_USE_SCROLLS_DESCRIPTION"],
			order = 28,
			width = ns.OPTIONS_LABEL_WIDTH,
			get = function()
				return ScrollsActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("useScrolls", value)
			end,
		},
		scrollsMode = FeatureModeSelect("scrollsMode", ModeDescription(L["FEATURE_SCROLL_BUFFS"]), ScrollsActive, 29),
		spaceScrolls = Spacer(30),
		scrollTypesGroup = {
			type = "group",
			name = L["OPTIONS_SCROLL_TYPES"],
			order = 31,
			inline = true,
			hidden = function()
				return not ScrollsActive()
			end,
			args = {
				scrollAgility = SubsetToggle("scrollTypes", "Agility", L["OPTIONS_SCROLL_AGILITY"], 1),
				scrollIntellect = SubsetToggle("scrollTypes", "Intellect", L["OPTIONS_SCROLL_INTELLECT"], 2),
				scrollProtection = SubsetToggle("scrollTypes", "Protection", L["OPTIONS_SCROLL_PROTECTION"], 3),
				scrollSpirit = SubsetToggle("scrollTypes", "Spirit", L["OPTIONS_SCROLL_SPIRIT"], 4),
				scrollStamina = SubsetToggle("scrollTypes", "Stamina", L["OPTIONS_SCROLL_STAMINA"], 5),
				scrollStrength = SubsetToggle("scrollTypes", "Strength", L["OPTIONS_SCROLL_STRENGTH"], 6),
			},
		},
		spaceScrollTypes = {
			type = "description",
			name = " ",
			order = 32,
			hidden = function()
				return not ScrollsActive()
			end,
		},
		toggleConjuredFirst = {
			type = "toggle",
			name = L["OPTIONS_CONJURED_FIRST"],
			desc = L["OPTIONS_CONJURED_FIRST_DESCRIPTION"],
			order = 33,
			width = ns.OPTIONS_LABEL_WIDTH,
			get = function()
				return ConjuredFirstActive()
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("useConjuredFirst", value)
			end,
		},
		conjuredFirstMode = FeatureModeSelect(
			"conjuredFirstMode",
			L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"],
			ConjuredFirstActive,
			34
		),

		-- Potions & Healthstones
		spacePotions0 = Spacer(40),
		headerPotions = Header(L["OPTIONS_POTIONS_HEADER"], 41),
		spacePotions1 = Spacer(42),
		descPotions = Desc(GetColor("BODY") .. L["OPTIONS_POTIONS_DESCRIPTION"] .. "|r", 43),
		spacePotions2 = Spacer(44),
		toggleCombineHealthstones = {
			type = "toggle",
			name = L["OPTIONS_COMBINE_HEALTHSTONES"],
			desc = L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"],
			order = 45,
			width = "full",
			get = function()
				local settings = GetSettings()
				return settings and settings.combineHealthstones
			end,
			set = function(_, value)
				ns.db.profile.combineHealthstones = value
				ns.ResetMacroState()
				ns.RequestUpdate()
			end,
		},

		-- Mana Gems & Runes
		spaceManaGems0 = Spacer(50),
		headerManaGems = Header(L["OPTIONS_MANA_GEMS_HEADER"], 51),
		spaceManaGems1 = Spacer(52),
		descManaGems = Desc(GetColor("BODY") .. L["OPTIONS_MANA_GEMS_DESCRIPTION"] .. "|r", 53),
		spaceManaGems2 = Spacer(54),
		toggleIncludeManaRunes = {
			type = "toggle",
			name = L["OPTIONS_INCLUDE_MANA_RUNES"],
			desc = L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"],
			order = 55,
			width = "full",
			get = function()
				local settings = GetSettings()
				return settings and settings.includeManaRunes
			end,
			set = function(_, value)
				ns.db.profile.includeManaRunes = value
				ns.ResetMacroState()
				ns.RequestUpdate()
			end,
		},

		--[[
		    Buff Re-Application -- one threshold governing Buff Food
		    and Scroll Buffs (under Food & Water) and Pet Food Buffs below.
		    Dropdown keys are the threshold in seconds, stored directly in
		    earlyReapplyThreshold.
		]]
		spaceReapply0 = Spacer(90),
		headerReapply = Header(L["OPTIONS_REAPPLY_HEADER"], 91),
		spaceReapply1 = Spacer(92),
		descReapply = Desc(GetColor("BODY") .. L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] .. "|r", 93),
		spaceReapply2 = Spacer(94),
		toggleReapply = {
			type = "toggle",
			name = L["OPTIONS_REAPPLY"],
			desc = L["OPTIONS_REAPPLY_DESCRIPTION"],
			order = 95,
			width = ns.OPTIONS_LABEL_WIDTH,
			get = function()
				return ReapplyActive()
			end,
			set = function(_, value)
				ns.db.profile.earlyReapply = value
				ns.ResetMacroState()
				ns.RequestUpdate()
			end,
		},
		reapplyThreshold = {
			type = "select",
			name = "",
			desc = L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"],
			order = 96,
			width = ns.OPTIONS_CONTROL_WIDTH,
			hidden = function()
				return not ReapplyActive()
			end,
			values = {
				[60] = L["REAPPLY_THRESHOLD_ONE"],
				[120] = string.format(L["REAPPLY_THRESHOLD_MANY"], 2),
				[180] = string.format(L["REAPPLY_THRESHOLD_MANY"], 3),
				[240] = string.format(L["REAPPLY_THRESHOLD_MANY"], 4),
				[300] = string.format(L["REAPPLY_THRESHOLD_MANY"], 5),
			},
			sorting = { 60, 120, 180, 240, 300 },
			get = function()
				return ns.db.profile.earlyReapplyThreshold
			end,
			set = function(_, value)
				ns.db.profile.earlyReapplyThreshold = value
				ns.ResetMacroState()
				ns.RequestUpdate()
			end,
		},

		-- Pet Food Buffs
		spacePet0 = { type = "description", name = " ", order = 300, hidden = NoPetBuffFoods },
		headerPet = Header(L["OPTIONS_PET_HEADER"], 301, NoPetBuffFoods),
		spacePet1 = { type = "description", name = " ", order = 302, hidden = NoPetBuffFoods },
		descPet = {
			type = "description",
			name = GetColor("BODY") .. L["OPTIONS_PET_SECTION_DESCRIPTION"] .. "|r",
			fontSize = "medium",
			order = 303,
			hidden = NoPetBuffFoods,
		},
		spacePet2 = { type = "description", name = " ", order = 304, hidden = NoPetBuffFoods },
		togglePetBuffs = {
			type = "toggle",
			name = L["OPTIONS_USE_PET_BUFFS"],
			desc = L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"],
			order = 305,
			width = ns.OPTIONS_LABEL_WIDTH,
			hidden = NoPetBuffFoods,
			get = function()
				return PetBuffActive()
			end,
			set = function(_, value)
				ns.db.profile.usePetBuffFood = value
				ns.UpdateAuraTracking()
				ns.ResetMacroState()
				ns.RequestUpdate()
			end,
		},
		petBuffFoodMode = FeatureModeSelect(
			"petBuffFoodMode",
			ModeDescription(L["OPTIONS_PET_HEADER"]),
			PetBuffActive,
			306
		),
		spacePetTypes0 = {
			type = "description",
			name = " ",
			order = 307,
			hidden = function()
				return not PetBuffActive()
			end,
		},
		petTypesGroup = {
			type = "group",
			name = L["OPTIONS_PET_BUFF_TYPES"],
			order = 308,
			inline = true,
			hidden = function()
				return not PetBuffActive()
			end,
			args = PetBuffTypeToggles(),
		},

		-- Explosives
		spaceExplosives0 = Spacer(350),
		headerExplosives = Header(L["OPTIONS_EXPLOSIVES_HEADER"], 351),
		spaceExplosives1 = Spacer(352),
		descExplosives = Desc(GetColor("BODY") .. L["OPTIONS_EXPLOSIVES_DESCRIPTION"] .. "|r", 353),
		spaceExplosives2 = Spacer(354),
		labelExplosivesClickMode = RowLabel(GetColor("TITLE") .. L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] .. "|r", 355),
		explosivesClickMode = {
			type = "select",
			name = "",
			desc = L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"],
			order = 356,
			width = ns.OPTIONS_CONTROL_WIDTH,
			values = {
				atplayer = L["EXPLOSIVES_MODE_ATPLAYER"],
				toss = L["EXPLOSIVES_MODE_TOSS"],
			},
			sorting = { "atplayer", "toss" },
			get = function()
				return ns.db.profile.explosivesClickMode
			end,
			set = function(_, value)
				ns.db.profile.explosivesClickMode = value
				ns.ResetMacroState()
				ns.RequestUpdate()
			end,
		},

		-- Druids
		spaceDruid0 = { type = "description", name = " ", order = 500, hidden = NotDruid },
		headerDruid = Header(L["OPTIONS_DRUIDS_HEADER"], 501, NotDruid),
		spaceDruid1 = { type = "description", name = " ", order = 502, hidden = NotDruid },
		toggleDruidMacroHelper = {
			type = "toggle",
			name = L["OPTIONS_DRUID_MACRO_HELPER"],
			desc = L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"],
			order = 503,
			width = ns.OPTIONS_LABEL_WIDTH,
			hidden = NotDruid,
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
			order = 504,
			width = ns.OPTIONS_CONTROL_WIDTH,
			hidden = function()
				return NotDruid() or not DruidMacroHelperActive()
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
		    free. Hidden for other classes; Night Elf Rogues see THIS
		    section (the Night Elves one hides itself for Rogues).
		]]
		spaceRogue0 = { type = "description", name = " ", order = 520, hidden = NotRogue },
		headerRogue = Header(L["OPTIONS_ROGUES_HEADER"], 521, NotRogue),
		spaceRogue1 = { type = "description", name = " ", order = 522, hidden = NotRogue },
		descPoisons = {
			type = "description",
			name = GetColor("BODY") .. L["OPTIONS_POISONS_DESCRIPTION"] .. "|r",
			fontSize = "medium",
			order = 523,
			hidden = NotRogue,
		},
		spaceRogue2 = { type = "description", name = " ", order = 524, hidden = NotRogue },
		-- Label-beside-control rows: the label cell, then the unlabeled dropdown, one row wide together.
		labelMainHandPoison = {
			type = "description",
			name = GetColor("TITLE") .. L["OPTIONS_POISON_MAIN_HAND"] .. "|r",
			fontSize = "medium",
			width = ns.OPTIONS_LABEL_WIDTH,
			order = 525,
			hidden = NotRogue,
		},
		mainHandPoison = PoisonHandDropdown("", L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"], "mainHandPoisonGroup", 526),
		spaceRogue3 = { type = "description", name = " ", order = 527, hidden = NotRogue },
		labelOffHandPoison = {
			type = "description",
			name = GetColor("TITLE") .. L["OPTIONS_POISON_OFF_HAND"] .. "|r",
			fontSize = "medium",
			width = ns.OPTIONS_LABEL_WIDTH,
			order = 528,
			hidden = NotRogue,
		},
		offHandPoison = PoisonHandDropdown("", L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"], "offHandPoisonGroup", 529),
		spaceRogue4 = { type = "description", name = " ", order = 530, hidden = NotRogue },
		toggleStealthEatingRogue = {
			type = "toggle",
			name = L["OPTIONS_STEALTH_EATING"],
			desc = L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"],
			order = 531,
			width = "full",
			hidden = NotRogue,
			get = function()
				return ns.db and ns.db.profile and ns.db.profile.enableStealthEating
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("enableStealthEating", value)
			end,
		},

		-- Night Elves
		spaceNightElf0 = { type = "description", name = " ", order = 600, hidden = NotNightElf },
		headerNightElf = Header(L["OPTIONS_NIGHTELF_HEADER"], 601, NotNightElf),
		spaceNightElf1 = { type = "description", name = " ", order = 602, hidden = NotNightElf },
		descStealthPickOne = {
			type = "description",
			name = GetColor("HELP") .. L["OPTIONS_STEALTH_PICK_ONE"] .. "|r",
			fontSize = "medium",
			order = 603,
			hidden = NotNightElf,
		},
		spaceNightElf2 = { type = "description", name = " ", order = 604, hidden = NotNightElf },
		toggleShadowmeldDrinking = {
			type = "toggle",
			name = L["OPTIONS_STEALTH_DRINKING"],
			desc = L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"],
			order = 605,
			width = "full",
			hidden = NotNightElf,
			get = function()
				return ns.db and ns.db.profile and ns.db.profile.enableShadowmeldDrinking
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("enableShadowmeldDrinking", value)
			end,
		},
		toggleStealthEatingNightElf = {
			type = "toggle",
			name = L["OPTIONS_STEALTH_EATING"],
			desc = L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"],
			order = 606,
			width = "full",
			hidden = NotNightElf,
			get = function()
				return ns.db and ns.db.profile and ns.db.profile.enableStealthEating
			end,
			set = function(_, value)
				ns.ToggleMacroSetting("enableStealthEating", value)
			end,
		},
	}

	return {
		type = "group",
		name = L["TAB_MACROS"],
		args = args,
	}
end
