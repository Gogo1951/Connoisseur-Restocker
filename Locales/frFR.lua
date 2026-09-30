local L = LibStub("AceLocale-3.0"):NewLocale("Connoisseur", "frFR")
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
L["MACRO_EXPLOSIVES"] = "- Explosifs"
L["MACRO_FEED_PET"] = "- Nourrir fam."
L["MACRO_FOOD"] = "- Manger"
L["MACRO_FOOD_AND_POTION"] = "- Nourr./Potion"
L["MACRO_HEALTH_POTION"] = "- Pot. Soins"
L["MACRO_HEALTHSTONE"] = "- Pierre"
L["MACRO_MANA_GEM"] = "- Gemme de mana"
L["MACRO_MANA_POTION"] = "- Pot. Mana"
L["MACRO_POISONS"] = "- Poisons"
L["MACRO_SOULSTONE"] = "- Pierre d'âme"
L["MACRO_WATER"] = "- Boire"
L["MACRO_WATER_AND_POTION"] = "- Boisson/Potion"

--------------------------------------------------------------------------------
-- Common
--------------------------------------------------------------------------------

-- Joins the items of a printed list: a Readiness Report clause, or the Restocker's "Couldn't move" list.
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

    They are ALSO the food checkbox labels in the Starter List pop-up, so they
    read as ordinary labels while carrying that hard constraint. Translate them
    as the client's own diet words, never as the nicer label they look like --
    a locale that "improves" one here stops matching that client's strings and
    silently breaks pet-food selection for everyone playing in it.
]]

L["DIET_BREAD"] = "Pain"
L["DIET_CHEESE"] = "Fromage"
L["DIET_FISH"] = "Poisson"
L["DIET_FRUIT"] = "Fruit"
L["DIET_FUNGUS"] = "Champignon"
L["DIET_MEAT"] = "Viande"

--------------------------------------------------------------------------------
-- Chat Messages
--------------------------------------------------------------------------------

-- { item link, item ID, zone, subzone, map ID, Discord link }
L["MESSAGE_BUG_REPORT"] =
	"On dirait que vous avez trouvé un bug ! %s (%s) est inutilisable dans %s > %s (%s). Veuillez nous le signaler pour que nous puissions le corriger. Merci ! %s"
L["MESSAGE_NO_ITEM"] = "Aucun objet approprié de type %s trouvé dans vos sacs."
L["MESSAGE_MACRO_SLOTS_FULL"] =
	"Certaines macros Connoisseur n'ont pas pu être créées car vos emplacements de macros sont pleins. Libérez un emplacement en supprimant les macros que vous n'utilisez plus, ou désactivez les macros Connoisseur dont vous n'avez pas besoin dans Options > Add-ons > Connoisseur > Macros."

L["CHAT_LOADED"] =
	"Version %s. Les réglages (y compris l'option pour désactiver ce message) se trouvent dans Options > Add-ons > Connoisseur. Vous aimez l'add-on ? Parlez-en à un ami ! (="

L["CHAT_OPTIONS_IN_COMBAT"] = "Par mesure de sécurité, l'interface des options ne peut pas être ouverte en combat."

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

L["READINESS_TITLE"] = "Rapport de préparation"
-- { clause label, its items }
L["READINESS_CLAUSE_FORMAT"] = "%s %s"
L["READINESS_CLAUSE_SEPARATOR"] = ". "

-- Clause labels, in the order the lines print them.
L["READINESS_MISSING_BUFFS"] = "Améliorations manquantes :"
L["READINESS_EXPIRING"] = "Expiration imminente :"
L["READINESS_MISSING_ITEMS"] = "Objets manquants :"
L["READINESS_DAMAGED_GEAR"] = "Équipement endommagé :"
L["READINESS_CHARACTER"] = "Personnage :"
L["READINESS_QUESTIONABLE_GEAR"] = "Équipement non prévu pour le combat :"

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
L["READINESS_FLASK"] = "Flacon ou 2x élixirs"
L["READINESS_WELL_FED"] = "Bien nourri"
L["READINESS_PET_WELL_FED"] = "Bien nourri (familier)"
L["READINESS_SCROLLS"] = "Parchemins"
L["READINESS_SOULSTONE"] = "Pierre d'âme inactive"
L["READINESS_MAIN_HAND"] = "Main droite"
L["READINESS_OFF_HAND"] = "Main gauche"
L["READINESS_HEALTHSTONE"] = "Pierre de soins"
L["READINESS_MANA_GEM"] = "Gemme de mana"
L["READINESS_HEALING_POTION"] = "Potion de soins"
L["READINESS_MANA_POTION"] = "Potion de mana"
L["READINESS_BANDAGES"] = "Bandages"
L["READINESS_PVP_ON"] = "JcJ activé !"

-- { buff name, whole minutes left }
L["READINESS_TIME_MINUTES"] = "%s %d min"
-- %s is the buff name; used when under a minute is left.
L["READINESS_TIME_EXPIRING"] = "%s moins d'1 min"
-- { dominant talent tree, slash-joined point spread }
L["READINESS_SPEC_FORMAT"] = "%s (%s)"
-- Talent points the character has not spent: exactly one, or %d for two or more.
L["READINESS_UNSPENT_TALENTS_ONE"] = "1 point de talent non dépensé"
L["READINESS_UNSPENT_TALENTS_MANY"] = "%d points de talent non dépensés"

--------------------------------------------------------------------------------
-- ConnoisseurTip Messages
--------------------------------------------------------------------------------

-- Printed in chat by macro bodies via /run ConnoisseurTip("key") or ConnoisseurTipIf. See Features/Macros/Runtime.lua.

L["TIP_PET_NO_FOOD"] = "Vous n'avez actuellement aucune nourriture utile pour votre familier."
L["TIP_PET_NO_SKILLS"] =
	"Vous ne connaissez actuellement pas Appel du familier, Renvoyer le familier, Nourrir le familier ou Ressusciter le familier."
L["TIP_PET_NO_MEND"] = "Vous ne connaissez actuellement pas Guérison du familier."
L["TIP_NO_HAND_POISON"] = "Vous n'avez plus le poison choisi pour cette arme."

-- %s is the localized spell name, resolved at print time.
L["TIP_DONT_KNOW_SPELL"] = "Vous ne connaissez actuellement pas %s."

--------------------------------------------------------------------------------
-- Minimap Tooltip
--------------------------------------------------------------------------------

-- Feature toggles shown in the mini-map tooltip, each with a description line. Both names also fill OPTIONS_MODE_DESCRIPTION's %s.
L["FEATURE_BUFF_FOOD"] = "Nourriture à amélioration"
L["MENU_BUFF_FOOD_DESCRIPTION"] =
	'Priorise la nourriture conférant l\'amélioration "Bien nourri" si elle est absente.'
L["FEATURE_SCROLL_BUFFS"] = "Améliorations de parchemins"
L["MENU_SCROLL_BUFFS_DESCRIPTION"] =
	"Transforme votre macro Nourriture en applicateur de parchemins lorsqu'il vous manque des améliorations de parchemins."

-- Section titles and ignore-list actions in the mini-map tooltip.
L["MINIMAP_BEST_FOOD"] = "Nourriture actuelle"
L["MINIMAP_BEST_PET_FOOD"] = "Nourriture actuelle du familier"
-- Weapon-slot titles beside the rogue's resolved poison, in the Attention Rogues block.
L["MINIMAP_MAIN_HAND"] = "Main droite"
L["MINIMAP_OFF_HAND"] = "Main gauche"
--[[
    The value shown beside an item title when nothing resolved. Kept to a single
    word so it fits in the tooltip's right column, which never wraps -- the full
    sentence, MESSAGE_NO_ITEM, explains it on the wrapping line underneath.
]]
L["MINIMAP_NONE"] = "Aucun"
L["MINIMAP_IGNORE_LIST"] = "Liste d'exclusion"
L["MENU_IGNORE"] = "Ignorer"
L["MENU_CLEAR_IGNORE"] = "Vider la liste d'exclusion"

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
L["MINIMAP_RESTOCKER_REPORT"] = "Rapport Restocker"
L["MINIMAP_RESTOCKER_NEEDED"] = "%d commandes en attente"
L["MINIMAP_RESTOCKER_ITEM_COUNT"] = "%d/%d"
L["MINIMAP_RESTOCKER_STOCKED"] = "Félicitations, vos réserves sont au complet !"

-- Options entry at the bottom of the mini-map tooltip.
L["MENU_OPTIONS"] = "Options de Connoisseur"
L["MENU_OPTIONS_KEYBIND"] = "Maj + Clic milieu"

--------------------------------------------------------------------------------
-- Class Tips
--------------------------------------------------------------------------------

--[[
    Class-colored headers and click tips shown in the mini-map tooltip for the
    player's class.
]]

L["PREFIX_HUNTER"] = "Avis aux chasseurs"
L["PREFIX_MAGE"] = "Avis aux mages"
L["PREFIX_ROGUE"] = "Avis aux voleurs"
L["PREFIX_WARLOCK"] = "Avis aux démonistes"

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
L["TIP_HUNTER_MACROS"] = "À propos de votre macro Nourrir le familier..."
L["TIP_MAGE_MACROS"] = "À propos de vos macros Nourriture, Eau et Gemme de mana..."
L["TIP_ROGUE_MACROS"] = "À propos de votre macro Poisons..."
L["TIP_WARLOCK_MACROS"] = "À propos de vos macros Pierre de soins et Pierre d'âme..."

L["TIP_HUNTER_ALL_IN_ONE"] = "Nourrir le familier est un bouton tout-en-un !"
L["TIP_HUNTER_CALL"] = "Clic gauche pour appeler, nourrir ou ressusciter automatiquement votre familier."
L["TIP_HUNTER_MEND"] = "Clic droit, ou tout clic en combat, pour lancer Guérison du familier."
L["TIP_HUNTER_MODIFIERS"] = "Maintenez Maj pour forcer la résurrection, ou Ctrl pour le renvoyer."

--[[
    Target downranking is per-macro, not block-wide: it applies only to the
    mage's Food and Water and the warlock's Healthstone. Mana Gems, Soulstones,
    and both rituals ignore the target (ignoreTarget in the resolvers), so each
    line names what it actually affects rather than saying "the macro."
]]
L["TIP_MAGE_CONJURE"] =
	"Clic droit sur vos macros Nourriture ou Eau pour lancer Invocation de nourriture ou Invocation d'eau."
L["TIP_MAGE_DOWNRANK"] =
	"Cibler un joueur de niveau inférieur invoquera de la nourriture ou de l'eau adaptée à son niveau."
L["TIP_MAGE_TABLE"] = "Clic milieu sur vos macros Nourriture ou Eau pour lancer Rituel des rafraîchissements."
L["TIP_MAGE_GEM"] =
	"Clic droit sur votre macro Gemme de mana pour invoquer une nouvelle gemme. Cliquez à nouveau avec le bouton droit pour en invoquer une de rang inférieur en secours."

L["TIP_WARLOCK_HEALTHSTONE"] =
	"Clic droit sur votre macro Pierre de soins pour lancer Création de Pierre de soins. Cliquez à nouveau avec le bouton droit pour en créer une de rang inférieur en secours."
L["TIP_WARLOCK_DOWNRANK"] = "Cibler un joueur de niveau inférieur créera une Pierre de soins adaptée à son niveau."
L["TIP_WARLOCK_SOULSTONE"] = "Clic droit sur votre macro Pierre d'âme pour lancer Création de Pierre d'âme."
L["TIP_WARLOCK_SOUL"] = "Clic milieu sur votre macro Pierre de soins pour lancer Rituel des âmes."

L["TIP_ROGUE_OFF_HAND"] = "Clic gauche applique votre poison de main gauche."
L["TIP_ROGUE_MAIN_HAND"] = "Clic droit applique votre poison de main droite."
L["TIP_ROGUE_REPLACE"] = "Les poisons existants sont remplacés automatiquement."
L["TIP_ROGUE_WINDOW"] = "Clic milieu ouvre la fenêtre Poisons."

--------------------------------------------------------------------------------
-- Item Labels
--------------------------------------------------------------------------------

--[[
    One label per macro type, dropped as-is into MESSAGE_NO_ITEM ("No suitable
    %s found...") from ConnoisseurNoItem and the mini-map tooltip. LABEL_WATER
    is also the List Builder's Water checkbox.
]]

L["LABEL_BANDAGE"] = "Bandage"
L["LABEL_EXPLOSIVE"] = "Explosif"
L["LABEL_FOOD"] = "Nourriture"
L["LABEL_HEALTH_POTION"] = "Potion de soins"
L["LABEL_HEALTHSTONE"] = "Pierre de soins"
L["LABEL_MANA_GEM"] = "Gemme de mana"
L["LABEL_MANA_POTION"] = "Potion de mana"
L["LABEL_PET_FOOD"] = "Nourriture pour familier"
L["LABEL_POISONS"] = "Poison"
L["LABEL_SOULSTONE"] = "Pierre d'âme"
L["LABEL_WATER"] = "Eau"

--------------------------------------------------------------------------------
-- UI Labels
--------------------------------------------------------------------------------

-- Generic labels used in the mini-map tooltip.

L["MINIMAP_ENABLED"] = "Activé"
L["MINIMAP_DISABLED"] = "Désactivé"
L["MINIMAP_TOGGLE"] = "Activer/désactiver"
L["MINIMAP_LEFT_CLICK"] = "Clic gauche"
L["MINIMAP_RIGHT_CLICK"] = "Clic droit"
L["MINIMAP_MIDDLE_CLICK"] = "Clic milieu"
L["MINIMAP_SHIFT_LEFT"] = "Maj + Clic gauche"

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
	'Détermine quand votre macro Nourriture propose "%s" : toujours, ou uniquement en solo, en groupe ou en raid, en raid, en montant en niveau ou au niveau maximum.'
L["MODE_ALWAYS"] = "Toujours"
L["MODE_SOLO"] = "En solo"
L["MODE_PARTY"] = "En groupe ou en raid"
L["MODE_RAID"] = "En raid"
L["MODE_LEVELING"] = "En montant en niveau"
L["MODE_MAX_LEVEL"] = "Au niveau maximum"

--------------------------------------------------------------------------------
-- Options Panel
--------------------------------------------------------------------------------

L["OPTIONS_DESCRIPTION"] =
	"Des macros qui utilisent automatiquement votre meilleure nourriture, nourriture à amélioration, eau, potions, pierres de soins, bandages et parchemins, ainsi qu'une liste de réapprovisionnement qui garde vos sacs pleins et améliore vos consommables à mesure que vous montez en niveau. Une automatisation du confort de jeu pour des performances optimales."

-- Welcome Message
L["OPTIONS_WELCOME_MESSAGE"] = "Activer le message de bienvenue"
L["OPTIONS_WELCOME_MESSAGE_DESCRIPTION"] = "Affiche un message de bienvenue dans le chat lors de la connexion."

-- Minimap Button
L["OPTIONS_MINIMAP_BUTTON"] = "Activer le bouton de la minicarte"
L["OPTIONS_MINIMAP_BUTTON_DESCRIPTION"] = "Affiche le bouton de la minicarte."

--[[
    /Commands. Both halves of each line are locale keys: the literal, which
    stays identical in every locale since a slash command has nothing to
    translate, and its description.
]]
L["OPTIONS_COMMANDS_HEADER"] = "/Commands"
L["OPTIONS_COMMAND"] = "/foodie"
L["OPTIONS_COMMAND_DESCRIPTION"] = "Ouvre l'interface des options de cet add-on."
L["RESTOCKER_COMMAND"] = "/crs"
L["RESTOCKER_COMMAND_DESCRIPTION"] = "Ouvre la fenêtre Restocker pour gérer votre liste de réapprovisionnement."

--[[
    Feedback & Support. The four service names are brand names and stay English
    in every locale; OPTIONS_VERSION translates, with %s the version number.
]]
L["OPTIONS_COMMUNITY_HEADER"] = "Commentaires et assistance"
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
	"Connoisseur crée une macro par consommable et la tient à jour au fil des changements dans vos sacs, pour que le bouton de votre barre attrape toujours le meilleur objet que vous transportez. Choisissez ci-dessous les macros à créer, puis réglez la façon dont chacune choisit son objet."

-- Macro Names on Buttons
L["OPTIONS_MACRO_NAMES"] = "Activer les noms de macro sur les boutons"
L["OPTIONS_MACRO_NAMES_DESCRIPTION"] =
	"Affiche le nom des macros sur les boutons de vos barres d'action ; Connoisseur le masque par défaut."

-- Enable Macros
L["OPTIONS_ENABLE_MACROS_HEADER"] = "Activer les macros"
L["OPTIONS_ENABLE_MACROS_DESCRIPTION"] =
	"Choisissez les macros que Connoisseur crée et gère. Désactiver une macro la supprime également."
--[[
    Hover text on each Enable Macros toggle, whose own label names the macro.
    It says "this macro" because a LABEL_* is not every macro's name: Feed Pet's
    label is Pet Food.
]]
L["OPTIONS_MACRO_TOGGLE_DESCRIPTION"] = "Crée et gère cette macro, et la supprime quand la case est décochée."

--[[
    Food & Water: Prioritize Buff Food, Enable Scroll Buffs, and Use Conjured
    Food & Water First, in page order. One description serves all three, so
    each option's hover text says what it does.
]]
L["OPTIONS_FOOD_WATER_HEADER"] = "Nourriture et eau"
L["OPTIONS_FOOD_WATER_DESCRIPTION"] =
	"Vos macros Nourriture et Eau utilisent la meilleure nourriture et la meilleure boisson de vos sacs. Ces options peuvent faire passer en premier la nourriture à amélioration, les parchemins ou la nourriture et l'eau invoquées."

--[[
    Buff Food, the first option under Food & Water. Its hover text is a key of
    its own because it carries the arena exception, which the mini-map
    tooltip's MENU_BUFF_FOOD_DESCRIPTION has no room for.
]]
L["OPTIONS_BUFF_FOOD"] = "Prioriser la nourriture à amélioration"
L["OPTIONS_BUFF_FOOD_DESCRIPTION"] =
	'Priorise la nourriture conférant l\'amélioration "Bien nourri" si elle est absente, sauf en arène.'

-- Scroll Buffs, the second option under Food & Water.
L["OPTIONS_USE_SCROLLS"] = "Activer les améliorations de parchemins"
L["OPTIONS_USE_SCROLLS_DESCRIPTION"] =
	"Votre macro Nourriture applique les parchemins manquants à la première pression, puis vous fait manger à la suivante ; elle ignore les parchemins quand vous ciblez un joueur allié ou que vous êtes en arène."
L["OPTIONS_SCROLL_TYPES"] = "Types de parchemins à vérifier"
L["OPTIONS_SCROLL_AGILITY"] = "Agilité"
L["OPTIONS_SCROLL_INTELLECT"] = "Intelligence"
L["OPTIONS_SCROLL_PROTECTION"] = "Protection"
L["OPTIONS_SCROLL_SPIRIT"] = "Esprit"
L["OPTIONS_SCROLL_STAMINA"] = "Endurance"
L["OPTIONS_SCROLL_STRENGTH"] = "Force"
-- Hover text on each scroll type and pet food type; %s is the scroll type's label or the pet food's item name.
L["OPTIONS_BUFF_TYPE_DESCRIPTION"] = 'Inclut "%s" lors de la vérification des améliorations manquantes.'

-- Use Conjured Food & Water First, the third option under Food & Water.
L["OPTIONS_CONJURED_FIRST"] = "Utiliser d'abord la nourriture et l'eau invoquées"
L["OPTIONS_CONJURED_FIRST_DESCRIPTION"] =
	'Vos macros Nourriture et Eau utilisent la nourriture et l\'eau invoquées avant tout le reste, même si un objet de vos sacs rend davantage, car elles ne coûtent rien et disparaissent peu après la déconnexion. La nourriture à amélioration reste prioritaire tant que "Prioriser la nourriture à amélioration" est activé.'
L["OPTIONS_CONJURED_FIRST_MODE_DESCRIPTION"] =
	"Détermine quand la nourriture et l'eau invoquées passent en premier : toujours, ou uniquement en solo, en groupe ou en raid, en raid, en montant en niveau ou au niveau maximum."

-- Potions & Healthstones
L["OPTIONS_POTIONS_HEADER"] = "Potions et Pierres de soins"
L["OPTIONS_POTIONS_DESCRIPTION"] =
	"Les macros ne peuvent pas être modifiées en combat (c'est une restriction de Blizzard), chaque macro de Potion et de Pierre de soins est donc pré-générée avec votre meilleur objet et jusqu'à deux options de secours. Lors de longs combats, l'icône et l'infobulle peuvent devenir obsolètes et afficher le mauvais objet, mais cliquer sur la macro utilisera toujours le meilleur objet que vous possédez réellement dans vos sacs."
L["OPTIONS_COMBINE_HEALTHSTONES"] = "Combiner les Pierres de soins dans la macro de Potion de soins"
L["OPTIONS_COMBINE_HEALTHSTONES_DESCRIPTION"] =
	"Ajoute votre meilleure Pierre de soins à la fin de la macro de Potion de soins, de sorte qu'une seule pression utilise une potion et une Pierre de soins."

-- Mana Gems & Runes
L["OPTIONS_MANA_GEMS_HEADER"] = "Gemmes de mana et runes"
L["OPTIONS_MANA_GEMS_DESCRIPTION"] =
	"Les Runes démoniaques et ténébreuses, ainsi que quelques autres objets de mana, partagent le temps de recharge des Gemmes de mana. Comme les runes coûtent des points de vie, la macro Gemme de mana les laisse tous de côté, sauf si vous les ajoutez."
L["OPTIONS_INCLUDE_MANA_RUNES"] = "Ajouter les runes et autres objets de mana à la macro Gemme de mana"
L["OPTIONS_INCLUDE_MANA_RUNES_DESCRIPTION"] =
	"Intègre vos Runes démoniaques et ténébreuses, ainsi que tout autre objet de mana qui partage le temps de recharge des Gemmes de mana, au classement de vos Gemmes de mana, pour que la macro Gemme de mana utilise l'un d'eux quand c'est votre meilleure option ou quand vous n'avez plus de gemmes."

-- Buff Re-Application
L["OPTIONS_REAPPLY_HEADER"] = "Renouvellement des améliorations"
L["OPTIONS_REAPPLY_SECTION_DESCRIPTION"] =
	"Les macros ne peuvent pas être modifiées en combat, donc une amélioration qui expire en plein combat reste absente jusqu'à la fin du combat."
L["OPTIONS_REAPPLY"] = "Renouveler les améliorations expirantes"
L["OPTIONS_REAPPLY_DESCRIPTION"] =
	"Considère comme expirées la Nourriture à amélioration, les Améliorations de parchemins et les Améliorations de nourriture pour familier dont le temps restant est inférieur à votre seuil, afin que vos macros en proposent une nouvelle avant le combat."
--[[
    Threshold dropdown, beside the Re-Apply toggle. It has no caption, so the
    values carry the "when" themselves.
]]
L["OPTIONS_REAPPLY_THRESHOLD_DESCRIPTION"] =
	"Définit à quel point une amélioration peut être proche d'expirer avant que vos macros en proposent une nouvelle."
L["REAPPLY_THRESHOLD_ONE"] = "Quand il reste < 1 minute"
L["REAPPLY_THRESHOLD_MANY"] = "Quand il reste < %d minutes"

-- Pet Food Buffs
L["OPTIONS_PET_HEADER"] = "Améliorations de nourriture pour familier"
L["OPTIONS_PET_SECTION_DESCRIPTION"] =
	'Certains aliments confèrent à votre familier sa propre amélioration "Bien nourri".'
L["OPTIONS_USE_PET_BUFFS"] = "Utiliser les améliorations de nourriture pour familier"
L["OPTIONS_USE_PET_BUFFS_DESCRIPTION"] =
	"Ajoute de la nourriture pour familier à votre macro Nourriture quand votre familier n'a pas l'amélioration \"Bien nourri\", sauf en arène."
-- The pet food toggles under this heading carry the client's own item names, so they have no keys here.
L["OPTIONS_PET_BUFF_TYPES"] = "Types de nourriture pour familier à vérifier"

-- Explosives
L["OPTIONS_EXPLOSIVES_HEADER"] = "Explosifs"
L["OPTIONS_EXPLOSIVES_DESCRIPTION"] =
	"L'option @player ignore le réticule de ciblage et déclenche l'explosif à vos pieds. Idéal quand votre cible est au corps à corps. Votre autre clic le lance comme d'habitude."
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT"] = "Attribution des clics"
L["OPTIONS_EXPLOSIVES_CLICK_LAYOUT_DESCRIPTION"] =
	"Détermine quel clic lance l'explosif et lequel le déclenche à vos pieds."
-- Each layout names its Left-Click alone: Right-Click always does the other, and the short value fits the standard dropdown.
L["EXPLOSIVES_MODE_ATPLAYER"] = "Clic gauche : @player"
L["EXPLOSIVES_MODE_TOSS"] = "Clic gauche : lancer"

-- Druids
L["OPTIONS_DRUIDS_HEADER"] = "Druides"
L["OPTIONS_DRUID_MACRO_HELPER"] = "Activer l'intégration de DruidMacroHelper"
L["OPTIONS_DRUID_MACRO_HELPER_DESCRIPTION"] =
	"Crée des macros de powershifting pour les potions de soins, les potions de mana et les pierres de soins à l'aide de DruidMacroHelper (/dmh)."
--[[
    Return-form dropdown, beside the DruidMacroHelper toggle. The macro
    powershifts out of form, uses the consumable, then returns to this one, so
    the values name that return, which is why the dropdown needs no caption.
]]
L["OPTIONS_DRUID_RETURN_FORM_DESCRIPTION"] =
	"Détermine la forme dans laquelle vos macros de powershifting vous ramènent après l'utilisation de l'objet."
L["DRUID_FORM_BEAR"] = "Retour en ours"
L["DRUID_FORM_CAT"] = "Retour en félin"

-- Rogues
L["OPTIONS_ROGUES_HEADER"] = "Voleurs"
L["OPTIONS_POISONS_DESCRIPTION"] =
	"Garde la macro Poisons chargée avec le meilleur rang utilisable de chaque type de poison. Clic gauche pour la main gauche, clic droit pour la main droite ; les poisons existants sont remplacés automatiquement."
L["OPTIONS_POISON_MAIN_HAND"] = "Type de poison de main droite"
L["OPTIONS_POISON_OFF_HAND"] = "Type de poison de main gauche"
L["OPTIONS_POISON_MAIN_HAND_DESCRIPTION"] =
	"Détermine le poison que votre macro Poisons applique à votre main droite lors d'un clic droit."
L["OPTIONS_POISON_OFF_HAND_DESCRIPTION"] =
	"Détermine le poison que votre macro Poisons applique à votre main gauche lors d'un clic gauche."
-- Shared by the Rogue (Stealth) and Night Elf (Shadowmeld) toggles; a character sees one at most.
L["OPTIONS_STEALTH_EATING"] = "Activer le camouflage en mangeant"
L["OPTIONS_STEALTH_EATING_ROGUE_DESCRIPTION"] =
	"Ajoute Camouflage à votre macro Nourriture pour vous camoufler pendant que vous mangez."

-- Night Elves
L["OPTIONS_NIGHTELF_HEADER"] = "Elfes de la nuit"
L["OPTIONS_STEALTH_DRINKING"] = "Activer le camouflage en buvant"
L["OPTIONS_STEALTH_DRINKING_DESCRIPTION"] =
	"Ajoute Camouflage dans l'ombre à votre macro Eau pour vous camoufler pendant que vous buvez."
L["OPTIONS_STEALTH_EATING_NIGHTELF_DESCRIPTION"] =
	"Ajoute Camouflage dans l'ombre à votre macro Nourriture pour vous camoufler pendant que vous mangez."
L["OPTIONS_STEALTH_PICK_ONE"] =
	"Astuce de pro : Choisissez-en un. Vous pouvez manger et boire en même temps, mais manger ou boire après vous être camouflé rompra le camouflage."

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
L["TAB_IGNORE_LIST"] = "Liste d'exclusion"
L["OPTIONS_IGNORE_LIST_DESCRIPTION"] =
	"Les objets ignorés ne sont jamais choisis par aucune macro. Nourriture, eau, potions, tout. La liste globale couvre tous les personnages ; celle d'un personnage ne couvre que lui. Faites un clic droit sur le bouton de la minicarte pour ignorer votre meilleure nourriture du moment."
L["OPTIONS_IGNORE_GLOBAL"] = "Globale"
L["OPTIONS_IGNORE_PROMOTE_DESCRIPTION"] =
	"Déplace cet objet vers la liste globale, afin qu'il soit ignoré sur tous les personnages."
L["OPTIONS_IGNORE_ADD_ID"] = "Ajouter par ID d'objet"
L["OPTIONS_IGNORE_ADD_ID_DESCRIPTION"] =
	"Saisissez un ID d'objet, ou faites Maj + Clic sur un lien d'objet dans le chat pendant que ce champ est actif."
L["OPTIONS_IGNORE_ADD_ID_INVALID"] = "Saisissez un ID d'objet, ou faites Maj + Clic sur un lien d'objet dans le chat."
L["OPTIONS_IGNORE_REMOVE"] = "Retirer"
L["OPTIONS_IGNORE_EMPTY"] = "Cette liste est vide."
-- %d is the item ID, shown while the client is still resolving the item.
L["LOADING_ITEM"] = "Chargement de l'ID : %d"

--[[
    Restocker options panel. The tree label stays "Restocker" in every locale:
    it is the feature's proper name, so there is nothing in it to translate.
]]
L["TAB_RESTOCKER"] = "Restocker"
L["OPTIONS_RESTOCKER_DESCRIPTION"] =
	"Garde vos sacs approvisionnés grâce à votre liste de réapprovisionnement, en achetant chez les marchands et en déplaçant automatiquement les objets entre vos sacs et la banque. Tapez %s pour ouvrir la liste."
L["OPTIONS_RESTOCKER_OPEN_BANK"] = "Ouvrir à la banque"
L["OPTIONS_RESTOCKER_OPEN_BANK_DESCRIPTION"] = "Ouvre la fenêtre Restocker quand vous vous rendez à la banque."
L["OPTIONS_RESTOCKER_OPEN_MERCHANT"] = "Ouvrir chez le marchand"
L["OPTIONS_RESTOCKER_OPEN_MERCHANT_DESCRIPTION"] =
	"Ouvre la fenêtre Restocker quand vous vous rendez chez un marchand."
L["OPTIONS_RESTOCKER_REMIND"] = "Activer les rappels de réapprovisionnement en ville"
L["OPTIONS_RESTOCKER_REMIND_DESCRIPTION"] =
	"Affiche un rappel dans le chat quand il vous manque des objets de votre liste de réapprovisionnement et que vous arrivez dans une auberge ou une ville, ou que vous vous y trouvez déjà à la connexion."
L["OPTIONS_RESTOCKER_MERCHANT_REMIND"] = "Activer les rappels de réapprovisionnement chez le marchand"
L["OPTIONS_RESTOCKER_MERCHANT_REMIND_DESCRIPTION"] =
	"Signale les éventuelles commandes de réapprovisionnement en attente quand vous fermez une fenêtre de marchand."
L["OPTIONS_RESTOCKER_BANK_REMIND"] = "Activer les rappels de réapprovisionnement à la banque"
L["OPTIONS_RESTOCKER_BANK_REMIND_DESCRIPTION"] =
	"Signale les éventuelles commandes de réapprovisionnement en attente quand vous fermez la banque."

--[[
    The Starter List Builder pop-up. This toggle and the pop-up's own "Don't
    Show This Again" box are the same per-character choice read from opposite
    ends, which is why one ships on and the other off: a settings row reads
    naturally as "enable", a dismissal reads naturally as "stop".
]]
L["OPTIONS_RESTOCKER_STARTER_LIST"] = "Activer l'assistant de liste quand la liste de réapprovisionnement est vide"
L["OPTIONS_RESTOCKER_STARTER_LIST_DESCRIPTION"] =
	"Propose une liste de réapprovisionnement de départ à la connexion dès que celle de ce personnage est vide."

--[[
    How much each reminder says. Simple is the headline alone; Verbose adds a
    line per item, showing how many you have against how many you want.

    One word each, deliberately: they sit in the dropdown beside each reminder,
    which has no caption, and read there as how much it says.
]]
L["OPTIONS_RESTOCKER_REMIND_MODE_DESCRIPTION"] =
	"Détermine si le rappel tient en une seule ligne ou ajoute une ligne pour chaque objet qui vous manque."
L["OPTIONS_RESTOCKER_MODE_SIMPLE"] = "Simple"
L["OPTIONS_RESTOCKER_MODE_VERBOSE"] = "Détaillé"

L["OPTIONS_RESTOCKER_REMIND_SOUND"] = "Jouer un son"
L["OPTIONS_RESTOCKER_REMIND_SOUND_DESCRIPTION"] =
	"Joue une alerte en même temps que le rappel, pour quand le chat est chargé."
L["OPTIONS_RESTOCKER_SOUND_PREVIEW"] = "Cliquez pour écouter l'alerte."

L["OPTIONS_RESTOCKER_WINDOW_HEADER"] = "Fenêtre Restocker"

--[[
    Praise for the adopted Restocker code. The three names are proper nouns and
    stay as written in every locale; the sentences around them translate.
]]
L["OPTIONS_RESTOCKER_PRAISE_HEADER"] = "Remerciements"
L["OPTIONS_RESTOCKER_PRAISE"] =
	"J'ai toujours adoré Restocker, et je suis reconnaissant d'avoir l'occasion de le voir perdurer au sein de Connoisseur. Un immense merci à ChiliFajita, qui a écrit l'Auto Restocker d'origine, ainsi qu'à kvakvs et guardycmw, qui l'ont fait vivre à travers Classic et Mists of Pandaria."

-- Readiness Report
L["TAB_READINESS_REPORT"] = "Rapport de préparation"
L["OPTIONS_READINESS_ENABLE"] = "Activer le rapport de préparation lors d'un appel"
L["OPTIONS_READINESS_ENABLE_DESCRIPTION"] = "Active le rapport de préparation pour tous les personnages de ce compte."
--[[
    Says what the report does AND that it stays quiet, because the quiet is the
    feature: a player who turns this on and sees nothing for three pulls has to
    know that is the report working rather than the report broken.
]]
L["OPTIONS_READINESS_DESCRIPTION"] =
	"Quand un appel commence, affiche une liste privée de ce qu'il reste à corriger, et ne dit rien du tout quand vous êtes prêt."

--[[
    The reset button under the master toggle. It needs a control of its own
    because these settings are account-wide: the stock Reset Profile reaches
    only the character's own profile, so nothing else on any panel can return
    them to their defaults.

    The confirm names the one consequence a player would not otherwise predict.
    Off is what the report ships as, so resetting switches it back off, and a
    page that emptied itself with no warning would read as a bug.
]]
L["OPTIONS_READINESS_RESET"] = "Réinitialiser les réglages du rapport de préparation"
L["OPTIONS_READINESS_RESET_DESCRIPTION"] =
	"Remet chaque case à cocher et les deux seuils de cette page à leurs valeurs par défaut, sans toucher aux autres pages."
L["OPTIONS_READINESS_RESET_CONFIRM"] =
	"Réinitialiser tous les réglages du rapport de préparation à leurs valeurs par défaut ? Cela désactive aussi le rapport lui-même."

--[[
    The three sections, each a real header over the switches it covers. They
    name what the line is called in chat, so the panel and the report read as
    the same feature.
]]
L["OPTIONS_READINESS_BUFFS_HEADER"] = "Améliorations manquantes"
L["OPTIONS_READINESS_ITEMS_HEADER"] = "Objets manquants"
L["OPTIONS_READINESS_CHARACTER_HEADER"] = "Personnage"

-- Missing Buffs
L["OPTIONS_READINESS_FLASK_DESCRIPTION"] =
	"Signale un flacon manquant. Un flacon, ou un élixir de bataille et un élixir du gardien, compte comme couvert."
L["OPTIONS_READINESS_WELL_FED_DESCRIPTION"] =
	"Signale l'absence de l'amélioration \"Bien nourri\". Nécessite d'activer Nourriture à amélioration dans Macros."
L["OPTIONS_READINESS_PET_WELL_FED_DESCRIPTION"] =
	"Signale l'absence de l'amélioration \"Bien nourri\" sur votre familier. Nécessite d'activer Améliorations de nourriture pour familier dans Macros, et d'avoir un familier invoqué."
L["OPTIONS_READINESS_SCROLLS"] = "Améliorations de parchemins"
L["OPTIONS_READINESS_SCROLLS_DESCRIPTION"] =
	"Signale les améliorations de parchemins manquantes. Nécessite d'activer Améliorations de parchemins dans Macros, et ne vérifie que les types de parchemins qui y sont sélectionnés."
--[[
    The one entry that asks about the GROUP rather than the player's own bags,
    which the helper text has to say outright: a raid carrying seven unused
    stones is not covered, and one deployed stone covers it.
]]
L["OPTIONS_READINESS_SOULSTONE_DESCRIPTION"] =
	"Signale quand aucun membre de votre groupe n'a de Pierre d'âme active ; une pierre dans un sac ne compte pas. Affiché uniquement pour un démoniste capable d'en créer une."
L["OPTIONS_READINESS_MAIN_HAND"] = "Amélioration d'arme (main droite)"
--[[
    Says the Shaman exemption outright, because a main-hand line that goes quiet
    the moment a Shaman joins reads as a broken switch otherwise.
]]
L["OPTIONS_READINESS_MAIN_HAND_DESCRIPTION"] =
	"Signale une arme en main droite sans enchantement temporaire. Tout enchantement compte, et rien n'est signalé quand il y a un chaman dans votre groupe."
L["OPTIONS_READINESS_OFF_HAND"] = "Amélioration d'arme (main gauche)"
L["OPTIONS_READINESS_OFF_HAND_DESCRIPTION"] =
	"Signale une arme en main gauche sans enchantement temporaire. Tout enchantement compte : une pierre, une huile, un poison ou une amélioration d'arme de chaman."
--[[
    Names the OTHER threshold so the two cannot be mistaken for each other: the
    Macros panel has one that decides when a macro treats a buff as spent, and
    this one only decides when the report mentions it.
]]
L["OPTIONS_READINESS_EXPIRING"] = "Améliorations expirant sous"
L["OPTIONS_READINESS_EXPIRING_DESCRIPTION"] =
	"Nomme chaque amélioration dont vous bénéficiez et qui est sur le point d'expirer, pas seulement celles appliquées par Connoisseur, et fonctionne indépendamment de Renouvellement des améliorations dans Macros."
-- %s is a whole or half number of minutes.
L["OPTIONS_READINESS_EXPIRING_MINUTES"] = "%s minutes"
-- The one-minute entry alone; one plural template cannot render it grammatically.
L["OPTIONS_READINESS_EXPIRING_MINUTES_ONE"] = "1 minute"
L["OPTIONS_READINESS_EXPIRING_THRESHOLD_DESCRIPTION"] =
	"Définit à quel point une amélioration doit être proche d'expirer pour que le rapport la nomme."

-- Missing Items
L["OPTIONS_READINESS_HEALTHSTONE_DESCRIPTION"] =
	"Signale quand vous ne portez aucune Pierre de soins. Affiché uniquement quand un démoniste de votre groupe peut vous en donner une, ou quand le démoniste, c'est vous."
L["OPTIONS_READINESS_MANA_GEM_DESCRIPTION"] =
	"Signale quand vous ne portez aucune Gemme de mana. Affiché uniquement pour un mage capable d'en invoquer une."
L["OPTIONS_READINESS_HEALING_POTION_DESCRIPTION"] =
	"Signale quand vous ne portez aucune potion de soins, car personne ne peut vous en passer une en plein combat."
L["OPTIONS_READINESS_MANA_POTION_DESCRIPTION"] =
	"Signale quand vous ne portez aucune potion de mana. Affiché uniquement quand vous jouez une classe qui utilise du mana."
L["OPTIONS_READINESS_BANDAGES_DESCRIPTION"] =
	"Signale quand vous ne portez aucun bandage que votre compétence en Premiers soins vous permet d'utiliser."
L["OPTIONS_READINESS_DURABILITY"] = "Équipement endommagé sous"
L["OPTIONS_READINESS_DURABILITY_DESCRIPTION"] =
	"Affiche le lien de chaque objet équipé dont la durabilité est inférieure à ce seuil, mesurée objet par objet pour qu'une seule arme cassée apparaisse quand même."
-- %d is a durability percentage.
L["OPTIONS_READINESS_DURABILITY_PERCENT"] = "%d%%"
L["OPTIONS_READINESS_DURABILITY_THRESHOLD_DESCRIPTION"] =
	"Définit jusqu'où la durabilité d'un objet doit baisser pour que le rapport en affiche le lien."

-- Character
L["OPTIONS_READINESS_SPEC"] = "Spécialisation actuelle"
L["OPTIONS_READINESS_SPEC_DESCRIPTION"] =
	"Affiche votre répartition de talents, et les points que vous n'avez pas dépensés."
L["OPTIONS_READINESS_PVP"] = "Marqueur JcJ actif"
L["OPTIONS_READINESS_PVP_DESCRIPTION"] = "Avertit quand vous portez un marqueur JcJ."
L["OPTIONS_READINESS_QUESTIONABLE_GEAR"] = "Équipement non prévu pour le combat"
L["OPTIONS_READINESS_QUESTIONABLE_GEAR_DESCRIPTION"] =
	"Affiche le lien des objets équipés qui n'ont rien à faire dans un combat, comme une Cravache d'équitation ou une canne à pêche."

--------------------------------------------------------------------------------
-- Restocker Window & Chat
--------------------------------------------------------------------------------

-- Chat messages printed by the Restocker feature (Features/Restocker/).
L["RESTOCKER_PROFILE_EXISTS"] = 'Une liste nommée "%s" existe déjà.'
-- %d is the item ID the player typed.
L["RESTOCKER_UNKNOWN_ITEM"] = "Il n'existe aucun objet portant l'ID %d."
L["RESTOCKER_BANK_NOT_OPEN"] = "La banque n'est pas ouverte."
--[[
    %s is the /crs slash command, colored at the call site. Only the bank flow
    prints this, so the Shift hint names the bank; Shift is read as the window
    opens (ns.OnRestockerBankOpen), not stored as a preference.
]]
L["RESTOCKER_COMPLETE"] =
	"Réapprovisionnement terminé. Maintenez Maj en ouvrant la banque pour ignorer le réapprovisionnement. Tapez %s pour modifier votre liste de réapprovisionnement."
L["RESTOCKER_STOPPED_BOTH_FULL"] = "Réapprovisionnement arrêté. Vos sacs et votre banque sont pleins."
L["RESTOCKER_STOPPED_BANK_FULL"] =
	"Réapprovisionnement arrêté. Votre banque est pleine ; libérez un emplacement et rouvrez-la."
L["RESTOCKER_STOPPED_BAG_FULL"] =
	"Réapprovisionnement arrêté. Vos sacs sont pleins ; libérez un emplacement et rouvrez la banque."
L["RESTOCKER_STOPPED_NO_PROGRESS"] = "Réapprovisionnement arrêté. Aucun progrès possible."
L["RESTOCKER_STOPPED_COULD_NOT_MOVE"] = "Réapprovisionnement arrêté. Impossible de déplacer : %s"
-- { count, item name }
L["RESTOCKER_STUCK_ITEM_FORMAT"] = "%dx %s"
L["RESTOCKER_STUCK_ITEM_EXTRA_FORMAT"] = "%dx %s (en trop)"
L["RESTOCKER_STOPPED_ERROR"] = "Réapprovisionnement arrêté à cause d'une erreur : %s"
--[[
    Printed during a merchant restock when the crafting-reagent buyer stands
    down: this merchant stocks some of the reagents the Restock List needs but
    not all of them, and reagents buy all-or-nothing (VendorStocksAllReagents in
    Features/Restocker/Restocker-Merchant.lua). Silent at vendors stocking none.
]]
L["RESTOCKER_REAGENTS_SKIPPED"] =
	"Ce marchand ne vend pas tous les ingrédients dont vos poisons ont besoin. Aucun ne sera acheté."
-- Printed on reaching an inn or a city while the Restock List is short of something.
L["RESTOCKER_TOWN_REMINDER"] = "N'oubliez pas de vous réapprovisionner tant que vous êtes en ville !"

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
L["RESTOCKER_STILL_SHORT_ONE"] = "1 commande de réapprovisionnement en attente."
L["RESTOCKER_STILL_SHORT_MANY"] = "%d commandes de réapprovisionnement en attente."

--[[
    Level-up upgrades. The headline makes the Restock List the subject, so
    there is no item count to agree with and one string covers any number of
    swaps; the line under it is { old link, old amount, new link, new amount },
    outgoing tier on the left and incoming on the right.

    Both amounts are carried because they are not always equal: a swap onto a
    tier the list already holds merges the two rows, so the new amount is the
    sum rather than the old amount moved across.
]]
L["RESTOCKER_UPGRADED"] = "Votre liste de réapprovisionnement a été mise à niveau."
L["RESTOCKER_UPGRADED_ITEM"] = "%sx%d devient %sx%d."

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
L["RESTOCKER_RESTOCKED_ONE"] = "1 commande de réapprovisionnement honorée."
L["RESTOCKER_RESTOCKED_MANY"] = "%d commandes de réapprovisionnement honorées."

--[[
    The vendor had some of what an order asked for but not all of it. Its own
    line rather than a clause on the one above, so the two counts stay
    independent and a mixed run needs no combined string -- both print when
    both are non-zero, and a run with no partials never mentions them.

    Without this line, a partial buy would spend gold and say nothing, since
    "filled" has to stay false for it.
]]
L["RESTOCKER_RESTOCKED_PARTIAL_ONE"] = "1 commande de réapprovisionnement partiellement honorée."
L["RESTOCKER_RESTOCKED_PARTIAL_MANY"] = "%d commandes de réapprovisionnement partiellement honorées."
-- Printed after the counts above when the bags ran out of room before every order was bought.
L["RESTOCKER_BAGS_FULL_PARTIAL"] = "Vos sacs se sont remplis avant que tout soit acheté."

-- /crs help lines. The command literals stay in code; these are the descriptions.
L["RESTOCKER_HELP_SHOW"] = "Affiche la fenêtre Restocker."
-- Stands for the list name the player types after a /crs profile subcommand.
L["RESTOCKER_HELP_NAME_PLACEHOLDER"] = "[nom]"
L["RESTOCKER_HELP_PROFILE_ADD"] = "Ajoute une liste portant ce nom."
L["RESTOCKER_HELP_PROFILE_DELETE"] = "Supprime la liste portant ce nom."
L["RESTOCKER_HELP_PROFILE_RENAME"] = "Renomme la liste actuelle avec ce nom."
L["RESTOCKER_HELP_PROFILE_COPY"] = "Remplace la liste actuelle par une copie de la liste portant ce nom."
L["RESTOCKER_HELP_PROFILE_USE"] = "Fait passer ce personnage à la liste portant ce nom."

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
	"Votre liste de réapprovisionnement est vide, alors ajoutons quelques objets pour bien démarrer."
-- Shown instead when the window is opened over a list that already has items on it.
L["STARTER_POPUP_INTRO_STOCKED"] =
	"Choisissez les produits de base à garder approvisionnés. Ce qui figure déjà sur votre liste de réapprovisionnement est coché."
L["STARTER_POPUP_INTRO_HOW"] =
	"Tout ce que vous cochez est réapprovisionné automatiquement dès que vous ouvrez un marchand ou votre banque, et les articles courants montent en gamme tout seuls à mesure que vous gagnez des niveaux, pour que vous ayez toujours le meilleur disponible."
-- %s is the /crs slash command, colored at the call site.
L["STARTER_POPUP_COMMAND_HINT"] =
	"Vous pouvez à tout moment ajuster cette liste, ou ajouter d'autres objets plus tard, en tapant %s."
--[[
    The first section's heading names the Water row beneath it as well; the
    food-only heading is the fallback for a section with no Water row.
]]
L["STARTER_POPUP_FOOD_AND_WATER_HEADER"] = "Nourriture et eau"
L["STARTER_POPUP_FOOD_HEADER"] = "Nourriture"
L["STARTER_POPUP_AMMO_HEADER"] = "Munitions"
-- The two ammo staples; the Water label reuses LABEL_WATER above.
L["STARTER_POPUP_BULLETS"] = "Balles"
L["STARTER_POPUP_ARROWS"] = "Flèches"
--[[
    The Reagents & Tools section: the Hearthstone, plus each class's tools and
    spell reagents. Rogues additionally get a Poisons section of their own,
    whose note under the header reuses PREFIX_ROGUE (rogue-colored at the call
    site) to say the ingredients take care of themselves. Both sections name
    their rows with the client's own item names, so neither has row labels here.
]]
L["STARTER_POPUP_REAGENTS_HEADER"] = "Composants et outils"
L["STARTER_POPUP_POISONS_HEADER"] = "Poisons"
-- %s is the rogue-colored PREFIX_ROGUE; the spaced colon is deliberate.
L["STARTER_POPUP_POISONS_NOTE"] =
	"%s : Ajoutez le poison fini à votre liste, et Connoisseur achète automatiquement les ingrédients chez tout marchand qui les vend tous."
--[[
    Checkbox tooltips: { item link, amount }. The first is for ladder items;
    the second for single-tier reagents, which never upgrade.
]]
L["STARTER_POPUP_ITEM_DESCRIPTION"] =
	"Ajoute %s à votre liste de réapprovisionnement, en gardant %d dans vos sacs et en les améliorant à mesure que vous montez en niveau."
L["STARTER_POPUP_ITEM_DESCRIPTION_STATIC"] =
	"Ajoute %s à votre liste de réapprovisionnement et garde %d dans vos sacs."
--[[
    The stacks dropdown beside each staple that takes an amount. The label is
    unit-agnostic, since a stack is whatever its item stacks to; the tooltip
    below carries that item's own stack size as %d.
]]
L["STARTER_POPUP_STACK_ONE"] = "1 pile"
L["STARTER_POPUP_STACK_MANY"] = "%d piles"
L["STARTER_POPUP_STACKS_DESCRIPTION"] = "Nombre de piles à garder en réserve, une pile valant %d."
--[[
    The same dropdown where the staple does not stack (Soul Shards): the
    choices are bare numbers, so only the tooltip needs words.
]]
L["STARTER_POPUP_COUNT_DESCRIPTION"] =
	"Nombre d'exemplaires à garder en réserve, chacun dans son propre emplacement de sac puisqu'ils ne s'empilent pas."
L["STARTER_POPUP_DISMISS"] = "Ne plus afficher pour ce personnage"
L["STARTER_POPUP_DISMISS_DESCRIPTION"] =
	"Empêche ces suggestions de revenir lors d'une connexion où votre liste de réapprovisionnement est vide."

-- Restocker window UI.
L["RESTOCKER_WINDOW_TITLE"] = "Connoisseur Restocker"
L["RESTOCKER_FILTER_PLACEHOLDER"] = "Filtrer les objets..."
L["RESTOCKER_FILTER_CLEAR_TOOLTIP"] = "Effacer"
L["RESTOCKER_ADD_BUTTON"] = "Ajouter"
L["RESTOCKER_LIST_BUILDER_BUTTON"] = "Ouvrir l'assistant de liste"
L["RESTOCKER_LIST_BUILDER_TOOLTIP"] =
	"Ouvre l'assistant de liste, avec les mêmes produits de base que ceux proposés à un nouveau personnage, et ferme cette fenêtre."
L["RESTOCKER_ADD_TOOLTIP_TITLE"] = "Ajouter un objet"
L["RESTOCKER_ADD_TOOLTIP_BODY"] =
	"Déposez un objet depuis vos sacs, ou saisissez un ID d'objet et appuyez sur Entrée."
--[[
    In-box placeholder for the add row; the tooltip above carries the detail.
    Kept to a phrase rather than a sentence: both boxes on that row share a
    fixed width sized to this English hint, and a longer one is cut off.
]]
L["RESTOCKER_ADD_PLACEHOLDER"] = "Déposer un objet ou saisir son ID"
L["RESTOCKER_PROFILE_LABEL"] = "Liste"
L["RESTOCKER_PROFILE_TOOLTIP"] =
	"Cliquez pour faire passer ce personnage à une autre liste de réapprovisionnement, ou pour en commencer une nouvelle."
L["RESTOCKER_RENAME_LABEL"] = "Renommer"
L["RESTOCKER_NEW_PROFILE"] = "Nouvelle liste"
L["RESTOCKER_COPY_PROFILE"] = "Copier"
--[[
    The three single-argument tooltips below (Copy, Delete, and the row's
    Remove) render in ns.SetupRestockerTooltip's TITLE slot, not its body, so
    they take title case and no terminal punctuation -- matching every other
    title in the window. Don't "restore" the period they read as wanting.
]]
L["RESTOCKER_COPY_PROFILE_TOOLTIP"] = "Copier cette liste dans une nouvelle"
-- %s becomes "<list name> Copy"; numbered if that name is taken.
L["RESTOCKER_PROFILE_COPY_NAME"] = "%s - Copie"
L["RESTOCKER_DELETE_PROFILE"] = "Supprimer"
L["RESTOCKER_DELETE_PROFILE_TOOLTIP"] = "Supprimer cette liste"
L["RESTOCKER_RENAME_TOOLTIP"] = "Renomme cette liste pour tous les personnages qui l'utilisent."
-- %s is the list name, colored at the call site. |n are line breaks.
L["RESTOCKER_DELETE_PROFILE_CONFIRM"] =
	"Voulez-vous vraiment supprimer cette liste ?|n|n%s|n|nCette action est irréversible."
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
L["RESTOCKER_UPGRADE_TOOLTIP_TITLE"] = "Améliorer au fil des niveaux"
L["RESTOCKER_UPGRADE_TOOLTIP_BODY"] =
	"Permet à Connoisseur de remplacer la nourriture, l'eau, les munitions, les poisons, les potions et les composants de classe par de meilleurs objets à mesure que vous montez en niveau."

--[[
    The band labels drawn over the Bank and Merchant column groups, and the
    Upgrade column's caption. The bands name the place an item moves to or
    from, so the column captions under them can stay one word each.
]]
L["RESTOCKER_ROW_BANK"] = "Banque"
L["RESTOCKER_ROW_MERCHANT"] = "Marchand"
L["RESTOCKER_ROW_UPGRADE"] = "Améliorer"

--[[
    Column headings over the list.

    Keep these SHORT. Every heading but Item can widen its column, and every
    pixel a heading takes comes out of the item name beside it. Six full-length
    headings do not fit beside a readable name at the smallest window size.

    "Take" and "Store" are short because they never appear alone: both sit
    under a "Bank" band, which is what makes them exact. Translate them as a
    pair with that band in mind, and keep them a single short word each.
]]
L["RESTOCKER_COLUMN_ITEM"] = "Objet"
L["RESTOCKER_COLUMN_WITHDRAW"] = "Retirer"
L["RESTOCKER_COLUMN_DEPOSIT"] = "Ranger"
L["RESTOCKER_COLUMN_REPUTATION"] = "Rép."
L["RESTOCKER_COLUMN_AMOUNT"] = "Quantité"

L["RESTOCKER_GROUP_OTHER"] = "Autre"
--[[
    Temporary group holding items added during this viewing of the window. It
    sorts above every real item type and disappears when the window closes.
]]
L["RESTOCKER_GROUP_NEW"] = "Nouveaux"
--[[
    The category pane's first entry, above the item types. Selected by default,
    and the way back to the whole list once a type has been picked, so it has
    to read as "everything" rather than as another type.
]]
L["RESTOCKER_GROUP_ALL"] = "Tous les objets"
-- Title slot, like the Copy and Delete tooltips above: title case, no terminal period.
L["RESTOCKER_REMOVE_TOOLTIP"] = "Retirer cet objet de la liste de réapprovisionnement"
L["RESTOCKER_AMOUNT_TOOLTIP_TITLE"] = "Quantité à maintenir"
L["RESTOCKER_AMOUNT_TOOLTIP_BODY"] = "Appuyez sur Entrée quand vous avez terminé."
L["RESTOCKER_BUY_LABEL"] = "Acheter"
L["RESTOCKER_BUY_TOOLTIP_TITLE"] = "Acheter chez le marchand"
L["RESTOCKER_BUY_TOOLTIP_BODY"] = "Achète la quantité nécessaire chez le marchand quand sa fenêtre est ouverte."

--[[
    Some vendor slots hold only a few units and trickle back over time, which is
    how Classic sells its scarce consumables. Extra empties those slots outright
    rather than buying the shortfall, so the tooltip has to say what it buys and
    that only limited stock counts.
]]
L["RESTOCKER_EXTRA_LABEL"] = "Extra"
L["RESTOCKER_EXTRA_TOOLTIP_TITLE"] = "Acheter en extra"
L["RESTOCKER_EXTRA_TOOLTIP_STOCK"] =
	"Achète tout le stock limité de cet objet chez un marchand, ces marchandises vendues au compte-gouttes qu'il réapprovisionne peu à peu, même au-delà de votre quantité cible."
L["RESTOCKER_DEPOSIT_TOOLTIP_TITLE"] = "Ranger à la banque"
--[[
    Names the Amount column, so it is coupled to RESTOCKER_COLUMN_AMOUNT: a
    locale that renders that heading differently has to say the same word here,
    or the sentence points at a column the player cannot find.
]]
L["RESTOCKER_DEPOSIT_TOOLTIP_BODY"] =
	"Range les objets en trop à la banque quand elle est ouverte, ou la totalité si la colonne Quantité indique 0."
L["RESTOCKER_WITHDRAW_TOOLTIP_TITLE"] = "Retirer de la banque"
L["RESTOCKER_WITHDRAW_TOOLTIP_BODY"] = "Retire les objets nécessaires de la banque quand elle est ouverte."

-- Required-reputation control (per-item vendor gate).
L["RESTOCKER_REPUTATION_MENU_TITLE"] = "Réputation requise"
--[[
    { standing label, discount percent }.

    This string IS run through string.format, so its literal percent sign is
    escaped as %%. RESTOCKER_REPUTATION_TOOLTIP_STANDING below is printed
    as-is and therefore writes bare % signs. Both are correct where they
    stand; neither may be "normalized" to match the other, in any locale.
]]
L["RESTOCKER_REPUTATION_DISCOUNT_FORMAT"] = "%s (%d%% de remise)"
L["RESTOCKER_REPUTATION_ANY"] = "Aucune"
L["RESTOCKER_REPUTATION_FRIENDLY"] = "Amical"
L["RESTOCKER_REPUTATION_HONORED"] = "Honoré"
L["RESTOCKER_REPUTATION_REVERED"] = "Révéré"
L["RESTOCKER_REPUTATION_EXALTED"] = "Exalté"
L["RESTOCKER_REPUTATION_TOOLTIP_TITLE"] = "Réputation requise auprès du marchand"
--[[
    Quotes the cell's own values, which couples this line to
    RESTOCKER_REPUTATION_ANY and the four standings above: a locale that renders
    a standing differently has to say so here too.
]]
L["RESTOCKER_REPUTATION_TOOLTIP_STANDING"] =
	"Cliquez pour définir la réputation qu'un marchand exige avant que Connoisseur n'achète chez lui (\"Aucune\" achète partout), ce qui réduit aussi le prix : Amical 5%, Honoré 10%, Révéré 15%, Exalté 20%."
