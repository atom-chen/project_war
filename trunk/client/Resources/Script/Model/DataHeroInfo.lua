----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-1-21
-- Brief: 保存所有英雄的数据
----------------------------------------------------------------------
DataHeroInfo = {
	["selectedHeros"] = {},		
	
	
}

--获得五种元素的图片
function DataHeroInfo:getFiveElementIcon()
	local tbIcon = {}
	local normalElementIds = {2001, 2002, 2003, 2004, 2005}
	for key,val in pairs(normalElementIds) do
		local icon = LogicTable:get("element_tplt", val, true).normal_image
		table.insert(tbIcon,icon)
	end
	return tbIcon
end
-----------------------------------升级后，修改相应位置-------------------------------------------------
--更新保存在本地的已经解锁的最高的英雄id
function DataHeroInfo:updateSaveIds(lastHero,newHero)
	local oriHeroIds = DataMap:getHeroIds()
	for key,val in pairs(oriHeroIds) do
		if lastHero.id == val then
			oriHeroIds[key] = newHero.id
			return oriHeroIds
		end
	end
end

--更新保存在本地的当前选择的的英雄id
function DataHeroInfo:updateSelectIds(id)
	local selectedIds = DataMap:getSelectedHeroIds()
	local nowStr = string.sub(id,1,2)
	for key,val in pairs(selectedIds) do
		local oldStr = string.sub(val,1,2)
		if nowStr == oldStr then
			selectedIds[key] = id
			DataMap:setSelectedHeroIds(selectedIds)
			self.selectedHeros = selectedIds
			return selectedIds
		end
	end
end

--升级后，更新对应英雄的数据
function DataHeroInfo:updateHeroGrowInfo(lastHero,newHero)
	for key,val in pairs(self.heroTb[lastHero.type]) do
		if val.id == lastHero.id then
			val = newHero
			self.heroTb[lastHero.type][key] = newHero
			self.heroTb[lastHero.type][key].tip = DataHeroInfo:isMaterialEnough(newHero)
			local oriHeroIds = DataHeroInfo:updateSaveIds(lastHero,newHero)
			DataMap:setHeroIds(oriHeroIds)
			DataHeroInfo:updateHeroData_init()
			
			local selectedIds = DataHeroInfo:updateSelectIds(val.id)
			--DataMap:setSelectedHeroIds(selectedIds)
			return
		end
	end
end
----------------------------------初始化数据--------------------------------------------
--把元素id排序
function DataHeroInfo:sortTb(tb)
	for i=1, #tb - 1 do
	   local min = i
	   for j=i+1, #tb do
			if tb[j].id < tb[min].id  then
				 min = j
			end
	   end
	   if min ~= i then
			tb[min], tb[i] = tb[i], tb[min]
	   end
  end
	return tb
end

--更新某一个数据
function DataHeroInfo:updateHeroTypeId(heroInfo,str1)
	local heroData = DataHeroInfo:getHeroTb()
	for key,val in pairs(heroData[heroInfo.type])do
		local str = string.sub(val.id,0,2)
		if str1 == str then
			heroData[heroInfo.type][key] = heroInfo
			return heroData
		end
	end
end

--根据已经解锁的最大id，更新数据
function DataHeroInfo:updateHeroData_init()
	local oriHeroIds = DataMap:getHeroIds()
	for k,v in pairs(oriHeroIds) do
		local heroInfo = LogicTable:get("hero_tplt", v, true)
		local str1 = string.sub(v,0,2)
		local heroData = DataHeroInfo:updateHeroTypeId(heroInfo,str1)
		self.heroTb = heroData
	end
end

--先把所有类型相同的，放在一个表里（处理的原始的等级为一的）
function DataHeroInfo:joinTheSameType()
	local heroTable = LogicTable:getAll("hero_tplt")

	local tempHeroTable = {{},{},{},{},{}}
	local function insertHeroTable(hero)
		if hero.level == 1 then
			if #tempHeroTable[hero.type] ~= 0  then
				table.insert(tempHeroTable[hero.type],hero)
				return
			end
			table.insert(tempHeroTable[hero.type],hero)
		end
	end
	
	for key, val in pairs(heroTable) do
		insertHeroTable(val)
	end
	
	local temp = {}
	for key,val in pairs(tempHeroTable) do
		local sortTb = DataHeroInfo:sortTb(val)
		table.insert(temp,sortTb)
	end
	self.heroTb = temp
	return temp
end

--根据英雄信息,判断升级所需物品是否足够
function DataHeroInfo:isMaterialEnough(val)
	local nowBall = ModelItem:getTotalBall()
	local nowCookie = ModelItem:getTotalCookie()
	local ballFlag,cookieFlag = true,true
	for key,val in pairs(val.materials) do
		if val[1] == 1 then
			if nowBall < val[2] then
				ballFlag = false
			end
		elseif val[1]== 2 then
			if nowCookie < val[2] then
				cookieFlag = false
			end
		elseif val[1] == 0 then
			return false
		end
	end
	if ballFlag == false or cookieFlag == false then
		return false
	end
	return true
end

--判断该英雄有没有解锁
function DataHeroInfo:isHeroUnlock(heroId)
	local tb = DataMap:getHeroIds()
	for key,val in pairs(tb) do
		if val == heroId then
			return true
		end
	end
	return false
end

--根据有没有已经解锁的，可以升级的，更新初始数据表
function DataHeroInfo:updateHeroData_addItem(tipflag,lockFlag)
	for k,v in pairs(self.heroTb) do
		for key,val in pairs(self.heroTb[k]) do
			if lockFlag then
				if DataHeroInfo:isHeroUnlock(val.id) then
					val.unlock = true
				else
					val.unlock = false
				end
			end
			if tipflag then 
				if DataHeroInfo:isMaterialEnough(val) then
					val.tip = true
				else
					val.tip = false
				end
			end
		end
	end
end

--根据类型获得英雄的数据
function DataHeroInfo:getHeroTb()
	return self.heroTb
end
-----------------------------------------------------------------------------------
--根据元素类型，判断可以升级的个数
function DataHeroInfo:getGrowNumberByType(types)
	local count = 0
	for key,val in pairs(self.heroTb[types]) do
		if DataHeroInfo:isHeroUnlock(val.id) and DataHeroInfo:isMaterialEnough(val) then
			count = count + 1
		end
	end
	return count
end

--判断所有英雄可以升级的个数
function DataHeroInfo:getAllGrowNumber()
	local count = 0
	for i= 1,5,1 do
		local temp = DataHeroInfo:getGrowNumberByType(i)
		count = count + temp
	end
	return count
end

--设置解锁的英雄id(如，抽奖获得)
function DataHeroInfo:setUnlockHeroTb(heroId)
	local tb = DataMap:getHeroIds()
	table.insert(tb,heroId)
	DataMap:setHeroIds(tb)
	--Log("DataHeroInfo:setUnlockHeroTb",DataMap:getHeroIds())
end

--根据选择的解锁的id，判断英雄的位置
function DataHeroInfo:getHeroIndex(heroId)
	local tb = LogicTable:get("hero_tplt", heroId, true)
	return tb.type
end

--根据已经解锁的英雄和可以升级的英雄，获得英雄界面的初始位置
function DataHeroInfo:getInitHeroIndex()
	local growNumber = DataHeroInfo:getAllGrowNumber()
	if growNumber == 0 then		--获得第一个解锁的位置
		for k,v in pairs(self.heroTb) do
			for key,val in pairs(self.heroTb[k]) do
				if DataHeroInfo:isHeroUnlock(val.id) then
					return	val.type
				end
			end
		end
		return 1
	else						--获得第一个可以升级的位置
		for i= 1,5,1 do
			local temp = DataHeroInfo:getGrowNumberByType(i)
			if temp > 0 then
				return i
			end
		end
		return 1
	end
end

--根据英雄的类型，判断前面有几个已经解锁了的id信息
function DataHeroInfo:getAllUnlockTypeTbByType(types)
	local count = 0
	local allTypeTb = DataHeroInfo:getHeroTb()[types]
	for key,val in pairs(allTypeTb) do
		if DataHeroInfo:isHeroUnlock(val.id) then
			val.unlock = true
			count = count + 1
		else
			val.unlock =false
		end
	end
	return allTypeTb,count
end

--根据英雄的id，判断前面有几个已经解锁了的id信息
function DataHeroInfo:getAllUnlockTypeTb(heroId)
	local count = 0
	local types = DataHeroInfo:getHeroIndex(heroId)
	allTypeTb,count = DataHeroInfo:getAllUnlockTypeTbByType(types)
	return allTypeTb,count
end

--判断所有英雄中解锁的有没有超过一个
function DataHeroInfo:canShowScrollTip()
	for i = 1,5,1 do
		local count = 0
		local allTypeTb = DataHeroInfo:getHeroTb()[i]
		for key,val in pairs(allTypeTb) do
			if DataHeroInfo:isHeroUnlock(val.id) then
				count = count + 1
				if count > 1 then
					return true
				end
			end
		end
	end
	return false
end

--（滑动pageView时调用）设置当前关卡选择的英雄ids,（flag,表示是否更换选中的英雄id
function DataHeroInfo:setSelectHeroId(heroId,flag)
	local index = DataHeroInfo:getHeroIndex(heroId)
	if nil == self.selectedHeros[index]  then
		self.selectedHeros[index] = heroId
	elseif nil ~= self.selectedHeros[index] and flag == true then
		self.selectedHeros[index] = heroId
	elseif nil ~= self.selectedHeros[index] and flag == false then
	
	end
end

--获得当前选择的英雄id
function DataHeroInfo:getSelectHeroId()
	DataMap:setSelectedHeroIds(self.selectedHeros)
	return self.selectedHeros
end

--根据英雄的技能id，获得他的技能图标
function DataHeroInfo:getSkillIconById(skillId)
	local skillInfo =  LogicTable:get("skill_tplt", skillId, true)
	local elementInfo = LogicTable:get("element_tplt", skillInfo.element_id, true)
	return elementInfo.normal_image
end

--根据上次选择的英雄id，判断他是同类英雄中的第几个
function DataHeroInfo:getIndexById(heroId)
	local index = DataHeroInfo:getHeroIndex(heroId)
	local allTypeTb = DataHeroInfo:getHeroTb()[index]
	for key,val in pairs(allTypeTb) do
		if val.id == heroId then
			return key
		end
	end
	return 1
end

--根据英雄的信息，获得他的勋章头像和第几个勋章
function DataHeroInfo:getMedalLevel(curHeoInfo)
	local medalLevel = {1,5,10,15,20}			--{20,15,10,5,1}
	for key,val in pairs(medalLevel) do
		if curHeoInfo.level< val then
			return key-1,"medal_"..(key-1)..".png"
		elseif curHeoInfo.level ==  val then
			return key,"medal_"..key..".png"
		end
	end
	return medalLevel[#medalLevel],"medal_"..#medalLevel..".png"
end

--判断该解锁的英雄id，是不是当前选中的
function DataHeroInfo:isUnlockSelected(heroId)
	local selected = DataMap:getSelectedHeroIds()
	for key,val in pairs(selected) do
		if val ==  heroId then
			return true
		end
	end
	return false
end

DataHeroInfo:joinTheSameType()

function DataHeroInfo:init()
	self.selectedHeros = DataMap:getSelectedHeroIds()
	DataHeroInfo:updateHeroData_init()		-- 初始化英雄数据
	DataHeroInfo:updateHeroData_addItem(true,true)
end
