local _, ns = ...

--------------------------------------------------------------------------------
-- Water & Potion Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Water & Potion",

	--[[
	    The Water winner out of combat, and in combat the Mana Potion macro's
	    ranked potions. No selection of its own; the body comes from
	    ns.BuildComboBody (Body-Builder.lua).
	]]
	buildModeOverride = function(context)
		return ns.BuildComboBody(context.best, "Water", "Mana Potion")
	end,
})
