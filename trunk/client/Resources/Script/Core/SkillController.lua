----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 技能控制器
----------------------------------------------------------------------
SkillController = class("SkillController", Component)

-- 构造函数
function SkillController:ctor()
	self.super:ctor(self.__cname)
	self.mTouchedInfoList = {}				-- 触摸信息表
	self.mAffectedInfoList = {}				-- 受技能影响信息表
	self.mAffectedBoardInfoList = {}		-- 受技能影响的隔板信息表
	self.mBombCount = 0						-- 当前消除的格子中的炸弹个数
	self.mSkillCount = 0					-- 当前消除的格子中的技能个数
end

-- 添加触摸信息
function SkillController:addTouchedInfo(grid)
	local elementType = grid:getShowElement():getType()
	-- 触摸信息
	local touchedInfo = {
		coord = grid:getCoord(),								-- 坐标
		element_id = grid:getShowElement():getData().id,		-- 元素id
		element_type = elementType,								-- 元素类型
	}
	if ElementType["skill"] == elementType then
		local skillId = grid:getShowElement():getPreSkillId()
		if 0 == skillId then
			skillId = grid:getShowElement():getSkillId()
		end
		touchedInfo.skill_id = skillId							-- 技能id
	end
	table.insert(self.mTouchedInfoList, touchedInfo)
end

-- 移除触摸信息
function SkillController:removeTouchedInfo(grid)
	for i, touchedInfo in pairs(self.mTouchedInfoList) do
		if Core:equalCoord(touchedInfo.coord, grid:getCoord()) then
			table.remove(self.mTouchedInfoList, i)
			return
		end
	end
end

-- 清除触摸信息
function SkillController:clearTouchedInfos()
	local gridController = self:getSibling("GridController")
	for i, touchedInfo in pairs(self.mTouchedInfoList) do
		local _, grid = gridController:getGrid(touchedInfo.coord.row, touchedInfo.coord.col)
		if grid then
			if ElementType["skill"] == grid:getShowElement():getType() then
				grid:getShowElement():exitTouch(grid)
			end
			if ElementType["normal"] == touchedInfo.element_type then
				grid:setElement(Factory:createElement(touchedInfo.element_id))
			elseif ElementType["skill"] == touchedInfo.element_type then
				grid:setElement(Factory:createSkillElement(touchedInfo.skill_id))
			end
		end
	end
	self.mTouchedInfoList = {}
end

-- 获取最新触摸信息
function SkillController:getLatestTouchedInfo()
	return self.mTouchedInfoList[#self.mTouchedInfoList]
end

-- 格子是否受影响
function SkillController:isAffected(grid)
	if nil == grid then return false end
	for i, affectedInfo in pairs(self.mAffectedInfoList) do
		if Core:equalCoord(grid:getCoord(), affectedInfo.coord) then
			return true
		end
	end
	return false
end

-- 格子是否受指定格子影响
function SkillController:isAffectedBy(grid, inflictGrid)
	if nil == grid then return false end
	inflictGrid = inflictGrid or grid
	for i, affectedInfo in pairs(self.mAffectedInfoList) do
		if Core:equalCoord(grid:getCoord(), affectedInfo.coord) then
			for j, inflictCoord in pairs(affectedInfo.inflict_coords) do
				if Core:equalCoord(inflictCoord, inflictGrid:getCoord()) then
					return true
				end
			end
			return false
		end
	end
	return false
end

-- 获取施加影响的格子
function SkillController:getInflictGrid(grid, inflictSkillType)
	if nil == grid then return nil end
	local gridController = self:getSibling("GridController")
	for i, affectedInfo in pairs(self.mAffectedInfoList) do
		if Core:equalCoord(grid:getCoord(), affectedInfo.coord) then
			for j, inflictCoord in pairs(affectedInfo.inflict_coords) do
				local _, inflictGrid = gridController:getGrid(inflictCoord.row, inflictCoord.col)
				if inflictGrid and inflictGrid:getShowElement() 
					and ElementType["skill"] == inflictGrid:getShowElement():getType() 
					and inflictSkillType == inflictGrid:getShowElement():getSubType() then
					return inflictGrid
				end
			end
			return nil
		end
	end
	return nil
end

-- 添加受影响格子
function SkillController:addAffectedInfo(grid, inflictGrid)
	if nil == grid or ElementType["obstacle"] == grid:getShowElement():getType() or
		self:getSibling("GridController"):isBornCoord(grid:getCoord()) then
		return
	end
	inflictGrid = inflictGrid or grid
	for i, affectedInfo in pairs(self.mAffectedInfoList) do
		if Core:equalCoord(grid:getCoord(), affectedInfo.coord) then
			for j, inflictCoord in pairs(affectedInfo.inflict_coords) do
				if Core:equalCoord(inflictGrid:getCoord(), inflictCoord) then
					return
				end
			end
			table.insert(affectedInfo.inflict_coords, inflictGrid:getCoord())
			return
		end
	end
	grid:onAffectEnter(2)
	grid:showTipCircle(true)
	local affectedInfo = {
		coord = grid:getCoord(),		-- 受影响格子坐标
		inflict_coords = {}				-- 施加影响格子坐标列表
	}
	table.insert(affectedInfo.inflict_coords, inflictGrid:getCoord())
	table.insert(self.mAffectedInfoList, affectedInfo)
	self:getSibling("GridController"):addPassiveCoord(grid:getCoord())
end

-- 移除受影响格子
function SkillController:removeAffectedInfo(grid, inflictGrid)
	if nil == grid then return end
	inflictGrid = inflictGrid or grid
	for i, affectedInfo in pairs(self.mAffectedInfoList) do
		if Core:equalCoord(grid:getCoord(), affectedInfo.coord) then
			for j, inflictCoord in pairs(affectedInfo.inflict_coords) do
				if Core:equalCoord(inflictGrid:getCoord(), inflictCoord) then
					table.remove(affectedInfo.inflict_coords, j)
					break
				end
			end
			if 0 == #affectedInfo.inflict_coords then
				grid:onAffectExit(2)
				grid:showTipCircle(false)
				table.remove(self.mAffectedInfoList, i)
				self:getSibling("GridController"):removePassiveCoord(grid:getCoord())
			end
			return
		end
	end
end

-- 清空受影响格子
function SkillController:clearAffectedInfos()
	local gridController = self:getSibling("GridController")
	for i, affectedInfo in pairs(self.mAffectedInfoList) do
		local _, grid = gridController:getGrid(affectedInfo.coord.row, affectedInfo.coord.col)
		if grid and grid:getShowElement() then
			if ElementType["skill"] == grid:getShowElement():getType() then
				grid:getShowElement():exitTouch(grid)
				if grid:getShowElement():getPreSkillId() > 0 then
					grid:setElement(Factory:createSkillElement(grid:getShowElement():getPreSkillId()))
				end
			end
			grid:onAffectExit(2)
			grid:showTipCircle(false)
		end
	end
	self.mAffectedInfoList = {}
end

-- 添加受影响隔板
function SkillController:addAffectedBoard(row, col, direct)
	for i, effectBoard in pairs(self.mAffectedBoardInfoList) do
		if row == effectBoard.row and col == effectBoard.col and direct == effectBoard.direct then
			effectBoard.relate_times = effectBoard.relate_times + 1
			return
		end
	end
	table.insert(self.mAffectedBoardInfoList, {row = row, col = col, direct = direct, relate_times = 1})
	self:getSibling("GridController"):addPassiveBoard(Core:makeCoord(row, col), direct)
end

-- 移除受影响隔板
function SkillController:removeAffectedBoard(row, col, direct)
	for i, effectBoard in pairs(self.mAffectedBoardInfoList) do
		if row == effectBoard.row and col == effectBoard.col and direct == effectBoard.direct then
			effectBoard.relate_times = effectBoard.relate_times - 1
			if effectBoard.relate_times <= 0 then
				table.remove(self.mAffectedBoardInfoList, i)
				self:getSibling("GridController"):removePassiveBoard(Core:makeCoord(row, col), direct)
			end
			return
		end
	end
end

-- 清空受影响隔板
function SkillController:clearAffectedBoardInfos()
	self.mAffectedBoardInfoList = {}
end

-- 自增炸弹个数
function SkillController:increaseBomb()
	self.mBombCount = self.mBombCount + 1
end

-- 自减炸弹个数
function SkillController:decreaseBomb()
	if self.mBombCount > 0 then
		self.mBombCount = self.mBombCount - 1
	end
end

-- 是否有炸弹
function SkillController:existBomb()
	return self.mBombCount > 0
end

-- 自增技能个数
function SkillController:increaseSkill()
	self.mSkillCount = self.mSkillCount + 1
end

-- 自减技能个数
function SkillController:decreaseSkill()
	if self.mSkillCount > 0 then
		self.mSkillCount = self.mSkillCount - 1
	end
end

-- 是否有技能
function SkillController:existSkill()
	return self.mSkillCount > 0
end

-- 开始触摸
function SkillController:beginTouch(grid)
	self.mBombCount = 0
	self.mSkillCount = 0
	self:addTouchedInfo(grid)
	if ElementType["skill"] == grid:getShowElement():getType() then
		self:addAffectedInfo(grid, nil)
		grid:getShowElement():enterTouch(grid, nil)
	end
end

-- 移动前进
function SkillController:moveAdvance(preGrid, grid)
	self:addTouchedInfo(grid)
	if ElementType["normal"] == grid:getShowElement():getType() then	-- 当前格子是普通元素
		if grid:getFixedElement() or ElementType["normal"] == preGrid:getShowElement():getType() or not preGrid:isCanTouch() then
			return
		end
		self:removeAffectedInfo(preGrid, nil)
		self:addAffectedInfo(grid, nil)
		local preSkillId = preGrid:getShowElement():getPreSkillId()
		local skillId = preGrid:getShowElement():getSkillId()
		-- 前一格设置为普通元素
		preGrid:getShowElement():exitTouch(preGrid)
		preGrid:setElement(Factory:createElement(grid:getShowElement():getData().id))
		preGrid:onSelectEnter()
		-- 如果当前格不被影响,则使用原始的技能id
		local skillElement = nil
		if preSkillId > 0 and not self:isAffected(grid) then
			skillElement = Factory:createSkillElement(preSkillId)
		else
			skillElement = Factory:createSkillElement(skillId)
			skillElement:setPreSkillId(preSkillId)
		end
		-- 当前格设置为技能元素
		grid:setElement(skillElement)
		grid:getShowElement():enterTouch(grid, nil)
		grid:onSelectEnter()
	elseif ElementType["skill"] == grid:getShowElement():getType() then	-- 当前格子是技能元素
		self:addAffectedInfo(grid, nil)
		grid:getShowElement():enterTouch(grid, nil)
	end
end

-- 移动后退
function SkillController:moveBack(grid, removeGrid)
	local latestTouchedInfo = self:getLatestTouchedInfo()
	self:removeTouchedInfo(removeGrid)
	if ElementType["normal"] == latestTouchedInfo.element_type then		-- 移除格子是普通元素
		if ElementType["skill"] == removeGrid:getShowElement():getType() then
			self:removeAffectedInfo(removeGrid, nil)
			self:addAffectedInfo(grid, nil)
			local preSkillId = removeGrid:getShowElement():getPreSkillId()
			local skillId = removeGrid:getShowElement():getSkillId()
			-- 移除格子恢复为普通元素
			removeGrid:getShowElement():exitTouch(removeGrid)
			removeGrid:setElement(Factory:createElement(latestTouchedInfo.element_id))
			-- 如果当前格不被影响,则使用原始的技能id
			local skillElement = nil
			if preSkillId > 0 and not self:isAffected(grid) then
				skillElement = Factory:createSkillElement(preSkillId)
			else
				skillElement = Factory:createSkillElement(skillId)
				skillElement:setPreSkillId(preSkillId)
			end
			-- 设置当前格为技能元素
			grid:setElement(skillElement)
			grid:getShowElement():enterTouch(grid, nil)
			grid:onSelectEnter()
		end
	elseif ElementType["skill"] == latestTouchedInfo.element_type then	-- 移除格子是技能元素
		self:removeAffectedInfo(removeGrid, nil)
		if ElementType["skill"] == removeGrid:getShowElement():getType() then
			if not self:isAffected(removeGrid) then
				removeGrid:getShowElement():exitTouch(removeGrid)
			end
		else
			-- 移除格子恢复为技能元素
			removeGrid:setElement(Factory:createSkillElement(latestTouchedInfo.skill_id))
			if self:isAffected(removeGrid) then
				removeGrid:getShowElement():enterTouch(grid)
				removeGrid:onSelectEnter()
			end
		end
	end
end

-- 移动触摸
function SkillController:moveTouch(preGrid, grid, removeGrid)
	if nil == removeGrid then		-- 前进
		self:moveAdvance(preGrid, grid)
	else							-- 回退
		self:moveBack(grid, removeGrid)
	end
end

-- 结束触摸
function SkillController:endTouch()
	self:clearAffectedBoardInfos()
	self:clearAffectedInfos()
	self:clearTouchedInfos()
end

