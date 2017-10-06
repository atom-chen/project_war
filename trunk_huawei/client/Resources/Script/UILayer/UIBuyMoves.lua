
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
	if nil ~= self.timer then
		self.timer:stop()
		self.timer = nil
	end
	self.leftTime = nil
	UIManager:close(self)
	UIMiddlePub:openUIFailed()
end

--够买步数
function UIBuyMoves:buyMoves(moves)
	if nil ~= self.timer then
		self.timer:stop()
		self.timer = nil
	end
	self:setBuyMovesFlag(true)
	self.leftTime = nil
	CopyModel:setCurrMoves(moves + 1)
	UIGameGoal:updateLeftMoves()
	UIManager:close(self)
	AudioMgr:playMusic(1002)--主战音乐
end

function UIBuyMoves:onStart(ui, param)

	self.productTb = param.product_tb
	AudioMgr:playEffect(2007)
	--购买五步的价格
	self.buyPrice = UIManager:seekNodeByName(ui.root, "buy_price")
	
	local movesTb = self.productTb 
	Log("过滤后的movesTb信息******",movesTb)
	local priceTag = ChannelProxy:getPriceByDataKey(movesTb,"buy_moves")
	self.buyPrice:setString(priceTag)
	
	--self.buyPrice:setString(LanguageStr("BUY_MOVES_NEED")..ChannelPayCode:getMoneySign()..ChannelPayCode:getBuyMovPrice())
	--关卡名
	local name = UIManager:seekNodeByName(ui.root, "Text_name")
	name:setString(DataLevelInfo:getCopyInfo().name..LanguageStr("BUY_MOVES_1") )
	
	--结束战斗按钮
	local btnEnd = UIManager:seekNodeByName(ui.root, "Button_end")
	Utils:addTouchEvent(btnEnd, function(sender)
		UIBuyMoves:enterFailUI()
	end, true, true, 0)
	
	--倒计时 
	self.leftTime = UIManager:seekNodeByName(ui.root, "Text_leftTime")
	self.leftTime:enableOutline(cc.c4b(123,58,2,255),3)
	local temp = G.BUY_MOVES_TIME
	
	local function timer1_CF1(tm, runCount)
		tm:setParam("count_"..tm:getCurrentCount())
		if self.leftTime ~= nil then
			self.leftTime:setString(LanguageStr("BUY_MOVES_LEFTTIME")..G.BUY_MOVES_TIME - tm:getCurrentCount())
		end
	end

	local function timer1_CF2(tm)
		UIBuyMoves:enterFailUI()
	end
	self.timer = CreateTimer(1, 10, timer1_CF1, timer1_CF2)
	self.timer:setParam(temp)
	self.timer:start()

	--关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIBuyMoves:enterFailUI()
	end, true, true, 0)
	
	--分享按钮
	self.shareBtn = UIManager:seekNodeByName(ui.root, "Button_share")
	local nShareCount = DataMap:getFailShareCount()
	if ChannelProxy:isEnglish() then
		UIManager:seekNodeByName(ui.root, "Image_share_bushu"):setVisible(false)
	else
		if nShareCount >= G.SHARE_STEP_BACK_COUNT then
			self.shareBtn:setVisible(false)
			self.shareBtn:setTouchEnabled(false)
			local btnEnd = UIManager:seekNodeByName(ui.root, "Button_end")
			local bgImage = UIManager:seekNodeByName(ui.root, "Image_7")
			btnEnd:setPosition( cc.p(bgImage:getContentSize().width/2, btnEnd:getPositionY()) )
		else
			UIManager:seekNodeByName(ui.root, "Text_share_bushu"):setString("+" .. G.SHARE_FAIL_GET_STEP)
		end
	end
	
	Utils:addTouchEvent(self.shareBtn, function(sender)
		local shareData = Utils:getShareContent()
		local function shareHandler(sResult)
			if ChannelProxy:isEnglish() then
			else
				if nShareCount < G.SHARE_STEP_BACK_COUNT then
					nShareCount = nShareCount + 1
					DataMap:setFailShareCount(nShareCount)
					if nShareCount >= G.SHARE_STEP_BACK_COUNT and not tolua.isnull(self.shareBtn) then
						UIManager:seekNodeByName(ui.root, "Image_share_bushu"):setVisible(false)
					end
					-- 增加的步数G.SHARE_FAIL_GET_STEP
					self:buyMoves(G.SHARE_FAIL_GET_STEP)
				end
			end
			ChannelProxy:recordCustom(shareData["ums_id"])
			ChannelProxy:recordCustom("stat_buy_move_share_success")	-- 友盟统计
		end
		ChannelProxy:shareEvent(shareData, shareHandler)				-- 截图分享
		ChannelProxy:recordCustom("stat_buy_move_share")				-- 友盟统计
	end, true, true, 1)
	local wxImage = UIManager:seekNodeByName(self.shareBtn, "Image_92")
	if ChannelProxy:isFeixin() then
		wxImage:setVisible(false)
	else
		wxImage:setVisible(true)
	end
	
	--专用的购买步数
	self.btnBuyMoves_spe = UIManager:seekNodeByName(ui.root, "Button_buyMoves_spe")
	self.btnBuyMoves_spe:setVisible(G.CONFIG["debug"])
	Utils:addTouchEvent(self.btnBuyMoves_spe, function(sender)
		self:buyMoves(5)
	end, true, true, 0)
	
	--购买步数按钮
	self.btnBuyMoves = UIManager:seekNodeByName(ui.root, "Button_buyMoves")
	Utils:addTouchEvent(self.btnBuyMoves, function(sender)
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
		}
		local function fnBuySuccessHandler()
			if not isNil(self.btnBuyMoves) then
				self.btnBuyMoves:setTouchEnabled(true)
			end
			self:buyMoves(5)
			ChannelProxy:recordPay(ChannelPayCode:getBuyMovPrice(), "0", LanguageStr("BUY_MOVES_PAY_TITLE"))
			ChannelProxy:recordCustom("stat_buy_move_game_over")	-- 友盟统计
		end
		local function fnBuyFailHandler()
			if not isNil(self.btnBuyMoves) then
				self.btnBuyMoves:setTouchEnabled(true)
				self.timer:resume()
			end
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 1)
	
	--恢复倒计时测试
	local btnRecover = UIManager:seekNodeByName(ui.root, "Button_recover")
	btnRecover:setVisible(false)
	Utils:addTouchEvent(btnRecover, function(sender)
		--self.timer:resume()
	end, true, true, 0)
	
	--显示目标
	local goalPanel = UIManager:seekNodeByName(ui.root, "Panel_goal")
	local goals = CopyModel:getGoals()
	for i=1,3,1 do
		local back = UIManager:seekNodeByName(ui.root, "back_"..i)
		local icon = UIManager:seekNodeByName(ui.root, "icon_"..i)
		local amount = UIManager:seekNodeByName(ui.root, "amount_"..i)
		local full = UIManager:seekNodeByName(ui.root, "full_"..i) 
		if #goals >= i then
			back:setVisible(true)
			local goalId = goals[i].id
			local nowNumber = CopyModel:getRemainGoalCount(goalId)
			local iconStr = DataLevelInfo:getIconStrById(goalId)
			icon:loadTexture(iconStr)
			if nowNumber <= 0 then
				amount:setVisible(false)
				full:setVisible(true)
			else
				amount:setString(nowNumber)
				full:setVisible(false)
			end
		else
			back:setVisible(false)
		end
	end
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


