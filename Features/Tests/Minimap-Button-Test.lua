-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the mini-map button: its tooltip and its clicks (no WoW
    client needed).

    Run it with:   lua Features/Tests/Minimap-Button-Test.lua        (from the add-on root)

    Like the other headless tests, this does NOT model the feature: every
    scenario loads the REAL Features/Minimap-Button.lua behind the thinnest
    stubs that hold it up. The copy comes from the REAL Locales/enUS.lua through
    a strict table, so a key the tooltip reads that enUS does not define fails
    the suite instead of printing itself.

    WHAT IS PINNED HERE.

    The tooltip's blocks, in the order the maintainer settled: Current Food,
    Buff Food, Scroll Buffs, the Restocker List, the class notes, the Restocker
    Report, the Ignore List, then Options.

    Their shapes. An item is right-aligned on the row under its title, and the
    "no suitable item" sentence takes that row when there is none. The Restocker
    List is a block of its own with a description and an Open label. A class's
    own items (a Hunter's pet food, a Rogue's two poisons) lead its notes, then
    one group per macro: the macro's name, a row per click, a closing line.

    What is gated. A row shows only for a spell the character knows, a group
    with no rows is not drawn, and a character with no groups gets no header.

    The limits and the honest states. The Restocker Report and the Ignore List
    list eight items and show a count past that; an empty Restock List is not a
    stocked one; a switch whose when-to-use choice does not hold shows that
    choice in place of Enabled.

    The colors that carry meaning: blue for a click on the mini-map button,
    silver for a click on a macro.

    And the six clicks, each doing what its hint says.
]]

local ROOT = arg[1] or "."

local failures = 0

local function check(label, got, want)
	if got == want then
		print("  ok    " .. label)
	else
		failures = failures + 1
		print(("  FAIL  %s: got %s, want %s"):format(label, tostring(got), tostring(want)))
	end
end

-- Text as the player reads it: color tags, color codes, icon escapes and link wrappers stripped.
local function plain(text)
	return (
		text:gsub("|T.-|t ", "")
			:gsub("<%u+>", "")
			:gsub("|c%x%x%x%x%x%x%x%x", "")
			:gsub("|r", "")
			:gsub("|H.-|h", "")
			:gsub("|h", "")
	)
end

-- An item's link as the client hands one over: a color, the link, and the name in square brackets.
local function link(itemID, name)
	return "|cffffffff|Hitem:" .. itemID .. "|h[" .. name .. "]|h|r"
end

-- One tooltip line: "left | right" for a pair, "(right) item" for a row with nothing on the left.
local function plainLine(line)
	if not line then
		return nil
	end
	if not line.right then
		return plain(line.left)
	end
	if line.left == " " then
		return "(right) " .. plain(line.right)
	end
	return plain(line.left) .. " | " .. plain(line.right)
end

-- Compare a run of tooltip lines, starting at `from`, against the lines wanted; the first difference is reported.
local function checkLines(label, lines, from, want)
	for offset, wanted in ipairs(want) do
		local got = plainLine(lines[from + offset - 1])
		if got ~= wanted then
			failures = failures + 1
			print(
				("  FAIL  %s: line %d is %s, want %s"):format(label, from + offset - 1, tostring(got), tostring(wanted))
			)
			return
		end
	end
	print("  ok    " .. label)
end

-- The index of the first line reading `text`, or nil.
local function find(lines, text)
	for index, line in ipairs(lines) do
		if plainLine(line) == text then
			return index
		end
	end
	return nil
end

--------------------------------------------------------------------------------
-- Stubs
--------------------------------------------------------------------------------

-- The shipped English, loaded from the real locale file.
local STRINGS = {}
LibStub = function()
	return {
		NewLocale = function()
			return STRINGS
		end,
	}
end
assert(loadfile(ROOT .. "/Locales/enUS.lua"))()

local L = setmetatable({}, {
	__index = function(_, key)
		local value = STRINGS[key]
		if value == nil then
			error("Locales/enUS.lua defines no " .. tostring(key), 2)
		end
		return value
	end,
})

local SKYWALL_SOUFFLE = 1001
local ROASTED_QUAIL = 2001
local INSTANT_POISON = 3001
local DEADLY_POISON = 3002
local FRESHLY_BAKED_BREAD = 4001

local POISONS = 2842
local CONJURE_FOOD, CONJURE_WATER, RITUAL_OF_REFRESHMENT, CONJURE_MANA_GEM = 587, 5504, 43987, 759
local CREATE_HEALTHSTONE, CREATE_SOULSTONE, RITUAL_OF_SOULS = 6201, 693, 29893

local SPELL_NAMES = {
	[RITUAL_OF_REFRESHMENT] = "Ritual of Refreshment",
	[RITUAL_OF_SOULS] = "Ritual of Souls",
}

local function conjureSpells()
	return {
		MageCreateTable = { { RITUAL_OF_REFRESHMENT, 70 } },
		MageCreateWater = { { CONJURE_WATER, 1, 1 } },
		MageCreateFood = { { CONJURE_FOOD, 1, 1 } },
		MageCreateManaGem = { { CONJURE_MANA_GEM, 28 } },
		WarlockCreateHealthstone = { { CREATE_HEALTHSTONE, 1, 1 } },
		WarlockCreateSoulstone = { { CREATE_SOULSTONE, 18 } },
		WarlockCreateSoulwell = { { RITUAL_OF_SOULS, 68 } },
	}
end

local function NewTooltip()
	local tooltip = { lines = {}, shown = false }
	function tooltip:SetOwner(owner, anchor)
		self.owner, self.anchor = owner, anchor
	end
	function tooltip:GetOwner()
		return self.owner
	end
	function tooltip:ClearLines()
		self.lines = {}
	end
	function tooltip:AddLine(text, _, _, _, wrap)
		self.lines[#self.lines + 1] = { left = text, wrap = wrap or false }
	end
	function tooltip:AddDoubleLine(left, right)
		self.lines[#self.lines + 1] = { left = left, right = right }
	end
	function tooltip:Show()
		self.shown = true
	end
	function tooltip:Hide()
		self.shown = false
		self.owner = nil
	end
	return tooltip
end

--[[
    One logged-in character, hovering nothing yet. opts: class, knows (spell
    IDs), food (false for empty bags), petSpells (false before Feed Pet is
    learned; mend = false before Mend Pet), petFood (false for none), poisons
    ({ main, off }, false for an empty hand), groceries (the Restocker's
    shortfall rows), restockEmpty, ignoreList ({ [itemID] = true }), itemNames
    (what the client has cached, by item ID), profile (overrides), raid (the
    character is in one), conjureSpells (the flavor's lists), noDatabase.
]]
local function session(opts)
	opts = opts or {}
	local calls = {}
	local shift = false
	local itemInfoReads = 0
	local button = {
		icon = {
			SetTexture = function(self, texture)
				self.texture = texture
			end,
		},
	}

	format = string.format
	tinsert = table.insert
	GameTooltip = NewTooltip()
	IsShiftKeyDown = function()
		return shift
	end
	UnitClass = function()
		return "Class", opts.class or "WARRIOR"
	end
	C_Item = {
		GetItemIconByID = function(itemID)
			return "icon" .. itemID
		end,
		GetItemInfo = function(itemID)
			itemInfoReads = itemInfoReads + 1
			local name = opts.itemNames and opts.itemNames[itemID]
			if name then
				return name, nil, 1, nil, nil, nil, nil, nil, nil, "icon" .. itemID
			end
		end,
		GetItemQualityColor = function()
			return 1, 1, 1, "ffffffff"
		end,
	}
	C_Spell = {
		GetSpellName = function(spellID)
			return SPELL_NAMES[spellID]
		end,
	}

	local dataObject
	LibStub = function(name)
		if name == "LibDataBroker-1.1" then
			return {
				NewDataObject = function(_, _, object)
					dataObject = object
					return object
				end,
			}
		end
		assert(name == "LibDBIcon-1.0", "unexpected library " .. tostring(name))
		return {
			Register = function(_, objectName)
				calls[#calls + 1] = "Register " .. objectName
			end,
			GetMinimapButton = function()
				return button
			end,
			Refresh = function()
				calls[#calls + 1] = "Refresh"
			end,
		}
	end

	local known = {}
	for _, spellID in ipairs(opts.knows or {}) do
		known[spellID] = true
	end

	local profile = { useBuffFood = true, buffFoodMode = "always", useScrolls = true, scrollsMode = "always" }
	for key, value in pairs(opts.profile or {}) do
		profile[key] = value
	end

	local ns = {
		L = L,
		LOCALE_NAME = "Connoisseur",
		Version = "Dev",
		GetColor = function(key)
			return "<" .. key .. ">"
		end,
		-- Utilities' class color accessor, over the four classes with notes.
		GetClassColor = function(classToken)
			local hex = ({ HUNTER = "AAD372", MAGE = "3FC7EB", ROGUE = "FFF468", WARLOCK = "8788EE" })[classToken]
			return hex and ("|cff" .. hex) or nil
		end,
		KnowsAny = function(spellList)
			for _, data in ipairs(spellList) do
				if known[data[1]] then
					return true
				end
			end
			return false
		end,
		IsSpellKnown = function(spellID)
			return known[spellID] or false
		end,
		IsPlayerSpell = function()
			return false
		end,
		-- The real predicate's group half: Always holds, When in a Raid holds in one.
		IsModeActive = function(mode)
			return mode == "always" or (mode == "raid" and opts.raid == true)
		end,
		MODE_VALUES = { always = L["MODE_ALWAYS"], raid = L["MODE_RAID"] },
		CONJURE_SPELLS = opts.conjureSpells or conjureSpells(),
		POISONS_SPELL_ID = POISONS,
		MACRO_DEFAULT_ITEM_IDS = { Food = 117 },
		GetBestPoisonForHand = function(hand)
			local poison = opts.poisons and opts.poisons[hand]
			if poison then
				return poison[1], poison[2]
			end
		end,
		GetIgnoreList = function()
			return opts.ignoreList
		end,
		IsRestockListEmpty = function()
			return opts.restockEmpty or false
		end,
		BuildGroceryList = function()
			return opts.groceries or {}
		end,
		-- Item-Cache.lua's three namers, as far as the tooltip uses them: a link for an ID, the bare name without one.
		GetItemHyperlink = function(itemID, itemName)
			return itemID and link(itemID, itemName) or itemName
		end,
		UnbracketItemLink = function(itemLink)
			return (itemLink:gsub("|h%[(.-)%]|h", "|h%1|h"))
		end,
		GetItemLabel = function(itemID, itemName)
			local itemLink = itemID and link(itemID, itemName) or itemName
			return (itemLink:gsub("|h%[(.-)%]|h", "|h%1|h"))
		end,
		OpenOptionsPanel = function()
			calls[#calls + 1] = "OpenOptionsPanel"
		end,
		ToggleRestockWindow = function()
			calls[#calls + 1] = "ToggleRestockWindow"
		end,
		IgnoreItem = function(itemID)
			calls[#calls + 1] = "IgnoreItem " .. itemID
		end,
		ClearIgnoreList = function()
			calls[#calls + 1] = "ClearIgnoreList"
		end,
	}
	-- The real setter flips the profile switch; the tooltip must read the result.
	function ns.ToggleMacroSetting(key)
		calls[#calls + 1] = "ToggleMacroSetting " .. key
		profile[key] = not profile[key]
	end
	if not opts.noDatabase then
		ns.db = { profile = profile, global = { minimap = { hide = false } } }
	end
	if opts.food ~= false then
		ns.bestFoodID, ns.bestFoodLink = SKYWALL_SOUFFLE, link(SKYWALL_SOUFFLE, "Skywall Souffle")
	end
	if opts.class == "HUNTER" and opts.petSpells ~= false then
		local petSpells = opts.petSpells or {}
		ns.feedPetSpellName = "Feed Pet"
		ns.mendPetSpellName = petSpells.mend ~= false and (petSpells.mend or "Mend Pet") or nil
	end
	if opts.petFood ~= false then
		ns.bestPetFoodID, ns.bestPetFoodLink = ROASTED_QUAIL, link(ROASTED_QUAIL, "Roasted Quail")
	end

	assert(loadfile(ROOT .. "/Features/Minimap-Button.lua"))("Consumable-Connoisseur", ns)

	local s = { ns = ns, calls = calls, button = button, profile = profile }

	function s.hover()
		dataObject.OnEnter(button)
		return GameTooltip.lines
	end

	function s.click(mouseButton, withShift)
		shift = withShift or false
		dataObject.OnClick(button, mouseButton)
		shift = false
	end

	function s.lastCall()
		return calls[#calls]
	end

	function s.itemInfoReads()
		return itemInfoReads
	end

	return s
end

local function order(name, have, wanted, itemID)
	return { itemID = itemID, itemName = name, have = have, wanted = wanted }
end

local ONE_SHORT = { order("Freshly Baked Bread", 0, 20, FRESHLY_BAKED_BREAD) }

--------------------------------------------------------------------------------
-- Scenarios
--------------------------------------------------------------------------------

print("1. A class with no notes: the whole tooltip, in order")
local s = session({ groceries = ONE_SHORT })
local lines = s.hover()
checkLines("every line", lines, 1, {
	"Connoisseur | Dev",
	" ",
	" ",
	"Current Food",
	"(right) Skywall Souffle",
	"Right-Click | Ignore",
	" ",
	"Buff Food | Enabled",
	'Prioritizes food that grants "Well Fed" whenever the buff is missing.',
	"Left-Click | Toggle",
	" ",
	"Scroll Buffs | Enabled",
	"Applies missing scroll buffs from your Food macro before you eat.",
	"Shift + Left-Click | Toggle",
	" ",
	"Restocker List",
	"Buys and banks the items on your list.",
	"Shift + Right-Click | Open",
	" ",
	"Restocker Report",
	"Freshly Baked Bread | 0/20",
	" ",
	"Connoisseur Options",
	"Shift + Middle-Click",
})
check("and nothing after Options", #lines, 24)
check("anchored under the button", GameTooltip.anchor, "ANCHOR_BOTTOMLEFT")
check("shown", GameTooltip.shown, true)
check("the title is gold", lines[1].left, "<TITLE>Connoisseur|r")
check("the version is muted", lines[1].right, "<MUTED>Dev|r")
check("the item row's left is blank", lines[5].left, " ")
check(
	"the item keeps its icon and its quality color, and loses its link's brackets",
	lines[5].right,
	"|Ticon1001:14:14|t |cffffffff|Hitem:1001|hSkywall Souffle|h|r"
)
check("a click on the button is blue", lines[6].left, "<INFO>Right-Click|r")
check("and so is what it does", lines[6].right, "<INFO>Ignore|r")
check("a description wraps", lines[9].wrap, true)
check("the Restocker List title stands alone", lines[16].right, nil)
check("its description wraps", lines[17].wrap, true)
check("its click is blue", lines[18].left, "<INFO>Shift + Right-Click|r")
check("and has an action beside it", lines[18].right, "<INFO>Open|r")
check(
	"an order row is its icon and its bare name",
	lines[21].left,
	"|Ticon4001:14:14|t |cffffffff|Hitem:4001|hFreshly Baked Bread|h|r"
)
check("the Options click stands alone", lines[24].right, nil)

print("2. Hunter: pet food leads the notes, then the Feed Pet macro, then the report")
s = session({ class = "HUNTER", groceries = ONE_SHORT })
lines = s.hover()
checkLines("from the Restocker List down", lines, 16, {
	"Restocker List",
	"Buys and banks the items on your list.",
	"Shift + Right-Click | Open",
	" ",
	"Attention Hunters",
	"Current Pet Food",
	"(right) Roasted Quail",
	" ",
	"Feed Pet Macro",
	"Left-Click | Call, Feed, or Revive",
	"Right-Click, or in Combat | Mend Pet",
	"Hold Shift | Force Revive",
	"Hold Ctrl | Dismiss",
	" ",
	"Restocker Report",
	"Freshly Baked Bread | 0/20",
	" ",
	"Connoisseur Options",
	"Shift + Middle-Click",
})
check("the header wears the hunter color", lines[20].left, "|cffAAD372Attention Hunters|r")
check("the pet food title is gold", lines[21].left, "<TITLE>Current Pet Food|r")
check("the macro's name is gold", lines[24].left, "<TITLE>Feed Pet Macro|r")
check("a click on the macro is silver, not blue", lines[25].left, "<HELP>Left-Click|r")
check("and so is what it does", lines[25].right, "<HELP>Call, Feed, or Revive|r")

s = session({ class = "HUNTER", petSpells = { mend = "Guérison du familier" } })
lines = s.hover()
check(
	"Mend Pet is the client's own name",
	plainLine(lines[find(lines, "Feed Pet Macro") + 2]),
	"Right-Click, or in Combat | Guérison du familier"
)

s = session({ class = "HUNTER", petSpells = { mend = false } })
lines = s.hover()
checkLines("before Mend Pet is learned, its row is left out", lines, find(lines, "Feed Pet Macro"), {
	"Feed Pet Macro",
	"Left-Click | Call, Feed, or Revive",
	"Hold Shift | Force Revive",
	"Hold Ctrl | Dismiss",
	" ",
})

s = session({ class = "HUNTER", petFood = false })
lines = s.hover()
checkLines("no pet food: the sentence takes the item's row", lines, find(lines, "Attention Hunters"), {
	"Attention Hunters",
	"Current Pet Food",
	"No suitable Pet Food found in your bags.",
	" ",
	"Feed Pet Macro",
})
check("and wraps", lines[find(lines, "No suitable Pet Food found in your bags.")].wrap, true)

s = session({ class = "HUNTER", petSpells = false })
check("before Feed Pet is learned there are no notes", find(s.hover(), "Attention Hunters"), nil)

print("3. Rogue: both poisons lead the notes, two lines each, then the Poisons macro")
s = session({
	class = "ROGUE",
	knows = { POISONS },
	poisons = {
		main = { INSTANT_POISON, link(INSTANT_POISON, "Instant Poison VI") },
		off = { DEADLY_POISON, link(DEADLY_POISON, "Deadly Poison V") },
	},
	groceries = ONE_SHORT,
})
lines = s.hover()
checkLines("from the header down", lines, find(lines, "Attention Rogues"), {
	"Attention Rogues",
	"Main Hand Poison",
	"(right) Instant Poison VI",
	" ",
	"Off-Hand Poison",
	"(right) Deadly Poison V",
	" ",
	"Poisons Macro",
	"Left-Click | Off Hand",
	"Right-Click | Main Hand",
	"Middle-Click | Poisons Window",
	"Replaces old poisons automatically.",
	" ",
	"Restocker Report",
	"Freshly Baked Bread | 0/20",
	" ",
	"Connoisseur Options",
	"Shift + Middle-Click",
})
check("the header wears the rogue color", lines[find(lines, "Attention Rogues")].left, "|cffFFF468Attention Rogues|r")
check(
	"the closing line is silver and wraps",
	lines[find(lines, "Replaces old poisons automatically.")].left,
	"<HELP>Replaces old poisons automatically.|r"
)
check("(it wraps)", lines[find(lines, "Replaces old poisons automatically.")].wrap, true)

s = session({
	class = "ROGUE",
	knows = { POISONS },
	poisons = { main = { INSTANT_POISON, link(INSTANT_POISON, "Instant Poison VI") }, off = false },
})
lines = s.hover()
checkLines("an empty hand says so under its own title", lines, find(lines, "Main Hand Poison"), {
	"Main Hand Poison",
	"(right) Instant Poison VI",
	" ",
	"Off-Hand Poison",
	"No suitable Poison found in your bags.",
	" ",
	"Poisons Macro",
})

s = session({ class = "ROGUE" })
check("before Poisons is learned there are no notes", find(s.hover(), "Attention Rogues"), nil)

print("4. Mage: one group per macro, a row only for what is known")
s = session({
	class = "MAGE",
	knows = { CONJURE_FOOD, CONJURE_WATER, RITUAL_OF_REFRESHMENT, CONJURE_MANA_GEM },
	restockEmpty = true,
})
lines = s.hover()
checkLines("everything known", lines, find(lines, "Attention Mages") - 1, {
	" ",
	"Attention Mages",
	"Food and Water Macros",
	"Right-Click | Conjure",
	"Middle-Click | Ritual of Refreshment",
	"Target a lower-level player to conjure for their level.",
	" ",
	"Mana Gem Macro",
	"Right-Click | Conjure",
	"Right-Click Again | Lower-Rank Backup",
	" ",
	"Restocker Report",
})
check("the header wears the mage color", lines[find(lines, "Attention Mages")].left, "|cff3FC7EBAttention Mages|r")

s = session({ class = "MAGE", knows = { CONJURE_WATER } })
lines = s.hover()
checkLines("only Conjure Water: one row, its line, no gem group", lines, find(lines, "Attention Mages"), {
	"Attention Mages",
	"Food and Water Macros",
	"Right-Click | Conjure",
	"Target a lower-level player to conjure for their level.",
	" ",
	"Congratulations, you're fully stocked up!",
})

s = session({ class = "MAGE", knows = { CONJURE_MANA_GEM } })
lines = s.hover()
checkLines(
	"only a Mana Gem: its group follows the header, with no doubled gap",
	lines,
	find(lines, "Attention Mages") - 1,
	{
		" ",
		"Attention Mages",
		"Mana Gem Macro",
		"Right-Click | Conjure",
		"Right-Click Again | Lower-Rank Backup",
		" ",
	}
)

local noRitual = conjureSpells()
noRitual.MageCreateTable = {}
s = session({ class = "MAGE", knows = { CONJURE_FOOD, RITUAL_OF_REFRESHMENT }, conjureSpells = noRitual })
check(
	"a flavor with no ritual rows has no Middle-Click row",
	find(s.hover(), "Middle-Click | Ritual of Refreshment"),
	nil
)

s = session({ class = "MAGE" })
check("a Mage who knows none of it gets no header", find(s.hover(), "Attention Mages"), nil)

print("5. Warlock: Healthstone and Soulstone, each its own group")
s = session({ class = "WARLOCK", knows = { CREATE_HEALTHSTONE, CREATE_SOULSTONE, RITUAL_OF_SOULS } })
lines = s.hover()
checkLines("everything known", lines, find(lines, "Attention Warlocks"), {
	"Attention Warlocks",
	"Healthstone Macro",
	"Right-Click | Create",
	"Right-Click Again | Lower-Rank Backup",
	"Middle-Click | Ritual of Souls",
	"Target a lower-level player to create one for their level.",
	" ",
	"Soulstone Macro",
	"Right-Click | Create",
	" ",
})
check(
	"the header wears the warlock color",
	lines[find(lines, "Attention Warlocks")].left,
	"|cff8788EEAttention Warlocks|r"
)

s = session({ class = "WARLOCK", knows = { CREATE_HEALTHSTONE } })
lines = s.hover()
checkLines("no Ritual of Souls, no Soulstone: one group", lines, find(lines, "Attention Warlocks"), {
	"Attention Warlocks",
	"Healthstone Macro",
	"Right-Click | Create",
	"Right-Click Again | Lower-Rank Backup",
	"Target a lower-level player to create one for their level.",
	" ",
	"Congratulations, you're fully stocked up!",
})

print("6. The Restocker Report: empty, stocked, listed, counted")
s = session({ restockEmpty = true, groceries = ONE_SHORT })
lines = s.hover()
checkLines("a list with no rows is empty, not stocked", lines, find(lines, "Restocker Report"), {
	"Restocker Report",
	"Your list is empty.",
	" ",
	"Connoisseur Options",
})
check("the line is white", lines[find(lines, "Your list is empty.")].left, "<BODY>Your list is empty.|r")

s = session({})
lines = s.hover()
checkLines(
	"nothing short: the congratulation stands in for the header",
	lines,
	find(lines, "Shift + Right-Click | Open"),
	{
		"Shift + Right-Click | Open",
		" ",
		"Congratulations, you're fully stocked up!",
		" ",
		"Connoisseur Options",
	}
)
local stocked = lines[find(lines, "Congratulations, you're fully stocked up!")]
check("in green", stocked.left, "<ON>Congratulations, you're fully stocked up!|r")
check("wrapping", stocked.wrap, true)

local eight = {}
for index = 1, 8 do
	eight[index] = order("Item " .. index, index, 20, 5000 + index)
end
s = session({ groceries = eight })
lines = s.hover()
check("eight orders are all listed", plainLine(lines[find(lines, "Restocker Report") + 8]), "Item 8 | 8/20")
check("under a header with no count", lines[find(lines, "Restocker Report")].right, nil)

local nine = {}
for index = 1, 9 do
	nine[index] = order("Item " .. index, index, 20, 5000 + index)
end
s = session({ groceries = nine })
lines = s.hover()
checkLines("nine become a count beside the header", lines, find(lines, "Restocker Report | 9 Orders Outstanding"), {
	"Restocker Report | 9 Orders Outstanding",
	" ",
	"Connoisseur Options",
})

s = session({ groceries = { order("Mystery Meat", 1, 5, nil) } })
lines = s.hover()
check(
	"a name-only row shows the question mark",
	lines[find(lines, "Restocker Report") + 1].left,
	"|TInterface\\ICONS\\INV_Misc_QuestionMark:14:14|t Mystery Meat"
)

print("7. The Ignore List: last before Options, eight rows at most")
s = session({ groceries = ONE_SHORT })
check("no block while the list is empty", find(s.hover(), "Ignore List"), nil)
s = session({ groceries = ONE_SHORT, ignoreList = {} })
check("nor for a list with no entries", find(s.hover(), "Ignore List"), nil)

s = session({
	class = "MAGE",
	knows = { CONJURE_WATER },
	groceries = ONE_SHORT,
	ignoreList = { [7001] = true, [7002] = true, [7003] = true },
	itemNames = { [7001] = "Nightfin Soup", [7002] = "Alterac Manna Biscuit" },
})
lines = s.hover()
checkLines("after the notes and the report, A to Z, an uncached item last", lines, find(lines, "Restocker Report"), {
	"Restocker Report",
	"Freshly Baked Bread | 0/20",
	" ",
	"Ignore List",
	"Alterac Manna Biscuit",
	"Nightfin Soup",
	"Loading ID: 7003",
	"Middle-Click | Clear Ignore List",
	" ",
	"Connoisseur Options",
	"Shift + Middle-Click",
})
check("the notes sit above the report", find(lines, "Attention Mages") < find(lines, "Restocker Report"), true)
check(
	"an ignored item is its icon and its bare name, in its quality color",
	lines[find(lines, "Alterac Manna Biscuit")].left,
	"|Ticon7002:14:14|t |cffffffffAlterac Manna Biscuit|r"
)
check("an uncached item is muted", lines[find(lines, "Loading ID: 7003")].left, "<MUTED>Loading ID: 7003|r")
check("the clear click is blue", lines[find(lines, "Middle-Click | Clear Ignore List")].left, "<INFO>Middle-Click|r")

local eightIgnored, nineIgnored, names = {}, {}, {}
for index = 1, 9 do
	names[8000 + index] = "Ignored " .. index
	nineIgnored[8000 + index] = true
	if index <= 8 then
		eightIgnored[8000 + index] = true
	end
end
s = session({ ignoreList = eightIgnored, itemNames = names })
lines = s.hover()
check("eight are all listed", plainLine(lines[find(lines, "Ignore List") + 8]), "Ignored 8")

s = session({ ignoreList = nineIgnored, itemNames = names })
lines = s.hover()
checkLines("nine become a count beside the title", lines, find(lines, "Ignore List | 9 Items"), {
	"Ignore List | 9 Items",
	"Middle-Click | Clear Ignore List",
	" ",
	"Connoisseur Options",
})
check("and no item is looked up to say so", s.itemInfoReads(), 0)

print("8. A switch's state: off, on, or waiting on its when-to-use choice")
s = session({ profile = { useBuffFood = false } })
lines = s.hover()
check("off is red", lines[find(lines, "Buff Food | Disabled")].right, "<OFF>Disabled|r")
check("the other switch is judged on its own", lines[find(lines, "Scroll Buffs | Enabled")].right, "<ON>Enabled|r")

s = session({ profile = { buffFoodMode = "raid" } })
lines = s.hover()
check(
	"on, but solo with When in a Raid: the choice, in gray",
	lines[find(lines, "Buff Food | When in a Raid")].right,
	"<SEPARATOR>When in a Raid|r"
)

s = session({ profile = { buffFoodMode = "raid", scrollsMode = "raid" }, raid = true })
lines = s.hover()
check("in a raid it holds, so Enabled in green", lines[find(lines, "Buff Food | Enabled")].right, "<ON>Enabled|r")
check("Scroll Buffs reads its own choice", lines[find(lines, "Scroll Buffs | Enabled")].right, "<ON>Enabled|r")

s = session({ profile = { useScrolls = false, scrollsMode = "raid" } })
check("off wins over a waiting choice", find(s.hover(), "Scroll Buffs | Disabled") ~= nil, true)

print("9. No food in the bags")
s = session({ food = false })
lines = s.hover()
checkLines("the sentence takes the item's row, and there is no Ignore hint", lines, 4, {
	"Current Food",
	"No suitable Food found in your bags.",
	" ",
	"Buff Food | Enabled",
})
check("the sentence wraps", lines[5].wrap, true)

print("10. The six clicks")
s = session({})
s.click("LeftButton")
check("Left-Click toggles Buff Food", s.lastCall(), "ToggleMacroSetting useBuffFood")
s.click("LeftButton", true)
check("Shift + Left-Click toggles Scroll Buffs", s.lastCall(), "ToggleMacroSetting useScrolls")
s.click("RightButton")
check("Right-Click ignores the current food", s.lastCall(), "IgnoreItem " .. SKYWALL_SOUFFLE)
s.click("RightButton", true)
check("Shift + Right-Click opens the Restock List", s.lastCall(), "ToggleRestockWindow")
s.click("MiddleButton")
check("Middle-Click clears the Ignore List", s.lastCall(), "ClearIgnoreList")
s.click("MiddleButton", true)
check("Shift + Middle-Click opens the options", s.lastCall(), "OpenOptionsPanel")
check("six clicks, six calls", #s.calls, 6)

s = session({ food = false })
s.click("RightButton")
check("with no food, Right-Click ignores nothing", #s.calls, 0)
check("the button falls back to the Food macro's default icon", s.button.icon.texture, "icon117")

print("11. A click redraws the tooltip while the mouse is still over the button")
s = session({})
s.hover()
s.click("LeftButton")
check("the state flips without a new hover", find(GameTooltip.lines, "Buff Food | Disabled") ~= nil, true)
check("the icon follows the current food", s.button.icon.texture, "icon" .. SKYWALL_SOUFFLE)
GameTooltip:Hide()
s.click("LeftButton")
check("with the mouse elsewhere, nothing is drawn", GameTooltip.shown, false)

print("12. Registration and the General panel's switch")
s = session({})
s.ns.RegisterMinimapIcon()
s.ns.RegisterMinimapIcon()
check("registered once, under the brand name", table.concat(s.calls, ", "), "Register Connoisseur")
s.ns.ToggleMinimapButton(false)
check("switched off, the button hides", s.ns.db.global.minimap.hide, true)
s.ns.ToggleMinimapButton()
check("with no argument it flips back", s.ns.db.global.minimap.hide, false)
check("and LibDBIcon is told each time", s.lastCall(), "Refresh")

print("13. Before the saved settings exist, the tooltip draws nothing")
s = session({ noDatabase = true })
check("no lines", #s.hover(), 0)
check("and nothing shown", GameTooltip.shown, false)

print("")
if failures == 0 then
	print("ALL MINI-MAP BUTTON SCENARIOS PASSED")
else
	print(("%d MINI-MAP BUTTON CHECK(S) FAILED"):format(failures))
	os.exit(1)
end
