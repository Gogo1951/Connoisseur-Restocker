# Connoisseur // Manual Test Plan

This is the manual test plan for Connoisseur, the steps to confirm it works before a release is tagged. For what it does, see [README.md](https://github.com/Gogo1951/Connoisseur-Restocker/blob/main/README.md); for how it works, see [README-Technical.md](https://github.com/Gogo1951/Connoisseur-Restocker/blob/main/README-Technical.md).

## Before you start

**Run the whole list on each flavor in turn: Classic Era, Season of Discovery on the Classic Era client, WoW Forever, and TBC Anniversary.** Steps are numbered continuously so you can report "failed on step N."

Gather these once so you aren't caught short mid-run:

- **Lua errors on screen.** Type `/console scriptErrors 1`, or install BugSack, so no error slips past unseen.
- **Two characters on one realm with saved data from 2026.09.24.A**, for steps 1, 2, 6 and 10. Before you install this build, while 2026.09.24.A is still installed, put both on the **Default** profile (**Options > Connoisseur > Profiles**, **Existing Profiles**), give each a different Restock List with a few rows, and have both carry some of one item. On the first, tick **Enable Scroll Buffs** on the **Macros** page and Right-Click the mini-map button to ignore your current food.
- **A full restart after installing.** Quit the game completely and start it again. This build adds files the game reads only at startup, so a `/reload` over the old version gives a Lua error at login. That error is not a bug.
- **A Mage** that knows at least two ranks of Conjure Water, and **a second player of a lower level** you can target and group with, for steps 14, 17 and 20.
- **A Hunter** that knows Mend Pet, with its pet out and at least one food it eats in the bags.
- **A Warlock** that knows at least two ranks of Create Healthstone and one of Create Soulstone, carrying a Soulstone.
- **A Rogue with Poisons trained**, carrying poison, with a poison on its Restock List set above what it carries.
- **Vendors scouted before you start:** one selling items you can put on your list, one stocking **every** reagent your listed poison needs, one stocking **only some** of them, and one listing an item you lack the reputation to buy.
- **Bank access**, with at least one bank bag bought on Classic Era, Season of Discovery and TBC Anniversary and one bank tab on WoW Forever, plus enough spare items to fill the bank for step 8.
- **A loading screen you can cross**: a boat, a zeppelin, or an instance portal.
- **Something to fight**, any open-world mob or a target dummy.
- **On WoW Forever, a Scroll of Rat Familiar**, which a Mage and then a non-Mage carry in step 13.
- **In your bags:** a Hearthstone, a buff food and at least two plain foods of different quality, with no Well Fed buff on you, plus water, a Healthstone, a healing potion and a mana potion.
- **Any non-English client**, for the optional last step.

Unless a step says otherwise, be **out of combat with no target selected**. Untick **Enable Diagnostic Tools** when a step that used it is done: while it's on, every bank restock prints a step-by-step trace to chat.

This plan deliberately skips casting Ritual of Refreshment and Ritual of Souls, Rogue poison hands, Druid DruidMacroHelper wraps, Night Elf stealth eating, Goblin and Gnomish explosives, the Feed Pet quest-food skip, the macro size limit on a Russian client, Use Conjured Food & Water First, the Food & Water option layout, the Readiness Report's per-flavor switches, Restock List upgrades on level-up, the staples pop-up's login offer, the arena rules, and the Event Registration, Item Selection and Saved Variables reports in Diagnostic Tools. Refresh coverage there when a release touches those systems.

## Verify this release's changes

Since the last release (2026.09.24.A), every character has a profile of its own again, and with it its own settings and Ignore List beside the Global one. The Restock List is still shared, and each profile picks the list it uses. On WoW Forever a character is known by its first name and surname.

The Restock List window has been rebuilt. It gains:

- the list's controls across the top;
- a Keep amount beside each item that turns yellow while your bags are short;
- a count of outstanding orders under the list;
- Undo for a removed row;
- column menus;
- **Add Item from Bags**;
- a page of its own for an empty list.

The staples pop-up becomes **Connoisseur Staples**, item tooltips gain an Inventory Report, and the mini-map tooltip is rebuilt, with Shift + Right-Click now opening the Restock List. The potion macros can eat and drink out of combat.

The Restocker also changes. A bank run fixes its Keep amounts when it starts and, when the bank is full, takes before it stores. A merchant run skips what gold alone can't buy, keeps a Gold Reserve (on at 1 gold, step 22), and no longer under-buys a reagent that has a row of its own.

WoW Forever's data is reworked, with Mage-only familiar scrolls. Validate Data waits for spell text. The Readiness Report stops asking for a Soulstone while the stones are on cooldown, and its PvP line is no longer red. Run these first, on every flavor.

**Upgrading from 2026.09.24.A**

**1.** *The two characters you set up on 2026.09.24.A, after the full restart.* Log in the first. No Lua error may appear, and the **Connoisseur Staples** window must not open by itself.

Open **Options > Connoisseur > Profiles**:

- **Current Profile** must be the character's own name: `Name - Realm` on Classic Era, Season of Discovery and TBC Anniversary, and its first name and surname on WoW Forever.
- **Existing Profiles** must not offer **Default**. On WoW Forever an old `Name - PvE` profile, and **Default** beside it, may stay listed. That is expected.
- **Enable Scroll Buffs** must still be ticked on the **Macros** page.
- The food you ignored must still be listed in the mini-map tooltip's Ignore List.

Type `/crs`: the **List** selector must show the list this character used, with every row. On WoW Forever, the "Used by" line must name the character once, by first name and surname.

Log in the second character: it too must be on its own profile, with **Enable Scroll Buffs** ticked and the same food ignored, since the two shared **Default**, and on its own list.

Failure is any of these:

- a character still on **Default**, or settings back at their defaults;
- the ignored food offered again;
- a new empty list named for your class, such as "Mage (2)";
- the staples window opening;
- a WoW Forever character named by its first name alone or listed twice.

**One profile per character**

**2.** *The same two characters.* On the second, untick **Enable Scroll Buffs**. Log back in to the first: it must still be ticked there.

Right-Click the mini-map button to ignore your current food, and open **Options > Connoisseur > Ignore List**. The tree must read **Global**, then the profiles that hold ignored items, this character's among them. The food must be on this character's page, shown as its icon and its name with no square brackets.

Log in the second character. The food you just ignored must not be on its page, and `- Food` must still offer it when it is this character's best. From here, open the first character's page and press **Global** beside the item: the row must leave that page and appear under **Global**, and the item must now be ignored on both characters. Remove it from **Global**: it must be ignored on neither.

On the **Profiles** page:

- **Existing Profiles**, **Copy From** and **Delete a Profile** must each list only profiles that exist, never a realm or class name.
- Pick the first character's profile under **Existing Profiles**: the **List** selector in `/crs` must switch to the first character's list. Pick your own back: your own list must return with every row.
- Press **Reset Profile**: the Macros settings must return to their defaults, apart from **Enable Macros** and **Enable Macro Names on Buttons**, which are account-wide and stay as they were. This character's Ignore List must empty, and the Restock List window must keep the same list and every row on it.

Failure is any of these:

- a setting that followed you to the other character;
- an item ignored on a character that never ignored it;
- a **Global** item that either character's macros still use;
- a suggested profile nobody made;
- a list that doesn't follow the profile;
- a Restock List emptied or swapped by the reset;
- a Lua error.

**The Restock List window**

**3.** Type `/crs`. If your Hearthstone isn't on the list, add it with **Add Item from Bags**.

The top of the window:

- The title bar must read **Connoisseur Restock List**.
- The **List** selector, a "Used by" line naming every character on the list, and **Manage Lists** must run across the top. Your own name on the "Used by" line must be in your class color.
- The second row must hold the filter, **Add Item from Bags**, the add box with **Add**, and **Pick Staples**. None may touch another, even with the window dragged to its smallest. **Add Item from Bags** must be in the same grey as the two hints beside it, and the space to its right must match the space between **Add** and **Pick Staples**.

The rows:

- Each row must carry its **Keep** box beside the item's name, ahead of the Bank and Merchant columns.
- A Keep above what your bags hold must be yellow, the gold of the headings, never red. One your bags cover, or any Keep of 0, must be white.
- With the window open, visit a vendor who sells a yellow row's item, with that row's **Buy** on: the number must turn white as the purchase lands.

The line under the list:

- It must read "1 restocking order outstanding." or "N restocking orders outstanding.", in the same yellow as those Keep numbers.
- Hovering it must list each order as icon, name and have/wanted under **Restocker Report**.
- Stock every row, then untick **Buy** on one and spend some of its item. That row's **Extra** and **Rep** cells must dim, take no click, and say why on hover. Its Keep must be yellow, and the line must read "No restocking orders outstanding." in white.
- With nothing yellow, the line must read "Congratulations, you're fully stocked up!" in green.

The tooltips and cells:

- Hover a Keep box, then the **Keep** heading. Each tooltip must say the number turns yellow, and neither may tell you to press Enter.
- A row with no standing set must show a dash under **Rep**, not "Any".
- The Hearthstone's **Upgrade** cell must be dimmed and say "This item has no better version to upgrade to."

Failure is any of these:

- a control on the second row overlapping its neighbor;
- a Keep box at the far end of the row;
- a red number on any row, or a yellow number on a stocked row;
- an orders line in another color than the numbers it counts;
- a tooltip that runs off the screen;
- a dimmed cell that still toggles.

**4.** Pick a category on the left, then click the **Buy** heading. Its menu must offer **Turn On for N Shown** and **Turn Off for N Shown**, N being the rows in that category that match the filter. Pick **Turn Off**: every one of those rows must lose its Buy tick, and no row in another category may change.

Click the remove icon on a row. The row must go, and "Removed" must appear beside the count, followed by the item's icon and its name with no square brackets. An **Undo** button must follow, drawn as a button like **Manage Lists**, never as a colored word. Click **Undo**: the row must return with its Keep amount and ticks as they were. Remove it again, then close and reopen the window: the offer must be gone.

Pick up an item from your bags that isn't on the list and click it onto a row's **Buy** cell. Pick up another and click it onto a row's remove icon. Each must join the list under **New**, with nothing toggled and nothing removed.

Click **Add Item from Bags**: its menu must list every item in your bags that is not on the list, each by icon and name, and nothing that is on it. Pick one: it must join the list under **New** keeping one stack, and the menu must close. The next time the menu opens, that item must be gone from it. Keep picking until the menu opens on "Nothing in Your Bags to Add", which no click picks.

Failure is any of these:

- a menu offering an item already on the list, or a pick that adds nothing;
- a heading that changes rows in another category;
- an item named in square brackets;
- an Undo drawn as a word, or one that brings a row back without its settings;
- a dropped item toggling or removing the row under it.

**5.** Click the **List** selector to open its menu, then click it again: it must close. **Manage Lists**, **Add Item from Bags**, the **Buy** heading, and the **Rep** cell of a row with Buy on must each do the same. Open one of those menus and then another: the first must close as the second opens.

Type `999999` in the add box and press Enter. The box must read "No item has ID 999999." in red where its hint was, nothing may print to chat, and no row may appear. Typing again must clear the notice, and emptying the box must bring back the grey "Drop item or type item ID". Type `zzzz` and press Enter: the box must read "Type an item ID instead." in red.

Type `zzzz` in the filter: "Nothing on this list matches your filter." must show under the headings. Clear it.

Click a white Keep box and type a number above what your bags hold, without pressing Enter. The number must turn yellow and the count under the list must rise at once. Close and reopen the window: the number must still be there. Put it back.

Pick up an item from your bags that isn't on the list, and click it onto an empty part of the window. Do the same onto a category on the left and onto the **List** selector. Each must join under **New**, and no menu may open.

At the bank, and again at a merchant, open **Manage Lists** and pick **Delete This List**. The confirmation must appear in front of the window, readable and clickable. Click **No**.

Failure is any of these:

- a menu that stays open on the second click, or two menus open at once;
- a notice printed to chat instead of the box;
- a Keep number that waits for Enter to change color, or one lost when the window closes;
- a dropped item that opens a menu or adds nothing;
- a confirmation hidden behind the window.

**6.** *The two characters from step 1.* On the second, pick the first character's list from the **List** selector, so the two share it.

Open **Manage Lists** and pick **Delete This List**. The confirmation must:

- name the other character in its class color and say "... uses it too, and will log in to an empty list with the same name.";
- say "You'll switch to" followed by the first list in the **List** selector's menu other than this one.

Click **No**.

Open the **List** selector's menu: each list must carry the characters on it beside its name, each in its class color.

Rename and Copy:

- Pick **Rename This List**: the selector must become a field holding the name, selected. Press Escape: the name must be unchanged.
- Rename it again and press Enter: the selector must show the new name, and the first character must log in on the renamed list, not on a new empty one.
- Rename it to the name of another list: chat must print `Connoisseur // A list named "..." already exists.` and the name must stay as it was. Rename it back.
- Pick **Copy This List into a New One**: the window must switch to "<name> Copy" with the same rows, its name ready to type over. Press Escape.

Pick **New List**. The window must show "Nothing on This List Yet", two sentences under it, a **Pick Staples** button and "Dropping an item anywhere on this window adds it too.", the whole block centred in the list area. There must be no column headings and nothing under the list.

Delete the copy and the new list, each while it is the list in use. Each delete must leave you on the first list in the selector's menu, and the menu must show one list fewer, never a new one. Switch back to your usual list.

Failure is any of these:

- a confirmation that names nobody on a shared list;
- a rename that survives Escape, or a shared list the other character loses after a rename;
- an empty list drawn as a bare grid;
- a delete that leaves a new numbered list such as "Druid (3)" behind.

**Connoisseur Staples**

**7.** Pick **New List** again and click **Pick Staples**:

- The **Connoisseur Staples** window must open in front, with the Restock List window still open behind it.
- Its text must open with "Your Restock List is empty, so let's add some items to get you started."
- The window must be solid, with nothing of the list behind showing through it.
- Every staple must carry its item's icon between its checkbox and its name. The space between the icon and the name must stay while you hold the mouse down on the row.
- The checkboxes and dropdowns must line up in two columns from **Food & Water** down to **Reagents & Tools**, with Water in the same block as the foods.
- The window must end just under its last row. A scroll bar may appear only for a character offered more than it can hold, such as a level-60 Rogue on Classic Era.

Tick a staple: its row must appear on the list behind, under **New**. Untick it: the row must go. Hover a staple: its tooltip must name the item without square brackets.

Close the staples window with its close button. Delete this list, and on your usual list click **Pick Staples** again: the text must open with "Pick the staples you want kept stocked."

Failure is any of these:

- the Restock List window closing when the staples open;
- a staples window the list shows through;
- a staple with no icon, or with its name against the icon;
- columns that shift between sections;
- a scroll bar or empty space the window does not need.

**Bank and merchant runs**

**8.** Keep amounts are fixed when a bank run starts:

1. Put ten single units of a Take item in the bank, one per slot, with a Keep of 10 and none in your bags. Add a Store row with a Keep of 20 and exactly 20 in your bags.
2. Tick **Open at Bank** and open the bank.
3. While the moves run, clear the Store row's Keep box without pressing Enter: none of that item may go to the bank.
4. Press Enter on the empty box: the run must start again and store the whole stack, since a Keep of 0 banks everything. Set it back to 20.

A full bank must take before it stores:

1. Fill every bank slot, every tab on WoW Forever. One slot must hold a stack of 5 of a Take item with a Keep of 10 and none in your bags, and a Store item must sit 5 over its Keep in your bags with none in the bank.
2. Open the bank. The 5 must come out, the surplus must go into the slot they freed, and chat must end with "Connoisseur // Restocking complete. Hold Shift while opening the bank to skip restocking. Type /crs to edit your Restock List."

Watch the Take row's Keep while it fills: with the window open, it must turn white as the item arrives.

Failure is any of these:

- an item stored before you pressed Enter;
- "Connoisseur // Restocking stopped. Your bank is full; free a slot and reopen it." with the Take stack still in the bank;
- a Keep number that stays yellow after the item arrives.

**9.** *Rogue.* A reagent that has a row of its own must not be under-bought:

1. Set the poison row 5 short with **Buy** on.
2. Put one of the poison's reagents on the list as its own row with **Buy** on and a Keep of 10, and carry 5.
3. Open the vendor stocking every reagent.

The reagent must end at exactly 15, enough for the poisons and its own Keep of 10.

Slots gold alone can't buy must be skipped:

1. Put on the list, with **Buy** on and **Rep** left as a dash, the item you lack the reputation to buy. On TBC Anniversary, add one sold for badges or honor as well.
2. Open that vendor.

Nothing of either may be bought, no red reputation error may appear, and your badges and honor must be unchanged.

Failure is any of these:

- the reagent bought only up to its own Keep, at 10;
- a red error;
- badges or honor spent.

**The Inventory Report**

**10.** *The two characters from step 1.* Log the second character in, open its bank once and log out, so both its bags and its bank are recorded. On the first, wait a few seconds after login, then hover the item both hold. Below the item's own lines, the tooltip must carry a **Connoisseur & Restocker // Inventory Report** block, each line one space in from the block's header:

- **Bags**, as have/keep, such as 7/10, when the item is on your Restock List with a Keep above 0;
- **Bank**, a grey **Unknown** until this character has opened its bank once, and the bank's count after;
- a line for the other character in its class color, with what it carries and has banked;
- **Total**.

On WoW Forever, the other character's line must read its first name and surname, once. Check the other character's count against what it carries: on WoW Forever a build once saved every logged-out character's bags as empty.

Open the bank, move some of the item in, close it and hover again: **Bank** must show the new count. Link the item in chat and click the link: the window that opens must carry the block once. Hover an item nobody holds that is on no list: no block. Hover a recipe one of you holds: the block must appear once, not twice.

On the **Restocker** options page, read down from **Restock List Window**. You must see:

- "Choose when your Restock List opens on its own.";
- **Open at Bank** and **Open at Merchant**, whose tooltips read "Opens your Restock List when you visit the bank." and "Opens your Restock List when you visit a merchant.";
- the **Inventory Report** header, and under it **Enable Inventory Report in Item Tooltips**.

Untick it: the block must leave every tooltip, and return when you tick it again. **WoW Forever is the flavor to watch**, since its tooltips are built differently.

Failure is any of these:

- a missing block, or two blocks on one tooltip;
- another character's line missing, or short of what it holds;
- a Bank of 0 before the bank was ever opened;
- a character from another realm listed;
- "Restocker Window" or "Enable List Builder" anywhere on the page;
- the block staying with the option off.

**The mini-map tooltip**

**11.** Hover the mini-map button and read its tooltip top to bottom:

1. **Current Food**, with the item on the row beneath it, as its icon and its name;
2. **Buff Food**;
3. **Scroll Buffs**;
4. **Restocker List**, with "Buys and banks the items on your list." and Shift + Right-Click beside **Open**;
5. the class notes, on classes that have them;
6. the **Restocker Report**;
7. the Ignore List, when it holds items;
8. **Connoisseur Options**, last.

No item anywhere in this tooltip may wear square brackets.

*On the Hunter, Rogue, Mage and Warlock*, the class notes must sit between the Restocker List and the Restocker Report:

- The Hunter's must open with **Current Pet Food**.
- The Rogue's must open with **Main Hand Poison** and **Off-Hand Poison**, each item on the row beneath its title.
- Each macro's clicks must follow as silver rows under the macro's name, with a row only for a spell that character knows.

Now work through the clicks against the tooltip:

- Left-Click flips Buff Food, and Shift + Left-Click flips Scroll Buffs.
- Right-Click ignores your current food, and the Current Food item switches to the next best.
- Shift + Right-Click opens and closes the Restock List window the way `/crs` does, and ignores nothing.
- Middle-Click clears this character's Ignore List instantly, with no confirmation. That is deliberate.
- Shift + Middle-Click opens the options.

After each toggle, the state must flip while you are still hovering, and must agree with the Macros page.

While ungrouped, set the dropdown beside **Prioritize Buff Food** to **When in a Raid**: the tooltip must read "When in a Raid" in grey where it said Enabled. On a character whose Restock List is empty, the Restocker Report must read "Your list is empty.", never the congratulation. Ignore nine items: the tooltip must show eight at most, or their count in place of the list.

Untick **Enable Mini-map Button** on the root Connoisseur page: the button must vanish at once. Ticking it must bring it straight back, with no `/reload`.

Failure is any of these:

- a block out of order, or a note for a spell the character has not learned;
- Shift + Right-Click ignoring a food;
- any click doing something its tooltip doesn't say;
- the tooltip and the Macros page disagreeing;
- a button that needs a reload to hide or return.

**Macros**

**12.** Open **Options > Connoisseur > Macros**. The **Enable Macros** checkboxes must read Bandage, Explosives, Food and so on, with no leading "- ". Each must carry its macro's default icon, such as a bandage, dynamite or a muffin, between its box and its name, with a clear space before the name. On TBC Anniversary, the **Pet Food Buffs** checkboxes must carry their items' icons too.

Under **Potions & Healthstones**, **Use Food & Water in Potion Macros Out of Combat** must sit above **Combine Healthstones into Health Potion Macro** and be off on a fresh profile. With a healing potion, a mana potion, food and water in your bags, tick it:

- Out of combat, `- Health Potion` must show the food's icon and eat it when pressed, and `- Mana Potion` must show the water's icon and drink it.
- Pull a mob: both icons must switch to the potions, and a press must drink the potion.
- Bank the potions: out of combat `- Health Potion` must still eat, and in combat it must print "Connoisseur // No suitable Health Potion found in your bags."
- Tick **Combine Healthstones into Health Potion Macro** with a Healthstone in your bags: it must eat out of combat and use the stone in combat.
- *On a Rogue*, tick **Enable Stealth Eating**: out of combat, `- Health Potion` must eat and stealth on one press, and in combat a press must drink the potion without stealthing. *On a Night Elf* that isn't a Rogue, do the same with **Enable Stealth Eating** (Shadowmeld on `- Health Potion`) and then **Enable Stealth Drinking** (Shadowmeld on `- Mana Potion`). Untick each again: its potion macro must lose its `/cast` line.
- Untick the new option: both bodies must lose their `[nocombat]` lines.

Failure is any of these:

- a "- " left on a checkbox, or a checkbox with no icon;
- a potion drunk out of combat while food is in your bags;
- food's icon showing in combat;
- a scroll, pet food or conjure line appearing in either potion macro.

**Data and diagnostics**

**13.** Open **Options > Connoisseur > Diagnostic Tools**, tick **Enable Diagnostic Tools** and press **Test WoW API Endpoints**. `C_Secrets.ShouldCooldownsBeSecret`, `C_Container.GetItemCooldown` and `UnitNameUnmodified` must each read `[PASS]` on every flavor, and `RegionalUniqueNamesEnabled` must read `[PASS]` on WoW Forever. A `[FAIL]` for that last one is expected on the other flavors.

Press **Validate Data** in each of the 19 **Validate Data** sections and let each run until the "Validated N / M IDs" progress line gives way to the report. No row may begin `NOT ON CLIENT`, `TABLE MISSING` or `ERROR`. A row that stays `INCOMPLETE` when you run its section again is fine if its **Description** or **Item Spell Description** cell is empty, and a problem if that cell has text. On WoW Forever, every `OK` row with an **Item Spell ID** must also have its **Item Spell Description** filled in. Hand the WoW Forever reports back, since many of its amounts are still waiting on them.

*On WoW Forever,* tick **Enable Scroll Buffs** with Intellect ticked, and have no Intellect buff on you. As a Mage carrying a Scroll of Rat Familiar, `- Food` must read the scroll first. As a non-Mage carrying the same scroll, `- Food` must never offer it.

Failure is any of these:

- a `[FAIL]` on the first three API rows;
- a flagged row, or a WoW Forever `OK` row with an empty spell description;
- the familiar scroll offered to a non-Mage, or passed over by a Mage.

**The Readiness Report**

**14.** On the **Readiness Report** page, tick **Enable Readiness Report on Ready Check**, then **Soulstone Inactive** and **PvP Flag On**.

*Warlock, grouped with your second player:*

1. Use a Soulstone on the second player, and have them Right-Click the buff away.
2. With **Enable Diagnostic Tools** ticked, press **Show Readiness Report**. "Soulstone Inactive" must not appear under "Missing Buffs :" while the stone is on cooldown.
3. Type `/pvp` and start a ready check. The report must show "PvP Flagged!" in the same white as the rest of its line.

**Classic Era and TBC Anniversary are the flavors to watch here**, since the cooldown check is new to them.

Failure is any of these:

- "Soulstone Inactive" listed while the stone is on cooldown;
- a Lua error at the report or the ready check;
- "PvP Flagged!" in red.

When steps 1-14 pass on every flavor, this release's changes are verified. Proceed to `4 - Pre-Launch Review Prompt.md`.

## Core checks

**15.** Log in with Connoisseur enabled.

- At character select, the **AddOns** list must show **Connoisseur & Restocker**, enabled, not marked out of date, and with its icon beside the name.
- No Lua error window and no red text may appear.
- A colored welcome line must print in the shape "Connoisseur // Version ...".
- Under **Diagnostic Tools**, tick **Enable Diagnostic Tools** and press **Show Connoisseur Context**. The report's first line must end in `Flavor Vanilla // Data Vanilla` on Classic Era, `Flavor Vanilla // Data Discovery` on a Season of Discovery realm, `Flavor Camelot // Data Camelot` on WoW Forever, and `Flavor TBC // Data TBC` on TBC Anniversary.
- Type `/reload`: the UI must come back clean, and the welcome line must print again.

Failure is any of these:

- any error naming Connoisseur;
- no welcome line;
- the wrong folder on any flavor. Season of Discovery is the one to watch, since it shares Classic Era's client.

**16.** Open the options from **every** entry point:

- type `/foodie`;
- Shift + Middle-Click the mini-map button;
- type `/crs config`;
- pick Connoisseur from the Blizzard Options > AddOns category list.

Each must open the settings **docked inside the Blizzard Options window**, with Connoisseur selected in the category list on the left. Macros, Ignore List, Restocker, Readiness Report, Profiles and Diagnostic Tools must show beneath it.

Failure looks like either nothing happening at all, or a standalone window floating free of the Options frame. **TBC Anniversary is the flavor that historically breaks this**, so a tester who runs only Era has not finished.

**17.** *Mage, grouped with your second player, with the Readiness Report's **Healing Potion** ticked and no healing potion in your bags, and **Prioritize Buff Food** on with Well Fed up.* Pull a mob.

While in combat:

1. Try `/foodie`, `/crs config` and Shift + Middle-Click. Each must print "Connoisseur // As a safety precaution, the Options Interface cannot be opened during combat.", and the panel must **not** open.
2. Type `/crs` on its own: it must still open the Restock List window, because only the Options route is gated.
3. Press a Connoisseur macro: it must use its item with no error.
4. Tab to yourself, to your second player and back, and cast a few spells. End on your second player as your target.
5. Right-Click the mini-map button twice, and start a ready check.

No Lua error may appear on any flavor.

The ready check is where the flavors differ. Classic Era, Season of Discovery and TBC Anniversary must print the report mid-fight, "Missing Items : Healing Potion" included. **WoW Forever is the flavor that breaks here**: its engine can hide buffs, cooldowns and casts during combat. Its report may stay silent mid-fight and speak at the next ready check instead, but it must never error.

Leave combat. After the fight:

- The options panel must **not** open by itself.
- Within a second or two, the `/cast` line of `- Water` (type `/macro` to read it) must show the rank for your second player's level.
- The food you Right-Clicked must be on this character's Ignore List, not taken back off by the second click.
- `- Food` must offer your next-best plain food, not your buff food, while Well Fed lasts.

Middle-Click the mini-map button afterwards to clear the list.

Failure is any of these:

- the panel opening, silence instead of the message, or a red `ADDON_ACTION_BLOCKED` error;
- any Lua error;
- a silent report mid-fight on Classic Era, Season of Discovery or TBC Anniversary;
- a macro left stale after the fight.

**18.** Type `/crs`: the Restock List window must toggle open and closed. Then:

- `/crs show` must open it without toggling.
- `/crs help` must print the show line, "/crs show  Opens your Restock List.", then the config line and the five profile commands. Each must carry a description and no raw keys, and the profile lines must show `[name]` where the list name goes.
- `/crs profile` with nothing after it must print the five profile lines rather than erroring.
- With the window open, `/crs profile use NoSuchList` must change nothing: the **List** selector keeps your list and every row stays. It prints nothing, by design.

Failure is a Lua error, a command other than that last one silently doing nothing, or a blank List selector.

**19.** Loot, buy or trade yourself a food better than your current pick. Within about a second the `- Food` macro, in the **General** macro tab, must rewrite to the new item, and the mini-map tooltip's Current Food row must agree.

Type `/macro` to open the game's macro window. With it still open, eat or destroy the last of your current best food: `- Food` must **not** change while the window is open, and must rewrite to your next best food within a second of closing it.

Empty every food out of your bags and press `- Food`: chat must print "Connoisseur // No suitable Food found in your bags." Each macro prints the same shape, with its own category name, when its category is empty.

Failure is any of these:

- a macro that only updates after a `/reload`;
- a macro still stale after the macro window closes;
- macros landing in the character-specific tab;
- silence on an empty category, or the wrong category label.

**20.** *Mage.* Right-Click `- Water`: it must conjure your highest rank of Conjure Water. The `/cast` line in its body must pin that rank the way your spellbook writes it, as in `Conjure Water(Rank 7)`.

Then Middle-Click `- Water`:

- On Classic Era, Season of Discovery and WoW Forever, which have no Ritual of Refreshment, it must drink just as a Left-Click does.
- On TBC Anniversary, a Mage below level 70 must get "Connoisseur // You don't currently know Ritual of Refreshment."

*Hunter.* Work through `- Feed Pet`:

1. Ctrl + Left-Click: your pet must be dismissed.
2. Left-Click: it must call the pet back, never cast Revive Pet.
3. Left-Click again: the pet must eat food from your bags.
4. Right-Click: Mend Pet.
5. Let your pet die and Left-Click: Revive Pet. Once it stands, the next Left-Click must feed it rather than revive it again.

**On WoW Forever**, let your pet die, dismiss it, pull a mob and Left-Click `- Feed Pet`: no Lua error may appear.

Failure is any of these:

- nothing conjured, the wrong rank, or a `/cast` line with no rank;
- Revive Pet cast on a pet that was only dismissed;
- a click that does nothing, or a macro stuck on Revive.

**21.** *Warlock.* Read the `/cast` lines in the `- Healthstone` and `- Soulstone` macro bodies, then Right-Click each macro:

- **On Classic Era and Season of Discovery, both spells must be bare full names**, such as `Create Healthstone (Minor)`, with no `(Rank N)`.
- **On TBC Anniversary, both must be rank-pinned**, as in `Create Healthstone(Rank 3)`.
- **On WoW Forever, Create Healthstone must be rank-pinned while Create Soulstone stays bare.**

A wrong name makes the Right-Click **silently do nothing**, and Classic Era is where that has broken before. Test the click itself on every flavor rather than only reading the body. Right-Click `- Healthstone` again with the new stone in your bags: it must create a lower-rank backup.

Failure is a `(Rank N)` where the flavor casts bare, a missing rank where it pins one, or a Right-Click that creates nothing.

**22.** Merchant runs:

- With **more** of a Restock List item than its Keep, open a vendor: **nothing may ever be sold**, so check bags and money before and after.
- With **less** than its Keep and **Buy** on, open a vendor who stocks it: Connoisseur must buy up to the Keep and never past it.
- Hold Shift while opening the vendor: restocking must be skipped entirely.
- Leave exactly one free slot in your bags, with a row more than a stack short of an item that vendor sells. The run must fill the slot and stop, and chat must end with "Connoisseur // Your bags filled up before everything was bought."
- On the **Restocker** page, **Enable Staples Pop-Up When Restock List Is Empty** and then **Enable Gold Reserve** must sit right under the page's description, above a new **Reminders** header that holds the three reminders. **Enable Gold Reserve** must be ticked, with **1** and the gold coin in its dropdown. Its dropdown must offer 1, 2, 3, 5, 8, 13, 21, 34 and 55 gold, and must hide while the box is unticked.
- Set the reserve above the gold you carry and open a vendor who stocks a short row: nothing may be bought, and chat must print "Connoisseur // Restocking paused; not enough gold. It will resume once it can complete your purchase orders without dipping into your reserve (1).", with the gold coin after the amount you set. Bank restocking must still run.
- Set the reserve a little under your gold, so it covers only part of a short row: the run must stop with your gold still at or above the reserve, and chat must print the same line.
- Untick **Enable Gold Reserve**, spend down until you can't afford a short row, and open a vendor who stocks it: chat must print only "Connoisseur // Not enough gold to finish restocking.", with no reserve sentence. Then open a vendor who stocks nothing on your list: no gold line may print.

*On the Rogue*, with no reagent on the list as a row of its own and the missing reagent absent from your bags:

- Open the vendor stocking **every** reagent your listed poison needs: each one buys.
- Open the vendor stocking **only some**: nothing may be bought, and chat must print "Connoisseur // This merchant doesn't stock every ingredient your poisons need. Skipping them all."
- Untick **Buy** on the poison's row and open the full vendor again: none of its reagents may be bought. Tick **Buy** again afterwards.

Failure is any of these:

- any item leaving your bags at a merchant;
- over-buying, or Shift being ignored;
- a red "Inventory is full" error;
- half a recipe filling your bags;
- reagents bought for a row with Buy off.

**23.** Bank runs:

1. Put a **Take** item only inside a bank bag, not the bank's main slots (on WoW Forever, inside a bank tab, since its bank has no bags), with your bags short of it.
2. Put a Restock List item into the bank as three small stacks, such as 5, 4 and 2 of one that stacks to 20, with your bags already holding its Keep.
3. Carry more of a **Store** item than its Keep.

Hold Shift while opening the bank: nothing may move. Close it and open it again without Shift:

- The Take item must come out of the bank bag or tab.
- The Store surplus must go into the bank.
- The three small stacks must merge into as few as they fit, one stack of 11 in the example.
- Chat must print "Connoisseur // Restocking complete. Hold Shift while opening the bank to skip restocking. Type /crs to edit your Restock List."

Pick **New List** from the **List** selector and open the bank again. Nothing may move, no "Restocking complete..." line may print, and the Restock List window must not open by itself, even with **Open at Bank** ticked. Switch back to your usual list and delete the empty one. **WoW Forever is the flavor to watch**, since its bank is built differently.

Failure is any of these:

- anything moving on the Shift visit;
- nothing leaving the bank bag or tab, or small stacks left as they were;
- a restock with no closing line;
- a restock message from an empty list.

**24.** On the **Restocker** page, set the dropdown beside **Enable At-Merchant Restock Reminders** to **Verbose**. Then close a merchant window with a row still short and **Buy** on.

Chat must print "Connoisseur // 1 restocking order outstanding." or "Connoisseur // N restocking orders outstanding.", followed by one line per short item in the shape "Connoisseur // 3/20 [item]". Each line must be complete, with a working, clickable item link, no `nil`, no stray `%s` or `%d`, and no half-rendered link.

Then cross a loading screen without visiting a merchant or the bank: that headline must not print as the world loads. Arriving at an inn or a city may print only the in-town reminder, "Don't forget to restock while you're in town!", with its own per-item lines under it.

Failure is any of these:

- per-item lines missing in Verbose;
- a broken link;
- the outstanding-orders headline turning up on arrival from a boat.

**25.** Open **Diagnostic Tools** on a fresh login: **Enable Diagnostic Tools** must be **off**, and off again after a `/reload`, since it lasts one session only.

Tick it and click **Start Event Log**. Spam a red combat error by pressing an ability that isn't ready over and over, then click **Show Captured Events**. The spam must **not** appear as individual timestamped lines. Read the `-- Suppressed (uncorrelated) traffic --` block at the end: the spam must fold into one counted row there, such as `x12`.

Failure is diagnostics surviving a reload, or spam flooding the log line by line.

**26.** *Optional, non-English client.* Read these in that language:

- the options pages;
- the mini-map tooltip;
- the Restock List window;
- the **Connoisseur Staples** window;
- an item tooltip's Inventory Report.

Every label and tooltip must render in that language, with no raw key like `OPTIONS_FOOD_WATER_HEADER` on screen.

This release's copy needs the closest look:

- **Macros page:** **Use Food & Water in Potion Macros Out of Combat**.
- **Restocker page:** **Enable Gold Reserve** and its two tooltips, the **Reminders** header, **Restock List Window** and its line, **Enable Staples Pop-Up When Restock List Is Empty**, and the **Inventory Report** section.
- **Chat:** both gold lines from step 22, with the gold coin after the reserve.
- **Restock List window:** its title, the "Used by" line, **Manage Lists** and its menu, **Add Item from Bags**, the **Keep** heading and tooltip (which must call the number yellow, not red), the heading menus' "Turn On for N Shown", the removal line with **Undo**, the dimmed-cell tooltips, the line under the list with its "and N more", the empty list, the filter's nothing-found lines, and the delete confirmation.
- **Staples window:** its title and text.
- **Mini-map tooltip:** the Restocker List block, the item titles, and each class's notes from step 11.

The Rogue's poison dropdowns, the pet food checkboxes on TBC Anniversary, and the staples window's poison and reagent rows take their names from the game, so each must read exactly as that item does in your bags.

Layout:

- The **Buffs Expiring Within** choice of two and a half minutes must use that language's decimal mark, such as "2,5" in German.
- No checkbox label beside a dropdown may be cut short, and no dropdown choice may overflow its box.
- No Restock List column heading may grow so wide that it crushes the item name beside it, and neither add-box notice from step 5 may overflow the box.

Trigger a few chat lines: the welcome line, a "No suitable ... found" line, the bags-full line and the poison-reagent skip line from step 22, and a Readiness Report line. Each must read as one complete sentence, with no `nil` and no stray `%s` or `%d`. A Readiness Report line must separate its items with that language's own punctuation.

These stay **English on every client**, and that is deliberate, not a missed translation:

- the slash commands `/foodie` and `/crs`, and the /Commands heading;
- the name Restocker;
- the four URLs, and the names Discord, GitHub, CurseForge and Wago;
- the whole Diagnostic Tools page.

When every step passes on each of Classic Era, Season of Discovery, WoW Forever and TBC Anniversary, manual testing is complete. Proceed to `4 - Pre-Launch Review Prompt.md`.
