local _, ns = ...

--[[
    Scanner-Character -- reads the character's own facts: profession skills and
    the session constants (race and class, spell-name caches, the conjure-spell
    cache). Which buffs the character still needs is Scanner-Auras.lua's job.
]]

--------------------------------------------------------------------------------
-- State
--------------------------------------------------------------------------------

ns.currentFirstAidSkill = 0
ns.currentAlchemySkill = 0
ns.currentEngineeringSkill = 0

--------------------------------------------------------------------------------
-- Profession Skills
--------------------------------------------------------------------------------

function ns.UpdateFirstAidSkill()
	local firstAidSpellName = C_Spell.GetSpellName(ns.FIRST_AID_SPELL_ID)
	if not firstAidSpellName then
		ns.currentFirstAidSkill = 0
		return
	end

	for i = 1, ns.GetNumSkillLines() do
		local skillName, isHeader, _, skillRank, skillLineID = ns.GetSkillLineInfo(i)
		if not isHeader and (skillName == firstAidSpellName or skillLineID == ns.FIRST_AID_SKILL_LINE_ID) then
			ns.currentFirstAidSkill = skillRank
			return
		end
	end

	ns.currentFirstAidSkill = 0
end

function ns.UpdateAlchemySkill()
	local alchemySpellName = C_Spell.GetSpellName(ns.ALCHEMY_SPELL_ID)
	if not alchemySpellName then
		ns.currentAlchemySkill = 0
		return
	end

	for i = 1, ns.GetNumSkillLines() do
		local skillName, isHeader, _, skillRank, skillLineID = ns.GetSkillLineInfo(i)
		if not isHeader and (skillName == alchemySpellName or skillLineID == ns.ALCHEMY_SKILL_LINE_ID) then
			ns.currentAlchemySkill = skillRank
			return
		end
	end

	ns.currentAlchemySkill = 0
end

function ns.UpdateEngineeringSkill()
	local engineeringSpellName = C_Spell.GetSpellName(ns.ENGINEERING_SPELL_ID)
	if not engineeringSpellName then
		ns.currentEngineeringSkill = 0
		return
	end

	for i = 1, ns.GetNumSkillLines() do
		local skillName, isHeader, _, skillRank, skillLineID = ns.GetSkillLineInfo(i)
		if not isHeader and (skillName == engineeringSpellName or skillLineID == ns.ENGINEERING_SKILL_LINE_ID) then
			ns.currentEngineeringSkill = skillRank
			return
		end
	end

	ns.currentEngineeringSkill = 0
end

--------------------------------------------------------------------------------
-- Session Constants
--------------------------------------------------------------------------------

--[[
    One-time, session-constant character setup: race/class detection,
    spell-name caches, the conjure-spell existence cache, and profession skills.
    None of these change during a session, so they resolve once and the event
    handlers (PLAYER_LEVEL_UP, SPELLS_CHANGED, SKILL_LINES_CHANGED) keep the
    level-dependent pieces fresh afterward. Called once at login, after ns.db
    exists.
]]
function ns.InitCharacterConstants()
	local _, raceToken = UnitRace("player")
	ns.isNightElf = (raceToken == "NightElf")

	-- Resolve the Shadowmeld spell name once for macro building
	if ns.isNightElf then
		ns.shadowmeldSpellName = C_Spell.GetSpellName(ns.SHADOWMELD_SPELL_ID)
	end

	--[[
	    Class detection. Used by macro builders to decide which conjure
	    branches the player could *eventually* know — so a low-level mage
	    gets "You don't currently know Conjure Food." while a hunter sees no
	    message at all (they'll never learn that spell).
	]]
	local _, classToken = UnitClass("player")
	ns.isHunter = (classToken == "HUNTER")
	ns.isDruid = (classToken == "DRUID")
	ns.isMage = (classToken == "MAGE")
	ns.isWarlock = (classToken == "WARLOCK")
	ns.isRogue = (classToken == "ROGUE")

	-- Resolve the Stealth spell name once for macro building (Stealth Eating)
	if ns.isRogue then
		ns.stealthSpellName = C_Spell.GetSpellName(ns.STEALTH_SPELL_ID)
	end

	if ns.isHunter then
		ns.ResolveHunterSpells()
		ns.petDeadDismissed = false
	end

	ns.spellCache = {}
	for _, spellList in pairs(ns.CONJURE_SPELLS) do
		for _, data in ipairs(spellList) do
			local spellID = data[1]
			if C_Spell.GetSpellName(spellID) then
				ns.spellCache[spellID] = true
			end
		end
	end

	ns.UpdateFirstAidSkill()
	ns.UpdateAlchemySkill()
	ns.UpdateEngineeringSkill()
end
