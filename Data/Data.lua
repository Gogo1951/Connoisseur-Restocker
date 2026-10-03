local ADDON_NAME, ns = ...

--[[
    Canonical in-Lua identity (brand name), decoupled from the packaged
    folder/slug — ADDON_NAME is "Consumable-Connoisseur". This is the single
    source for the AceLocale GetLocale lookup, the LibDBIcon registration key,
    and the LDB object name, so all three stay in lockstep and match the
    NewLocale("Connoisseur") literal in every Locales/ file. APIs keyed off the
    packaged add-on (GetAddOnMetadata, the TOC Version token) still use
    ADDON_NAME, not this.
]]
ns.LOCALE_NAME = "Connoisseur"

ns.L = LibStub("AceLocale-3.0"):GetLocale(ns.LOCALE_NAME)

--------------------------------------------------------------------------------
-- Brand Colors
--------------------------------------------------------------------------------

--[[
    Raw hex palette. Features/Utilities.lua derives the |cff-prefixed COLORS
    table and the ns.GetColor accessor from this, keeping Data files logic-free.
]]
ns.PALETTE = {
	TITLE = "FFD100", -- Gold: Titles, Headers, Section Names
	INFO = "00BBFF", -- Blue: Interactions, Toggles, Links, Keybinds, Slash Commands
	BODY = "FFFFFF", -- White: Descriptions, Options Body Text, Field Labels
	HELP = "CCCCCC", -- Silver: Pro Tips, Helper Text
	TEXT = "FFFFFF", -- White: Messages, Values, Spell Names
	ON = "33CC33", -- Green: On
	OFF = "CC3333", -- Red: Off
	SEPARATOR = "AAAAAA", -- Gray: Separators, Dividers
	MUTED = "808080", -- Dark Gray: Meta-data, Version Numbers
}

--------------------------------------------------------------------------------
-- Restock Window Colors
--------------------------------------------------------------------------------

--[[
    The Restock window's own UI states, which no brand color names. Raw hex like
    ns.PALETTE; the window's files convert them with ns.HexToRGB.

    Red is kept for errors. An add that did not go through is one. A Keep
    amount the bags are short of is not, so that mark is yellow, and the orders
    count under the list wears the same yellow, which is what tells a player
    what the mark means. It is the brand gold's hex, held as a role of its own
    so the mark can change without the headings following it.
]]
ns.RESTOCKER_WINDOW_COLORS = {
	DASH_OFF = "7A7A7A", -- Gray: Settings That Are Off
	DASH_NOT_APPLICABLE = "474747", -- Dark Gray: Settings That Cannot Apply
	BANK_LABEL = "39D5FF", -- Sky Blue: The Bank Band's Name
	BANK_CAPTION = "8BC7D8", -- Soft Blue: Column Headings Under Bank
	MERCHANT_LABEL = "FF4FA3", -- Pink: The Merchant Band's Name
	MERCHANT_CAPTION = "D38EAF", -- Soft Pink: Column Headings Under Merchant
	REPUTATION_SET = "D99959", -- Amber: A Required Reputation
	KEEP_SHORT = "FFD100", -- Yellow: A Keep Amount the Bags Are Short Of, and the Orders Count Under the List
	ADD_NOTICE = "FF5A4E", -- Red: Why an Add Did Not Go Through, in the Add Box
	ROW_LABEL = "C7BDAD", -- Warm Gray: Unselected Types in the Category Pane
	ROW_COUNT = "858075", -- Dim Warm Gray: Their Counts, a Step Quieter
}

--------------------------------------------------------------------------------
-- Class Colors
--------------------------------------------------------------------------------

ns.CLASS_COLORS = {
	DEATHKNIGHT = "C41E3A",
	DRUID = "FF7C0A",
	HUNTER = "AAD372",
	MAGE = "3FC7EB",
	PALADIN = "F48CBA",
	PRIEST = "FFFFFF",
	ROGUE = "FFF468",
	SHAMAN = "0070DD",
	WARLOCK = "8788EE",
	WARRIOR = "C69B6D",
}

--------------------------------------------------------------------------------
-- URLs
--------------------------------------------------------------------------------

ns.CURSEFORGE_URL = "https://www.curseforge.com/wow/addons/consumable-connoisseur"
ns.GITHUB_URL = "https://github.com/Gogo1951/Connoisseur-Restocker"
ns.DISCORD_URL = "https://discord.gg/eh8hKq992Q"
ns.WAGO_URL = "https://addons.wago.io/addons/connoisseur"

--------------------------------------------------------------------------------
-- AceConfig Registry Names
--------------------------------------------------------------------------------

--[[
    Stable AceConfig appName per options panel, derived from ADDON_NAME. Read by
    Options/*.lua for RegisterOptionsTable / AddToBlizOptions. Never localized,
    never built inline.
]]
-- Listed in the order the panels appear in Blizzard's tree (see ns.RegisterOptionsPanels).
ns.OPTIONS_REGISTRY = {
	General = ADDON_NAME .. "_General",
	Macros = ADDON_NAME .. "_Macros",
	IgnoreList = ADDON_NAME .. "_IgnoreList",
	Restocker = ADDON_NAME .. "_Restocker",
	-- Registered but never added to the Blizzard tree: it opens as its own window.
	StarterListPopup = ADDON_NAME .. "_StarterListPopup",
	ReadinessReport = ADDON_NAME .. "_ReadinessReport",
	Profiles = ADDON_NAME .. "_Profiles",
	Diagnostics = ADDON_NAME .. "_Diagnostics",
}

--------------------------------------------------------------------------------
-- Icons
--------------------------------------------------------------------------------

-- Interface\Icons\INV_Misc_QuestionMark
ns.QUESTION_MARK_ICON = 134400

--------------------------------------------------------------------------------
-- Options Layout Grid
--------------------------------------------------------------------------------

--[[
    Widths for the label-beside-control rows in Options/. A row is an
    ns.OptionsRowLabel cell plus its control, and the two always total
    ns.OPTIONS_ROW_WIDTH, so every row ends where every other row ends. A row
    whose control needs more room passes its own width to ns.OptionsRowLabel and
    gives the control the remainder.

    A toggle with a dropdown that tunes it is the same row, the toggle standing
    in for the label: it takes ns.OPTIONS_LABEL_WIDTH and the dropdown
    ns.OPTIONS_CONTROL_WIDTH, on every panel. The dropdown carries no caption,
    so its values must read on their own beside the toggle ("When in a Raid",
    "20%"), and like every sub-option it hides until the toggle is on.
]]
ns.OPTIONS_ROW_WIDTH = 3.4
ns.OPTIONS_LABEL_WIDTH = 2.1
ns.OPTIONS_CONTROL_WIDTH = ns.OPTIONS_ROW_WIDTH - ns.OPTIONS_LABEL_WIDTH

-- The item lists' remove column, sized to its icon rather than a caption.
ns.OPTIONS_REMOVE_ICON_WIDTH = 0.25

-- The blank cell a sub-option row leads with, sized to the parent's checkbox.
ns.OPTIONS_SUB_INDENT_WIDTH = 0.115

-- The item lists' promote column, sized to hold its button caption.
ns.OPTIONS_PROMOTE_WIDTH = 0.6

--[[
    A tree panel's sidebar eats into the pane its rows are laid out in, so rows
    inside one spend a shorter budget than ns.OPTIONS_ROW_WIDTH. AceGUI's tree
    defaults to 175px, which truncates the longer character names, a first name
    and surname or a name shown with its realm;
    widening it costs the item pane exactly what it gains, hence the paired
    constant. The tree stays drag-resizable, and a drag wins over this seed.
]]
ns.OPTIONS_TREE_WIDTH = 220
ns.OPTIONS_TREE_ROW_WIDTH = 2.3

--------------------------------------------------------------------------------
-- Item List Widget
--------------------------------------------------------------------------------

--[[
    dialogControl name for the small AceGUI widget each player-managed item-list
    row draws itself with (icon, colored link, tooltip on hover). Registered in
    Options/Options-Utilities.lua. Derived from ADDON_NAME so it can never
    collide with another add-on's widget of the same shape.
]]
ns.ITEM_LINK_WIDGET_TYPE = ADDON_NAME .. "_ItemLink"

--[[
    dialogControl name for the checkbox a toggle that stands for an item draws
    itself with: the stock AceGUI checkbox, with a gap between its icon and its
    label. Registered in Options/Options-Utilities.lua, which clears this again
    where there is no stock checkbox to build on. Derived from ADDON_NAME for
    the same reason as the name above.
]]
ns.ICON_CHECKBOX_WIDGET_TYPE = ADDON_NAME .. "_IconCheckBox"

--------------------------------------------------------------------------------
-- Ignore List Scopes
--------------------------------------------------------------------------------

--[[
    The Ignore List panel names one scope per list on the account. Every scope
    but one is an AceDB profile name (a character's, or one the player typed),
    so the Global list needs a key that no profile can collide with -- hence
    the asterisks, which no character's name can hold and nobody types as a
    profile name. Read by ns.GetIgnoreListForScope in Features/Ignore-List.lua.
]]
ns.IGNORE_SCOPE_GLOBAL = "**global**"

--------------------------------------------------------------------------------
-- Macro Configuration
--------------------------------------------------------------------------------

-- label: localized display name plugged into MESSAGE_NO_ITEM by ConnoisseurNoItem.
ns.MACRO_CONFIG = {
	["Bandage"] = { macro = ns.L["MACRO_BANDAGE"], label = ns.L["LABEL_BANDAGE"] },
	["Explosive"] = { macro = ns.L["MACRO_EXPLOSIVES"], label = ns.L["LABEL_EXPLOSIVE"] },
	["Food"] = { macro = ns.L["MACRO_FOOD"], label = ns.L["LABEL_FOOD"] },
	["Health Potion"] = { macro = ns.L["MACRO_HEALTH_POTION"], label = ns.L["LABEL_HEALTH_POTION"] },
	["Healthstone"] = { macro = ns.L["MACRO_HEALTHSTONE"], label = ns.L["LABEL_HEALTHSTONE"] },
	["Mana Gem"] = { macro = ns.L["MACRO_MANA_GEM"], label = ns.L["LABEL_MANA_GEM"] },
	["Mana Potion"] = { macro = ns.L["MACRO_MANA_POTION"], label = ns.L["LABEL_MANA_POTION"] },
	["Soulstone"] = { macro = ns.L["MACRO_SOULSTONE"], label = ns.L["LABEL_SOULSTONE"] },
	["Water"] = { macro = ns.L["MACRO_WATER"], label = ns.L["LABEL_WATER"] },
	["Feed Pet"] = { macro = ns.L["MACRO_FEED_PET"], label = ns.L["LABEL_PET_FOOD"] },
	["Poisons"] = { macro = ns.L["MACRO_POISONS"], label = ns.L["LABEL_POISONS"] },
}

--[[
    Macro types whose macros stack up to MULTI_USE_MAX_ITEMS ranked /use
    lines, best item first. Once the best item runs out mid-combat — where
    macros cannot be rewritten — the press falls through to the next-best
    item. Only safe for categories whose items all share an item cooldown,
    so a single press still consumes exactly one item.
]]
ns.MULTI_USE_MAX_ITEMS = 3

ns.MULTI_USE_MACRO_TYPES = {
	["Health Potion"] = true,
	["Healthstone"] = true,
	["Mana Gem"] = true,
	["Mana Potion"] = true,
}

--[[
    Number of free General macro slots Connoisseur leaves untouched for the
    player. At 0 nothing is reserved, so macro creation pauses only when the
    General macro book is completely full. When it pauses, a once-per-session
    chat message fires and creation resumes automatically once a slot frees
    up. See ns.TryCreateMacro in Macros/Writer.lua.
]]
ns.MACRO_SLOT_CUSHION = 0

--[[
    The ceiling every macro body is trimmed against. The unit is unconfirmed:
    Blizzard's macro edit box caps with letters="255" while the chat box uses
    SetMaxBytes, so the two may not agree. Every guard therefore measures #body
    in BYTES, which is never smaller than a character count and so holds under
    either reading -- never convert one to a character count. The three trims
    that read this are in Macros/Body-Builder.lua, Macros/Tools-Hunters.lua and
    Macros/Integration-Druid-Macro-Helper.lua; ruRU is the overflow canary.
]]
ns.MACRO_BODY_MAX_LENGTH = 255

--------------------------------------------------------------------------------
-- DruidMacroHelper Integration
--------------------------------------------------------------------------------

-- Which macro types are eligible for DMH wrapping when the druid toggle is on.
ns.DRUID_MACRO_HELPER_TYPES = {
	["Health Potion"] = true,
	["Mana Potion"] = true,
	["Healthstone"] = true,
}

--[[
    The /dmh guard prefix lines prepended to each DMH-wrapped macro body.
    Copied from the DruidMacroHelper add-on's own example macros:
      HP / HS  → "/dmh start" (stun + GCD + mana) plus a "/dmh cd <token>" line
      MP       → "/dmh stun gcd cd pot" (skips the mana check, since the
                 whole point of a mana pot is that the druid is OOM)
]]
ns.DRUID_MACRO_HELPER_GUARDS = {
	["Health Potion"] = { "/dmh start", "/dmh cd pot" },
	["Healthstone"] = { "/dmh start", "/dmh cd hs" },
	["Mana Potion"] = { "/dmh stun gcd cd pot" },
}

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

--[[
    Canned chat messages the macro bodies can fire via `/run ConnoisseurTip("key")`.
    ConnoisseurTip (in Features/Macros/Runtime.lua) consults two tables:
      ns.TIP_MESSAGES        → static message text
      ns.MISSING_SPELL_MESSAGE_IDS → spell IDs (the flavor folder's Conjure-Spells file) that
                                   ConnoisseurTip resolves at print time
                                   via C_Spell.GetSpellName, producing "You don't
                                   currently know <Localized Spell Name>."
    A key the flavor folder leaves out, or a spell ID the current client
    doesn't know, resolves to nil, so ConnoisseurTip silently skips the print
    rather than naming a spell the player will never see. The noPetSkills tip
    names four pet spells, so Runtime.lua builds it at print time too.
]]
ns.TIP_MESSAGES = {
	noPetFood = ns.L["TIP_PET_NO_FOOD"],
	noMendPet = ns.L["TIP_PET_NO_MEND"],
	noHandPoison = ns.L["TIP_NO_HAND_POISON"],
}

--------------------------------------------------------------------------------
-- Mode Order
--------------------------------------------------------------------------------

-- The one when-to-use list every mode dropdown offers: Always, then by group size, then by level.
ns.MODE_ORDER = { "always", "solo", "party", "raid", "leveling", "maxlevel" }

--------------------------------------------------------------------------------
-- Restock Reminders
--------------------------------------------------------------------------------

--[[
    Every restock reminder is either a headline on its own or a headline plus one
    line per item you are short of. Stored as a mode rather than a boolean so the
    option reads as a choice ("Simple" or "Verbose") instead of an unlabelled
    switch, and so a third level could be added without another setting.
]]
ns.REMINDER_SIMPLE = "simple"
ns.REMINDER_VERBOSE = "verbose"

--[[
    Alert played when you reach an inn or city with something left to restock.
    Built from ADDON_NAME so renaming the add-on folder cannot break the path.
]]
ns.RESTOCK_ALERT_SOUND = "Interface\\AddOns\\" .. ADDON_NAME .. "\\Includes\\Sounds\\Low-Battery.ogg"

--------------------------------------------------------------------------------
-- Gold Reserve
--------------------------------------------------------------------------------

--[[
    The amounts, in whole gold, the Restocker panel's Gold Reserve dropdown
    offers: the Fibonacci run, so the steps widen as a purse does, from the
    1 gold the setting ships on to 55. The merchant restock never spends below
    the one chosen (Features/Restocker/Restocker-Merchant.lua).
]]
ns.GOLD_RESERVE_AMOUNTS = { 1, 2, 3, 5, 8, 13, 21, 34, 55 }

--[[
    The gold coin, written after an amount the way the game writes money, so
    the reserve reads the same in the dropdown and in chat, in every locale.
]]
ns.GOLD_ICON = "|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"

--------------------------------------------------------------------------------
-- Reputation Standings
--------------------------------------------------------------------------------

--[[
    Required-reputation choices for the per-row dropdown. `value` is the item.reaction
    code the merchant logic compares against UnitReaction(vendor) -- 0 means "no
    requirement". `discount` is the standard Classic faction-vendor price saving for
    that standing, shown for reference (it is informational, not enforced here).
    "Neutral" is omitted: requiring Neutral is the same as no requirement ("Any"), since
    you can already buy from any vendor you're at least Neutral with. Labels come from
    ns.GetStandingLabel, which reads the client's own standing names.
]]
ns.REPUTATION_STANDINGS = {
	{ value = 0, discount = 0 },
	{ value = 5, discount = 5 },
	{ value = 6, discount = 10 },
	{ value = 7, discount = 15 },
	{ value = 8, discount = 20 },
}

--------------------------------------------------------------------------------
-- Pet Diets
--------------------------------------------------------------------------------

--[[
    Maps diet names from GetPetFoodTypes() to internal diet IDs. The API
    returns LOCALIZED names ("Fleisch" on deDE), so the localized names from
    the L["DIET_*"] locale keys are layered on top of the English baseline.
    The English rows add no match of their own, since an untranslated DIET_*
    key already falls back to English; they stay because the Starter List
    categories look diet IDs up by English name.
]]
ns.PET_DIET_MAP = {
	["Meat"] = 1,
	["Fish"] = 2,
	["Bread"] = 3,
	["Cheese"] = 4,
	["Fruit"] = 5,
	["Fungus"] = 6,
}

ns.PET_DIET_MAP[ns.L["DIET_MEAT"]] = 1
ns.PET_DIET_MAP[ns.L["DIET_FISH"]] = 2
ns.PET_DIET_MAP[ns.L["DIET_BREAD"]] = 3
ns.PET_DIET_MAP[ns.L["DIET_CHEESE"]] = 4
ns.PET_DIET_MAP[ns.L["DIET_FRUIT"]] = 5
ns.PET_DIET_MAP[ns.L["DIET_FUNGUS"]] = 6

--------------------------------------------------------------------------------
-- Rogue Poison Groups
--------------------------------------------------------------------------------

--[[
    The canonical group numbering, keyed off by the poison tables and by the
    Starter List. A group's name is the client's own name for its first item
    (ns.GetPoisonGroupName), so no string here names one.
]]
ns.POISON_GROUPS = { ANESTHETIC = 1, CRIPPLING = 2, DEADLY = 3, INSTANT = 4, MIND_NUMBING = 5, WOUND = 6 }

--------------------------------------------------------------------------------
-- Scroll Scan Priority
--------------------------------------------------------------------------------

ns.SCROLL_CHECK_ORDER = {
	"Agility",
	"Strength",
	"Protection",
	"Intellect",
	"Spirit",
	"Stamina",
}

--------------------------------------------------------------------------------
-- Starter List Categories
--------------------------------------------------------------------------------

--[[
    What the staples pop-up can offer, one row per checkbox.
    Features/Restocker/Restocker-Starter-List.lua owns every decision made about
    these rows -- which ladder each resolves to, who is offered it, what a tick
    adds. This table only says what exists.

    One table serves every client because it holds no game IDs. `chainKey`
    names a ladder in ns.CONSUMABLE_UPGRADE_CHAINS, and the loaded flavor
    folder's own ladders supply the items; the feature file resolves the key
    at load and drops any row whose ladder that folder does not carry.
]]

--[[
    The popup asks for WHOLE STACKS, not raw counts, because stacks are the
    unit a bag slot thinks in. A stack is whatever the item itself stacks to,
    so no row below carries a size: the staples do not share one, and some
    differ by client. A Symbol of Divinity stacks to 5, a Symbol of Kings to
    100, and an Ankh to 5 on Classic Era but 10 on TBC.
    Features/Restocker/Restocker-Starter-List.lua reads the size off the item.

    A tick defaults to one stack -- or to defaultStacks, where one is the
    wrong opening offer -- and the dropdown beside it runs to a per-category
    cap: 18 for ammo, where a hunter genuinely fills an 18-slot quiver, and a
    tighter 4 everywhere else, where more stacks than that is just a heavier
    corpse run.

    countsItems turns the same dropdown into a plain count, which is what an
    item that never stacks needs: Soul Shards take a bag slot each, so the
    choice is how many slots to give them, and the dropdown says "20" rather
    than "20 Stacks". It is declared here rather than read off the item
    because the dropdown's labels are drawn before a cold item resolves.

    A category with an explicit choices list offers those counts INSTEAD of
    every number up to a cap. Soul Shards step in fours from 12 to 40 -- a
    soul bag's worth at each of the sizes a warlock actually carries -- which
    is the same question a forty-entry dropdown would ask, without the
    scrolling. maxStacks is the cap for the every-number kind and is what
    choices replaces, so a category sets one or the other, never both.

    A category with fixedAmount gets no dropdown at all: totems are tools
    you own one of.
]]
local FOOD_MAX_STACKS = 4
local AMMO_MAX_STACKS = 18
local POISON_MAX_STACKS = 4
local REAGENT_MAX_STACKS = 4
local SOUL_SHARD_CHOICES = { 12, 16, 20, 24, 28, 32, 36, 40 }
local SOUL_SHARD_DEFAULT = 20

--------------------------------------------------------------------------------
-- Ladder And Class Keys
--------------------------------------------------------------------------------

--[[
    Canonical diet numbering; the English keys are always present alongside
    the localized aliases.
]]
local PET_DIET_MAP = ns.PET_DIET_MAP

-- Canonical poison-group numbering.
local POISON_GROUP = ns.POISON_GROUPS

--[[
    Class sets. classes on a category is WHO IS OFFERED it (absent = every
    class); defaultFor is who gets it PRE-TICKED when the window opens. Mana
    classes get water ticked; the manaless still see the row, unticked -- a
    warrior can carry water for a druid friend, but nobody decides that for
    them. Death Knights exist on Wrath, Mists and Mainline clients, yet their
    entries need no expansion gate of their own: only the Wrath folder gives
    Corpse Dust a tier, and every other folder's empty ladder keeps the row
    from being offered.
]]
local AMMO_CLASSES = { HUNTER = true, WARRIOR = true, ROGUE = true }
local MANA_CLASSES =
	{ DRUID = true, HUNTER = true, MAGE = true, PALADIN = true, PRIEST = true, SHAMAN = true, WARLOCK = true }

--[[
    One entry per checkbox. section groups entries under the popup's
    headings.

    A row that stands for a kind of item -- a food, water, an ammo type --
    carries a label, and the food labels reuse the DIET_ keys so the popup
    names bread whatever the pet-food tooltips call it. Every other row has no
    label: it shows the client's own name for an item on its ladder, so it
    needs no translation and always reads as the item does in bags and at
    vendors. That item is the one a tick would add right now, or, for a row
    marked namesFirstTier, the ladder's first item -- the poison types, whose
    first item's name is the type's own ("Instant Poison").

    The order HERE is for the maintainer's eye -- grouped by section, then
    by class. Display order is the popup's to compute (SectionCategories in
    Options-Starter-List-Popup.lua): dropdown staples first, fixed-amount
    singles after, each run alphabetical by the name it shows.

    A category whose ladder went missing is dropped by
    Features/Restocker/Restocker-Starter-List.lua rather than crashing the popup
    open.
]]
ns.STARTER_LIST_CATEGORIES = {
	--[[
	    Food, everyone. Bread arrives ticked for all; meat ticked for hunters
	    (their pet eats it too).
	]]
	{
		key = "bread",
		section = "food",
		label = ns.L["DIET_BREAD"],
		chainKey = "food:" .. PET_DIET_MAP["Bread"],
		maxStacks = FOOD_MAX_STACKS,
		defaultFor = "all",
	},
	{
		key = "cheese",
		section = "food",
		label = ns.L["DIET_CHEESE"],
		chainKey = "food:" .. PET_DIET_MAP["Cheese"],
		maxStacks = FOOD_MAX_STACKS,
	},
	{
		key = "fish",
		section = "food",
		label = ns.L["DIET_FISH"],
		chainKey = "food:" .. PET_DIET_MAP["Fish"],
		maxStacks = FOOD_MAX_STACKS,
	},
	{
		key = "fruit",
		section = "food",
		label = ns.L["DIET_FRUIT"],
		chainKey = "food:" .. PET_DIET_MAP["Fruit"],
		maxStacks = FOOD_MAX_STACKS,
	},
	{
		key = "fungus",
		section = "food",
		label = ns.L["DIET_FUNGUS"],
		chainKey = "food:" .. PET_DIET_MAP["Fungus"],
		maxStacks = FOOD_MAX_STACKS,
	},
	{
		key = "meat",
		section = "food",
		label = ns.L["DIET_MEAT"],
		chainKey = "food:" .. PET_DIET_MAP["Meat"],
		maxStacks = FOOD_MAX_STACKS,
		defaultFor = { HUNTER = true },
	},

	-- Water, everyone; pre-ticked for the classes that drink for mana.
	{
		key = "water",
		section = "water",
		label = ns.L["LABEL_WATER"],
		chainKey = "water",
		maxStacks = FOOD_MAX_STACKS,
		defaultFor = MANA_CLASSES,
	},

	-- Ammo, launcher classes only.
	{
		key = "bullets",
		section = "ammo",
		label = ns.L["STARTER_POPUP_BULLETS"],
		chainKey = "bullet",
		maxStacks = AMMO_MAX_STACKS,
		classes = AMMO_CLASSES,
	},
	{
		key = "arrows",
		section = "ammo",
		label = ns.L["STARTER_POPUP_ARROWS"],
		chainKey = "arrow",
		maxStacks = AMMO_MAX_STACKS,
		classes = AMMO_CLASSES,
	},

	--[[
	    Poisons, their own headed section for rogues (alphabetical, like the
	    foods) -- the popup adds a note under its header that the ingredients
	    buy themselves. Availability does the level work: every ladder opens
	    at its spell's training level, so the section fills out as the rogue
	    earns each type -- and Anesthetic's all-TBC ladder simply never comes
	    up on Era.
	]]
	{
		key = "anesthetic",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.ANESTHETIC,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "crippling",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.CRIPPLING,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "deadly",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.DEADLY,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "instant",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.INSTANT,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "mindnumbing",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.MIND_NUMBING,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "wound",
		section = "poisons",
		namesFirstTier = true,
		chainKey = "poison:" .. POISON_GROUP.WOUND,
		maxStacks = POISON_MAX_STACKS,
		classes = { ROGUE = true },
	},
	--[[
	    Reagents & Tools. Hearthstone is offered to every class -- the worked
	    example that ANYTHING can go on the Restock List, not just the
	    consumables the add-on curates -- alongside each class's own entries.
	]]
	{
		key = "hearthstone",
		section = "reagents",
		chainKey = "reagent:hearthstone",
		fixedAmount = 1,
	},
	{
		key = "blindingpowder",
		section = "reagents",
		chainKey = "reagent:blinding-powder",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { ROGUE = true },
	},
	{
		key = "flashpowder",
		section = "reagents",
		chainKey = "reagent:flash-powder",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { ROGUE = true },
	},
	-- A tool, not a consumable: you own one.
	{
		key = "thievestools",
		section = "reagents",
		chainKey = "reagent:thieves-tools",
		fixedAmount = 1,
		classes = { ROGUE = true },
	},

	{
		key = "corpsedust",
		section = "reagents",
		chainKey = "reagent:corpse-dust",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { DEATHKNIGHT = true },
	},

	{
		key = "seeds",
		section = "reagents",
		chainKey = "reagent:seeds",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { DRUID = true },
	},
	{
		key = "wilds",
		section = "reagents",
		chainKey = "reagent:wilds",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { DRUID = true },
	},

	{
		key = "arcanepowder",
		section = "reagents",
		chainKey = "reagent:arcane-powder",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { MAGE = true },
	},
	-- Light Feather serves the mage's Slow Fall and the priest's Levitate.
	{
		key = "lightfeather",
		section = "reagents",
		chainKey = "reagent:light-feather",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { MAGE = true, PRIEST = true },
	},
	{
		key = "teleportrunes",
		section = "reagents",
		chainKey = "reagent:rune-of-teleportation",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { MAGE = true },
	},
	{
		key = "portalrunes",
		section = "reagents",
		chainKey = "reagent:rune-of-portals",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { MAGE = true },
	},

	{
		key = "divinitysymbol",
		section = "reagents",
		chainKey = "reagent:symbol-of-divinity",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { PALADIN = true },
	},
	{
		key = "kingssymbol",
		section = "reagents",
		chainKey = "reagent:symbol-of-kings",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { PALADIN = true },
	},

	{
		key = "candles",
		section = "reagents",
		chainKey = "reagent:candles",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { PRIEST = true },
	},

	{
		key = "ankh",
		section = "reagents",
		chainKey = "reagent:ankh",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { SHAMAN = true },
	},
	{
		key = "fishscales",
		section = "reagents",
		chainKey = "reagent:fish-scales",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { SHAMAN = true },
	},
	{
		key = "fishoil",
		section = "reagents",
		chainKey = "reagent:fish-oil",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { SHAMAN = true },
	},
	-- Totems are tools: one each, no dropdown.
	{
		key = "earthtotem",
		section = "reagents",
		chainKey = "reagent:earth-totem",
		fixedAmount = 1,
		classes = { SHAMAN = true },
	},
	{
		key = "firetotem",
		section = "reagents",
		chainKey = "reagent:fire-totem",
		fixedAmount = 1,
		classes = { SHAMAN = true },
	},
	{
		key = "watertotem",
		section = "reagents",
		chainKey = "reagent:water-totem",
		fixedAmount = 1,
		classes = { SHAMAN = true },
	},
	{
		key = "airtotem",
		section = "reagents",
		chainKey = "reagent:air-totem",
		fixedAmount = 1,
		classes = { SHAMAN = true },
	},

	{
		key = "figurine",
		section = "reagents",
		chainKey = "reagent:demonic-figurine",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { WARLOCK = true },
	},
	{
		key = "infernalstone",
		section = "reagents",
		chainKey = "reagent:infernal-stone",
		maxStacks = REAGENT_MAX_STACKS,
		classes = { WARLOCK = true },
	},
	--[[
	    Soul Shards never stack, so their dropdown counts bag slots rather than
	    stacks (countsItems), offering the soul-bag sizes above and opening on
	    a middling one.
	]]
	{
		key = "soulshards",
		section = "reagents",
		chainKey = "reagent:soul-shard",
		countsItems = true,
		choices = SOUL_SHARD_CHOICES,
		defaultStacks = SOUL_SHARD_DEFAULT,
		classes = { WARLOCK = true },
	},
}
