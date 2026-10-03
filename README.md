# Connoisseur & Restocker

Macros that automatically use your best food, water, potions, healthstones, bandages, poisons, and pet food, plus a Restock List that auto-buys and banks your consumables and upgrades them as you level. Quality-of-life automation for peak performance.

**TL;DR**: For levelers and raiders tired of swapping food, water, and potions on their bars every few levels, and of leaving town without enough of them. Connoisseur keeps the buttons current and the bags full.

![Consumable-Connoisseur](https://github.com/user-attachments/assets/326eb93f-329f-4967-b750-909011a05b01)

## Features

🧞‍♂️ **Always the Best Item** // Your buttons rewrite themselves as your bags change, skipping anything your level, profession skill, zone, or an Arena won't let you use. Mana gems, Soulstones, and explosives get buttons too.

🛒 **Restocker, Revisited** // Pick your staples and your Restock List is ready in seconds. A reminder speaks up when you reach town still short of something, and named lists can be shared with your alts.

🎯 **Class-Smart Macros** // Mages and Warlocks conjure straight from their macros at ranks matched to their target, Hunters get an all-in-one pet button, and Rogues poison both weapons from one.

✅ **Readiness Report** // Turn it on, and when a ready check starts you privately learn which consumables or essentials you're missing, before the pull.

🦺 **Safety First** // Put any item on the Ignore List, for one character or all of them, and no macro will ever touch it.

## Setup

1. Install the add-on, ideally using [CurseForge](https://www.curseforge.com/wow/addons/consumable-connoisseur) or [Wago](https://addons.wago.io/addons/connoisseur).
2. Log in. Connoisseur scans your bags and creates its macros in your General macro tab.
3. Drag the dash-prefixed macros (`- Food`, `- Water`, `- Health Potion`, and the rest) onto your action bars.
4. Optional: type `/foodie` to choose which macros exist and tune buff food, scrolls, pet food, and your class options.
5. From level 6, pick your staples when Connoisseur Staples pops up at login, or type `/crs` any time and click Pick Staples.
6. _"Luck favors the prepared, darling."_

## How It Works

### Macros Created

| Macro | Uses |
| --- | --- |
| `- Food` | Best food, plus optional buff food, scroll buffs, and pet buff food |
| `- Water` | Best drink |
| `- Health Potion` | Best healing potion, optionally with your best Healthstone stacked underneath |
| `- Mana Potion` | Best mana potion |
| `- Healthstone` | Best Healthstone |
| `- Mana Gem` | Best Mana Gem, optionally ranked alongside runes and other mana items |
| `- Soulstone` | Best Soulstone |
| `- Bandage` | Best bandage your First Aid skill allows |
| `- Explosives` | Hardest-hitting bomb, grenade, or sapper your Engineering skill allows, with Ez-Thro Dynamite open to everyone |
| `- Feed Pet` | All-in-one pet button (Hunters only) |
| `- Poisons` | Poisons for both weapons from one button (Rogues only) |

**How it picks.** Connoisseur ranks every usable item in your bags:

* A percentage restore beats a flat one, then the biggest restore wins.
* Buff food jumps the queue when Buff Food is on and you're missing Well Fed.
* Conjured food and water can jump it too: turn on Use Conjured Food & Water First and your Food and Water macros eat and drink it before anything that restores more, while you're leveling or whenever else you choose.
* Turn on Use Restock List Food & Water Last and, between two items that restore the same amount, your Food and Water macros use the one that isn't on your Restock List.
* Ties go to whatever loses its worth soonest: conjured items first, then items that only work in one zone, then soulbound ones, then whatever vendors for least.
* Anything you can't use is filtered out, whether that's a level requirement, a missing profession skill, or the wrong zone.
* Inside a PvP Arena, where the game blocks ordinary food and drink, only conjured items and the arena's own drinks are offered.
* Macros can't be edited in combat, so the Potion and Healthstone macros carry your best item plus up to two fallbacks. On a long fight the icon can go stale, but a press still uses the best item in your bags.
* Coming from an add-on with one button for both? Turn on Use Food & Water in Potion Macros Out of Combat and your Health Potion macro eats, and your Mana Potion macro drinks, whenever you're out of combat.

### Restocker

* **Build your list in ten seconds.** From level 6, Connoisseur Staples pops up at login while your Restock List is empty. Tick the staples you carry (food, water, ammo, poisons, class reagents, even your Hearthstone), pick how many stacks of each, and you're done. After that, `/crs` opens your Restock List any time: Pick Staples brings the staples back, and you can drop in anything else from your bags.
* **Your list levels with you.** Food, water, ammo, poisons, potions, and class reagents climb their upgrade paths as you level, and every swap is announced in chat. Refreshing Spring Water becomes Ice Cold Milk at 5, Melon Juice at 15, Sweet Nectar at 25, and so on. Anything above your level, or without an upgrade path, stays exactly where you put it.
* **Rogues get a bonus.** Put the finished poison on your list and its ingredients buy themselves at any merchant that stocks them all.
* **Reminders** speak up when you reach an inn or a city short of something, or when you close a merchant or the bank with orders still outstanding. Pick one line or item by item, with an optional alert sound for busy chat.
* **Named lists** let a character switch loadouts or share one with an alt. Copy, rename, and delete all live in the window.
* **Hold Shift** while opening a merchant or the bank to skip restocking for that visit.

<img width="800" src="https://github.com/user-attachments/assets/62a9acfb-6c3d-4443-bf73-3af49ae3a5ec" />

### Class & Race Features

* **Druids** // With DruidMacroHelper integration on, your Health Potion, Mana Potion, and Healthstone macros powershift you out of form, use the item, and put you back in Bear or Cat.
* **Hunters** // `- Feed Pet` is an all-in-one pet button. Left-Click calls, feeds, or revives your pet, feeding it the lowest-level food that still gives full happiness. Right-Click, or click during combat, to cast Mend Pet. Hold Shift to force Revive, or Ctrl to Dismiss.
* **Mages** // Right-Click Food or Water to conjure more, or Middle-Click either one for Ritual of Refreshment. Right-Click Mana Gem to conjure a gem, and again for a lower-rank backup. Targeting a lower-level player conjures food or water they can use.
* **Night Elves** // Stealth Drinking and Stealth Eating add Shadowmeld to the Water or Food macro. Pick one, since eating or drinking after you stealth breaks it.
* **Rogues** // Left-Click `- Poisons` for your Off Hand, Right-Click for your Main Hand, or Middle-Click to open the Poisons window. Pick each hand's poison in the options, and old poisons are replaced automatically. Stealth Eating slips you into Stealth while you snack.
* **Warlocks** // Right-Click Healthstone to create one, and again for a lower-rank backup, or Middle-Click it for Ritual of Souls. Right-Click Soulstone to create one. Targeting a lower-level player makes a Healthstone sized for them.

### Mini-Map Button

* Hover for your current best food, the state of Buff Food and Scroll Buffs, the Restocker List, notes for your class, a Restocker Report of what's still short, and this character's Ignore List.
* The icon changes to match your current best food.

| Action | Effect |
| --- | --- |
| Left-Click | Toggle Buff Food |
| Shift + Left-Click | Toggle Scroll Buffs |
| Right-Click | Ignore your current best food |
| Shift + Right-Click | Open or close the Restocker List |
| Middle-Click | Clear this character's Ignore List |
| Shift + Middle-Click | Open the Options Interface |

<img width="300" src="https://github.com/user-attachments/assets/a2e70f47-00a1-4259-9401-d07d0d2200ec" />

### Options

Type `/foodie` to open the Options Interface, also found under **Options > AddOns > Connoisseur**, or `/crs` to open your Restock List.

* **Connoisseur** // The welcome message, the mini-map button, the `/foodie` and `/crs` commands, and where to reach the author.
* **Macros** // Which macros exist and how each one picks: buff food, scroll buffs, conjured food and water, buff re-application, pet food buffs, eating and drinking from the potion macros, Healthstone stacking, runes and other mana items, explosive clicks, and the class options. Connoisseur hides macro names on your action buttons unless you switch them back on here.
* **Ignore List** // Items no macro will ever offer, on the Global list for every character or on one character's own list.
* **Restocker** // Reminders and how much they say, the alert sound, opening the window at a bank or merchant, the Connoisseur Staples pop-up, and the Inventory Report that adds your bag, bank, and alt counts to item tooltips.
* **Readiness Report** // What a ready check reports on. It ships switched off, so turn it on to use it.
* **Profiles** // Copy one character's setup onto another, or reset one back to defaults.
* **Diagnostic Tools** // Read-only probes to paste into a bug report.

Most settings are per character, so your raiding 60 and your level-15 alt keep their own consumable choices. Which macros exist, the mini-map button, the Restocker and Readiness Report settings, and your Restock Lists are account-wide, though each character picks the list it shops from.

<img width="800" src="https://github.com/user-attachments/assets/0f234519-72ad-44f9-b97d-5cffce8634c6" />

## Testing & Localization Status

🔴 World of Warcraft // 12.1.0

🔴 Mists of Pandaria Classic // 5.5.4

🟢 Burning Crusade Anniversary // 2.5.6

🟢 World of Warcraft: Forever // 1.60.1

🟡 World of Warcraft: Season of Discovery // 1.15.9

🟢 World of Warcraft: Classic // 1.15.9

**Available Locales** // enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW

## Appreciation & History

🚀 **This add-on stands on the shoulders of those that came before.**

* targon's [Free Refills](https://www.wowinterface.com/downloads/info7950-FreeRefills.html)
* kvakvs's [Restocker Classic](https://www.curseforge.com/wow/addons/restocker-classic)
* guardycmw's [Restocker (MoP)](https://www.curseforge.com/wow/addons/restocker-mop)

## Get Involved

❤️ **You can help make this better!** Feedback, code contributions, testing, and localization assistance are always appreciated. If you'd like to get involved, please reach out.

* [GitHub](https://github.com/Gogo1951/Connoisseur-Restocker)
* [Discord](https://discord.gg/eh8hKq992Q)

## Related Add-ons

### 🟢 Pairs With

* ForsakenNGS's [DruidMacroHelper](https://www.curseforge.com/wow/addons/druidmacrohelper)
* Gogo1951's [Magic Eraser](https://www.curseforge.com/wow/addons/magic-eraser)
* ykiigor's [Method Raid Tools](https://www.curseforge.com/wow/addons/method-raid-tools)
* Gogo1951's [Play It Forward](https://www.curseforge.com/wow/addons/play-it-forward)
* Gogo1951's [Water Dispenser](https://www.curseforge.com/wow/addons/water-dispenser-revisited)

### 🟡 Overlaps

* Kemayo's [BankStack](https://www.curseforge.com/wow/addons/bank-stack)
* kvakvs's [Buffomat Classic](https://www.curseforge.com/wow/addons/buffomat-classic)
* Pupp3h's [Buffwatch Classic](https://www.curseforge.com/wow/addons/buffwatch-classic)
* lanscetre's [Necrosis all version](https://www.curseforge.com/wow/addons/necrosis-tbc-classic-bcc-for)
* Venomisto's [Nova Consumes Helper](https://www.curseforge.com/wow/addons/nova-consumes-helper)

### 🔴 Alternatives

* ollidiemaus's [Auto Potion](https://www.curseforge.com/wow/addons/auto-potion)
* MuffinManKen's [AutoBar Classic](https://www.curseforge.com/wow/addons/autobar-classic)
* mZHg's [Buffet](https://www.curseforge.com/wow/addons/buffet)
* executedpoorly's [Feed Me](https://www.curseforge.com/wow/addons/feed-me)
* humfras's [Poisoner](https://www.curseforge.com/wow/addons/poisoner)
