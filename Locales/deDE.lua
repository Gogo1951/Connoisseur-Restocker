local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "deDE")
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

L["MACRO_BANDAGE"] = "- Verband"
L["MACRO_EXPLOSIVES"] = "- Sprengstoff"
L["MACRO_FEED_PET"] = "- Tier füttern"
L["MACRO_FOOD"] = "- Essen"
L["MACRO_HEALTH_POTION"] = "- Heiltrank"
L["MACRO_HEALTHSTONE"] = "- GS"
L["MACRO_MANA_GEM"] = "- Manastein"
L["MACRO_MANA_POTION"] = "- Manatrank"
L["MACRO_POISONS"] = "- Gifte"
L["MACRO_SOULSTONE"] = "- Seelenstein"
L["MACRO_WATER"] = "- Wasser"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of a list: a Readiness Report clause, the Restocker's "Couldn't move" list, or the characters on a Restock List.
L["LIST_SEPARATOR"] = ", "
-- The decimal mark in a number the code prints, such as the Readiness Report's 2.5-minute choice.
L["DECIMAL_SEPARATOR"] = ","

--------------------------------------------------------------------------------
-- Pet Diets
--------------------------------------------------------------------------------

--[[
    Diet names as returned by the pet diet reader, which is localized. These
    values MUST match the client's strings exactly (verify in-game with a pet
    out: /dump GetPetFoodTypes() on Era and TBC,
    /dump C_PetInfo.GetPetFoodTypes() on Forever). Used to build
    ns.PET_DIET_MAP in Data/Data.lua.

    They are ALSO the food checkbox labels in the staples pop-up, so they
    read as ordinary labels while carrying that hard constraint. Translate them
    as the client's own diet words, never as the nicer label they look like --
    a locale that "improves" one here stops matching that client's strings and
    silently breaks pet-food selection for everyone playing in it.
]]

L["DIET_BREAD"] = "Brot"
L["DIET_CHEESE"] = "Käse"
L["DIET_FISH"] = "Fisch"
L["DIET_FRUIT"] = "Obst"
L["DIET_FUNGUS"] = "Fungus"
L["DIET_MEAT"] = "Fleisch"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Sieht aus, als hättest du einen Bug gefunden! %s (%s) kann in %s > %s (%s) nicht verwendet werden. Bitte melde das, damit wir es beheben können. Danke! %s"
L["MESSAGE_NO_ITEM"] = "Kein geeigneter Gegenstand vom Typ %s in deinen Taschen gefunden."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"Einige Connoisseur-Makros konnten nicht erstellt werden, weil deine Makroplätze voll sind. Mache einen Platz frei, indem du Makros löschst, die du nicht mehr verwendest, oder deaktiviere nicht benötigte Connoisseur-Makros unter Optionen > Addons > Connoisseur > Makros."

L["CHAT_LOADED"] =
	"Version %s. Einstellungen (einschließlich der Option, diese Nachricht zu deaktivieren) finden sich unter Optionen > Addons > Connoisseur. Gefällt dir das Add-on? Erzähle einem Freund davon! (="

L["CHAT_OPTIONS_IN_COMBAT"] = "Aus Sicherheitsgründen kann das Optionsmenü im Kampf nicht geöffnet werden."

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

L["READINESS_TITLE"] = "Bereitschaftsbericht"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Fehlende Buffs:"
L["READINESS_EXPIRING"] = "Läuft bald ab:"
L["READINESS_MISSING_ITEMS"] = "Fehlende Gegenstände:"
L["READINESS_DAMAGED_GEAR"] = "Beschädigte Ausrüstung:"
L["READINESS_CHARACTER"] = "Charakter:"
L["READINESS_QUESTIONABLE_GEAR"] = "Nicht kampftaugliche Ausrüstung angelegt:"

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
L["READINESS_FLASK"] = "Fläschchen oder 2x Elixiere"
L["READINESS_WELL_FED"] = "Satt"
L["READINESS_PET_WELL_FED"] = "Satt (Tier)"
L["READINESS_SCROLLS"] = "Schriftrollen"
L["READINESS_SOULSTONE"] = "Seelenstein inaktiv"
L["READINESS_MAIN_HAND"] = "Waffenhand"
L["READINESS_OFF_HAND"] = "Schildhand"
L["READINESS_HEALTHSTONE"] = "Gesundheitsstein"
L["READINESS_MANA_GEM"] = "Manastein"
L["READINESS_HEALING_POTION"] = "Heiltrank"
L["READINESS_MANA_POTION"] = "Manatrank"
L["READINESS_BANDAGES"] = "Verbände"
L["READINESS_PVP_ON"] = "PvP aktiv!"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d Min."
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s unter 1 Min."
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 nicht verteilter Talentpunkt"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d nicht verteilte Talentpunkte"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Du hast derzeit kein nützliches Futter für dein Tier."
L["TIP_PET_NO_SKILLS"] =
	"Du kennst derzeit keinen der Zauber Tier rufen, Tier freigeben, Tier füttern oder Tier wiederbeleben."
L["TIP_PET_NO_MEND"] = "Du kennst Tier heilen derzeit nicht."
L["TIP_NO_HAND_POISON"] = "Für diese Waffe ist das gewählte Gift aufgebraucht."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Du kennst %s derzeit nicht."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "Buff-Essen"
L["MENU_BUFF_FOOD_DESCRIPTION"] = 'Bevorzugt Essen, das den "Satt"-Buff gewährt, wenn der Buff fehlt.'
L["FEATURE_SCROLL_BUFFS"] = "Schriftrollen-Buffs"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] = "Wendet mit deinem Essen-Makro fehlende Schriftrollen-Buffs an, bevor du isst."

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Attention Hunters block, and the two poison titles open the
    Attention Rogues block.
]]
L["MINIMAP_BEST_FOOD"] = "Aktuelles Essen"
L["MINIMAP_BEST_PET_FOOD"] = "Aktuelles Tierfutter"
L["MINIMAP_MAIN_HAND_POISON"] = "Waffenhand-Gift"
L["MINIMAP_OFF_HAND_POISON"] = "Schildhand-Gift"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Ignorierliste"
L["MINIMAP_IGNORE_COUNT"] = "%d Gegenstände"
L["MENU_IGNORE"] = "Ignorieren"
L["MENU_CLEAR_IGNORE"] = "Ignorierliste leeren"

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
    row, on a wrapping line of its own, so it can be a full sentence. EMPTY is
    the line under the header when the list holds nothing at all, which is not
    the same as being stocked.

    ITEM_COUNT is the right-hand value of a listed row: { have, wanted }, the
    ratio RESTOCKER_REMINDER_ITEM prints. Wordless, so there is nothing to
    translate, but a key anyway for the same reason that one is.
]]
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker-Bericht"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d offene Posten"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Glückwunsch, deine Vorräte sind vollständig aufgefüllt!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Deine Liste ist leer."

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Restocker-Liste"
L["MENU_RESTOCKER_DESCRIPTION"] = "Kauft die Gegenstände auf deiner Liste und lagert sie in der Bank."
L["MENU_RESTOCKER_KEYBIND"] = "Shift + Rechtsklick"
L["MENU_OPTIONS"] = "Connoisseur-Optionen"
L["MENU_OPTIONS_KEYBIND"] = "Shift + Mittelklick"

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The class block of the mini-map tooltip: a class-colored header, the items
    the class's own macro will use (a Hunter's pet food, a Rogue's two poisons,
    titled in the Minimap Tooltip section above), then one group per macro.
]]

L["PREFIX_HUNTER"] = "Achtung Jäger"
L["PREFIX_MAGE"] = "Achtung Magier"
L["PREFIX_ROGUE"] = "Achtung Schurken"
L["PREFIX_WARLOCK"] = "Achtung Hexenmeister"

--[[
    A group is the macro's name, then one row per click: the click on the left
    and what it does on the right. The right-hand column never wraps, so each
    result stays a few words. A spell the row casts is named by the client
    (Mend Pet, Ritual of Refreshment, Ritual of Souls) and has no key here, and
    a plain click reuses MINIMAP_LEFT_CLICK, MINIMAP_RIGHT_CLICK or
    MINIMAP_MIDDLE_CLICK.
]]
L["NOTE_MACRO_FEED_PET"] = "Tier-füttern-Makro"
L["NOTE_MACRO_FOOD_WATER"] = "Essen- und Wasser-Makros"
L["NOTE_MACRO_MANA_GEM"] = "Manastein-Makro"
L["NOTE_MACRO_HEALTHSTONE"] = "GS-Makro"
L["NOTE_MACRO_SOULSTONE"] = "Seelenstein-Makro"
L["NOTE_MACRO_POISONS"] = "Gifte-Makro"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Rufen, füttern oder wiederbeleben"
L["NOTE_PET_MEND_CLICK"] = "Rechtsklick oder im Kampf"
L["NOTE_HOLD_SHIFT"] = "Shift halten"
L["NOTE_PET_FORCE_REVIVE"] = "Wiederbeleben erzwingen"
L["NOTE_HOLD_CONTROL"] = "Strg halten"
L["NOTE_PET_DISMISS"] = "Freigeben"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Herbeizaubern"
L["NOTE_CREATE"] = "Herstellen"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Erneuter Rechtsklick"
L["NOTE_LOWER_RANK_BACKUP"] = "Ersatz niedrigeren Ranges"
L["NOTE_MAGE_TARGET_LEVEL"] =
	"Visiere einen Spieler niedrigerer Stufe an, um Essen oder Wasser für dessen Stufe herbeizuzaubern."
L["NOTE_WARLOCK_TARGET_LEVEL"] =
	"Visiere einen Spieler niedrigerer Stufe an, um einen Gesundheitsstein für dessen Stufe herzustellen."

-- Rogue. The two hands are the results of a Left-Click and a Right-Click on the Poisons macro.
L["MINIMAP_MAIN_HAND"] = "Waffenhand"
L["MINIMAP_OFF_HAND"] = "Schildhand"
L["NOTE_POISONS_WINDOW"] = "Gifte-Fenster"
L["NOTE_POISONS_REPLACED"] = "Ersetzt alte Gifte automatisch."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Verband"
L["LABEL_EXPLOSIVE"] = "Sprengstoff"
L["LABEL_FOOD"] = "Essen"
L["LABEL_HEALTH_POTION"] = "Heiltrank"
L["LABEL_HEALTHSTONE"] = "Gesundheitsstein"
L["LABEL_MANA_GEM"] = "Manastein"
L["LABEL_MANA_POTION"] = "Manatrank"
L["LABEL_PET_FOOD"] = "Tierfutter"
L["LABEL_POISONS"] = "Gift"
L["LABEL_SOULSTONE"] = "Seelenstein"
L["LABEL_WATER"] = "Wasser"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Aktiviert"
L["MINIMAP_DISABLED"] = "Deaktiviert"
L["MINIMAP_TOGGLE"] = "Umschalten"
L["MINIMAP_OPEN"] = "Öffnen"
L["MINIMAP_LEFT_CLICK"] = "Linksklick"
L["MINIMAP_RIGHT_CLICK"] = "Rechtsklick"
L["MINIMAP_MIDDLE_CLICK"] = "Mittelklick"
L["MINIMAP_SHIFT_LEFT"] = "Shift + Linksklick"

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

    In the mini-map tooltip, a Buff Food or Scroll Buffs switch that is on
    while its choice does not apply shows the choice's label in place of
    MINIMAP_ENABLED, so every label has to read as a state too.
]]
L["OPTIONS_MODE_DESCRIPTION"] =
	'Legt fest, wann dein Essen-Makro "%s" anbietet: immer oder nur beim Solospiel, in einer Gruppe oder einem Schlachtzug, im Schlachtzug, beim Leveln oder auf Höchststufe.'
L["MODE_ALWAYS"] = "Immer"
L["MODE_SOLO"] = "Beim Solospiel"
L["MODE_PARTY"] = "In Gruppe oder Schlachtzug"
L["MODE_RAID"] = "Im Schlachtzug"
L["MODE_LEVELING"] = "Beim Leveln"
L["MODE_MAX_LEVEL"] = "Auf Höchststufe"

--------------------------------------------------------------------------------
-- Inventory Report
--------------------------------------------------------------------------------

--[[
    The block Features/Inventory-Report.lua adds under an item's own tooltip
    lines. Its header is "Connoisseur & Restocker // Inventory Report": the
    brand below, filled with ADDON_TITLE and TAB_RESTOCKER, then the title, in
    the chat prints' branded colors. Under it, each line is a label on the left
    with its count at the right edge: Bags, Bank, one line per other character
    (the client's own character names, so no keys here), then Total.

    Keep the labels to a word: they share a line with a number, and the tooltip
    is as wide as its longest line. The Bags count of a Restock List item is the
    have/keep ratio MINIMAP_RESTOCKER_ITEM_COUNT prints.
]]
-- { add-on name, feature name }
L["INVENTORY_REPORT_BRAND"] = "%s & %s"
L["INVENTORY_REPORT_TITLE"] = "Inventarbericht"
L["INVENTORY_REPORT_BAGS"] = "Taschen"
L["INVENTORY_REPORT_BANK"] = "Bank"
-- In place of the Bank count, muted, until this character's bank has been opened once with the add-on running.
L["INVENTORY_REPORT_BANK_UNKNOWN"] = "Unbekannt"
-- Everything above it added up: this character and every other one on the realm.
L["INVENTORY_REPORT_TOTAL"] = "Gesamt"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Makros, die automatisch dein bestes Essen, Wasser, Tränke, Gesundheitssteine, Verbände, Gifte und Tierfutter verwenden, dazu eine Nachschubliste, die deine Verbrauchsgegenstände automatisch kauft, in der Bank lagert und mit deiner Stufe aufwertet. Komfort-Automatisierung für Höchstleistung."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Willkommensnachricht aktivieren"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Gibt beim Anmelden eine Willkommensnachricht im Chat aus."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Minikarten-Button aktivieren"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Zeigt den Minikarten-Button an."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Öffnet das Optionsmenü dieses Add-ons."
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Öffnet deine Nachschubliste."

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "Feedback und Unterstützung"
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
L["TAB_MACROS"] = "Makros"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur erstellt ein Makro pro Verbrauchsgegenstand und hält es aktuell, während sich deine Taschen ändern, damit der Button auf deiner Leiste immer zum besten Gegenstand greift, den du dabeihast. Wähle unten, welche Makros erstellt werden, und lege dann fest, wie jedes seinen Gegenstand auswählt."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Makronamen auf Buttons aktivieren"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Zeigt den Makronamen-Text auf den Buttons deiner Aktionsleisten an, den Connoisseur standardmäßig ausblendet."

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "Makros aktivieren"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Wähle, welche Makros Connoisseur erstellt und pflegt. Wenn du eines deaktivierst, wird es auch entfernt."
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] =
	"Erstellt und pflegt dieses Makro und entfernt es, wenn du das Kästchen abwählst."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Essen und Wasser"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Deine Essen- und Wasser-Makros verwenden das beste Essen und die besten Getränke in deinen Taschen. Diese Optionen können Buff-Essen, Schriftrollen oder herbeigezaubertes Essen und Wasser an die erste Stelle und Essen und Wasser der Nachschubliste an die letzte Stelle setzen."

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Buff-Essen bevorzugen"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'Bevorzugt Essen, das den "Satt"-Buff gewährt, wenn der Buff fehlt, außer in Arenen.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Schriftrollen-Buffs aktivieren"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Dein Essen-Makro wendet beim ersten Drücken fehlende Schriftrollen an und lässt dich beim nächsten essen, überspringt die Schriftrollen aber, wenn du einen befreundeten Spieler anvisierst oder in einer Arena bist."
L["OPTIONS_SCROLL_TYPES"] = "Schriftrollentypen in Prüfung einschließen"
L["OPTIONS_SCROLL_AGILITY"] = "Beweglichkeit"
L["OPTIONS_SCROLL_INTELLECT"] = "Intelligenz"
L["OPTIONS_SCROLL_PROTECTION"] = "Schutz"
L["OPTIONS_SCROLL_SPIRIT"] = "Willenskraft"
L["OPTIONS_SCROLL_STAMINA"] = "Ausdauer"
L["OPTIONS_SCROLL_STRENGTH"] = "Stärke"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = 'Schließt "%s" in die Prüfung auf fehlende Buffs ein.'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Herbeigezaubertes Essen und Wasser zuerst verwenden"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Deine Essen- und Wasser-Makros verwenden herbeigezaubertes Essen und Wasser vor allem anderen, auch wenn etwas in deinen Taschen mehr wiederherstellt, denn es kostet nichts und verschwindet kurz nach dem Ausloggen. Buff-Essen hat weiterhin Vorrang, solange "Buff-Essen bevorzugen" aktiviert ist.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Legt fest, wann herbeigezaubertes Essen und Wasser Vorrang haben: immer oder nur beim Solospiel, in einer Gruppe oder einem Schlachtzug, im Schlachtzug, beim Leveln oder auf Höchststufe."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "Essen und Wasser der Nachschubliste zuletzt verwenden"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Von zwei Speisen oder Getränken, die gleich viel wiederherstellen, verwenden deine Essen- und Wasser-Makros diejenige, die nicht auf deiner Nachschubliste steht. So bleibt, was die Nachschubliste kauft, für später."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Tränke und Gesundheitssteine"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Makros können während des Kampfes nicht geändert werden (dies ist eine Blizzard-Einschränkung). Daher wird jedes Trank- und Gesundheitsstein-Makro im Voraus mit deinem besten Gegenstand und bis zu zwei Ersatzgegenständen erstellt. Bei längeren Kämpfen können das Symbol und der Tooltip veralten und den falschen Gegenstand anzeigen, aber ein Klick auf das Makro verwendet immer den besten Gegenstand, den du tatsächlich in deinen Taschen hast."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Essen und Wasser außerhalb des Kampfes in Trank-Makros verwenden"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Außerhalb des Kampfes isst du mit deinem Heiltrank-Makro dein bestes Essen und trinkst mit deinem Manatrank-Makro dein bestes Wasser. Im Kampf verwenden die Makros wie bisher deine Tränke. Schriftrollen, Tierfutter und das Herbeizaubern bleiben bei den Essen- und Wasser-Makros."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Gesundheitssteine mit Heiltrank-Makro kombinieren"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Fügt deinen besten Gesundheitsstein unten an das Heiltrank-Makro an, sodass ein Tastendruck einen Trank und einen Gesundheitsstein verwendet."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Manasteine und Runen"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"Dämonische Runen und Dunkelrunen sowie einige andere Mana-Gegenstände teilen sich die Abklingzeit mit Manasteinen. Die Runen kosten bei der Verwendung Gesundheit, daher lässt das Manastein-Makro all diese Gegenstände weg, solange du sie nicht hinzufügst."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Runen und andere Mana-Gegenstände zum Manastein-Makro hinzufügen"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"Nimmt deine Dämonischen Runen und Dunkelrunen sowie jeden anderen Mana-Gegenstand, der sich die Abklingzeit mit Manasteinen teilt, in die Rangfolge deiner Manasteine auf, sodass das Manastein-Makro einen davon verwendet, wenn das deine beste Wahl ist oder du keine Manasteine mehr hast."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Buff-Erneuerung"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Makros können während des Kampfes nicht geändert werden, daher bleibt ein Buff, der mitten im Kampf abläuft, bis zum Ende des Kampfes weg."
L["OPTIONS_REAPPLY"] = "Ablaufende Buffs erneuern"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Behandelt Buff-Essen, Schriftrollen-Buffs und Tierfutter-Buffs mit weniger Restzeit als deinem Schwellenwert als abgelaufen, sodass deine Makros vor dem Pull einen frischen anbieten."
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie kurz ein Buff vor dem Ablaufen stehen darf, bevor deine Makros einen frischen anbieten."
L["REAPPLY_THRESHOLD_ONE"] = "Wenn < 1 Minute übrig"
L["REAPPLY_THRESHOLD_MANY"] = "Wenn < %d Minuten übrig"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Tierfutter-Buffs"
L["OPTIONS_PET_SECTION_DESCRIPTION"] = 'Ein paar Futtersorten verleihen deinem Tier einen eigenen "Satt"-Buff.'
L["OPTIONS_USE_PET_BUFFS"] = "Tierfutter-Buffs verwenden"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	'Fügt deinem Essen-Makro Tierfutter hinzu, wenn deinem Tier der "Satt"-Buff fehlt, außer in Arenen.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Tierfutter-Arten in Prüfung einschließen"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Sprengstoff"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"Die @player-Option überspringt den Zielkreis und zündet den Sprengstoff direkt zu deinen Füßen. Ideal, wenn dein Ziel in Nahkampfreichweite ist. Der andere Klick wirft ihn wie gewohnt."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Klickbelegung"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Legt fest, welcher Klick den Sprengstoff wirft und welcher ihn zu deinen Füßen zündet."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Linksklick @player"
L["EXPLOSIVES_MODE_TOSS"] = "Linksklick Werfen"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "Druiden"
L["OPTIONS_DRUID_MACRO_HELPER"] = "DruidMacroHelper-Integration aktivieren"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Erstellt Powershifting-Makros für Heiltränke, Manatränke und Gesundheitssteine mithilfe von DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Legt fest, in welche Gestalt dich deine Powershifting-Makros nach dem Verwenden des Gegenstands zurückverwandeln."
L["DRUID_FORM_BEAR"] = "Zurück in Bärengestalt"
L["DRUID_FORM_CAT"] = "Zurück in Katzengestalt"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "Schurken"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Hält das Gifte-Makro mit dem besten nutzbaren Rang jedes Gifttyps bestückt. Linksklick trägt auf die Schildhand auf, Rechtsklick auf die Waffenhand; vorhandene Gifte werden automatisch ersetzt."
L["OPTIONS_POISON_MAIN_HAND"] = "Gifttyp Waffenhand"
L["OPTIONS_POISON_OFF_HAND"] = "Gifttyp Schildhand"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Legt fest, welches Gift dein Gifte-Makro per Rechtsklick auf deine Waffenhand aufträgt."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Legt fest, welches Gift dein Gifte-Makro per Linksklick auf deine Schildhand aufträgt."
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "Verstohlenes Essen aktivieren"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] =
	"Fügt Verstohlenheit zu deinem Essen-Makro hinzu, damit du beim Essen verborgen bist."

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "Nachtelfen"
L["OPTIONS_STEALTH_DRINKING"] = "Verstohlenes Trinken aktivieren"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] =
	"Fügt Schattenhaftigkeit zu deinem Wasser-Makro hinzu, damit du beim Trinken verborgen bist."
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] =
	"Fügt Schattenhaftigkeit zu deinem Essen-Makro hinzu, damit du beim Essen verborgen bist."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Profi-Tipp: Wähle eines. Du kannst gleichzeitig essen und trinken, aber Essen oder Trinken nach dem Verstecken beendet deine Tarnung."

--[[
    Ignore List panel (Options-Ignore-List.lua). One tree scope per list: the
    Global list, then the character playing and every other character with
    something ignored, each under its profile's name, which is never
    translated and has no key here. The rows are items, so the copy here is
    the panel description, the scope and promote labels, the add box, Remove,
    the empty-list line, and LOADING_ITEM, the placeholder shown while the
    client is still resolving an item's name (the mini-map tooltip, the Macros
    panel, and the staples pop-up use it too). The mini-map tooltip's section
    keeps its own MINIMAP_IGNORE_LIST and MENU_CLEAR_IGNORE keys.
]]
L["TAB_IGNORE_LIST"] = "Ignorierliste"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Ignorierte Gegenstände werden von keinem Makro ausgewählt. Essen, Wasser, Tränke, alles. Die Global-Liste gilt für jeden Charakter; die Liste eines Charakters gilt nur für diesen einen. Rechtsklicke auf den Minikarten-Button, um dein aktuell bestes Essen zu ignorieren."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Verschiebt diesen Gegenstand auf die Global-Liste, sodass er auf jedem Charakter ignoriert wird."
L["OPTIONS_IGNORE_ADD_ID"] = "Per Gegenstands-ID hinzufügen"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Gib eine Gegenstands-ID ein oder mache Shift + Klick auf einen Gegenstandslink im Chat, während dieses Feld ausgewählt ist."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"Gib eine Gegenstands-ID ein oder mache Shift + Klick auf einen Gegenstandslink im Chat."
L["OPTIONS_IGNORE_REMOVE"] = "Entfernen"
L["OPTIONS_IGNORE_EMPTY"] = "Diese Liste ist leer."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Lade ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Hält deine Taschen anhand deiner Nachschubliste gefüllt, indem automatisch bei Händlern eingekauft und Gegenstände zwischen Taschen und Bank verschoben werden. Gib %s ein, um die Liste zu öffnen."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Bei der Bank öffnen"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Öffnet deine Nachschubliste, wenn du die Bank besuchst."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Beim Händler öffnen"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Öffnet deine Nachschubliste, wenn du einen Händler besuchst."
L["OPTIONS_RESTOCKER_REMIND"] = "Nachschub-Erinnerungen in der Stadt aktivieren"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Gibt eine Chat-Erinnerung aus, wenn deiner Nachschubliste etwas fehlt und du ein Gasthaus oder eine Stadt erreichst oder dich beim Anmelden bereits dort befindest."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Nachschub-Erinnerungen beim Händler aktivieren"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Meldet alle offenen Nachschubposten, wenn du ein Händlerfenster schließt."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Nachschub-Erinnerungen bei der Bank aktivieren"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "Meldet alle offenen Nachschubposten, wenn du die Bank schließt."

--[[
    The staples pop-up (STARTER_POPUP_TITLE below). This toggle and the
    pop-up's own "Don't Show This Again" box are the same per-character choice
    read from opposite ends, which is why one ships on and the other off: a
    settings row reads naturally as "enable", a dismissal reads naturally as
    "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] = "Grundvorräte-Fenster aktivieren, wenn die Nachschubliste leer ist"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"Bietet beim Anmelden die Grundvorräte für deine Klasse an, wenn die Nachschubliste dieses Charakters leer ist."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Legt fest, ob die Erinnerung nur eine Zeile umfasst oder für jeden fehlenden Gegenstand eine Zeile hinzufügt."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Einfach"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Ausführlich"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Ton abspielen"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Spielt zusätzlich zur Erinnerung einen Hinweiston ab, falls im Chat gerade viel los ist."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Klicke, um den Hinweiston zu hören."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Fenster der Nachschubliste"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Wähle, wann sich deine Nachschubliste von selbst öffnet."

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Zeigt im Tooltip eines Gegenstands an, wie viele davon du auf all deinen Charakteren dieses Realms besitzt."
L["OPTIONS_INVENTORY_REPORT"] = "Inventarbericht in Gegenstands-Tooltips aktivieren"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"Fügt dem Tooltip eines Gegenstands hinzu, wie viele davon du in deinen Taschen, in deiner Bank und auf deinen anderen Charakteren hast. Deaktiviere den Bericht, wenn bereits ein anderes Add-on diese Zahlen anzeigt."

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Danksagung"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"Ich habe Restocker schon immer geliebt und bin dankbar für die Gelegenheit, ihn in Connoisseur weiterleben zu lassen. Ein riesiges Dankeschön an ChiliFajita für den ursprünglichen Auto Restocker und an kvakvs und guardycmw, die ihn durch Classic und Mists of Pandaria am Leben gehalten haben."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Bereitschaftsbericht"
L["OPTIONS_READINESS_ENABLE"] = "Bereitschaftsbericht beim Bereitschaftscheck aktivieren"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] = "Aktiviert den Bereitschaftsbericht für alle Charaktere dieses Accounts."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Gibt beim Start eines Bereitschaftschecks eine private Liste dessen aus, was noch behoben werden muss, und bleibt komplett still, wenn du bereit bist."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Bereitschaftsbericht-Einstellungen zurücksetzen"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Setzt jedes Kontrollkästchen und beide Schwellenwerte auf dieser Seite auf ihre Standardwerte zurück und lässt alle anderen Seiten unverändert."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Alle Einstellungen des Bereitschaftsberichts auf ihre Standardwerte zurücksetzen? Das schaltet auch den Bericht selbst wieder aus."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Fehlende Buffs"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Fehlende Gegenstände"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Charakter"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Meldet ein fehlendes Fläschchen. Ein Fläschchen oder je ein Kampf- und ein Wächterelixier gelten als abgedeckt."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	'Meldet einen fehlenden "Satt"-Buff. Erfordert aktiviertes Buff-Essen unter Makros.'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	'Meldet den fehlenden "Satt"-Buff deines Tiers. Erfordert aktivierte Tierfutter-Buffs unter Makros und ein herbeigerufenes Tier.'
L["OPTIONS_READINESS_SCROLLS"] = "Schriftrollen-Buffs"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Meldet fehlende Schriftrollen-Buffs. Erfordert aktivierte Schriftrollen-Buffs unter Makros und prüft nur die dort ausgewählten Schriftrollentypen."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Meldet sich, wenn auf niemandem in deiner Gruppe ein Seelenstein aktiv ist; einer in einer Tasche zählt nicht. Wird nur einem Hexenmeister angezeigt, der einen herstellen kann."
L["OPTIONS_READINESS_MAIN_HAND"] = "Waffenbuff (Waffenhand)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Meldet eine Waffe in der Waffenhand ohne temporäre Verzauberung. Jede Verzauberung zählt, und der Bericht schweigt dazu, wenn ein Schamane in deiner Gruppe ist."
L["OPTIONS_READINESS_OFF_HAND"] = "Waffenbuff (Schildhand)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Meldet eine Waffe in der Schildhand ohne temporäre Verzauberung. Jede Verzauberung zählt: ein Stein, ein Öl, ein Gift oder ein Schamanen-Waffenbuff."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Ablaufende Buffs innerhalb von"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"Nennt jeden Buff auf dir, der bald abläuft, nicht nur die von Connoisseur angewendeten, und ist unabhängig von der Buff-Erneuerung unter Makros."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s Minuten"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 Minute"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie kurz ein Buff vor dem Ablaufen stehen muss, damit der Bericht ihn nennt."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Gesundheitsstein dabeihast. Wird nur angezeigt, wenn ein Hexenmeister in deiner Gruppe ist, den man fragen kann, oder wenn du selbst der Hexenmeister bist."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Manastein dabeihast. Wird nur einem Magier angezeigt, der einen herbeizaubern kann."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Heiltrank dabeihast, denn mitten im Kampf kann dir niemand einen reichen."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Manatrank dabeihast. Wird nur angezeigt, wenn du eine Klasse spielst, die Mana verwendet."
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] =
	"Meldet sich, wenn du keinen Verband dabeihast, den du mit deiner Erste-Hilfe-Fertigkeit verwenden kannst."
L["OPTIONS_READINESS_DURABILITY"] = "Beschädigte Ausrüstung unter"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Verlinkt jeden angelegten Gegenstand unter dieser Haltbarkeit, pro Gegenstand gemessen, damit auch eine einzelne kaputte Waffe auftaucht."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Legt fest, wie tief die Haltbarkeit eines Gegenstands sinken muss, damit der Bericht ihn verlinkt."

-- Character
L["OPTIONS_READINESS_SPEC"] = "Aktuelle Skillung"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] =
	"Gibt deine Talentverteilung aus sowie alle Punkte, die du noch nicht verteilt hast."
L["OPTIONS_READINESS_PVP"] = "PvP-Status aktiv"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Warnt, wenn dein PvP-Status aktiv ist."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Nicht kampftaugliche Ausrüstung angelegt"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"Verlinkt angelegte Gegenstände, die nicht in einen Kampf gehören, etwa eine Reitgerte oder eine Angel."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Eine Liste namens "%s" existiert bereits.'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "Es gibt keine ID %d."
L["RESTOCKER_BANK_NOT_OPEN"] = "Die Bank ist nicht geöffnet."
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Auffüllen abgeschlossen. Halte Shift beim Öffnen der Bank, um das Auffüllen zu überspringen. Gib %s ein, um deine Nachschubliste zu bearbeiten."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Auffüllen gestoppt. Deine Taschen und deine Bank sind voll."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Auffüllen gestoppt. Deine Bank ist voll; mache einen Platz frei und öffne sie erneut."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Auffüllen gestoppt. Deine Taschen sind voll; mache einen Platz frei und öffne die Bank erneut."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Auffüllen gestoppt. Es konnte kein Fortschritt erzielt werden."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Auffüllen gestoppt. Konnte nicht verschieben: %s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (überschüssig)"
L["RESTOCKER_STOPPED_ERROR"] = "Auffüllen wegen eines Fehlers gestoppt: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Dieser Händler führt nicht alle Zutaten, die deine Gifte benötigen. Es wird keine davon gekauft."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Vergiss nicht, deine Vorräte aufzufüllen, solange du in der Stadt bist!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 Nachschubposten offen."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d Nachschubposten offen."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Deine Nachschubliste wurde aufgewertet."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d wird zu %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 Nachschubposten erfüllt."
L["RESTOCKER_RESTOCKED_MANY"] = "%d Nachschubposten erfüllt."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 Nachschubposten teilweise erfüllt."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d Nachschubposten teilweise erfüllt."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Deine Taschen waren voll, bevor alles gekauft war."

-- /crs help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[Name]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Legt eine Liste mit diesem Namen an."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Löscht die Liste mit diesem Namen."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Benennt die aktuelle Liste auf diesen Namen um."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Ersetzt die aktuelle Liste durch eine Kopie der Liste mit diesem Namen."
L["RESTOCKER_HELP_PROFILE_USE"] = "Weist diesem Charakter die Liste mit diesem Namen zu."

--[[
    Starter List pop-up, the staples window: offers staples at login when the
    Restock List is empty, and on demand from the Restock List window's Pick
    Staples button (Features/Restocker/Restocker-Starter-List.lua). The six
    food staples reuse the DIET_ keys above, so each food row carries the
    client's own pet diet name.

    The title is its own, and carries the add-on's name: at login this window
    opens with nothing else of Connoisseur's on screen, so its title bar is
    all that says whose it is.

    The intro is one paragraph: an opening sentence that answers to how the
    window was reached (EMPTY over an empty list, STOCKED over one that has
    items), then HOW, which says what a check does. The two are run together
    with a space at the call site, so each has to stand as whole sentences.
    The way back in (COMMAND_HINT) is a second paragraph, shown only when the
    window opened by itself at login; from the Pick Staples button the list it
    names is open right behind it.
]]
L["STARTER_POPUP_TITLE"] = "Connoisseur-Grundvorräte"
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Deine Nachschubliste ist leer, also lass uns ein paar Gegenstände hinzufügen, damit du loslegen kannst."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Wähle die Grundvorräte, die aufgefüllt bleiben sollen."
L["STARTER_POPUP_INTRO_HOW"] =
	"Alles, was du anhakst, wird automatisch aufgefüllt, sobald du einen Händler oder deine Bank öffnest. Standardwaren werten sich mit deiner Stufe von selbst auf, sodass du immer das Beste dabeihast."
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Du kannst diese Liste jederzeit anpassen oder später weitere Gegenstände hinzufügen, indem du %s eingibst."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Essen und Wasser"
L["STARTER_POPUP_FOOD_HEADER"] = "Essen"
L["STARTER_POPUP_AMMO_HEADER"] = "Munition"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Kugeln"
L["STARTER_POPUP_ARROWS"] = "Pfeile"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header reuses PREFIX_ROGUE (rogue-colored at the call
    site) to say the ingredients take care of themselves. Both sections name
    their rows with the client's own item names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagenzien und Werkzeuge"
L["STARTER_POPUP_POISONS_HEADER"] = "Gifte"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Setze das fertige Gift auf deine Liste, und Connoisseur kauft die Zutaten automatisch bei jedem Händler, der sie alle führt."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Fügt %s zu deiner Nachschubliste hinzu, hält %d davon in deinen Taschen und wertet sie mit deiner Stufe auf."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] =
	"Fügt %s zu deiner Nachschubliste hinzu und hält %d in deinen Taschen bereit."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 Stapel"
L["STARTER_POPUP_STACK_MANY"] = "%d Stapel"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Wie viele Stapel vorrätig bleiben sollen, wobei ein Stapel %d Stück umfasst."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Wie viele vorrätig bleiben sollen, jeweils auf einem eigenen Taschenplatz, da sie sich nicht stapeln lassen."
L["STARTER_POPUP_DISMISS"] = "Für diesen Charakter nicht mehr anzeigen"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] =
	"Verhindert, dass diese Vorschläge bei einer Anmeldung erneut erscheinen, bei der deine Nachschubliste leer ist."

-- Restock List window UI. The title names what the window holds; the feature that acts on it stays "Restocker".
L["RESTOCKER_WINDOW_TITLE"] = "Connoisseur-Nachschubliste"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Gegenstände filtern..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Leeren"
L["RESTOCKER_ADD_BUTTON"] = "Hinzufügen"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. The keys keep the pop-up's
    earlier name, the List Builder. "Check" is the pop-up's own word
    (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "Grundvorräte wählen"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"Wähle aus den Grundvorräten für deine Klasse und Stufe: Essen, Wasser, Munition, Gifte und Reagenzien. Was du anhakst, wird dieser Liste hinzugefügt, und was du abwählst, wird entfernt."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Gegenstand hinzufügen"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Ziehe einen Gegenstand aus deinen Taschen hierher oder irgendwo auf dieses Fenster, oder gib eine Gegenstands-ID ein und drücke Enter."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Ziehen oder ID eingeben"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Stattdessen ID eingeben."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Aus Taschen hinzufügen"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Alle Gegenstände in deinen Taschen, die noch nicht auf dieser Liste stehen. Klicke auf einen, um ihn hinzuzufügen."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nichts in deinen Taschen zum Hinzufügen"

--[[
    The list bar across the top of the window: the selector, the characters on
    the list, and Manage Lists.

    USED_BY's %s is those characters, the client's own names joined with
    LIST_SEPARATOR, which also joins them on the selector's menu and in the
    delete confirmation. Each name is colored by its class at the call site.
    Keep USED_BY short: the line shares its row with the selector and the
    Manage Lists button, and truncates when it outgrows the space. MANAGE is
    that button's caption and the title of its tooltip.
]]
L["RESTOCKER_PROFILE_LABEL"] = "Liste"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Klicke, um diesem Charakter eine andere Nachschubliste zuzuweisen oder eine neue anzulegen."
L["RESTOCKER_USED_BY"] = "Genutzt von %s"
L["RESTOCKER_MANAGE"] = "Listen verwalten"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Lege eine neue Liste an oder kopiere diese, benenne sie um oder lösche sie."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu. The Copy and Delete keys end in
    _TOOLTIP because they began as the tooltips of two buttons this menu
    replaced.
]]
L["RESTOCKER_NEW_PROFILE"] = "Neue Liste"
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "Diese Liste in eine neue kopieren"
L["RESTOCKER_RENAME_PROFILE"] = "Diese Liste umbenennen"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "Diese Liste löschen"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Kopie"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Umbenennen"
L["RESTOCKER_RENAME_TOOLTIP"] = "Benennt diese Liste für jeden Charakter um, der sie verwendet."
--[[
    The delete confirmation, a paragraph per fact, joined with blank lines in
    code: QUESTION, the list's name (colored at the call site), what happens
    next, and FINAL.

    "What happens next" is SHARED followed by SWITCH or LAST, run together as
    one paragraph, so each has to stand as a full sentence. SHARED appears only
    when other characters are on the list; its %s is their names, joined with
    LIST_SEPARATOR, and ONE or MANY follows how many there are.

    SWITCH says where this character lands: %s is the top list in the List
    selector, colored at the call site. LAST stands in for it when the list
    being deleted is the only one, which is the one delete that makes a list.
]]
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Möchtest du diese Liste wirklich löschen?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s nutzt sie ebenfalls und findet beim nächsten Anmelden eine leere Liste mit demselben Namen vor."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s nutzen sie ebenfalls und finden beim nächsten Anmelden jeweils eine leere Liste mit demselben Namen vor."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Du wechselst dann zu %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "Es ist die einzige verbliebene Liste, daher beginnst du mit einer neuen, leeren."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Das kann nicht rückgängig gemacht werden."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Mit steigender Stufe aufwerten"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Erlaubt Connoisseur, Essen, Wasser, Munition, Gifte, Tränke und Klassenreagenzien mit steigender Stufe auf bessere Gegenstände aufzuwerten."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Bank"
L["RESTOCKER_ROW_MERCHANT"] = "Händler"
L["RESTOCKER_ROW_UPGRADE"] = "Aufwertung"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Gegenstand"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Holen"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Lagern"
L["RESTOCKER_COLUMN_REPUTATION"] = "Ruf"
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Behalten"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Klicke auf die Überschrift, um dies für alle angezeigten Gegenstände festzulegen."
L["RESTOCKER_BULK_ON"] = "%d angezeigte aktivieren"
L["RESTOCKER_BULK_OFF"] = "%d angezeigte deaktivieren"

L["RESTOCKER_GROUP_OTHER"] = "Sonstiges"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Neu"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Alle Gegenstände"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_LIST_BUILDER_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Noch nichts auf dieser Liste"
L["RESTOCKER_EMPTY_BODY"] =
	"Wähle Grundvorräte wie Essen, Wasser oder Klassenreagenzien aus, oder füge über das Menü oben beliebige Gegenstände aus deinen Taschen hinzu. Ausgewählte Gegenstände werden automatisch aufgefüllt oder in deiner Bank eingelagert, damit deine Taschen aufgeräumt bleiben."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Gegenstände, die du irgendwo auf dieses Fenster ziehst, werden auch hinzugefügt."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nichts auf dieser Liste passt zu deinem Filter."
L["RESTOCKER_NO_MATCH_GROUP"] = "In dieser Kategorie ist nichts mehr übrig."

--[[
    The status line under the list. The orders count itself is
    RESTOCKER_STILL_SHORT_ONE / _MANY above, and the all-stocked line is
    MINIMAP_RESTOCKER_STOCKED, so the window, the reminders and the mini-map
    tooltip say the same thing in the same words.

    NO_ORDERS is the in-between: nothing for a merchant to fill, but a row with
    Buy off is still short in the bags (its Keep number is yellow), so the
    congratulation would be untrue. "Outstanding" stays beside the noun, as in
    the counts.

    REPORT_MORE closes the orders tooltip when the list is longer than it shows:
    %d is how many were left out. REMOVED_ITEM's %s is the item's icon and name,
    and UNDO is the button beside it that puts the item back; UNDO_TOOLTIP
    renders in the title slot.
]]
L["RESTOCKER_NO_ORDERS"] = "Keine Nachschubposten offen."
L["RESTOCKER_REPORT_MORE"] = "und %d weitere"
L["RESTOCKER_REMOVED_ITEM"] = "%s entfernt."
L["RESTOCKER_UNDO"] = "Rückgängig"
L["RESTOCKER_UNDO_TOOLTIP"] = "Diesen Gegenstand wieder auf die Liste setzen"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Diesen Gegenstand von der Nachschubliste entfernen"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Du kannst das unten im Fenster rückgängig machen."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "In deinen Taschen behalten"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"Wie viele du in deinen Taschen behalten willst. Die Zahl wird gelb, solange deine Taschen weniger enthalten, und eine 0 schickt bei aktiviertem Lagern alles in die Bank."
L["RESTOCKER_BUY_LABEL"] = "Kaufen"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Beim Händler kaufen"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "Kauft die benötigte Menge beim Händler, wenn das Händlerfenster geöffnet ist."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Extra kaufen"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Kauft den gesamten begrenzten Vorrat eines Händlers an diesem Gegenstand, also Ware, die er nur nach und nach wieder auffüllt, auch über deinen Behalten-Wert hinaus."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "In der Bank lagern"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Lagert überschüssige Gegenstände in der Bank, wenn die Bank geöffnet ist, oder alle, wenn in der Behalten-Spalte 0 steht."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Aus der Bank holen"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Holt benötigte Gegenstände aus der Bank, wenn die Bank geöffnet ist."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Benötigter Ruf"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% Rabatt)"
L["RESTOCKER_REPUTATION_ANY"] = "Beliebig"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "Freundlich"
L["RESTOCKER_REPUTATION_HONORED"] = "Wohlwollend"
L["RESTOCKER_REPUTATION_REVERED"] = "Respektvoll"
L["RESTOCKER_REPUTATION_EXALTED"] = "Ehrfürchtig"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Benötigter Ruf beim Händler"
--[[
    Quotes the cell's own values, which couples this line to the four standings
    above: a locale that renders a standing differently has to say so here too.
    With no standing required the cell draws a dash rather than the word "Any",
    which is why the last sentence names the dash; "Any" is still the menu's
    first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	"Klicke, um festzulegen, welchen Ruf ein Händler voraussetzt, bevor Connoisseur bei ihm kauft, was auch den Preis senkt: Freundlich 5%, Wohlwollend 10%, Respektvoll 15%, Ehrfürchtig 20%. Mit einem Strich wird bei jedem Händler gekauft."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"Kaufen ist für diesen Gegenstand deaktiviert, also gibt es nichts extra zu kaufen."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"Kaufen ist für diesen Gegenstand deaktiviert, also spielt der Ruf keine Rolle."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Für diesen Gegenstand gibt es keine bessere Version zum Aufwerten."
