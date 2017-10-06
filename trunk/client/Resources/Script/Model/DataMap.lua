----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-01-05
-- Brief: 数据字典
----------------------------------------------------------------------
DataMap = {
	mDataBase = nil
}

-- 初始化
function DataMap:init()
	local writablePath = cc.FileUtils:getInstance():getWritablePath()
	local deviceId = ChannelProxy:getDeviceId()
	if "string" ~= type(deviceId) or 0 == string.len(deviceId) then
		deviceId = cc.Application:getInstance():getTargetPlatform()..cc.Device:getDPI()
	end
	cclog("device id: "..deviceId)
	local fileName = writablePath..deviceId..".dbs"
	local cryptoKey = md5_value(deviceId)
	-- 兼容老的数据库格式
	local oldDeviceId = cc.Application:getInstance():getTargetPlatform()..cc.Device:getDPI()
	local oldFileName = writablePath..oldDeviceId..".dbs"
	local oldCryptoKey = md5_value(oldFileName)
	if cc.FileUtils:getInstance():isFileExist(oldFileName) then
		deviceId = oldDeviceId
		fileName = oldFileName
		cryptoKey = oldCryptoKey
	end
	-- 创建数据库对象
	mDataBase = CreateDataBase(fileName, nil, nil, function(isEncrypt, str)
		local plaintext = rc4_crypto(str, cryptoKey)
		if nil == CommonFunc:deserialize(plaintext) then
			plaintext = rc4_crypto(str, md5_value(oldDeviceId))
		end
		return plaintext
	end)
	-- 兼容老的数据库格式
	local userList = mDataBase:get("user_list")
	if "table" == type(userList) then
		local userInfo = userList["default"]
		if "table" == type(userInfo) then
			for key, value in pairs(userInfo) do
				mDataBase:set(key, value)
			end
			mDataBase:set("cur_account", nil)
			mDataBase:set("user_list", nil)
			mDataBase:save()
		end
	end
end

-- 设置值
function DataMap:setValue(key, value)
	mDataBase:set(key, value)
end

-- 获取值
function DataMap:getValue(key)
	return mDataBase:get(key)
end

-- 保存数据库
function DataMap:saveDataBase()
	mDataBase:save()
	collectgarbage("collect")
end

-- 设置等级
function DataMap:setLevel(level)
	self:setValue("level", level)
end

-- 获取等级
function DataMap:getLevel()
	return self:getValue("level") or 1
end

-- 设置砖石
function DataMap:setDiamond(diamond)
	self:setValue("diamond", diamond)
end

-- 获取砖石
function DataMap:getDiamond()
	return self:getValue("diamond") or G.INIT_DIAMOND
end

-- 设置钥匙
function DataMap:setKey(key)
	self:setValue("key", key)
end

-- 获取钥匙
function DataMap:getKey()
	return self:getValue("key") or 0
end

-- 设置毛球
function DataMap:setBall(ball)
	self:setValue("ball", ball)
end

-- 获取毛球
function DataMap:getBall()
	return self:getValue("ball") or 0
end
-- 设置饼干
function DataMap:setCookie(cookie)
	self:setValue("cookie", cookie)
end

-- 获取饼干
function DataMap:getCookie()
	return self:getValue("cookie") or 0
end

-- 设置通关数
function DataMap:setPass(pass)
	self:setValue("pass", pass)
end
-- 获取通关数
function DataMap:getPass()
	return self:getValue("pass") or 0
end

-- 设置特殊关卡通关数
function DataMap:setSpePass(pass)
	self:setValue("spe_pass", pass)
end
-- 获取特殊关卡通关数
function DataMap:getSpePass()
	return self:getValue("spe_pass") or 0
end

-- 设置上次通关数
function DataMap:setLastPass(pass)
	self:setValue("last_pass", pass)
end

-- 获取上次通关数
function DataMap:getLastPass()
	return self:getValue("last_pass") or 0
end

-- 设置最大通关关卡
function DataMap:setMaxPass(pass)
	local curPass = self:getValue("maxPass") or 0
	if pass > curPass then
		self:setValue("maxPass", pass)
	end
end

-- 获取最大的通关次数
function DataMap:getMaxPass()
	return self:getValue("maxPass") or 0
end

-- 设置体力最大值
function DataMap:setMaxPower(power)
	self:setValue("max_power", power)
end

-- 获取体力最大值
function DataMap:getMaxPower()
	return self:getValue("max_power") or G.CUR_MAX_POWER
end

-- 设置体力
function DataMap:setPower(power)
	self:setValue("power", power)
end

-- 获取体力
function DataMap:getPower()
	return self:getValue("power") or G.CUR_MAX_POWER
end

--设置是否购买过增加最大体力（增加体力上限，只可购买一次）
function DataMap:setAddMaxPower(addMaxPower)
	self:setValue("add_max_power", addMaxPower)
end

--获取是否购买过增加最大体力
function DataMap:getAddMaxPower()
	return self:getValue("add_max_power") or false
end

--设置开始倒计时的日期
function DataMap:setDate(dates)
	self:setValue("date", dates)
end

--获取开始倒计时的日期
function DataMap:getDate()
	return self:getValue("date") or STime:getClientTime()							
end

--设置已经解锁的英雄的id
function DataMap:setHeroIds(idTb)
	self:setValue("hero_ids", idTb)
end

--获取已经解锁的英雄的id
function DataMap:getHeroIds()
	local tb = {}
	for key,val in pairs(G.HERO_ID_BORN) do
		table.insert(tb,val)
	end
	return self:getValue("hero_ids") or tb							
end

--设置当前关卡选择的英雄ids
function DataMap:setSelectedHeroIds(idTb)
	self:setValue("selected_hero_ids", idTb)
end

--获取当前关卡选择的英雄的id
function DataMap:getSelectedHeroIds()
	local tb = {}
	for key,val in pairs(G.HERO_ID_BORN) do
		local index = DataHeroInfo:getHeroIndex(val)
		tb[index] = val
	end
	return self:getValue("selected_hero_ids") or tb							
end

--设置是否走完四格漫画
function DataMap:setCompleteCG(str)
	self:setValue("complete_cg", str)
end

--获取是否走完四格漫画
function DataMap:getCompleteCG()
	return self:getValue("complete_cg") or false												
end

--设置通关的关卡中，必出的信息
--{["level_id"]= 5,["pond_id"]= 5,["award_pond_name"] = "award_2",["show_times"]=2,["award_id"] = 1001 }
function DataMap:setLevelOneInfo(tb)
	self:setValue("complete_level_one", tb)
end

--获取通关的关卡中，已经出现过只能出现一次的信息
function DataMap:getLevelOneInfo()
	--Log("DataMap:getLevelOneInfo**************",self:getValue("complete_level_one") or {})
	return self:getValue("complete_level_one") or {}												
end

--保存已经出现过的显示特价信息
function DataMap:getDisDiamondInfo()
	return self:getValue("dis_dia_info") or {}												
end

--设置已经出现过的显示特价信息tb ={ {["start_time"] = {},["end_time"],["dis_dia_info"] = {} }			}
function DataMap:setDisDiamondInfo(tb)
	self:setValue("dis_dia_info", tb)										
end

--保存已经解锁过的关卡id
function DataMap:setUnlockIdTb(tb)
	self:setValue("copy_unlock_ids", tb)										
end

--获得已经解锁过的关卡id
function DataMap:getUnlockIdTb()
	return self:getValue("copy_unlock_ids") or {}													
end

-- 获取商店分享的次数
function DataMap:getShopShareCount()
	return self:getValue("shop_share_count") or 0
end

-- 设置商店分享的次数
function DataMap:setShopShareCount(nCount)
	return self:setValue("shop_share_count", nCount)
end

-- 获取失败分享的次数
function DataMap:getFailShareCount()
	return self:getValue("fail_share_count") or 0
end

-- 设置失败分享的次数
function DataMap:setFailShareCount(nCount)
	return self:setValue("fail_share_count", nCount)
end

-- 获取成功分享的次数
function DataMap:getWinShareCount()
	return self:getValue("win_share_count") or 0
end

-- 设置成功分享的次数
function DataMap:setWinShareCount(nCount)
	return self:setValue("win_share_count", nCount)
end

-- 获取获得英雄分享的次数
function DataMap:geGetHeroShareCount()
	return self:getValue("gethero_share_count") or 0
end

-- 设置获得英雄分享的次数
function DataMap:setGetHeroShareCount(nCount)
	return self:setValue("gethero_share_count", nCount)
end

-- 获取获得大礼包分享的次数
function DataMap:geGetGiftShareCount()
	return self:getValue("getgift_share_count") or 0
end

-- 设置获得大礼包分享的次数
function DataMap:setGetGiftShareCount(nCount)
	return self:setValue("getgift_share_count", nCount)
end

-- 获取新手完成标识
function DataMap:isGuideComplete()
	return self:getValue("guide_complete") or false
end

-- 设置新手完成标识
function DataMap:setGuideComplete()
	self:setValue("guide_complete", true)
end

-- 获取是否换过英雄标识
function DataMap:getChangeHeroFlag()
	return self:getValue("change_hero") or false
end

-- 设置是否换过英雄标识
function DataMap:setChangeHeroFlag(bool)
	self:setValue("change_hero", bool)
end

-- 获取界面引导过的key值
function DataMap:getUIGuideInfo()
	return self:getValue("ui_guide") or {}
end

-- 设置界面引导过的key值
function DataMap:setUIGuideInfo(tb)
	self:setValue("ui_guide", tb)
end

-- 获取该关卡领过奖励的次数
function DataMap:getCopyAwardTimesInfo()
	return self:getValue("copy_award_times") or {}
end

-- 设置该关卡领过奖励的次数
function DataMap:setCopyAwardTimesInfo(tb)
	self:setValue("copy_award_times", tb)
end

-- 设置评分显示次数
function DataMap:setRemarkShowCount(count)
	self:setValue("remark_show_times", count or 0)
end

-- 获取评分显示次数
function DataMap:getRemarkShowCount()
	return self:getValue("remark_show_times") or 0
end

-- 设置关卡失败次数
function DataMap:setCopyFailCount(copyId, count)
	local copyFailList = self:getValue("copy_fail_list") or {}
	copyFailList[copyId] = count or 0
	self:setValue("copy_fail_list", copyFailList)
end

-- 获取关卡失败次数
function DataMap:getCopyFailCount(copyId)
	local copyFailList = self:getValue("copy_fail_list") or {}
	return copyFailList[copyId] or 0
end

-- 设置7日签到数据
function DataMap:setSignInData(dataTb)
	self:setValue("sign_in_data", dataTb or {})
end

-- 获取7日签到数据
function DataMap:getSignInData()
	local tb1 = {["year"] = 2015,["month"] = 7,["day"] = 28}
	local tb2 = {["year"] = 2015,["month"] = 7,["day"] = 29}
	local tb3 = {["year"] = 2015,["month"] = 7,["day"] = 30}
	local tb4 = {["year"] = 2015,["month"] = 7,["day"] = 31}
	local tb5 = {["year"] = 2015,["month"] = 8,["day"] = 1}
	local tb6 = {["year"] = 2015,["month"] = 8,["day"] = 2}
	local tb7 = {["year"] = 2015,["month"] = 8,["day"] = 3}
	--local tb = {tb4,tb5,tb6}
	--local tb = {tb1,tb2,tb3,tb4,tb5}
	--local tb = {tb1,tb2,tb3,tb4,tb5,tb6}
	local tb = {tb4,tb5,tb6}
	--return tb
	return self:getValue("sign_in_data") or {}
end

-- 设置今天有没有签到
function DataMap:setTodaySignFlag(flag)		
	self:setValue("today_sign_in_flag", flag or false)
end

-- 获取今天有没有签到
function DataMap:getTodaySignFlag()
	return self:getValue("today_sign_in_flag") or false
end
