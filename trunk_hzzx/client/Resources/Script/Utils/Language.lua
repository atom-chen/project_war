----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-4
-- Brief: 语言
----------------------------------------------------------------------
-- 简体中文
local mLanguageSimplifiedCN = {
	-- 通用符号
	VERSION = "版本号：",
	PUBLIC_L_BRACKET = "（",
	PUBLIC_R_BRACKET = "）",
	PUBLIC_LM_BRACKET = "【",
	PUBLIC_RM_BRACKET = "】",
	PUBLIC_COMMA = "、",
	PUBLIC_COLON = "：",
	PUBLIC_EXCLAMATION = "！",
	PUBLIC_MONEY = "￥",
	TIAN = "天",
	MAP_EDIT = "地图编辑器",
	BUY_DIA_HAVE = "你拥有：",
	BUY_DIA_NEED = "你需要：",
	BUY_POWER_1 = "少年体力不足了,快点购买!",
	BUY_POWER_2 = "冒险遇到困难时，记得去升级哦！",
	BUY_POWER_3 = "抽奖有风险，买钥匙需谨慎!",
	BUY_POWER_4 = "今天的我也萌萌哒，喵！",
	COPY_UNLOCK_1 = "拥有%d只英雄",
	COPY_UNLOCK_2 = "将%d只英雄培养到%d级",
	CG_1 = "点击继续",
	GOAL_TEXT_COLLECT = "收集",
	GOAL_TEXT_KILL = "击杀",
	COPY_INFO_LOCK_TIP = "该英雄尚未解锁，抽奖可获得新英雄！",
	COPY_INFO_SELECT_TIP = "提示:点选英雄上下滑动可更换不同的英雄！",
	HERO_LEVEL_UP = "等级提升！",
	HERO_ATTACK = "攻击力+",
	HERO_SKILL_UP = "技能提升!",
	REWARD_GIFT_POINT = "点",
	REWARD_GIFT_GE = "个",
	REWARD_GIFT_GET = "哇！你获得了",
	COPYINFO_GAME_GOALS = "游戏目标",
	COPYINFO_GAME_MOVES = "步数",
	COPYINFO_LEVEL = "_等级:",
	COPYINFO_ATTACK = "_攻击力:",
	CONTACT_QQ = "",
	CONTACT_WEB = "",
	CONTACT_EMAIL = "",
	CONTACT_TEL = "",
	COPY_UNLOCK_CONDITION = "解锁条件",
	COPY_UNLOCK_OR = "或者",
	COPY_UNLOCK_MONEY = "解锁%d元",
	DIS_DIA_ORI_MONEY = "原价￥",
	GAME_FAIL_GETITEM = "收集物品",
	GAME_PAUSE_LEVEL = "关卡",
	HERO_INFO_ATTACK = "攻击",
	HERO_INFO_SKILL = "技能",
	HERO_INFO_MAX_LEVEL = "已经是最高等级!",
	HERO_TIP_1 = "点击解锁",
	HERO_TIP_2 = "消耗材料id填重复了*************",
	POWER_TIP_1 = "只可以购买一次最大体力!",
	GOAL_TIP_1 = "喵喵又生气了！",
	GOAL_TIP_2 = "喵喵%d生气了**%d****",
	GAME_GOAL = "目标：",
	CHANNEL_COMPANY_NAME 	= "",
	DIS_DIA_GET = "领取消耗%s元",
	DIS_MOVES_GET = "花费%s元",
	DISCOUNT_CIAMOND_TITLE 	= "限时选购",			-- 限时选购支付标题
	DISCOUNT_CIAMOND_DESC 	= "限时抢购",			-- 限时选购支付描述
	BUY_POWER_PAY_TITLE		= "补满体力",			-- 补满体力支付标题
	BUY_POWER_PAY_DESC 		= "补满体力",			-- 补满体力支付描述
	BUY_DIS_MOVES_PAY_TITLE = "步数优惠",			-- 步数优惠支付标题
	BUY_DIS_MOVES_PAY_DESC 	= "步数优惠",			-- 步数优惠支付描述
	BUY_MOVES_PAY_TITLE		= "购买步数",			-- 购买步数支付标题
	BUY_MOVES_PAY_DESC 		= "购买步数",			-- 购买步数支付描述
	COPY_UCLOCK_TITLE 		= "副本解锁",			-- 副本解锁支付标题
	COPY_UCLOCK_DESC 		= "副本解锁",			-- 副本解锁支付描述
	BUY_KEYS_TITLE 			= "购买钥匙",			-- 购买钥匙支付标题
	BUY_KEYS_DESC 			= "购买钥匙",			-- 购买钥匙支付描述
	UNLOCK_HERO_TITLE 		= "解锁英雄",			-- 解锁英雄支付标题
	UNLOCK_HERO_DESC 		= "解锁英雄",			-- 解锁英雄支付描述
	FREE_POWER_TITLE 		= "两小时内不耗费体力",	-- 两小时内不耗费体力支付标题
	FREE_POWER_DESC 		= "两小时内不耗费体力",	-- 两小时内不耗费体力支付描述
	GUIDE_1 = "duang！我是特效村长！\n帮我将绿色贝壳收集起来吧！",
	GUIDE_2 = "前方有河豚挡路！连接相同的元素来消灭它！",
	GUIDE_3 = "红色的海星造成了一些伤害，但如果你消除绿色的贝壳，索隆喵就会帮助你。",
	GUIDE_4 = "我们喵星人最喜欢饼干啦。收集好吃的饼干，让猫咪更快的成长！",
	GUIDE_5 = "打开猫咪收藏界面，用小饼干喂食猫咪",
	GUIDE_6 = "哟，初次见面请多关照！现在轻按“开始升级”。",
	GUIDE_7 = "呃，饼干不够吃了...",
	GUIDE_8 = "用钻石换取缺少的饼干吧，轻按“确定”。",
	GUIDE_9 = "我感觉自己变强了！现在，我们出发寻宝吧，我将成为你强大的助力！",
	About = "",
	-- 
}
----------------------------------------------------------------------
-- 繁体中文
local mLaguageTraditionalCN = {
	-- 通用符号
	VERSION = "版本号：",
	PUBLIC_L_BRACKET = "（",
	PUBLIC_R_BRACKET = "）",
	PUBLIC_LM_BRACKET = "【",
	PUBLIC_RM_BRACKET = "】",
	PUBLIC_COMMA = "、",
	PUBLIC_COLON = "：",
	-- 
}
----------------------------------------------------------------------
-- 英文
local mLanguageEN = {
	-- 通用符号
	VERSION = "version：",
	PUBLIC_L_BRACKET = "(",
	PUBLIC_R_BRACKET = ")",
	PUBLIC_LM_BRACKET = "[",
	PUBLIC_RM_BRACKET = "]",
	PUBLIC_COMMA = ",",
	PUBLIC_COLON = ":",
	-- 
}
----------------------------------------------------------------------
-- 获取语言字符串
local function getLanguageString(languageTb, key, ...)
	assert("table" == type(languageTb) and "string" == type(key), "arguments type is not wrong ...")
	local str = languageTb[key]
	assert("string" == type(str), "can't find key = ["..key.."] ...")
	return string.format(str, ...)
end
----------------------------------------------------------------------
-- 获取字符串
function LanguageStr(key, ...)
	return getLanguageString(mLanguageSimplifiedCN, key, ...)
end
----------------------------------------------------------------------