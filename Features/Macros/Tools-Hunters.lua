local _, ns = ...
local MACRO_CONFIG = ns.MACRO_CONFIG

--------------------------------------------------------------------------------
-- Hunter Tools
--------------------------------------------------------------------------------

--[[
    All hunter-specific logic lives here (organizing rule: see
    Tools-Mages.lua): pet-spell resolution, dead-pet handling, and the Feed Pet
    macro. Pet food scanning and the pet-buff-food override resolver, which the
    bag scan reads as well, live beside it in Tools-Hunters-Pet-Food.lua.

    Feed Pet is Hunter-only and owns its whole update cycle: knowledge tiers
    (print-only stub for pre-10 hunters, Mend-less cascade at 10-11, full
    cascade at 12+), pet-spell resolution, dead-pet detection, and its own
    macro state, all in this file. The definition at the bottom scans pet food
    for every Hunter, then routes the engine's update to UpdateFeedPetMacro or
    removes the macro when disabled; for non-Hunters it does nothing at all.
    The scan sits outside that branch because ns.bestPetFoodID is read by the
    mini-map tooltip and by Diagnostics whether or not the macro exists.
]]

--------------------------------------------------------------------------------
-- Pet Spell Resolution
--------------------------------------------------------------------------------

--[[
    Resolves each pet spell's name only if the player actually knows the spell.
    C_Spell.GetSpellName returns a name even for unlearned spells, so a level-8 hunter
    without Mend Pet would otherwise get a macro referencing a spell they can't
    cast. Core re-runs this on PLAYER_LEVEL_UP and SPELLS_CHANGED so a
    newly-learned spell (Mend Pet at 12) starts participating without a /reload.
]]
local function ResolveIfKnown(spellID)
	if ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID) then
		return C_Spell.GetSpellName(spellID)
	end
	return nil
end

function ns.ResolveHunterSpells()
	if not ns.isHunter then
		return
	end
	ns.feedPetSpellName = ResolveIfKnown(ns.FEED_PET_SPELL_ID)
	ns.revivePetSpellName = ResolveIfKnown(ns.REVIVE_PET_SPELL_ID)
	ns.mendPetSpellName = ResolveIfKnown(ns.MEND_PET_SPELL_ID)
	ns.callPetSpellName = ResolveIfKnown(ns.CALL_PET_SPELL_ID)
	ns.dismissPetSpellName = ResolveIfKnown(ns.DISMISS_PET_SPELL_ID)
end

--------------------------------------------------------------------------------
-- UI Error Handling (Hunter)
--------------------------------------------------------------------------------

--[[
    Detect a dead-but-dismissed pet. When Call Pet fails because the pet is
    dead, the client shows the SPELL_FAILED_TARGETS_DEAD text; we match that
    text and flip the flag so the macro rebuilds with Revive Pet on the next
    cycle. A spell aimed at a dead target shows the same text, so the error is
    ignored while the target is dead. Core's dispatcher routes UI_ERROR_MESSAGE
    here ahead of its combat-lockdown guard, so this still fires mid-fight.
]]
function ns.OnHunterUiErrorMessage(message)
	if not ns.isHunter then
		return
	end
	if UnitExists("pet") or not message then
		return
	end
	if UnitExists("target") and UnitIsDead("target") then
		return
	end
	local deadMessage = SPELL_FAILED_TARGETS_DEAD
	if deadMessage and message == deadMessage then
		ns.petDeadDismissed = true
		ns.RequestUpdate()
	end
end

--------------------------------------------------------------------------------
-- Pet State Events (Hunter)
--------------------------------------------------------------------------------

--[[
    UNIT_PET handler routed from Core's dispatcher. When the player's pet
    appears or changes, clear the dead-dismissed flag so the Feed Pet macro
    stops offering Revive, then rebuild. The flag reset is Hunter-specific;
    the rebuild runs for every class the dispatcher forwards.
]]
function ns.OnUnitPet(unit)
	if unit ~= "player" then
		return
	end
	if ns.isHunter and UnitExists("pet") and not UnitIsDead("pet") then
		ns.petDeadDismissed = false
	end
	ns.RequestUpdate()
end

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

local currentPetFoodState = nil

function ns.ResetHunterMacroState()
	currentPetFoodState = nil
end

--------------------------------------------------------------------------------
-- Feed Pet Macro Body
--------------------------------------------------------------------------------

--[[
    Logic flow prioritizes modifier inputs first, then pet state, then combat.
    Combining conditions into bracket groups (e.g., [btn:2][combat]) keeps the
    body compact, but the cast cascade still names up to five client-localized
    spells, so a body that fits in enUS can exceed the 255 macro ceiling in
    multibyte locales: BuildFeedPetBody trims optional branches to fit (below).

    The macro adapts to which pet spells the hunter actually knows:
      Tier A (pre-10; any of Feed/Revive/
              Call/Dismiss Pet missing)  → print-only stub explaining the gap
      Tier B (10-11, no Mend Pet)        → full cascade minus Mend Pet, plus a
                                           click-time print on [btn:2][combat]
      Tier C (12+, every pet spell known) → full cascade as documented below

    Tier C modifier actions:
      [mod:ctrl]                 → Dismiss Pet
      [mod:shift] OR [@pet,dead] → Revive Pet
      [nopet]                    → Call Pet (or Revive Pet when dead-dismissed)
      [btn:2] OR [combat]        → Mend Pet
      default                    → Feed Pet + /use food
]]

--[[
    Trap: the trailing "/use item:" food line is the casualty of an overflow, so
    a truncated body silently drops the feed. The ceiling is
    ns.MACRO_BODY_MAX_LENGTH (Data/Data.lua), measured in bytes for the reason
    kept there. The Tier B/C cast cascade names up to five pet spells, and
    C_Spell.GetSpellName returns CLIENT-localized names, so a body that fits in enUS
    (Tier C is ~196 bytes) overflows in multibyte locales: ruRU pet-spell names
    run roughly double the byte cost and push Tier B/C past 300 bytes.

    Rule: assemble the full body, then while it exceeds the ceiling shed the
    optional modifier conveniences in priority order, the [mod:ctrl] Dismiss
    shortcut first and then the [mod:shift]/[@pet,dead] Revive shortcut,
    rebuilding the matching /stopmacro set each time so it stays consistent with
    the branches that remain. The [nopet] summon, the [btn:2]/[combat] Mend
    branch, the default Feed, and the /use food line are never dropped, so the
    macro's core feed/summon behavior survives in every locale.
]]
local function ComposeFeedPetBody(tier, itemID, includeDismiss, includeRevive)
	local feedName = ns.feedPetSpellName
	local reviveName = ns.revivePetSpellName
	local callName = ns.callPetSpellName
	local dismissName = ns.dismissPetSpellName
	local mendName = ns.mendPetSpellName -- nil in Tier B

	--[[
	    When we know the pet is dead but dismissed, [nopet] uses Revive Pet
	    instead of Call Pet so a single click revives without the user
	    needing to remember the dead state.
	]]
	local nopetSpell = (ns.petDeadDismissed and reviveName) or callName

	--[[
	    Modifier cascade. Tier C includes the Mend Pet branch on
	    [btn:2][combat]; Tier B omits it (and we print a tip earlier in the
	    macro to explain why right-click/combat does nothing useful). The
	    Dismiss and Revive shortcuts are optional and are the first to be
	    dropped when the body must shrink to fit the 255 ceiling.
	]]
	local castClauses = {}
	if includeDismiss then
		castClauses[#castClauses + 1] = "[mod:ctrl] " .. dismissName
	end
	if includeRevive then
		castClauses[#castClauses + 1] = "[mod:shift][@pet,dead] " .. reviveName
	end
	castClauses[#castClauses + 1] = "[nopet] " .. nopetSpell
	if mendName then
		castClauses[#castClauses + 1] = "[btn:2][combat] " .. mendName
	end
	castClauses[#castClauses + 1] = feedName

	local lines = { "#showtooltip" }

	if tier == "B" then
		--[[
		    Tier B: explain the missing Mend Pet on the inputs that would
		    have used it, then halt before the Feed Pet cascade so we don't
		    try to /cast Feed Pet in combat (it would fail) or on a
		    right-click the user expected to mean Mend.
		]]
		lines[#lines + 1] = '/run ConnoisseurTipIf("[btn:2][combat]","noMendPet")'
		lines[#lines + 1] = "/stopmacro [btn:2][combat]"
	end

	lines[#lines + 1] = "/cast " .. table.concat(castClauses, "; ")

	--[[
	    Halt before /use when /cast dispatched to a non-Feed-Pet branch. Each
	    guard token is present only while its branch is: [mod] covers both the
	    ctrl and shift shortcuts, and once a trim drops one, only the survivor's
	    modifier is named, so the dropped one's click falls through to Feed Pet
	    and its food; [@pet,dead] the dead-pet auto-revive, and [btn:2]/[combat]
	    the Mend branch (Tier C). The token order stays fixed: reordering it would
	    change every written body's text, and so rewrite every Feed Pet macro, for
	    no change in behavior.
	]]
	local stopTokens = {}
	if includeDismiss and includeRevive then
		stopTokens[#stopTokens + 1] = "[mod]"
	elseif includeRevive then
		stopTokens[#stopTokens + 1] = "[mod:shift]"
	elseif includeDismiss then
		stopTokens[#stopTokens + 1] = "[mod:ctrl]"
	end
	if mendName then
		stopTokens[#stopTokens + 1] = "[btn:2]"
	end
	stopTokens[#stopTokens + 1] = "[nopet]"
	if includeRevive then
		stopTokens[#stopTokens + 1] = "[@pet,dead]"
	end
	if mendName then
		stopTokens[#stopTokens + 1] = "[combat]"
	end
	lines[#lines + 1] = "/stopmacro " .. table.concat(stopTokens, "")

	if itemID then
		lines[#lines + 1] = "/use item:" .. itemID
	else
		--[[
		    No useful food in bags: clicking Feed Pet should explain that
		    rather than silently doing nothing on the food line.
		]]
		lines[#lines + 1] = '/run ConnoisseurTip("noPetFood")'
	end

	return table.concat(lines, "\n")
end

local function BuildFeedPetBody(tier, itemID)
	if tier == "A" then
		return table.concat({
			"#showtooltip",
			'/run ConnoisseurTip("noPetSkills")',
		}, "\n")
	end

	--[[
	    Full body first, then drop the Dismiss shortcut, then the Revive
	    shortcut, stopping as soon as the body fits (see the note above
	    ComposeFeedPetBody). #body is the byte length, matching the
	    macro-length trims in Body-Builder.lua and Integration-Druid-Macro-Helper.lua.
	]]
	local body = ComposeFeedPetBody(tier, itemID, true, true)
	if #body > ns.MACRO_BODY_MAX_LENGTH then
		body = ComposeFeedPetBody(tier, itemID, false, true)
	end
	if #body > ns.MACRO_BODY_MAX_LENGTH then
		body = ComposeFeedPetBody(tier, itemID, false, false)
	end
	return body
end

--------------------------------------------------------------------------------
-- Feed Pet Update
--------------------------------------------------------------------------------

local function UpdateFeedPetMacro(forced)
	if forced then
		currentPetFoodState = nil
	end

	local config = MACRO_CONFIG["Feed Pet"]
	if not config then
		return
	end
	local macroName = config.macro

	--[[
	    Knowledge tier drives the macro shape. The Tier B/C cast line
	    concatenates Feed, Revive, Call, AND Dismiss Pet, so a missing name
	    for any of them — not just Feed Pet — collapses to the print-only
	    stub (Tier A). The four spells normally arrive together with the
	    level-10 pet quests, but this also covers a hunter mid-quest-chain
	    and any transient SPELLS_CHANGED timing where ns.IsSpellKnown hasn't
	    caught up; the next SPELLS_CHANGED rebuild promotes the tier. Mend
	    Pet absence is the common transient state for a level-10/11 hunter
	    who hasn't trained the level-12 spell yet.
	]]
	local tier
	if not (ns.feedPetSpellName and ns.revivePetSpellName and ns.callPetSpellName and ns.dismissPetSpellName) then
		tier = "A"
	elseif not ns.mendPetSpellName then
		tier = "B"
	else
		tier = "C"
	end

	--[[
	    Tier A bypasses food entirely — the macro can't act on it without
	    Feed Pet — so we don't encode itemID into the state. Tiers B and C
	    both rely on the food line, so we include it.
	]]
	local itemID = (tier ~= "A") and ns.bestPetFoodID or nil

	local stateID = tier
		.. "_"
		.. (itemID and tostring(itemID) or "none")
		.. "_"
		.. (ns.petDeadDismissed and "DD" or "ND")

	if currentPetFoodState == stateID and not forced then
		return
	end

	local body = BuildFeedPetBody(tier, itemID)

	-- On a failed create, leave the state unset so the next update retries.
	if not ns.WriteMacroBody(macroName, body) then
		currentPetFoodState = nil
		return
	end

	currentPetFoodState = stateID
end

--------------------------------------------------------------------------------
-- Definition
--------------------------------------------------------------------------------

ns.RegisterMacroType({
	typeName = "Feed Pet",

	customUpdate = function(forced)
		if not ns.isHunter then
			return
		end

		--[[
		    Ahead of the enabled check, because ns.bestPetFoodID and
		    ns.bestPetFoodLink are published state with readers that stay live
		    whether or not the macro is built -- the mini-map tooltip's pet-food
		    row and two Diagnostics reports. Scanning only when the macro is on
		    would freeze all three at whatever the last enabled pass left. It
		    costs nothing extra: the scan reads ns.scannedItemCounts, which
		    ns.ScanBags refilled earlier in this same update pass.
		]]
		ns.ScanPetFood()

		if ns.IsMacroEnabled("Feed Pet") then
			UpdateFeedPetMacro(forced)
		else
			local config = MACRO_CONFIG["Feed Pet"]
			if config then
				ns.DeleteMacroByName(config.macro)
				ns.ResetHunterMacroState()
			end
		end
	end,
})
