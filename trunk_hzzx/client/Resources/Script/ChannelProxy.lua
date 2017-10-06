----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-04
-- Brief: 渠道接口定义
----------------------------------------------------------------------
ChannelProxy = {
	mChannelId = "30001",		-- 第1位用来标识平台:1.android,2.ios,3.windows;第2-4位用来标识渠道;第5位用来标识渠道包数
	mDeviceId = "",				-- 设备id
}
----------------------------------------------------------------------
-- 调用java静态方法
function ChannelProxy:callJavaStaticFunc(funcName, args, sig)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		local ok, ret = require("cocos.cocos2d.luaj").callStaticMethod("org.cocos2dx.lua.AppActivity", funcName, args, sig)
		cclog("callJavaStaticFunc -> funcName: "..funcName..", ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- 调用oc静态方法
function ChannelProxy:callOCStaticFunc(funcName, args)
	if cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		local ok, ret = require("cocos.cocos2d.luaoc").callStaticMethod("AppController", funcName, args)
		cclog("callOCStaticFunc -> funcName: "..funcName..", ok: "..tostring(ok)..", ret: "..tostring(ret))
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
	local macAddress = self:getMacAddr()
	if "_" == macAddress then
		macAddress = tostring(math.random(99999999999))
	end
	return tostring(os.time())..string.gsub(macAddress, ":", "")..tostring(math.random(999999999))
end
----------------------------------------------------------------------
-- 内容分享并且截屏
function ChannelProxy:shareEventAndCapture(successHandler, failHandler)
    local function captureScreenHandler(succeed, outputFile)
		local dataTable = {
			["share_type"] = 1,
			["share_content"] = "",
			["share_url"] = "",
			["share_pic"] = outputFile,
		}
		local function handler(result)
			cclog("share event and capture: "..result)
			if "success" == result then
				Utils:doCallback(successHandler)
			elseif "fail" == result then
				Utils:doCallback(failHandler)
			elseif "cancel" == result then
				Utils:doCallback(failHandler)
			end
			DataMap:saveDataBase()
		end
		-- 截图失败
        if not succeed then
			handler("fail")
			return
		end
		-- 平台区分
		if cc.PLATFORM_OS_WINDOWS == G.PLATORM then
			handler("success")
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
		["share_type"] = 2,
		["share_content"] = shareData["share_content"],
		["share_url"] = shareData["share_url"],
		["share_pic"] = "",
	}
	local function handler(result)
		cclog("share event: "..result)
		if "success" == result then
			Utils:doCallback(successHandler)
		elseif "fail" == result then
			Utils:doCallback(failHandler)
		elseif "cancel" == result then
			Utils:doCallback(failHandler)
		end
		DataMap:saveDataBase()
	end
	-- 平台区分
	if cc.PLATFORM_OS_WINDOWS == G.PLATORM then
		handler("success")
	elseif cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {201, json.encode(dataTable), handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		dataTable["type"] = 201
		dataTable["handler"] = handler
		self:callOCStaticFunc("ocProxy", dataTable)
	end
end
----------------------------------------------------------------------
--[[dataTable = {
	["product_name"]	= sProductName,		-- 产品名称
	["total_fee"]		= fTotalFee,		-- 订单金额
	["product_desc"]	= sDesc,			-- 订单描述
	["product_id"]		= sProductId,		-- 订单ID
	["tycode"]			= sTYCode,			-- 天翼支付码
	["ltcode"]			= sLTCode,			-- 联通支付码
	["ydcode"]			= sYDCode,			-- 移动支付码
}]]
----------------------------------------------------------------------
-- 购买小额
function ChannelProxy:buyLittle(dataTable, successHandler, failHandler)
	dataTable["order_id"]		= self:getOrderId()						-- 订单号
	dataTable["company"]		= LanguageStr("CHANNEL_COMPANY_NAME")	-- 公司名称
	dataTable["service_phone"]	= G.SERVER_PHONE						-- 客服热线
	dataTable["tycode"]			= dataTable["tycode"] or "0"			-- 天翼支付码
	dataTable["ltcode"]			= dataTable["ltcode"] or "0"			-- 联通支付码
	dataTable["ydcode"]			= dataTable["ydcode"] or "0"			-- 移动支付码
	dataTable["pay_type"]		= 1
	local function handler(result)
		cclog("buy little: "..result)
		if "success" == result then
			Utils:doCallback(successHandler)
		elseif "fail" == result then
			Utils:doCallback(failHandler)
		elseif "cancel" == result then
			Utils:doCallback(failHandler)
		end
		DataMap:saveDataBase()
	end
	if 1 == G.CONFIG["update_type"] then	-- 内网
		handler("success")
		return
	end
	-- 平台区分
	if cc.PLATFORM_OS_WINDOWS == G.PLATORM then
		handler("success")
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
	dataTable["order_id"] 		= self:getOrderId()						-- 订单号
	dataTable["company"]		= LanguageStr("CHANNEL_COMPANY_NAME")	-- 公司名称
	dataTable["service_phone"]	= G.SERVER_PHONE						-- 客服热线
	dataTable["tycode"]			= dataTable["tycode"] or "0"			-- 天翼支付码
	dataTable["ltcode"]			= dataTable["ltcode"] or "0"			-- 联通支付码
	dataTable["ydcode"]			= dataTable["ydcode"] or "0"			-- 移动支付码
	dataTable["pay_type"]		= 2
	local function handler(result)
		cclog("buy many: "..result)
		if "success" == result then
			Utils:doCallback(successHandler)
		elseif "fail" == result then
			Utils:doCallback(failHandler)
		elseif "cancel" == result then
			Utils:doCallback(failHandler)
		end
		DataMap:saveDataBase()
	end
	if 1 == G.CONFIG["update_type"] then	-- 内网
		handler("success")
		return
	end
	-- 平台区分
	if cc.PLATFORM_OS_WINDOWS == G.PLATORM then
		handler("success")
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
		self:callOCStaticFunc("ocProxy", {["type"] = 207, "stat_level_"..levelId})
	end
end
----------------------------------------------------------------------
-- 打开更多
function ChannelProxy:openMore()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {303, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 303})
	end
end
----------------------------------------------------------------------
-- 登录
function ChannelProxy:login(successHandler)
	local function handler(result)
		cclog("login: "..result)
		if "success" == result then
			successHandler()
		elseif "fail" == result then
		elseif "cancel" == result then
		end
	end
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {310, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 310})
	end
	handler("success")
end
----------------------------------------------------------------------