﻿-- Contributors:七曜·星の痕

local _, addonTable = ...
local L = addonTable.L

-- Lua
local _G = getfenv(0)

if GetLocale() ~= "zhCN" then return end

L["ANCHOR"] = "通知定位点"
L["ANCHOR_FRAME"] = "定位框架"
L["BORDER"] = "通知边框"
L["COLLECTIONS_TAINT_WARNING"] = "开启这个选项后可能会出现报错，尤其是在战斗中。"
L["COLORS"] = "染色名称"
L["COLORS_TOOLTIP"] = "根据品质染色物品与追随者名称，并且根据稀有度染色世界任务与任务标题。"
L["COPPER_THRESHOLD"] = "金币拾取界限"
L["COPPER_THRESHOLD_DESC"] = "设置显示通知的最小金币数量。"
L["DND"] = "勿扰"
L["DND_TOOLTIP"] = "通知处于勿扰模式将不会在战斗中显示，但会取代成在系统队列。一但你离开战斗，就会开始跳出通知。"
L["FADE_OUT_DELAY"] = "淡出延迟"
L["FONTS"] = "字体"
L["GROWTH_DIR"] = "成长方向"
L["GROWTH_DIR_DOWN"] = "下"
L["GROWTH_DIR_LEFT"] = "左"
L["GROWTH_DIR_RIGHT"] = "右"
L["GROWTH_DIR_UP"] = "上"
L["HANDLE_LEFT_CLICK"] = "左键点击处理"
L["ICON_BORDER"] = "图标边框"
L["NAME"] = "物品名称"
L["OPEN_CONFIG"] = "打开设置"
L["RARITY_THRESHOLD"] = "染色品质"
L["SCALE"] = "缩放"
L["SETTINGS_TYPE_LABEL"] = "通知类型"
L["SHOW_ILVL"] = "等级"
L["SHOW_ILVL_DESC"] = "在物品名称旁边显示物品等级。"
L["SHOW_QUEST_ITEMS"] = "任务物品"
L["SHOW_QUEST_ITEMS_DESC"] = "显示任务物品，不论品质。"
L["SIZE"] = "大小"
L["SKIN"] = "皮肤"
L["STRATA"] = "层级"
L["TEST"] = "测试"
L["TEST_ALL"] = "测试全部"
L["TOAST_NUM"] = "通知数量"
L["TRANSMOG_ADDED"] = "外观已加入"
L["TRANSMOG_REMOVED"] = "外观已移除"
L["TYPE_ACHIEVEMENT"] = "成就"
L["TYPE_ARCHAEOLOGY"] = "考古"
L["TYPE_CLASS_HALL"] = "职业大厅"
L["TYPE_COLLECTION"] = "藏品"
L["TYPE_COLLECTION_DESC"] = "由藏品触发的通知，例如：坐骑、宠物、玩具..等等。"
L["TYPE_DUNGEON"] = "地下城"
L["TYPE_GARRISON"] = "要塞"
L["TYPE_LOOT_COMMON"] = "拾取(一般)"
L["TYPE_LOOT_COMMON_DESC"] = "由聊天事件触发的通知，例如：绿色蓝色或某些史诗，一切其他不属于特殊战利品的处理。"
L["TYPE_LOOT_CURRENCY"] = "拾取(货币)"
L["TYPE_LOOT_GOLD"] = "拾取(金币)"
L["TYPE_LOOT_SPECIAL"] = "拾取(特殊)"
L["TYPE_LOOT_SPECIAL_DESC"] = "由特殊战利品触发的通知，例如：赢得掷股、传说掉落、个人拾取..等等。"
L["TYPE_RECIPE"] = "专业图纸"
L["TYPE_TRANSMOG"] = "幻化提醒"
-- L["TYPE_WAR_EFFORT"] = "War Effort"
L["TYPE_WORLD_QUEST"] = "世界任务"