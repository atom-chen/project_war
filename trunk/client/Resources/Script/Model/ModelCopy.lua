----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-06-19
-- Brief: 副本数据
----------------------------------------------------------------------
ModelCopy = {
	mType = 0,					-- 副本类型,对应:CopyType
	mId = 0,					-- 副本id
	mName = 0,					-- 副本名称
	mHp = 0,					-- 体力消耗
	mMoves = 0,					-- 步数
	mOriMoves = 0,				-- 初始化时，表中的步数
	mAwards = {},				-- 奖励
	mGoals = {},				-- 目标(怪物数量 + 元素数量)
	mCurrGoals = {},			-- 已完成目标(怪物数量 + 元素数量)
	mGoalType = 0,				-- 最新完成的目标类型,对应:GoalType
	mUnlockNeed = {},			-- 副本解锁条件unlocks
	mShowDis = 0,				-- 是否显示限时打折界面
	mRewardTimes = 0,			-- 可以给奖励的次数
	mBuyDiscountMovesCount = 0,	-- 购买打折步数次数
	mBuyMovesCount = 0,			-- 购买步数次数
}

-- 初始
function ModelCopy:init(copyType, copyInfo)
	local id = copyInfo.id
	local name = copyInfo.name
	local hp = copyInfo.hp
	local moves = copyInfo.moves
	local originMoves = copyInfo.moves
	local awards = copyInfo.awards
	local killGoals = copyInfo.kill_goals
	local collectGoals = copyInfo.collect_goals
	local unlockNeed = copyInfo.unlocks[1]
	local showDis = copyInfo.discount_diamond_id
	local rewardTimes = copyInfo.reward_times
	self:reset(copyType, id, name, hp, moves, awards, killGoals, collectGoals, unlockNeed, showDis, rewardTimes)
end

-- 数据重置
function ModelCopy:reset(copyType, id, name, hp, moves, awards, killGoals, collectGoals, unlockNeed, showDis, rewardTimes)
	self.mType = copyType or CopyType["normal"]
	self.mId = id or 0
	self.mName = name or ""
	self.mHp = hp or 0
	self.mMoves = moves or 0
	self.mOriMoves = moves or 0
	self.mAwards = CommonFunc:clone(awards) or {}
	-- 目标解析(id=0表示击杀怪物,id>0表示收集元素)
	self.mGoals = {}
	self.mCurrGoals = {}
	if #killGoals > 0 then
		table.insert(self.mGoals, {id = 0, count = #killGoals})
		table.insert(self.mCurrGoals, {id = 0, count = 0})
	end
	for i, collectGoal in pairs(collectGoals) do
		table.insert(self.mGoals, {id = collectGoal[1], count = collectGoal[2]})
		table.insert(self.mCurrGoals, {id = collectGoal[1], count = 0})
	end
	self.mGoalType = GoalType["none"]
	self.mUnlockNeed = unlockNeed
	self.mShowDis = showDis
	self.mRewardTimes = rewardTimes
	self.mBuyDiscountMovesCount = 0
	self.mBuyMovesCount = 0
end

-- 获取副本类型
function ModelCopy:getType()
	return self.mType
end

-- 获取副本id
function ModelCopy:getId()
	return self.mId
end

-- 获取副本名称
function ModelCopy:getName()
	return self.mName
end

--判断体力是否足够
function ModelCopy:canEnterCopy()
	if PowerManger:getCurPower() < ModelCopy:getHp() then
		return false
	end
	return true
end

-- 获取体力消耗
function ModelCopy:getHp()
	return self.mHp
end

-- 获取步数
function ModelCopy:getMoves()
	return self.mMoves
end

-- 设置步数
function ModelCopy:setMoves(moves)
	self.mMoves = moves or 0
end

-- 获取奖励
function ModelCopy:getAwards()
	return CommonFunc:clone(self.mAwards)
end

-- 获取目标
function ModelCopy:getGoals()
	return CommonFunc:clone(self.mGoals)
end

-- 获取目标剩余数量
function ModelCopy:getRemainGoalCount(goalId)
	for index=1, #self.mGoals do
		if goalId == self.mGoals[index].id then
			local remainCount = self.mGoals[index].count - self.mCurrGoals[index].count
			if remainCount < 0 then
				remainCount = 0
			end
			return remainCount
		end
	end
	return 0
end

-- 获取剩余数量最多的普通收集元素id
function ModelCopy:getMaxRemainCountNormalGoal()
	-- 筛选最多剩余数量
	local goalIdList, maxRemainCount = {}, 0
	for index=1, #self.mGoals do
		if Factory:isNormalId(self.mGoals[index].id) then
			local remainCount = self.mGoals[index].count - self.mCurrGoals[index].count
			if remainCount > maxRemainCount then
				maxRemainCount = remainCount
				goalIdList = {}
				table.insert(goalIdList, self.mGoals[index].id)
			elseif remainCount == maxRemainCount then
				table.insert(goalIdList, self.mGoals[index].id)
			end
		end
	end
	return CommonFunc:getRandom(goalIdList) or 0
end

-- 目标是否完成
function ModelCopy:isGoalsComplete()
	for index=1, #self.mGoals do
		if self.mCurrGoals[index].count < self.mGoals[index].count then
			return false
		end
	end
	return true
end

-- 击杀目标是否完成
function ModelCopy:isKillGoalsComplete()
	for index=1, #self.mGoals do
		if 0 == self.mGoals[index].id then	-- 怪物
			return self.mCurrGoals[index].count >= self.mGoals[index].count
		end
	end
	return true
end

-- 收集目标是否完成
function ModelCopy:isCollectGoalsComplete()
	for index=1, #self.mGoals do
		if Factory:isNormalId(self.mGoals[index].id) or 5001 == self.mGoals[index].id then	-- 普通元素,砖石
			if self.mCurrGoals[index].count < self.mGoals[index].count then
				return false
			end
		end
	end
	return true
end

-- 破坏目标是否完成
function ModelCopy:isDamageGoalsComplete()
	for index=1, #self.mGoals do
		-- 其它元素:非怪物,非普通元素,非砖石
		if self.mGoals[index].id > 0 and not Factory:isNormalId(self.mGoals[index].id) and 5001 ~= self.mGoals[index].id then
			if self.mCurrGoals[index].count < self.mGoals[index].count then
				return false
			end
		end
	end
	return true
end

-- 更新击杀目标(返回已击杀数量)
function ModelCopy:updateKillGoals()
	local killGoals = {}
	for index, goal in pairs(self.mCurrGoals) do
		if 0 == goal.id then
			local killCount = self.mCurrGoals[index].count + 1
			self.mCurrGoals[index].count = killCount
			self.mGoalType = GoalType["kill"]
			killGoals[index] = {id = goal.id, count = killCount}
			break
		end
	end
	return killGoals
end

-- 更新收集目标(返回已收集数量)
function ModelCopy:updateColleteGoals(elementDatas)
	local collectGoals = {}
	-- 遍历被消除的元素
	for i, elementData in pairs(elementDatas) do
		local elementId = elementData.id
		if ElementType["skill"] == elementData.type then
			elementId = Factory:getNormalId(elementData.extra_type)
		end
		-- 匹配目标id
		for index, goal in pairs(self.mCurrGoals) do
			if elementId == goal.id then
				local collectCount = self.mCurrGoals[index].count + 1
				self.mCurrGoals[index].count = collectCount
				self.mGoalType = GoalType["collect"]
				-- 本次新收集的目标
				if nil == collectGoals[index] then
					collectGoals[index] = {id = goal.id, count = collectCount}
				else
					collectGoals[index].count = collectCount
				end
				break
			end
		end
		-- 记录炸弹事件
		if 5002 == elementId then
			ChannelProxy:recordCustom("stat_copy_bomb")
		end
	end
	return collectGoals
end

-- 获取目标类型
function ModelCopy:getGoalType()
	return self.mGoalType
end

-- 获取副本解锁的条件
function ModelCopy:getUnlockNeed()
	return self.mUnlockNeed
end

-- 获取限时打折是否显示
function ModelCopy:getShowDis()
	return self.mShowDis
end

-- 获取可以给奖励的次数
function ModelCopy:getRewardTimes()
	return self.mRewardTimes
end

-- 获取通过关卡需要的步数
function ModelCopy:getOriMoves()
	return self.mOriMoves
end

-- 获取购买打折步数次数
function ModelCopy:getBuyDiscountMovesCount()
	return self.mBuyDiscountMovesCount
end

-- 设置购买打折步数次数
function ModelCopy:setBuyDiscountMovesCount(count)
	self.mBuyDiscountMovesCount = count or 0
end

-- 获取购买步数次数
function ModelCopy:getBuyMovesCount()
	return self.mBuyMovesCount
end

-- 设置购买步数次数
function ModelCopy:setBuyMovesCount(count)
	self.mBuyMovesCount = count or 0
end
