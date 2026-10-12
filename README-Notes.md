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
- **Instead:** Every `ns` function is dot-defined, and nothing on the namespace takes `self`.
- **Why:** Nothing on the namespace uses `self`.

### Feature subfolders

- **Departs from:** FILE STRUCTURE, `Features/{Feature-Name}.lua`.
- **Instead:** Large features live in `Features/` subfolders, whose files carry the feature name in the basename (`Features/Restocker/Restocker-Window.lua`); `Features/Macros/` keeps its own file names.
- **Why:** The maintainer's choice.
