﻿

local B, C, L, DB = unpack(select(2, ...))

	frame = CreateFrame("Frame", "CustomEmoteFrame", UIParent)
	B.CreateMF(frame)
	B.CreateBD(frame)
	B.CreateTex(frame)
	local close = CreateFrame("Button", nil, frame)
	close:SetPoint("TOPRIGHT", -10, -10)
	close:SetSize(20, 20)
	close:SetScript("OnClick", function(self) frame:Hide() end)