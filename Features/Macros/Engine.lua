local _, ns = ...
local MACRO_CONFIG = ns.MACRO_CONFIG
local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")

--[[
    Engine -- the shared macro-writing machinery. Owns the definition
    registry, the update loop that drives one registered definition per
    macro, and the switch setter that rebuilds them. Beside it: target and
    group signatures (Signatures.lua), conjure rank resolution
    (Smart-Spell.lua), macro create/edit/delete (Writer.lua), and the
    standard-body, conjure-block and state-key builders with the macro-length
    trim (Body-Builder.lua).

    Per-macro behavior lives in Features/Macros/<Name>.lua files, each of
    which calls ns.RegisterMacroType with a definition table:

      typeName          -- key into ns.MACRO_CONFIG (required)

    Selection fields — how the scanner picks this category's item. A
    definition with an itemTypes set participates in ScanBags: every usable
    bag item is dispatched to each definition claiming its cached itemType
    (more than one may claim the same item — a hybrid potion feeds Health
    Potion and Mana Potion, a foodwater item feeds Food and Water). The
    shared tiebreak ladder (RANKING_PRIORITY) stays in Scanner-Inventory.

      itemTypes         -- set of ns.CacheItemData itemType strings this
                           category consumes, e.g. {potion = true}
      accepts(data)     -- optional extra gate on the cached item data
                           (Health Potion: data.healthValue > 0)
      score(data)       -- the raw restore/damage value fed to the ladder's
                           value step, e.g. data.healthValue. Burn-first
                           preferences (conjured, zone-locked, soulbound,
                           high-stack) are ladder steps, not score bonuses
      ranked            -- true: collect all candidates and rank into the
                           winner's topIDs (the multi-use types); otherwise
                           a single running winner is kept
      allowBuffFood     -- true: compare with the scanner's live
                           ns.allowBuffFood preference (Food, Water); absent:
                           the ladder's buff-food step stays gated off
      allowConjuredFirst -- true: compare with the scanner's live
                           ns.allowConjuredFirst preference (Food, Water);
                           absent: the ladder's conjured-first step stays
                           gated off
      allowRestockLast  -- true: compare with the scanner's live
                           ns.allowRestockLast preference (Food, Water);
                           absent: the ladder's restock-last step stays
                           gated off
      preferHybrid      -- direction of the ladder's hybrid step: true
                           prefers hybrid food/water (Food), false prefers
                           dedicated items (Water)
      winnerExtras(winner, data, hyperlink) -- store NON-comparison fields on
                           the winning record (Food: link, for
                           ns.bestFoodLink). Everything the ladder compares is
                           filled by the scanner's FillRecord

    Body hooks — what the written macro looks like.

      conjure()         -- class conjure resolver; returns the info table
                           documented under Conjure Protocol below, or nil
                           when this character has no conjure semantics
                           (Mage Food/Water/Mana Gem, Warlock Healthstone/
                           Soulstone)
      modifyItem(id)    -- replace the scanned best item before body assembly
                           (Food's pet-buff override)
      buildUseLine(id)  -- custom /use line(s) for the item; nil falls back to
                           the standard single- or multi-use block (Explosive's
                           click layout, Food's [@pet] line)
      getStackIDs(best) -- ranked ids appended below the main block, or the
                           whole body when there is no main item (Health
                           Potion's healthstone stacking)
      stackTypeName     -- the macro type those ids belong to, whose
                           DruidMacroHelper guards a stack-only body takes
                           (Health Potion: "Healthstone")
      outOfCombatTypeName -- the macro type whose scanned best item this body
                           uses instead while out of combat, behind
                           potionsUseFoodAndWater (Health Potion: "Food",
                           Mana Potion: "Water"). The scanned item only: no
                           scrolls, pet food, conjure clicks or stealth line
      buildModeOverride(context) -- full-body takeover; returns body, stateKey
                           or nil (Food's scroll-only mode). Mode state keys
                           MUST use their own prefix (e.g. "SCROLLS:") so they
                           can never collide with standard ITEMID-keys — a
                           transition into or out of the mode always rewrites.
      stateExtras(parts, id) -- append extra state-key parts (Explosive's
                           "EX:mode" click layout)
      appendBlock(id)   -- returns (text, stateFlag) appended after the action
                           block, given the item the body uses (after
                           modifyItem; nil when there is none): Water's
                           Shadowmeld line (flag "SM") and Food's Stealth
                           Eating line (flag "SE")
      customUpdate(forced) -- the definition owns its whole update; it is
                           skipped by the standard loop (Feed Pet, which
                           routes to the Hunter builder, and Poisons, which
                           routes to the Rogue builder)

    The macro-callback globals (ConnoisseurFire, ConnoisseurTip,
    ConnoisseurTipIf, ConnoisseurNoItem) and the state they share live in
    Features/Macros/Runtime.lua, which loads immediately after this file.
    Body-Builder.lua writes the `/run Connoisseur...` lines into macro bodies
    at update time, long after load, so the later load order is safe --
    nothing calls those globals while the files are being read.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local currentMacroState = {}

--------------------------------------------------------------------------------
-- Definition Registry
--------------------------------------------------------------------------------

local macroDefinitions = {}
local customDefinitions = {}

--[[
    The scanner reads the standard definitions' selection fields at scan
    time (Scanner-Inventory loads before this file, so it cannot see the
    local directly; every scan happens long after all registrations).
]]
ns.REGISTERED_MACRO_DEFINITIONS = macroDefinitions

--[[
    The custom definitions, exposed on the same terms for diagnostics only.
    They own their whole update and never reach the scanner's ranking ladder,
    so the Selection Report names them as resolved elsewhere rather than
    leaving the reader to wonder why Feed Pet and Poisons are missing from it.
]]
ns.REGISTERED_CUSTOM_MACRO_DEFINITIONS = customDefinitions

function ns.RegisterMacroType(definition)
	if definition.customUpdate then
		customDefinitions[#customDefinitions + 1] = definition
	else
		macroDefinitions[#macroDefinitions + 1] = definition
	end
end

--------------------------------------------------------------------------------
-- Conjure Protocol
--------------------------------------------------------------------------------

--[[
    A definition's `conjure` hook is a function returning a table:

      {
        rightName, rightID,    -- /cast spell on [btn:2] (or nil)
        middleName, middleID,  -- /cast spell on [btn:3] (or nil)
        rightMiss,             -- ConnoisseurTip key to fire on [btn:2] when right
                                  is not yet learned (or nil)
        middleMiss,            -- ConnoisseurTip key to fire on [btn:3] when middle
                                  is not yet learned (or nil)
        noItemMiss,            -- ConnoisseurTip key to fire on left-click when there
                                  is no item to /use AND the class can learn
                                  the conjure (replaces the generic no-item
                                  message). (or nil)
      }

    Returning nil from the resolver means "no conjure semantics for this
    macro type for this player" — leave the macro body as plain /use item.
    Class gating (ns.isMage / ns.isWarlock) lives inside each resolver.
]]

--------------------------------------------------------------------------------
-- Macro Enablement
--------------------------------------------------------------------------------

--[[
    Which macros the account wants. Account-wide to match the macros themselves,
    which live in the shared General tab (see ns.TryCreateMacro in Writer.lua), so
    a character switch never adds or removes a macro -- it only rewrites the
    shared bodies to that character's best items.
]]
function ns.IsMacroEnabled(typeName)
	local enabled = ns.db and ns.db.global.enabledMacros
	if not enabled then
		return true
	end
	return enabled[typeName] ~= false
end

local function DeleteMacroIfExists(macroName, typeName)
	ns.DeleteMacroByName(macroName)
	currentMacroState[typeName] = nil
end

--------------------------------------------------------------------------------
-- Macro Writing
--------------------------------------------------------------------------------

-- Writes through ns.WriteMacroBody (Writer.lua), recording the state key only when the write landed.
local function WriteMacro(macroName, body, stateKey, typeName)
	if ns.WriteMacroBody(macroName, body) then
		currentMacroState[typeName] = stateKey
	else
		currentMacroState[typeName] = nil
	end
end

--------------------------------------------------------------------------------
-- Macro Update Loop
--------------------------------------------------------------------------------

--[[
    One-time OnHide hook on the Blizzard Macro UI. MacroFrame saves its edit box
    back over the selected macro when the selection changes and when it hides,
    so a Connoisseur macro the user had selected may just have been reverted to
    the text from when the frame opened. The state keys can't see that -- they
    track what WE last wrote, and after a revert they match a body that is no
    longer there -- so drop them all and rebuild from scratch.

    The frame is load-on-demand, so this can only run once Blizzard_MacroUI has
    loaded. UpdateMacros calls it on EVERY pass rather than only from the
    frame-is-shown deferral below: installed from that branch alone, the hook
    arms only when an update happens to land while the frame is open, and a
    short visit that requests no update never arms it at all -- leaving exactly
    the stale-macro case this hook exists to close.

    One gap survives by design: a first open-and-close with no macro update in
    between still misses the hook, because the frame does not exist until the
    open and nothing runs before the close.
]]
local macroUIHooked = false

local function EnsureMacroUIHook()
	if macroUIHooked or not MacroFrame then
		return
	end
	macroUIHooked = true
	MacroFrame:HookScript("OnHide", function()
		ns.ResetMacroState()
		ns.RequestUpdate()
	end)
end

function ns.UpdateMacros(forced)
	--[[
	    Arm the Macro UI hook as early as possible. It self-guards on both
	    "already hooked" and "frame does not exist yet", so this costs one
	    boolean test per update.
	]]
	EnsureMacroUIHook()

	--[[
	    The wipe runs ahead of the deferral guards so a forced rebuild that
	    arrives in combat or with the Macro UI open keeps its force: the
	    deferred pass runs unforced, and only the wiped state guarantees it
	    rewrites bodies whose state key did not change.
	]]
	if forced then
		wipe(currentMacroState)
	end

	if InCombatLockdown() then
		ns.RequestUpdate()
		return
	end

	--[[
	    Writing while the Blizzard Macro UI is open is worse than useless: the
	    open frame never refreshes (the user stares at the old body and
	    concludes the rebuild is broken), and its save-back then reverts the
	    write -- leaving currentMacroState recording a body the macro no longer
	    has, which blocks every later rewrite whose state key matches (the
	    "stale macros until something else changes" failure). Leave the work
	    pending without re-arming the throttle: the OnHide hook above replays it
	    as a full rebuild the moment the frame closes, and it is always armed by
	    now, since EnsureMacroUIHook ran first and the frame exists.
	]]
	if MacroFrame and MacroFrame:IsShown() then
		ns.MarkUpdatePending()
		return
	end

	local best, dataRetry = ns.ScanBags()

	if dataRetry then
		ns.RegisterDataRetry()
	else
		ns.UnregisterDataRetry()
	end

	--[[
	    Scrolls are dropped from the macro when targeting a friendly player so
	    the macro reads cleanly as a conjure-for-friend action (Mage food).
	    Computed once per update and handed to buildModeOverride hooks via the
	    shared context (only Food consumes it today).
	]]
	local friendlyPlayerTarget = ns.HasFriendlyPlayerTarget()
	local context = {
		best = best,
		activeScrollIDs = (not friendlyPlayerTarget) and ns.scrollOverrideIDs or nil,
	}

	for _, definition in ipairs(macroDefinitions) do
		local typeName = definition.typeName
		local config = MACRO_CONFIG[typeName]

		if not ns.IsMacroEnabled(typeName) then
			DeleteMacroIfExists(config.macro, typeName)
		else
			local bestEntry = best[typeName]
			local itemID = bestEntry and bestEntry.id

			-- Definition hook: swap the scanned item (Food's pet-buff override).
			if definition.modifyItem then
				itemID = definition.modifyItem(itemID)
			end

			--[[
			    Ranked /use list for multi-use types; topIDs[1] is itemID
			    itself, so the list only adds fallback lines below it.
			]]
			local useIDs
			if itemID and ns.MULTI_USE_MACRO_TYPES[typeName] and bestEntry.topIDs and #bestEntry.topIDs > 0 then
				useIDs = bestEntry.topIDs
			end

			--[[
			    Definition hook: ranked ids appended below the main block
			    (Health Potion's healthstone stacking). With no main item they
			    become the whole body instead -- a Health Potion macro with no
			    potion, which is every TBC arena, still uses the stones -- and
			    the DruidMacroHelper guards follow what the body now uses.
			]]
			local stackIDs
			local overrideTypeName = typeName
			if definition.getStackIDs then
				local stacked = definition.getStackIDs(best)
				if itemID then
					stackIDs = stacked
				elseif stacked and #stacked > 0 then
					itemID, useIDs = stacked[1], stacked
					overrideTypeName = definition.stackTypeName or typeName
				end
			end

			--[[
			    Definition field: the food or water a potion macro uses out
			    of combat. It is the scanner's pick for that type as it
			    stands, buff food included, whether or not that type's own
			    macro is enabled; none in bags leaves the body as it was.
			]]
			local outOfCombatID
			if definition.outOfCombatTypeName and ns.db.profile.potionsUseFoodAndWater then
				local outOfCombatEntry = best[definition.outOfCombatTypeName]
				outOfCombatID = outOfCombatEntry and outOfCombatEntry.id
			end

			--[[
			    Class-specific macro overrides. The Druid builder owns the
			    DMH-wrap path (HP/MP/HS). Returns nil here means "no override
			    for this type/item" — fall through to the standard body.
			]]
			local classBody, classStateID
			if itemID then
				classBody, classStateID =
					ns.BuildDruidMacroOverride(overrideTypeName, itemID, useIDs, stackIDs, outOfCombatID)
			end

			--[[
			    Definition hook: full-body mode override (Food's scroll-only
			    mode). Built after the class override but written ahead of it,
			    so a mode body always wins.
			]]
			local modeBody, modeStateID
			if definition.buildModeOverride then
				modeBody, modeStateID = definition.buildModeOverride(context)
			end

			if modeBody then
				--[[
				    Mode override: the definition produced a fully formed body
				    and a state key it owns. Mode state keys use their own
				    prefix ("SCROLLS:") so they can never collide with the
				    standard ITEMID-prefixed key, which guarantees a rewrite
				    happens at every transition into and out of the mode
				    (target-change, scroll-applied, bag scan removing the last
				    scroll item, etc).
				]]
				if currentMacroState[typeName] ~= modeStateID or forced then
					WriteMacro(config.macro, modeBody, modeStateID, typeName)
				end
			elseif classBody then
				--[[
				    Class-override mode. The class builder produced a fully
				    formed macro body and a state key it owns; we just write
				    it. State keys from class builders MUST be prefixed
				    distinctly (e.g. "DMH:") so they cannot collide with the
				    standard or mode-override keys — a transition into or out
				    of override mode always triggers a rewrite.
				]]
				if currentMacroState[typeName] ~= classStateID or forced then
					WriteMacro(config.macro, classBody, classStateID, typeName)
				end
			else
				--[[
				    Class-specific conjure spells (or "spell not yet learned"
				    print tips). The definition's resolver may return nil for
				    macro types this player's class doesn't engage with.
				]]
				local conjureInfo = definition.conjure and definition.conjure() or nil

				-- Definition hook: appended block + its state flag, given the item the body uses.
				local appendText, appendFlag
				if definition.appendBlock then
					appendText, appendFlag = definition.appendBlock(itemID)
				end

				local stateID =
					ns.BuildStateKey(definition, itemID, useIDs, stackIDs, conjureInfo, appendFlag, outOfCombatID)

				if currentMacroState[typeName] ~= stateID or forced then
					local body = ns.BuildStandardBody(
						definition,
						itemID,
						useIDs,
						stackIDs,
						conjureInfo,
						appendText,
						outOfCombatID
					)
					WriteMacro(config.macro, body, stateID, typeName)
				end
			end
		end
	end

	--[[
	    Definitions that own their whole update cycle (Feed Pet and Poisons,
	    which route to the Hunter and Rogue builders and gate on the class
	    internally).
	]]
	for _, definition in ipairs(customDefinitions) do
		definition.customUpdate(forced)
	end

	ns.UpdateMinimapIcon()
end

function ns.ResetMacroState()
	wipe(currentMacroState)
	ns.ResetHunterMacroState()
	ns.ResetPoisonMacroState()
	ns.ResetScrollBuffTracking()
	ns.ResetTargetTracking()
end

--------------------------------------------------------------------------------
-- Feature Toggles
--------------------------------------------------------------------------------

--[[
    The one setter for the profile switches that reshape macro bodies. No value
    flips the current state (mini-map click path); a boolean sets it directly
    (options-panel path) and matches what AceConfig hands back to the set
    callback. The buff-food and scroll switches also change which auras are
    tracked. The Macros panel repaints either way, since a mini-map click has
    nothing else to ask for one while the panel is open.
]]
local AURA_TRACKED_SETTINGS = {
	useBuffFood = true,
	useScrolls = true,
}

function ns.ToggleMacroSetting(key, value)
	local settings = ns.db.profile
	if value == nil then
		settings[key] = not settings[key]
	else
		settings[key] = value
	end
	if AURA_TRACKED_SETTINGS[key] then
		ns.UpdateAuraTracking()
	end
	ns.ResetMacroState()
	ns.RequestUpdate()
	AceConfigRegistry:NotifyChange(ns.OPTIONS_REGISTRY.Macros)
end
