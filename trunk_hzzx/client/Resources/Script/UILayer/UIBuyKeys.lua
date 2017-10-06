
----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-4-22
-- Brief: 购买钥匙界面
----------------------------------------------------------------------
UIBuyKeys = {
	csbFile = "BuyKeys.csb"
}

--购买函数
function UIBuyKeys:handleBuy()
	self.btnBuyKeysBg:setTouchEnabled(false)
	local tbData = {
		["product_name"]		= LanguageStr("BUY_KEYS_TITLE"),	    -- 产品名称
		["total_fee"]			= G.BUY_KEYS_MONEY,						-- 订单金额
		["product_desc"]		= LanguageStr("BUY_KEYS_DESC"),	    	-- 订单描述
		["product_id"]			= "buy_keys",							-- 订单ID
		["tycode"]				= G.BUY_KEYS_PAY_TY_CODE or "0",		-- 天翼支付码
		["ltcode"]				= G.BUY_KEYS_PAY_LT_CODE or "0",		-- 联通支付码
		["ydcode"]				= G.BUY_KEYS_PAY_YD_CODE or "0",		-- 移动支付码
		["ascode"]				= "0",									-- AppStore支付码
	}
	local function fnBuySuccessHandler()
		if not isNil(self.btnBuyKeysBg) then
			self.btnBuyKeysBg:setTouchEnabled(true)
		end
		
		UIGetAward:refuseBuyKeysUI()
		UIManager:close(self)
		ChannelProxy:recordPay(G.BUY_KEYS_MONEY, "0", LanguageStr("BUY_KEYS_TITLE"))
		ChannelProxy:recordCustom("stat_buy_keys")	-- 友盟统计
	end
	local function fnBuyFailHandler()
		if not isNil(self.btnBuyKeysBg) then
			self.btnBuyKeysBg:setTouchEnabled(true)
		end
	end
	ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
end

function UIBuyKeys:onStart(ui, param)
	
	self.rootPanel = UIManager:seekNodeByName(ui.root, "Panel_1")
	Utils:addTouchEvent(self.rootPanel, function(sender)
		print("我尽力啊了*******************")
		self:handleBuy()
	end, true, true, 0)
	
	--购买五步的价格
	self.buyPrice = UIManager:seekNodeByName(ui.root, "buy_price")
	self.buyPrice:setString(string.format(LanguageStr("DIS_MOVES_GET",G.BUY_KEYS_MONEY)))
	
	--关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:autoChangePos(btnClose)
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	
	--购买钥匙按钮放大区域
	self.btnBuyKeysBg = UIManager:seekNodeByName(ui.root, "Button_buyKeys_bg")
	Utils:addTouchEvent(self.btnBuyKeysBg, function(sender)
		self:handleBuy()
	end, true, true, 1)
	
	--购买钥匙按钮
	self.btnBuyKeys = UIManager:seekNodeByName(ui.root, "Button_buyKeys")
	Utils:addTouchEvent(self.btnBuyKeys, function(sender)
		self:handleBuy()
	end, true, true, 1)
end

function UIBuyKeys:onTouch(touch, event, eventCode)
end

function UIBuyKeys:onUpdate(dt)
end

function UIBuyKeys:onDestroy()
	
end


