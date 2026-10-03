local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "zhTW")
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

L["MACRO_BANDAGE"] = "- 繃帶"
L["MACRO_EXPLOSIVES"] = "- 爆炸物"
L["MACRO_FEED_PET"] = "- 餵養寵物"
L["MACRO_FOOD"] = "- 食物"
L["MACRO_HEALTH_POTION"] = "- 治療藥水"
L["MACRO_HEALTHSTONE"] = "- 治療石"
L["MACRO_MANA_GEM"] = "- 法力寶石"
L["MACRO_MANA_POTION"] = "- 法力藥水"
L["MACRO_POISONS"] = "- 毒藥"
L["MACRO_SOULSTONE"] = "- 靈魂石"
L["MACRO_WATER"] = "- 水"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of a list: a Readiness Report clause, the Restocker's "Couldn't move" list, or the characters on a Restock List.
L["LIST_SEPARATOR"] = "、"
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

    They are ALSO the food checkbox labels in the staples pop-up, so they
    read as ordinary labels while carrying that hard constraint. Translate them
    as the client's own diet words, never as the nicer label they look like --
    a locale that "improves" one here stops matching that client's strings and
    silently breaks pet-food selection for everyone playing in it.
]]

L["DIET_BREAD"] = "麵包"
L["DIET_CHEESE"] = "乳酪"
L["DIET_FISH"] = "魚"
L["DIET_FRUIT"] = "水果"
L["DIET_FUNGUS"] = "蘑菇"
L["DIET_MEAT"] = "肉"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"看來你發現了一個錯誤！%s (%s) 無法在 %s > %s (%s) 使用。請將此問題回報給我們，以便修正。謝謝！%s"
L["MESSAGE_NO_ITEM"] = "背包中未找到合適的%s。"
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"由於你的巨集欄位已滿，部分 Connoisseur 巨集未能建立。請刪除不再使用的巨集以騰出欄位，或在 選項 > 插件 > Connoisseur > 巨集 中關閉不需要的 Connoisseur 巨集。"

L["CHAT_LOADED"] =
	"版本 %s。設定（包括停用此訊息的選項）可以在 選項 > 插件 > Connoisseur 中找到。喜歡這個插件嗎？告訴朋友吧！(="

L["CHAT_OPTIONS_IN_COMBAT"] = "基於安全考量，戰鬥中無法開啟選項介面。"

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

L["READINESS_TITLE"] = "就緒報告"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s%s"
L["READINESS_CLAUSE_SEPARATOR"] = "。"

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "缺少增益："
L["READINESS_EXPIRING"] = "即將到期："
L["READINESS_MISSING_ITEMS"] = "缺少物品："
L["READINESS_DAMAGED_GEAR"] = "受損裝備："
L["READINESS_CHARACTER"] = "角色："
L["READINESS_QUESTIONABLE_GEAR"] = "裝備了非戰鬥裝備："

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
L["READINESS_FLASK"] = "精煉藥劑或 2 種藥劑"
L["READINESS_WELL_FED"] = "進食充分"
L["READINESS_PET_WELL_FED"] = "進食充分（寵物）"
L["READINESS_SCROLLS"] = "卷軸"
L["READINESS_SOULSTONE"] = "靈魂石未啟用"
L["READINESS_MAIN_HAND"] = "主手"
L["READINESS_OFF_HAND"] = "副手"
L["READINESS_HEALTHSTONE"] = "治療石"
L["READINESS_MANA_GEM"] = "法力寶石"
L["READINESS_HEALING_POTION"] = "治療藥水"
L["READINESS_MANA_POTION"] = "法力藥水"
L["READINESS_BANDAGES"] = "繃帶"
L["READINESS_PVP_ON"] = "PvP 已開啟！"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d 分鐘"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s 不足 1 分鐘"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 個未使用的天賦點"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d 個未使用的天賦點"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "你目前沒有任何對寵物有用的食物。"
L["TIP_PET_NO_SKILLS"] = "你目前還沒有學會召喚寵物、解散野獸、餵養寵物或復活寵物。"
L["TIP_PET_NO_MEND"] = "你目前還沒有學會治療寵物。"
L["TIP_NO_HAND_POISON"] = "這把武器所選的毒藥已用完。"

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "你目前還沒有學會%s。"

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "增益食物"
L["MENU_BUFF_FOOD_DESCRIPTION"] = '缺少"進食充分"增益時，優先使用可提供該增益的食物。'
L["FEATURE_SCROLL_BUFFS"] = "卷軸增益"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] = "進食前，透過你的食物巨集補上缺少的卷軸增益。"

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Attention Hunters block, and the two poison titles open the
    Attention Rogues block.
]]
L["MINIMAP_BEST_FOOD"] = "當前食物"
L["MINIMAP_BEST_PET_FOOD"] = "當前寵物食物"
L["MINIMAP_MAIN_HAND_POISON"] = "主手毒藥"
L["MINIMAP_OFF_HAND_POISON"] = "副手毒藥"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "忽略列表"
L["MINIMAP_IGNORE_COUNT"] = "%d 件物品"
L["MENU_IGNORE"] = "忽略"
L["MENU_CLEAR_IGNORE"] = "清除忽略列表"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker 報告"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d 項未完成訂單"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "恭喜，你的補給已全部備齊！"
L["MINIMAP_RESTOCKER_EMPTY"] = "你的清單是空的。"

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Restocker 清單"
L["MENU_RESTOCKER_DESCRIPTION"] = "購買你清單上的物品，並在銀行存取。"
L["MENU_RESTOCKER_KEYBIND"] = "Shift + 右鍵點擊"
L["MENU_OPTIONS"] = "Connoisseur 選項"
L["MENU_OPTIONS_KEYBIND"] = "Shift + 中鍵點擊"

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The class block of the mini-map tooltip: a class-colored header, the items
    the class's own macro will use (a Hunter's pet food, a Rogue's two poisons,
    titled in the Minimap Tooltip section above), then one group per macro.
]]

L["PREFIX_HUNTER"] = "獵人請注意"
L["PREFIX_MAGE"] = "法師請注意"
L["PREFIX_ROGUE"] = "盜賊請注意"
L["PREFIX_WARLOCK"] = "術士請注意"

--[[
    A group is the macro's name, then one row per click: the click on the left
    and what it does on the right. The right-hand column never wraps, so each
    result stays a few words. A spell the row casts is named by the client
    (Mend Pet, Ritual of Refreshment, Ritual of Souls) and has no key here, and
    a plain click reuses MINIMAP_LEFT_CLICK, MINIMAP_RIGHT_CLICK or
    MINIMAP_MIDDLE_CLICK.
]]
L["NOTE_MACRO_FEED_PET"] = "餵養寵物巨集"
L["NOTE_MACRO_FOOD_WATER"] = "食物和水巨集"
L["NOTE_MACRO_MANA_GEM"] = "法力寶石巨集"
L["NOTE_MACRO_HEALTHSTONE"] = "治療石巨集"
L["NOTE_MACRO_SOULSTONE"] = "靈魂石巨集"
L["NOTE_MACRO_POISONS"] = "毒藥巨集"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "召喚、餵養或復活"
L["NOTE_PET_MEND_CLICK"] = "右鍵點擊，或戰鬥中點擊"
L["NOTE_HOLD_SHIFT"] = "按住 Shift"
L["NOTE_PET_FORCE_REVIVE"] = "強制復活"
L["NOTE_HOLD_CONTROL"] = "按住 Ctrl"
L["NOTE_PET_DISMISS"] = "解散"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "製造"
L["NOTE_CREATE"] = "製造"
L["NOTE_RIGHT_CLICK_AGAIN"] = "再次右鍵點擊"
L["NOTE_LOWER_RANK_BACKUP"] = "低等級備用"
L["NOTE_MAGE_TARGET_LEVEL"] = "以等級較低的玩家為目標，即可依其等級製造。"
L["NOTE_WARLOCK_TARGET_LEVEL"] = "以等級較低的玩家為目標，即可依其等級製造一顆治療石。"

-- Rogue. The two hands are the results of a Left-Click and a Right-Click on the Poisons macro.
L["MINIMAP_MAIN_HAND"] = "主手"
L["MINIMAP_OFF_HAND"] = "副手"
L["NOTE_POISONS_WINDOW"] = "毒藥視窗"
L["NOTE_POISONS_REPLACED"] = "自動替換舊毒藥。"

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "繃帶"
L["LABEL_EXPLOSIVE"] = "爆炸物"
L["LABEL_FOOD"] = "食物"
L["LABEL_HEALTH_POTION"] = "治療藥水"
L["LABEL_HEALTHSTONE"] = "治療石"
L["LABEL_MANA_GEM"] = "法力寶石"
L["LABEL_MANA_POTION"] = "法力藥水"
L["LABEL_PET_FOOD"] = "寵物食物"
L["LABEL_POISONS"] = "毒藥"
L["LABEL_SOULSTONE"] = "靈魂石"
L["LABEL_WATER"] = "水"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "已啟用"
L["MINIMAP_DISABLED"] = "已停用"
L["MINIMAP_TOGGLE"] = "切換"
L["MINIMAP_OPEN"] = "開啟"
L["MINIMAP_LEFT_CLICK"] = "左鍵點擊"
L["MINIMAP_RIGHT_CLICK"] = "右鍵點擊"
L["MINIMAP_MIDDLE_CLICK"] = "中鍵點擊"
L["MINIMAP_SHIFT_LEFT"] = "Shift + 左鍵點擊"

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
	"選擇你的食物巨集何時提供%s：總是提供，或僅在單人時、隊伍或團隊中、團隊中、練等時或滿等時提供。"
L["MODE_ALWAYS"] = "總是"
L["MODE_SOLO"] = "單人時"
L["MODE_PARTY"] = "在隊伍或團隊中時"
L["MODE_RAID"] = "在團隊中時"
L["MODE_LEVELING"] = "練等時"
L["MODE_MAX_LEVEL"] = "滿等時"

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
L["INVENTORY_REPORT_TITLE"] = "庫存報告"
L["INVENTORY_REPORT_BAGS"] = "背包"
L["INVENTORY_REPORT_BANK"] = "銀行"
-- In place of the Bank count, muted, until this character's bank has been opened once with the add-on running.
L["INVENTORY_REPORT_BANK_UNKNOWN"] = "未知"
-- Everything above it added up: this character and every other one on the realm.
L["INVENTORY_REPORT_TOTAL"] = "總計"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"自動取用你最好的食物、水、藥水、治療石、繃帶、毒藥和寵物食物的巨集，外加一份補貨清單，自動購買並在銀行存取你的消耗品，還會讓它們隨等級升級。為巔峰表現打造的便利性自動化。"

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "啟用歡迎訊息"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "登入時在聊天視窗中輸出歡迎訊息。"

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "啟用小地圖按鈕"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "顯示小地圖按鈕。"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "開啟此插件的選項介面。"
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "開啟你的補貨清單。"

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "回饋與支援"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["CURSEFORGE"] = "CurseForge"
L["WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "版本 %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Enable Macros header below titles the first section,
    after the page's one headerless toggle, Macro Names on Buttons.
]]
L["TAB_MACROS"] = "巨集"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur 會為每種消耗品各建立一個巨集，並隨著背包變化保持更新，讓你快捷列上的按鈕始終取用你身上最好的物品。請在下方選擇要建立哪些巨集，然後設定每個巨集如何挑選物品。"

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "在按鈕上顯示巨集名稱"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"在你的快捷列按鈕上顯示巨集名稱文字，Connoisseur 預設會隱藏這些文字。"

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "啟用巨集"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"選擇 Connoisseur 要建立並維護哪些巨集。關閉某個巨集也會將其移除。"
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "建立並維護此巨集，取消勾選時會將其移除。"

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "食物與水"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"你的食物和水巨集會使用背包中最好的食物和飲料。這些選項可以讓增益食物、卷軸或魔法製造的食物和水優先，並讓補貨清單中的食物和水最後使用。"

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "優先增益食物"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'缺少"進食充分"增益時，優先使用可提供該增益的食物，競技場中除外。'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "啟用卷軸增益"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"你的食物巨集第一次按下時會使用缺少的卷軸，再按一次則進食；以友方玩家為目標或身處競技場時會跳過卷軸。"
L["OPTIONS_SCROLL_TYPES"] = "在檢查中包含卷軸類型"
L["OPTIONS_SCROLL_AGILITY"] = "敏捷"
L["OPTIONS_SCROLL_INTELLECT"] = "智力"
L["OPTIONS_SCROLL_PROTECTION"] = "保護"
L["OPTIONS_SCROLL_SPIRIT"] = "精神"
L["OPTIONS_SCROLL_STAMINA"] = "耐力"
L["OPTIONS_SCROLL_STRENGTH"] = "力量"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = '檢查缺少的增益時包含"%s"。'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "優先使用魔法製造的食物與水"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'魔法製造的食物和水不花錢，並會在你離線後不久消失，因此你的食物和水巨集會優先使用它們，即使背包裡有恢復量更高的物品。開啟"優先增益食物"時，增益食物仍然最先使用。'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"選擇魔法製造的食物和水何時優先：總是優先，或僅在單人時、隊伍或團隊中、團隊中、練等時或滿等時優先。"

-- Use Restock List Food & Water Last, the fourth option under Food & Water.
L["OPTIONS_RESTOCK_LAST"] = "最後使用補貨清單中的食物與水"
L["OPTIONS_RESTOCK_LAST_DESCRIPTION"] =
	"當兩種食物或飲料恢復量相同時，你的食物和水巨集會先使用不在補貨清單上的那種，把補貨清單購買的留到以後。"

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "藥水與治療石"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"巨集在戰鬥中無法更改（這是暴雪的限制），因此每個藥水和治療石巨集都預先包含你最好的物品以及最多兩個備用物品。在較長的戰鬥中，圖示和提示可能會過時並顯示錯誤的物品，但點擊該巨集將始終使用你背包中實際擁有的最佳物品。"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "非戰鬥時在藥水巨集中使用食物與水"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"非戰鬥時，你的治療藥水巨集會食用你最好的食物，法力藥水巨集會飲用你最好的水。戰鬥中則照舊使用你的藥水。卷軸、寵物食物和魔法製造仍保留在食物和水巨集中。"
L["OPTIONS_COMBINE_HEALTHSTONES"] = "將治療石合併到治療藥水巨集中"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"將你最好的治療石加入治療藥水巨集的底部，這樣按一次即可同時使用藥水和治療石。"

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "法力寶石與符文"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"惡魔符文、黑暗符文以及另外幾種法力物品，都與法力寶石共用冷卻時間。符文使用時會消耗生命力，因此除非你選擇加入，否則法力寶石巨集不會包含其中任何一種。"
L["OPTIONS_INCLUDE_MANA_RUNES"] = "將符文與其他法力物品加入法力寶石巨集"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"將你的惡魔符文、黑暗符文，以及任何其他與法力寶石共用冷卻時間的法力物品，和你的法力寶石一同排序，這樣當其中某件物品是你的最佳選擇，或你的法力寶石用完時，法力寶石巨集就會使用該物品。"

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "增益重新施放"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"巨集在戰鬥中無法更改，因此戰鬥中途到期的增益會一直缺失，直到戰鬥結束。"
L["OPTIONS_REAPPLY"] = "提前補充即將到期的增益"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"將剩餘時間低於你所設門檻的增益食物、卷軸增益和寵物食物增益視為已到期，讓你的巨集在開怪前提供新的增益。"
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"設定增益離到期還剩多久時，你的巨集就會提供新的增益。"
L["REAPPLY_THRESHOLD_ONE"] = "當剩餘不足 1 分鐘時"
L["REAPPLY_THRESHOLD_MANY"] = "當剩餘不足 %d 分鐘時"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "寵物食物增益"
L["OPTIONS_PET_SECTION_DESCRIPTION"] = '少數食物會為你的寵物提供專屬的"進食充分"增益。'
L["OPTIONS_USE_PET_BUFFS"] = "使用寵物食物增益"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	'當你的寵物缺少"進食充分"增益時，將寵物食物加入你的食物巨集，競技場中除外。'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "在檢查中包含寵物食物類型"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "爆炸物"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"@player 選項會跳過目標指示圈，直接將爆炸物在你腳下引爆，非常適合目標處於近戰距離時使用。另一個鍵則照常投擲。"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "點擊方式"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"選擇用哪個鍵投擲爆炸物，用哪個鍵將它在你腳下引爆。"
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "左鍵點擊 @player"
L["EXPLOSIVES_MODE_TOSS"] = "左鍵點擊投擲"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "德魯伊"
L["OPTIONS_DRUID_MACRO_HELPER"] = "啟用 DruidMacroHelper 整合"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"使用 DruidMacroHelper (/dmh) 為治療藥水、法力藥水和治療石建立變形巨集。"
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] = "選擇你的變形巨集在使用物品後讓你返回哪種形態。"
L["DRUID_FORM_BEAR"] = "返回熊形態"
L["DRUID_FORM_CAT"] = "返回獵豹形態"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "盜賊"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"讓毒藥巨集始終裝載每種毒藥類型可用的最高等級。左鍵塗抹副手，右鍵塗抹主手，既有毒藥會自動替換。"
L["OPTIONS_POISON_MAIN_HAND"] = "主手毒藥類型"
L["OPTIONS_POISON_OFF_HAND"] = "副手毒藥類型"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] = "選擇你的毒藥巨集在右鍵點擊時塗抹到主手的毒藥。"
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] = "選擇你的毒藥巨集在左鍵點擊時塗抹到副手的毒藥。"
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "啟用進食時潛行"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] = "將潛行加入你的食物巨集中，以便你在進食時潛行。"

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "夜精靈"
L["OPTIONS_STEALTH_DRINKING"] = "啟用喝水時潛行"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] = "將影遁加入你的水巨集中，以便你在喝水時潛行。"
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] =
	"將影遁加入你的食物巨集中，以便你在進食時潛行。"
L["OPTIONS_STEALTH_PICK_ONE"] =
	"專業提示：只選一個。你可以同時進食和喝水，但潛行後再進食或喝水會解除潛行。"

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
L["TAB_IGNORE_LIST"] = "忽略列表"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"被忽略的物品永遠不會被任何巨集選用。食物、水、藥水，任何東西都一樣。全域列表對所有角色生效；角色列表只對該角色生效。右鍵點擊小地圖按鈕可忽略你當前的最佳食物。"
L["OPTIONS_IGNORE_GLOBAL"] = "全域"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] = "將此物品移至全域列表，使其在所有角色上都被忽略。"
L["OPTIONS_IGNORE_ADD_ID"] = "以物品 ID 新增"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"輸入物品 ID，或在此輸入框取得焦點時按住 Shift + 點擊聊天中的物品連結。"
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "輸入物品 ID，或按住 Shift + 點擊聊天中的物品連結。"
L["OPTIONS_IGNORE_REMOVE"] = "移除"
L["OPTIONS_IGNORE_EMPTY"] = "此列表為空。"
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "正在載入 ID：%d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"根據你的補貨清單保持背包物資充足，自動向商人購買，並在背包與銀行之間搬運物品。輸入 %s 開啟清單。"
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "在銀行開啟"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "造訪銀行時開啟你的補貨清單。"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "在商人處開啟"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "造訪商人時開啟你的補貨清單。"
L["OPTIONS_RESTOCKER_REMIND"] = "啟用城鎮補貨提醒"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"當補貨清單尚有缺口，且你抵達旅店或城市，或登入時已身處其中，在聊天中輸出提醒。"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "啟用商人補貨提醒"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] = "關閉商人視窗時，回報所有未完成的補貨訂單。"
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "啟用銀行補貨提醒"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "關閉銀行時，回報所有未完成的補貨訂單。"

--[[
    The staples pop-up (STARTER_POPUP_TITLE below). This toggle and the
    pop-up's own "Don't Show This Again" box are the same per-character choice
    read from opposite ends, which is why one ships on and the other off: a
    settings row reads naturally as "enable", a dismissal reads naturally as
    "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] = "補貨清單為空時啟用基礎物資彈出視窗"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"當此角色的補貨清單為空時，在登入時提供適合你職業的基礎物資。"

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"選擇提醒只有一行，還是為你缺少的每件物品各加一行。"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "簡潔"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "詳細"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "播放音效"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] = "在提醒的同時播放提示音，適合聊天繁忙的時候。"
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "點擊試聽提示音。"

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "補貨清單視窗"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "選擇你的補貨清單何時自動開啟。"

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"在物品提示中顯示你在本伺服器所有角色上共有多少件該物品。"
L["OPTIONS_INVENTORY_REPORT"] = "在物品提示中啟用庫存報告"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"在物品提示中加入該物品在你的背包、銀行和其他角色身上各有多少件。如果其他插件已經顯示這些數量，請將其關閉。"

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "致謝"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"我一直很喜歡 Restocker，很感激能有機會讓它在 Connoisseur 中延續下去。非常感謝撰寫最初 Auto Restocker 的 ChiliFajita，以及在經典版與潘達利亞之謎期間一直維護它的 kvakvs 和 guardycmw。"

-- Readiness Report
L["TAB_READINESS_REPORT"] = "就緒報告"
L["OPTIONS_READINESS_ENABLE"] = "在準備確認時啟用就緒報告"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] = "為此帳號的所有角色開啟就緒報告。"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"準備確認開始時，輸出一份僅你可見的清單，列出仍需處理的事項；如果你已準備就緒，則完全不會輸出任何內容。"

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "重置就緒報告設定"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"將本頁的所有核取方塊和兩個門檻恢復為預設值，其他頁面皆不受影響。"
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"將就緒報告的所有設定重置為預設值？這也會重新關閉報告本身。"

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "缺少增益"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "缺少物品"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "角色"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"缺少精煉藥劑時提醒。一瓶精煉藥劑，或作戰藥劑與守護藥劑各一瓶，均視為已滿足。"
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	'缺少"進食充分"增益時提醒。需要在巨集頁面中開啟增益食物。'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	'你的寵物缺少"進食充分"增益時提醒。需要在巨集頁面中開啟寵物食物增益，並且已召喚出寵物。'
L["OPTIONS_READINESS_SCROLLS"] = "卷軸增益"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"缺少卷軸增益時提醒。需要在巨集頁面中開啟卷軸增益，並且只檢查該處所選的卷軸類型。"
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"當隊伍中沒有人身上有生效的靈魂石時提醒；背包裡的靈魂石不算。僅對能製造靈魂石的術士顯示。"
L["OPTIONS_READINESS_MAIN_HAND"] = "主手武器增益"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"主手武器沒有臨時附魔時提醒。任何附魔都算，且隊伍中有薩滿時不會回報此項。"
L["OPTIONS_READINESS_OFF_HAND"] = "副手武器增益"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"副手武器沒有臨時附魔時提醒。任何附魔都算：磨刀石、油劑、毒藥或薩滿的武器增益。"
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "增益到期時間少於"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"列出你身上所有即將到期的增益，而不僅是 Connoisseur 施加的那些；此設定與巨集頁面中的增益重新施放相互獨立。"
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s 分鐘"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 分鐘"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"設定增益離到期還剩多久時，報告才會列出它。"

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"當你身上沒有治療石時提醒。僅當隊伍中有可以索取的術士，或你自己就是術士時才顯示。"
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"當你身上沒有法力寶石時提醒。僅對能製造法力寶石的法師顯示。"
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"當你身上沒有治療藥水時提醒，因為戰鬥中沒人能遞給你藥水。"
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"當你身上沒有法力藥水時提醒。僅當你的角色是使用法力的職業時顯示。"
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] = "當你身上沒有急救技能允許使用的繃帶時提醒。"
L["OPTIONS_READINESS_DURABILITY"] = "受損裝備低於"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"連結耐久度低於該值的每件已裝備物品；按單件計算，因此即使只有一把武器損壞也會顯示。"
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"設定物品耐久度降到多低時，報告才會連結它。"

-- Character
L["OPTIONS_READINESS_SPEC"] = "當前天賦"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] = "輸出你的天賦分配，以及尚未使用的點數。"
L["OPTIONS_READINESS_PVP"] = "PvP 標記開啟"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "當你的 PvP 標記開啟時發出警告。"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "裝備了非戰鬥裝備"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"連結不該出現在戰鬥中的已裝備物品，比如騎乘馬鞭或魚竿。"

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = '已存在名為"%s"的清單。'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "沒有 ID 為 %d 的物品。"
L["RESTOCKER_BANK_NOT_OPEN"] = "銀行未開啟。"
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"補貨完成。開啟銀行時按住 Shift 可跳過補貨。輸入 %s 編輯你的補貨清單。"
L["RESTOCKER_STOPPED_BOTH_FULL"] = "補貨已停止。你的背包和銀行都已滿。"
L["RESTOCKER_STOPPED_BANK_FULL"] = "補貨已停止。你的銀行已滿；請騰出一格後重新開啟。"
L["RESTOCKER_STOPPED_BAG_FULL"] = "補貨已停止。你的背包已滿；請騰出一格後重新開啟銀行。"
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "補貨已停止。無法繼續進行。"
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "補貨已停止。無法移動：%s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (多餘)"
L["RESTOCKER_STOPPED_ERROR"] = "補貨因錯誤而停止：%s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"這個商人沒有販售你的毒藥所需的全部材料。跳過購買這些材料。"
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "在城裡的時候別忘了補貨！"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "還有 1 項補貨訂單未完成。"
L["RESTOCKER_STILL_SHORT_MANY"] = "還有 %d 項補貨訂單未完成。"

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "你的補貨清單已升級。"
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d 升級為 %sx%d。"

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
L["RESTOCKER_RESTOCKED_ONE"] = "已完成 1 項補貨訂單。"
L["RESTOCKER_RESTOCKED_MANY"] = "已完成 %d 項補貨訂單。"

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "有 1 項補貨訂單僅部分完成。"
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "有 %d 項補貨訂單僅部分完成。"
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "背包在全部購買完成前就已裝滿。"

-- /crs help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[名稱]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "新增一個以該名稱命名的清單。"
L["RESTOCKER_HELP_PROFILE_DELETE"] = "刪除該名稱的清單。"
L["RESTOCKER_HELP_PROFILE_RENAME"] = "將當前清單重新命名為該名稱。"
L["RESTOCKER_HELP_PROFILE_COPY"] = "用該名稱的清單副本取代當前清單。"
L["RESTOCKER_HELP_PROFILE_USE"] = "將此角色切換到該名稱的清單。"

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
L["STARTER_POPUP_TITLE"] = "Connoisseur 基礎物資"
L["STARTER_POPUP_INTRO_EMPTY"] = "你的補貨清單是空的，我們來新增一些物品好讓你上手。"
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "挑選你想保持備足的基礎物資。"
L["STARTER_POPUP_INTRO_HOW"] =
	"你勾選的一切都會在你開啟商人或銀行時自動補足。常規物資會隨著等級提升自動升級，所以你手上永遠是目前最好的。"
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] = "你隨時可以輸入 %s 來調整這份清單，或稍後新增更多物品。"
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "食物與水"
L["STARTER_POPUP_FOOD_HEADER"] = "食物"
L["STARTER_POPUP_AMMO_HEADER"] = "彈藥"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "子彈"
L["STARTER_POPUP_ARROWS"] = "箭矢"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header reuses PREFIX_ROGUE (rogue-colored at the call
    site) to say the ingredients take care of themselves. Both sections name
    their rows with the client's own item names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "材料與工具"
L["STARTER_POPUP_POISONS_HEADER"] = "毒藥"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s ：將成品毒藥加入你的清單，Connoisseur 會在任何販售全部所需材料的商人處自動購買這些材料。"
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"將 %s 加入你的補貨清單，在背包中保留 %d 個，並隨著你的等級自動升級。"
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "將 %s 加入補貨清單，並在背包中保留 %d 個。"
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 疊"
L["STARTER_POPUP_STACK_MANY"] = "%d 疊"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "要保持備足多少疊，每疊 %d 個。"
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"要保持備足多少個；這些物品無法堆疊，因此每個都會佔用一個背包格。"
L["STARTER_POPUP_DISMISS"] = "不再為此角色顯示"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] = "登入時即使補貨清單為空，也不再顯示這些建議。"

-- Restock List window UI. The title names what the window holds; the feature that acts on it stays "Restocker".
L["RESTOCKER_WINDOW_TITLE"] = "Connoisseur 補貨清單"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "篩選物品……"
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "清除"
L["RESTOCKER_ADD_BUTTON"] = "新增"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. The keys keep the pop-up's
    earlier name, the List Builder. "Check" is the pop-up's own word
    (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "挑選基礎物資"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"從適合你職業和等級的基礎物資中選擇：食物、水、彈藥、毒藥和施法材料。勾選一項即可將其加入此清單，取消勾選則會將其移除。"
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "新增物品"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"將背包中的物品拖曳到這裡或此視窗的任意位置，或輸入物品 ID 後按 Enter。"
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "拖曳物品或輸入物品 ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "請改為輸入物品 ID。"
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "從背包新增物品"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"你背包中尚未加入此清單的所有物品。點擊其中一件即可新增。"
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "背包中沒有可新增的物品"

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
L["RESTOCKER_PROFILE_LABEL"] = "清單"
L["RESTOCKER_PROFILE_TOOLTIP"] = "點擊為此角色切換到其他補貨清單，或新建一個清單。"
L["RESTOCKER_USED_BY"] = "使用者：%s"
L["RESTOCKER_MANAGE"] = "管理清單"
L["RESTOCKER_MANAGE_TOOLTIP"] = "新建一個清單，或複製、重新命名、刪除此清單。"
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu. The Copy and Delete keys end in
    _TOOLTIP because they began as the tooltips of two buttons this menu
    replaced.
]]
L["RESTOCKER_NEW_PROFILE"] = "新清單"
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "將此清單複製為新清單"
L["RESTOCKER_RENAME_PROFILE"] = "重新命名此清單"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "刪除此清單"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s 副本"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "重新命名"
L["RESTOCKER_RENAME_TOOLTIP"] = "重新命名此清單，對所有使用它的角色生效。"
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "確定要刪除此清單嗎？"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "%s 也在使用此清單，下次登入時將進入一個同名的空清單。"
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s 也在使用此清單，下次登入時將各自進入一個同名的空清單。"
L["RESTOCKER_DELETE_LIST_SWITCH"] = "你將切換到 %s。"
L["RESTOCKER_DELETE_LIST_LAST"] = "這是僅剩的一個清單，因此你將從一個新的空清單開始。"
L["RESTOCKER_DELETE_LIST_FINAL"] = "此操作無法復原。"
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "隨等級升級"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"允許 Connoisseur 在你升級時，將食物、水、彈藥、毒藥、藥水和職業施法材料升級為更好的物品。"

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "銀行"
L["RESTOCKER_ROW_MERCHANT"] = "商人"
L["RESTOCKER_ROW_UPGRADE"] = "升級"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "物品"
L["RESTOCKER_COLUMN_WITHDRAW"] = "取出"
L["RESTOCKER_COLUMN_DEPOSIT"] = "存入"
L["RESTOCKER_COLUMN_REPUTATION"] = "聲望"
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "保留"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "點擊此標題，可為目前顯示的所有物品設定此項。"
L["RESTOCKER_BULK_ON"] = "為顯示的 %d 件物品開啟"
L["RESTOCKER_BULK_OFF"] = "為顯示的 %d 件物品關閉"

L["RESTOCKER_GROUP_OTHER"] = "未分類"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "新增"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "全部物品"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_LIST_BUILDER_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "此清單中還沒有物品"
L["RESTOCKER_EMPTY_BODY"] =
	"選擇食物、水或職業施法材料等基礎物資，或透過上方的選單新增背包中的任何物品。選取的物品會自動補足或存入你的銀行，讓你的背包保持整潔。"
L["RESTOCKER_EMPTY_DROP_HINT"] = "將物品拖曳到此視窗的任意位置也能新增。"
L["RESTOCKER_NO_MATCH_FILTER"] = "此清單中沒有符合篩選條件的物品。"
L["RESTOCKER_NO_MATCH_GROUP"] = "此分類中已沒有物品。"

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
L["RESTOCKER_NO_ORDERS"] = "沒有未完成的補貨訂單。"
L["RESTOCKER_REPORT_MORE"] = "還有 %d 項"
L["RESTOCKER_REMOVED_ITEM"] = "已移除 %s。"
L["RESTOCKER_UNDO"] = "復原"
L["RESTOCKER_UNDO_TOOLTIP"] = "將此物品放回清單"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "將此物品從補貨清單中移除"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "你可以在視窗底部復原此操作。"
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "在背包中保留"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'要在背包中保留多少個。背包中的數量少於此數時，該數字會顯示為黃色；若設為 0 並開啟"存入"，則會將其全部存入銀行。'
L["RESTOCKER_BUY_LABEL"] = "購買"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "向商人購買"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "商人視窗開啟時，向商人購買所需數量。"

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "額外"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "額外購買"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"買下商人此物品的全部限量存貨（即每次只有少量、會慢慢刷新的商品），即使超出你的保留數量。"
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "存入銀行"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"銀行開啟時，將多餘的物品存入銀行；若保留欄填寫 0，則全部存入。"
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "從銀行取出"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "銀行開啟時，從銀行取出所需物品。"

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "所需聲望"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (優惠 %d%%)"
L["RESTOCKER_REPUTATION_ANY"] = "任意"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "友好"
L["RESTOCKER_REPUTATION_HONORED"] = "尊敬"
L["RESTOCKER_REPUTATION_REVERED"] = "崇敬"
L["RESTOCKER_REPUTATION_EXALTED"] = "崇拜"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "所需商人聲望"
--[[
    Quotes the cell's own values, which couples this line to the four standings
    above: a locale that renders a standing differently has to say so here too.
    With no standing required the cell draws a dash rather than the word "Any",
    which is why the last sentence names the dash; "Any" is still the menu's
    first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	"點擊設定 Connoisseur 向商人購買前所需的聲望等級；聲望還會降低價格：友好 5%，尊敬 10%，崇敬 15%，崇拜 20%。短橫線表示向任何商人購買。"

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] = '此物品的"購買"已關閉，因此無法額外購買。'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] = '此物品的"購買"已關閉，因此聲望要求不適用。'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "此物品沒有可升級的更好版本。"
