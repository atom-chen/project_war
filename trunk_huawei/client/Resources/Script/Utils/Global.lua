------------------------------------------------------------------------ Author: jaron.ho-- Date: 2014-12-4-- Brief: 全局变量,G在:Main.lua,Game.lua,里进行预定义----------------------------------------------------------------------G = G or {}G.GRID_ROW = 8						-- 格子行数G.GRID_COL = 11						-- 格子列数G.GRID_WIDTH = 66					-- 格子宽度G.GRID_HEIGHT = 66					-- 格子高度G.GRID_GAP = 5						-- 格子间距G.GRID_TOUCH_GAP = 3				-- 格子触摸间距G.SCENE_ZORDER_BG = 1				-- 场景背景层级G.SCENE_ZORDER_PARTICLE_IN = 2		-- 场景内层粒子层级G.SCENE_ZORDER_BOOTH = 3			-- 场景展台层级G.SCENE_ZORDER_MONSTER = 4			-- 场景怪物层级G.SCENE_ZORDER_PARTICLE_OUT = 5		-- 场景外层粒子层级G.SCENE_ZORDER_TIP = 6				-- 场景提示层级G.MAP_ZORDER_BG = 1					-- 地图背景层级G.MAP_ZORDER_LINE = 2				-- 地图连线层级G.MAP_ZORDER_GRID = 3				-- 地图格子层级G.MAP_ZORDER_BOARD = 4				-- 地图隔板层级G.MAP_ZORDER_EFFECT = 5				-- 地图特效层级G.MAP_ZORDER_MASK = 6				-- 地图遮罩层级G.TOP_ZORDER_SEABED = 1				-- 顶层海底层级G.TOP_ZORDER_BOOTH = 2				-- 顶层展台层级G.TOP_ZORDER_NORMAL = 3				-- 顶层元素层级G.TOP_ZORDER_SKILL = 4				-- 顶层技能层级G.TOP_ZORDER_HERO = 5				-- 顶层英雄层级G.TOP_ZORDER_THROW = 10				-- 顶层投放层级G.TOP_ZORDER_TIP = 11				-- 顶层提示层级G.TOP_ZORDER_EFFECT = 12			-- 顶层特效层级G.TOP_ZORDER_HERO_INFO = 13			-- 顶层英雄信息层级G.TOP_ZORDER_GUIDE = 20				-- 顶层引导层级G.MIN_COLLECT = 3					-- 元素最少收集个数G.NORMAL_BASE_ATTACK = 60			-- 普通元素基础攻击力G.SKILL_BASE_ATTACK = 900			-- 技能元素基础攻击力G.SKILL_DELTA_ATTACK1 = 150			-- 技能元素增量攻击力1G.SKILL_DELTA_ATTACK2 = 225			-- 技能元素增量攻击力2G.SKILL_DELTA_ATTACK3 = 300			-- 技能元素增量攻击力3G.SKILL_DELTA_ATTACK4 = 375			-- 技能元素增量攻击力4G.HERO_IDLE = "idle"				-- 英雄待机动作G.HERO_PREPARE = "pre_attack"		-- 英雄准备攻击动作G.HERO_ATTACK = "attack"			-- 英雄攻击动作G.HERO_WIN = "win"					-- 英雄欢呼动作G.SHARE_ITEM_GET_DIAMAND	= 5		-- 获取大礼包分享送钻石的数量G.MONSTER_IDLE = "idle"				-- 怪物待机动作G.MONSTER_ATTACK = "attack"			-- 怪物投放动作G.MONSTER_HIT = "hit"				-- 怪物被击动作G.MONSTER_DIE = "die"				-- 怪物死亡动作G.CUR_MAX_POWER = 20				-- 体力的最大值G.INIT_DIAMOND = 50					-- 初始砖石if G.CONFIG["debug"] then	G.POWER_RECOVER_TIME = 600			-- 体力恢复一点的时间(10分钟,600秒)else	G.POWER_RECOVER_TIME = 600			-- 体力恢复一点的时间(10分钟,600秒)endG.ADD_MAX_POWER = 5					-- 只可购买一次增加的体力上限值G.BUY_MOVES_TIME = 10				-- 增加步数倒计时G.HERO_ID_BORN = {}				-- 一进入游戏就有的英雄id--G.HERO_ID_BORN = {1101,1201,1301,2101,2201,2301,3101,3201,3301,4101,4201,4301,5101,5201,5301}				-- 一进入游戏就有的英雄idG.COOKIE_PRICE = 0.5					-- 每个饼干耗费的砖石G.BALL_PRICE = 0.2					-- 每个毛球耗费的砖石G.KEY_PRICE = 1						-- 每个钥匙耗费的砖石G.BUY_ONE_MAX_POWER = 300			-- 购买一次最大体力耗费的砖石G.BUY_MAX_POWER_NUMBER = 5			-- 购买一次最大体力的数值G.DIS_MOVES_TIMES = 3				-- 失败几次后会弹出打折步数界面G.ADD_KEYS = 3						-- 每次购买可以获得的钥匙个数if G.CONFIG["debug"] then	G.ADD_KEYS = 3					-- 每次购买可以获得的钥匙个数else	G.ADD_KEYS = 3					-- 每次购买可以获得的钥匙个数endG.COPY_UNLICK_DIA = 100				-- 解锁某关卡，需要消耗的砖石	G.DIS_DIA_LEVEL = 12				-- 限时打折界面开启等级G.SHARE_URL = "http://www.onekes.com/kxllx"-- 分享的网址G.SHARE_SHOP_COUNT			= 1		-- 商店分享有送钻石的次数G.SHARE_STEP_BACK_COUNT		= 1		-- 失败界面分享有送步数的次数G.SHARE_WIN_COUNT 			= 1		-- 成功界面有钻石的分享次数G.SHARE_GET_HERO_COUNT		= 1		-- 获取英雄的界面分享获得钻石的次数G.SHARE_GET_ITEM_COUNT		= 1		-- 获取大礼包分享送钻石的次数G.SHARE_SHOP_GIVE_DIAMOND	= 5		-- 商店分享送钻石的数量G.SHARE_WIN_GIVE_DIAMOND	= 5		-- 成功分享送钻石的数量G.SHARE_HERO_GET_DIAMOND	= 5		-- 获取英雄分享送钻石的数量G.SHARE_ITEM_GET_DIAMAND	= 5		-- 获取大礼包分享送钻石的数量G.SHARE_FAIL_GET_STEP		= 5		-- 战斗失败分享获取步数G.PRODUCT_STAFF = {					-- 制作人员名单}G.SERVER_PHONE = "0592-5191370"G.SHADER_ENABLED = true				-- 是否开启shaderG.GUIDE_CHANGE_HERO = 23            -- 通过23关后，24关再引导换英雄----------------------------------------------------------------------