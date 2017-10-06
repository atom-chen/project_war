----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-1-16
-- Brief: 保存当前关卡的数据
----------------------------------------------------------------------
ModelLevelLottery = {
	["getAwardTimes"] = 0,			-- 当前关卡（抽到物品后点击确定的次数，统计的是翻页的1到9）
	["rewardClickTimes"] = 0,		-- 当前关卡(从一递增，点击气泡的次数)
	["MustShowHeroInfo"] = {}		-- 抽奖必现的英雄信息
}

local mMustShowHeroAwardIds = {5004, 5001, 5010, 5013}--5002}	-- 抽奖必现的奖励id
local mMustShowHeroIds = {2101, 1101, 4101, 5101}--1201}		-- 抽奖必现的英雄id
local mMustShowHeroLevels = {5, 7, 10, 13}--22}				-- 抽奖必现的英雄等级

--抽取一个唯一的奖励出来
function ModelLevelLottery:getOnlyOneReward()
	local finalId,awardPondId,awardPondInfo,itemInfo = self:getGetAwardId()
	strNow = string.sub(itemInfo.id,1,2)
	local tb = {finalId,awardPondId,awardPondInfo,itemInfo}
	if itemInfo.award_type == 2 then	--根据抽取到的物品，判断该英雄有没有出现过，如果出现过了，就再抽一次
		local unlockHeroIds = DataMap:getHeroIds()	--已经解锁的英雄id
		if self:isSameClass(strNow) == false then
			return tb
		else
			return self:getOnlyOneReward()
		end
	else
		return	tb
	end	
end

--抽取一个抽奖池中的元素id出来（奖励id，奖励池id，奖励池信息）
function ModelLevelLottery:getGetAwardId()
	--根据关卡id，和抽奖次数，获得奖励池id
	local level = DataMap:getPass()
	if level == 0 then	--容错处理
		level = 1
	end
	if level == DataMap:getMaxPass() + 1 then		--失败后，还是上次最大关卡的奖励
		level = DataMap:getMaxPass()
	end
	
	local finalId,awardPondId,awardPondInfo,itemInfo = self:getRewardMustShowHeroInfo(level)
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
		finalId = self:getRandomOneId(awardPondInfo)
		itemInfo = self:getRewardIconInfo(finalId)
	end
	--cclog("最终的是*************",finalId,awardPondId)
	return finalId,awardPondId,awardPondInfo,itemInfo
end

--根据奖励池中的信息，获取随机到的id
function ModelLevelLottery:getRandomOneId(awardPondInfo)
	local proTb = {}		--可能性
	for key,val in pairs(awardPondInfo) do
		local levelId = DataMap:getPass()
		if levelId == DataMap:getMaxPass() + 1 then
			levelId = DataMap:getMaxPass()
		end
		if key ~= "id" then
			if awardPondInfo[key][3] == -1 then
				local flag,cases,leftTimes = self:alreadyShowFullTimes( levelId,awardPondInfo.id,key,awardPondInfo[key][3],awardPondInfo[key][1])
				--cclog("-1的************",awardPondInfo[key][1],flag,cases,leftTimes)
				if flag == false and cases == 2 and awardPondInfo[key][3] == -1 then	--必须出现的
					return awardPondInfo[key][1]
				end
			elseif awardPondInfo[key][3] >0 then		--有次数限制的
				local flag,cases,leftTimes = self:alreadyShowFullTimes( levelId,awardPondInfo.id,key,awardPondInfo[key][3],awardPondInfo[key][1])
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

--判断随机数有没有出现够次数(当前/上一关关卡id，奖池id，奖池项)
function ModelLevelLottery:alreadyShowFullTimes(levelId,pondId,keyStr,times,finalId)
	local temp = ModelLottery:getLevelTimesInfo()
	local flag = 0
	local leftTimes = 0 		--还需要的次数
	--Log(temp)
	local itemInfo = self:getRewardIconInfo(finalId)
	if times == -1 and itemInfo.award_type == 2 then	
		--Log("保存的数据**************",temp)
		--为提前解锁必出英雄做的限制
		local strNow = string.sub(itemInfo.id,1,2)
		if self:isSameClass(strNow) then
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

--判断解锁的有没有同类英雄
function ModelLevelLottery:isSameClass(strNow)
	local unlockHeroIds = DataMap:getHeroIds()	--已经解锁的英雄id
	for	 key,val in pairs(unlockHeroIds) do
		local strOri = string.sub(val,1,2)
		if strNow == strOri then
			return	true
		end
	end
	return false
end

--判断前面必出的英雄有没有没出现的，如果有，就出现最前面必须出现的
function ModelLevelLottery:getRewardMustShowHeroInfo(level)
	--解决没抽奖和退出问题，必抽的英雄没有出现
	for key,val in pairs(mMustShowHeroIds) do
		if level > mMustShowHeroLevels[key]  then
			strNow = string.sub(val,1,2)
			if self:isSameClass(strNow) == false then
				finalId = mMustShowHeroAwardIds[key]
				awardPondId = mMustShowHeroLevels[key]
				awardPondInfo = self.MustShowHeroInfo[key]
				itemInfo = self:getRewardIconInfo(finalId)
				return finalId,awardPondId,awardPondInfo,itemInfo
			end	
		end
	end
	return 0,0,{}
end
------------------------------------------------------------------------------------------------
--根据抽取到的物品，设置数据库
function ModelLevelLottery:setOneTime(finalId,awardPondId,awardPondInfo,itemInfo)
	local keyStr,allTimes = self:getKeyByAwardInfo(awardPondInfo,finalId)
	if itemInfo.award_type == 1 or itemInfo.award_type == 3 then 
		local types = UIMiddlePub:getItemTypeById(itemInfo.id)
		if types == ItemType["ball"]  then			-- 毛球 -- 毛球包			
			ModelItem:appendTotalBall(itemInfo.count)
		elseif  types == ItemType["cookie"] then		-- 饼干
			ModelItem:appendTotalCookie(itemInfo.count)
		elseif types == ItemType["dia"] then			-- 砖石 -- 砖石包
			ModelItem:appendTotalDiamond(itemInfo.count)		
		end
	elseif itemInfo.award_type == 2 then			--抽取到的是英雄需要特殊判断
		DataHeroInfo:setUnlockHeroTb(itemInfo.id)
		DataHeroInfo:setSelectHeroId(itemInfo.id,false)
		DataHeroInfo:getSelectHeroId()
	end
	
	if  allTimes ~= 0 then	--设置数据库(只能抽取几次的)
		local levelId = DataMap:getPass()					--id有可能需要改变？？？？？？
		if levelId == DataMap:getMaxPass() + 1 then		--失败后，还是上次最大关卡的奖励
			levelId = DataMap:getMaxPass()
		end
		local flag,cases,leftTimes = self:alreadyShowFullTimes(levelId,awardPondId,keyStr,allTimes,finalId)
		local rewardData = ModelLottery:getLevelTimesInfo()
		if flag == false and cases == 2 then
			local tb = {["level_id"]= levelId,["pond_id"]= awardPondId,["award_pond_name"] = keyStr,
				["show_times"]= 1,["award_id"] = finalId}
			table.insert(rewardData,tb)
			ModelLottery:setLevelTimesInfo(rewardData)
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
					ModelLottery:setLevelTimesInfo(rewardData)
					return
				end
			end
		end
	end
end

--根据奖励池中的奖励id，判断他的key值和抽取次数
function ModelLevelLottery:getKeyByAwardInfo(awardPondInfo,id)
	for key,val in pairs(awardPondInfo) do
		if key ~= "id" and val[1] == id then
			return key,val[3]
		end
	end
end
------------------------------------------------------------------------------------------------
--根据奖励id，获得图片或plist文件名
function ModelLevelLottery:getRewardIconInfo(rewardId)
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
function ModelLevelLottery:setGetAwardTimes(times)
	self.getAwardTimes = times
end

--获得当前关卡抽奖的次数（统计的是翻页的1到9）
function ModelLevelLottery:getGetAwardTimes()
	return self.getAwardTimes
end

--设置当前关卡的抽奖次数
function ModelLevelLottery:setRewardClickTimes(times)
	self.rewardClickTimes = times
end

--获得当前关卡抽奖的次数(从一递增)
function ModelLevelLottery:getRewardClickTimes()
	return self.rewardClickTimes
end
------------------------------------------------------------------------------------------------
--初始化英雄必抽的信息
function ModelLevelLottery:initMustShowHeroInfo()
	for key,val in pairs(mMustShowHeroAwardIds) do
		local awardInfo = LogicTable:get("award_pond_tplt", mMustShowHeroLevels[key], true)
		table.insert(self.MustShowHeroInfo,awardInfo)
	end
end
------------------------------------------------------------------------------------------------