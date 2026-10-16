local _, ns = ...
local L = ns.L

--[[
    Print a reminder: the headline, then in verbose mode a line per short item.
    Callers pass the list they already built, so nothing is counted twice.
]]
function ns.PrintRestockShortfall(headline, mode, groceries)
	ns.PrintMessage(headline)
	if mode ~= ns.REMINDER_VERBOSE then
		return
	end
	for _, entry in ipairs(groceries) do
		ns.PrintMessage(
			string.format(
				L["RESTOCKER_REMINDER_ITEM"],
				entry.have,
				entry.wanted,
				ns.GetItemHyperlink(entry.itemID, entry.itemName)
			)
		)
	end
end

--[[
    The "orders outstanding" headline, singular or plural. The count is of
    grocery-list rows, not of missing units, which is what the wording says.
]]
function ns.RestockShortfallHeadline(count)
	if count == 1 then
		return L["RESTOCKER_STILL_SHORT_ONE"]
	end
	return string.format(L["RESTOCKER_STILL_SHORT_MANY"], count)
end

--------------------------------------------------------------------------------
-- Entering Town
--------------------------------------------------------------------------------

--[[
    Resting status is the game's own "you are somewhere with vendors" signal --
    it turns on in inns and cities and nowhere else -- so it is what the reminder
    keys off rather than a zone list we would have to maintain.

    Only a not-resting to resting transition counts, so this reminds you on
    ARRIVING in town rather than every time the flag twitches while you are in
    one -- and logging in counts as arriving, see the arming block below.

    Three things reach the check, because one signal does not cover every way of
    arriving:

      PLAYER_UPDATE_RESTING  -- walking in. Fires on both edges and can repeat,
                                which the transition rule already absorbs.
      PLAYER_ENTERING_WORLD  -- logging in, hearthing, portalling, or stepping
                                out of an instance. The resting flag is part of
                                the state the client syncs across a loading
                                screen, so no update event follows and
                                walking-in was the only arrival that ever fired.
      PLAYER_CONTROL_GAINED  -- landing off a flight path; see the taxi rule.

    Both halves are gated on actually being short of something: a reminder to
    restock when there is nothing to buy is noise too. All three settings ship on.
]]
local wasResting = nil

--[[
    A flight path crosses inns and towns the whole way, and the resting flag
    flickers on and off with them. None of those is an arrival -- you cannot
    shop from the back of a gryphon -- so a taxi counts as NOT IN TOWN for as
    long as it lasts, and the recorded state is forced to match. That is what
    leaves a genuine not-resting to resting edge for the landing to trip:
    PLAYER_CONTROL_GAINED re-checks once control is back and UnitOnTaxi has
    cleared, so touching down at a town flight master still reminds you.
]]
local function OnTaxi()
	return UnitOnTaxi("player") and true or false
end

--[[
    The quiet window after a reminder. Arrivals cluster -- a hearth lands you in
    an inn inside a city, and a quick errand in and out of an instance re-crosses
    the same boundary -- and each of those is one trip to town, not three
    reminders. Measured from the reminder, not from the arrival, so a suppressed
    check (nothing short, everything off) never starts the clock.
]]
local REMINDER_COOLDOWN = 60
local lastReminderAt = nil

--[[
    How long to let an arrival settle before reading it. Resting status and the
    bag counts the shortfall is built from both land after the loading screen,
    and after a flight the taxi flag clears a moment behind control returning --
    reading either too early reports the trip you just left.

    A login settles slower than a zone change and waits longer still -- past the
    loading-screen flurry, past the add-on's own post-login work, and well past
    the item queries that fill in each list entry's name and link. The shortfall
    is read at the END of that pause, not the start, so a bag that finishes
    filling in the meantime is counted and a list that is no longer short says
    nothing.
]]
local ARRIVAL_SETTLE_DELAY = 2
local LOGIN_SETTLE_DELAY = 5

--------------------------------------------------------------------------------
-- Arming
--------------------------------------------------------------------------------

--[[
    Nothing reminds until PLAYER_ENTERING_WORLD has said what kind of entry this
    was, because the two kinds want opposite things and the resting events during
    a load arrive too early to tell them apart:

      Logging in IS an arrival -- you have just walked up to the game -- so a
      character who logs in resting gets the reminder. The gate keeps that
      consistent: an inn fires a late PLAYER_UPDATE_RESTING and a city does
      not, so without it the same standing-in-town login would remind you or
      not depending on which side of the door you logged out on.

      A /reload is NOT an arrival. It records where the character already is --
      so the next real arrival still has an edge to trip -- and says nothing,
      which is the whole reason the flag is seeded rather than simply cleared.

    Left false until then, the check does nothing at all rather than recording
    state: a resting event landing mid-load would otherwise consume the very
    transition the login is about to report.
]]
local remindersArmed = false

local function CheckResting()
	if not ns.restockerLoaded or not remindersArmed then
		return
	end

	if OnTaxi() then
		wasResting = false
		return
	end

	local resting = IsResting() and true or false
	if resting == wasResting then
		return
	end
	wasResting = resting

	if not resting then
		return
	end

	local settings = ns.restockSettings
	if not settings then
		return
	end
	if not settings.restockReminderChat then
		return
	end

	if lastReminderAt and (GetTime() - lastReminderAt) < REMINDER_COOLDOWN then
		return
	end

	local groceries = ns.BuildGroceryList()
	if #groceries == 0 then
		return
	end

	lastReminderAt = GetTime()

	--[[
	    Unlike the closing-window reminders, this one keeps its own headline: it
	    is a nudge on arrival rather than a report on the way out. The sound is
	    the reminder's sub-option and plays only with it.
	]]
	ns.PrintRestockShortfall(L["RESTOCKER_TOWN_REMINDER"], settings.restockReminderMode, groceries)

	if settings.restockReminderSound then
		PlaySoundFile(ns.RESTOCK_ALERT_SOUND, "Master")
	end
end

function ns.OnRestockerUpdateResting()
	CheckResting()
end

--[[
    Arriving under your own steam: off a flight path (the common case for this
    event) or out of anything else that took control away. Delayed like the
    loading-screen arrivals, because UnitOnTaxi clears a moment after control
    returns and an immediate read would still call it a flight.
]]
function ns.OnRestockerControlGained()
	C_Timer.After(ARRIVAL_SETTLE_DELAY, CheckResting)
end

--[[
    The one PLAYER_ENTERING_WORLD handler (the dispatcher in Features/Core.lua routes
    one per event from Restocker-Events.lua's handler table), shared by the arrival
    check and the Starter List pop-up.

    isReloadingUi is the only entry that is not an arrival: a login is one, and
    so is any other loading screen -- a hearth, a portal, an instance door. Both
    branches wait out the same settle before touching the resting flag, so a
    /reload cannot be reminded on by a resting event that beat the seeding.
]]
-- Arms the reminders without reporting where the character already is, as a /reload does.
function ns.ArmRestockerReminders()
	wasResting = IsResting() and true or false
	remindersArmed = true
end

function ns.OnRestockerEnteringWorld(isInitialLogin, isReloadingUi)
	local delay = isInitialLogin and LOGIN_SETTLE_DELAY or ARRIVAL_SETTLE_DELAY

	C_Timer.After(delay, function()
		if isReloadingUi then
			ns.ArmRestockerReminders()
			return
		end

		remindersArmed = true
		CheckResting()
	end)

	ns.OnStarterListEnteringWorld(isInitialLogin, isReloadingUi)

	--[[
	    Catch-up for a list that is behind the player's level. A ding is not the
	    only way that happens -- levels gained with the add-on disabled, a list
	    copied off a higher character, a ding that arrived while the list was
	    mid-load -- and without this, a single missed level-up would strand the
	    entry for good, since nothing else re-checks.

	    Safe here: ns.InflateSavedRestockItems has already turned the saved one-line entries back
	    into tables (it runs at PLAYER_LOGIN, ahead of this event), and the check
	    is silent and free once nothing is behind, so the zone-in case costs a walk
	    of the list. A cold item cache at login needs no special handling: the move
	    defers and rides GET_ITEM_INFO_RECEIVED like any other.
	]]
	ns.UpgradeRestockList()
end
