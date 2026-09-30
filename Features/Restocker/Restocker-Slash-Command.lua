local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Restock List Slash Command
--------------------------------------------------------------------------------

--[[
    One slash-help line: the command in C_INFO, then the localized description
    (TEXT restored for the tail, since ns.PrintMessage wraps the whole body in TEXT).
    The subcommand words stay English, since they are what the parser below matches.
]]
local function SlashHelpLine(subcommand, description)
	return GetColor("INFO")
		.. L["RESTOCKER_COMMAND"]
		.. " "
		.. subcommand
		.. "|r"
		.. GetColor("TEXT")
		.. "  "
		.. description
end

local NAME = L["RESTOCKER_HELP_NAME_PLACEHOLDER"]

local RESTOCKER_COMMANDS = {
	show = SlashHelpLine("show", L["RESTOCKER_COMMAND_DESCRIPTION"]),
	config = SlashHelpLine("config", L["OPTIONS_COMMAND_DESCRIPTION"]),
	profile = {
		add = SlashHelpLine("profile add " .. NAME, L["RESTOCKER_HELP_PROFILE_ADD"]),
		delete = SlashHelpLine("profile delete " .. NAME, L["RESTOCKER_HELP_PROFILE_DELETE"]),
		rename = SlashHelpLine("profile rename " .. NAME, L["RESTOCKER_HELP_PROFILE_RENAME"]),
		copy = SlashHelpLine("profile copy " .. NAME, L["RESTOCKER_HELP_PROFILE_COPY"]),
		use = SlashHelpLine("profile use " .. NAME, L["RESTOCKER_HELP_PROFILE_USE"]),
	},
}

-- The order help prints in: the table above is keyed for lookups, and pairs() would shuffle it.
local COMMAND_ORDER = { "show", "config", "profile" }
local PROFILE_SUBCOMMAND_ORDER = { "add", "delete", "rename", "copy", "use" }

local function PrintProfileHelp()
	for _, subcommand in ipairs(PROFILE_SUBCOMMAND_ORDER) do
		ns.PrintMessage(RESTOCKER_COMMANDS.profile[subcommand])
	end
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

function ns.HandleRestockerCommand(args)
	local command, rest = strsplit(" ", args, 2)
	command = command:lower()

	if command == "show" then
		ns.ShowRestockWindow()
	elseif command == "profile" then
		if rest == "" or rest == nil then
			PrintProfileHelp()
			return
		end

		local subcommand, name = strsplit(" ", rest, 2)

		--[[
		    Every /crs profile subcommand needs a name; print its usage line instead of
		    erroring on a nil table key when the name is missing.
		]]
		if (name == nil or name == "") and RESTOCKER_COMMANDS.profile[subcommand] then
			ns.PrintMessage(RESTOCKER_COMMANDS.profile[subcommand])
			return
		end

		if subcommand == "add" then
			ns.AddRestockList(name)
		elseif subcommand == "delete" then
			ns.DeleteRestockList(name)
		elseif subcommand == "rename" then
			ns.RenameCurrentRestockList(name)
		elseif subcommand == "use" then
			ns.SwitchRestockList(name)
		elseif subcommand == "copy" then
			ns.CopyIntoCurrentRestockList(name)
		end
	elseif command == "help" then
		for _, eachCommand in ipairs(COMMAND_ORDER) do
			if eachCommand == "profile" then
				PrintProfileHelp()
			else
				ns.PrintMessage(RESTOCKER_COMMANDS[eachCommand])
			end
		end
		return
	elseif command == "config" then
		ns.OpenOptionsPanel()
		return
	else
		ns.ToggleRestockWindow()
	end
	ns.UpdateRestockList()
end
