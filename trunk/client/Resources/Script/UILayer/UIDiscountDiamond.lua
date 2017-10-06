----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-05
-- Brief: 通过多少关后，显示砖石打折界面
----------------------------------------------------------------------
UIDEFINE("UIDiscountDiamond", "DiscountDiamonds.csb")
--更新界面UI
function UIDiscountDiamond:updateUI()
	if nil == self.Text_leftTime then
		return
	end
	self.Text_leftTime:setString(Utils:secToString(tonumber(ModelDiscount:getActivityLeftTime())))
	self.Text_number:setString(self.disDiaInfo.diamonds_number.." "..LanguageStr("DIS_DIA_2"))
	self.Text_nowPrice:setString(ChannelPayCode:getFormatPrice(self.disDiaInfo.dis_price))
	self.icon:loadTexture(self.disDiaInfo.dis_icon)
	self.Text_origin_price:setString(LanguageStr("DIS_DIA_ORI_MONEY")..ChannelPayCode:getFormatPrice(self.disDiaInfo.price))
end

function UIDiscountDiamond:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self.disDiaInfo = DataMap:getDisDiamondInfo()[1].dis_dia_info
	--描述
	self.dis_des = self:getChild("Text_des_l")
	self.dis_des:setString(LanguageStr("DIS_DES_1"))
	--活动剩余时间
	self.Text_leftTime = self:getChild("Text_leftTime")
	self.Text_leftTime:enableOutline(cc.c4b(100,47,13,255),3)
	--砖石的个数
	self.Text_number = self:getChild("Text_number")
	--打折后的价钱
	self.Text_nowPrice = self:getChild("Text_nowPrice")
	self.Text_nowPrice:enableOutline(cc.c4b(99,46,12,255),3)
	--打折图片
	self.icon = self:getChild("Image_dis")
	--原价
	self.Text_origin_price = self:getChild("Text_origin_price")
	
	if "20002" == ChannelProxy:getChannelId() then --ios 的 google 不显示原价
		self.Text_origin_price:setVisible(false)
		self.price_bg = self:getChild("Image_57_Copy_0")
		self.price_bg:setPosition(cc.p(156.5,114))
	end
	
	self:updateUI()
	-- 抢购按钮
	self.btnBuy = self:getChild("Button_buy")
	local codeInfo = {}
	if 0 ~= self.disDiaInfo.code then
		codeInfo = LogicTable:get("code_tplt", self.disDiaInfo.code, true)
	end
	self:addTouchEvent(self.btnBuy, function(sender)
		self.btnBuy:setTouchEnabled(false)
		self.Text_leftTime = nil
		local tbData = {
			["product_name"]	= LanguageStr("DISCOUNT_CIAMOND_TITLE"),		-- 产品名称
			["total_fee"]		= self.disDiaInfo.dis_price,					-- 订单金额
			["product_desc"]	= LanguageStr("DISCOUNT_CIAMOND_TITLE"),		-- 订单描述
			["product_id"]		= "discount_diamond_"..self.disDiaInfo.id,		-- 订单ID
			["tycode"]			= codeInfo.dx_code or "0",				-- 天翼支付码
			["ltcode"]			= codeInfo.lt_code or "0",				-- 联通支付码
			["ydcode"]			= ModelPub:changeYDCode(codeInfo.yd_code) or "0",				-- 移动支付码
			["ascode"]			= codeInfo.as_code or "0",				-- AppStore支付码
			["gpcode"]			= codeInfo.gp_code or "0",				-- GooglePlay支付码
			["ckcode"]			= codeInfo.ck_code or "0",				-- 触控支付码
		}
		local function fnBuySuccessHandler()
			if not isNil(self.btnBuy) then
				self.btnBuy:setTouchEnabled(true)
			end
			local lastNumber = ModelItem:getTotalDiamond()
			ModelItem:appendTotalDiamond(self.disDiaInfo.diamonds_number)
			
			local tb = {}
			tb.itemType = ItemType["dia"] 
			tb.oldAmount = lastNumber
			tb.newAmount = lastNumber + self.disDiaInfo.diamonds_number
			tb.flag = SignType["add"]
			EventCenter:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
		
			ChannelProxy:recordPay(tostring(self.disDiaInfo.dis_price), tostring(self.disDiaInfo.diamonds_number), LanguageStr("DISCOUNT_CIAMOND_TITLE"))
			ChannelProxy:recordCustom("stat_buy_discount_diamond_"..self.disDiaInfo.record_id)	-- 友盟统计
			if not tolua.isnull(self.btnBuy) then
				self:close()
			end
			UIMiddlePub:showDisDiaBtn()
		end
		local function fnBuyFailHandler()
			if not isNil(self.btnBuy) then
				self.btnBuy:setTouchEnabled(true)
			end
		end
		ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
	end, true, true, 1)
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		self.Text_leftTime = nil
		if nil ~= self.timer then
			self.timer:stop()
			self.timer = nil
		end
		self:close()
		UIMiddlePub:showDisDiaBtn()
	end, true, true, 0)
	
	local function timer1_CF1(tm, runCount)
		if self.Text_leftTime ~= nil then
			local tempTime = tonumber(ModelDiscount:getActivityLeftTime() - runCount)
			if tempTime <= 0 then
				tempTime = 0
			end
			local leftTime = Utils:secToString(tempTime)
			self.Text_leftTime:setString(leftTime)
		end
	end

	local function timer1_CF2(tm)
		self.timer = nil
		ModelDiscount:saveDisDiaData()
		self.disDiaInfo = DataMap:getDisDiamondInfo()[1].dis_dia_info
		UIDiscountDiamond:updateUI()
		
		self.timer = CreateTimer(1, ModelDiscount:getActivityLeftTime(), timer1_CF1, timer1_CF2)
		self.timer:start()	
	end
	self.timer = CreateTimer(1, ModelDiscount:getActivityLeftTime(), timer1_CF1, timer1_CF2)
	self.timer:start()	
end

function UIDiscountDiamond:onTouch(touch, event, eventCode)
end

function UIDiscountDiamond:onUpdate(dt)
end

function UIDiscountDiamond:onDestroy()
end

