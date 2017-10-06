----------------------------------------------------------------------
-- Author: lhq
-- Date: 2015-1-06
-- Brief: 中间层界面
----------------------------------------------------------------------
UIDEFINE("UIMiddlePub", "MiddlePub.csb")
function UIMiddlePub:onStart(ui, param)
	self:bind(EventDef["ED_POWER_LEFT_TIME"], self.setPowerLeftTime, self)
	self:bind(EventDef["ED_POWER"], self.updatePowerMaxLoad, self)
	self:bind(EventDef["ED_CHANGE_REWARD_DATA"],self.numberChange, self) 
	-- 设置按钮
	self.mSetBtn = self:getChild("btnSetting")
	Utils:autoChangePos(self.mSetBtn)
	self:addTouchEvent(self.mSetBtn, function(sender)
		self:handleSetting()
	end, true, true, 0)
	--体力背景
	self.mPowerBg = self:getChild("powerBg")
	Utils:autoChangePos(self.mPowerBg)
	self:addTouchEvent(self.mPowerBg, function(sender)
		self:handlePower()
	end, false, true, 0)
	self.mPowerText = self:getChild("powerText")		--体力值
	self.mPowerTextMax = self:getChild("powerText_max")	--体力最大值
	self.mPowerTime = self:getChild("powerTime")		--体力倒计时
	self.mLoardingBar = self:getChild("LoadingBar_1")	--体力进度条
	UIMiddlePub:setPowerLeftTime(PowerManger:getLeftTime())
	UIMiddlePub:updatePowerMaxLoad()
	
	--收集物品背景 --毛球个数--饼干个数--砖石个数
	self.mCollectedBg = self:getChild("Panel_collect")
	Utils:autoChangePos(self.mCollectedBg)
	self.mCollectBall = self:getChild("Text_collect_ball")	
	self.mCollectCookie = self:getChild("Text_collect_cookie")
	self.mDiamond = self:getChild("diamond")					
	
	--毛球、饼干、砖石、体力的icon
	self.collectBall = self:getChild("collect_ball") 
	self.collectCookie = self:getChild("collect_cookie")
	self.diamond = self:getChild("diamondIcon")
	self.powerIcon = self:getChild("powerIcon")
	
	--钥匙提示和个数、英雄可升级提示和个数
	self.tipKeyBg = self:getChild("tip_key")
	self.tipKeyText = self:getChild("Text_key")
	self.tipGrowBg = self:getChild("tip_grow")
	self.tipGrowText = self:getChild("Text_grow")
	
	--进入英雄
	self.mBtnEnterHero = self:getChild("btnEnterHero")
	self:addTouchEvent(self.mBtnEnterHero, function(sender)
		self:handleEnterHeroUI()
	end, true, true, 0)
	Utils:autoChangePos(self.mBtnEnterHero)
	--活动按钮
	self.mBtnActivityNode = self:getChild("btnActivity")
	self.mBtnActivityNode:setPosition(cc.p(21.6,250))
	self.mBtnActivityNode:loadTextures("touming.png","touming.png","touming.png")
	Utils:autoChangePos(self.mBtnActivityNode)
	self.mBtnActivityBg = Utils:createArmatureNode("gift_icon", "idle", true, function(armatureBack, movementType, movementId)
		if ccs.MovementEventType.complete == movementType and "idle" == movementId then
		end
	end)
	self.mBtnActivityBg:setScale(1.0)
	self.mBtnActivityBg:setAnchorPoint(cc.p(0.5,0.5))
	self.mBtnActivityBg:setPosition(cc.p(50,50))
	self.mBtnActivityNode:addChild(self.mBtnActivityBg, 101)
	--活动按钮的点击区域
	self.mBtnActivity = ccui.ImageView:create()	
	self.mBtnActivity:loadTexture("touming.png")		--activity_gift
	self.mBtnActivity:setScale9Enabled(true)
	self.mBtnActivity:setCapInsets(cc.rect(0, 0, 0, 0))
	self.mBtnActivity:setContentSize(cc.size(100,100))
	self.mBtnActivity:setPosition(cc.p(0,-100))
	self.mBtnActivity:setAnchorPoint(cc.p(0,0))
	self.mBtnActivity:setTouchEnabled(true)
	self.mBtnActivityBg:addChild(self.mBtnActivity)
	self:addTouchEvent(self.mBtnActivity, function(sender)
		self:handleActivity()
	end, true, true, 0)
	--抽奖按钮
	self.mBtnAward = self:getChild("btnAward")
	Utils:autoChangePos(self.mBtnAward)
	if DataMap:getPass() == 0 then
		self.mBtnAward:setTouchEnabled(false)
	else
		self.mBtnAward:setTouchEnabled(true)
	end
	self:addTouchEvent(self.mBtnAward, function(sender)
		self:handleEnterAwardUI()
	end, true, true, 0)
	--返回按钮
	self.mBtnBack = self:getChild("btnBackMain")
	self:addTouchEvent(self.mBtnBack, function(sender)
		self:handleBackMain()
		if  DataMap:getMaxPass() ~= 22 then
			if GuideUI:checkUIGuide(self) then
				UIMain:setScorllViewTouch(false)
			end
		end
		AudioMgr:playEffect(2007)
	end, true, true, 0)
	Utils:autoChangePos(self.mBtnBack)
	--每日签到按钮
	self.mSignIn = self:getChild("btnSignIn")
	self:addTouchEvent(self.mSignIn, function(sender)
		self:handleSignIn()
	end, true, true, 0)
	Utils:autoChangePos(self.mSignIn)
	--砖石背景
	self.mBtnDiamondBg = self:getChild("diamondBg")
	Utils:autoChangePos(self.mBtnDiamondBg)
	self:addTouchEvent(self.mBtnDiamondBg, function(sender)
		self:handleBuyPower()
	end, false, true, 0)
	
	UIMiddlePub:setCollectNumber()
	UIMiddlePub:setCollectPos()
	UIMiddlePub:initBtns()
end
----------------------------------抽奖动画-------------------------------------------------------------
--设置各个图标终点的位置（毛球图标、饼干图标、砖石图标、体力）
function UIMiddlePub:setCollectPos()
	self.x1= self.collectBall:getWorldPosition().x
	self.y1 = self.collectBall:getWorldPosition().y
	self.x2 = self.collectCookie:getWorldPosition().x
	self.y2 = self.collectCookie:getWorldPosition().y
	self.x3 = self.diamond:getWorldPosition().x
	self.y3 = self.diamond:getWorldPosition().y
	self.x4 = self.powerIcon:getWorldPosition().x
	self.y4	= self.powerIcon:getWorldPosition().y
	self.x5 = self.mBtnEnterHero:getWorldPosition().x
	self.y5	= self.mBtnEnterHero:getWorldPosition().y
end

--获得毛球图标、饼干图标、砖石图标、体力、英雄图标的位置
function UIMiddlePub:getCollectPos()
	return self.x1,self.y1,self.x2,self.y2,self.x3,self.y3,self.x4,self.y4,self.x5,self.y5
end

--根据物品的类型，获得一些信息
function UIMiddlePub:getInfosByType(types)
	local widget,lastNumber,nowNumber = nil,0,0
	if types == 1 then
		widget = self.mCollectBall
		nowNumber = ModelItem:getTotalBall()
		lastNumber = nowNumber - ModelItem:getCollectBall()
	elseif types == 2 then
		widget = self.mCollectCookie
		nowNumber = ModelItem:getTotalCookie()
		lastNumber = nowNumber - ModelItem:getCollectCookie()
	elseif types == 3 then
		widget = self.mDiamond
		nowNumber = ModelItem:getTotalDiamond()
		lastNumber = nowNumber - ModelItem:getCollectDiamond()
	elseif types == 4 then
	end
	return widget,lastNumber,nowNumber
end

--根据物品的id，判断物品的类型
function UIMiddlePub:getItemTypeById(id)
	if id == 1 or id == 5 or id == 10 or id == 11  then		-- 毛球 -- 毛球包
		types = ItemType["ball"]
	elseif id == 2 or id == 9 or id == 12 or id == 13 then	-- 饼干
		types = ItemType["cookie"]
	elseif id == 4 or id == 6 then							-- 砖石 -- 砖石包
		types = ItemType["dia"]
	elseif id == 7 then										-- 体力
		types = ItemType["power"]
	elseif id == 8 then										-- 体力上限
		types = ItemType["maxpower"]
	elseif id == 3 then										-- 钥匙
		types = ItemType["key"]
	end
	return types
end

--根据物品的类型，获得对应的控件
function UIMiddlePub:getWidgetByItemType(types)
	local widget = nil
	if types == ItemType["ball"] then
		widget = self.mCollectBall
	elseif types == ItemType["cookie"] then
		widget = self.mCollectCookie
	elseif types == ItemType["dia"] then
		widget = self.mDiamond
	elseif types == ItemType["power"] then
		widget = self.mPowerText
	elseif types == ItemType["maxpower"] then
		widget = self.mPowerTextMax
	end
	return widget
end

--根据加减，控件名，前后数据，让数字变动
function UIMiddlePub:numberChange(tb, widget)
	if nil == widget then
		widget = self:getWidgetByItemType(tb.itemType)
	end
	if isNil(widget) then return end
	widget:stopAllActions()
	tb.oldAmount = tonumber(tb.oldAmount)
	tb.newAmount = tonumber(tb.newAmount)
	local changeNumber = 1
	local temp = tb.newAmount - tb.oldAmount
	
	local inter,mode = math.modf(math.abs(temp)/10)		--math.mod(temp,10) 
	mode = mode*10
	
	if mode ~=  0 then
		changeNumber = 1
	elseif inter ~= 0  then
		changeNumber = 10	
	else
		changeNumber = inter	
	end
	if tb.flag == SignType["add"] then
		tb.oldAmount = tb.oldAmount + changeNumber
	elseif tb.flag == SignType["reduce"] then
		tb.oldAmount = tb.oldAmount - changeNumber
	else
		return
	end
	widget:setString(tostring(tb.oldAmount))
	if tb.oldAmount < tb.newAmount and tb.flag == SignType["add"] then
		Actions:delayWith(widget, 0.01, function()
			self:numberChange(tb, widget)
		end)
		return
	elseif tb.oldAmount >= tb.newAmount and tb.flag == SignType["add"] then
		widget:stopAllActions()
		widget:setString(tostring(tb.newAmount))
		return
	end
	if tb.oldAmount > tb.newAmount and tb.flag == SignType["reduce"] then
		Actions:delayWith(widget, 0.01, function()
			self:numberChange(tb, widget)
		end)
		return
	elseif tb.oldAmount <= tb.newAmount and tb.flag == SignType["reduce"] then
		widget:setString(tostring(tb.newAmount))
		widget:stopAllActions()
		return
	end	
end

--根据抽取到的物品，加载数字变动的动画
function UIMiddlePub:loadChangeAction(finalId,awardPondId,awardPondInfo,itemInfo,changeFlag)
	--local keyStr,allTimes = ModelLevelLottery:getKeyByAwardInfo(awardPondInfo,finalId)		
	if itemInfo.award_type == 1 or itemInfo.award_type == 3 then		-- 礼包类型
		local lastNumber = 0
		local types = UIMiddlePub:getItemTypeById(itemInfo.id)
		local widget = UIMiddlePub:getWidgetByItemType(types)
		if types == ItemType["ball"]  then					-- 毛球 -- 毛球包			
			lastNumber = ModelLottery:getCurRewardBall()
		elseif  types == ItemType["cookie"] then			-- 饼干
			lastNumber = ModelLottery:getCurRewardCookie()
		elseif types == ItemType["dia"] then				-- 砖石 -- 砖石包
			lastNumber = ModelLottery:getCurRewardDiamond()
		elseif  types == ItemType["power"] then				-- 体力
			lastNumber = ModelLottery:getCurRewardPower()
		elseif types == ItemType["maxpower"] then			-- 体力上限
			lastNumber = ModelLottery:getCurRewardMaxPower()
		end
		self:changeNumber(widget, types, lastNumber, 1, itemInfo.count,changeFlag)
	end
end

-- 数据变动(changeType:1.表示增加,-1.表示减少)
function UIMiddlePub:changeNumber(widget, numberType, currNumber, changeType, changeCount,changeFlag)
	if isNil(widget) then return end
	widget:stopAllActions()
	widget:setString(currNumber)
	local changeFlags = true
	if changeFlag ~= nil then
		changeFlags = changeFlag
	end
	local newNumber = currNumber + changeType*changeCount
	if ItemType["ball"] == numberType then
		ModelLottery:setCurRewardBall(newNumber)
	elseif ItemType["cookie"] == numberType then
		ModelLottery:setCurRewardCookie(newNumber)
	elseif ItemType["dia"] == numberType then
		ModelLottery:setCurRewardDiamond(newNumber)
	elseif ItemType["power"] == numberType then
		ModelLottery:setCurRewardPower(newNumber)
		PowerManger:setCurPower(newNumber)
		UIMiddlePub:setLoadingBar()
		PowerManger:updateTimeByRewardPower()
	elseif ItemType["maxpower"] == numberType then
		ModelLottery:setCurRewardMaxPower(newNumber)
		PowerManger:setMaxPower(newNumber)
		UIMiddlePub:setLoadingBar()
		PowerManger:updateTimeByRewardPower()
	end

	if changeFlags == true then
		local function innerChange()
			changeCount = changeCount - 1
			if changeCount < 0 then return end
			currNumber = currNumber + changeType
			Actions:delayWith(widget, 0.005, function()
				widget:setString(currNumber)
				innerChange()
			end)
		end
		innerChange()
	else
		widget:setString(newNumber)
	end
end

--抽奖图片飞的函数
function UIMiddlePub:getAwardFlyAction(iconWidget,amountText,itemInfo,finalId,awardPondId,awardPondInfo,clickTimes)
	local x1,y1,x2,y2,x3,y3,x4,y4 = UIMiddlePub:getCollectPos()
	local new_X,new_y = 0,0
	local iconStr = "touming.png"
	local types = UIMiddlePub:getItemTypeById(itemInfo.id)
	if types == ItemType["ball"] then	    -- 毛球	-- 毛球包
		new_X = x1
		new_y = y1
		iconStr = "ball_01.png"
	elseif types == ItemType["cookie"] then	-- 饼干	-- 饼干包
		new_X = x2
		new_y = y2
		iconStr = "cookie_01.png"
	elseif types == ItemType["dia"] then	-- 砖石 -- 砖石包
		new_X = x3
		new_y = y3
		iconStr = "diamond_01.png"
	elseif types == ItemType["power"] or types == ItemType["maxpower"] then	-- 体力 -- 体力上限
		new_X = x4
		new_y = y4	
		iconStr = "power.png"
	end
	
	local old_x = iconWidget:getWorldPosition().x
	local old_y = iconWidget:getWorldPosition().y
	local panel = self:getChild("Panel_1")
	--抽奖物品
	local newFlyIcon = ccui.ImageView:create()	
	newFlyIcon:loadTexture(iconStr)
	newFlyIcon:setPosition(cc.p(old_x +(G.DESIGN_WIDTH - G.VISIBLE_SIZE.width)/2,old_y))
	newFlyIcon:setAnchorPoint(cc.p(0.5,0.5))
	panel:addChild(newFlyIcon)
	newFlyIcon:setScale(0.5)
	--抽奖个数
	local amountText = ccui.TextBMFont:create()
	amountText:setFntFile("font_05.fnt")
	amountText:setString("x"..itemInfo.count)
	amountText:setAnchorPoint(cc.p(0,0.5))
	amountText:setPosition(cc.p(30.02, 26.49))
	newFlyIcon:addChild(amountText,0)
	amountText:setScale(0.5) 
	--个数隐藏
	local function CallFucnCallback1()
		amountText:setVisible(false)
	end

	local action5 = cc.DelayTime:create(0.4)
	local action3 = cc.Spawn:create(cc.MoveBy:create(0.5,cc.p( new_X - old_x ,new_y - old_y )),cc.ScaleTo:create(0.5, 1.0))
	local action7 = cc.Spawn:create(cc.ScaleTo:create(0.5,1.0, 1.0),cc.MoveBy:create(0.5,cc.p(0 ,15)))
	local function CallFucnCallback2()
		self:loadChangeAction(finalId,awardPondId,awardPondInfo,itemInfo)
		newFlyIcon:removeFromParent()
		ModelLevelLottery:setGetAwardTimes(ModelLevelLottery:getGetAwardTimes() + 1)
	end
	
	local function CallFucnCallback3()
		UIGetAward:refreshDiamondUI(ModelItem:getTotalKey())
		UIGetAward:setMiddleBackBtn(ModelItem:getTotalKey())
		--重新加载9个icon--正常的没有礼包打开的时候
		if (UI:isOpened(UIItemInfo) == false and UI:isOpened(UIRewardHeroInfo) == false) and 
			ModelLevelLottery:getGetAwardTimes() == 9 and 
			ModelLottery:getOpenHeroBagFlag() == false then
				ModelLevelLottery:setGetAwardTimes(0)	
				ModelLottery:setRewardNeedData({})
				UIGetAward:createRewardBg()
			--若有一个礼包界面开着且，没有了延迟的后一个礼包界面，且已经打开九个了
		elseif (UI:isOpened(UIItemInfo) or UI:isOpened(UIRewardHeroInfo)) and 
			(UIDELAYPOP(UIItemInfo) == false or UIDELAYPOP(UIRewardHeroInfo) == false) and
			ModelLevelLottery:getGetAwardTimes()  == 9 and 
			ModelLottery:getOpenHeroBagFlag() == false then
				ModelLevelLottery:setGetAwardTimes(0)			--防止加载完后，多次加载9个箱子
				ModelLottery:setRewardNeedData({})
				UIGetAward:createRewardBg()
		end
	end
	if itemInfo.award_type == 1 or itemInfo.award_type == 3 then
		if itemInfo.id == 5 or itemInfo.id == 9 or itemInfo.id == 7
			or itemInfo.id == 6 or itemInfo.id == 8 then	-- 礼包类
			amountText:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 0.7),cc.DelayTime:create(0.0),cc.CallFunc:create(CallFucnCallback1)))
			newFlyIcon:runAction(cc.Sequence:create(action3,cc.CallFunc:create(CallFucnCallback2),
				cc.CallFunc:create(CallFucnCallback3)))	
		else												--正常饼干、毛球
			amountText:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5, 0.7),cc.DelayTime:create(0.5),cc.CallFunc:create(CallFucnCallback1)))
			newFlyIcon:runAction(cc.Sequence:create(action7,action5,action3,
			cc.CallFunc:create(CallFucnCallback2),cc.CallFunc:create(CallFucnCallback3)))
		end
	elseif  itemInfo.award_type == 2 then					--英雄
		iconWidget:runAction(cc.Sequence:create(cc.CallFunc:create(CallFucnCallback2), cc.DelayTime:create(0.5),cc.CallFunc:create(CallFucnCallback3)))
	end
end
------------------------------------------------------------------------------------------------------------------------
function UIMiddlePub:onTouch(touch, event, eventCode)
end

function UIMiddlePub:onUpdate(dt)
end

function UIMiddlePub:onDestroy()
	self.mLoardingBar = nil
	self.mPowerText = nil
	self.mPowerText = nil
	self.mPowerTime = nil
	self.mCollectBall = nil
	self.mCollectCookie = nil
	self.mDiamond = nil
	self.mSignIn = nil 
	self.mBtnActivity = nil
	self.mBtnActivityNode = nil
end
-----------------------------------------设置与获得各个中间界面元素-----------------------------------------------
--获得毛球text
function UIMiddlePub:getCollectNumberBall() return self.mCollectBall end

--获得体力text
function UIMiddlePub:getPowerText() return self.mPowerText end

--获得最大体力text
function UIMiddlePub:getMaxPowerText() return self.mPowerTextMax end

--获得饼干text
function UIMiddlePub:getCollectNumberCookie()  return self.mCollectCookie end

--获得砖石text
function UIMiddlePub:getCollectNumberDiamond() return self.mDiamond end

--设置毛球和饼干和砖石的个数
function UIMiddlePub:setCollectNumber()
	self.mCollectBall:setString(ModelItem:getTotalBall())
	self.mCollectCookie:setString(ModelItem:getTotalCookie())
	self.mDiamond:setString(ModelItem:getTotalDiamond())
end

--设置体力倒计时
function UIMiddlePub:setPowerLeftTime(text)
	if nil == self.mPowerTime then return end
	if  text == "00:00" or PowerManger:getCurPower() >= PowerManger:getMaxPower() then	--容错处理
		self.mPowerTime:setVisible(false)
	else
		self.mPowerTime:setString(text)
		self.mPowerTime:setVisible(true)
	end
end

--设置体力
function UIMiddlePub:setPower()
	if nil ~= self.mPowerText then
		self.mPowerText:setString(PowerManger:getCurPower())	
	end
end

--设置最大体力
function UIMiddlePub:setMaxPower()
	if nil ~= self.mPowerTextMax then
		self.mPowerTextMax:setString(PowerManger:getMaxPower())
	end
end

--设置进度条
function UIMiddlePub:setLoadingBar()
	if nil ~= self.mLoardingBar then
		local percent = PowerManger:getCurPower()/PowerManger:getMaxPower()*100
		if percent >= 100 then
			self.mLoardingBar:setPercent(100)
		else
			self.mLoardingBar:setPercent(percent)
		end
	end
end

--更新体力，最大体力，进度条
function UIMiddlePub:updatePowerMaxLoad()
	UIMiddlePub:setPower()
	UIMiddlePub:setMaxPower()
	UIMiddlePub:setLoadingBar()
end

--更新体力和倒计时、进度条（购买体力界面使用）
function UIMiddlePub:updatePowerAndTime()
	UIMiddlePub:setPower()
	UIMiddlePub:setLoadingBar()
	UIMiddlePub:setPowerLeftTime(PowerManger:getLeftTime())
end
------------------------------------------设置按钮、提示显示情况-----------------------------------------------------
--点击英雄使用
function UIMiddlePub:setPubBtn()
	ModelPub:setWidgetVisible(self.mBtnBack,true)
	ModelPub:setWidgetVisible(self.mSetBtn,false)
	ModelPub:setWidgetVisible(self.mBtnAward,false)
	ModelPub:setWidgetVisible(self.mCollectedBg,true)
	ModelPub:setWidgetVisible(self.mBtnActivity,false)
	ModelPub:setWidgetVisible(self.mBtnEnterHero,false)
	ModelPub:setWidgetVisible(self.mSignIn,false)
	ModelPub:setWidgetVisible(self.mBtnActivityNode,false)
end

--成功、失败后，抽奖界面使用
function UIMiddlePub:setSuccessBtn()
	ModelPub:setWidgetVisible(self.mSetBtn,false)
	ModelPub:setWidgetVisible(self.mBtnBack,false)
	ModelPub:setWidgetVisible(self.mBtnAward,false)
	ModelPub:setWidgetVisible(self.mCollectedBg,true)
	ModelPub:setWidgetVisible(self.mBtnActivity,false)
	ModelPub:setWidgetVisible(self.mBtnEnterHero,false)
	ModelPub:setWidgetVisible(self.mSignIn,false)
	ModelPub:setWidgetVisible(self.mBtnActivityNode,false)
end

--显示限时打折活动按钮
function UIMiddlePub:showDisDiaBtn()
	ModelPub:setWidgetVisible(self.mBtnActivityNode,ModelDiscount:showActivityBtn())
	ModelPub:setWidgetVisible(self.mBtnActivity,ModelDiscount:showActivityBtn())
end

--显示每日签到按钮
function UIMiddlePub:showSignInBtn()
	if self.mSignIn == nil or self.mBtnActivityNode == nil then
		return
	end
	ModelPub:setWidgetVisible(self.mSignIn,ModelSignIn:showSignInBtn())
	self.signInTip = self:getChild("img_signIn_tip")
	local flag = ModelSignIn:isTodaySignIn()
	self.signInTip:setVisible(not flag)
	--设置限时打折按钮的位置
	if ModelSignIn:showSignInBtn()== false then
		local pos_x,pos_y = self.mSignIn:getPosition()
		self.mBtnActivityNode:setPosition(cc.p(pos_x,pos_y))
	end
end

--设置各个按钮的显示及可否点击（主界面时的中间按钮）
function UIMiddlePub:initBtns()
	self:showDisDiaBtn()
	self:showSignInBtn()
	UIMiddlePub:setTips()
	ModelPub:setWidgetVisible(self.mSetBtn,true)
	ModelPub:setWidgetVisible(self.mBtnBack,false)
	ModelPub:setWidgetVisible(self.mCollectedBg,false)
	ModelPub:setWidgetVisible(self.mBtnAward,GuideMgr:isLotteryOpen())
	ModelPub:setWidgetVisible(self.mBtnEnterHero,GuideMgr:isHeroOpen())	
end

-- 隐藏返回按钮
function UIMiddlePub:showBackBtn(flag)
	ModelPub:setWidgetVisible(self.mBtnBack,flag)
end

-- 返回按钮放大缩小动画
function UIMiddlePub:backScaleAction()
	self.mBtnBack:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.4,0.9), 
		cc.ScaleTo:create(0.4,1.0))))
end

--设置是否显示钥匙和进入英雄的红点
function UIMiddlePub:setTips()
	local count = DataHeroInfo:getAllGrowNumber()
	self.tipGrowBg = self:getChild("tip_grow")
	if count == 0 then
		self.tipGrowBg:setVisible(false)
	else
		self.tipGrowBg:setVisible(GuideMgr:isHeroOpen())
		self.tipGrowText:setString(count)
	end
	
	local keyNumber = ModelItem:getTotalKey()
	if keyNumber == 0 then
		self.tipKeyBg:setVisible(false)
	else
		self.tipKeyBg:setVisible(GuideMgr:isLotteryOpen())
		self.tipKeyText:setString(keyNumber)
	end
end
----------------------------------------点击事件----------------------------------------------------------------
-- 设置按纽事件
function UIMiddlePub:handleSetting()
	if ChannelProxy:getChannelId() == "10201" then		--电信
		UITelSetUp:openFront(true)
	elseif ChannelProxy:isCocos() then	--触控
		UITelSetUp:openFront(true)
	elseif ChannelProxy:getChannelId() == "10181" then	--触控--移动
		UITelSetUp:openFront(true)
	else
		UISetUp:openFront(true)
	end
end

-- 体力按纽事件
function UIMiddlePub:handlePower()
	UIBuyPower:openFront(true)
	ChannelProxy:recordCustom("stat_hp")
end

-- 抽奖按纽事件
function UIMiddlePub:handleEnterAwardUI()
	UIMain:close()
	UIGetAward:openBack()		-- 打开战斗失败界面	
	UIMiddlePub:openBack()				-- 打开中间界面 
	UIMiddlePub:setPubBtn()
	UIGetAward:setMiddleBackBtn(ModelItem:getTotalKey())
end

--进入英雄按钮事件
function UIMiddlePub:handleEnterHeroUI()
	ChannelProxy:recordCustom("stat_hero_tabs")
	UIMain:close()
	UIMiddlePub:setPubBtn()
	UIHero:setInitPage(DataHeroInfo:getInitHeroIndex())
	UIHero:openBack()
end

--返回主界面按钮事件
function UIMiddlePub:handleBackMain()
	UIHero:close()
	UIGetAward:close()
	UIMain:openBack()
	self:initBtns()
	ModelDiscount:showDisCountDiamond(ModelCopy:getShowDis())
	ModelSignIn:showSignInUI()
	
	self.mBtnBack:stopAllActions()
	self.mBtnBack:setScale(1.0)
	
	UIMiddlePub:setCollectNumber()
end

-- 购买砖石事件
function UIMiddlePub:handleBuyPower()
	UIBuyDiamond:openFront(true, {["enter_mode"] ="middle",["diamondNumber"] = ModelItem:getTotalDiamond()})
end

--活动点击事件
function UIMiddlePub:handleActivity()		--如果是false，因为定时器，要特殊处理了*************
	UIDiscountDiamond:openFront(true)
end

--每日签到点击事件
function UIMiddlePub:handleSignIn()		
	UISignIn:openFront(true)
end
----------------------------------------------------------------------------------------------