local _, ns = ...

--------------------------------------------------------------------------------
-- Profiles Panel
--------------------------------------------------------------------------------

--[[
    The stock AceDBOptions-3.0 profiles panel (profile picker, Copy From, Delete
    a Profile, Reset Profile), with nothing added and nothing removed. Its
    second argument, noDefaultProfiles, stops the picker offering profiles
    nobody made, one each for the realm, the class and a shared "Default":
    every character has a profile of its own, so the picker lists those and
    whatever the player has made. The widgets come already localized from
    AceDBOptions, so there are no locale keys of our own. Registered
    second-to-last, directly above Diagnostic Tools (see Options.lua).
]]
function ns.BuildProfilesOptions()
	return LibStub("AceDBOptions-3.0"):GetOptionsTable(ns.db, true)
end
