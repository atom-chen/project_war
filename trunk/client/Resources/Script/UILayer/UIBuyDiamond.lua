----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-2
-- Brief: 购买砖石界面
----------------------------------------------------------------------
UIDEFINE("UIBuyDiamond", "BuyDiamond.csb")
function UIBuyDiamond:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self.diamondNumber = param.diamondNumber
	self.hasText = self:getChild("Text_has")
	self.hasText_1 = self:getChild("Text_has_1")
	self.shopScrollView = self:getChild("ScrollView_shop")
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		if nil ~= UIMiddlePub:getCollectNumberDiamond() then
			UIMiddlePub:getCollectNumberDiamond():stopAllActions()
			UIMiddlePub:getCollectNumberDiamond():setString(ModelItem:getTotalDiamond())
		end
		self:close()
	end, true, true, 0)
	-- 判断是否要显示钻石的数量
	local nShareCount = DataMap:getShopShareCount()
	if ChannelProxy:isEnglish() then
		self:getChild("Image_share_zuan"):setVisible(false)
	else
		if nShareCount >= G.SHARE_SHOP_COUNT then
			self:getChild("Image_share_zuan"):setVisible(false)
		else
			self:getChild("Text_share_zuan"):setString("+" .. G.SHARE_SHOP_GIVE_DIAMOND)
		end
	end
	--专用的加一百砖石
	self.buyDia_spe = self:getChild("Button_buyDia_spe")
	self:addTouchEvent(self.buyDia_spe, function(sender)
		local lastNumber = ModelItem:getTotalDiamond()
		ModelItem:appendTotalDiamond(100)
		
		local tb = {}
		tb.itemType = ItemType["dia"] 
		tb.oldAmount = lastNumber
		tb.newAmount = lastNumber + 100
		tb.flag = SignType["add"]
		EventCenter:post(EventDef["ED_CHANGE_REWARD_DATA"],tb)
		ModelLottery:updateRewardInfo()
		self:addDiamond(100)
	end, true, true, 0)
	if G.CONFIG["debug"] then
		self.buyDia_spe:setVisible(true)
	else
		self.buyDia_spe:setVisible(false)
	end
	-- 分享按钮
	self.shareBtn = self:getChild("Button_share")
	self:addTouchEvent(self.shareBtn, function(sender)
		local shareData = Utils:getShareContent()
		local function shareHandler(sResult)
			if ChannelProxy:isEnglish() then
			else
				if nShareCount < G.SHARE_SHOP_COUNT then
					nShareCount = nShareCount + 1
					DataMap:setShopShareCount( nShareCount )
					ModelItem:appendTotalDiamond(G.SHARE_SHOP_GIVE_DIAMOND)
					local newNumber = ModelItem:getTotalDiamond()
					local tb = {}
					tb.itemType = ItemType["dia"] 
					tb.oldAmount = newNumber - G.SHARE_SHOP_GIVE_DIAMOND
					tb.newAmount = newNumber
					tb.flag = SignType["add"]
					EventCenter:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
					
					if not tolua.isnull(self.shareBtn) then
						self:addDiamond( G.SHARE_SHOP_GIVE_DIAMOND )
						if nShareCount >= G.SHARE_SHOP_COUNT then
							self:getChild("Image_share_zuan"):setVisible(false)
						end
					end
				end
			end
			ChannelProxy:recordCustom(shareData["ums_id"])
			ChannelProxy:recordCustom("stat_shop_share_success")	-- 友盟统计
		end
		ChannelProxy:shareEvent(shareData, shareHandler)
		ChannelProxy:recordCustom("stat_shop_share")				-- 友盟统计
	end, true, true, 1)
	local wxImage = self:getChild("Image_60")
	if ChannelProxy:isFeixin() then
		wxImage:setVisible(false)
	else
		wxImage:setVisible(true)
	end
	self:setEnterMode(param.enter_mode,param.diamondNumber)
end

function UIBuyDiamond:onTouch(touch, event, eventCode)
end

function UIBuyDiamond:onUpdate(dt)
end

function UIBuyDiamond:onDestroy()
end

-- 界面加钻石
function UIBuyDiamond:addDiamond( nAdd )
	self.diamondNumber = self.diamondNumber + nAdd
	self.hasText:setString( self.diamondNumber )
end

--加载scrollView
function UIBuyDiamond:initScrollView(data)
	--创建列表单元格
	local function createCell(cellBg, ItemData, index)
		cellBg = ccui.Layout:create()
		cellBg:setContentSize(cc.size(407,110))
		cellBg:setBackGroundImageScale9Enabled(true)
		cellBg:setBackGroundImage("public_4.png")
		cellBg:setBackGroundImageCapInsets(cc.rect(30, 30, 30, 30))
		--图片
		local icon = ccui.ImageView:create()
		icon:loadTexture(ItemData.image)	
		icon:setAnchorPoint(cc.p(0.5,0.5))
		icon:setPosition(cc.p(65.72,52.97))
		cellBg:addChild(icon)
		--数值panel
		numberBgPanel = ccui.Layout:create()
		numberBgPanel:setContentSize(cc.size(123,32))
		numberBgPanel:setBackGroundImageScale9Enabled(true)
		numberBgPanel:setBackGroundImage("public_2.png")
		numberBgPanel:setBackGroundImageCapInsets(cc.rect(13, 13,13, 13))
		numberBgPanel:setAnchorPoint(cc.p(0.5,0.5))
		numberBgPanel:setPosition(cc.p(202.39,79.9))
		cellBg:addChild(numberBgPanel)
		local numberText = ccui.Text:create(ItemData.diamonds, "", 20)
		numberText:setPosition(cc.p(70.51, 15.43))
		numberText:setColor(cc.c3b(86,35,8))
		numberText:setAnchorPoint(cc.p(0.5,0.5))
		numberBgPanel:addChild(numberText)
		local diamondIcon = ccui.ImageView:create()
		diamondIcon:loadTexture("diamond_01.png")	
		diamondIcon:setAnchorPoint(cc.p(0.5,0.5))
		diamondIcon:setPosition(cc.p(14.87,15.87))
		diamondIcon:setScale(0.65)
		numberBgPanel:addChild(diamondIcon)
		
		local descText = ccui.Text:create(ItemData.name, "", 20)
		if ChannelProxy:isEnglish() then
			descText:setPosition(cc.p(204.58, 35))
		else
			descText:setPosition(cc.p(204.58, 30))
		end
		descText:setColor(cc.c3b(86,35,8))
		descText:setTextAreaSize(cc.size(150,60))
		descText:setAnchorPoint(cc.p(0.5,0.5))
		descText:setContentSize(cc.size(150,60))
		descText:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		descText:ignoreContentAdaptWithSize(false)
		cellBg:addChild(descText)
		
		self.buyBtn = ccui.Button:create()
		self.buyBtn:loadTextures("btn_1.png", "btn_1.png", "")
		self.buyBtn:setTitleText(ChannelPayCode:getFormatPrice(ItemData.price))
		self.buyBtn:setTitleFontSize(25)
		self.buyBtn:setColor(cc.c3b(113,57,8))
		self.buyBtn:setPosition(cc.p(340.7, 51.54))
		self.buyBtn:setAnchorPoint(cc.p(0.5, 0.5))
		self.buyBtn:setScale9Enabled(true)
		self.buyBtn:setContentSize(cc.size(118,55))
		
		local codeInfo = {}
		if 0 ~= ItemData.code then
			codeInfo = LogicTable:get("code_tplt", ItemData.code, true)
		end
		self:addTouchEvent(self.buyBtn, function(sender)
			self.buyBtn:setTouchEnabled(false)
			local tbData = {
				["product_name"]	= ItemData.name,			-- 产品名称
				["total_fee"]		= ItemData.price,			-- 订单金额
				["product_desc"]	= ItemData.name,			-- 订单描述
				["diamond"]			= ItemData.diamonds,		-- 钻石数量
				["product_id"]		= "shop_" .. ItemData.id,	-- 订单ID
				["tycode"]			= codeInfo.dx_code or "0",	-- 天翼支付码
				["ltcode"]			= codeInfo.lt_code or "0",	-- 联通支付码
				["ydcode"]			= ModelPub:changeYDCode(codeInfo.yd_code) or "0",	-- 移动支付码
				["ascode"]			= codeInfo.as_code or "0",	-- AppStore支付码
				["gpcode"]			= codeInfo.gp_code or "0",	-- GooglePlay支付码
				["ckcode"]			= codeInfo.ck_code or "0",	-- 触控支付码
			}
			local function fnBuySuccessHandler()
				if not isNil(self.buyBtn) then
					self.buyBtn:setTouchEnabled(true)
				end
				ModelItem:appendTotalDiamond(ItemData.diamonds)
				local newNumber = ModelItem:getTotalDiamond()
				local tb = {}
				tb.itemType = ItemType["dia"] 
				tb.oldAmount = newNumber - ItemData.diamonds
				tb.newAmount = newNumber
				tb.flag = SignType["add"]
				EventCenter:post(EventDef["ED_CHANGE_REWARD_DATA"],tb)
				ChannelProxy:recordCustom("stat_buy_shop_"..index)
				ChannelProxy:recordPay(ItemData.price, ItemData.diamonds, ItemData.name)
				ModelLottery:updateRewardInfo()
				if not tolua.isnull(self.buyBtn) then
					self:addDiamond( ItemData.diamonds )
				end
			end
			local function fnBuyFailHandler()
				if not isNil(self.buyBtn) then
					self.buyBtn:setTouchEnabled(true)
				end
			end
			if 1 == tonumber(ItemData.pay_type) then
				ChannelProxy:buyLittle(tbData, fnBuySuccessHandler, fnBuyFailHandler)
			else	-- 2
				ChannelProxy:buyMany(tbData, fnBuySuccessHandler, fnBuyFailHandler)
			end
		end, true, true, 1)
		cellBg:addChild(self.buyBtn)
		--遮罩图片
		local shadeImg = ccui.ImageView:create()
		shadeImg:loadTexture("shade_diamond.png")	
		shadeImg:setAnchorPoint(cc.p(0.5,0.5))
		shadeImg:setPosition(cc.p(204,52))
		shadeImg:setScale9Enabled(true)
		shadeImg:setContentSize(cc.size(407,112))
		shadeImg:setCapInsets(cc.rect(20, 20, 1, 1))
		cellBg:addChild(shadeImg)
		if ItemData.isEnough == false then
			shadeImg:setVisible(true)
			shadeImg:setOpacity(180)
			self.buyBtn:setTouchEnabled(false)
		else
			shadeImg:setVisible(false)
			shadeImg:setOpacity(255)
			self.buyBtn:setTouchEnabled(true)
		end
		return cellBg
	end
	UIScrollViewEx.show(self.shopScrollView, data, createCell,"V", 407, 100, 2,1, 5, false, nil, true, true)
end

--判断砖石是否足够
function UIBuyDiamond:isDiamondEnough(number,buyNumber)
	if number > buyNumber then
		return false
	end
	return true
end

--获取渠道数据
function UIBuyDiamond:getChannelData()
	local allTb = LogicTable:getAll("shop_tplt")	 --表中所有的数据
	local channelTb = {}
	local channelId, defaultChannelId = ChannelProxy:getChannelId()
	for key, val in pairs(allTb) do
		if channelId == val.channel_id then
			table.insert(channelTb, val)
		end
	end
	if 0 == #channelTb then
		for key, val in pairs(allTb) do
			if defaultChannelId == val.channel_id then
				table.insert(channelTb, val)
			end
		end
	end
	return channelTb
end

--获取code过滤后的数据
function UIBuyDiamond:getChannelCodeData(channelDataTable, name, number)
	local dataTable = {}				-- 最终根据code和渠道显示的数据
	for index, channelData in pairs(channelDataTable) do
		channelData.index = index
		channelData.isEnough = true
		if "buy" == name then
			channelData.isEnough = self:isDiamondEnough(number, channelData.diamonds)
		end
		table.insert(dataTable, channelData)
	end
	return dataTable
end

function UIBuyDiamond:setEnterMode(name,number)
	if name == "middle" then	--由中间界面进入
		self.hasText:setString(number)
		self.hasText_1:setString(LanguageStr("BUY_DIA_HAVE"))
	elseif name == "buy" then	--由需要购买界面进入
		self.hasText:setString(number)
		self.hasText_1:setString(LanguageStr("BUY_DIA_NEED"))
	end
	local data = self:getChannelCodeData(self:getChannelData(), name, number)	
	--最终根据code和渠道显示的数据
	self:initScrollView(data)
end
