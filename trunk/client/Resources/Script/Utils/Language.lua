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
	TIAN = "天",
	MAP_EDIT = "地图编辑器",
	BUY_DIA_HAVE = "你拥有钻石：",
	BUY_DIA_NEED = "你需要钻石：",
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
	COPYINFO_TEAM = "选择英雄建立你的队伍",
	BUY_MOVES_1 = "你没有通过",
	CONTACT_QQ = "QQ:1214169123",
	CONTACT_WEB = "网站：www.onekes.com",
	CONTACT_EMAIL = "邮箱：gm@onekes.com",
	CONTACT_TEL = "电话：0592-5191370",
	COPY_UNLOCK_CONDITION = "解锁条件",
	COPY_UNLOCK_OR = "或者",
	DIS_DIA_ORI_MONEY = "原价",
	GAME_FAIL_GETITEM = "收集物品",
	SPECIAL_COPY_TITLE = "过关奖励",	
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
	BUY_MOVES_NEED = "仅需：",
	BUY_MOVES_LEFTTIME = "倒计时：  ",
	DIS_DES_1 = "(可以培养英雄，购买钥匙)",
	DIS_DIA_2 = "颗钻石",	
	SIGNIN_DES = "已签到         天",
	SIGNIN_Days = "第%d天",
	CHANNEL_COMPANY_NAME 	= "厦门顽客网络科技有限公司",
	DISCOUNT_CIAMOND_TITLE 	= "限时选购",			-- 限时选购支付标题
	DISCOUNT_CIAMOND_DESC 	= "限时抢购",			-- 限时选购支付描述
	BUY_POWER_PAY_TITLE		= "补满体力",			-- 补满体力支付标题
	BUY_POWER_PAY_DESC 		= "补满体力",			-- 补满体力支付描述
	BUY_DIS_MOVES_PAY_TITLE = "步数优惠",			-- 步数优惠支付标题
	BUY_DIS_MOVES_PAY_DESC 	= "步数优惠",			-- 步数优惠支付描述
	BUY_MOVES_PAY_TITLE		= "购买步数",			-- 购买步数支付标题
	BUY_MOVES_PAY_DESC 		= "购买步数",			-- 购买步数支付描述
	GUIDE_1 = "前方海怪挡道！连接3个以上同色贝壳来攻击海怪。",
	GUIDE_2 = "通关目标：打败1只海怪，继续连接贝壳来进攻吧。",
	GUIDE_4 = "这次要打败2只海怪才能过关，卡勒喵会来帮你。",
	GUIDE_5 = "首先是索隆喵，连接和索隆喵颜色相同的绿色贝壳，他会增加你的攻击力。",
	GUIDE_6 = "11步内必须完成目标哦！",
	GUIDE_7 = "本关目标：击退海怪，收集足够的绿色贝壳和钻石。",
	GUIDE_8 = "连接钻石周围的贝壳即可获得它。",
	GUIDE_9 = "卡勒猫不仅增加攻击力，还能释放魔力球，合理利用魔力球能帮助你快速完成目标",
	GUIDE_10 = "收集同色贝壳能够帮助你获得魔力球。",
	GUIDE_12 = "恭喜你得到鸣人喵，试试这只卡勒喵带来的魔力球。",
	GUIDE_13 = "合理利用魔力球能帮助你快速完成目标。",
	GUIDE_14 = "我们喵星人最喜欢饼干啦。收集好吃的饼干，让猫咪更快的成长！",
	GUIDE_15 = "打开猫咪收藏界面，用小饼干喂食猫咪",
	GUIDE_16 = "哟，初次见面请多关照！现在轻按“开始升级",
	GUIDE_17 = "呃，饼干不够吃了...",
	GUIDE_18 = "用钻石换取缺少的饼干吧，轻按“确定”。",
	GUIDE_19 = "我感觉自己变强了！现在，我们出发寻宝吧，我将成为你强大的助力！",
	GUIDE_20 = "收集难度又增加啦，木箱需要消除3次才能打开，箱子里藏着好东西哦！",
	GUIDE_21 = "连接贝壳可以消除周围的障碍物，试着消除下方的障碍物收集其中隐藏的箱子吧。",
	GUIDE_22 = "使用魔力球可以直接破坏木箱，不管是多坚固的障碍物，魔力球都能一次性清除它们。",
	GUIDE_23 = "使用技能引爆炸弹可以带来非常酷炫的效果。",
	GUIDE_24 = "这关需要收集48个红色贝壳，让新获得的卡勒喵上阵吧，他释放的变色魔力球能够帮助你轻松完成目标。",
	
	About = "应用名称:开心连连消\n版 本 号:%s\n类    型:三消类\n公司名称:厦门顽客网络科技有限公司\n客服电话:0592-5191370\n本游戏免责声明:\n  本游戏版权归厦门顽客网络科技有\n限公司所有，游戏中的文字、图片等\n内容均为游戏版权所有者的个人态度\n或立场，炫彩公司（中国电信）对此\n不承担任何法律责任。 ",
	NOTIFY_FIXED_MSG_1 = "大海深处，喵星人已经陷入苦战，赶快前去支援，同他们一起并肩作战吧！",
	NOTIFY_FIXED_MSG_2 = "连连消里的喵星人还在等待你的回归，不要丢下和你同生共死的喵族兄弟！",
	NOTIFY_FIXED_MSG_3 = "主人，喵喵们想你啦。快回来看看我们。没有主人喵喵们会被大鲨鱼欺负的。",
	NOTIFY_POWER_MSG_1 = "经过一段时间的休整，喵喵军团已恢复巅峰状态，随时可以踏上冒险历程！",
	NOTIFY_POWER_MSG_2 = "神采奕奕的喵星人，已经整装待命，期待你带领他们寻到最终的宝藏！",
	NOTIFY_POWER_MSG_3 = "喵喵们已经体力充沛，就等主人扬帆起航！",
	NOTIFY_POWER_MSG_4 = "喵喵们已经蓄势待发，主人快快带领我们继续征程吧！",
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
	PUBLIC_EXCLAMATION = "!",
	TIAN = "Day",
	MAP_EDIT = "地图编辑器",
	BUY_DIA_HAVE = "You have:",				--建议显示内容：You have: %d 钻石图标
	BUY_DIA_NEED = "You need:",			
	BUY_POWER_1 = "Lord，we need more Energy.",
	BUY_POWER_2 = "Don't forget to feed cats.",	--不要忘记喂猫！
	BUY_POWER_3 = "Show me the Cookies.",	--钥匙必有用。（给玩家钥匙有用的信息而非钥匙有风险的信息）
	BUY_POWER_4 = "Let's collect more seashells.",		--"猫就是猫，自己命运的主人。（闲聊，老外不懂萌萌哒哏）"

	COPY_UNLOCK_1 = "Have %d Cats.",
	COPY_UNLOCK_2 = "Feed %d Cats to level %d.",				--培养这边用喂养feed来标注
	CG_1 = "Tap to continue",
	GOAL_TEXT_COLLECT = "Collect",
	GOAL_TEXT_KILL = "Defeat",				--击杀太血腥了，改成击败
	COPY_INFO_LOCK_TIP = "Open more Chests to unlock the Cat!",	--这只喵被锁定了，打开更多宝箱解锁新英雄！
	COPY_INFO_SELECT_TIP = "Slide up and down to change the Cats.",	--NOTICE: the team list
	HERO_LEVEL_UP = "Level up!",
	HERO_ATTACK = "Attack +",
	HERO_SKILL_UP = "Skill Improved!",
	REWARD_GIFT_POINT = "",		--英文不需要这种计量单位
	REWARD_GIFT_GE = "",		--英文不需要这种计量单位
	REWARD_GIFT_GET = "WOW！We found ",
	COPYINFO_GAME_GOALS = "Goals",
	COPYINFO_GAME_MOVES = "Moves",
	COPYINFO_LEVEL = " Level ",
	COPYINFO_ATTACK = " Attack:",
	COPYINFO_TEAM = "Choose your team:",
	BUY_MOVES_1 = "Failed",
	CONTACT_QQ = "QQ:1214169123",
	CONTACT_WEB = "Website:www.onekes.com",
	CONTACT_EMAIL = "E-mail:gm@onekes.com",
	CONTACT_TEL = "Phone num:0592-5191370",
	COPY_UNLOCK_CONDITION = "Requirements",	--复数条件（如果单数条件去掉s）
	COPY_UNLOCK_OR = "or",
	DIS_DIA_ORI_MONEY = "Price:",
	GAME_FAIL_GETITEM = "Collected",	--已收集：
	SPECIAL_COPY_TITLE = "Stage Reward",	
	GAME_PAUSE_LEVEL = "Stage",
	HERO_INFO_ATTACK = "Attack",
	HERO_INFO_SKILL = "Skill",
	HERO_INFO_MAX_LEVEL = "Congratulations!This Cat has reached the Max Level!",	--" 恭喜！这只猫达到了最高等级！"

	HERO_TIP_1 = "点击解锁",
	HERO_TIP_2 = "消耗材料id填重复了*************",
	POWER_TIP_1 = "We can't buy more.",
	GOAL_TIP_1 = "喵喵又生气了！",
	GOAL_TIP_2 = "喵喵%d生气了**%d****",
	GAME_GOAL = "Goal：",
	BUY_MOVES_NEED = "Only：",
	BUY_MOVES_LEFTTIME = "Countdown：  ",
	DIS_DES_1 = "(Diamonds can buy Cat Foods and Keys.)",
	DIS_DIA_2 = "Diamonds",
	SIGNIN_DES = "已连续登录     天",
	SIGNIN_Days = "第%d天",
	CHANNEL_COMPANY_NAME 	= "XIAMEN ONEKES INTERNET TECHONOLGY LTD. CO.",
	DISCOUNT_CIAMOND_TITLE 	= "Special offer",			-- 限时选购支付标题
	DISCOUNT_CIAMOND_DESC 	= "Special offer",			-- 限时选购支付描述
	BUY_POWER_PAY_TITLE		= "Fill Energy",			-- 补满体力支付标题
	BUY_POWER_PAY_DESC 		= "Fill Energy",			-- 补满体力支付描述
	BUY_DIS_MOVES_PAY_TITLE = "Moves purchase",			-- 步数优惠支付标题(预购步数)
	BUY_DIS_MOVES_PAY_DESC 	= "Moves purchase",			-- 步数优惠支付描述(预购步数)
	BUY_MOVES_PAY_TITLE		= "+5 Moves",			-- 购买步数支付标题
	BUY_MOVES_PAY_DESC 		= "+5 Moves",			-- 购买步数支付描述
	GUIDE_1 = "Sea monster!Slide to Collect Seashells to attack.",
	GUIDE_2 = "We need to defeat this monster,collect more Seashells!",
	GUIDE_4 = "There are 2 monsters,but Color Cat will help us!",
	GUIDE_5 = "This is Zoro.He can use GREEN SEASHELLS(the same color as his) to deal more damage.",
	GUIDE_6 = "Please finish this stage in 11 moves.",
	GUIDE_7 = "Fight monsters,collect green Seashells and Diamonds!",
	GUIDE_8 = "If we collect the Seashells next to Diamonds.We can also colllect the diamonds.",
	GUIDE_9 = "When Color Cats collect enough Seashells,they can create magic bombs.",
	GUIDE_10 = "Fill Zoro's skill bar to create a green magic bomb.",
	GUIDE_12 = "Catruto!His speacial skill can create a different magic bomb.",
	GUIDE_13 = "Magic bombs can help you to collect more seashells.",
	GUIDE_14 = "We Cats love Cookies.Collect Cookies to feed us.",
	GUIDE_15 = "Tap to feed Cats.",
	GUIDE_16 = "Tap the Feed button.",
	GUIDE_17 = ":(,Meow,we don't get enough cookies.",
	GUIDE_18 = "Diamonds can replace the missing cookies.Tap Yes button.",
	GUIDE_19 = "Thanks for the cookies,i am stronger now!Now let's set out to collet more seashells!",
	GUIDE_20 = "Crate is very sturdy,but there's good stuff inside.",
	GUIDE_21 = "Collect seashells next to the garbages can destory them.Have a try!",
	GUIDE_22 = "Magic bombs can destory everything.Use magic bombs to destory the crate.",
	GUIDE_23 = "Use magic bombs to detonate THE BOMB!",
	GUIDE_24 = "The new Color Cat's special skill can create magic bomb which help you to achieve this stage's goal.",
	About = "应用名称:开心连连消\n版 本 号:%s\n类    型:三消类\n公司名称:厦门顽客网络科技有限公司\n客服电话:0592-5191370\n本游戏免责声明:\n  本游戏版权归厦门顽客网络科技有限公司所有，游戏中的文字、图片等内容均为游戏版权所有者的个人态度或立场，炫彩公司（中国电信）对此不承担任何法律责任。",
	NOTIFY_FIXED_MSG_1 = "Help!Too many enemies,too little cookies.",	--"……和什么苦战？不是在海中收集贝壳么，怎么就变成苦战了，到底遭遇了什么"
	NOTIFY_FIXED_MSG_2 = "Don't leave us alone.We need your help.",
	NOTIFY_FIXED_MSG_3 = "We miss you(and your Cookies).Please come back and play with us.",
	NOTIFY_POWER_MSG_1 = "Cats are waiting for new advanture!",
	NOTIFY_POWER_MSG_2 = "Meow,we are fully energized!",
	NOTIFY_POWER_MSG_3 = "Meow,we are ready for sail out!",
	NOTIFY_POWER_MSG_4 = "Let's sail out for more seashells!",
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
local mLanguage = mLanguageSimplifiedCN
if ChannelProxy:isEnglish() then
	mLanguage = mLanguageEN
end
function LanguageStr(key, ...)
	return getLanguageString(mLanguage, key, ...)
end
----------------------------------------------------------------------