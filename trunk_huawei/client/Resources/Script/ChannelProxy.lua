----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-04
-- Brief: 渠道接口定义
----------------------------------------------------------------------
ChannelProxy = {
	mChannelId = "30001",		-- 第1位用来标识平台:1.android,2.ios,3.windows;第2-4位用来标识渠道;第5位用来标识渠道包数
	mDeviceId = "",				-- 设备id
	mProductTb = {},			-- 所有商品的信息
	SUCCESS = "1",				-- 回调:成功
	FAIL = "2",					-- 回调:失败
	CANCEL = "3",				-- 回调:取消
}
----------------------------------------------------------------------
-- 调用java静态方法
function ChannelProxy:callJavaStaticFunc(funcName, args, sig)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		cclog("callJavaStaticFunc -> funcName: "..funcName)
		local ok, ret = require("cocos.cocos2d.luaj").callStaticMethod("org.cocos2dx.lua.AppActivity", funcName, args, sig)
		cclog("ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- 调用oc静态方法
function ChannelProxy:callOCStaticFunc(funcName, args)
	if cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		cclog("callOCStaticFunc -> funcName: "..funcName)
		local ok, ret = require("cocos.cocos2d.luaoc").callStaticMethod("AppController", funcName, args)
		cclog("ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- 获取Mac地址
function ChannelProxy:getMacAddr()
	local macAddress = "_"
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		macAddress, _ = self:callJavaStaticFunc("javaProxy", {101, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		macAddress, _ = self:callOCStaticFunc("ocProxy", {["type"] = 101})
	end
	return macAddress
end
----------------------------------------------------------------------
-- 获取当前手机的类型
-- "SIM_NULL"		sim卡不可用
-- "SIM_YD"			移动sim卡
-- "SIM_LT"			联通sim卡
-- "SIM_DX"			电信sim卡
-- "SIM_UNKNOWN"	无法识别的sim卡
function ChannelProxy:getPhoneSimState()
	local simState = "SIM_NULL"
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		simState, _ = self:callJavaStaticFunc("javaProxy", {102, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		simState, _ = self:callOCStaticFunc("ocProxy", {["type"] = 102})
	end
	return simState
end
----------------------------------------------------------------------
-- 渠道id
function ChannelProxy:getChannelId()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self.mChannelId, _ = self:callJavaStaticFunc("javaProxy", {103, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self.mChannelId, _ = self:callOCStaticFunc("ocProxy", {["type"] = 103})
	end
	return self.mChannelId
end
----------------------------------------------------------------------
-- 设备id
function ChannelProxy:getDeviceId()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self.mDeviceId, _ = self:callJavaStaticFunc("javaProxy", {104, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self.mDeviceId, _ = self:callOCStaticFunc("ocProxy", {["type"] = 104})
	end
	return self.mDeviceId
end
----------------------------------------------------------------------
-- 获取订单号
function ChannelProxy:getOrderId()
	local sMac = self:getMacAddr()
	if "_" == sMac then
		sMac = tostring(math.random(99999999999))
	end
	return tostring(os.time())..string.gsub(sMac, ":", "")..tostring(math.random(999999999))
end
----------------------------------------------------------------------
-- 内容分享并且截屏
function ChannelProxy:shareEventAndCapture(successHandler, failHandler)
    local function captureScreenHandler(succeed, outputFile)
		local dataTable = {
			["share_channel"] = 1,
			["share_type"] = 1,
			["share_content"] = "",
			["share_url"] = "",
			["share_pic"] = outputFile,
		}
		local function handler(result)
			cclog("share event and capture: "..result)
			if self.SUCCESS == result then
				Utils:delayExecute(0, successHandler)
			elseif self.FAIL == result then
				Utils:delayExecute(0, failHandler)
			elseif self.CANCEL == result then
				Utils:delayExecute(0, failHandler)
			end
			DataMap:saveDataBase()
		end
		-- 截图失败
        if not succeed then
			handler(self.FAIL)
			return
		end
		-- 平台区分
		if cc.PLATFORM_OS_WINDOWS == G.PLATORM then
			handler(self.SUCCESS)
		elseif cc.PLATFORM_OS_ANDROID == G.PLATORM then
			self:callJavaStaticFunc("javaProxy", {201, json.encode(dataTable), handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
		elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
			dataTable["type"] = 201
			dataTable["handler"] = handler
			self:callOCStaticFunc("ocProxy", dataTable)
		end
    end
    cc.utils:captureScreen(captureScreenHandler, "share.jpg")
end
----------------------------------------------------------------------
-- 内容分享
function ChannelProxy:shareEvent(shareData, successHandler, failHandler)
	local dataTable = {
		["share_channel"] = 1,
		["share_type"] = 2,
		["share_content"] = shareData["share_content"],
		["share_url"] = shareData["share_url"],
		["share_pic"] = "",
	}
	local function handler(result)
		cclog("share event: "..result)
		if self.SUCCESS == result then
			Utils:delayExecute(0, successHandler)
		elseif self.FAIL == result then
			Utils:delayExecute(0, failHandler)
		elseif self.CANCEL == result then
			Utils:delayExecute(0, failHandler)
		end
		DataMap:saveDataBase()
	end
	-- 平台区分
	if cc.PLATFORM_OS_WINDOWS == G.PLATORM then
		handler(self.SUCCESS)
	elseif cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {201, json.encode(dataTable), handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		dataTable["type"] = 201
		dataTable["handler"] = handler
		self:callOCStaticFunc("ocProxy", dataTable)
	end
end
----------------------------------------------------------------------
--[[
["product_id"]		-- 订单id
["product_name"]	-- 产品名称
["product_desc"]	-- 订单描述
["total_fee"]		-- 订单金额
["pay_type"]		-- 支付类型:1.小额支付,2.大额支付
["pay_channel"]		-- 支付渠道:0.自动识别,1.电信,2.联通,3.移动,4.支付宝,5.微信,6.AppStore,7.GooglePlay,8.Coda
["order_id"]		-- 订单号
["tycode"]			-- 天翼支付码
["ltcode"]			-- 联通支付码
["ydcode"]			-- 移动支付码
["ascode"]			-- AppStore支付码
["gpcode"]			-- GooglePlay支付码
]]
local function convertCode(code)
	if "string" ~= type(code) or "nil" == code then
		return ""
	end
	return code
end
----------------------------------------------------------------------
-- 购买小额
function ChannelProxy:buyLittle(dataTable, successHandler, failHandler)
	dataTable["pay_type"]		= 1										-- 支付类型
	dataTable["order_id"]		= self:getOrderId()						-- 订单号
	dataTable["company"]		= LanguageStr("CHANNEL_COMPANY_NAME")	-- 公司名称
	dataTable["service_phone"]	= G.SERVER_PHONE						-- 客服热线
	dataTable["tycode"]			= convertCode(dataTable["tycode"])		-- 天翼支付码
	dataTable["ltcode"]			= convertCode(dataTable["ltcode"])		-- 联通支付码
	dataTable["ydcode"]			= convertCode(dataTable["ydcode"])		-- 移动支付码
	dataTable["ascode"]			= convertCode(dataTable["ascode"])		-- AppStore支付码
	dataTable["gpcode"]			= convertCode(dataTable["gpcode"])		-- GooglePlay支付码
	local function handler(result)
		cclog("buy little: "..result)
		if self.SUCCESS == result then
			Utils:delayExecute(0, successHandler)
		elseif self.FAIL == result then
			Utils:delayExecute(0, failHandler)
		elseif self.CANCEL == result then
			Utils:delayExecute(0, failHandler)
		end
		DataMap:saveDataBase()
	end
	-- 平台区分
	if cc.PLATFORM_OS_WINDOWS == G.PLATORM then
		handler(self.SUCCESS)
	elseif cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {202, json.encode(dataTable), handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		dataTable["type"] = 202
		dataTable["handler"] = handler
		self:callOCStaticFunc("ocProxy", dataTable)
	end
end
----------------------------------------------------------------------
-- 购买大额
function ChannelProxy:buyMany(dataTable, successHandler, failHandler)
	dataTable["pay_type"]		= 2										-- 支付类型
	dataTable["order_id"] 		= self:getOrderId()						-- 订单号
	dataTable["company"]		= LanguageStr("CHANNEL_COMPANY_NAME")	-- 公司名称
	dataTable["service_phone"]	= G.SERVER_PHONE						-- 客服热线
	dataTable["tycode"]			= convertCode(dataTable["tycode"])		-- 天翼支付码
	dataTable["ltcode"]			= convertCode(dataTable["ltcode"])		-- 联通支付码
	dataTable["ydcode"]			= convertCode(dataTable["ydcode"])		-- 移动支付码
	dataTable["ascode"]			= convertCode(dataTable["ascode"])		-- AppStore支付码
	dataTable["gpcode"]			= convertCode(dataTable["gpcode"])		-- GooglePlay支付码
	local function handler(result)
		cclog("buy many: "..result)
		if self.SUCCESS == result then
			Utils:delayExecute(0, successHandler)
		elseif self.FAIL == result then
			Utils:delayExecute(0, failHandler)
		elseif self.CANCEL == result then
			Utils:delayExecute(0, failHandler)
		end
		DataMap:saveDataBase()
	end
	-- 平台区分
	if cc.PLATFORM_OS_WINDOWS == G.PLATORM then
		handler(self.SUCCESS)
	elseif cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {202, json.encode(dataTable), handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		dataTable["type"] = 202
		dataTable["handler"] = handler
		self:callOCStaticFunc("ocProxy", dataTable)
	end
end
----------------------------------------------------------------------
-- 自定义事件
function ChannelProxy:recordCustom(event)
    if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {203, event, 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 203, ["event"] = event})
	end
end
----------------------------------------------------------------------
-- 自定义事件(带参数)
function ChannelProxy:recordValue(valueTable)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {208, json.encode(valueTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		valueTable["type"] = 208
		self:callOCStaticFunc("ocProxy", valueTable)
	end
end
----------------------------------------------------------------------
-- 支付事件
function ChannelProxy:recordPay(totalFee, diamond, productName)
	local dataTable = {
		["cash"] = totalFee,		-- 总支付金额
		["cash_type"] = "CNY",		-- 国际标准组织ISO4217中规范的货币代码,如:人民币CNY,美元USD等
		["item"] = productName,		-- 物品名称
		["amount"] = 1,				-- 数量
		["price"] = diamond,		-- 单个物品价格
		["source"] = 2				-- 支付入口
	}
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {204, json.encode(dataTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		dataTable["source"] = 1
		dataTable["type"] = 204
		self:callOCStaticFunc("ocProxy", dataTable)
	end
end
----------------------------------------------------------------------
-- 关卡开始事件
function ChannelProxy:recordLevelStart(levelId)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {205, "stat_level_"..levelId, 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 205, ["level"] = "stat_level_"..levelId})
	end
end
----------------------------------------------------------------------
-- 关卡成功事件
function ChannelProxy:recordLevelFinish(levelId)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {206, "stat_level_"..levelId, 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 206, ["level"] = "stat_level_"..levelId})
	end
end
----------------------------------------------------------------------
-- 关卡失败事件
function ChannelProxy:recordLevelFail(levelId)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {207, "stat_level_"..levelId, 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 207, ["level"] = "stat_level_"..levelId})
	end
end
----------------------------------------------------------------------
-- 打开更多
function ChannelProxy:openMore()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {303, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	end
end
----------------------------------------------------------------------
-- 注册通知
function ChannelProxy:registNotify()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {304, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 304})
	end
end
----------------------------------------------------------------------
-- 添加通知
function ChannelProxy:addNotify(notifyType, notifyKey, notifyMsg, notifyDelay)
	local dataTable = {
		["notify_type"] = notifyType,	-- 1.每天定时推送,2.延迟推送
		["notify_key"] = notifyKey,
		["notify_msg"] = notifyMsg,
		["notify_delay"] = notifyDelay,
	}
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {305, json.encode(dataTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		dataTable["type"] = 305
		self:callOCStaticFunc("ocProxy", dataTable)
	end
end
----------------------------------------------------------------------
-- 根据类型移除通知
function ChannelProxy:removeNotifyByType(notifyType)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {306, tostring(notifyType), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 306, ["notify_type"] = notifyType})
	end
end
----------------------------------------------------------------------
-- 根据关键字移除通知
function ChannelProxy:removeNotifyByKey(notifyKey)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {307, tostring(notifyKey), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 307, ["notify_key"] = notifyKey})
	end
end
----------------------------------------------------------------------
-- 清除通知
function ChannelProxy:clearNotify()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {308, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 308})
	end
end
----------------------------------------------------------------------
-- 登录
function ChannelProxy:login(successHandler)
	local function handler(result)
		cclog("login: "..result)
		if self.SUCCESS == result then
			successHandler()
		elseif self.FAIL == result then
		elseif self.CANCEL == result then
		end
	end
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {310, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 310})
	end
	handler(self.SUCCESS)
end
----------------------------------------------------------------------
-- 评价
function ChannelProxy:remark()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {312, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 312})
	end
end
----------------------------------------------------------------------
-- 是否为飞信渠道
function ChannelProxy:isFeixin()
	if "10261" == self:getChannelId() then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- 是否为英文版
function ChannelProxy:isEnglish()
	local channelId = self:getChannelId()
	-- google play,Coda印度尼西亚,huawei
	if "10271" == channelId or "10291" == channelId or "10301" == channelId then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- 初始化商品列表信息
function ChannelProxy:initPaymentList(successHandler, failHandler)
	local function handler(productList)
		if "" == productList then
			Utils:delayExecute(0, failHandler)
			cclog("init payment list failed")
		else
			self.mProductTb = json.decode(productList) or {}
			--Log("init payment list success", self.mProductTb)
			Utils:delayExecute(0, successHandler)
		end
	end
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {106, "", handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
	end
end
-----------------------------------------------------------------
-- 根据类型，获得所有的信息(buy_moves,buy_power_finish,
--					discount_diamond_41,shop,discount_moves)
function ChannelProxy:getStrInfo(str, handler)
	local function getFilterInfos()
		local productTb = {}
		for key, infos in pairs(self.mProductTb) do
			local tempTb = {}
			if str == string.sub(key, 1, string.len(str)) then
				tempTb[key] = infos["price"]
				table.insert(productTb, tempTb)
			end
		end
		return productTb
	end
	if "table" == type(self.mProductTb) and #self.mProductTb > 0 then
		Utils:doCallback(handler, getFilterInfos())
		return
	end
	self:initPaymentList(function()
		Utils:doCallback(handler, getFilterInfos())
	end, function()
		Utils:doCallback(handler, {})
	end)
end
----------------------------------------------------------------------
-- 根据表和key，获得价格
function ChannelProxy:getPriceByDataKey(dataTb,keyStr)
	--Log("ChannelProxy:getPriceByDataKey**********",#dataTb,dataTb,keyStr,keyStr)
	for key,val in pairs(dataTb) do
		for k,v in pairs(val) do
			if keyStr == k then
				return v
				--return val.price
			end
		end 
	end
end
----------------------------------------------------------------------
-- 处理购买补单情况
function ChannelProxy:queryResupplyOrder()
	local function handler(orderInfo)
		if "" == orderInfo then
			return
		end
		orderInfo = json.decode(orderInfo) or {}
		local orderId			= orderInfo["order_id"]			-- "1435049317f6d010d348ea773577436"
		local price				= orderInfo["price"]			-- 5
		local payDescription	= orderInfo["pay_description"]	-- "商城购买750个钻石"
		local productName		= orderInfo["product_name"]		-- "购买750个钻石"
		local originalPrice		= orderInfo["original_price"]	-- 5
		local count				= orderInfo["count"]			-- 1
		local productId			= orderInfo["product_id"]		-- "shop_42"
		local description		= orderInfo["description"]		-- "商城购买750个钻石"
		local splitTb = CommonFunc:stringSplit(productId, "_", false)
		if "buy_power_finish" == productId then
			UIBuyPower:buyPowerSucHandler()
		elseif "shop" == splitTb[1] then
			local shopTb = UIBuyDiamond:getFinalShopData("buy",0)
			local shopInfo,index = UIBuyDiamond:getShopInfoById(shopTb,splitTb[2])
			UIBuyDiamond:buyDiaSucHandler(shopInfo.diamonds,index,shopInfo.price,shopInfo.name)
		elseif "discount" == splitTb[1] then
			local disInfo = LogicTable:get("discount_diamond_tplt", tonumber(splitTb[3]), true)
			UIDiscountDiamond:buyDisSucHandler(disInfo.diamonds_number, disInfo.dis_price, disInfo.record_id)
		end
		UIMiddlePub:setCollectNumber()
		DataMap:saveDataBase()
	end
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {107, "", handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
	end
end
----------------------------------------------------------------------