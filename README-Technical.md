# Connoisseur // Technical Reference

This document combines architecture notes and contribution guidance for developers working on Connoisseur. For end-user documentation, see [README.md](https://github.com/Gogo1951/Connoisseur/blob/main/README.md).

## File Map

```
Connoisseur/
├── .github/
│   └── workflows/
│       └── package.yml                          CurseForge + Wago release + library vendoring
├── .gitattributes                               Line-ending normalization
├── .gitignore                                   Dev-clutter ignore list
├── .luacheckrc                                  Lint config; skips Includes/ and .claude/
├── .pkgmeta                                     Externals and the packager ignore list
├── Consumable-Connoisseur_Vanilla.toc           Classic Era
├── Consumable-Connoisseur_TBC.toc               TBC Anniversary
├── Consumable-Connoisseur_Camelot.toc           WoW Forever
├── Data/
│   ├── Flavor.lua                               Flavor identity and the data folder to load; canonical copy
│   ├── Data.lua                                 Locale init, palette, macro config and ceilings, List Builder rows, other ID-free constants
│   ├── {Game}/                                  One complete data set per flavor: Vanilla, Discovery, TBC, Camelot, Wrath, Mists, Standard
│   │   ├── Scrolls-{Game}.lua                   Scroll types, their items and the class buffs they conflict with
│   │   ├── Bandages-{Game}.lua                  Heal amounts, First Aid skill, zones
│   │   ├── Food-and-Water-{Game}.lua            Restores, buff food, zones, and the arena column that also marks conjured
│   │   ├── Healthstones-{Game}.lua              Every item on the Healthstone cooldown, with required levels
│   │   ├── Soulstones-{Game}.lua                Stone values plus the soulstone buff IDs
│   │   ├── Mana-Gems-{Game}.lua                 Gem and rune mana
│   │   ├── Conjured-Items-{Game}.lua            The items each conjure spell makes
│   │   ├── Potions-{Game}.lua                   Health and mana restores, zones, Alchemy requirement
│   │   ├── Pet-Foods-{Game}.lua                 Food level, diet, price and the quests that consume it
│   │   ├── Poisons-{Game}.lua                   Poison ranks and each group's base item
│   │   ├── Explosives-{Game}.lua                Damage, Engineering skill and the specialization gate
│   │   ├── Consumable-Upgrade-Paths-{Game}.lua  Every upgrade ladder, with the tiers this client sells
│   │   ├── Poison-Recipes-{Game}.lua            Crafted poison to reagent rows, with this client's counts
│   │   ├── Elixirs-{Game}.lua                   Flask and elixir buff IDs
│   │   ├── Questionable-Equipment-{Game}.lua    Non-combat gear the Readiness Report can only name by ID
│   │   ├── Game-IDs-{Game}.lua                  Single spell IDs (stealth, druid forms, Poisons, pet spells, professions) and the pet buff foods
│   │   ├── Macro-Default-Items-{Game}.lua       The item each macro shows while the bags hold none
│   │   ├── Conjure-Spells-{Game}.lua            Conjure spell ranks and the missing-spell tip IDs
│   │   └── Well-Fed-Buffs-{Game}.lua            Extra Well Fed buff IDs and the Well Fed icons
│   └── Default-Settings.lua                     The AceDB defaults, with each account-wide key's reason
├── Features/
│   ├── Core.lua                                 Dispatcher, AceDB lifecycle, migration calls, update throttle
│   ├── Utilities.lua                            Colors, client-difference accessors, legacy API shims, spell and mode predicates
│   ├── Announcements.lua                        The branded chat print and the welcome message
│   ├── Item-Cache.lua                           Consumable cache, session item memo, item-info waiters
│   ├── Scanner-Character.lua                    Profession skills and the session constants (race, class, spell caches)
│   ├── Scanner-Auras.lua                        The aura snapshot, Well Fed, scroll and pet-food buff probes, UNIT_AURA
│   ├── Scanner-Inventory.lua                    Bag scan, usability gates, the RANKING_PRIORITY ladder
│   ├── Macros/
│   │   ├── Signatures.lua                       Target and group signatures, the friendly-player test
│   │   ├── Smart-Spell.lua                      Conjure rank resolution (ns.GetSmartSpell)
│   │   ├── Writer.lua                           Macro create, edit and delete, the full-book warning
│   │   ├── Body-Builder.lua                     Standard body, conjure block and state key, the 255 trim, the combo body
│   │   ├── Engine.lua                           Definition registry and protocol, the update loop, the switch setter
│   │   ├── Runtime.lua                          The globals macro bodies call, plus the short-name bridge
│   │   ├── Tools-Mages.lua                      Mage conjure resolvers (food, water, gem, table)
│   │   ├── Tools-Warlocks.lua                   Warlock conjure resolvers (healthstone, soulstone, soulwell)
│   │   ├── Tools-Rogues.lua                     The Poisons macro, start to finish
│   │   ├── Tools-Hunters.lua                    Pet food, the pet-buff override, and the Feed Pet macro
│   │   ├── Bandage.lua                          Definition
│   │   ├── Explosive.lua                        Definition plus the click-layout use line
│   │   ├── Food.lua                             Definition: buff food, pet-buff override, scroll-only mode, Stealth Eating
│   │   ├── Food-and-Potion.lua                  Definition: the Food winner out of combat, Health Potion lines in it
│   │   ├── Health-Potion.lua                    Ranked definition plus optional Healthstone stacking
│   │   ├── Healthstone.lua                      Ranked definition
│   │   ├── Mana-Gem.lua                         Ranked definition plus the opt-in runes
│   │   ├── Mana-Potion.lua                      Ranked definition
│   │   ├── Soulstone.lua                        Definition
│   │   ├── Water.lua                            Definition plus the Shadowmeld drinking line
│   │   ├── Water-and-Potion.lua                 Definition: the Water winner out of combat, Mana Potion lines in it
│   │   └── Integration-Druid-Macro-Helper.lua   DruidMacroHelper powershift wrapping (HP, MP, HS)
│   ├── Action-Button-Text.lua                   Macro-name visibility on the default action bars
│   ├── Readiness-Report-Probes.lua              Stateless live reads: auras, weapons, gear, talents, PvP
│   ├── Readiness-Report.lua                     What the report says, and when it stays quiet
│   ├── Ignore-List.lua                          Both ignore lists, scopes, promotion, logout pruning
│   ├── Restocker/                               The Restock List, behind /crs
│   │   ├── Restocker-List.lua                   The New group, adding an item, item-info waits and retries
│   │   ├── Restocker-Saved-Lists.lua            Named lists: add, rename, copy, delete, switch, class names
│   │   ├── Restocker-Saved-Format.lua           The one-line saved format, inflate and deflate
│   │   ├── Restocker-Saved-Migration.lua        Saved-data migrations, removed after 2026-10-18 (see Migration Chain)
│   │   ├── Restocker-Bags.lua                   Bag and bank slot scans and single-move primitives
│   │   ├── Restocker-Bank.lua                   Withdraw and deposit engine: coroutine, pacing, watchdogs
│   │   ├── Restocker-Merchant.lua               Purchase orders, Buy Extra, the buy loop, the grocery list
│   │   ├── Restocker-Crafting-Reagents.lua      Poison recipe resolution and the reagent order
│   │   ├── Restocker-Upgrade.lua                The ladder index and level-up upgrades
│   │   ├── Restocker-Window.lua                 Frame, geometry, top control row, add box, shared tooltip
│   │   ├── Restocker-Window-Columns.lua         Columns, measured widths, shared colors, header, the layout walk
│   │   ├── Restocker-Window-Filter.lua          What shows, in what order, under which category; no frames
│   │   ├── Restocker-Window-Rows.lua            Row controls, the reputation menu, the render loop
│   │   ├── Restocker-Window-Categories.lua      The category pane and its selection state
│   │   ├── Restocker-Window-Footer.lua          The list selector, Copy, Delete and Rename
│   │   ├── Restocker-Starter-List.lua           List Builder: offers, ticks, dismissal, login trigger
│   │   ├── Restocker-Reminders.lua              Town, bank and merchant shortfall reminders
│   │   ├── Restocker-Events.lua                 Startup, merchant, bank, level-up and logout handlers, the handler table
│   │   ├── Restocker-Slash-Command.lua          The /crs dispatcher (registered in Options/Options.lua)
│   │   └── Tests/                               Dev-only offline suites (see Offline Test Suites)
│   ├── Diagnostics.lua                          Runtime-only reports, event-log filters, Validate Data
│   ├── Minimap-Button.lua                       LDB object, tooltip, click handlers
│   └── Tests/                                   Dev-only offline suites (see Offline Test Suites)
├── Includes/
│   ├── Images/
│   │   └── Connoisseur.tga                      Add-on icon (## IconTexture)
│   ├── Libraries/                               Vendored libraries, never edited by hand
│   └── Sounds/
│       └── Low-Battery.ogg                      The town reminder's alert sound
├── Locales/                                     AceLocale strings
├── Options/
│   ├── Options-Utilities.lua                    Shared widgets, item-cache warmer, item-list builder
│   ├── Options-General.lua                      Root panel: welcome, mini-map, commands, links, version
│   ├── Options-Macros.lua                       Which macros exist, and how each behaves
│   ├── Options-Ignore-List.lua                  Tree panel: Global, then each character with entries
│   ├── Options-Restocker.lua                    Reminders, List Builder toggle, auto-open, Praise
│   ├── Options-Starter-List-Popup.lua           The List Builder window; never added to the Blizzard tree
│   ├── Options-Readiness-Report.lua             Master switch, category switches, thresholds, Reset
│   ├── Options-Profiles.lua                     Stock AceDBOptions-3.0 panel
│   ├── Options-Diagnostics.lua                  Diagnostic Tools panel
│   └── Options.lua                              Registration, the options opener, /foodie and /crs
├── LICENSE                                      MIT
├── README.md                                    End-user documentation
├── README-Notes.md                              The maintainer's settled exceptions and decisions
├── README-Technical.md                          This file
└── README-Testing.md                            Manual test plan
```

Within each folder, files are listed in TOC load order, which is dependency-first, and the two `Tests/` folders, which no TOC loads, close their folders. A file that reads another file's tables while it loads must come after it: `Data/Flavor.lua` opens the `# Data` block because any file may read the flavor, `Restocker-Upgrade.lua` indexes the ladders, and `Scanner-Auras.lua` derives its scroll lookups from `ns.SCROLL_DATA`.

**Static game data lives in seven flavor folders, one complete copy per flavor** (Style Guide → DATA → Flavor Folders). Each TOC lists `Data/Flavor.lua`, `Data/Data.lua`, its own folder, then `Data/Default-Settings.lua`; the Vanilla TOC lists `Data/Vanilla/` and then `Data/Discovery/`, whose files open with opposite `ns.IS_DISCOVERY` guards, so a Season of Discovery realm builds only Discovery's tables. No TOC lists `Data/Wrath/`, `Data/Mists/` or `Data/Standard/`: they are forward-prep for flavors that have no TOC yet. Every folder declares the same tables whole, an empty one where the flavor has no rows, so feature code never checks which flavor built a table, and no row carries an expansion tag: which tiers and recipes a client gets is its folder's contents. Discovery started from the pre-split tables as the Classic Era client loaded them, and Camelot as a copy of Vanilla; Wrath, Mists and Standard started from TBC's rows, and most of their files also carry the rows the pre-split tables tagged for Wrath. Each file's source block names the folder or client its rows came from, and a row Validate Data flags NOT ON CLIENT is pruned from the folders that client loads, never from another client's. Season of Discovery items live in `Data/Discovery/` alone (README-Notes). `Data/Data.lua` holds no item, spell or buff ID: the diet, poison-group and scroll-order constants and the List Builder rows stay there, and every game ID, the macros' default items included, lives in the folders.

Three names for one add-on, and they do not all match. The GitHub repo is `Connoisseur`. The installed folder is `Consumable-Connoisseur`, and the CurseForge slug is the same name in lowercase, which is why the TOCs carry that name and `ADDON_NAME` reads that way. The in-Lua brand identity is `Connoisseur`, pinned once as `ns.LOCALE_NAME` in `Data/Data.lua` and reused for the AceLocale lookup, the LibDBIcon key and the LDB object name. The TOCs' `## Title` and the H1 of `README.md` are deliberately `Connoisseur & Restocker`, for discoverability; every other surface says Connoisseur.

`.pkgmeta`'s ignore list strips the repo scaffolding above the TOCs, `LICENSE` and both `Tests/` folders, so a copy installed from CurseForge or Wago carries none of them.

Every file inside a `Features/` feature subfolder carries the feature name in its basename, so an editor tab or a stack trace identifies itself without the folder: `Restocker-Window.lua`, never `Window.lua`. `Features/Macros/` is the one exception and keeps its own names. Inside it, a definition file owns what a macro is, a `Tools-*` file owns what a class knows, and an `Integration-*` file owns another add-on's syntax. The Rogue and Hunter tool files also carry their class's whole custom macro, since neither Poisons nor Feed Pet is a bag-scan winner.

The whole add-on hangs off the shared namespace with **dot functions only**. Nothing on `ns` takes `self`, including the Diagnostics framework and the options opener, where the Style Guide's snippets show colon methods. Names that would be ambiguous on a shared namespace carry the feature word (`ns.ShowRestockWindow`, not `ns.Show`).

Files that must stay gone:

- The pre-split layout: the unsuffixed `Consumable-Connoisseur.toc`, and the flat `Data/*.lua` tables (`Bandages.lua` through `Starter-List-Categories.lua`) that the flavor folders replaced, along with `Data/Data.lua` for the List Builder rows.
- The pre-restructure `Features/Macro-*.lua` layout.
- The pre-rename Restocker set: `Bag.lua`, `Bank.lua`, `Bank-Restock.lua`, `BuyCommand.lua`, `BuyIngredients.lua`, `Cache.lua`, `Containers.lua`, `Events.lua`, `Inventory.lua`, `Item.lua`, `KvEnv.lua`, `List.lua`, `List-Categories.lua`, `ListFrame.lua`, `MainFrame.lua`, `Merchant.lua`, `Module.lua`, `Profiles.lua`, `Recipe.lua`, `Restocker.lua`, `RestockerClass.lua`, `RestockerConf.lua`, `Settings.lua`, `StarterList.lua`, `Upgrade.lua`, and the annotation-only `Specs/` stubs. Its module registry and flavor-flag duplicate are dissolved into the namespace and `Data/Flavor.lua`.
- The Readiness Report's earlier names: `Features/Readiness.lua`, `Features/Readiness-Probes.lua` and `Options/Options-Readiness.lua`.
- The CamelCase suite names: `ReadinessTest.lua`, `BuyExtraTest.lua`, `ColumnLayoutTest.lua`, `ReagentBuyTest.lua`, `RestockPlannerTest.lua` and `UpgradeLevelTest.lua`.

## Architecture

### Event Loop

`Features/Core.lua` owns one frame and one dispatcher. Feature files never register events on frames of their own, the Restock List included; Diagnostics' Event Registration check is the one exception, and its probe frame has no handler: it registers each name and releases it at once, only to learn whether this client knows the event. A feature that needs an event only some of the time asks for it through `ns.SetEventRegistered(event, enabled, ...)`, which registers on Core's frame (unit-filtered when units follow), so the event still routes through the dispatcher and into the Diagnostics event log. Every event name is listed once in `ns.EVENT_NAMES`, which both the registration loop and that Event Registration check read, so the two cannot drift.

`PLAYER_LOGIN` runs three steps in a fixed order: the database (with the migration chain), then `ns.InitializeRestocker`, then the arrival state. The order matters because `ns.InitCharacterConstants`, called inside the database step, sets `ns.isHunter`, which the arrival step reads to decide `QUEST_LOG_UPDATE`'s registration.

Five of those names are in `DEFERRED_EVENTS`, which the plain registration loop skips:

| Event | How it registers |
|---|---|
| `UNIT_PET`, `UNIT_SPELLCAST_SUCCEEDED` | `RegisterUnitEvent` on `player`, at load |
| `UNIT_AURA` | On `player` and `pet`, only while buff food, scrolls or pet buff food is on and its mode is active, pet buff food only on a flavor whose `ns.PET_BUFF_FOODS` has rows (`ns.UpdateAuraTracking`, which re-registers only when that wanted state flips, since every bag scan passes through it) |
| `QUEST_LOG_UPDATE` | Hunters only, re-decided on every arrival in `RefreshArrivalState` |
| `GET_ITEM_INFO_RECEIVED` | Only while a waiter holds it (`ns.RequestItemInfoEvents` / `ns.ReleaseItemInfoEvents`, `Features/Item-Cache.lua`) |

`GET_ITEM_INFO_RECEIVED` fires once for every item the client resolves, a flood during login, so it stays registered only while somebody is waiting. Its waiters are `"scan"` (the bag scan), `"restocker"` (the Restock List) and one `"options:" .. registryName` for each options panel still warming item rows (see Item Data Caching). They are keyed rather than counted: a waiter that asks twice must not have to release twice, and the last one out unregisters. While it is registered, only an answer for an item in the consumable tables (`ns.HasRawData`) requests a macro rebuild, since `ns.CacheItemData` is the one macro input that reads item info; every other answer only reaches the Restock List and options handlers.

Rebuilds funnel through `ns.RequestUpdate()`. A two-flag throttle (`isUpdatePending`, `isTickScheduled`) arms a 0.5 second `OnUpdate` tick, and the timer resets only when a fresh tick is armed, so a burst of requests rebuilds half a second after the first of them rather than debouncing to the last. The flags are separate so pending work can never strand: any out-of-combat request re-arms a disarmed tick. `ns.MarkUpdatePending()` records work without arming the tick, for a deferral that something else is certain to replay. Every arrival in the world requests a rebuild at once and again 3 seconds later, past the loading-screen flurry. The one caller that skips the throttle is an Ignore List edit, which wipes the macro state and calls `ns.UpdateMacros(true)` at once, relying on the deferral guards inside it.

A rebuild is a full bag rescan, so the four firehose events diff their inputs before requesting one:

- `PLAYER_TARGET_CHANGED` fires on every tab. `ns.TargetSignatureChanged()` compares the only three target facts a body uses: whether it is a friendly player (scroll suppression), whether it is the player (plain-food mode) and, for a friendly player only, its level (the conjure downrank cap), so tabbing between mobs of different levels rebuilds nothing. Anything new that reads the target must join this signature, or its macro goes stale. The is-the-player reading refreshes only while `C_Secrets.CanCompareUnitTokens("target", "player")` allows it; otherwise it keeps its last value, so a restricted read counts as no change (see Forever).
- `GROUP_ROSTER_UPDATE` fires on every raid roster change. `ns.GroupSignatureChanged()` compares only whether the player is grouped and whether the group is a raid, the inputs of the solo, party and raid modes.
- `UNIT_AURA` goes to `ns.OnUnitAura` (`Features/Scanner-Auras.lua`). While buff food or scrolls is live, it requests only when the Well Fed state changes or, for an enabled scroll type, the scroll buff's expiration or the largest conflicting class buff moves. Pet auras request whenever pet buff food is on and the flavor has one; they change rarely. The handler and `ns.UpdateAuraTracking` decide what is live through one shared gate, `PlayerAuraFeaturesActive`, because a diff against a feature the tracker is not tracking would read as a change on every firing: the scan resets that feature's state.
- `QUEST_LOG_UPDATE` fires on every objective tick. `ns.PetFoodQuestsChanged()` (`Features/Macros/Tools-Hunters.lua`) requests only when the set of active quests that consume pet food changes.

The signatures start unset, so the first reading always counts as a change. `ns.ResetMacroState()` clears the target and group signatures (and the scroll-aura baseline) along with the macro state keys; the pet-food quest signature is never reset.

The aura and quest diffs run only out of combat: below the lockdown guard those two skip their diff and simply mark the update pending, so one unrelated aura or quest tick mid-fight still costs one rebuild when combat ends. Every scan also refreshes the baselines those two compare against (`ns.UpdateAuraTracking` records the scroll readings and `ns.ScanPetFood` the pet-food quest signature), so a buff or quest that changes mid-fight and changes back afterwards still reads as a change against what the macros were last built from. The target and group diffs run above the guard instead (see Combat Lockdown).

`UNIT_SPELLCAST_SUCCEEDED` is filtered too: it rebuilds only for a spell in `ns.spellCache`, every `ns.CONJURE_SPELLS` ID this client resolves (`Features/Scanner-Character.lua`), and skips a spell ID `ns.IsSecretValue` calls secret.

Besides the cold-scan retry (see Item Data Caching), one rebuild has no event behind it. With early re-application on, a tracked buff counts as spent once its remaining time drops under the threshold, and nothing announces that moment, so `BuffCountsAsActive` schedules a one-shot rebuild for when it crosses (`ScheduleExpiryRecheck`). `C_Timer.After` cannot be cancelled, so it tracks the earliest pending fire time and later timers no-op.

### Combat Lockdown

Macros cannot be written in combat, so writes defer rather than fail. Below its lockdown guard the dispatcher only marks the update pending, `ns.RequestUpdate()` in combat records the work without arming the tick, a tick that finds combat disarms itself, `ns.UpdateMacros()` re-requests whenever it is reached in combat (an Ignore List edit mid-fight does exactly that), and `PLAYER_REGEN_ENABLED` replays whatever is pending.

Some paths refuse instead of deferring:

- **The options opener.** `ns.OpenOptionsPanel` (`Options/Options.lua`) checks `InCombatLockdown()` before any routing, prints `CHAT_OPTIONS_IN_COMBAT` and returns, never queuing the open for later. Blizzard's Settings panel is protected in combat, so opening it would raise `ADDON_ACTION_BLOCKED` naming the add-on. `/foodie`, `/crs config` and the mini-map button's Shift + Middle-Click all go through this one entry point, so they answer identically. It routes by the category ID that `ns.RegisterOptionsPanels` captured from the root panel's `AddToBlizOptions` (`ns.optionsFrames.categoryID`, opened through `Settings.OpenToCategory`), never by title, since a title lookup falls through to a floating window on TBC Anniversary. Only a missing `Settings.OpenToCategory` or category ID reaches the standalone `AceConfigDialog:Open` fallback.
- **The List Builder's login offer.** A fresh login still in combat when the offer's 3-second timer fires skips it silently and never replays it; the empty list is still empty at the next login.

Several branches run above the dispatcher's guard, because each must work mid-fight and none touches a protected function:

| Event | Why it runs in combat |
|---|---|
| `PLAYER_LOGIN` | `ns.db` must exist even when the player enters the world already fighting (zoning into a running battleground). |
| Restock List handlers | A merchant or bank window cannot open in combat, and a logout mid-fight must still pack the lists for the saved-variables file. A handler does not consume its event: the dispatcher carries on to Core's own branch for it, if there is one. |
| `GET_ITEM_INFO_RECEIVED` | An options panel waiting on the item repaints mid-fight, and an answer for anything outside the consumable tables stops here, so only a consumable's answer reaches the guard. |
| `UI_ERROR_MESSAGE` | The wrong-zone report fires exactly when a zone-locked potion is pressed mid-fight; the dead-pet branch only flips a flag and requests a rebuild, which defers itself. |
| `UNIT_PET` | A pet revived or called mid-fight must clear the dead-pet flag at once, or the Feed Pet macro keeps offering Revive Pet; the handler only flips that flag and requests a rebuild, which defers itself. |
| `PLAYER_LEVEL_UP` | A killing-blow ding fires in combat. The event's own level and `C_Spell.GetSpellName` are safe reads; the macro write still defers. |
| `PLAYER_LOGOUT` | A mid-combat `/reload` still fires it, and the Ignore List prune must run. |
| `READY_CHECK` | Ready checks routinely land with the raid already pulling, and the report only reads. |
| `PLAYER_TARGET_CHANGED`, `GROUP_ROSTER_UPDATE` | Behind the guard, a change made mid-fight would leave the signature at its pre-fight reading, so changing back after combat would read as no change and keep the macros built for the fight. |

Everything else waits behind the guard, with two consequences. `ZONE_CHANGED_NEW_AREA` cannot refresh the cached map mid-fight, so `ns.ScanBags()` re-reads the map at the start of every scan. And a login or `/reload` that lands in combat skips `PLAYER_ENTERING_WORLD`'s own branch, so the welcome print, the macro-name visibility and the 3-second second rebuild wait for the next loading screen out of combat; only the pending rebuild replays when combat ends.

### Macro UI Deferral

The open Blizzard Macro UI is treated like combat. `MacroFrame` saves its edit box back over the selected macro when the selection changes and when it closes, so a body written while the frame is open never shows (the frame does not refresh) and is then reverted. With the state key already recording the new body, nothing would rewrite it until that key next changed.

`ns.UpdateMacros()` therefore leaves the work pending while `MacroFrame:IsShown()`, through `ns.MarkUpdatePending()` so an open frame does not keep re-arming the throttle, and an `OnHide` hook, installed once, wipes every state key and requests a full rebuild each time the frame closes, which also heals a hand-edit of a Connoisseur macro. The hook is armed at the top of every update pass, not from inside the deferral branch: the frame is load-on-demand, and a short visit that requested no update would otherwise never arm it. One gap survives by design, a first open-and-close with no update in between.

A `forced` rebuild wipes the standard macros' state table ahead of both deferral guards, so a force that arrives in combat or with the Macro UI open keeps its force: the deferred pass runs unforced, and only the wiped state guarantees it rewrites bodies whose key never changed. Feed Pet and Poisons keep state keys of their own, which only `ns.ResetMacroState()` clears, so a caller that forces calls that first, as the Ignore List does.

### Scan, Compose, Write

1. **Scan.** `ns.ScanBags()` (`Features/Scanner-Inventory.lua`) re-reads the map, reconciles aura tracking (a group or mode change has no tracking call of its own) and then settles `ns.allowBuffFood` and `ns.allowConjuredFirst`. That order is load-bearing: buff food reads the Well Fed state the tracking call refreshes, and both flags must be settled before the dispatch below, where Food's and Water's `accepts` read them. `ns.UpdateAuraTracking` returns the player aura snapshot it took, and the scan hands that same snapshot to `ns.FindScrollOverrides`, so one scan walks the player's auras at most once. It walks bags once, resolves the scroll and pet-buff overrides (both nil in an arena), and skips every scroll item, which the scroll override owns. Each remaining consumable passes the usability gates: required level; First Aid, Alchemy and Engineering skill; an Engineering specialization spell (`requiredSpellID`, checked live so learning Goblin Engineer applies at the next `SPELLS_CHANGED`); the zone set against the current map; the arena-only drinks, which are unusable outside an arena; and the arena rules, under which potions drop out and, of the food and drink, only conjured food and water and the arena-only drinks survive, while every other type stays usable. Arena state comes from `IsInInstance()`, never a zone-ID list. A usable item then goes to every registered definition whose `itemTypes` claims its cached `itemType` and whose optional `accepts(data)` passes (Health Potion needs a heal, Mana Potion needs mana, Food and Water refuse buff food while `ns.allowBuffFood` is off, and Mana Gem takes runes only with `includeManaRunes`), deliberately not to the first match only: a potion restoring health and mana feeds both potion macros, and a food-and-drink item feeds Food and Water. An item on either Ignore List stops there: instead of competing it only marks those categories in `ns.scannedIgnoredTypes`, which the Readiness Report reads.

   The scroll and pet-buff overrides read the raw bag counts rather than this dispatch, so none of its gates or its ignore check applies to them: each re-checks the level and `ns.IsIgnored` itself, and any new override must do the same.
2. **Compose.** `ns.UpdateMacros()` (`Features/Macros/Engine.lua`) walks the registered definitions. A disabled macro is deleted. Otherwise the body comes from the first of: the definition's `buildModeOverride` (Food's scroll-only mode), the Druid Macro Helper override (`ns.BuildDruidMacroOverride`), or the standard body assembled from the definition's hooks. The definition protocol, every selection field and body hook, is documented at the top of `Engine.lua`. The canonical standard body is:

   ```
   #showtooltip item:13446
   /run ConnoisseurFire(13446)
   /use item:13446
   ```

   Custom definitions (Feed Pet, Poisons) then run their own `customUpdate` and never reach the ranking ladder.
3. **Write.** `ns.WriteMacroBody()` is the one writer for every macro, standard or custom. It creates a missing macro in the shared General tab with the question-mark icon, so `#showtooltip` decides what the button shows, and edits only when the body differs. The state key is recorded only when the write landed, so a create that failed on a full macro book retries on the next pass. Creation respects `ns.MACRO_SLOT_CUSHION` (0, so it pauses only when the General book is full), warns once per session and retries on every later update pass, so it resumes once a slot frees.

The ranking is one ordered list, `RANKING_PRIORITY`, and its order is the whole specification:

`isBuffFood` (only while the definition sets `allowBuffFood` and `ns.allowBuffFood` holds) → `isConjured` (only while the definition sets `allowConjuredFirst` and `ns.allowConjuredFirst` holds) → `isPercent` → `value` (higher; the raw restore or damage) → `isConjured` → `hasZones` → `isSoulbound` → `price` (lower) → `isHighStack` (max stack over 10) → `isHybrid` (Food prefers hybrids; Water and the ranked lists prefer dedicated items) → `count` (lower) → `id` (lower)

The three burn-first steps are ordered by shelf life, so the copy worth least to you soonest is spent first: conjured is gone at logout, zone-locked is dead weight outside its zone, and soulbound keeps its value only for this character. They sit below `value` deliberately (a zone-locked Superior Mana Draught at 560 must never beat a Super Mana Potion at 1800 in a battleground); the one exception is the gated `isConjured` near the top, which puts conjured food and water above `value` only because the player asked for it. They are ladder steps rather than bonuses folded into `value`, because a bonus can outweigh a real restore difference and two equal bonuses cancel instead of ranking. `price` sits above `isHighStack` because a price of 0 means the item has no vendor value at all, so using it forgoes nothing. The final `id` step makes the pick deterministic, so an in-session rescan and a `/reload` always agree and equal ranks never churn rewrites. A percent restore stores a placeholder `value`, so percent items tie there and rank on the steps below.

Both comparator forms, the single running winner and the ranked lists' sort, are generated from that list by `CompareRecords`, and every record on either side of a comparison is built by the one `FillRecord`. Booleans compare raw, never coerced, which is only safe because every flag reaches `FillRecord` as a real `true` or `false`. `CompareRecords` also returns the step that decided, which is what the Item Selection report prints. The `ranked` definitions (the four multi-use types) collect every candidate and sort once; everything else keeps a running winner. The ranked sort passes `allowBuffFood`, `allowConjuredFirst` and `preferHybrid` as off, so none of the three does anything on a ranked definition. The per-category tables are built lazily on the first scan, because the definitions register from files that load after the scanner, and only once, so a definition must register while its file loads: one registered after the first scan has no table, and the scan indexes nil.

The scan publishes what it saw: `ns.bestSelection` (the per-category winner records), `ns.scannedItemCounts` and `ns.scannedItemLinks`. All three are wiped and refilled in place on every pass, so they are the last scan's snapshot: read them, never retain them, and never write to them from outside `ScanBags`. They are only as fresh as the last pass that actually ran, which combat or an open Macro UI holds back. A ranked type's `ns.bestSelection` entry carries only `id`, `value`, `price`, `count` and `topIDs`; its ladder flags stay at their reset values and it has no `link`.

### Item Data Caching

Two caches sit side by side in `Features/Item-Cache.lua`, and they answer different questions.

**The consumable cache.** `ns.CacheItemData` derives one canonical record per consumable into `ns.db.profile.itemCache`: restore or damage values, skill and specialization requirements, the zone set, and the buff-food, percent, arena and conjured flags from the consumable tables (`ns.FOOD_AND_WATER`, `ns.POTIONS`, `ns.HEALTHSTONES`, `ns.SOULSTONES`, `ns.BANDAGES`, `ns.MANA_GEMS`, `ns.MANA_RUNES`, `ns.EXPLOSIVES`), plus what it reads once from `C_Item.GetItemInfo`: the required level (which `ns.HEALTHSTONES` overrides from its own column), vendor price, max stack, and `isSoulbound`, which is bind type 1 (bind on acquire; bind on use stays tradeable until consumed, so it is deliberately not soulbound). An item none of them carries (`ns.HasRawData`) returns `"IGNORE"` without calling the item API and without being cached, so the cache holds consumables only and a cold non-consumable never arms a rescan; a stored `"IGNORE"` left by an older build is cleared on sight. The cache is not declared in the defaults: `ns.EnsureItemCache` creates it on the profile at login and after every profile change. Invalidation is two-layered. A version stamp (`itemCacheVersion ~= ns.Version`) wipes it on release bumps, and a nil-test of the newest cached fields in `ns.ScanBags` catches a same-version build that adds a field, since a dev copy's version always reads `Dev`. The newest field today is `itemID`. Nothing catches a same-version change to a table value or to how an existing field is derived: a dev copy keeps its old records until the cache is wiped by a release bump or Reset Profile.

**The session memo.** `ns.GetItemData` remembers every `C_Item.GetItemInfo` answer this session, keyed by whatever it was asked with (an id on the hot paths, a link at a merchant). It answers for any item at all and is thrown away at logout. `ns.GetItemHyperlink` rides on it and returns a clickable link for any id, hand-building a white `|Hitem:|` link while the item is cold.

A miss is remembered only while somebody is waiting on `GET_ITEM_INFO_RECEIVED`, and only when it was asked by id; the last waiter out drops every remembered miss. The client announces each answer once, and with the event unregistered it lands unheard, so a miss remembered while nobody listens would outlive the answer: a Restock List row stuck on a question-mark icon, or an add, upgrade or recipe parked for an answer that already came. While a waiter listens, every answer reaches `ns.OnRestockerItemInfoReceived`, which calls `ns.ForgetItemDataMiss` before retrying anything. The one exception is an answer reporting that the item does not exist, which is skipped, so that miss stays remembered. Misses are not scoped to a frame with `GetTime()` instead, because that clock can read the same across consecutive frames. The price is a fresh API call for each ask while nothing waits.

**Cold scans.** A scan that meets an unresolved consumable returns `dataRetry`. `ns.RegisterDataRetry` holds the `"scan"` waiter and arms a 2 second rescan with a budget of `DATA_RETRY_MAX_ATTEMPTS` (10), because a scan that ends unresolved arms the timer that starts the next scan, so an id the server never answers would otherwise spin forever. The event stays registered past the budget, since a late answer still rebuilds, and a clean scan (`ns.UnregisterDataRetry`) refunds the budget and releases the waiter.

**Options panels.** `ns.WarmItemCache` (`Options/Options-Utilities.lua`) requests item data for the ids a panel is showing and holds a `GET_ITEM_INFO_RECEIVED` waiter keyed by the panel's registry name (`"options:" .. registryName`) while any of them is outstanding, so an item row never sits on a bare id. Core hands every answer to `ns.OnOptionsItemInfoReceived` right after the Restocker's handler has forgotten the item's remembered miss; the panels waiting on that id repaint through `NotifyChange`, and a panel with nothing left outstanding releases its waiter. A failed answer settles the wait too and is remembered for the session, so the repaint that follows does not ask again. An id `C_Item.DoesItemExistByID` rejects is never requested at all, and the add boxes refuse one (the Restock List's with a chat line), because its answer never comes and a wait on it would hold the event for the rest of the session. A call while ids are still pending (the repaint re-entering with still-cold ids, or a row added mid-load) adds to that panel's set.

### State Encoding

Every input that affects a macro body must appear in its state key, or the macro goes stale. Standard keys are item-led:

```
ITEMIDS(+HS:stackIDs)?(_C(_M:id)?(_R:id)?(_MR:key)?(_MM:key)?(_NI:key)?)?(_EX:mode)?(_SM|_SE)?
```

`ITEMIDS` is the single itemID, the literal `none` when there is no item, or the comma-joined ranked list for the multi-use types, so a change in any fallback rank also rewrites. `+HS:` carries Health Potion's stacked Healthstones, the `_C` group carries the conjure clicks and their not-yet-learned tips, `_EX:` carries the Explosive click layout, and `_SM` / `_SE` mark the Shadowmeld drinking and Stealth Eating lines.

Namespaces are disjoint by prefix, so any transition into or out of a mode forces a rewrite: Food's scroll-only mode keys under `SCROLLS:`, the combo macros under `COMBO:` (their combat ids, then their rest item) and the Druid Macro Helper override under `DMH:`, which also carries the return form's spell ID, so learning Dire Bear Form rewrites a body still returning to Bear Form. Poisons (`K` or `NK` plus each hand's item) and Feed Pet (knowledge tier, food item, dead-pet flag) keep their own keys under the same lossless rule.

## Macro Runtime Globals

A macro body's `/run` executes in the global environment, which cannot see the add-on namespace, so `Features/Macros/Runtime.lua` defines the six globals the bodies call, each with the full `Connoisseur` prefix:

- `ConnoisseurFire(itemID)` rides in every standard body that has an item and in every Druid Macro Helper body, and stamps the item and the time. When `ERR_ITEM_WRONG_ZONE` arrives within a second of it, `ns.OnMacroUiErrorMessage` prints a bug report naming the item, zone, subzone and map ID, which is how a wrong zone set in `Data/` gets reported with everything needed to fix it. The scroll-only, no-item, Poisons and Feed Pet bodies never call it, so a wrong-zone error from one of those prints no report. The call is short on purpose: it spends bytes in every body against the 255 ceiling.
- `ConnoisseurFireIf(condition, itemID, altItemID)` stamps `itemID` when a macro conditional matches and `altItemID` otherwise, with the same sentinel as `ConnoisseurTipIf`. The Food & Potion and Water & Potion bodies call it with `[combat]` when both halves have an item, and `ConnoisseurFire` when only one does.
- `ConnoisseurTip(key)` prints a canned tip: static text from `ns.TIP_MESSAGES`, or "you don't currently know" a spell from `ns.MISSING_SPELL_MESSAGE_IDS`, resolved through `C_Spell.GetSpellName` at press time so the name is localized and a spell absent from this client prints nothing.
- `ConnoisseurTipIf(condition, key)` fires the tip only when a macro conditional matches. It appends a sentinel ` 1` so `SecureCmdOptionParse` returns a clean truthy value.
- `ConnoisseurNoItem(typeName)` prints the no-item line. The type key stays English inside the body, so bodies and state keys are locale-independent, and resolves to its localized label at press time.
- `ConnoisseurNoItemIf(condition, typeName)` prints the no-item line only when a macro conditional matches, with the same sentinel as `ConnoisseurTipIf`. The Food & Potion and Water & Potion bodies use it for a half with nothing in bags.

Until 2026-10-18 the short names `ConnFire`, `ConnTip`, `ConnIf` and `ConnNoItem` remain as globals (MIGRATION): `ConnTip` and `ConnIf` translate the old tip keys, and the other two are plain aliases. A body saved by an older build calls them until Connoisseur rewrites it, which waits out combat and an open Macro UI, and a press before then would otherwise raise a Lua error.

## Food and Water: Modes and Overrides

The Food definition (`Features/Macros/Food.lua`) is the busiest:

- **Buff food.** Buff food competes only while the scanner's `ns.allowBuffFood` holds (the setting, its mode, not already Well Fed, not targeting yourself, not in an arena), and while it holds, the ladder prefers buff food outright. Water uses the same gate. Targeting yourself is a deliberate testing aid: it switches off buff food and scrolls, so you can see what the macro picks without re-toggling settings.
- **Conjured first.** With Use Conjured Food & Water First on (`useConjuredFirst`) and its mode holding (`conjuredFirstMode`, from the same `always` / `solo` / `party` / `raid` / `leveling` / `maxlevel` list as Buff Food's mode; the default `leveling` means below max level), the scanner sets `ns.allowConjuredFirst`, and Food and Water (`allowConjuredFirst` on their definitions) rank conjured items above everything but buff food, even over a bigger restore. Off, conjured wins only ties. `ns.IsModeActive` answers every mode: the group modes read `IsInGroup()` and `IsInRaid()`, already in the group signature, and the level modes compare `ns.cachedPlayerLevel` with `ns.GetMaxPlayerLevel()`, which `PLAYER_LEVEL_UP` already rebuilds on, so any mode flipping rebuilds the macros. No other macro takes the flag: potions, pet food and the rest always use the best.
- **Hybrids.** Food prefers a food-and-drink item on a tie, since one slot covers both needs; Water prefers the dedicated drink and saves the hybrid for Food.
- **Scroll-only mode.** With scrolls on and their mode active, outside an arena, when an enabled scroll type's buff is missing (or under the re-apply threshold), a usable scroll for it is in bags and not ignored, no class buff at least as strong covers it, and no friendly player is targeted, the whole body becomes a scroll applier, in `ns.SCROLL_CHECK_ORDER`:

  ```
  #showtooltip
  /use [@player] item:4425
  /use [@player] item:1180
  ```

  It flips back on the next update once the buffs land. A mode override outranks every other body, so while it is up it also hides the pet-buff line, the conjure clicks and Stealth Eating. Targeting a friendly player drops the scrolls, which is what lets a Mage conjure food for a friend. The lines are plain ASCII, so the body cannot grow in another locale.
- **Pet-buff override.** When `ns.ShouldTrackPetFood()` holds (a food in the flavor's `ns.PET_BUFF_FOODS`, the setting, its mode, the lowest level any of those foods requires, a living pet) and the pet lacks the buff, `modifyItem` swaps the food for the highest-ranked pet buff food in the bags that the player's level allows (each row carries its `requiredLevel`), each behind its own toggle, and `buildUseLine` targets `[@pet]`. The Vanilla, Discovery and Camelot folders have none, so on Classic Era, Season of Discovery and Forever the feature never runs and its options section is hidden. `ns.ShouldTrackPetFood` tests for pet buff foods before it compares levels, because the lowest required level is nil where the folder has none; the aura tracker and handler lead with the same test. The swap reaches `buildUseLine` through a file-local flag, which works only because the engine calls the two hooks in that order. It is not class-gated, so a Warlock's pet qualifies too, and it is never offered in an arena.
- **Stealth Eating and Shadowmeld drinking.** `appendBlock` adds `/cast [nostealth] Stealth` for Rogues, or Shadowmeld for other Night Elves, under the food line (flag `SE`; one `enableStealthEating` key serves both), skipped when there is no food or the pet-buff override holds the body. Water adds Shadowmeld for Night Elves (flag `SM`, and only when there is a drink) but never for Rogues: their options section has no drinking toggle, so a stale saved value must never fire.
- **Early re-application.** With `earlyReapply` on, a Well Fed, scroll or pet buff with less than `earlyReapplyThreshold` seconds left counts as spent, so the macros offer a fresh one before the pull. A class buff at least as strong as the scroll is exempt from the threshold, because while it is still active the scroll line would only error on use.

## Multi-Use Macros and the 255 Trim

Health Potion, Mana Potion, Healthstone and Mana Gem are the `ns.MULTI_USE_MACRO_TYPES`: up to `ns.MULTI_USE_MAX_ITEMS` (3) `/use` lines, best first. That is safe only because each category's items share one cooldown, so a press consumes exactly one item. The extra lines are fallbacks for combat, where macros cannot be rewritten, and a blocked line only raises a harmless "not ready" error.

**Cooldown sharing decides the design, so confirm it before building.** Items on one shared cooldown rank into one list: behind `includeManaRunes`, the Mana Gem macro ranks `ns.MANA_RUNES` in with the gems (the Demonic and Dark Runes, plus Luminous Bluetail in the TBC folder), because they share the gem cooldown. Items on separate cooldowns stack instead: Health Potion's optional Healthstone lines (`combineHealthstones`, through the `getStackIDs` hook) sit below the potion lines so one press uses both. With no potion to stack onto, as in any TBC arena, those lines become the whole body, taking the Healthstone's DruidMacroHelper guards (`stackTypeName`). "Healthstone" in the data therefore means the shared cooldown group, which is why non-Warlock items on that cooldown live in `ns.HEALTHSTONES`. The runes' restore is recorded at its low end, 900, so a rune outranks Agate, Jade and Citrine but not Ruby, and the soulbound Demonic Rune burns before the tradeable Dark Rune through the `isSoulbound` step.

Macro bodies are capped at 255, and the unit of that cap is unconfirmed (Style Guide → MESSAGES → Message Length). Connoisseur sidesteps the question by measuring bytes: every trim site tests `#body` against `ns.MACRO_BODY_MAX_LENGTH`, and byte length is never smaller than character length, so a body that passes is inside either reading. **Never convert one of these checks to a character count.**

| Site | Sheds | Never drops |
|---|---|---|
| `Body-Builder.lua`, `ns.BuildStandardBody` (ranked types only; any other body is never trimmed) | Stacked Healthstone lines first, then ranked fallback lines, bottom-up | The rank-1 `/use` line |
| `Body-Builder.lua`, `ns.BuildComboBody` | Stacked Healthstone lines first, then potion fallback lines, bottom-up | The first `[combat]` line and the `[nocombat]` rest line |
| `Integration-Druid-Macro-Helper.lua` | `/use` lines from the bottom, stacked stones first | The rank-1 `/use` line, and the trailing `/cast !Form` and `/dmh end` pair |
| `Tools-Hunters.lua` | The Dismiss shortcut, then the Revive shortcut with its `[@pet,dead]` auto-revive | Summon, Mend, Feed and the food line |

Localized spell names make this real: a body that fits in enUS can overflow in ruRU, the overflow canary. A Feed Pet body still too long after both drops is written as it stands.

Connoisseur never calls `SendChatMessage`. It has no cross-player chat path and defines no `ns.TARGET_MARKER`, so the 255-byte chat ceiling applies nowhere in this codebase.

## Era vs TBC: Warlock Rank Pinning

This has broken Era three times. Warlock Healthstones and Soulstones are distinctly named spells on Era, where they must be cast bare: appending `(Rank N)` builds a spell name that does not exist, and the `/cast` silently no-ops. On TBC they are one spell with numeric ranks, and the rank must be pinned. The split is data: each flavor folder's `ns.CONJURE_SPELLS` (`Conjure-Spells-{Game}.lua`) gives a warlock stone a rank column only where the client needs the rank written. The Vanilla and Discovery rows carry none. Camelot's Healthstone rows do, because Forever casts Create Healthstone by number, but its Soulstone rows do not, because the soulstone resolver ignores the target and a bare cast already fires the best rank the Warlock knows. The TBC, Wrath, Mists and Standard rows do.

Only the column's presence matters: `ns.GetSmartSpell` never reads the number, and writes the client's own rank text (`C_Spell.GetSpellSubtext`), never a translated rank word, because word order and grammar differ by locale ("7 레벨", "7-й уровень") and a built "(Rank N)" silently fails in those clients. When the client returns no rank text, the cast goes out bare, which on a numeric-rank client fires the highest known rank and undoes any downrank. The Vanilla, Discovery and Camelot soulstone rows name their max target level in the trailing comment. Wrath, Mists and Standard carry it as a fourth, documentation-only column after the rank; on a row with no rank column it would land in the third column and be read as a rank. Mage Conjure Food and Water are numeric-rank on every client, so their rank column is correct everywhere.

Read the RECURRING BUG note on `WarlockCreateHealthstone` in the folder's `Conjure-Spells-{Game}.lua` before touching any of it, never "simplify" the two spell families together, never copy warlock rows between a Classic Era folder and a TBC one without dropping or adding the rank column, and test any change on every client: the Era representation is the one that breaks silently.

`ns.GetSmartSpell` also decides which rank a conjure click casts. Food, Water and Healthstone conjures downrank to a friendly player target's level, so the friend can use what is conjured; the gem, soulstone and ritual clicks ignore the target (a soulstone's target cap rises with its rank, so the best known rank always fits). With `checkUnique`, used for gems and Healthstones, a rank whose unique conjured item is already in bags is skipped. When no rank fits the cap, it falls back to the lowest rank the player actually knows, because players can skip training low ranks and casting an untrained spell silently does nothing.

## Forever

WoW Forever runs Classic content on the Retail client, so its API is Retail's, and it reports `WOW_PROJECT_ID` as `WOW_PROJECT_MAINLINE`, the same as Retail. The flavor therefore comes from the TOC, never the client: `Data/Flavor.lua` reads the loaded TOC's `## X-Flavor`, so Forever is `ns.FLAVOR == "Camelot"`, and because it runs Era's data its `ns.EXPANSION` is 1, the same as Vanilla. Code that branches on the game's version compares `ns.EXPANSION`, so Forever lands with Era without being named; today that is only the Readiness Report's Flask line and its switch, hidden on both. The warlock stone casts never branch on the version: each folder's rows decide them (see Era vs TBC). Its data folder, `Data/Camelot/`, started as a copy of Vanilla's. The one gate that names a flavor is the Blinding Powder row repair, which checks `ns.FLAVOR == "Vanilla"` because only the Classic Era client ever shipped the bad ladder.

- **Legacy readers go through shims.** Forever has no `GetQuestLogTitle`, `GetSkillLineInfo`, `GetPetFoodTypes` or `GetMerchantItemInfo`. `Features/Utilities.lua` picks the namespaced replacement or the legacy global by existence, and each call site sees one shape on every client. Spell names come from `C_Spell.GetSpellName` everywhere, because Forever has no `GetSpellInfo`. The level cap (`ns.GetMaxPlayerLevel`) is the smaller of `GetMaxLevelForPlayerExpansion` and `GetMaxPlayerLevel`, which all three clients ship: the rule Blizzard's own `GameRulesUtil.GetEffectiveMaxLevelForPlayer` applies. Show Connoisseur Context prints both readers' answers. The offline suites stub globals, so a new legacy call surfaces only on Forever: give it a row in `ns.DIAGNOSTIC_API_CHECKS` and run Diagnostics' API Endpoints there, since that report checks only the rows it lists.
- **The bank is purchased tabs.** Forever has no `BANK_CONTAINER` or bank bags. `ns.LoadRestockBankBags` reads the character bank's `C_Bank` tabs instead, through `ns.FetchPurchasedBankTabIDs` (nil on Era and TBC), and the bank open handler re-reads them because a tab can be bought at any visit.
- **Tooltip text has two sources.** Validate Data, the only tooltip reader, goes through `ns.GetItemTooltipLines` and `ns.GetSpellTooltipLines`: Forever reads `C_TooltipInfo`, whose lines no other add-on's tooltip hooks can add to, and Era and TBC, which ship no `C_TooltipInfo` getters, fill a hidden tooltip and read it back.
- **No talent lines.** Forever's talents are Retail's, with no `GetNumTalentTabs` or `UnitCharacterPoints`, so their accessors, `ns.GetNumTalentTabs` and `ns.UnitCharacterPoints`, answer nil there: the Readiness Report's spec and unspent-talent lines never show, and the Spec switch hides.
- **Reads can be secret.** Forever returns secret values while the client restricts aura or unit data, and comparing one errors. The dispatcher holds aura scans until combat drops, but restriction is the client's call rather than combat's, so the aura entry points ask `C_Secrets.ShouldAurasBeSecret()` first: the player snapshot and the pet probe answer with their last reading while it is true, since a reset reading would look like "no buffs" and rebuild the macros around a buff the player still has, and `ns.OnReadyCheck`, the one aura read that runs ahead of the combat guard, stays silent. The Readiness Report's own aura walks (soulstone, expiring buffs, flask) ask nothing themselves and rely on that gate. The target signature and the bag scan's self-target test ask `C_Secrets.CanCompareUnitTokens` before `UnitIsUnit`, the Diagnostic Tools Readiness report asks `C_Secrets.ShouldAurasBeSecret()` before it builds its lines, the `UNIT_SPELLCAST_SUCCEEDED` handler skips a spell ID `ns.IsSecretValue` calls secret, and the Diagnostics event-log tap, which runs ahead of every handler, writes a secret argument as `<secret>` before any string work touches it.

The last four differences resolve once at load through the six accessors of the Client Differences block in `Features/Utilities.lua` (one for the bank tabs, two for talents, two for tooltips, and `ns.IsSecretValue`), while the `C_Secrets` gates call `C_Secrets` directly, since every client ships it. Every API behind them has a row in Diagnostics' API Endpoints.

## Feed Pet (Hunter)

A custom definition in `Tools-Hunters.lua`, shaped by which pet spells the Hunter knows rather than by level:

- **Tier A**, any of Feed, Revive, Call or Dismiss Pet unknown: a print-only stub.
- **Tier B**, no Mend Pet (in practice levels 10 and 11): the cascade without Mend, plus a tip and a stop on `[btn:2][combat]`.
- **Tier C**, every pet spell known: `[mod:ctrl]` Dismiss; `[mod:shift]` or `[@pet,dead]` Revive; `[nopet]` Call, or Revive when the pet is known to be dead but dismissed; `[btn:2]` or `[combat]` Mend; otherwise Feed plus the food line.

The `/stopmacro` line names only the modifiers whose shortcuts survived the 255 trim (`[mod]` while both do, `[mod:shift]` once Dismiss is dropped), so a dropped shortcut's click falls through to Feed Pet and its food. Its token order is fixed: reordering it would change every written body's text and rewrite every Feed Pet macro for no change in behavior.

Pet food selection prefers the lowest-level food that still gives full happiness (pet level minus food level between 0 and 10), then the cheapest, then the fewest in bags, then the lowest itemID, so the pick never flips between rebuilds. With nothing in that bracket it falls back to the lowest food above the pet's level, since pets eat above-level food without limit. Foods that an active quest needs, including one ready to turn in, are skipped; that is the only reason `QUEST_LOG_UPDATE` is registered, and only for Hunters. A dead-but-dismissed pet is detected from `SPELL_FAILED_TARGETS_DEAD` on `UI_ERROR_MESSAGE`, ignored while the target is dead (a spell aimed at a corpse shows the same text), and cleared by `UNIT_PET`, which Core handles ahead of its combat guard.

`ns.ScanPetFood` runs for every Hunter even with the macro disabled, because the mini-map tooltip and Diagnostics read `ns.bestPetFoodID`, and it reads the bag snapshot `ns.ScanBags` filled earlier in the same pass rather than walking the bags again.

## Poisons (Rogue)

Also custom, in `Tools-Rogues.lua`. Left-click poisons the off hand (slot 17), right-click (`[btn:2]`) the main hand (slot 16), and middle-click (`[btn:3]`) casts Poisons to open the crafting window and stops there. A keybind press registers as a left-click, so it applies the off hand. The body `/use`s the poison and then the slot, clicks `StaticPopup1Button1` to confirm the replacement prompt, and clears UI errors so an empty hand does not spam the screen.

There are four body shapes: a tip-only stub without the Poisons skill; the crafting line plus a no-item print when neither hand has a poison; a tip and a stop on the missing hand's click when only one does; and the full dual apply. Each hand's poison group comes from the profile. Poisons are not soulbound, so a twink can carry ranks above their level; each hand takes the highest rank in bags that the character can use and has not ignored.

The pick reads the bags live (`C_Item.GetItemCount`) rather than the scan's snapshot, and the mini-map tooltip resolves it on demand through `ns.GetBestPoisonForHand` rather than reading a published pick the way it reads `ns.bestPetFoodID`: bag contents change without a rebuild, and nothing rebuilds at all while the Poisons macro is off. Group names are the client's own name for each group's base item, so they localize for free; `ns.GetPoisonGroupName` answers nil while that item is cold, and the Macros panel's dropdown shows the loading text until `ns.WarmItemCache` repaints it.

## Readiness Report

On `READY_CHECK`, a private report of what still needs fixing, printed through `ns.PrintMessage`. Nothing is ever sent to group chat. The report ships off behind `readinessReportEnabled` as a beta soft launch. Of its categories, only Soulstone, Healthstone and Mana Gem ship on, because each can be fixed inside the few seconds a ready check allows.

**Silence is the normal output, and that is the whole design.** A category with nothing wrong prints nothing, and there is no all-clear line: a report that greets a prepared player is one that gets switched off, and that silence is what lets it cover this much without becoming noise. Every switch but one can only add a line about something wrong. The exception is Spec, off by default, which names the current spec on every ready check once talent points are spent.

The report is a header and up to three body lines, each branded, each dropped when empty, and the header prints only when a body line survives:

```
Connoisseur // Readiness Report
Connoisseur // Missing Buffs : Well Fed, Scrolls. Expiring Soon : ...
Connoisseur // Missing Items : Healthstone. Damaged Gear : ...
Connoisseur // Character : 1 Unspent Talent Point. Non-Combat Gear Equipped : ...
```

A label and its items join through `READINESS_CLAUSE_FORMAT`, the items through `LIST_SEPARATOR` and the clauses through `READINESS_CLAUSE_SEPARATOR`, so each locale joins with its own punctuation. Each clause reopens the text color after its label, because `|r` resets to the default color rather than to the enclosing one.

Three gating rules run through the whole feature:

- **Two switches per buff.** A buff line needs its report switch and the macro setting saying the character uses the thing at all, since reporting a buff the character never applies is noise whatever the report is set to. For the pet that setting is the whole `ns.ShouldTrackPetFood()` gate the Food macro uses, shared on purpose: when the two drifted, the report asked a level-30 Hunter for a buff its own macro would never apply. Flask and the weapon buffs have no macro behind them, and Soulstone is gated on the player being a Warlock rather than on its macro; all three answer to their report switch alone. Flask is skipped on Era and Forever by maintainer decision, and its switch hides there.
- **Never nag at something nobody can fix.** The Healthstone line needs a Warlock in the group (the player counts), the soulstone line needs the player to be a Warlock who knows Create Soulstone (only they can put one up), Mana Gem needs a Mage who knows a Conjure Mana Gem rank, Mana Potion needs a class with a mana bar (a static class set, not `UnitPowerType`, which reads energy for a Druid in cat form), and a Shaman in the group satisfies the main-hand weapon buff.
- **Read the last scan; never rescan.** Missing items come from `ns.bestSelection`. `ScanBags` fills every category whether or not its macro is enabled, so a player who turned a macro off still gets a truthful answer. An item on either Ignore List never competes, but the scan still resolves it and marks the categories it would have competed in (`ns.scannedIgnoredTypes`), so the report counts it as carried and never names something the player has in their bags. The scan runs only inside a macro update, though, so a ready check that lands in combat or with the Macro UI open reads the scan before it, and before the first scan every item line stays silent. The Mana Gem line looks for any gem in the scan's bag counts (`ns.scannedItemCounts`), so a winning rune still reports the gem missing, and runes that push a held gem out of the ranked slots do not hide it.

Well Fed and scroll coverage are read from the raw aura snapshot, never settled from `ns.scrollOverrideIDs` alone: that list holds only scrolls in bags, so someone missing the buffs with no scrolls to fire would read as covered. The scroll line also fires while the Food macro has scrolls to apply. The soulstone check asks whether a stone is up on anyone, matched by spell ID or by the shared localized aura name, so a wrong or missing ID costs nothing while one ID still resolves, rather than whether anyone holds one: seven unused stones resurrect nobody. The aura APIs answer only for group members the client can see, so its failure mode is a false "missing", never a false all-clear.

Inside a PvP Arena, which blocks potions, buff food and scrolls and flags every player for PvP, `ns.BuildReadinessLines(inArena)` drops Missing Buffs, Expiring Soon, Missing Items and the PvP flag, and keeps what the prep room can still fix (Damaged Gear, spec and unspent points, non-combat gear). A battleground flags everyone too, so the PvP flag line is dropped there as well. The builder is split from `ns.OnReadyCheck`, which owns the master switch, so Diagnostic Tools can render the same answer on demand; that is the only way to tell "you are ready" from "it never ran". It returns nil rather than an empty table, so no caller can print a header over nothing. `ns.OnReadyCheck` runs the checks unguarded, so one that throws silences the whole report; only the Diagnostic Tools render catches the error and prints it.

The panel's confirmed Reset (`Options/Options-Readiness-Report.lua`) writes the shipped defaults back onto `ns.db.global` for every key whose name starts with `readiness`, master switch included, and touches nothing else. It exists because those keys are account-wide, where Reset Profile never reaches. It copies each value straight across, so a new report setting takes the `readiness` prefix and stays a scalar, and no other `global` key may start with it.

## Ignore List

Two lists, and ignoring is additive: an item on either one is invisible to every macro's selection, and it stays hidden until it is off both. The per-character list lives on the AceDB profile; the account-wide list is its mirror on `global`. `ns.IsIgnored` answers for one item, but the bag scan and the Hunter pet-food scan read both tables directly, so a change to what "ignored" means has to reach all three.

`Options/Options-Ignore-List.lua` renders every list on the account as a `childGroups = "tree"` panel: Global first, then each character whose list holds entries, plus the current character so a first entry is always reachable. The tree's keys are the scope keys themselves, never positions, because the tree remembers its selection by key and a key that shifted when a character appeared would silently reselect someone else. The global scope is `ns.IGNORE_SCOPE_GLOBAL` (`"**global**"`), which no profile name can collide with. Rows come from the shared `ns.BuildItemListOptions` at `ns.OPTIONS_TREE_ROW_WIDTH`, since the tree sidebar takes its share of the panel first, and `Options/Options.lua` seeds that sidebar to `ns.OPTIONS_TREE_WIDTH` so long scope keys are not truncated. There is no drop target: opening the Options Interface closes the bags, so items are added by id or by shift-clicked link.

Two details are load-bearing:

- **Other characters' lists are read through `ns.db.sv.profiles`.** AceDB builds only the profile you are on and strips default-valued tables at logout, so a character who never ignored anything has no stored `ignoreList`. `ns.GetIgnoreListForScope` returns nil for a missing list and builds one only when a write passes `createIfMissing`. The current character always resolves through `ns.db.profile`, so an edit lands on the table the scanner reads.
- **Promote, never copy.** Each row on a character's pane carries a Global button. It adds the item to the account-wide list alone, and `ns.SetIgnoredInScope` then clears it off every character's list, because the global list already hides it everywhere and a leftover row could change nothing. Removing an item from Global deliberately puts it back on nobody: there is no record of who held it.

Every mutation wipes the macro state and forces a rebuild, because an item ignored while its macro already names it has to be written out of that body, not just out of the list; `ns.UpdateMacros` defers itself, so forcing is safe anywhere. The mini-map button's Right-Click (ignore the food it is offering) and Middle-Click (clear, with no confirmation, by design) act on the current character's list only, matching what its tooltip shows, and both call `NotifyChange` on the panel, since a mini-map click is the one edit path with nothing else to request a repaint. Right-Click only ever adds, never toggles: in combat or with the Macro UI open the rebuild waits, so the tooltip still offers the same food, and a second click must not take it back off. At logout, `ns.OnIgnoreListPlayerLogout` drops entries that are no longer known consumables (`ns.IsKnownConsumable`) from the current character's list; other characters' lists are pruned when they log out. The account-wide list drops only items this client does not know at all (`C_Item.DoesItemExistByID`): Classic Era and Season of Discovery characters share it while their realms build different folders' tables, so pruning it against one folder's data would erase the other's entries.

## Restock List

The Restock List, behind `/crs`. It is an ordinary part of the add-on: it hangs off the shared namespace, its events run through Core's dispatcher, its data lives on `ns.db.global.restocker`, and it is formatted and linted like every other file. Player-facing strings call its named shopping lists "List", never "Profile"; the locale keys that carry `PROFILE` (`RESTOCKER_PROFILE_*`, `RESTOCKER_HELP_PROFILE_*`, `RESTOCKER_NEW_PROFILE`, `RESTOCKER_COPY_PROFILE*` and `RESTOCKER_DELETE_PROFILE*`) and the `/crs profile` subcommand keep their older spelling on purpose.

Core's `PLAYER_LOGIN` branch starts it through `ns.InitializeRestocker` (`Restocker-Events.lua`), after the migration chain: inflate the saved lines, pick this character's list, prune empty orphan lists, build the event handlers, then the bag definitions, crafting recipes and window. `ns.InitRestockerEvents` rebuilds `ns.restockerEventHandlers` there, one handler per event, which the dispatcher calls ahead of its lockdown guard with the event's own arguments and no leading event name. Core's `PLAYER_LOGIN` branch returns before that lookup, so login work belongs in `ns.InitializeRestocker`, never in a `PLAYER_LOGIN` entry.

### Characters and Lists

`ns.GetCharacterKey()` is `"Name-Realm"` with the realm's spaces stripped, which is not AceDB's profile name; both formats live in the same saved file, so never build one from the other. `listsByCharacter` maps a character key to the list it uses, and `ns.UseRestockList` is the single choke point for switching: it sets `currentList` and remembers the choice for the character. A character seen for the first time gets a new list named for its localized class, numbered "Class (2)" on a collision; a new list never auto-joins an existing one, and legacy `"Name-Realm"` lists are left as they are. A list a character points at is recreated at login if another character deleted it. `ns.SwitchRestockList` ignores a name that matches no list (a mistyped `/crs profile use`), because pointing a character at no list breaks every list read. A switch also reruns the bank restock and the merchant buy while either window is open, which is why the list menu ignores a pick of the list already in use, and a rename re-points every character that followed the old name, which would otherwise get a fresh empty list at its next login.

### Bank Restocking

A coroutine stepped by a ping-paced `OnUpdate` timer (`Restocker-Bank.lua`): one move per tick, at the longer of 0.14 seconds and three times the higher latency, stashing before restocking. Every step re-scans reality rather than trusting bookkeeping, issues at most one move and waits for locks on list items to settle, but only for `MAX_STUCK_STEPS` ticks: an item of ours can stay locked (held on the cursor, or a lock the server never clears), so the gate then resumes and lets the cursor clear and the watchdog count. A no-progress watchdog (`MAX_STUCK_STEPS`) stops with an honest report; an in-flight gate (`MAX_INFLIGHT_STEPS`) ignores scans taken while a move is mid-air, because a maintained item's bag-plus-bank total can dip with nothing locked; and a bounced exact split escalates to a whole-stack pull whose overshoot is stashed back, even with Stash off. Once the moves are done, a tidy phase merges the partial stacks of list items in the bags and then the bank (never across the two), whole-stack merges first and an exact-split top-off only when no stack can absorb another whole, with a watchdog of its own that stops after `MAX_STUCK_STEPS` steps in a row without the partial-stack count falling, or at once when nothing is left to merge.

- **Never sell.** `C_Container.UseContainerItem` sells when a merchant window is open, so `RunRestockLogic` bails whenever `ns.merchantIsOpen` is set, which `ns.OnRestockerMerchantShow` sets before its Shift-to-skip early return. There is no sell path at all, and having too much of an item is left alone.
- **Split moves name an empty slot.** A whole stack moves with `C_Container.UseContainerItem`, which the server places and never bounces. A split puts its part on the cursor, and `PutItemInBag` and `PutItemInBackpack` clear the cursor whether or not the server accepts the item, which makes "did it land" always read yes. The primitives in `Restocker-Bags.lua` therefore drop the part into an empty slot they name themselves, merge into a partial stack only when no slot takes it, and never leave an item on the cursor, which would make the next split fail.
- **Full bags stop neither run.** `ERR_INV_FULL` and `ERR_BANK_FULL` clear `ns.restockBuying`, but a merchant run sends every purchase inside one `MERCHANT_SHOW` handler, before the error can arrive, which is why it checks its own money and bag room as it goes. The bank run ignores the error, because it can fire on a transient race: the loop re-scans every step and stops itself with a clear message when it is genuinely out of room.

The bank's containers are rebuilt by `ns.LoadRestockBankBags` at every bank open: the fixed `BANK_CONTAINER` plus bank bags on Era and TBC, the purchased `C_Bank` tabs on Forever. A Shift held while opening the bank skips the run entirely, and since that path returns before the bank counts as open, it also skips the bank-close reminder. An empty Restock List skips it the same way, so a character that never uses the list is not told a restock completed. The debug trace (`ns.RestockerDebug`) is gated on the runtime-only diagnostics flag, so nothing can leave it on across sessions.

### Merchant Orders

- **Counting is by itemID; orders are keyed by name.** Bag counts (`BuildPurchaseOrder`, `BuildGroceryList`, the crafted items in the reagent order) use the itemID, because a name-keyed count reads 0 for a saved line whose name never resolved and then buys a full stack of something already in the bags. Purchase orders themselves are keyed by the client's current item name (the saved name while the client has none), which the buy loop matches against the name the merchant lists, so a list row and a same-name reagent line merge into one order, and the reagents' bag count has to use that name too: the one shortfall in the add-on that cannot be counted by ID. Recipes are found by name as well: `ns.SetupCraftingRecipes` keys them by the crafted item's localized name, read with the row's saved `itemName`, so a poison row whose saved name is stale buys no reagents, which is one reason inflate refreshes saved names from the client.
- **Buy Extra.** An ordinary order asks for the shortfall and caps down to what the vendor holds. An Extra row instead takes a limited slot's whole count, up or down, which is the useful behavior for scarce consumables that trickle back a few at a time; on an unlimited slot Extra does nothing and the ordinary shortfall is bought, since "buy every one they have" has no end on a slot that never runs out. Extra rides on top of Buy and still honors the reputation gate, and the flag sits on the order, not the row, because a reagent line can merge into the same order.
- **Crafting reagents buy all-or-nothing per vendor.** `VendorStocksAllReagents` (`Restocker-Merchant.lua`) gates the poison-reagent buy: unless the vendor stocks every reagent the crafting order still needs (reagents already in bags excluded, a sold-out limited slot counting as not stocked), none are bought, because half a recipe is worse than none. Quantity coverage is deliberately not required: a slot holding 4 of the 6 dust wanted still crafts 4 poisons. The crafted-item shortfall counts bags only, never the bank, since the bank pile is the one this add-on's own stash creates. Only rows with Buy on get their reagents bought: a row's Buy toggle governs every purchase it makes.
- **Buying.** `BuyMerchantItem` sells at most one stack per call, so buys are chunked. A merchant can list one item in more than one slot, and two items sharing a name share an order, so each order carries what it still owes (`remaining`) and every slot buys against that, never the whole amount. "Filled" and "partly filled" are decided once per order after the last slot, from the units it bought, never from bag counts, which lag. `MERCHANT_SHOW` can double-fire, so a restock runs at most once a second, and a Shift held while opening the merchant skips buying for that visit. Money and bag room are read once per run and spent down chunk by chunk, because neither changes until the server answers, after the whole run is sent: every chunk claims its money and its bag room (`ns.ClaimBagSpace`, partial stacks included) before it goes out, so full bags never block a top-up that fits and a chunk the player cannot pay for or carry is never sent. A chunk refused for room makes the run say the bags filled up.

### The Saved Format

Each item deflates at logout to one comma-separated line and inflates at login (`Restocker-Saved-Format.lua`), so the SavedVariables file holds one physical line per item instead of the many WoW's serializer would spend on a table:

```
itemType, itemName, amount, stashToBank, restockFromBank, buyFromMerchant, reaction, upgrade, buyExtra
```

Booleans are `1` and `0`, and `reaction` is the required standing (0 for none). The itemID is never written, because the table key is the itemID. Every field after the type is written every time (the type is left off only when neither the item cache nor the saved row knows it), and a missing trailing field reads as its own default (`buyFromMerchant` and `upgrade` on, `buyExtra` off), so a new trailing field needs no version stamp: a row written before `buyExtra` existed reads Extra off, which is what it asked for. The parser also reads a line with no leading type. Nothing escapes a comma: one inside a label cuts it short when the line is read back, until the client's own name replaces it at login. Deflate is the last step at logout; from then on every entry is a string for the rest of the session.

### Grocery List and Reminders

`ns.BuildGroceryList` (`Restocker-Merchant.lua`) is the single answer to "what am I short of": the merchant purchase order's shortfall, minus the vendor, so only rows with Buy on appear in any reminder. The reputation gate is skipped, since it depends on which vendor you walk up to, and crafting reagents are left out, since those resolve against the merchant's stock. Counts are bags only, matching what the merchant restock compares against. Every reminder reads that one list, so they can never disagree:

- **Entering town.** Keyed off the client's own resting flag, which is on in inns and cities and nowhere else, so no zone list is maintained. Only a not-resting to resting edge counts, and three events reach the check because no one signal covers every arrival: `PLAYER_UPDATE_RESTING` (walking in), `PLAYER_ENTERING_WORLD` (login, hearth, portal, leaving an instance, where the flag crosses a loading screen with no update event behind it) and `PLAYER_CONTROL_GAINED` (landing off a flight path). A taxi counts as not in town for its whole duration, which leaves a real edge for the landing to trip. Walking in is checked at once, a landing 2 seconds after control returns (the taxi flag clears a moment late), and a loading screen 2 seconds after `PLAYER_ENTERING_WORLD` (5 after a fresh login); nothing reminds until the first `PLAYER_ENTERING_WORLD` arms the check at the end of its delay. A `/reload` only records the current resting state, and a one-minute cooldown collapses clustered arrivals into one nudge. The alert sound is a sub-option of the chat line: it plays only while the chat reminder is on, and the panel hides it while the chat line is off.
- **Leaving a merchant or a bank.** Reported on the way out, after a 0.3 second settle, so purchases and bank moves that land on `BAG_UPDATE` are already counted. Each close handler keys off its own tracked open flag, because the client fires `MERCHANT_CLOSED` and `BANKFRAME_CLOSED` on loading-screen teardown with no matching open, and can double-fire them.
- **Mini-map tooltip.** Up to eight shortfalls, each with have and wanted; past eight, only the count. A fully stocked list shows a green line rather than no section, because "fully stocked" is an answer.

The three chat reminders each have a Simple or Verbose mode (`ns.REMINDER_SIMPLE` / `ns.REMINDER_VERBOSE`): the headline alone, or the headline plus one line per short item. Town defaults to Verbose, since you are away from your bags and the detail is the point; merchant and bank default to Simple, since you are already looking at the window that fixes it.

### Upgrade Ladders

`Data/{Game}/Consumable-Upgrade-Paths-{Game}.lua` holds `ns.CONSUMABLE_UPGRADE_CHAINS`: one ladder per staple family (each food diet, water, arrows, bullets, each poison group, each class reagent, the Hearthstone, and healing and mana potions). A chain carries a `kind`, plus, where one kind has several ladders, the key its category is looked up by (`diet` for food, `group` for poisons, `reagent` for a reagent string); water, arrows and bullets are looked up by `kind` alone. Each tier is `{ minLevel, itemID, rank }`, a higher rank being a better tier, and a folder holds only the tiers its client sells: Blinding Powder, which left the game after Classic, has a tier in the Vanilla, Discovery and Camelot folders alone. A chain its client has no tier for (Anesthetic in those three folders, Corpse Dust in every folder but Wrath) stays in the folder with empty `tiers`, so its List Builder row still resolves and is simply never available. Food, water and ammo tiers are gold-buyable, unlimited-stock vendor items, which keeps arena, token, limited-stock and reputation items off the ladders. Potions and Soul Shards are ladders with no vendor, so their Buy toggle has nothing to buy from while the bank half still moves them; no vendor sells a poison either, but a poison row's Buy toggle buys its reagents.

Which folders hold a tier is decided by hand and has to be: a Wrath database cannot say when an item was added, the ID blocks interleave, and its vendor data describes 3.3.5. Row order carries no meaning: `Restocker-Upgrade.lua` sorts each chain by rank at load, `BestTier` takes the highest-ranked tier at or below the level, so where two tiers share a level (the Wrath folder's level-65 food and water) the Wrath item's higher rank wins, and an upgrade compares ranks, so a wrong rank, not a misplaced row, is what would win silently. The index is built once at load, so an itemID on two chains belongs to the later one. `diet` uses `ns.PET_DIET_MAP`'s numbering, not `item_template.FoodType`, which disagrees with it on four of six values.

`ns.UpgradeRestockList` (`Restocker-Upgrade.lua`) runs on `PLAYER_LEVEL_UP` and moves each eligible entry on the current list to a strictly later tier, never to "the tier matching my level", because an item above the player's level was stocked deliberately. The new level is passed in from the event rather than read from `UnitLevel`, which still reports the old level while `PLAYER_LEVEL_UP` is being handled. It also runs on every `PLAYER_ENTERING_WORLD` as a catch-up, because a ding is not the only way a list falls behind (levels gained with the add-on disabled, a list copied off a higher character). Lists are keyed by itemID, so a move is a delete plus an insert; if the target tier is already listed, the two rows merge, their amounts sum and the existing row keeps its own flags. A per-item `upgrade` flag (nil means on) opts a row out. An unresolved target defers rather than writing the old name against the new ID, and retries on `GET_ITEM_INFO_RECEIVED`.

### List Builder

A window of staples to start a Restock List from. `Restocker-Starter-List.lua` owns the offers, ticks, dismissal and login trigger; `Options/Options-Starter-List-Popup.lua` draws the window, orders its rows, carries its don't-show-again box and clears the Restock List's New group when it closes, as a standalone AceConfigDialog window registered like any other panel but never added to the Blizzard tree. The code and its files still call it the Starter List.

- **When it opens.** Three seconds after a fresh login (`isInitialLogin` only, so neither a `/reload` nor a loading screen re-opens it), for a character at level 6 or higher whose list is empty, that has not dismissed it, and that is not in combat. It opens on demand from the Restock List window's List Builder button. The Restocker panel's "Enable List Builder When Restock List Is Empty" toggle is the dismissal flag, inverted.
- **Pre-ticks.** A few staples arrive pre-ticked by class (`defaultFor`), written onto the list just before the window opens through the same path a hand-tick uses, so unticking takes them straight back off. Those rows are also what usually stops the window returning: an empty list, including one the player emptied, is offered again at every fresh login until the character dismisses the builder.
- **Every offering is a ladder.** Offers are drawn from `ns.CONSUMABLE_UPGRADE_CHAINS` rather than a list of their own, so the builder can never suggest a staple the upgrader would not then maintain; single-tier reagents ride the same rails and simply never move. A ticked staple is added at the best tier for the character's level, through the resolver the upgrader uses. Ticks are usually measured in whole stacks, read off the item itself because stack sizes differ by item and some by client; `fixedAmount` rows add a fixed count with no dropdown, and `countsItems` rows (Soul Shards) count single items from their `choices`. A tick on an unresolved item waits and retries on `GET_ITEM_INFO_RECEIVED`. Potion ladders are never offered.
- **Names come from the client.** A row that stands for a kind of item (a food, water, an ammo type) carries a label; every poison and reagent row shows the client's own name instead, a poison type for its ladder's first item and any other row for the item a tick adds. Those rows need no strings and read as the items do in bags and at vendors. A name the client has not resolved shows the panels' loading text until the window repaints. Within a section, dropdown rows come before fixed-amount rows, each group sorted by the names it shows, with unresolved names last by item ID. The rows hold no game IDs, so one table in `Data/Data.lua` serves every client, and each flavor folder's ladders supply the items.
- **Dismissal is per character and outside AceDB profiles.** It lives in `ns.db.global.restocker.starterListDismissed`, keyed by `ns.GetCharacterKey()`, so a profile switch or reset can neither resurrect nor suppress a window the character already answered.

### The Window

The Restock List window is hand-built from Blizzard templates rather than AceGUI, and its geometry lives in `ns.db.global.restocker.framePosition`, so one layout follows the player across every character. The two menus, the reputation cell and the list selector, open an `AceGUI:Create("Dropdown-Pullout")`. Blizzard's `UIDropDownMenu` drives shared global frames that its own secure code also uses, so routing through them leaves taint behind, while AceGUI owns its frames and raises the pullout to `TOOLTIP` strata, which also keeps it in front of the window. The window itself sits at `HIGH` strata: above the bags and the default panels, but below the `DIALOG` strata Blizzard forces on every confirmation popup, so the Delete confirmation always draws on top of it. A `Dropdown-Item-Toggle` does not close its own pullout (unlike `-Execute`), so both menus close explicitly on pick. The reputation pullout is created per open and released on close, while the list pullout is built once and cleared on each open, because releasing it on close would free the New List item while its own click handler is still running.

- **The grid is defined once.** `Restocker-Window-Columns.lua` defines the columns, widths and gaps and resolves the colors the header and rows share, from the palette and `ns.RESTOCKER_WINDOW_COLORS` in `Data/Data.lua`, and the header and every row lay out through the same walk, so they cannot drift apart. Column widths are measured against the live font when the window is built at login; if the font has not resolved by then, every list refresh measures again until it has, and the header and rows pick the new widths up.
- **The filter is pure data.** `Restocker-Window-Filter.lua` decides which items show, in what order and under which category, and touches no frame. It works off a view built once per redraw, because the sort comparator asks for an item's group on every comparison, and resolving it there made the filter box cost an item-cache lookup per comparison on every keystroke.
- **Rows are pooled.** A row control reads its own rebound item, never its parent's, and the reputation menu closes inside `ns.UpdateRestockList`, because pooled rows are rebound under an open menu.
- **The Amount box saves as you type.** Closing the window without pressing Enter keeps whatever the box holds, and an emptied box saves 0, which for a bank deposit means store all.
- **The add box takes dragged items and typed item IDs.** Shift + Click is not captured: the clients route it through `ChatFrameUtil.InsertLink`, which an add-on could only claim by overwriting a Blizzard function.
- **A visit closes only what it opened.** A merchant or bank close hides the window through `ns.HideRestockWindowAfterVisit`, which acts only when that visit opened it (`ns.ShowRestockWindowForVisit`). A close handler never calls `ns.HideRestockWindow` directly, which would shut a window the player opened, and a loading screen, which fires the close events with nothing open, never closes it.
- **Delete removes the list it named.** The confirmation carries the list's name as the dialog's data and deletes that one. The dialog does not lock the window, so reading `currentList` on accept could delete a list the player switched to in the meantime, and a Restock List has no undo.

## Diagnostics

Runtime-only: `ns.diagnostics` is never saved, so the panel starts off at every login, and nothing runs on load or on panel open. The panel (`Options/Options-Diagnostics.lua`) offers, in order: Event Log, Event Registration, API Endpoints, Connoisseur Context, Item Selection, Readiness Report, Other Add-ons, Saved Variables and Library Versions; then one Validate Data section per flavor-folder file, titled with the folder this client loaded; then Taint Log and External Tools. Besides its in-memory log, the only state Diagnostics writes is the `taintLog` CVar, through its two buttons, and that CVar persists across sessions. Its strings are developer-facing plain English and never localized. Turning the panel on also switches on the Restock List's chat trace (`ns.RestockerDebug`); the panel itself stays read-only, so nothing on it may start a restock or any other gameplay action.

What can and cannot drift:

- **Event Registration** reads `ns.EVENT_NAMES`, the list the dispatcher registers from, so it cannot drift.
- **API Endpoints** run `ns.DIAGNOSTIC_API_CHECKS`, a hand-kept list of every API reached through a guard or fallback plus the load-bearing ones. A modern-to-legacy fallback gets two rows, the modern API and a separate `(legacy)` one, so on each client exactly one side of the pair is expected to pass. A new guarded API needs its own row.
- **Validate Data** runs `ns.DIAGNOSTIC_DATA_SOURCES`, one entry per flavor-folder file labeled by the table part of its name, naming each table by its key on `ns` rather than holding it, so a table this client's folder never built prints one `TABLE MISSING` row instead of throwing, and an `"other"` table, whose IDs no client API reads, prints its row count. A file left off the manifest is never checked, and a clean run flags nothing: a NOT ON CLIENT ID is a row in the wrong folder, to be pruned from the folders this client loads, while an INCOMPLETE or ERROR row calls for a rerun or a code fix, never a prune. It proves an ID exists on this client, never that it is the item its row names: a wrong ID that happens to be a real item passes. Each row prints every by-ID reader the three clients share, the item's spell with that spell's text and the whole tooltip included (lines joined by ` // `, a right-hand text after ` >> `), so an amount such as a bandage's heal comes straight off the report. Every ID goes through in batches of 100, spells first. A row's first poll settles it NOT ON CLIENT at once when `C_Item.DoesItemExistByID` or `C_Spell.DoesSpellExist` says it does not exist, and otherwise requests its data; each batch is polled until every row in it has settled, its stragglers asked for again every five idle polls, and only then does the next batch start. A row is OK once its spell or item, its text and its tooltip have all loaded. After 25 polls with no progress a straggler that never loaded is NOT ON CLIENT and one that loaded partway is INCOMPLETE, so a slow load is never cut off. A reader that throws settles an ERROR row with the message in its Name column, except on a row already settling NOT ON CLIENT, which keeps that status on three cells, and the run carries on. A second press restarts the section, turning the tools off stops it and clears its progress line, and the progress repaints at most once a second (`VALIDATE_REPAINT_SECONDS`), because a repaint rebuilds every report box on the panel.

Worth knowing about the reports:

- **Item Selection** prints each category's winner and, for each of up to four runners-up, the `RANKING_PRIORITY` step that put the winner ahead of it. Candidate retention runs only while the panel is enabled, and the retained lists are wiped at the start of every scan either way, so switching the panel off leaves nothing stale behind.
- **Readiness Report** renders what the report would print right now, ignoring the master switch but applying the arena rule, and lists which switches are on from a hand-kept `READINESS_SWITCHES`. It strips color codes and escapes the remaining pipes, so the item links on the gear lines paste as plain text.
- **Saved Variables** dumps the live `ConnoisseurDB`, so AceDB defaults appear on `global` and the current profile even though the saved file strips them; other characters' profiles print as saved. Every row the player can edit prints in full, the Restock Lists included, since those rows are what explain a bug; only the derived `itemCache` is counted rather than printed.

The event log keeps the last 500 entries, up to 8 arguments each, every argument turned into a string at once (never retaining a frame or table) and cut to 255 bytes, with pipes escaped after the cut; a secret argument is written as `<secret>` instead. Start replaces the log, Stop keeps it, and turning the panel off discards it. Noise control happens at capture, never at render, because folding at render still lets spam push real entries out; it counts rather than deletes, and suppressed traffic renders as a tally at the end, biggest offender first:

- `ns.DIAGNOSTIC_EVENT_EXCLUDE` holds only `UNIT_AURA`. The capture tap runs before the handler, and only the handler knows whether an aura change mattered, so `ns.OnUnitAura` writes its signal firings back through `ns.LogEventNow`, with a reason (`wellfed`, `scrolls`, `petbuff`, or a combination such as `wellfed+scrolls`). The tally counts every `UNIT_AURA` firing, signal ones included.
- `ns.MESSAGE_ID_FILTERED_EVENTS` classifies `UI_ERROR_MESSAGE` by its message text (argument 2), which is what the handlers compare. `IsCorrelatedMessage` is an allowlist of exactly the globals those handlers compare against (`ERR_ITEM_WRONG_ZONE`, `SPELL_FAILED_TARGETS_DEAD`, `ERR_INV_FULL`, `ERR_BANK_FULL`), read live so it cannot drift. Never invert it into a denylist of noise, which is unbounded and renumbers across patches. A handler that starts comparing another message must add it here, or its firings fold into the tally.

The log sees only events currently registered on Core's frame, so an on-demand event (`UNIT_AURA`, `QUEST_LOG_UPDATE`, `GET_ITEM_INFO_RECEIVED`) missing from it proves nothing.

## Offline Test Suites

WoW's sandboxed Lua has no test framework, so logic tests are plain-Lua scripts beside the code they test. They are dev-only: no TOC lists them and `.pkgmeta` strips both `Tests/` folders. Each prints its `ALL ... PASSED` line and exits 0. The four in `Features/Tests/` run from the add-on root and the rest from `Features/Restocker/`:

```
lua Features/Tests/Readiness-Report-Test.lua
cd Features/Restocker && lua Tests/Restocker-Cold-Item-Test.lua
```

| Suite | Kind | Pins |
|---|---|---|
| `Readiness-Report-Test.lua` | Real files | Silence (restricted auras included), the arena and battleground rules, the class and group gates, the soulstone name match, Mana Gem runes, ignored items counted as carried, Expiring Soon, spec and unspent talents (Forever's missing APIs included), print order |
| `Diagnostics-Event-Log-Test.lua` | Real file | Folded uncorrelated messages, allowlisted full lines, verbatim unclassifiable firings, `UNIT_AURA` counting, secret arguments |
| `Diagnostics-Validate-Data-Test.lua` | Real files | Validate Data's batch gate, the OK, INCOMPLETE, NOT ON CLIENT, ERROR, TABLE MISSING and `"other"` rows, one cell per column, both tooltip readers, stopping, restarting, the once-a-second repaint |
| `Combo-Macros-Test.lua` | Real files | The Food & Potion and Water & Potion bodies, Healthstone stacking under Combine Healthstones, the no-item lines, the 255 trim, the state key, `ConnoisseurFireIf` and `ConnoisseurNoItemIf` |
| `Restocker-Cold-Item-Test.lua` | Real files | The waiter-scoped item memo: remembered misses, forgets, releases and retries |
| `Restocker-Saved-Migration-Test.lua` | Real files | Adoption, the saved-key rename and the Blinding Powder repair |
| `Restocker-Starter-List-Test.lua` | Real files | Stack sizes read off the item, ticks on cold items, and rows named by the client |
| `Restocker-Upgrade-Level-Test.lua` | Real files | Level-up upgrades using the event's level |
| `Restocker-Restock-Planner-Test.lua` | Model | The bank restock loop: rescans, one move per step, the watchdog |
| `Restocker-Buy-Extra-Test.lua` | Model | Extra orders, chunked buys, one item in two slots, the saved flag |
| `Restocker-Reagent-Buy-Test.lua` | Model | The reagent order and chunked buying |
| `Restocker-Column-Layout-Test.lua` | Model | Header and row alignment and the item-name width floors |

The two kinds fail differently, and that is the trap:

- **Real-file suites** `loadfile` the shipping files they exercise and stub every other `ns` function they touch. Feature code calls namespace functions outright, never behind `if ns.X then`, so a new cross-file call added to a file a suite loads crashes that suite with "attempt to call a nil value". Before adding one, grep both `Tests/` folders for the file you are changing and give each suite that loads it a stub. These suites take an optional root path as their first argument, which is how to run them against a copy of the add-on.
- **Model suites** replicate an algorithm instead of loading it, so they keep passing when the shipped code changes. A change to a modelled algorithm must be mirrored in its model.

Every suite opens with `-- luacheck: allow defined, ignore 121 122 131 143`, because the suites are linted with the rest of the repo while deliberately defining the WoW globals the config treats as read-only.

## Saved Variables

Connoisseur uses the **Per-Character** saved-variables model (Style Guide → SAVED VARIABLES → The Two Models): `AceDB:New` in `Features/Core.lua` omits its third argument, so every character lands on its own profile, named `"Name - Realm"`. On WoW Forever the vendored AceDB names the profile for the realm's ruleset instead (`"Name - PvE"`, `"Name - PvP"`, `"Name - RP"` or `"Name - Hardcore"`), so two same-named characters on realms of one ruleset share a profile. **Reset Profile therefore clears only the active character's profile**: its consumable settings, its poison groups, its own Ignore List and the derived item cache, while everything on `ns.db.global` survives.

The profile is the default scope here, because consumable choices genuinely differ per character: a level-15 alt and a raiding 60 want different buff food, and two Rogues want their own poison pairs. A setting goes on `global` only for a concrete account-wide reason, written in `Data/Default-Settings.lua`, in its header block or on the key itself.

**`ConnoisseurDB`** is the add-on's saved table. **`ConnoisseurRestockerDB`**, the Restock List's old standalone table, is also declared on every TOC's `SavedVariables` line until 2026-09-29, only so the adoption step below can still read it, because WoW hands back only the variables a TOC declares. Besides AceDB's own `profileKeys`, the shape of `ConnoisseurDB` is:

- **`profiles.<profile>`**: the Macros settings (buff food, scrolls, conjured food and water first, pet buff food, early re-application, the Explosive click layout, Druid Macro Helper, Shadowmeld drinking, Stealth Eating, mana runes, Healthstone stacking), the scroll and pet-buff types, the Rogue's poison groups, the character's `ignoreList`, and the derived `itemCache` / `itemCacheVersion`.
- **`global`**: presentation (`showWelcome`, `showMacroNames`, `minimap`); `enabledMacros`; the account-wide `ignoreList`; the Readiness Report's `readinessReportEnabled` and its `readiness*` switches and thresholds; and `restocker`.
- **`global.restocker`**: the whole Restock List subsystem: `lists` (the named lists, each item a one-line string keyed by itemID), `listsByCharacter`, `currentList` (written at runtime, not a default), `starterListDismissed`, `framePosition`, and the reminder and auto-open settings. It sits on `global` rather than a profile on purpose: those lists are shopping lists, not AceDB profiles, so a profile switch or Reset Profile must never empty one or re-offer the List Builder to a character that answered it.

`enabledMacros` is the one macro-behavior setting on `global`, a recorded exception to keeping a feature's settings in one scope: the macros live in the shared General macro tab, so a per-character switch would have one character delete a macro another recreates, losing its action-bar placement on every character switch. The Readiness Report panel's Reset is the other recorded exception (see Readiness Report).

`OnProfileChanged`, `OnProfileCopied` and `OnProfileReset` all run one handler that ensures the item cache, resets macro state, refreshes aura tracking, re-pushes the two account-wide settings applied imperatively (mini-map visibility and macro-name text), notifies every panel in `ns.OPTIONS_REGISTRY` and requests a rebuild, so a reset or switch takes effect at once rather than at the next `/reload`.

Retired keys are cleared explicitly at login, as the last step of the migration chain (until 2026-09-29): the old `readyCheck*` names on `global` plus `readinessReport`, the first master switch, which only looks like a live `readiness*` key, and the Restock List's `debugMessages` and `adoptedLegacyData`. A retired name is never reused. AceDB strips a value equal to its default at logout, but a value the player set stays in the saved file, and once its key leaves the defaults table nothing fills or strips it any more, so a reused name would read back a choice made under its old meaning.

Defaults come from `ns.DATABASE_DEFAULTS` and are applied by AceDB-3.0 when a scope is first accessed, and explicit user values, including `false`, are never overridden. Note that scalar and table defaults are physically copied into the saved table (`copyDefaults` via `rawset`); only `*`/`**` wildcard defaults resolve through metatables.

There is no refill-on-empty logic for settings. Connoisseur ships no user-editable default item lists, since the static tables in `Data/` are code rather than saved data, and settings maps like `enabledMacros` deliberately survive being all-false. The nearest thing is the List Builder, which refills an empty Restock List with its class pre-ticks at a fresh login until the character dismisses it (see List Builder). The derived `itemCache` is created outside the defaults table because `ns.EnsureItemCache` owns its invalidation.

### Migration Chain

Every change to the shape, name or scope of saved data ships with a migration supported for 30 days (Style Guide → SAVED VARIABLES → Migration Windows). The live steps run in this order from `InitializeSavedVariables` in `Features/Core.lua`, after `AceDB:New` and before `ns.InitializeRestocker` reads the lists; all four touch `ns.db.global` alone. The first three live in `Features/Restocker/Restocker-Saved-Migration.lua`, whose sections list every piece that comes out with them, and are pinned by `Restocker-Saved-Migration-Test.lua`; the fourth sits inline in `InitializeSavedVariables`:

1. `ns.AdoptStandaloneRestockerDB` (remove after 2026-09-29): copies the Restock List from `ConnoisseurRestockerDB` onto `ns.db.global.restocker` only when the new table holds no saved item yet, under its old key names for step 2 to convert in the same login, and nils the old table either way, so it can never run twice on the same data.
2. `ns.RenameRestockerSavedKeys` (remove after 2026-10-18): moves `profiles`, `profileKeys`, `currentProfile` and `framePos` (with its `xOfs` / `yOfs`) to `lists`, `listsByCharacter`, `currentList` and `framePosition` (`xOffset` / `yOffset`), moving a key only when the new name is missing or empty, so it never overwrites data.
3. `ns.RepairBlindingPowderRows` (remove after 2026-10-18): Classic Era only. Moves rows saved under 6510, Infantry Gauntlets, a wrong ID the Blinding Powder ladder once carried, onto Blinding Powder (5530) without their saved name, so the merchant cannot buy gauntlets by it; a list that already holds Blinding Powder keeps its own row and drops the stray. `ns.NameBlindingPowderRows`, called from `ns.SyncRestockItemInfoSubscription`, names a moved row once the client loads the item.
4. The retired-key clears (remove after 2026-09-29): nil `debugMessages` and `adoptedLegacyData` on `ns.db.global.restocker`, and the old Ready Check switches plus `readinessReport`, the Readiness Report's first master switch, on `ns.db.global`.

The short macro globals in `Features/Macros/Runtime.lua`, with their entries in `.luacheckrc`'s globals, are the one migration outside saved variables (see Macro Runtime Globals), also until 2026-10-18.

## Adding a New Consumable Category

1. Add the static data as `Data/{Game}/<Category>-{Game}.lua` in all seven flavor folders, declared whole under an UPPER_SNAKE_CASE name (empty where a flavor has no rows), with the originating SQL query and the client database it came from in a block comment above the column-header comment (or `-- TODO: Add SQL Query`). The Vanilla and Discovery copies open with their `ns.IS_DISCOVERY` guards. List each copy in its TOC's own folder block, before `Data/Default-Settings.lua`: the Vanilla TOC takes both `Data/Vanilla/` and `Data/Discovery/`.
2. In `Features/Item-Cache.lua`, add the table to `ns.HasRawData` (which decides what gets cached, and which `ns.IsKnownConsumable`, and so the per-character Ignore List's logout prune, relies on), and add a branch to `ns.CacheItemData` deriving the record's `itemType`, values and requirements.
3. Add an entry for the file to `ns.DIAGNOSTIC_DATA_SOURCES` in `Features/Diagnostics.lua`, labeled by the table part of its file name and naming each table by its key on `ns`, or Validate Data never checks it. The panel orders each Validate Data section at `60 + index * 3`, so a thirty-third entry would collide with Taint Log's order (160).
4. Create `Features/Macros/<Category>.lua` calling `ns.RegisterMacroType` as the file loads, with its selection fields and body hooks (the protocol is at the top of `Engine.lua`), and add its line among the definitions in every TOC. A definition registered after the first scan has no selection table and crashes the scan.
5. Add the macro to `ns.MACRO_CONFIG` in `Data/Data.lua`, its default item to `ns.MACRO_DEFAULT_ITEM_IDS` in every folder's `Macro-Default-Items-{Game}.lua`, to `enabledMacros` in `Data/Default-Settings.lua` and to the Enable Macros inline group in `Options/Options-Macros.lua`, with its `MACRO_*` and `LABEL_*` keys in `Locales/enUS.lua` only. The macro name is at most 16 characters and never changes once shipped.
6. If the category's items share one cooldown and the body should carry fallbacks, add it to `ns.MULTI_USE_MACRO_TYPES` and mark the definition `ranked`; the ranked sort ignores `allowBuffFood`, `allowConjuredFirst` and `preferHybrid`. If the items do not share one cooldown, they must not rank together.
7. Mind the 255 macro ceiling if the body stacks lines (ruRU is the canary), and check the written body in-game on all three clients before shipping.

## Adding a New Ranking Step

1. Add the step to `RANKING_PRIORITY` in `Features/Scanner-Inventory.lua`, in the position that expresses the preference. The order is the specification.
2. Fill its field in `FillRecord`, which builds both sides of every comparison, and reset it in `ResetBest`.
3. Add it to `CopyCandidateRecord`. A field left out of the diagnostic copy does not make its step neutral; it makes the step decide, because a real boolean tests unequal to a missing one.
4. If the step reads a new cached field, derive it in `ns.CacheItemData` as a real `true` or `false`, since steps compare raw, and add it to the stale-schema nil-test in `ns.ScanBags` so existing caches re-derive on a same-version build.
5. Prefer a boolean ladder step over a bonus folded into `value`: a bonus can outweigh a genuine restore difference, and two equal bonuses cancel each other instead of ranking.

## Adding a New Registered Event

1. Add the name to `ns.EVENT_NAMES` in `Features/Core.lua` and a branch to the dispatcher. Registration and the Diagnostics Event Registration check pick it up together.
2. Place the branch above the lockdown guard only if it must run mid-fight and touches nothing protected.
3. If it must register per unit or only while needed, add it to `DEFERRED_EVENTS` and register it through `ns.SetEventRegistered`.
4. If it is a firehose, diff its inputs before calling `ns.RequestUpdate()`, as the target, group, aura and quest-log branches do. A diff that sits below the lockdown guard never runs in combat, so have every scan refresh its baseline too, as the aura and quest diffs do, or a change undone after a fight reads as no change. If a handler compares `UI_ERROR_MESSAGE` text, add that message to `IsCorrelatedMessage` in `Features/Diagnostics.lua`.

The Restock List registers nothing of its own. `ns.InitRestockerEvents` (`Restocker-Events.lua`) builds `ns.restockerEventHandlers`, one handler per event, so anything else wanting an event already in the table shares the existing entry rather than adding a second: the arrival reminder, the List Builder's login trigger and the upgrade catch-up all hang off `ns.OnRestockerEnteringWorld`. Add an entry inside that constructor, never by assigning into the table at load, because it is rebuilt at login. Every entry runs ahead of Core's lockdown guard, so a handler must touch nothing protected.

## Adding a New Scroll Type or Poison Recipe

- **Scrolls:** add the type to `ns.SCROLL_DATA` in the `Scrolls-{Game}.lua` of every folder whose client has the scrolls (`items` as `{ itemID, buffID, requiredLevel, amount }`, sorted by required level at load, `conflictSpells` as `[spellID] = amount`), then to `ns.SCROLL_CHECK_ORDER` in `Data/Data.lua` (also the order the scroll-only body fires them in), the `scrollTypes` defaults, an options toggle and the enUS keys. `Scanner-Auras.lua` derives `ns.SCROLL_ITEM_LOOKUP`, the reverse buff and conflict maps and the aura snapshot's entries from `ns.SCROLL_DATA` at load, so nothing else needs a matching edit.
- **Poison recipes:** add a row to `ns.POISON_RECIPES` in the `Poison-Recipes-{Game}.lua` of every folder whose client crafts the poison: the crafted itemID and its `{ reagentID, count }` pairs, with that client's counts. Blizzard rebalanced most counts in TBC, so the same poison often carries different counts in the Classic Era and TBC folders.

## Adding a New Upgrade Ladder or List Builder Staple

1. Add the ladder to `ns.CONSUMABLE_UPGRADE_CHAINS` in every folder's `Consumable-Upgrade-Paths-{Game}.lua`, with the tiers that folder's client sells, each ranked (higher is better); a folder whose client sells none keeps the chain with empty `tiers`. Give it a `kind`, plus, where one kind has several ladders, the key its category is looked up by (`diet`, `group` or `reagent`).
2. A ladder alone is enough for `Restocker-Upgrade.lua`: anything on it now follows the player's level.
3. To offer it in the List Builder too, add a row to `ns.STARTER_LIST_CATEGORIES` in `Data/Data.lua`, one table for every client, with a unique `key` (it names the row's widgets and indexes its remembered stack choice), its `section`, a `chainKey` (`food:<diet>`, `poison:<group>`, `reagent:<name>`, or a bare kind), and exactly one of `maxStacks`, `choices` or `fixedAmount`. Add `classes` to limit who is offered it and `defaultFor` (`"all"` or a class set) to pre-tick it. A row whose ladder the loaded folder lacks is dropped at load rather than crashing the window open.
4. Name it only if it stands for a kind of item, as the foods, water and ammo do: an `L["..."]` `label`, with the key added to `Locales/enUS.lua` only. Any other row needs no string, since it shows the client's own name for the item a tick adds, or, with `namesFirstTier`, for its ladder's first item, as the poison types do. A row in an existing section needs nothing else, since the window's height recounts its rows on every open; a new `section` also needs builder code in `Options/Options-Starter-List-Popup.lua`, or its rows are silently never drawn.

## Adding a Player-Managed Item List

`ns.BuildItemListOptions` in `Options/Options-Utilities.lua` owns the shape of a list the player builds in the Options Interface; the Ignore List is its caller today, while the Restock List window has its own add row. The panel supplies `getSourceTable`, `onAdd`, `onRemove`, `notifyKey` and `labels`, and optionally `rowWidth`, `startOrder` and an `actionColumn`, either an execute button (the Ignore List's Global button) or a select. The builder adds the add row, one inline group per item sorted by name with ties broken by id (so identically named rows never reshuffle on a repaint), and the icon-only remove button, and warms uncached items through `ns.WarmItemCache`. Keep the add row a stock AceGUI edit box, which is what receives shift-clicked links; its input goes through `ns.ParseItemInput`, which accepts only a bare id or an item link. Restore Defaults is deliberately absent, because a list the player built from nothing has nothing to restore, so a panel needing a clear-all seats that control in its own head, where it can carry the confirm a destructive action requires.

## Changing the Shape of Saved Data

1. Write the migration as a function beside the feature's other migrations (the Restock List's live in `Features/Restocker/Restocker-Saved-Migration.lua`). Make it safe to run on a file it already converted, and never let it overwrite data the new shape already holds. A profile key must be converted in every stored profile (`ns.db.sv.profiles`), not just the active one: `InitializeSavedVariables` sees only the profile this character is on, and another character's would come back in the old shape on a switch or copy.
2. Call it from `InitializeSavedVariables` in `Features/Core.lua`, after the steps before it and before anything reads the new shape. Call it outright rather than behind a check that the function exists: a migration failing quietly is how player data gets lost.
3. Tag every piece `MIGRATION (remove after YYYY-MM-DD)` in its file's comment syntax, TOC and `.luacheckrc` lines included, dated 30 days past the release that ships it, and list at the top of its section every piece that comes out together.
4. Pin it with scenarios in `Restocker-Saved-Migration-Test.lua` or a new suite, and stub the new call in every other suite that loads the file calling it.
5. After the date, delete the migration and all of its pieces in one change.

## Localization

- **`enUS.lua` is the source of truth** and the only file passing AceLocale's `true` default-fallback flag. Every string originates there; the other ten locales translate its key set and fall back to English for any key they lack. They belong to the Localization pass (`3 - Copy Cleanup & Localization Prompt.md`): add new keys to `enUS.lua` only, and never hand-edit the others during ordinary work.
- **Registration.** All eleven files call `NewLocale("Connoisseur", ...)`, the brand literal pinned as `ns.LOCALE_NAME` in `Data/Data.lua`, not the packaged folder name.
- **Placeholders.** `%s` and `%d` count, type and order must match `enUS` per key in every locale, or the string crashes at runtime.
- **Macro names are identity.** Macros are found by name, so a shipped `MACRO_*` value never changes in any locale: a changed name creates a second macro and leaves the old one stale on every player's action bar. Names are capped at 16 characters, noted above the `MACRO_*` block in `enUS.lua`.
- **Join text through the locale.** Chat output joins list items and report clauses with `LIST_SEPARATOR`, `READINESS_CLAUSE_SEPARATOR` and `READINESS_CLAUSE_FORMAT`, never a literal `", "`, so each locale joins with its own punctuation.
- **Not localized:** the Diagnostics strings, developer-facing plain English in the Diagnostics files, and the English type keys inside macro bodies.

The Spanish file pairing, the overflow canary (ruRU here, which is why the three macro trims exist) and the output ceilings are per Style Guide → LOCALIZATION and MESSAGES → Message Length.

## Common Pitfalls

- **Editing macros in combat**: silently blocked by the client. Always route through `ns.RequestUpdate()`; pending work replays on `PLAYER_REGEN_ENABLED`.
- **Editing macros while the Blizzard Macro UI is open**: the frame's save-back reverts the write after the state key recorded it, so the macro sticks stale. `ns.UpdateMacros` defers while `MacroFrame:IsShown()` and its `OnHide` hook rebuilds on close. Never write around that guard, and never move the hook install inside the deferral branch.
- **A body input missing from the state key**: the macro silently goes stale. Keys are lossless, and mode overrides use disjoint prefixes so transitions always rewrite.
- **Forcing a rebuild without resetting state**: `ns.UpdateMacros(true)` wipes only the standard macros' state, and a force deferred by combat or the Macro UI replays unforced, so Feed Pet and Poisons rewrite only when their own keys change. Call `ns.ResetMacroState()` before forcing, as the Ignore List does.
- **Reading target or group state without joining its signature**: `PLAYER_TARGET_CHANGED` and `GROUP_ROSTER_UPDATE` request a rebuild only when `ns.TargetSignatureChanged` or `ns.GroupSignatureChanged` sees a change, so a new input read there never triggers one. Add it to the signature.
- **Registering a macro definition late**: the per-category selection tables are built once, on the first scan, so a definition registered after it has no table and the scan indexes nil. Register as the file loads, as every definition file does.
- **A new override that reads the bags directly**: the scroll and pet-buff overrides bypass the scan's usability gates and ignore check, so each re-checks level and `ns.IsIgnored` itself. A new one must do the same, or it offers an ignored or unusable item.
- **Appending `(Rank N)` to warlock stones on Era**: the `/cast` silently no-ops. The Classic Era folders' warlock rows carry no rank column and `ns.GetSmartSpell` pins only what a row carries; never add one there, and never "simplify" the spell families together.
- **Editing one flavor folder's copy of a row**: the seven folders hold separate copies, so a fix to one leaves the other six as they were. Look the ID up in every folder, change each copy the fix is true for (by script for any table over 20 rows), and say which copies you left and why.
- **Changing a shipped macro name**: macros are found by name, so the rename creates a second macro and strands the old one on every action bar. `MACRO_*` values never change, in any locale.
- **Passing a numeric `1` to `CreateMacro`'s `perCharacter` argument**: the client boolean-checks it, so a number lands in General only by accident. Omit the argument, as `ns.WriteMacroBody`, the only writer, does.
- **Overflowing macro bodies in wide locales**: always assemble, then trim (the four trim sites). `#body` measures bytes, which holds under either reading of the 255 ceiling; never loosen it to a character count.
- **Adding a ranking or cached field halfway**: steps compare booleans raw, so a nil against `false` decides a step that should tie, and a same-version build (every dev copy reads `Dev`) keeps cached entries missing a new field. Build every flag as a real boolean, copy every step field in `CopyCandidateRecord`, and extend the stale-schema nil-test in `ns.ScanBags`.
- **`GetItemInfo` cold nils**: a fresh login cannot resolve uncached items. The scan flags `dataRetry` and re-runs on `GET_ITEM_INFO_RECEIVED`, so never assume the first scan is complete; Restock List adds, upgrades and List Builder ticks defer on the same miss rather than writing a row with the wrong name, and options panels hand cold ids to `ns.WarmItemCache`. Every answer heard must reach `ns.ForgetItemDataMiss` before any retry, since a miss remembered past its answer strands that item for the session, and anything parked on an item calls `ns.SyncRestockItemInfoSubscription` so the `"restocker"` waiter stays registered while it waits.
- **Calling the deprecated item globals**: on every client `GetItemInfo`, `GetItemCount` and their kin exist only through Blizzard's deprecation layer, which the `loadDeprecationFallbacks` CVar switches off, and the offline suites stub them, so a call that works only through the layer passes every test. Call `C_Item` directly (and `C_SpecializationInfo` for talents), with no legacy fallback: every client ships the namespaced item readers. The same holds for `IsSpellKnown` and `IsPlayerSpell` on Forever: go through `ns.IsSpellKnown` / `ns.IsPlayerSpell`, which read `C_SpellBook`.
- **Holding the aura snapshot**: `ns.GetPlayerBuffSnapshot()` returns one shared buffer that the next call overwrites. Take one snapshot and pass it down, as `ns.ScanBags` does from `ns.UpdateAuraTracking` into `ns.FindScrollOverrides`; nothing between those two calls may take another.
- **Reading `UnitLevel("player")` inside a `PLAYER_LEVEL_UP` handler**: it still returns the old level. Use the level the event passes, as Core and `ns.UpgradeRestockList` do.
- **`UseContainerItem` at a merchant sells the item**: the bank restock loop must never run with the merchant window open. Guarded in `RunRestockLogic`.
- **`PutItemInBag` or `PutItemInBackpack` in the bank engine**: both clear the cursor even when the server refuses the item, so "did it land" always reads yes. The split primitives in `Restocker-Bags.lua` name an empty slot themselves.
- **A second handler for an event the Restock List already uses**: `ns.restockerEventHandlers` keeps one handler per event, so the later entry silently replaces the earlier one. Share the existing entry.
- **Counting Restock List items by name**: a saved line whose name never resolved reads as 0 in bags and buys a full stack of something already carried. Count by itemID; the reagent count is the one exception, only because merchants report names.
- **Folding a nil-default flag into `x and false or nil`**: `false` is falsy, so the `or` takes over and the expression yields nil for every input. The off state becomes unstorable and the setting comes back on at the next login (see `ItemFromString`).
- **Reusing a retired saved key**: whatever a player saved under the old meaning is still in the file and reads straight back. Clear the old name explicitly and choose a new one.
- **Changing a shipped default**: AceDB strips a value equal to its default at logout, so every player still on the old default silently moves to the new one. A default change is a behavior change for existing players, not just for new installs.
- **Assuming another character's list exists**: AceDB strips default-valued tables at logout, so a character who never ignored anything has no stored `ignoreList`. Anything walking `ns.db.sv.profiles` treats a missing subtable as normal and creates on write, never on read.
- **Indexing a default subtable at logout**: AceDB strips default-valued tables on `PLAYER_LOGOUT` before the add-on's own handler runs, so an empty default such as `framePosition` is already nil there. Logout code writes whole values instead of indexing a default subtable (see `ns.SaveRestockWindowGeometry`).
- **Mixing the two character-key formats**: AceDB profiles are `"Name - Realm"`, or `"Name - <ruleset>"` on WoW Forever; the Restock List's `listsByCharacter` and `starterListDismissed` use `ns.GetCharacterKey()`, `"Name-Realm"` with the realm's spaces stripped, on every client.
- **Blizzard dropdowns in the hand-built Restock List window**: `UIDropDownMenu` drives shared global frames its own secure code also uses, so running through them leaves taint behind. Both menus use an `AceGUI:Create("Dropdown-Pullout")` and close explicitly on pick.
- **`PLAYER_ENTERING_WORLD` refires on every loading screen**: SavedVariables setup happens on `PLAYER_LOGIN` only, and the List Builder's trigger checks `isInitialLogin`. Keep new login work behind those, never on this event alone.
- **Reading a secret value on Forever**: while the client restricts aura or unit data, comparing a returned field errors. Ask `C_Secrets` at the entry point and answer with the last reading, as the player snapshot, the pet probe and the target signature do; never reset to empty, which reads as "no buffs".
- **A Readiness check that calls an API one client lacks**: `ns.OnReadyCheck` runs its checks unguarded, so the error silences the whole report on that client. Reach the API through an accessor in `Features/Utilities.lua` that answers nil where it is missing, and give it an API Endpoints row.
- **Adding an all-clear line to the Readiness Report**: silence is the feature. A report that fires when everything is fine is one players switch off entirely.
- **Adding a Readiness Report switch in one place**: a new switch also needs its panel row, Diagnostics' `READINESS_SWITCHES` and the offline suite's all-off settings, and its key needs the `readiness` prefix so the panel's Reset reaches it.
- **Trusting a green offline suite**: a real-file suite crashes on a new cross-file call it has no stub for, so grep the `Tests/` folders for the file you changed and stub the call in each suite that loads it; a model suite (Planner, Buy Extra, Reagent Buy, Column Layout) keeps passing against the old behavior, so mirror a change to a modelled algorithm in its model.
- **Putting a new setting on the wrong scope**: the profile is the default here, because consumable choices genuinely differ per character. Add to `global` only for a concrete account-wide reason, and write that reason in `Data/Default-Settings.lua`.
- **Editing non-enUS locale files by hand**: they are owned by the Localization pass, so hand edits get overwritten. enUS only.
- **StyLua and luacheck**: run `stylua` (default config) over every Lua file before committing, then a clean `luacheck .` from the add-on root. `Includes/` is vendored and never touched by either, and luacheck also skips `.claude/`; everything else, the offline suites included, is linted.

## Contributing

- **Issues**: [GitHub Issues](https://github.com/Gogo1951/Connoisseur/issues).
- **Bug reports**: include game version and locale, class and level, repro steps, and the relevant macro body or chat output. The in-game Diagnostic Tools panel (the last entry under Connoisseur in the Options Interface) builds pasteable reports; the Event Log, Connoisseur Context, Item Selection and Readiness Report sections answer most "my macro did not update" and "the report said nothing" tickets.
- **Discord**: <https://discord.gg/eh8hKq992Q>.
- **PR guidelines**: keep a PR to one change; match house style (StyLua defaults plus a clean `luacheck .`) and keep the offline suites passing; ship a migration with any change to saved data's shape (see Changing the Shape of Saved Data); check the 255 macro ceiling for any macro-body change, against ruRU (Style Guide → MESSAGES → Message Length); and update this document when the architecture or the file map changes.
- **Commit and PR descriptions require a User Story.** Do not just say "I changed X." Frame it:

  **Format:** *As a [role], I [needed / wanted] [behavior] so that [outcome]. This change [does X].*

  **Example:** *As a Rogue who ticked Blinding Powder in the List Builder, I needed my Restock List to stock Blinding Powder rather than Infantry Gauntlets so that my merchant visits buy the reagent I asked for. This change fixes the item ID on the Blinding Powder ladder and moves rows already saved under the wrong ID onto the real item.*

  The User Story makes review faster and gives future maintainers context the diff alone will not carry.
