-- luacheck: allow defined, ignore 121 122 131 143
--[[
    Headless test for the Inventory Report (no WoW client needed).

    Run it with:   lua Features/Tests/Inventory-Report-Test.lua        (from the add-on root)

    Like the other headless tests, this does NOT model the feature: every scenario
    loads the REAL Features/Inventory-Report.lua behind the thinnest stubs that
    hold it up -- containers the client would read, the two tooltips, and the
    tooltip pipeline of whichever client the scenario plays: Era and TBC's
    OnTooltipSetItem, or Forever's TooltipDataProcessor post-call.

    WHAT IS PINNED HERE.

    The block's exact shape, as the maintainer specified it: the branded header,
    then label-and-count pairs -- Bags (against the Restock List's Keep amount
    when the item is on it), Bank, one line per other character holding the item
    (class-colored, alphabetical, on this realm only, bags and bank as one
    number), and Total last, with a spacer either side of the characters. Every
    row under the header is led by one space, as Water Dispenser pads its own.

    What it must NOT say: nothing at all for an item nobody holds that is not on
    the list, no second block when Era fires OnTooltipSetItem twice for one item,
    nothing with the report switched off, and no bank count before the bank has
    been seen (a 0 there would be a claim the add-on cannot back; it reads
    Unknown, muted).

    WHERE it sits: the hooks go in a few seconds after login, so the block lands
    under the lines of add-ons that hooked at load or at login.

    And the recording half: a logout packs this character's bags and bank into
    one sorted "itemID:count" line each, and the next character reads them back.
    The bags packed are the ones last read while the character was playing,
    never a read made at the logout, where the client no longer answers. A
    Forever character is recorded, and listed, under its first name and
    surname.
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

-- Text with its color codes stripped, so an assertion reads like the tooltip does.
local function plain(text)
	return (text:gsub("<%u+>", ""):gsub("|cff%x%x%x%x%x%x", ""):gsub("|r", ""))
end

-- One tooltip line as "left | right", or just the left of a plain line.
local function plainLine(line)
	if not line then
		return nil
	end
	if line.right then
		return plain(line.left) .. " | " .. plain(line.right)
	end
	return plain(line.left)
end

local function plainLines(lines)
	local out = {}
	for index, line in ipairs(lines or {}) do
		out[index] = plainLine(line)
	end
	return table.concat(out, " / ")
end

--------------------------------------------------------------------------------
-- Stubs
--------------------------------------------------------------------------------

-- The keys the report reads carry their real English; any other key reads as itself.
local STRINGS = {
	ADDON_TITLE = "Connoisseur",
	TAB_RESTOCKER = "Restocker",
	INVENTORY_REPORT_BRAND = "%s & %s",
	INVENTORY_REPORT_TITLE = "Inventory Report",
	INVENTORY_REPORT_BAGS = "Bags",
	INVENTORY_REPORT_BANK = "Bank",
	INVENTORY_REPORT_BANK_UNKNOWN = "Unknown",
	INVENTORY_REPORT_TOTAL = "Total",
	MINIMAP_RESTOCKER_ITEM_COUNT = "%d/%d",
}

local function NewTooltip(name)
	local tooltip = { name = name, lines = {}, scripts = {} }
	function tooltip:HookScript(script, handler)
		self.scripts[script] = self.scripts[script] or {}
		table.insert(self.scripts[script], handler)
	end
	function tooltip:AddLine(text)
		self.lines[#self.lines + 1] = { left = text }
	end
	function tooltip:AddDoubleLine(left, right)
		self.lines[#self.lines + 1] = { left = left, right = right }
	end
	function tooltip:GetItem()
		return nil, self.link
	end
	function tooltip:IsForbidden()
		return false
	end
	function tooltip:Run(script)
		for _, handler in ipairs(self.scripts[script] or {}) do
			handler(self)
		end
	end
	return tooltip
end

--[[
    One logged-in character. opts: name, surname (a Forever character's, which
    the client gives apart from the name), realm, class, forever (plays Forever's
    tooltip pipeline and bank tabs), enabled (the Restocker panel switch), list
    (the current Restock List's rows), inventory (the saved snapshots, shared
    between sessions to play a relog), early (leave the login delay unelapsed,
    so the hooks are not installed yet).
]]
local function session(opts)
	opts = opts or {}
	local name = opts.name or "Mossbark"
	local fullName = opts.surname and (name .. " " .. opts.surname) or name
	local realm = opts.realm or "Mankrik"
	local containers = {}
	local timers = {}
	local postCalls = {}
	-- Whether the client answers for the containers (not once the character has left the world), and whether it is fighting.
	local inWorld, inCombat = true, false

	BACKPACK_CONTAINER = 0
	NUM_BAG_SLOTS = 4
	BANK_CONTAINER = (not opts.forever) and -1 or nil
	C_Container = {
		-- The backpack keeps its 16 slots however little is in it; any other container is as big as what it holds.
		GetContainerNumSlots = function(bagID)
			if not inWorld then
				return 0
			end
			local held = containers[bagID] and #containers[bagID] or 0
			return bagID == BACKPACK_CONTAINER and math.max(16, held) or held
		end,
		GetContainerItemInfo = function(bagID, slot)
			local item = inWorld and containers[bagID] and containers[bagID][slot]
			if item then
				return { itemID = item[1], stackCount = item[2] }
			end
		end,
	}
	function InCombatLockdown()
		return inCombat
	end
	C_Item = {
		GetItemCount = function(itemID, includeBank)
			assert(includeBank == false, "the report reads live bag counts only")
			local count = 0
			for bagID = 0, NUM_BAG_SLOTS do
				for _, item in ipairs(containers[bagID] or {}) do
					if item[1] == itemID then
						count = count + item[2]
					end
				end
			end
			return count
		end,
	}
	C_Timer = {
		After = function(delay, callback)
			timers[#timers + 1] = { delay = delay, callback = callback }
		end,
	}
	UnitName = function()
		return name
	end
	UnitClass = function()
		return "Class", opts.class or "DRUID"
	end
	GetRealmName = function()
		return realm
	end
	format = string.format
	Enum = { TooltipDataType = { Item = 0 } }
	GameTooltip = NewTooltip("GameTooltip")
	ItemRefTooltip = NewTooltip("ItemRefTooltip")
	if opts.forever then
		TooltipDataProcessor = {
			AddTooltipPostCall = function(kind, callback)
				assert(kind == Enum.TooltipDataType.Item, "only item tooltips are hooked")
				postCalls[#postCalls + 1] = callback
			end,
		}
	else
		TooltipDataProcessor = nil
	end

	local ns = {
		L = setmetatable({}, {
			__index = function(_, key)
				return STRINGS[key] or key
			end,
		}),
		GetColor = function(key)
			return "<" .. key .. ">"
		end,
		-- Utilities' class color accessor, over the three classes these characters are.
		GetClassColor = function(classToken)
			local hex = ({ DRUID = "FF7C0A", HUNTER = "AAD372", MAGE = "3FC7EB" })[classToken]
			return hex and ("|cff" .. hex) or nil
		end,
		IsSecretValue = function()
			return false
		end,
		FetchPurchasedBankTabIDs = function()
			return opts.forever and { 6, 7 } or nil
		end,
		-- The whole name: a Forever character's surname rides on opts.surname.
		GetPlayerFullName = function()
			return fullName
		end,
		GetCharacterKey = function()
			return fullName .. "-" .. realm
		end,
		db = { global = { inventoryReport = opts.enabled ~= false, inventory = opts.inventory or {} } },
		restockSettings = { currentList = "Druid (2)", lists = { ["Druid (2)"] = opts.list or {} } },
	}

	assert(loadfile(ROOT .. "/Features/Inventory-Report.lua"))("Consumable-Connoisseur", ns)
	ns.InitializeInventoryReport()

	local s = { ns = ns, containers = containers }

	-- Let every pending timer fire: the login delay, and the bank's settle look.
	function s.settle()
		local pending = timers
		timers = {}
		for _, timer in ipairs(pending) do
			timer.callback()
		end
	end

	function s.pendingDelay()
		return timers[1] and timers[1].delay
	end

	function s.put(bagID, slots)
		containers[bagID] = slots
	end

	function s.fire(event)
		ns.inventoryEventHandlers[event]()
	end

	-- Fill a bag the way the client reports it: the contents land, then BAG_UPDATE_DELAYED says so.
	function s.loot(bagID, slots)
		containers[bagID] = slots
		s.fire("BAG_UPDATE_DELAYED")
	end

	-- A real logout: the character leaves the world, after which the containers read as nothing, then PLAYER_LOGOUT.
	function s.logout()
		inWorld = false
		s.fire("PLAYER_LOGOUT")
	end

	function s.combat(fighting)
		inCombat = fighting
		if not fighting then
			s.fire("PLAYER_REGEN_ENABLED")
		end
	end

	-- Show an item the way the client would: clear the tooltip, then set the item.
	function s.hover(itemID, tooltip)
		tooltip = tooltip or GameTooltip
		tooltip:Run("OnTooltipCleared")
		tooltip.lines = {}
		if opts.forever then
			for _, callback in ipairs(postCalls) do
				callback(tooltip, { id = itemID })
			end
		else
			tooltip.link = "|cffffffff|Hitem:" .. itemID .. "::::::::60:::::|h[Item]|h|r"
			tooltip:Run("OnTooltipSetItem")
		end
		return tooltip.lines
	end

	-- Era firing OnTooltipSetItem a second time for what is already shown, with no clear between.
	function s.again(tooltip)
		tooltip = tooltip or GameTooltip
		tooltip:Run("OnTooltipSetItem")
		return tooltip.lines
	end

	if not opts.early then
		s.settle()
	end
	return s
end

--------------------------------------------------------------------------------
-- Scenarios
--------------------------------------------------------------------------------

local DEW = 8766 -- Morning Glory Dew
local PIE = 8950 -- Homemade Cherry Pie
local HEARTHSTONE = 6948

-- The realm's other characters, as their logouts left them.
local function realmInventory()
	return {
		["Mossbark-Mankrik"] = { name = "Mossbark", realm = "Mankrik", class = "DRUID", bank = "8766:18" },
		["Thornhoof-Mankrik"] = {
			name = "Thornhoof",
			realm = "Mankrik",
			class = "DRUID",
			bags = "8766:7",
			bank = "8766:20",
		},
		["Coinpurse-Mankrik"] = { name = "Coinpurse", realm = "Mankrik", class = "MAGE", bags = "", bank = "8766:30" },
		-- No bank snapshot yet: its bags still count.
		["Aardvark-Mankrik"] = { name = "Aardvark", realm = "Mankrik", class = "HUNTER", bags = "8766:2" },
		-- Holds none of it: no line.
		["Quickshot-Mankrik"] = { name = "Quickshot", realm = "Mankrik", class = "HUNTER", bags = "8950:5", bank = "" },
		-- Another realm: never listed, never counted.
		["Zed-Faerlina"] = {
			name = "Zed",
			realm = "Faerlina",
			class = "MAGE",
			bags = "4242:3 8766:99",
			bank = "8766:99",
		},
	}
end

print("1. The block's shape: header, Bags against Keep, Bank, the realm's holders A to Z, then Total")
local s = session({ inventory = realmInventory(), list = { [DEW] = { itemID = DEW, amount = 10 } } })
s.put(0, { { DEW, 5 }, { HEARTHSTONE, 1 } })
s.put(1, { { DEW, 2 } })
local lines = s.hover(DEW)
check(
	"the exact lines, in order",
	plainLines(lines),
	table.concat({
		" ",
		"Connoisseur & Restocker // Inventory Report",
		" Bags | 7/10",
		" Bank | 18",
		" ",
		" Aardvark | 2",
		" Coinpurse | 30",
		" Thornhoof | 27",
		" ",
		" Total | 84",
	}, " / ")
)
check(
	"the header wears the chat prints' branded colors",
	lines[2].left,
	"<INFO>Connoisseur & Restocker|r <SEPARATOR>//|r <TEXT>Inventory Report|r"
)
check("the header is one plain line", lines[2].right, nil)
check("and sits flush, with every row under it one space in", lines[3].left, " <TEXT>Bags|r")
check("a hunter's name wears the hunter color", lines[6].left, " |cffAAD372Aardvark|r")
check("a mage's name wears the mage color", lines[7].left, " |cff3FC7EBCoinpurse|r")
check("a druid's name wears the druid color", lines[8].left, " |cffFF7C0AThornhoof|r")
check("a character's count is white", lines[8].right, "<TEXT>27|r")

print("2. Off the list, Bags is a plain count; a list row keeping 0 has no target either")
s = session({ inventory = realmInventory(), list = { [PIE] = { itemID = PIE, amount = 0 } } })
s.put(0, { { DEW, 7 } })
check("no Keep, no slash", plainLine(s.hover(DEW)[3]), " Bags | 7")
s.put(0, { { PIE, 3 } })
check("Keep 0 (bank all of it) shows no slash", plainLine(s.hover(PIE)[3]), " Bags | 3")

print("3. Silence: nothing for an item nobody on the realm holds and the list does not name")
s = session({ inventory = realmInventory() })
check("no lines at all", #s.hover(12345), 0)
check("an item only another realm's character holds says nothing", #s.hover(4242), 0)

print("4. An item on the list reports even when this character holds none")
s = session({ inventory = realmInventory(), list = { [PIE] = { itemID = PIE, amount = 20 } } })
check(
	"0/20, a counted bank's 0, Quickshot's 5, and the total",
	plainLines(s.hover(PIE)),
	table.concat({
		" ",
		"Connoisseur & Restocker // Inventory Report",
		" Bags | 0/20",
		" Bank | 0",
		" ",
		" Quickshot | 5",
		" ",
		" Total | 5",
	}, " / ")
)

print("5. With nobody else holding it, one spacer sits between the bank and the total")
s = session({ name = "Newbie" })
s.put(0, { { DEW, 4 } })
lines = s.hover(DEW)
check(
	"header, Bags, Bank, spacer, Total",
	plainLines(lines),
	table.concat({
		" ",
		"Connoisseur & Restocker // Inventory Report",
		" Bags | 4",
		" Bank | Unknown",
		" ",
		" Total | 4",
	}, " / ")
)
check("a bank never seen reads Unknown, muted", lines[4].right, "<MUTED>Unknown|r")

print("6. The bank is counted while it is open, and only then")
s.put(-1, { { DEW, 11 }, { PIE, 2 } })
s.put(5, { { DEW, 9 } })
s.fire("BANKFRAME_OPENED")
check("the open bank is counted, main slots and bags", plainLine(s.hover(DEW)[4]), " Bank | 20")
check("and the total follows", plainLine(s.hover(DEW)[6]), " Total | 24")
s.put(-1, { { DEW, 1 } })
s.fire("BAG_UPDATE_DELAYED")
check("a bag update at the bank rescans it", plainLine(s.hover(DEW)[4]), " Bank | 10")
s.fire("BANKFRAME_CLOSED")
s.put(-1, {})
s.put(5, {})
s.fire("BAG_UPDATE_DELAYED")
check("away from it, the last scan stands", plainLine(s.hover(DEW)[4]), " Bank | 10")

print("7. Logout packs one sorted line per place, and the next character reads it back")
local shared = {}
s = session({ name = "Mossbark", inventory = shared })
s.loot(0, { { DEW, 7 }, { HEARTHSTONE, 1 } })
s.loot(2, { { DEW, 3 } })
s.put(-1, { { PIE, 40 } })
s.fire("BANKFRAME_OPENED")
s.fire("BANKFRAME_CLOSED")
s.logout()
check("bags packed in itemID order", shared["Mossbark-Mankrik"].bags, "6948:1 8766:10")
check("bank packed", shared["Mossbark-Mankrik"].bank, "8950:40")
check("class recorded", shared["Mossbark-Mankrik"].class, "DRUID")
local alt = session({ name = "Thornhoof", inventory = shared })
check("the alt sees the druid's pie, bags and bank as one number", plainLine(alt.hover(PIE)[6]), " Mossbark | 40")

print("8. A bank never opened is not written as empty")
shared = {}
s = session({ name = "Fresh", inventory = shared })
s.loot(0, { { DEW, 1 } })
s.logout()
check("bags written", shared["Fresh-Mankrik"].bags, "8766:1")
check("bank left unknown", shared["Fresh-Mankrik"].bank, nil)

print("9. The Restocker panel's switch silences it")
s = session({ inventory = realmInventory(), enabled = false })
s.put(0, { { DEW, 7 } })
check("no lines", #s.hover(DEW), 0)
s.ns.db.global.inventoryReport = true
check("back on, with no reload", #s.hover(DEW) > 0, true)

print("10. One block per showing, however often Era fires OnTooltipSetItem")
s = session({ inventory = realmInventory() })
s.put(0, { { DEW, 7 } })
local first = #s.hover(DEW)
check("a second fire adds nothing", #s.again(), first)
check("a fresh showing reports again", #s.hover(DEW), first)
check("the clicked-link tooltip reports too", #s.hover(DEW, ItemRefTooltip), first)

print("11. Forever: the post-call, the bank's tabs, and only the two tooltips")
s = session({ forever = true, inventory = realmInventory() })
s.put(0, { { DEW, 7 } })
s.put(6, { { DEW, 4 } })
s.put(7, { { DEW, 5 } })
s.fire("BANKFRAME_OPENED")
check("the purchased tabs are the bank", plainLine(s.hover(DEW)[4]), " Bank | 9")
local comparison = NewTooltip("ShoppingTooltip1")
check("a comparison tooltip gets nothing", #s.hover(DEW, comparison), 0)
check(
	"the Forever post-call path adds one block",
	plainLine(s.hover(DEW)[2]),
	"Connoisseur & Restocker // Inventory Report"
)

print("12. The bank's late arrivals are caught by the settle look")
s = session({ name = "Latecomer" })
s.fire("BANKFRAME_OPENED")
s.put(-1, { { PIE, 6 } })
s.settle()
check("counted after the settle delay", plainLine(s.hover(PIE)[4]), " Bank | 6")

print("13. The hooks go in after the login delay, so the block lands under other add-ons' lines")
s = session({ inventory = realmInventory(), early = true })
s.put(0, { { DEW, 7 } })
check("nothing is hooked at login itself", #s.hover(DEW), 0)
check("the hook waits on a timer of several seconds", (s.pendingDelay() or 0) >= 3, true)
s.settle()
check(
	"once it has passed, the report is there",
	plainLine(s.hover(DEW)[2]),
	"Connoisseur & Restocker // Inventory Report"
)

print("14. A Forever character is recorded, and listed, under its first name and surname")
shared = {}
s = session({ name = "Gogodruid", surname = "Forever", forever = true, inventory = shared })
s.loot(0, { { DEW, 6 } })
s.logout()
check("keyed by the whole name", shared["Gogodruid Forever-Mankrik"] ~= nil, true)
check("and named by it", shared["Gogodruid Forever-Mankrik"].name, "Gogodruid Forever")
alt = session({ name = "Gogohunter", surname = "Classic", class = "HUNTER", forever = true, inventory = shared })
check("which is how an alt lists it", plainLine(alt.hover(DEW)[6]), " Gogodruid Forever | 6")

print("15. The bags saved are the ones last read while playing, never a read made at logout")
shared = {}
s = session({ name = "Mossbark", inventory = shared })
s.put(0, { { DEW, 7 }, { HEARTHSTONE, 1 } })
s.fire("PLAYER_ENTERING_WORLD")
s.logout()
check("bags that never changed are read on arriving in the world", shared["Mossbark-Mankrik"].bags, "6948:1 8766:7")
s = session({ name = "Mossbark", inventory = shared })
s.logout()
check("a session that never read its bags keeps the last snapshot", shared["Mossbark-Mankrik"].bags, "6948:1 8766:7")
s = session({ name = "Mossbark", inventory = shared })
s.loot(0, { { DEW, 7 }, { HEARTHSTONE, 1 } })
s.combat(true)
s.loot(0, { { DEW, 5 }, { HEARTHSTONE, 1 } })
s.combat(false)
s.logout()
check("a change made mid-fight is read when the fight ends", shared["Mossbark-Mankrik"].bags, "6948:1 8766:5")
s = session({ name = "Mossbark", inventory = shared })
s.loot(0, {})
s.logout()
check("bags emptied while playing are saved as empty", shared["Mossbark-Mankrik"].bags, "")

print("")
if failures == 0 then
	print("ALL INVENTORY REPORT SCENARIOS PASSED")
else
	print(("%d INVENTORY REPORT CHECK(S) FAILED"):format(failures))
	os.exit(1)
end
