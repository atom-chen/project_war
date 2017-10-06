----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-04
-- Brief: �����ӿڶ���
----------------------------------------------------------------------
ChannelProxy = {}
RT_SUCCESS = "1"			-- �ص�:�ɹ�
RT_FAIL = "2"				-- �ص�:ʧ��
RT_CANCEL = "3"				-- �ص�:ȡ��
----------------------------------------------------------------------
-- ����java��̬����
function ChannelProxy:callJavaStaticFunc(funcName, args, sig)
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		local ok, ret = require("cocos.cocos2d.luaj").callStaticMethod("org.cocos2dx.lua.AppActivity", funcName, args, sig)
		cclog("callJavaStaticFunc -> funcName: "..funcName..", ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- ����oc��̬����
function ChannelProxy:callOCStaticFunc(funcName, args)
	if cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		local ok, ret = require("cocos.cocos2d.luaoc").callStaticMethod("AppController", funcName, args)
		cclog("callOCStaticFunc -> funcName: "..funcName..",ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- ��ȡMac��ַ
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
-- ��ȡ��ǰ�ֻ�������
-- "SIM_NULL"		sim��������
-- "SIM_YD"			�ƶ�sim��
-- "SIM_LT"			��ͨsim��
-- "SIM_DX"			����sim��
-- "SIM_UNKNOWN"	�޷�ʶ���sim��
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
-- ����id
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
-- �豸id
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
-- ��ȡ��Ӫ������
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
-- ��ȡ��Ч����
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
-- ��ȡ������
function ChannelProxy:getOrderId()
	local sMac = self:getMacAddr()
	if "_" == sMac then
		sMac = tostring(math.random(99999999999))
	end
	return tostring(os.time())..string.gsub(sMac, ":", "")..tostring(math.random(999999999))
end
----------------------------------------------------------------------
-- ��¼
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
["product_id"]		-- ����id
["product_name"]	-- ��Ʒ����
["product_desc"]	-- ��������
["total_fee"]		-- �������
["pay_type"]		-- ֧������:1.С��֧��,2.���֧��
["order_id"]		-- ������
["tycode"]			-- ����֧����
["ltcode"]			-- ��֧ͨ����
["ydcode"]			-- �ƶ�֧����
["ascode"]			-- AppStore֧����
["gpcode"]			-- GooglePlay֧����
["ckcode"]			-- Cocos֧����
]]
local function convertCode(code)
	if "string" ~= type(code) or "nil" == code then
		return ""
	end
	return code
end
----------------------------------------------------------------------
-- ����С��
function ChannelProxy:buyLittle(dataTable, successHandler, failHandler)
	dataTable["pay_type"]		= 1										-- ֧������
	dataTable["order_id"]		= self:getOrderId()						-- ������
	dataTable["company"]		= LanguageStr("CHANNEL_COMPANY_NAME")	-- ��˾����
	dataTable["service_phone"]	= G.SERVER_PHONE						-- �ͷ�����
	dataTable["tycode"]			= convertCode(dataTable["tycode"])		-- ����֧����
	dataTable["ltcode"]			= convertCode(dataTable["ltcode"])		-- ��֧ͨ����
	dataTable["ydcode"]			= convertCode(dataTable["ydcode"])		-- �ƶ�֧����
	dataTable["ascode"]			= convertCode(dataTable["ascode"])		-- AppStore֧����
	dataTable["gpcode"]			= convertCode(dataTable["gpcode"])		-- GooglePlay֧����
	dataTable["ckcode"]			= convertCode(dataTable["ckcode"])		-- Cocos֧����
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
	-- ƽ̨����
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
-- ������
function ChannelProxy:buyMany(dataTable, successHandler, failHandler)
	dataTable["pay_type"]		= 2										-- ֧������
	dataTable["order_id"] 		= self:getOrderId()						-- ������
	dataTable["company"]		= LanguageStr("CHANNEL_COMPANY_NAME")	-- ��˾����
	dataTable["service_phone"]	= G.SERVER_PHONE						-- �ͷ�����
	dataTable["tycode"]			= convertCode(dataTable["tycode"])		-- ����֧����
	dataTable["ltcode"]			= convertCode(dataTable["ltcode"])		-- ��֧ͨ����
	dataTable["ydcode"]			= convertCode(dataTable["ydcode"])		-- �ƶ�֧����
	dataTable["ascode"]			= convertCode(dataTable["ascode"])		-- AppStore֧����
	dataTable["gpcode"]			= convertCode(dataTable["gpcode"])		-- GooglePlay֧����
	dataTable["ckcode"]			= convertCode(dataTable["ckcode"])		-- Cocos֧����
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
	-- ƽ̨����
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
-- ���ݷ����ҽ���
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
		-- ��ͼʧ��
        if not succeed then
			handler(RT_FAIL)
			return
		end
		-- ƽ̨����
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
-- ���ݷ���
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
	-- ƽ̨����
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
-- �Զ����¼�
function ChannelProxy:recordCustom(event)
	local dataTable = {
		["tag"] = 1,					-- ��ǩ
		["event"] = event				-- �¼�
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
-- ��¼�ؿ�״̬��Ϣ
function ChannelProxy:recordValue(status)
	if 3 ~= G.CONFIG["update_type"] then	-- �ǹ���
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
-- ֧���¼�
function ChannelProxy:recordPay(totalFee, diamond, productName)
	local dataTable = {
		["tag"] = 3,				-- ��ǩ
		["cash"] = totalFee,		-- ��֧�����
		["cash_type"] = "CNY",		-- ���ʱ�׼��֯ISO4217�й淶�Ļ��Ҵ���,��:�����CNY,��ԪUSD��
		["item"] = productName,		-- ��Ʒ����
		["amount"] = 1,				-- ����
		["price"] = diamond,		-- ������Ʒ�۸�
		["source"] = 2				-- ֧�����
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
-- �ؿ���ʼ�¼�
function ChannelProxy:recordLevelStart(levelId)
	local dataTable = {
		["tag"] = 4,							-- ��ǩ
		["level"] = "stat_level_"..levelId		-- �ؿ�
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
-- �ؿ��ɹ��¼�
function ChannelProxy:recordLevelFinish(levelId)
	local dataTable = {
		["tag"] = 5,							-- ��ǩ
		["level"] = "stat_level_"..levelId		-- �ؿ�
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
-- �ؿ�ʧ���¼�
function ChannelProxy:recordLevelFail(levelId)
	local dataTable = {
		["tag"] = 6,							-- ��ǩ
		["level"] = "stat_level_"..levelId		-- �ؿ�
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
-- �򿪸���
function ChannelProxy:openMore()
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {207, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- ����
function ChannelProxy:remark()
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {208, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 208})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- չʾ��������
function ChannelProxy:showAbout(text)
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {209, tostring(text), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- ע��֪ͨ
function ChannelProxy:registNotify()
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {303, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 303})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- ���֪ͨ
function ChannelProxy:addNotify(notifyType, notifyKey, notifyMsg, notifyDelay)
	local dataTable = {
		["tag"] = notifyType,	-- 1.ÿ�춨ʱ����,2.�ӳ�����
		["key"] = notifyKey,
		["title"] = "",
		["msg"] = notifyMsg,
		["delay"] = notifyDelay,
		-- ��������
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
-- ���������Ƴ�֪ͨ
function ChannelProxy:removeNotifyByType(notifyType)
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {305, tostring(notifyType), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 305, ["notify_type"] = notifyType})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- ���ݹؼ����Ƴ�֪ͨ
function ChannelProxy:removeNotifyByKey(notifyKey)
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {306, tostring(notifyKey), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 306, ["notify_key"] = notifyKey})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- ���֪ͨ
function ChannelProxy:clearNotify()
	if cc.PLATFORM_OS_ANDROID == G.PLATFORM then
		self:callJavaStaticFunc("javaProxy", {307, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATFORM or cc.PLATFORM_OS_IPAD == G.PLATFORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 307})
	elseif cc.PLATFORM_OS_WP8 == G.PLATFORM then
	end
end
----------------------------------------------------------------------
-- �Ƿ�Ϊ��������
function ChannelProxy:isFeixin()
	if "10261" == self:getChannelId() then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- �Ƿ�Ϊ��������
function ChannelProxy:isCocos()
	if "10321" == self:getChannelId() then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- �Ƿ�ΪӢ�İ�
function ChannelProxy:isEnglish()
	local channelId = self:getChannelId()
	-- google play,Codaӡ��������,ios����(Ӣ��)
	if "10271" == channelId or "10291" == channelId or "20002" == channelId then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- �Ƿ�Ϊ������Ӫ��
function ChannelProxy:isDianxin()
	local operatorType = self:getOperatorType()
	-- EGAME,EGAME Lite
	if "201" == operatorType or "202" == operatorType then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- �Ƿ�Ϊ��ͨ��Ӫ��
function ChannelProxy:isLiantong()
	local operatorType = self:getOperatorType()
	-- UniPay web,UniPay sms,UniPay offline
	if "101" == operatorType or "102" == operatorType or "103" == operatorType then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- �Ƿ�Ϊ�ƶ���Ӫ��
function ChannelProxy:isYidong()
	local operatorType = self:getOperatorType()
	-- ��Ϸ����,�ƶ�MM
	if "0" == operatorType or "1" == operatorType then
		return true
	end
	return false
end
----------------------------------------------------------------------
