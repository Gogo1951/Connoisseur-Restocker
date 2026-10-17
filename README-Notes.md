# Connoisseur // Notes

> Where Connoisseur departs from the Gogo1951 add-on Style Guide, kept so no review raises it again.

## Exceptions

### Profiles panel without suggested profiles (remove after 2026-10-30)

- **Departs from:** OPTIONS PANEL → Profiles Panel, "returns the stock AceDBOptions-3.0 table unmodified".
- **Instead:** The Profiles panel is built with AceDBOptions' `noDefaultProfiles` flag, so its pickers list only profiles that exist, never the suggested Default, realm and class profiles.
- **Why:** While the migration that moves characters off the shared Default profile runs, a character put on Default is moved off it again at its next login.

### Game names in a few locale strings

- **Departs from:** GAME NAMES, "Locale files hold only our own words."
- **Instead:** `TIP_PET_NO_MEND` names Mend Pet in its own string, and where one language's clients name the same spell, item or label differently, the locale uses the Classic Era and WoW Forever name.
- **Why:** Looking Mend Pet up by ID would put its spell ID in every data folder, and one string per language must serve all three clients.

### Era reports prune Discovery

- **Departs from:** `04 - Data Review.md`, "a Vanilla report never touches `Data/Discovery/`".
- **Instead:** A row a Classic Era Validate Data report flags NOT ON CLIENT leaves `Data/Discovery/` too; Discovery's other values wait for a Season of Discovery export.
- **Why:** Season of Discovery runs on the Classic Era client, so an ID that client lacks is missing there as well.

### Dot-defined namespace functions

- **Departs from:** the guide's snippets, which define `ns` functions with colons.
- **Instead:** Every `ns` function outside `Diagnostics/` is dot-defined and takes no `self`, while `Diagnostics/` keeps Magic Eraser's colon methods.
- **Why:** Nothing outside the diagnostics framework uses `self`, and the framework stays identical to the Magic Eraser folder it is copied from.

### Every class and race section shows to everyone

- **Departs from:** OPTIONS PANEL → Widget Conventions, "Only show spells the player knows".
- **Instead:** The Class & Race panel shows its Druid, Rogue, Night Elf and Forsaken sections, and the Macros panel its Feed Pet and Poisons macro toggles, to every character, and gates only on what a client can't do.
- **Why:** The maintainer wants every option visible from any character.

### Feature subfolders

- **Departs from:** FILE STRUCTURE, `Features/{Feature-Name}.lua`.
- **Instead:** Large features live in `Features/` subfolders, whose files carry the feature name in the basename (`Features/Restocker/Restocker-Window.lua`); `Features/Macros/` keeps its own file names.
- **Why:** The maintainer's choice.

### Title names the Restocker

- **Departs from:** `09 - Optional Create README.md` → Title, "H1, the add-on's Short Name".
- **Instead:** The README's H1 is "Connoisseur & Restocker", the name the Inventory Report's tooltip header carries too.
- **Why:** The maintainer wants the title to say that Restocker lives on inside Connoisseur.

### Staples pop-up answer kept account-wide

- **Departs from:** SAVED VARIABLES → The Two Models, "per-character state in `ns.db.profile`".
- **Instead:** Whether a character answered the staples pop-up is saved in `ns.db.global`, keyed by character.
- **Why:** Switching, copying or resetting a profile must never bring back, or suppress, a pop-up the character already answered.

## Decisions

- Star's Tears and Star's Lament are offered only inside an arena (arena column 1), though the client lets them be used anywhere: they are expensive, and ordinary food and water serve better outside one.
- The four Ogre Brews keep Gruul's Lair (330) among their allowed zones: they work there, though their tooltip names only the Blade's Edge Plateaus.
- Harvest Bread and Winter Veil Loaf carry no arena value though their tooltips say Conjured Item: the TBC client doesn't flag them usable in arenas, so they are never offered there.
