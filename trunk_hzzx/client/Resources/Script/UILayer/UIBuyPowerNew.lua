----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-4-22
-- Brief: 新款补满体力界面
----------------------------------------------------------------------
UIBuyPowerNew = {
	csbFile = "BuyPowerNew.csb"
}

--补满体力后刷新界面						
function UIBuyPowerNew:refreshUIAfterFullEnergy()
	PowerManger:setCurPower(DataMap:getMaxPower())
	PowerManger:setTimer()					-- 设置体力管理器
	PowerManger:timerChangeCurPower()
	PowerManger:setLeftTime("00:00")
	EventDispatcher:post(EventDef["ED_POWER_LEFT_TIME"], "00:00")
	EventDispatcher:post(EventDef["ED_POWER"])
end

--补满体力后刷新界面						
function UIBuyPowerNew:handleBuy()
	self.buyPowerBg:setTouchEnabled(false)
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
		if not isNil(self.buyPowerBg) then
			self.buyPowerBg:setTouchEnabled(true)
		end
		if nil == sResult or "" == sResult or ChannelProxy.PAY_SUCCESS == sResult then
			-- 支付完成以后回调
			self:refreshUIAfterFullEnergy()
			UIManager:close(self)
			ChannelProxy:recordPay(ChannelPayCode:getBuyPowerPrice(), "0",LanguageStr("BUY_POWER_PAY_TITLE"))
			ChannelProxy:recordCustom("stat_buy_hp")
		end
	end
	local function fnBuyFailHandler()
		if not isNil(self.buyPowerBg) then
			self.buyPowerBg:setTouchEnabled(true)
		end
	end
	ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
end

function UIBuyPowerNew:onStart(ui, param)
	AudioMgr:playEffect(2007)
	
	self.rootPanel = UIManager:seekNodeByName(ui.root, "Panel_1")
	Utils:addTouchEvent(self.rootPanel, function(sender)
		print("我尽力啊了*******************")
		self:handleBuy()
	end, true, true, 0)
	
	--补满体力
	self.buyPower = UIManager:seekNodeByName(ui.root, "buyPower")
	Utils:addTouchEvent(self.buyPower, function(sender)
		self:handleBuy()
	end, true, true, 0)
	
	--补满体力放大区域
	self.buyPowerBg = UIManager:seekNodeByName(ui.root, "buyPowerBg")
	Utils:addTouchEvent(self.buyPowerBg, function(sender)
		self:handleBuy()
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:autoChangePos(btnClose)
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	
	--补满体力需要的人民币
	local Text_fullEnergy = UIManager:seekNodeByName(ui.root, "buy_price")	
	Text_fullEnergy:setString(string.format(LanguageStr("DIS_MOVES_GET",ChannelPayCode:getBuyPowerPrice())))
end

function UIBuyPowerNew:onTouch(touch, event, eventCode)
end

function UIBuyPowerNew:onUpdate(dt)
end

function UIBuyPowerNew:onDestroy()

end

function UIBuyPowerNew:onGameInit(param)
	
end

