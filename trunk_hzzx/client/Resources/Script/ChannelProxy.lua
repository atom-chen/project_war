----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-04
-- Brief: �����ӿڶ���
----------------------------------------------------------------------
ChannelProxy = {
	mChannelId = "30001",		-- ��1λ������ʶƽ̨:1.android,2.ios,3.windows;��2-4λ������ʶ����;��5λ������ʶ��������
	mDeviceId = "",				-- �豸id
}
----------------------------------------------------------------------
-- ����java��̬����
function ChannelProxy:callJavaStaticFunc(funcName, args, sig)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		local ok, ret = require("cocos.cocos2d.luaj").callStaticMethod("org.cocos2dx.lua.AppActivity", funcName, args, sig)
		cclog("callJavaStaticFunc -> funcName: "..funcName..", ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- ����oc��̬����
function ChannelProxy:callOCStaticFunc(funcName, args)
	if cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		local ok, ret = require("cocos.cocos2d.luaoc").callStaticMethod("AppController", funcName, args)
		cclog("callOCStaticFunc -> funcName: "..funcName..", ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- ��ȡMac��ַ
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
-- ��ȡ��ǰ�ֻ�������
-- "SIM_NULL"		sim��������
-- "SIM_YD"			�ƶ�sim��
-- "SIM_LT"			��ͨsim��
-- "SIM_DX"			����sim��
-- "SIM_UNKNOWN"	�޷�ʶ���sim��
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
-- ����id
function ChannelProxy:getChannelId()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self.mChannelId, _ = self:callJavaStaticFunc("javaProxy", {103, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self.mChannelId, _ = self:callOCStaticFunc("ocProxy", {["type"] = 103})
	end
	return self.mChannelId
end
----------------------------------------------------------------------
-- �豸id
function ChannelProxy:getDeviceId()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self.mDeviceId, _ = self:callJavaStaticFunc("javaProxy", {104, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self.mDeviceId, _ = self:callOCStaticFunc("ocProxy", {["type"] = 104})
	end
	return self.mDeviceId
end
----------------------------------------------------------------------
-- ��ȡ������
function ChannelProxy:getOrderId()
	local macAddress = self:getMacAddr()
	if "_" == macAddress then
		macAddress = tostring(math.random(99999999999))
	end
	return tostring(os.time())..string.gsub(macAddress, ":", "")..tostring(math.random(999999999))
end
----------------------------------------------------------------------
-- ���ݷ����ҽ���
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
		-- ��ͼʧ��
        if not succeed then
			handler("fail")
			return
		end
		-- ƽ̨����
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
-- ���ݷ���
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
	-- ƽ̨����
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
	["product_name"]	= sProductName,		-- ��Ʒ����
	["total_fee"]		= fTotalFee,		-- �������
	["product_desc"]	= sDesc,			-- ��������
	["product_id"]		= sProductId,		-- ����ID
	["tycode"]			= sTYCode,			-- ����֧����
	["ltcode"]			= sLTCode,			-- ��֧ͨ����
	["ydcode"]			= sYDCode,			-- �ƶ�֧����
}]]
----------------------------------------------------------------------
-- ����С��
function ChannelProxy:buyLittle(dataTable, successHandler, failHandler)
	dataTable["order_id"]		= self:getOrderId()						-- ������
	dataTable["company"]		= LanguageStr("CHANNEL_COMPANY_NAME")	-- ��˾����
	dataTable["service_phone"]	= G.SERVER_PHONE						-- �ͷ�����
	dataTable["tycode"]			= dataTable["tycode"] or "0"			-- ����֧����
	dataTable["ltcode"]			= dataTable["ltcode"] or "0"			-- ��֧ͨ����
	dataTable["ydcode"]			= dataTable["ydcode"] or "0"			-- �ƶ�֧����
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
	if 1 == G.CONFIG["update_type"] then	-- ����
		handler("success")
		return
	end
	-- ƽ̨����
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
-- ������
function ChannelProxy:buyMany(dataTable, successHandler, failHandler)
	dataTable["order_id"] 		= self:getOrderId()						-- ������
	dataTable["company"]		= LanguageStr("CHANNEL_COMPANY_NAME")	-- ��˾����
	dataTable["service_phone"]	= G.SERVER_PHONE						-- �ͷ�����
	dataTable["tycode"]			= dataTable["tycode"] or "0"			-- ����֧����
	dataTable["ltcode"]			= dataTable["ltcode"] or "0"			-- ��֧ͨ����
	dataTable["ydcode"]			= dataTable["ydcode"] or "0"			-- �ƶ�֧����
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
	if 1 == G.CONFIG["update_type"] then	-- ����
		handler("success")
		return
	end
	-- ƽ̨����
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
-- �Զ����¼�
function ChannelProxy:recordCustom(event)
    if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {203, event, 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 203, ["event"] = event})
	end
end
----------------------------------------------------------------------
-- �Զ����¼�(������)
function ChannelProxy:recordValue(valueTable)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {208, json.encode(valueTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		valueTable["type"] = 208
		self:callOCStaticFunc("ocProxy", valueTable)
	end
end
----------------------------------------------------------------------
-- ֧���¼�
function ChannelProxy:recordPay(totalFee, diamond, productName)
	local dataTable = {
		["cash"] = totalFee,		-- ��֧�����
		["cash_type"] = "CNY",		-- ���ʱ�׼��֯ISO4217�й淶�Ļ��Ҵ���,��:�����CNY,��ԪUSD��
		["item"] = productName,		-- ��Ʒ����
		["amount"] = 1,				-- ����
		["price"] = diamond,		-- ������Ʒ�۸�
		["source"] = 2				-- ֧�����
	}
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {204, json.encode(dataTable), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		dataTable["type"] = 204
		self:callOCStaticFunc("ocProxy", dataTable)
	end
end
----------------------------------------------------------------------
-- �ؿ���ʼ�¼�
function ChannelProxy:recordLevelStart(levelId)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {205, "stat_level_"..levelId, 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 205, ["level"] = "stat_level_"..levelId})
	end
end
----------------------------------------------------------------------
-- �ؿ��ɹ��¼�
function ChannelProxy:recordLevelFinish(levelId)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {206, "stat_level_"..levelId, 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 206, ["level"] = "stat_level_"..levelId})
	end
end
----------------------------------------------------------------------
-- �ؿ�ʧ���¼�
function ChannelProxy:recordLevelFail(levelId)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {207, "stat_level_"..levelId, 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 207, "stat_level_"..levelId})
	end
end
----------------------------------------------------------------------
-- �򿪸���
function ChannelProxy:openMore()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {303, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 303})
	end
end
----------------------------------------------------------------------
-- ��¼
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