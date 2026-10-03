local _, ns = ...

--------------------------------------------------------------------------------
-- Database Defaults
--------------------------------------------------------------------------------

--[[
    The single AceDB-3.0 defaults table. Features/Core.lua passes this to
    AceDB:New, which applies the defaults itself -- there is no hand-rolled
    merge. Scalar and table defaults are physically copied into the saved
    table (copyDefaults via rawset) when a scope is first accessed; only
    */** wildcard defaults resolve through a metatable. An explicit user
    value, including false, is never overridden either way.

    The consumable settings live under `profile`, so they are per-character:
    each character gets a profile of its own, named as AceDB names the
    character (its first name and surname on WoW Forever, "Name - Realm" on
    Era and TBC), and can run a different set of consumables. That is the
    point -- a level-15 alt and a raiding 60 want different buff food, scrolls
    differ by class, and two Rogues want their own poison pairs. The stock
    Profiles panel (Options/Options-Profiles.lua) is therefore meaningful:
    switching, copying, or resetting a profile moves real settings, and two
    characters share a setup only when the player puts both on one profile.

    What stays under `global` (account-wide), each for a concrete reason rather
    than convenience:
      * showWelcome    -- one login greeting per account, not per character.
      * showMacroNames -- a client-wide action-bar appearance tweak.
      * readinessReportEnabled -- a behaviour preference (does Connoisseur speak
                          up on a ready check?) rather than a consumable choice.
      * enabledMacros  -- the macros themselves are account-wide: they live in
                          the shared General macro tab, so which ones exist has
                          to be one choice for the whole account. Keeping the
                          setting here means the two agree -- a character switch
                          never adds or removes a macro, it only rewrites the
                          shared bodies to that character's best items.
      * minimap        -- LibDBIcon reads this subtable directly and owns its
                          contents (position etc.), so keeping it off the
                          profile means switching, resetting, or deleting a
                          profile never moves the minimap button.
      * ignoreList     -- the Global half of the Ignore List, hiding an
                          item from every character's macros at once; the
                          character's half keeps the same key on the profile,
                          and Features/Ignore-List.lua reads both.
      * readiness*     -- the per-category switches under
                          readinessReportEnabled, each answered once for the
                          account like the master toggle above it. Their own
                          reasons are on the keys.
      * restocker      -- the Restock Lists and the Restocker's settings,
                          shared by the account; a profile only picks which
                          list it uses. Its reason is on the key itself.
      * inventoryReport, inventory -- the item-tooltip counts and the
                          per-character snapshots behind them. Their reasons
                          are on the keys.

    The derived item cache (itemCache, with its itemCacheVersion and
    itemCacheFolder stamps) is deliberately NOT declared here:
    ns.EnsureItemCache (Features/Item-Cache.lua) creates it on the profile at
    login and after every profile change, and owns its stamp invalidation, so
    it never needs a default.

    restockList, the name of the Restock List a profile uses, is not declared
    either, because no list exists to name until a character logs in:
    ns.InitCharacterRestockList
    (Features/Restocker/Restocker-Saved-Lists.lua) gives a profile without one
    a list named for the character's class.
]]
ns.DATABASE_DEFAULTS = {
	profile = {
		--[[
		    The character's own half of the Ignore List, itemID to true: the
		    items hidden from the macros of whoever is on this profile. The
		    Global half keeps the same key on `global`, and
		    Features/Ignore-List.lua reads both.
		]]
		ignoreList = {},
		--[[
		    Use Conjured Food & Water First: the Food and Water macros rank
		    conjured items above anything that restores more (buff food still
		    comes first). Off by default like every opt-in here, and while on
		    it applies only while leveling ("leveling", below max level) unless
		    the player picks another mode from the shared list: leveling is when
		    free conjured food matters, solo or in a dungeon with a Mage friend,
		    while at max level a raider wants the best. Per-character like the
		    other consumable choices.
		]]
		useConjuredFirst = false,
		conjuredFirstMode = "leveling",
		--[[
		    Use Restock List Food & Water Last: between two items that restore
		    the same amount, the Food and Water macros pick the one not on the
		    current Restock List, whatever its Keep amount. Off by default.
		]]
		useRestockLast = false,
		--[[
		    Use Food & Water in Potion Macros Out of Combat: the Health Potion
		    macro eats the Food macro's pick and the Mana Potion macro drinks
		    the Water macro's pick while the player is out of combat, the way
		    an older add-on's single button did. Off by default.
		]]
		potionsUseFoodAndWater = false,
		combineHealthstones = false,
		includeManaRunes = false,
		--[[
		    Early re-application: with earlyReapply on, a food/scroll/pet buff
		    whose remaining time is under earlyReapplyThreshold (seconds)
		    counts as already expired, so the macros offer a fresh application
		    before a pull. See BuffCountsAsActive in Scanner-Auras.lua.
		]]
		earlyReapply = false,
		earlyReapplyThreshold = 120,
		useBuffFood = false,
		buffFoodMode = "always",
		useScrolls = false,
		scrollsMode = "always",
		scrollTypes = {
			Agility = true,
			Intellect = true,
			Protection = true,
			Spirit = true,
			Stamina = true,
			Strength = true,
		},
		--[[
		    Off by default, like every other opt-in feature here. Pet buff food
		    is a min-maxer's tool -- it needs level 55+, a live pet, and a
		    steady supply of Kibler's Bits or Sporeling Snacks -- so a new user
		    should never meet it uninvited. Leave this false.
		]]
		usePetBuffFood = false,
		petBuffFoodMode = "always",
		petBuffTypes = {
			KiblersBits = true,
			SporelingSnacks = true,
		},
		--[[
		    Explosive macro click layout: "atplayer" fires [@player] on
		    left-click and the standard toss on right-click; "toss" swaps
		    the buttons. See BuildExplosiveUseLine in Features/Macros/Explosive.lua.
		]]
		explosivesClickMode = "atplayer",
		enableDruidMacroHelper = false,
		druidReturnForm = "bear",
		enableShadowmeldDrinking = false,
		--[[
		    Stealth Eating appends the character's stealth ability to the Food
		    macro -- Stealth for Rogues, Shadowmeld for other Night Elves. One
		    key serves both; the class/race gate lives in Food.lua's appendBlock.
		    Per-character, so a Night Elf Druid enabling it never switches it
		    on for the account's Rogues.
		]]
		enableStealthEating = false,
		--[[
		    Rogue poison groups per weapon slot, keyed by ns.POISON_GROUP_BASE_ITEMS
		    group IDs (4 = Instant Poison). See ns.POISON_GROUPS in Data/Data.lua.
		]]
		mainHandPoisonGroup = 4,
		offHandPoisonGroup = 4,
	},
	global = {
		showWelcome = true,
		--[[
		    The Restock List subsystem. `lists` are the player's own named
		    shopping lists, shared by every character, and the stock Reset
		    Profile control must never reach them. Putting them on global is
		    what guarantees that -- a profile switch or reset cannot empty a
		    hand-built list or re-offer the Starter List to a character that
		    already answered it. The one thing a profile holds is which list it
		    uses, in its own restockList, so each character shops from its own
		    list and two characters on one profile share theirs.

		    The two reminder modes differ on purpose: in town you are away from
		    your bags and the detail is the whole point, while at a merchant or
		    a bank you are already looking at the window that fixes it.
		]]
		restocker = {
			lists = {},
			starterListDismissed = {},
			framePosition = {},
			restockReminderChat = true,
			restockReminderSound = true,
			restockReminderMode = "verbose",
			merchantReminder = true,
			merchantReminderMode = "simple",
			bankReminder = true,
			bankReminderMode = "simple",
			autoOpenAtBank = false,
			autoOpenAtMerchant = false,
		},
		--[[
		    The Inventory Report in item tooltips (Features/Inventory-Report.lua).
		    Ships ON, unlike the opt-ins above: it only ever adds lines to a
		    tooltip the player asked for, and never acts. The switch exists
		    because most auction add-ons print their own counts under the same
		    items, and a player running one wants a single set. A display
		    preference for the account, like showMacroNames.
		]]
		inventoryReport = true,
		--[[
		    Every character's last-known bags and bank, keyed by character (the
		    Restocker's "Name-Realm" key), each place packed into one line of
		    "itemID:count" pairs by Features/Inventory-Report.lua. Account-wide
		    because its whole point is showing one character what the others
		    hold, and never a profile: switching or resetting one must not wipe
		    what an alt was carrying. Each record also holds the character's
		    name, realm and class, and the Restock List reads the class to color
		    the characters on a list.
		]]
		inventory = {},
		--[[
		    The Global half of the Ignore List, itemID to true: items hidden
		    from every character's macros, whatever profile the character is on.
		    Outside the profiles so that it reaches all of them, and so that
		    resetting one character's profile never empties it.
		]]
		ignoreList = {},
		--[[
		    Macro-name text on the default action bars. Off by default so the
		    add-on hides the names Blizzard recently began showing again; the
		    "Enable Macro Names on Buttons" toggle reads it directly, so checked
		    means the names show (see Features/Action-Button-Text.lua).
		]]
		showMacroNames = false,
		--[[
		    The Readiness Report: on a ready check, a private report naming what
		    still needs fixing. A behaviour preference -- whether you want
		    Connoisseur speaking up at all -- rather than a consumable choice, so
		    it is answered once for the account rather than per character, and so
		    is every category switch under it.

		    Silence is the report's normal output: a category with nothing wrong
		    prints nothing, and a clean character prints nothing at all. That is
		    what lets it cover this much without becoming noise, so a switch here
		    should only ever be able to ADD a line about something broken.

		    Beta soft launch: the report ships OFF and every player opts in. The
		    key is deliberately a NEW one rather than the retired readinessReport,
		    whose saved values belong to its old meaning.
		]]
		readinessReportEnabled = false,
		--[[
		    Which categories the report covers. Each is answered once for the
		    account, like the master toggle above, and every one of them is dead
		    while readinessReportEnabled is off.

		    Three ship ON, and they share a reason: each is something another
		    player standing next to you can fix inside the few seconds a ready
		    check gives you. A Warlock can hand you a stone, a Warlock can put a
		    soulstone up, and a Mage conjures their own gem. Each also gates on
		    who can fix it, so none of the three can nag someone who cannot
		    answer it: the Healthstone on a Warlock being in the group, the
		    soulstone and the gem on the player being that class.

		    Everything else ships OFF. A report that fires on a fresh install for
		    things the player never asked about is one they switch off entirely
		    rather than tune, and the switches are cheap to find once they go
		    looking. The two potions especially: mid-pull an empty potion slot is
		    not something anyone can act on.
		]]
		-- Missing Buffs
		readinessFlask = false,
		readinessWellFed = false,
		readinessPetWellFed = false,
		readinessScrolls = false,
		readinessSoulstone = true,
		readinessMainHandBuff = false,
		readinessOffHandBuff = false,
		--[[
		    Buffs about to lapse, in seconds. Distinct from the Macros panel's
		    Buff Re-Application threshold, which decides when the MACROS treat a
		    buff as spent: this one only decides when the report mentions one,
		    covers every aura on the character rather than the tracked ones, and
		    reaches further out because a raid leader's pull timer is longer than
		    a macro press.
		]]
		readinessExpiring = false,
		readinessExpiringThreshold = 150,

		-- Missing Items
		readinessHealthstone = true,
		readinessManaGem = true,
		readinessHealingPotion = false,
		readinessManaPotion = false,
		readinessBandages = false,
		--[[
		    Percent, compared against the LOWEST equipped item rather than an
		    average: one weapon at 5% is the thing that breaks mid-pull, and an
		    average hides it behind seventeen healthy pieces.
		]]
		readinessDurability = false,
		readinessDurabilityThreshold = 20,

		-- Character
		readinessSpec = false,
		readinessPvP = false,
		readinessQuestionableGear = false,
		--[[
		    Which macros Connoisseur maintains. Account-wide because the macros
		    are: they live in the shared General macro tab, so unchecking one
		    removes the shared macro for every character. Feed Pet and Poisons
		    are class-gated on top of this toggle and build only for Hunters and
		    Rogues; the conjure-capable macros (Healthstone, Mana Gem,
		    Soulstone) are built for every class, with only their conjure clicks
		    class-gated.
		]]
		enabledMacros = {
			["Bandage"] = true,
			["Explosive"] = true,
			["Feed Pet"] = true,
			["Food"] = true,
			["Health Potion"] = true,
			["Healthstone"] = true,
			["Mana Gem"] = true,
			["Mana Potion"] = true,
			["Poisons"] = true,
			["Soulstone"] = true,
			["Water"] = true,
		},
		--[[
		    Minimap button visibility. LibDBIcon reads `hide` from this subtable,
		    so it stays the single source of truth -- the "Enable Mini-map Button"
		    toggle is its inverse (hide = false means shown). LibDBIcon owns the
		    rest of the subtable (position, etc.); living under `global`, it is
		    untouched by profile switches and resets.
		]]
		minimap = {
			hide = false,
		},
	},
}
