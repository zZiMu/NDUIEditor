local addon, ns = ...
local cfg = ns.cfg
local init = ns.init

if cfg.System == true then
	local Stat = CreateFrame("Frame", nil, UIParent)
	Stat:EnableMouse(true)
	Stat:SetFrameLevel(3)
	Stat:SetFrameStrata("BACKGROUND")
	Stat:SetHitRectInsets(0, 0, 0, -10)
	local Text = Stat:CreateFontString(nil, "OVERLAY")
	Text:SetFont(unpack(cfg.Fonts))
	Text:SetPoint(unpack(cfg.SystemPoint))
	Stat:SetAllPoints(Text)

	local function colorLatency(latency)
		if latency < 300 then
			return "|cff0CD809"..latency.."|r"
		elseif (latency >= 300 and latency < 500) then
			return "|cffE8DA0F"..latency.."|r"
		else
			return "|cffD80909"..latency.."|r"
		end
	end

	local function colorFps(fps)
		if fps >= 30 then
			return "|cff0CD809"..fps.."|r"
		elseif (fps > 15 and fps < 30) then
			return "|cffE8DA0F"..fps.."|r"
		else
			return "|cffD80909"..fps.."|r"
		end
	end

	local int = 1
	local function Update(self, t)
		int = int - t

		if int < 0 then
			local _, _, latencyHome, latencyWorld = GetNetStats()
			local lat = math.max(latencyHome, latencyWorld)
			local fps = floor(GetFramerate())

			Text:SetText(colorFps(fps).."Fps"..init.Colored.." / |r"..colorLatency(lat).."Ms")
			int = .8
		end
	end

	local UsageTable
	local function RefreshUsage()
		UsageTable = {}
		UpdateAddOnCPUUsage()
		local total, count = .001, 0
		for i = 1, GetNumAddOns() do
			if IsAddOnLoaded(i) then
				count = count + 1
				local usage = GetAddOnCPUUsage(i)
				UsageTable[count] = {select(2, GetAddOnInfo(i)), usage}
				total = total + usage
			end
		end

		table.sort(UsageTable, function(a, b)
			if a and b then
				return a[2] > b[2]
			end
		end)
		return total
	end

	StaticPopupDialogs["CPUUSAGE"] = {
		text = infoL["Toggle CPU Usage"],
		button1 = APPLY,
		button2 = CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
		OnAccept = function()
			ReloadUI()
		end,
		whileDead = 1,
	}

	Stat:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, -15)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(infoL["System"], 0,.6,1)
		GameTooltip:AddLine(" ")

		if GetCVar("scriptProfile") == "1" then
			local totalUsage = RefreshUsage()
			local maxAddOns = math.min(cfg.MaxAddOns, #UsageTable)
			if IsShiftKeyDown() then
				maxAddOns = #UsageTable
			end

			for i = 1, maxAddOns do
				local percent = UsageTable[i][2]/totalUsage * 100
				local color = percent <= 1 and {0, 1} -- 0 - 1
				or percent <= 5 and {.75, 1} -- 1 - 5
				or percent <= 10 and {1, 1} -- 5 - 10
				or percent <= 25 and {1, .75} -- 10 - 25
				or percent <= 50 and {1, .5} -- 25 - 50
				or {1, .1} -- 50 +
				GameTooltip:AddDoubleLine(UsageTable[i][1], format("%.1f%s", percent, " %"), 1, 1, 1, color[1], color[2], 0)
			end

			local hiddenUsage = 0
			if not IsShiftKeyDown() then
				for i = (cfg.MaxAddOns + 1), #UsageTable do
					hiddenUsage = hiddenUsage + UsageTable[i][2]
				end
				if #UsageTable > cfg.MaxAddOns then
					local numHidden = #UsageTable - cfg.MaxAddOns
					GameTooltip:AddDoubleLine(format("%s（%s）：%d", infoL["Hidden"], infoL["Shift"], numHidden), format("%.1f%s", hiddenUsage/totalUsage*100, " %"), .6,.8,1, .6,.8,1)
				end
			end
			GameTooltip:AddLine(" ")
		end

		local _, _, latencyHome, latencyWorld = GetNetStats()
		GameTooltip:AddDoubleLine(infoL["Latency:"], format("%s%s(%s) / %s%s(%s)", colorLatency(latencyHome).."|r", "Ms", infoL["Home"], colorLatency(latencyWorld).."|r", "Ms", CHANNEL_CATEGORY_WORLD), .6,.8,1, 1,1,1)
		GameTooltip:AddDoubleLine(" ", "--------------", 1,1,1, .5,.5,.5)
		GameTooltip:AddDoubleLine(" ", init.RightButton..infoL["CPU Usage:"]..(GetCVar("scriptProfile") == "1" and "|cff55ff55"..VIDEO_OPTIONS_ENABLED or "|cffff5555"..VIDEO_OPTIONS_DISABLED), 1,1,1, .6,.8,1)
		GameTooltip:Show()
	end)

	local status = GetCVar("scriptProfile")
	Stat:SetScript("OnLeave", GameTooltip_Hide)
	Stat:SetScript("OnMouseUp", function(self, btn)
		if btn == "RightButton" then
			if GetCVar("scriptProfile") == "0" then
				SetCVar("scriptProfile", 1)
			else
				SetCVar("scriptProfile", 0)
			end

			if GetCVar("scriptProfile") == status then
				StaticPopup_Hide("CPUUSAGE")
			else
				StaticPopup_Show("CPUUSAGE")
			end
			self:GetScript("OnEnter")(self)
		end
	end)
	Stat:SetScript("OnUpdate", Update)
end