local _, ns = ...
local L = ns.L
local GetColor = ns.GetColor

--------------------------------------------------------------------------------
-- Feedback & Support Panel
--------------------------------------------------------------------------------

local PARAGRAPHS = {
	"OPTIONS_LEVEL_UP_INTRO",
	"OPTIONS_LEVEL_UP_WAYS",
	"OPTIONS_LEVEL_UP_FEEDBACK",
	"OPTIONS_LEVEL_UP_FRIEND",
	"OPTIONS_LEVEL_UP_CURSEFORGE",
	"OPTIONS_LEVEL_UP_GITHUB",
	"OPTIONS_LEVEL_UP_THANKS",
}

-- { captionKey, linkKey }, in display order
local LINKS = {
	{ "OPTIONS_DISCORD", "DISCORD" },
	{ "OPTIONS_CURSEFORGE", "CURSEFORGE" },
	{ "OPTIONS_WAGO", "WAGO" },
	{ "OPTIONS_GITHUB", "GITHUB" },
}

-- The label is one short word and the box holds a full URL, so the label cell is narrower than a normal row's.
local LINK_LABEL_WIDTH = 0.6

function ns.BuildFeedbackSupportOptions()
	local args = {}
	local order = 0

	for index, key in ipairs(PARAGRAPHS) do
		if index > 1 then
			order = order + 1
			args["spaceParagraph" .. index] = ns.OptionsSpacer(order)
		end
		order = order + 1
		args["descParagraph" .. index] = ns.OptionsDesc(L[key], order)
	end

	order = order + 1
	args.spaceLinks0 = ns.OptionsSpacer(order)
	order = order + 1
	args.headerLinks = ns.OptionsHeader(L["OPTIONS_FEEDBACK_LINKS_HEADER"], order)

	for index, link in ipairs(LINKS) do
		local captionKey, linkKey = link[1], link[2]
		order = order + 1
		args["spaceLink" .. index] = ns.OptionsSpacer(order)
		order = order + 1
		args["labelLink" .. index] =
			ns.OptionsRowLabel(GetColor("TITLE") .. L[captionKey] .. "|r", order, LINK_LABEL_WIDTH)
		order = order + 1
		args["urlLink" .. index] = {
			type = "input",
			name = "",
			order = order,
			width = ns.OPTIONS_ROW_WIDTH - LINK_LABEL_WIDTH,
			get = function()
				return ns.LINKS[linkKey]
			end,
			set = function() end,
		}
	end

	order = order + 1
	args.spaceCopyLink = ns.OptionsSpacer(order)
	order = order + 1
	args.descCopyLink = ns.OptionsDesc(GetColor("HELP") .. L["OPTIONS_COPY_LINK"] .. "|r", order)

	args.spaceVersion = {
		type = "description",
		name = " ",
		width = "full",
		order = 998,
	}
	args.versionLine = {
		type = "description",
		name = GetColor("INFO") .. L["OPTIONS_VERSION"]:format(ns.Version) .. "|r",
		fontSize = "medium",
		order = 999,
	}

	return {
		name = L["OPTIONS_LEVEL_UP_TITLE"],
		type = "group",
		args = args,
	}
end
