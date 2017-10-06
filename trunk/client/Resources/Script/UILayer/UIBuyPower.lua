----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-7
-- Brief: 体力购买界面
----------------------------------------------------------------------
UIDEFINE("UIBuyPower", "BuyPower.csb")
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
	EventCenter:post(EventDef["ED_POWER_LEFT_TIME"], "00:00")
	EventCenter:post(EventDef["ED_POWER"])
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

function UIBuyPower:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self:bind(EventDef["ED_POWER_LEFT_TIME"], self.setPowerLeftTime, self)
	self:bind(EventDef["ED_POWER"], self.setPower, self)
	local curPower = PowerManger:getCurPower()
	local maxPower = PowerManger:getMaxPower()
	--设置随机的文字
	local tb = {LanguageStr("BUY_POWER_2"),LanguageStr("BUY_POWER_3"),LanguageStr("BUY_POWER_4")}
	self.Text_random = self:getChild("Text_random")
	local copyInfo = LogicTable:get("copy_tplt", DataMap:getMaxPass() + 1, false)
	if nil ~= copyInfo and curPower < copyInfo.hp then
		self.Text_random:setString(LanguageStr("BUY_POWER_1"))
	else
		self.Text_random:setString(CommonFunc:getRandom(tb))
	end
	
	--血条
	self.blood = self:getChild("LoadingBar_1")
	self.blood:setPercent(100.00*curPower/maxPower)
	--当前体力
	self.mText_power = self:getChild("Text_power")
	--体力倒计时
	self.mText_LeftTime = self:getChild("Text_LeftTime")
	self:updatePowerAndTime()
	
	--专用的补满体力
	self.buyPower_spe = self:getChild("buyPower_spe")
	self.buyPower_spe:setVisible(G.CONFIG["debug"])
	self:addTouchEvent(self.buyPower_spe, function(sender)
		self:refreshUIAfterFullEnergy()
	end, true, true, 0)
	
	self.buyPowerTip = self:getChild("Image_34")
	self.buyPower = self:getChild("buyPower")
	self:addTouchEvent(self.buyPower, function(sender)
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
			["ckcode"]			= ChannelPayCode:getBuyPowerCkCode() or "0",	-- 触控支付码
		}
		local function fnBuySuccessHandler()
			self:refreshUIAfterFullEnergy()
			self:setBuyPowerButtonGray()
			ChannelProxy:recordPay(ChannelPayCode:getBuyPowerPrice(), "0",LanguageStr("BUY_POWER_PAY_TITLE"))
			ChannelProxy:recordCustom("stat_buy_hp")
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
	local buyMaxPower = self:getChild("buyMaxPower")
	if DataMap:getAddMaxPower() == false then
		self:addTouchEvent(buyMaxPower, function(sender)
			if DataMap:getAddMaxPower() == true then
				UIPrompt:show(LanguageStr("POWER_TIP_1"))
				return
			end
			local currDiamond = ModelItem:getTotalDiamond()
			if currDiamond < G.BUY_ONE_MAX_POWER then
				local data = G.BUY_ONE_MAX_POWER - currDiamond
				UIBuyDiamond:openFront(true, {["enter_mode"] ="buy",["diamondNumber"] = data})
				return
			end
			--购买最大体力后，设置体力补满
			DataMap:setAddMaxPower(true)
			PowerManger:setMaxPower(DataMap:getMaxPower() + G.BUY_MAX_POWER_NUMBER)
			UIMiddlePub:setMaxPower()
			self:refreshUIAfterFullEnergy()
			ModelItem:appendTotalDiamond(-G.BUY_ONE_MAX_POWER)
			
			local tb = {}
			tb.itemType = ItemType["dia"] 
			tb.oldAmount = currDiamond
			tb.newAmount = currDiamond - G.BUY_ONE_MAX_POWER
			tb.flag = SignType["reduce"]
			EventCenter:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 

			ChannelProxy:recordCustom("stat_hp_add_max")
		end, true, true, 0)
	else
		buyMaxPower:setTouchEnabled(false)
		buyMaxPower:loadTextures("public_red_btn_gray.png", "public_red_btn_gray.png", "public_red_btn_gray.png")
		local buyMaxPowerTip = self:getChild("Image_34_Copy")
		buyMaxPowerTip:loadTexture("text_power_gray.png")
	end
	
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		self:close()
	end, true, true, 0)
	
	--补满体力需要的人民币
	local Text_fullEnergy = self:getChild("Text_fullEnergy")	
	Text_fullEnergy:setString(ChannelPayCode:getFormatPrice(ChannelPayCode:getBuyPowerPrice()))
	--购买最大体力耗费的砖石
	local Text_needDiamond = self:getChild("Text_needDiamond")	
	Text_needDiamond:setString(G.BUY_ONE_MAX_POWER)
	
	--添加一个待机的英雄
	local smallRoot =  self:getChild("Image_6")	
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
	local tellImg = self:getChild("Image_tell")	
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

