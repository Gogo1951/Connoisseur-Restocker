local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "itIT")
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

L["MACRO_BANDAGE"] = "- Benda"
L["MACRO_EXPLOSIVES"] = "- Esplosivi"
L["MACRO_FEED_PET"] = "- Nutri Famiglio"
L["MACRO_FOOD"] = "- Cibo"
L["MACRO_HEALTH_POTION"] = "- Poz. Salute"
L["MACRO_HEALTHSTONE"] = "- Pietra Salute"
L["MACRO_MANA_GEM"] = "- Gemma di Mana"
L["MACRO_MANA_POTION"] = "- Poz. Mana"
L["MACRO_POISONS"] = "- Veleni"
L["MACRO_SOULSTONE"] = "- Pietra Anima"
L["MACRO_WATER"] = "- Acqua"

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

L["DIET_BREAD"] = "Pane"
L["DIET_CHEESE"] = "Formaggio"
L["DIET_FISH"] = "Pesce"
L["DIET_FRUIT"] = "Frutta"
L["DIET_FUNGUS"] = "Funghi"
L["DIET_MEAT"] = "Carne"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Sembra che tu abbia trovato un bug! Non è possibile usare %s (%s) in %s > %s (%s). Segnalacelo, così potremo risolverlo. Grazie! %s"
L["MESSAGE_NO_ITEM"] = "%s: nessun oggetto adatto trovato nelle tue borse."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"Non è stato possibile creare alcune macro di Connoisseur perché gli slot delle macro sono pieni. Libera uno slot eliminando le macro che non usi più, oppure disattiva le macro di Connoisseur che non ti servono in Opzioni > Add-on > Connoisseur > Macro."

L["CHAT_LOADED"] =
	"Versione %s. Le impostazioni (inclusa l'opzione per disattivare questo messaggio) si trovano in Opzioni > Add-on > Connoisseur. Ti piace l'add-on? Parlane a un amico! (="

L["CHAT_OPTIONS_IN_COMBAT"] =
	"Per sicurezza, l'interfaccia delle opzioni non può essere aperta durante il combattimento."

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

L["READINESS_TITLE"] = "Rapporto di preparazione"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Buff mancanti:"
L["READINESS_EXPIRING"] = "In scadenza:"
L["READINESS_MISSING_ITEMS"] = "Oggetti mancanti:"
L["READINESS_DAMAGED_GEAR"] = "Equipaggiamento danneggiato:"
L["READINESS_CHARACTER"] = "Personaggio:"
L["READINESS_QUESTIONABLE_GEAR"] = "Equipaggiamento non da combattimento:"

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
L["READINESS_FLASK"] = "Tonico o 2x elisir"
L["READINESS_WELL_FED"] = "Ben Nutrito"
L["READINESS_PET_WELL_FED"] = "Ben Nutrito (famiglio)"
L["READINESS_SCROLLS"] = "Pergamene"
L["READINESS_SOULSTONE"] = "Pietra dell'Anima inattiva"
L["READINESS_MAIN_HAND"] = "Mano primaria"
L["READINESS_OFF_HAND"] = "Mano secondaria"
L["READINESS_HEALTHSTONE"] = "Pietra della Salute"
L["READINESS_MANA_GEM"] = "Gemma di Mana"
L["READINESS_HEALING_POTION"] = "Pozione di Cura"
L["READINESS_MANA_POTION"] = "Pozione di Mana"
L["READINESS_BANDAGES"] = "Bende"
L["READINESS_PVP_ON"] = "PvP attivo!"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s meno di 1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 punto talento non speso"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d punti talento non spesi"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Al momento non hai alcun cibo utile per il tuo famiglio."
L["TIP_PET_NO_SKILLS"] =
	"Al momento non conosci Richiama Famiglio, Congeda Famiglio, Nutri Famiglio o Rianima Famiglio."
L["TIP_PET_NO_MEND"] = "Al momento non conosci Cura Famiglio."
L["TIP_NO_HAND_POISON"] = "Hai esaurito il veleno scelto per quest'arma."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Al momento non conosci %s."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "Cibo con buff"
L["MENU_BUFF_FOOD_DESCRIPTION"] = 'Dà priorità al cibo che fornisce il buff "Ben Nutrito" quando il buff è assente.'
L["FEATURE_SCROLL_BUFFS"] = "Buff delle pergamene"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] = "La tua macro Cibo applica i buff delle pergamene mancanti prima di mangiare."

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Attention Hunters block, and the two poison titles open the
    Attention Rogues block.
]]
L["MINIMAP_BEST_FOOD"] = "Cibo attuale"
L["MINIMAP_BEST_PET_FOOD"] = "Cibo attuale del famiglio"
L["MINIMAP_MAIN_HAND_POISON"] = "Veleno mano primaria"
L["MINIMAP_OFF_HAND_POISON"] = "Veleno mano secondaria"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Lista ignorati"
L["MINIMAP_IGNORE_COUNT"] = "%d oggetti"
L["MENU_IGNORE"] = "Ignora"
L["MENU_CLEAR_IGNORE"] = "Svuota lista ignorati"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Rapporto di Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d ordini in sospeso"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Complimenti, hai le scorte al completo!"
L["MINIMAP_RESTOCKER_EMPTY"] = "La tua lista è vuota."

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Lista di Restocker"
L["MENU_RESTOCKER_DESCRIPTION"] = "Compra e deposita in banca gli oggetti della tua lista."
L["MENU_RESTOCKER_KEYBIND"] = "Maiusc + clic destro"
L["MENU_OPTIONS"] = "Opzioni di Connoisseur"
L["MENU_OPTIONS_KEYBIND"] = "Maiusc + clic centrale"

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The class block of the mini-map tooltip: a class-colored header, the items
    the class's own macro will use (a Hunter's pet food, a Rogue's two poisons,
    titled in the Minimap Tooltip section above), then one group per macro.
]]

L["PREFIX_HUNTER"] = "Attenzione Cacciatori"
L["PREFIX_MAGE"] = "Attenzione Maghi"
L["PREFIX_ROGUE"] = "Attenzione Ladri"
L["PREFIX_WARLOCK"] = "Attenzione Stregoni"

--[[
    A group is the macro's name, then one row per click: the click on the left
    and what it does on the right. The right-hand column never wraps, so each
    result stays a few words. A spell the row casts is named by the client
    (Mend Pet, Ritual of Refreshment, Ritual of Souls) and has no key here, and
    a plain click reuses MINIMAP_LEFT_CLICK, MINIMAP_RIGHT_CLICK or
    MINIMAP_MIDDLE_CLICK.
]]
L["NOTE_MACRO_FEED_PET"] = "Macro Nutri Famiglio"
L["NOTE_MACRO_FOOD_WATER"] = "Macro Cibo e Acqua"
L["NOTE_MACRO_MANA_GEM"] = "Macro Gemma di Mana"
L["NOTE_MACRO_HEALTHSTONE"] = "Macro Pietra Salute"
L["NOTE_MACRO_SOULSTONE"] = "Macro Pietra Anima"
L["NOTE_MACRO_POISONS"] = "Macro Veleni"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Richiama, nutri o rianima"
L["NOTE_PET_MEND_CLICK"] = "Clic destro, o in combattimento"
L["NOTE_HOLD_SHIFT"] = "Tieni premuto Maiusc"
L["NOTE_PET_FORCE_REVIVE"] = "Forza la rianimazione"
L["NOTE_HOLD_CONTROL"] = "Tieni premuto Ctrl"
L["NOTE_PET_DISMISS"] = "Congeda"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Evoca"
L["NOTE_CREATE"] = "Crea"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Clic destro di nuovo"
L["NOTE_LOWER_RANK_BACKUP"] = "Scorta di grado inferiore"
L["NOTE_MAGE_TARGET_LEVEL"] = "Seleziona un giocatore di livello inferiore per evocare in base al suo livello."
L["NOTE_WARLOCK_TARGET_LEVEL"] = "Seleziona un giocatore di livello inferiore per crearne una in base al suo livello."

-- Rogue. The two hands are the results of a Left-Click and a Right-Click on the Poisons macro.
L["MINIMAP_MAIN_HAND"] = "Mano primaria"
L["MINIMAP_OFF_HAND"] = "Mano secondaria"
L["NOTE_POISONS_WINDOW"] = "Finestra dei Veleni"
L["NOTE_POISONS_REPLACED"] = "Sostituisce automaticamente i vecchi veleni."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Benda"
L["LABEL_EXPLOSIVE"] = "Esplosivo"
L["LABEL_FOOD"] = "Cibo"
L["LABEL_HEALTH_POTION"] = "Pozione di Salute"
L["LABEL_HEALTHSTONE"] = "Pietra della Salute"
L["LABEL_MANA_GEM"] = "Gemma di Mana"
L["LABEL_MANA_POTION"] = "Pozione di Mana"
L["LABEL_PET_FOOD"] = "Cibo per famigli"
L["LABEL_POISONS"] = "Veleno"
L["LABEL_SOULSTONE"] = "Pietra dell'Anima"
L["LABEL_WATER"] = "Acqua"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Attivato"
L["MINIMAP_DISABLED"] = "Disattivato"
L["MINIMAP_TOGGLE"] = "Attiva/disattiva"
L["MINIMAP_OPEN"] = "Apri"
L["MINIMAP_LEFT_CLICK"] = "Clic sinistro"
L["MINIMAP_RIGHT_CLICK"] = "Clic destro"
L["MINIMAP_MIDDLE_CLICK"] = "Clic centrale"
L["MINIMAP_SHIFT_LEFT"] = "Maiusc + clic sinistro"

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
	'Determina quando la tua macro Cibo propone "%s": sempre, oppure soltanto quando giochi da solo, sei in gruppo o incursione, sei in incursione, stai salendo di livello o sei al livello massimo.'
L["MODE_ALWAYS"] = "Sempre"
L["MODE_SOLO"] = "Da solo"
L["MODE_PARTY"] = "In gruppo o incursione"
L["MODE_RAID"] = "In incursione"
L["MODE_LEVELING"] = "Mentre sali di livello"
L["MODE_MAX_LEVEL"] = "Al livello massimo"

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
L["INVENTORY_REPORT_TITLE"] = "Rapporto di inventario"
L["INVENTORY_REPORT_BAGS"] = "Borse"
L["INVENTORY_REPORT_BANK"] = "Banca"
-- In place of the Bank count, muted, until this character's bank has been opened once with the add-on running.
L["INVENTORY_REPORT_BANK_UNKNOWN"] = "Sconosciuto"
-- Everything above it added up: this character and every other one on the realm.
L["INVENTORY_REPORT_TOTAL"] = "Totale"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Macro che usano automaticamente il tuo miglior cibo, acqua, pozioni, pietre della salute, bende, veleni e cibo per famigli, oltre a una lista di rifornimento che compra automaticamente i tuoi consumabili, li deposita in banca e li migliora man mano che sali di livello. Automazione per il comfort di gioco, per prestazioni al massimo."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Attiva il messaggio di benvenuto"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Mostra un messaggio di benvenuto in chat all'accesso."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Attiva il pulsante della minimappa"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Mostra il pulsante della minimappa."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Apre l'interfaccia delle opzioni di questo add-on."
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Apre la tua lista di rifornimento."

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "Feedback e supporto"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["CURSEFORGE"] = "CurseForge"
L["WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Versione %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Enable Macros header below titles the first section,
    after the page's one headerless toggle, Macro Names on Buttons.
]]
L["TAB_MACROS"] = "Macro"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur crea una macro per ogni consumabile e la tiene aggiornata mentre le tue borse cambiano, così il pulsante sulla barra punta sempre al miglior oggetto che stai portando. Scegli qui sotto quali macro creare, poi imposta come ciascuna sceglie il suo oggetto."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Attiva i nomi delle macro sui pulsanti"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Mostra sui pulsanti della barra delle azioni il nome delle macro, che Connoisseur nasconde per impostazione predefinita."

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "Attiva macro"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Scegli quali macro Connoisseur crea e mantiene. Disattivarne una la rimuove anche."
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Crea e mantiene questa macro e la rimuove quando togli la spunta."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Cibo e acqua"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Le tue macro Cibo e Acqua usano il miglior cibo e la miglior bevanda nelle tue borse. Queste opzioni possono mettere al primo posto il cibo con buff, le pergamene o il cibo e l'acqua evocati, e all'ultimo posto il cibo e l'acqua della lista di rifornimento."

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Dai priorità al cibo con buff"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'Dà priorità al cibo che fornisce il buff "Ben Nutrito" quando il buff è assente, tranne nelle arene.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Attiva i buff delle pergamene"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"La tua macro Cibo applica le pergamene mancanti alla prima pressione e mangia a quella successiva, saltando le pergamene quando selezioni un giocatore amico o sei in un'arena."
L["OPTIONS_SCROLL_TYPES"] = "Includi i tipi di pergamena nel controllo"
L["OPTIONS_SCROLL_AGILITY"] = "Agilità"
L["OPTIONS_SCROLL_INTELLECT"] = "Intelletto"
L["OPTIONS_SCROLL_PROTECTION"] = "Difesa"
L["OPTIONS_SCROLL_SPIRIT"] = "Spirito"
L["OPTIONS_SCROLL_STAMINA"] = "Tempra"
L["OPTIONS_SCROLL_STRENGTH"] = "Forza"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = 'Include "%s" nel controllo dei buff mancanti.'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Usa prima cibo e acqua evocati"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Le tue macro Cibo e Acqua usano cibo e acqua evocati prima di qualsiasi altra cosa, anche se qualcosa nelle tue borse ripristina di più, perché non costano nulla e svaniscono poco dopo la disconnessione. Il cibo con buff resta comunque al primo posto finché "Dai priorità al cibo con buff" è attivo.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Determina quando cibo e acqua evocati hanno la precedenza: sempre, oppure soltanto quando giochi da solo, sei in gruppo o incursione, sei in incursione, stai salendo di livello o sei al livello massimo."

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "Usa per ultimi cibo e acqua della lista di rifornimento"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"Tra due cibi o bevande che ripristinano la stessa quantità, le tue macro Cibo e Acqua usano quello che non è nella tua lista di rifornimento, conservando per dopo ciò che la lista acquista."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Pozioni e Pietre della Salute"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Le macro non possono cambiare durante il combattimento (questa è una restrizione della Blizzard), quindi ogni macro per Pozioni e Pietre della Salute è pre-costruita con il tuo miglior oggetto più fino a due alternative. Nei combattimenti più lunghi, l'icona e il tooltip possono diventare obsoleti e mostrare l'oggetto sbagliato, ma cliccando sulla macro verrà sempre utilizzato il miglior oggetto che hai effettivamente nelle borse."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Usa cibo e acqua nelle macro delle pozioni fuori dal combattimento"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Fuori dal combattimento, la tua macro Pozione di Salute mangia il tuo miglior cibo e la tua macro Pozione di Mana beve la tua miglior acqua. In combattimento, usano le tue pozioni come prima. Le pergamene, il cibo per famigli e l'evocazione restano nelle macro Cibo e Acqua."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combina le Pietre della Salute nella macro Pozione di Salute"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Aggiunge la tua migliore Pietra della Salute in fondo alla macro Pozione di Salute, così una singola pressione usa una pozione e una Pietra della Salute."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemme di Mana e rune"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"Le Rune Demoniache e le Rune Oscure, insieme ad alcuni altri oggetti per il mana, condividono il tempo di recupero con le Gemme di Mana. Usare le rune costa salute, quindi la macro Gemma di Mana esclude tutti questi oggetti, a meno che tu non li aggiunga."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Aggiungi le rune e gli altri oggetti per il mana alla macro Gemma di Mana"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"Inserisce nella stessa classifica delle tue Gemme di Mana le tue Rune Demoniache e Oscure e ogni altro oggetto per il mana che ne condivide il tempo di recupero, così la macro Gemma di Mana ne usa uno quando è la tua opzione migliore o quando hai finito le gemme."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Rinnovo dei buff"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Le macro non possono cambiare durante il combattimento, quindi un buff che scade a metà scontro resta assente fino alla fine del combattimento."
L["OPTIONS_REAPPLY"] = "Rinnova i buff in scadenza"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	'Considera scaduti "Cibo con buff", "Buff delle pergamene" e "Buff del cibo per famigli" quando resta meno tempo della tua soglia, così le tue macro te ne propongono uno nuovo prima dello scontro.'
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Imposta quanto vicino alla scadenza può arrivare un buff prima che le tue macro te ne propongano uno nuovo."
L["REAPPLY_THRESHOLD_ONE"] = "Quando rimane < 1 minuto"
L["REAPPLY_THRESHOLD_MANY"] = "Quando rimangono < %d minuti"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Buff del cibo per famigli"
L["OPTIONS_PET_SECTION_DESCRIPTION"] = 'Alcuni cibi danno al tuo famiglio un buff "Ben Nutrito" tutto suo.'
L["OPTIONS_USE_PET_BUFFS"] = "Usa i buff del cibo per famigli"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	'Aggiunge il cibo per famigli alla tua macro Cibo quando al tuo famiglio manca il buff "Ben Nutrito", tranne nelle arene.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Includi i tipi di cibo per famigli nel controllo"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Esplosivi"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"L'opzione @player salta il reticolo di puntamento e fa detonare l'esplosivo ai tuoi piedi. Ideale quando il bersaglio è in mischia. L'altro clic lancia l'esplosivo come al solito."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Assegnazione dei clic"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Determina quale clic lancia l'esplosivo e quale lo fa detonare ai tuoi piedi."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clic sinistro @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clic sinistro lancio"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "Druidi"
L["OPTIONS_DRUID_MACRO_HELPER"] = "Attiva l'integrazione con DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Crea macro di mutaforma per Pozioni di Salute, Pozioni di Mana e Pietre della Salute utilizzando DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Determina la forma in cui le tue macro di mutaforma ti riportano dopo l'uso dell'oggetto."
L["DRUID_FORM_BEAR"] = "Torna in Forma d'Orso"
L["DRUID_FORM_CAT"] = "Torna in Forma Felina"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "Ladri"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Mantiene la macro Veleni carica con il miglior grado utilizzabile di ogni tipo di veleno: clic sinistro applica alla mano secondaria, clic destro alla mano primaria, e i veleni esistenti vengono sostituiti automaticamente."
L["OPTIONS_POISON_MAIN_HAND"] = "Tipo di veleno mano primaria"
L["OPTIONS_POISON_OFF_HAND"] = "Tipo di veleno mano secondaria"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Determina il veleno che la tua macro Veleni applica alla mano primaria con il clic destro."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Determina il veleno che la tua macro Veleni applica alla mano secondaria con il clic sinistro."
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "Attiva la furtività mentre mangi"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] =
	"Aggiunge Furtività alla tua macro Cibo per renderti furtivo mentre mangi."

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "Elfi della Notte"
L["OPTIONS_STEALTH_DRINKING"] = "Attiva la furtività mentre bevi"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] =
	"Aggiunge Fondersi nelle Ombre alla tua macro Acqua per renderti furtivo mentre bevi."
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] =
	"Aggiunge Fondersi nelle Ombre alla tua macro Cibo per renderti furtivo mentre mangi."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Suggerimento pro: scegline uno. Puoi mangiare e bere allo stesso tempo, ma mangiare o bere dopo esserti reso furtivo interromperà la furtività."

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
L["TAB_IGNORE_LIST"] = "Lista ignorati"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Gli oggetti ignorati non vengono mai scelti da nessuna macro. Cibo, acqua, pozioni, qualsiasi cosa. La lista Globale vale per tutti i personaggi; quella di un personaggio vale solo per lui. Fai clic destro sul pulsante della minimappa per ignorare il tuo miglior cibo attuale."
L["OPTIONS_IGNORE_GLOBAL"] = "Globale"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Sposta questo oggetto nella lista Globale, così viene ignorato su tutti i personaggi."
L["OPTIONS_IGNORE_ADD_ID"] = "Aggiungi tramite ID oggetto"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Digita un ID oggetto, oppure fai Maiusc + clic su un collegamento a un oggetto in chat mentre questo campo è attivo."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"Digita un ID oggetto, oppure fai Maiusc + clic su un collegamento a un oggetto in chat."
L["OPTIONS_IGNORE_REMOVE"] = "Rimuovi"
L["OPTIONS_IGNORE_EMPTY"] = "Questa lista è vuota."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Caricamento ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Mantiene rifornite le tue borse in base alla tua lista di rifornimento, comprando dai mercanti e spostando automaticamente gli oggetti da e verso la banca. Digita %s per aprire la lista."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Apri in banca"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Apre la tua lista di rifornimento quando visiti la banca."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Apri dal mercante"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Apre la tua lista di rifornimento quando visiti un mercante."
L["OPTIONS_RESTOCKER_REMIND"] = "Attiva i promemoria di rifornimento in città"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Mostra un promemoria in chat quando ti manca qualcosa della tua lista di rifornimento e raggiungi una locanda o una città, o ti trovi già in una all'accesso."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Attiva i promemoria di rifornimento dal mercante"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Segnala gli eventuali ordini di rifornimento in sospeso quando chiudi la finestra di un mercante."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Attiva i promemoria di rifornimento in banca"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Segnala gli eventuali ordini di rifornimento in sospeso quando chiudi la banca."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Attiva la riserva d'oro"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "Il rifornimento non spende mai l'oro che metti da parte qui."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Quanto oro il rifornimento ti lascia sempre."

--[[
    The staples pop-up (STARTER_POPUP_TITLE below). This toggle and the
    pop-up's own "Don't Show This Again" box are the same per-character choice
    read from opposite ends, which is why one ships on and the other off: a
    settings row reads naturally as "enable", a dismissal reads naturally as
    "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] = "Attiva il pop-up dei beni essenziali quando la lista di rifornimento è vuota"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"Propone i beni essenziali per la tua classe all'accesso ogni volta che la lista di rifornimento di questo personaggio è vuota."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Determina se il promemoria sia una sola riga o ne aggiunga una per ogni oggetto da rifornire."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Semplice"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Dettagliato"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Riproduci suono"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Riproduce un avviso insieme al promemoria, per quando la chat è affollata."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Clicca per ascoltare l'avviso."

L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Promemoria"
L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Finestra della lista di rifornimento"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Scegli quando la tua lista di rifornimento si apre da sola."

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Mostra nel tooltip di un oggetto quanti ne possiedi, contando tutti i tuoi personaggi di questo reame."
L["OPTIONS_INVENTORY_REPORT"] = "Attiva il rapporto di inventario nei tooltip degli oggetti"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"Aggiunge al tooltip di un oggetto quanti ne hai nelle tue borse, nella tua banca e sugli altri tuoi personaggi. Disattivalo se un altro add-on mostra già questi conteggi."

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Ringraziamenti"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"Ho sempre amato Restocker, e sono felice che continui a vivere dentro Connoisseur. Un grazie enorme a ChiliFajita, che ha scritto l'Auto Restocker originale, e a kvakvs e guardycmw, che lo hanno tenuto in vita attraverso Classic e Mists of Pandaria."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Rapporto di preparazione"
L["OPTIONS_READINESS_ENABLE"] = "Attiva il rapporto di preparazione all'appello"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] =
	"Attiva il rapporto di preparazione per tutti i personaggi di questo account."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Quando parte un appello, mostra in chat una lista privata di ciò che va ancora sistemato e, se sei pronto, non dice proprio nulla."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Ripristina le impostazioni del rapporto di preparazione"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Riporta ai valori predefiniti ogni casella ed entrambe le soglie di questa pagina, senza toccare le altre pagine."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Ripristinare tutte le impostazioni del rapporto di preparazione ai valori predefiniti? Questo disattiva di nuovo anche il rapporto stesso."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Buff mancanti"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Oggetti mancanti"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personaggio"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Segnala se manca un tonico. Basta un tonico, oppure un elisir di combattimento e un elisir di protezione."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	'Segnala se manca il buff "Ben Nutrito". Richiede che "Cibo con buff" sia attivo nel pannello Macro.'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	'Segnala se al tuo famiglio manca il buff "Ben Nutrito". Richiede che "Buff del cibo per famigli" sia attivo nel pannello Macro e che tu abbia un famiglio evocato.'
L["OPTIONS_READINESS_SCROLLS"] = "Buff delle pergamene"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	'Segnala se ti mancano i buff delle pergamene. Richiede che "Buff delle pergamene" sia attivo nel pannello Macro e controlla solo i tipi di pergamena selezionati lì.'
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Segnala quando nessuno nel tuo gruppo ha una Pietra dell'Anima attiva; una rimasta in una borsa non conta. Mostrato solo a uno Stregone che può crearne una."
L["OPTIONS_READINESS_MAIN_HAND"] = "Buff arma (mano primaria)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Segnala un'arma nella mano primaria senza incantamento temporaneo. Conta qualsiasi incantamento, e resta in silenzio quando nel tuo gruppo c'è uno Sciamano."
L["OPTIONS_READINESS_OFF_HAND"] = "Buff arma (mano secondaria)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Segnala un'arma nella mano secondaria senza incantamento temporaneo. Conta qualsiasi incantamento: una pietra, un olio, un veleno o un buff arma da Sciamano."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Buff in scadenza entro"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	'Elenca ogni buff su di te che sta per scadere, non solo quelli applicati da Connoisseur, ed è indipendente da "Rinnovo dei buff" nel pannello Macro.'
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minuti"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minuto"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Imposta quanto vicino alla scadenza deve essere un buff perché il rapporto lo elenchi."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna Pietra della Salute. Mostrato solo quando c'è uno Stregone nel gruppo a cui chiederla, o quando lo Stregone sei tu."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna Gemma di Mana. Mostrato solo a un Mago che può evocarne una."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna pozione di cura, perché nessuno può passartene una in pieno combattimento."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna pozione di mana. Mostrato solo quando giochi con una classe che usa il mana."
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] =
	"Segnala quando non porti con te nessuna benda che la tua abilità in Pronto Soccorso ti permetta di usare."
L["OPTIONS_READINESS_DURABILITY"] = "Equipaggiamento danneggiato sotto"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Mostra il collegamento di ogni oggetto equipaggiato con integrità inferiore a questa soglia, calcolata oggetto per oggetto, così compare anche una sola arma rotta."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Imposta quanto deve scendere l'integrità di un oggetto perché il rapporto ne mostri il collegamento."

-- Character
L["OPTIONS_READINESS_SPEC"] = "Specializzazione attuale"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] = "Mostra la distribuzione dei talenti e gli eventuali punti che non hai speso."
L["OPTIONS_READINESS_PVP"] = "PvP attivo"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avvisa quando la tua modalità PvP è attiva."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Equipaggiamento non da combattimento"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"Mostra il collegamento degli oggetti equipaggiati che non c'entrano con un combattimento, come un frustino o una canna da pesca."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Esiste già una lista chiamata "%s".'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "L'ID %d non esiste."
L["RESTOCKER_BANK_NOT_OPEN"] = "La banca non è aperta."
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Rifornimento completato. Tieni premuto Maiusc mentre apri la banca per saltare il rifornimento. Digita %s per modificare la tua lista di rifornimento."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Rifornimento interrotto. Le tue borse e la tua banca sono piene."
L["RESTOCKER_STOPPED_BANK_FULL"] = "Rifornimento interrotto. La tua banca è piena; libera uno spazio e riaprila."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Rifornimento interrotto. Le tue borse sono piene; libera uno spazio e riapri la banca."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Rifornimento interrotto. Nessun progresso possibile."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Rifornimento interrotto. Impossibile spostare: %s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (in eccesso)"
L["RESTOCKER_STOPPED_ERROR"] = "Rifornimento interrotto a causa di un errore: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Questo mercante non vende tutti gli ingredienti necessari ai tuoi veleni. Non ne verrà comprato nessuno."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Non dimenticare di fare rifornimento mentre sei in città!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 ordine di rifornimento in sospeso."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d ordini di rifornimento in sospeso."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "La tua lista di rifornimento è stata migliorata."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d diventa %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 ordine di rifornimento evaso."
L["RESTOCKER_RESTOCKED_MANY"] = "%d ordini di rifornimento evasi."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 ordine di rifornimento evaso in parte."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d ordini di rifornimento evasi in parte."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Le tue borse si sono riempite prima che fosse comprato tutto."
L["RESTOCKER_OUT_OF_GOLD"] = "Oro insufficiente per completare il rifornimento."
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Rifornimento in pausa; oro insufficiente. Riprenderà quando potrà completare i tuoi ordini d'acquisto senza intaccare la tua riserva (%s)."

-- /crs help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nome]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Aggiunge una lista con quel nome."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Elimina la lista con quel nome."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Rinomina la lista attuale con quel nome."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Sostituisce la lista attuale con una copia della lista con quel nome."
L["RESTOCKER_HELP_PROFILE_USE"] = "Assegna a questo personaggio la lista con quel nome."

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
L["STARTER_POPUP_TITLE"] = "Beni essenziali di Connoisseur"
L["STARTER_POPUP_INTRO_EMPTY"] =
	"La tua lista di rifornimento è vuota, quindi aggiungiamo qualche oggetto per iniziare."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Scegli i beni essenziali che vuoi tenere di scorta."
L["STARTER_POPUP_INTRO_HOW"] =
	"Tutto ciò che spunti viene rifornito automaticamente ogni volta che apri un mercante o la tua banca. Gli oggetti di uso comune migliorano da soli man mano che sali di livello, così avrai sempre il meglio disponibile."
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Puoi sempre modificare questa lista, o aggiungere altri oggetti in seguito, digitando %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Cibo e acqua"
L["STARTER_POPUP_FOOD_HEADER"] = "Cibo"
L["STARTER_POPUP_AMMO_HEADER"] = "Munizioni"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Proiettili"
L["STARTER_POPUP_ARROWS"] = "Frecce"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header reuses PREFIX_ROGUE (rogue-colored at the call
    site) to say the ingredients take care of themselves. Both sections name
    their rows with the client's own item names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagenti e strumenti"
L["STARTER_POPUP_POISONS_HEADER"] = "Veleni"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : aggiungi il veleno finito alla tua lista e Connoisseur comprerà automaticamente gli ingredienti da qualsiasi mercante che li venda tutti."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Aggiunge %s alla tua lista di rifornimento, mantenendone %d nelle borse e migliorandoli man mano che sali di livello."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Aggiunge %s alla tua lista di rifornimento, mantenendone %d nelle borse."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 pila"
L["STARTER_POPUP_STACK_MANY"] = "%d pile"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Quante pile tenere di scorta, dove una pila equivale a %d."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Quanti tenerne di scorta, ognuno in uno spazio a sé nelle borse, perché non si impilano."
L["STARTER_POPUP_DISMISS"] = "Non mostrare più per questo personaggio"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] =
	"Impedisce che questi suggerimenti ricompaiano agli accessi in cui la tua lista di rifornimento è vuota."

-- Restock List window UI. The title names what the window holds; the feature that acts on it stays "Restocker".
L["RESTOCKER_WINDOW_TITLE"] = "Lista di rifornimento di Connoisseur"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtra oggetti..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Cancella"
L["RESTOCKER_ADD_BUTTON"] = "Aggiungi"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. The keys keep the pop-up's
    earlier name, the List Builder. "Check" is the pop-up's own word
    (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "Beni essenziali"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"Scegli tra i beni essenziali per la tua classe e il tuo livello: cibo, acqua, munizioni, veleni e reagenti. Spuntarne uno lo aggiunge a questa lista e togliere la spunta lo rimuove."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Aggiungi un oggetto"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Trascina un oggetto dalle tue borse qui o in qualsiasi punto di questa finestra, oppure digita un ID oggetto e premi Invio."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Trascina o digita l'ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Digita invece un ID."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Aggiungi dalle borse"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Ogni oggetto nelle tue borse che non è ancora in questa lista. Cliccane uno per aggiungerlo."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nulla da aggiungere dalle tue borse"

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
L["RESTOCKER_PROFILE_LABEL"] = "Lista"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Clicca per assegnare a questo personaggio un'altra lista di rifornimento o per iniziarne una nuova."
L["RESTOCKER_USED_BY"] = "Usata da %s"
L["RESTOCKER_MANAGE"] = "Gestisci liste"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Inizia una nuova lista, oppure copia, rinomina o elimina questa."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu. The Copy and Delete keys end in
    _TOOLTIP because they began as the tooltips of two buttons this menu
    replaced.
]]
L["RESTOCKER_NEW_PROFILE"] = "Nuova lista"
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "Copia questa lista in una nuova"
L["RESTOCKER_RENAME_PROFILE"] = "Rinomina questa lista"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "Elimina questa lista"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Copia"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Rinomina"
L["RESTOCKER_RENAME_TOOLTIP"] = "Rinomina questa lista per tutti i personaggi che la usano."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Vuoi davvero eliminare questa lista?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "Anche %s la usa e, all'accesso, troverà una lista vuota con lo stesso nome."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"Anche %s la usano e, all'accesso, ognuno troverà una lista vuota con lo stesso nome."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Passerai alla lista %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "È l'unica lista rimasta, quindi ripartirai da una nuova lista vuota."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Questa azione non può essere annullata."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Migliora salendo di livello"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permette a Connoisseur di migliorare cibo, acqua, munizioni, veleni, pozioni e reagenti di classe, passando a oggetti migliori man mano che sali di livello."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Banca"
L["RESTOCKER_ROW_MERCHANT"] = "Mercante"
L["RESTOCKER_ROW_UPGRADE"] = "Migliora"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Oggetto"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Preleva"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Deposita"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Tieni"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Clicca sull'intestazione per impostare questa opzione su tutti gli oggetti mostrati."
L["RESTOCKER_BULK_ON"] = "Attiva (mostrati: %d)"
L["RESTOCKER_BULK_OFF"] = "Disattiva (mostrati: %d)"

L["RESTOCKER_GROUP_OTHER"] = "Altro"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Nuovi"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Tutti gli oggetti"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_LIST_BUILDER_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Questa lista è ancora vuota"
L["RESTOCKER_EMPTY_BODY"] =
	"Seleziona beni essenziali come cibo, acqua o reagenti di classe, oppure aggiungi qualsiasi cosa dalle tue borse con il menu qui sopra. Gli oggetti selezionati vengono tenuti di scorta o depositati in banca automaticamente, così le tue borse restano in ordine."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Puoi anche aggiungere un oggetto trascinandolo ovunque in questa finestra."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nessun oggetto in questa lista corrisponde al tuo filtro."
L["RESTOCKER_NO_MATCH_GROUP"] = "Non è rimasto nulla in questa categoria."

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
L["RESTOCKER_NO_ORDERS"] = "Nessun ordine di rifornimento in sospeso."
L["RESTOCKER_REPORT_MORE"] = "e %d in più"
L["RESTOCKER_REMOVED_ITEM"] = "Hai rimosso %s."
L["RESTOCKER_UNDO"] = "Annulla"
L["RESTOCKER_UNDO_TOOLTIP"] = "Rimetti questo oggetto nella lista"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Rimuovi questo oggetto dalla lista di rifornimento"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Puoi annullare questa azione in fondo alla finestra."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Tieni nelle borse"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'Quanti tenerne nelle borse. Il numero diventa giallo finché le tue borse ne contengono di meno, e 0 con "Deposita" attivo manda tutto in banca.'
L["RESTOCKER_BUY_LABEL"] = "Compra"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Compra dal mercante"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Compra dal mercante la quantità necessaria quando la finestra del mercante è aperta."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Compra extra"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Compra da un mercante tutta la scorta limitata di questo oggetto, cioè la merce che vende pochi pezzi alla volta e rifornisce lentamente, anche oltre il numero della colonna Tieni."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Deposita in banca"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Deposita in banca gli oggetti in eccesso quando la banca è aperta, oppure tutti se nella colonna Tieni imposti 0."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Preleva dalla banca"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Preleva dalla banca gli oggetti necessari quando la banca è aperta."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Reputazione richiesta"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% di sconto)"
L["RESTOCKER_REPUTATION_ANY"] = "Qualsiasi"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "Amichevole"
L["RESTOCKER_REPUTATION_HONORED"] = "Onorato"
L["RESTOCKER_REPUTATION_REVERED"] = "Riverito"
L["RESTOCKER_REPUTATION_EXALTED"] = "Osannato"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Reputazione richiesta con il mercante"
--[[
    Quotes the cell's own values, which couples this line to the four standings
    above: a locale that renders a standing differently has to say so here too.
    With no standing required the cell draws a dash rather than the word "Any",
    which is why the last sentence names the dash; "Any" is still the menu's
    first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	"Clicca per impostare la reputazione che un mercante richiede prima che Connoisseur compri da lui, il che riduce anche il prezzo: Amichevole 5%, Onorato 10%, Riverito 15%, Osannato 20%. Con un trattino, Connoisseur compra da qualsiasi mercante."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	'"Compra" è disattivato per questo oggetto, quindi non c\'è nulla di extra da comprare.'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	'"Compra" è disattivato per questo oggetto, quindi la reputazione non si applica.'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Questo oggetto non ha una versione migliore a cui passare."
