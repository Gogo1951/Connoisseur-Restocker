local _, ns = ...

if not ns.IS_DISCOVERY then
	return
end

-- [ID] = {Rank Value}, -- Name
ns.SOULSTONES = {
	[16896] = { 2200 }, -- Major Soulstone
	[16895] = { 1600 }, -- Greater Soulstone
	[16893] = { 1100 }, -- Soulstone
	[16892] = { 750 }, -- Lesser Soulstone
	[5232] = { 400 }, -- Minor Soulstone
}

-- buffSpellID, -- Rank, Name (conjure spell ID)
ns.SOULSTONE_BUFF_SPELL_IDS = {
	20707, -- Rank 1, Minor    (conjure 693)
	20762, -- Rank 2, Lesser   (conjure 20752)
	20763, -- Rank 3, Soulstone (conjure 20755)
	20764, -- Rank 4, Greater  (conjure 20756)
	20765, -- Rank 5, Major    (conjure 20757)
}

--[[
How We Got the Data

Last Validated
	2026-10-16, Season of Discovery 1.15.9.70003

Notes
	- ns.SOULSTONES holds the warlock's soulstones, read by the item cache and the Readiness Report. Rank Value is the stone's resurrection health, used as a sortable preference score (Minor < Lesser < Soulstone < Greater < Major).
	- ns.SOULSTONE_BUFF_SPELL_IDS holds the Soulstone Resurrection auras, what a stone leaves on whoever it was used on: distinct from the Create Soulstone spells (Conjure-Spells-Discovery.lua) and from the stones in a bag. The Readiness Report wants the aura, since a raid cares that a stone is deployed on someone, not that unused ones ride around in bags. Ranks pair one-for-one with the conjure spells, and each is its rank's stone's use spell.
	- The report also matches on the aura's own localized name, which every rank shares and which is read from C_Spell.GetSpellName rather than written here, so a wrong ID in that list costs nothing as long as one still resolves.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.15.9.70003
	https://wago.tools/db2/ItemSparse?build=1.15.9.70003
	https://wago.tools/db2/ItemEffect?build=1.15.9.70003
	https://wago.tools/db2/Spell?build=1.15.9.70003
	https://wago.tools/db2/SpellEffect?build=1.15.9.70003
	https://wago.tools/db2/SpellMisc?build=1.15.9.70003
	https://wago.tools/db2/SpellDuration?build=1.15.9.70003
]]
