local _, ns = ...

local GetClientHeader = ns.GetDiagnosticClientHeader
local CountKeys = ns.CountDiagnosticKeys

--------------------------------------------------------------------------------
-- API Endpoints
--------------------------------------------------------------------------------

--[[
    Existence and shape checks only: read-only, no side effects, no protected
    calls. One row per WoW API the add-on depends on, scanned from across
    Features/ and Options/. Every API the code guards for existence (e.g.
    C_Bank.FetchPurchasedBankTabIDs) or reaches through a modern->legacy fallback gets a
    row of its own — modern and legacy listed separately — so the manifest stays
    one-to-one with the code's guards and the report shows exactly what each
    client provides.
]]
ns.DIAGNOSTIC_API_CHECKS = {
	-- { label, testFunction }
	{
		"C_AddOns.GetAddOnMetadata",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnMetadata) == "function"
		end,
	},
	{
		"C_AddOns.GetAddOnInfo",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetAddOnInfo) == "function"
		end,
	},
	{
		"C_AddOns.GetNumAddOns",
		function()
			return type(C_AddOns) == "table" and type(C_AddOns.GetNumAddOns) == "function"
		end,
	},
	-- Decides Season of Discovery's data folder (Data/Flavor.lua), which is only ever asked on Classic Era.
	{
		"C_Seasons.GetActiveSeason (Classic Era only)",
		function()
			return type(C_Seasons) == "table" and type(C_Seasons.GetActiveSeason) == "function"
		end,
	},
	--[[
	    C_Container is the container surface on all three target clients, so both
	    readers are probed there and nowhere else. Neither carries a legacy
	    fallback nor may be given one, so there is no legacy row to pair with
	    either.
	]]
	{
		"C_Container.GetContainerNumSlots",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerNumSlots) == "function"
		end,
	},
	{
		"C_Container.GetContainerItemInfo",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerItemInfo) == "function"
		end,
	},
	--[[
	    Every spell name the macros cast and the panels show, on every client:
	    without it no /cast line can be written.
	]]
	{
		"C_Spell.GetSpellName",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellName) == "function"
		end,
	},
	-- The Forsaken Cannibalize line reads the spell's cooldown (Tools-Forsaken.lua).
	{
		"C_Spell.GetSpellCooldown",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellCooldown) == "function"
		end,
	},
	{
		"C_Map.GetBestMapForUnit",
		function()
			return type(C_Map) == "table" and type(C_Map.GetBestMapForUnit) == "function"
		end,
	},
	--[[
	    The route ns.OpenOptionsPanel docks the panel with
	    (Options/Options.lua). A client that does not provide it falls through
	    to AceConfigDialog, which opens a standalone floating window instead of
	    docking -- so a report where this row FAILs is the one that explains a
	    panel the player says opened in the wrong place.
	]]
	{
		"Settings.OpenToCategory",
		function()
			return type(Settings) == "table" and type(Settings.OpenToCategory) == "function"
		end,
	},
	--[[
	    A frame method, read off UIParent because every frame shares one
	    metatable. The Restocker window calls SetResizeBounds unconditionally as
	    it is built, so a FAIL here means that window errors when it opens.
	]]
	{
		"Frame:SetResizeBounds",
		function()
			return type(UIParent.SetResizeBounds) == "function"
		end,
	},
	{
		"IsInInstance",
		function()
			return type(IsInInstance) == "function"
		end,
	},
	--[[
	    All three load-bearing for the Restocker's entering-town reminder:
	    IsResting is the signal it keys off, UnitOnTaxi is what keeps a flight
	    path over a town from counting as arriving in one, and PlaySoundFile
	    plays the optional alert.
	]]
	{
		"IsResting",
		function()
			return type(IsResting) == "function"
		end,
	},
	{
		"UnitOnTaxi",
		function()
			return type(UnitOnTaxi) == "function"
		end,
	},
	{
		"PlaySoundFile",
		function()
			return type(PlaySoundFile) == "function"
		end,
	},
	{
		"C_Item.GetItemCount",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemCount) == "function"
		end,
	},
	{
		"C_Item.GetItemInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfo) == "function"
		end,
	},
	{
		"C_Item.GetItemQualityColor",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemQualityColor) == "function"
		end,
	},
	-- Validate Data: item existence, and the instant fields every item row carries.
	{
		"C_Item.DoesItemExistByID",
		function()
			return type(C_Item) == "table" and type(C_Item.DoesItemExistByID) == "function"
		end,
	},
	{
		"C_Item.GetItemInfoInstant",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemInfoInstant) == "function"
		end,
	},
	--[[
	    Called by ns.WarmItemCache (Options/Options-Utilities.lua): without it an
	    options item list can only show ids the client already cached, so the
	    rows sit on their loading text until something else pulls the data.
	]]
	{
		"C_Item.RequestLoadItemDataByID",
		function()
			return type(C_Item) == "table" and type(C_Item.RequestLoadItemDataByID) == "function"
		end,
	},
	-- Validate Data's other item columns.
	{
		"C_Item.GetItemSpell",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemSpell) == "function"
		end,
	},
	{
		"C_Item.GetDetailedItemLevelInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetDetailedItemLevelInfo) == "function"
		end,
	},
	-- Validate Data's stat read goes through ns.GetItemStats, which takes whichever of the pair this client ships.
	{
		"C_Item.GetItemStats",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemStats) == "function"
		end,
	},
	{
		"GetItemStats (legacy)",
		function()
			return type(GetItemStats) == "function"
		end,
	},
	{
		"C_Item.GetItemClassInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemClassInfo) == "function"
		end,
	},
	{
		"C_Item.GetItemSubClassInfo",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemSubClassInfo) == "function"
		end,
	},
	{
		"GetMacroIndexByName",
		function()
			return type(GetMacroIndexByName) == "function"
		end,
	},
	{
		"CreateMacro",
		function()
			return type(CreateMacro) == "function"
		end,
	},
	{
		"EditMacro",
		function()
			return type(EditMacro) == "function"
		end,
	},
	{
		"DeleteMacro",
		function()
			return type(DeleteMacro) == "function"
		end,
	},
	{
		"GetMacroBody",
		function()
			return type(GetMacroBody) == "function"
		end,
	},
	{
		"GetNumMacros",
		function()
			return type(GetNumMacros) == "function"
		end,
	},
	--[[
	    The shims in Utilities that Forever needs: each client should PASS
	    exactly one side of every pair -- the namespaced reader on Forever, the
	    legacy global on Era and TBC.
	]]
	{
		"C_PetInfo.GetPetFoodTypes",
		function()
			return type(C_PetInfo) == "table" and type(C_PetInfo.GetPetFoodTypes) == "function"
		end,
	},
	{
		"GetPetFoodTypes (legacy)",
		function()
			return type(GetPetFoodTypes) == "function"
		end,
	},
	{
		"C_SkillInfo.GetNumSkillLines",
		function()
			return type(C_SkillInfo) == "table" and type(C_SkillInfo.GetNumSkillLines) == "function"
		end,
	},
	{
		"C_SkillInfo.GetSkillLineInfo",
		function()
			return type(C_SkillInfo) == "table" and type(C_SkillInfo.GetSkillLineInfo) == "function"
		end,
	},
	{
		"GetNumSkillLines (legacy)",
		function()
			return type(GetNumSkillLines) == "function"
		end,
	},
	{
		"GetSkillLineInfo (legacy)",
		function()
			return type(GetSkillLineInfo) == "function"
		end,
	},
	-- The profession readers name their skill lines through this, on every client.
	{
		"C_TradeSkillUI.GetTradeSkillDisplayName",
		function()
			return type(C_TradeSkillUI) == "table" and type(C_TradeSkillUI.GetTradeSkillDisplayName) == "function"
		end,
	},
	{
		"C_QuestLog.GetNumQuestLogEntries",
		function()
			return type(C_QuestLog) == "table" and type(C_QuestLog.GetNumQuestLogEntries) == "function"
		end,
	},
	{
		"C_QuestLog.GetInfo",
		function()
			return type(C_QuestLog) == "table" and type(C_QuestLog.GetInfo) == "function"
		end,
	},
	{
		"GetNumQuestLogEntries (legacy)",
		function()
			return type(GetNumQuestLogEntries) == "function"
		end,
	},
	{
		"GetQuestLogTitle (legacy)",
		function()
			return type(GetQuestLogTitle) == "function"
		end,
	},
	{
		"C_MerchantFrame.GetItemInfo",
		function()
			return type(C_MerchantFrame) == "table" and type(C_MerchantFrame.GetItemInfo) == "function"
		end,
	},
	{
		"GetMerchantItemInfo (legacy)",
		function()
			return type(GetMerchantItemInfo) == "function"
		end,
	},
	--[[
	    The level cap behind the Leveling and Max Level modes (ns.GetMaxPlayerLevel
	    in Utilities), the smaller of these two, which all three clients ship.
	    Connoisseur Context prints what each one answers.
	]]
	{
		"GetMaxPlayerLevel",
		function()
			return type(GetMaxPlayerLevel) == "function"
		end,
	},
	{
		"GetMaxLevelForPlayerExpansion",
		function()
			return type(GetMaxLevelForPlayerExpansion) == "function"
		end,
	},
	-- Forever's bank is its purchased tabs; Era and TBC read BANK_CONTAINER and the bank bags instead.
	{
		"C_Bank.FetchPurchasedBankTabIDs",
		function()
			return type(C_Bank) == "table" and type(C_Bank.FetchPurchasedBankTabIDs) == "function"
		end,
	},
	{
		"BANK_CONTAINER (legacy)",
		function()
			return type(BANK_CONTAINER) == "number"
		end,
	},
	{
		"C_UnitAuras.GetBuffDataByIndex",
		function()
			return type(C_UnitAuras) == "table" and type(C_UnitAuras.GetBuffDataByIndex) == "function"
		end,
	},
	{
		"C_Secrets.ShouldAurasBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldAurasBeSecret) == "function"
		end,
	},
	{
		"C_Secrets.CanCompareUnitTokens",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.CanCompareUnitTokens) == "function"
		end,
	},
	{
		"C_Secrets.ShouldCooldownsBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldCooldownsBeSecret) == "function"
		end,
	},
	-- Behind ns.IsSecretValue, which answers false where it FAILs (Era and TBC).
	{
		"issecretvalue",
		function()
			return type(issecretvalue) == "function"
		end,
	},
	--[[
	    Behind ns.GetPlayerFullName, which a character is saved and shown under.
	    RegionalUniqueNamesEnabled is Forever's alone: where it FAILs (Era and
	    TBC) a character has the one name and UnitNameUnmodified is never asked.
	    A FAIL on Forever means characters are keyed by first name only again.
	]]
	{
		"RegionalUniqueNamesEnabled",
		function()
			return type(RegionalUniqueNamesEnabled) == "function"
		end,
	},
	{
		"UnitNameUnmodified",
		function()
			return type(UnitNameUnmodified) == "function"
		end,
	},
	--[[
	    The Readiness Report's surface. Every one of these is reached only when
	    its own switch is on, and nothing isolates a probe, so a missing one
	    stops the whole report -- and does it silently, since a client with
	    scriptErrors off swallows the error. A FAIL here is the fastest
	    explanation for "I turned that on and the report went quiet". The
	    exceptions are GetNumTalentTabs and UnitCharacterPoints, which the
	    probes reach through ns accessors that answer nil where the client lacks
	    them: they FAIL on Forever as expected, and their lines never show there.
	]]
	{
		"GetWeaponEnchantInfo",
		function()
			return type(GetWeaponEnchantInfo) == "function"
		end,
	},
	{
		"GetInventoryItemDurability",
		function()
			return type(GetInventoryItemDurability) == "function"
		end,
	},
	{
		"GetInventoryItemLink",
		function()
			return type(GetInventoryItemLink) == "function"
		end,
	},
	{
		"GetNumTalentTabs",
		function()
			return type(GetNumTalentTabs) == "function"
		end,
	},
	{
		"C_SpecializationInfo.GetSpecializationInfo",
		function()
			return type(C_SpecializationInfo) == "table"
				and type(C_SpecializationInfo.GetSpecializationInfo) == "function"
		end,
	},
	{
		"UnitCharacterPoints",
		function()
			return type(UnitCharacterPoints) == "function"
		end,
	},
	{
		"UnitIsPVP",
		function()
			return type(UnitIsPVP) == "function"
		end,
	},
	{
		"C_Container.GetItemCooldown",
		function()
			return type(C_Container) == "table" and type(C_Container.GetItemCooldown) == "function"
		end,
	},
	-- Validate Data reads spells through these.
	{
		"C_Spell.RequestLoadSpellData",
		function()
			return type(C_Spell) == "table" and type(C_Spell.RequestLoadSpellData) == "function"
		end,
	},
	{
		"C_Spell.GetSpellDescription",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellDescription) == "function"
		end,
	},
	{
		"C_Spell.IsSpellDataCached",
		function()
			return type(C_Spell) == "table" and type(C_Spell.IsSpellDataCached) == "function"
		end,
	},
	--[[
	    Validate Data's tooltip text (ns.GetTooltipLines in Utilities): Forever
	    reads the C_TooltipInfo pair, and Era and TBC a hidden scan tooltip,
	    probed through the GameTooltip methods it inherits so the check creates
	    nothing. Forever passes both, since its tooltips are built from that
	    same data.
	]]
	{
		"C_TooltipInfo.GetItemByID",
		function()
			return type(C_TooltipInfo) == "table" and type(C_TooltipInfo.GetItemByID) == "function"
		end,
	},
	{
		"C_TooltipInfo.GetSpellByID",
		function()
			return type(C_TooltipInfo) == "table" and type(C_TooltipInfo.GetSpellByID) == "function"
		end,
	},
	{
		"Hidden scan tooltip (legacy)",
		function()
			return type(CreateFrame) == "function"
				and type(GameTooltip) == "table"
				and type(GameTooltip.SetHyperlink) == "function"
				and type(GameTooltip.NumLines) == "function"
		end,
	},
	{
		"C_SpellBook.IsSpellInSpellBook",
		function()
			return type(C_SpellBook) == "table" and type(C_SpellBook.IsSpellInSpellBook) == "function"
		end,
	},
	{
		"C_SpellBook.IsSpellKnown",
		function()
			return type(C_SpellBook) == "table" and type(C_SpellBook.IsSpellKnown) == "function"
		end,
	},
	{
		"SecureCmdOptionParse",
		function()
			return type(SecureCmdOptionParse) == "function"
		end,
	},
	{
		"C_Timer.After",
		function()
			return type(C_Timer) == "table" and type(C_Timer.After) == "function"
		end,
	},
	{
		"C_EventUtils.IsEventValid",
		function()
			return type(C_EventUtils) == "table" and type(C_EventUtils.IsEventValid) == "function"
		end,
	},
	-- Restocker's load-bearing surface (merchant buying and bank restocking).
	{
		"GetMerchantNumItems",
		function()
			return type(GetMerchantNumItems) == "function"
		end,
	},
	{
		"GetMerchantItemLink",
		function()
			return type(GetMerchantItemLink) == "function"
		end,
	},
	{
		"BuyMerchantItem",
		function()
			return type(BuyMerchantItem) == "function"
		end,
	},
	{
		"UnitReaction",
		function()
			return type(UnitReaction) == "function"
		end,
	},
	{
		"GetNetStats",
		function()
			return type(GetNetStats) == "function"
		end,
	},
	{
		"C_Container.GetContainerNumFreeSlots",
		function()
			return type(C_Container) == "table" and type(C_Container.GetContainerNumFreeSlots) == "function"
		end,
	},
	{
		"C_Container.PickupContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.PickupContainerItem) == "function"
		end,
	},
	{
		"C_Container.SplitContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.SplitContainerItem) == "function"
		end,
	},
	{
		"C_Container.UseContainerItem",
		function()
			return type(C_Container) == "table" and type(C_Container.UseContainerItem) == "function"
		end,
	},
	{
		"GetCursorInfo",
		function()
			return type(GetCursorInfo) == "function"
		end,
	},
	{
		"CursorHasItem",
		function()
			return type(CursorHasItem) == "function"
		end,
	},
	{
		"ClearCursor",
		function()
			return type(ClearCursor) == "function"
		end,
	},
	-- The Gold Reserve's floor is checked against this before every merchant purchase.
	{
		"GetMoney",
		function()
			return type(GetMoney) == "function"
		end,
	},
	-- The Restocker sorts bag slots by the family of what each holds (Restocker-Bags.lua).
	{
		"C_Item.GetItemFamily",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemFamily) == "function"
		end,
	},
	-- The mini-map icon, the options item rows and the Restock List's footer draw item icons through this.
	{
		"C_Item.GetItemIconByID",
		function()
			return type(C_Item) == "table" and type(C_Item.GetItemIconByID) == "function"
		end,
	},
	-- The rank text a Warlock's Healthstone /cast line carries (Smart-Spell.lua).
	{
		"C_Spell.GetSpellSubtext",
		function()
			return type(C_Spell) == "table" and type(C_Spell.GetSpellSubtext) == "function"
		end,
	},
	--[[
	    The Forsaken Cannibalize line (Tools-Forsaken.lua): the target's creature
	    type, and the two C_Secrets questions asked before the type and the
	    cooldown are read. Where these FAIL, the line never shows.
	]]
	{
		"UnitCreatureType",
		function()
			return type(UnitCreatureType) == "function"
		end,
	},
	{
		"C_Secrets.ShouldUnitIdentityBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldUnitIdentityBeSecret) == "function"
		end,
	},
	{
		"C_Secrets.ShouldSpellCooldownBeSecret",
		function()
			return type(C_Secrets) == "table" and type(C_Secrets.ShouldSpellCooldownBeSecret) == "function"
		end,
	},
	-- The Macros panel's Night Elf header names the race through this.
	{
		"C_CreatureInfo.GetRaceInfo",
		function()
			return type(C_CreatureInfo) == "table" and type(C_CreatureInfo.GetRaceInfo) == "function"
		end,
	},
	--[[
	    The Inventory Report's way into item tooltips (Inventory-Report.lua):
	    Forever hands every item tooltip to a TooltipDataProcessor post-call,
	    and Era and TBC fire OnTooltipSetItem instead. Each client should PASS
	    one side; where both FAIL the tooltip block never shows.
	]]
	{
		"TooltipDataProcessor.AddTooltipPostCall",
		function()
			return type(TooltipDataProcessor) == "table" and type(TooltipDataProcessor.AddTooltipPostCall) == "function"
		end,
	},
	{
		"GameTooltip OnTooltipSetItem (legacy)",
		function()
			return type(GameTooltip) == "table"
				and type(GameTooltip.HasScript) == "function"
				and GameTooltip:HasScript("OnTooltipSetItem") == true
		end,
	},
	-- The standing labels in the Restock List's reputation column (ns.GetStandingLabel).
	{
		"GetText",
		function()
			return type(GetText) == "function"
		end,
	},
	-- The Taint Log box's read and its two buttons.
	{
		"GetCVar",
		function()
			return type(GetCVar) == "function"
		end,
	},
	{
		"SetCVar",
		function()
			return type(SetCVar) == "function"
		end,
	},
}

--------------------------------------------------------------------------------
-- Connoisseur Context
--------------------------------------------------------------------------------

-- The add-on's own example reports, appended to the shared Event Log intro.
ns.DiagnosticsStrings.EVENT_LOG_EXAMPLES = "The best tool for 'my macro didn't update' reports."

--[[
    The spells the add-on gates on, for Connoisseur Context's spell knowledge
    lines. A spell this client's data folder doesn't carry has a nil id and
    gets no line.
]]
ns.DIAGNOSTIC_SPELLS = {
	-- { spellID, label }
	{ ns.MISSING_SPELL_MESSAGE_IDS.noConjureFood, "Conjure Food (Rank 1)" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noConjureWater, "Conjure Water (Rank 1)" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noConjureManaGem, "Conjure Mana Agate" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noRitualOfRefreshment, "Ritual of Refreshment" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noCreateHealthstone, "Create Healthstone (Minor)" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noCreateSoulstone, "Create Soulstone (Minor)" },
	{ ns.MISSING_SPELL_MESSAGE_IDS.noRitualOfSouls, "Ritual of Souls" },
	{ ns.CALL_PET_SPELL_ID, "Call Pet" },
	{ ns.FEED_PET_SPELL_ID, "Feed Pet" },
	{ ns.MEND_PET_SPELL_ID, "Mend Pet" },
	{ ns.REVIVE_PET_SPELL_ID, "Revive Pet" },
	{ ns.DISMISS_PET_SPELL_ID, "Dismiss Pet" },
	{ ns.SHADOWMELD_SPELL_ID, "Shadowmeld" },
	{ ns.CANNIBALIZE_SPELL_ID, "Cannibalize" },
	{ ns.POISONS_SPELL_ID, "Poisons" },
	{ ns.STEALTH_SPELL_ID, "Stealth" },
	{ ns.GOBLIN_ENGINEER_SPELL_ID, "Goblin Engineer" },
	{ ns.DRUID_BEAR_FORM_SPELL_ID, "Bear Form" },
	{ ns.DRUID_DIRE_BEAR_FORM_SPELL_ID, "Dire Bear Form" },
	{ ns.DRUID_CAT_FORM_SPELL_ID, "Cat Form" },
}

--[[
    Existence/value reads only (same read-only contract as the API checks). The
    probe for "my macro does nothing" reports: every reason a macro can sit
    still, each with its current value -- a switch off, combat or the Macro
    window holding writes back, a full macro book, a class, race, level or
    target gate, a spell not known, a pet diet the add-on can't read, an item
    not loaded -- then what the last scan picked and the spells the add-on
    gates on. Restocker Context covers the Restocker and the Inventory Report,
    Readiness Report the ready check, and Display Context the mini-map button.
]]

local function OnOff(value)
	return value and "on" or "off"
end

local function YesNo(value)
	return value and "yes" or "no"
end

-- The keys of a set table that are switched on, sorted and comma-joined.
local function EnabledKeys(set)
	local keys = {}
	for key, value in pairs(set or {}) do
		if value then
			keys[#keys + 1] = tostring(key)
		end
	end
	table.sort(keys)
	return #keys > 0 and table.concat(keys, ", ") or "(none)"
end

local function ItemText(itemID)
	if not itemID then
		return "(none)"
	end
	local name = C_Item.GetItemInfo(itemID)
	return string.format("%d (%s)", itemID, name or "name not loaded")
end

local function AppendCharacter(lines)
	local _, classToken = UnitClass("player")
	local _, raceToken = UnitRace("player")
	local _, instanceType = IsInInstance()
	lines[#lines + 1] = "-- Character --"
	lines[#lines + 1] = string.format(
		"Saved variables loaded: %s // Profile: %s",
		YesNo(ns.db),
		tostring(ns.db and ns.db:GetCurrentProfile())
	)
	lines[#lines + 1] = string.format(
		"Class: %s // Race: %s // Level: %s // Cached level: %s",
		tostring(classToken),
		tostring(raceToken),
		tostring(UnitLevel("player")),
		tostring(ns.cachedPlayerLevel)
	)

	-- The cap the Leveling and Max Level modes compare against, and what each reader answers.
	lines[#lines + 1] = string.format(
		"Max level: %s // GetMaxPlayerLevel: %s // GetMaxLevelForPlayerExpansion: %s",
		tostring(ns.GetMaxPlayerLevel()),
		tostring(GetMaxPlayerLevel and GetMaxPlayerLevel()),
		tostring(GetMaxLevelForPlayerExpansion and GetMaxLevelForPlayerExpansion())
	)

	-- The flags every class and race gate reads, set once at login (Scanner-Character.lua).
	lines[#lines + 1] = string.format(
		"Read as: Hunter %s, Druid %s, Mage %s, Warlock %s, Rogue %s, Night Elf %s, Forsaken %s",
		YesNo(ns.isHunter),
		YesNo(ns.isDruid),
		YesNo(ns.isMage),
		YesNo(ns.isWarlock),
		YesNo(ns.isRogue),
		YesNo(ns.isNightElf),
		YesNo(ns.isForsaken)
	)

	-- Zone-locked and arena-only items read the cached map and the instance type.
	lines[#lines + 1] = string.format(
		"Map: %s // Cached map: %s // Instance: %s // Resting: %s",
		tostring(C_Map.GetBestMapForUnit("player")),
		tostring(ns.cachedMapID),
		tostring(instanceType),
		YesNo(IsResting())
	)

	-- A friendly player target drops the scrolls and downranks the conjures to their level.
	lines[#lines + 1] = string.format(
		"Dead: %s // Ghost: %s // Target: %s // Friendly player target: %s",
		YesNo(UnitIsDead("player")),
		YesNo(UnitIsGhost("player")),
		YesNo(UnitExists("target")),
		YesNo(ns.HasFriendlyPlayerTarget())
	)

	-- The profession ranks the scanner's usability gates read (0 = unlearned).
	lines[#lines + 1] = string.format(
		"Skills: First Aid %s // Alchemy %s // Engineering %s",
		tostring(ns.currentFirstAidSkill),
		tostring(ns.currentAlchemySkill),
		tostring(ns.currentEngineeringSkill)
	)
end

--[[
    Every macro the add-on keeps, as it stands in the General tab. Feed Pet and
    Poisons build only for their class, so their switch alone never makes them.
]]
local CLASS_ONLY_MACROS = {
	["Feed Pet"] = " (Hunters only)",
	["Poisons"] = " (Rogues who know Poisons only)",
}

local function AppendMacroWriting(lines)
	local global = ns.db and ns.db.global
	lines[#lines + 1] = "-- Macro writing --"
	lines[#lines + 1] = string.format(
		"Macros switch: %s (off leaves every macro as it last was)",
		OnOff(global and global.macrosEnabled)
	)
	lines[#lines + 1] =
		string.format("In combat lockdown: %s (writes wait until combat ends)", YesNo(InCombatLockdown()))
	lines[#lines + 1] =
		string.format("Macro window open: %s (writes wait until it closes)", YesNo(MacroFrame and MacroFrame:IsShown()))
	lines[#lines + 1] = string.format(
		"General macros: %d of %d used, %d kept free (a full book stops new macros)",
		GetNumMacros() or 0,
		MAX_ACCOUNT_MACROS or 120,
		ns.MACRO_SLOT_CUSHION
	)

	local typeNames = {}
	for typeName in pairs(ns.MACRO_CONFIG) do
		typeNames[#typeNames + 1] = typeName
	end
	table.sort(typeNames)
	for _, typeName in ipairs(typeNames) do
		local macroName = ns.MACRO_CONFIG[typeName].macro
		local state = "NOT WRITTEN"
		if (GetMacroIndexByName(macroName) or 0) > 0 then
			state = string.format("written, %d bytes", #(GetMacroBody(macroName) or ""))
		end
		lines[#lines + 1] = string.format(
			"[%s] %s: %s, %s%s",
			ns.IsMacroEnabled(typeName) and "on " or "off",
			typeName,
			macroName,
			state,
			CLASS_ONLY_MACROS[typeName] or ""
		)
	end
end

local function AppendChoices(lines)
	local profile = ns.db and ns.db.profile
	if not profile then
		return
	end
	local global = ns.db.global
	lines[#lines + 1] = "-- Choices that steer the picks --"
	lines[#lines + 1] = string.format(
		"Buff food: %s (%s) // in force now: %s",
		OnOff(profile.useBuffFood),
		tostring(profile.buffFoodMode),
		YesNo(ns.allowBuffFood)
	)

	-- What holds buff food back while it is on (Scanner-Inventory.lua), as the last scan read it.
	local targetingSelf = C_Secrets.CanCompareUnitTokens("target", "player")
		and UnitExists("target")
		and UnitIsUnit("target", "player")
	lines[#lines + 1] = string.format(
		"Buff food held back by: Well Fed %s, targeting yourself %s, arena %s // aura data restricted now: %s",
		YesNo(ns.wellFedState),
		YesNo(targetingSelf),
		YesNo(select(2, IsInInstance()) == "arena"),
		YesNo(C_Secrets.ShouldAurasBeSecret())
	)
	lines[#lines + 1] = string.format(
		"Conjured first: %s (%s) // in force now: %s",
		OnOff(profile.useConjuredFirst),
		tostring(profile.conjuredFirstMode),
		YesNo(ns.allowConjuredFirst)
	)
	lines[#lines + 1] = string.format(
		"Restock List last: %s // in force now: %s",
		OnOff(profile.useRestockLast),
		YesNo(ns.allowRestockLast)
	)
	lines[#lines + 1] = string.format(
		"Scrolls: %s (%s) // types: %s // picked now: %s",
		OnOff(profile.useScrolls),
		tostring(profile.scrollsMode),
		EnabledKeys(profile.scrollTypes),
		(ns.scrollOverrideIDs and #ns.scrollOverrideIDs > 0) and table.concat(ns.scrollOverrideIDs, ", ") or "(none)"
	)
	lines[#lines + 1] = string.format(
		"Pet buff food: %s (%s) // types: %s // picked now: %s",
		OnOff(profile.usePetBuffFood),
		tostring(profile.petBuffFoodMode),
		EnabledKeys(profile.petBuffTypes),
		tostring(ns.petBuffOverrideID)
	)
	lines[#lines + 1] = string.format(
		"Early re-application: %s (%s s)",
		OnOff(profile.earlyReapply),
		tostring(profile.earlyReapplyThreshold)
	)
	lines[#lines + 1] = string.format(
		"Healthstones in Health Potion: %s // Mana runes with Mana Gem: %s // Food and water in potion macros: %s",
		OnOff(profile.combineHealthstones),
		OnOff(profile.includeManaRunes),
		OnOff(profile.potionsUseFoodAndWater)
	)
	lines[#lines + 1] = string.format("Explosive clicks: %s", tostring(profile.explosivesClickMode))
	lines[#lines + 1] = string.format(
		"Ignore List: %d on this character, %d on Global",
		CountKeys(profile.ignoreList),
		CountKeys(global.ignoreList)
	)

	-- A stamp that differs from this load's means the cache is rebuilt at the next scan.
	lines[#lines + 1] = string.format(
		"Item cache: %d items // stamped %s, %s // this load %s, %s",
		CountKeys(profile.itemCache),
		tostring(profile.itemCacheVersion),
		tostring(profile.itemCacheFolder),
		tostring(ns.Version),
		tostring(ns.DATA_FOLDER)
	)
end

local function CannibalizeCooldownText()
	local spellID = ns.CANNIBALIZE_SPELL_ID
	if not spellID then
		return "(no spell on this client)"
	end
	if C_Secrets.ShouldSpellCooldownBeSecret(spellID) then
		return "restricted right now"
	end
	local cooldown = C_Spell.GetSpellCooldown(spellID)
	if not (cooldown and cooldown.duration and cooldown.duration > 0) then
		return "ready"
	end
	return string.format("%.1f s left", cooldown.startTime + cooldown.duration - GetTime())
end

-- Whether any add-on has registered this slash command; the Druid Macro Helper bodies call /dmh.
local function SlashCommandExists(command)
	for key, value in pairs(_G) do
		if type(key) == "string" and string.sub(key, 1, 6) == "SLASH_" and type(value) == "string" then
			if string.lower(value) == command then
				return true
			end
		end
	end
	return false
end

--[[
    Pet diets arrive as names in the client's language, and Feed Pet reads them
    through ns.PET_DIET_MAP, whose non-English rows come from the DIET_* locale
    strings. An UNMAPPED diet is food Feed Pet never offers.
]]
local function PetDietText()
	if not UnitExists("pet") then
		return "(no pet out)"
	end
	local ok, diets = pcall(ns.GetPetFoodTypes)
	if not ok then
		return "ERROR: " .. tostring(diets)
	end
	local parts = {}
	for _, diet in ipairs(diets or {}) do
		parts[#parts + 1] = string.format("%s -> %s", tostring(diet), tostring(ns.PET_DIET_MAP[diet] or "UNMAPPED"))
	end
	return #parts > 0 and table.concat(parts, ", ") or "(none)"
end

local function AppendClassAndRace(lines)
	local profile = ns.db and ns.db.profile
	if not profile then
		return
	end
	lines[#lines + 1] = "-- Class and race extras --"
	lines[#lines + 1] = string.format(
		"Stealth Eating: %s // Stealth name: %s // Shadowmeld name: %s",
		OnOff(profile.enableStealthEating),
		tostring(ns.stealthSpellName),
		tostring(ns.shadowmeldSpellName)
	)
	lines[#lines + 1] = string.format("Shadowmeld Drinking: %s", OnOff(profile.enableShadowmeldDrinking))
	lines[#lines + 1] = string.format(
		"Cannibalize: eating %s, drinking %s (restores mana on this client: %s) // name: %s",
		OnOff(profile.enableCannibalizeEating),
		OnOff(profile.enableCannibalizeDrinking),
		YesNo(ns.CANNIBALIZE_RESTORES_MANA),
		tostring(ns.cannibalizeSpellName)
	)
	-- Tools-Forsaken.lua is new in the TOCs, so a client updated while running lacks it until a restart.
	if ns.TargetIsCannibalizable then
		-- nil while the client restricts the target's identity (Forever, mid-fight), which the macro treats as no.
		local cannibalizable = ns.TargetIsCannibalizable()
		lines[#lines + 1] = string.format(
			"Cannibalize now: target Humanoid or Undead %s // cooldown %s",
			cannibalizable == nil and "restricted right now" or YesNo(cannibalizable),
			CannibalizeCooldownText()
		)
	else
		lines[#lines + 1] = "Cannibalize now: Tools-Forsaken.lua not loaded (restart the client)"
	end
	lines[#lines + 1] = string.format(
		"Druid Macro Helper: %s // return form: %s // /dmh command present: %s",
		OnOff(profile.enableDruidMacroHelper),
		tostring(profile.druidReturnForm),
		YesNo(SlashCommandExists("/dmh"))
	)
	lines[#lines + 1] = string.format(
		"Pet: out %s, dead %s // dead-pet flag: %s // spells named: Call %s, Feed %s, Mend %s, Revive %s, Dismiss %s",
		YesNo(UnitExists("pet")),
		YesNo(UnitIsDead("pet")),
		YesNo(ns.petDeadDismissed),
		YesNo(ns.callPetSpellName),
		YesNo(ns.feedPetSpellName),
		YesNo(ns.mendPetSpellName),
		YesNo(ns.revivePetSpellName),
		YesNo(ns.dismissPetSpellName)
	)
	lines[#lines + 1] = "Pet diets: " .. PetDietText()
	lines[#lines + 1] = "Feed Pet pick: " .. ItemText(ns.bestPetFoodID)
	lines[#lines + 1] = string.format(
		"Poisons known: %s // main hand: %s -> %s // off hand: %s -> %s",
		YesNo(ns.POISONS_SPELL_ID and (ns.IsSpellKnown(ns.POISONS_SPELL_ID) or ns.IsPlayerSpell(ns.POISONS_SPELL_ID))),
		tostring(profile.mainHandPoisonGroup),
		ItemText((ns.GetBestPoisonForHand("main"))),
		tostring(profile.offHandPoisonGroup),
		ItemText((ns.GetBestPoisonForHand("off")))
	)
end

local function AppendSelection(lines)
	lines[#lines + 1] = "-- Best-item selection --"
	lines[#lines + 1] = string.format("bestFoodID: %s", tostring(ns.bestFoodID))
	lines[#lines + 1] = string.format("bestPetFoodID: %s", tostring(ns.bestPetFoodID))

	--[[
	    Per-category winners from the last ScanBags pass (ns.bestSelection is
	    the scanner's live best table). The read-out for "category X didn't
	    update" reports: it shows exactly what the scanner picked plus the
	    tiebreak inputs (value/price/count) the comparison ladder ordered on,
	    and the ranked topIDs for multi-use types, none of which bestFoodID
	    alone can reveal.
	]]
	local selection = ns.bestSelection
	if not selection then
		lines[#lines + 1] = "No scan has completed yet."
		return
	end
	local categories = {}
	for typeName in pairs(selection) do
		categories[#categories + 1] = typeName
	end
	table.sort(categories)
	for _, typeName in ipairs(categories) do
		local entry = selection[typeName]
		local detail = string.format(
			"id=%s value=%s price=%s count=%s",
			tostring(entry.id),
			tostring(entry.value),
			tostring(entry.price),
			tostring(entry.count)
		)
		if entry.topIDs and #entry.topIDs > 0 then
			detail = detail .. " topIDs=" .. table.concat(entry.topIDs, ",")
		end
		lines[#lines + 1] = string.format("%s: %s", typeName, detail)
	end
end

local function AppendSpells(lines)
	lines[#lines + 1] = "-- Spell knowledge --"
	for _, entry in ipairs(ns.DIAGNOSTIC_SPELLS) do
		local spellID, label = entry[1], entry[2]
		if spellID then
			local known = ns.IsSpellKnown(spellID) or ns.IsPlayerSpell(spellID)
			local name = C_Spell.GetSpellName(spellID)
			lines[#lines + 1] = string.format(
				"[%s] %s (%d)%s",
				known and "KNOWN" or "  -  ",
				label,
				spellID,
				name and (" = " .. name) or " (no name on this client)"
			)
		end
	end

	-- Each conjure ladder: how many of its ranks are known, and what the macros' /cast line would name now.
	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Conjure ranks --"
	local listNames = {}
	for listName in pairs(ns.CONJURE_SPELLS) do
		listNames[#listNames + 1] = listName
	end
	table.sort(listNames)
	for _, listName in ipairs(listNames) do
		local list = ns.CONJURE_SPELLS[listName]
		local known = 0
		for _, row in ipairs(list) do
			if ns.IsSpellKnown(row[1]) or ns.IsPlayerSpell(row[1]) then
				known = known + 1
			end
		end
		local castName = ns.GetSmartSpell(list)
		lines[#lines + 1] =
			string.format("%s: %d of %d ranks known // casts: %s", listName, known, #list, tostring(castName))
	end
end

function ns:BuildConnoisseurContextReport()
	local lines = { GetClientHeader(), "" }
	AppendCharacter(lines)
	lines[#lines + 1] = ""
	AppendMacroWriting(lines)
	lines[#lines + 1] = ""
	AppendChoices(lines)
	lines[#lines + 1] = ""
	AppendClassAndRace(lines)
	lines[#lines + 1] = ""
	AppendSelection(lines)
	lines[#lines + 1] = ""
	AppendSpells(lines)
	return (table.concat(lines, "\n"):gsub("|", "||"))
end

--------------------------------------------------------------------------------
-- Restocker Context
--------------------------------------------------------------------------------

--[[
    The probe for "the Restocker did nothing" and "the tooltip shows no counts"
    reports: the switches, the list this character shops from, the gold and
    bag space a purchase needs, the windows open now, the staples offer's
    gates, what a merchant would buy now, the reminders and their gates, and
    the Inventory Report's hook. Read-only.
]]
local function MoneyText(copper)
	copper = copper or 0
	return string.format("%dg %ds %dc", math.floor(copper / 10000), math.floor(copper / 100) % 100, copper % 100)
end

-- Free slots in the carried bags that take any item (bag family 0).
local function FreeBagSlots()
	local free = 0
	for bag = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local slots, family = C_Container.GetContainerNumFreeSlots(bag)
		if family == 0 then
			free = free + (slots or 0)
		end
	end
	return free
end

function ns:BuildRestockerContextReport()
	local lines = { GetClientHeader(), "" }
	local global = ns.db and ns.db.global
	if not global then
		lines[#lines + 1] = "Saved variables are not loaded yet."
		return table.concat(lines, "\n")
	end
	local settings = global.restocker or {}
	local lists = settings.lists or {}
	local list = settings.currentList and lists[settings.currentList]
	local characterKey = ns.GetCharacterKey()

	lines[#lines + 1] = "-- Restocker --"
	lines[#lines + 1] = string.format(
		"Restocker switch: %s (off stops the window, /crs, the reminders and every purchase) // started: %s",
		OnOff(global.restockerEnabled),
		YesNo(ns.restockerLoaded)
	)
	lines[#lines + 1] = string.format(
		"List in use: %s // this profile picks: %s // exists: %s // rows: %d // lists saved: %d",
		tostring(settings.currentList),
		tostring(ns.db.profile.restockList),
		YesNo(list),
		CountKeys(list),
		CountKeys(lists)
	)
	lines[#lines + 1] = string.format(
		"Gold Reserve: %s, %s gold // money now: %s",
		OnOff(settings.goldReserve),
		tostring(settings.goldReserveAmount),
		MoneyText(GetMoney())
	)
	lines[#lines + 1] = string.format("Free bag slots: %d", FreeBagSlots())
	lines[#lines + 1] = string.format(
		"Merchant open: %s // buying skipped: %s // Bank open: %s",
		YesNo(ns.merchantIsOpen),
		YesNo(ns.merchantBuyingSkipped),
		YesNo(ns.bankIsOpen)
	)
	lines[#lines + 1] = string.format(
		"Town reminder: chat %s, sound %s, %s // resting: %s, on a flight: %s",
		OnOff(settings.restockReminderChat),
		OnOff(settings.restockReminderSound),
		tostring(settings.restockReminderMode),
		YesNo(IsResting()),
		YesNo(UnitOnTaxi("player"))
	)
	lines[#lines + 1] = string.format(
		"Merchant reminder: %s, %s // auto-open at merchant: %s",
		OnOff(settings.merchantReminder),
		tostring(settings.merchantReminderMode),
		OnOff(settings.autoOpenAtMerchant)
	)
	lines[#lines + 1] = string.format(
		"Bank reminder: %s, %s // auto-open at bank: %s",
		OnOff(settings.bankReminder),
		tostring(settings.bankReminderMode),
		OnOff(settings.autoOpenAtBank)
	)
	lines[#lines + 1] = string.format(
		"Window open: %s // staples offer dismissed for this character: %s // level: %d",
		YesNo(ns.restockWindow and ns.restockWindow:IsShown()),
		YesNo(settings.starterListDismissed and settings.starterListDismissed[characterKey]),
		UnitLevel("player") or 0
	)

	-- What a merchant visit would buy now (the rows short of their Keep amount with Buy on), with what the bags hold.
	local short = {}
	for _, entry in ipairs(ns.BuildGroceryList()) do
		short[#short + 1] =
			string.format("%s %d/%d", tostring(entry.itemName or entry.itemID), entry.have, entry.wanted)
	end
	lines[#lines + 1] =
		string.format("Short now (a merchant would buy): %s", #short > 0 and table.concat(short, ", ") or "(nothing)")

	--[[
	    The Inventory Report's file is new in a TOC, so a client updated while
	    running reads it only after a restart: until then the feature is absent.
	]]
	local inventory = global.inventory or {}
	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Inventory Report --"
	lines[#lines + 1] = string.format(
		"Inventory Report switch: %s // feature loaded: %s",
		OnOff(global.inventoryReport),
		YesNo(ns.InitializeInventoryReport)
	)
	lines[#lines + 1] = string.format(
		"Tooltip hook: %s",
		(TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall) and "TooltipDataProcessor post-call"
			or "OnTooltipSetItem"
	)
	lines[#lines + 1] = string.format(
		"This character recorded: %s (%s) // characters recorded: %d",
		YesNo(inventory[characterKey]),
		characterKey,
		CountKeys(inventory)
	)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Account --"
	lines[#lines + 1] = string.format(
		"Welcome message: %s // Macro names on buttons: %s // Readiness Report: %s",
		OnOff(global.showWelcome),
		OnOff(global.showMacroNames),
		OnOff(global.readinessReportEnabled)
	)
	return (table.concat(lines, "\n"):gsub("|", "||"))
end

--------------------------------------------------------------------------------
-- Item Selection
--------------------------------------------------------------------------------

--[[
    The "why did it pick that?" read-out. For every category that goes through
    the scanner's ranking ladder, prints the winner and the runners-up it beat,
    each tagged with the RANKING_PRIORITY field that decided the pair (see
    Features/Scanner-Inventory.lua). Reads only what the last scan left behind;
    it never rescans, so the report can never disagree with the macros the
    player is actually looking at.
]]

local function DescribeItem(itemID)
	if not itemID then
		return "(none)"
	end
	local name = C_Item.GetItemInfo(itemID)
	if name then
		return string.format("%d (%s)", itemID, name)
	end
	return string.format("%d (name not cached)", itemID)
end

local function AppendCategoryLines(lines, typeName, entry, candidates)
	lines[#lines + 1] = string.format("%s: %s", typeName, DescribeItem(entry and entry.id))

	if entry and entry.id then
		lines[#lines + 1] = string.format(
			"    won with value=%s price=%s count=%s",
			tostring(entry.value),
			tostring(entry.price),
			tostring(entry.count)
		)
	end

	if entry and entry.topIDs and #entry.topIDs > 0 then
		lines[#lines + 1] = "    stacked /use order: " .. table.concat(entry.topIDs, ", ")
	end

	if not candidates or #candidates < 2 then
		return
	end

	for i = 2, #candidates do
		local candidate = candidates[i]
		lines[#lines + 1] = string.format(
			"    beat %s on %s (value=%s price=%s count=%s)",
			DescribeItem(candidate.id),
			candidate.decidedBy or "nothing (identical record)",
			tostring(candidate.value),
			tostring(candidate.price),
			tostring(candidate.count)
		)
	end
end

function ns:BuildSelectionReport()
	local lines = { GetClientHeader(), "" }

	local selection = ns.bestSelection
	local candidates = ns.diagnosticCandidates

	if not selection then
		lines[#lines + 1] = "No scan has completed yet. Trigger one by looting an item or changing zone."
		return table.concat(lines, "\n")
	end

	--[[
	    Candidate retention starts when the tools are enabled, so a report run
	    before the next scan has winners but no runners-up. Say so rather than
	    letting an empty list read as "nothing else was in the running."
	]]
	local retained = false
	for _, list in pairs(candidates) do
		if #list > 0 then
			retained = true
			break
		end
	end

	lines[#lines + 1] = string.format("allowBuffFood (live scan preference): %s", tostring(ns.allowBuffFood))
	lines[#lines + 1] = string.format("allowConjuredFirst (live scan preference): %s", tostring(ns.allowConjuredFirst))
	lines[#lines + 1] = string.format("allowRestockLast (live scan preference): %s", tostring(ns.allowRestockLast))
	if not retained then
		lines[#lines + 1] = ""
		lines[#lines + 1] =
			"No candidates were retained: the last scan ran before these tools were enabled. Trigger a rescan (loot something, or change zone) and run this again to see the runners-up."
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Ranked by the selection ladder --"

	local typeNames = {}
	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS or {}) do
		if definition.itemTypes then
			typeNames[#typeNames + 1] = definition.typeName
		end
	end
	table.sort(typeNames)

	for _, typeName in ipairs(typeNames) do
		AppendCategoryLines(lines, typeName, selection[typeName], candidates[typeName])
	end

	--[[
	    The custom definitions own their whole update and resolve their item
	    outside the ladder (the Hunter pet-food scan, the Rogue poison walk),
	    so they have no candidate list to show. Naming them keeps the report
	    honest about what it does and does not cover.
	]]
	local customNames = {}
	for _, definition in ipairs(ns.REGISTERED_CUSTOM_MACRO_DEFINITIONS or {}) do
		customNames[#customNames + 1] = definition.typeName
	end
	table.sort(customNames)

	if #customNames > 0 then
		lines[#lines + 1] = ""
		lines[#lines + 1] = "-- Resolved outside the ladder (no candidate ranking) --"
		for _, typeName in ipairs(customNames) do
			lines[#lines + 1] = string.format("%s: resolved by its own builder at macro-update time", typeName)
		end
		lines[#lines + 1] = string.format("Feed Pet current pick: %s", DescribeItem(ns.bestPetFoodID))
	end

	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Readiness Report
--------------------------------------------------------------------------------

--[[
    The Readiness Report as it would print right now, without waiting for a
    ready check. Read-only: it asks the same probes the report asks and prints
    nothing to chat.

    The report has two silences that look identical from a chat window, "you
    are ready" and "it never ran", and only one of them is a bug. Rendering it
    on demand separates them in one button press, and the switch states below
    say which lines were even eligible to speak.

    Color escapes are stripped: reports are plain text, and a |cff pasted into
    a bug report is noise.
]]
local READINESS_SWITCHES = {
	"readinessFlask",
	"readinessWellFed",
	"readinessPetWellFed",
	"readinessScrolls",
	"readinessSoulstone",
	"readinessMainHandBuff",
	"readinessOffHandBuff",
	"readinessExpiring",
	"readinessHealthstone",
	"readinessManaGem",
	"readinessHealingPotion",
	"readinessManaPotion",
	"readinessBandages",
	"readinessDurability",
	"readinessSpec",
	"readinessPvP",
	"readinessQuestionableGear",
}

function ns:BuildReadinessDiagnosticReport()
	local lines = { GetClientHeader(), "" }

	local reports = ns.db and ns.db.global
	if not reports then
		lines[#lines + 1] = "Saved variables are not loaded yet."
		return table.concat(lines, "\n")
	end

	lines[#lines + 1] = string.format("Report enabled: %s", tostring(reports.readinessReportEnabled))
	lines[#lines + 1] = string.format("Instance type: %s", tostring(select(2, IsInInstance())))
	lines[#lines + 1] = string.format("In group: %s", tostring(IsInGroup()))

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- What it would print now --"

	-- The report walks auras, and on Forever a restricted aura read throws.
	if C_Secrets.ShouldAurasBeSecret() then
		lines[#lines + 1] = "(aura data is restricted right now -- run this report again out of combat)"
	else
		-- A probe that throws must still leave a report, or this button shows nothing at all.
		local ok, body = pcall(ns.BuildReadinessLines, select(2, IsInInstance()) == "arena")
		if not ok then
			lines[#lines + 1] = "ERROR: " .. tostring(body)
		elseif not body then
			lines[#lines + 1] = "(nothing -- this character has nothing the report would name)"
		else
			lines[#lines + 1] = ns.L["READINESS_TITLE"]
			for _, line in ipairs(body) do
				lines[#lines + 1] = line
			end
		end
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Category switches --"
	for _, key in ipairs(READINESS_SWITCHES) do
		lines[#lines + 1] = string.format("[%s] %s", reports[key] and "ON " or "   ", key)
	end

	local text = table.concat(lines, "\n")
	-- Item links (Damaged / Non-Combat Gear) survive the color strip; escaping them makes the paste plain text.
	return (text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""):gsub("|", "||"))
end

--------------------------------------------------------------------------------
-- Name Lookups
--------------------------------------------------------------------------------

--[[
    A conjure row's name as the macros' /cast line writes it (Smart-Spell.lua's
    CastName): a row carrying a rank number adds the client's own rank text, so
    the name is right in every locale.
]]
local function ConjureCastName(row)
	local name = C_Spell.GetSpellName(row[1])
	if not name then
		return nil
	end
	if row[3] then
		local subtext = C_Spell.GetSpellSubtext(row[1])
		if subtext and subtext ~= "" then
			return name .. "(" .. subtext .. ")"
		end
	end
	return name
end

local function SortedKeys(tbl)
	local keys = {}
	for key in pairs(tbl or {}) do
		keys[#keys + 1] = key
	end
	table.sort(keys, function(a, b)
		return tostring(a) < tostring(b)
	end)
	return keys
end

--[[
    Every record Connoisseur shows or matches by the name this client gives it,
    for the Localization tab's Game Names report, each read through the call
    its feature makes. A record this client's folder doesn't carry has a nil id
    and gets no row. Spells and items load late, so their rows add request,
    which the report calls and polls. The Blizzard UI labels are globals, so
    each one's id is its own name; the reputation standings come in the
    player's gender, as the Restock List's column shows them.
]]
local nameLookups = {}

local function AddLookup(constant, kind, id, lookup, request)
	if id ~= nil then
		nameLookups[#nameLookups + 1] =
			{ constant = constant, kind = kind, id = id, lookup = lookup, request = request }
	end
end

local function AddSpellLookup(constant, spellID, lookup)
	AddLookup(constant, "spell", spellID, lookup or function()
		return C_Spell.GetSpellName(spellID)
	end, function()
		C_Spell.RequestLoadSpellData(spellID)
	end)
end

local function AddItemLookup(constant, itemID, lookup)
	AddLookup(constant, "item", itemID, lookup or function()
		return (C_Item.GetItemInfo(itemID))
	end, function()
		C_Item.RequestLoadItemDataByID(itemID)
	end)
end

local function AddUiLabel(constant, lookup)
	AddLookup(constant, "uiLabel", constant, lookup or function()
		return _G[constant]
	end)
end

-- Spells cast or named by their own constant: the stealths, Cannibalize, the pet and Druid form spells.
for _, constant in ipairs({
	"CALL_PET_SPELL_ID",
	"CANNIBALIZE_SPELL_ID",
	"DISMISS_PET_SPELL_ID",
	"DRUID_BEAR_FORM_SPELL_ID",
	"DRUID_CAT_FORM_SPELL_ID",
	"DRUID_DIRE_BEAR_FORM_SPELL_ID",
	"FEED_PET_SPELL_ID",
	"MEND_PET_SPELL_ID",
	"POISONS_SPELL_ID",
	"REVIVE_PET_SPELL_ID",
	"SHADOWMELD_SPELL_ID",
	"STEALTH_SPELL_ID",
}) do
	AddSpellLookup(constant, ns[constant])
end
AddSpellLookup("WELL_FED_SPELL_ID", ns.WELL_FED_SPELL_ID, ns.GetWellFedName)

-- The spells the "you don't know <spell>" tips name (Runtime.lua).
for _, key in ipairs(SortedKeys(ns.MISSING_SPELL_MESSAGE_IDS)) do
	AddSpellLookup("MISSING_SPELL_MESSAGE_IDS." .. key, ns.MISSING_SPELL_MESSAGE_IDS[key])
end

-- Every conjure rank, as the /cast line names it.
for _, listName in ipairs(SortedKeys(ns.CONJURE_SPELLS)) do
	for index, row in ipairs(ns.CONJURE_SPELLS[listName]) do
		AddSpellLookup(string.format("CONJURE_SPELLS.%s[%d]", listName, index), row[1], function()
			return ConjureCastName(row)
		end)
	end
end

--[[
    The skill lines the profession gates find in the skill list
    (Scanner-Character.lua), First Aid through the accessor the options read.
]]
AddLookup("FIRST_AID_SKILL_LINE_ID", "skillLine", ns.FIRST_AID_SKILL_LINE_ID, ns.GetFirstAidName)
for _, constant in ipairs({ "ALCHEMY_SKILL_LINE_ID", "ENGINEERING_SKILL_LINE_ID" }) do
	local skillLineID = ns[constant]
	AddLookup(constant, "skillLine", skillLineID, function()
		return C_TradeSkillUI.GetTradeSkillDisplayName(skillLineID)
	end)
end

-- The Macros panel's headers.
AddLookup("NIGHT_ELF_RACE_ID", "race", ns.NIGHT_ELF_RACE_ID, function()
	local info = C_CreatureInfo.GetRaceInfo(ns.NIGHT_ELF_RACE_ID)
	return info and info.raceName
end)
for _, classToken in ipairs({ "DRUID", "ROGUE" }) do
	AddLookup("LOCALIZED_CLASS_NAMES_MALE." .. classToken, "class", classToken, function()
		return LOCALIZED_CLASS_NAMES_MALE[classToken]
	end)
end

--[[
    The runes the Mana Gem texts name, the pet foods the Pet Food Buffs toggles
    name, and each poison group by its first item.
]]
AddItemLookup("DEMONIC_RUNE_ITEM_ID", ns.DEMONIC_RUNE_ITEM_ID)
AddItemLookup("DARK_RUNE_ITEM_ID", ns.DARK_RUNE_ITEM_ID)
for _, itemID in ipairs(SortedKeys(ns.PET_BUFF_FOODS)) do
	AddItemLookup(string.format("PET_BUFF_FOODS[%d]", itemID), itemID)
end
for _, groupID in ipairs(SortedKeys(ns.POISON_GROUP_BASE_ITEMS)) do
	AddItemLookup(
		string.format("POISON_GROUP_BASE_ITEMS[%s]", tostring(groupID)),
		ns.POISON_GROUP_BASE_ITEMS[groupID],
		function()
			return ns.GetPoisonGroupName(groupID)
		end
	)
end

--[[
    The staples window's rows named by an item rather than a label. Which tier
    names the row follows the character's level and list, so every tier item of
    the category's ladder gets a row, each once, and the report checks every name
    the window can show for any character. A ladder this client carries no tiers
    for adds nothing.
]]
for _, category in ipairs(ns.GetStarterCategories()) do
	if not category.label then
		local seen = {}
		for index, tier in ipairs(category.chain.tiers) do
			local itemID = tier[2]
			if not seen[itemID] then
				seen[itemID] = true
				AddItemLookup(string.format("STARTER_LIST_CATEGORIES.%s[%d]", category.key, index), itemID)
			end
		end
	end
end

--[[
    Blizzard UI labels the add-on shows (the weapon slots, the scroll stats, the
    pop-up buttons) and the error texts its handlers match a UI_ERROR_MESSAGE
    against, and UNKNOWNOBJECT, which marks a character name not yet known.
]]
for _, constant in ipairs({
	"MAINHANDSLOT",
	"SECONDARYHANDSLOT",
	"SPELL_STAT1_NAME",
	"SPELL_STAT2_NAME",
	"SPELL_STAT3_NAME",
	"SPELL_STAT4_NAME",
	"SPELL_STAT5_NAME",
	"YES",
	"NO",
	"CANCEL",
	"ERR_ITEM_WRONG_ZONE",
	"SPELL_FAILED_TARGETS_DEAD",
	"UNKNOWNOBJECT",
}) do
	AddUiLabel(constant)
end
for _, standing in ipairs(ns.REPUTATION_STANDINGS) do
	if standing.value > 0 then
		AddUiLabel("FACTION_STANDING_LABEL" .. standing.value, function()
			return ns.GetStandingLabel(standing.value)
		end)
	end
end

ns.DIAGNOSTIC_NAME_LOOKUPS = nameLookups

--------------------------------------------------------------------------------
-- Message Length
--------------------------------------------------------------------------------

--[[
    Connoisseur sends no chat, so Message Length is the macros alone, against
    ns.MACRO_BODY_MAX_LENGTH in bytes. First every macro as it stands in the
    General tab now. Then each standard macro built through
    ns.BuildStandardBody at its longest, nothing written: the longest item ID
    this data folder holds in every /use line, every ranked and stacked line,
    each shape its conjure clicks can take, and the stealth, Cannibalize and
    out-of-combat food or water lines, all with this client's spell names. The
    longest of three characters wins: a Mage or Warlock (conjures), a Rogue
    (Stealth) and a Night Elf (Shadowmeld), the first two Forsaken
    (Cannibalize). The builder trims its own body, so a length over the
    ceiling is one the trim could not fit, and every line it shed is counted.
    Feed Pet, Poisons and the Druid Macro Helper bodies come from builders that
    read the character's own state, so they show only as written.
]]

-- Each macro's conjure clicks: the right- and middle-click ladders and their not-yet-learned tips.
local CONJURE_SHAPES = {
	["Food"] = {
		right = "MageCreateFood",
		rightMiss = "noConjureFood",
		middle = "MageCreateTable",
		middleMiss = "noRitualOfRefreshment",
	},
	["Water"] = {
		right = "MageCreateWater",
		rightMiss = "noConjureWater",
		middle = "MageCreateTable",
		middleMiss = "noRitualOfRefreshment",
	},
	["Mana Gem"] = { right = "MageCreateManaGem", rightMiss = "noConjureManaGem" },
	["Healthstone"] = {
		right = "WarlockCreateHealthstone",
		rightMiss = "noCreateHealthstone",
		middle = "WarlockCreateSoulwell",
		middleMiss = "noRitualOfSouls",
	},
	["Soulstone"] = { right = "WarlockCreateSoulstone", rightMiss = "noCreateSoulstone" },
}

-- Which stealths each macro's own appended line can cast (Food's Stealth Eating, Water's Shadowmeld Drinking).
local STEALTHS_BY_TYPE = {
	["Food"] = { STEALTH_SPELL_ID = true, SHADOWMELD_SPELL_ID = true },
	["Water"] = { SHADOWMELD_SPELL_ID = true },
}

-- Which macros cast Cannibalize (Water only where it restores mana).
local function CastsCannibalize(typeName)
	return typeName == "Food" or (typeName == "Water" and ns.CANNIBALIZE_RESTORES_MANA)
end

local LENGTH_CHARACTERS = {
	{ label = "Mage or Warlock, Forsaken", conjure = true, corpse = true },
	{ label = "Rogue, Forsaken", stealth = "STEALTH_SPELL_ID", corpse = true },
	{ label = "Night Elf", stealth = "SHADOWMELD_SPELL_ID" },
}

-- The item ID with the most digits among every item the data folder holds.
local function LongestItemID()
	local longest
	local function Consider(id)
		if type(id) == "number" and (not longest or #tostring(id) > #tostring(longest)) then
			longest = id
		end
	end
	for _, entry in ipairs(ns.DIAGNOSTIC_DATA_SOURCES) do
		for _, source in ipairs(entry.sources) do
			local tbl = ns[source.table]
			if source.kind == "item" and type(tbl) == "table" then
				if source.collect then
					for _, found in ipairs(source.collect(tbl)) do
						Consider(found.id)
					end
				else
					for key, row in pairs(tbl) do
						Consider(source.rowId(key, row))
					end
				end
			end
		end
	end
	return longest
end

local function LongestCastName(listName)
	local longest
	for _, row in ipairs(ns.CONJURE_SPELLS[listName] or {}) do
		local name = ConjureCastName(row)
		if name and (not longest or #name > #longest) then
			longest = name
		end
	end
	return longest
end

-- Every conjure info the macro's resolver can return for a character who conjures, longest names in.
local function ConjureVariants(typeName)
	local shape = CONJURE_SHAPES[typeName]
	if not shape then
		return { false }
	end
	local rights = { { miss = shape.rightMiss } }
	local rightName = LongestCastName(shape.right)
	if rightName then
		rights[#rights + 1] = { name = rightName, id = 0 }
	end
	local middles = { {} }
	if shape.middle and #(ns.CONJURE_SPELLS[shape.middle] or {}) > 0 then
		middles = { { miss = shape.middleMiss } }
		local middleName = LongestCastName(shape.middle)
		if middleName then
			middles[#middles + 1] = { name = middleName, id = 0 }
		end
	end
	local variants = {}
	for _, right in ipairs(rights) do
		for _, middle in ipairs(middles) do
			variants[#variants + 1] = {
				rightName = right.name,
				rightID = right.id,
				rightMiss = right.miss,
				middleName = middle.name,
				middleID = middle.id,
				middleMiss = middle.miss,
			}
		end
	end
	return variants
end

local function StealthName(typeName, character)
	local constant = character.stealth
	if constant and STEALTHS_BY_TYPE[typeName] and STEALTHS_BY_TYPE[typeName][constant] and ns[constant] then
		return C_Spell.GetSpellName(ns[constant])
	end
	return nil
end

local function CorpseName(typeName, character)
	if character.corpse and CastsCannibalize(typeName) and ns.CANNIBALIZE_SPELL_ID then
		return C_Spell.GetSpellName(ns.CANNIBALIZE_SPELL_ID)
	end
	return nil
end

local function Repeat(value, count)
	local list = {}
	for index = 1, count do
		list[index] = value
	end
	return list
end

local function CountUseLines(body)
	local _, count = string.gsub(body, "/use item:", "")
	return count
end

--[[
    One macro's longest body for one character, as (body, shed): shed counts
    the /use lines the trim dropped, plus one when it dropped Cannibalize.
]]
local function LongestBodyFor(definition, character, itemID)
	local typeName = definition.typeName
	local useIDs = ns.MULTI_USE_MACRO_TYPES[typeName] and Repeat(itemID, ns.MULTI_USE_MAX_ITEMS) or nil
	local stackIDs = definition.getStackIDs and Repeat(itemID, ns.MULTI_USE_MAX_ITEMS) or nil
	local stealth = StealthName(typeName, character)
	local appendText = stealth and ("\n/cast [nostealth] " .. stealth) or nil
	local corpse = CorpseName(typeName, character)

	local outOfCombatID, outOfCombatStealth, outOfCombatCorpse
	local source = definition.outOfCombatTypeName
	if source then
		outOfCombatID = itemID
		outOfCombatStealth = StealthName(source, character)
		outOfCombatCorpse = CorpseName(source, character)
	end

	local wantedUses = (useIDs and #useIDs or 1) + (stackIDs and #stackIDs or 0)
	local best, bestShed
	local variants = character.conjure and ConjureVariants(typeName) or { false }
	for _, conjureInfo in ipairs(variants) do
		local body = ns.BuildStandardBody(
			definition,
			itemID,
			useIDs,
			stackIDs,
			conjureInfo or nil,
			appendText,
			outOfCombatID,
			outOfCombatStealth,
			corpse,
			outOfCombatCorpse
		)
		local shed = wantedUses - CountUseLines(body)
		if (corpse or outOfCombatCorpse) and not string.find(body, "dead]", 1, true) then
			shed = shed + 1
		end
		if not best or #body > #best then
			best, bestShed = body, shed
		end
	end
	return best, bestShed
end

local function AppendWrittenMacros(lines)
	lines[#lines + 1] = "-- As written now --"
	for _, typeName in ipairs(SortedKeys(ns.MACRO_CONFIG)) do
		local macroName = ns.MACRO_CONFIG[typeName].macro
		if (GetMacroIndexByName(macroName) or 0) > 0 then
			local length = #(GetMacroBody(macroName) or "")
			lines[#lines + 1] = string.format(
				"[%s] %s: %d / %d bytes",
				length > ns.MACRO_BODY_MAX_LENGTH and "OVER" or "OK  ",
				typeName,
				length,
				ns.MACRO_BODY_MAX_LENGTH
			)
		else
			lines[#lines + 1] = string.format("[--  ] %s: not written", typeName)
		end
	end
end

function ns:BuildMessageLengthReport()
	local lines = { GetClientHeader(), "" }
	AppendWrittenMacros(lines)

	lines[#lines + 1] = ""
	lines[#lines + 1] = "-- Longest build in this locale --"
	local itemID = LongestItemID()
	if not itemID then
		lines[#lines + 1] = "(this data folder holds no items)"
		return table.concat(lines, "\n")
	end
	lines[#lines + 1] = string.format("Longest item ID: %d", itemID)

	local definitions = {}
	for _, definition in ipairs(ns.REGISTERED_MACRO_DEFINITIONS) do
		definitions[#definitions + 1] = definition
	end
	table.sort(definitions, function(a, b)
		return a.typeName < b.typeName
	end)
	--[[
	    The worst character is the one whose body sheds the most, then the
	    longest: a trimmed body always fits, so its length alone hides the trim.
	]]
	for _, definition in ipairs(definitions) do
		local longest, longestShed, longestLabel
		local differs = false
		for _, character in ipairs(LENGTH_CHARACTERS) do
			local body, shed = LongestBodyFor(definition, character, itemID)
			if longest and #body ~= #longest then
				differs = true
			end
			if not longest or shed > longestShed or (shed == longestShed and #body > #longest) then
				longest, longestShed, longestLabel = body, shed, character.label
			end
		end
		if not differs then
			longestLabel = "any character"
		end
		lines[#lines + 1] = string.format(
			"[%s] %s: %d / %d bytes (%s)%s",
			#longest > ns.MACRO_BODY_MAX_LENGTH and "OVER" or "OK  ",
			definition.typeName,
			#longest,
			ns.MACRO_BODY_MAX_LENGTH,
			longestLabel,
			longestShed > 0 and string.format(", trim shed %d line(s)", longestShed) or ""
		)
	end

	lines[#lines + 1] = ""
	lines[#lines + 1] =
		"Feed Pet, Poisons and Druid Macro Helper bodies read this character's state; see them as written above."
	return table.concat(lines, "\n")
end

--------------------------------------------------------------------------------
-- Validate Data Sources
--------------------------------------------------------------------------------

--[[
    One entry per data file, and one report row per entry on the Data tab
    (Diagnostics/Options-Diagnostics.lua). Each entry's label is the
    table-name part of its file name, so ns.DataSourceFileName can name the
    file this client's folder built. Each source names the static table on ns
    and its kind: "spell" or "item" for ids the client can look up, "other"
    for ids no client API reads, which report their row count. Ids are reached
    through rowId(key, row) over the table's pairs, or through collect(tbl)
    for a table not keyed by the id it holds, which returns { id, key, row }
    entries, each id once. Adding a data file adds an entry here, and the
    panel and the validator pick it up with no second list.
]]
local function KeyIsId(key)
	return key
end

local function KeyValue(key)
	return key
end

--[[
    A collect function from a walk over the table: walk(tbl, add) calls
    add(id, key, row) for every id it finds, and an id found twice is kept
    once.
]]
local function Collector(walk)
	return function(tbl)
		local entries, seen = {}, {}
		walk(tbl, function(id, key, row)
			if id ~= nil and not seen[id] then
				seen[id] = true
				entries[#entries + 1] = { id = id, key = key, row = row }
			end
		end)
		return entries
	end
end

local CollectValues = Collector(function(tbl, add)
	for key, id in pairs(tbl) do
		add(id, key, id)
	end
end)

-- One field of every row, by index for row arrays and by name for keyed rows.
local function CollectColumn(field)
	return Collector(function(tbl, add)
		for key, row in pairs(tbl) do
			add(row[field], key, row)
		end
	end)
end

-- Every id in a table whose values are lists of ids.
local CollectListValues = Collector(function(tbl, add)
	for key, list in pairs(tbl) do
		for _, id in ipairs(list) do
			add(id, key, list)
		end
	end
end)

local CollectUpgradeTierItems = Collector(function(chains, add)
	for index, chain in ipairs(chains) do
		for _, tier in ipairs(chain.tiers) do
			add(tier[2], index, tier)
		end
	end
end)

local CollectRecipeReagents = Collector(function(recipes, add)
	for index, recipe in ipairs(recipes) do
		for _, reagent in ipairs(recipe[2]) do
			add(reagent[1], index, reagent)
		end
	end
end)

local function CollectScrollColumn(field)
	return Collector(function(scrollData, add)
		for scrollType, data in pairs(scrollData) do
			for _, row in ipairs(data.items) do
				add(row[field], scrollType, row)
			end
		end
	end)
end

local CollectScrollConflictSpells = Collector(function(scrollData, add)
	for scrollType, data in pairs(scrollData) do
		for spellID in pairs(data.conflictSpells) do
			add(spellID, scrollType, data)
		end
	end
end)

local CollectConjureSpells = Collector(function(conjureSpells, add)
	for listName, spellList in pairs(conjureSpells) do
		for _, entry in ipairs(spellList) do
			add(entry[1], listName, entry)
		end
	end
end)

--[[
    Game-IDs-{Game}.lua's single-id constants hold the id itself rather than a
    table, so each kind's constants are validated by name through these lists:
    the collect reads ns[name], and DATA_CONSTANT names the constant on its row.
]]
ns.DIAGNOSTIC_SPELL_ID_CONSTANTS = {
	"CALL_PET_SPELL_ID",
	"CANNIBALIZE_SPELL_ID",
	"DISMISS_PET_SPELL_ID",
	"DRUID_BEAR_FORM_SPELL_ID",
	"DRUID_CAT_FORM_SPELL_ID",
	"DRUID_DIRE_BEAR_FORM_SPELL_ID",
	"FEED_PET_SPELL_ID",
	"GOBLIN_ENGINEER_SPELL_ID",
	"MEND_PET_SPELL_ID",
	"POISONS_SPELL_ID",
	"REVIVE_PET_SPELL_ID",
	"SHADOWMELD_SPELL_ID",
	"STEALTH_SPELL_ID",
	"WELL_FED_SPELL_ID",
}

ns.DIAGNOSTIC_ITEM_ID_CONSTANTS = {
	"DARK_RUNE_ITEM_ID",
	"DEMONIC_RUNE_ITEM_ID",
}

-- The skill line and race IDs no lookup kind reads: Game Names checks each one's name instead.
ns.DIAGNOSTIC_OTHER_ID_CONSTANTS = {
	"ALCHEMY_SKILL_LINE_ID",
	"ENGINEERING_SKILL_LINE_ID",
	"FIRST_AID_SKILL_LINE_ID",
	"NIGHT_ELF_RACE_ID",
}

local CollectConstants = Collector(function(names, add)
	for _, name in ipairs(names) do
		add(ns[name], name, name)
	end
end)

local CONSTANT_COLUMN = { "DATA_CONSTANT", KeyValue }

ns.DIAGNOSTIC_DATA_SOURCES = {
	-- { label, sources = { { table, kind, rowId or collect, dataColumns } } }
	{
		label = "Bandages",
		sources = { { table = "BANDAGES", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Conjure-Spells",
		sources = {
			{ table = "CONJURE_SPELLS", kind = "spell", collect = CollectConjureSpells },
			{ table = "MISSING_SPELL_MESSAGE_IDS", kind = "spell", collect = CollectValues },
		},
	},
	{
		label = "Conjured-Items",
		sources = {
			{ table = "CONJURED_ITEM_IDS_BY_SPELL", kind = "spell", rowId = KeyIsId },
			{ table = "CONJURED_ITEM_IDS_BY_SPELL", kind = "item", collect = CollectListValues },
		},
	},
	{
		label = "Consumable-Upgrade-Paths",
		sources = { { table = "CONSUMABLE_UPGRADE_CHAINS", kind = "item", collect = CollectUpgradeTierItems } },
	},
	{
		label = "Elixirs",
		sources = {
			{ table = "FLASK_BUFF_IDS", kind = "spell", rowId = KeyIsId },
			{ table = "ELIXIR_BUFF_IDS", kind = "spell", rowId = KeyIsId },
		},
	},
	{
		label = "Explosives",
		sources = {
			{ table = "EXPLOSIVES", kind = "item", rowId = KeyIsId },
			{ table = "EXPLOSIVES", kind = "spell", collect = CollectColumn(4) },
		},
	},
	{
		label = "Food-and-Water",
		sources = { { table = "FOOD_AND_WATER", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Game-IDs",
		sources = {
			{
				table = "DIAGNOSTIC_SPELL_ID_CONSTANTS",
				kind = "spell",
				collect = CollectConstants,
				dataColumns = { CONSTANT_COLUMN },
			},
			{
				table = "DIAGNOSTIC_ITEM_ID_CONSTANTS",
				kind = "item",
				collect = CollectConstants,
				dataColumns = { CONSTANT_COLUMN },
			},
			{ table = "PET_BUFF_FOODS", kind = "item", rowId = KeyIsId },
			{ table = "PET_BUFF_FOODS", kind = "spell", collect = CollectColumn(1) },
			{ table = "DIAGNOSTIC_OTHER_ID_CONSTANTS", kind = "other" },
			{ table = "CANNIBALIZE_CREATURE_TYPE_IDS", kind = "other" },
		},
	},
	{
		label = "Healthstones",
		sources = { { table = "HEALTHSTONES", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Macro-Default-Items",
		sources = { { table = "MACRO_DEFAULT_ITEM_IDS", kind = "item", collect = CollectValues } },
	},
	{
		label = "Mana-Gems",
		sources = {
			{ table = "MANA_GEMS", kind = "item", rowId = KeyIsId },
			{ table = "MANA_RUNES", kind = "item", rowId = KeyIsId },
		},
	},
	{
		label = "Pet-Foods",
		sources = { { table = "PET_FOOD_DATA", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Poison-Recipes",
		sources = {
			{ table = "POISON_RECIPES", kind = "item", collect = CollectColumn(1) },
			{ table = "POISON_RECIPES", kind = "item", collect = CollectRecipeReagents },
		},
	},
	{
		label = "Poisons",
		sources = {
			{ table = "POISON_DATA", kind = "item", rowId = KeyIsId },
			{ table = "POISON_GROUP_BASE_ITEMS", kind = "item", collect = CollectValues },
		},
	},
	{
		label = "Potions",
		sources = { { table = "POTIONS", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Questionable-Equipment",
		sources = { { table = "QUESTIONABLE_EQUIPMENT", kind = "item", rowId = KeyIsId } },
	},
	{
		label = "Scrolls",
		sources = {
			{ table = "SCROLL_DATA", kind = "item", collect = CollectScrollColumn(1) },
			{ table = "SCROLL_DATA", kind = "spell", collect = CollectScrollColumn(2) },
			{ table = "SCROLL_DATA", kind = "spell", collect = CollectScrollConflictSpells },
		},
	},
	{
		label = "Soulstones",
		sources = {
			{ table = "SOULSTONES", kind = "item", rowId = KeyIsId },
			{ table = "SOULSTONE_BUFF_SPELL_IDS", kind = "spell", collect = CollectValues },
		},
	},
	{
		label = "Well-Fed-Buffs",
		sources = {
			{ table = "WELL_FED_BUFF_IDS", kind = "spell", rowId = KeyIsId },
			{ table = "WELL_FED_ICON_IDS", kind = "other" },
		},
	},
}
