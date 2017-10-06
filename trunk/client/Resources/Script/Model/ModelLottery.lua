----------------------------------------------------------------------
-- Author: 李慧琴
-- Date: 2015-03-03
-- Brief: 抽奖数据模型
----------------------------------------------------------------------
ModelLottery = {
	mLevelTimesInfo = {},			-- (当前关卡的抽奖数据)			--保存在数据库中的数据
	mCurRewardBall = 0,				-- 当前界面的毛球
	mCurRewardCookie = 0,			-- 当前界面的饼干
	mCurRewardDia = 0,				-- 当前界面的砖石
	mCurRewardKey = 0,				-- 当前界面的钥匙
	mCurRewardPower = 0,			-- 当前界面的体力
	mCurRewardMaxPower = 0,			-- 当前界面的最大体力
	mCurRewardNeedData = {},		-- 保存所有抽奖需要的数据
	mCuOpenHeroFlag = false,		-- 保存当前礼包有没有打开的
	mCuOpenBagFlag = false,			-- 保存当前礼包有没有打开的
}

-- 获得有没有打开的英雄或礼包界面
function ModelLottery:getOpenHeroBagFlag()
	if self.mCuOpenBagFlag or self.mCuOpenHeroFlag then
		return true
	end
	return false
end

-- 判断有没有打开礼包界面
function ModelLottery:setOpenBag(flag)
	self.mCuOpenBagFlag = flag
end

--判断有没有打开礼包界面
function ModelLottery:getOpenBag()
	return self.mCuOpenBagFlag
end

-- 判断有没有打开英雄界面
function ModelLottery:setOpenHero(flag)
	self.mCuOpenHeroFlag = flag
end

-- 判断有没有打开英雄界面
function ModelLottery:getOpenHero()
	return self.mCuOpenHeroFlag
end

-- 设置当前九个抽奖数据
function ModelLottery:setRewardNeedData(data)
	self.mCurRewardNeedData = data
end

-- 获取当前九个抽奖数据
function ModelLottery:getRewardNeedData()
	return self.mCurRewardNeedData
end
---------------------------------所有关卡的抽奖数据-----------------------------------------------------------
-- 初始化抽奖数据
function ModelLottery:init()
	self.mLevelTimesInfo = DataMap:getLevelOneInfo() 
	self:updateRewardInfo()
end

--更新抽奖界面的数据
function ModelLottery:updateRewardInfo()
	self.mCurRewardBall = ModelItem:getTotalBall()
	self.mCurRewardCookie = ModelItem:getTotalCookie()
	self.mCurRewardDia = ModelItem:getTotalDiamond()
	self.mCurRewardKey = ModelItem:getTotalKey()
	self.mCurRewardPower = PowerManger:getCurPower()
	self.mCurRewardMaxPower = PowerManger:getMaxPower()
end

--设置抽奖的信息
function ModelLottery:setLevelTimesInfo(rewardData)
	self.mLevelTimesInfo = rewardData
end

--获取抽奖的信息
function ModelLottery:getLevelTimesInfo()
	return self.mLevelTimesInfo  
end
-----------------------------------------------------------------------------------------------
-- 追加总毛球数
function ModelLottery:setCurRewardBall(ball)
	self.mCurRewardBall =  ball
end

-- 追加总饼干数
function ModelLottery:setCurRewardCookie(cookie)
	self.mCurRewardCookie = cookie
end

-- 追加总钥匙数
function ModelLottery:setCurRewardKey(key)
	self.mCurRewardKey = key
end

-- 追加总砖石数
function ModelLottery:setCurRewardDiamond(diamond)
	self.mCurRewardDia = diamond
end

-- 追加总体力
function ModelLottery:setCurRewardPower(power)
	self.mCurRewardPower =  power
end

-- 追加总最大体力
function ModelLottery:setCurRewardMaxPower(maxPower)
	self.mCurRewardMaxPower =  maxPower
end

-- 获取当前界面的毛球
function ModelLottery:getCurRewardBall()
	return self.mCurRewardBall
end

-- 获取当前界面的饼干
function ModelLottery:getCurRewardCookie()
	return self.mCurRewardCookie
end

-- 获取当前界面的钥匙
function ModelLottery:getCurRewardKey()
	return self.mCurRewardKey
end

-- 获取当前界面的砖石
function ModelLottery:getCurRewardDiamond()
	return self.mCurRewardDia
end

-- 获取当前界面的体力
function ModelLottery:getCurRewardPower()
	return self.mCurRewardPower
end

-- 获取当前界面的最大体力
function ModelLottery:getCurRewardMaxPower()
	return self.mCurRewardMaxPower
end

