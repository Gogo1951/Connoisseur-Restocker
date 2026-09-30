local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "koKR")
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

L["MACRO_BANDAGE"] = "- 붕대"
L["MACRO_EXPLOSIVES"] = "- 폭발물"
L["MACRO_FEED_PET"] = "- 먹이 주기"
L["MACRO_FOOD"] = "- 음식"
L["MACRO_FOOD_AND_POTION"] = "- 음식/물약"
L["MACRO_HEALTH_POTION"] = "- 치유 물약"
L["MACRO_HEALTHSTONE"] = "- 생명석"
L["MACRO_MANA_GEM"] = "- 마나 보석"
L["MACRO_MANA_POTION"] = "- 마나 물약"
L["MACRO_POISONS"] = "- 독"
L["MACRO_SOULSTONE"] = "- 영혼석"
L["MACRO_WATER"] = "- 물"
L["MACRO_WATER_AND_POTION"] = "- 물/물약"

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

L["DIET_BREAD"] = "빵"
L["DIET_CHEESE"] = "치즈"
L["DIET_FISH"] = "생선"
L["DIET_FRUIT"] = "과일"
L["DIET_FUNGUS"] = "버섯"
L["DIET_MEAT"] = "고기"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"버그를 발견한 것 같습니다! %s (%s) 아이템은 %s > %s (%s)에서 사용할 수 없습니다. 수정할 수 있도록 제보해 주세요. 감사합니다! %s"
L["MESSAGE_NO_ITEM"] = "가방에서 적합한 %s 아이템을 찾지 못했습니다."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"매크로 슬롯이 가득 차서 일부 Connoisseur 매크로를 만들지 못했습니다. 더 이상 사용하지 않는 매크로를 삭제해 슬롯을 비우거나, 설정 > 애드온 > Connoisseur > 매크로에서 필요 없는 Connoisseur 매크로를 끄세요."

L["CHAT_LOADED"] =
	"버전 %s. 설정(이 메시지 비활성화 옵션 포함)은 설정 > 애드온 > Connoisseur에서 찾을 수 있습니다. 애드온이 마음에 드시나요? 친구에게 알려주세요! (="

L["CHAT_OPTIONS_IN_COMBAT"] = "안전을 위해 전투 중에는 설정 인터페이스를 열 수 없습니다."

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

L["READINESS_TITLE"] = "준비 보고서"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "부족한 버프:"
L["READINESS_EXPIRING"] = "곧 만료:"
L["READINESS_MISSING_ITEMS"] = "부족한 아이템:"
L["READINESS_DAMAGED_GEAR"] = "손상된 장비:"
L["READINESS_CHARACTER"] = "캐릭터:"
L["READINESS_QUESTIONABLE_GEAR"] = "비전투용 장비 착용:"

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
L["READINESS_FLASK"] = "영약 또는 비약 2종"
L["READINESS_WELL_FED"] = "포만감"
L["READINESS_PET_WELL_FED"] = "포만감 (소환수)"
L["READINESS_SCROLLS"] = "두루마리"
L["READINESS_SOULSTONE"] = "영혼석 비활성"
L["READINESS_MAIN_HAND"] = "주장비"
L["READINESS_OFF_HAND"] = "보조장비"
L["READINESS_HEALTHSTONE"] = "생명석"
L["READINESS_MANA_GEM"] = "마나 보석"
L["READINESS_HEALING_POTION"] = "치유 물약"
L["READINESS_MANA_POTION"] = "마나 물약"
L["READINESS_BANDAGES"] = "붕대"
L["READINESS_PVP_ON"] = "PvP 활성!"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d분"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s 1분 미만"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "미사용 특성 포인트 1점"
L["READINESS_UNSPENT_TALENTS_MANY"] = "미사용 특성 포인트 %d점"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "현재 소환수에게 줄 수 있는 적절한 먹이가 없습니다."
L["TIP_PET_NO_SKILLS"] =
	"현재 야수 부르기, 야수 소환해제, 먹이주기 또는 야수 되살리기를 배우지 않았습니다."
L["TIP_PET_NO_MEND"] = "현재 동물 치료를 배우지 않았습니다."
L["TIP_NO_HAND_POISON"] = "이 무기용으로 선택한 독이 다 떨어졌습니다."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "현재 %s 기술을 배우지 않았습니다."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "버프 음식"
L["MENU_BUFF_FOOD_DESCRIPTION"] =
	'"포만감" 버프가 없을 때 해당 버프를 주는 음식을 우선 사용합니다.'
L["FEATURE_SCROLL_BUFFS"] = "두루마리 버프"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] =
	"두루마리 버프가 없을 때 음식 매크로가 두루마리를 사용하도록 바꿉니다."

-- Section titles and ignore-list actions in the mini-map tooltip.
L["MINIMAP_BEST_FOOD"] = "현재 음식"
L["MINIMAP_BEST_PET_FOOD"] = "현재 소환수 음식"
-- Weapon-slot titles beside the rogue's resolved poison, in the Attention Rogues block.
L["MINIMAP_MAIN_HAND"] = "주장비"
L["MINIMAP_OFF_HAND"] = "보조장비"
--[[
    The value shown beside an item title when nothing resolved. Kept to a single
    word so it fits in the tooltip's right column, which never wraps -- the full
    sentence, MESSAGE_NO_ITEM, explains it on the wrapping line underneath.
]]
L["MINIMAP_NONE"] = "없음"
L["MINIMAP_IGNORE_LIST"] = "차단 목록"
L["MENU_IGNORE"] = "차단"
L["MENU_CLEAR_IGNORE"] = "차단 목록 초기화"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Restocker 보고서"
L["MINIMAP_RESTOCKER_NEEDED"] = "미완료 주문 %d건"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "축하합니다, 필요한 물품을 모두 갖췄습니다!"

-- Options entry at the bottom of the mini-map tooltip.
L["MENU_OPTIONS"] = "Connoisseur 설정"
L["MENU_OPTIONS_KEYBIND"] = "Shift + 휠클릭"

--------------------------------------------------------------------------------
-- Class Tips
--------------------------------------------------------------------------------

--[[
    Class-colored headers and click tips shown in the mini-map tooltip for the
    player's class.
]]

L["PREFIX_HUNTER"] = "사냥꾼 주목"
L["PREFIX_MAGE"] = "마법사 주목"
L["PREFIX_ROGUE"] = "도적 주목"
L["PREFIX_WARLOCK"] = "흑마법사 주목"

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
L["TIP_HUNTER_MACROS"] = "먹이 주기 매크로 안내..."
L["TIP_MAGE_MACROS"] = "음식, 물, 마나 보석 매크로 안내..."
L["TIP_ROGUE_MACROS"] = "독 매크로 안내..."
L["TIP_WARLOCK_MACROS"] = "생명석 및 영혼석 매크로 안내..."

L["TIP_HUNTER_ALL_IN_ONE"] = "먹이 주기는 올인원 소환수 버튼입니다!"
L["TIP_HUNTER_CALL"] = "좌클릭하면 소환수를 자동으로 부르거나, 먹이를 주거나, 되살립니다."
L["TIP_HUNTER_MEND"] = "우클릭하거나 전투 중에 클릭하면 동물 치료를 시전합니다."
L["TIP_HUNTER_MODIFIERS"] =
	"Shift를 누르고 있으면 되살리기를 강제하고, Ctrl을 누르고 있으면 소환을 해제합니다."

--[[
    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone. Mana Gems, Soulstones,
    and both rituals ignore the target (ignoreTarget in the resolvers), so each
    line names what it actually affects rather than saying "the macro."
]]
L["TIP_MAGE_CONJURE"] =
	"음식 또는 물 매크로를 우클릭하면 음식 창조 또는 음료 창조를 시전합니다."
L["TIP_MAGE_DOWNRANK"] =
	"레벨이 낮은 플레이어를 대상으로 지정하면 그 레벨에 맞는 음식이나 물을 창조합니다."
L["TIP_MAGE_TABLE"] = "음식 또는 물 매크로를 휠클릭하면 원기 회복의 의식을 시전합니다."
L["TIP_MAGE_GEM"] =
	"마나 보석 매크로를 우클릭하면 새 보석을 창조합니다. 다시 우클릭하면 낮은 등급의 예비 보석을 창조합니다."

L["TIP_WARLOCK_HEALTHSTONE"] =
	"생명석 매크로를 우클릭하면 생명석 창조를 시전합니다. 다시 우클릭하면 낮은 등급의 예비 생명석을 창조합니다."
L["TIP_WARLOCK_DOWNRANK"] =
	"레벨이 낮은 플레이어를 대상으로 지정하면 그 레벨에 맞는 생명석을 창조합니다."
L["TIP_WARLOCK_SOULSTONE"] = "영혼석 매크로를 우클릭하면 영혼석 창조를 시전합니다."
L["TIP_WARLOCK_SOUL"] = "생명석 매크로를 휠클릭하면 영혼의 의식을 시전합니다."

L["TIP_ROGUE_OFF_HAND"] = "좌클릭하면 보조장비에 독을 바릅니다."
L["TIP_ROGUE_MAIN_HAND"] = "우클릭하면 주장비에 독을 바릅니다."
L["TIP_ROGUE_REPLACE"] = "기존 독은 자동으로 교체됩니다."
L["TIP_ROGUE_WINDOW"] = "휠클릭하면 독 조제 창을 엽니다."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the List Builder's Water checkbox.
]]

L["LABEL_BANDAGE"] = "붕대"
L["LABEL_EXPLOSIVE"] = "폭발물"
L["LABEL_FOOD"] = "음식"
L["LABEL_HEALTH_POTION"] = "치유 물약"
L["LABEL_HEALTHSTONE"] = "생명석"
L["LABEL_MANA_GEM"] = "마나 보석"
L["LABEL_MANA_POTION"] = "마나 물약"
L["LABEL_PET_FOOD"] = "소환수 음식"
L["LABEL_POISONS"] = "독"
L["LABEL_SOULSTONE"] = "영혼석"
L["LABEL_WATER"] = "물"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "켜짐"
L["MINIMAP_DISABLED"] = "꺼짐"
L["MINIMAP_TOGGLE"] = "켜기/끄기"
L["MINIMAP_LEFT_CLICK"] = "좌클릭"
L["MINIMAP_RIGHT_CLICK"] = "우클릭"
L["MINIMAP_MIDDLE_CLICK"] = "휠클릭"
L["MINIMAP_SHIFT_LEFT"] = "Shift + 좌클릭"

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
	"음식 매크로에서 %s 기능을 항상 사용할지, 아니면 혼자일 때, 파티 또는 공격대에 있을 때, 공격대에 있을 때, 레벨업 중일 때, 최고 레벨일 때만 사용할지 선택합니다."
L["MODE_ALWAYS"] = "항상"
L["MODE_SOLO"] = "혼자일 때"
L["MODE_PARTY"] = "파티 또는 공격대에 있을 때"
L["MODE_RAID"] = "공격대에 있을 때"
L["MODE_LEVELING"] = "레벨업 중일 때"
L["MODE_MAX_LEVEL"] = "최고 레벨일 때"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"최고의 음식, 버프 음식, 물, 물약, 생명석, 붕대, 두루마리를 자동으로 사용하는 매크로와, 가방을 가득 채워 두고 레벨에 맞춰 소모품을 업그레이드해 주는 보충 목록을 제공합니다. 최고의 성능을 위한 편의성 자동화입니다."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "환영 메시지 활성화"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "로그인 시 대화창에 환영 메시지를 출력합니다."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "미니맵 버튼 활성화"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "미니맵 버튼을 표시합니다."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "이 애드온의 설정 인터페이스를 엽니다."
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "보충 목록을 관리할 Restocker 창을 엽니다."

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "피드백 및 지원"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["CURSEFORGE"] = "CurseForge"
L["WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "버전 %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Enable Macros header below titles the first section,
    after the page's one headerless toggle, Macro Names on Buttons.
]]
L["TAB_MACROS"] = "매크로"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur는 소모품마다 매크로를 하나씩 만들고 가방이 바뀔 때마다 최신 상태로 유지하므로, 단축바에 놓인 버튼은 항상 지금 가진 최고의 아이템을 사용합니다. 아래에서 만들 매크로를 고른 다음, 각 매크로가 아이템을 고르는 방식을 설정하세요."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "버튼에 매크로 이름 표시"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Connoisseur가 기본적으로 숨기는 매크로 이름 텍스트를 행동 단축바 버튼에 표시합니다."

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "매크로 활성화"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Connoisseur가 생성하고 관리할 매크로를 선택하세요. 매크로를 끄면 해당 매크로도 삭제됩니다."
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] =
	"이 매크로를 생성하고 관리하며, 체크를 해제하면 삭제합니다."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "음식 및 물"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"음식 및 물 매크로는 가방에 있는 가장 좋은 음식과 음료를 사용합니다. 이 옵션들로 버프 음식, 두루마리, 창조된 음식과 물을 먼저 사용하게 할 수 있습니다."

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "버프 음식 우선"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'투기장을 제외하고, "포만감" 버프가 없을 때 해당 버프를 주는 음식을 우선 사용합니다.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "두루마리 버프 활성화"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"음식 매크로를 처음 누르면 빠진 두루마리 버프를 적용하고 다음에 누르면 음식을 먹으며, 아군 플레이어를 대상으로 지정했거나 투기장에 있을 때는 두루마리를 건너뜁니다."
L["OPTIONS_SCROLL_TYPES"] = "확인할 두루마리 유형 포함"
L["OPTIONS_SCROLL_AGILITY"] = "민첩성"
L["OPTIONS_SCROLL_INTELLECT"] = "지능"
L["OPTIONS_SCROLL_PROTECTION"] = "보호"
L["OPTIONS_SCROLL_SPIRIT"] = "정신력"
L["OPTIONS_SCROLL_STAMINA"] = "체력"
L["OPTIONS_SCROLL_STRENGTH"] = "힘"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "빠진 버프를 확인할 때 %s 유형을 포함합니다."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "창조된 음식 및 물 먼저 사용"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'창조된 음식과 물은 비용이 들지 않고 접속을 종료하면 곧 사라지므로, 가방에 더 많이 회복하는 아이템이 있더라도 음식 및 물 매크로가 이를 가장 먼저 사용합니다. "버프 음식 우선"이 켜져 있으면 버프 음식이 여전히 가장 먼저입니다.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"창조된 음식과 물을 항상 먼저 사용할지, 아니면 혼자일 때, 파티 또는 공격대에 있을 때, 공격대에 있을 때, 레벨업 중일 때, 최고 레벨일 때만 먼저 사용할지 선택합니다."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "물약 및 생명석"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"전투 중에는 매크로를 변경할 수 없으므로(블리자드 제한 사항), 각 물약 및 생명석 매크로는 가장 좋은 아이템과 최대 2개의 예비 아이템으로 미리 구성됩니다. 긴 전투에서는 아이콘과 툴팁이 갱신되지 않아 잘못된 아이템을 표시할 수 있지만, 매크로를 클릭하면 항상 가방에 실제로 있는 가장 좋은 아이템을 사용합니다."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "생명석을 치유 물약 매크로에 결합"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"가장 좋은 생명석을 치유 물약 매크로의 하단에 추가하여, 한 번 누르면 물약과 생명석을 모두 사용합니다."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "마나 보석 및 룬"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"악마의 룬과 암흑의 룬, 그리고 몇몇 다른 마나 회복 아이템은 마나 보석과 재사용 대기시간을 공유합니다. 룬은 사용할 때 생명력이 소모되므로, 직접 추가하지 않으면 마나 보석 매크로는 이들을 모두 제외합니다."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "룬 및 기타 마나 회복 아이템을 마나 보석 매크로에 추가"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"악마의 룬과 암흑의 룬, 그리고 마나 보석과 재사용 대기시간을 공유하는 다른 마나 회복 아이템도 마나 보석과 함께 우선순위를 매겨, 그중 하나가 가장 좋은 선택이거나 보석이 다 떨어졌을 때 마나 보석 매크로가 이를 사용합니다."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "버프 재적용"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"전투 중에는 매크로를 변경할 수 없으므로, 전투 도중 만료된 버프는 전투가 끝날 때까지 사라진 채로 남습니다."
L["OPTIONS_REAPPLY"] = "만료 임박 버프 재적용"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"남은 시간이 설정한 기준값보다 적은 버프 음식, 두루마리 버프, 소환수 음식 버프를 만료된 것으로 간주하여, 전투 전에 매크로가 새 버프를 제안합니다."
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"버프가 만료되기 얼마 전부터 매크로가 새 버프를 제안할지 설정합니다."
L["REAPPLY_THRESHOLD_ONE"] = "1분 미만 남았을 때"
L["REAPPLY_THRESHOLD_MANY"] = "%d분 미만 남았을 때"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "소환수 음식 버프"
L["OPTIONS_PET_SECTION_DESCRIPTION"] = '일부 음식은 소환수에게 별도의 "포만감" 버프를 줍니다.'
L["OPTIONS_USE_PET_BUFFS"] = "소환수 음식 버프 사용"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	'투기장을 제외하고, 소환수에게 "포만감" 버프가 없을 때 음식 매크로에 소환수 음식을 추가합니다.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "확인할 소환수 음식 유형 포함"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "폭발물"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"@player 옵션은 조준 원 없이 폭발물을 발밑에서 바로 터뜨립니다. 대상이 근접 거리일 때 이상적입니다. 다른 클릭은 평소처럼 폭발물을 던집니다."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "클릭 할당"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"어떤 클릭으로 폭발물을 던지고 어떤 클릭으로 발밑에서 터뜨릴지 선택합니다."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "좌클릭 @player"
L["EXPLOSIVES_MODE_TOSS"] = "좌클릭 던지기"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "드루이드"
L["OPTIONS_DRUID_MACRO_HELPER"] = "DruidMacroHelper 연동 활성화"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"DruidMacroHelper(/dmh)를 사용하여 치유 물약, 마나 물약, 생명석에 대한 변신 매크로를 생성합니다."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"변신 매크로로 아이템을 사용한 뒤 복귀할 형태를 선택합니다."
L["DRUID_FORM_BEAR"] = "곰으로 복귀"
L["DRUID_FORM_CAT"] = "표범으로 복귀"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "도적"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"독 매크로를 각 독 종류의 사용 가능한 최고 등급으로 유지합니다. 좌클릭은 보조장비에, 우클릭은 주장비에 바르며, 기존 독은 자동으로 교체됩니다."
L["OPTIONS_POISON_MAIN_HAND"] = "주장비 독 종류"
L["OPTIONS_POISON_OFF_HAND"] = "보조장비 독 종류"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"독 매크로를 우클릭할 때 주장비에 바를 독을 선택합니다."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"독 매크로를 좌클릭할 때 보조장비에 바를 독을 선택합니다."
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "먹을 때 은신 사용"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] =
	"음식 매크로에 은신을 추가하여 음식을 먹는 동안 은신합니다."

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "나이트 엘프"
L["OPTIONS_STEALTH_DRINKING"] = "마실 때 은신 사용"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] =
	"물 매크로에 그림자 숨기를 추가하여 물을 마시는 동안 은신합니다."
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] =
	"음식 매크로에 그림자 숨기를 추가하여 음식을 먹는 동안 은신합니다."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"프로 팁: 하나만 선택하세요. 먹기와 마시기는 동시에 할 수 있지만, 은신한 뒤에 먹거나 마시면 은신이 풀립니다."

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
L["TAB_IGNORE_LIST"] = "차단 목록"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"차단한 아이템은 어떤 매크로에서도 선택되지 않습니다. 음식, 물, 물약 등 무엇이든 해당됩니다. 전체 목록은 모든 캐릭터에 적용되고, 캐릭터 목록은 해당 캐릭터에만 적용됩니다. 미니맵 버튼을 우클릭하면 현재 가장 좋은 음식을 차단합니다."
L["OPTIONS_IGNORE_GLOBAL"] = "전체"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"이 아이템을 전체 목록으로 옮겨 모든 캐릭터에서 차단합니다."
L["OPTIONS_IGNORE_ADD_ID"] = "아이템 ID로 추가"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"아이템 ID를 입력하거나, 이 입력란이 선택된 상태에서 대화창의 아이템 링크를 Shift + 클릭하세요."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] =
	"아이템 ID를 입력하거나, 대화창의 아이템 링크를 Shift + 클릭하세요."
L["OPTIONS_IGNORE_REMOVE"] = "제거"
L["OPTIONS_IGNORE_EMPTY"] = "목록이 비어 있습니다."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "ID 불러오는 중: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"보충 목록에 따라 가방을 채워 두며, 상인에게서 구매하고 은행과 가방 사이에서 아이템을 옮기는 작업을 자동으로 처리합니다. 목록을 열려면 %s 명령어를 입력하세요."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "은행에서 열기"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "은행을 방문하면 Restocker 창을 엽니다."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "상인 방문 시 열기"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "상인을 방문하면 Restocker 창을 엽니다."
L["OPTIONS_RESTOCKER_REMIND"] = "마을 보충 알림 사용"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"보충 목록에 부족한 것이 있고 여관이나 도시에 도착하거나 이미 그곳에 있는 상태로 접속했을 때 대화창에 알림을 표시합니다."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "상인 보충 알림 사용"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"상인 창을 닫을 때 미완료 보충 주문이 있으면 알려 줍니다."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "은행 보충 알림 사용"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"은행을 닫을 때 미완료 보충 주문이 있으면 알려 줍니다."

--[[
    The Starter List Builder pop-up. This toggle and the pop-up's own "Don't
    Show This Again" box are the same per-character choice read from opposite
    ends, which is why one ships on and the other off: a settings row reads
    naturally as "enable", a dismissal reads naturally as "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] = "보충 목록이 비어 있을 때 목록 도우미 사용"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"이 캐릭터의 보충 목록이 비어 있으면 접속할 때 기본 보충 목록을 제안합니다."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"알림을 한 줄로만 표시할지, 부족한 아이템마다 한 줄씩 추가할지 선택합니다."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "간단히"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "자세히"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "소리 재생"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"대화창이 바쁠 때를 위해 알림과 함께 경고음을 재생합니다."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "클릭하면 경고음을 들어 볼 수 있습니다."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Restocker 창"

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "감사의 말"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"저는 늘 Restocker를 좋아했고, 이것이 Connoisseur 안에서 계속 살아 있게 되어 기쁩니다. 원조 Auto Restocker를 만든 ChiliFajita, 그리고 클래식과 판다리아의 안개를 거치며 이를 이어 온 kvakvs와 guardycmw에게 큰 감사를 전합니다."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "준비 보고서"
L["OPTIONS_READINESS_ENABLE"] = "전투 준비 확인 시 준비 보고서 사용"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] = "이 계정의 모든 캐릭터에서 준비 보고서를 켭니다."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"전투 준비 확인이 시작되면 아직 해결해야 할 항목을 자신만 볼 수 있는 목록으로 출력하고, 준비가 되어 있으면 아무것도 출력하지 않습니다."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the character's own profile, so nothing else on any panel can return
    them to their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "준비 보고서 설정 초기화"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"이 페이지의 모든 체크박스와 두 기준값을 기본값으로 되돌리며, 다른 페이지는 건드리지 않습니다."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"준비 보고서의 모든 설정을 기본값으로 초기화할까요? 보고서 자체도 다시 꺼집니다."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "부족한 버프"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "부족한 아이템"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "캐릭터"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"영약이 없으면 알려 줍니다. 영약 하나, 또는 전투 비약과 수호 비약 각 하나가 있으면 충족된 것으로 봅니다."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	'"포만감" 버프가 없으면 알려 줍니다. 매크로 설정에서 버프 음식을 켜야 합니다.'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	'소환수에게 "포만감" 버프가 없으면 알려 줍니다. 매크로 설정에서 소환수 음식 버프를 켜야 하며, 소환수를 불러낸 상태여야 합니다.'
L["OPTIONS_READINESS_SCROLLS"] = "두루마리 버프"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"빠진 두루마리 버프가 있으면 알려 줍니다. 매크로 설정에서 두루마리 버프를 켜야 하며, 그곳에서 선택한 두루마리 유형만 확인합니다."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"그룹 내 누구에게도 영혼석이 활성화되어 있지 않으면 알려 줍니다. 가방에 있는 영혼석은 인정하지 않습니다. 영혼석을 창조할 수 있는 흑마법사에게만 표시됩니다."
L["OPTIONS_READINESS_MAIN_HAND"] = "주장비 무기 버프"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"주장비 무기에 일시적인 강화 효과가 없으면 알려 줍니다. 어떤 강화든 인정하며, 그룹에 주술사가 있으면 알리지 않습니다."
L["OPTIONS_READINESS_OFF_HAND"] = "보조장비 무기 버프"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"보조장비 무기에 일시적인 강화 효과가 없으면 알려 줍니다. 어떤 강화든 인정합니다: 숫돌, 무게추, 오일, 독, 주술사 무기 버프."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "버프 만료 기준 시간"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"Connoisseur가 적용하는 버프만이 아니라 자신에게 걸린 버프 중 곧 만료될 것을 모두 알려 주며, 매크로 설정의 버프 재적용과는 별개입니다."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s분"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1분"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"버프가 만료되기 얼마 전부터 보고서에 표시할지 설정합니다."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"생명석을 하나도 가지고 있지 않으면 알려 줍니다. 부탁할 흑마법사가 그룹에 있거나, 자신이 흑마법사일 때만 표시됩니다."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"마나 보석을 하나도 가지고 있지 않으면 알려 줍니다. 마나 보석을 창조할 수 있는 마법사에게만 표시됩니다."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"전투 중에는 아무도 물약을 건네줄 수 없으므로, 치유 물약을 하나도 가지고 있지 않으면 알려 줍니다."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"마나 물약을 하나도 가지고 있지 않으면 알려 줍니다. 마나를 사용하는 직업으로 플레이할 때만 표시됩니다."
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] =
	"현재 응급치료 숙련도로 사용할 수 있는 붕대를 하나도 가지고 있지 않으면 알려 줍니다."
L["OPTIONS_READINESS_DURABILITY"] = "손상된 장비 (내구도 기준)"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"내구도가 이 값보다 낮은 착용 장비를 모두 링크하며, 장비별로 측정하므로 무기 하나만 부서져도 표시됩니다."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"장비의 내구도가 얼마나 떨어지면 보고서에 링크할지 설정합니다."

-- Character
L["OPTIONS_READINESS_SPEC"] = "현재 특성"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] = "특성 분배와 아직 사용하지 않은 포인트를 출력합니다."
L["OPTIONS_READINESS_PVP"] = "PvP 상태 켜짐"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "PvP 상태가 켜져 있으면 경고합니다."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "비전투용 장비 착용"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"말채찍이나 낚싯대처럼 전투에 어울리지 않는 착용 장비를 링크합니다."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = '"%s" 이름의 목록이 이미 있습니다.'
-- %d is the item ID the player typed.
L["RESTOCKER_UNKNOWN_ITEM"] = "ID %d에 해당하는 아이템이 없습니다."
L["RESTOCKER_BANK_NOT_OPEN"] = "은행이 열려 있지 않습니다."
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"보충이 완료되었습니다. 은행을 열 때 Shift를 누르고 있으면 보충을 건너뜁니다. 보충 목록을 편집하려면 %s 명령어를 입력하세요."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "보충이 중단되었습니다. 가방과 은행이 모두 가득 찼습니다."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"보충이 중단되었습니다. 은행이 가득 찼습니다. 칸을 비우고 다시 여세요."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"보충이 중단되었습니다. 가방이 가득 찼습니다. 칸을 비우고 은행을 다시 여세요."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "보충이 중단되었습니다. 더 이상 진행할 수 없습니다."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "보충이 중단되었습니다. 옮기지 못함: %s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (초과분)"
L["RESTOCKER_STOPPED_ERROR"] = "오류로 보충이 중단되었습니다: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"이 상인은 독에 필요한 재료를 전부 취급하지는 않습니다. 재료 구매를 모두 건너뜁니다."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "마을에 있는 동안 잊지 말고 보충하세요!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "보충 주문 1건이 남아 있습니다."
L["RESTOCKER_STILL_SHORT_MANY"] = "보충 주문 %d건이 남아 있습니다."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "보충 목록이 업그레이드되었습니다."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d에서 %sx%d(으)로 업그레이드되었습니다."

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
L["RESTOCKER_RESTOCKED_ONE"] = "보충 주문 1건을 완료했습니다."
L["RESTOCKER_RESTOCKED_MANY"] = "보충 주문 %d건을 완료했습니다."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "보충 주문 1건을 일부만 채웠습니다."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "보충 주문 %d건을 일부만 채웠습니다."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "모든 아이템을 구매하기 전에 가방이 가득 찼습니다."

-- /crs help lines. The command literals stay in code; these are the descriptions.
L["RESTOCKER_HELP_SHOW"] = "Restocker 창을 표시합니다."
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[이름]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "해당 이름의 목록을 추가합니다."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "해당 이름의 목록을 삭제합니다."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "현재 목록의 이름을 해당 이름으로 바꿉니다."
L["RESTOCKER_HELP_PROFILE_COPY"] = "현재 목록을 해당 이름의 목록 복사본으로 바꿉니다."
L["RESTOCKER_HELP_PROFILE_USE"] = "이 캐릭터가 해당 이름의 목록을 사용하도록 전환합니다."

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
L["STARTER_POPUP_INTRO_EMPTY"] =
	"보충 목록이 비어 있으니, 시작할 수 있도록 아이템을 몇 가지 추가해 봅시다."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] =
	"계속 채워 둘 기본 물품을 고르세요. 이미 보충 목록에 있는 것은 체크되어 있습니다."
L["STARTER_POPUP_INTRO_HOW"] =
	"선택한 항목은 상인이나 은행을 열 때마다 자동으로 채워지고, 기본 소모품은 레벨이 오르면 스스로 상위 등급으로 바뀌므로 항상 최선의 물건을 갖게 됩니다."
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"%s 명령어를 입력하면 언제든지 이 목록을 조정하거나 아이템을 더 추가할 수 있습니다."
--[[
    The first section's heading names the Water row beneath it as well; the
    food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "음식 및 물"
L["STARTER_POPUP_FOOD_HEADER"] = "음식"
L["STARTER_POPUP_AMMO_HEADER"] = "탄약"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "탄환"
L["STARTER_POPUP_ARROWS"] = "화살"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header reuses PREFIX_ROGUE (rogue-colored at the call
    site) to say the ingredients take care of themselves. Both sections name
    their rows with the client's own item names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "재료 및 도구"
L["STARTER_POPUP_POISONS_HEADER"] = "독"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : 완성된 독을 목록에 추가하면, 재료를 모두 취급하는 상인이라면 어디서든 Connoisseur가 재료를 자동으로 구매합니다."
--[[
    Checkbox tooltips: { item link, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"%s을(를) 보충 목록에 추가하고, 가방에 %d개를 유지하며 레벨에 맞춰 상위 등급으로 바꿔 줍니다."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] =
	"%s을(를) 보충 목록에 추가하고 가방에 %d개를 유지합니다."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1묶음"
L["STARTER_POPUP_STACK_MANY"] = "%d묶음"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "계속 채워 둘 묶음 수를 정하며, 한 묶음은 %d개입니다."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"계속 채워 둘 개수를 정하며, 이 아이템은 겹쳐지지 않으므로 하나당 가방 한 칸을 차지합니다."
L["STARTER_POPUP_DISMISS"] = "이 캐릭터에서 다시 표시하지 않기"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] =
	"보충 목록이 비어 있는 상태로 접속해도 이 제안이 다시 나타나지 않게 합니다."

-- Restocker window UI.
L["RESTOCKER_WINDOW_TITLE"] = "Connoisseur Restocker"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "아이템 필터..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "지우기"
L["RESTOCKER_ADD_BUTTON"] = "추가"
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "목록 도우미 열기"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"새 캐릭터에게 제안되는 것과 같은 기본 물품을 담은 목록 도우미를 열고, 이 창을 닫습니다."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "아이템 추가"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"가방에서 아이템을 끌어다 놓거나, 아이템 ID를 입력하고 Enter를 누르세요."
--[[
    In-box placeholder for the add row; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: both boxes on that row share a
    fixed width sized to this English hint, and a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "여기에 아이템 놓기 또는 ID 입력"
L["RESTOCKER_PROFILE_LABEL"] = "목록"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"클릭하면 이 캐릭터가 사용할 보충 목록을 다른 목록으로 바꾸거나 새 목록을 시작할 수 있습니다."
L["RESTOCKER_RENAME_LABEL"] = "이름 바꾸기"
L["RESTOCKER_NEW_PROFILE"] = "새 목록"
L["RESTOCKER_COPY_PROFILE"] = "복사"
--[[
    The three single-argument tooltips below (Copy, Delete, and the row's
    Remove) render in ns.SetupRestockerTooltip's TITLE slot, not its body, so
    they take title case and no terminal punctuation -- matching every other
    title in the window. Don't "restore" the period they read as wanting.
]]
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "이 목록을 새 목록으로 복사"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s 복사본"
L["RESTOCKER_DELETE_PROFILE"] = "삭제"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "이 목록 삭제"
L["RESTOCKER_RENAME_TOOLTIP"] =
	"이 목록을 사용하는 모든 캐릭터에서 이 목록의 이름을 바꿉니다."
-- %s is the list name, colored at the call site. |n are line breaks.
L["RESTOCKER_DELETE_PROFILE_CONFIRM"] =
	"이 목록을 정말 삭제하시겠습니까?|n|n%s|n|n되돌릴 수 없습니다."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "레벨에 맞춰 업그레이드"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"레벨이 오르면 Connoisseur가 음식, 물, 탄약, 독, 물약, 직업 재료를 더 좋은 아이템으로 업그레이드하도록 허용합니다."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "은행"
L["RESTOCKER_ROW_MERCHANT"] = "상인"
L["RESTOCKER_ROW_UPGRADE"] = "업그레이드"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "아이템"
L["RESTOCKER_COLUMN_WITHDRAW"] = "꺼내기"
L["RESTOCKER_COLUMN_DEPOSIT"] = "보관"
L["RESTOCKER_COLUMN_REPUTATION"] = "평판"
L["RESTOCKER_COLUMN_AMOUNT"] = "수량"

L["RESTOCKER_GROUP_OTHER"] = "미분류"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "신규"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "모든 아이템"
-- Title slot, like the Copy and Delete tooltips above: title case, no terminal period.
L["RESTOCKER_REMOVE_TOOLTIP"] = "보충 목록에서 이 아이템 제거"
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "보충할 수량"
L["RESTOCKER_AMOUNT_TOOLTIP_BODY"] = "편집을 마치면 Enter를 누르세요."
L["RESTOCKER_BUY_LABEL"] = "구매"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "상인에게서 구매"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "상인 창이 열려 있을 때 상인에게서 필요한 수량을 구매합니다."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "여분"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "여분 구매"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"상인이 가진 이 아이템의 한정 재고, 즉 조금씩 천천히 다시 채워지는 상품을 목표 수량을 넘더라도 모두 구매합니다."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "은행에 보관"
--[[
    Names the Amount column, so it is coupled to RESTOCKER_COLUMN_AMOUNT: a
    locale that renders that heading differently has to say the same word here,
    or the sentence points at a column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"은행이 열려 있을 때 초과분을 은행에 보관하며, 수량 열이 0이면 전부 보관합니다."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "은행에서 꺼내기"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "은행이 열려 있을 때 필요한 아이템을 은행에서 꺼냅니다."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "필요 평판"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% 할인)"
L["RESTOCKER_REPUTATION_ANY"] = "무관"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "약간 우호적"
L["RESTOCKER_REPUTATION_HONORED"] = "우호적"
L["RESTOCKER_REPUTATION_REVERED"] = "매우 우호적"
L["RESTOCKER_REPUTATION_EXALTED"] = "확고한 동맹"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "필요한 상인 평판"
--[[
    Quotes the cell's own values, which couples this line to
    RESTOCKER_REPUTATION_ANY and the four standings above: a locale that renders
    a standing differently has to say so here too.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	'클릭하면 Connoisseur가 상인에게서 구매하는 데 필요한 평판 단계("무관"은 어디서나 구매)를 설정할 수 있으며, 이 평판으로 가격도 할인됩니다: 약간 우호적 5%, 우호적 10%, 매우 우호적 15%, 확고한 동맹 20%.'
