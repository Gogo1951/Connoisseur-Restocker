# Connoisseur // Notes

> The maintainer's settled rulings for Connoisseur, kept so no review raises them again: exceptions to the Gogo1951 add-on Style Guide, and decisions it leaves open.

## Exceptions

### Profiles panel without suggested profiles (remove after 2026-10-30)

- **Departs from:** OPTIONS PANEL → Profiles Panel, "returns the stock AceDBOptions-3.0 table unmodified".
- **Instead:** The Profiles panel is built with AceDBOptions' `noDefaultProfiles` flag, so its pickers list only profiles that exist, never the suggested Default, realm and class profiles.
- **Why:** While the migration that moves characters off the shared Default profile runs, a character put on Default is moved off it again at its next login.

## Decisions

- The TOC `## Title`, `README.md`'s H1 and the Inventory Report header on item tooltips are `Connoisseur & Restocker`, for discoverability of the absorbed Restocker feature; every other surface says `Connoisseur`.
- A WoW Forever character is kept and shown by its first name and surname everywhere the add-on saves or names one; Classic Era and TBC characters keep their one name.
- The Ignore List is per character, living on the character's own profile; the Global list sits outside every profile and applies to every character.
- The mini-map button's Middle-Click clears the current character's Ignore List instantly, with no confirmation, and the Ignore List panel ships no clear-all of its own.
- Enable Inventory Report in Item Tooltips sits on the Restocker options page under an Inventory Report header, not on the root page.
- Every row of the Inventory Report tooltip block sits one space in from its header, Water Dispenser's pad, so the rows read as the header's own.
- The mini-map tooltip reads, top to bottom: Current Food (the item the icon shows), Buff Food, Scroll Buffs, Restocker List, the class notes, the Restocker Report, the Ignore List, then Options.
- The Restocker List is a tooltip block of its own with a line saying what it is and its click, never a row of the Restocker Report: it is a feature of the button, and a report must not hide it.
- A lone item in the tooltip sits right-aligned on the row under its title. Off-Hand Poison carries its hyphen in that title, while the macro rows and the options page say Off Hand.
- Class notes in the tooltip are one row per click, the click on the left and what it does on the right, in the palette's HELP silver, so INFO blue marks only a click on the mini-map button itself.
- The tooltip's Ignore List shows eight items at most and a count past that, the Restocker Report's own limit.
- A Buff Food or Scroll Buffs switch that is on while its when-to-use choice does not apply shows that choice in gray in the tooltip, in place of Enabled.
- `README.md`'s Appreciation & History thanks only targon (Free Refills), kvakvs and guardycmw, under the 🚀 lead line: Connoisseur is Gogo1951's own, Restocker is an absorbed subsystem, and ChiliFajita's Auto Restocker is gone from CurseForge and GitHub. The in-game Restocker Praise string names ChiliFajita, kvakvs and guardycmw.
- `README.md`'s Related Add-ons files an add-on built around one Connoisseur job, such as Poisoner or Feed Me, under 🔴 Alternatives.
- Restock Lists are global (`ns.db.global.restocker`), outside every profile, so a profile switch or reset never touches a list or re-offers the Starter List; each profile only picks which list it uses, and resetting a profile keeps that pick.
- New Restock Lists are named for the character's localized class, numbered "Class (2)" on collision, and never auto-join an existing list; legacy "Name-Realm" lists stay as they are, and there is no eponymous backstop list.
- Deleting the Restock List in use moves the character to the top list in the List selector, another character's included, and makes a new empty class-named list only when the deleted list was the last one.
- The characters on a Restock List are named in their class colors, left uncolored while the class isn't known yet.
- Restock Lists are called "List" in every player-facing string, never "Profile"; the `RESTOCKER_PROFILE_*` key names and the `/crs profile` literal keep their spelling, and the values are never changed to match them.
- The Restock List window's Keep box saves as you type: closing the window keeps what the box holds, an emptied box lands at 0 (store-all for bank deposits), and its tooltip says nothing about pressing Enter.
- The Restock List window's second row runs: the filter, Add Item from Bags (every bag item not already on the list, its caption in the hints' grey), the add box with its Add button, then Pick Staples.
- The Restock List window takes dragged items and typed item IDs only: both clients route Shift + Click through `ChatFrameUtil.InsertLink`, which an add-on can't claim without overwriting a Blizzard function.
- Red text is for errors alone. A Keep amount the bags are short of is yellow, as is the orders count that explains it; the add box's notice, an error, stays red.
- Whatever a click acts on in the Restock List window is a button or a field, never a colored word, so Undo is a button: blue marks information.
- The list bar's button reads Manage Lists.
- An item named in the add-on's own windows, panels and tooltips is its icon and its name in its quality color, with no square brackets; chat lines keep the game's clickable bracketed links.
- A checkbox that stands for an item or a macro carries its icon between the box and the name, a space off the name.
- The staples pop-up names its poison and reagent rows with the client's own item names: a poison type by its ladder's first item, any other row by the item a tick adds. Only rows that stand for a kind of item (the food diets, water, ammo) keep a label, and the Macros panel names poison groups and pet foods from the client the same way. Its rows live once, in `Data/Data.lua`, never per flavor folder, and its window fits Rune of Teleportation on one line.
- The staples pop-up has a solid background, one grid of checkboxes and dropdowns through every section, and Water in the food grid.
- A Buy toggle off on a Restock List row stops every purchase the row makes, a poison's ingredients included.
- The Restock window closes with a merchant or bank only when that visit opened it; one the player opened stays open, through loading screens too.
- The Gold Reserve ships on at 1 gold, applies at every level, and is account-wide, kept with the Restock Lists: a character with less than the reserve buys nothing and is told restocking paused.
- Files inside a `Features/` feature subfolder carry the feature name in the basename (`Features/Restocker/Restocker-Window.lua`); `Features/Macros/` keeps its own file names.
- Every `ns` function is dot-defined (nothing on the namespace takes `self`), including where guide snippets show colon methods.
- The Readiness Report ships default-off behind `readinessReportEnabled` as a beta soft launch, and stays default-off.
- The Readiness Report's Flask or 2x Elixirs check counts the zone-limited flask and elixir auras (the Unstable and Shattrath flasks, and Bloodberry) as flasked everywhere, because those auras persist outside their zones and the check errs toward silence.
- The Readiness Report counts an item on either Ignore List as carried.
- The Poisons macro keeps its `/click StaticPopup1Button1` replace confirmation even though it also accepts any other confirmation box on top; a Weapon Buff macro may reuse it.
- The Feed Pet macro's "You don't currently know Mend Pet." stays its own locale string (`TIP_PET_NO_MEND`): joining `TIP_DONT_KNOW_SPELL` would put Mend Pet's spell ID in every data folder, and only esES on TBC Anniversary names the spell differently.
- Where one language's clients name the same spell, item or label differently, its locale file uses the Classic Era and WoW Forever name, so one string serves all three clients.
- Use Conjured Food & Water First (Food and Water only, off by default, When Leveling by default) is the only way a macro passes over your best item. Every other macro always uses the best, with no custom sort orders or second-best rules (issue #40).
- The options panel shows macro names without their leading "- "; the macros themselves keep it.
- Buff Food, Scroll Buffs and Use Conjured Food & Water First share one Food & Water section, each described in its own hover text; Buff Re-Application and Pet Food Buffs keep their own sections.
- Every when-to-use dropdown offers the same six choices in the same order, none trimmed per feature: Always, When Solo, When in a Party or Raid, When in a Raid, When Leveling, When at Max Level. Leveling means below the client's own max level, and group and level never combine.
- Every options dropdown is the same width; a choice too long for it gets shorter copy, so the Explosives layouts name only the Left-Click.
- The Potions & Healthstones option that eats and drinks out of combat is labeled Use Food & Water in Potion Macros Out of Combat, in the Use wording of its neighbors.
- The class notes in the mini-map tooltip, the Macros panel's class and race sections, and the staples pop-up's Poisons note are headed with the client's own singular name for the class or race, with no "Attention" lead.
- The consumable tables leave out oddball items a data check turns up, even when they share a table's cooldown: Scorpid Surprise (5473), Green Tea Leaf (1401), Holy Spring Water (737) and Night Dragon's Breath (11952).
- The pet-food tables leave out foods Feed Pet would waste, even when the client gives them a pet diet: special foods that sell for nothing (Whipper Root Tuber, Essence Mango, holiday foods) and battleground or zone rations, since Feed Pet feeds the cheapest food first.
- Season of Discovery items live only in `Data/Discovery/`, with a deliberately-absent note in every other folder, even where its client's Validate Data reports them OK.
- A Classic Era Validate Data report also prunes `Data/Discovery/`: a row Era flags NOT ON CLIENT leaves Discovery too, while Discovery's values wait for a Season of Discovery export.
- Star's Tears and Star's Lament are offered only inside an arena (arena column 1): they are expensive, and ordinary food and water serve better outside one.
- The four Ogre Brews keep Gruul's Lair (330) among their allowed zones: they work there, though their tooltip names only the Blade's Edge Plateaus.
- Harvest Bread and Winter Veil Loaf carry no arena value though their tooltips say Conjured Item: the TBC client doesn't flag them usable in arenas, and since the arena column is the only test for conjured, Use Conjured Food & Water First treats them, like anything that merely sells for nothing, as ordinary food.
