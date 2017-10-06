----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-05
-- Brief: 通过多少关后，显示砖石打折界面
----------------------------------------------------------------------
UIDiscountDiamond = {
	csbFile = "DiscountDiamonds.csb"
}

--更新界面UI
function UIDiscountDiamond:updateUI()
	if nil == self.Text_number or  nil == self.Text_nowPrice then
		return
	end
	self.Text_number:setString(self.disDiaInfo.diamonds_number)
	self.Text_nowPrice:setString(string.format(LanguageStr("DIS_DIA_GET",self.disDiaInfo.dis_price)))
end

--更新界面UI
function UIDiscountDiamond:handleBuy()
	self.btnBuyBg:setTouchEnabled(false)
	local tbData = {
		["product_name"]	= LanguageStr("DISCOUNT_CIAMOND_TITLE"),-- 产品名称
		["total_fee"]		= self.disDiaInfo.dis_price,		-- 订单金额
		["product_desc"]	= LanguageStr("DISCOUNT_CIAMOND_TITLE"),			-- 订单描述
		["product_id"]		= "discount_diamond",				-- 订单ID
		["tycode"]			= self.disDiaInfo.DISCOUNT_CIAMOND_TY_CODE or "0",		-- 天翼支付码
		["ltcode"]			= self.disDiaInfo.DISCOUNT_CIAMOND_LT_CODE or "0",		-- 联通支付码
		["ydcode"]			= self.disDiaInfo.DISCOUNT_CIAMOND_YD_CODE or "0",		-- 移动支付码
	}
	local function fnBuySuccessHandler(sResult)
		if not isNil(self.btnBuyBg) then
			self.btnBuyBg:setTouchEnabled(true)
		end
		-- 支付完成以后回调
		if nil == sResult or "" == sResult or ChannelProxy.PAY_SUCCESS == sResult then
			local lastNumber = ItemModel:getTotalDiamond()
			ItemModel:appendTotalDiamond(self.disDiaInfo.diamonds_number)
			
			local tb = {}
			tb.itemType = ItemType["dia"] 
			tb.oldAmount = lastNumber
			tb.newAmount = lastNumber + self.disDiaInfo.diamonds_number
			tb.flag = SignType["add"]
			EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
		
			ChannelProxy:recordPay(tostring(self.disDiaInfo.dis_price), tostring(self.disDiaInfo.diamonds_number), LanguageStr("DISCOUNT_CIAMOND_TITLE"))
			ChannelProxy:recordCustom("stat_buy_discount_diamond_"..self.disDiaInfo.id)	-- 友盟统计
			if not tolua.isnull(self.btnBuyBg) then
				UIManager:close(self)
			end
		end
	end
	local function fnBuyFailHandler()
		if not isNil(self.btnBuyBg) then
			self.btnBuyBg:setTouchEnabled(true)
		end
	end
	ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
end

function UIDiscountDiamond:onStart(ui, param)

	self.rootPanel = UIManager:seekNodeByName(ui.root, "Panel_1")
	Utils:addTouchEvent(self.rootPanel, function(sender)
		print("我尽力啊了*******************")
		self:handleBuy()
	end, true, true, 0)

	AudioMgr:playEffect(2007)
	self.disDiaInfo = DataMap:getDisDiamondInfo()[1].dis_dia_info
	
	--砖石的个数
	self.Text_number = UIManager:seekNodeByName(ui.root, "Text_number")
	--打折后的价钱
	self.Text_nowPrice = UIManager:seekNodeByName(ui.root, "Text_nowPrice")
	self:updateUI()
	-- 抢购按钮放大区域
	self.btnBuyBg = UIManager:seekNodeByName(ui.root, "Button_buy_bg")
	Utils:addTouchEvent(self.btnBuyBg, function(sender)
		self:handleBuy()
	end, true, true, 1)
	
	-- 抢购按钮
	self.btnBuy = UIManager:seekNodeByName(ui.root, "Button_buy")
	self.btnBuy:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.4,0.9), 
		cc.ScaleTo:create(0.4,1.0))))
	Utils:addTouchEvent(self.btnBuy, function(sender)
		self:handleBuy()
	end, true, true, 1)
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:autoChangePos(btnClose)
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
		UIManager:openFront(UIFreePower,true)
	end, true, true, 0)
	
	--活动剩余时间
	if self.timer ~= nil then
		self.timer:start()
	end

	local function timer1_CF1(tm, runCount)
	--[[
		if self.Text_leftTime ~= nil then
			local tempTime = tonumber(DataLevelInfo:getActivityLeftTime() - runCount)
			if tempTime <= 0 then
				tempTime = 0
			end
			local leftTime = Utils:secToString(tempTime)
			self.Text_leftTime:setString(leftTime)
		end
		]]--
	end

	local function timer1_CF2(tm)
		self.timer = nil
		
		DataLevelInfo:saveDisDiaData()
		self.disDiaInfo = DataMap:getDisDiamondInfo()[1].dis_dia_info
		UIDiscountDiamond:updateUI()
		
		self.timer = CreateTimer(1, DataLevelInfo:getActivityLeftTime(), timer1_CF1, timer1_CF2)
		self.timer:start()	
	end
	self.timer = CreateTimer(1, DataLevelInfo:getActivityLeftTime(), timer1_CF1, timer1_CF2)
	self.timer:start()	
	
end

function UIDiscountDiamond:onTouch(touch, event, eventCode)
end

function UIDiscountDiamond:onUpdate(dt)
end

function UIDiscountDiamond:onDestroy()
end

