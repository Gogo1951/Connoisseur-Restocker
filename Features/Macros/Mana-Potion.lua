local _, ns = ...

--------------------------------------------------------------------------------
-- Mana Potion Macro
--------------------------------------------------------------------------------

-- Multi-use ranked macro (ns.MULTI_USE_MACRO_TYPES).
ns.RegisterMacroType({
	typeName = "Mana Potion",

	--[[
	    Selection: every potion with a mana value competes (a hybrid potion
	    also feeds Health Potion), ranked by raw mana — then by the ladder's
	    burn-first steps — into topIDs for the stacked /use fallback lines.
	]]
	itemTypes = { potion = true },
	accepts = function(data)
		return data.manaValue > 0
	end,
	score = function(data)
		return data.manaValue
	end,
	ranked = true,

	-- Behind potionsUseFoodAndWater, the macro drinks the Water macro's pick while out of combat.
	outOfCombatTypeName = "Water",
})
