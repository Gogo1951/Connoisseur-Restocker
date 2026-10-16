local _, ns = ...

-- [ID] = {Bandage Amount, First Aid Skill, Vendor Value, {Allowed Zones}}, -- Name
ns.BANDAGES = {
	[19307] = { 2000, 225, 100, { 1459 } }, -- Alterac Heavy Runecloth Bandage
	[20065] = { 1104, 175, 75, { 1461 } }, -- Arathi Basin Mageweave Bandage
	[20066] = { 2000, 225, 100, { 1461 } }, -- Arathi Basin Runecloth Bandage
	[20067] = { 640, 125, 50, { 1461 } }, -- Arathi Basin Silk Bandage
	[23684] = { 2500, 225, 1500 }, -- Crystal Infused Bandage
	[272057] = { 1104, 175, 75, { 2524 } }, -- Darkspear Islands Mageweave Bandage
	[272058] = { 2000, 225, 100, { 2524 } }, -- Darkspear Islands Runecloth Bandage
	[272056] = { 640, 125, 50, { 2524 } }, -- Darkspear Islands Silk Bandage
	[20232] = { 1104, 175, 75, { 1461 } }, -- Defiler's Mageweave Bandage
	[20234] = { 2000, 225, 100, { 1461 } }, -- Defiler's Runecloth Bandage
	[20235] = { 640, 125, 50, { 1461 } }, -- Defiler's Silk Bandage
	-- Dense Runecloth Bandage (232433) is deliberately absent; it is a Season of Discovery item that Validate Data still reports OK on Forever.
	[2581] = { 114, 20, 20 }, -- Heavy Linen Bandage
	[8545] = { 1104, 175, 600 }, -- Heavy Mageweave Bandage
	[14530] = { 2000, 225, 1000 }, -- Heavy Runecloth Bandage
	[6451] = { 640, 125, 400 }, -- Heavy Silk Bandage
	[3531] = { 301, 75, 57 }, -- Heavy Wool Bandage
	[20237] = { 1104, 175, 75, { 1461 } }, -- Highlander's Mageweave Bandage
	[20243] = { 2000, 225, 100, { 1461 } }, -- Highlander's Runecloth Bandage
	[20244] = { 640, 125, 50, { 1461 } }, -- Highlander's Silk Bandage
	[1251] = { 66, 1, 10 }, -- Linen Bandage
	[8544] = { 800, 150, 400 }, -- Mageweave Bandage
	[14529] = { 1360, 200, 500 }, -- Runecloth Bandage
	[6450] = { 400, 100, 200 }, -- Silk Bandage
	[19067] = { 1104, 175, 75, { 1460 } }, -- Warsong Gulch Mageweave Bandage
	[19066] = { 2000, 225, 100, { 1460 } }, -- Warsong Gulch Runecloth Bandage
	[19068] = { 640, 125, 50, { 1460 } }, -- Warsong Gulch Silk Bandage
	[3530] = { 161, 50, 28 }, -- Wool Bandage
	-- Dense Frostweave Bandage (38640) and Dalaran Bandage (44646) are deliberately absent; the query above excludes them too, so a regeneration will not bring them back.
}

--[[
How We Got the Data

Last Validated
	2026-10-16, WoW Forever 1.60.1.70425

Notes
	- Every First Aid bandage on this client, read by the item cache (Features/Item-Cache.lua) to rank the Bandage macro's picks.
	- Bandage Amount is the whole heal over the channel, the per-tick heal times the ticks. First Aid Skill is the rank the tooltip requires (0 when it names none). Vendor Value is the sell price in copper.
	- Allowed Zones are uiMapIDs: 1459 Alterac Valley, 1460 Warsong Gulch, 1461 Arathi Basin, 2524 Darkspear Islands (area 16606). Each battleground bandage's tooltip says where it works ("Usable only inside Arathi Basin"; Alterac's says "May only be used in Alterac Valley"), and the item is offered nowhere else.
	- Dense Frostweave Bandage (38640) and Dalaran Bandage (44646) are Wrath items, left out; the query below excludes them too.
	- This client's anti-venoms, poultices and tourniquets share the bandage cooldown but cure poisons, diseases and bleeds rather than heal, so they are not bandages here.
	- Season of Discovery items are left out even though this client knows many of their IDs (any ID of 200000 or more that the Classic Era tables also hold): they live only in Data/Discovery/. Where a table would otherwise pick one up, a deliberately-absent line in the table says so.

SQL (CMaNGOS)
	Database not recorded.

	SELECT
	    CONCAT(
	        '    [',
	        it.entry, '] = {',

	        -- Dynamically calculates the Total Heal amount!
	        (st.EffectBasePoints1 + 1) *
	        CASE
	            WHEN it.RequiredSkillRank < 50 THEN 6   -- Linen (6 ticks)
	            WHEN it.RequiredSkillRank < 100 THEN 7  -- Wool (7 ticks)
	            ELSE 8                                  -- Silk and above (8 ticks)
	        END,

	        ', ', it.RequiredSkillRank,
	        ', ', it.SellPrice,

	        -- Appends the optional Zone restrictions for Battlegrounds
	        CASE
	            WHEN it.entry IN (19307) THEN ', {1459}'
	            WHEN it.entry IN (20065, 20066, 20067, 20232, 20234, 20235, 20237, 20243, 20244) THEN ', {1461}'
	            WHEN it.entry IN (19066, 19067, 19068) THEN ', {1460}'
	            ELSE ''
	        END,

	        '}, -- ', it.name
	    ) AS `ns.RAW_DATA.Bandage`
	FROM item_template it
	JOIN spell_template st ON it.spellid_1 = st.Id
	WHERE it.class = 0
	  AND it.subclass = 7
	  AND it.spellid_1 > 0
	  AND st.EffectBasePoints1 > 0
	  AND it.entry NOT IN (38640, 44646)
	ORDER BY
	  it.RequiredSkillRank DESC,
	  it.entry DESC;

Wowhead
	None.

wago.tools
	https://wago.tools/db2/Item?build=1.60.1.70425
	https://wago.tools/db2/ItemSparse?build=1.60.1.70425
	https://wago.tools/db2/ItemEffect?build=1.60.1.70425
	https://wago.tools/db2/ItemXItemEffect?build=1.60.1.70425
	https://wago.tools/db2/Spell?build=1.60.1.70425
	https://wago.tools/db2/SpellEffect?build=1.60.1.70425
	https://wago.tools/db2/SpellMisc?build=1.60.1.70425
	https://wago.tools/db2/SpellDuration?build=1.60.1.70425
	https://wago.tools/db2/SpellCastingRequirements?build=1.60.1.70425
	https://wago.tools/db2/AreaGroupMember?build=1.60.1.70425
	https://wago.tools/db2/UiMapAssignment?build=1.60.1.70425
]]
