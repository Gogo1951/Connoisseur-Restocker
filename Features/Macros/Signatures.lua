local _, ns = ...

--------------------------------------------------------------------------------
-- Target Helpers
--------------------------------------------------------------------------------

--[[
    Single source of truth for "is the current target a friendly player." Used
    by both GetSmartSpell (for conjure rank downranking) and the scroll-mode
    gate (which drops scrolls so a Mage can right-click to conjure food
    for a friend without firing scrolls on themselves).
]]
local function HasFriendlyPlayerTarget()
	return UnitExists("target") and UnitIsFriend("player", "target") and UnitIsPlayer("target")
end
ns.HasFriendlyPlayerTarget = HasFriendlyPlayerTarget

--------------------------------------------------------------------------------
-- Target and Group Tracking
--------------------------------------------------------------------------------

--[[
    PLAYER_TARGET_CHANGED fires on every tab, and a rebuild is a full bag
    rescan, so an unconditional request there costs one of those per mob
    targeted. Only four things about a target reach a macro body:

      is it a friendly player  -- scroll suppression (ns.HasFriendlyPlayerTarget)
      is it the player         -- plain-food mode (targetingSelf in ns.ScanBags)
      its level, when it is a  -- the conjure downrank cap (ns.GetSmartSpell),
      friendly player             which reads no other target's level
      is it Humanoid or        -- the Cannibalize line (ns.TargetIsCannibalizable),
      Undead, for the Forsaken    read only while a Cannibalize switch is on

    Those four ARE the whole of what a target contributes to a written body,
    so anything new that reads the target MUST join this signature or its macro
    goes stale. Same diff-before-requesting shape ns.OnUnitAura uses on
    UNIT_AURA, and the group signature and ns.PetFoodQuestsChanged use on the
    other firehoses.

    GROUP_ROSTER_UPDATE fires on every raid roster change, yet the only group
    state a written body reads is whether the player is grouped and whether that
    group is a raid (the group-restricted modes, ns.IsModeActive). Hunters'
    QUEST_LOG_UPDATE fires on every objective tick and is diffed by
    ns.PetFoodQuestsChanged in Tools-Hunters-Pet-Food.lua.

    Left nil until the first firing, so the first reading always counts as a
    change rather than being compared against a state nobody has read yet.

    PLAYER_TARGET_CHANGED runs in combat, where the client can restrict unit
    comparisons (Forever): UnitIsUnit then returns a secret value, and testing
    it errors. While C_Secrets says the comparison is off, the self reading
    keeps its last value, so a restricted read counts as unchanged, never as a
    flip. The creature-type reading does the same when the client hides it.
]]
local lastTargetFriendly, lastTargetIsSelf, lastTargetLevel, lastTargetCannibalizable
local lastInGroup, lastInRaid

-- Records this firing's target readings and reports whether any of the four moved.
function ns.TargetSignatureChanged()
	local isFriendly = HasFriendlyPlayerTarget() and true or false
	local isSelf = lastTargetIsSelf
	if C_Secrets.CanCompareUnitTokens("target", "player") then
		isSelf = (UnitExists("target") and UnitIsUnit("target", "player")) and true or false
	end
	local level = isFriendly and UnitLevel("target") or nil
	local cannibalizable = false
	if ns.CannibalizeSwitchedOn() then
		cannibalizable = ns.TargetIsCannibalizable()
		if cannibalizable == nil then
			cannibalizable = lastTargetCannibalizable
		end
	end

	local changed = isFriendly ~= lastTargetFriendly
		or isSelf ~= lastTargetIsSelf
		or level ~= lastTargetLevel
		or cannibalizable ~= lastTargetCannibalizable
	lastTargetFriendly, lastTargetIsSelf, lastTargetLevel = isFriendly, isSelf, level
	lastTargetCannibalizable = cannibalizable
	return changed
end

-- Records this firing's group readings and reports whether either moved.
function ns.GroupSignatureChanged()
	local inGroup, inRaid = IsInGroup(), IsInRaid()
	local changed = inGroup ~= lastInGroup or inRaid ~= lastInRaid
	lastInGroup, lastInRaid = inGroup, inRaid
	return changed
end

function ns.ResetTargetTracking()
	lastTargetFriendly, lastTargetIsSelf, lastTargetLevel, lastTargetCannibalizable = nil, nil, nil, nil
	lastInGroup, lastInRaid = nil, nil
end
