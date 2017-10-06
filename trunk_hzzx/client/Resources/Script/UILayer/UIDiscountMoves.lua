----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-5
-- Brief: 关卡通过几关后，步数打折界面
----------------------------------------------------------------------
UIDiscountMoves = {
	csbFile = "DiscountMoves.csb"
}

--抢购购买步数
function UIDiscountMoves:handleBuy()
	self.buyMovesBg:setTouchEnabled(false)
	local tbData = {
		["product_name"]	= LanguageStr("BUY_DIS_MOVES_PAY_TITLE"),		-- 产品名称
		["total_fee"]		= ChannelPayCode:getBuyDisMovPrice(),			-- 订单金额
		["product_desc"]	= LanguageStr("BUY_DIS_MOVES_PAY_DESC"),		-- 订单描述
		["product_id"]		= "discount_moves",								-- 订单ID
		["tycode"]			= ChannelPayCode:getDisMovDxCode() or "0",		-- 天翼支付码
		["ltcode"]			= ChannelPayCode:getDisMovLtCode() or "0",		-- 联通支付码
		["ydcode"]			= ChannelPayCode:getDisMovYdCode() or "0",		-- 移动支付码
		--["ascode"]			= ChannelPayCode:getDisMovAsCode() or "0",		-- AppStore支付码
	}
	local function fnBuySuccessHandler()
		if not isNil(self.buyMovesBg) then
			self.buyMovesBg:setTouchEnabled(true)
		end
		self:buyDisMoves()
		UIManager:close(self)
		ChannelProxy:recordPay(ChannelPayCode:getBuyDisMovPrice(), "0", LanguageStr("BUY_DIS_MOVES_PAY_TITLE"))
		ChannelProxy:recordCustom("stat_buy_move_game_start")
	end
	local function fnBuyFailHandler()
		if not isNil(self.buyMovesBg) then
			self.buyMovesBg:setTouchEnabled(true)
		end
	end
	ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
end

function UIDiscountMoves:onStart(ui, param)

	self.rootPanel = UIManager:seekNodeByName(ui.root, "Panel_1")
	Utils:addTouchEvent(self.rootPanel, function(sender)
		print("我尽力啊了*******************")
		self:handleBuy()
	end, true, true, 0)
	
	AudioMgr:playEffect(2007)

	local nowPrice = string.format("%.2f",ChannelPayCode:getBuyDisMovPrice())
	--现价
	self.Text_nowPrice = UIManager:seekNodeByName(ui.root, "Text_nowPrice")
	self.Text_nowPrice:setString(LanguageStr("DIS_MOVES_GET",nowPrice))
	
	--购买步数放大区域
	self.buyMovesBg = UIManager:seekNodeByName(ui.root, "Button_buy_bg")
	Utils:addTouchEvent(self.buyMovesBg, function(sender)
		self:handleBuy()
	end, true, true, 1)
	
	--购买步数
	self.buyMoves = UIManager:seekNodeByName(ui.root, "Button_buy")
	Utils:addTouchEvent(self.buyMoves, function(sender)
		self:handleBuy()
	end, true, true, 1)
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:autoChangePos(btnClose)
	Utils:addTouchEvent(btnClose, function(sender)
		DataLevelInfo:setFailTimes(0)
		UIManager:close(self)
	end, true, true, 0)
	
end

--抢购购买步数
function UIDiscountMoves:buyDisMoves()
	local oriMoves = CopyModel:getCurrMoves()
	local nowMoves = oriMoves + 5
	CopyModel:setCurrMoves(nowMoves + 1)
	UIGameGoal:updateLeftMoves()
	DataLevelInfo:setFailTimes(0)
end

function UIDiscountMoves:onTouch(touch, event, eventCode)
end

function UIDiscountMoves:onUpdate(dt)
end

function UIDiscountMoves:onDestroy()
end

