----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 出生控制器
----------------------------------------------------------------------
BornController = class("BornController", Component)

-- 构造函数
function BornController:ctor()
	self.super:ctor(self.__cname)
	self.mInitSkillIds = {}						-- 初始的技能数据列表
	self.mNormalElementProbability = nil		-- 普通元素随机概率
	self.mSpecialElementDrop = {}				-- 特殊元素个数及出现概率
	self.mCurrRound = 0							-- 当前回合数
	-- 注册事件
	self:subscribeEvent(EventDef["ED_ROUND_OVER"], self.handleRoundOver)
end

-- 初始化
function BornController:init(initSkills, bornRates, specialElementDropList)
	for i, skillId in pairs(initSkills) do
		local skillData = LogicTable:get("skill_tplt", skillId, true)
		self.mInitSkillIds[skillData.element_id] = skillId
	end
	self.mNormalElementProbability = Probability.new(bornRates)
	for i, specialElementDrop in pairs(specialElementDropList) do
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
	local gridDatas = self:getSibling("GridController"):getGridDatas()
	local boardDatas = self:getSibling("GridController"):getBoardDatas()
	local bornCoords = self:getSibling("GridController"):getBornCoords()
	local bornCoordList = {}
	for i, bornCoord in pairs(bornCoords) do
		-- 出生位置没有格子,且下方格子有效
		if (nil == gridDatas[bornCoord.row] or nil == gridDatas[bornCoord.row][bornCoord.col] or
			nil == gridDatas[bornCoord.row][bornCoord.col][1] or gridDatas[bornCoord.row][bornCoord.col][1] <=0) and
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
	self:getSibling("GridController"):setTouchEnabled(false)
	local bornCoordList = {}
	local dropCount = 0
	local gridDatas = self:getSibling("GridController"):getGridDatas()
	for row, rowData in pairs(gridDatas) do
		for col, gridData in pairs(rowData) do
			local grid = self:getSibling("GridController"):createGrid(row, col, gridData)
			-- 初始格子(非障碍物)需要掉落表现
			if grid and grid:isCanDrop() then
				-- 初始技能
				if ElementType["skill"] == grid:getShowElement():getType() then
					local elementId = grid:getShowElement():getData().id
					local skillId = self.mInitSkillIds[elementId]
					assert(skillId, "can not find init skill id, with element id "..elementId.." at ("..row..", "..col..")")
					grid:setElement(Factory:createSkillElement(skillId))
				end
				dropCount = dropCount + 1
				Actions:dropOneGridHeight(grid:getShowElement():getSprite(), function()
					dropCount = dropCount - 1
					if 0 == dropCount and 0 == #bornCoordList then
						self:getSibling("GridController"):arrangeGridList()
					end
				end)
			end
		end
	end
	bornCoordList = self:getGridBornCoords()
	if 0 == #bornCoordList then
		return
	end
	self:getSibling("GridController"):startDropGridList(nil, nil, false)
end

-- 生成初始隔板
function BornController:generateInitBoard()
	local boardDatas = self:getSibling("GridController"):getBoardDatas()
	for row, rowData in pairs(boardDatas) do
		for col, boardData in pairs(rowData) do
			for boardDirect, boardId in pairs(boardData) do
				self:getSibling("GridController"):createBoard(row, col, boardDirect, boardId)
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
		if #bornCoordList > 0 then
			local index = math.random(1, #bornCoordList)
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
	-- 生成格子
	for i, bornCoordInfo in pairs(bornCoordInfoList) do
		local elementId, specialId = nil, bornCoordInfo.special_id
		if nil == specialId then	-- 普通元素
			elementId = self.mNormalElementProbability:getValue()
		else						-- 特殊元素
			elementId = self.mSpecialElementDrop[specialId].special_id
			self.mSpecialElementDrop[specialId].remain_count = self.mSpecialElementDrop[specialId].remain_count - 1
			self.mSpecialElementDrop[specialId].round = self.mCurrRound
		end
		local grid = self:getSibling("GridController"):createGrid(bornCoordInfo.coord.row, bornCoordInfo.coord.col, {elementId})
		grid:getNode():setVisible(false)
	end
	return true
end

-- 获取特殊元素格子
function BornController:getSpecialElementGrid(specialElementId)
	local gridNodes = self:getSibling("GridController"):getGridNodes()
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

-- 处理回合结束事件
function BornController:handleRoundOver(isRoundValid)
	if isRoundValid then
		self.mCurrRound = self.mCurrRound + 1
	end
end

