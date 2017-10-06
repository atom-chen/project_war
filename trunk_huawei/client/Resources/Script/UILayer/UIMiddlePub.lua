----------------------------------------------------------------------
-- Author: lhq
-- Date: 2015-1-06
-- Brief: 中间层界面
----------------------------------------------------------------------
UIMiddlePub = {
	csbFile = "MiddlePub.csb"
}

function UIMiddlePub:onStart(ui, param)
	self:subscribeEvent(EventDef["ED_POWER_LEFT_TIME"], self.setPowerLeftTime)
	self:subscribeEvent(EventDef["ED_POWER"], self.updatePowerMaxLoad)
	self:subscribeEvent(EventDef["ED_CHANGE_REWARD_DATA"],self.numberChange) 
	-- 设置按钮
	self.mSetBtn = UIManager:seekNodeByName(ui.root, "btnSetting")
	Utils:autoChangePos(self.mSetBtn)
	Utils:addTouchEvent(self.mSetBtn, function(sender)
		self:handleSetting()
	end, true, true, 0)
	--体力背景
	self.mPowerBg = UIManager:seekNodeByName(ui.root, "powerBg")
	Utils:autoChangePos(self.mPowerBg)
	Utils:addTouchEvent(self.mPowerBg, function(sender)
		self:handlePower()
	end, false, true, 0)
	self.mPowerText = UIManager:seekNodeByName(ui.root, "powerText")		--体力值
	self.mPowerTextMax = UIManager:seekNodeByName(ui.root, "powerText_max")	--体力最大值
	self.mPowerTime = UIManager:seekNodeByName(ui.root, "powerTime")		--体力倒计时
	self.mLoardingBar = UIManager:seekNodeByName(ui.root, "LoadingBar_1")	--体力进度条
	UIMiddlePub:setPowerLeftTime(PowerManger:getLeftTime())
	UIMiddlePub:updatePowerMaxLoad()
	
	--收集物品背景 --毛球个数--饼干个数--砖石个数
	self.mCollectedBg = UIManager:seekNodeByName(ui.root, "Panel_collect")
	Utils:autoChangePos(self.mCollectedBg)
	self.mCollectBall = UIManager:seekNodeByName(self.root, "Text_collect_ball")	
	self.mCollectCookie = UIManager:seekNodeByName(self.root, "Text_collect_cookie")
	self.mDiamond = UIManager:seekNodeByName(self.root, "diamond")					
	
	--毛球、饼干、砖石、体力的icon
	self.collectBall = UIManager:seekNodeByName(self.root, "collect_ball") 
	self.collectCookie = UIManager:seekNodeByName(self.root, "collect_cookie")
	self.diamond = UIManager:seekNodeByName(self.root, "diamondIcon")
	self.powerIcon = UIManager:seekNodeByName(self.root, "powerIcon")
	
	--钥匙提示和个数、英雄可升级提示和个数
	self.tipKeyBg = UIManager:seekNodeByName(self.root, "tip_key")
	self.tipKeyText = UIManager:seekNodeByName(self.root, "Text_key")
	self.tipGrowBg = UIManager:seekNodeByName(self.root, "tip_grow")
	self.tipGrowText = UIManager:seekNodeByName(self.root, "Text_grow")
	
	--进入英雄
	self.mBtnEnterHero = UIManager:seekNodeByName(ui.root, "btnEnterHero")
	Utils:addTouchEvent(self.mBtnEnterHero, function(sender)
		self:handleEnterHeroUI()
	end, true, true, 0)
	Utils:autoChangePos(self.mBtnEnterHero)
	--活动按钮
	self.mBtnActivity = UIManager:seekNodeByName(ui.root, "btnActivity")
	Utils:autoChangePos(self.mBtnActivity)
	Utils:addTouchEvent(self.mBtnActivity, function(sender)
		self:handleActivity()
	end, true, true, 0)
	--抽奖按钮
	self.mBtnAward = UIManager:seekNodeByName(ui.root, "btnAward")
	Utils:autoChangePos(self.mBtnAward)
	if DataMap:getPass() == 0 then
		self.mBtnAward:setTouchEnabled(false)
	else
		self.mBtnAward:setTouchEnabled(true)
	end
	Utils:addTouchEvent(self.mBtnAward, function(sender)
		self:handleEnterAwardUI()
	end, true, true, 0)
	--返回按钮
	self.mBtnBack = UIManager:seekNodeByName(ui.root, "btnBackMain")
	Utils:addTouchEvent(self.mBtnBack, function(sender)
		self:handleBackMain()
		if  DataMap:getMaxPass() ~= 22 then
			if GuideUI:checkUIGuide(self) then
				UIMain:setScorllViewTouch(false)
			end
		end
		AudioMgr:playEffect(2007)
	end, true, true, 0)
	Utils:autoChangePos(self.mBtnBack)
	--砖石背景
	self.mBtnDiamondBg = UIManager:seekNodeByName(ui.root, "diamondBg")
	Utils:autoChangePos(self.mBtnDiamondBg)
	Utils:addTouchEvent(self.mBtnDiamondBg, function(sender)
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
end

--获得毛球图标、饼干图标、砖石图标、体力图标的位置
function UIMiddlePub:getCollectPos()
	return self.x1,self.y1,self.x2,self.y2,self.x3,self.y3,self.x4,self.y4
end

--根据物品的类型，获得一些信息
function UIMiddlePub:getInfosByType(types)
	local widget,lastNumber,nowNumber = nil,0,0
	if types == 1 then
		widget = self.mCollectBall
		nowNumber = ItemModel:getTotalBall()
		lastNumber = nowNumber - ItemModel:getCollectBall()
	elseif types == 2 then
		widget = self.mCollectCookie
		nowNumber = ItemModel:getTotalCookie()
		lastNumber = nowNumber - ItemModel:getCollectCookie()
	elseif types == 3 then
		widget = self.mDiamond
		nowNumber = ItemModel:getTotalDiamond()
		lastNumber = nowNumber - ItemModel:getCollectDiamond()
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
function UIMiddlePub:loadChangeAction(finalId,awardPondId,awardPondInfo,itemInfo)
	local keyStr,allTimes = DataLevelInfo:getKeyByAwardInfo(awardPondInfo,finalId)		
	if itemInfo.award_type == 1 or itemInfo.award_type == 3 then		-- 礼包类型
		local lastNumber = 0
		local types = UIMiddlePub:getItemTypeById(itemInfo.id)
		local widget = UIMiddlePub:getWidgetByItemType(types)
		if types == ItemType["ball"]  then					-- 毛球 -- 毛球包			
			lastNumber = GetRewardModel:getCurRewardBall()
		elseif  types == ItemType["cookie"] then			-- 饼干
			lastNumber = GetRewardModel:getCurRewardCookie()
		elseif types == ItemType["dia"] then				-- 砖石 -- 砖石包
			lastNumber = GetRewardModel:getCurRewardDiamond()
		elseif  types == ItemType["power"] then				-- 体力
			lastNumber = GetRewardModel:getCurRewardPower()
		elseif types == ItemType["maxpower"] then			-- 体力上限
			lastNumber = GetRewardModel:getCurRewardMaxPower()
		end
		self:changeNumber(widget, types, lastNumber, 1, itemInfo.count)
	end
end

-- 数据变动(changeType:1.表示增加,-1.表示减少)
function UIMiddlePub:changeNumber(widget, numberType, currNumber, changeType, changeCount)
	if isNil(widget) then return end
	widget:stopAllActions()
	widget:setString(currNumber)
	local newNumber = currNumber + changeType*changeCount
	if ItemType["ball"] == numberType then
		GetRewardModel:setCurRewardBall(newNumber)
	elseif ItemType["cookie"] == numberType then
		GetRewardModel:setCurRewardCookie(newNumber)
	elseif ItemType["dia"] == numberType then
		GetRewardModel:setCurRewardDiamond(newNumber)
	elseif ItemType["power"] == numberType then
		GetRewardModel:setCurRewardPower(newNumber)
		PowerManger:setCurPower(newNumber)
		UIMiddlePub:setLoadingBar()
		PowerManger:updateTimeByRewardPower()
	elseif ItemType["maxpower"] == numberType then
		GetRewardModel:setCurRewardMaxPower(newNumber)
		PowerManger:setMaxPower(newNumber)
		UIMiddlePub:setLoadingBar()
		PowerManger:updateTimeByRewardPower()
	end
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
	local panel = UIManager:seekNodeByName(self.root, "Panel_1")
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
		DataLevelInfo:setGetAwardTimes(DataLevelInfo:getGetAwardTimes() + 1)
	end
	
	local function CallFucnCallback3()
		UIGetAward:refreshDiamondUI(ItemModel:getTotalKey())
		UIGetAward:setMiddleBackBtn(ItemModel:getTotalKey())
		--重新加载9个icon--正常的没有礼包打开的时候
		if (UIManager:isLayerOpen(UIItemInfo) == false and UIManager:isLayerOpen(UIRewardHeroInfo) == false) and 
			DataLevelInfo:getGetAwardTimes() == 9 and 
			GetRewardModel:getOpenHeroBagFlag() == false then
				DataLevelInfo:setGetAwardTimes(0)	
				GetRewardModel:setRewardNeedData({})
				UIGetAward:createRewardBg()
			--若有一个礼包界面开着且，没有了延迟的后一个礼包界面，且已经打开九个了
		elseif (UIManager:isLayerOpen(UIItemInfo)  or UIManager:isLayerOpen(UIRewardHeroInfo)) and 
			(UIManager:popDelay(UIItemInfo) == false or UIManager:popDelay(UIRewardHeroInfo) == false) and
			DataLevelInfo:getGetAwardTimes()  == 9 and 
			GetRewardModel:getOpenHeroBagFlag() == false then
				DataLevelInfo:setGetAwardTimes(0)			--防止加载完后，多次加载9个箱子
				GetRewardModel:setRewardNeedData({})
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
	self.mCollectBall:setString(ItemModel:getTotalBall())
	self.mCollectCookie:setString(ItemModel:getTotalCookie())
	self.mDiamond:setString(ItemModel:getTotalDiamond())
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
--设置控件显示与触摸
function UIMiddlePub:setWidgetVisible(widget,isVisible)
	widget:setVisible(isVisible)
	widget:setTouchEnabled(isVisible)
end

--点击英雄使用
function UIMiddlePub:setPubBtn()
	self:setWidgetVisible(self.mBtnBack,true)
	self:setWidgetVisible(self.mSetBtn,false)
	self:setWidgetVisible(self.mBtnAward,false)
	self:setWidgetVisible(self.mCollectedBg,true)
	self:setWidgetVisible(self.mBtnActivity,false)
	self:setWidgetVisible(self.mBtnEnterHero,false)
end

--成功、失败后，抽奖界面使用
function UIMiddlePub:setSuccessBtn()
	self:setWidgetVisible(self.mSetBtn,false)
	self:setWidgetVisible(self.mBtnBack,false)
	self:setWidgetVisible(self.mBtnAward,false)
	self:setWidgetVisible(self.mCollectedBg,true)
	self:setWidgetVisible(self.mBtnActivity,false)
	self:setWidgetVisible(self.mBtnEnterHero,false)
end

--显示限时打折活动按钮
function UIMiddlePub:showDisDiaBtn()
	self:setWidgetVisible(self.mBtnActivity,DataLevelInfo:showActivityBtn())
end

--设置各个按钮的显示及可否点击（主界面时的中间按钮）
function UIMiddlePub:initBtns()
	self:showDisDiaBtn()
	UIMiddlePub:setTips()
	self:setWidgetVisible(self.mSetBtn,true)
	self:setWidgetVisible(self.mBtnBack,false)
	self:setWidgetVisible(self.mCollectedBg,false)
	self:setWidgetVisible(self.mBtnAward,GuideMgr:isLotteryOpen())
	self:setWidgetVisible(self.mBtnEnterHero,GuideMgr:isHeroOpen())	
end

-- 隐藏返回按钮
function UIMiddlePub:showBackBtn(flag)
	self:setWidgetVisible(self.mBtnBack,flag)
end

-- 返回按钮放大缩小动画
function UIMiddlePub:backScaleAction()
	self.mBtnBack:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.4,0.9), 
		cc.ScaleTo:create(0.4,1.0))))
end

--设置是否显示钥匙和进入英雄的红点
function UIMiddlePub:setTips()
	local count = DataHeroInfo:getAllGrowNumber()
	self.tipGrowBg = UIManager:seekNodeByName(self.root, "tip_grow")
	if count == 0 then
		self.tipGrowBg:setVisible(false)
	else
		self.tipGrowBg:setVisible(GuideMgr:isHeroOpen())
		self.tipGrowText:setString(count)
	end
	
	local keyNumber = ItemModel:getTotalKey()
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
	if ChannelProxy:getChannelId() == "10201" then
		UIManager:openFront(UITelSetUp, true)
	else
		UIManager:openFront(UISetUp, true)
	end
end

-- 体力按纽事件
function UIMiddlePub:handlePower()
	ChannelProxy:getStrInfo("buy_power_finish", function(productTb)
		if 0 == #productTb then
			UIPrompt:show(LanguageStr("QURERY_FAIL"))
		else
			UIManager:openFront(UIBuyPower, true ,{["product_tb"]=productTb})
			ChannelProxy:recordCustom("stat_hp")
		end
	end)	
end

-- 抽奖按纽事件
function UIMiddlePub:handleEnterAwardUI()
	UIManager:close(UIMain)
	UIManager:openBack(UIGetAward)		-- 打开战斗失败界面
	UIManager:openBack(UIMiddlePub)		-- 打开中间界面 
	UIMiddlePub:setPubBtn()
	UIGetAward:setMiddleBackBtn(ItemModel:getTotalKey())
end

--进入英雄按钮事件
function UIMiddlePub:handleEnterHeroUI()
	ChannelProxy:recordCustom("stat_hero_tabs")
	UIManager:close(UIMain)
	UIMiddlePub:setPubBtn()
	UIHero:setInitPage(DataHeroInfo:getInitHeroIndex())
	UIManager:openBack(UIHero)
end

--返回主界面按钮事件
function UIMiddlePub:handleBackMain()
	UIManager:close(UIHero)
	UIManager:close(UIGetAward)
	UIManager:openBack(UIMain)
	self:initBtns()
	DataLevelInfo:showDisCountDiamond()
	
	self.mBtnBack:stopAllActions()
	self.mBtnBack:setScale(1.0)
	
	UIMiddlePub:setCollectNumber()
end

-- 购买砖石事件
function UIMiddlePub:handleBuyPower()
	ChannelProxy:getStrInfo("shop", function(productTb)
		Log(productTb,#productTb)
		if 0 == #productTb then
			UIPrompt:show(LanguageStr("QURERY_FAIL"))
		else
			UIManager:openFront(UIBuyDiamond,true,{["enter_mode"] ="middle",["diamondNumber"] = ItemModel:getTotalDiamond(), ["product_tb"]=productTb})
		end
	end)
end

--活动点击事件
function UIMiddlePub:handleActivity()		--如果是false，因为定时器，要特殊处理了*************
	local str = "discount_diamond_"..DataMap:getDisDiamondInfo()[1].dis_dia_info.id
	ChannelProxy:getStrInfo(str, function(productTb)
		if 0 == #productTb then
			UIPrompt:show(LanguageStr("QURERY_FAIL"))
		else
			UIManager:openFront(UIDiscountDiamond, true ,{["product_tb"]=productTb})
		end
	end)
end
----------------------------------------------------------------------------------------------
-- 打开成功界面
function UIMiddlePub:openUISuccess()
	--特殊关卡奖励次数限制
	local curCopyInfo = DataLevelInfo:getCopyInfo()
	if curCopyInfo.reward_times ~= 0 then
		local tb = DataMap:getCopyAwardTimesInfo()
		if nil ~= tb[curCopyInfo.id] and curCopyInfo.reward_times > tb[curCopyInfo.id] then
			tb[curCopyInfo.id] = tb[curCopyInfo.id] + 1
			DataMap:setCopyAwardTimesInfo(tb)
			ItemModel:updatePassAward()			-- 过关奖励
		end
	else
		ItemModel:updatePassAward()				-- 过关奖励
	end
	
	UIManager:close(UIPauseGame)			--临界，多界面情况
	CreateTimer(1.6, 1, nil, function(tm)
		UIManager:openFront(UIGameSuccess, true)
	end):start()
	ChannelProxy:recordCustom("stat_copy_end_success")
	ChannelProxy:recordLevelFinish(DataMap:getPass())
end

--打开失败界面
function UIMiddlePub:openUIFailed()
	ChannelProxy:recordCustom("stat_copy_end_failure")
	ChannelProxy:recordLevelFail(DataMap:getPass())
	UIManager:close(UIPauseGame)			--临界，多界面情况
	UIManager:openFront(UIGameFailed,true)
end
------------------------------------------------------------------------------------------------