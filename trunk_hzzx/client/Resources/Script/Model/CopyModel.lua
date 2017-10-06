----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-12
-- Brief: 副本模型
----------------------------------------------------------------------
CopyModel = {
	mCopyInfo = {},				-- 副本数据信息
	mGoals = {},				-- 目标(怪物数量 + 元素数量)
	mCurrGoals = {},			-- 当前完成目标(怪物数量 + 元素数量)
	mCurrMoves = 0,				-- 当前步数
	mLatestGoalType = 0,		-- 最新完成的目标类型,对应:GoalType
}

-- 初始化
function CopyModel:init(copyId)
	
	
	local copyInfo = LogicTable:get("copy_tplt", copyId, false)
	if nil == copyInfo then
		return
	end
	self.mCopyInfo = copyInfo
	--设置体力
	CopyModel:setCostHp()
	
	--self:subscribeEvent(EventDef["ED_FREE_POWER_end"], self.setCostHp)
	
	-- 目标解析(id=0表示击杀怪物,id>0表示收集元素)
	self.mGoals = {}
	self.mCurrGoals = {}
	if  #copyInfo.kill_goals ~= 0 then		--否则会显示击杀0只怪
		table.insert(self.mGoals, {id = 0, count = #copyInfo.kill_goals})
		table.insert(self.mCurrGoals, {id = 0, count = 0})
	end
	for i, collectGoal in pairs(copyInfo.collect_goals) do
		table.insert(self.mGoals, {id = collectGoal[1], count = collectGoal[2]})
		table.insert(self.mCurrGoals, {id = collectGoal[1], count = 0})
	end
	--
	self.mCurrMoves = copyInfo.moves
	self.mLatestGoalType = GoalType["none"]
end

-- 获取副本名称
function CopyModel:getName()
	return (self.mCopyInfo.id or 0)..":"..(self.mCopyInfo.name or "")
end

-- 获取消耗体力
function CopyModel:getCostHp()
	return self.mCopyInfo.hp or 0
end

-- 设置消耗体力
function CopyModel:setCostHp()
	print("CopyModel:setCostHp()*************",self.mCopyInfo.hp,DataLevelInfo:getCopyInfo().hp,FreePowerManger:getLeftTime() )
	if nil == self.mCopyInfo then
		cclog("纳尼******************")
		return
	end
	if FreePowerManger:getLeftTime() == "00:00" then
		self.mCopyInfo.hp = DataLevelInfo:getCopyInfo().hp 
	else
		self.mCopyInfo.hp = 0
	end
end

-- 获取奖励id列表
function CopyModel:getAwards()
	return self.mCopyInfo.awards or {}
end

-- 获取最大步数
function CopyModel:getMaxMoves()
	return self.mCopyInfo.moves or 0
end

-- 获取当前步数
function CopyModel:getCurrMoves()
	return self.mCurrMoves
end

-- 设置当前步数
function CopyModel:setCurrMoves(currMoves)
	self.mCurrMoves = currMoves
end

-- 获取目标
function CopyModel:getGoals()
	return CommonFunc:clone(self.mGoals)
end

-- 获取剩余目标数量
function CopyModel:getRemainGoalCount(goalId)
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

-- 目标是否完成
function CopyModel:isGoalsComplete()
	for index=1, #self.mGoals do
		if self.mCurrGoals[index].count < self.mGoals[index].count then
			return false
		end
	end
	return true
end

-- 更新收集目标(返回追加的数量)
function CopyModel:updateColleteGoals(elementDatas)
	local collectGoals = {}
	-- 遍历被消除的元素
	for i, elementData in pairs(elementDatas) do
		local elementId = elementData.id
		if 5002 == elementId then
			ChannelProxy:recordCustom("stat_copy_bomb")
		end
		if ElementType["skill"] == elementData.type then
			elementId = Factory:getNormalId(elementData.extra_type)
		end
		-- 匹配目标id
		for index, goal in pairs(self.mCurrGoals) do
			if elementId == goal.id then
				local collectCount = self.mCurrGoals[index].count + 1
				self.mCurrGoals[index].count = collectCount
				-- 本次新收集的目标
				if nil == collectGoals[index] then
					collectGoals[index] = {id = elementId, count = collectCount}
				else
					collectGoals[index].count = collectCount
				end
				self.mLatestGoalType = GoalType["collect"]
				break
			end
		end
	end
	return collectGoals
end

-- 更新击杀目标
function CopyModel:updateKillGoals()
	local index = 1
	local killCount = self.mCurrGoals[index].count + 1
	self.mCurrGoals[index].count = killCount
	self.mLatestGoalType = GoalType["kill"]
	return {[index] = {id = 0, count = killCount}}
end

-- 获取最新完成的目标类型
function CopyModel:getLatestGoalType()
	return self.mLatestGoalType
end
