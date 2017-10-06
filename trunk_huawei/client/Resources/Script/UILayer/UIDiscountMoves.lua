----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-5
-- Brief: 关卡通过几关后，步数打折界面
----------------------------------------------------------------------
UIDiscountMoves = {
	csbFile = "DiscountMoves.csb"
}

function UIDiscountMoves:onStart(ui, param)

	self.productTb = param.product_tb
	AudioMgr:playEffect(2007)
	--self.discountMoveInfo = LogicTable:get("discount_moves_tplt", 1, true)
	
	--原价
	self.Text_origin_price = UIManager:seekNodeByName(ui.root, "Text_origin_price")
	local oriText = ChannelPayCode:getBuyMovPrice()
	self.Text_origin_price:setString(LanguageStr("DIS_DIA_ORI_MONEY")..ChannelPayCode:getMoneySign()..oriText)
	--cclog(tonumber(discountMoveInfo.price),discountMoveInfo.discount)
	local nowPrice = ChannelPayCode:getBuyDisMovPrice()
	--现价
	self.Text_nowPrice = UIManager:seekNodeByName(ui.root, "Text_nowPrice")
	
	local disTb = self.productTb
	Log("过滤后的disTb信息******",disTb)
	local priceTag = ChannelProxy:getPriceByDataKey(disTb,"discount_moves")
	self.Text_nowPrice:setString(priceTag)
	--self.Text_nowPrice:setString(ChannelPayCode:getMoneySign()..nowPrice)
	self.Text_nowPrice:enableOutline(cc.c4b(99,47,12,255),3)
	--折扣图片
	self.dis_img = UIManager:seekNodeByName(ui.root, "dis_img")
	self.dis_img:loadTexture(ChannelPayCode:getDisMovDiscountImg())
	--增加的步数		(现改为图片)
	--self.Text_addMoves = UIManager:seekNodeByName(ui.root, "dis_img")
	--self.Text_addMoves:setString(self.discountMoveInfo.add_moves)
	
	--购买步数
	self.buyMoves = UIManager:seekNodeByName(ui.root, "Button_buy")
	Utils:addTouchEvent(self.buyMoves, function(sender)
		self.buyMoves:setTouchEnabled(false)
		local tbData = {
			["product_name"]	= LanguageStr("BUY_DIS_MOVES_PAY_TITLE"),		-- 产品名称
			["total_fee"]		= ChannelPayCode:getBuyDisMovPrice(),			-- 订单金额
			["product_desc"]	= LanguageStr("BUY_DIS_MOVES_PAY_DESC"),		-- 订单描述
			["product_id"]		= "discount_moves",								-- 订单ID
			["tycode"]			= ChannelPayCode:getDisMovDxCode() or "0",		-- 天翼支付码
			["ltcode"]			= ChannelPayCode:getDisMovLtCode() or "0",		-- 联通支付码
			["ydcode"]			= ChannelPayCode:getDisMovYdCode() or "0",		-- 移动支付码
			["ascode"]			= ChannelPayCode:getDisMovAsCode() or "0",		-- AppStore支付码
			["gpcode"]			= ChannelPayCode:getDisMovGpCode() or "0",		-- GooglePlay支付码
		}
		local function fnBuySuccessHandler()
			if not isNil(self.buyMoves) then
				self.buyMoves:setTouchEnabled(true)
			end
			self:buyDisMoves()
			UIManager:close(self)
			ChannelProxy:recordPay(ChannelPayCode:getBuyDisMovPrice(), "0", LanguageStr("BUY_DIS_MOVES_PAY_TITLE"))
			ChannelProxy:recordCustom("stat_buy_move_game_start")
		end
		local function fnBuyFailHandler()
			if not isNil(self.buyMoves) then
				self.buyMoves:setTouchEnabled(true)
			end
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 1)
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
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

