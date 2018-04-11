local B, C, L, DB = unpack(select(2, ...))
local module = NDui:GetModule("AurasTable")

-- 法师的法术监控
local list = {
	["Player Aura"] = {		-- 玩家光环组
		--寒冰护体
		{AuraID =  11426, UnitID = "player"},
		--烈焰护体
		{AuraID = 235313, UnitID = "player"},
		--棱光屏障
		{AuraID = 235450, UnitID = "player"},
		--隐形术
		{AuraID =  32612, UnitID = "player"},
		--强化隐形术
		{AuraID = 110960, UnitID = "player"},
		--缓落
		{AuraID =    130, UnitID = "player"},
		--灸灼
		{AuraID =  87023, UnitID = "player"},
	},
	["Target Aura"] = {		-- 目标光环组
		--点燃
		{AuraID =  12654, UnitID = "target", Caster = "player"},
		--炎爆术
		{AuraID =  11366, UnitID = "target", Caster = "player"},
		--活动炸弹
		{AuraID = 217694, UnitID = "target", Caster = "player"},
		--龙息术
		{AuraID =  31661, UnitID = "target", Caster = "player"},
		--冲击波
		{AuraID = 157981, UnitID = "target", Caster = "player"},
		--冰霜新星
		{AuraID =    122, UnitID = "target", Caster = "player"},
		--冰霜之环
		{AuraID =  82691, UnitID = "target", Caster = "player"},
		--减速
		{AuraID =  31589, UnitID = "target", Caster = "player"},
		--虚空风暴
		{AuraID = 114923, UnitID = "target", Caster = "player"},
		--寒冰炸弹
		{AuraID = 112948, UnitID = "target", Caster = "player"},
		--寒冰箭
		{AuraID = 205708, UnitID = "target", Caster = "player"},
		--冰锥术
		{AuraID = 212792, UnitID = "target", Caster = "player"},
		--寒冰新星
		{AuraID = 157997, UnitID = "target", Caster = "player"},
		--奥术侵蚀
		{AuraID = 210134, UnitID = "target", Caster = "player"},
		--冰川尖刺
		{AuraID = 199786, UnitID = "target", Caster = "player"},
		--冰冻术
		{AuraID =  33395, UnitID = "target", Caster = "pet"},
		--水流喷射
		{AuraID = 135029, UnitID = "target", Caster = "pet"},
	},
	["Player Special Aura"] = {	-- 玩家重要光环组
		--寒冰屏障
		{AuraID =  45438, UnitID = "player"},
		--隐没
		{AuraID = 157913, UnitID = "player"},
		--炽热疾速
		{AuraID = 108843, UnitID = "player"},
		--咒术洪流
		{AuraID = 116267, UnitID = "player"},
		--能量符文
		{AuraID = 116014, UnitID = "player"},
		--浮冰
		{AuraID = 108839, UnitID = "player"},
		--气定神闲
		{AuraID = 205025, UnitID = "player"},
		--奥术充能
		{AuraID =  36032, UnitID = "player"},
		--奥术飞弹!
		{AuraID =  79683, UnitID = "player"},
		--奥术强化
		{AuraID =  12042, UnitID = "player"},
		--冰冷血脉
		{AuraID =  12472, UnitID = "player"},
		--寒冰指
		{AuraID =  44544, UnitID = "player"},
		--强化隐形术
		{AuraID = 113862, UnitID = "player"},
		--炽烈之咒
		{AuraID = 194329, UnitID = "player"},
		--炎爆术！
		{AuraID =  48108, UnitID = "player"},
		--热力迸发
		{AuraID =  48107, UnitID = "player"},
		--燃烧
		{AuraID = 190319, UnitID = "player"},
		--置换
		{AuraID = 212799, UnitID = "player"},
		--加速
		{AuraID = 198924, UnitID = "player"},
		--冰刺
		{AuraID = 205473, UnitID = "player"},
		--隐形术
		{AuraID =     66, UnitID = "player"},
		--刺骨冰寒
		{AuraID = 205766, UnitID = "player"},
	},
	["Spell CD"] = {	-- 技能冷却计时组
		--冰冷血脉
		{SpellID = 12472, UnitID = "player"},
		--奥术强化
		{SpellID = 12042, UnitID = "player"},
		--燃烧
		{SpellID = 190319, UnitID = "player"},
		--能量符文
		{TotemID =     1, UnitID = "player"},
	},
}

module:AddNewAuraWatch("MAGE", list)