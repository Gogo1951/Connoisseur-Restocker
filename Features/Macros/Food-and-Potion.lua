local _, ns = ...

--------------------------------------------------------------------------------
-- Food & Potion Macro
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Food & Potion",

	--[[
	    The Food winner out of combat, and in combat what the Health Potion
	    macro uses: its ranked potions, then the Healthstones while Combine
	    Healthstones is on. No selection of its own; the body comes from
	    ns.BuildComboBody (Body-Builder.lua).
	]]
	buildModeOverride = function(context)
		local stackIDs
		local settings = ns.db and ns.db.profile
		if settings and settings.combineHealthstones then
			stackIDs = context.best["Healthstone"].topIDs
		end
		return ns.BuildComboBody(context.best, "Food", "Health Potion", stackIDs)
	end,
})
