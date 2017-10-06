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
	if nil == self.Text_leftTime then
		return
	end
	self.Text_leftTime:setString(Utils:secToString(tonumber(DataLevelInfo:getActivityLeftTime())))
	self.Text_number:setString(self.disDiaInfo.diamonds_number.." "..LanguageStr("DIS_DIA_2"))
	
	local disTb = self.productTb
	--Log("过滤后的disTb信息******",disTb)
	local priceTag = ChannelProxy:getPriceByDataKey(disTb,"discount_diamond_"..self.disDiaInfo.id)
	self.Text_nowPrice:setString(priceTag)
	--self.Text_nowPrice:setString(ChannelPayCode:getMoneySign()..self.disDiaInfo.dis_price)
	self.icon:loadTexture(self.disDiaInfo.dis_icon)
	--self.Text_origin_price:setString(LanguageStr("DIS_DIA_ORI_MONEY")..ChannelPayCode:getMoneySign()..self.disDiaInfo.price)
end

-- 购买打折钻石成功回调
function UIDiscountDiamond:buyDisSucHandler(diamonds, price, recordId)
	ItemModel:appendTotalDiamond(diamonds)
	ChannelProxy:recordPay(tostring(price), tostring(diamonds), LanguageStr("DISCOUNT_CIAMOND_TITLE"))
	ChannelProxy:recordCustom("stat_buy_discount_diamond_"..recordId)	-- 友盟统计
end

function UIDiscountDiamond:onStart(ui, param)
	self.productTb = param.product_tb
	AudioMgr:playEffect(2007)
	self.disDiaInfo = DataMap:getDisDiamondInfo()[1].dis_dia_info
	--描述
	self.dis_des = UIManager:seekNodeByName(ui.root, "Text_des_l")
	self.dis_des:setString(LanguageStr("DIS_DES_1"))
	--活动剩余时间
	self.Text_leftTime = UIManager:seekNodeByName(ui.root, "Text_leftTime")
	self.Text_leftTime:enableOutline(cc.c4b(100,47,13,255),3)
	--砖石的个数
	self.Text_number = UIManager:seekNodeByName(ui.root, "Text_number")
	--打折后的价钱
	self.Text_nowPrice = UIManager:seekNodeByName(ui.root, "Text_nowPrice")
	self.Text_nowPrice:enableOutline(cc.c4b(99,46,12,255),3)
	--打折图片
	self.icon = UIManager:seekNodeByName(ui.root, "Image_dis")
	--原价
	--self.Text_origin_price = UIManager:seekNodeByName(ui.root, "Text_origin_price")
	
	self:updateUI()
	-- 抢购按钮
	self.btnBuy = UIManager:seekNodeByName(ui.root, "Button_buy")
	Utils:addTouchEvent(self.btnBuy, function(sender)
		self.btnBuy:setTouchEnabled(false)
		--self.Text_leftTime = nil
		self.timer:pause()
		local tbData = {
			["product_name"]	= LanguageStr("DISCOUNT_CIAMOND_TITLE"),		-- 产品名称
			["total_fee"]		= self.disDiaInfo.dis_price,					-- 订单金额
			["product_desc"]	= LanguageStr("DISCOUNT_CIAMOND_TITLE"),		-- 订单描述
			["product_id"]		= "discount_diamond_"..self.disDiaInfo.id,		-- 订单ID
			["tycode"]			= self.disDiaInfo.dx_code or "0",				-- 天翼支付码
			["ltcode"]			= self.disDiaInfo.lt_code or "0",				-- 联通支付码
			["ydcode"]			= self.disDiaInfo.yd_code or "0",				-- 移动支付码
			["ascode"]			= self.disDiaInfo.as_code or "0",				-- AppStore支付码
			["gpcode"]			= self.disDiaInfo.gp_code or "0",				-- GooglePlay支付码
		}
		local function fnBuySuccessHandler()
			if not isNil(self.btnBuy) then
				self.btnBuy:setTouchEnabled(true)
			end
			self.Text_leftTime = nil
			self:buyDisSucHandler(self.disDiaInfo.diamonds_number, self.disDiaInfo.dis_price, self.disDiaInfo.record_id)
			
			local lastNumber = ItemModel:getTotalDiamond()
			local tb = {}
			tb.itemType = ItemType["dia"] 
			tb.oldAmount = lastNumber
			tb.newAmount = lastNumber + self.disDiaInfo.diamonds_number
			tb.flag = SignType["add"]
			EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 

			if not tolua.isnull(self.btnBuy) then
				UIManager:close(self)
			end
			UIMiddlePub:showDisDiaBtn()
		end
		local function fnBuyFailHandler()
			if not isNil(self.btnBuy) then
				self.btnBuy:setTouchEnabled(true)
				print("我来恢复时间了***************")
				self.timer:resume()
			end
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 1)
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		self.Text_leftTime = nil
		if nil ~= self.timer then
			self.timer:stop()
			self.timer = nil
		end
		UIManager:close(self)
		UIMiddlePub:showDisDiaBtn()
	end, true, true, 0)
	
	local function timer1_CF1(tm, runCount)
		if self.Text_leftTime ~= nil then
			local tempTime = tonumber(DataLevelInfo:getActivityLeftTime() - runCount)
			if tempTime <= 0 then
				tempTime = 0
			end
			local leftTime = Utils:secToString(tempTime)
			self.Text_leftTime:setString(leftTime)
		end
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

