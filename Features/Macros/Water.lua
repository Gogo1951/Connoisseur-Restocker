local _, ns = ...

--------------------------------------------------------------------------------
-- Water Macro
--------------------------------------------------------------------------------

--[[
    Stealth Drinking's spell and state flag, or nil while the option is off.
    Night Elves only -- and not Night Elf Rogues: their options section is the
    Rogues one (which has no Stealth Drinking toggle), so this must never fire
    off a stale enableShadowmeldDrinking value.
]]
local function ShadowmeldDrinkingSpell()
	if not ns.isNightElf or ns.isRogue then
		return nil
	end
	local settings = ns.db and ns.db.profile
	if not settings or not settings.enableShadowmeldDrinking then
		return nil
	end
	if not ns.shadowmeldSpellName then
		return nil
	end
	return ns.shadowmeldSpellName, "SM"
end

ns.RegisterMacroType({
	typeName = "Water",

	--[[
	    Selection: any drink competes, including the water half of a
	    foodwater hybrid (which also feeds Food), by raw mana value. The
	    buff-food gate matches Food's — a buff drink only competes while
	    ns.allowBuffFood is on — and so does conjured-first: while
	    ns.allowConjuredFirst holds, a conjured drink beats anything but a
	    buff drink. Unlike Food, ties prefer the DEDICATED drink
	    (preferHybrid = false): the hybrid is better saved for the Food
	    slot, and Water never stores a link (nothing reads one).
	]]
	itemTypes = { water = true, foodwater = true },
	accepts = function(data)
		return not (data.isBuffFood and not ns.allowBuffFood)
	end,
	score = function(data)
		return data.manaValue
	end,
	allowBuffFood = true,
	allowConjuredFirst = true,
	preferHybrid = false,
	--[[
	    Mage conjure: shared Water/Food resolution (Refreshment Table on
	    middle-click) lives in Tools-Mages.lua; called at update time.
	]]
	conjure = function()
		return ns.ResolveMageWaterOrFoodConjure(ns.CONJURE_SPELLS.MageCreateWater, "noConjureWater")
	end,

	--[[
	    Night Elf Shadowmeld drinking: appends a stealth cast below the drink
	    line so the player melds while drinking. The "SM" flag keeps the
	    append in the state key so toggling the option rewrites the macro.
	    Only a body with a drink carries it: with nothing to drink the press
	    would meld for nothing.
	]]
	appendBlock = function(itemID)
		if not itemID then
			return nil
		end
		local spellName, flag = ShadowmeldDrinkingSpell()
		if spellName then
			return "\n/cast [nostealth] " .. spellName, flag
		end
		return nil
	end,

	--[[
	    The Mana Potion macro drinks this macro's pick out of combat
	    (outOfCombatTypeName), and melds the same way while it does.
	]]
	stealthSpell = ShadowmeldDrinkingSpell,
})
