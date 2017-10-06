----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-4
-- Brief: 游戏逻辑
----------------------------------------------------------------------
G = G or {}
G.VISIBLE_SIZE = cc.Director:getInstance():getVisibleSize()		-- 可视大小
G.WIN_SIZE = cc.Director:getInstance():getWinSize()				-- 窗口大小
local FLAG_REQUIRE, FLAG_RUN = false, false						-- 标志位
Game = {}
----------------------------------------------------------------------
function CreateBaseNodes()
	-- root => {ui_back -> scene -> ui_middle -> ui_front -> ui_top}
	local nodes = {
		root = cc.Layer:create(),		-- 根节点(不允许挂载)
		back = cc.Layer:create(),		-- 底层UI节点(挂载游戏背景等最底层UI)
		scene = cc.Layer:create(),		-- 场景节点(挂载游戏战斗场景)
		middle = cc.Layer:create(),		-- 中层UI节点(挂载非模态UI)
		front = cc.Layer:create(),		-- 上层UI节点(挂载模态UI)
		top = cc.Layer:create()			-- 顶层UI节点(挂载游戏提示等最顶层UI)
	}
    nodes.root:addChild(nodes.back, 1)
    nodes.root:addChild(nodes.scene, 2)
    nodes.root:addChild(nodes.middle, 3)
    nodes.root:addChild(nodes.front, 4)
    nodes.root:addChild(nodes.top, 5)
    return nodes
end
----------------------------------------------------------------------
-- 初始化
function Game:init()
	local nodes = CreateBaseNodes()
    self.NODE_UI_BACK = nodes.back
    self.NODE_SCENE = nodes.scene
    self.NODE_UI_MIDDLE = nodes.middle
    self.NODE_UI_FRONT = nodes.front
    self.NODE_UI_TOP = nodes.top
	cc.Director:getInstance():getRunningScene():addChild(nodes.root)
	-- 预显示界面
	local backgroundSprite = nil
	if ChannelProxy:isCocos() then
		backgroundSprite = ccui.ImageView:create("background_01.jpg")
	else
		backgroundSprite = ccui.ImageView:create("background_02.jpg")
	end
	backgroundSprite:setAnchorPoint(cc.p(0.5, 0.5))
	backgroundSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, G.VISIBLE_SIZE.height/2))
	self.NODE_UI_BACK:addChild(backgroundSprite)
	local tipSprite = cc.Sprite:create("text_jiazai.png")
	tipSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 114))
	self.NODE_UI_BACK:addChild(tipSprite)
	-- windows平台,开启命令模块
	if cc.PLATFORM_OS_WINDOWS == G.PLATFORM then
		require("Command"):init(self.NODE_UI_TOP)
	end
	-- 执行逻辑
	nodes.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
		if self.mScheduleId then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.mScheduleId)
			self.mScheduleId = nil
		end
		self.mScheduleId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt) self:update(dt) end, 0, false)
		local startRequireTime = os.clock()
		require("Require")
		cclog("require lua cost time: "..(os.clock() - startRequireTime))
		FLAG_REQUIRE = true
	end)))
	ChannelProxy:recordCustom("stat_game_logo_loading")
end
----------------------------------------------------------------------
-- 运行脚本逻辑
function Game:run()
	ChannelProxy:registNotify()
	ChannelProxy:clearNotify()
	DataMap:init()							-- 初始玩家数据
	AudioMgr:init()							-- 初始化音频管理器
	PowerManger:init()						-- 初始化体力数据
	ModelItem:init()						-- 初始化物品数据(毛球,饼干,钥匙,砖石)
	ModelLottery:init()						-- 初始化抽奖数据
	ModelLevelLottery:initMustShowHeroInfo()-- 初始化英雄必抽的信息
	DataHeroInfo:init()
	ChannelPayCode:initGlobalCode()			-- 根据渠道id，初始化相应的支付码
	ModelPub:initSound()					-- 初始化音乐、音效
	ModelSignIn:initSignInData()			-- 初始化签到数据
	
	DataMap:setPass(DataMap:getMaxPass())
	UIMain:openBack()						-- 打开主界面
	UIMiddlePub:openMiddle()				-- 打开中间界面
	ChannelProxy:recordCustom("stat_enter_main")
	
	-- if DataMap:getCompleteCG() == false then
		-- UICG:openFront(true, nil, false, false)		-- 四格漫画
	-- end
	if  DataMap:getMaxPass() ~= G.GUIDE_CHANGE_HERO then
		if GuideUI:checkUIGuide(UIMiddlePub)  then
			UIMain:setScorllViewTouch(false)
		end
	end
	-- 推送定时通知
	local notifyMsgTable = {"NOTIFY_FIXED_MSG_1", "NOTIFY_FIXED_MSG_2", "NOTIFY_FIXED_MSG_3"}
	local notifyTimeTable = {{19,0,0}, {20,0,0}, {21,0,0}}
	local notifyMsg = CommonFunc:getRandom(notifyMsgTable)
	local notifyTime = CommonFunc:getRandom(notifyTimeTable)
	ChannelProxy:addNotify(2, 1, LanguageStr(notifyMsg), notifyTime[1]*3600 + notifyTime[2]*60 + notifyTime[3])
	--打开每日签到界面
	if ModelSignIn:isFinishSignIn()== false then
		if ModelSignIn:showSignInBtn() and (ModelSignIn:isTodaySignIn()== false) then
			UISignIn:openFront(true)
		end
	end
end
----------------------------------------------------------------------
-- 每帧更新
function Game:update(dt)
	-- 定时器更新调度
	UpdateTimer()
	-- 界面更新调度
	UIUPDATE(dt)
	-- 数据表加载调度
	LogicTable:updateLoad(function()
		self:run()
		FLAG_RUN = true
	end)
	
end
----------------------------------------------------------------------
-- 程序进入后台调用
function applicationDidEnterBackground()
	cclog("applicationDidEnterBackground")
	if not FLAG_REQUIRE or not FLAG_RUN then return end
	DataMap:saveDataBase()
	AudioMgr:pause()
	PowerManger:pushNotify()
end
----------------------------------------------------------------------
-- 程序进入前台调用
function applicationWillEnterForeground()
	cclog("applicationWillEnterForeground")
	if not FLAG_REQUIRE or not FLAG_RUN then return end
	DataMap:saveDataBase()
	AudioMgr:resume()
	PowerManger:popNotify()
end
----------------------------------------------------------------------
