local _, ns = ...

--------------------------------------------------------------------------------
-- Health Potion Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Health Potion",

	--[[
	    Selection: every potion with a heal value competes (a hybrid potion
	    also feeds Mana Potion), ranked by raw heal — then by the ladder's
	    burn-first steps — into topIDs for the stacked /use fallback lines.
	]]
	itemTypes = { potion = true },
	accepts = function(data)
		return data.healthValue > 0
	end,
	score = function(data)
		return data.healthValue
	end,
	ranked = true,

	-- Behind potionsUseFoodAndWater, the macro eats the Food macro's pick while out of combat.
	outOfCombatTypeName = "Food",

	--[[
	    Healthstone stacking: when the player opts in, the Health Potion
	    macro gets the best Healthstone's ranked /use lines appended below
	    the potion lines — potions and healthstones live in separate cooldown
	    categories, so one press fires one of each. The Healthstone topIDs
	    come straight from the scan and are populated regardless of whether
	    the standalone Healthstone macro is enabled. With no potion to stack
	    onto, the engine makes these lines the whole body; with one, it sheds
	    them first in the macro-length trim.
	]]
	stackTypeName = "Healthstone",
	getStackIDs = function(best)
		local settings = ns.db and ns.db.profile
		if not (settings and settings.combineHealthstones) then
			return nil
		end
		local healthstoneEntry = best["Healthstone"]
		if healthstoneEntry and healthstoneEntry.topIDs and #healthstoneEntry.topIDs > 0 then
			return healthstoneEntry.topIDs
		end
		return nil
	end,
})
