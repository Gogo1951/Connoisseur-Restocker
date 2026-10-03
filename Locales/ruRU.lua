local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "ruRU")
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

L["MACRO_BANDAGE"] = "- Бинты"
L["MACRO_EXPLOSIVES"] = "- Взрывчатка"
L["MACRO_FEED_PET"] = "- Корм. питомца"
L["MACRO_FOOD"] = "- Еда"
L["MACRO_HEALTH_POTION"] = "- Леч. зелье"
L["MACRO_HEALTHSTONE"] = "- Кам. здоровья"
L["MACRO_MANA_GEM"] = "- Мана-камень"
L["MACRO_MANA_POTION"] = "- Зелье маны"
L["MACRO_POISONS"] = "- Яды"
L["MACRO_SOULSTONE"] = "- Кам. души"
L["MACRO_WATER"] = "- Вода"

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

L["DIET_BREAD"] = "Хлеб"
L["DIET_CHEESE"] = "Сыр"
L["DIET_FISH"] = "Рыба"
L["DIET_FRUIT"] = "Фрукты"
L["DIET_FUNGUS"] = "Грибы"
L["DIET_MEAT"] = "Мясо"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Похоже, вы нашли ошибку! Предмет %s (%s) нельзя использовать в локации %s > %s (%s). Пожалуйста, сообщите об этом, чтобы мы могли её исправить. Спасибо! %s"
L["MESSAGE_NO_ITEM"] = "%s: в ваших сумках нет ничего подходящего."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"Не удалось создать некоторые макросы Connoisseur, так как все ячейки для макросов заняты. Освободите ячейку, удалив макросы, которыми вы больше не пользуетесь, или отключите ненужные макросы Connoisseur в меню Параметры > Модификации > Connoisseur > Макросы."

L["CHAT_LOADED"] =
	"Версия %s. Настройки (включая возможность отключения этого сообщения) находятся в меню Параметры > Модификации > Connoisseur. Нравится аддон? Расскажите другу! (="

L["CHAT_OPTIONS_IN_COMBAT"] =
	"В целях безопасности интерфейс настроек нельзя открыть в бою."

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

L["READINESS_TITLE"] = "Отчёт о готовности"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Не хватает баффов:"
L["READINESS_EXPIRING"] = "Скоро истекает:"
L["READINESS_MISSING_ITEMS"] = "Не хватает предметов:"
L["READINESS_DAMAGED_GEAR"] = "Повреждённое снаряжение:"
L["READINESS_CHARACTER"] = "Персонаж:"
L["READINESS_QUESTIONABLE_GEAR"] = "Надето небоевое снаряжение:"

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
L["READINESS_FLASK"] = "Настой или 2 эликсира"
L["READINESS_WELL_FED"] = "Сытость"
L["READINESS_PET_WELL_FED"] = "Сытость (питомец)"
L["READINESS_SCROLLS"] = "Свитки"
L["READINESS_SOULSTONE"] = "Камень души не активен"
L["READINESS_MAIN_HAND"] = "Правая рука"
L["READINESS_OFF_HAND"] = "Левая рука"
L["READINESS_HEALTHSTONE"] = "Камень здоровья"
L["READINESS_MANA_GEM"] = "Мана-камень"
L["READINESS_HEALING_POTION"] = "Лечебное зелье"
L["READINESS_MANA_POTION"] = "Зелье маны"
L["READINESS_BANDAGES"] = "Бинты"
L["READINESS_PVP_ON"] = "PvP включён!"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d мин"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s меньше 1 мин"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 нераспределённое очко талантов"
L["READINESS_UNSPENT_TALENTS_MANY"] = "Нераспределённых очков талантов: %d"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] =
	"В данный момент у вас нет подходящей еды для питомца."
L["TIP_PET_NO_SKILLS"] =
	"В данный момент вы не знаете способности Призыв питомца, Прогнать питомца, Кормление питомца или Воскрешение питомца."
L["TIP_PET_NO_MEND"] =
	"В данный момент вы не знаете способность Лечение питомца."
L["TIP_NO_HAND_POISON"] = "Выбранный яд для этого оружия закончился."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "В данный момент вы не знаете способность %s."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "Еда с эффектом"
L["MENU_BUFF_FOOD_DESCRIPTION"] =
	'Предпочитает еду, дающую эффект "Сытость", если он отсутствует.'
L["FEATURE_SCROLL_BUFFS"] = "Баффы от свитков"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] =
	"Применяет недостающие баффы от свитков через ваш макрос Еды, прежде чем вы начнёте есть."

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Attention Hunters block, and the two poison titles open the
    Attention Rogues block.
]]
L["MINIMAP_BEST_FOOD"] = "Текущая еда"
L["MINIMAP_BEST_PET_FOOD"] = "Текущая еда для питомца"
L["MINIMAP_MAIN_HAND_POISON"] = "Яд для правой руки"
L["MINIMAP_OFF_HAND_POISON"] = "Яд для левой руки"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Список игнорирования"
L["MINIMAP_IGNORE_COUNT"] = "Предметов: %d"
L["MENU_IGNORE"] = "Игнорировать"
L["MENU_CLEAR_IGNORE"] = "Очистить список игнорирования"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Отчёт Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "Невыполненных заказов: %d"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Поздравляем, запасы полностью пополнены!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Ваш список пуст."

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Список Restocker"
L["MENU_RESTOCKER_DESCRIPTION"] =
	"Покупает предметы из вашего списка и складывает их в банк."
L["MENU_RESTOCKER_KEYBIND"] = "Shift + ПКМ"
L["MENU_OPTIONS"] = "Настройки Connoisseur"
L["MENU_OPTIONS_KEYBIND"] = "Shift + СКМ"

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The class block of the mini-map tooltip: a class-colored header, the items
    the class's own macro will use (a Hunter's pet food, a Rogue's two poisons,
    titled in the Minimap Tooltip section above), then one group per macro.
]]

L["PREFIX_HUNTER"] = "Внимание, охотники"
L["PREFIX_MAGE"] = "Внимание, маги"
L["PREFIX_ROGUE"] = "Внимание, разбойники"
L["PREFIX_WARLOCK"] = "Внимание, чернокнижники"

--[[
    A group is the macro's name, then one row per click: the click on the left
    and what it does on the right. The right-hand column never wraps, so each
    result stays a few words. A spell the row casts is named by the client
    (Mend Pet, Ritual of Refreshment, Ritual of Souls) and has no key here, and
    a plain click reuses MINIMAP_LEFT_CLICK, MINIMAP_RIGHT_CLICK or
    MINIMAP_MIDDLE_CLICK.
]]
L["NOTE_MACRO_FEED_PET"] = 'Макрос "Корм. питомца"'
L["NOTE_MACRO_FOOD_WATER"] = 'Макросы "Еда" и "Вода"'
L["NOTE_MACRO_MANA_GEM"] = 'Макрос "Мана-камень"'
L["NOTE_MACRO_HEALTHSTONE"] = 'Макрос "Кам. здоровья"'
L["NOTE_MACRO_SOULSTONE"] = 'Макрос "Кам. души"'
L["NOTE_MACRO_POISONS"] = 'Макрос "Яды"'

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Призвать, накормить или воскресить"
L["NOTE_PET_MEND_CLICK"] = "ПКМ или в бою"
L["NOTE_HOLD_SHIFT"] = "Удерживая Shift"
L["NOTE_PET_FORCE_REVIVE"] = "Принудительно воскресить"
L["NOTE_HOLD_CONTROL"] = "Удерживая Ctrl"
L["NOTE_PET_DISMISS"] = "Прогнать"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Сотворить"
L["NOTE_CREATE"] = "Создать"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Ещё раз ПКМ"
L["NOTE_LOWER_RANK_BACKUP"] = "Запасной камень на ранг ниже"
L["NOTE_MAGE_TARGET_LEVEL"] =
	"Выберите целью игрока более низкого уровня, чтобы сотворить еду или воду для его уровня."
L["NOTE_WARLOCK_TARGET_LEVEL"] =
	"Выберите целью игрока более низкого уровня, чтобы создать Камень здоровья для его уровня."

-- Rogue. The two hands are the results of a Left-Click and a Right-Click on the Poisons macro.
L["MINIMAP_MAIN_HAND"] = "Правая рука"
L["MINIMAP_OFF_HAND"] = "Левая рука"
L["NOTE_POISONS_WINDOW"] = "Окно Ядов"
L["NOTE_POISONS_REPLACED"] = "Автоматически заменяет старые яды."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Бинты"
L["LABEL_EXPLOSIVE"] = "Взрывчатка"
L["LABEL_FOOD"] = "Еда"
L["LABEL_HEALTH_POTION"] = "Лечебное зелье"
L["LABEL_HEALTHSTONE"] = "Камень здоровья"
L["LABEL_MANA_GEM"] = "Мана-камень"
L["LABEL_MANA_POTION"] = "Зелье маны"
L["LABEL_PET_FOOD"] = "Еда для питомца"
L["LABEL_POISONS"] = "Яд"
L["LABEL_SOULSTONE"] = "Камень души"
L["LABEL_WATER"] = "Вода"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Включено"
L["MINIMAP_DISABLED"] = "Отключено"
L["MINIMAP_TOGGLE"] = "Переключить"
L["MINIMAP_OPEN"] = "Открыть"
L["MINIMAP_LEFT_CLICK"] = "ЛКМ"
L["MINIMAP_RIGHT_CLICK"] = "ПКМ"
L["MINIMAP_MIDDLE_CLICK"] = "СКМ"
L["MINIMAP_SHIFT_LEFT"] = "Shift + ЛКМ"

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
	'Выбирает, когда ваш макрос Еды предлагает "%s": всегда или только в одиночку, в группе или рейде, в рейде, до максимального уровня или на максимальном уровне.'
L["MODE_ALWAYS"] = "Всегда"
L["MODE_SOLO"] = "В одиночку"
L["MODE_PARTY"] = "В группе или рейде"
L["MODE_RAID"] = "В рейде"
L["MODE_LEVELING"] = "До максимального уровня"
L["MODE_MAX_LEVEL"] = "На максимальном уровне"

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
L["INVENTORY_REPORT_TITLE"] = "Отчёт об инвентаре"
L["INVENTORY_REPORT_BAGS"] = "Сумки"
L["INVENTORY_REPORT_BANK"] = "Банк"
-- In place of the Bank count, muted, until this character's bank has been opened once with the add-on running.
L["INVENTORY_REPORT_BANK_UNKNOWN"] = "Неизвестно"
-- Everything above it added up: this character and every other one on the realm.
L["INVENTORY_REPORT_TOTAL"] = "Всего"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Макросы, которые автоматически используют вашу лучшую еду, воду, зелья, камни здоровья, бинты, яды и еду для питомца, а также список пополнения, который сам закупает ваши расходуемые предметы, складывает их в банк и улучшает по мере роста уровня. Удобная автоматизация для максимальной эффективности."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Включить приветственное сообщение"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] =
	"Выводит приветственное сообщение в чат при входе в игру."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Включить кнопку на миникарте"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Показывает кнопку на миникарте."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Открывает интерфейс настроек этого аддона."
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Открывает ваш список пополнения."

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "Обратная связь и поддержка"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["CURSEFORGE"] = "CurseForge"
L["WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Версия %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Enable Macros header below titles the first section,
    after the page's one headerless toggle, Macro Names on Buttons.
]]
L["TAB_MACROS"] = "Макросы"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur создаёт по одному макросу на каждый тип расходуемых предметов и обновляет его вслед за содержимым сумок, так что кнопка на панели всегда тянется к лучшему предмету, который у вас есть. Выберите ниже, какие макросы создавать, а затем настройте, как каждый из них выбирает предмет."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Включить названия макросов на кнопках"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Показывает названия макросов на кнопках панелей команд. По умолчанию Connoisseur скрывает эти названия."

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "Включить макросы"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Выберите, какие макросы Connoisseur будет создавать и поддерживать. Отключённый макрос также удаляется."
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] =
	"Создаёт и поддерживает этот макрос, а при снятии флажка удаляет его."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Еда и вода"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Ваши макросы Еды и Воды используют лучшую еду и питьё из ваших сумок. Эти настройки позволяют ставить на первое место еду с эффектом, свитки или сотворенные еду и воду."

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Предпочитать еду с эффектом"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'Предпочитает еду, дающую эффект "Сытость", если он отсутствует, кроме как на аренах.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Включить баффы от свитков"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Ваш макрос Еды при первом нажатии применяет недостающие свитки, а при следующем использует еду, пропуская свитки, если целью выбран дружественный игрок или вы находитесь на арене."
L["OPTIONS_SCROLL_TYPES"] = "Включить типы свитков в проверку"
L["OPTIONS_SCROLL_AGILITY"] = "Ловкость"
L["OPTIONS_SCROLL_INTELLECT"] = "Интеллект"
L["OPTIONS_SCROLL_PROTECTION"] = "Защита"
L["OPTIONS_SCROLL_SPIRIT"] = "Дух"
L["OPTIONS_SCROLL_STAMINA"] = "Выносливость"
L["OPTIONS_SCROLL_STRENGTH"] = "Сила"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "Включает в проверку недостающих баффов: %s."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Сначала использовать сотворенные еду и воду"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Ваши макросы Еды и Воды используют сотворенные еду и воду раньше всего остального, даже если в сумках есть что-то, что восполняет больше, ведь они ничего не стоят и исчезают вскоре после выхода из игры. Еда с эффектом по-прежнему идёт первой, пока включено "Предпочитать еду с эффектом".'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Выбирает, когда сотворенные еда и вода идут первыми: всегда или только в одиночку, в группе или рейде, в рейде, до максимального уровня или на максимальном уровне."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Зелья и камни здоровья"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Макросы не могут изменяться во время боя (это ограничение Blizzard), поэтому каждый макрос Зелья и Камня здоровья создаётся заранее с вашим лучшим предметом и до двух запасных вариантов. В затяжных боях иконка и подсказка могут устареть и показывать не тот предмет, но клик по макросу всегда будет использовать лучший предмет, который у вас действительно есть в сумках."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] =
	"Использовать еду и воду в макросах зелий вне боя"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Вне боя ваш макрос Лечебного зелья использует вашу лучшую еду, а макрос Зелья маны лучшую воду. В бою они, как и раньше, используют ваши зелья. Свитки, еда для питомца и сотворение остаются в макросах Еды и Воды."
L["OPTIONS_COMBINE_HEALTHSTONES"] =
	"Объединить Камни здоровья в макрос Лечебного зелья"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Добавляет ваш лучший Камень здоровья в конец макроса Лечебного зелья, поэтому одно нажатие использует и зелье, и Камень здоровья."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Мана-камни и руны"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"Демонические и Темные руны, а также ещё несколько предметов для восполнения маны, имеют общее время восстановления с мана-камнями. Использование рун отнимает здоровье, поэтому макрос Мана-камня не включает ни один из этих предметов, пока вы сами их не добавите."
L["OPTIONS_INCLUDE_MANA_RUNES"] =
	"Добавить руны и другие предметы для восполнения маны в макрос Мана-камня"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"Учитывает наравне с мана-камнями ваши Демонические и Темные руны и любые другие предметы для восполнения маны с общим с ними временем восстановления, так что макрос Мана-камня использует такой предмет, когда это лучший вариант или когда у вас закончились камни."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Обновление баффов"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Макросы не могут изменяться во время боя, поэтому, если бафф истечёт посреди боя, его не будет до конца боя."
L["OPTIONS_REAPPLY"] = "Обновлять истекающие баффы"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Считает истёкшими баффы от еды с эффектом, свитков и еды для питомцев, если до их окончания осталось меньше заданного порога, чтобы макросы предложили новые ещё до начала боя."
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Задаёт, за сколько времени до истечения баффа макросы предложат новый."
L["REAPPLY_THRESHOLD_ONE"] = "Когда осталось < 1 минуты"
L["REAPPLY_THRESHOLD_MANY"] = "Когда осталось < %d минут"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Баффы от еды для питомцев"
L["OPTIONS_PET_SECTION_DESCRIPTION"] =
	'Некоторая еда даёт вашему питомцу собственный эффект "Сытость".'
L["OPTIONS_USE_PET_BUFFS"] = "Использовать баффы от еды для питомцев"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	'Добавляет еду для питомца в ваш макрос Еды, когда у питомца нет эффекта "Сытость", кроме как на аренах.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Включить типы еды для питомцев в проверку"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Взрывчатка"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"Вариант @player пропускает прицельный круг и подрывает взрывчатку прямо у ваших ног. Идеально, когда цель в ближнем бою. Другой кнопкой мыши вы бросаете взрывчатку как обычно."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Назначение кнопок"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Выбирает, какая кнопка мыши бросает взрывчатку, а какая подрывает её у ваших ног."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "ЛКМ @player"
L["EXPLOSIVES_MODE_TOSS"] = "ЛКМ Бросок"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "Друиды"
L["OPTIONS_DRUID_MACRO_HELPER"] = "Включить интеграцию DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Создаёт макросы смены облика для лечебных зелий, зелий маны и камней здоровья с помощью DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Выбирает облик, в который вас возвращают макросы смены облика после использования предмета."
L["DRUID_FORM_BEAR"] = "Вернуться в облик медведя"
L["DRUID_FORM_CAT"] = "Вернуться в облик кошки"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "Разбойники"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Держит макрос Ядов заряженным лучшим доступным рангом каждого типа яда. ЛКМ наносит яд на левую руку, ПКМ на правую, а нанесённые яды заменяются автоматически."
L["OPTIONS_POISON_MAIN_HAND"] = "Тип яда для правой руки"
L["OPTIONS_POISON_OFF_HAND"] = "Тип яда для левой руки"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Выбирает яд, который ваш макрос Ядов наносит на правую руку по ПКМ."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Выбирает яд, который ваш макрос Ядов наносит на левую руку по ЛКМ."
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "Включить незаметность при еде"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] =
	'Добавляет способность "Незаметность" в макрос Еды, чтобы вы уходили в незаметность во время еды.'

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "Ночные эльфы"
L["OPTIONS_STEALTH_DRINKING"] = "Включить незаметность при питье"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] =
	'Добавляет способность "Слиться с тенью" в макрос Воды, чтобы вы уходили в незаметность во время питья.'
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] =
	'Добавляет способность "Слиться с тенью" в макрос Еды, чтобы вы уходили в незаметность во время еды.'
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Совет профи: Выберите что-то одно. Есть и пить можно одновременно, но еда или питьё после ухода в незаметность прервёт её."

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
L["TAB_IGNORE_LIST"] = "Список игнорирования"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	'Игнорируемые предметы никогда не выбираются ни одним макросом. Еда, вода, зелья, что угодно. Список "Общий" действует для всех персонажей; список персонажа действует только для него. ПКМ по кнопке на миникарте, чтобы игнорировать вашу текущую лучшую еду.'
L["OPTIONS_IGNORE_GLOBAL"] = "Общий"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	'Переносит этот предмет в список "Общий", чтобы он игнорировался на всех персонажах.'
L["OPTIONS_IGNORE_ADD_ID"] = "Добавить по ID предмета"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Введите ID предмета или сделайте Shift + Клик по ссылке на предмет в чате, пока это поле активно."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"Введите ID предмета или сделайте Shift + Клик по ссылке на предмет в чате."
L["OPTIONS_IGNORE_REMOVE"] = "Убрать"
L["OPTIONS_IGNORE_EMPTY"] = "Список пуст."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Загрузка ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Поддерживает запасы в ваших сумках по списку пополнения, автоматически покупая у торговцев и перемещая предметы в банк и из банка. Введите %s, чтобы открыть список."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Открывать в банке"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] =
	"Открывает ваш список пополнения при посещении банка."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Открывать у торговца"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] =
	"Открывает ваш список пополнения при посещении торговца."
L["OPTIONS_RESTOCKER_REMIND"] = "Включить напоминания о пополнении в городе"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Выводит напоминание в чат, когда вам не хватает чего-то из списка пополнения и вы добираетесь до таверны или города либо уже находитесь в них при входе в игру."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] =
	"Включить напоминания о пополнении у торговца"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Сообщает о невыполненных заказах на пополнение, если такие есть, когда вы закрываете окно торговца."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Включить напоминания о пополнении в банке"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Сообщает о невыполненных заказах на пополнение, если такие есть, когда вы закрываете банк."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Включить запас золота"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] =
	"Пополнение никогда не тратит золото, отложенное здесь."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] =
	"Сколько золота пополнение всегда оставляет вам."

--[[
    The staples pop-up (STARTER_POPUP_TITLE below). This toggle and the
    pop-up's own "Don't Show This Again" box are the same per-character choice
    read from opposite ends, which is why one ships on and the other off: a
    settings row reads naturally as "enable", a dismissal reads naturally as
    "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] =
	"Включить всплывающее окно припасов, когда список пополнения пуст"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"Предлагает припасы для вашего класса при входе в игру, если список пополнения этого персонажа пуст."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Выбирает, состоит ли напоминание из одной строки или добавляет по строке на каждый недостающий предмет."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Кратко"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Подробно"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Проигрывать звук"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Проигрывает сигнал вместе с напоминанием на случай, если в чате оживлённо."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Нажмите, чтобы прослушать сигнал."

L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Напоминания"
L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Окно списка пополнения"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] =
	"Выберите, когда ваш список пополнения будет открываться сам."

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Показывает в подсказке предмета, сколько таких предметов есть у всех ваших персонажей в этом игровом мире."
L["OPTIONS_INVENTORY_REPORT"] =
	"Включить отчёт об инвентаре в подсказках предметов"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"Добавляет в подсказку предмета, сколько таких предметов у вас в сумках, в банке и у других ваших персонажей. Отключите отчёт, если другой аддон уже показывает эти числа."

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Благодарности"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"Я всегда любил Restocker и рад, что он продолжает жить внутри Connoisseur. Огромное спасибо ChiliFajita, автору оригинального Auto Restocker, а также kvakvs и guardycmw, которые поддерживали его в Classic и Mists of Pandaria."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Отчёт о готовности"
L["OPTIONS_READINESS_ENABLE"] =
	"Включить отчёт о готовности при проверке готовности"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] =
	"Включает отчёт о готовности для всех персонажей этой учётной записи."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Когда начинается проверка готовности, выводит видимый только вам список того, что ещё нужно исправить, а если вы готовы, не пишет ничего."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Сбросить настройки отчёта о готовности"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Возвращает все флажки и оба порога на этой странице к значениям по умолчанию, не затрагивая остальные страницы."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Сбросить все настройки отчёта о готовности к значениям по умолчанию? Это также снова выключит сам отчёт."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Не хватает баффов"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Не хватает предметов"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Персонаж"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Сообщает об отсутствии настоя. Настой либо один боевой и один охранный эликсир засчитываются."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	'Сообщает об отсутствии эффекта "Сытость". Требуется включить настройку "Еда с эффектом" в разделе "Макросы".'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	'Сообщает, если у питомца нет эффекта "Сытость". Требуется включить "Баффы от еды для питомцев" в разделе "Макросы" и призвать питомца.'
L["OPTIONS_READINESS_SCROLLS"] = "Баффы от свитков"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	'Сообщает об отсутствующих баффах от свитков. Требуется включить "Баффы от свитков" в разделе "Макросы"; проверяются только выбранные там типы свитков.'
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Сообщает, когда ни на ком из вашей группы нет активного Камня души; камень в сумке не считается. Показывается только чернокнижнику, который может его создать."
L["OPTIONS_READINESS_MAIN_HAND"] = "Бафф оружия (правая рука)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Сообщает, если на оружии в правой руке нет временного улучшения. Засчитывается любое улучшение; если в вашей группе есть шаман, эта проверка не срабатывает."
L["OPTIONS_READINESS_OFF_HAND"] = "Бафф оружия (левая рука)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Сообщает, если на оружии в левой руке нет временного улучшения. Засчитывается любое улучшение: камень, масло, яд или шаманский бафф оружия."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Баффы истекают в течение"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	'Называет каждый бафф на вас, который скоро истечёт, а не только наложенные Connoisseur, и не зависит от настройки "Обновление баффов" в разделе "Макросы".'
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s мин"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 мин"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Задаёт, за сколько времени до истечения баффа отчёт назовёт его."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Сообщает, когда у вас нет Камня здоровья. Показывается, только когда в группе есть чернокнижник, у которого можно попросить камень, или когда вы сами чернокнижник."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Сообщает, когда у вас нет мана-камня. Показывается только магу, который может его сотворить."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Сообщает, когда у вас нет лечебного зелья, ведь посреди боя вам его никто не передаст."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Сообщает, когда у вас нет зелья маны. Показывается, только если вы играете за класс, использующий ману."
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] =
	"Сообщает, когда у вас нет бинтов, которые позволяет использовать ваш навык Первой помощи."
L["OPTIONS_READINESS_DURABILITY"] = "Повреждённое снаряжение ниже"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Приводит ссылки на все надетые предметы с прочностью ниже этого значения, считая по каждому предмету отдельно, так что даже одно сломанное оружие будет видно."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Задаёт, насколько низко должна упасть прочность предмета, чтобы отчёт привёл ссылку на него."

-- Character
L["OPTIONS_READINESS_SPEC"] = "Текущая специализация"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] =
	"Выводит распределение талантов и очки, которые вы ещё не потратили."
L["OPTIONS_READINESS_PVP"] = "Включён режим PvP"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] =
	"Предупреждает, когда у вас включён режим PvP."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Надето небоевое снаряжение"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"Приводит ссылки на надетые предметы, которым не место в бою, например Ездовой хлыст или удочку."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Список с именем "%s" уже существует.'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "Нет предмета с ID %d."
L["RESTOCKER_BANK_NOT_OPEN"] = "Банк не открыт."
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Пополнение завершено. Удерживайте Shift при открытии банка, чтобы пропустить пополнение. Введите %s, чтобы изменить список пополнения."
L["RESTOCKER_STOPPED_BOTH_FULL"] =
	"Пополнение остановлено. Ваши сумки и банк переполнены."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Пополнение остановлено. Ваш банк переполнен; освободите ячейку и откройте его снова."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Пополнение остановлено. Ваши сумки переполнены; освободите ячейку и откройте банк снова."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Пополнение остановлено. Продвижения нет."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] =
	"Пополнение остановлено. Не удалось переместить: %s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (лишнее)"
L["RESTOCKER_STOPPED_ERROR"] = "Пополнение остановлено из-за ошибки: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"У этого торговца есть не все ингредиенты, необходимые для ваших ядов. Ни один из них не будет куплен."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Не забудьте пополнить запасы, пока вы в городе!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 заказ на пополнение не выполнен."
L["RESTOCKER_STILL_SHORT_MANY"] = "Не выполнено заказов на пополнение: %d."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Ваш список пополнения улучшен."
L["RESTOCKER_UPGRADED_ITEM"] = "Было: %sx%d, стало: %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 заказ на пополнение выполнен."
L["RESTOCKER_RESTOCKED_MANY"] = "Выполнено заказов на пополнение: %d."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 заказ на пополнение выполнен частично."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] =
	"Частично выполнено заказов на пополнение: %d."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] =
	"Сумки заполнились раньше, чем удалось всё купить."
L["RESTOCKER_OUT_OF_GOLD"] =
	"Недостаточно золота, чтобы завершить пополнение."
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Пополнение приостановлено: недостаточно золота. Оно возобновится, как только сможет выполнить ваши заказы на покупку, не трогая ваш запас (%s)."

-- /crs help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[имя]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Добавляет список с этим именем."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Удаляет список с этим именем."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Даёт текущему списку указанное имя."
L["RESTOCKER_HELP_PROFILE_COPY"] =
	"Заменяет текущий список копией списка с этим именем."
L["RESTOCKER_HELP_PROFILE_USE"] =
	"Переключает этого персонажа на список с этим именем."

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
L["STARTER_POPUP_TITLE"] = "Припасы Connoisseur"
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Ваш список пополнения пуст, так что давайте добавим несколько предметов для начала."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] =
	"Выберите припасы, которые хотите держать в запасе."
L["STARTER_POPUP_INTRO_HOW"] =
	"Всё, что вы отметите, будет автоматически пополняться при открытии окна торговца или банка. Базовые товары сами улучшаются по мере роста уровня, так что у вас всегда будет лучшее из доступного."
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Вы всегда можете изменить этот список или добавить предметы позже, введя %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Еда и вода"
L["STARTER_POPUP_FOOD_HEADER"] = "Еда"
L["STARTER_POPUP_AMMO_HEADER"] = "Боеприпасы"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Пули"
L["STARTER_POPUP_ARROWS"] = "Стрелы"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header reuses PREFIX_ROGUE (rogue-colored at the call
    site) to say the ingredients take care of themselves. Both sections name
    their rows with the client's own item names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Реагенты и инструменты"
L["STARTER_POPUP_POISONS_HEADER"] = "Яды"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Добавьте готовый яд в список, и Connoisseur будет автоматически покупать ингредиенты у любого торговца, который продаёт их все."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Добавляет предмет %s в список пополнения, держит в сумках %d шт. и улучшает их по мере роста уровня."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] =
	"Добавляет предмет %s в список пополнения и держит в сумках %d шт."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 стопка"
L["STARTER_POPUP_STACK_MANY"] = "Стопок: %d"
L["STARTER_POPUP_STACKS_DESCRIPTION"] =
	"Сколько стопок держать в запасе, по %d в каждой."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Сколько держать в запасе, каждый предмет в отдельной ячейке сумки, так как они не складываются в стопки."
L["STARTER_POPUP_DISMISS"] = "Больше не показывать для этого персонажа"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] =
	"Не даёт этим предложениям появляться снова при входе, когда список пополнения пуст."

-- Restock List window UI. The title names what the window holds; the feature that acts on it stays "Restocker".
L["RESTOCKER_WINDOW_TITLE"] = "Список пополнения Connoisseur"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Фильтр предметов..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Очистить"
L["RESTOCKER_ADD_BUTTON"] = "Добавить"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. The keys keep the pop-up's
    earlier name, the List Builder. "Check" is the pop-up's own word
    (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "Выбрать припасы"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"Выберите из припасов для вашего класса и уровня: еда, вода, боеприпасы, яды и реагенты. Отмеченный предмет добавляется в этот список, а при снятии отметки убирается из него."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Добавить предмет"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Перетащите предмет из сумок сюда или в любое место этого окна либо введите ID предмета и нажмите Enter."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Перетащите или введите ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Лучше введите ID предмета."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Добавить из сумок"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Все предметы из ваших сумок, которых ещё нет в этом списке. Нажмите на предмет, чтобы добавить его."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "В сумках нечего добавить"

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
L["RESTOCKER_PROFILE_LABEL"] = "Список"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Нажмите, чтобы переключить этого персонажа на другой список пополнения или создать новый."
L["RESTOCKER_USED_BY"] = "Используют: %s"
L["RESTOCKER_MANAGE"] = "Управлять списками"
L["RESTOCKER_MANAGE_TOOLTIP"] =
	"Создайте новый список либо скопируйте, переименуйте или удалите этот."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu. The Copy and Delete keys end in
    _TOOLTIP because they began as the tooltips of two buttons this menu
    replaced.
]]
L["RESTOCKER_NEW_PROFILE"] = "Новый список"
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "Копировать этот список в новый"
L["RESTOCKER_RENAME_PROFILE"] = "Переименовать этот список"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "Удалить этот список"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s (копия)"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Переименовать"
L["RESTOCKER_RENAME_TOOLTIP"] =
	"Переименовывает этот список для всех персонажей, которые его используют."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Вы уверены, что хотите удалить этот список?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s тоже использует этот список и при входе в игру получит пустой список с тем же именем."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s тоже используют этот список, и каждый при входе в игру получит пустой список с тем же именем."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Вы переключитесь на список %s."
L["RESTOCKER_DELETE_LIST_LAST"] =
	"Это единственный оставшийся список, поэтому вы начнёте с нового пустого списка."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Это нельзя отменить."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Улучшать по мере роста уровня"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Позволяет Connoisseur заменять еду, воду, боеприпасы, яды, зелья и классовые реагенты на более качественные по мере роста уровня."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Банк"
L["RESTOCKER_ROW_MERCHANT"] = "Торговец"
L["RESTOCKER_ROW_UPGRADE"] = "Улучшение"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Предмет"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Взять"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Сложить"
L["RESTOCKER_COLUMN_REPUTATION"] = "Реп."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Норма"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] =
	"Нажмите на заголовок, чтобы задать это для всех видимых предметов."
L["RESTOCKER_BULK_ON"] = "Включить для видимых (%d)"
L["RESTOCKER_BULK_OFF"] = "Отключить для видимых (%d)"

L["RESTOCKER_GROUP_OTHER"] = "Прочее"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Новые"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Все предметы"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_LIST_BUILDER_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "В этом списке пока ничего нет"
L["RESTOCKER_EMPTY_BODY"] =
	"Выберите припасы, такие как еда, вода или классовые реагенты, либо добавьте что угодно из сумок через меню выше. Выбранные предметы автоматически пополняются или складываются в банк, так что в ваших сумках всегда порядок."
L["RESTOCKER_EMPTY_DROP_HINT"] =
	"Предмет также можно добавить, перетащив его в любое место этого окна."
L["RESTOCKER_NO_MATCH_FILTER"] = "Ничто в этом списке не подходит под ваш фильтр."
L["RESTOCKER_NO_MATCH_GROUP"] = "В этой категории ничего не осталось."

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
L["RESTOCKER_NO_ORDERS"] = "Невыполненных заказов на пополнение нет."
L["RESTOCKER_REPORT_MORE"] = "и ещё %d"
L["RESTOCKER_REMOVED_ITEM"] = "Убрано: %s."
L["RESTOCKER_UNDO"] = "Отменить"
L["RESTOCKER_UNDO_TOOLTIP"] = "Вернуть этот предмет в список"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Убрать этот предмет из списка пополнения"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Это можно отменить внизу окна."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Норма в сумках"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'Сколько держать в сумках. Число становится жёлтым, пока в сумках меньше нормы, а норма 0 при включённом "Сложить" отправляет в банк всё.'
L["RESTOCKER_BUY_LABEL"] = "Купить"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Покупать у торговца"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Покупает нужное количество у торговца, когда открыто окно торговца."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Сверх"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Покупать сверх нормы"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Выкупает у торговца весь ограниченный запас этого предмета, который он понемногу пополняет, даже сверх вашей нормы."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Складывать в банк"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	'Складывает лишние предметы в банк, когда он открыт, или все, если в столбце "Норма" указан 0.'
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Брать из банка"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] =
	"Берёт нужные предметы из банка, когда он открыт."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Требуемая репутация"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (скидка %d%%)"
L["RESTOCKER_REPUTATION_ANY"] = "Любая"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "Дружелюбие"
L["RESTOCKER_REPUTATION_HONORED"] = "Уважение"
L["RESTOCKER_REPUTATION_REVERED"] = "Почтение"
L["RESTOCKER_REPUTATION_EXALTED"] = "Превознесение"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Требуемая репутация у торговца"
--[[
    Quotes the cell's own values, which couples this line to the four standings
    above: a locale that renders a standing differently has to say so here too.
    With no standing required the cell draws a dash rather than the word "Any",
    which is why the last sentence names the dash; "Any" is still the menu's
    first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	"Нажмите, чтобы указать уровень репутации, начиная с которого Connoisseur покупает у торговца; репутация также снижает цену: Дружелюбие 5%, Уважение 10%, Почтение 15%, Превознесение 20%. Прочерк означает покупку у любого торговца."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	'Для этого предмета отключено "Купить", поэтому покупать сверх нормы нечего.'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	'Для этого предмета отключено "Купить", поэтому репутация не учитывается.'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] =
	"Для этого предмета нет более качественной замены."
