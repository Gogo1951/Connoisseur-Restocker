-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the combo macros (no WoW client needed).

    Run it with:   lua Features/Tests/Combo-Macros-Test.lua        (from the add-on root)

    Like Readiness-Report-Test, this does NOT model the logic: it loads the REAL
    Features/Macros/Body-Builder.lua, Features/Macros/Food-and-Potion.lua,
    Features/Macros/Water-and-Potion.lua and Features/Macros/Runtime.lua, and
    drives the two definitions' buildModeOverride and the macro globals behind
    the thinnest stubs that will hold them up (a scan result, a chat sink, and
    the combat conditional).

    WHAT IS PINNED HERE. The body shape: bare #showtooltip, one
    ConnoisseurFireIf line naming both halves, [combat] lines in the potion
    macro's order, then the [nocombat] rest line. Food & Potion follows
    Combine Healthstones exactly as the Health Potion macro does, including the
    stones becoming the whole combat half when there is no potion; Water &
    Potion uses mana potions only. A missing half turns into a
    ConnoisseurNoItemIf line for its own combat state, and a body with nothing
    at all keeps an icon. The 255 trim sheds stacked lines before potion
    fallbacks and never the first combat line. The state key moves with every
    input. At press time, ConnoisseurFireIf stamps the item its conditional
    picks and ConnoisseurNoItemIf prints only when its conditional holds.
]]

local ROOT = arg[1] or "."

local ns = { L = {} }

--------------------------------------------------------------------------------
-- Stubs
--------------------------------------------------------------------------------

-- Locale keys resolve to their own name, with placeholders where a format needs them.
setmetatable(ns.L, {
	__index = function(_, key)
		if key == "MESSAGE_NO_ITEM" then
			return "NO:%s"
		elseif key == "MESSAGE_BUG_REPORT" then
			return "BUG:%s:%s:%s:%s:%s:%s"
		end
		return key
	end,
})

ns.REGISTERED_MACRO_DEFINITIONS = {}
function ns.RegisterMacroType(definition)
	ns.REGISTERED_MACRO_DEFINITIONS[#ns.REGISTERED_MACRO_DEFINITIONS + 1] = definition
end

ns.MACRO_BODY_MAX_LENGTH = 255
ns.MACRO_DEFAULT_ITEM_IDS = { ["Food"] = 5349, ["Water"] = 5350 }
ns.MACRO_CONFIG = {}
ns.DISCORD_URL = "discord"
ns.db = { profile = { combineHealthstones = false } }

local inCombat = false
local printed = {}

function ns.PrintMessage(text)
	printed[#printed + 1] = text
end
function ns.GetItemHyperlink(itemID)
	return "item" .. tostring(itemID)
end

-- Only the two conditions the combo bodies emit.
function SecureCmdOptionParse(text)
	if text == "[combat] 1" then
		return inCombat and "1" or nil
	elseif text == "[nocombat] 1" then
		return (not inCombat) and "1" or nil
	end
	error("unexpected conditional: " .. text)
end
function GetTime()
	return 100
end
function GetZoneText()
	return "Zone"
end
function GetSubZoneText()
	return ""
end
C_Map = {
	GetBestMapForUnit = function()
		return 1
	end,
}
ERR_ITEM_WRONG_ZONE = "wrong zone"

local realPrint = io.write
local function say(text)
	realPrint(text .. "\n")
end

--------------------------------------------------------------------------------

local function loadAddonFile(path)
	-- Add-on files are chunks taking (addonName, ns) as varargs, the way WoW loads them.
	return assert(loadfile(ROOT .. "/" .. path))("Consumable-Connoisseur", ns)
end

loadAddonFile("Features/Macros/Body-Builder.lua")
loadAddonFile("Features/Macros/Food-and-Potion.lua")
loadAddonFile("Features/Macros/Water-and-Potion.lua")
loadAddonFile("Features/Macros/Runtime.lua")

--------------------------------------------------------------------------------

local failures = 0

local function check(label, got, want)
	if got == want then
		say(("  ok    %s = %s"):format(label, tostring(got)))
	else
		failures = failures + 1
		say(("  FAIL  %s: got %s, want %s"):format(label, tostring(got), tostring(want)))
	end
end

local function definition(typeName)
	for _, registered in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
		if registered.typeName == typeName then
			return registered
		end
	end
	error("not registered: " .. typeName)
end

--[[
    A scan result in the shape ns.ScanBags returns: ranked entries carry topIDs,
    empty when the category has no winner; Food and Water carry only an id.
]]
local function scan(spec)
	local best = {}
	for typeName, ids in pairs(spec) do
		if typeName == "Food" or typeName == "Water" then
			best[typeName] = { id = ids[1] }
		else
			best[typeName] = { id = ids[1], topIDs = ids }
		end
	end
	return best
end

local function build(typeName, best)
	return definition(typeName).buildModeOverride({ best = best })
end

local function lines(...)
	return table.concat({ ... }, "\n")
end

-- Clears the chat sink, fires the wrong-zone error, and returns the item id the bug report names.
local function zoneErrorBlames()
	printed = {}
	ns.OnMacroUiErrorMessage(ERR_ITEM_WRONG_ZONE)
	return printed[1] and printed[1]:match("^BUG:item(%d+):") or nil
end

--------------------------------------------------------------------------------

say("FOOD & POTION")

local full = scan({
	["Food"] = { 8932 },
	["Health Potion"] = { 13446, 3928, 1710 },
	["Healthstone"] = { 9421, 5510 },
})

say("1. Potions in combat, food out of it")
local body, keyPlain = build("Food & Potion", full)
check(
	"body",
	body,
	lines(
		"#showtooltip",
		'/run ConnoisseurFireIf("[combat]",13446,8932)',
		"/use [combat] item:13446",
		"/use [combat] item:3928",
		"/use [combat] item:1710",
		"/use [nocombat] item:8932"
	)
)

say("2. Combine Healthstones stacks the stones below the potions")
ns.db.profile.combineHealthstones = true
local keyCombined
body, keyCombined = build("Food & Potion", full)
check(
	"body",
	body,
	lines(
		"#showtooltip",
		'/run ConnoisseurFireIf("[combat]",13446,8932)',
		"/use [combat] item:13446",
		"/use [combat] item:3928",
		"/use [combat] item:1710",
		"/use [combat] item:9421",
		"/use [combat] item:5510",
		"/use [nocombat] item:8932"
	)
)
check("key moves", keyPlain ~= keyCombined, true)

say("3. With no potion, the stones are the whole combat half")
body = build("Food & Potion", scan({ ["Food"] = { 8932 }, ["Health Potion"] = {}, ["Healthstone"] = { 9421 } }))
check(
	"body",
	body,
	lines(
		"#showtooltip",
		'/run ConnoisseurFireIf("[combat]",9421,8932)',
		"/use [combat] item:9421",
		"/use [nocombat] item:8932"
	)
)

say("4. No potion and Combine Healthstones off: the combat half names the missing potion")
ns.db.profile.combineHealthstones = false
body = build("Food & Potion", scan({ ["Food"] = { 8932 }, ["Health Potion"] = {}, ["Healthstone"] = { 9421 } }))
check(
	"body",
	body,
	lines(
		"#showtooltip",
		"/run ConnoisseurFire(8932)",
		'/run ConnoisseurNoItemIf("[combat]","Health Potion")',
		"/use [nocombat] item:8932"
	)
)

say("5. No food: the rest half names the missing food")
body = build("Food & Potion", scan({ ["Food"] = {}, ["Health Potion"] = { 13446 }, ["Healthstone"] = {} }))
check(
	"body",
	body,
	lines(
		"#showtooltip",
		"/run ConnoisseurFire(13446)",
		"/use [combat] item:13446",
		'/run ConnoisseurNoItemIf("[nocombat]","Food")'
	)
)

say("6. Nothing in bags: both halves name their item and the icon falls back to the default")
body = build("Food & Potion", scan({ ["Food"] = {}, ["Health Potion"] = {}, ["Healthstone"] = {} }))
check(
	"body",
	body,
	lines(
		"#showtooltip item:5349",
		'/run ConnoisseurNoItemIf("[combat]","Health Potion")',
		'/run ConnoisseurNoItemIf("[nocombat]","Food")'
	)
)

say("7. The state key moves with the food and the potion, under its own prefix")
local _, keyA = build("Food & Potion", scan({ ["Food"] = { 8932 }, ["Health Potion"] = { 13446 }, ["Healthstone"] = {} }))
local _, keyB = build("Food & Potion", scan({ ["Food"] = { 4599 }, ["Health Potion"] = { 13446 }, ["Healthstone"] = {} }))
local _, keyC = build("Food & Potion", scan({ ["Food"] = { 8932 }, ["Health Potion"] = { 3928 }, ["Healthstone"] = {} }))
check("food moves it", keyA ~= keyB, true)
check("potion moves it", keyA ~= keyC, true)
check("prefix", keyA:sub(1, 6), "COMBO:")

say("")
say("WATER & POTION")

say("8. Mana potions in combat, water out of it, and no Mana Gem line")
body = build("Water & Potion", scan({ ["Water"] = { 8766 }, ["Mana Potion"] = { 13444, 6149 }, ["Mana Gem"] = { 8008, 8007 } }))
check(
	"body",
	body,
	lines(
		"#showtooltip",
		'/run ConnoisseurFireIf("[combat]",13444,8766)',
		"/use [combat] item:13444",
		"/use [combat] item:6149",
		"/use [nocombat] item:8766"
	)
)

say("9. Nothing in bags: both halves name their item and the icon falls back to the default")
body = build("Water & Potion", scan({ ["Water"] = {}, ["Mana Potion"] = {}, ["Mana Gem"] = {} }))
check(
	"body",
	body,
	lines(
		"#showtooltip item:5350",
		'/run ConnoisseurNoItemIf("[combat]","Mana Potion")',
		'/run ConnoisseurNoItemIf("[nocombat]","Water")'
	)
)

say("")
say("THE 255 TRIM")

ns.db.profile.combineHealthstones = true

-- Ids long enough that three potions, three stones and the rest line overflow.
local P1, P2, P3 = 111111111, 222222222, 333333333
local S1, S2, S3 = 444444444, 555555555, 666666666
local F = 777777777

say("10. An overflowing body sheds the last stone first and keeps the rest")
body = build("Food & Potion", scan({ ["Food"] = { F }, ["Health Potion"] = { P1, P2, P3 }, ["Healthstone"] = { S1, S2, S3 } }))
check("fits", #body <= 255, true)
check("last stone dropped", body:find(tostring(S3), 1, true), nil)
check("first stone kept", body:find(tostring(S1), 1, true) ~= nil, true)
check("last potion kept", body:find(tostring(P3), 1, true) ~= nil, true)
check("rest line kept", body:find("/use [nocombat] item:" .. F, 1, true) ~= nil, true)

-- Ids so long that only one combat line can fit.
local huge = ("9"):rep(60)

say("11. The first combat line is never dropped")
body = build("Food & Potion", scan({ ["Food"] = { huge }, ["Health Potion"] = { huge, huge }, ["Healthstone"] = { huge } }))
local _, useCount = body:gsub("/use %[combat%]", "")
check("combat lines", useCount, 1)

ns.db.profile.combineHealthstones = false

say("")
say("AT PRESS TIME")

say("12. ConnoisseurFireIf stamps the alternative item out of combat")
inCombat = false
ConnoisseurFireIf("[combat]", 13446, 8932)
check("blamed item", zoneErrorBlames(), "8932")

say("13. ConnoisseurFireIf stamps the matching item in combat")
inCombat = true
ConnoisseurFireIf("[combat]", 13446, 8932)
check("blamed item", zoneErrorBlames(), "13446")

say("14. ConnoisseurFire stamps its one item")
inCombat = false
ConnoisseurFire(13446)
check("blamed item", zoneErrorBlames(), "13446")

say("15. ConnoisseurNoItemIf prints only when its conditional holds")
printed = {}
inCombat = false
ConnoisseurNoItemIf("[combat]", "Health Potion")
check("quiet", #printed, 0)
ConnoisseurNoItemIf("[nocombat]", "Food")
check("printed", printed[1], "NO:Food")

say("")
if failures == 0 then
	say("ALL COMBO MACRO SCENARIOS PASSED")
else
	say(failures .. " COMBO MACRO SCENARIOS FAILED")
	os.exit(1)
end
