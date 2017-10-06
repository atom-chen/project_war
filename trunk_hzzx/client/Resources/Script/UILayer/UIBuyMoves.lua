
----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-19
-- Brief: 战斗结束购买步数界面
----------------------------------------------------------------------
UIBuyMoves = {
	csbFile = "BuyMoves.csb"
}

--进入战斗失败界面
function UIBuyMoves:enterFailUI()
	UIManager:close(self)
	UIMiddlePub:openUIFailed()
end

--够买步数
function UIBuyMoves:buyMoves(moves)
	CopyModel:setCurrMoves(moves + 1)
	UIGameGoal:updateLeftMoves()
	UIManager:close(self)
	AudioMgr:playMusic(1002)--主战音乐
end

--够买步数
function UIBuyMoves:handleBuy()
	self.btnBuyMovesBg:setTouchEnabled(false)
	local tbData = {
		["product_name"]		= LanguageStr("BUY_MOVES_PAY_TITLE"),	    -- 产品名称
		["total_fee"]			= ChannelPayCode:getBuyMovPrice(),			-- 订单金额
		["product_desc"]		= LanguageStr("BUY_MOVES_PAY_DESC"),	    -- 订单描述
		["product_id"]			= "buy_moves",							    -- 订单ID
		["tycode"]				= ChannelPayCode:getMovDxCode() or "0",		-- 天翼支付码
		["ltcode"]				= ChannelPayCode:getMovLtCode() or "0",		-- 联通支付码
		["ydcode"]				= ChannelPayCode:getMovYdCode() or "0",		-- 移动支付码
		--["ascode"]				= ChannelPayCode:getMovAsCode() or "0",		-- AppStore支付码
	}
	local function fnBuySuccessHandler()
		if not isNil(self.btnBuyMovesBg) then
			self.btnBuyMovesBg:setTouchEnabled(true)
		end
		self:buyMoves(5)
		ChannelProxy:recordPay(ChannelPayCode:getBuyMovPrice(), "0", LanguageStr("BUY_MOVES_PAY_TITLE"))
		ChannelProxy:recordCustom("stat_buy_move_game_over")	-- 友盟统计
	end
	local function fnBuyFailHandler()
		if not isNil(self.btnBuyMovesBg) then
			self.btnBuyMovesBg:setTouchEnabled(true)
		end
	end
	ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
end

function UIBuyMoves:onStart(ui, param)
	
	self.rootPanel = UIManager:seekNodeByName(ui.root, "Panel_1")
	Utils:addTouchEvent(self.rootPanel, function(sender)
		print("我尽力啊了*******************")
		self:handleBuy()
	end, true, true, 0)
	
	AudioMgr:playEffect(2007)
	--购买五步的价格
	self.buyPrice = UIManager:seekNodeByName(ui.root, "buy_price")
	self.buyPrice:setString(string.format(LanguageStr("DIS_MOVES_GET",ChannelPayCode:getBuyMovPrice())))

	--关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:autoChangePos(btnClose)
	Utils:addTouchEvent(btnClose, function(sender)
		UIBuyMoves:enterFailUI()
	end, true, true, 0)
	
	--购买步数按钮放大区域
	self.btnBuyMovesBg = UIManager:seekNodeByName(ui.root, "Button_buyMoves_bg")
	Utils:addTouchEvent(self.btnBuyMovesBg, function(sender)
		self:handleBuy()
	end, true, true, 1)
	
	--购买步数按钮
	self.btnBuyMoves = UIManager:seekNodeByName(ui.root, "Button_buyMoves")
	Utils:addTouchEvent(self.btnBuyMoves, function(sender)
		self:handleBuy()
	end, true, true, 1)
end

function UIBuyMoves:onTouch(touch, event, eventCode)
end

function UIBuyMoves:onUpdate(dt)
end

function UIBuyMoves:onDestroy()
	
end


