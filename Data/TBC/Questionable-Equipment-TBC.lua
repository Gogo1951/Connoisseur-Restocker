local _, ns = ...

-- [itemID] = true, -- Item Name
ns.QUESTIONABLE_EQUIPMENT = {
	[25653] = true, -- Riding Crop
}

--[[
How We Got the Data

Last Validated
	2026-10-23, TBC Anniversary 2.5.6.70006

Notes
	- Items that are fine to own and wrong to be wearing when a pull starts, read by the Non-combat Gear Equipped check in Features/Readiness-Report-Probes.lua.
	- This table is the exceptions, not the list. Nearly everything worth catching is a whole weapon subclass (every fishing pole, mining pick and skinning knife, the tournament lances), and the check answers those from the equipped item's own class and subclass, so they need no rows here and a pole added later is covered the day it ships. What is left is the handful that share a subclass with real gear: trinkets. No property tells a mount-speed trinket from a raid trinket, so those are named.

SQL (CMaNGOS)
	TODO: Add SQL Query

Wowhead
	None.

wago.tools
	https://wago.tools/db2/ItemSparse?build=2.5.6.70006

QuestieDB
	None.
]]
