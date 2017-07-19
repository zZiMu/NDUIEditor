--[[

	xMerchant
	Copyright (c) 2010-2014, Nils Ruesch
	All rights reserved.

]]

local addonName, xMerchant = ...;
local L = xMerchant.L;
local buttons = {};
local knowns = {};
local errors = {};
-- DONEY
local factions = {};
local currencies = {};
local searching = "";
-- local RECIPE = select(7, GetAuctionItemClasses()); --deprecated API 5.0
-- DONEY
local RECIPE = GetItemClassInfo(LE_ITEM_CLASS_RECIPE); -- new API 7.0
--[[
@see: https://github.com/tomrus88/BlizzardInterfaceCode/blob/master/Interface/AddOns/Blizzard_AuctionUI/Blizzard_AuctionData.lua
LE_ITEM_CLASS_WEAPON
LE_ITEM_CLASS_ARMOR
LE_ITEM_CLASS_CONTAINER
LE_ITEM_CLASS_GEM
LE_ITEM_CLASS_ITEM_ENHANCEMENT
LE_ITEM_CLASS_CONSUMABLE
LE_ITEM_CLASS_GLYPH
LE_ITEM_CLASS_TRADEGOODS
LE_ITEM_CLASS_RECIPE
LE_ITEM_CLASS_BATTLEPET
LE_ITEM_CLASS_QUESTITEM
LE_ITEM_CLASS_MISCELLANEOUS
]]
local REQUIRES_LEVEL = L["Requires Level (%d+)"];
local LEVEL = L["Level %d"];
local REQUIRES_REPUTATION = L["Requires .+ %- (.+)"];
-- DONEY
local REQUIRES_REPUTATION_NAME = L["Requires (.+) %- .+"];
local REQUIRES_SKILL = L["Requires (.+) %((%d+)%)"];
local SKILL = L["%1$s (%2$d)"];
local REQUIRES = L["Requires (.+)"];
local tooltip = CreateFrame("GameTooltip", "xMerchantTooltip", UIParent, "GameTooltipTemplate");

function getCurrentDB()
	return xMerchantDB and xMerchantDB.global or {}
end

-- DONEY
local ENABLE_DEBUG_DONEY = false;


-- DONEY
local XMERCHANT_DEBUG_TAGS = {};
XMERCHANT_DEBUG_TAGS["[GetError]"] = 0;
XMERCHANT_DEBUG_TAGS["[GetKnown]"] = 0;
XMERCHANT_DEBUG_TAGS["[AltCurrency]"] = 0;
XMERCHANT_DEBUG_TAGS["[CurrencyFrames]"] = 1;
XMERCHANT_DEBUG_TAGS["[CurrencyUpdate]"] = 0;
XMERCHANT_DEBUG_TAGS["[FactionsUpdate]"] = 0;
XMERCHANT_DEBUG_TAGS["[Faction]"] = 0;
XMERCHANT_DEBUG_TAGS["[MerchantItemInfo]"] = 0;

-- DONEY
local function XMERCHANT_LOGD(msg)
	if (ENABLE_DEBUG_DONEY) then
		local pos = strfind(msg, " ");
		local tag = pos and pos > 0 and strsub(msg, 0, pos-1) or "";
		--DEFAULT_CHAT_FRAME:AddMessage("[xMerchant][Debug] pos: "..(pos or "nil").."  tag: ["..(tag or "nil").."]  TAGS: "..(XMERCHANT_DEBUG_TAGS[tag] or "nil"));

		if not tag
		or tag and not XMERCHANT_DEBUG_TAGS[tag]
		or tag and XMERCHANT_DEBUG_TAGS[tag] and XMERCHANT_DEBUG_TAGS[tag] == 1 then
			DEFAULT_CHAT_FRAME:AddMessage("[xMer][D] "..msg);
		end
	end
end
function xMerchant.LOGW(msg)
	DEFAULT_CHAT_FRAME:AddMessage("[xMerchant][Warning] "..msg);
end
local LOGW = xMerchant.LOGW

local function GetError(link, isRecipe)
	--XMERCHANT_LOGD("==== GetError ====   link: "..link);
	if ( not link ) then
		return false;
	end

	local id = link:match("item:(%d+)");
	if ( errors[id] ) then
		XMERCHANT_LOGD("[GetError]  "..link.."  @return errors[id]: "..errors[id]);
		return errors[id];
	end

	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	tooltip:SetHyperlink(link);

	local errormsg = "";
	for i=2, tooltip:NumLines() do
		local text = _G["xMerchantTooltipTextLeft"..i];
		local r, g, b = text:GetTextColor();
		local gettext = text:GetText();
		if ( gettext and r >= 0.9 and g <= 0.2 and b <= 0.2 and gettext ~= RETRIEVING_ITEM_INFO ) then
			if ( errormsg ~= "" ) then
				errormsg = errormsg..", ";
			end

			local level = gettext:match(REQUIRES_LEVEL);
			if ( level ) then
				errormsg = errormsg..LEVEL:format(level);
			end

			local reputation = gettext:match(REQUIRES_REPUTATION);
			if ( reputation ) then
				errormsg = errormsg..reputation;
				-- DONEY
				local factionName = gettext:match(REQUIRES_REPUTATION_NAME);
				if ( factionName ) then
					local standingLabel = factions[factionName];
					if ( standingLabel ) then
						errormsg = errormsg.." ("..standingLabel..") - "..factionName;
					else
						errormsg = errormsg.." ("..factionName..")";
					end
				end
				XMERCHANT_LOGD("RequireFaction  ".."  : "..(reputation or "").."  : "..(factionName or ""));
			end

			local skill, slevel = gettext:match(REQUIRES_SKILL);
			if ( skill and slevel ) then
				errormsg = errormsg..SKILL:format(skill, slevel);
			end

			local requires = gettext:match(REQUIRES);
			if ( not level and not reputation and not skill and requires ) then
				XMERCHANT_LOGD("[GetError]  Line: "..i.."   REQUIRES: "..(requires or ""));
				errormsg = errormsg..requires;
			end

			if ( not level and not reputation and not skill and not requires ) then
				if ( errormsg ~= "" ) then
					errormsg = gettext..", "..errormsg;
				else
					errormsg = errormsg..gettext;
				end
			end
		end

		local text = _G["xMerchantTooltipTextRight"..i];
		local r, g, b = text:GetTextColor();
		local gettext = text:GetText();
		if ( gettext and r >= 0.9 and g <= 0.2 and b <= 0.2 ) then
			if ( errormsg ~= "" ) then
				errormsg = errormsg..", ";
			end
			errormsg = errormsg..gettext;
		end

		XMERCHANT_LOGD("[GetError]  Line: "..i.."   TooltipTextLeft: "..(_G["xMerchantTooltipTextLeft"..i]:GetText() or ""));
		XMERCHANT_LOGD("[GetError]  Line: "..i.."   TooltipTextRight: "..(_G["xMerchantTooltipTextRight"..i]:GetText() or ""));

		if ( isRecipe and i == 5 ) then
			XMERCHANT_LOGD("[GetError]  Line: "..i.."   isRecipe detail line");
			break;
		end
	end

	if ( errormsg == "" ) then
		return false;
	end

	errors[id] = errormsg;
	return errormsg;
end

local function GetKnown(link)
	--XMERCHANT_LOGD("==== GetKnown ====   link: "..link);
	if ( not link ) then
		--XMERCHANT_LOGD("[GetKnown]  not link   @return false");
		return false;
	end

	local id = link:match("item:(%d+)");
	if ( knowns[id] ) then
		XMERCHANT_LOGD("[GetKnown]  "..link.."  @return true");
		return true;
	end

	tooltip:SetOwner(UIParent, "ANCHOR_NONE");
	tooltip:SetHyperlink(link);

	for i=1, tooltip:NumLines() do
		if ( _G["xMerchantTooltipTextLeft"..i]:GetText() == ITEM_SPELL_KNOWN ) then
			knowns[id] = true;
			--XMERCHANT_LOGD("[GetKnown]  Line: "..i.."  ".._G["xMerchantTooltipTextLeft"..i]:GetText());
			return true;
		end
	end

	return false;
end

-- DONEY
local function FactionsUpdate()
	wipe(factions);

	for factionIndex = 1, GetNumFactions() do
		-- Patch 5.0.4 Added new return value: factionID
		local name, description, standingId, bottomValue, topValue, earnedValue, atWarWith, canToggleAtWar, isHeader, isCollapsed, hasRep, isWatched, isChild, factionID = GetFactionInfo(factionIndex);

		if name~=nil and factionID~=nil then
			-- Patch 5.1.0 Added API GetFriendshipReputation
			local friendID, friendRep, friendMaxRep, friendName, friendText, friendTexture, friendTextLevel = GetFriendshipReputation(factionID)

			local standingLabel
			if isHeader == nil then
				-- thanks to SSJNinjaMonkey @ curse
				--[[ debug code ]]
				--[[
				if standingId == 1 then
					standingId = 10
				end
				if standingId == 2 then
					standingId = 9
				end
				--]]
				if friendID~=nil then
					standingLabel = friendTextLevel or "unkown"
				else
					standingLabel = (_G["FACTION_STANDING_LABEL"..tostring(standingId)] or "unkown")
				end
				factions[name] = standingLabel

				if friendID ~= nil then
					XMERCHANT_LOGD("[FactionsUpdate]  " .. name .. " - " .. earnedValue .. " - " .. bottomValue .. " - " .. topValue .. " - " .. tostring(standingId) .. " " .. standingLabel);
				end
			end
		end
	end
end

local function CurrencyUpdate()
	wipe(currencies);

	local limit = GetCurrencyListSize();
	XMERCHANT_LOGD("[CurrencyUpdate] GetCurrencyListSize  limit: "..limit);

	for i=1, limit do
		-- DONEY note for 6.0   the itemID seemes not avail any more, while the http://wowpedia.org/API_GetCurrencyListInfo is out-dated, 2014-10-25
		local name, isHeader, _, _, _, count, icon, maximum, hasWeeklyLimit, currentWeeklyAmount, _, itemID = GetCurrencyListInfo(i);
		if ( not isHeader ) then
			XMERCHANT_LOGD("[CurrencyUpdate]  ".."  name: "..(name or "nil").."  count: "..(count or "nil").."  maxi: "..(maximum or "nil").."  itemID: "..(itemID or "nil"));
		end
		if ( not isHeader and itemID ) then
			currencies[tonumber(itemID)] = count;
			-- DONEY fix for 5.0 points
			if ( not isHeader and itemID and tonumber(itemID) <= 9 ) then
				currencies[name] = count;
			end
		elseif ( not isHeader and not itemID ) then
			currencies[name] = count;
			XMERCHANT_LOGD("[CurrencyUpdate]  ".."  name: "..(name or "nil").."  not itemID");
		end
	end

	XMERCHANT_DEBUG_TAGS["CurrencyUpdate"] = 0;

	for i=INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED, 1 do
		local itemID = GetInventoryItemID("player", i);
		if ( itemID ) then
			currencies[tonumber(itemID)] = 1;
		end
	end

	for bagID=0, NUM_BAG_SLOTS, 1 do
		local numSlots = GetContainerNumSlots(bagID);
		for slotID=1, numSlots, 1 do
			local itemID = GetContainerItemID(bagID, slotID);
			if ( itemID ) then
				local count = select(2, GetContainerItemInfo(bagID, slotID));
				itemID = tonumber(itemID);
				local currency = currencies[itemID];
				if ( currency ) then
					currencies[itemID] = currency+count;
				else
					currencies[itemID] = count;
				end
			end
		end
	end
end

local function AltCurrencyFrame_Update(item, texture, cost, itemID, currencyName)
	if ( itemID ~= 0 or currencyName) then
		local currency = currencies[itemID] or currencies[currencyName];
		if ( currency and currency < cost or not currency ) then
			-- DONEY
			XMERCHANT_LOGD("[AltCurrency]  currency: "..(currency or "nil").."  cost: "..(cost or "nil").."  itemID: "..(itemID or "nil").."  currencyName: "..(currencyName or "nil"));
			item.count:SetTextColor(1, 0, 0);
		else
			item.count:SetTextColor(1, 1, 1);
		end
	end

	item.count:SetText(cost);
	item.icon:SetTexture(texture);
	if ( item.pointType == HONOR_POINTS ) then
		item.count:SetPoint("RIGHT", item.icon, "LEFT", 1, 0);
		--item.icon:SetTexCoord(0.03125, 0.59375, 0.03125, 0.59375);
	else
		item.count:SetPoint("RIGHT", item.icon, "LEFT", -2, 0);
		--item.icon:SetTexCoord(0, 1, 0, 1);
	end
	local iconWidth = 17;
	item.icon:SetWidth(iconWidth);
	item.icon:SetHeight(iconWidth);
	item:SetWidth(item.count:GetWidth() + iconWidth + 4);
	item:SetHeight(item.count:GetHeight() + 4);
	-- Aurora Reskin
	if IsAddOnLoaded("Aurora") then
		if not item.styled then
			local F = unpack(Aurora)
			F.ReskinIcon(item.icon)
			item.styled = true
		end
	end
end

local function UpdateAltCurrency(button, index, i)
	XMERCHANT_LOGD("[CurrencyFrames] UpdateAltCurrency  ".." index: "..index.." i: "..i);
	local currency_frames = {};
	local lastFrame;
	local honorPoints, arenaPoints, itemCount = GetMerchantItemCostInfo(index);

	if ( select(4, GetBuildInfo()) >= 40000 ) then
		itemCount, honorPoints, arenaPoints = honorPoints, 0, 0;
	end

	if ( itemCount > 0 ) then
		for i=1, MAX_ITEM_COST, 1 do
			local itemTexture, itemValue, itemLink, currencyName = GetMerchantItemCostItem(index, i);
			local item = button.item[i];
			item.index = index;
			item.item = i;
			if( currencyName ) then
				item.pointType = "Beta";
				item.itemLink = currencyName;
			else
				item.pointType = nil;
				item.itemLink = itemLink;
			end

			-- DONEY
			if i == 1 then
				XMERCHANT_LOGD("[AltCurrency]  ".."  index: "..(index or "nil").."  itemLink: "..(itemLink or "nil").."  i: "..(i or "nil"));
			end
			local itemID = tonumber((itemLink or "item:0"):match("item:(%d+)"));
			AltCurrencyFrame_Update(item, itemTexture, itemValue, itemID, currencyName);

			if ( not itemTexture ) then
				item:Hide();
			else
				lastFrame = item;
				lastFrame._dbg_name = "item"..i
				table.insert(currency_frames, item)
				item:Show();
			end
		end
	else
		for i=1, MAX_ITEM_COST, 1 do
			button.item[i]:Hide();
		end
	end

	local arena = button.arena;
	if ( arenaPoints > 0 ) then
		arena.pointType = ARENA_POINTS;

		AltCurrencyFrame_Update(arena, "Interface\\PVPFrame\\PVP-ArenaPoints-Icon", arenaPoints);

		if ( GetArenaCurrency() < arenaPoints ) then
			arena.count:SetTextColor(1, 0, 0);
		else
			arena.count:SetTextColor(1, 1, 1);
		end

		lastFrame = arena;
		lastFrame._dbg_name = "arena"
		table.insert(currency_frames, arena)
		arena:Show();
	else
		arena:Hide();
	end

	local honor = button.honor;
	if ( honorPoints > 0 ) then
		honor.pointType = HONOR_POINTS;

		local factionGroup = UnitFactionGroup("player");
		local honorTexture = "Interface\\TargetingFrame\\UI-PVP-Horde";
		if ( factionGroup ) then
			honorTexture = "Interface\\TargetingFrame\\UI-PVP-"..factionGroup;
		end

		AltCurrencyFrame_Update(honor, honorTexture, honorPoints);

		if ( GetHonorCurrency() < honorPoints ) then
			honor.count:SetTextColor(1, 0, 0);
		else
			honor.count:SetTextColor(1, 1, 1);
		end

		lastFrame = honor;
		lastFrame._dbg_name = "honor"
		table.insert(currency_frames, arena)
		honor:Show();
	else
		honor:Hide();
	end

	button.money._dbg_name = "money"
	table.insert(currency_frames, button.money)

	-- DONEY
	lastFrame = nil
	for i,frame in ipairs(currency_frames) do
		if i == 1 then
			XMERCHANT_LOGD("[CurrencyFrames]  i: "..i.."  "..frame._dbg_name.."  RIGHT +");
			frame:SetPoint("RIGHT", -2, 0)
		else
			if lastFrame then
				XMERCHANT_LOGD("[CurrencyFrames]  i: "..i.."  "..frame._dbg_name.."  RIGHT to "..lastFrame._dbg_name);
				frame:SetPoint("RIGHT", lastFrame, "LEFT", -2, 0);
			else
				-- warning, lastFrame nil unexpected
				XMERCHANT_LOGD("[CurrencyFrames]  i: "..i.."  "..frame._dbg_name.."  lastFrame nil unexpected!");
				frame:SetPoint("RIGHT", -2, 0);
			end
		end
		lastFrame = frame
	end
end

xMerchant.kItemButtonHeight = 29.4

local function MerchantUpdate()
	XMERCHANT_LOGD("[xMerchant][Debug] MerchantUpdate");
	local self = xMerchantFrame;
	local numMerchantItems = GetMerchantNumItems();

	--[[
	if (ENABLE_DEBUG_DONEY) then
		local itemClasses = { GetAuctionItemClasses() };
			if #itemClasses > 0 then
			local itemClass;
			for _, itemClass in pairs(itemClasses) do
			DEFAULT_CHAT_FRAME:AddMessage(itemClass);
			end
		end
	end
	]]--

	FauxScrollFrame_Update(self.scrollframe, numMerchantItems, 10, xMerchant.kItemButtonHeight, nil, nil, nil, nil, nil, nil, 1);
	for i=1, 10, 1 do
		local offset = i+FauxScrollFrame_GetOffset(self.scrollframe);
		local button = buttons[i];
		button.hover = nil;
		if ( offset <= numMerchantItems ) then
			--API name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(index)
			local name, texture, price, quantity, numAvailable, isUsable, extendedCost = GetMerchantItemInfo(offset);
			local link = GetMerchantItemLink(offset);
			-- DONEY
			local name_text = name;
			local iteminfo_text = "";
			local r, g, b = 0.5, 0.5, 0.5;
			local _, itemRarity, itemType, itemSubType;
			local iLevel, iLevelText;
			if ( link ) then
				--API name, link, quality, iLevel, reqLevel, class, subclass, maxStack, equipSlot, texture, vendorPrice = GetItemInfo(itemID) or GetItemInfo("itemName") or GetItemInfo("itemLink")
				_, _, itemRarity, iLevel, _, itemType, itemSubType = GetItemInfo(link);
				if itemRarity then
					r, g, b = GetItemQualityColor(itemRarity);
					button.itemname:SetTextColor(r, g, b);
				end

				-- DONEY
				if itemSubType then
					iteminfo_text = itemSubType:gsub("%(OBSOLETE%)", "");
					if iLevel and iLevel > 1 then
						iLevelText = tostring(iLevel);
						iteminfo_text = iteminfo_text.." - "..iLevelText;
					end
				else
					iteminfo_text = ""
				end

				local alpha = 0.3;
				if ( searching == "" or searching == SEARCH:lower() or name:lower():match(searching)
					or ( itemRarity and ( tostring(itemRarity):lower():match(searching) or _G["ITEM_QUALITY"..tostring(itemRarity).."_DESC"]:lower():match(searching) ) )
					or ( itemType and itemType:lower():match(searching) )
					or ( itemSubType and itemSubType:lower():match(searching) )
					) then
					alpha = 1;
				elseif ( self.tooltipsearching ) then
					tooltip:SetOwner(UIParent, "ANCHOR_NONE");
					tooltip:SetHyperlink(link);
					for i=1, tooltip:NumLines() do
						if ( _G["xMerchantTooltipTextLeft"..i]:GetText():lower():match(searching) ) then
							alpha = 1;
							break;
						end
					end
				end
				button:SetAlpha(alpha);
			else
				-- TODO: feature of currencies player have
				-- if currencies[name] then
					-- iteminfo_text = "You have: " .. tostring(currencies[name]);
				-- end
			end

			-- XMERCHANT_LOGD("[MerchantItemInfo]  ".." - "..(name or "")
				-- .." - quantity "..(quantity and tostring(quantity) or "")
				-- .." - numAvailable "..(numAvailable and tostring(numAvailable) or "")
				-- .." - isUsable "..(isUsable and tostring(isUsable) or "")
				-- .." - extendedCost "..(extendedCost and tostring(extendedCost) or ""));

			local prename_text = (numAvailable >= 0 and "|cffffffff["..numAvailable.."]|r " or "")..(quantity > 1 and "|cffffffff"..quantity.."x|r " or "")
			name_text = prename_text..(name or "|cffff0000"..RETRIEVING_ITEM_INFO)
			-- name_text = prename_text..(name and (name..name) or "|cffff0000"..RETRIEVING_ITEM_INFO)-- debug code
			button.itemname:SetText(name_text);

			-- button.itemlevel:SetText(iLevelText or "");
			button.icon:SetTexture(texture);

			UpdateAltCurrency(button, offset, i);
			if ( extendedCost and price <= 0 ) then
				button.price = nil;
				button.extendedCost = true;
				button.money:SetText("");
			elseif ( extendedCost and price > 0 ) then
				button.price = price;
				button.extendedCost = true;
				button.money:SetText(GetCoinTextureString(price));
			else
				button.price = price;
				button.extendedCost = nil;
				button.money:SetText(GetCoinTextureString(price));
			end

			if ( GetMoney() < price ) then
				button.money:SetTextColor(1, 0, 0);
			else
				button.money:SetTextColor(1, 1, 1);
			end

			if ( numAvailable == 0 ) then
				button.highlight:SetVertexColor(0.5, 0.5, 0.5, 0.5);
				button.highlight:Show();
				button.isShown = 1;
			elseif ( not isUsable ) then
				button.highlight:SetVertexColor(1, 0.2, 0.2, 0.5);
				button.highlight:Show();
				button.isShown = 1;

				local errors = GetError(link, itemType and itemType == RECIPE);
				if ( errors ) then
					-- DONEY
					iteminfo_text = "|cffd00000"..iteminfo_text.." - "..errors.."|r";
				end
			elseif ( itemType and itemType == RECIPE and not GetKnown(link) ) then
				button.highlight:SetVertexColor(0.2, 1, 0.2, 0.5);
				button.highlight:Show();
				button.isShown = 1;
			else
				button.highlight:SetVertexColor(r, g, b, 0.5);
				button.highlight:Hide();
				button.isShown = nil;
				-- DONEY
				local errors = GetError(link, itemType and itemType == RECIPE);
				if ( errors ) then
					iteminfo_text = "|cffd00000"..iteminfo_text.." - "..errors.."|r";
				end
			end

			if button.itemname:GetNumLines() <= 1 then
				button.iteminfo:SetText(iteminfo_text);
			else
				button.iteminfo:SetText(iteminfo_text);
			end

			button.r = r;
			button.g = g;
			button.b = b;
			button.link = GetMerchantItemLink(offset);
			button.hasItem = true;
			button.texture = texture;
			button:SetID(offset);
			button:Show();
		else
			button.price = nil;
			button.hasItem = nil;
			button:Hide();
		end
		if ( button.hasStackSplit == 1 ) then
			StackSplitFrame:Hide();
		end
	end
end

local function xScrollFrame_OnShow(self)
	XMERCHANT_LOGD("[xMerchant][Debug] xScrollFrame_OnShow");
end
local function xScrollFrame_OnVerticalScroll(self, offset)
	XMERCHANT_LOGD("[xMerchant][Debug] OnVerticalScroll");
	local current_offset_n = FauxScrollFrame_GetOffset(self);
	local offset_n = (offset >= 0 and 1 or -1) * math.floor(math.abs(offset) / xMerchant.kItemButtonHeight + 0.1);
	local changed_n = offset_n - current_offset_n
	-- LOGW("xScrollFrame_OnVerticalScroll - offset: "..offset.." current_offset_n: "..current_offset_n.." changed_n: "..changed_n)
	if getCurrentDB().scroll_limit_enabled then
		if changed_n > getCurrentDB().scroll_limit_amount or changed_n < -getCurrentDB().scroll_limit_amount then
			changed_n = math.min(changed_n, getCurrentDB().scroll_limit_amount)
			changed_n = math.max(changed_n, -getCurrentDB().scroll_limit_amount)
			offset_n = (current_offset_n + changed_n)
			offset = (offset_n > 0.1 and (offset_n - 0.1) or 0) * xMerchant.kItemButtonHeight
			-- LOGW("xScrollFrame_OnVerticalScroll - limit offset to: "..offset.." changed_n to: "..changed_n)
		end
	end
	FauxScrollFrame_OnVerticalScroll(self, offset, xMerchant.kItemButtonHeight, MerchantUpdate);
end

local function OnClick(self, button)
	if ( IsModifiedClick() ) then
		MerchantItemButton_OnModifiedClick(self, button);
	else
		MerchantItemButton_OnClick(self, button);
	end
end

local function OnEnter(self)
	if ( self.isShown and not self.hover ) then
		self.oldr, self.oldg, self.oldb, self.olda = self.highlight:GetVertexColor();
		self.highlight:SetVertexColor(self.r, self.g, self.b, self.olda);
		self.hover = 1;
	else
		self.highlight:Show();
	end
	MerchantItemButton_OnEnter(self);
end

local function OnLeave(self)
	if ( self.isShown ) then
		self.highlight:SetVertexColor(self.oldr, self.oldg, self.oldb, self.olda);
		self.hover = nil;
	else
		self.highlight:Hide();
	end
	GameTooltip:Hide();
	ResetCursor();
	MerchantFrame.itemHover = nil;
end

local function SplitStack(button, split)
	if ( button.extendedCost ) then
		MerchantFrame_ConfirmExtendedItemCost(button, split)
	elseif ( split > 0 ) then
		BuyMerchantItem(button:GetID(), split);
	end
end

local function Item_OnClick(self)
	HandleModifiedItemClick(self.itemLink);
end

local function Item_OnEnter(self)
	local parent = self:GetParent();
	if ( parent.isShown and not parent.hover ) then
		parent.oldr, parent.oldg, parent.oldb, parent.olda = parent.highlight:GetVertexColor();
		parent.highlight:SetVertexColor(parent.r, parent.g, parent.b, parent.olda);
		parent.hover = 1;
	else
		parent.highlight:Show();
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	if ( self.pointType == ARENA_POINTS ) then
		GameTooltip:SetText(ARENA_POINTS, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddLine(TOOLTIP_ARENA_POINTS, nil, nil, nil, 1);
		GameTooltip:Show();
	elseif ( self.pointType == HONOR_POINTS ) then
		GameTooltip:SetText(HONOR_POINTS, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:AddLine(TOOLTIP_HONOR_POINTS, nil, nil, nil, 1);
		GameTooltip:Show();
	elseif ( self.pointType == "Beta" ) then
		GameTooltip:SetText(self.itemLink, HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
		GameTooltip:Show();
	else
		GameTooltip:SetHyperlink(self.itemLink);
	end
	if ( IsModifiedClick("DRESSUP") ) then
		ShowInspectCursor();
	else
		ResetCursor();
	end
end

local function Item_OnLeave(self)
	local parent = self:GetParent();
	if ( parent.isShown ) then
		parent.highlight:SetVertexColor(parent.oldr, parent.oldg, parent.oldb, parent.olda);
		parent.hover = nil;
	else
		parent.highlight:Hide();
	end
	GameTooltip:Hide();
	ResetCursor();
end

local function OnEvent(self, event, ...)
	if ( addonName == select(1, ...) ) then
		self:UnregisterEvent("ADDON_LOADED");

		local x = 0;
		if ( IsAddOnLoaded("SellOMatic") ) then
			x = 20;
		elseif ( IsAddOnLoaded("DropTheCheapestThing") ) then
			x = 14;
		end
		if ( x ~= 0 ) then
			-- DONEY
			self.search:SetWidth(92-x);
			self.search:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 50-x, 9);
		end

		if xMerchant.initDB~=nil then
			xMerchant.initDB()
		end

		return;
	end
end

local frame = CreateFrame("Frame", "xMerchantFrame", MerchantFrame);
local function xMerchant_InitFrame(frame)
	frame:RegisterEvent("ADDON_LOADED");
	frame:SetScript("OnEvent", OnEvent);
	frame:SetWidth(295);
	frame:SetHeight(294);
	-- DONEY
	-- frame:SetPoint("TOPLEFT", 21, -76);
	frame:SetPoint("TOPLEFT", 10, -65);

	xMerchant.merchantFrame = frame

	-- TODO: test impl slash command
	-- self:RegisterChatCommand("xmerchant", "OnChatCommand")
	-- self:RegisterChatCommand("xmer", "OnChatCommand")
end
xMerchant_InitFrame(frame)

local function OnTextChanged(self)
	XMERCHANT_LOGD("[xMerchant][Debug] OnTextChanged");
	searching = self:GetText():trim():lower();
	MerchantUpdate();
end

local function OnShow(self)
	self:SetText(SEARCH);
	searching = "";
end

local function OnEnterPressed(self)
	self:ClearFocus();
end

local function OnEscapePressed(self)
	self:ClearFocus();
	self:SetText(SEARCH);
	searching = "";
end

local function OnEditFocusLost(self)
	self:HighlightText(0, 0);
	if ( strtrim(self:GetText()) == "" ) then
		self:SetText(SEARCH);
		searching = "";
	end
end

local function OnEditFocusGained(self)
	XMERCHANT_LOGD("[xMerchant][Debug] OnEditFocusGained");
	self:HighlightText();
	if ( self:GetText():trim():lower() == SEARCH:lower() ) then
		self:SetText("");
	end
end

-- TODO: Need polish display before enabling the options button feature
-- local optionsButton = CreateFrame("Button", "$parentOptions", frame, "UIPanelButtonTemplate")
-- frame.optionsButton = optionsButton;
-- optionsButton:SetWidth(16)
-- optionsButton:SetHeight(16)
-- optionsButton:SetText("")
-- optionsButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-UP");
-- optionsButton:SetPushedTexture("Interface\\Buttons\\UI-PlusButton-DOWN");
-- -- optionsButton:SetDisabledTexture("Interface\\Icons\\INV_Gizmo_03");
-- -- optionsButton:SetHighlightTexture("Interface\\Icons\\INV_Gizmo_03");
-- optionsButton:ClearAllPoints()
-- optionsButton:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 28, 13)
-- optionsButton:SetScript("OnClick", function( ... )
-- 	InterfaceOptionsFrame_OpenToCategory("xMerchant")
-- 	InterfaceOptionsFrame_OpenToCategory(xMerchant.OptionsFrame)
-- 	InterfaceOptionsFrame_OpenToCategory("xMerchant")
-- 	InterfaceOptionsFrame_OpenToCategory(xMerchant.OptionsFrame)
-- end)

local search = CreateFrame("EditBox", "$parentSearch", frame, "InputBoxTemplate");
frame.search = search;
if IsAddOnLoaded('Aurora') then
	search:SetSize(122, 20)
	search:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 10, 13)
else
	search:SetSize(92, 24)
	search:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 50, 9)
end
search:SetAutoFocus(false);
search:SetFontObject("GameFontHighlight");
search:SetScript("OnTextChanged", OnTextChanged);
search:SetScript("OnShow", OnShow);
search:SetScript("OnEnterPressed", OnEnterPressed);
search:SetScript("OnEscapePressed", OnEscapePressed);
search:SetScript("OnEditFocusLost", OnEditFocusLost);
search:SetScript("OnEditFocusGained", OnEditFocusGained);
search:SetText(SEARCH);

local function Search_OnClick(self)
	if ( self:GetChecked() ) then
		PlaySound("igMainMenuOptionCheckBoxOn");
		frame.tooltipsearching = 1;
	else
		PlaySound("igMainMenuOptionCheckBoxOff");
		frame.tooltipsearching = nil;
	end
	if ( searching ~= "" and searching ~= SEARCH:lower() ) then
		XMERCHANT_LOGD("[xMerchant][Debug] Search_OnClick");
		MerchantUpdate();
	end
end

local function Search_OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
	GameTooltip:SetText(L["To browse item tooltips, too"]);
end

local tooltipsearching = CreateFrame("CheckButton", "$parentTooltipSearching", frame, "InterfaceOptionsSmallCheckButtonTemplate");
search.tooltipsearching = tooltipsearching;
if IsAddOnLoaded('Aurora') then
	tooltipsearching:SetSize(28, 28)
	tooltipsearching:SetPoint("LEFT", search, "RIGHT", 0, 0)
else
	tooltipsearching:SetSize(21, 21)
	tooltipsearching:SetPoint("LEFT", search, "RIGHT", -1, 0)
end
tooltipsearching:SetHitRectInsets(0, 0, 0, 0);
tooltipsearching:SetScript("OnClick", Search_OnClick);
tooltipsearching:SetScript("OnEnter", Search_OnEnter);
tooltipsearching:SetScript("OnLeave", GameTooltip_Hide);
tooltipsearching:SetChecked(false);

local scrollframe = CreateFrame("ScrollFrame", "xMerchantScrollFrame", frame, "FauxScrollFrameTemplate");
frame.scrollframe = scrollframe;
-- DONEY
-- scrollframe:SetWidth(295);
scrollframe:SetWidth(284);
scrollframe:SetHeight(298);
-- DONEY
-- scrollframe:SetPoint("TOPLEFT", MerchantFrame, 22, -74);
scrollframe:SetPoint("TOPLEFT", MerchantFrame, 22, -65);
scrollframe:SetScript("OnShow", xScrollFrame_OnShow);
scrollframe:SetScript("OnVerticalScroll", xScrollFrame_OnVerticalScroll);

local top = frame:CreateTexture("$parentTop", "ARTWORK");
frame.top = top
top:SetWidth(31);
top:SetHeight(256);
top:SetPoint("TOPRIGHT", 30, 6);
top:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar");
top:SetTexCoord(0, 0.484375, 0, 1);

local bottom = frame:CreateTexture("$parentBottom", "ARTWORK");
frame.bottom = bottom
bottom:SetWidth(31);
bottom:SetHeight(108);
bottom:SetPoint("BOTTOMRIGHT", 30, -6);
bottom:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-ScrollBar");
bottom:SetTexCoord(0.515625, 1, 0, 0.421875);

xMerchant.merchantFrameButtons = {}
local function xMerchant_InitItemsButtons()
	for i=1, 10, 1 do
		local button = CreateFrame("Button", "xMerchantFrame"..i, frame);
		button:SetWidth(frame:GetWidth());
		button:SetHeight(xMerchant.kItemButtonHeight);
		if ( i == 1 ) then
			button:SetPoint("TOPLEFT", 0, -1);
		else
			button:SetPoint("TOP", buttons[i-1], "BOTTOM");
		end
		button:RegisterForClicks("LeftButtonUp","RightButtonUp");
		button:RegisterForDrag("LeftButton");
		button.UpdateTooltip = OnEnter;
		button.SplitStack = SplitStack;
		button:SetScript("OnClick", OnClick);
		button:SetScript("OnDragStart", MerchantItemButton_OnClick);
		button:SetScript("OnEnter", OnEnter);
		button:SetScript("OnLeave", OnLeave);
		button:SetScript("OnHide", OnHide);

		local highlight = button:CreateTexture("$parentHighlight", "BACKGROUND"); -- better highlight
		button.highlight = highlight;
		highlight:SetAllPoints();
		highlight:SetBlendMode("ADD");
		highlight:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2");
		highlight:Hide();

		local itemname_fontsize = getCurrentDB().itemname_fontsize or 15
		local iteminfo_fontsize = getCurrentDB().iteminfo_fontsize or 12

		local itemname = button:CreateFontString("ARTWORK", "$parentItemName");
		button.itemname = itemname;
		itemname:SetFont(GameFontHighlight:GetFont(), itemname_fontsize)
		itemname:SetPoint("TOPLEFT", 30.4, -2);
		itemname:SetJustifyH("LEFT");
		itemname:SetJustifyV("TOP");
		itemname:SetWordWrap(false)

		local iteminfo = button:CreateFontString("ARTWORK", "$parentItemInfo");
		button.iteminfo = iteminfo;
		iteminfo:SetFont(GameFontHighlight:GetFont(), iteminfo_fontsize)
		iteminfo:SetPoint("BOTTOMLEFT", 30.4, 2);
		iteminfo:SetJustifyH("LEFT");
		iteminfo:SetJustifyV("TOP");
		iteminfo:SetTextColor(0.5, 0.5, 0.5);
		iteminfo:SetWordWrap(false)

		local icon = button:CreateTexture("$parentIcon", "BORDER");
		button.icon = icon;
		icon:SetWidth(25.4);
		icon:SetHeight(25.4);
		icon:SetPoint("LEFT", 2, 0);
		icon:SetTexture("Interface\\Icons\\temp");

		-- DONEY todo?
		-- local itemlevel = button:CreateFontString("ARTWORK", "$parentItemName", "GameFontNormal");
		-- button.itemlevel = itemlevel;
		-- itemlevel:SetPoint("BOTTOMLEFT", 1.0, -3);
		-- itemlevel:SetJustifyH("LEFT");

		local money = button:CreateFontString("ARTWORK", "$parentMoney");
		button.money = money;
		money:SetFontObject(GameFontHighlight)
		money:SetPoint("RIGHT", -2, 0);
		money:SetJustifyH("RIGHT");
		itemname:SetPoint("RIGHT", money, "LEFT", -2, 0);
		iteminfo:SetPoint("RIGHT", money, "RIGHT", -2, 0);

		button.item = {};
		for j=1, MAX_ITEM_COST, 1 do
			local item = CreateFrame("Button", "$parentItem"..j, button);
			button.item[j] = item;
			item:SetWidth(17);
			item:SetHeight(17);
			if ( j == 1 ) then
				item:SetPoint("RIGHT", -2, 0);
			else
				item:SetPoint("RIGHT", button.item[j-1], "LEFT", -2, 0);
			end
			item:RegisterForClicks("LeftButtonUp","RightButtonUp");
			item:SetScript("OnClick", Item_OnClick);
			item:SetScript("OnEnter", Item_OnEnter);
			item:SetScript("OnLeave", Item_OnLeave);
			item.hasItem = true;
			item.UpdateTooltip = Item_OnEnter;

			local icon = item:CreateTexture("$parentIcon", "BORDER");
			item.icon = icon;
			icon:SetWidth(17);
			icon:SetHeight(17);
			icon:SetPoint("RIGHT");

			local count = item:CreateFontString("ARTWORK", "$parentCount", "GameFontHighlight");
			item.count = count;
			count:SetPoint("RIGHT", icon, "LEFT", -2, 0);
		end

		local honor = CreateFrame("Button", "$parentHonor", button);
		button.honor = honor;
		honor.itemLink = select(2, GetItemInfo(43308)) or "\124cffffffff\124Hitem:43308:0:0:0:0:0:0:0:0\124h[Ehrenpunkte]\124h\124r";
		honor:SetWidth(17);
		honor:SetHeight(17);
		honor:SetPoint("RIGHT", -2, 0);
		honor:RegisterForClicks("LeftButtonUp","RightButtonUp");
		honor:SetScript("OnClick", Item_OnClick);
		honor:SetScript("OnEnter", Item_OnEnter);
		honor:SetScript("OnLeave", Item_OnLeave);
		honor.hasItem = true;
		honor.UpdateTooltip = Item_OnEnter;

		local icon = honor:CreateTexture("$parentIcon", "BORDER");
		honor.icon = icon;
		icon:SetWidth(17);
		icon:SetHeight(17);
		icon:SetPoint("RIGHT");

		local count = honor:CreateFontString("ARTWORK", "$parentCount", "GameFontHighlight");
		honor.count = count;
		count:SetPoint("RIGHT", icon, "LEFT", -2, 0);

		local arena = CreateFrame("Button", "$parentArena", button);
		button.arena = arena;
		arena.itemLink = select(2, GetItemInfo(43307)) or "\124cffffffff\124Hitem:43307:0:0:0:0:0:0:0:0\124h[Arenapunkte]\124h\124r";
		arena:SetWidth(17);
		arena:SetHeight(17);
		arena:SetPoint("RIGHT", -2, 0);
		arena:RegisterForClicks("LeftButtonUp","RightButtonUp");
		arena:SetScript("OnClick", Item_OnClick);
		arena:SetScript("OnEnter", Item_OnEnter);
		arena:SetScript("OnLeave", Item_OnLeave);
		arena.hasItem = true;
		arena.UpdateTooltip = Item_OnEnter;

		local icon = arena:CreateTexture("$parentIcon", "BORDER");
		arena.icon = icon;
		icon:SetWidth(17);
		icon:SetHeight(17);
		icon:SetPoint("RIGHT");

		local count = arena:CreateFontString("ARTWORK", "$parentCount", "GameFontHighlight");
		arena.count = count;
		count:SetPoint("RIGHT", icon, "LEFT", -2, 0);

		xMerchant.merchantFrameButtons[i] = button
		buttons[i] = button;
	end
end
xMerchant_InitItemsButtons()

local function Update()
	if ( MerchantFrame.selectedTab == 1 ) then
		for i=1, 12, 1 do
			_G["MerchantItem"..i]:Hide();
		end
		frame:Show();
		XMERCHANT_LOGD("[xMerchant][Debug] Update:  CurrencyUpdate");
		CurrencyUpdate();
		-- DONEY
		FactionsUpdate();
		XMERCHANT_LOGD("[xMerchant][Debug] Update:  MerchantUpdate");
		MerchantUpdate();
	else
		frame:Hide();
		for i=1, 12, 1 do
			_G["MerchantItem"..i]:Show();
		end
		if ( StackSplitFrame:IsShown() ) then
			StackSplitFrame:Hide();
		end
	end
end
hooksecurefunc("MerchantFrame_Update", Update);

local function OnHide()
	wipe(errors);
	wipe(currencies);
end
hooksecurefunc("MerchantFrame_OnHide", OnHide);


MerchantBuyBackItem:ClearAllPoints();
if IsAddOnLoaded('Aurora') then
	MerchantBuyBackItem:SetPoint("BOTTOMLEFT", 169, 28)
else
	MerchantBuyBackItem:SetPoint("BOTTOMLEFT", 175, 32)
end

for _, frame in next, { MerchantNextPageButton, MerchantPrevPageButton, MerchantPageText } do
	frame:Hide()
	frame.Show = function() end;
end

-- Aurora Reskin
if IsAddOnLoaded("Aurora") then
	local F = unpack(Aurora)
	F.ReskinInput(search)
	F.ReskinCheck(tooltipsearching)
	F.ReskinScroll(xMerchantScrollFrameScrollBar)
	xMerchantFrameTop:Hide()
	xMerchantFrameBottom:Hide()
	for i=1, 10, 1 do
		local bu = _G["xMerchantFrame"..i]
		local ic = bu.icon
		F.ReskinIcon(ic)
	end
end