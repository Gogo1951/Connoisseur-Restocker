-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the Forsaken Cannibalize lines (no WoW client needed).

    Run it with:   lua Tests/Cannibalize-Test.lua        (from the add-on root)

    Like the other headless tests, this does NOT model the feature. It loads the
    REAL Game-IDs and Macro-Default-Items files, Features/Macros/Signatures.lua,
    Tools-Forsaken.lua, Body-Builder.lua, Engine.lua and the Food, Water, Health
    Potion and Mana Potion definitions, then runs ns.UpdateMacros and reads the
    bodies it writes. The scanner, the writer and the client are stubs.

    WHAT IS PINNED HERE. With the option on, a Forsaken's Food macro casts
    Cannibalize on a dead target, ahead of eating, while the target is Humanoid
    or Undead and the spell is off cooldown; anything else leaves the usual
    body. Buff food, the pet-buff override and scroll-only mode keep their
    bodies. The Water macro does the same only where Cannibalize restores mana.
    With Use Food & Water in Potion Macros Out of Combat on, the potion macros
    cannibalize out of combat too, under the same gates, and never in combat.
    The cooldown's end is timed for a rebuild, once per cooldown. Every body
    stays within 255 bytes in Russian with six-digit item IDs, shedding the
    Cannibalize lines first. The target signature moves with the creature type.
    With Macros switched off nothing is written, while the bag scan and the
    mini-map icon still run.
]]

local ROOT = arg[1] or "."

local failures = 0

local function check(label, got, want)
	if got == want then
		print("  ok    " .. label)
	else
		failures = failures + 1
		print(("  FAIL  %s:\n        got  %s\n        want %s"):format(label, tostring(got), tostring(want)))
	end
end

local function contains(label, body, fragment, want)
	check(label, (body or ""):find(fragment, 1, true) ~= nil, want)
end

--------------------------------------------------------------------------------
-- Client Stubs
--------------------------------------------------------------------------------

local now = 1000
local target -- nil, or { creatureType = "Humanoid", secret = false }
local cooldown -- { startTime, duration }
local timers = {}
local requests = 0

local SECRET = setmetatable({}, {
	__tostring = function()
		return "<secret>"
	end,
})

function GetTime()
	return now
end
function InCombatLockdown()
	return false
end
function UnitExists(unit)
	return unit == "target" and target ~= nil
end
-- The client's name and creature type ID; the add-on reads only the ID.
local CREATURE_TYPE_IDS = { Beast = 1, Undead = 6, Humanoid = 7 }
function UnitCreatureType()
	if not target then
		return nil
	end
	if target.secret then
		return SECRET, SECRET
	end
	return "name-" .. target.creatureType, CREATURE_TYPE_IDS[target.creatureType]
end
function UnitIsFriend()
	return false
end
function UnitIsPlayer()
	return false
end
function UnitIsUnit()
	return false
end
function UnitLevel()
	return 60
end
function IsInGroup()
	return false
end
function IsInRaid()
	return false
end
function wipe(t)
	for key in pairs(t) do
		t[key] = nil
	end
	return t
end
function LibStub()
	return { NotifyChange = function() end }
end

C_Secrets = {
	CanCompareUnitTokens = function()
		return true
	end,
	ShouldUnitIdentityBeSecret = function()
		return target ~= nil and target.secret == true
	end,
	ShouldSpellCooldownBeSecret = function()
		return cooldown[1] == SECRET
	end,
}
C_Spell = {
	GetSpellCooldown = function()
		return { startTime = cooldown[1], duration = cooldown[2], isEnabled = true, modRate = 1 }
	end,
}
C_Timer = {
	After = function(seconds, callback)
		timers[#timers + 1] = { seconds = seconds, callback = callback }
	end,
}

--------------------------------------------------------------------------------
-- Add-on Stubs
--------------------------------------------------------------------------------

local ns = {}
local written = {}

ns.MACRO_CONFIG = {}
for _, typeName in ipairs({ "Food", "Water", "Health Potion", "Mana Potion" }) do
	ns.MACRO_CONFIG[typeName] = { macro = typeName }
end
ns.MULTI_USE_MACRO_TYPES = { ["Health Potion"] = true, ["Mana Potion"] = true }
ns.MACRO_BODY_MAX_LENGTH = 255
ns.CONJURE_SPELLS = {}

function ns.IsSecretValue(value)
	return value == SECRET
end
function ns.RequestUpdate()
	requests = requests + 1
end
function ns.WriteMacroBody(macroName, body)
	written[macroName] = body
	return true
end
function ns.DeleteMacroByName() end
function ns.RegisterDataRetry() end
function ns.UnregisterDataRetry() end
local iconUpdates = 0
function ns.UpdateMinimapIcon()
	iconUpdates = iconUpdates + 1
end
function ns.MarkUpdatePending() end
function ns.BuildDruidMacroOverride()
	return nil
end
function ns.ResetHunterMacroState() end
function ns.ResetPoisonMacroState() end
function ns.ResetScrollBuffTracking() end

local conjure -- what the Mage resolver answers for Food, or nil
function ns.ResolveMageWaterOrFoodConjure()
	return conjure
end

local best
local scans = 0
function ns.ScanBags()
	scans = scans + 1
	return best, false
end

local function load(path)
	local chunk = assert(loadfile(ROOT .. "/" .. path))
	chunk("Consumable-Connoisseur", ns)
end

load("Data/Camelot/Game-IDs-Camelot.lua")
load("Data/Camelot/Macro-Default-Items-Camelot.lua")
load("Features/Macros/Signatures.lua")
load("Features/Macros/Tools-Forsaken.lua")
load("Features/Macros/Body-Builder.lua")
load("Features/Macros/Engine.lua")
load("Features/Macros/Food.lua")
load("Features/Macros/Health-Potion.lua")
load("Features/Macros/Mana-Potion.lua")
load("Features/Macros/Water.lua")

--------------------------------------------------------------------------------
-- Scenario Helpers
--------------------------------------------------------------------------------

local function Entry(id, isBuffFood)
	return { id = id, isBuffFood = isBuffFood or false }
end

--[[
    A Forsaken on WoW Forever with both switches on, a Humanoid target, the
    spell ready, and plain food and water in the bags. Each scenario changes
    what it tests.
]]
local function Reset()
	ns.isForsaken = true
	ns.cannibalizeSpellName = "Cannibalize"
	ns.isRogue, ns.stealthSpellName = false, nil
	ns.isNightElf = false
	ns.CANNIBALIZE_RESTORES_MANA = true
	ns.petBuffOverrideID = nil
	ns.scrollOverrideIDs = nil
	ns.db = {
		profile = {
			enableCannibalizeEating = true,
			enableCannibalizeDrinking = true,
			potionsUseFoodAndWater = false,
		},
		global = { macrosEnabled = true },
	}
	target = { creatureType = "Humanoid" }
	cooldown = { 0, 0 }
	conjure = nil
	best = {
		Food = Entry(8952),
		Water = Entry(8766),
		["Health Potion"] = { id = 13446, topIDs = { 13446 } },
		["Mana Potion"] = { id = 13444, topIDs = { 13444 } },
	}
	timers = {}
	requests = 0
	wipe(written)
end

local function Update()
	wipe(written)
	ns.UpdateMacros(true)
end

--------------------------------------------------------------------------------
-- The Food and Water Macros
--------------------------------------------------------------------------------

print("Food and Water macros")

Reset()
Update()
check(
	"Food casts Cannibalize on a dead target, then eats",
	written.Food,
	"#showtooltip [dead] Cannibalize; item:8952\n"
		.. "/cast [dead] Cannibalize\n"
		.. "/run ConnoisseurFire(8952)\n"
		.. "/use item:8952"
)
check(
	"Water does the same where Cannibalize restores mana",
	written.Water,
	"#showtooltip [dead] Cannibalize; item:8766\n"
		.. "/cast [dead] Cannibalize\n"
		.. "/run ConnoisseurFire(8766)\n"
		.. "/use item:8766"
)
check("the potion macros are left alone while their option is off", written["Health Potion"]:find("Cannibalize"), nil)

Reset()
target.creatureType = "Undead"
Update()
contains("an Undead target counts", written.Food, "/cast [dead] Cannibalize", true)

Reset()
target.creatureType = "Beast"
Update()
check(
	"a Beast target leaves the usual body",
	written.Food,
	"#showtooltip item:8952\n/run ConnoisseurFire(8952)\n/use item:8952"
)

Reset()
target = nil
Update()
contains("no target leaves the usual body", written.Food, "Cannibalize", false)

Reset()
target.secret = true
Update()
contains("a hidden creature type leaves the usual body", written.Food, "Cannibalize", false)

Reset()
ns.db.profile.enableCannibalizeEating = false
Update()
contains("Food's switch off leaves its usual body", written.Food, "Cannibalize", false)
contains("... and Water keeps its own switch", written.Water, "Cannibalize", true)

Reset()
ns.isForsaken = false
Update()
contains("another race never casts it", written.Food, "Cannibalize", false)

Reset()
ns.CANNIBALIZE_RESTORES_MANA = false
Update()
contains("Water skips it where Cannibalize restores no mana", written.Water, "Cannibalize", false)
contains("... while Food still casts it", written.Food, "Cannibalize", true)

Reset()
best.Food = Entry(13931, true)
best.Water = Entry(13931, true)
Update()
contains("a buff food pick comes first", written.Food, "Cannibalize", false)
contains("... and so does a buff drink", written.Water, "Cannibalize", false)

Reset()
best.Food = Entry(nil)
Update()
check(
	"with no food it still cannibalizes, and a corpse press skips the no-item line",
	written.Food,
	"#showtooltip [dead] Cannibalize; item:"
		.. ns.MACRO_DEFAULT_ITEM_IDS.Food
		.. "\n/cast [dead] Cannibalize\n"
		.. "/stopmacro [dead]\n"
		.. '/run ConnoisseurNoItem("Food")'
)

Reset()
best.Food = Entry(nil)
conjure = { noItemMiss = "conjureFood" }
Update()
contains(
	"... and so does the not-yet-learned tip",
	written.Food,
	"/cast [dead] Cannibalize\n/stopmacro [dead]\n/run ConnoisseurTip(",
	true
)

Reset()
best.Food = Entry(nil)
target.creatureType = "Beast"
Update()
contains("without the cast, the no-item line has no stop above it", written.Food, "/stopmacro", false)

Reset()
ns.petBuffOverrideID = 33874
Update()
contains("the pet-buff override feeds the pet without it", written.Food, "Cannibalize", false)
contains("... and still feeds the pet", written.Food, "/use [@pet] item:33874", true)

Reset()
ns.scrollOverrideIDs = { 10307 }
Update()
check("scroll-only mode comes first", written.Food, "#showtooltip\n/use [@player] item:10307\n")

Reset()
ns.scrollOverrideIDs = { 10307, 10306 }
Update()
check(
	"one press uses every missing scroll",
	written.Food,
	"#showtooltip\n/use [@player] item:10307\n/use [@player] item:10306\n"
)
Reset()
ns.FLAVOR = "Camelot"
ns.scrollOverrideIDs = { 10307, 10306 }
Update()
check(
	"... but one at a time on Forever, where scrolls trigger the GCD",
	written.Food,
	"#showtooltip\n/use [@player] item:10307\n"
)
ns.FLAVOR = nil

Reset()
ns.isRogue, ns.stealthSpellName = true, "Stealth"
ns.db.profile.enableStealthEating = true
Update()
check(
	"Stealth Eating stays below the eat line",
	written.Food,
	"#showtooltip [dead] Cannibalize; item:8952\n"
		.. "/cast [dead] Cannibalize\n"
		.. "/run ConnoisseurFire(8952)\n"
		.. "/use item:8952\n"
		.. "/cast [nostealth] Stealth"
)

Reset()
conjure = { rightName = "Conjure Food(Rank 7)", rightID = 28612 }
Update()
check(
	"a Mage's conjure click stays above it",
	written.Food,
	"#showtooltip [dead] Cannibalize; item:8952\n"
		.. "/cast [btn:2] Conjure Food(Rank 7); \n"
		.. "/stopmacro [btn:2]\n"
		.. "/cast [dead] Cannibalize\n"
		.. "/run ConnoisseurFire(8952)\n"
		.. "/use item:8952"
)

--------------------------------------------------------------------------------
-- Cooldown
--------------------------------------------------------------------------------

print("Cooldown")

Reset()
cooldown = { now - 0.5, 1.5 }
Update()
contains("the global cooldown alone counts as on cooldown", written.Food, "Cannibalize", false)
check("... and times the line's return for when it ends", timers[1] and timers[1].seconds, 1.1)

Reset()
cooldown = { now - 50, 120 }
Update()
contains("on cooldown, Food eats as usual", written.Food, "Cannibalize", false)
contains("... and so does Water", written.Water, "Cannibalize", false)
check("one rebuild is timed for the cooldown's end", #timers, 1)
check("... at the moment it ends", timers[1] and timers[1].seconds, 70.1)
Update()
check("a later pass on the same cooldown times no second one", #timers, 1)
if timers[1] then
	timers[1].callback()
end
check("the timer asks for a rebuild", requests, 1)
now = now + 70.1
Update()
contains("off cooldown again, the line is back", written.Food, "/cast [dead] Cannibalize", true)
now = 1000

Reset()
cooldown = { SECRET, SECRET }
Update()
contains("a hidden cooldown counts as on cooldown", written.Food, "Cannibalize", false)

Reset()
check("a Forsaken's own Cannibalize cast asks for a rebuild", ns.SpellCastChangesMacros(ns.CANNIBALIZE_SPELL_ID), true)
check("... and an unrelated cast does not", ns.SpellCastChangesMacros(1), false)
ns.isForsaken = false
check("... nor another race's Cannibalize", ns.SpellCastChangesMacros(ns.CANNIBALIZE_SPELL_ID), false)

--------------------------------------------------------------------------------
-- Potion Macros Out of Combat
--------------------------------------------------------------------------------

print("Potion macros out of combat")

Reset()
ns.db.profile.potionsUseFoodAndWater = true
Update()
check(
	"Health Potion cannibalizes or eats out of combat, drinks the potion in it",
	written["Health Potion"],
	"#showtooltip [combat] item:13446; item:8952\n"
		.. "/run ConnoisseurFire(13446,8952)\n"
		.. "/cast [nocombat,dead] Cannibalize\n"
		.. "/use [nocombat] item:8952\n"
		.. "/stopmacro [nocombat]\n"
		.. "/use item:13446"
)
contains("Mana Potion cannibalizes too", written["Mana Potion"], "/cast [nocombat,dead] Cannibalize\n", true)

Reset()
ns.db.profile.potionsUseFoodAndWater = true
ns.isRogue, ns.stealthSpellName = true, "Stealth"
ns.db.profile.enableStealthEating = true
Update()
contains(
	"a failed Cannibalize falls through to the food and its stealth",
	written["Health Potion"],
	"/cast [nocombat,dead] Cannibalize\n/use [nocombat] item:8952\n/cast [nocombat,nostealth] Stealth\n/stopmacro [nocombat]\n",
	true
)

Reset()
ns.db.profile.potionsUseFoodAndWater = true
best.Food = Entry(13931, true)
Update()
contains("buff food comes first there as well", written["Health Potion"], "Cannibalize", false)
contains("... eaten out of combat as before", written["Health Potion"], "/use [nocombat] item:13931\n", true)

Reset()
ns.db.profile.potionsUseFoodAndWater = true
cooldown = { now - 50, 120 }
Update()
contains("on cooldown the potion macro just eats", written["Health Potion"], "Cannibalize", false)

Reset()
ns.db.profile.potionsUseFoodAndWater = true
ns.CANNIBALIZE_RESTORES_MANA = false
Update()
contains("Mana Potion skips it where it restores no mana", written["Mana Potion"], "Cannibalize", false)

--------------------------------------------------------------------------------
-- Macros Master Switch
--------------------------------------------------------------------------------

print("Macros master switch")

-- Off, the macros stay as they were, but the scan the Readiness Report and the mini-map read still runs.
Reset()
ns.db.global.macrosEnabled = false
scans, iconUpdates = 0, 0
Update()
check("switched off, no macro is written", next(written), nil)
check("... the bags are still scanned", scans, 1)
check("... and the mini-map icon still follows the scan", iconUpdates, 1)

--------------------------------------------------------------------------------
-- Rewrites
--------------------------------------------------------------------------------

print("Rewrites")

-- The state key must move with the line, or the macro keeps a stale body.
Reset()
ns.UpdateMacros(true)
local writes = 0
local realWrite = ns.WriteMacroBody
function ns.WriteMacroBody(macroName, body)
	if macroName == "Food" then
		writes = writes + 1
	end
	return realWrite(macroName, body)
end
ns.UpdateMacros(false)
check("an unchanged pass writes nothing", writes, 0)
target.creatureType = "Beast"
ns.UpdateMacros(false)
check("losing the line rewrites the macro", writes, 1)
target.creatureType = "Humanoid"
ns.UpdateMacros(false)
check("gaining it back rewrites it again", writes, 2)
ns.WriteMacroBody = realWrite

Reset()
ns.ResetTargetTracking()
ns.TargetSignatureChanged()
target.creatureType = "Beast"
check("a Forsaken's target signature moves from Humanoid to Beast", ns.TargetSignatureChanged(), true)
check("... and holds while it stays a Beast", ns.TargetSignatureChanged(), false)
target.secret = true
check("... and holds while the client hides the type", ns.TargetSignatureChanged(), false)
target = { creatureType = "Undead" }
check("... and moves again on an Undead", ns.TargetSignatureChanged(), true)
ns.isForsaken = false
target.creatureType = "Beast"
ns.TargetSignatureChanged()
target.creatureType = "Humanoid"
check("another race's signature ignores creature types", ns.TargetSignatureChanged(), false)

Reset()
ns.db.profile.enableCannibalizeEating = false
ns.db.profile.enableCannibalizeDrinking = false
ns.ResetTargetTracking()
ns.TargetSignatureChanged()
target.creatureType = "Beast"
check("with both switches off a Forsaken's signature ignores creature types", ns.TargetSignatureChanged(), false)
ns.db.profile.enableCannibalizeDrinking = true
ns.CANNIBALIZE_RESTORES_MANA = false
target.creatureType = "Humanoid"
check("... and so does Drinking alone where Cannibalize restores no mana", ns.TargetSignatureChanged(), false)

--------------------------------------------------------------------------------
-- Macro Length
--------------------------------------------------------------------------------

print("Macro length (ruRU, six-digit IDs)")

local function Russian()
	Reset()
	ns.cannibalizeSpellName = "Каннибализм"
	ns.isRogue, ns.stealthSpellName = true, "Незаметность"
	ns.db.profile.enableStealthEating = true
	ns.db.profile.potionsUseFoodAndWater = true
	best.Food = Entry(250327)
	best.Water = Entry(250328)
	best["Health Potion"] = { id = 250329, topIDs = { 250329, 250330, 250331 } }
	best["Mana Potion"] = { id = 250332, topIDs = { 250332, 250333, 250334 } }
end

Russian()
Update()
for _, typeName in ipairs({ "Food", "Water", "Health Potion", "Mana Potion" }) do
	check(typeName .. " fits in 255 bytes", #written[typeName] <= 255, true)
end
-- Too long at six digits: the Rogue's Health Potion sheds Cannibalize before any potion.
contains(
	"the Rogue's Health Potion sheds Cannibalize at six digits",
	written["Health Potion"],
	"Каннибализм",
	false
)
contains("... keeping its fallback potions", written["Health Potion"], "/use item:250330", true)
contains("... and its best potion", written["Health Potion"], "/use item:250329", true)

-- A far longer Cannibalize name changes nothing more: it is shed first, so the fallback potions stay.
Russian()
ns.cannibalizeSpellName = ("Каннибализм"):rep(4)
Update()
check("an overlong Health Potion body fits", #written["Health Potion"] <= 255, true)
contains("... by shedding Cannibalize", written["Health Potion"], "Каннибализм", false)
contains("... which lets its fallback potions back in", written["Health Potion"], "/use item:250331", true)
contains("... and keeps its stealth", written["Health Potion"], "Незаметность", true)

-- A Mage's Food macro, whose conjure clicks never shed, sheds Cannibalize instead.
Russian()
ns.isRogue, ns.stealthSpellName = false, nil
conjure = {
	rightName = "Сотворение пищи(Уровень 7)",
	rightID = 28612,
	middleName = "Обряд сотворения яств(Уровень 2)",
	middleID = 43987,
}
local longName = ("Каннибализм"):rep(4)
ns.cannibalizeSpellName = longName
Update()
check("an overlong Food body fits", #written.Food <= 255, true)
contains("... by shedding Cannibalize", written.Food, longName, false)
contains("... and keeping the conjure clicks", written.Food, "[btn:3]", true)

-- With nothing in the bags, the corpse press's stop rides along with the cast.
Russian()
best.Food = Entry(nil)
Update()
check("the no-item Food body fits in 255 bytes", #written.Food <= 255, true)
contains("... keeping Cannibalize", written.Food, "/cast [dead] Каннибализм\n/stopmacro [dead]\n", true)

--------------------------------------------------------------------------------

print()
if failures == 0 then
	print("ALL CANNIBALIZE SCENARIOS PASSED")
else
	print(("%d CANNIBALIZE SCENARIO(S) FAILED"):format(failures))
	os.exit(1)
end
