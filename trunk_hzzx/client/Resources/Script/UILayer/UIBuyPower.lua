----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-7
-- Brief: 体力购买界面
----------------------------------------------------------------------
UIBuyPower = {
	csbFile = "BuyPower.csb"
}

--设置当前界面的体力与倒计时
function UIBuyPower:setPowerLeftTime(text)
	if nil == self.mText_LeftTime then return end
	if PowerManger:getCurPower() >= PowerManger:getMaxPower() or text == "00:00" then	--
		self.mText_LeftTime:setVisible(false)
	else
		self.mText_LeftTime:setString(text)
		self.mText_LeftTime:setVisible(true)
	end
end

--设置体力
function UIBuyPower:setPower()
	if nil == self.mText_power or nil == self.blood then
		return
	end
	self.mText_power:setString(PowerManger:getCurPower().."/"..PowerManger:getMaxPower())
	self.blood:setPercent(100.00*PowerManger:getCurPower()/PowerManger:getMaxPower())
end

--更新体力和倒计时
function UIBuyPower:updatePowerAndTime()
	UIBuyPower:setPower()
	UIBuyPower:setPowerLeftTime(PowerManger:getLeftTime())
end

--补满体力后刷新界面						--不知体力补满有没有要求动画，数字变动	????????????????????????
function UIBuyPower:refreshUIAfterFullEnergy()
	PowerManger:setCurPower(DataMap:getMaxPower())
	PowerManger:setTimer()					-- 设置体力管理器
	PowerManger:timerChangeCurPower()
	PowerManger:setLeftTime("00:00")
	EventDispatcher:post(EventDef["ED_POWER_LEFT_TIME"], "00:00")
	EventDispatcher:post(EventDef["ED_POWER"])
	if not tolua.isnull(self.blood) then
		self.blood:setPercent(100.00)
	end
end

function UIBuyPower:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self:subscribeEvent(EventDef["ED_POWER_LEFT_TIME"], self.setPowerLeftTime)
	self:subscribeEvent(EventDef["ED_POWER"], self.setPower)
	local curPower = PowerManger:getCurPower()
	local maxPower = PowerManger:getMaxPower()
	--设置随机的文字
	local tb = {LanguageStr("BUY_POWER_2"),LanguageStr("BUY_POWER_3"),LanguageStr("BUY_POWER_4")}
	self.Text_random = UIManager:seekNodeByName(ui.root, "Text_random")
	local copyInfo = LogicTable:get("copy_tplt", DataMap:getMaxPass() + 1, false)
	if nil ~= copyInfo and curPower < copyInfo.hp then
		self.Text_random:setString(LanguageStr("BUY_POWER_1"))
	else
		self.Text_random:setString(CommonFunc:getRandom(tb))
	end
	
	--血条
	self.blood = UIManager:seekNodeByName(ui.root, "LoadingBar_1")
	self.blood:setPercent(100.00*curPower/maxPower)
	--当前体力
	self.mText_power = UIManager:seekNodeByName(ui.root, "Text_power")
	--体力倒计时
	self.mText_LeftTime = UIManager:seekNodeByName(ui.root, "Text_LeftTime")
	self:updatePowerAndTime()
	
	--专用的补满体力
	self.buyPower_spe = UIManager:seekNodeByName(ui.root, "buyPower_spe")
	Utils:addTouchEvent(self.buyPower_spe, function(sender)
		cclog("补满体力*****************")
		self:refreshUIAfterFullEnergy()
	end, true, true, 0)
	if G.CONFIG["debug"] then
		self.buyPower_spe:setVisible(true)
	else
		self.buyPower_spe:setVisible(false)
	end
	
	self.buyPower = UIManager:seekNodeByName(ui.root, "buyPower")
	Utils:addTouchEvent(self.buyPower, function(sender)
		self.buyPower:setTouchEnabled(false)
		local tbData = {
			["product_name"]	= LanguageStr("BUY_POWER_PAY_TITLE"),			-- 产品名称
			["total_fee"]		= ChannelPayCode:getBuyPowerPrice(),									-- 订单金额
			["product_desc"]	= LanguageStr("BUY_POWER_PAY_DESC"),			-- 订单描述
			["product_id"]		= "buy_power_finish",							-- 订单ID
			["tycode"]			= ChannelPayCode:getBuyPowerDxCode() or "0",	-- 天翼支付码
			["ltcode"]			= ChannelPayCode:getBuyPowerLtCode() or "0",	-- 联通支付码
			["ydcode"]			= ChannelPayCode:getBuyPowerYdCode() or "0",	-- 移动支付码
		}
		local function fnBuySuccessHandler(sResult)
			if not isNil(self.buyPower) then
				self.buyPower:setTouchEnabled(true)
			end
			if nil == sResult or "" == sResult or ChannelProxy.PAY_SUCCESS == sResult then
				-- 支付完成以后回调
				self:refreshUIAfterFullEnergy()
				ChannelProxy:recordPay(ChannelPayCode:getBuyPowerPrice(), "0",LanguageStr("BUY_POWER_PAY_TITLE"))
				ChannelProxy:recordCustom("stat_buy_hp")
			end
		end
		local function fnBuyFailHandler()
			if not isNil(self.buyPower) then
				self.buyPower:setTouchEnabled(true)
			end
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 0)
	
	
	--购买最大体力
	local buyMaxPower = UIManager:seekNodeByName(ui.root, "buyMaxPower")
	if DataMap:getAddMaxPower() == false then
		Utils:addTouchEvent(buyMaxPower, function(sender)
			if DataMap:getAddMaxPower() == true then
				UIPrompt:show(LanguageStr("POWER_TIP_1"))
				return
			end
			local currDiamond = ItemModel:getTotalDiamond()
			if currDiamond < G.BUY_ONE_MAX_POWER then
				local data = G.BUY_ONE_MAX_POWER - currDiamond
				UIManager:openFront(UIBuyDiamond,true,{["enter_mode"] ="buy",["diamondNumber"] = data})
				return
			end
			--购买最大体力后，设置体力补满
			DataMap:setAddMaxPower(true)
			PowerManger:setMaxPower(DataMap:getMaxPower() + G.BUY_MAX_POWER_NUMBER)
			UIMiddlePub:setMaxPower()
			UIMiddlePub:setLoadingBar()
			--self:refreshUIAfterFullEnergy()
			ItemModel:appendTotalDiamond(-G.BUY_ONE_MAX_POWER)
			
			local tb = {}
			tb.itemType = ItemType["dia"] 
			tb.oldAmount = currDiamond
			tb.newAmount = currDiamond - G.BUY_ONE_MAX_POWER
			tb.flag = SignType["reduce"]
			EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 

			ChannelProxy:recordCustom("stat_hp_add_max")
		end, true, true, 0)
	else
		buyMaxPower:setTouchEnabled(false)
	end
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	
	--补满体力需要的人民币
	local Text_fullEnergy = UIManager:seekNodeByName(ui.root, "Text_fullEnergy")	
	Text_fullEnergy:setString(string.format("￥%.2f",ChannelPayCode:getBuyPowerPrice()))
	--购买最大体力耗费的砖石
	local Text_needDiamond = UIManager:seekNodeByName(ui.root, "Text_needDiamond")	
	Text_needDiamond:setString(G.BUY_ONE_MAX_POWER)
	
	--添加一个待机的英雄
	local smallRoot =  UIManager:seekNodeByName(ui.root, "Image_6")	
	local tb = DataMap:getSelectedHeroIds()
	local tempTb = {}
	for key,val in pairs(tb) do
		table.insert(tempTb,key)
	end
	local randomNumber = CommonFunc:getRandom(tempTb)
	local heroInfo = LogicTable:get("hero_tplt", tb[randomNumber], true)
	local normalType = heroInfo.type
	local heroNode = Utils:createArmatureNode(heroInfo.display,G.MONSTER_IDLE,true)
	-- 设置英雄坐标
	heroNode:setAnchorPoint(cc.p(0.5, 0.5))
	heroNode:setPosition(cc.p(250, 397.83))
	smallRoot:addChild(heroNode)
end

function UIBuyPower:onTouch(touch, event, eventCode)
end

function UIBuyPower:onUpdate(dt)
end

function UIBuyPower:onDestroy()
	self.mText_power = nil 
	self.blood = nil
	self.mText_LeftTime = nil
end

function UIBuyPower:onGameInit(param)
	cclog("---------------11111 UIBuyPower",param)
end

