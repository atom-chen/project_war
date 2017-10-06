
----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-19
-- Brief: 战斗结束购买步数界面
----------------------------------------------------------------------
UIDEFINE("UIBuyMoves", "BuyMoves.csb")
--进入战斗失败界面
function UIBuyMoves:enterFailUI()
	if nil ~= self.timer then
		self.timer:stop()
		self.timer = nil
	end
	self.leftTime = nil
	self:close()
	ModelPub:openUIFailed()
end

--够买步数
function UIBuyMoves:buyMoves(moves)
	if nil ~= self.timer then
		self.timer:stop()
		self.timer = nil
	end
	self:setBuyMovesFlag(true)
	self.leftTime = nil
	ModelCopy:setMoves(moves + 1)
	UIGameGoal:updateLeftMoves()
	self:close()
	AudioMgr:playMusic(1002)--主战音乐
end

function UIBuyMoves:onStart(ui, param)
	AudioMgr:playEffect(2007)
	--购买五步的价格
	self.buyPrice = self:getChild("buy_price")
	self.buyPrice:setString(ChannelPayCode:getFormatPrice(string.format("%0.2f",ChannelPayCode:getBuyMovPrice())))

	
	--倒计时 
	--self.leftTime = self:getChild("Text_leftTime")
	--self.leftTime:enableOutline(cc.c4b(123,58,2,255),3)
	
	local temp = G.BUY_MOVES_TIME
	self.panel1 = self:getChild("Panel_1")
	self.leftTime = cc.LabelAtlas:_create("10", "font_12.png", 31, 39,  string.byte("0"))
	--self.leftTime:setVisible(false)
	self.leftTime:setPosition(cc.p(430,565))
	local function timer1_CF1(tm, runCount)
		tm:setParam("count_"..tm:getCurrentCount())
		if self.leftTime ~= nil then
			--self.leftTime:setString(G.BUY_MOVES_TIME - tm:getCurrentCount())
			self.leftTime:setString(G.BUY_MOVES_TIME - tm:getCurrentCount())
			--self.leftTime:setVisible(true)
			self.leftTime:setPosition(cc.p(445,565))
		end
	end
	
	self.panel1:addChild(self.leftTime)
	local function timer1_CF2(tm)
		UIBuyMoves:enterFailUI()
	end
	self.timer = CreateTimer(1, 10, timer1_CF1, timer1_CF2)
	self.timer:setParam(temp)
	self.timer:start()

	self.image_5 = self:getChild("Image_5")
	self.image_5:setRotationSkewY(180)
	
	--关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		UIBuyMoves:enterFailUI()
	end, true, true, 0)

	--购买步数按钮
	self.btnBuyMoves = self:getChild("Button_buyMoves")
	--Log(self.btnBuyMoves)
	--self.btnBuyMoves:getScale()
	self:addTouchEvent(self.btnBuyMoves, function(sender)
		self.btnBuyMoves:setTouchEnabled(false)
		self.timer:pause()
		local tbData = {
			["product_name"]		= LanguageStr("BUY_MOVES_PAY_TITLE"),	    -- 产品名称
			["total_fee"]			= ChannelPayCode:getBuyMovPrice(),			-- 订单金额
			["product_desc"]		= LanguageStr("BUY_MOVES_PAY_DESC"),	    -- 订单描述
			["product_id"]			= "buy_moves",							    -- 订单ID
			["tycode"]				= ChannelPayCode:getMovDxCode() or "0",		-- 天翼支付码
			["ltcode"]				= ChannelPayCode:getMovLtCode() or "0",		-- 联通支付码
			["ydcode"]				= ChannelPayCode:getMovYdCode() or "0",		-- 移动支付码
			["ascode"]				= ChannelPayCode:getMovAsCode() or "0",		-- AppStore支付码
			["gpcode"]				= ChannelPayCode:getMovGpCode() or "0",		-- GooglePlay支付码
			["ckcode"]				= ChannelPayCode:getMovCkCode() or "0",		-- 触控支付码
		}
		local function fnBuySuccessHandler()
			if not isNil(self.btnBuyMoves) then
				self.btnBuyMoves:setTouchEnabled(true)
		    end
			self:buyMoves(5)
			ModelCopy:setBuyMovesCount(ModelCopy:getBuyMovesCount() + 1)
			ChannelProxy:recordPay(ChannelPayCode:getBuyMovPrice(), "0", LanguageStr("BUY_MOVES_PAY_TITLE"))
			ChannelProxy:recordCustom("stat_buy_move_game_over")	-- 友盟统计
		end
		local function fnBuyFailHandler()
			if not isNil(self.btnBuyMoves) then
				self.btnBuyMoves:setTouchEnabled(true)
			end
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 1)
	
	
end

--设置购买步数标志
function UIBuyMoves:setBuyMovesFlag(flag)
	self.buyFlag = flag or false
end

--获得购买步数标志
function UIBuyMoves:getBuyMovesFlag()
	return self.buyFlag
end

function UIBuyMoves:onTouch(touch, event, eventCode)
end

function UIBuyMoves:onUpdate(dt)
end

function UIBuyMoves:onDestroy()
	self.leftTime = nil
end


