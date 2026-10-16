local _, ns = ...

--------------------------------------------------------------------------------
-- Profiles Panel
--------------------------------------------------------------------------------

--[[
    The stock AceDBOptions-3.0 profiles panel (profile picker, Copy From, Delete
    a Profile, Reset Profile), with nothing added. Its second argument,
    noDefaultProfiles, takes out the profiles the picker would suggest though
    nobody made them, one each for the realm, the class and a shared "Default",
    while the migration that moves characters off Default runs (README-Notes):
    a character put on Default would be moved off it again at its next login.
    The widgets come already localized from AceDBOptions, so there are no
    locale keys of our own. Registered second-to-last, directly above
    Diagnostic Tools (see Options.lua).
]]
function ns.BuildProfilesOptions()
	return LibStub("AceDBOptions-3.0"):GetOptionsTable(
		ns.db,
		true -- MIGRATION (remove after 2026-10-30)
	)
end
