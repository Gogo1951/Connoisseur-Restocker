# Connoisseur & Restocker // Notes

> Where Connoisseur & Restocker departs from the Gogo1951 add-on Style Guide, kept so no review raises it again.

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

### Title carries both names

- **Departs from:** `09 - Optional Create README.md` → Title, "H1, the add-on's Short Name".
- **Instead:** The README's H1 is "Connoisseur & Restocker (C & R)": the Full Name, then the Short Name in brackets.
- **Why:** The maintainer's naming rule: every add-on has a Full Name for window titles and for talking about the add-on, and a Short Name for tooltips, chat prints and messages to other players, and the README's H1 joins the two.

### Staples pop-up answer kept account-wide

- **Departs from:** SAVED VARIABLES → The Two Models, "per-character state in `ns.db.profile`".
- **Instead:** Whether a character answered the staples pop-up is saved in `ns.db.global`, keyed by character.
- **Why:** Switching, copying or resetting a profile must never bring back, or suppress, a pop-up the character already answered.
