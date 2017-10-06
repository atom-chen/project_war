----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 出生控制器
----------------------------------------------------------------------
BornController = class("BornController", Component)

-- 构造函数
function BornController:ctor()
	self.super:ctor(self.__cname)
	self.mGridController = nil					-- 格子控制器
	self.mBornCoords = {}						-- 出生坐标表
	self.mCopyId = 0							-- 副本id
	self.mDropInfo = 0							-- 掉落信息
	self.mInitSkillIds = {}						-- 初始的技能数据列表
	self.mNormalElementProbability = nil		-- 普通元素随机概率
	self.mSpecialElementDrop = {}				-- 特殊元素个数及出现概率
	self.mCurrRound = 0							-- 当前回合数
	-- 注册事件
	self:bind(EventDef["ED_ROUND_OVER"], self.handleRoundOver, self)
end

-- 初始化
function BornController:init(copyId, initSkills, dropId)
	self.mGridController = self:getSibling("GridController")
	self.mBornCoords = self.mGridController:getBornCoords()
	for i, skillId in pairs(initSkills) do
		local skillData = LogicTable:get("skill_tplt", skillId, true)
		self.mInitSkillIds[skillData.element_id] = skillId
	end
	-- 动态难度(开局模式判断)
	self.mCopyId = copyId
	self.mDropInfo = LogicTable:get("copy_drop_tplt", dropId, true)
	if not self:openStartMode() then	-- 开局模式
		self:openNormalMode()			-- 常规模式
	end
	-- 特殊元素信息
	for i, specialElementDrop in pairs(self.mDropInfo.special_element_drop) do
		local info = {
			special_id = specialElementDrop[1],				-- 特殊元素id
			remain_count = specialElementDrop[2],			-- 可出现剩余个数
			drop_round = specialElementDrop[3],				-- 多少回合可掉落
			probabilty = specialElementDrop[4],				-- 达到回合数时的掉落概率
			round = 0,										-- 最近一次触发的回合
		}
		self.mSpecialElementDrop[info.special_id] = info
	end
end

-- 获取格子可生成的坐标
function BornController:getGridBornCoords()
	local gridDatas = self.mGridController:getGridDatas()
	local boardDatas = self.mGridController:getBoardDatas()
	local bornCoordList = {}
	for i, bornCoord in pairs(self.mBornCoords) do
		-- 出生位置没有格子,且下方格子有效
		if (nil == gridDatas[bornCoord.row] or nil == gridDatas[bornCoord.row][bornCoord.col] or
			nil == gridDatas[bornCoord.row][bornCoord.col][1] or gridDatas[bornCoord.row][bornCoord.col][1] <= 0) and
			(Core:isCanMoveTo(bornCoord, Core:makeCoord(bornCoord.row + 1, bornCoord.col), boardDatas, gridDatas) or
			Core:isCanMoveTo(bornCoord, Core:makeCoord(bornCoord.row + 1, bornCoord.col - 1), boardDatas, gridDatas) or
			Core:isCanMoveTo(bornCoord, Core:makeCoord(bornCoord.row + 1, bornCoord.col + 1), boardDatas, gridDatas)) then
			table.insert(bornCoordList, bornCoord)
		end
	end
	return bornCoordList
end

-- 生成初始格子
function BornController:generateInitGrid()
	self.mGridController:setTouchEnabled(false)
	local bornCoordList = {}
	local dropCount = 0
	local gridDatas = self.mGridController:getGridDatas()
	for row, rowData in pairs(gridDatas) do
		for col, gridData in pairs(rowData) do
			local grid = self.mGridController:createGrid(row, col, gridData)
			if grid then
				-- 初始技能
				if ElementType["skill"] == grid:getShowElement():getType() then
					local elementId = grid:getShowElement():getData().id
					local skillId = self.mInitSkillIds[elementId]
					assert(skillId, "can not find init skill id, with element id "..elementId.." at ("..row..", "..col..")")
					grid:setElement(Factory:createSkillElement(skillId))
				end
				-- 初始格子(非障碍物)需要掉落表现
				if grid:isCanDrop() then
					dropCount = dropCount + 1
					Actions:dropOneGridHeight(grid:getShowElement():getSprite(), function()
						dropCount = dropCount - 1
						if 0 == dropCount and 0 == #bornCoordList then
							self.mGridController:arrangeGridList()
						end
					end)
				end
			end
		end
	end
	bornCoordList = self:getGridBornCoords()
	if 0 == #bornCoordList then
		return
	end
	self.mGridController:dropGridList(nil, nil, false)
end

-- 生成初始隔板
function BornController:generateInitBoard()
	local boardDatas = self.mGridController:getBoardDatas()
	for row, rowData in pairs(boardDatas) do
		for col, boardData in pairs(rowData) do
			for boardDirect, boardId in pairs(boardData) do
				self.mGridController:createBoard(row, col, boardDirect, boardId)
			end
		end
	end
end

-- 生成随机格子
function BornController:generateRandomGrid()
	local bornCoordList = self:getGridBornCoords()
	if 0 == #bornCoordList then
		return false
	end
	-- 计算特殊元素的初始位置
	local bornCoordInfoList = {}
	local specialElementIdList = self:getSpecialElementIdList()
	for i, specialElementId in pairs(specialElementIdList) do
		local bornCoordCount = #bornCoordList
		if bornCoordCount > 0 then
			local index = math.random(1, bornCoordCount)
			local bornCoordInfo = {
				coord = bornCoordList[index],
				special_id = specialElementId
			}
			table.remove(bornCoordList, index)
			table.insert(bornCoordInfoList, bornCoordInfo)
		end
	end
	for i, bornCoord in pairs(bornCoordList) do
		local bornCoordInfo = {
			coord = bornCoord,
			special_id = nil
		}
		table.insert(bornCoordInfoList, bornCoordInfo)
	end
	if 0 == #bornCoordInfoList then
		return false
	end
	-- 生成格子
	for i, bornCoordInfo in pairs(bornCoordInfoList) do
		local elementId, specialId = nil, bornCoordInfo.special_id
		if nil == specialId then	-- 普通元素
			elementId = self.mNormalElementProbability:getValue()
		else						-- 特殊元素
			elementId = self.mSpecialElementDrop[specialId].special_id
			self.mSpecialElementDrop[specialId].remain_count = self.mSpecialElementDrop[specialId].remain_count - 1
			self.mSpecialElementDrop[specialId].round = self.mCurrRound
			if self.mSpecialElementDrop[specialId].remain_count <= 0 then
				self.mSpecialElementDrop[specialId] = nil
			end
		end
		local grid = self.mGridController:createGrid(bornCoordInfo.coord.row, bornCoordInfo.coord.col, {elementId})
		grid:getNode():setVisible(false)
	end
	return true
end

-- 获取特殊元素格子
function BornController:getSpecialElementGrid(specialElementId)
	local gridNodes = self.mGridController:getGridNodes()
	for i, gridRow in pairs(gridNodes) do
		for j, grid in pairs(gridRow) do
			if grid:getShowElement() and specialElementId == grid:getShowElement():getData().id then
				return grid
			end
		end
	end
	return nil
end

-- 获取特殊元素id列表
function BornController:getSpecialElementIdList()
	local specialElementIdList = {}
	for specialId, info in pairs(self.mSpecialElementDrop) do
		-- 地图中无该特殊元素,且特殊元素个数>0,且达到
		if nil == self:getSpecialElementGrid(info.special_id) and info.remain_count > 0 and
			self.mCurrRound >= info.drop_round + info.round and CommonFunc:probability(info.probabilty) then
			table.insert(specialElementIdList, info.special_id)
		end
	end
	return specialElementIdList
end

-- 当前关卡场上最多数量的普通元素id
function BornController:getMaxCountNormalId()
	-- 计算普通元素数量
	local normalCountList = {}
	local gridDatas = self.mGridController:getGridDatas()
	for row, rowData in pairs(gridDatas) do
		for col, gridData in pairs(rowData) do
			local elementId = gridData[1]
			if Factory:isNormalId(elementId) then
				normalCountList[elementId] = (normalCountList[elementId] or 0) + 1
			end
		end
	end
	-- 筛选最多数量
	local elementIdList, maxCount = {}, 0
	for elementId, count in pairs(normalCountList) do
		if count > maxCount then
			maxCount = count
			elementIdList = {}
			table.insert(elementIdList, elementId)
		elseif count == maxCount then
			table.insert(elementIdList, elementId)
		end
	end
	return CommonFunc:getRandom(elementIdList) or 0
end

-- 获取优势元素
function BornController:getAdvantageNormalId()
	local colorList = {[2001] = "红色", [2002] = "黄色", [2003] = "绿色", [2004] = "蓝色", [2005] = "紫色"}
	local normalId = 0
	-- priority1:当前关卡所需收集元素中剩余最多者
	normalId = ModelCopy:getMaxRemainCountNormalGoal()
	if normalId > 0 then
		return normalId
	end
	-- priority2:当前关卡场上元素最多者
	normalId = self:getMaxCountNormalId()
	if normalId > 0 then
		return normalId
	end
	-- priority3:当前出场英雄中攻击力最高所代表的颜色元素
	normalId = self:getSibling("HeroController"):getMaxAttackNormalId()
	return normalId
end

-- 开启开局模式
function BornController:openStartMode()
	-- 挑战该关卡的失败次数>=开局触发_失败次数
	local failCount = DataMap:getCopyFailCount(self.mCopyId)
	if failCount < self.mDropInfo.start_fail_count then
		return false
	end
	-- 计算权重
	local originProbaility = CommonFunc:clone(self.mDropInfo.probability)
	local advantageId = self:getAdvantageNormalId()
	for index, weight in pairs(originProbaility) do
		if advantageId == weight[1] then
			-- 影响后的权重=影响前权重*开局影响_权重倍率
			originProbaility[index][2] = weight[2]*self.mDropInfo.start_weight_rate
		end
	end
	self.mNormalElementProbability = CreateProbability(originProbaility)
	return true
end

-- 开启常规模式
function BornController:openNormalMode()
	self.mNormalElementProbability = CreateProbability(self.mDropInfo.probability)
end

-- 开启尾数模式
function BornController:openEndMode()
	-- 挑战该关卡的失败次数>=尾数触发_失败次数
	local failCount = DataMap:getCopyFailCount(self.mCopyId)
	if failCount < self.mDropInfo.end_fail_count then
		return false
	end
	-- step1:计算生效步数,生效步数=理论步数+(该关卡的失败次数-尾数触发_失败次数)*尾数触发_步数步进
	local validSteps = self.mDropInfo.moves_theory + (failCount - self.mDropInfo.end_fail_count)*self.mDropInfo.moves_step
	-- step2:生效步数<尾数触发_步数控制,则取生效步数,否则生效步数=尾数触发_步数控制
	if validSteps > self.mDropInfo.moves_limit then
		validSteps = self.mDropInfo.moves_limit
	end
	-- 前剩余步数<=生效步数
	if ModelCopy:getMoves() > validSteps then
		return false
	end
	-- 计算权重
	local originProbaility = CommonFunc:clone(self.mDropInfo.probability)
	local advantageId = self:getAdvantageNormalId()
	for index, weight in pairs(originProbaility) do
		if advantageId == weight[1] then
			-- 影响后的权重=影响前权重*尾数影响_权重倍率
			originProbaility[index][2] = weight[2]*self.mDropInfo.end_weight_rate
		end
	end
	self.mNormalElementProbability = CreateProbability(originProbaility)
	return true
end

-- 处理回合结束事件
function BornController:handleRoundOver(isRoundValid)
	if isRoundValid then
		self.mCurrRound = self.mCurrRound + 1
	end
	-- 开局模式仅影响第一次的元素掉落,之后回复原有权重或尾数模式
	if not self:openEndMode() then
		self:openNormalMode()
	end
end

