local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "ptBR")
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

L["MACRO_BANDAGE"] = "- Bandagem"
L["MACRO_EXPLOSIVES"] = "- Explosivos"
L["MACRO_FEED_PET"] = "- Alim. Ajudante"
L["MACRO_FOOD"] = "- Comida"
L["MACRO_HEALTH_POTION"] = "- Poção de Cura"
L["MACRO_HEALTHSTONE"] = "- Pedra de Vida"
L["MACRO_MANA_GEM"] = "- Gema de Mana"
L["MACRO_MANA_POTION"] = "- Poção de Mana"
L["MACRO_POISONS"] = "- Venenos"
L["MACRO_SOULSTONE"] = "- Pedra de Alma"
L["MACRO_WATER"] = "- Água"

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

L["DIET_BREAD"] = "Pão"
L["DIET_CHEESE"] = "Queijo"
L["DIET_FISH"] = "Peixe"
L["DIET_FRUIT"] = "Fruta"
L["DIET_FUNGUS"] = "Fungo"
L["DIET_MEAT"] = "Carne"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"Parece que você encontrou um bug! %s (%s) não pode ser usado em %s > %s (%s). Por favor, informe o problema para que possamos corrigi-lo. Obrigado! %s"
L["MESSAGE_NO_ITEM"] = "Nenhum item adequado do tipo %s encontrado nas suas bolsas."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"Algumas macros do Connoisseur não puderam ser criadas porque seus espaços de macro estão cheios. Libere um espaço excluindo as macros que você não usa mais, ou desative as macros do Connoisseur de que você não precisa em Opções > AddOns > Connoisseur > Macros."

L["CHAT_LOADED"] =
	"Versão %s. As configurações (incluindo a opção de desativar esta mensagem) podem ser encontradas em Opções > AddOns > Connoisseur. Gostando do addon? Conte para um amigo! (="

L["CHAT_OPTIONS_IN_COMBAT"] = "Por segurança, a interface de opções não pode ser aberta durante o combate."

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

L["READINESS_TITLE"] = "Relatório de Prontidão"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Buffs faltando:"
L["READINESS_EXPIRING"] = "Expirando em breve:"
L["READINESS_MISSING_ITEMS"] = "Itens faltando:"
L["READINESS_DAMAGED_GEAR"] = "Equipamento danificado:"
L["READINESS_CHARACTER"] = "Personagem:"
L["READINESS_QUESTIONABLE_GEAR"] = "Equipamento não combativo equipado:"

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
L["READINESS_FLASK"] = "Frasco ou 2x elixires"
L["READINESS_WELL_FED"] = "Bem Alimentado"
L["READINESS_PET_WELL_FED"] = "Bem Alimentado (ajudante)"
L["READINESS_SCROLLS"] = "Pergaminhos"
L["READINESS_SOULSTONE"] = "Pedra da Alma inativa"
L["READINESS_MAIN_HAND"] = "Mão Principal"
L["READINESS_OFF_HAND"] = "Mão Secundária"
L["READINESS_HEALTHSTONE"] = "Pedra de Vida"
L["READINESS_MANA_GEM"] = "Gema de Mana"
L["READINESS_HEALING_POTION"] = "Poção de Cura"
L["READINESS_MANA_POTION"] = "Poção de Mana"
L["READINESS_BANDAGES"] = "Bandagens"
L["READINESS_PVP_ON"] = "JxJ ativado!"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s menos de 1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 ponto de talento não gasto"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d pontos de talento não gastos"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Atualmente você não tem nenhuma comida útil para o seu ajudante."
L["TIP_PET_NO_SKILLS"] =
	"Você ainda não aprendeu Chamar Ajudante, Dispensar Ajudante, Alimentar Ajudante ou Reviver Ajudante."
L["TIP_PET_NO_MEND"] = "Você ainda não aprendeu Curar Ajudante."
L["TIP_NO_HAND_POISON"] = "Você está sem o veneno escolhido para esta arma."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Você ainda não aprendeu %s."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "Comida com Buff"
L["MENU_BUFF_FOOD_DESCRIPTION"] = 'Prioriza comida que concede o buff "Bem Alimentado", quando o buff estiver faltando.'
L["FEATURE_SCROLL_BUFFS"] = "Buffs de Pergaminho"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] =
	"Sua macro de Comida aplica os buffs de pergaminho que faltam antes de você comer."

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Attention Hunters block, and the two poison titles open the
    Attention Rogues block.
]]
L["MINIMAP_BEST_FOOD"] = "Comida atual"
L["MINIMAP_BEST_PET_FOOD"] = "Comida de Ajudante atual"
L["MINIMAP_MAIN_HAND_POISON"] = "Veneno da Mão Principal"
L["MINIMAP_OFF_HAND_POISON"] = "Veneno da Mão Secundária"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Lista de Ignorados"
L["MINIMAP_IGNORE_COUNT"] = "%d itens"
L["MENU_IGNORE"] = "Ignorar"
L["MENU_CLEAR_IGNORE"] = "Limpar Lista de Ignorados"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Relatório do Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d pedidos pendentes"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Parabéns, seu estoque está completo!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Sua lista está vazia."

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Lista do Restocker"
L["MENU_RESTOCKER_DESCRIPTION"] = "Compra e guarda no banco os itens da sua lista."
L["MENU_RESTOCKER_KEYBIND"] = "Shift + clique direito"
L["MENU_OPTIONS"] = "Opções do Connoisseur"
L["MENU_OPTIONS_KEYBIND"] = "Shift + clique do meio"

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The class block of the mini-map tooltip: a class-colored header, the items
    the class's own macro will use (a Hunter's pet food, a Rogue's two poisons,
    titled in the Minimap Tooltip section above), then one group per macro.
]]

L["PREFIX_HUNTER"] = "Atenção Caçadores"
L["PREFIX_MAGE"] = "Atenção Magos"
L["PREFIX_ROGUE"] = "Atenção Ladinos"
L["PREFIX_WARLOCK"] = "Atenção Bruxos"

--[[
    A group is the macro's name, then one row per click: the click on the left
    and what it does on the right. The right-hand column never wraps, so each
    result stays a few words. A spell the row casts is named by the client
    (Mend Pet, Ritual of Refreshment, Ritual of Souls) and has no key here, and
    a plain click reuses MINIMAP_LEFT_CLICK, MINIMAP_RIGHT_CLICK or
    MINIMAP_MIDDLE_CLICK.
]]
L["NOTE_MACRO_FEED_PET"] = "Macro de Alim. Ajudante"
L["NOTE_MACRO_FOOD_WATER"] = "Macros de Comida e Água"
L["NOTE_MACRO_MANA_GEM"] = "Macro de Gema de Mana"
L["NOTE_MACRO_HEALTHSTONE"] = "Macro de Pedra de Vida"
L["NOTE_MACRO_SOULSTONE"] = "Macro de Pedra de Alma"
L["NOTE_MACRO_POISONS"] = "Macro de Venenos"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Chamar, alimentar ou reviver"
L["NOTE_PET_MEND_CLICK"] = "Clique direito, ou em combate"
L["NOTE_HOLD_SHIFT"] = "Segure Shift"
L["NOTE_PET_FORCE_REVIVE"] = "Forçar reviver"
L["NOTE_HOLD_CONTROL"] = "Segure Ctrl"
L["NOTE_PET_DISMISS"] = "Dispensar"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Conjurar"
L["NOTE_CREATE"] = "Criar"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Clique direito de novo"
L["NOTE_LOWER_RANK_BACKUP"] = "Reserva de grau inferior"
L["NOTE_MAGE_TARGET_LEVEL"] =
	"Selecione como alvo um jogador de nível mais baixo para conjurar de acordo com o nível dele."
L["NOTE_WARLOCK_TARGET_LEVEL"] =
	"Selecione como alvo um jogador de nível mais baixo para criar uma de acordo com o nível dele."

-- Rogue. The two hands are the results of a Left-Click and a Right-Click on the Poisons macro.
L["MINIMAP_MAIN_HAND"] = "Mão Principal"
L["MINIMAP_OFF_HAND"] = "Mão Secundária"
L["NOTE_POISONS_WINDOW"] = "Janela de Venenos"
L["NOTE_POISONS_REPLACED"] = "Substitui os venenos antigos automaticamente."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Bandagem"
L["LABEL_EXPLOSIVE"] = "Explosivo"
L["LABEL_FOOD"] = "Comida"
L["LABEL_HEALTH_POTION"] = "Poção de Cura"
L["LABEL_HEALTHSTONE"] = "Pedra de Vida"
L["LABEL_MANA_GEM"] = "Gema de Mana"
L["LABEL_MANA_POTION"] = "Poção de Mana"
L["LABEL_PET_FOOD"] = "Comida de Ajudante"
L["LABEL_POISONS"] = "Veneno"
L["LABEL_SOULSTONE"] = "Pedra da Alma"
L["LABEL_WATER"] = "Água"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Ativado"
L["MINIMAP_DISABLED"] = "Desativado"
L["MINIMAP_TOGGLE"] = "Alternar"
L["MINIMAP_OPEN"] = "Abrir"
L["MINIMAP_LEFT_CLICK"] = "Clique esquerdo"
L["MINIMAP_RIGHT_CLICK"] = "Clique direito"
L["MINIMAP_MIDDLE_CLICK"] = "Clique do meio"
L["MINIMAP_SHIFT_LEFT"] = "Shift + clique esquerdo"

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
	"Escolhe quando sua macro de Comida oferece %s: sempre, ou apenas quando você estiver jogando sozinho, em grupo ou raide, em raide, subindo de nível ou no nível máximo."
L["MODE_ALWAYS"] = "Sempre"
L["MODE_SOLO"] = "Jogando sozinho"
L["MODE_PARTY"] = "Em grupo ou raide"
L["MODE_RAID"] = "Em raide"
L["MODE_LEVELING"] = "Subindo de nível"
L["MODE_MAX_LEVEL"] = "No nível máximo"

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
L["INVENTORY_REPORT_TITLE"] = "Relatório de Inventário"
L["INVENTORY_REPORT_BAGS"] = "Bolsas"
L["INVENTORY_REPORT_BANK"] = "Banco"
-- In place of the Bank count, muted, until this character's bank has been opened once with the add-on running.
L["INVENTORY_REPORT_BANK_UNKNOWN"] = "Desconhecido"
-- Everything above it added up: this character and every other one on the realm.
L["INVENTORY_REPORT_TOTAL"] = "Total"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Macros que usam automaticamente sua melhor comida, água, poções, pedras de vida, bandagens, venenos e comida de ajudante, além de uma lista de reabastecimento que compra e guarda no banco seus consumíveis automaticamente e os melhora conforme você sobe de nível. Automação de qualidade de vida para um desempenho máximo."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Ativar mensagem de boas-vindas"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Exibe uma mensagem de boas-vindas no chat ao entrar no jogo."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Ativar botão do minimapa"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Mostra o botão do minimapa."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre a interface de opções deste addon."
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Abre sua lista de reabastecimento."

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "Feedback e suporte"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["CURSEFORGE"] = "CurseForge"
L["WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Versão %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Enable Macros header below titles the first section,
    after the page's one headerless toggle, Macro Names on Buttons.
]]
L["TAB_MACROS"] = "Macros"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"O Connoisseur cria uma macro por consumível e a mantém atualizada conforme suas bolsas mudam, então o botão na sua barra sempre busca o melhor item que você está carregando. Escolha abaixo quais macros criar e depois defina como cada uma escolhe seu item."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Ativar nomes de macro nos botões"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Mostra o nome das macros nos botões da sua barra de ações, texto que o Connoisseur oculta por padrão."

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "Ativar macros"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Escolha quais macros o Connoisseur cria e mantém. Desativar uma também a remove."
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Cria e mantém esta macro, e a remove quando você desmarca esta opção."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Comida e água"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Suas macros de Comida e Água usam a melhor comida e bebida das suas bolsas. Estas opções podem colocar primeiro a comida com buff, os pergaminhos ou a comida e água conjuradas."

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Priorizar Comida com Buff"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'Prioriza comida que concede o buff "Bem Alimentado" quando o buff estiver faltando, exceto nas Arenas.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Ativar Buffs de Pergaminho"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Sua macro de Comida aplica os pergaminhos que faltam no primeiro clique e come no seguinte, ignorando os pergaminhos quando você tem um jogador amigável como alvo ou está em uma Arena."
L["OPTIONS_SCROLL_TYPES"] = "Incluir tipos de pergaminho na verificação"
L["OPTIONS_SCROLL_AGILITY"] = "Agilidade"
L["OPTIONS_SCROLL_INTELLECT"] = "Intelecto"
L["OPTIONS_SCROLL_PROTECTION"] = "Proteção"
L["OPTIONS_SCROLL_SPIRIT"] = "Espírito"
L["OPTIONS_SCROLL_STAMINA"] = "Vigor"
L["OPTIONS_SCROLL_STRENGTH"] = "Força"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "Inclui %s na verificação de buffs faltando."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Usar primeiro comida e água conjuradas"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Suas macros de Comida e Água usam comida e água conjuradas antes de qualquer outra coisa, mesmo quando algo nas suas bolsas restaurar mais, já que elas não custam nada e somem pouco depois que você sai do jogo. A comida com buff continua vindo primeiro enquanto "Priorizar Comida com Buff" estiver ativado.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Escolhe quando comida e água conjuradas vêm primeiro: sempre, ou apenas quando você estiver jogando sozinho, em grupo ou raide, em raide, subindo de nível ou no nível máximo."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Poções e Pedras de Vida"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"As macros não podem ser alteradas durante o combate (isso é uma restrição da Blizzard), então cada macro de Poção e Pedra de Vida é pré-construída com seu melhor item mais até duas alternativas. Em lutas mais longas, o ícone e a dica de interface podem ficar desatualizados e mostrar o item errado, mas clicar na macro sempre usará o melhor item que você realmente tem nas suas bolsas."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Usar comida e água nas macros de Poção fora de combate"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Fora de combate, sua macro de Poção de Cura come sua melhor comida e sua macro de Poção de Mana bebe sua melhor água. Em combate, elas usam suas poções como antes. Pergaminhos, comida de ajudante e conjuração continuam nas macros de Comida e Água."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combinar Pedras de Vida na macro de Poção de Cura"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Adiciona sua melhor Pedra de Vida ao final da macro de Poção de Cura, para que um clique use uma poção e uma Pedra de Vida."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemas de Mana e Runas"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"As Runas Demoníacas e Negras, e alguns outros itens de mana, compartilham o tempo de recarga com as Gemas de Mana. As runas custam vida ao serem usadas, então a macro de Gema de Mana deixa todos esses itens de fora, a menos que você os adicione."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Adicionar Runas e outros itens de mana à macro de Gema de Mana"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"Classifica suas Runas Demoníacas e Negras, e qualquer outro item de mana que compartilhe o tempo de recarga das Gemas de Mana, junto com suas Gemas de Mana, para que a macro de Gema de Mana use um deles quando for sua melhor opção ou quando você estiver sem gemas."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Reaplicação de Buffs"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"As macros não podem ser alteradas durante o combate, então um buff que expira no meio da luta continua ausente até o combate terminar."
L["OPTIONS_REAPPLY"] = "Reaplicar buffs prestes a expirar"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Considera expirados Comida com Buff, Buffs de Pergaminho e Buffs de Comida de Ajudante que tenham menos tempo restante que o seu limite, para que suas macros ofereçam um novo antes do combate."
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Define o quão perto de expirar um buff pode chegar antes que suas macros ofereçam um novo."
L["REAPPLY_THRESHOLD_ONE"] = "Quando restar < 1 minuto"
L["REAPPLY_THRESHOLD_MANY"] = "Quando restarem < %d minutos"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Buffs de Comida de Ajudante"
L["OPTIONS_PET_SECTION_DESCRIPTION"] = 'Algumas comidas dão ao seu ajudante um buff "Bem Alimentado" próprio.'
L["OPTIONS_USE_PET_BUFFS"] = "Usar Buffs de Comida de Ajudante"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	'Adiciona comida de ajudante à sua macro de Comida quando falta o buff "Bem Alimentado" no seu ajudante, exceto nas Arenas.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Incluir tipos de Comida de Ajudante na verificação"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Explosivos"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"A opção @player pula o retículo de mira e detona o explosivo aos seus pés. Ideal quando o alvo está no corpo a corpo. Seu outro clique arremessa o explosivo normalmente."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Configuração de cliques"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Escolhe qual clique arremessa o explosivo e qual o detona aos seus pés."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clique esquerdo @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clique esquerdo arremessar"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "Druidas"
L["OPTIONS_DRUID_MACRO_HELPER"] = "Ativar integração do DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Cria macros de mudança de forma para Poções de Cura, Poções de Mana e Pedras de Vida usando o DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Escolhe para qual forma suas macros de mudança de forma fazem você voltar depois de usar o item."
L["DRUID_FORM_BEAR"] = "Voltar para Urso"
L["DRUID_FORM_CAT"] = "Voltar para Felino"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "Ladinos"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Mantém a macro de Venenos carregada com o melhor grau utilizável de cada tipo de veneno: clique esquerdo aplica na mão secundária, clique direito na mão principal, e venenos existentes são substituídos automaticamente."
L["OPTIONS_POISON_MAIN_HAND"] = "Tipo de veneno da mão principal"
L["OPTIONS_POISON_OFF_HAND"] = "Tipo de veneno da mão secundária"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Escolhe o veneno que sua macro de Venenos aplica na sua mão principal com o clique direito."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Escolhe o veneno que sua macro de Venenos aplica na sua mão secundária com o clique esquerdo."
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "Ativar furtividade ao comer"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] =
	"Anexa Furtividade à sua macro de Comida para que você entre em furtividade enquanto come."

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "Elfos Noturnos"
L["OPTIONS_STEALTH_DRINKING"] = "Ativar furtividade ao beber"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] =
	"Anexa Fusão Sombria à sua macro de Água para que você entre em furtividade enquanto bebe."
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] =
	"Anexa Fusão Sombria à sua macro de Comida para que você entre em furtividade enquanto come."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Dica pro: Escolha um. Você pode comer e beber ao mesmo tempo, mas comer ou beber depois de entrar em furtividade quebrará sua furtividade."

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
L["TAB_IGNORE_LIST"] = "Lista de Ignorados"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Itens ignorados nunca são escolhidos por nenhuma macro. Comida, água, poções, qualquer coisa. A lista Global vale para todos os personagens; a lista de um personagem vale só para ele. Clique com o botão direito no botão do minimapa para ignorar sua melhor comida atual."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Move este item para a lista Global, para que seja ignorado em todos os personagens."
L["OPTIONS_IGNORE_ADD_ID"] = "Adicionar por ID do item"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Digite um ID de item, ou dê Shift + Clique em um link de item no chat enquanto este campo estiver ativo."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "Digite um ID de item, ou dê Shift + Clique em um link de item no chat."
L["OPTIONS_IGNORE_REMOVE"] = "Remover"
L["OPTIONS_IGNORE_EMPTY"] = "Esta lista está vazia."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Carregando ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Mantém suas bolsas abastecidas a partir da sua lista de reabastecimento, comprando dos mercadores e movendo itens de e para o banco automaticamente. Digite %s para abrir a lista."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Abrir no banco"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Abre sua lista de reabastecimento quando você visita o banco."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Abrir no mercador"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Abre sua lista de reabastecimento quando você visita um mercador."
L["OPTIONS_RESTOCKER_REMIND"] = "Ativar lembretes de reabastecimento na cidade"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Exibe um lembrete no chat quando falta algo na sua lista de reabastecimento e você chega a uma estalagem ou cidade, ou já está em uma ao entrar no jogo."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Ativar lembretes de reabastecimento no mercador"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Informa quaisquer pedidos de reabastecimento pendentes quando você fecha a janela de um mercador."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Ativar lembretes de reabastecimento no banco"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Informa quaisquer pedidos de reabastecimento pendentes quando você fecha o banco."

--[[
    The staples pop-up (STARTER_POPUP_TITLE below). This toggle and the
    pop-up's own "Don't Show This Again" box are the same per-character choice
    read from opposite ends, which is why one ships on and the other off: a
    settings row reads naturally as "enable", a dismissal reads naturally as
    "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] = "Ativar janela de básicos quando a lista de reabastecimento estiver vazia"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"Oferece os básicos da sua classe ao entrar no jogo sempre que a lista de reabastecimento deste personagem estiver vazia."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Escolhe se o lembrete fica em uma única linha ou adiciona uma linha para cada item em falta."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Simples"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Detalhado"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Tocar som"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Toca um alerta junto com o lembrete, para quando o chat está agitado."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Clique para ouvir o alerta."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Janela da lista de reabastecimento"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Escolha quando sua lista de reabastecimento se abre sozinha."

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Mostra na dica de interface de um item quantas unidades dele você possui, somando todos os seus personagens neste reino."
L["OPTIONS_INVENTORY_REPORT"] = "Ativar Relatório de Inventário nas dicas de interface dos itens"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"Adiciona à dica de interface de um item quantas unidades dele você tem nas suas bolsas, no seu banco e nos seus outros personagens. Desative-o se outro addon já mostrar essas quantidades."

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Agradecimentos"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"Sempre amei o Restocker, e sou grato pela oportunidade de mantê-lo vivo dentro do Connoisseur. Muito obrigado a ChiliFajita, que escreveu o Auto Restocker original, e a kvakvs e guardycmw, que o mantiveram ativo ao longo do Classic e de Mists of Pandaria."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Relatório de Prontidão"
L["OPTIONS_READINESS_ENABLE"] = "Ativar Relatório de Prontidão na verificação de jogadores prontos"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] = "Ativa o Relatório de Prontidão para todos os personagens desta conta."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Quando uma verificação de jogadores prontos começa, exibe uma lista privada do que ainda precisa ser resolvido e não diz absolutamente nada quando está tudo pronto."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Redefinir configurações do Relatório de Prontidão"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Restaura todas as caixas de seleção e os dois limites desta página para os valores padrão, sem alterar nenhuma outra página."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Redefinir todas as configurações do Relatório de Prontidão para o padrão? Isso também desliga o próprio relatório de novo."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Buffs faltando"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Itens faltando"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personagem"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Avisa quando falta um frasco. Um frasco, ou um elixir de batalha e um elixir guardião, já é suficiente."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	'Avisa quando falta o buff "Bem Alimentado". Requer Comida com Buff ativada em Macros.'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	'Avisa quando falta o buff "Bem Alimentado" no seu ajudante. Requer Buffs de Comida de Ajudante ativados em Macros e um ajudante evocado.'
L["OPTIONS_READINESS_SCROLLS"] = "Buffs de Pergaminho"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Avisa quando faltam buffs de pergaminho. Requer Buffs de Pergaminho ativados em Macros e verifica apenas os tipos de pergaminho selecionados lá."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Avisa quando ninguém do seu grupo tem uma Pedra da Alma ativa; uma guardada na bolsa não conta. Só aparece para um Bruxo que possa criar uma."
L["OPTIONS_READINESS_MAIN_HAND"] = "Buff de arma (Mão Principal)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Avisa quando a arma da mão principal não tem encantamento temporário. Qualquer encantamento conta, e o aviso não aparece quando há um Xamã no seu grupo."
L["OPTIONS_READINESS_OFF_HAND"] = "Buff de arma (Mão Secundária)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Avisa quando a arma da mão secundária não tem encantamento temporário. Qualquer encantamento conta: uma pedra, um óleo, um veneno ou um buff de arma de Xamã."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Buffs expirando em até"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"Lista todos os buffs em você prestes a expirar, não só os que o Connoisseur aplica, e é independente da Reaplicação de Buffs em Macros."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minutos"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minuto"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Define o quão perto de expirar um buff precisa estar para que o relatório o liste."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma Pedra de Vida. Só aparece quando há um Bruxo no grupo a quem pedir, ou quando o Bruxo é você."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma Gema de Mana. Só aparece para um Mago que possa conjurar uma."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma poção de cura, já que ninguém pode entregar uma para você no meio da luta."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma poção de mana. Só aparece quando você está jogando com uma classe que usa mana."
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] =
	"Avisa quando você não carrega nenhuma bandagem que sua perícia em Primeiros Socorros permita usar."
L["OPTIONS_READINESS_DURABILITY"] = "Equipamento danificado abaixo de"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Mostra o link de cada item equipado abaixo dessa durabilidade, medida por item para que uma única arma quebrada ainda apareça."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Define o quão baixa a durabilidade de um item precisa ficar para que o relatório mostre o link dele."

-- Character
L["OPTIONS_READINESS_SPEC"] = "Especialização atual"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] = "Mostra sua distribuição de talentos, e os pontos que você não gastou."
L["OPTIONS_READINESS_PVP"] = "Marcação JxJ ativa"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avisa quando sua marcação JxJ está ativa."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Equipamento não combativo equipado"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"Mostra o link de itens equipados que não têm lugar em combate, como um Rebenque ou uma vara de pescar."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Já existe uma lista chamada "%s".'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "Não há item com ID %d."
L["RESTOCKER_BANK_NOT_OPEN"] = "O banco não está aberto."
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Reabastecimento concluído. Segure Shift ao abrir o banco para pular o reabastecimento. Digite %s para editar sua lista de reabastecimento."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Reabastecimento interrompido. Suas bolsas e seu banco estão cheios."
L["RESTOCKER_STOPPED_BANK_FULL"] = "Reabastecimento interrompido. Seu banco está cheio; libere um espaço e reabra-o."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Reabastecimento interrompido. Suas bolsas estão cheias; libere um espaço e reabra o banco."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Reabastecimento interrompido. Nenhum progresso foi possível."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Reabastecimento interrompido. Não foi possível mover: %s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (excedente)"
L["RESTOCKER_STOPPED_ERROR"] = "Reabastecimento interrompido por um erro: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Este mercador não tem todos os ingredientes de que seus venenos precisam. Nenhum será comprado."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "Não se esqueça de reabastecer enquanto estiver na cidade!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 pedido de reabastecimento pendente."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d pedidos de reabastecimento pendentes."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Sua lista de reabastecimento recebeu melhorias."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d passa a %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 pedido de reabastecimento atendido."
L["RESTOCKER_RESTOCKED_MANY"] = "%d pedidos de reabastecimento atendidos."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 pedido de reabastecimento atendido em parte."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d pedidos de reabastecimento atendidos em parte."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Suas bolsas encheram antes de tudo ser comprado."

-- /crs help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nome]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Adiciona uma lista com esse nome."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Exclui a lista com esse nome."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renomeia a lista atual para esse nome."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Substitui a lista atual por uma cópia da lista com esse nome."
L["RESTOCKER_HELP_PROFILE_USE"] = "Troca este personagem para a lista com esse nome."

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
L["STARTER_POPUP_TITLE"] = "Básicos do Connoisseur"
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Sua lista de reabastecimento está vazia, então vamos adicionar alguns itens para você começar."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Escolha os básicos que você quer manter abastecidos."
L["STARTER_POPUP_INTRO_HOW"] =
	"Tudo o que você marcar é reabastecido automaticamente sempre que você visitar um mercador ou o seu banco. Os itens comuns melhoram sozinhos conforme você sobe de nível, então você sempre terá o melhor disponível."
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] = "Você sempre pode ajustar esta lista, ou adicionar mais itens depois, digitando %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Comida e água"
L["STARTER_POPUP_FOOD_HEADER"] = "Comida"
L["STARTER_POPUP_AMMO_HEADER"] = "Munição"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Balas"
L["STARTER_POPUP_ARROWS"] = "Flechas"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header reuses PREFIX_ROGUE (rogue-colored at the call
    site) to say the ingredients take care of themselves. Both sections name
    their rows with the client's own item names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Reagentes e ferramentas"
L["STARTER_POPUP_POISONS_HEADER"] = "Venenos"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Adicione o veneno pronto à sua lista, e o Connoisseur compra os ingredientes automaticamente em qualquer mercador que venda todos eles."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Adiciona %s à sua lista de reabastecimento, mantendo %d nas suas bolsas e melhorando-os conforme você sobe de nível."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Adiciona %s à sua lista de reabastecimento, mantendo %d nas suas bolsas."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 pilha"
L["STARTER_POPUP_STACK_MANY"] = "%d pilhas"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Quantas pilhas manter em estoque, sendo que uma pilha equivale a %d."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Quantos manter em estoque, cada um em seu próprio espaço na bolsa, já que não empilham."
L["STARTER_POPUP_DISMISS"] = "Não mostrar novamente para este personagem"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] =
	"Impede que estas sugestões voltem em um login que encontre sua lista de reabastecimento vazia."

-- Restock List window UI. The title names what the window holds; the feature that acts on it stays "Restocker".
L["RESTOCKER_WINDOW_TITLE"] = "Lista de reabastecimento do Connoisseur"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtrar itens..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Limpar"
L["RESTOCKER_ADD_BUTTON"] = "Adicionar"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. The keys keep the pop-up's
    earlier name, the List Builder. "Check" is the pop-up's own word
    (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "Escolher básicos"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"Escolha entre os básicos da sua classe e do seu nível: comida, água, munição, venenos e reagentes. Ao marcar um, ele é adicionado a esta lista; ao desmarcá-lo, ele é removido."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Adicionar um item"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Solte um item das suas bolsas aqui ou em qualquer lugar desta janela, ou digite um ID de item e pressione Enter."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Solte o item ou digite o ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Em vez disso, digite o ID."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Adicionar das bolsas"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Todos os itens das suas bolsas que ainda não estão nesta lista. Clique em um para adicioná-lo."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nada nas suas bolsas para adicionar"

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
	"Clique para trocar este personagem para outra lista de reabastecimento, ou para começar uma nova."
L["RESTOCKER_USED_BY"] = "Usada por %s"
L["RESTOCKER_MANAGE"] = "Gerenciar listas"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Comece uma nova lista, ou copie, renomeie ou exclua esta."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu. The Copy and Delete keys end in
    _TOOLTIP because they began as the tooltips of two buttons this menu
    replaced.
]]
L["RESTOCKER_NEW_PROFILE"] = "Nova lista"
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "Copiar esta lista para uma nova"
L["RESTOCKER_RENAME_PROFILE"] = "Renomear esta lista"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "Excluir esta lista"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Cópia"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Renomear"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renomeia esta lista para todos os personagens que a usam."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "Tem certeza de que deseja excluir esta lista?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] = "%s também a usa e, ao entrar no jogo, terá uma lista vazia com o mesmo nome."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s também a usam e, ao entrar no jogo, cada um terá uma lista vazia com o mesmo nome."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Você passará a usar %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "É a única lista que resta, então você começará com uma nova lista vazia."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Isso não pode ser desfeito."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Melhorar conforme você sobe de nível"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permite que o Connoisseur substitua comida, água, munição, venenos, poções e reagentes de classe por itens melhores conforme você sobe de nível."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Banco"
L["RESTOCKER_ROW_MERCHANT"] = "Mercador"
L["RESTOCKER_ROW_UPGRADE"] = "Melhoria"

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
L["RESTOCKER_COLUMN_WITHDRAW"] = "Pegar"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Guardar"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Manter"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Clique no cabeçalho para definir isto em todos os itens exibidos."
L["RESTOCKER_BULK_ON"] = "Ativar nos exibidos (%d)"
L["RESTOCKER_BULK_OFF"] = "Desativar nos exibidos (%d)"

L["RESTOCKER_GROUP_OTHER"] = "Outros"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Novos"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Todos os itens"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_LIST_BUILDER_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Nada nesta lista ainda"
L["RESTOCKER_EMPTY_BODY"] =
	"Selecione básicos como comida, água ou reagentes de classe, ou adicione qualquer coisa das suas bolsas pelo menu acima. Os itens selecionados são mantidos em estoque ou guardados no seu banco automaticamente, deixando suas bolsas organizadas."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Soltar um item em qualquer lugar desta janela também o adiciona."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nada nesta lista corresponde ao seu filtro."
L["RESTOCKER_NO_MATCH_GROUP"] = "Não resta nada nesta categoria."

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
L["RESTOCKER_NO_ORDERS"] = "Nenhum pedido de reabastecimento pendente."
L["RESTOCKER_REPORT_MORE"] = "e mais %d"
L["RESTOCKER_REMOVED_ITEM"] = "Você removeu %s."
L["RESTOCKER_UNDO"] = "Desfazer"
L["RESTOCKER_UNDO_TOOLTIP"] = "Devolver este item à lista"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Remover este item da lista de reabastecimento"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Você pode desfazer isso na parte inferior da janela."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Manter nas suas bolsas"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"Quantos manter nas suas bolsas. O número fica amarelo enquanto suas bolsas tiverem menos, e 0, com Guardar ativado, envia tudo para o banco."
L["RESTOCKER_BUY_LABEL"] = "Comprar"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Comprar do mercador"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Compra a quantidade necessária do mercador quando a janela do mercador está aberta."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Comprar extra"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Compra todo o estoque limitado que um mercador tem deste item, as mercadorias de poucas unidades que ele repõe devagar, mesmo acima do valor da coluna Manter."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Guardar no banco"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Guarda os itens excedentes no banco quando o banco está aberto, ou todos eles com 0 na coluna Manter."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Pegar do banco"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Pega os itens necessários do banco quando o banco está aberto."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Reputação exigida"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% de desconto)"
L["RESTOCKER_REPUTATION_ANY"] = "Qualquer"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "Respeitado"
L["RESTOCKER_REPUTATION_HONORED"] = "Honrado"
L["RESTOCKER_REPUTATION_REVERED"] = "Reverenciado"
L["RESTOCKER_REPUTATION_EXALTED"] = "Exaltado"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Reputação exigida com o mercador"
--[[
    Quotes the cell's own values, which couples this line to the four standings
    above: a locale that renders a standing differently has to say so here too.
    With no standing required the cell draws a dash rather than the word "Any",
    which is why the last sentence names the dash; "Any" is still the menu's
    first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	"Clique para definir a reputação que um mercador exige antes que o Connoisseur compre dele, o que também reduz o preço: Respeitado 5%, Honrado 10%, Reverenciado 15%, Exaltado 20%. Com um traço, compra de qualquer mercador."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"Comprar está desativado para este item, então não há nada extra para comprar."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"Comprar está desativado para este item, então nenhuma reputação se aplica."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Este item não tem uma versão melhor para substituí-lo."
