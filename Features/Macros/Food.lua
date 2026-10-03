local _, ns = ...

--------------------------------------------------------------------------------
-- Food Macro
--------------------------------------------------------------------------------

--[[
    The busiest macro definition: plain food by default, buff food when the
    live ns.allowBuffFood preference allows it (the scanner computes that
    flag from setting/mode/Well Fed/arena state; the selection fields below
    declare how it applies), a pet-buff-food override when the Hunter
    feature wants the pet fed, and a full-body scroll-only mode when scroll
    buffs are missing.
]]

--[[
    Pet buff override flag — set by modifyItem, read by appendBlock and
    buildUseLine later in the same update iteration (the engine always calls
    modifyItem first). The override replaces the Food slot item with pet food.
    It never shares a body with scrolls: scroll-only mode replaces the whole
    body, pet line included, until the scrolls are applied.
]]
local petBuffOverride = false

--[[
    When the player has missing scroll buffs and is not targeting a friendly
    player, the Food macro becomes a dedicated scroll-fire macro. The body
    is just `#showtooltip` plus one /use [@player] item:NNN line per scroll
    in ns.SCROLL_CHECK_ORDER priority. No food, no conjure, no state-write —
    the user taps once to apply scrolls; the next tap (with all scrolls
    applied) sees the macro flip back to its normal food form.

    Bare `#showtooltip` lets the action bar resolve the icon from the first
    usable line — the first scroll — which is exactly what the user should
    see when the button is about to fire scrolls.

    All scrolls fit comfortably under the 255 macro ceiling: 14 bytes for
    the tooltip line + at most 6 scrolls × ~25 bytes ≈ 164 bytes. The lines are
    pure ASCII (no localized names), so the count cannot grow in another locale.
]]
local function BuildScrollOnlyBody(scrollList)
	local lines = { "#showtooltip" }
	for _, scrollID in ipairs(scrollList) do
		lines[#lines + 1] = "/use [@player] item:" .. scrollID
	end
	return table.concat(lines, "\n") .. "\n"
end

ns.RegisterMacroType({
	typeName = "Food",

	--[[
	    Selection: any food competes, including the food half of a foodwater
	    hybrid (which also feeds Water), by raw food value. Buff food only
	    competes while the scanner's live ns.allowBuffFood preference is on
	    (setting + mode + not Well Fed + not self-targeting + not arena),
	    and the allowBuffFood flag additionally makes the ladder prefer buff
	    food outright when it is. While Use Conjured Food & Water First holds
	    (ns.allowConjuredFirst), conjured food comes next, ahead of anything
	    that restores more. While Use Restock List Food & Water Last holds
	    (ns.allowRestockLast), food off the Restock List beats an equal one
	    on it. Hybrids beat dedicated food on ties — one bag
	    slot covering both needs. The winner record carries the item link,
	    which the scanner publishes as ns.bestFoodLink for the mini-map
	    tooltip.
	]]
	itemTypes = { food = true, foodwater = true },
	accepts = function(data)
		return not (data.isBuffFood and not ns.allowBuffFood)
	end,
	score = function(data)
		return data.healthValue
	end,
	allowBuffFood = true,
	allowConjuredFirst = true,
	allowRestockLast = true,
	preferHybrid = true,
	--[[
	    Only the link: every field the ladder compares is filled by the
	    scanner's FillRecord, for this category and all the others.
	]]
	winnerExtras = function(winner, _, hyperlink)
		winner.link = hyperlink
	end,

	--[[
	    Mage conjure: shared Water/Food resolution (Refreshment Table on
	    middle-click) lives in Tools-Mages.lua; called at update time.
	]]
	conjure = function()
		return ns.ResolveMageWaterOrFoodConjure(ns.CONJURE_SPELLS.MageCreateFood, "noConjureFood")
	end,

	modifyItem = function(itemID)
		petBuffOverride = false
		if ns.petBuffOverrideID then
			petBuffOverride = true
			return ns.petBuffOverrideID
		end
		return itemID
	end,

	-- Pet food buffs target the pet.
	buildUseLine = function(itemID)
		if petBuffOverride then
			return "/use [@pet] item:" .. itemID
		end
		return nil
	end,

	--[[
	    Scroll mode. The "SCROLLS:" state-key prefix can never collide with
	    the standard ITEMID-prefixed key, which guarantees a rewrite happens
	    at every transition into and out of scroll mode (target-change,
	    scroll-applied, bag scan removing the last scroll item, etc).
	]]
	buildModeOverride = function(context)
		local scrollIDs = context.activeScrollIDs
		if not scrollIDs or #scrollIDs == 0 then
			return nil
		end
		return BuildScrollOnlyBody(scrollIDs), "SCROLLS:" .. table.concat(scrollIDs, ",")
	end,

	--[[
	    Stealth Eating: appends a stealth cast below the food line -- Stealth
	    for Rogues, Shadowmeld for other Night Elves -- so the player stealths
	    while eating. The "SE" flag keeps the append in the state key so
	    toggling the option rewrites the macro. Only a body the player eats
	    from carries it: with no food the press would stealth for nothing, and
	    the pet-buff override feeds the pet rather than the player. Scroll-only
	    mode bypasses this too (mode overrides never reach appendBlock), which
	    is correct: a scroll tap is not a meal.
	]]
	appendBlock = function(itemID)
		if not itemID or petBuffOverride then
			return nil
		end
		local settings = ns.db and ns.db.profile
		if not settings or not settings.enableStealthEating then
			return nil
		end
		if ns.isRogue and ns.stealthSpellName then
			return "\n/cast [nostealth] " .. ns.stealthSpellName, "SE"
		end
		if ns.isNightElf and ns.shadowmeldSpellName then
			return "\n/cast [nostealth] " .. ns.shadowmeldSpellName, "SE"
		end
		return nil
	end,
})
