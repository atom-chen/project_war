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
	self:setBuyPowerButtonGray()
end

--更新体力和倒计时
function UIBuyPower:updatePowerAndTime()
	self:setPower()
	self:setPowerLeftTime(PowerManger:getLeftTime())
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

-- 设补满体力灰态
function UIBuyPower:setBuyPowerButtonGray()
	if isNil(self.buyPower) or isNil(self.buyPowerTip) then
		return
	end
	if DataMap:getPower() < DataMap:getMaxPower() then	-- 体力未满
		return
	end
	self.buyPower:setTouchEnabled(false)
	self.buyPower:loadTextures("public_red_btn_gray.png", "public_red_btn_gray.png", "public_red_btn_gray.png")
	self.buyPowerTip:loadTexture("text_add_full_power_gray.png")
end

-- 补满体力成功回调
function UIBuyPower:buyPowerSucHandler()
	self:refreshUIAfterFullEnergy()
	ChannelProxy:recordPay(ChannelPayCode:getBuyPowerPrice(), "0",LanguageStr("BUY_POWER_PAY_TITLE"))
	ChannelProxy:recordCustom("stat_buy_hp")
end

function UIBuyPower:onStart(ui, param)
	self.productTb = param.product_tb
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
	self.buyPower_spe:setVisible(G.CONFIG["debug"])
	Utils:addTouchEvent(self.buyPower_spe, function(sender)
		self:refreshUIAfterFullEnergy()
	end, true, true, 0)
	
	self.buyPowerTip = UIManager:seekNodeByName(ui.root, "Image_34")
	self.buyPower = UIManager:seekNodeByName(ui.root, "buyPower")
	Utils:addTouchEvent(self.buyPower, function(sender)
		self.buyPower:setTouchEnabled(false)
		local tbData = {
			["product_name"]	= LanguageStr("BUY_POWER_PAY_TITLE"),			-- 产品名称
			["total_fee"]		= ChannelPayCode:getBuyPowerPrice(),			-- 订单金额
			["product_desc"]	= LanguageStr("BUY_POWER_PAY_DESC"),			-- 订单描述
			["product_id"]		= "buy_power_finish",							-- 订单ID
			["tycode"]			= ChannelPayCode:getBuyPowerDxCode() or "0",	-- 天翼支付码
			["ltcode"]			= ChannelPayCode:getBuyPowerLtCode() or "0",	-- 联通支付码
			["ydcode"]			= ChannelPayCode:getBuyPowerYdCode() or "0",	-- 移动支付码
			["ascode"]			= ChannelPayCode:getBuyPowerAsCode() or "0",	-- AppStore支付码
			["gpcode"]			= ChannelPayCode:getBuyPowerGpCode() or "0",	-- GooglePlay支付码
		}
		local function fnBuySuccessHandler()
			self:setBuyPowerButtonGray()
			self:buyPowerSucHandler()
		end
		local function fnBuyFailHandler()
			if not isNil(self.buyPower) then
				self.buyPower:setTouchEnabled(true)
			end
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 0)
	if DataMap:getPower() < DataMap:getMaxPower() then	-- 体力未满
		self.buyPower:setTouchEnabled(true)
		self.buyPower:loadTextures("public_red_btn.png", "public_red_btn.png", "public_red_btn.png")
		self.buyPowerTip:loadTexture("text_add_full_power.png")
	else	-- 体力已满
		self:setBuyPowerButtonGray()
	end
	
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
				
				ChannelProxy:getStrInfo("shop", function(productTb)
					if 0 == #productTb then
						UIPrompt:show(LanguageStr("QURERY_FAIL"))
					else
						UIManager:openFront(UIBuyDiamond,true,{["enter_mode"] ="buy",["diamondNumber"] = data, ["product_tb"]=productTb})
					end
				end)
				
				return
			end
			--购买最大体力后，设置体力补满
			DataMap:setAddMaxPower(true)
			PowerManger:setMaxPower(DataMap:getMaxPower() + G.BUY_MAX_POWER_NUMBER)
			UIMiddlePub:setMaxPower()
			self:refreshUIAfterFullEnergy()
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
		buyMaxPower:loadTextures("public_red_btn_gray.png", "public_red_btn_gray.png", "public_red_btn_gray.png")
		local buyMaxPowerTip = UIManager:seekNodeByName(ui.root, "Image_34_Copy")
		buyMaxPowerTip:loadTexture("text_power_gray.png")
	end
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	
	--补满体力需要的人民币
	local Text_fullEnergy = UIManager:seekNodeByName(ui.root, "Text_fullEnergy")
	
	local powerTb = self.productTb
	Log("过滤后的movesTb信息******",powerTb)
	local priceTag = ChannelProxy:getPriceByDataKey(powerTb,"buy_power_finish")
	Text_fullEnergy:setString(priceTag)
	
	--Text_fullEnergy:setString(ChannelPayCode:getMoneySign()..ChannelPayCode:getBuyPowerPrice())
	--购买最大体力耗费的砖石
	local Text_needDiamond = UIManager:seekNodeByName(ui.root, "Text_needDiamond")	
	Text_needDiamond:setString(G.BUY_ONE_MAX_POWER)
	
	--添加一个待机的英雄
	local smallRoot =  UIManager:seekNodeByName(ui.root, "Image_6")	
	local tb = DataMap:getSelectedHeroIds()
	if tb[3] ~= nil then
		local tempTb = {}
		for key,val in pairs(tb) do
			table.insert(tempTb,key)
		end
		local randomNumber = CommonFunc:getRandom(tempTb)
		local heroInfo = LogicTable:get("hero_tplt", tb[randomNumber], true)
		local normalType = heroInfo.type
		local heroNode = Utils:createArmatureNode(heroInfo.display,G.MONSTER_IDLE,true)
		ui.root:reorderChild(heroNode,0)
		-- 设置英雄坐标
		heroNode:setAnchorPoint(cc.p(0.5, 0.5))
		heroNode:setPosition(cc.p(250, 397.83))
		smallRoot:addChild(heroNode,0)
	end
	local tellImg = UIManager:seekNodeByName(ui.root, "Image_tell")	
	ui.root:reorderChild(tellImg,10000)
	
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
end

