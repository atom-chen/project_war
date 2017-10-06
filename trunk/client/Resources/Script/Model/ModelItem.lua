----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-13
-- Brief: 物品数据
----------------------------------------------------------------------
ModelItem = {
	mTotalBall = 0,				-- 总的毛球数
	mTotalCookie = 0,			-- 总的饼干数
	mTotalKey = 0,				-- 总的钥匙数
	mTotalDiamond = 0,			-- 总的砖石数
	mCollectBall = 0,			-- 收集到的毛球数
	mCollectCookie = 0,			-- 收集到的饼干数
	mCollectKey = 0,			-- 收集到的钥匙数
	mCollectDiamond = 0,		-- 收集到的砖石数
}

-- 初始化物品数据
function ModelItem:init()
	self.mTotalBall = DataMap:getBall()
	self.mTotalCookie = DataMap:getCookie()
	self.mTotalKey = DataMap:getKey()
	self.mTotalDiamond = DataMap:getDiamond()
end

-- 清除收集数据
function ModelItem:clearCollect()
	self.mCollectBall = 0
	self.mCollectCookie = 0
	self.mCollectKey = 0
	self.mCollectDiamond = 0
end

-- 更新收集数据
function ModelItem:updateCollect(elementDataList)
	for i, elementData in pairs(elementDataList) do
		if elementData.award_id > 0 then
			local awardData = LogicTable:getAwardData(elementData.award_id)
			if AwardType["item"] == awardData.type then
				if 1 == awardData.sub_id then		-- 毛球
					self:appendTotalBall(awardData.count)
					self.mCollectBall = self.mCollectBall + awardData.count
				elseif 2 == awardData.sub_id then	-- 饼干
					self:appendTotalCookie(awardData.count)
					self.mCollectCookie = self.mCollectCookie + awardData.count
				elseif 3 == awardData.sub_id then	-- 钥匙
					self:appendTotalKey(awardData.count)
					self.mCollectKey = self.mCollectKey + awardData.count
				elseif 4 == awardData.sub_id then	-- 砖石
					self:appendTotalDiamond(awardData.count)
					self.mCollectDiamond = self.mCollectDiamond + awardData.count
				end
			end
		end
	end
end

-- 更新过关奖励
function ModelItem:updatePassAward(awardIdList)
	for i, awardId in pairs(awardIdList) do
		local awardData = LogicTable:getAwardData(awardId)
		if AwardType["item"] == awardData.type then
			local types = UIMiddlePub:getItemTypeById(awardData.sub_id)
			if types == ItemType["ball"] then			-- 毛球
				self:appendTotalBall(awardData.count)
				self.mCollectBall = self.mCollectBall + awardData.count
			elseif types == ItemType["cookie"] then		-- 饼干
				self:appendTotalCookie(awardData.count)
				self.mCollectCookie = self.mCollectCookie + awardData.count
			elseif types == ItemType["key"] then		-- 钥匙
				self:appendTotalKey(awardData.count)
				self.mCollectKey = self.mCollectKey + awardData.count
			elseif types == ItemType["dia"] then		-- 砖石
				self:appendTotalDiamond(awardData.count)
				self.mCollectDiamond = self.mCollectDiamond + awardData.count
			end
		end
	end
end

-- 追加总毛球数
function ModelItem:appendTotalBall(ball)
	self.mTotalBall = self.mTotalBall + ball
	DataMap:setBall(self.mTotalBall)
end

-- 追加总饼干数
function ModelItem:appendTotalCookie(cookie)
	self.mTotalCookie = self.mTotalCookie + cookie
	DataMap:setCookie(self.mTotalCookie)
end

-- 追加总钥匙数
function ModelItem:appendTotalKey(key)
	self.mTotalKey = self.mTotalKey + key
	DataMap:setKey(self.mTotalKey)
end

-- 追加总砖石数
function ModelItem:appendTotalDiamond(diamond)
	self.mTotalDiamond = self.mTotalDiamond + diamond
	DataMap:setDiamond(self.mTotalDiamond)
end

-- 获取总毛球数
function ModelItem:getTotalBall()
	return self.mTotalBall
end

-- 获取总饼干数
function ModelItem:getTotalCookie()
	return self.mTotalCookie
end

-- 获取总钥匙数
function ModelItem:getTotalKey()
	return self.mTotalKey
end

-- 获取总砖石数
function ModelItem:getTotalDiamond()
	return self.mTotalDiamond
end

-- 获取收集到的毛球数
function ModelItem:getCollectBall()
	return self.mCollectBall
end

-- 获取收集到的饼干数
function ModelItem:getCollectCookie()
	return self.mCollectCookie
end

-- 获取收集到的钥匙数
function ModelItem:getCollectKey()
	return self.mCollectKey
end

-- 获取收集到的砖石数
function ModelItem:getCollectDiamond()
	return self.mCollectDiamond
end

