----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-04
-- Brief: 渠道接口定义
----------------------------------------------------------------------
ChannelProxy = {}
RT_SUCCESS = "1"			-- 回调:成功
RT_FAIL = "2"				-- 回调:失败
RT_CANCEL = "3"				-- 回调:取消
----------------------------------------------------------------------
-- 调用java静态方法
function ChannelProxy:callJavaStaticFunc(funcName, args, sig)
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		local ok, ret = require("cocos.cocos2d.luaj").callStaticMethod("org.cocos2dx.lua.AppActivity", funcName, args, sig)
		cclog("callJavaStaticFunc -> funcName: "..funcName..", ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- 调用oc静态方法
function ChannelProxy:callOCStaticFunc(funcName, args)
	if cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		local ok, ret = require("cocos.cocos2d.luaoc").callStaticMethod("AppController", funcName, args)
		cclog("callOCStaticFunc -> funcName: "..funcName..",ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- 获取Mac地址
function ChannelProxy:getMacAddr()
	local macAddress = "_"
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		macAddress, _ = self:callJavaStaticFunc("javaProxy", {101, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		macAddress, _ = self:callOCStaticFunc("ocProxy", {["type"] = 101})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
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
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		simState, _ = self:callJavaStaticFunc("javaProxy", {102, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		simState, _ = self:callOCStaticFunc("ocProxy", {["type"] = 102})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
	return simState
end
----------------------------------------------------------------------
-- 渠道id
function ChannelProxy:getChannelId()
	local channelId, defaultChannelId = "10001", "10001"
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		channelId, _ = self:callJavaStaticFunc("javaProxy", {103, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
		if nil == channelId or "" == channelId then
			channelId = "10001"
		end
		defaultChannelId = "10001"
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		channelId, _ = self:callOCStaticFunc("ocProxy", {["type"] = 103})
		if nil == channelId or "" == channelId then
			channelId = "20001"
		end
		defaultChannelId = "20001"
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
	return channelId, defaultChannelId
end
----------------------------------------------------------------------
-- 设备id
function ChannelProxy:getDeviceId()
	local deviceId = ""
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		deviceId, _ = self:callJavaStaticFunc("javaProxy", {104, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		deviceId, _ = self:callOCStaticFunc("ocProxy", {["type"] = 104})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
	return deviceId
end
----------------------------------------------------------------------
-- 获取运营商类型
function ChannelProxy:getOperatorType()
	local operatorType = ""
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		operatorType, _ = self:callJavaStaticFunc("javaProxy", {108, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
	return operatorType
end
----------------------------------------------------------------------
-- 获取音效开关
function ChannelProxy:isSoundOn()
	local soundOn = true
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		soundOn = self:callJavaStaticFunc("javaProxy", {109, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
	return soundOn
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
-- 登录
function ChannelProxy:login(successHandler)
	local function handler(result)
		cclog("login: "..result)
		if RT_SUCCESS == result then
			successHandler()
		elseif RT_FAIL == result then
		elseif RT_CANCEL == result then
		end
	end
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {202, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 202})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
	handler(RT_SUCCESS)
end
----------------------------------------------------------------------
--[[
["product_id"]		-- 订单id
["product_name"]	-- 产品名称
["product_desc"]	-- 订单描述
["total_fee"]		-- 订单金额
["pay_type"]		-- 支付类型:1.小额支付,2.大额支付
["order_id"]		-- 订单号
["tycode"]			-- 天翼支付码
["ltcode"]			-- 联通支付码
["ydcode"]			-- 移动支付码
["ascode"]			-- AppStore支付码
["gpcode"]			-- GooglePlay支付码
["ckcode"]			-- Cocos支付码
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
	dataTable["ckcode"]			= convertCode(dataTable["ckcode"])		-- Cocos支付码
	local function handler(result)
		cclog("buy little: "..result)
		if RT_SUCCESS == result or "success" == result then
			Utils:delayExecute(0, successHandler)
		elseif RT_FAIL == result or "fail" == result then
			Utils:delayExecute(0, failHandler)
		elseif RT_CANCEL == result or "cancel" == result then
			Utils:delayExecute(0, failHandler)
		end
		DataMap:saveDataBase()
	end
	-- 平台区分
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {204, json.encode(dataTable), handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		dataTable["type"] = 204
		dataTable["handler"] = handler
		self:callOCStaticFunc("ocProxy", dataTable)
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
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
	dataTable["ckcode"]			= convertCode(dataTable["ckcode"])		-- Cocos支付码
	local function handler(result)
		cclog("buy many: "..result)
		if RT_SUCCESS == result or "success" == result then
			Utils:delayExecute(0, successHandler)
		elseif RT_FAIL == result or "fail" == result then
			Utils:delayExecute(0, failHandler)
		elseif RT_CANCEL == result or "cancel" == result then
			Utils:delayExecute(0, failHandler)
		end
		DataMap:saveDataBase()
	end
	-- 平台区分
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {204, json.encode(dataTable), handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		dataTable["type"] = 204
		dataTable["handler"] = handler
		self:callOCStaticFunc("ocProxy", dataTable)
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
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
			if RT_SUCCESS == result or "success" == result then
				Utils:delayExecute(0, successHandler)
			elseif RT_FAIL == result or "fail" == result then
				Utils:delayExecute(0, failHandler)
			elseif RT_CANCEL == result or "cancel" == result then
				Utils:delayExecute(0, failHandler)
			end
			DataMap:saveDataBase()
		end
		-- 截图失败
        if not succeed then
			handler(RT_FAIL)
			return
		end
		-- 平台区分
		if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
			self:callJavaStaticFunc("javaProxy", {205, json.encode(dataTable), handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
		elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
			dataTable["type"] = 205
			dataTable["handler"] = handler
			self:callOCStaticFunc("ocProxy", dataTable)
		elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
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
		if RT_SUCCESS == result or "success" == result then
			Utils:delayExecute(0, successHandler)
		elseif RT_FAIL == result or "fail" == result then
			Utils:delayExecute(0, failHandler)
		elseif RT_CANCEL == result or "cancel" == result then
			Utils:delayExecute(0, failHandler)
		end
		DataMap:saveDataBase()
	end
	-- 平台区分
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {205, json.encode(dataTable), handler}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		dataTable["type"] = 205
		dataTable["handler"] = handler
		self:callOCStaticFunc("ocProxy", dataTable)
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 自定义事件
function ChannelProxy:recordCustom(event)
	local dataTable = {
		["tag"] = 1,					-- 标签
		["event"] = event				-- 事件
	}
    if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {206, json.encode(dataTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		dataTable["type"] = 206
		self:callOCStaticFunc("ocProxy", dataTable)
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 记录关卡状态信息
function ChannelProxy:recordValue(status)
	if 3 ~= G.CONFIG["update_type"] then	-- 非官网
		return
	end
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	else
		return
	end
	local copyInfo = Utils:collectCopyInfo(status)
	local xhr = cc.XMLHttpRequest:new()
	xhr:open("POST", "http://121.199.38.126:8080/txz/log/miaomiao.html")
	xhr:send("content="..(json.encode(copyInfo) or ""))
end
----------------------------------------------------------------------
-- 支付事件
function ChannelProxy:recordPay(totalFee, diamond, productName)
	local dataTable = {
		["tag"] = 3,				-- 标签
		["cash"] = totalFee,		-- 总支付金额
		["cash_type"] = "CNY",		-- 国际标准组织ISO4217中规范的货币代码,如:人民币CNY,美元USD等
		["item"] = productName,		-- 物品名称
		["amount"] = 1,				-- 数量
		["price"] = diamond,		-- 单个物品价格
		["source"] = 2				-- 支付入口
	}
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {206, json.encode(dataTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		dataTable["source"] = 1
		dataTable["type"] = 206
		self:callOCStaticFunc("ocProxy", dataTable)
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 关卡开始事件
function ChannelProxy:recordLevelStart(levelId)
	local dataTable = {
		["tag"] = 4,							-- 标签
		["level"] = "stat_level_"..levelId		-- 关卡
	}
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {206, json.encode(dataTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		dataTable["type"] = 206
		self:callOCStaticFunc("ocProxy", dataTable)
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 关卡成功事件
function ChannelProxy:recordLevelFinish(levelId)
	local dataTable = {
		["tag"] = 5,							-- 标签
		["level"] = "stat_level_"..levelId		-- 关卡
	}
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {206, json.encode(dataTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		dataTable["type"] = 206
		self:callOCStaticFunc("ocProxy", dataTable)
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 关卡失败事件
function ChannelProxy:recordLevelFail(levelId)
	local dataTable = {
		["tag"] = 6,							-- 标签
		["level"] = "stat_level_"..levelId		-- 关卡
	}
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {206, json.encode(dataTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		dataTable["type"] = 206
		self:callOCStaticFunc("ocProxy", dataTable)
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 打开更多
function ChannelProxy:openMore()
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {207, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 评价
function ChannelProxy:remark()
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {208, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 208})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 展示免责声明
function ChannelProxy:showAbout(text)
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {209, tostring(text), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 注册通知
function ChannelProxy:registNotify()
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {303, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 303})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 添加通知
function ChannelProxy:addNotify(notifyType, notifyKey, notifyMsg, notifyDelay)
	local dataTable = {
		["tag"] = notifyType,	-- 1.每天定时推送,2.延迟推送
		["key"] = notifyKey,
		["title"] = "",
		["msg"] = notifyMsg,
		["delay"] = notifyDelay,
		-- 即将废弃
		["notify_type"] = notifyType,
		["notify_key"] = notifyKey,
		["notify_msg"] = notifyMsg,
		["notify_delay"] = notifyDelay,
	}
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {304, json.encode(dataTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		dataTable["type"] = 304
		self:callOCStaticFunc("ocProxy", dataTable)
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 根据类型移除通知
function ChannelProxy:removeNotifyByType(notifyType)
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {305, tostring(notifyType), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 305, ["notify_type"] = notifyType})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 根据关键字移除通知
function ChannelProxy:removeNotifyByKey(notifyKey)
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {306, tostring(notifyKey), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 306, ["notify_key"] = notifyKey})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- 清除通知
function ChannelProxy:clearNotify()
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {307, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 307})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
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
-- 是否为触控渠道
function ChannelProxy:isCocos()
	if "10321" == self:getChannelId() then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- 是否为英文版
function ChannelProxy:isEnglish()
	local channelId = self:getChannelId()
	-- google play,Coda印度尼西亚,ios自有(英文)
	if "10271" == channelId or "10291" == channelId or "20002" == channelId then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- 是否为电信运营商
function ChannelProxy:isDianxin()
	local operatorType = self:getOperatorType()
	-- EGAME,EGAME Lite
	if "201" == operatorType or "202" == operatorType then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- 是否为联通运营商
function ChannelProxy:isLiantong()
	local operatorType = self:getOperatorType()
	-- UniPay web,UniPay sms,UniPay offline
	if "101" == operatorType or "102" == operatorType or "103" == operatorType then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- 是否为移动运营商
function ChannelProxy:isYidong()
	local operatorType = self:getOperatorType()
	-- 游戏基地,移动MM
	if "0" == operatorType or "1" == operatorType then
		return true
	end
	return false
end
----------------------------------------------------------------------
