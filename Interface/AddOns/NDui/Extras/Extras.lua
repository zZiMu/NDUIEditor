local B, C, L, DB = unpack(select(2, ...))

--- 修复世界地图错位
local old_ResetZoom = _G.WorldMapScrollFrame_ResetZoom
function _G.WorldMapScrollFrame_ResetZoom()
	if _G.InCombatLockdown() then
		_G.WorldMapFrame_Update()
		_G.WorldMapScrollFrame_ReanchorQuestPOIs()
		_G.WorldMapFrame_ResetPOIHitTranslations()
		_G.WorldMapBlobFrame_DelayedUpdateBlobs()
	else
		old_ResetZoom()
	end
end

--- 修复MirrorTimer重叠
local mt = {"MirrorTimer1", "MirrorTimer2", "MirrorTimer3"}
for i = 1, #mt do
	if i > 1 then
		_G[mt[i]]:SetPoint("TOP", _G[mt[i-1]], "BOTTOM", 0, -5)
	end
end

--- 修复部分职业大厅地图返回问题
local ohMap = {
	[23] = function() return select(4, GetMapInfo()) and 1007 end, -- Paladin, Sanctum of Light; Eastern Plaguelands
	[1040] = function() return 1007 end, -- Priest, Netherlight Temple; Azeroth
	[1044] = function() return 1007 end, -- Monk, Temple of Five Dawns; none
	[1048] = function() return 1007 end, -- Druid, Emerald Dreamway; none
	[1052] = function() return GetCurrentMapDungeonLevel() > 1 and 1007 end, -- Demon Hunter, Fel Hammer; Mardum
	[1088] = function() return GetCurrentMapDungeonLevel() == 3 and 1033 end, -- Nighthold -> Suramar
}
local OnClick = WorldMapZoomOutButton_OnClick
function WorldMapZoomOutButton_OnClick()
	local id = ohMap[GetCurrentMapAreaID()]
	local out = id and id()
	if out then
		SetMapByID(out)
	else
		OnClick()
	end
end

--- 共享计量条材质
local media = LibStub("LibSharedMedia-3.0")
media:Register("statusbar", "Altz01", [[Interface\AddOns\NDui\Media\StatusBar\Altz01]])
media:Register("statusbar", "Altz02", [[Interface\AddOns\NDui\Media\StatusBar\Altz02]])
media:Register("statusbar", "Altz03", [[Interface\AddOns\NDui\Media\StatusBar\Altz03]])
media:Register("statusbar", "Altz04", [[Interface\AddOns\NDui\Media\StatusBar\Altz04]])
media:Register("statusbar", "MaoR", [[Interface\AddOns\NDui\Media\StatusBar\MaoR]])
media:Register("statusbar", "normTex", [[Interface\AddOns\NDui\Media\normTex]])
media:Register("statusbar", "Ray01", [[Interface\AddOns\NDui\Media\StatusBar\Ray01]])
media:Register("statusbar", "Ray02", [[Interface\AddOns\NDui\Media\StatusBar\Ray02]])
media:Register("statusbar", "Ray03", [[Interface\AddOns\NDui\Media\StatusBar\Ray03]])
media:Register("statusbar", "Ray04", [[Interface\AddOns\NDui\Media\StatusBar\Ray04]])
media:Register("statusbar", "Ya01", [[Interface\AddOns\NDui\Media\StatusBar\Ya01]])
media:Register("statusbar", "Ya02", [[Interface\AddOns\NDui\Media\StatusBar\Ya02]])
media:Register("statusbar", "Ya03", [[Interface\AddOns\NDui\Media\StatusBar\Ya03]])
media:Register("statusbar", "Ya04", [[Interface\AddOns\NDui\Media\StatusBar\Ya04]])
media:Register("statusbar", "Ya05", [[Interface\AddOns\NDui\Media\StatusBar\Ya05]])

--- 自动填写DELETE
hooksecurefunc(StaticPopupDialogs["DELETE_GOOD_ITEM"], "OnShow", function(self)
	self.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
end)

--- 新人加入公会自动欢迎
local function GuildWelcome(event, msg)
	if not NDuiDB["Extras"]["GuildWelcome"] then return end
	local str = GUILDEVENT_TYPE_JOIN:gsub("%%s", "")
	if msg:find(str) then
		local name = msg:gsub(str, "")
		name = Ambiguate(name, "guild")
		if not UnitIsUnit(name, "player") then
			C_Timer.After(random(1000) / 1000, function()
				SendChatMessage(L["Guild Welcome Message"]:format(name), "GUILD")
			end)
		end
	end
end
B:RegisterEvent("CHAT_MSG_SYSTEM", GuildWelcome)

--- 优化巅峰声望显示
hooksecurefunc("ReputationFrame_Update",function()
	ReputationFrame.paragonFramesPool:ReleaseAll()
	local numFactions = GetNumFactions()
	local factionOffset = FauxScrollFrame_GetOffset(ReputationListScrollFrame)
	for i=1, NUM_FACTIONS_DISPLAYED, 1 do
		local factionIndex = factionOffset + i
		local factionRow = _G["ReputationBar"..i]
		local factionBar = _G["ReputationBar"..i.."ReputationBar"]
		local factionStanding = _G["ReputationBar"..i.."ReputationBarFactionStanding"]
		if factionIndex <= numFactions then
			local factionID = select(14, GetFactionInfo(factionIndex))
			if factionID and C_Reputation.IsFactionParagon(factionID) then
				local currentValue, threshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
				local value = mod(currentValue, threshold)
				if hasRewardPending then
					local paragonFrame = ReputationFrame.paragonFramesPool:Acquire()
					paragonFrame.factionID = factionID
					paragonFrame:SetPoint("RIGHT", factionRow, 11, 0)
					paragonFrame.Glow:SetShown(true)
					paragonFrame.Check:SetShown(true)
					paragonFrame:Show()
					value = value + threshold
				end
				factionBar:SetMinMaxValues(0, threshold)
				factionBar:SetValue(value)
				factionBar:SetStatusBarColor(0, .5, .9)
				factionRow.rolloverText = HIGHLIGHT_FONT_COLOR_CODE..format(REPUTATION_PROGRESS_FORMAT, BreakUpLargeNumbers(value), BreakUpLargeNumbers(threshold))..FONT_COLOR_CODE_CLOSE
				factionStanding:SetText(L["Paragon"])
				factionRow.standingText = L["Paragon"]
			end
		else
			factionRow:Hide()
		end
	end
end)

--- 神器能量提示当前专精和武器
GameTooltip:HookScript("OnTooltipSetItem", function(self)
	local _, link = self:GetItem()
	if type(link) == "string" then
		if IsArtifactPowerItem(link) then
			local artifactID, _, artifactName = C_ArtifactUI.GetEquippedArtifactInfo()
			if artifactName then
				local spec = GetSpecialization()
				local _, specName = GetSpecializationInfo(spec)
				if artifactName then
					self:AddLine(" ")
					self:AddDoubleLine(format(DB.MyColor.."<%s>", specName), format("|cffe6cc80[%s]", artifactName))
					self:Show()
				end
			end
		end
	end
end)

--- 特殊物品购买无需确认
--[[
MerchantItemButton_OnClick = function(self, button, ...)
	if MerchantFrame.selectedTab == 1 then
		MerchantFrame.extendedCost = nil
		MerchantFrame.highPrice = nil
		if button == "LeftButton" then
			if MerchantFrame.refundItem then
				if ContainerFrame_GetExtendedPriceString(MerchantFrame.refundItem, MerchantFrame.refundItemEquipped) then
					return
				end
			end
			PickupMerchantItem(self:GetID())
		else
			BuyMerchantItem(self:GetID())
		end
	end
end
]]