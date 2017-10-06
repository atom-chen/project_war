----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-04
-- Brief: �����ӿڶ���
----------------------------------------------------------------------
ChannelProxy = {
	mChannelId = "30001",		-- ��1λ������ʶƽ̨:1.android,2.ios,3.windows;��2-4λ������ʶ����;��5λ������ʶ��������
	mDeviceId = "",				-- �豸id
	mProductTb = {},			-- ������Ʒ����Ϣ
	SUCCESS = "1",				-- �ص�:�ɹ�
	FAIL = "2",					-- �ص�:ʧ��
	CANCEL = "3",				-- �ص�:ȡ��
}
----------------------------------------------------------------------
-- ����java��̬����
function ChannelProxy:callJavaStaticFunc(funcName, args, sig)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		cclog("callJavaStaticFunc -> funcName: "..funcName)
		local ok, ret = require("cocos.cocos2d.luaj").callStaticMethod("org.cocos2dx.lua.AppActivity", funcName, args, sig)
		cclog("ok: "..tostring(ok)..", ret: "..tostring(ret))
		return ret, ok
	end
end
----------------------------------------------------------------------
-- ����oc��̬����
function ChannelProxy:callOCStaticFunc(funcName, args)
	if cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		cclog("callOCStaticFunc -> funcName: "..funcName)
		local ok, ret = require("cocos.cocos2d.luaoc").callStaticMethod("AppController", funcName, args)
		cclog("ok: "..tostring(ok)..", ret: "..tostring(ret))
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
	local sMac = self:getMacAddr()
	if "_" == sMac then
		sMac = tostring(math.random(99999999999))
	end
	return tostring(os.time())..string.gsub(sMac, ":", "")..tostring(math.random(999999999))
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
			if self.SUCCESS == result then
				Utils:delayExecute(0, successHandler)
			elseif self.FAIL == result then
				Utils:delayExecute(0, failHandler)
			elseif self.CANCEL == result then
				Utils:delayExecute(0, failHandler)
			end
			DataMap:saveDataBase()
		end
		-- ��ͼʧ��
        if not succeed then
			handler(self.FAIL)
			return
		end
		-- ƽ̨����
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
		if self.SUCCESS == result then
			Utils:delayExecute(0, successHandler)
		elseif self.FAIL == result then
			Utils:delayExecute(0, failHandler)
		elseif self.CANCEL == result then
			Utils:delayExecute(0, failHandler)
		end
		DataMap:saveDataBase()
	end
	-- ƽ̨����
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
["product_id"]		-- ����id
["product_name"]	-- ��Ʒ����
["product_desc"]	-- ��������
["total_fee"]		-- �������
["pay_type"]		-- ֧������:1.С��֧��,2.���֧��
["pay_channel"]		-- ֧������:0.�Զ�ʶ��,1.����,2.��ͨ,3.�ƶ�,4.֧����,5.΢��,6.AppStore,7.GooglePlay,8.Coda
["order_id"]		-- ������
["tycode"]			-- ����֧����
["ltcode"]			-- ��֧ͨ����
["ydcode"]			-- �ƶ�֧����
["ascode"]			-- AppStore֧����
["gpcode"]			-- GooglePlay֧����
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
	-- ƽ̨����
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
	-- ƽ̨����
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
		dataTable["source"] = 1
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
		self:callOCStaticFunc("ocProxy", {["type"] = 207, ["level"] = "stat_level_"..levelId})
	end
end
----------------------------------------------------------------------
-- �򿪸���
function ChannelProxy:openMore()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {303, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	end
end
----------------------------------------------------------------------
-- ע��֪ͨ
function ChannelProxy:registNotify()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {304, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 304})
	end
end
----------------------------------------------------------------------
-- ���֪ͨ
function ChannelProxy:addNotify(notifyType, notifyKey, notifyMsg, notifyDelay)
	local dataTable = {
		["notify_type"] = notifyType,	-- 1.ÿ�춨ʱ����,2.�ӳ�����
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
-- ���������Ƴ�֪ͨ
function ChannelProxy:removeNotifyByType(notifyType)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {306, tostring(notifyType), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 306, ["notify_type"] = notifyType})
	end
end
----------------------------------------------------------------------
-- ���ݹؼ����Ƴ�֪ͨ
function ChannelProxy:removeNotifyByKey(notifyKey)
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {307, tostring(notifyKey), 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 307, ["notify_key"] = notifyKey})
	end
end
----------------------------------------------------------------------
-- ���֪ͨ
function ChannelProxy:clearNotify()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {308, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 308})
	end
end
----------------------------------------------------------------------
-- ��¼
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
-- ����
function ChannelProxy:remark()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM then
		self:callJavaStaticFunc("javaProxy", {312, "", 0}, "(ILjava/lang/String;I)Ljava/lang/String;")
	elseif cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
		self:callOCStaticFunc("ocProxy", {["type"] = 312})
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
-- �Ƿ�ΪӢ�İ�
function ChannelProxy:isEnglish()
	local channelId = self:getChannelId()
	-- google play,Codaӡ��������,huawei
	if "10271" == channelId or "10291" == channelId or "10301" == channelId then
		return true
	end
	return false
end
----------------------------------------------------------------------
-- ��ʼ����Ʒ�б���Ϣ
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
-- �������ͣ�������е���Ϣ(buy_moves,buy_power_finish,
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
-- ���ݱ��key����ü۸�
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
-- �����򲹵����
function ChannelProxy:queryResupplyOrder()
	local function handler(orderInfo)
		if "" == orderInfo then
			return
		end
		orderInfo = json.decode(orderInfo) or {}
		local orderId			= orderInfo["order_id"]			-- "1435049317f6d010d348ea773577436"
		local price				= orderInfo["price"]			-- 5
		local payDescription	= orderInfo["pay_description"]	-- "�̳ǹ���750����ʯ"
		local productName		= orderInfo["product_name"]		-- "����750����ʯ"
		local originalPrice		= orderInfo["original_price"]	-- 5
		local count				= orderInfo["count"]			-- 1
		local productId			= orderInfo["product_id"]		-- "shop_42"
		local description		= orderInfo["description"]		-- "�̳ǹ���750����ʯ"
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