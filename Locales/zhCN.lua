local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "zhCN")
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

L["MACRO_BANDAGE"] = "- 绷带"
L["MACRO_EXPLOSIVES"] = "- 爆炸物"
L["MACRO_FEED_PET"] = "- 喂养宠物"
L["MACRO_FOOD"] = "- 食物"
L["MACRO_HEALTH_POTION"] = "- 治疗药水"
L["MACRO_HEALTHSTONE"] = "- 治疗石"
L["MACRO_MANA_GEM"] = "- 法力宝石"
L["MACRO_MANA_POTION"] = "- 法力药水"
L["MACRO_POISONS"] = "- 毒药"
L["MACRO_SOULSTONE"] = "- 灵魂石"
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

L["DIET_BREAD"] = "面包"
L["DIET_CHEESE"] = "奶酪"
L["DIET_FISH"] = "鱼"
L["DIET_FRUIT"] = "水果"
L["DIET_FUNGUS"] = "蘑菇"
L["DIET_MEAT"] = "肉"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"看来你发现了一个错误！%s (%s) 无法在 %s > %s (%s) 使用。请将此问题报告给我们，以便修复。谢谢！%s"
L["MESSAGE_NO_ITEM"] = "背包中未找到合适的%s。"
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"由于你的宏栏位已满，部分 Connoisseur 宏未能创建。请删除不再使用的宏以腾出栏位，或在 设置选项 > 插件 > Connoisseur > 宏 中关闭不需要的 Connoisseur 宏。"

L["CHAT_LOADED"] =
	"版本 %s。设置（包括禁用此消息的选项）可以在 设置选项 > 插件 > Connoisseur 中找到。喜欢这个插件吗？告诉朋友吧！(="

L["CHAT_OPTIONS_IN_COMBAT"] = "出于安全考虑，战斗中无法打开选项界面。"

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

L["READINESS_TITLE"] = "就绪报告"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s%s"
L["READINESS_CLAUSE_SEPARATOR"] = "。"

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "缺少增益："
L["READINESS_EXPIRING"] = "即将到期："
L["READINESS_MISSING_ITEMS"] = "缺少物品："
L["READINESS_DAMAGED_GEAR"] = "受损装备："
L["READINESS_CHARACTER"] = "角色："
L["READINESS_QUESTIONABLE_GEAR"] = "装备了非战斗装备："

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
L["READINESS_FLASK"] = "合剂或 2 种药剂"
L["READINESS_WELL_FED"] = "进食充分"
L["READINESS_PET_WELL_FED"] = "进食充分（宠物）"
L["READINESS_SCROLLS"] = "卷轴"
L["READINESS_SOULSTONE"] = "灵魂石未激活"
L["READINESS_MAIN_HAND"] = "主手"
L["READINESS_OFF_HAND"] = "副手"
L["READINESS_HEALTHSTONE"] = "治疗石"
L["READINESS_MANA_GEM"] = "法力宝石"
L["READINESS_HEALING_POTION"] = "治疗药水"
L["READINESS_MANA_POTION"] = "法力药水"
L["READINESS_BANDAGES"] = "绷带"
L["READINESS_PVP_ON"] = "PvP 已开启！"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d 分钟"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s 不足 1 分钟"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 个未使用的天赋点"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d 个未使用的天赋点"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "你目前没有任何对宠物有用的食物。"
L["TIP_PET_NO_SKILLS"] = "你目前还没有学会召唤宠物、解散野兽、喂养宠物或复活宠物。"
L["TIP_PET_NO_MEND"] = "你目前还没有学会治疗宠物。"
L["TIP_NO_HAND_POISON"] = "这把武器所选的毒药已用完。"

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "你目前还没有学会%s。"

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "增益食物"
L["MENU_BUFF_FOOD_DESCRIPTION"] = '缺少"进食充分"增益时，优先使用可提供该增益的食物。'
L["FEATURE_SCROLL_BUFFS"] = "卷轴增益"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] = "进食前，通过你的食物宏补上缺少的卷轴增益。"

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Attention Hunters block, and the two poison titles open the
    Attention Rogues block.
]]
L["MINIMAP_BEST_FOOD"] = "当前食物"
L["MINIMAP_BEST_PET_FOOD"] = "当前宠物食物"
L["MINIMAP_MAIN_HAND_POISON"] = "主手毒药"
L["MINIMAP_OFF_HAND_POISON"] = "副手毒药"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker 报告"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d 项未完成订单"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "恭喜，你的补给已全部备齐！"
L["MINIMAP_RESTOCKER_EMPTY"] = "你的清单是空的。"

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Restocker 清单"
L["MENU_RESTOCKER_DESCRIPTION"] = "购买你清单上的物品，并在银行存取。"
L["MENU_RESTOCKER_KEYBIND"] = "Shift + 右键点击"
L["MENU_OPTIONS"] = "Connoisseur 选项"
L["MENU_OPTIONS_KEYBIND"] = "Shift + 中键点击"

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The class block of the mini-map tooltip: a class-colored header, the items
    the class's own macro will use (a Hunter's pet food, a Rogue's two poisons,
    titled in the Minimap Tooltip section above), then one group per macro.
]]

L["PREFIX_HUNTER"] = "猎人请注意"
L["PREFIX_MAGE"] = "法师请注意"
L["PREFIX_ROGUE"] = "潜行者请注意"
L["PREFIX_WARLOCK"] = "术士请注意"

--[[
    A group is the macro's name, then one row per click: the click on the left
    and what it does on the right. The right-hand column never wraps, so each
    result stays a few words. A spell the row casts is named by the client
    (Mend Pet, Ritual of Refreshment, Ritual of Souls) and has no key here, and
    a plain click reuses MINIMAP_LEFT_CLICK, MINIMAP_RIGHT_CLICK or
    MINIMAP_MIDDLE_CLICK.
]]
L["NOTE_MACRO_FEED_PET"] = "喂养宠物宏"
L["NOTE_MACRO_FOOD_WATER"] = "食物和水宏"
L["NOTE_MACRO_MANA_GEM"] = "法力宝石宏"
L["NOTE_MACRO_HEALTHSTONE"] = "治疗石宏"
L["NOTE_MACRO_SOULSTONE"] = "灵魂石宏"
L["NOTE_MACRO_POISONS"] = "毒药宏"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "召唤、喂养或复活"
L["NOTE_PET_MEND_CLICK"] = "右键点击，或战斗中点击"
L["NOTE_HOLD_SHIFT"] = "按住 Shift"
L["NOTE_PET_FORCE_REVIVE"] = "强制复活"
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
L["NOTE_CONJURE"] = "制造"
L["NOTE_CREATE"] = "制造"
L["NOTE_RIGHT_CLICK_AGAIN"] = "再次右键点击"
L["NOTE_LOWER_RANK_BACKUP"] = "低等级备用"
L["NOTE_MAGE_TARGET_LEVEL"] = "以等级较低的玩家为目标，即可按其等级制造。"
L["NOTE_WARLOCK_TARGET_LEVEL"] = "以等级较低的玩家为目标，即可按其等级制造一颗治疗石。"

-- Rogue. The two hands are the results of a Left-Click and a Right-Click on the Poisons macro.
L["MINIMAP_MAIN_HAND"] = "主手"
L["MINIMAP_OFF_HAND"] = "副手"
L["NOTE_POISONS_WINDOW"] = "毒药窗口"
L["NOTE_POISONS_REPLACED"] = "自动替换旧毒药。"

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "绷带"
L["LABEL_EXPLOSIVE"] = "爆炸物"
L["LABEL_FOOD"] = "食物"
L["LABEL_HEALTH_POTION"] = "治疗药水"
L["LABEL_HEALTHSTONE"] = "治疗石"
L["LABEL_MANA_GEM"] = "法力宝石"
L["LABEL_MANA_POTION"] = "法力药水"
L["LABEL_PET_FOOD"] = "宠物食物"
L["LABEL_POISONS"] = "毒药"
L["LABEL_SOULSTONE"] = "灵魂石"
L["LABEL_WATER"] = "水"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "已启用"
L["MINIMAP_DISABLED"] = "已禁用"
L["MINIMAP_TOGGLE"] = "切换"
L["MINIMAP_OPEN"] = "打开"
L["MINIMAP_LEFT_CLICK"] = "左键点击"
L["MINIMAP_RIGHT_CLICK"] = "右键点击"
L["MINIMAP_MIDDLE_CLICK"] = "中键点击"
L["MINIMAP_SHIFT_LEFT"] = "Shift + 左键点击"

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
	"选择你的食物宏何时提供%s：总是提供，或仅在单人时、小队或团队中、团队中、练级时或满级时提供。"
L["MODE_ALWAYS"] = "总是"
L["MODE_SOLO"] = "单人时"
L["MODE_PARTY"] = "在小队或团队中时"
L["MODE_RAID"] = "在团队中时"
L["MODE_LEVELING"] = "练级时"
L["MODE_MAX_LEVEL"] = "满级时"

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
L["INVENTORY_REPORT_TITLE"] = "库存报告"
L["INVENTORY_REPORT_BAGS"] = "背包"
L["INVENTORY_REPORT_BANK"] = "银行"
-- In place of the Bank count, muted, until this character's bank has been opened once with the add-on running.
L["INVENTORY_REPORT_BANK_UNKNOWN"] = "未知"
-- Everything above it added up: this character and every other one on the realm.
L["INVENTORY_REPORT_TOTAL"] = "总计"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"自动取用你最好的食物、水、药水、治疗石、绷带、毒药和宠物食物的宏，外加一份补货清单，自动购买并在银行存取你的消耗品，还会让它们随等级升级。为巅峰表现打造的便利性自动化。"

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "启用欢迎消息"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "登录时在聊天框中输出欢迎消息。"

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "启用小地图按钮"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "显示小地图按钮。"

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "打开此插件的选项界面。"
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "打开你的补货清单。"

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "反馈与支持"
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
L["TAB_MACROS"] = "宏"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur 会为每种消耗品各建立一个宏，并随着背包变化保持更新，让你动作条上的按钮始终取用你身上最好的物品。请在下方选择要创建哪些宏，然后设置每个宏如何挑选物品。"

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "在按钮上显示宏名称"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"在你的动作条按钮上显示宏名称文字，Connoisseur 默认会隐藏这些文字。"

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "启用宏"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"选择 Connoisseur 要创建并维护哪些宏。关闭某个宏也会将其移除。"
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "创建并维护此宏，取消勾选时会将其移除。"

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "食物与水"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"你的食物和水宏会使用背包中最好的食物和饮料。这些选项可以让增益食物、卷轴或魔法制造的食物和水优先。"

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "优先增益食物"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'缺少"进食充分"增益时，优先使用可提供该增益的食物，竞技场中除外。'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "启用卷轴增益"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"你的食物宏第一次按下时会使用缺少的卷轴，再按一次则进食；以友方玩家为目标或身处竞技场时会跳过卷轴。"
L["OPTIONS_SCROLL_TYPES"] = "在检查中包含卷轴类型"
L["OPTIONS_SCROLL_AGILITY"] = "敏捷"
L["OPTIONS_SCROLL_INTELLECT"] = "智力"
L["OPTIONS_SCROLL_PROTECTION"] = "保护"
L["OPTIONS_SCROLL_SPIRIT"] = "精神"
L["OPTIONS_SCROLL_STAMINA"] = "耐力"
L["OPTIONS_SCROLL_STRENGTH"] = "力量"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = '检查缺少的增益时包含"%s"。'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "优先使用魔法制造的食物与水"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'魔法制造的食物和水不花钱，并会在你下线后不久消失，因此你的食物和水宏会优先使用它们，即使背包里有恢复量更高的物品。开启"优先增益食物"时，增益食物仍然最先使用。'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"选择魔法制造的食物和水何时优先：总是优先，或仅在单人时、小队或团队中、团队中、练级时或满级时优先。"

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "药水与治疗石"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"宏在战斗中无法更改（这是暴雪的限制），因此每个药水和治疗石宏都预先包含你最好的物品以及最多两个备用物品。在较长的战斗中，图标和提示可能会过时并显示错误的物品，但点击该宏将始终使用你背包中实际拥有的最佳物品。"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "非战斗时在药水宏中使用食物与水"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"非战斗时，你的治疗药水宏会食用你最好的食物，法力药水宏会饮用你最好的水。战斗中则照旧使用你的药水。卷轴、宠物食物和魔法制造仍保留在食物和水宏中。"
L["OPTIONS_COMBINE_HEALTHSTONES"] = "将治疗石合并到治疗药水宏中"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"将你最好的治疗石添加到治疗药水宏的底部，这样按一次即可同时使用药水和治疗石。"

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "法力宝石与符文"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"恶魔符文、黑暗符文以及另外几种法力物品，都与法力宝石共享冷却时间。符文使用时会消耗生命值，因此除非你选择加入，否则法力宝石宏不会包含其中任何一种。"
L["OPTIONS_INCLUDE_MANA_RUNES"] = "将符文与其他法力物品加入法力宝石宏"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"将你的恶魔符文、黑暗符文，以及任何其他与法力宝石共享冷却时间的法力物品，和你的法力宝石一同排序，这样当其中某件物品是你的最佳选择，或你的法力宝石用完时，法力宝石宏就会使用该物品。"

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "增益重新应用"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"宏在战斗中无法更改，因此战斗中途到期的增益会一直缺失，直到战斗结束。"
L["OPTIONS_REAPPLY"] = "提前补充即将到期的增益"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"将剩余时间低于你所设阈值的增益食物、卷轴增益和宠物食物增益视为已到期，让你的宏在开怪前提供新的增益。"
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"设置增益离到期还剩多久时，你的宏就会提供新的增益。"
L["REAPPLY_THRESHOLD_ONE"] = "当剩余不足 1 分钟时"
L["REAPPLY_THRESHOLD_MANY"] = "当剩余不足 %d 分钟时"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "宠物食物增益"
L["OPTIONS_PET_SECTION_DESCRIPTION"] = '少数食物会为你的宠物提供专属的"进食充分"增益。'
L["OPTIONS_USE_PET_BUFFS"] = "使用宠物食物增益"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	'当你的宠物缺少"进食充分"增益时，将宠物食物加入你的食物宏，竞技场中除外。'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "在检查中包含宠物食物类型"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "爆炸物"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"@player 选项会跳过目标指示圈，直接将爆炸物在你脚下引爆，非常适合目标处于近战距离时使用。另一个键则照常投掷。"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "点击方式"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"选择用哪个键投掷爆炸物，用哪个键将它在你脚下引爆。"
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "左键点击 @player"
L["EXPLOSIVES_MODE_TOSS"] = "左键点击投掷"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "德鲁伊"
L["OPTIONS_DRUID_MACRO_HELPER"] = "启用 DruidMacroHelper 整合"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"使用 DruidMacroHelper (/dmh) 为治疗药水、法力药水和治疗石构建变形宏。"
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] = "选择你的变形宏在使用物品后让你返回哪种形态。"
L["DRUID_FORM_BEAR"] = "返回熊形态"
L["DRUID_FORM_CAT"] = "返回猎豹形态"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "潜行者"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"让毒药宏始终装载每种毒药类型可用的最高等级。左键涂抹副手，右键涂抹主手，已有毒药会自动替换。"
L["OPTIONS_POISON_MAIN_HAND"] = "主手毒药类型"
L["OPTIONS_POISON_OFF_HAND"] = "副手毒药类型"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] = "选择你的毒药宏在右键点击时涂抹到主手的毒药。"
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] = "选择你的毒药宏在左键点击时涂抹到副手的毒药。"
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "启用进食时潜行"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] = "将潜行添加到你的食物宏中，以便你在进食时潜行。"

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "暗夜精灵"
L["OPTIONS_STEALTH_DRINKING"] = "启用喝水时潜行"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] = "将影遁添加到你的水宏中，以便你在喝水时潜行。"
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] =
	"将影遁添加到你的食物宏中，以便你在进食时潜行。"
L["OPTIONS_STEALTH_PICK_ONE"] =
	"专业提示：只选一个。你可以同时进食和喝水，但潜行后再进食或喝水会解除潜行。"

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
	"被忽略的物品永远不会被任何宏选用。食物、水、药水，任何东西都一样。全局列表对所有角色生效；角色列表只对该角色生效。右键点击小地图按钮可忽略你当前的最佳食物。"
L["OPTIONS_IGNORE_GLOBAL"] = "全局"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] = "将此物品移至全局列表，使其在所有角色上都被忽略。"
L["OPTIONS_IGNORE_ADD_ID"] = "按物品 ID 添加"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"输入物品 ID，或在此输入框处于焦点时按住 Shift + 点击聊天中的物品链接。"
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "输入物品 ID，或按住 Shift + 点击聊天中的物品链接。"
L["OPTIONS_IGNORE_REMOVE"] = "移除"
L["OPTIONS_IGNORE_EMPTY"] = "此列表为空。"
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "正在载入 ID：%d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"根据你的补货清单保持背包物资充足，自动向商人购买，并在背包与银行之间搬运物品。输入 %s 打开清单。"
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "在银行打开"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "访问银行时打开你的补货清单。"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "在商人处打开"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "访问商人时打开你的补货清单。"
L["OPTIONS_RESTOCKER_REMIND"] = "启用城镇补货提醒"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"当补货清单尚有缺口，且你抵达旅店或城市，或登录时已身处其中，在聊天中输出提醒。"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "启用商人补货提醒"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] = "关闭商人窗口时，报告所有未完成的补货订单。"
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "启用银行补货提醒"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] = "关闭银行时，报告所有未完成的补货订单。"

--[[
    The staples pop-up (STARTER_POPUP_TITLE below). This toggle and the
    pop-up's own "Don't Show This Again" box are the same per-character choice
    read from opposite ends, which is why one ships on and the other off: a
    settings row reads naturally as "enable", a dismissal reads naturally as
    "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] = "补货清单为空时启用基础物资弹窗"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"当此角色的补货清单为空时，在登录时提供适合你职业的基础物资。"

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"选择提醒只有一行，还是为你缺少的每件物品各加一行。"
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "简洁"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "详细"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "播放声音"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] = "在提醒的同时播放提示音，适合聊天繁忙的时候。"
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "点击试听提示音。"

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "补货清单窗口"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "选择你的补货清单何时自动打开。"

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"在物品提示中显示你在本服务器所有角色上共有多少件该物品。"
L["OPTIONS_INVENTORY_REPORT"] = "在物品提示中启用库存报告"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"在物品提示中加入该物品在你的背包、银行和其他角色身上各有多少件。如果其他插件已经显示这些数量，请将其关闭。"

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "致谢"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"我一直很喜欢 Restocker，很感激能有机会让它在 Connoisseur 中延续下去。非常感谢编写最初 Auto Restocker 的 ChiliFajita，以及在经典怀旧服与熊猫人之谜期间一直维护它的 kvakvs 和 guardycmw。"

-- Readiness Report
L["TAB_READINESS_REPORT"] = "就绪报告"
L["OPTIONS_READINESS_ENABLE"] = "在就位确认时启用就绪报告"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] = "为此账号的所有角色开启就绪报告。"
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"就位确认开始时，输出一份仅你可见的清单，列出仍需处理的事项；如果你已准备就绪，则完全不会输出任何内容。"

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "重置就绪报告设置"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"将本页的所有复选框和两个阈值恢复为默认值，其他页面均不受影响。"
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"将就绪报告的所有设置重置为默认值？这也会重新关闭报告本身。"

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
	"缺少合剂时提醒。一瓶合剂，或战斗药剂与守护药剂各一瓶，均视为已满足。"
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	'缺少"进食充分"增益时提醒。需要在宏页面中开启增益食物。'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	'你的宠物缺少"进食充分"增益时提醒。需要在宏页面中开启宠物食物增益，并且已召唤出宠物。'
L["OPTIONS_READINESS_SCROLLS"] = "卷轴增益"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"缺少卷轴增益时提醒。需要在宏页面中开启卷轴增益，并且只检查该处所选的卷轴类型。"
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"当队伍中没有人身上有生效的灵魂石时提醒；背包里的灵魂石不算。仅对能制造灵魂石的术士显示。"
L["OPTIONS_READINESS_MAIN_HAND"] = "主手武器增益"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"主手武器没有临时附魔时提醒。任何附魔都算，且队伍中有萨满祭司时不会报告此项。"
L["OPTIONS_READINESS_OFF_HAND"] = "副手武器增益"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"副手武器没有临时附魔时提醒。任何附魔都算：磨刀石、油剂、毒药或萨满祭司的武器增益。"
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "增益到期时间少于"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"列出你身上所有即将到期的增益，而不仅是 Connoisseur 施加的那些；此设置与宏页面中的增益重新应用相互独立。"
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s 分钟"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 分钟"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"设置增益离到期还剩多久时，报告才会列出它。"

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"当你身上没有治疗石时提醒。仅当队伍中有可以索要的术士，或你自己就是术士时才显示。"
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"当你身上没有法力宝石时提醒。仅对能制造法力宝石的法师显示。"
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"当你身上没有治疗药水时提醒，因为战斗中没人能递给你药水。"
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"当你身上没有法力药水时提醒。仅当你的角色是使用法力的职业时显示。"
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] = "当你身上没有急救技能允许使用的绷带时提醒。"
L["OPTIONS_READINESS_DURABILITY"] = "受损装备低于"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"链接耐久度低于该值的每件已装备物品；按单件计算，因此即使只有一把武器损坏也会显示。"
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"设置物品耐久度降到多低时，报告才会链接它。"

-- Character
L["OPTIONS_READINESS_SPEC"] = "当前天赋"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] = "输出你的天赋分配，以及尚未使用的点数。"
L["OPTIONS_READINESS_PVP"] = "PvP 标记开启"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "当你的 PvP 标记开启时发出警告。"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "装备了非战斗装备"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"链接不该出现在战斗中的已装备物品，比如马鞭或鱼竿。"

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = '已存在名为"%s"的清单。'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "没有 ID 为 %d 的物品。"
L["RESTOCKER_BANK_NOT_OPEN"] = "银行未打开。"
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"补货完成。打开银行时按住 Shift 可跳过补货。输入 %s 编辑你的补货清单。"
L["RESTOCKER_STOPPED_BOTH_FULL"] = "补货已停止。你的背包和银行都已满。"
L["RESTOCKER_STOPPED_BANK_FULL"] = "补货已停止。你的银行已满；请腾出一格后重新打开。"
L["RESTOCKER_STOPPED_BAG_FULL"] = "补货已停止。你的背包已满；请腾出一格后重新打开银行。"
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "补货已停止。无法继续进行。"
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "补货已停止。无法移动：%s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (多余)"
L["RESTOCKER_STOPPED_ERROR"] = "补货因错误而停止：%s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"这个商人没有出售你的毒药所需的全部材料。跳过购买这些材料。"
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "在城里的时候别忘了补货！"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "还有 1 项补货订单未完成。"
L["RESTOCKER_STILL_SHORT_MANY"] = "还有 %d 项补货订单未完成。"

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "你的补货清单已升级。"
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d 升级为 %sx%d。"

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
L["RESTOCKER_RESTOCKED_ONE"] = "已完成 1 项补货订单。"
L["RESTOCKER_RESTOCKED_MANY"] = "已完成 %d 项补货订单。"

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "有 1 项补货订单仅部分完成。"
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "有 %d 项补货订单仅部分完成。"
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "背包在全部购买完成前就已装满。"

-- /crs help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[名称]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "添加一个以该名称命名的清单。"
L["RESTOCKER_HELP_PROFILE_DELETE"] = "删除该名称的清单。"
L["RESTOCKER_HELP_PROFILE_RENAME"] = "将当前清单重命名为该名称。"
L["RESTOCKER_HELP_PROFILE_COPY"] = "用该名称的清单副本替换当前清单。"
L["RESTOCKER_HELP_PROFILE_USE"] = "将此角色切换到该名称的清单。"

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
L["STARTER_POPUP_TITLE"] = "Connoisseur 基础物资"
L["STARTER_POPUP_INTRO_EMPTY"] = "你的补货清单是空的，我们来添加一些物品好让你上手。"
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "挑选你想保持备足的基础物资。"
L["STARTER_POPUP_INTRO_HOW"] =
	"你勾选的一切都会在你打开商人或银行时自动补足。常规物资会随着等级提升自动升级，所以你手上永远是当前最好的。"
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] = "你随时可以输入 %s 来调整这份清单，或稍后添加更多物品。"
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "食物与水"
L["STARTER_POPUP_FOOD_HEADER"] = "食物"
L["STARTER_POPUP_AMMO_HEADER"] = "弹药"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "子弹"
L["STARTER_POPUP_ARROWS"] = "箭矢"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header reuses PREFIX_ROGUE (rogue-colored at the call
    site) to say the ingredients take care of themselves. Both sections name
    their rows with the client's own item names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "材料与工具"
L["STARTER_POPUP_POISONS_HEADER"] = "毒药"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s ：将成品毒药加入你的清单，Connoisseur 会在任何出售全部所需材料的商人处自动购买这些材料。"
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"将 %s 加入你的补货清单，在背包中保留 %d 个，并随着你的等级自动升级。"
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "将 %s 加入补货清单，并在背包中保留 %d 个。"
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 组"
L["STARTER_POPUP_STACK_MANY"] = "%d 组"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "要保持备足多少组，每组 %d 个。"
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"要保持备足多少个；这些物品无法堆叠，因此每个都会占用一个背包格。"
L["STARTER_POPUP_DISMISS"] = "不再为此角色显示"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] = "登录时即使补货清单为空，也不再显示这些建议。"

-- Restock List window UI. The title names what the window holds; the feature that acts on it stays "Restocker".
L["RESTOCKER_WINDOW_TITLE"] = "Connoisseur 补货清单"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "筛选物品……"
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "清除"
L["RESTOCKER_ADD_BUTTON"] = "添加"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. The keys keep the pop-up's
    earlier name, the List Builder. "Check" is the pop-up's own word
    (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "挑选基础物资"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"从适合你职业和等级的基础物资中选择：食物、水、弹药、毒药和施法材料。勾选一项即可将其加入此清单，取消勾选则会将其移除。"
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "添加物品"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"将背包中的物品拖到这里或此窗口的任意位置，或输入物品 ID 后按回车。"
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "拖入物品或输入物品 ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "请改为输入物品 ID。"
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "从背包添加物品"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"你背包中尚未加入此清单的所有物品。点击其中一件即可添加。"
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "背包中没有可添加的物品"

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
L["RESTOCKER_PROFILE_LABEL"] = "清单"
L["RESTOCKER_PROFILE_TOOLTIP"] = "点击为此角色切换到其他补货清单，或新建一个清单。"
L["RESTOCKER_USED_BY"] = "使用者：%s"
L["RESTOCKER_MANAGE"] = "管理清单"
L["RESTOCKER_MANAGE_TOOLTIP"] = "新建一个清单，或复制、重命名、删除此清单。"
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu. The Copy and Delete keys end in
    _TOOLTIP because they began as the tooltips of two buttons this menu
    replaced.
]]
L["RESTOCKER_NEW_PROFILE"] = "新清单"
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "将此清单复制为一个新清单"
L["RESTOCKER_RENAME_PROFILE"] = "重命名此清单"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "删除此清单"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s 副本"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "重命名"
L["RESTOCKER_RENAME_TOOLTIP"] = "重命名此清单，对所有使用它的角色生效。"
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "确定要删除此清单吗？"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "%s 也在使用此清单，下次登录时将进入一个同名的空清单。"
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s 也在使用此清单，下次登录时将各自进入一个同名的空清单。"
L["RESTOCKER_DELETE_LIST_SWITCH"] = "你将切换到 %s。"
L["RESTOCKER_DELETE_LIST_LAST"] = "这是仅剩的一个清单，因此你将从一个新的空清单开始。"
L["RESTOCKER_DELETE_LIST_FINAL"] = "此操作无法撤销。"
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "随等级升级"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"允许 Connoisseur 在你升级时，将食物、水、弹药、毒药、药水和职业施法材料升级为更好的物品。"

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "银行"
L["RESTOCKER_ROW_MERCHANT"] = "商人"
L["RESTOCKER_ROW_UPGRADE"] = "升级"

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
L["RESTOCKER_COLUMN_REPUTATION"] = "声望"
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
L["RESTOCKER_COLUMN_BULK_HINT"] = "点击此标题，可为当前显示的所有物品设置此项。"
L["RESTOCKER_BULK_ON"] = "为显示的 %d 件物品开启"
L["RESTOCKER_BULK_OFF"] = "为显示的 %d 件物品关闭"

L["RESTOCKER_GROUP_OTHER"] = "未分类"
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
L["RESTOCKER_EMPTY_TITLE"] = "此清单中还没有物品"
L["RESTOCKER_EMPTY_BODY"] =
	"选择食物、水或职业施法材料等基础物资，或通过上方的菜单添加背包中的任何物品。选中的物品会自动补足或存入你的银行，让你的背包保持整洁。"
L["RESTOCKER_EMPTY_DROP_HINT"] = "将物品拖到此窗口的任意位置也能添加。"
L["RESTOCKER_NO_MATCH_FILTER"] = "此清单中没有符合筛选条件的物品。"
L["RESTOCKER_NO_MATCH_GROUP"] = "此分类中已没有物品。"

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
L["RESTOCKER_NO_ORDERS"] = "没有未完成的补货订单。"
L["RESTOCKER_REPORT_MORE"] = "还有 %d 项"
L["RESTOCKER_REMOVED_ITEM"] = "已移除 %s。"
L["RESTOCKER_UNDO"] = "撤销"
L["RESTOCKER_UNDO_TOOLTIP"] = "将此物品放回清单"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "将此物品从补货清单中移除"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "你可以在窗口底部撤销此操作。"
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "在背包中保留"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	'要在背包中保留多少个。背包中的数量少于此数时，该数字会显示为黄色；若设为 0 并开启"存入"，则会将其全部存入银行。'
L["RESTOCKER_BUY_LABEL"] = "购买"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "向商人购买"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "商人窗口打开时，向商人购买所需数量。"

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "额外"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "额外购买"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"买下商人此物品的全部限量库存（即每次只有少量、会慢慢刷新的商品），即使超出你的保留数量。"
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "存入银行"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"银行打开时，将多余的物品存入银行；若保留栏填写 0，则全部存入。"
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "从银行取出"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "银行打开时，从银行取出所需物品。"

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "所需声望"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (优惠 %d%%)"
L["RESTOCKER_REPUTATION_ANY"] = "任意"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "友善"
L["RESTOCKER_REPUTATION_HONORED"] = "尊敬"
L["RESTOCKER_REPUTATION_REVERED"] = "崇敬"
L["RESTOCKER_REPUTATION_EXALTED"] = "崇拜"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "所需商人声望"
--[[
    Quotes the cell's own values, which couples this line to the four standings
    above: a locale that renders a standing differently has to say so here too.
    With no standing required the cell draws a dash rather than the word "Any",
    which is why the last sentence names the dash; "Any" is still the menu's
    first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	"点击设置 Connoisseur 向商人购买前所需的声望等级；声望还会降低价格：友善 5%，尊敬 10%，崇敬 15%，崇拜 20%。短横线表示向任何商人购买。"

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] = '此物品的"购买"已关闭，因此无法额外购买。'
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] = '此物品的"购买"已关闭，因此声望要求不适用。'
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "此物品没有可升级的更好版本。"
