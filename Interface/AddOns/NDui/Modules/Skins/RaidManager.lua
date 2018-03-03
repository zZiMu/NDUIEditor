local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("Skins")

function module:CreateRM()
	if not NDuiDB["Skins"]["RM"] then return end
	local cr, cg, cb = DB.ClassColor.r, DB.ClassColor.g, DB.ClassColor.b

	local header = CreateFrame("Button", nil, UIParent)
	header:SetSize(120, 30)
	header:SetFrameLevel(2)
	B.CreateBD(header)
	B.CreateTex(header)
	B.CreateBC(header, .5)
	B.Mover(header, L["Raid Tool"], "RaidManager", C.Skins.RMPos)
	header:RegisterEvent("GROUP_ROSTER_UPDATE")
	header:RegisterEvent("PLAYER_ENTERING_WORLD")
	header:SetScript("OnEvent", function(self)
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		if IsInGroup() then
			self:Show()
		else
			self:Hide()
		end
	end)
	header:HookScript("OnEnter", function(self)
		if IsInInstance() then return end
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(DB.InfoColor..L["Double-click"]..DB.RightButton..PARTY_LEAVE)
		GameTooltip:Show()
	end)
	header:HookScript("OnLeave", GameTooltip_Hide)

	-- Role counts
	local function getRaidMaxGroup()
		local _, instType, difficulty = GetInstanceInfo()
		if (instType == "party" or instType == "scenario") and not IsInRaid() then
			return 1
		elseif instType ~= "raid" then
			return 8
		elseif difficulty == 8 or difficulty == 1 or difficulty == 2 or difficulty == 24 then
			return 1
		elseif difficulty == 14 or difficulty == 15 then
			return 6
		elseif difficulty == 16 then
			return 4
		elseif difficulty == 3 or difficulty == 5 then
			return 2
		elseif difficulty == 9 then
			return 8
		else
			return 5
		end
	end

	local roleTexCoord = {
		{.5, .75, 0, 1},
		{.75, 1, 0, 1},
		{.25, .5, 0, 1},
	}

	local roleFrame = CreateFrame("Frame", nil, header)
	roleFrame:SetAllPoints()
	local role = {}
	for i = 1, 3 do
		role[i] = roleFrame:CreateTexture(nil, "OVERLAY")
		role[i]:SetPoint("LEFT", 36*i-30, 0)
		role[i]:SetSize(15, 15)
		role[i]:SetTexture("Interface\\LFGFrame\\LFGROLE")
		role[i]:SetTexCoord(unpack(roleTexCoord[i]))
		role[i].text = B.CreateFS(roleFrame, 13, "0")
		role[i].text:ClearAllPoints()
		role[i].text:SetPoint("CENTER", role[i], "RIGHT", 12, 0)
	end

	roleFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
	roleFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	roleFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	roleFrame:RegisterEvent("UNIT_FLAGS")
	roleFrame:RegisterEvent("UPDATE_ACTIVE_BATTLEFIELD")
	roleFrame:SetScript("OnEvent", function()
		local raidCounts = {
			totalTANK = 0,
			totalHEALER = 0,
			totalDAMAGER = 0,
		}
		local maxgroup = getRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, _, _, online, isDead, _, _, assignedRole = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead and assignedRole ~= "NONE" then
				raidCounts["total"..assignedRole] = raidCounts["total"..assignedRole] + 1
			end
		end

		role[1].text:SetText(raidCounts.totalTANK)
		role[2].text:SetText(raidCounts.totalHEALER)
		role[3].text:SetText(raidCounts.totalDAMAGER)
	end)

	-- Battle resurrect
	local resFrame = CreateFrame("Frame", nil, header)
	resFrame:SetAllPoints()
	resFrame:SetAlpha(0)
	local res = CreateFrame("Frame", nil, resFrame)
	res:SetSize(20, 20)
	res:SetPoint("LEFT", 5, 0)
	B.CreateIF(res)
	res.Icon:SetTexture(GetSpellTexture(20484))
	res.Count = B.CreateFS(resFrame, 16, "0")
	res.Count:ClearAllPoints()
	res.Count:SetPoint("LEFT", res, "RIGHT", 5, 0)
	res.Timer = B.CreateFS(resFrame, 16, "00:00", false, "RIGHT", -5, 0)

	res:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed > .1 then
			local charges, _, started, duration = GetSpellCharges(20484)
			if charges then
				self.Count:SetText(charges)

				local timer = duration - (GetTime() - started)
				if timer < 0 then
					self.Timer:SetText(CAPPED)
				else
					self.Timer:SetFormattedText("%d:%.2d", timer/60, timer%60)
				end

				if charges == 0 then
					self.Count:SetTextColor(1, 0, 0)
				else
					self.Count:SetTextColor(0, 1, 0)
				end
				resFrame:SetAlpha(1)
				roleFrame:SetAlpha(0)
			else
				resFrame:SetAlpha(0)
				roleFrame:SetAlpha(1)
			end

			self.elapsed = 0
		end
	end)

	-- World marker
	local marker = CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton
	marker:ClearAllPoints()
	marker:SetPoint("RIGHT", header, "LEFT", 0, 0)
	marker:SetParent(header)
	marker:SetSize(30, 30)
	marker:GetNormalTexture():SetVertexColor(cr, cg, cb)
	marker.SetNormalTexture = B.Dummy
	marker.SetPushedTexture = B.Dummy
	for i = 1, 9 do
		select(i, marker:GetRegions()):Hide()
	end
	B.CreateBD(marker)
	B.CreateTex(marker)
	B.CreateBC(marker, .5)
	marker:HookScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then ClearRaidMarker() end
	end)
	marker:RegisterEvent("GROUP_ROSTER_UPDATE")
	marker:RegisterEvent("PLAYER_ENTERING_WORLD")
	marker:SetScript("OnEvent", function()
		marker:UnregisterEvent("PLAYER_ENTERING_WORLD")
		if (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
			marker:Enable()
			marker:SetAlpha(1)
		else
			marker:Disable()
			marker:SetAlpha(.5)
		end
	end)
	marker:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 0, 0)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(DB.RightButton..DB.InfoColor..REMOVE_WORLD_MARKERS)
		GameTooltip:Show()
	end)
	marker:HookScript("OnLeave", GameTooltip_Hide)

	-- Buff checker
	local checker = CreateFrame("Button", nil, header)
	checker:SetPoint("LEFT", header, "RIGHT", 0, 0)
	checker:SetSize(30, 30)
	B.CreateBD(checker)
	B.CreateTex(checker)
	B.CreateFS(checker, 16, "!", true, "CENTER", 0, 0)
	B.CreateBC(checker, .5)

	local BuffName = {L["Flask"], L["Food"], RUNES}
	local function scanBuff()
		local NoBuff, numPlayer = {}, 0
		for i = 1, 3 do NoBuff[i] = {} end
		local maxgroup = getRaidMaxGroup()
		for i = 1, GetNumGroupMembers() do
			local name, _, subgroup, _, _, class, _, online, isDead = GetRaidRosterInfo(i)
			if name and online and subgroup <= maxgroup and not isDead then
				numPlayer = numPlayer + 1
				for j = 1, 3 do
					local HasBuff
					local buffTable = DB.BuffList[j]
					for k = 1, #buffTable do
						local buffname = GetSpellInfo(buffTable[k])
						if UnitAura(name, buffname) then
							HasBuff = true
							break
						end
					end
					if not HasBuff then
						name = strsplit("-", name)	-- remove realm name
						table.insert(NoBuff[j], name)
					end
				end
			end
		end
		if not NDuiDB["Skins"]["RMRune"] then NoBuff[3] = {} end

		local debugMode = false
		local function sendMsg(text)
			if debugMode then
				print(text)
			else
				SendChatMessage(text, IsPartyLFG() and "INSTANCE_CHAT" or IsInRaid() and "RAID" or "PARTY")
			end
		end
		local function sendResult(i)
			if #NoBuff[i] > 0 then
				if #NoBuff[i] >= numPlayer then
					sendMsg(L["Lack"]..BuffName[i]..L[":"]..ALL..PLAYER)
				else
					local str = L["Lack"]..BuffName[i]..L[":"]
					for j = 1, #NoBuff[i] do
						str = str..NoBuff[i][j]..(j < #NoBuff[i] and L[","] or "")
						if #str > 230 then
							sendMsg(str)
							str = ""
						end
					end
					sendMsg(str)
				end
			end
		end

		if #NoBuff[1] == 0 and #NoBuff[2] == 0 and #NoBuff[3] == 0 then
			sendMsg(L["Buffs Ready"])
		else
			sendMsg(L["Raid Buff Check"])
			for i = 1, 2 do sendResult(i) end
			if NDuiDB["Skins"]["RMRune"] then sendResult(3) end
		end
	end

	checker:HookScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 0)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(DB.LeftButton..DB.InfoColor..READY_CHECK)
		GameTooltip:AddLine(DB.ScrollButton..DB.InfoColor..L["Count Down"])
		GameTooltip:AddLine(DB.RightButton..DB.InfoColor..L["Check Status"])
		GameTooltip:Show()
	end)
	checker:HookScript("OnLeave", GameTooltip_Hide)

	local reset = true
	checker:RegisterForClicks("AnyUp")
	checker:SetScript("OnClick", function(_, btn)
		if InCombatLockdown() then return end
		if btn == "RightButton" then
			scanBuff()
		elseif btn == "LeftButton" then
			DoReadyCheck()
		else
			if IsAddOnLoaded("DBM-Core") then
				if reset then
					SlashCmdList["DEADLYBOSSMODS"]("pull "..NDuiDB["Skins"]["DBMCount"])
				else
					SlashCmdList["DEADLYBOSSMODS"]("pull 0")
				end
				reset = not reset
			elseif IsAddOnLoaded("BigWigs") then
				if not SlashCmdList["BIGWIGSPULL"] then LoadAddOn("BigWigs_Plugins") end
				if reset then
					SlashCmdList["BIGWIGSPULL"](NDuiDB["Skins"]["DBMCount"])
				else
					SlashCmdList["BIGWIGSPULL"]("0")
				end
				reset = not reset
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..L["DBM Required"])
			end
		end
	end)
	checker:RegisterEvent("GROUP_ROSTER_UPDATE")
	checker:RegisterEvent("PLAYER_ENTERING_WORLD")
	checker:RegisterEvent("PLAYER_REGEN_ENABLED")
	checker:SetScript("OnEvent", function()
		checker:UnregisterEvent("PLAYER_ENTERING_WORLD")
		reset = true
		if UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
			checker:Enable()
			checker:SetAlpha(1)
		else
			checker:Disable()
			checker:SetAlpha(.5)
		end
	end)

	-- Others
	local menu = CreateFrame("Frame", nil, header)
	menu:SetPoint("TOP", header, "BOTTOM")
	menu:SetSize(180, 70)
	B.CreateBD(menu)
	B.CreateTex(menu)
	menu:Hide()
	menu:SetScript("OnLeave", function(self)
		self:SetScript("OnUpdate", function(self, elapsed)
			self.timer = (self.timer or 0) + elapsed
			if self.timer > .1 then
				if not menu:IsMouseOver() then
					self:Hide()
					self:SetScript("OnUpdate", nil)
				end

				self.timer = 0
			end
		end)
	end)

	StaticPopupDialogs["Group_Disband"] = {
		text = L["Disband Info"],
		button1 = YES,
		button2 = NO,
		OnAccept = function()
			if InCombatLockdown() then return end
			if IsInRaid() then
				SendChatMessage(L["Disband Process"], "RAID")
				for i = 1, GetNumGroupMembers() do
					local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
					if online and name ~= UnitName("player") then
						UninviteUnit(name)
					end
				end
			else
				for i = MAX_PARTY_MEMBERS, 1, -1 do
					if UnitExists("party"..i) then
						UninviteUnit(UnitName("party"..i))
					end
				end
			end
			LeaveParty()
		end,
		timeout = 0,
		whileDead = 1,
	}

	local buttons = {
		{TEAM_DISBAND, function()
			if UnitIsGroupLeader("player") then
				StaticPopup_Show("Group_Disband")
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end},
		{CONVERT_TO_RAID, function()
			if UnitIsGroupLeader("player") and not HasLFGRestrictions() and GetNumGroupMembers() <= 5 then
				if IsInRaid() then ConvertToParty() else ConvertToRaid() end
				menu:Hide()
				menu:SetScript("OnUpdate", nil)
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end},
		{ROLE_POLL, function()
			if IsInGroup() and not HasLFGRestrictions() and (UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")) then
				InitiateRolePoll()
			else
				UIErrorsFrame:AddMessage(DB.InfoColor..ERR_NOT_LEADER)
			end
		end},
		{RAID_CONTROL, function() ToggleFriendsFrame(4) end},
	}
	local bu = {}
	for i, j in pairs(buttons) do
		bu[i] = CreateFrame("Button", nil, menu)
		bu[i]:SetPoint(mod(i, 2) == 0 and "TOPRIGHT" or "TOPLEFT", mod(i, 2) == 0 and -5 or 5, i > 2 and -35 or -5)
		bu[i]:SetSize(85, 30)
		B.CreateBD(bu[i], .3)
		B.CreateBC(bu[i])
		bu[i]:SetScript("OnClick", j[2])
		bu[i].text = B.CreateFS(bu[i], 12, j[1], true)
	end

	local function updateText(text)
		if IsInRaid() then
			text:SetText(CONVERT_TO_PARTY)
		else
			text:SetText(CONVERT_TO_RAID)
		end
	end
	header:RegisterForClicks("AnyUp")
	header:SetScript("OnClick", function(_, btn)
		if btn == "LeftButton" then
			ToggleFrame(menu)
			updateText(bu[2].text)
		end
	end)
	header:SetScript("OnDoubleClick", function(_, btn)
		if btn == "RightButton" and not IsInInstance() then
			LeaveParty()
		end
	end)

	-- Easymarking
	local menuFrame = CreateFrame("Frame", "NDui_EastMarking", UIParent, "UIDropDownMenuTemplate")
	local menuList = {
		{text = RAID_TARGET_NONE, func = function() SetRaidTarget("target", 0) end},
		{text = B.HexRGB(1, .92, 0)..RAID_TARGET_1.." "..ICON_LIST[1].."12|t", func = function() SetRaidTarget("target", 1) end},
		{text = B.HexRGB(.98, .57, 0)..RAID_TARGET_2.." "..ICON_LIST[2].."12|t", func = function() SetRaidTarget("target", 2) end},
		{text = B.HexRGB(.83, .22, .9)..RAID_TARGET_3.." "..ICON_LIST[3].."12|t", func = function() SetRaidTarget("target", 3) end},
		{text = B.HexRGB(.04, .95, 0)..RAID_TARGET_4.." "..ICON_LIST[4].."12|t", func = function() SetRaidTarget("target", 4) end},
		{text = B.HexRGB(.7, .82, .875)..RAID_TARGET_5.." "..ICON_LIST[5].."12|t", func = function() SetRaidTarget("target", 5) end},
		{text = B.HexRGB(0, .71, 1)..RAID_TARGET_6.." "..ICON_LIST[6].."12|t", func = function() SetRaidTarget("target", 6) end},
		{text = B.HexRGB(1, .24, .168)..RAID_TARGET_7.." "..ICON_LIST[7].."12|t", func = function() SetRaidTarget("target", 7) end},
		{text = B.HexRGB(.98, .98, .98)..RAID_TARGET_8.." "..ICON_LIST[8].."12|t", func = function() SetRaidTarget("target", 8) end},
	}

	WorldFrame:HookScript("OnMouseDown", function(_, btn)
		if not NDuiDB["Skins"]["EasyMarking"] then return end
		if btn == "LeftButton" and IsControlKeyDown() and UnitExists("mouseover") then
			if not IsInGroup() or (IsInGroup() and not IsInRaid()) or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player") then
				local ricon = GetRaidTargetIndex("mouseover")
				for i = 1, 8 do
					if ricon == i then
						menuList[i+1].checked = true
					else
						menuList[i+1].checked = false
					end
				end
				EasyMenu(menuList, menuFrame, "cursor", 0, 0, "MENU", 1)
			end
		end
	end)
end