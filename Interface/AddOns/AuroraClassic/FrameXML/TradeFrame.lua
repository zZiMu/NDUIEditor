local F, C = unpack(select(2, ...))

tinsert(C.themes["AuroraClassic"], function()
	TradePlayerEnchantInset:DisableDrawLayer("BORDER")
	TradePlayerItemsInset:DisableDrawLayer("BORDER")
	TradeRecipientEnchantInset:DisableDrawLayer("BORDER")
	TradeRecipientItemsInset:DisableDrawLayer("BORDER")
	TradePlayerInputMoneyInset:DisableDrawLayer("BORDER")
	TradeRecipientMoneyInset:DisableDrawLayer("BORDER")
	TradeRecipientBG:Hide()
	TradePlayerEnchantInsetBg:Hide()
	TradePlayerItemsInsetBg:Hide()
	TradePlayerInputMoneyInsetBg:Hide()
	TradeRecipientEnchantInsetBg:Hide()
	TradeRecipientItemsInsetBg:Hide()
	TradeRecipientMoneyBg:Hide()
	TradeRecipientPortraitFrame:Hide()
	TradeRecipientBotLeftCorner:Hide()
	TradeRecipientLeftBorder:Hide()
	select(4, TradePlayerItem7:GetRegions()):Hide()
	select(4, TradeRecipientItem7:GetRegions()):Hide()
	TradeFramePlayerPortrait:Hide()
	TradeFrameRecipientPortrait:Hide()

	F.ReskinPortraitFrame(TradeFrame, true)
	F.Reskin(TradeFrameTradeButton)
	F.Reskin(TradeFrameCancelButton)
	F.ReskinInput(TradePlayerInputMoneyFrameGold)
	F.ReskinInput(TradePlayerInputMoneyFrameSilver)
	F.ReskinInput(TradePlayerInputMoneyFrameCopper)

	TradePlayerInputMoneyFrameSilver:SetPoint("LEFT", TradePlayerInputMoneyFrameGold, "RIGHT", 1, 0)
	TradePlayerInputMoneyFrameCopper:SetPoint("LEFT", TradePlayerInputMoneyFrameSilver, "RIGHT", 1, 0)

	for i = 1, MAX_TRADE_ITEMS do
		local bu1 = _G["TradePlayerItem"..i.."ItemButton"]
		local bu2 = _G["TradeRecipientItem"..i.."ItemButton"]

		_G["TradePlayerItem"..i.."SlotTexture"]:Hide()
		_G["TradePlayerItem"..i.."NameFrame"]:Hide()
		_G["TradeRecipientItem"..i.."SlotTexture"]:Hide()
		_G["TradeRecipientItem"..i.."NameFrame"]:Hide()

		bu1:SetNormalTexture("")
		bu1:SetPushedTexture("")
		bu1.icon:SetTexCoord(.08, .92, .08, .92)
		bu1.IconBorder:SetAlpha(0)
		bu2:SetNormalTexture("")
		bu2:SetPushedTexture("")
		bu2.icon:SetTexCoord(.08, .92, .08, .92)
		bu2.IconBorder:SetAlpha(0)

		local bg1 = CreateFrame("Frame", nil, bu1)
		bg1:SetPoint("TOPLEFT", -1, 1)
		bg1:SetPoint("BOTTOMRIGHT", 1, -1)
		bg1:SetFrameLevel(bu1:GetFrameLevel()-1)
		F.CreateBD(bg1, .25)
		F.CreateSD(bg1)

		local bg2 = CreateFrame("Frame", nil, bu2)
		bg2:SetPoint("TOPLEFT", -1, 1)
		bg2:SetPoint("BOTTOMRIGHT", 1, -1)
		bg2:SetFrameLevel(bu2:GetFrameLevel()-1)
		F.CreateBD(bg2, .25)
		F.CreateSD(bg2)
	end
end)