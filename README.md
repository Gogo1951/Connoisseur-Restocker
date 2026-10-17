# Connoisseur & Restocker

Macros that automatically use your best food, water, potions, healthstones, bandages, poisons, and pet food, plus a Restock List that auto-buys and banks your consumables and upgrades them as you level. Quality-of-life automation for peak performance.

**TL;DR**: For levelers and raiders tired of swapping food, water, and potions on their bars every few levels, and of leaving town without enough of them. It keeps the buttons current and the bags full.

![Consumable-Connoisseur](https://github.com/user-attachments/assets/326eb93f-329f-4967-b750-909011a05b01)

## Features

🧞‍♂️ **Always the Best Item** // Your buttons rewrite themselves as your bags change, skipping anything you can't use yet.

🛒 **Restocker, Revisited** // Pick your staples and your Restock List is ready in seconds, with a reminder when you reach town still short.

🎯 **Class-Smart Macros** // Mages and Warlocks conjure straight from their macros at ranks matched to their target, Hunters get an all-in-one pet button, and Rogues poison both weapons from one.

✅ **Readiness Report** // Turn it on, and when a ready check starts you privately learn which consumables or essentials you're missing, before the pull.

🦺 **Safety First** // Put any item on the Ignore List, for one character or all of them, and no macro will ever touch it.

## Setup

1. Install the add-on, ideally using [CurseForge](https://www.curseforge.com/wow/addons/connoisseur-restocker) or [Wago](https://addons.wago.io/addons/connoisseur).
2. Log in. Connoisseur scans your bags and creates its macros in your General macro tab.
3. Type `/m` to open the in-game Macro interface, then find the dash-prefixed macros (`- Food`, `- Water`, `- Health Potion`, `- Poisons`, and the rest) in the General tab and drag them onto your action bars.
4. Pick your staples when Connoisseur Staples pops up at login, or type `/crs` any time and click **Pick Staples**. From then on, whenever you visit a vendor or your bank, Connoisseur keeps you stocked.
5. Optional: type `/foodie` to customize settings.
6. _"Luck favors the prepared, darling."_

## How It Works

### Macros

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
* Buff food jumps the queue when you're missing Well Fed, and conjured food and water can go first whenever you choose.
* Ties go to whatever loses its worth soonest: conjured items first, then items that only work in one zone, then soulbound ones, then whatever vendors for least.
* Anything you can't use is skipped, whether that's a level requirement, a missing profession skill, or the wrong zone.
* Inside a PvP Arena, only conjured items and the arena's own drinks are offered.
* Want one button for both? Your Health Potion macro can eat, and your Mana Potion macro drink, whenever you're out of combat.

#### Class & Race Features

* **Forsaken** // Target a Humanoid or Undead you've killed and your Food macro casts Cannibalize instead, and on WoW Forever your Water macro too.
* **Night Elves** // Stealth Drinking or Stealth Eating slips Shadowmeld into your Water or Food macro.
* **Druids** // With DruidMacroHelper, your Health Potion, Mana Potion, and Healthstone macros powershift you out of form and back into Bear or Cat.
* **Hunters** // `- Feed Pet` calls, feeds, or revives your pet on Left-Click, feeding it the lowest-level food that still gives full happiness, and casts Mend Pet on Right-Click.
* **Mages** // Right-Click Food, Water, or Mana Gem to conjure more, or Middle-Click Food or Water for Ritual of Refreshment. Target a lower-level player to conjure food or water they can use.
* **Rogues** // Left-Click `- Poisons` for your Off Hand, Right-Click for your Main Hand, or Middle-Click to open the Poisons window. Stealth Eating slips you into Stealth while you snack.
* **Warlocks** // Right-Click Healthstone or Soulstone to create one, or Middle-Click Healthstone for Ritual of Souls. Target a lower-level player to make a Healthstone sized for them.

### Restocker

* **Build your list in ten seconds.** From level 6, Connoisseur Staples pops up at login while your Restock List is empty. Tick the staples you carry (food, water, ammo, poisons, class reagents, even your Hearthstone), pick how many stacks of each, and you're done. `/crs` opens the list any time, and you can drop in anything else from your bags.
* **Your list levels with you.** Food, water, ammo, poisons, potions, and class reagents climb their upgrade paths as you level, and every swap is announced in chat. Refreshing Spring Water becomes Ice Cold Milk at 5, Melon Juice at 15, Sweet Nectar at 25, and so on.
* **Rogues get a bonus.** Put the finished poison on your list and its ingredients buy themselves at any merchant that stocks them all.
* **Reminders** speak up when you reach an inn or a city short of something, or leave a merchant or the bank with orders still outstanding.
* **Named lists** let a character switch loadouts or share one with an alt.
* **A Gold Reserve** keeps restocking from spending your last gold.
* **Inventory Tooltips** show how many of any item you have in your bags, your bank, and on your other characters on the realm.
* **Hold Shift** while opening a merchant or the bank to skip restocking for that visit.

<img width="800" src="https://github.com/user-attachments/assets/62a9acfb-6c3d-4443-bf73-3af49ae3a5ec" />

### Readiness Report

Turn it on, and when a ready check starts you get a private list in chat of what still needs fixing. When you're ready, it says nothing at all.

```
Connoisseur // Readiness Report
Connoisseur // Missing Buffs : Well Fed, Scrolls. Expiring Soon : Arcane Intellect 2 min
Connoisseur // Missing Items : Healthstone, Mana Potion
Connoisseur // Character : Frost (17/0/33), 1 Unspent Talent Point
```

* **Missing Buffs** // Flask or elixirs, Well Fed for you and your pet, scrolls, weapon buffs, and your group's Soulstone.
* **Missing Items** // Healthstone, Mana Gem, potions, bandages, and gear close to breaking.
* **Character** // Your spec and any unspent talent points, a PvP flag, and fishing or riding gear left on.

### Mini-Map Button

* Hover for your current best food, the state of Buff Food & Scrolls and the Readiness Report, the Restocker List, notes for your class, a Restocker Report of what's still short, and this character's Ignore List.
* The icon changes to match your current best food.

| Action | Effect |
| --- | --- |
| Left-Click | Toggle Buff Food and Scroll Buffs together |
| Shift + Left-Click | Toggle the Readiness Report |
| Right-Click | Ignore your current best food |
| Shift + Right-Click | Open or close the Restocker List |
| Middle-Click | Clear this character's Ignore List |
| Shift + Middle-Click | Open the Options Interface |

<img width="300" src="https://github.com/user-attachments/assets/a2e70f47-00a1-4259-9401-d07d0d2200ec" />

### Options

Type `/foodie` to open the Options Interface, also found under **Options > AddOns > Connoisseur**, or `/crs` to open your Restock List.

* **Connoisseur** // The welcome message, the mini-map button, an on/off switch for each feature, and the `/foodie` and `/crs` commands.
* **Macros** // Which macros exist and how each one picks: buff food, scroll buffs, conjured food and water, buff re-application, pet food buffs, eating and drinking from the potion macros, Healthstone stacking, runes and other mana items, and explosive clicks. Connoisseur hides macro names on your action buttons unless you switch them back on here.
  * **Class & Race** // Druid powershifting, Rogue poisons and Stealth eating, Forsaken Cannibalize, and Night Elf Shadowmeld drinking. Every section shows on every character.
  * **Ignore List** // Items no macro will ever offer, on the Global list for every character or on one character's own list.
* **Restocker** // Reminders and how much they say, the alert sound, the Gold Reserve, opening the window at a bank or merchant, the Connoisseur Staples pop-up, and the Inventory Report that adds your bag, bank, and alt counts to item tooltips.
* **Readiness Report** // What a ready check reports on. It ships switched off, so turn it on to use it.
* **Profiles** // Copy one character's setup onto another, or reset one back to defaults.
* **Feedback & Support** // Where to reach the author, and how you can help the add-on grow.
* **Diagnostic Tools** // Read-only probes to paste into a bug report.

Most settings are per character, so your raiding 60 and your level-15 alt keep their own consumable choices. Which macros exist, the mini-map button, the Restocker and Readiness Report settings, and your Restock Lists are account-wide, though each character picks the list it shops from.

<img width="800" src="https://github.com/user-attachments/assets/0f234519-72ad-44f9-b97d-5cffce8634c6" />

## Testing & Localization Status

🔴 World of Warcraft // 12.1.0

🔴 Mists of Pandaria Classic // 5.5.4

🟢 Burning Crusade Anniversary // 2.5.6

🟢 World of Warcraft: Forever // 1.60.1

🟢 World of Warcraft: Season of Discovery // 1.15.9

🟢 World of Warcraft: Classic // 1.15.9

**Available Locales** // enUS, deDE, esES, esMX, frFR, itIT, koKR, ptBR, ruRU, zhCN, zhTW

## Appreciation & History

🚀 **This add-on stands on the shoulders of those that came before.**

* targon's [Free Refills](https://www.wowinterface.com/downloads/info7950-FreeRefills.html)
* kvakvs's [Restocker Classic](https://www.curseforge.com/wow/addons/restocker-classic)
* guardycmw's [Restocker Kit](https://www.curseforge.com/wow/addons/restocker-kit)

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
