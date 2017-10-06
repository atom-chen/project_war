
----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-4-27
-- Brief:两小时内不耗费体力
----------------------------------------------------------------------
UIFreePower = {
	csbFile = "FreePower.csb"
}

--
local enterMode = {
	["main"] = 1,		--直接点击按钮进入
	["restart"] = 2,	--体力不足时进入，（副本开始按钮，暂停时重新开始按钮，失败后重新开始按钮）
}

--购买函数
function UIFreePower:handleBuy()
	if FreePowerManger:getLeftTime() ~= "00:00" then
		--UIPrompt:show("你真的要点了啊！")
		--return
	end
	print("购买体力*************")
	self.mFreePowerBtn:setTouchEnabled(false)
	local tbData = {
		["product_name"]	= LanguageStr("FREE_POWER_TITLE"),	-- 产品名称
		["total_fee"]		= G.FREE_POWER_MONEY,				-- 订单金额
		["product_desc"]	= LanguageStr("FREE_POWER_DESC"),	-- 订单描述
		["product_id"]		= "buy_free_power_finish",			-- 订单ID
		["tycode"]			= G.FREE_POWER_PAY_TY_CODE or "0",	-- 天翼支付码
		["ltcode"]			= G.FREE_POWER_PAY_LT_CODE or "0",	-- 联通支付码
		["ydcode"]			= G.FREE_POWER_PAY_YD_CODE or "0",	-- 移动支付码
	}
	local function fnBuySuccessHandler(sResult)
		if not isNil(self.mFreePowerBtn) then
			self.mFreePowerBtn:setTouchEnabled(true)
		end
		if nil == sResult or "" == sResult or ChannelProxy.PAY_SUCCESS == sResult then
			-- 支付完成以后回调
			--体力回满
			PowerManger:setCurPower(DataMap:getMaxPower())
			PowerManger:setTimer()					-- 设置体力管理器
			PowerManger:timerChangeCurPower()
			PowerManger:setLeftTime("00:00")
			EventDispatcher:post(EventDef["ED_POWER_LEFT_TIME"], "00:00")
			EventDispatcher:post(EventDef["ED_POWER"])
			--记录开始时间
			DataMap:setFreePowerStartDate(STime:getClientTime())
			
			print("已经进来了***************")
			--开始倒计时
			FreePowerManger:timerChangeStart()
			ChannelProxy:recordPay(G.FREE_POWER_MONEY, "0",LanguageStr("FREE_POWER_TITLE"))
			ChannelProxy:recordCustom("stat_free_power")
			UIManager:close(self)
		end
	end
	local function fnBuyFailHandler()
		if not isNil(self.mFreePowerBtn) then
			self.mFreePowerBtn:setTouchEnabled(true)
		end
	end
	ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
end

function UIFreePower:onStart(ui, param)
	
	self.rootPanel = UIManager:seekNodeByName(ui.root, "Panel_1")
	Utils:addTouchEvent(self.rootPanel, function(sender)
		print("我尽力啊了*******************")
		self:handleBuy()
	end, true, true, 0)
	
	
	--购买的价格
	self.buyPrice = UIManager:seekNodeByName(ui.root, "buy_price")
	self.buyPrice:setString("花费"..G.FREE_POWER_MONEY.."元")
	
	--关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	
	--购买钥匙按钮
	self.mFreePowerBtn = UIManager:seekNodeByName(ui.root, "Button_buy")
	Utils:addTouchEvent(self.mFreePowerBtn, function(sender)
		self:handleBuy()
	end, true, true, 0)
end

function UIFreePower:onTouch(touch, event, eventCode)
end

function UIFreePower:onUpdate(dt)
end

function UIFreePower:onDestroy()
	self.enterMode = 1
end

function UIFreePower:getEnterMode()
	return self.enterMode
end

function UIFreePower:setEnterMode(mode)
	self.enterMode = mode or  1
end
