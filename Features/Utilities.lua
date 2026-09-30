local _, ns = ...

--[[
    Utilities -- stateless, cross-cutting helpers used by multiple files: the
    color accessor, cross-client API shims, and small game-state predicates.
    No SavedVariables, and no module state beyond the hidden tooltip Era and
    TBC read tooltip text through.
]]

--------------------------------------------------------------------------------
-- Colors
--------------------------------------------------------------------------------

--[[
    Derived color table and accessor. The raw hex palette lives in
    Data/Data.lua (ns.PALETTE); this file prefixes each entry with the
    |cff escape and exposes ns.GetColor. Append |r at the point of use.
]]
local COLOR_PREFIX = "|cff"

local COLORS = {}
for key, hex in pairs(ns.PALETTE) do
	COLORS[key] = COLOR_PREFIX .. hex
end

ns.COLORS = COLORS

function ns.GetColor(key)
	return COLORS[key] or COLORS.TEXT
end

--[[
    "RRGGBB" to the {r, g, b} 0-1 triple the frame APIs take. Exposed rather than
    kept private to the palette loop below because the Restock window converts
    its own colors (ns.RESTOCKER_WINDOW_COLORS in Data/Data.lua) with it too, so
    every color is kept as the hex it was chosen as, never as hand-divided decimals.
]]
function ns.HexToRGB(hex)
	return {
		r = tonumber(hex:sub(1, 2), 16) / 255,
		g = tonumber(hex:sub(3, 4), 16) / 255,
		b = tonumber(hex:sub(5, 6), 16) / 255,
	}
end

--[[
    The same palette as numbers, for the APIs that take components rather than
    an escape string -- SetTextColor, SetColorTexture, SetVertexColor. Derived
    from ns.PALETTE at load rather than written out again, so a palette edit
    reaches the drawn frames and the coloured text together instead of moving
    one and leaving the other behind.
]]
ns.COLORS_RGB = {}
for key, hex in pairs(ns.PALETTE) do
	ns.COLORS_RGB[key] = ns.HexToRGB(hex)
end

--[[
    A class's color as an escape, for a character's name: the hex from
    ns.CLASS_COLORS (Data/Data.lua) behind the same prefix. nil for no class
    and for one the table does not hold, so each caller says what a name of
    unknown class falls back to. Append |r at the point of use.
]]
function ns.GetClassColor(classToken)
	local hex = classToken and ns.CLASS_COLORS[classToken]
	return hex and (COLOR_PREFIX .. hex) or nil
end

--------------------------------------------------------------------------------
-- Spell Knowledge
--------------------------------------------------------------------------------

--[[
    On Forever the IsSpellKnown and IsPlayerSpell globals exist only in
    Blizzard's deprecation layer, which the loadDeprecationFallbacks CVar
    switches off. C_SpellBook ships on all three clients, so these read it
    directly: ns.IsSpellKnown is exactly the deprecated IsSpellKnown (in the
    spellbook, overrides excluded) and ns.IsPlayerSpell is IsPlayerSpell.
    Callers wanting "does the player know it" test both.
]]
function ns.IsSpellKnown(spellID)
	return C_SpellBook.IsSpellInSpellBook(spellID, Enum.SpellBookSpellBank.Player, false)
end

function ns.IsPlayerSpell(spellID)
	return C_SpellBook.IsSpellKnown(spellID)
end

--------------------------------------------------------------------------------
-- Client Differences
--------------------------------------------------------------------------------

--[[
    One accessor per API the engines differ on, resolved once here so every
    caller agrees and Diagnostics' API Endpoints show which side a client took.
    Each answers on every client, neutrally where the client lacks the API:

      ns.FetchPurchasedBankTabIDs()  Forever's character bank is the C_Bank
                                     tabs the player bought; nil on Era and
                                     TBC, which have BANK_CONTAINER and bags.
      ns.GetNumTalentTabs()          The classic talent trees; nil on Forever,
                                     whose talents are Retail's.
      ns.UnitCharacterPoints(unit)   Unspent talent points; nil on Forever.
      ns.IsSecretValue(value)        Forever's secret values; false elsewhere.
      ns.GetItemTooltipLines(itemID) A tooltip's lines as { left, right }
      ns.GetSpellTooltipLines(spellID) text pairs: C_TooltipInfo on Forever,
                                     a hidden tooltip on Era and TBC.
      ns.GetPlayerFullName()         This character's name: the first name and
                                     surname on Forever, the one name on Era
                                     and TBC.
]]
if C_Bank and C_Bank.FetchPurchasedBankTabIDs then
	function ns.FetchPurchasedBankTabIDs()
		return C_Bank.FetchPurchasedBankTabIDs(Enum.BankType.Character)
	end
else
	function ns.FetchPurchasedBankTabIDs()
		return nil
	end
end

if GetNumTalentTabs then
	ns.GetNumTalentTabs = GetNumTalentTabs
else
	function ns.GetNumTalentTabs()
		return nil
	end
end

if UnitCharacterPoints then
	ns.UnitCharacterPoints = UnitCharacterPoints
else
	function ns.UnitCharacterPoints()
		return nil
	end
end

if issecretvalue then
	ns.IsSecretValue = issecretvalue
else
	function ns.IsSecretValue()
		return false
	end
end

--[[
    Only Validate Data reads tooltip text: feature code keeps what a tooltip
    says about an ID as static data. Forever's C_TooltipInfo returns the lines
    before any other add-on's tooltip hooks can add to them. Era and TBC ship
    no C_TooltipInfo getters, so they fill a hidden tooltip, created on first
    use, and read its lines back.
]]
if C_TooltipInfo and C_TooltipInfo.GetItemByID then
	local function DataLines(data)
		local lines = {}
		for _, line in ipairs(data and data.lines or {}) do
			lines[#lines + 1] = { line.leftText, line.rightText }
		end
		return lines
	end

	function ns.GetItemTooltipLines(itemID)
		return DataLines(C_TooltipInfo.GetItemByID(itemID))
	end

	function ns.GetSpellTooltipLines(spellID)
		return DataLines(C_TooltipInfo.GetSpellByID(spellID))
	end
else
	local SCAN_TOOLTIP_NAME = "ConnoisseurScanTooltip"
	local scanTooltip

	-- A hidden right-hand string still holds text from an earlier tooltip, so only a shown one counts.
	local function ScanLines(setter, id)
		scanTooltip = scanTooltip or CreateFrame("GameTooltip", SCAN_TOOLTIP_NAME, nil, "GameTooltipTemplate")
		scanTooltip:SetOwner(UIParent, "ANCHOR_NONE")
		scanTooltip[setter](scanTooltip, id)
		local lines = {}
		for index = 1, scanTooltip:NumLines() do
			local right = _G[SCAN_TOOLTIP_NAME .. "TextRight" .. index]
			lines[index] = {
				_G[SCAN_TOOLTIP_NAME .. "TextLeft" .. index]:GetText(),
				right:IsShown() and right:GetText() or nil,
			}
		end
		scanTooltip:Hide()
		return lines
	end

	function ns.GetItemTooltipLines(itemID)
		return ScanLines("SetItemByID", itemID)
	end

	function ns.GetSpellTooltipLines(spellID)
		return ScanLines("SetSpellByID", spellID)
	end
end

--[[
    A Forever character has a first name and a surname, unique together across
    the region, and the client hands them back as two values. Only a client
    with that system has RegionalUniqueNamesEnabled, and what it writes between
    the two is a constant of its own. On Era and TBC a name's second value is a
    realm, which for the player is nil.

    UnitNameUnmodified rather than UnitName, as AceDB keys its own records:
    this is the name a character is saved under, so it must not follow
    anything that restyles names for display.

    The surname is added only to a first value that does not already end with
    it. An earlier beta build's UnitName gave the whole name first, and saved
    files from it hold keys in that shape.
]]
if RegionalUniqueNamesEnabled then
	local separatorConstants = Constants.CharacterNameSeparatorConsts
	local SURNAME_SEPARATOR = separatorConstants and separatorConstants.CHARACTERNAME_SURNAME_SEPARATOR or " "

	function ns.GetPlayerFullName()
		local name, surname = UnitNameUnmodified("player")
		if name and surname and surname ~= "" and RegionalUniqueNamesEnabled() then
			local ending = SURNAME_SEPARATOR .. surname
			if name:sub(-#ending) ~= ending then
				name = name .. ending
			end
		end
		return name
	end
else
	function ns.GetPlayerFullName()
		return (UnitName("player"))
	end
end

--------------------------------------------------------------------------------
-- Character Profile Names
--------------------------------------------------------------------------------

--[[
    AceDB keeps each character's profile choice in the saved file's
    profileKeys, under a name it builds for the character, and a new character
    gets a profile of that same name. On Era and TBC it is "Name - Realm". On
    WoW Forever, where a whole name is unique across the region, it is the
    first name and surname with a space between and no realm (AceDB-3.0 from
    minor 39, which is the copy in Includes/Libraries). These three are the
    only places that spell the format out:

      ns.GetCharacterProfileName()
          This character's. nil while the client has not named the character,
          when it answers with its "Unknown" placeholder.
      ns.ProfileNameForCharacter(name, realm)
          Any character's, from its whole name and its realm as the client
          writes them.
      ns.SplitCharacterProfileName(profileKey)
          The name and realm back out of one; no realm on Forever. nil for a
          key that names no character: one written while the client had not
          named the character, or on Forever the first name and rule set an
          AceDB older than minor 39 wrote ("Name - PvE").

    This is not the add-on's own character key (ns.GetCharacterKey,
    "Name-Realm" with the realm's spaces closed up), which everything the
    add-on saves by character is keyed by.
]]
local function HasRegionalNames()
	return RegionalUniqueNamesEnabled ~= nil and RegionalUniqueNamesEnabled()
end

function ns.ProfileNameForCharacter(name, realm)
	if HasRegionalNames() then
		return name
	end
	return name .. " - " .. realm
end

function ns.GetCharacterProfileName()
	local name, surname = (UnitNameUnmodified or UnitName)("player")
	if not name or name == UNKNOWNOBJECT then
		return nil
	end
	if HasRegionalNames() then
		return surname and (name .. " " .. surname) or name
	end
	return name .. " - " .. GetRealmName()
end

function ns.SplitCharacterProfileName(profileKey)
	local name, realm
	if not HasRegionalNames() then
		name, realm = profileKey:match("^(.-) %- (.+)$")
	elseif not profileKey:find(" - ", 1, true) then
		name = profileKey
	end
	if not name or name == UNKNOWNOBJECT then
		return nil
	end
	return name, realm
end

--------------------------------------------------------------------------------
-- Quest, Skill, Pet & Merchant API Shims
--------------------------------------------------------------------------------

--[[
    Forever runs on the Retail client, which has dropped these legacy readers
    for namespaced ones that return a table; Era and TBC have only the legacy
    globals. Each shim gives its call sites one shape on all three clients: the
    legacy return order, except the quest reader (a quest ID, nil for a header
    line) and the pet diet reader (a list). The merchant reader's goes as far as
    the eighth value, whether the slot costs something besides gold.

    Spell names need no shim: every call site reads C_Spell.GetSpellName, which
    all three clients ship, and Forever has no GetSpellInfo.
]]
if C_QuestLog and C_QuestLog.GetInfo then
	ns.GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries

	function ns.GetQuestLogQuestID(questIndex)
		local info = C_QuestLog.GetInfo(questIndex)
		if info and not info.isHeader then
			return info.questID
		end
	end
else
	ns.GetNumQuestLogEntries = GetNumQuestLogEntries

	function ns.GetQuestLogQuestID(questIndex)
		local _, _, _, isHeader, _, _, _, questID = GetQuestLogTitle(questIndex)
		if not isHeader then
			return questID
		end
	end
end

if C_SkillInfo and C_SkillInfo.GetSkillLineInfo then
	ns.GetNumSkillLines = C_SkillInfo.GetNumSkillLines

	function ns.GetSkillLineInfo(skillIndex)
		local info = C_SkillInfo.GetSkillLineInfo(skillIndex)
		if info then
			return info.name, info.isHeader, not info.isCollapsed, info.rank
		end
	end
else
	ns.GetNumSkillLines = GetNumSkillLines
	ns.GetSkillLineInfo = GetSkillLineInfo
end

if C_PetInfo and C_PetInfo.GetPetFoodTypes then
	ns.GetPetFoodTypes = C_PetInfo.GetPetFoodTypes
else
	function ns.GetPetFoodTypes()
		return { GetPetFoodTypes() }
	end
end

if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
	function ns.GetMerchantItemInfo(index)
		local info = C_MerchantFrame.GetItemInfo(index)
		if info then
			return info.name,
				info.texture,
				info.price,
				info.stackCount,
				info.numAvailable,
				info.isPurchasable,
				info.isUsable,
				info.hasExtendedCost
		end
	end
else
	ns.GetMerchantItemInfo = GetMerchantItemInfo
end

--------------------------------------------------------------------------------
-- Game-State Predicates
--------------------------------------------------------------------------------

--[[
    The level cap on this client, which the Leveling and Max Level modes
    compare against: the smaller of the expansion's cap and the player's own,
    the rule Blizzard's GameRulesUtil.GetEffectiveMaxLevelForPlayer applies on
    all three clients, which ship both readers. Show Connoisseur Context prints
    what each answers.
]]
function ns.GetMaxPlayerLevel()
	return math.min(GetMaxLevelForPlayerExpansion(), GetMaxPlayerLevel())
end

--[[
    The group-mode settings' shared test, behind every when-to-use dropdown
    (Buff Food, Scroll Buffs, Pet Food Buffs, and Use Conjured Food & Water
    First), which all offer the same six modes. Every group read here must
    stay inside the group signature (ns.GroupSignatureChanged), or a join or
    leave never rescans. The level modes need no signature: PLAYER_LEVEL_UP
    already refreshes ns.cachedPlayerLevel and rebuilds every macro. An
    unknown mode counts as active.
]]
function ns.IsModeActive(mode)
	if mode == "always" then
		return true
	end
	if mode == "party" then
		return IsInGroup()
	end
	if mode == "raid" then
		return IsInRaid()
	end
	if mode == "solo" then
		return not IsInGroup()
	end
	if mode == "leveling" or mode == "maxlevel" then
		local atMaxLevel = (ns.cachedPlayerLevel or UnitLevel("player")) >= ns.GetMaxPlayerLevel()
		if mode == "maxlevel" then
			return atMaxLevel
		end
		return not atMaxLevel
	end
	return true
end

function ns.KnowsAny(spellList)
	if not spellList then
		return false
	end
	for _, data in ipairs(spellList) do
		if ns.IsSpellKnown(data[1]) or ns.IsPlayerSpell(data[1]) then
			return true
		end
	end
	return false
end
