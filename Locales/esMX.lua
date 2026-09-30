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
L["MACRO_FOOD_AND_POTION"] = "- Comida/Poción"
L["MACRO_HEALTH_POTION"] = "- Poc. Salud"
L["MACRO_HEALTHSTONE"] = "- Piedra"
L["MACRO_MANA_GEM"] = "- Gema de maná"
L["MACRO_MANA_POTION"] = "- Poc. Maná"
L["MACRO_POISONS"] = "- Venenos"
L["MACRO_SOULSTONE"] = "- Piedra de alma"
L["MACRO_WATER"] = "- Agua"
L["MACRO_WATER_AND_POTION"] = "- Agua/Poción"

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
	"Convierte tu macro de Comida en un aplicador de pergaminos cuando te faltan beneficios de pergaminos."

-- Section titles and ignore-list actions in the mini-map tooltip.
L["MINIMAP_BEST_FOOD"] = "Comida actual"
L["MINIMAP_BEST_PET_FOOD"] = "Comida de mascota actual"
-- Weapon-slot titles beside the rogue's resolved poison, in the Attention Rogues block.
L["MINIMAP_MAIN_HAND"] = "Mano derecha"
L["MINIMAP_OFF_HAND"] = "Mano izquierda"
--[[
    The value shown beside an item title when nothing resolved. Kept to a single
    word so it fits in the tooltip's right column, which never wraps -- the full
    sentence, MESSAGE_NO_ITEM, explains it on the wrapping line underneath.
]]
L["MINIMAP_NONE"] = "Ninguno"
L["MINIMAP_IGNORE_LIST"] = "Lista de ignorados"
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
    row, on a wrapping line of its own, so it can be a full sentence.

    ITEM_COUNT is the right-hand value of a listed row: { have, wanted }, the
    ratio RESTOCKER_REMINDER_ITEM prints. Wordless, so there is nothing to
    translate, but a key anyway for the same reason that one is.
]]
L["MINIMAP_RESTOCKER_REPORT"] = "Informe de Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d pedidos pendientes"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "¡Felicidades, lo tienes todo abastecido!"

-- Options entry at the bottom of the mini-map tooltip.
L["MENU_OPTIONS"] = "Opciones de Connoisseur"
L["MENU_OPTIONS_KEYBIND"] = "Mayús + Clic central"

--------------------------------------------------------------------------------
-- Class Tips
--------------------------------------------------------------------------------

--[[
    Class-colored headers and click tips shown in the mini-map tooltip for the
    player's class.
]]

L["PREFIX_HUNTER"] = "Atención, cazadores"
L["PREFIX_MAGE"] = "Atención, magos"
L["PREFIX_ROGUE"] = "Atención, pícaros"
L["PREFIX_WARLOCK"] = "Atención, brujos"

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
L["TIP_HUNTER_MACROS"] = "Sobre tu macro de Alimentar mascota..."
L["TIP_MAGE_MACROS"] = "Sobre tus macros de Comida, Agua y Gema de maná..."
L["TIP_ROGUE_MACROS"] = "Sobre tu macro de Venenos..."
L["TIP_WARLOCK_MACROS"] = "Sobre tus macros de Piedra de salud y Piedra de alma..."

L["TIP_HUNTER_ALL_IN_ONE"] = "¡Alimentar mascota es un botón de mascota todo en uno!"
L["TIP_HUNTER_CALL"] = "Clic izquierdo para llamar, alimentar o revivir a tu mascota automáticamente."
L["TIP_HUNTER_MEND"] = "Clic derecho, o cualquier clic durante el combate, para lanzar Aliviar mascota."
L["TIP_HUNTER_MODIFIERS"] = "Mantén Mayús para forzar Revivir, o Ctrl para Retirar."

--[[
    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone. Mana Gems, Soulstones,
    and both rituals ignore the target (ignoreTarget in the resolvers), so each
    line names what it actually affects rather than saying "the macro."
]]
L["TIP_MAGE_CONJURE"] = "Clic derecho en tus macros de Comida o Agua para lanzar Crear comida o Crear agua."
L["TIP_MAGE_DOWNRANK"] = "Seleccionar a un jugador de menor nivel creará comida o agua apropiada para su nivel."
L["TIP_MAGE_TABLE"] = "Clic central en tus macros de Comida o Agua para lanzar Ritual de refrigerio."
L["TIP_MAGE_GEM"] =
	"Clic derecho en tu macro de Gema de maná para crear una nueva gema. Vuelve a hacer clic derecho para crear una gema de rango inferior como respaldo."

L["TIP_WARLOCK_HEALTHSTONE"] =
	"Clic derecho en tu macro de Piedra de salud para lanzar Crear piedra de salud. Vuelve a hacer clic derecho para crear otra de rango inferior como respaldo."
L["TIP_WARLOCK_DOWNRANK"] =
	"Seleccionar a un jugador de menor nivel creará una Piedra de salud apropiada para su nivel."
L["TIP_WARLOCK_SOULSTONE"] = "Clic derecho en tu macro de Piedra de alma para lanzar Crear piedra de alma."
L["TIP_WARLOCK_SOUL"] = "Clic central en tu macro de Piedra de salud para lanzar Ritual de almas."

L["TIP_ROGUE_OFF_HAND"] = "Clic izquierdo aplica el veneno de tu mano izquierda."
L["TIP_ROGUE_MAIN_HAND"] = "Clic derecho aplica el veneno de tu mano derecha."
L["TIP_ROGUE_REPLACE"] = "Los venenos existentes se reemplazan automáticamente."
L["TIP_ROGUE_WINDOW"] = "Clic central abre la ventana de Venenos."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the List Builder's Water checkbox.
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
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Macros que usan automáticamente tu mejor comida, comida con beneficio, agua, pociones, piedras de salud, vendas y pergaminos, además de una lista de reabastecimiento que mantiene tus bolsas llenas y mejora tus consumibles conforme subes de nivel. Automatización de calidad de vida para un rendimiento máximo."

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
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Abre la ventana de Restocker para gestionar tu lista de reabastecimiento."

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
    account-wide Global list, then the current character and every other
    character with something ignored. The rows are items, so the copy here is
    the panel description, the scope and promote labels, the add box, Remove,
    the empty-list line, and LOADING_ITEM, the placeholder shown while the
    client is still resolving an item's name (the mini-map tooltip, the Macros
    panel, and the List Builder use it too). The mini-map tooltip's section
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
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Abre la ventana de Restocker al visitar el banco."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Abrir con el mercader"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] = "Abre la ventana de Restocker al visitar a un mercader."
L["OPTIONS_RESTOCKER_REMIND"] = "Activar recordatorios de reabastecimiento en la ciudad"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Muestra un recordatorio en el chat cuando a tu lista de reabastecimiento le falta algo y llegas a una posada o una ciudad, o ya estás en una al iniciar sesión."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Activar recordatorios de reabastecimiento en el mercader"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Informa de cualquier pedido de reabastecimiento pendiente al cerrar la ventana de un mercader."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Activar recordatorios de reabastecimiento en el banco"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Informa de cualquier pedido de reabastecimiento pendiente al cerrar el banco."

--[[
    The Starter List Builder pop-up. This toggle and the pop-up's own "Don't
    Show This Again" box are the same per-character choice read from opposite
    ends, which is why one ships on and the other off: a settings row reads
    naturally as "enable", a dismissal reads naturally as "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] = "Activar el asistente de lista cuando la lista de reabastecimiento esté vacía"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"Ofrece una lista de reabastecimiento inicial al iniciar sesión siempre que la de este personaje esté vacía."

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

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Ventana de Restocker"

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
    only the character's own profile, so nothing else on any panel can return
    them to their defaults.

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
-- %d is the item ID the player typed.
L["RESTOCKER_UNKNOWN_ITEM"] = "No existe ningún objeto con el ID %d."
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

-- /crs help lines. The command literals stay in code; these are the descriptions.
L["RESTOCKER_HELP_SHOW"] = "Muestra la ventana de Restocker."
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nombre]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Añade una lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Elimina la lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renombra la lista actual a ese nombre."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Reemplaza la lista actual por una copia de la lista con ese nombre."
L["RESTOCKER_HELP_PROFILE_USE"] = "Hace que este personaje use la lista con ese nombre."

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
	"Tu lista de reabastecimiento está vacía, así que vamos a añadir algunos objetos para empezar."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] =
	"Elige los básicos que quieres mantener abastecidos. Lo que ya esté en tu lista de reabastecimiento aparece marcado."
L["STARTER_POPUP_INTRO_HOW"] =
	"Todo lo que marques se mantiene abastecido automáticamente cada vez que visitas a un mercader o tu banco, y los objetos básicos se mejoran solos según subes de nivel, así que siempre tendrás lo mejor disponible."
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Siempre puedes ajustar esta lista, o añadir más objetos más adelante, escribiendo %s."
--[[
    The first section's heading names the Water row beneath it as well; the
    food-only heading is the fallback for a section with no Water row.
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
    Checkbox tooltips: { item link, amount }. The first is for ladder items;
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

-- Restocker window UI.
L["RESTOCKER_WINDOW_TITLE"] = "Connoisseur Restocker"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtrar objetos..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Borrar"
L["RESTOCKER_ADD_BUTTON"] = "Añadir"
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "Abrir el asistente de lista"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"Abre el asistente de lista, con los mismos básicos que se ofrecen a un personaje nuevo, y cierra esta ventana."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Añadir un objeto"
L["RESTOCKER_ADD_TOOLTIP_BODY"] = "Suelta un objeto desde tus bolsas, o escribe un ID de objeto y pulsa Intro."
--[[
    In-box placeholder for the add row; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: both boxes on that row share a
    fixed width sized to this English hint, and a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Suelta un objeto o escribe su ID"
L["RESTOCKER_PROFILE_LABEL"] = "Lista"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Haz clic para que este personaje use otra lista de reabastecimiento, o para empezar una nueva."
L["RESTOCKER_RENAME_LABEL"] = "Renombrar"
L["RESTOCKER_NEW_PROFILE"] = "Lista nueva"
L["RESTOCKER_COPY_PROFILE"] = "Copiar"
--[[
    The three single-argument tooltips below (Copy, Delete, and the row's
    Remove) render in ns.SetupRestockerTooltip's TITLE slot, not its body, so
    they take title case and no terminal punctuation -- matching every other
    title in the window. Don't "restore" the period they read as wanting.
]]
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "Copiar esta lista en una nueva"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - copia"
L["RESTOCKER_DELETE_PROFILE"] = "Eliminar"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "Eliminar esta lista"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renombra esta lista para todos los personajes que la usan."
-- %s is the list name, colored at the call site. |n are line breaks.
L["RESTOCKER_DELETE_PROFILE_CONFIRM"] = "¿Seguro que quieres eliminar esta lista?|n|n%s|n|nEsto no se puede deshacer."
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
L["RESTOCKER_COLUMN_AMOUNT"] = "Cantidad"

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
-- Title slot, like the Copy and Delete tooltips above: title case, no terminal period.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Quitar este objeto de la lista de reabastecimiento"
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Cantidad a mantener"
L["RESTOCKER_AMOUNT_TOOLTIP_BODY"] = "Pulsa Intro cuando termines de editar."
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
	"Compra todas las existencias limitadas que un mercader tenga de este objeto, esos pocos artículos que repone lentamente, incluso por encima de tu cantidad objetivo."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Guardar en el banco"
--[[
    Names the Amount column, so it is coupled to RESTOCKER_COLUMN_AMOUNT: a
    locale that renders that heading differently has to say the same word here,
    or the sentence points at a column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Guarda en el banco los objetos sobrantes cuando el banco está abierto, o todos ellos si pones 0 en la columna Cantidad."
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
    Quotes the cell's own values, which couples this line to
    RESTOCKER_REPUTATION_ANY and the four standings above: a locale that renders
    a standing differently has to say so here too.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	'Haz clic para elegir la reputación necesaria con un mercader antes de que Connoisseur le compre ("Cualquiera" compra en cualquier lugar), lo que además rebaja el precio: Amistoso 5%, Honorable 10%, Venerado 15%, Exaltado 20%.'
