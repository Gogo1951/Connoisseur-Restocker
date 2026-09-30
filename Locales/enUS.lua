local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "enUS", true)
if not L then
	return
end

--------------------------------------------------------------------------------
-- Brand
--------------------------------------------------------------------------------

L["ADDON_TITLE"] = "Connoisseur"

--------------------------------------------------------------------------------
-- Macro Names
--------------------------------------------------------------------------------

--[[
    Macro names cannot exceed 16 total characters. Macros are found by name, so
    a shipped name never changes: a new translation creates a second macro and
    leaves every player's existing one stale on their action bar.
]]

L["MACRO_BANDAGE"] = "- Bandage"
L["MACRO_EXPLOSIVES"] = "- Explosives"
L["MACRO_FEED_PET"] = "- Feed Pet"
L["MACRO_FOOD"] = "- Food"
L["MACRO_FOOD_AND_POTION"] = "- Food & Potion"
L["MACRO_HEALTH_POTION"] = "- Health Potion"
L["MACRO_HEALTHSTONE"] = "- Healthstone"
L["MACRO_MANA_GEM"] = "- Mana Gem"
L["MACRO_MANA_POTION"] = "- Mana Potion"
L["MACRO_POISONS"] = "- Poisons"
L["MACRO_SOULSTONE"] = "- Soulstone"
L["MACRO_WATER"] = "- Water"
L["MACRO_WATER_AND_POTION"] = "- Water & Potion"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of a printed list: a Readiness Report clause, or the Restocker's "Couldn't move" list.
L["LIST_SEPARATOR"] = ", "
-- The decimal mark in a number the code prints, such as the Readiness Report's 2.5-minute choice.
L["DECIMAL_SEPARATOR"] = "."

--------------------------------------------------------------------------------
-- Pet Diets
--------------------------------------------------------------------------------

--[[
    Diet names as returned by the pet diet reader, which is localized. These
    values MUST match the client's strings exactly (verify in-game with a pet
    out: /dump GetPetFoodTypes() on Era and TBC,
    /dump C_PetInfo.GetPetFoodTypes() on Forever). Used to build
    ns.PET_DIET_MAP in Data/Data.lua.

    They are ALSO the food checkbox labels in the Starter List pop-up, so they
    read as ordinary labels while carrying that hard constraint. Translate them
    as the client's own diet words, never as the nicer label they look like --
    a locale that "improves" one here stops matching that client's strings and
    silently breaks pet-food selection for everyone playing in it.
]]

L["DIET_BREAD"] = "Bread"
L["DIET_CHEESE"] = "Cheese"
L["DIET_FISH"] = "Fish"
L["DIET_FRUIT"] = "Fruit"
L["DIET_FUNGUS"] = "Fungus"
L["DIET_MEAT"] = "Meat"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Looks like you found a bug! %s (%s) can't be used in %s > %s (%s). Please report this so we can get it fixed. Thanks! %s"
L["MESSAGE_NO_ITEM"] = "No suitable %s found in your bags."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"Some Connoisseur macros couldn't be created because your macro slots are full. Free up a slot by deleting macros you no longer use, or turn off any Connoisseur macros you don't need under Options > AddOns > Connoisseur > Macros."

L["CHAT_LOADED"] =
	"Version %s. Settings (including the option to disable this message) can be found under Options > AddOns > Connoisseur. Enjoying the add-on? Tell a friend about it! (="

L["CHAT_OPTIONS_IN_COMBAT"] = "As a safety precaution, the Options Interface cannot be opened during combat."

--------------------------------------------------------------------------------
-- Readiness Report
--------------------------------------------------------------------------------

--[[
    Printed when a ready check starts, as a header plus up to three lines. Each
    line is a set of "Label : a, b, c" clauses joined by ". ", and every part of
    it is dropped when it has nothing to say -- a clean character prints nothing
    at all, so there is no all-clear string here and must not be one.

    The joins are keys of their own so a locale can use its own punctuation:
    READINESS_CLAUSE_FORMAT puts a clause's label before its items, the items
    are joined with LIST_SEPARATOR, and the clauses with
    READINESS_CLAUSE_SEPARATOR.
]]

L["READINESS_TITLE"] = "Readiness Report"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Missing Buffs :"
L["READINESS_EXPIRING"] = "Expiring Soon :"
L["READINESS_MISSING_ITEMS"] = "Missing Items :"
L["READINESS_DAMAGED_GEAR"] = "Damaged Gear :"
L["READINESS_CHARACTER"] = "Character :"
L["READINESS_QUESTIONABLE_GEAR"] = "Non-Combat Gear Equipped :"

--[[
    What the report calls each thing. The Readiness Report panel labels its
    switches with these same keys, so a switch names exactly the line it
    controls; a switch that needs other words than its line (Main Hand Weapon
    Buff, PvP Flag On) keeps an OPTIONS_READINESS_* label of its own.

    Deliberately its own set rather than the shared LABEL_* keys the macro
    messages use: those name an item you are being offered ("Health Potion"),
    these name a gap in your preparation ("Healing Potion"), and the two want
    to be reworded independently.
]]
L["READINESS_FLASK"] = "Flask or 2x Elixirs"
L["READINESS_WELL_FED"] = "Well Fed"
L["READINESS_PET_WELL_FED"] = "Well Fed (Pet)"
L["READINESS_SCROLLS"] = "Scrolls"
L["READINESS_SOULSTONE"] = "Soulstone Inactive"
L["READINESS_MAIN_HAND"] = "Main Hand"
L["READINESS_OFF_HAND"] = "Off Hand"
L["READINESS_HEALTHSTONE"] = "Healthstone"
L["READINESS_MANA_GEM"] = "Mana Gem"
L["READINESS_HEALING_POTION"] = "Healing Potion"
L["READINESS_MANA_POTION"] = "Mana Potion"
L["READINESS_BANDAGES"] = "Bandages"
L["READINESS_PVP_ON"] = "PvP Flagged!"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s under 1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 Unspent Talent Point"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d Unspent Talent Points"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "You don't currently have any food that is useful for your pet."
L["TIP_PET_NO_SKILLS"] = "You don't currently know Call Pet, Dismiss Pet, Feed Pet, or Revive Pet."
L["TIP_PET_NO_MEND"] = "You don't currently know Mend Pet."
L["TIP_NO_HAND_POISON"] = "You're out of the selected poison for this weapon."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "You don't currently know %s."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "Buff Food"
L["MENU_BUFF_FOOD_DESCRIPTION"] = 'Prioritizes food that grants "Well Fed" whenever the buff is missing.'
L["FEATURE_SCROLL_BUFFS"] = "Scroll Buffs"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] = "Turns your Food macro into a scroll-applier when you're missing scroll buffs."

-- Section titles and ignore-list actions in the mini-map tooltip.
L["MINIMAP_BEST_FOOD"] = "Current Food"
L["MINIMAP_BEST_PET_FOOD"] = "Current Pet Food"
-- Weapon-slot titles beside the rogue's resolved poison, in the Attention Rogues block.
L["MINIMAP_MAIN_HAND"] = "Main Hand"
L["MINIMAP_OFF_HAND"] = "Off Hand"
--[[
    The value shown beside an item title when nothing resolved. Kept to a single
    word so it fits in the tooltip's right column, which never wraps -- the full
    sentence, MESSAGE_NO_ITEM, explains it on the wrapping line underneath.
]]
L["MINIMAP_NONE"] = "None"
L["MINIMAP_IGNORE_LIST"] = "Ignore List"
L["MENU_IGNORE"] = "Ignore"
L["MENU_CLEAR_IGNORE"] = "Clear Ignore List"

--[[
    Restocker Report block in the mini-map tooltip. While the outstanding
    restocking orders are few enough to fit, it lists them under the header,
    one item per row; past that it shows only how many there are, beside the
    header. An order is one Restock List row with Buy switched on that is still
    short in your bags, so the count is of rows and not of missing units -- nine
    outstanding orders can be nine single juices or nine full stacks. The header
    beside it supplies the "restocking", so the count only needs the noun.

    The count only ever stands in for a list too long to show, so it is never
    one and needs no singular.

    The count sits in the tooltip's right column, beside the header, so it has
    to stay short enough to read as a value rather than a sentence. The
    all-stocked case has no header and no count: STOCKED replaces the whole
    row, on a wrapping line of its own, so it can be a full sentence.

    ITEM_COUNT is the right-hand value of a listed row: { have, wanted }, the
    ratio RESTOCKER_REMINDER_ITEM prints. Wordless, so there is nothing to
    translate, but a key anyway for the same reason that one is.
]]
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker Report"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d Orders Outstanding"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Congratulations, you're fully stocked up!"

-- Options entry at the bottom of the mini-map tooltip.
L["MENU_OPTIONS"] = "Connoisseur Options"
L["MENU_OPTIONS_KEYBIND"] = "Shift + Middle-Click"

--------------------------------------------------------------------------------
-- Class Tips
--------------------------------------------------------------------------------

--[[
    Class-colored headers and click tips shown in the mini-map tooltip for the
    player's class.
]]

L["PREFIX_HUNTER"] = "Attention Hunters"
L["PREFIX_MAGE"] = "Attention Mages"
L["PREFIX_ROGUE"] = "Attention Rogues"
L["PREFIX_WARLOCK"] = "Attention Warlocks"

--[[
    Subtitle under each class header, naming the macros the tips below apply
    to. Each tip below is one instruction, rendered on its own line. The Mage
    and Warlock tips name the macro they belong to, since those blocks cover
    more than one macro and a bare "Right-Click" would be ambiguous; the Hunter
    and Rogue blocks cover one macro each, which the subtitle names.

    The verb tracks the real spell names, which differ by class: mages get
    Conjure Food / Conjure Water, warlocks get Create Healthstone / Create
    Soulstone.
]]
L["TIP_HUNTER_MACROS"] = "Regarding your Feed Pet macro..."
L["TIP_MAGE_MACROS"] = "Regarding your Food, Water, and Mana Gem macros..."
L["TIP_ROGUE_MACROS"] = "Regarding your Poisons macro..."
L["TIP_WARLOCK_MACROS"] = "Regarding your Healthstone and Soulstone macros..."

L["TIP_HUNTER_ALL_IN_ONE"] = "Feed Pet is an All-in-One Pet Button!"
L["TIP_HUNTER_CALL"] = "Left-Click to automatically Call, Feed, or Revive your pet."
L["TIP_HUNTER_MEND"] = "Right-Click, or click during combat, to cast Mend Pet."
L["TIP_HUNTER_MODIFIERS"] = "Hold Shift to force Revive, or Ctrl to Dismiss."

--[[
    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone. Mana Gems, Soulstones,
    and both rituals ignore the target (ignoreTarget in the resolvers), so each
    line names what it actually affects rather than saying "the macro."
]]
L["TIP_MAGE_CONJURE"] = "Right-Click on your Food or Water macros to cast Conjure Food or Conjure Water."
L["TIP_MAGE_DOWNRANK"] = "Targeting a lower-level player will conjure food or water appropriate for their level."
L["TIP_MAGE_TABLE"] = "Middle-Click on your Food or Water macros to cast Ritual of Refreshment."
L["TIP_MAGE_GEM"] =
	"Right-Click on your Mana Gem macro to conjure a new gem. Right-Click again to conjure a lower-rank backup."

L["TIP_WARLOCK_HEALTHSTONE"] =
	"Right-Click on your Healthstone macro to cast Create Healthstone. Right-Click again to create a lower-rank backup."
L["TIP_WARLOCK_DOWNRANK"] = "Targeting a lower-level player will create a Healthstone appropriate for their level."
L["TIP_WARLOCK_SOULSTONE"] = "Right-Click on your Soulstone macro to cast Create Soulstone."
L["TIP_WARLOCK_SOUL"] = "Middle-Click on your Healthstone macro to cast Ritual of Souls."

L["TIP_ROGUE_OFF_HAND"] = "Left-Click applies your Off Hand poison."
L["TIP_ROGUE_MAIN_HAND"] = "Right-Click applies your Main Hand poison."
L["TIP_ROGUE_REPLACE"] = "Existing poisons are replaced automatically."
L["TIP_ROGUE_WINDOW"] = "Middle-Click opens the Poisons window."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the List Builder's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Bandage"
L["LABEL_EXPLOSIVE"] = "Explosive"
L["LABEL_FOOD"] = "Food"
L["LABEL_HEALTH_POTION"] = "Health Potion"
L["LABEL_HEALTHSTONE"] = "Healthstone"
L["LABEL_MANA_GEM"] = "Mana Gem"
L["LABEL_MANA_POTION"] = "Mana Potion"
L["LABEL_PET_FOOD"] = "Pet Food"
L["LABEL_POISONS"] = "Poison"
L["LABEL_SOULSTONE"] = "Soulstone"
L["LABEL_WATER"] = "Water"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Enabled"
L["MINIMAP_DISABLED"] = "Disabled"
L["MINIMAP_TOGGLE"] = "Toggle"
L["MINIMAP_LEFT_CLICK"] = "Left-Click"
L["MINIMAP_RIGHT_CLICK"] = "Right-Click"
L["MINIMAP_MIDDLE_CLICK"] = "Middle-Click"
L["MINIMAP_SHIFT_LEFT"] = "Shift + Left-Click"

--------------------------------------------------------------------------------
-- Mode Values
--------------------------------------------------------------------------------

--[[
    The one when-to-use list, offered by every mode dropdown: Prioritize Buff
    Food, Enable Scroll Buffs, Use Pet Food Buffs, and Use Conjured Food &
    Water First. %s in OPTIONS_MODE_DESCRIPTION is the feature's name,
    FEATURE_BUFF_FOOD, FEATURE_SCROLL_BUFFS or OPTIONS_PET_HEADER; the
    conjured dropdown has hover text of its own. The dropdowns have no
    caption, so each value carries its own "when". Leveling means below the
    client's max level.
]]
L["OPTIONS_MODE_DESCRIPTION"] =
	"Chooses when your Food macro offers %s: always, or only while you're solo, in a party or raid, in a raid, still leveling, or at max level."
L["MODE_ALWAYS"] = "Always"
L["MODE_SOLO"] = "When Solo"
L["MODE_PARTY"] = "When in a Party or Raid"
L["MODE_RAID"] = "When in a Raid"
L["MODE_LEVELING"] = "When Leveling"
L["MODE_MAX_LEVEL"] = "When at Max Level"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Macros that automatically use your best food, water, potions, healthstones, bandages, poisons, and pet food, plus a Restock List that auto-buys and banks your consumables and upgrades them as you level. Quality-of-life automation for peak performance."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Enable Welcome Message"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Prints a welcome message in chat on login."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Enable Mini-map Button"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Shows the mini-map button."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Opens the Options Interface for this add-on."
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Opens the Restocker window to manage your Restock List."

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "Feedback & Support"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["CURSEFORGE"] = "CurseForge"
L["WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Version %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Enable Macros header below titles the first section,
    after the page's one headerless toggle, Macro Names on Buttons.
]]
L["TAB_MACROS"] = "Macros"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur builds one macro per consumable and keeps it current as your bags change, so the button on your bar always reaches for the best item you're carrying. Choose which macros to create below, then set how each one picks its item."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Enable Macro Names on Buttons"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Shows the macro name text on your action bar buttons, which Connoisseur hides by default."

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "Enable Macros"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Choose which macros Connoisseur creates and maintains. Turning one off also removes it."
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Creates and maintains this macro, and removes it when unchecked."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Food & Water"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Your Food and Water macros use the best food and drink in your bags. These options can put buff food, scrolls, or conjured food and water first."

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Prioritize Buff Food"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'Prioritizes food that grants "Well Fed" whenever the buff is missing, except in Arenas.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Enable Scroll Buffs"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Your Food macro applies missing scrolls on the first press and eats on the next, skipping scrolls when you target a friendly player or are in an Arena."
L["OPTIONS_SCROLL_TYPES"] = "Include Scroll Types in Check"
L["OPTIONS_SCROLL_AGILITY"] = "Agility"
L["OPTIONS_SCROLL_INTELLECT"] = "Intellect"
L["OPTIONS_SCROLL_PROTECTION"] = "Protection"
L["OPTIONS_SCROLL_SPIRIT"] = "Spirit"
L["OPTIONS_SCROLL_STAMINA"] = "Stamina"
L["OPTIONS_SCROLL_STRENGTH"] = "Strength"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "Includes %s when checking for missing buffs."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Use Conjured Food & Water First"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	"Your Food and Water macros use conjured food and water before anything else, even when something in your bags restores more, since it costs nothing and vanishes soon after you log out. Buff food still comes first while Prioritize Buff Food is on."
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Chooses when conjured food and water comes first: always, or only while you're solo, in a party or raid, in a raid, still leveling, or at max level."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Potions & Healthstones"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Macros cannot change during combat (this is a Blizzard restriction), so each Potion and Healthstone macro is pre-built with your best item plus up to two fallbacks. On longer fights the icon and tooltip can go stale and show the wrong item, but clicking the macro will always use the best item you actually have in your bags."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combine Healthstones into Health Potion Macro"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Adds your best Healthstone to the bottom of the Health Potion macro, so one press uses a potion and a Healthstone."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Mana Gems & Runes"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"Demonic and Dark Runes, and a few other mana items, share a cooldown with Mana Gems. The runes cost health to use, so the Mana Gem macro leaves all of them out unless you add them."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Add Runes & Other Mana Items to Mana Gem Macro"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"Ranks your Demonic and Dark Runes, and any other mana item that shares the Mana Gem cooldown, alongside your Mana Gems, so the Mana Gem macro uses one when it's your best option or when you're out of gems."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Buff Re-Application"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Macros can't change during combat, so a buff that runs out mid-fight stays gone until the fight ends."
L["OPTIONS_REAPPLY"] = "Re-Apply Expiring Buffs"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Treats Buff Food, Scroll Buffs, and Pet Food Buffs with less time left than your threshold as expired, so your macros offer a fresh one before the pull."
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Sets how close to expiring a buff can get before your macros offer a fresh one."
L["REAPPLY_THRESHOLD_ONE"] = "When < 1 Minute Left"
L["REAPPLY_THRESHOLD_MANY"] = "When < %d Minutes Left"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Pet Food Buffs"
L["OPTIONS_PET_SECTION_DESCRIPTION"] = 'A few foods give your pet a "Well Fed" buff of its own.'
L["OPTIONS_USE_PET_BUFFS"] = "Use Pet Food Buffs"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	'Adds pet food to your Food macro when your pet is missing "Well Fed", except in Arenas.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Include Pet Food Types in Check"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Explosives"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"The @player option skips the targeting reticle and sets the explosive off right at your feet, ideal when your target is in melee range. Your other click tosses it as usual."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Click Layout"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Chooses which click tosses the explosive and which sets it off at your feet."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Left-Click @player"
L["EXPLOSIVES_MODE_TOSS"] = "Left-Click Toss"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "Druids"
L["OPTIONS_DRUID_MACRO_HELPER"] = "Enable DruidMacroHelper Integration"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Builds powershifting macros for Health Potions, Mana Potions, and Healthstones using DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Chooses the form your powershifting macros return you to after using the item."
L["DRUID_FORM_BEAR"] = "Return to Bear"
L["DRUID_FORM_CAT"] = "Return to Cat"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "Rogues"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Keeps the Poisons macro loaded with the best usable rank of each poison type. Left-Click applies to your Off Hand, Right-Click to your Main Hand, and existing poisons are replaced automatically."
L["OPTIONS_POISON_MAIN_HAND"] = "Main Hand Poison Type"
L["OPTIONS_POISON_OFF_HAND"] = "Off Hand Poison Type"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Chooses the poison your Poisons macro applies to your Main Hand on Right-Click."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Chooses the poison your Poisons macro applies to your Off Hand on Left-Click."
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "Enable Stealth Eating"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] = "Appends Stealth to your Food macro so you stealth while eating."

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "Night Elves"
L["OPTIONS_STEALTH_DRINKING"] = "Enable Stealth Drinking"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] = "Appends Shadowmeld to your Water macro so you stealth while drinking."
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] = "Appends Shadowmeld to your Food macro so you stealth while eating."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Pro Tip: Pick one. You can eat and drink at the same time, but eating or drinking after you stealth will break your stealth."

--[[
    Ignore List panel (Options-Ignore-List.lua). One tree scope per list: the
    account-wide Global list, then the current character and every other
    character with something ignored. The rows are items, so the copy here is
    the panel description, the scope and promote labels, the add box, Remove,
    the empty-list line, and LOADING_ITEM, the placeholder shown while the
    client is still resolving an item's name (the mini-map tooltip, the Macros
    panel, and the List Builder use it too). The mini-map tooltip's section
    keeps its own MINIMAP_IGNORE_LIST and MENU_CLEAR_IGNORE keys.
]]
L["TAB_IGNORE_LIST"] = "Ignore List"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Ignored items are never picked by any macro. Food, water, potions, anything. The Global list covers every character; a character's list covers only that one. Right-Click the mini-map button to ignore your current best food."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] = "Moves this item to the Global list, so it is ignored on every character."
L["OPTIONS_IGNORE_ADD_ID"] = "Add by Item ID"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Type an item ID, or Shift + Click an item link in chat while this box has focus."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "Type an item ID, or Shift + Click an item link in chat."
L["OPTIONS_IGNORE_REMOVE"] = "Remove"
L["OPTIONS_IGNORE_EMPTY"] = "This list is empty."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Loading ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Keeps your bags stocked from your Restock List, buying from merchants and moving items to and from the bank automatically. Type %s to open the list."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Open at Bank"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Opens the Restocker window when you visit the bank."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Open at Merchant"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Opens the Restocker window when you visit a merchant."
L["OPTIONS_RESTOCKER_REMIND"] = "Enable In-Town Restock Reminders"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Prints a chat reminder when your Restock List is short of something and you reach an inn or a city, or log in already standing in one."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Enable At-Merchant Restock Reminders"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Reports any outstanding restocking orders when you close a merchant window."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Enable At-Bank Restock Reminders"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "Reports any outstanding restocking orders when you close the bank."

--[[
    The Starter List Builder pop-up. This toggle and the pop-up's own "Don't
    Show This Again" box are the same per-character choice read from opposite
    ends, which is why one ships on and the other off: a settings row reads
    naturally as "enable", a dismissal reads naturally as "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] = "Enable List Builder When Restock List Is Empty"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"Offers a starter Restock List at login whenever this character's list is empty."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Chooses whether the reminder is a single line or adds a line for each item you're short on."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Simple"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Verbose"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Play Sound"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] = "Plays an alert alongside the reminder, for when chat is busy."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Click to hear the alert."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Restocker Window"

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Praise"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"I've always loved Restocker, and I'm grateful for the opportunity to have it live on inside Connoisseur. Huge thanks to ChiliFajita, who wrote the original Auto Restocker, and to kvakvs and guardycmw, who kept it going through Classic and Mists of Pandaria."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Readiness Report"
L["OPTIONS_READINESS_ENABLE"] = "Enable Readiness Report on Ready Check"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] = "Turns the Readiness Report on for every character on this account."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"When a ready check starts, prints a private list of what still needs fixing, and says nothing at all when you are ready."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the character's own profile, so nothing else on any panel can return
    them to their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Reset Readiness Report Settings"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Returns every checkbox and both thresholds on this page to their defaults, leaving every other page untouched."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Reset every Readiness Report setting to its default? This also switches the report itself back off."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Missing Buffs"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Missing Items"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Character"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Reports a missing flask. A flask, or one battle elixir and one guardian elixir, counts as covered."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	'Reports a missing "Well Fed" buff. Needs Buff Food turned on under Macros.'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	'Reports your pet\'s missing "Well Fed" buff. Needs Pet Food Buffs turned on under Macros, and a pet out.'
L["OPTIONS_READINESS_SCROLLS"] = "Scroll Buffs"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Reports missing scroll buffs. Needs Scroll Buffs turned on under Macros, and checks only the scroll types selected there."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Reports when no one in your group has a Soulstone active; one sitting in a bag doesn't count. Only shown to a Warlock who can create one."
L["OPTIONS_READINESS_MAIN_HAND"] = "Main Hand Weapon Buff"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Reports a Main Hand weapon with no temporary enchant. Any enchant counts, and it stays quiet when there is a Shaman in your group."
L["OPTIONS_READINESS_OFF_HAND"] = "Off Hand Weapon Buff"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Reports an Off Hand weapon with no temporary enchant. Any enchant counts: a stone, an oil, a poison, or a Shaman weapon buff."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Buffs Expiring Within"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"Names every buff on you that is about to expire, not just the ones Connoisseur applies, and is separate from Buff Re-Application under Macros."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s Minutes"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 Minute"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Sets how close to expiring a buff must be for the report to name it."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Reports when you carry no Healthstone. Only shown when there's a Warlock in your group to ask, or when you're the Warlock."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Reports when you carry no Mana Gem. Only shown to a Mage who can conjure one."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Reports when you carry no healing potion, since nobody can hand you one mid-fight."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Reports when you carry no mana potion. Only shown when you're playing a class that uses mana."
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] = "Reports when you carry no bandage your First Aid skill lets you use."
L["OPTIONS_READINESS_DURABILITY"] = "Damaged Gear Below"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Links every equipped item under this much durability, measured per item so one broken weapon still shows."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Sets how low an item's durability must fall for the report to link it."

-- Character
L["OPTIONS_READINESS_SPEC"] = "Current Spec"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] = "Prints your talent spread, and any points you have not spent."
L["OPTIONS_READINESS_PVP"] = "PvP Flag On"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Warns when your PvP flag is up."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Non-Combat Gear Equipped"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"Links equipped items that do not belong in a fight, such as a Riding Crop or a fishing pole."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'A list named "%s" already exists.'
-- %d is the item ID the player typed.
L["RESTOCKER_UNKNOWN_ITEM"] = "No item with ID %d exists."
L["RESTOCKER_BANK_NOT_OPEN"] = "The bank is not open."
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Restocking complete. Hold Shift while opening the bank to skip restocking. Type %s to edit your Restock List."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Restocking stopped. Both your bags and your bank are full."
L["RESTOCKER_STOPPED_BANK_FULL"] = "Restocking stopped. Your bank is full; free a slot and reopen it."
L["RESTOCKER_STOPPED_BAG_FULL"] = "Restocking stopped. Your bags are full; free a slot and reopen the bank."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Restocking stopped. No progress could be made."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Restocking stopped. Couldn't move: %s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (extra)"
L["RESTOCKER_STOPPED_ERROR"] = "Restocking stopped due to an error: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] = "This merchant doesn't stock every ingredient your poisons need. Skipping them all."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Don't forget to restock while you're in town!"

--[[
    Headline for the merchant and bank reminders, which report on the way out
    rather than nudging on arrival, so the count is the message. The in-town
    reminder keeps its own line above.

    The count is of restocking orders -- Restock List rows with Buy switched on
    that are still short in your bags -- so it never says "items", and never
    puts a bare count after "short": "short 9 apples" reads as nine apples
    missing, while the number here is nine ROWS, each short by anything from one
    juice to a full stack. "Order" can only mean a line on a list, and it is the
    word the code uses (BuildPurchaseOrder, purchaseOrders).

    "Outstanding" is load-bearing, not decoration. "Restocking order" alone can
    be read as the sequence restocking happens in, and the list UI is sortable,
    so the word forcing the purchase-order sense has to stay beside the noun.
    Same job as "filled" on RESTOCKER_RESTOCKED_ONE -- never print the bare
    noun without one of them.
]]
L["RESTOCKER_STILL_SHORT_ONE"] = "1 restocking order outstanding."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d restocking orders outstanding."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Your Restock List has been upgraded."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d upgrades to %sx%d."

--[[
    Verbose follow-up line, one per short item: { have, wanted, item link }.
    Shared by all three reminders. Wordless on purpose -- the headline above it
    supplies the context, so there is nothing here to translate. It stays a
    locale key anyway so a locale that needs a different order can reorder it
    (same as RESTOCKER_STUCK_ITEM_FORMAT).
]]
L["RESTOCKER_REMINDER_ITEM"] = "%d/%d %s"

--[[
    Printed after buying at a vendor. Counts restocking orders FILLED -- Restock
    List rows and poison ingredients whose whole requested amount was ordered --
    not BuyMerchantItem calls. Forty juice bought in two stacks of twenty is one
    order filled; six of a requested twenty is not one at all, and belongs to
    the partial line below.

    The claim has to be earned: PurchaseMerchantItem returns nothing, and the
    caller decides filled or partly filled once per order, after the last slot,
    from the units that order bought. What the vendor did not stock is
    deliberately not mentioned here: the mini-map's Restocker Report owns the
    outstanding state, this line owns the event, and neither repeats the other.
]]
L["RESTOCKER_RESTOCKED_ONE"] = "1 restocking order filled."
L["RESTOCKER_RESTOCKED_MANY"] = "%d restocking orders filled."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 restocking order partly filled."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d restocking orders partly filled."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Your bags filled up before everything was bought."

-- /crs help lines. The command literals stay in code; these are the descriptions.
L["RESTOCKER_HELP_SHOW"] = "Shows the Restocker window."
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[name]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Adds a list with that name."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Deletes the list with that name."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renames the current list to that name."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Replaces the current list with a copy of that list."
L["RESTOCKER_HELP_PROFILE_USE"] = "Switches this character to the list with that name."

--[[
    Starter List pop-up, the List Builder: offers staples at login when the
    Restock List is empty, and on demand from the Restocker window
    (Features/Restocker/Restocker-Starter-List.lua). Its title reuses
    RESTOCKER_WINDOW_TITLE below, and the six food staples reuse the DIET_ keys
    above, so each food row carries the client's own pet diet name.

    The intro is three short paragraphs: why the window opened, what a tick
    does, and the way back in. Joined with blank lines at the call site, so
    each reads as its own breath rather than one wall.
]]
L["STARTER_POPUP_INTRO_EMPTY"] = "Your Restock List is empty, so let's add some items to get you started."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] =
	"Pick the staples you want kept stocked. Anything already on your Restock List is checked."
L["STARTER_POPUP_INTRO_HOW"] =
	"Anything you check is kept stocked automatically whenever you open a merchant or your bank, and commodity items upgrade themselves as you level, so you'll always have the best available."
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] = "You can always adjust this list, or add more items later, by typing %s."
--[[
    The first section's heading names the Water row beneath it as well; the
    food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Food & Water"
L["STARTER_POPUP_FOOD_HEADER"] = "Food"
L["STARTER_POPUP_AMMO_HEADER"] = "Ammo"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Bullets"
L["STARTER_POPUP_ARROWS"] = "Arrows"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header reuses PREFIX_ROGUE (rogue-colored at the call
    site) to say the ingredients take care of themselves. Both sections name
    their rows with the client's own item names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagents & Tools"
L["STARTER_POPUP_POISONS_HEADER"] = "Poisons"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Add the finished poison to your list, and Connoisseur buys the ingredients automatically at any merchant that stocks them all."
--[[
    Checkbox tooltips: { item link, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Adds %s to your Restock List, keeping %d in your bags and upgrading them as you level."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Adds %s to your Restock List, keeping %d in your bags."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 Stack"
L["STARTER_POPUP_STACK_MANY"] = "%d Stacks"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "How many stacks to keep stocked, where one stack is %d."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] = "How many to keep stocked, each in its own bag slot since these do not stack."
L["STARTER_POPUP_DISMISS"] = "Don't Show This Again for This Character"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] =
	"Stops these suggestions from returning at a login that finds your Restock List empty."

-- Restocker window UI.
L["RESTOCKER_WINDOW_TITLE"] = "Connoisseur Restocker"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filter items..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Clear"
L["RESTOCKER_ADD_BUTTON"] = "Add"
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "Open List Builder"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"Opens the List Builder, with the same staples a new character is offered, and closes this window."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Add an Item"
L["RESTOCKER_ADD_TOOLTIP_BODY"] = "Drop an item from your bags, or type an item ID and press Enter."
--[[
    In-box placeholder for the add row; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: both boxes on that row share a
    fixed width sized to this English hint, and a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Drop item here, or type item ID"
L["RESTOCKER_PROFILE_LABEL"] = "List"
L["RESTOCKER_PROFILE_TOOLTIP"] = "Click to switch this character to another Restock List, or to start a new one."
L["RESTOCKER_RENAME_LABEL"] = "Rename"
L["RESTOCKER_NEW_PROFILE"] = "New List"
L["RESTOCKER_COPY_PROFILE"] = "Copy"
--[[
    The three single-argument tooltips below (Copy, Delete, and the row's
    Remove) render in ns.SetupRestockerTooltip's TITLE slot, not its body, so
    they take title case and no terminal punctuation -- matching every other
    title in the window. Don't "restore" the period they read as wanting.
]]
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "Copy This List into a New One"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s Copy"
L["RESTOCKER_DELETE_PROFILE"] = "Delete"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "Delete This List"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renames this list for every character using it."
-- %s is the list name, colored at the call site. |n are line breaks.
L["RESTOCKER_DELETE_PROFILE_CONFIRM"] = "Are you sure you want to delete this list?|n|n%s|n|nThis can't be undone."
--[[
    The Upgrade toggle. One string serves both the column heading and every
    row's checkbox, so it has to read for a single item and for the whole
    column at once -- which is why it names categories rather than "this item".

    The categories are exactly the ladder kinds in each flavor folder's
    Consumable-Upgrade-Paths-{Game}.lua: food, water, arrow and bullet, poison,
    healing and mana potion, and the class reagents. Naming anything else here
    promises an upgrade that never arrives, since the toggle is disabled on any
    item that is not on a ladder -- which on a real list is most of them.
]]
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Upgrade as You Level"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Lets Connoisseur upgrade food, water, ammo, poisons, potions, and class reagents to better items as you level."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Bank"
L["RESTOCKER_ROW_MERCHANT"] = "Merchant"
L["RESTOCKER_ROW_UPGRADE"] = "Upgrade"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Item"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Take"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Store"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep"
L["RESTOCKER_COLUMN_AMOUNT"] = "Amount"

L["RESTOCKER_GROUP_OTHER"] = "Other"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "New"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "All Items"
-- Title slot, like the Copy and Delete tooltips above: title case, no terminal period.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Remove This Item from the Restock List"
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Amount to Restock"
L["RESTOCKER_AMOUNT_TOOLTIP_BODY"] = "Press Enter when finished editing."
L["RESTOCKER_BUY_LABEL"] = "Buy"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Buy from Merchant"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "Buys the needed amount from the merchant when the merchant window is open."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Buy Extra"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Buys a merchant's whole limited stock of this item, the few-at-a-time goods it slowly restocks, even past your target amount."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Store in Bank"
--[[
    Names the Amount column, so it is coupled to RESTOCKER_COLUMN_AMOUNT: a
    locale that renders that heading differently has to say the same word here,
    or the sentence points at a column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Stores extra items in the bank when the bank is open, or all of them with 0 in the Amount column."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Take from Bank"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Takes needed items from the bank when the bank is open."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Required Reputation"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% off)"
L["RESTOCKER_REPUTATION_ANY"] = "Any"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "Friendly"
L["RESTOCKER_REPUTATION_HONORED"] = "Honored"
L["RESTOCKER_REPUTATION_REVERED"] = "Revered"
L["RESTOCKER_REPUTATION_EXALTED"] = "Exalted"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Required Merchant Reputation"
--[[
    Quotes the cell's own values, which couples this line to
    RESTOCKER_REPUTATION_ANY and the four standings above: a locale that renders
    a standing differently has to say so here too.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	'Click to set the standing a merchant needs before Connoisseur buys from it ("Any" buys anywhere), which also cuts the price: Friendly 5%, Honored 10%, Revered 15%, Exalted 20%.'
