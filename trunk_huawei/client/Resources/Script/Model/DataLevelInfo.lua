----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-1-16
-- Brief: 保存当前关卡的数据
----------------------------------------------------------------------
DataLevelInfo = {
	["getAwardTimes"] = 0,			-- 当前关卡抽奖的次数（统计的是翻页的1到9）
	["rewardClickTimes"] = 0,		-- 当前关卡抽奖的次数(从一递增)
	["failTimes"] = 0,				-- 记录当前关卡失败的次数
	["copyInfo"] = {},				-- 当前关卡的所有信息
	["OpenDisDiaFlag"] = false,		-- 是否打开砖石打折界面
	["dis_dia_info"] = {},			-- 该关卡打折的信息
	["MustShowHeroInfo"] = {}		-- 抽奖必现的英雄信息
}

local mMustShowHeroAwardIds = {5004,5001,5010,5013}--5002}	-- 抽奖必现的奖励id
local mMustShowHeroIds = {2101,1101,4101,5101}--1201}		-- 抽奖必现的英雄id
local mMustShowHeroLevels = {5,7,10,13}--22}			-- 抽奖必现的英雄等级

--获得副本信息
function DataLevelInfo:getCopyInfo()
	return self.copyInfo
end
---------------------------------------------抽奖相关---------------------------------------------------
--设置当前关卡的抽奖次数
function DataLevelInfo:setRewardClickTimes(times)
	self.rewardClickTimes = times
end

--获得当前关卡的抽奖次数
function DataLevelInfo:getRewardClickTimes()
	return self.rewardClickTimes
end

--判断随机数有没有出现够次数(奖池id，奖池项)
function DataLevelInfo:alreadyShowFullTimes(levelId,pondId,keyStr,times,finalId)
	local temp = GetRewardModel:getLevelTimesInfo()
	local flag = 0
	local leftTimes = 0 		--还需要的次数
	--Log(temp)
	local itemInfo = DataLevelInfo:getRewardIconInfo(finalId)
	if times == -1 and itemInfo.award_type == 2 then	
		--Log("保存的数据**************",temp)
		--为提前解锁必出英雄做的限制
		local strNow = string.sub(itemInfo.id,1,2)
		if DataLevelInfo:isSameClass(strNow) then
			return  true,flag,leftTimes
		end
		-- 英雄重复出现的限制
		for k,v in pairs (temp) do
			if v.award_id == finalId then
				return  true,flag,leftTimes		--表示有，次数已经够
			end
		end
	else 
		for k,v in pairs (temp) do
			if v.level_id == levelId and v.pond_id == pondId and
			v.award_pond_name == keyStr and v.show_times >= times then
				return  true,flag,leftTimes		--表示有，次数已经够了
			elseif v.level_id == levelId and v.pond_id == pondId and
			v.award_pond_name == keyStr and v.show_times < times then
				 flag = 1		--表示有，次数还没够
				 leftTimes = times - v.show_times
				 return false,flag,leftTimes
			end
		end
	end
	flag = 2				--表示没有，次数还不够
	leftTimes = times
	return false,flag,leftTimes
end

--根据奖励池中的奖励id，判断他的key值和抽取次数
function DataLevelInfo:getKeyByAwardInfo(awardPondInfo,id)
	for key,val in pairs(awardPondInfo) do
		if key ~= "id" and val[1] == id then
			return key,val[3]
		end
	end
end

--根据奖励池中的信息，获取随机到的id
function DataLevelInfo:getRandomOneId(awardPondInfo)
	local proTb = {}		--可能性
	for key,val in pairs(awardPondInfo) do
		local levelId = DataMap:getPass()
		if levelId == DataMap:getMaxPass() + 1 then
			levelId = DataMap:getMaxPass()
		end
		if key ~= "id" then
			if awardPondInfo[key][3] == -1 then
				local flag,cases,leftTimes = DataLevelInfo:alreadyShowFullTimes( levelId,awardPondInfo.id,key,awardPondInfo[key][3],awardPondInfo[key][1])
				--cclog("-1的************",awardPondInfo[key][1],flag,cases,leftTimes)
				if flag == false and cases == 2 and awardPondInfo[key][3] == -1 then	--必须出现的
					return awardPondInfo[key][1]
				end
			elseif awardPondInfo[key][3] >0 then		--有次数限制的
				local flag,cases,leftTimes = DataLevelInfo:alreadyShowFullTimes( levelId,awardPondInfo.id,key,awardPondInfo[key][3],awardPondInfo[key][1])
				if flag == false then
					for i =1,leftTimes,1 do
						table.insert(proTb,val)
					end
				end	
			elseif awardPondInfo[key][2] ~= 0 then		--权重不为0的
				table.insert(proTb,val)
			end	
		end
	end
	
	if #proTb == 1 and proTb[1][3] ~= 0 then
		Log("随机的数组***抽奖有误***************",awardPondInfo.id,proTb)
	end
	local pro = CreateProbability(proTb)
	return pro:getValue()
end

--判断解锁的有没有同类英雄
function DataLevelInfo:isSameClass(strNow)
	local unlockHeroIds = DataMap:getHeroIds()	--已经解锁的英雄id
	for	 key,val in pairs(unlockHeroIds) do
		local strOri = string.sub(val,1,2)
		if strNow == strOri then
			return	true
		end
	end
	return false
end

--根据抽取到的物品，判断该英雄有没有出现过，如果出现过了，就再抽一次
function DataLevelInfo:getOnlyOneReward()
	local finalId,awardPondId,awardPondInfo,itemInfo = DataLevelInfo:getGetAwardId()
	strNow = string.sub(itemInfo.id,1,2)
	local tb = {finalId,awardPondId,awardPondInfo,itemInfo}
	if itemInfo.award_type == 2 then
		local unlockHeroIds = DataMap:getHeroIds()	--已经解锁的英雄id
		if DataLevelInfo:isSameClass(strNow) == false then
			return tb
		else
			return self:getOnlyOneReward()
		end
	else
		return	tb
	end	
end

--判断前面必出的英雄有没有没出现的，如果有，就出现最前面必须出现的
function DataLevelInfo:getRewardMustShowHeroInfo(level)
	--解决没抽奖和退出问题，必抽的英雄没有出现
	for key,val in pairs(mMustShowHeroIds) do
		if level > mMustShowHeroLevels[key]  then
			strNow = string.sub(val,1,2)
			if 	DataLevelInfo:isSameClass(strNow) == false then
				finalId = mMustShowHeroAwardIds[key]
				awardPondId = mMustShowHeroLevels[key]
				awardPondInfo = self.MustShowHeroInfo[key]
				itemInfo = DataLevelInfo:getRewardIconInfo(finalId)
				return finalId,awardPondId,awardPondInfo,itemInfo
			end	
		end
	end
	return 0,0,{}
end

--抽取一个抽奖池中的元素id出来（奖励id，奖励池id，奖励池信息）
function DataLevelInfo:getGetAwardId()
	--根据关卡id，和抽奖次数，获得奖励池id
	local level = DataMap:getPass()
	if level == 0 then	--容错处理
		level = 1
	end
	if level == DataMap:getMaxPass() + 1 then		--失败后，还是上次最大关卡的奖励
		level = DataMap:getMaxPass()
	end
	
	local finalId,awardPondId,awardPondInfo,itemInfo =  DataLevelInfo:getRewardMustShowHeroInfo(level)
	if finalId == 0 then
		local awardBaseInfo = LogicTable:get("award_base_tplt", level, true)
		if self.rewardClickTimes < 6 then
			awardPondId = awardBaseInfo.pond_id_pub
		elseif self.rewardClickTimes < 10 and self.rewardClickTimes >= 6 then
			awardPondId = awardBaseInfo.pond_id_six
		elseif self.rewardClickTimes >= 10 then
			awardPondId = awardBaseInfo.pond_id_ten
		end
		--根据奖励池id，获得奖励池信息
		awardPondInfo = LogicTable:get("award_pond_tplt", awardPondId, true)
		finalId = DataLevelInfo:getRandomOneId(awardPondInfo)
		itemInfo = DataLevelInfo:getRewardIconInfo(finalId)
	end
	--cclog("最终的是*************",finalId,awardPondId)
	return finalId,awardPondId,awardPondInfo,itemInfo
end

--根据抽取到的物品，设置数据库
function DataLevelInfo:setOneTime(finalId,awardPondId,awardPondInfo,itemInfo)
	local keyStr,allTimes = DataLevelInfo:getKeyByAwardInfo(awardPondInfo,finalId)

	if itemInfo.award_type == 1 or itemInfo.award_type == 3 then 
		local types = UIMiddlePub:getItemTypeById(itemInfo.id)
		if types == ItemType["ball"]  then			-- 毛球 -- 毛球包			
			ItemModel:appendTotalBall(itemInfo.count)
		elseif  types == ItemType["cookie"] then		-- 饼干
			ItemModel:appendTotalCookie(itemInfo.count)
		elseif types == ItemType["dia"] then			-- 砖石 -- 砖石包
			ItemModel:appendTotalDiamond(itemInfo.count)		
		end
	elseif itemInfo.award_type == 2 then			--抽取到的是英雄需要特殊判断
		DataHeroInfo:setUnlockHeroTb(itemInfo.id)
		DataHeroInfo:setSelectHeroId(itemInfo.id,false)
		DataHeroInfo:getSelectHeroId()
	end
	
	if  allTimes ~= 0 then	--设置数据库(只能抽取几次的)
		local levelId = DataMap:getPass()
		if levelId == DataMap:getMaxPass() + 1 then		--失败后，还是上次最大关卡的奖励
			levelId = DataMap:getMaxPass()
		end
		local flag,cases,leftTimes = DataLevelInfo:alreadyShowFullTimes(levelId,awardPondId,keyStr,allTimes,finalId)
		local rewardData = GetRewardModel:getLevelTimesInfo()
		if flag == false and cases == 2 then
			local tb = {["level_id"]= levelId,["pond_id"]= awardPondId,["award_pond_name"] = keyStr,
				["show_times"]= 1,["award_id"] = finalId}
			table.insert(rewardData,tb)
			GetRewardModel:setLevelTimesInfo(rewardData)
			if (itemInfo.award_type == 2 or itemInfo.award_type == 3) and leftTimes == -1 then	--保存当前关卡必现一次的礼包
				local oneTb = DataMap:getLevelOneInfo()
				table.insert(oneTb,tb)
				DataMap:setLevelOneInfo(oneTb)	
				--Log("设置关卡的必出现一次****************",oneTb,rewardData)
			end
			return
		elseif flag == false and cases == 1 then
			for key,val in pairs(rewardData) do		
				--已经存在过的信息，直接修改
				if val.level_id == levelId and val.pond_id == awardPondId and
					val.award_pond_name == keyStr and val.show_times < allTimes then

					val.show_times = val.show_times + 1
					GetRewardModel:setLevelTimesInfo(rewardData)
					return
				end
			end
		end
	end
end

--根据奖励id，获得图片或plist文件名
function DataLevelInfo:getRewardIconInfo(rewardId)
	local itemInfo ={}
	local awardInfo = LogicTable:getAwardData(rewardId)	--奖励的信息
	if awardInfo.type == 1 then		-- 物品信息
		itemInfo = LogicTable:get("item_tplt", awardInfo.sub_id, true)
		itemInfo.count = awardInfo.count
		itemInfo.award_type = 1
	elseif awardInfo.type == 2 then	-- 英雄信息
		itemInfo = LogicTable:get("hero_tplt", awardInfo.sub_id, true)
		itemInfo.count = awardInfo.count
		itemInfo.award_type = 2
	elseif awardInfo.type == 3 then	-- 礼包信息(目前只有填一个数值是正确的)
		local giftInfo = LogicTable:get("gift_bag_tplt", awardInfo.sub_id, true)
		itemInfo = LogicTable:get("item_tplt",giftInfo.items[1][1], true)
		itemInfo.count = awardInfo.count * giftInfo.items[1][2]
		itemInfo.award_type = 3
	end
	return itemInfo
end
	
--设置当前关卡的抽奖次数
function DataLevelInfo:setGetAwardTimes(times)
	self.getAwardTimes = times
end

--获得当前关卡的抽奖次数
function DataLevelInfo:getGetAwardTimes()
	return self.getAwardTimes
end
------------------------------------------------------------------------------------------------
--判断体力是否足够
function  DataLevelInfo:canEnterCopy()
	if PowerManger:getCurPower() < CopyModel:getCostHp() then
		return false
	end
	return true
end

--设置该关出现失败的次数
function  DataLevelInfo:setFailTimes(times)
	self.failTimes = times
end

--获得该关出现失败的次数
function  DataLevelInfo:getFailTimes()
	return self.failTimes 
end

--判断上一次和这一次打的关卡是否相同
function  DataLevelInfo:isSameLevel()
	if DataMap:getPass() == DataMap:getLastPass() then
		DataLevelInfo:setFailTimes(self.failTimes + 1)
	else
		 DataLevelInfo:setFailTimes(1)
	end
end

--如果失败了三次打第四次的时候，弹出打折购买步数界面
function  DataLevelInfo:showDiscountMoves()
	if DataLevelInfo:getFailTimes() == G.DIS_MOVES_TIMES and tostring(ChannelPayCode:getBuyDisMovPrice()) ~= "0"then
		UIGameGoal:closeCenterPanel()
		ChannelProxy:getStrInfo("discount_moves", function(productTb)
			if 0 == #productTb then
				--UIPrompt:show("商品查询失败")
				DataLevelInfo:setFailTimes(0)
				--UIManager:close(self)
			else
				UIManager:openFront(UIDiscountMoves, true ,{["product_tb"]=productTb})
			end
		end)
		
	end
end

--根据元素的id，获得元素的图标
function DataLevelInfo:getIconStrById(iconId)
	local iconStr = ""
	if iconId == 0 then				--怪物
		iconStr = "small_monster.png"
	elseif iconId == 5006 then		--木箱
		iconStr = "crate_01.png"
	else
		local elementInfo = LogicTable:get("element_tplt", iconId, true)
		iconStr = elementInfo.normal_image
	end
	return iconStr
end

--初始化英雄必抽的信息
function DataLevelInfo:initMustShowHeroInfo()
	for key,val in pairs(mMustShowHeroAwardIds) do
		local awardInfo = LogicTable:get("award_pond_tplt", mMustShowHeroLevels[key], true)
		table.insert(self.MustShowHeroInfo,awardInfo)
	end
end

function DataLevelInfo:init()
	self.copyInfo = LogicTable:get("copy_tplt", DataMap:getPass(), false)
end
-------------------------------------副本解锁条件-------------------------------------------------------
--获得副本解锁的条件
function DataLevelInfo:getUnlockCopyInfo()
	local unlockInfo = self.copyInfo.unlocks[1]
	return unlockInfo
end

-- 判断要不要出现副本解锁界面
function DataLevelInfo:showCopyUnlockUI(unlockInfo,copyId)
	if unlockInfo[2] == 0 then
		return false
	end
	local tb = DataMap:getUnlockIdTb()
	for key,val in pairs(tb) do
		if val == copyId then
			return false
		end
	end
	return true
end

-- 获取影响解锁的数量
function DataLevelInfo:getHeroUnlockCount( nLevel )
	local nRet = 0
	local allHeroInfo = DataHeroInfo:getHeroTb()
	for i=1,5,1 do
		for j=1,3,1 do
			local tb = allHeroInfo[i][j]
			if DataHeroInfo:isHeroUnlock(tb.id) then
				local tbHero = LogicTable:get("hero_tplt", tb.id, true)
				if tbHero.level >= nLevel then
					nRet = nRet + 1
				end
			end
		end
	end
	return nRet
end

--判断有没有达到副本解锁的条件，参数是关卡的解锁需求unlocks[1]字段
function DataLevelInfo:canUnlock(unlockNeed)
	local unlockInfo = unlockNeed			--DataLevelInfo:getUnlockCopyInfo()
	if DataLevelInfo:getHeroUnlockCount( unlockInfo[1] )  >= unlockInfo[2] then
		return true
	end
	return false
end
-------------------------------------限时打折购买界面------通过副本解锁-------------------------------------------------
--设置限时打折信息
function DataLevelInfo:setDisDiamondInfo(info)
	self.dis_dia_info = info
end

--获得限时打折信息
function DataLevelInfo:getDisDiamondInfo()
	return self.dis_dia_info
end

--设置是否打开限时打折界面
function DataLevelInfo:setOpenDisDiaFlag(flag)
	self.OpenDisDiaFlag = flag
end

--获得是否打开限时打折界面
function DataLevelInfo:getOpenDisDiaFlag()
	return self.OpenDisDiaFlag
end

--判断该关卡是不是第一次成功通过
function DataLevelInfo:isFirstSuccess()
	if DataMap:getPass() > DataMap:getMaxPass() then
		return true
	end
	return false
end

--判断是不是要显示限时打折购买界面（只根据最大关卡数，是可以的，因为最大关卡数已经改变，但是只能用flag）
function DataLevelInfo:showDisCountDiamond()
	if  DataLevelInfo:getOpenDisDiaFlag() and self.copyInfo.discount_diamond_id ~= 0 then
		DataLevelInfo:saveDisDiaData()
		
		local str = "discount_diamond_"..DataMap:getDisDiamondInfo()[1].dis_dia_info.id
		ChannelProxy:getStrInfo(str, function(productTb)
			if 0 == #productTb then
				--UIPrompt:show("商品查询失败")
			else
				UIManager:openFront(UIDiscountDiamond, true ,{["product_tb"]=productTb})
				DataLevelInfo:setOpenDisDiaFlag(false)
			end
		end)	
	end
end

--根据活动持续时间，和客户端开启时间，计算活动结束时间
function DataLevelInfo:getDisDiaEndTime(tb)
	local start_time = tb.start_time
	local dis_dia_info = tb.dis_dia_info  
	
	DataLevelInfo:setDisDiamondInfo(dis_dia_info)
	local endSec = start_time + dis_dia_info.times*60*60
	
	return endSec
end

--获取渠道数据
function DataLevelInfo:getChannelData()
	local allTb = LogicTable:getAll("discount_diamond_tplt")
	local channelTb = {}
	local flag = false
	for key,val in pairs(allTb) do
		if val.channel_id == ChannelProxy:getChannelId() then
			flag = true
			table.insert(channelTb,val)
		end	
	end
	if flag == false then
		local needChannelId = ChannelPayCode:getDefaultChannelId()
		for key,val in pairs(allTb) do
			if val.channel_id == needChannelId then
				table.insert(channelTb,val)	
			end
		end
	end
	return channelTb
end

--设置要随机的限时打折数据库
function DataLevelInfo:setDisDiaRandomTb()
	local channelDataTable = DataLevelInfo:getChannelData()
	local randomTable = {}
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
		else
			return channelDataTable
		end
	end
	for index, channelData in pairs(channelDataTable) do
		for key, val in pairs(channelData) do
			if simStateStr == key and "" ~= val and "0" ~= val and "nil" ~= val then
				table.insert(randomTable, channelData)
			end
		end
	end
	if 0 == #randomTable then
		return channelDataTable
	end
	return randomTable
end

--设置打折数据库
function DataLevelInfo:saveDisDiaData()
	local tb = {}
	tb.start_time = STime:getClientTime()
	tb.dis_dia_info = CommonFunc:getRandom(DataLevelInfo:setDisDiaRandomTb())
	tb.end_time = DataLevelInfo:getDisDiaEndTime(tb)
	
	local tempTb =  {tb}
	DataMap:setDisDiamondInfo(tempTb)
end

--获取活动剩余时间
function DataLevelInfo:getActivityLeftTime()
	local dataTb = DataMap:getDisDiamondInfo()
	local nowSec = STime:getClientTime()  		
	local endSec = dataTb[1].end_time
	local temp = endSec - nowSec
	if temp <= 0 then
		return 0
	end
	return temp
end

--判断活动按钮要不要显示
function DataLevelInfo:showActivityBtn()
	-- 没有开启的情况
	local maxPass = DataMap:getMaxPass()
	if maxPass < G.DIS_DIA_LEVEL then
		return false
	end
	local dataTb = DataMap:getDisDiamondInfo()
	-- 只要等级够,还没有保存到数据库中,就显示按钮
	if 0 == #dataTb then
		if maxPass >= G.DIS_DIA_LEVEL then
			DataLevelInfo:saveDisDiaData()
			return true
		end
		return false
	end
	local nowSec = STime:getClientTime()
	local endSec = nowSec
	-- 上次保存是table,容错处理
	if "table" ~= type(dataTb[1].end_time) then
		endSec = dataTb[1].end_time
	end
	-- 如果在后台时间够了,就重新随机一个出来
	if nowSec >= endSec then
		DataLevelInfo:saveDisDiaData()
	end
	return true
end

			
-----------------------------------限时打折购买界面------通过等级解锁---------------------------------------------------------------------
