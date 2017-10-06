----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-5
-- Brief: 关卡通过几关后，步数打折界面
----------------------------------------------------------------------
UIDEFINE("UIDiscountMoves", "DiscountMoves.csb")
function UIDiscountMoves:onStart(ui, param)
	AudioMgr:playEffect(2007)
	--self.discountMoveInfo = LogicTable:get("discount_moves_tplt", 1, true)
	
	--原价
	self.Text_origin_price = self:getChild("Text_origin_price")
	local oriPrice = ChannelPayCode:getBuyMovPrice()
	if ChannelProxy:isCocos() then
		self.Text_origin_price:setString(LanguageStr("DIS_DIA_ORI_MONEY")..ChannelPayCode:getFormatPrice(G.MOVES_ORI_PRICE))
	elseif "20002" == ChannelProxy:getChannelId() then
		self.Text_origin_price:setString(LanguageStr("DIS_DIA_ORI_MONEY")..ChannelPayCode:getFormatPrice(G.MOVES_ORI_PRICE_20002))
	else
		self.Text_origin_price:setString(LanguageStr("DIS_DIA_ORI_MONEY")..ChannelPayCode:getFormatPrice(oriPrice))
	end
	--cclog(tonumber(discountMoveInfo.price),discountMoveInfo.discount)
	local nowPrice = ChannelPayCode:getBuyDisMovPrice()
	--现价
	self.Text_nowPrice = self:getChild("Text_nowPrice")
	self.Text_nowPrice:setString(ChannelPayCode:getFormatPrice(nowPrice))
	self.Text_nowPrice:enableOutline(cc.c4b(99,47,12,255),3)
	--折扣图片
	self.dis_img = self:getChild("dis_img")
	self.dis_img:loadTexture(ChannelPayCode:getDisMovDiscountImg())
	--增加的步数		(现改为图片)
	--self.Text_addMoves = self:getChild("dis_img")
	--self.Text_addMoves:setString(self.discountMoveInfo.add_moves)
	
	--购买步数
	self.buyMoves = self:getChild("Button_buy")
	self:addTouchEvent(self.buyMoves, function(sender)
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
			["ckcode"]			= ChannelPayCode:getDisMovCkCode() or "0",		-- 触控支付码
		}
		local function fnBuySuccessHandler()
			if not isNil(self.buyMoves) then
				self.buyMoves:setTouchEnabled(true)
			end
			self:buyDisMoves()
			self:close()
			ChannelProxy:recordPay(ChannelPayCode:getBuyDisMovPrice(), "0", LanguageStr("BUY_DIS_MOVES_PAY_TITLE"))
			ChannelProxy:recordCustom("stat_buy_move_game_start")
		end
		local function fnBuyFailHandler()
			if not isNil(self.buyMoves) then
				self.buyMoves:setTouchEnabled(true)
			end
			ModelCopy:setBuyDiscountMovesCount(ModelCopy:getBuyDiscountMovesCount() + 1)
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 1)
	
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		ModelDisMoves:setFailTimes(0)
		self:close()
	end, true, true, 0)
	
end

--抢购购买步数
function UIDiscountMoves:buyDisMoves()
	local oriMoves = ModelCopy:getMoves()
	local nowMoves = oriMoves + 5
	ModelCopy:setMoves(nowMoves + 1)
	UIGameGoal:updateLeftMoves()
	ModelDisMoves:setFailTimes(0)
end

function UIDiscountMoves:onTouch(touch, event, eventCode)
end

function UIDiscountMoves:onUpdate(dt)
end

function UIDiscountMoves:onDestroy()
end

