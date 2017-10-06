----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 类型定义
----------------------------------------------------------------------
-- 元素类型
ElementType = {
	["none"] = 0,					-- 空
	["obstacle"] = 1,				-- 障碍物
	["normal"] = 2,					-- 普通小球
	["skill"] = 3,					-- 技能球
	["throw"] = 4,					-- 投放元素
	["special"] = 5,				-- 特殊元素
	["board"] = 6,					-- 隔板
}

-- 障碍物类型
ElementObstacleType = {
	["obstacle01"] = 1,				-- 障碍物1
	["obstacle02"] = 2,				-- 障碍物2
	["obstacle03"] = 3,				-- 障碍物3
	["obstacle04"] = 4,				-- 障碍物4
	["obstacle05"] = 5,				-- 障碍物5
	["obstacle06"] = 6,				-- 障碍物6
}

-- 普通小球类型
ElementNormalType = {
	["red"] = 1,					-- 红色
	["yellow"] = 2,					-- 黄色
	["green"] = 3,					-- 绿色
	["blue"] = 4,					-- 蓝色
	["purple"] = 5,					-- 紫色
}

-- 技能球类型
ElementSkillType = {
	["discolor"] = 1,				-- 变色技能球(不可点击)
	["horizontal"] = 2,				-- 横消(可点击)
	["vertical"] = 3,				-- 竖消(可点击)
	["cross"] = 4,					-- 十字消(可点击)
	["samecolor"] = 5,				-- 同色消(可点击)
	["step"] = 6,					-- 步数(可点击)
	["connect"] = 7,				-- 连接器(不可点击)
}

-- 投放类型
ElementThrowType = {
	["cover"] = 1,					-- 覆盖
	["replace"] = 2,				-- 替换
	["fixed"] = 3,					-- 固定
}

-- 覆盖类型
ElementThrowCoverType = {
	["ink"] = 1,					-- 墨汁
	["giftbag"] = 2,				-- 礼包
}

-- 替换类型
ElementThrowReplaceType = {
	["tooth"] = 1,					-- 牙齿
	["cannibal"] = 2,				-- 食人怪
	["timberpile"] = 3,				-- 木桩
	["snowdrift"] = 4,				-- 雪堆
	["wetland"] = 5,				-- 沼泽地
	["volcano_black"] = 6,			-- 黑色火山(产生沼泽地)
	["volcano_silver"] = 7,			-- 银色火山(产生炸弹)
}

-- 固定类型
ElementThrowFixedType = {
	["fence"] = 1,					-- 栅栏
}

-- 特殊元素类型
ElementSpecialType = {
	["diamond"] = 1,				-- 钻石
	["bomb"] = 2,					-- 炸弹
	["key"] = 3,					-- 钥匙
	["crate"] = 4,					-- 木箱
}

-- 隔板类型
ElementBoardType = {
	["onetimes"] = 1,				-- 需消除1次(可消除)
	["twotimes"] = 2,				-- 需消除2次(可消除)
	["threetimes"] = 3,				-- 需消除3次(可消除)
	["fourtimes"] = 4,				-- 需消除4次(可消除)
	["fivetimes"] = 5,				-- 需消除5次(可消除)
	["infinite"] = 6,				-- 不可消除
}

-- 隔板方向类型
BoardDirectType = {
	["vertical"] = 1,				-- 竖
	["horizontal"] = 2,				-- 横
}


