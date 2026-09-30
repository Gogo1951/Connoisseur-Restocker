local _, ns = ...

--------------------------------------------------------------------------------
-- Questionable Equipment
--------------------------------------------------------------------------------

--[[
    Items that are fine to own and wrong to be wearing when a pull starts. Read
    by the Non-combat Gear Equipped check in
    Features/Readiness-Report-Probes.lua.

    THIS TABLE IS THE EXCEPTIONS, NOT THE LIST. Nearly everything worth catching
    is a whole weapon subclass -- every fishing pole, every mining pick and
    skinning knife, the tournament lances -- and the check answers those from
    the equipped item's own class and subclass, so they need no rows here and a
    pole added in a later patch is covered on the day it ships.

    What is left is the handful that share a subclass with real gear: trinkets.
    No property tells a Riding Crop from a raid trinket, so those are named.
]]

--[[
    Source: copied from Data/Wrath/Questionable-Equipment-Wrath.lua: the rows a Wrath
    client loaded from the pre-split shared tables, until a Mainline TOC ships
    and Validate Data runs there.
]]
-- TODO: Add SQL Query
-- [itemID] = true, -- Item Name
ns.QUESTIONABLE_EQUIPMENT = {
	[25653] = true, -- Riding Crop
	[37254] = true, -- Super Simian Sphere
}
