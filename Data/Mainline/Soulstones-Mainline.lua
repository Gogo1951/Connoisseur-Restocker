local _, ns = ...

-- TODO: Add SQL Query
--[[
    Source: copied from Data/Wrath/Soulstones-Wrath.lua: the rows a Wrath
    client loaded from the pre-split shared tables, until a Mainline TOC ships
    and Validate Data runs there.

    Rank Value: the stone's resurrection health, used as a sortable
    preference score (Minor < Lesser < Soulstone < Greater < Major <
    Master < Demonic).
]]
-- [ID] = {Rank Value}, -- Name
ns.SOULSTONES = {
	[36895] = { 5300 }, -- Demonic Soulstone
	[22116] = { 2900 }, -- Master Soulstone
	[16896] = { 2200 }, -- Major Soulstone
	[16895] = { 1600 }, -- Greater Soulstone
	[16893] = { 1100 }, -- Soulstone
	[16892] = { 750 }, -- Lesser Soulstone
	[5232] = { 400 }, -- Minor Soulstone
}

--[[
    No soulstone rows in ns.CONJURED_ITEM_IDS_BY_SPELL, on purpose (see
    Conjured-Items-Mainline.lua): soulstones share a 30-minute use cooldown that
    matches the buff duration, so only one stone can ever be deployed at
    a time — conjuring a lower rank while holding the best one would
    just waste a soul shard. The Soulstone resolver therefore runs with
    checkUnique=false and always offers the best known conjure.
]]

--[[
    The Soulstone RESURRECTION auras — what a stone leaves on whoever it was
    used on. Distinct from the Create Soulstone spells in ns.CONJURE_SPELLS
    (Conjure-Spells-Mainline.lua), which are what a warlock casts to MAKE one,
    and distinct again from the item ids above, which are the stones sitting in
    a bag.

    The readiness report wants the aura: a raid cares that a stone is deployed
    on someone, not that seven unused ones are riding around in seven bags.

    Ranks pair one-for-one with the conjure spells, except that the Wrath
    Demonic pair is inverted — conjure 47884, aura 47883. That is Blizzard's
    numbering, not a transcription slip here.

    THESE IDS ARE UNVERIFIED against a live client. Because of that the report
    also matches on the aura's own localized name, which every rank shares and
    which is read from C_Spell.GetSpellName rather than written down here — so a wrong
    id in this list costs nothing as long as one id still resolves. Confirm
    them before relying on the id path alone.
]]
-- buffSpellID, -- Rank, Name (conjure spell ID)
ns.SOULSTONE_BUFF_SPELL_IDS = {
	20707, -- Rank 1, Minor    (conjure 693)
	20762, -- Rank 2, Lesser   (conjure 20752)
	20763, -- Rank 3, Soulstone (conjure 20755)
	20764, -- Rank 4, Greater  (conjure 20756)
	20765, -- Rank 5, Major    (conjure 20757)
	27239, -- Rank 6, Master   (conjure 27238)
	47883, -- Rank 7, Demonic  (conjure 47884)
}
