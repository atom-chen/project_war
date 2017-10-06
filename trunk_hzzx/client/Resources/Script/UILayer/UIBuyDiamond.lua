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
	if nShareCount >= G.SHARE_SHOP_COUNT then
		UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
	else
		UIManager:seekNodeByName(ui.root, "Text_share_zuan"):setString("+" .. G.SHARE_SHOP_GIVE_DIAMOND)
	end
	
	--专用的加一百砖石
	self.buyDia_spe = UIManager:seekNodeByName(ui.root, "Button_buyDia_spe")
	Utils:addTouchEvent(self.buyDia_spe, function(sender)
		cclog("买一百砖石*****************")
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
	self.btnShare = UIManager:seekNodeByName(ui.root, "Button_share")
	Utils:addTouchEvent(self.btnShare, function(sender)
		local function shareHandler(sResult)
			if nil == sResult or "" == sResult or ChannelProxy.SHARE_SUCCESS == sResult then
				if nShareCount < G.SHARE_SHOP_COUNT then
					nShareCount = nShareCount + 1
					DataMap:setShopShareCount( nShareCount )
					ItemModel:appendTotalDiamond(G.SHARE_SHOP_GIVE_DIAMOND)
					
					local tb = {}
					tb.itemType = ItemType["dia"] 
					tb.oldAmount = ItemModel:getTotalDiamond() - G.SHARE_SHOP_GIVE_DIAMOND
					tb.newAmount = ItemModel:getTotalDiamond()
					tb.flag = SignType["add"]
					EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
					
					if not tolua.isnull(self.btnShare) then
						self:addDiamond( G.SHARE_SHOP_GIVE_DIAMOND )
						if nShareCount >= G.SHARE_SHOP_COUNT then
							UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
						end
					end
				end
				ChannelProxy:recordCustom("stat_shop_share_success")	-- 友盟统计
			end
		end
		ChannelProxy:shareEvent(Utils:getShareContent(), shareHandler)
		ChannelProxy:recordCustom("stat_shop_share")	-- 友盟统计
	end, true, true, 1)
	
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
	--if name == "middle" then	--由中间界面进入
		self.diamondNumber = self.diamondNumber + nAdd
		self.hasText:setString( self.diamondNumber )
	--end
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
		--icon:setName(string.format("icon_%d",ItemData.index))
		cellBg:addChild(icon)
		
		--数值panel
		numberBgPanel = ccui.Layout:create()
		numberBgPanel:setContentSize(cc.size(123,32))
		numberBgPanel:setBackGroundImageScale9Enabled(true)
		numberBgPanel:setBackGroundImage("public_2.png")
		numberBgPanel:setBackGroundImageCapInsets(cc.rect(13, 13,13, 13))
		numberBgPanel:setAnchorPoint(cc.p(0.5,0.5))
		numberBgPanel:setPosition(cc.p(202.39,79.9))
		--icon:setName(string.format("icon_%d",ItemData.index))
		cellBg:addChild(numberBgPanel)
		local numberText = ccui.Text:create(ItemData.diamonds, "", 20)
		numberText:setPosition(cc.p(70.51, 15.43))
		numberText:setColor(cc.c3b(72,58,58))
		--numberText:setName("heroInfo")
		numberText:setAnchorPoint(cc.p(0.5,0.5))
		numberBgPanel:addChild(numberText)
		local diamondIcon = ccui.ImageView:create()
		diamondIcon:loadTexture("diamond_01.png")	
		diamondIcon:setAnchorPoint(cc.p(0.5,0.5))
		diamondIcon:setPosition(cc.p(14.87,15.87))
		diamondIcon:setScale(0.65)
		--icon:setName(string.format("icon_%d",ItemData.index))
		numberBgPanel:addChild(diamondIcon)
		
		local descText = ccui.Text:create(ItemData.name, "", 20)
		descText:setPosition(cc.p(204.58, 20))
		descText:setColor(cc.c3b(72,58,58))
		--numberText:setName("heroInfo")
		descText:setTextAreaSize(cc.size(150,60))
		descText:setAnchorPoint(cc.p(0.5,0.5))
		descText:setContentSize(cc.size(150,60))
		descText:setTextHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
		descText:ignoreContentAdaptWithSize(false)
		cellBg:addChild(descText)
		
		self.buyBtn = ccui.Button:create()
		self.buyBtn:loadTextures("btn_1.png", "btn_1.png", "")
		self.buyBtn:setTitleText("￥"..ItemData.price)
		self.buyBtn:setTitleFontSize(25)
		self.buyBtn:setColor(cc.c3b(255,255,255))
		self.buyBtn:setPosition(cc.p(340.7, 51.54))
		self.buyBtn:setAnchorPoint(cc.p(0.5, 0.5))
		self.buyBtn:setScale9Enabled(true)
		self.buyBtn:setContentSize(cc.size(118,55))
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
				["ydcode"]			= ItemData.yd_code			-- 移动支付码
			}
			local function fnBuySuccessHandler(sResult)
				if not isNil(self.buyBtn) then
					self.buyBtn:setTouchEnabled(true)
				end
				if nil == sResult or "" == sResult or ChannelProxy.PAY_SUCCESS == sResult then
					local lastNumber = ItemModel:getTotalDiamond()
					ItemModel:appendTotalDiamond(ItemData.diamonds)
					
					local tb = {}
					tb.itemType = ItemType["dia"] 
					tb.oldAmount = lastNumber
					tb.newAmount = lastNumber + ItemData.diamonds
					tb.flag = SignType["add"]
					EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb)
					ChannelProxy:recordCustom("stat_buy_shop_"..index)
					ChannelProxy:recordPay(ItemData.price, ItemData.diamonds, ItemData.name)
					GetRewardModel:updateRewardInfo()
					if not tolua.isnull(self.buyBtn) then
						self:addDiamond( ItemData.diamonds )
					end
				end
			end
			local function fnBuyFailHandler()
				if not isNil(self.buyBtn) then
					self.buyBtn:setTouchEnabled(true)
				end
			end
			ChannelProxy:buyMany(tbData, fnBuySuccessHandler, fnBuyFailHandler, fnBuyFailHandler)
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
		--icon:setName(string.format("icon_%d",ItemData.index))
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
function UIBuyDiamond:getChannelCodeData(channelData,name,number)
	local data = {}									 --最终根据code和渠道显示的数据
	local stateStr = ""								 --相应的code
	local phoneSimState = ChannelProxy:getPhoneSimState()	--获得手机是什么卡
	--测试--phoneSimState = "SIM_LT" --"SIM_LT"	--"SIM_YD"	--"SIM_NULL"	--"SIM_UNKNOWN"
	if phoneSimState == "SIM_DX" then
		stateStr = "dx_code"
	elseif phoneSimState == "SIM_LT" then
		stateStr = "lt_code"
	elseif phoneSimState == "SIM_YD" then
		stateStr = "yd_code"
	elseif phoneSimState == "SIM_NULL" or phoneSimState == "SIM_UNKNOWN" then
	
	end
	for key,val in pairs(channelData) do
		for k,v in pairs(val) do
			if stateStr == k and tostring(0) ~= v then
				local ItemData = val
				ItemData.index = key
				local flag = true
				if name == "buy" then
					flag = self:isDiamondEnough(number,val.diamonds)
				end
				ItemData.isEnough = flag
				table.insert(data,ItemData)
			end
		end
	end
	
	if #data == 0 then
		data = channelData
	end
	return data
end


function UIBuyDiamond:setEnterMode(name,number)
	if name == "middle" then	--由中间界面进入
		self.hasText:setString(number)
		self.hasText_1:setString(LanguageStr("BUY_DIA_HAVE"))
	elseif name == "buy" then	--由需要购买界面进入
		self.hasText:setString(number)
		self.hasText_1:setString(LanguageStr("BUY_DIA_NEED"))
	end

	local channelData = self:getChannelData()		--渠道中的数据
	local data = self:getChannelCodeData(channelData,name,number)	
	--最终根据code和渠道显示的数据
	self:initScrollView(data)
end
