----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-6-23
-- Brief: 副本解锁条件
----------------------------------------------------------------------
ModelUnlock = {
	
}

-- 判断要不要出现副本解锁界面
function ModelUnlock:showCopyUnlockUI(unlockInfo,copyId)
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
function ModelUnlock:getHeroUnlockCount( nLevel )
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
function ModelUnlock:canUnlock(unlockNeed)
	local unlockInfo = unlockNeed			
	if ModelUnlock:getHeroUnlockCount( unlockInfo[1] )  >= unlockInfo[2] then
		return true
	end
	return false
end
