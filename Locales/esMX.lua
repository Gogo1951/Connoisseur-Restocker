local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "esMX")
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

L["MACRO_BANDAGE"] = "- Venda"
L["MACRO_EXPLOSIVES"] = "- Explosivos"
L["MACRO_FEED_PET"] = "- Alim. mascota"
L["MACRO_FOOD"] = "- Comida"
L["MACRO_HEALTH_POTION"] = "- Poc. Salud"
L["MACRO_HEALTHSTONE"] = "- Piedra"
L["MACRO_MANA_GEM"] = "- Gema de maná"
L["MACRO_MANA_POTION"] = "- Poc. Maná"
L["MACRO_POISONS"] = "- Venenos"
L["MACRO_SOULSTONE"] = "- Piedra de alma"
L["MACRO_WATER"] = "- Agua"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of a list: a Readiness Report clause, the Restocker's "Couldn't move" list, or the characters on a Restock List.
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

    They are ALSO the food checkbox labels in the staples pop-up, so they
    read as ordinary labels while carrying that hard constraint. Translate them
    as the client's own diet words, never as the nicer label they look like --
    a locale that "improves" one here stops matching that client's strings and
    silently breaks pet-food selection for everyone playing in it.
]]

L["DIET_BREAD"] = "Pan"
L["DIET_CHEESE"] = "Queso"
L["DIET_FISH"] = "Pescado"
L["DIET_FRUIT"] = "Fruta"
L["DIET_FUNGUS"] = "Hongo"
L["DIET_MEAT"] = "Carne"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"¡Parece que has encontrado un error! %s (%s) no se puede usar en %s > %s (%s). Por favor, avísanos para que podamos corregirlo. ¡Gracias! %s"
L["MESSAGE_NO_ITEM"] = "No hay ningún objeto adecuado de tipo %s en tus bolsas."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"No se pudieron crear algunas macros de Connoisseur porque tus espacios para macros están llenos. Libera un espacio borrando macros que ya no uses, o desactiva las macros de Connoisseur que no necesites en Opciones > AddOns > Connoisseur > Macros."

L["CHAT_LOADED"] =
	"Versión %s. Los ajustes (incluida la opción de desactivar este mensaje) se encuentran en Opciones > AddOns > Connoisseur. ¿Te gusta el accesorio? ¡Cuéntaselo a un amigo! (="

L["CHAT_OPTIONS_IN_COMBAT"] = "Como medida de seguridad, la interfaz de opciones no se puede abrir durante el combate."

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

L["READINESS_TITLE"] = "Informe de preparación"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Beneficios que faltan:"
L["READINESS_EXPIRING"] = "A punto de expirar:"
L["READINESS_MISSING_ITEMS"] = "Objetos que faltan:"
L["READINESS_DAMAGED_GEAR"] = "Equipo dañado:"
L["READINESS_CHARACTER"] = "Personaje:"
L["READINESS_QUESTIONABLE_GEAR"] = "Equipo no apto para combate:"

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
L["READINESS_FLASK"] = "Frasco o 2x elixires"
L["READINESS_WELL_FED"] = "Bien alimentado"
L["READINESS_PET_WELL_FED"] = "Bien alimentado (mascota)"
L["READINESS_SCROLLS"] = "Pergaminos"
L["READINESS_SOULSTONE"] = "Piedra de alma inactiva"
L["READINESS_MAIN_HAND"] = "Mano derecha"
L["READINESS_OFF_HAND"] = "Mano izquierda"
L["READINESS_HEALTHSTONE"] = "Piedra de salud"
L["READINESS_MANA_GEM"] = "Gema de maná"
L["READINESS_HEALING_POTION"] = "Poción de sanación"
L["READINESS_MANA_POTION"] = "Poción de maná"
L["READINESS_BANDAGES"] = "Vendas"
L["READINESS_PVP_ON"] = "¡JcJ activado!"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s menos de 1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 punto de talento sin gastar"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d puntos de talento sin gastar"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Actualmente no tienes ninguna comida útil para tu mascota."
L["TIP_PET_NO_SKILLS"] =
	"Actualmente no conoces Llamar a mascota, Retirar mascota, Alimentar mascota o Revivir mascota."
L["TIP_PET_NO_MEND"] = "Actualmente no conoces Aliviar mascota."
L["TIP_NO_HAND_POISON"] = "Te has quedado sin el veneno elegido para esta arma."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Actualmente no conoces %s."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "Comida con beneficio"
L["MENU_BUFF_FOOD_DESCRIPTION"] = 'Prioriza la comida que otorga el beneficio "Bien alimentado" cuando te falta.'
L["FEATURE_SCROLL_BUFFS"] = "Beneficios de pergaminos"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] =
	"Aplica con tu macro de Comida los beneficios de pergaminos que te faltan antes de comer."

--[[
    Item titles in the mini-map tooltip. A title sits alone on its row and its
    item is right-aligned on the row beneath, so neither has to stay short;
    with nothing to show, MESSAGE_NO_ITEM takes the item's row. Current Pet
    Food opens the Attention Hunters block, and the two poison titles open the
    Attention Rogues block.
]]
L["MINIMAP_BEST_FOOD"] = "Comida actual"
L["MINIMAP_BEST_PET_FOOD"] = "Comida de mascota actual"
L["MINIMAP_MAIN_HAND_POISON"] = "Veneno de mano derecha"
L["MINIMAP_OFF_HAND_POISON"] = "Veneno de mano izquierda"

-- The Ignore List block. The count stands in for a list too long to show, so it is never one and needs no singular.
L["MINIMAP_IGNORE_LIST"] = "Lista de ignorados"
L["MINIMAP_IGNORE_COUNT"] = "%d objetos"
L["MENU_IGNORE"] = "Ignorar"
L["MENU_CLEAR_IGNORE"] = "Borrar lista de ignorados"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Informe de Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d pedidos pendientes"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "¡Felicidades, lo tienes todo abastecido!"
L["MINIMAP_RESTOCKER_EMPTY"] = "Tu lista está vacía."

--[[
    The Restocker List block, above the class notes: its title, a line saying
    what the list is for, and its click, which sits beside MINIMAP_OPEN. "Your
    list" in the description and in MINIMAP_RESTOCKER_EMPTY is this list. The
    Options entry is always the tooltip's last block and has no action label.
]]
L["MENU_RESTOCKER"] = "Lista de Restocker"
L["MENU_RESTOCKER_DESCRIPTION"] = "Compra y guarda en el banco los objetos de tu lista."
L["MENU_RESTOCKER_KEYBIND"] = "Mayús + Clic derecho"
L["MENU_OPTIONS"] = "Opciones de Connoisseur"
L["MENU_OPTIONS_KEYBIND"] = "Mayús + Clic central"

--------------------------------------------------------------------------------
-- Class Notes
--------------------------------------------------------------------------------

--[[
    The class block of the mini-map tooltip: a class-colored header, the items
    the class's own macro will use (a Hunter's pet food, a Rogue's two poisons,
    titled in the Minimap Tooltip section above), then one group per macro.
]]

L["PREFIX_HUNTER"] = "Atención, cazadores"
L["PREFIX_MAGE"] = "Atención, magos"
L["PREFIX_ROGUE"] = "Atención, pícaros"
L["PREFIX_WARLOCK"] = "Atención, brujos"

--[[
    A group is the macro's name, then one row per click: the click on the left
    and what it does on the right. The right-hand column never wraps, so each
    result stays a few words. A spell the row casts is named by the client
    (Mend Pet, Ritual of Refreshment, Ritual of Souls) and has no key here, and
    a plain click reuses MINIMAP_LEFT_CLICK, MINIMAP_RIGHT_CLICK or
    MINIMAP_MIDDLE_CLICK.
]]
L["NOTE_MACRO_FEED_PET"] = "Macro de Alim. mascota"
L["NOTE_MACRO_FOOD_WATER"] = "Macros de Comida y Agua"
L["NOTE_MACRO_MANA_GEM"] = "Macro de Gema de maná"
L["NOTE_MACRO_HEALTHSTONE"] = "Macro de Piedra"
L["NOTE_MACRO_SOULSTONE"] = "Macro de Piedra de alma"
L["NOTE_MACRO_POISONS"] = "Macro de Venenos"

-- Hunter. NOTE_PET_MEND_CLICK is the click that casts Mend Pet: a Right-Click, or any click during combat.
L["NOTE_PET_CALL_FEED_REVIVE"] = "Llamar, alimentar o revivir"
L["NOTE_PET_MEND_CLICK"] = "Clic derecho o en combate"
L["NOTE_HOLD_SHIFT"] = "Mantén Mayús"
L["NOTE_PET_FORCE_REVIVE"] = "Forzar revivir"
L["NOTE_HOLD_CONTROL"] = "Mantén Ctrl"
L["NOTE_PET_DISMISS"] = "Retirar"

--[[
    Mage and Warlock. The verb tracks the real spell names, which differ by
    class: mages Conjure, warlocks Create. A second Right-Click makes the next
    rank down, since the bags hold one of each rank.

    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone, so each line closes
    the group it belongs to. "One" in the warlock's line is a Healthstone.
]]
L["NOTE_CONJURE"] = "Crear"
L["NOTE_CREATE"] = "Crear"
L["NOTE_RIGHT_CLICK_AGAIN"] = "Otro clic derecho"
L["NOTE_LOWER_RANK_BACKUP"] = "Respaldo de rango inferior"
L["NOTE_MAGE_TARGET_LEVEL"] = "Selecciona a un jugador de menor nivel para crear lo adecuado a su nivel."
L["NOTE_WARLOCK_TARGET_LEVEL"] = "Selecciona a un jugador de menor nivel para crear una adecuada a su nivel."

-- Rogue. The two hands are the results of a Left-Click and a Right-Click on the Poisons macro.
L["MINIMAP_MAIN_HAND"] = "Mano derecha"
L["MINIMAP_OFF_HAND"] = "Mano izquierda"
L["NOTE_POISONS_WINDOW"] = "Ventana de Venenos"
L["NOTE_POISONS_REPLACED"] = "Reemplaza automáticamente los venenos anteriores."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the staples pop-up's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Venda"
L["LABEL_EXPLOSIVE"] = "Explosivo"
L["LABEL_FOOD"] = "Comida"
L["LABEL_HEALTH_POTION"] = "Poción de salud"
L["LABEL_HEALTHSTONE"] = "Piedra de salud"
L["LABEL_MANA_GEM"] = "Gema de maná"
L["LABEL_MANA_POTION"] = "Poción de maná"
L["LABEL_PET_FOOD"] = "Comida de mascota"
L["LABEL_POISONS"] = "Veneno"
L["LABEL_SOULSTONE"] = "Piedra de alma"
L["LABEL_WATER"] = "Agua"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Activado"
L["MINIMAP_DISABLED"] = "Desactivado"
L["MINIMAP_TOGGLE"] = "Alternar"
L["MINIMAP_OPEN"] = "Abrir"
L["MINIMAP_LEFT_CLICK"] = "Clic izquierdo"
L["MINIMAP_RIGHT_CLICK"] = "Clic derecho"
L["MINIMAP_MIDDLE_CLICK"] = "Clic central"
L["MINIMAP_SHIFT_LEFT"] = "Mayús + Clic izquierdo"

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
	'Elige cuándo tu macro de Comida ofrece "%s": siempre, o únicamente en solitario, en grupo o banda, en banda, mientras subes de nivel o al nivel máximo.'
L["MODE_ALWAYS"] = "Siempre"
L["MODE_SOLO"] = "En solitario"
L["MODE_PARTY"] = "En grupo o banda"
L["MODE_RAID"] = "En banda"
L["MODE_LEVELING"] = "Subiendo de nivel"
L["MODE_MAX_LEVEL"] = "Al nivel máximo"

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
L["INVENTORY_REPORT_TITLE"] = "Informe de inventario"
L["INVENTORY_REPORT_BAGS"] = "Bolsas"
L["INVENTORY_REPORT_BANK"] = "Banco"
-- In place of the Bank count, muted, until this character's bank has been opened once with the add-on running.
L["INVENTORY_REPORT_BANK_UNKNOWN"] = "Desconocido"
-- Everything above it added up: this character and every other one on the realm.
L["INVENTORY_REPORT_TOTAL"] = "Total"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Macros que usan automáticamente tu mejor comida, agua, pociones, piedras de salud, vendas, venenos y comida de mascota, además de una lista de reabastecimiento que compra automáticamente tus consumibles, los guarda en el banco y los mejora conforme subes de nivel. Automatización de calidad de vida para un rendimiento máximo."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Activar mensaje de bienvenida"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Muestra un mensaje de bienvenida en el chat al iniciar sesión."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Activar botón del minimapa"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Muestra el botón del minimapa."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Abre la interfaz de opciones de este accesorio."
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Abre tu lista de reabastecimiento."

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "Comentarios y soporte"
L["DISCORD"] = "Discord"
L["GITHUB"] = "GitHub"
L["CURSEFORGE"] = "CurseForge"
L["WAGO"] = "Wago"
L["OPTIONS_VERSION"] = "Versión %s"

--[[
    Macros panel. TAB_MACROS is the panel's label in the settings tree and the
    title on the page; OPTIONS_MACROS_DESCRIPTION is the intro beneath it, which
    orients the player to the page's two halves -- which macros exist, then how
    each one behaves. The Enable Macros header below titles the first section,
    after the page's one headerless toggle, Macro Names on Buttons.
]]
L["TAB_MACROS"] = "Macros"
L["OPTIONS_MACROS_DESCRIPTION"] =
	"Connoisseur crea una macro por consumible y la mantiene al día conforme cambian tus bolsas, de modo que el botón de tu barra siempre busca el mejor objeto que llevas encima. Elige abajo qué macros crear y luego ajusta cómo elige su objeto cada una."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Activar nombres de macro en los botones"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Muestra el nombre de la macro en los botones de tu barra de acción, un texto que Connoisseur oculta por defecto."

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "Activar macros"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Elige qué macros crea y mantiene Connoisseur. Al desactivar una, también se elimina."
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Crea y mantiene esta macro, y la elimina al desmarcar la casilla."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Comida y agua"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Tus macros de Comida y Agua usan la mejor comida y bebida de tus bolsas. Estas opciones pueden poner primero la comida con beneficio, los pergaminos o la comida y el agua mágicas."

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Priorizar comida con beneficio"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'Prioriza la comida que otorga el beneficio "Bien alimentado" cuando te falta, excepto en las Arenas.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Activar beneficios de pergaminos"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Tu macro de Comida aplica los pergaminos que faltan con la primera pulsación y come con la siguiente; omite los pergaminos si seleccionas a un jugador amistoso o estás en una Arena."
L["OPTIONS_SCROLL_TYPES"] = "Incluir tipos de pergaminos en la comprobación"
L["OPTIONS_SCROLL_AGILITY"] = "Agilidad"
L["OPTIONS_SCROLL_INTELLECT"] = "Intelecto"
L["OPTIONS_SCROLL_PROTECTION"] = "Protección"
L["OPTIONS_SCROLL_SPIRIT"] = "Espíritu"
L["OPTIONS_SCROLL_STAMINA"] = "Aguante"
L["OPTIONS_SCROLL_STRENGTH"] = "Fuerza"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = "Incluye %s al comprobar los beneficios que faltan."

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Usar primero la comida y el agua mágicas"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Tus macros de Comida y Agua usan la comida y el agua mágicas antes que cualquier otra cosa, aunque algo de tus bolsas restaure más, ya que no cuestan nada y desaparecen poco después de cerrar sesión. La comida con beneficio sigue yendo primero mientras "Priorizar comida con beneficio" esté activado.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Elige cuándo la comida y el agua mágicas van primero: siempre, o únicamente en solitario, en grupo o banda, en banda, mientras subes de nivel o al nivel máximo."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Pociones y Piedras de salud"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Las macros no pueden cambiar durante el combate (es una restricción de Blizzard), por lo que cada macro de Poción y Piedra de salud se crea previamente con tu mejor objeto más hasta dos alternativas. En combates largos, el icono y la descripción pueden quedar obsoletos y mostrar un objeto equivocado, pero al hacer clic en la macro siempre se usará el mejor objeto que realmente tengas en tus bolsas."
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER"] = "Usar comida y agua en las macros de Poción fuera de combate"
L["OPTIONS_POTIONS_USE_FOOD_AND_WATER_DESCRIPTION"] =
	"Fuera de combate, tu macro de Poción de salud come tu mejor comida y tu macro de Poción de maná bebe tu mejor agua. En combate, usan tus pociones como siempre. Los pergaminos, la comida de mascota y los hechizos de creación siguen en las macros de Comida y Agua."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combinar Piedras de salud en la macro de Poción de salud"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Añade tu mejor Piedra de salud al final de la macro de Poción de salud, para que al presionar una vez se use una poción y una Piedra de salud."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemas de maná y runas"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"Las Runas demoníacas, las Runas oscuras y algunos otros objetos de maná comparten tiempo de reutilización con las Gemas de maná. Las runas cuestan salud al usarlas, así que la macro de Gema de maná los deja fuera a todos a menos que los añadas."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Añadir runas y otros objetos de maná a la macro de Gema de maná"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"Clasifica tus Runas demoníacas y oscuras, y cualquier otro objeto de maná que comparta tiempo de reutilización con las Gemas de maná, junto a tus gemas, para que la macro de Gema de maná use uno de ellos cuando sea tu mejor opción o cuando te quedes sin gemas."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Renovación de beneficios"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Las macros no pueden cambiar durante el combate, así que si un beneficio expira en pleno combate, seguirás sin él hasta que el combate termine."
L["OPTIONS_REAPPLY"] = "Renovar beneficios a punto de expirar"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Considera expirados Comida con beneficio, Beneficios de pergaminos y Beneficios de comida de mascota cuando les quede menos tiempo que tu umbral, para que tus macros ofrezcan uno nuevo antes del combate."
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Define cuánto puede acercarse un beneficio a expirar antes de que tus macros ofrezcan uno nuevo."
L["REAPPLY_THRESHOLD_ONE"] = "Cuando quede < 1 minuto"
L["REAPPLY_THRESHOLD_MANY"] = "Cuando queden < %d minutos"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Beneficios de comida de mascota"
L["OPTIONS_PET_SECTION_DESCRIPTION"] = 'Algunas comidas dan a tu mascota su propio beneficio "Bien alimentado".'
L["OPTIONS_USE_PET_BUFFS"] = "Usar beneficios de comida de mascota"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	'Añade comida de mascota a tu macro de Comida cuando a tu mascota le falta el beneficio "Bien alimentado", excepto en las Arenas.'
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Incluir tipos de comida de mascota en la comprobación"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Explosivos"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"La opción @player omite la retícula de selección y detona el explosivo justo a tus pies. Ideal cuando tu objetivo está a distancia cuerpo a cuerpo. Tu otro clic lanza el explosivo como siempre."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Asignación de clics"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] = "Elige qué clic lanza el explosivo y cuál lo detona a tus pies."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clic izquierdo @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clic izquierdo Lanzar"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "Druidas"
L["OPTIONS_DRUID_MACRO_HELPER"] = "Activar integración con DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Crea macros de cambio de forma para pociones de salud, pociones de maná y piedras de salud usando DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Elige la forma a la que te devuelven tus macros de cambio de forma después de usar el objeto."
L["DRUID_FORM_BEAR"] = "Volver a Oso"
L["DRUID_FORM_CAT"] = "Volver a Gato"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "Pícaros"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Mantiene la macro de Venenos cargada con el mejor rango utilizable de cada tipo de veneno: clic izquierdo aplica a tu mano izquierda, clic derecho a tu mano derecha, y los venenos existentes se reemplazan automáticamente."
L["OPTIONS_POISON_MAIN_HAND"] = "Tipo de veneno de mano derecha"
L["OPTIONS_POISON_OFF_HAND"] = "Tipo de veneno de mano izquierda"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Elige el veneno que tu macro de Venenos aplica a tu mano derecha con clic derecho."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Elige el veneno que tu macro de Venenos aplica a tu mano izquierda con clic izquierdo."
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "Activar sigilo al comer"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] =
	"Añade Sigilo a tu macro de Comida para entrar en sigilo mientras comes."

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "Elfos de la noche"
L["OPTIONS_STEALTH_DRINKING"] = "Activar sigilo al beber"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] =
	"Añade Fusión de las Sombras a tu macro de Agua para entrar en sigilo mientras bebes."
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] =
	"Añade Fusión de las Sombras a tu macro de Comida para entrar en sigilo mientras comes."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Consejo experto: Elige uno. Puedes comer y beber a la vez, pero comer o beber después de entrar en sigilo lo romperá."

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
L["TAB_IGNORE_LIST"] = "Lista de ignorados"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Ninguna macro elige nunca los objetos ignorados. Comida, agua, pociones, lo que sea. La lista Global se aplica a todos los personajes; la de un personaje, solo a ese. Haz clic derecho en el botón del minimapa para ignorar tu mejor comida actual."
L["OPTIONS_IGNORE_GLOBAL"] = "Global"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Mueve este objeto a la lista Global, para que se ignore en todos los personajes."
L["OPTIONS_IGNORE_ADD_ID"] = "Añadir por ID de objeto"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Escribe un ID de objeto, o haz Mayús + Clic en un enlace de objeto del chat mientras este campo está activo."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "Escribe un ID de objeto, o haz Mayús + Clic en un enlace de objeto del chat."
L["OPTIONS_IGNORE_REMOVE"] = "Quitar"
L["OPTIONS_IGNORE_EMPTY"] = "Esta lista está vacía."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Cargando ID: %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Mantiene tus bolsas abastecidas según tu lista de reabastecimiento, comprando a los mercaderes y moviendo objetos desde y hacia el banco automáticamente. Escribe %s para abrir la lista."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Abrir en el banco"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Abre tu lista de reabastecimiento al visitar el banco."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Abrir con el mercader"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Abre tu lista de reabastecimiento al visitar a un mercader."
L["OPTIONS_RESTOCKER_REMIND"] = "Activar recordatorios de reabastecimiento en la ciudad"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Muestra un recordatorio en el chat cuando a tu lista de reabastecimiento le falta algo y llegas a una posada o una ciudad, o ya estás en una al iniciar sesión."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Activar recordatorios de reabastecimiento en el mercader"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Informa de cualquier pedido de reabastecimiento pendiente al cerrar la ventana de un mercader."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Activar recordatorios de reabastecimiento en el banco"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Informa de cualquier pedido de reabastecimiento pendiente al cerrar el banco."
L["OPTIONS_RESTOCKER_GOLD_RESERVE"] = "Activar reserva de oro"
L["OPTIONS_RESTOCKER_GOLD_RESERVE_DESCRIPTION"] = "El reabastecimiento nunca gasta el oro que apartes aquí."
L["OPTIONS_RESTOCKER_GOLD_RESERVE_AMOUNT_DESCRIPTION"] = "Cuánto oro te deja siempre el reabastecimiento."

--[[
    The staples pop-up (STARTER_POPUP_TITLE below). This toggle and the
    pop-up's own "Don't Show This Again" box are the same per-character choice
    read from opposite ends, which is why one ships on and the other off: a
    settings row reads naturally as "enable", a dismissal reads naturally as
    "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] =
	"Activar la ventana emergente de básicos cuando la lista de reabastecimiento esté vacía"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"Ofrece los básicos de tu clase al iniciar sesión siempre que la lista de reabastecimiento de este personaje esté vacía."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Elige si el recordatorio es una sola línea o añade una línea por cada objeto que te falta."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Simple"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Detallado"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Reproducir sonido"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Reproduce un aviso junto al recordatorio, para cuando el chat está muy movido."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Haz clic para oír el aviso."

L["OPTIONS_RESTOCKER_REMINDERS_HEADER"] = "Recordatorios"
L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Ventana de la lista de reabastecimiento"
L["OPTIONS_RESTOCKER_WINDOW_DESCRIPTION"] = "Elige cuándo se abre sola tu lista de reabastecimiento."

--[[
    The Inventory Report's switch, under a header that is the report's own
    title (INVENTORY_REPORT_TITLE, in the Inventory Report section above).
]]
L["OPTIONS_INVENTORY_REPORT_SECTION_DESCRIPTION"] =
	"Muestra en la descripción de un objeto cuántas unidades tienes entre todos tus personajes de este reino."
L["OPTIONS_INVENTORY_REPORT"] = "Activar el informe de inventario en las descripciones de objetos"
L["OPTIONS_INVENTORY_REPORT_DESCRIPTION"] =
	"Añade a la descripción de un objeto cuántas unidades tienes en tus bolsas, en tu banco y en tus otros personajes. Desactívalo si otro accesorio ya muestra estos recuentos."

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Agradecimientos"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"Siempre me ha encantado Restocker, y agradezco la oportunidad de que siga vivo dentro de Connoisseur. Muchísimas gracias a ChiliFajita, que escribió el Auto Restocker original, y a kvakvs y guardycmw, que lo mantuvieron con vida a lo largo de Classic y Mists of Pandaria."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Informe de preparación"
L["OPTIONS_READINESS_ENABLE"] = "Activar el informe de preparación al comprobar quiénes están listos"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] =
	"Activa el informe de preparación para todos los personajes de esta cuenta."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Cuando empieza una comprobación de quiénes están listos, muestra una lista privada de lo que aún falta por arreglar, y no dice nada en absoluto si estás preparado."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the active profile, so nothing else on any panel can return them to
    their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Restablecer ajustes del informe de preparación"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Restablece a sus valores por defecto todas las casillas y ambos umbrales de esta página, sin tocar las demás páginas."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"¿Restablecer todos los ajustes del informe de preparación a sus valores por defecto? Esto también vuelve a desactivar el propio informe."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Beneficios que faltan"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Objetos que faltan"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personaje"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Avisa si te falta un frasco. Un frasco, o un elixir de batalla y un elixir guardián, cuenta como cubierto."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	'Avisa si te falta el beneficio "Bien alimentado". Requiere activar Comida con beneficio en Macros.'
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	'Avisa si a tu mascota le falta el beneficio "Bien alimentado". Requiere activar Beneficios de comida de mascota en Macros, y tener una mascota invocada.'
L["OPTIONS_READINESS_SCROLLS"] = "Beneficios de pergaminos"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Avisa si te faltan beneficios de pergaminos. Requiere activar Beneficios de pergaminos en Macros, y solo comprueba los tipos de pergamino seleccionados allí."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Avisa cuando nadie de tu grupo tiene una Piedra de alma activa; una guardada en una bolsa no cuenta. Solo se muestra a los brujos que pueden crearla."
L["OPTIONS_READINESS_MAIN_HAND"] = "Beneficio de arma (mano derecha)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Avisa si el arma de tu mano derecha no tiene un encantamiento temporal. Cuenta cualquier encantamiento, y guarda silencio cuando hay un chamán en tu grupo."
L["OPTIONS_READINESS_OFF_HAND"] = "Beneficio de arma (mano izquierda)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Avisa si el arma de tu mano izquierda no tiene un encantamiento temporal. Cuenta cualquier encantamiento: una piedra, un aceite, un veneno o un beneficio de arma de chamán."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Beneficios que expiran en menos de"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"Nombra todos los beneficios que tienes a punto de expirar, no solo los que aplica Connoisseur, y es independiente de Renovación de beneficios en Macros."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minutos"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minuto"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Define cuánto debe acercarse un beneficio a expirar para que el informe lo nombre."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna Piedra de salud. Solo se muestra cuando hay un brujo en tu grupo al que pedirla, o cuando el brujo eres tú."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna Gema de maná. Solo se muestra a los magos que pueden crearla."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna poción de sanación, ya que nadie puede darte una en plena pelea."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna poción de maná. Solo se muestra cuando juegas con una clase que usa maná."
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] =
	"Avisa cuando no llevas ninguna venda que tu habilidad de Primeros auxilios te permita usar."
L["OPTIONS_READINESS_DURABILITY"] = "Equipo dañado por debajo de"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Enlaza cada objeto equipado por debajo de esta durabilidad, medida por objeto para que un arma rota siga apareciendo."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Define cuánto debe bajar la durabilidad de un objeto para que el informe lo enlace."

-- Character
L["OPTIONS_READINESS_SPEC"] = "Especialización actual"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] = "Muestra tu reparto de talentos y los puntos que no hayas gastado."
L["OPTIONS_READINESS_PVP"] = "Marca JcJ activada"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avisa cuando tu marca JcJ está activa."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Equipo no apto para combate"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"Enlaza los objetos equipados que no tienen cabida en un combate, como una Fusta o una caña de pescar."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Ya existe una lista llamada "%s".'
--[[
    %d is the item ID the player typed. Written into the add box itself while
    the window is open, so it shares that box's width with
    RESTOCKER_ADD_PLACEHOLDER and has to stay as short; printed to chat when the
    window is closed.
]]
L["RESTOCKER_UNKNOWN_ITEM"] = "El ID %d no existe."
L["RESTOCKER_BANK_NOT_OPEN"] = "El banco no está abierto."
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Reabastecimiento completado. Mantén Mayús al abrir el banco para omitir el reabastecimiento. Escribe %s para editar tu lista de reabastecimiento."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Reabastecimiento detenido. Tus bolsas y tu banco están llenos."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Reabastecimiento detenido. Tu banco está lleno; libera un espacio y vuelve a abrirlo."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Reabastecimiento detenido. Tus bolsas están llenas; libera un espacio y vuelve a abrir el banco."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Reabastecimiento detenido. No se pudo avanzar."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Reabastecimiento detenido. No se pudo mover: %s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (sobrante)"
L["RESTOCKER_STOPPED_ERROR"] = "Reabastecimiento detenido por un error: %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Este mercader no tiene todos los ingredientes que necesitan tus venenos. No se comprará ninguno."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "¡No olvides reabastecerte ahora que estás en la ciudad!"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 pedido de reabastecimiento pendiente."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d pedidos de reabastecimiento pendientes."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Tu lista de reabastecimiento se ha mejorado."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d pasa a %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 pedido de reabastecimiento completado."
L["RESTOCKER_RESTOCKED_MANY"] = "%d pedidos de reabastecimiento completados."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 pedido de reabastecimiento completado en parte."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d pedidos de reabastecimiento completados en parte."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Tus bolsas se llenaron antes de poder comprarlo todo."
L["RESTOCKER_OUT_OF_GOLD"] = "No tienes oro suficiente para terminar el reabastecimiento."
L["RESTOCKER_OUT_OF_GOLD_RESERVE"] =
	"Reabastecimiento en pausa; no hay oro suficiente. Se reanudará cuando pueda completar tus órdenes de compra sin tocar tu reserva (%s)."

-- /crs help lines. The command literals stay in code; these are the descriptions, and the show line reuses RESTOCKER_COMMAND_DESCRIPTION.
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nombre]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Añade una lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Elimina la lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renombra la lista actual a ese nombre."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Reemplaza la lista actual por una copia de la lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_USE"] = "Hace que este personaje use la lista con ese nombre."

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
L["STARTER_POPUP_TITLE"] = "Básicos de Connoisseur"
L["STARTER_POPUP_INTRO_EMPTY"] =
	"Tu lista de reabastecimiento está vacía, así que vamos a añadir algunos objetos para empezar."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] = "Elige los básicos que quieres mantener abastecidos."
L["STARTER_POPUP_INTRO_HOW"] =
	"Todo lo que marques se reabastece automáticamente cada vez que visitas a un mercader o tu banco. Los consumibles comunes se mejoran solos según subes de nivel, así que siempre tendrás lo mejor disponible."
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Siempre puedes ajustar esta lista, o añadir más objetos más adelante, escribiendo %s."
--[[
    The first section's heading names the Water row that closes its grid as
    well; the food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Comida y agua"
L["STARTER_POPUP_FOOD_HEADER"] = "Comida"
L["STARTER_POPUP_AMMO_HEADER"] = "Munición"
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
L["STARTER_POPUP_REAGENTS_HEADER"] = "Componentes y herramientas"
L["STARTER_POPUP_POISONS_HEADER"] = "Venenos"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Añade el veneno terminado a tu lista y Connoisseur comprará los ingredientes automáticamente en cualquier mercader que los venda todos."
--[[
    Checkbox tooltips: { item name, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Añade %s a tu lista de reabastecimiento, manteniendo %d en tus bolsas y mejorándolos según subes de nivel."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] = "Añade %s a tu lista de reabastecimiento y mantiene %d en tus bolsas."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 montón"
L["STARTER_POPUP_STACK_MANY"] = "%d montones"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Cuántos montones mantener abastecidos, a razón de %d por montón."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Cuántos mantener abastecidos, cada uno en su propio espacio de la bolsa, ya que no se apilan."
L["STARTER_POPUP_DISMISS"] = "No volver a mostrar esto en este personaje"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] =
	"Evita que estas sugerencias vuelvan a aparecer al iniciar sesión con tu lista de reabastecimiento vacía."

-- Restock List window UI. The title names what the window holds; the feature that acts on it stays "Restocker".
L["RESTOCKER_WINDOW_TITLE"] = "Lista de reabastecimiento de Connoisseur"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtrar objetos..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Borrar"
L["RESTOCKER_ADD_BUTTON"] = "Añadir"
--[[
    The button that opens the staples pop-up over the window, on the control
    row and on an empty list, and its tooltip. The keys keep the pop-up's
    earlier name, the List Builder. "Check" is the pop-up's own word
    (STARTER_POPUP_INTRO_HOW).
]]
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "Elegir básicos"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"Elige entre los básicos de tu clase y nivel: comida, agua, munición, venenos y componentes. Al marcar uno se añade a esta lista, y al desmarcarlo se quita."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Añadir un objeto"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Suelta un objeto de tus bolsas aquí o en cualquier parte de esta ventana, o escribe un ID de objeto y pulsa Intro."
--[[
    In-box placeholder for the add box; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: the box shares its row with two
    other fields and is sized to this English hint, so a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Suelta objeto o escribe ID"
--[[
    Written into the add box, in place of the placeholder above, when what was
    typed is neither an item ID nor an item the client can place by name. Same
    width budget as the placeholder. RESTOCKER_UNKNOWN_ITEM, for an ID with no
    item behind it, shows the same way.
]]
L["RESTOCKER_ADD_NOT_FOUND"] = "Escribe el ID del objeto."
--[[
    The bag menu on the control row, between the filter and the add box. The
    caption is all the closed menu shows and is its tooltip's title; it has
    room for about 24 characters, and a longer one is cut off. NONE is the one
    line the open menu holds when the bags have nothing the list lacks. Title
    case and no terminal punctuation for both, like every menu entry.
]]
L["RESTOCKER_ADD_FROM_BAGS"] = "Añadir desde tus bolsas"
L["RESTOCKER_ADD_FROM_BAGS_TOOLTIP"] =
	"Todos los objetos de tus bolsas que aún no están en esta lista. Haz clic en uno para añadirlo."
L["RESTOCKER_ADD_FROM_BAGS_NONE"] = "Nada en tus bolsas que añadir"

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
	"Haz clic para que este personaje use otra lista de reabastecimiento, o para empezar una nueva."
L["RESTOCKER_USED_BY"] = "Usada por %s"
L["RESTOCKER_MANAGE"] = "Gestionar listas"
L["RESTOCKER_MANAGE_TOOLTIP"] = "Empieza una lista nueva, o copia, renombra o elimina esta."
--[[
    The Manage Lists menu, top to bottom. Menu entries take title case and no
    terminal punctuation, like every title in the window. New List is also the
    last entry on the selector's own menu. The Copy and Delete keys end in
    _TOOLTIP because they began as the tooltips of two buttons this menu
    replaced.
]]
L["RESTOCKER_NEW_PROFILE"] = "Lista nueva"
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "Copiar esta lista en una nueva"
L["RESTOCKER_RENAME_PROFILE"] = "Renombrar esta lista"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "Eliminar esta lista"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - copia"
-- The button that commits a rename, beside the field Rename This List opens, and that button's tooltip.
L["RESTOCKER_RENAME_LABEL"] = "Renombrar"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renombra esta lista para todos los personajes que la usan."
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
L["RESTOCKER_DELETE_LIST_QUESTION"] = "¿Seguro que quieres eliminar esta lista?"
L["RESTOCKER_DELETE_LIST_SHARED_ONE"] =
	"%s también la usa y, al iniciar sesión, encontrará una lista vacía con el mismo nombre."
L["RESTOCKER_DELETE_LIST_SHARED_MANY"] =
	"%s también la usan y, al iniciar sesión, cada uno encontrará una lista vacía con el mismo nombre."
L["RESTOCKER_DELETE_LIST_SWITCH"] = "Pasarás a usar %s."
L["RESTOCKER_DELETE_LIST_LAST"] = "Es la única lista que queda, así que empezarás con una nueva y vacía."
L["RESTOCKER_DELETE_LIST_FINAL"] = "Esto no se puede deshacer."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Mejorar al subir de nivel"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permite que Connoisseur mejore la comida, el agua, la munición, los venenos, las pociones y los componentes de clase a objetos mejores según subes de nivel."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Banco"
L["RESTOCKER_ROW_MERCHANT"] = "Mercader"
L["RESTOCKER_ROW_UPGRADE"] = "Mejora"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Objeto"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Sacar"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Guardar"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rep."
--[[
    The row's target, beside the item's name: how many the list keeps in the
    bags. "Keep" rather than "Amount" because the number is a standing target,
    not a quantity to buy, and because 0 then reads as what it does -- keep
    none, which with Store on sends the whole stock to the bank. The keys, the
    code and the saved rows still call it the amount.
]]
L["RESTOCKER_COLUMN_AMOUNT"] = "Mantener"

--[[
    A toggle column's heading sets the column for every item shown. HINT closes
    the heading's tooltip; ON and OFF are the two entries of the menu a click on
    the heading opens, where %d is how many of the items shown the column can be
    set on. Menu entries: title case, no terminal punctuation.
]]
L["RESTOCKER_COLUMN_BULK_HINT"] = "Haz clic en el encabezado para ajustarlo en todos los objetos mostrados."
L["RESTOCKER_BULK_ON"] = "Activar en los mostrados (%d)"
L["RESTOCKER_BULK_OFF"] = "Desactivar en los mostrados (%d)"

L["RESTOCKER_GROUP_OTHER"] = "Otros"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Nuevos"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Todos los objetos"
--[[
    What the list area shows in place of rows. EMPTY_ is a list with nothing on
    it: a heading (title case), a body of two sentences (the two ways to add,
    then what the list does with what is on it), the Pick Staples button
    (RESTOCKER_LIST_BUILDER_BUTTON), and a hint under it. NO_MATCH_ is one line
    for a list that has items and is showing none: the filter matches nothing,
    or the selected category just lost its last item.
]]
L["RESTOCKER_EMPTY_TITLE"] = "Aún no hay nada en esta lista"
L["RESTOCKER_EMPTY_BODY"] =
	"Selecciona básicos como comida, agua o componentes de clase, o añade cualquier cosa de tus bolsas con el menú de arriba. Los objetos seleccionados se mantienen abastecidos o se guardan en tu banco automáticamente, para que tus bolsas queden despejadas."
L["RESTOCKER_EMPTY_DROP_HINT"] = "Soltar un objeto en cualquier parte de esta ventana también lo añade."
L["RESTOCKER_NO_MATCH_FILTER"] = "Nada de esta lista coincide con tu filtro."
L["RESTOCKER_NO_MATCH_GROUP"] = "No queda nada en esta categoría."

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
L["RESTOCKER_NO_ORDERS"] = "No hay pedidos de reabastecimiento pendientes."
L["RESTOCKER_REPORT_MORE"] = "y %d más"
L["RESTOCKER_REMOVED_ITEM"] = "Se quitó %s."
L["RESTOCKER_UNDO"] = "Deshacer"
L["RESTOCKER_UNDO_TOOLTIP"] = "Devolver este objeto a la lista"

-- Title slot: title case, no terminal period. The line under it is body text.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Quitar este objeto de la lista de reabastecimiento"
L["RESTOCKER_REMOVE_TOOLTIP_UNDO"] = "Puedes deshacerlo desde la parte inferior de la ventana."
--[[
    The Keep box and its heading, which share one tooltip: the title, and KEEP
    under it, which explains the number. There is no editing hint: the box
    saves as it is typed in, so nothing has to be pressed.
]]
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Mantener en tus bolsas"
L["RESTOCKER_AMOUNT_TOOLTIP_KEEP"] =
	"Cuántos mantener en tus bolsas. El número se muestra en amarillo mientras tus bolsas tengan menos, y 0 con Guardar activado lo envía todo al banco."
L["RESTOCKER_BUY_LABEL"] = "Comprar"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Comprar al mercader"
L["RESTOCKER_BUY_TOOLTIP_BODY"] =
	"Compra al mercader la cantidad necesaria cuando la ventana del mercader está abierta."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Comprar de más"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Compra todas las existencias limitadas que un mercader tenga de este objeto, esos pocos artículos que repone lentamente, incluso por encima de tu cifra de Mantener."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Guardar en el banco"
--[[
    Both this line and the Extra one above name the Keep column, so they are
    coupled to RESTOCKER_COLUMN_AMOUNT: a locale that renders that heading
    differently has to say the same word here, or the sentence points at a
    column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Guarda en el banco los objetos sobrantes cuando el banco está abierto, o todos ellos si pones 0 en la columna Mantener."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Sacar del banco"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Saca del banco los objetos necesarios cuando el banco está abierto."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Reputación requerida"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% de descuento)"
L["RESTOCKER_REPUTATION_ANY"] = "Cualquiera"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "Amistoso"
L["RESTOCKER_REPUTATION_HONORED"] = "Honorable"
L["RESTOCKER_REPUTATION_REVERED"] = "Venerado"
L["RESTOCKER_REPUTATION_EXALTED"] = "Exaltado"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Reputación requerida con el mercader"
--[[
    Quotes the cell's own values, which couples this line to the four standings
    above: a locale that renders a standing differently has to say so here too.
    With no standing required the cell draws a dash rather than the word "Any",
    which is why the last sentence names the dash; "Any" is still the menu's
    first entry.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	"Haz clic para elegir la reputación necesaria con un mercader antes de que Connoisseur le compre, lo que además rebaja el precio: Amistoso 5%, Honorable 10%, Venerado 15%, Exaltado 20%. Con un guion, compra a cualquier mercader."

--[[
    Why a cell cannot be set on its row: the tooltip a dimmed cell shows under
    its column's title, in place of the column's own explanation. Extra and
    Rep ride on Buy; Upgrade needs a ladder with somewhere to go, which a quest
    item lacks outright and the Hearthstone lacks for having one tier.
]]
L["RESTOCKER_EXTRA_NOT_APPLICABLE"] =
	"Comprar está desactivado para este objeto, así que no hay nada extra que comprar."
L["RESTOCKER_REPUTATION_NOT_APPLICABLE"] =
	"Comprar está desactivado para este objeto, así que no se aplica ninguna reputación."
L["RESTOCKER_UPGRADE_NOT_APPLICABLE"] = "Este objeto no tiene ninguna versión superior a la que mejorar."
