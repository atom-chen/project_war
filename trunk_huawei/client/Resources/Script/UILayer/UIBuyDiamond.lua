----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-2
-- Brief: 购买砖石界面
----------------------------------------------------------------------
UIBuyDiamond = {
	csbFile = "BuyDiamond.csb"
}

function UIBuyDiamond:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self.diamondNumber = param.diamondNumber
	self.hasText = UIManager:seekNodeByName(ui.root, "Text_has")
	self.hasText_1 = UIManager:seekNodeByName(ui.root, "Text_has_1")
	self.shopScrollView = UIManager:seekNodeByName(ui.root, "ScrollView_shop")
	self.productTb = param.product_tb
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		if nil ~= UIMiddlePub:getCollectNumberDiamond() then
			UIMiddlePub:getCollectNumberDiamond():stopAllActions()
			UIMiddlePub:getCollectNumberDiamond():setString(ItemModel:getTotalDiamond())
		end
		UIManager:close(self)
	end, true, true, 0)
	-- 判断是否要显示钻石的数量
	local nShareCount = DataMap:getShopShareCount()
	if ChannelProxy:isEnglish() then
		UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
	else
		if nShareCount >= G.SHARE_SHOP_COUNT then
			UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
		else
			UIManager:seekNodeByName(ui.root, "Text_share_zuan"):setString("+" .. G.SHARE_SHOP_GIVE_DIAMOND)
		end
	end
	--专用的加一百砖石
	self.buyDia_spe = UIManager:seekNodeByName(ui.root, "Button_buyDia_spe")
	Utils:addTouchEvent(self.buyDia_spe, function(sender)
		local lastNumber = ItemModel:getTotalDiamond()
		ItemModel:appendTotalDiamond(100)
		
		local tb = {}
		tb.itemType = ItemType["dia"] 
		tb.oldAmount = lastNumber
		tb.newAmount = lastNumber + 100
		tb.flag = SignType["add"]
		EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb)
		GetRewardModel:updateRewardInfo()
		self:addDiamond(100)
	end, true, true, 0)
	if G.CONFIG["debug"] then
		self.buyDia_spe:setVisible(true)
	else
		self.buyDia_spe:setVisible(false)
	end
	-- 分享按钮
	self.shareBtn = UIManager:seekNodeByName(ui.root, "Button_share")
	Utils:addTouchEvent(self.shareBtn, function(sender)
		local shareData = Utils:getShareContent()
		local function shareHandler(sResult)
			if ChannelProxy:isEnglish() then
			else
				if nShareCount < G.SHARE_SHOP_COUNT then
					nShareCount = nShareCount + 1
					DataMap:setShopShareCount( nShareCount )
					ItemModel:appendTotalDiamond(G.SHARE_SHOP_GIVE_DIAMOND)
					local nowNumber = ItemModel:getTotalDiamond()
					local tb = {}
					tb.itemType = ItemType["dia"] 
					tb.oldAmount = nowNumber - G.SHARE_SHOP_GIVE_DIAMOND
					tb.newAmount = nowNumber
					tb.flag = SignType["add"]
					EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
					
					if not tolua.isnull(self.shareBtn) then
						self:addDiamond( G.SHARE_SHOP_GIVE_DIAMOND )
						if nShareCount >= G.SHARE_SHOP_COUNT then
							UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
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
	local wxImage = UIManager:seekNodeByName(self.shareBtn, "Image_60")
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

-- 购买钻石成功回调
function UIBuyDiamond:buyDiaSucHandler(addDia,index,price,name)
	ItemModel:appendTotalDiamond(addDia)
	ChannelProxy:recordCustom("stat_buy_shop_"..index)
	ChannelProxy:recordPay(price, addDia, name)
	GetRewardModel:updateRewardInfo()
end

--加载scrollView
function UIBuyDiamond:initScrollView(data)
	local shopTb = self.productTb
	--Log("过滤后的shop信息******",shopTb)
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
		numberBgPanel:setPosition(cc.p(196.39,79.9))
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
			descText:setPosition(cc.p(198.58, 35))
		else
			descText:setPosition(cc.p(198.58, 30))
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
		--Log("nannan*********",shopTb,type(shopTb),#shopTb)
		local str = "shop_" .. ItemData.id
		local priceTag = ChannelProxy:getPriceByDataKey(shopTb,str)
		self.buyBtn:setTitleText(priceTag)
		--self.buyBtn:setTitleText(ChannelPayCode:getMoneySign()..ItemData.price)
		self.buyBtn:setTitleFontSize(22)
		self.buyBtn:setColor(cc.c3b(113,57,8))
		self.buyBtn:setPosition(cc.p(336.7, 51.54))
		self.buyBtn:setAnchorPoint(cc.p(0.5, 0.5))
		self.buyBtn:setScale9Enabled(true)
		self.buyBtn:setContentSize(cc.size(138,55))
		Utils:addTouchEvent(self.buyBtn, function(sender)
			self.buyBtn:setTouchEnabled(false)
			local tbData = {
				["product_name"]	= ItemData.name,			-- 产品名称
				["total_fee"]		= ItemData.price,			-- 订单金额
				["product_desc"]	= ItemData.name,			-- 订单描述
				["diamond"]			= ItemData.diamonds,		-- 钻石数量
				["product_id"]		= "shop_" .. ItemData.id,	-- 订单ID
				["tycode"]			= ItemData.dx_code,			-- 天翼支付码
				["ltcode"]			= ItemData.lt_code,			-- 联通支付码
				["ydcode"]			= ItemData.yd_code,			-- 移动支付码
				["ascode"]			= ItemData.as_code,			-- AppStore支付码
				["gpcode"]			= ItemData.gp_code,			-- GooglePlay支付码
			}
			local function fnBuySuccessHandler()
				if not isNil(self.buyBtn) then
					self.buyBtn:setTouchEnabled(true)
				end
				self:buyDiaSucHandler(ItemData.diamonds,index,ItemData.price,ItemData.name)
				local nowNumber = ItemModel:getTotalDiamond()
				local tb = {}
				tb.itemType = ItemType["dia"] 
				tb.oldAmount = nowNumber - ItemData.diamonds
				tb.newAmount = nowNumber
				tb.flag = SignType["add"]
				EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb)
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
	local shopData = LogicTable:getAll("shop_tplt")	 --表中所有的数据
	local channelData = {}							 --渠道中的数据
	local flag = false								 --表示表中是否存在该渠道id
	for key,val in pairs(shopData) do
		if val.channel_id == ChannelProxy:getChannelId() then
			flag = true
			table.insert(channelData,val)	
		end	
	end
	if flag == false then
		local needChannelId = ChannelPayCode:getDefaultChannelId()
		for key,val in pairs(shopData) do
			if val.channel_id == needChannelId then
				table.insert(channelData,val)	
			end
		end
	end
	self.channelData = channelData
	return channelData
end

--获取code过滤后的数据
function UIBuyDiamond:getChannelCodeData(channelDataTable, name, number)
	local dataTable = {}				-- 最终根据code和渠道显示的数据
	local simStateStr = ""
	local phoneSimState = ChannelProxy:getPhoneSimState()
	if "SIM_DX" == phoneSimState then
		simStateStr = "dx_code"
	elseif "SIM_LT" == phoneSimState then
		simStateStr = "lt_code"
	elseif "SIM_YD" == phoneSimState then
		simStateStr = "yd_code"
	else	-- "SIM_NULL","SIM_UNKNOWN"
		if cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
			simStateStr = "as_code"
		end
	end
	for index, channelData in pairs(channelDataTable) do
		for key, val in pairs(channelData) do
			if simStateStr == key and "" ~= val and "0" ~= val and "nil" ~= val then
				channelData.index = index
				channelData.isEnough = true
				if "buy" == name then
					channelData.isEnough = self:isDiamondEnough(number, channelData.diamonds)
				end
				table.insert(dataTable, channelData)
			end
		end
	end
	if 0 == #dataTable then
		return channelDataTable
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
	--最终根据code和渠道显示的数据
	local data = UIBuyDiamond:getFinalShopData(name,number)
	self:initScrollView(data)
end

--获得商城表内所有的数据
function UIBuyDiamond:getFinalShopData(name,number)
	local channelData = self:getChannelData()		--渠道中的数据
	local data = self:getChannelCodeData(channelData,name,number)	
	return data
end

--根据id，获得一整条具体的信息
function UIBuyDiamond:getShopInfoById(shopTb,id)
	for key,val in pairs(shopTb) do
		if tostring(id) == tostring(val.id) then
			return val,key
		end
	end
end