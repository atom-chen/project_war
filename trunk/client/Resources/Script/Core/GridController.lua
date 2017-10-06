----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 格子控制器
----------------------------------------------------------------------
GridController = class("GridController", Component)

-- 构造函数
function GridController:ctor()
	self.super:ctor(self.__cname)
	self.mRow = 0							-- 行数
	self.mCol = 0							-- 列数
	self.mGridDatas = {}					-- 格子数据表
	self.mGridNodes = {}					-- 格子节点表
	self.mBoardDatas = {}					-- 隔板数据表
	self.mBoardNodes = {}					-- 隔板节点表
	self.mBornCoords = {}					-- 出生坐标表
	self.mMinCountList = {}					-- 元素最少收集个数表
	self.mTouchedType = 0					-- 被触摸的普通元素类型
	self.mTouchedCoordList = {}				-- 被触摸的格子坐标列表
	self.mPassiveCoordList = {}				-- 被影响的格子坐标列表
	self.mPassiveBoardList = {}				-- 被影响的隔板信息列表
	self.mBombCoordList = {}				-- 被触发的炸弹坐标列表
end

-- 初始化
function GridController:init(gridFile, boardFile, bornPosList)
	self.mRow, self.mCol = self:getMaster():getRowCol()
	-- 初始格子
	for row=1, self.mRow do
		self.mGridDatas[row] = {}
		self.mGridNodes[row] = {}
		for col=1, self.mCol do
			self.mGridDatas[row][col] = {0}
			self.mGridNodes[row][col] = nil
		end
	end
	-- 加载初始格子数据
	if gridFile then
		LogicTable:loadData(gridFile)
		local allData = LogicTable:getAll(gridFile)
		for row, rowData in pairs(allData) do
			for col, colData in pairs(rowData) do
				self.mGridDatas[tonumber(row)][tonumber(col)] = colData
			end
		end
	end
	-- 初始隔板
	for row=1, self.mRow + 1 do
		self.mBoardDatas[row] = {}
		self.mBoardNodes[row] = {}
		for col=1, self.mCol + 1 do
			self.mBoardDatas[row][col] = {0, 0}
			self.mBoardNodes[row][col] = {nil, nil}
		end
	end
	-- 加载初始隔板数据
	if boardFile then
		LogicTable:loadData(boardFile)
		local allData = LogicTable:getAll(boardFile)
		for row, rowData in pairs(allData) do
			for col, boardData in pairs(rowData) do
				self.mBoardDatas[tonumber(row)][tonumber(col)] = boardData
			end
		end
	end
	-- 初始出生坐标
	for i, bornPos in pairs(bornPosList) do
		table.insert(self.mBornCoords, Core:makeCoord(bornPos[1], bornPos[2]))
	end
end

-- 开始触摸
function GridController:onTouchBegan(touch, event, gridInfo)
	if not self:isTouchEnabled() then return end
	-- 触摸第一行无效
	if nil == gridInfo or 1 == gridInfo.row then
		return
	end
	-- 格子为空|格子不可触摸
	local _, grid = self:getGrid(gridInfo.row, gridInfo.col)
	if nil == grid or not grid:isCanTouch() then
		return
	end
	-- 格子显示元素类型判断
	if ElementType["normal"] == grid:getShowElement():getType() then
		self.mTouchedType = grid:getShowElement():getSubType()
	elseif ElementType["skill"] == grid:getShowElement():getType() then
		self.mTouchedType = grid:getShowElement():getExtraType()
	else
		self.mTouchedType = 0
		return
	end
	local touchedMinCount = self:getMinCollect(self.mTouchedType)
	-- 计算消除信息
	table.insert(self.mTouchedCoordList, grid:getCoord())
	self:getSibling("SkillController"):beginTouch(grid)
	grid:onSelectEnter()
	local clearInfo = self:calcClearInfo(self.mTouchedType, touchedMinCount, self.mTouchedCoordList, self.mPassiveCoordList, self.mPassiveBoardList, true)
	EventCenter:post(EventDef["ED_TOUCH_GRID_BEGIN"], clearInfo)
end

-- 移动触摸
function GridController:onTouchMoved(touch, event, gridInfo)
	if not self:isTouchEnabled() then return end
	-- 触摸第一行无效
	if nil == gridInfo or 1 == gridInfo.row then
		return
	end
	-- 格子为空
	local _, grid = self:getGrid(gridInfo.row, gridInfo.col)
	if nil == grid then
		return
	end
	local touchedCount = #self.mTouchedCoordList
	if 0 == touchedCount then
		self:onTouchBegan(touch, event, gridInfo)
		return
	end
	-- 格子可连接判断
	local preTouchedCoord = self.mTouchedCoordList[touchedCount - 1]
	local curTouchedCoord = self.mTouchedCoordList[touchedCount]
	local _, curTouchedGrid = self:getGrid(curTouchedCoord.row, curTouchedCoord.col)
	if not self:canConnect(curTouchedGrid, grid) then
		return
	end
	local touchedMinCount = self:getMinCollect(self.mTouchedType)
	-- 格子已经被触摸
	if self:isTouchedCoord(Core:makeCoord(gridInfo.row, gridInfo.col)) then
		if preTouchedCoord and preTouchedCoord.row == gridInfo.row and preTouchedCoord.col == gridInfo.col then
			-- 计算消除信息
			self.mTouchedCoordList[touchedCount] = nil
			touchedCount = touchedCount - 1
			preTouchedCoord = self.mTouchedCoordList[touchedCount - 1]
			if nil == preTouchedCoord then
				self:getSibling("SkillController"):moveTouch(nil, grid, curTouchedGrid)
			else
				local _, preTouchGrid = self:getGrid(preTouchedCoord.row, preTouchedCoord.col)
				self:getSibling("SkillController"):moveTouch(preTouchGrid, grid, curTouchedGrid)
			end
			curTouchedGrid:onSelectExit()
			local clearInfo = self:calcClearInfo(self.mTouchedType, touchedMinCount, self.mTouchedCoordList, self.mPassiveCoordList, self.mPassiveBoardList, false)
			EventCenter:post(EventDef["ED_TOUCH_GRID_MOVE"], clearInfo)
		end
		return
	end
	-- 计算消除信息
	table.insert(self.mTouchedCoordList, grid:getCoord())
	touchedCount = touchedCount + 1
	preTouchedCoord = self.mTouchedCoordList[touchedCount - 1]
	local _, preTouchGrid = self:getGrid(preTouchedCoord.row, preTouchedCoord.col)
	self:getSibling("SkillController"):moveTouch(preTouchGrid, grid, nil)
	grid:onSelectEnter()
	local clearInfo = self:calcClearInfo(self.mTouchedType, touchedMinCount, self.mTouchedCoordList, self.mPassiveCoordList, self.mPassiveBoardList, true)
	EventCenter:post(EventDef["ED_TOUCH_GRID_MOVE"], clearInfo)
end

-- 结束触摸
function GridController:onTouchEnded(touch, event, gridInfo)
	if not self:isTouchEnabled() then return end
	if 0 == #self.mTouchedCoordList then
		return
	end
	local touchedMinCount = self:getMinCollect(self.mTouchedType)
	if gridInfo and gridInfo.min_collect and touchedMinCount < gridInfo.min_collect then
		touchedMinCount = gridInfo.min_collect
	end
	if #self.mTouchedCoordList < touchedMinCount then
		for i, coord in pairs(self.mTouchedCoordList) do
			local _, grid = self:getGrid(coord.row, coord.col)
			grid:onSelectExit()
		end
	end
	-- 计算消除信息
	local clearInfo = self:calcClearInfo(self.mTouchedType, touchedMinCount, self.mTouchedCoordList, self.mPassiveCoordList, self.mPassiveBoardList, false)
	if #self.mBombCoordList > 0 then	-- 炸弹消除
		self:clearAllGrid(clearInfo, 1, self.mBombCoordList[1])
	else								-- 普通消除
		self:clearGridList(clearInfo, 1)
	end
	self.mTouchedCoordList = {}
	self.mPassiveCoordList = {}
	self.mPassiveBoardList = {}
	self.mBombCoordList = {}
	self:getSibling("SkillController"):endTouch()
	EventCenter:post(EventDef["ED_TOUCH_GRID_END"], clearInfo)
end

-- 取消触摸
function GridController:onTouchCancelled(touch, event, gridInfo)
	self:onTouchEnded(touch, event, gridInfo)
end

-- 消除指定格子
function GridController:clearGrid(coord)
	local _, grid = self:getGrid(coord.row, coord.col)
	if nil == grid then
		return
	end
	if ElementType["normal"] == grid:getShowElement():getType() then
		self.mTouchedType = grid:getShowElement():getSubType()
	elseif ElementType["skill"] == grid:getShowElement():getType() then
		self.mTouchedType = grid:getShowElement():getExtraType()
	else
		self.mTouchedType = 0
		return
	end
	table.insert(self.mTouchedCoordList, coord)
	self:getSibling("SkillController"):beginTouch(grid)
	local clearInfo = self:calcClearInfo(self.mTouchedType, 1, self.mTouchedCoordList, self.mPassiveCoordList, self.mPassiveBoardList, false)
	if #self.mBombCoordList > 0 then	-- 炸弹消除
		self:clearAllGrid(clearInfo, 2, self.mBombCoordList[1])
	else								-- 普通消除
		self:clearGridList(clearInfo, 2)
	end
	self.mTouchedCoordList = {}
	self.mPassiveCoordList = {}
	self.mPassiveBoardList = {}
	self.mBombCoordList = {}
	self:getSibling("SkillController"):endTouch()
end

-- 添加被影响格子坐标
function GridController:addPassiveCoord(coord)
	if self:isTouchedCoord(coord) then
		return
	end
	Core:addCoord(self.mPassiveCoordList, coord)
end

-- 移除被影响格子坐标
function GridController:removePassiveCoord(coord)
	Core:removeCoord(self.mPassiveCoordList, coord)
end

-- 添加被影响隔板信息
function GridController:addPassiveBoard(coord, direct)
	Core:addBoardInfo(self.mPassiveBoardList, coord, direct)
end

-- 移除被影响隔板信息
function GridController:removePassiveBoard(coord, direct)
	Core:removeBoardInfo(self.mPassiveBoardList, coord, direct)
end

-- 添加被触发炸弹坐标
function GridController:addBombCoord(coord)
	Core:addCoord(self.mBombCoordList, coord)
end

-- 移除被触发炸弹坐标
function GridController:removeBombCoord(coord)
	Core:removeCoord(self.mBombCoordList, coord)
end

-- 获取格子数据
function GridController:getGridDatas()
	return self.mGridDatas
end

-- 获取格子节点,不包括出生点
function GridController:getGridNodes()
	return self.mGridNodes
end

-- 获取隔板数据
function GridController:getBoardDatas()
	return self.mBoardDatas
end

-- 获取隔板节点
function GridController:getBoardNodes()
	return self.mBoardNodes
end

-- 获取出生坐标
function GridController:getBornCoords()
	return self.mBornCoords
end

-- 是否出生坐标
function GridController:isBornCoord(coord)
	return Core:isCoordExist(self.mBornCoords, coord)
end

-- 设置最少收集个数
function GridController:setMinCollect(normalType, minCollect)
	self.mMinCountList[normalType] = minCollect
end

-- 获取最少收集个数
function GridController:getMinCollect(normalType)
	return self.mMinCountList[normalType] or 0
end

-- 获取被触摸普通元素类型
function GridController:getTouchedType()
	return self.mTouchedType
end

-- 获取被触摸的坐标
function GridController:getTouchedCoordList()
	return self.mTouchedCoordList
end

-- 坐标是否被触摸
function GridController:isTouchedCoord(coord)
	return Core:isCoordExist(self.mTouchedCoordList, coord)
end

-- 坐标是否被影响
function GridController:isPassiveCoord(coord)
	return Core:isCoordExist(self.mPassiveCoordList, coord)
end

-- 隔板是否被影响
function GridController:isPassiveBoard(coord, direct)
	return Core:isBoardInfoExist(self.mPassiveBoardList, coord, direct)
end

-- 创建格子
function GridController:createGrid(row, col, gridData)
	if gridData[1] <= 0 then
		return nil
	end
	local gridPos = self:getMaster():getGridPos(row, col)
	local grid = Grid.new()
	grid:setController(self)
	grid:setCoord(row, col)
	grid:getNode():setPosition(cc.p(gridPos.x, gridPos.y))
	-- 设置格子元素列表
	for i, elementId in pairs(gridData) do
		if elementId > 0 then
			grid:setElement(Factory:createElement(elementId))
		end
	end
	assert(grid:getShowElement(), "show element is null at ("..row..", "..col..")")
	self:getMaster():getMapLayer():addChild(grid:getNode(), G.MAP_ZORDER_GRID)
	self:setGrid(row, col, gridData, grid)
	return grid
end

-- 创建隔板
function GridController:createBoard(row, col, direct, boardId)
	if boardId <= 0 then
		return nil
	end
	local gridPos = nil
	if row > self.mRow and col > self.mCol then
		gridPos = self:getMaster():getGridPos(row - 1, col - 1)
	elseif row > self.mRow and col <= self.mCol then
		gridPos = self:getMaster():getGridPos(row - 1, col)
	elseif row <= self.mRow and col > self.mCol then
		gridPos = self:getMaster():getGridPos(row, col - 1)
	elseif row <= self.mRow and col <= self.mCol then
		gridPos = self:getMaster():getGridPos(row, col)
	end
	local boardElement = Factory:createElement(boardId)
	local boardPos = nil
	if BoardDirectType["vertical"] == direct then
		if col > self.mCol then
			boardPos = gridPos.right
		else
			boardPos = gridPos.left
		end
	elseif BoardDirectType["horizontal"] == direct then
		if row > self.mRow then
			boardPos = gridPos.down
		else
			boardPos = gridPos.up
		end
	end
	boardElement:setCoord(row, col)
	boardElement:getSprite():setPosition(boardPos)
	self:getMaster():getMapLayer():addChild(boardElement:getSprite(), G.MAP_ZORDER_BOARD)
	self:setBoard(row, col, direct, boardId, boardElement)
	return boardElement
end

-- 消除隔板
function GridController:clearBoard(boardElement, isForce)
	if nil == boardElement or not boardElement:isCanClear() then
		return
	end
	local boardData = boardElement:getData()
	local coord = boardElement:getCoord()
	local direct = boardElement:getExtraType()
	-- 非强力消除,且隔板消除后有指向下个隔板,且隔板不被影响
	if not isForce and boardData and boardData.next_id > 0 and not self:isPassiveBoard(coord, direct) then
		self:createBoard(coord.row, coord.col, direct, boardData.next_id)
	else
		self:setBoard(coord.row, coord.col, direct, nil, nil)
	end
	local xPos, yPos = boardElement:getSprite():getPosition()
	local param = {
		pos = cc.p(xPos, yPos),							-- 位置坐标
		parent = boardElement:getSprite():getParent()	-- 父节点
	}
	boardElement:clear(param, nil, nil, nil)
end

-- 设置格子
function GridController:setGrid(row, col, gridData, gridNode)
	if nil == self.mGridDatas[row] or nil == self.mGridNodes[row] then
		return
	end
	self.mGridDatas[row][col] = gridData or {0}
	self.mGridNodes[row][col] = gridNode
end

-- 获取格子
function GridController:getGrid(row, col)
	if nil == self.mGridDatas[row] or nil == self.mGridNodes[row] then
		return nil
	end
	return self.mGridDatas[row][col], self.mGridNodes[row][col]
end

-- 设置隔板
function GridController:setBoard(row, col, direct, boardId, boardElement)
	if nil == self.mBoardDatas[row] or nil == self.mBoardDatas[row][col] or 
		nil == self.mBoardNodes[row] or nil == self.mBoardNodes[row][col] then
		return
	end
	self.mBoardDatas[row][col][direct] = boardId or 0
	self.mBoardNodes[row][col][direct] = boardElement
end

-- 获取隔板
function GridController:getBoard(row, col, direct)
	if nil == self.mBoardDatas[row] or nil == self.mBoardDatas[row][col] or 
		nil == self.mBoardNodes[row] or nil == self.mBoardNodes[row][col] then
		return nil
	end
	return self.mBoardDatas[row][col][direct], self.mBoardNodes[row][col][direct]
end

-- 获取格子四周格子
function GridController:getAroundGrids(coord)
	local aroundGrids = {
		up = self.mGridNodes[coord.row - 1] and self.mGridNodes[coord.row - 1][coord.col] or nil,	-- 正上方格子
		right = self.mGridNodes[coord.row][coord.col + 1],											-- 正右方格子
		down = self.mGridNodes[coord.row + 1] and self.mGridNodes[coord.row + 1][coord.col] or nil,	-- 正下方格子
		left = self.mGridNodes[coord.row][coord.col - 1]											-- 正左方格子
	}
	return aroundGrids
end

-- 获取格子周围格子
function GridController:getAllAroundGrids(coord)
	local aroundGrids = self:getAroundGrids(coord)
	aroundGrids.left_up = self.mGridNodes[coord.row - 1] and self.mGridNodes[coord.row - 1][coord.col - 1] or nil		-- 左上方格子
	aroundGrids.right_up = self.mGridNodes[coord.row - 1] and self.mGridNodes[coord.row - 1][coord.col + 1] or nil		-- 右上方格子
	aroundGrids.left_down = self.mGridNodes[coord.row + 1] and self.mGridNodes[coord.row + 1][coord.col - 1] or nil		-- 左下方格子
	aroundGrids.right_down = self.mGridNodes[coord.row + 1] and self.mGridNodes[coord.row + 1][coord.col + 1] or nil	-- 右下方格子
	return aroundGrids
end

-- 获取格子四周可影响格子
function GridController:getAffectedAroundGrids(coord)
	local affectedAroundGrids = {}
	local aroundGrids = self:getAroundGrids(coord)
	for i, aroundGrid in pairs(aroundGrids) do
		if aroundGrid and Core:isCanContact(aroundGrid:getCoord(), coord, self.mBoardDatas) then
			local showElementType = aroundGrid:getShowElement():getType()
			if ElementType["normal"] == showElementType or ElementType["skill"] == showElementType then
				if aroundGrid:getFixedElement() or aroundGrid:getCoverElement() then
					table.insert(affectedAroundGrids, aroundGrid)
				end
			elseif ElementType["throw"] == showElementType then
				table.insert(affectedAroundGrids, aroundGrid)
			elseif ElementType["special"] == showElementType then
				if ElementSpecialType["bomb"] == aroundGrid:getShowElement():getSubType() then
					if aroundGrid:getFixedElement() or aroundGrid:getCoverElement() then
						table.insert(affectedAroundGrids, aroundGrid)
					end
				else
					table.insert(affectedAroundGrids, aroundGrid)
				end
			end
		end
	end
	return affectedAroundGrids
end

-- 获取格子四周隔板
function GridController:getAroundBoards(coord)
	local aroundBoards = {
		up = self.mBoardNodes[coord.row][coord.col][BoardDirectType["horizontal"]],			-- 上方隔板
		right = self.mBoardNodes[coord.row][coord.col + 1][BoardDirectType["vertical"]],	-- 右方隔板
		down = self.mBoardNodes[coord.row + 1][coord.col][BoardDirectType["horizontal"]],	-- 下方隔板
		left = self.mBoardNodes[coord.row][coord.col][BoardDirectType["vertical"]]			-- 左方隔板
	}
	return aroundBoards
end

-- 两个格子是否可以连接
function GridController:canConnect(grid1, grid2)
	if nil == grid1 or not grid1:isCanConnect() or nil == grid2 or not grid2:isCanConnect() then
		return false
	end
	if not Core:isCanContact(grid1:getCoord(), grid2:getCoord(), self.mBoardDatas) then
		return false
	end
	local showElementType1 = grid1:getShowElement():getType()
	local showElementType2 = grid2:getShowElement():getType()
	if (ElementType["normal"] ~= showElementType1 and ElementType["skill"] ~= showElementType1) or
		(ElementType["normal"] ~= showElementType2 and ElementType["skill"] ~= showElementType2) or
		(grid1:getCoverElement() or grid2:getCoverElement()) then
		return false
	end
	local normalType1 = grid1:getShowElement():getSubType()
	if ElementType["skill"] == showElementType1 then
		normalType1 = grid1:getShowElement():getExtraType()
	end
	local normalType2 = grid2:getShowElement():getSubType()
	if ElementType["skill"] == showElementType2 then
		normalType2 = grid2:getShowElement():getExtraType()
	end
	return normalType1 == normalType2
end

-- 增加元素个数
function GridController:increaseElementCount(totalCountList, normalCountList, skillCountList, grid)
	if nil == grid or nil == grid:getShowElement() or grid:isBorn() then
		return
	end
	local showElement = grid:getShowElement()
	local showElementType = showElement:getType()
	if ElementType["normal"] == showElementType then
		local showElementSubType = showElement:getSubType()
		Core:increaseCount(totalCountList, showElementSubType)
		Core:increaseCount(normalCountList, showElementSubType)
	elseif ElementType["skill"] == showElementType then
		local showElementExtraType = showElement:getExtraType()
		Core:increaseCount(totalCountList, showElementExtraType)
		if showElement:isCanTouch() then
			Core:increaseCount(skillCountList, showElementExtraType)
		else
			Core:increaseCount(normalCountList, showElementExtraType)
		end
	end
end

-- 计算消除信息
function GridController:calcClearInfo(touchedType, touchedMinCount, touchedCoordList, passiveCoordList, passiveBoardList, touchedAdvance)
	local clearInfo = {					-- 消除信息
		touched_type = touchedType,								-- 触摸类型
		touched_min_count = touchedMinCount,					-- 触摸最少需要个数
		touched_coord_list = touchedCoordList,					-- 触摸坐标列表
		touched_count = #touchedCoordList,						-- 触摸个数
		touched_advance = touchedAdvance,						-- 触摸前进:true.前进,false.后退
		affected_coord_list = {},								-- 受影响的坐标列表
		affected_board_list = {},								-- 受影响的隔板列表
		total_count_list = {},									-- 元素个数列表(普通元素+技能元素)
		normal_count_list = {},									-- 普通元素个数列表
		skill_count_list = {},									-- 技能元素个数列表
		can_clear_flag = #touchedCoordList >= touchedMinCount,	-- 可消除标识:true.可消除,false.不可消除
	}
	-- 有炸弹
	if #self.mBombCoordList > 0 then
		for row, rowGrids in pairs(self.mGridNodes) do
			for col, grid in pairs(rowGrids) do
				self:increaseElementCount(clearInfo.total_count_list, clearInfo.normal_count_list, clearInfo.skill_count_list, grid)
			end
		end
		return clearInfo
	end
	-- 被触摸的格子
	for i, coord in pairs(touchedCoordList) do
		local _, grid = self:getGrid(coord.row, coord.col)
		if nil == grid:getFixedElement() and nil == grid:getCoverElement() then
			self:increaseElementCount(clearInfo.total_count_list, clearInfo.normal_count_list, clearInfo.skill_count_list, grid)
		end
		local affectedAroundGrids = self:getAffectedAroundGrids(coord)
		for i, affectedGrid in pairs(affectedAroundGrids) do			-- 格子
			local gridCoord = affectedGrid:getCoord()
			if not self:isTouchedCoord(gridCoord) and not (affectedGrid:getFixedElement() and nil == affectedGrid:getCoverElement()) then
				Core:addCoord(clearInfo.affected_coord_list, gridCoord)
			end
		end
		local aroundBoards = self:getAroundBoards(coord)		-- 隔板
		for i, board in pairs(aroundBoards) do
			Core:addBoardInfo(clearInfo.affected_board_list, board:getCoord(), board:getExtraType())
		end
	end
	-- 受影响的格子
	for i, coord in pairs(passiveCoordList) do
		if not self:isTouchedCoord(coord) then
			local _, grid = self:getGrid(coord.row, coord.col)
			Core:addCoord(clearInfo.affected_coord_list, coord)
			if nil == grid:getFixedElement() and nil == grid:getCoverElement() then
				self:increaseElementCount(clearInfo.total_count_list, clearInfo.normal_count_list, clearInfo.skill_count_list, grid)
				local showElementType = grid:getShowElement():getType()
				if (ElementType["normal"] == showElementType or ElementType["skill"] == showElementType) then
					local affectedAroundGrids = self:getAffectedAroundGrids(coord)
					for i, affectedGrid in pairs(affectedAroundGrids) do		-- 格子
						local gridCoord = affectedGrid:getCoord()
						if not self:isTouchedCoord(gridCoord) and not (affectedGrid:getFixedElement() and nil == affectedGrid:getCoverElement()) then
							Core:addCoord(clearInfo.affected_coord_list, gridCoord)
						end
					end
				end
				if ElementType["obstacle"] ~= showElementType then
					local aroundBoards = self:getAroundBoards(coord)	-- 隔板
					for i, board in pairs(aroundBoards) do
						Core:addBoardInfo(clearInfo.affected_board_list, board:getCoord(), board:getExtraType())
					end
				end
			end
		end
	end
	-- 受影响的格子
	for i, boardInfo in pairs(passiveBoardList) do
		Core:addBoardInfo(clearInfo.affected_board_list, boardInfo.coord, boardInfo.direct)
	end
	return clearInfo
end

-- 根据格子坐标列表消除格子
function GridController:clearGridList(clearInfo, clearType)
	if not clearInfo.can_clear_flag or 0 == clearInfo.touched_count then
		return
	end
	-- 预设置
	self:setTouchEnabled(false)
	-- cclog("================================================ clear grid list begin")
	EventCenter:post(EventDef["ED_CLEAR_BEGIN"])
	-- 格子消除回调
	local totalClearCount = clearInfo.touched_count + #clearInfo.affected_coord_list
	local totalElementDatas = {}
	local function clearCF(elementDataList)
		EventCenter:post(EventDef["ED_CLEAR_GRID"], elementDataList)
		for i, elementData in pairs(elementDataList) do
			table.insert(totalElementDatas, elementData)
		end
		totalClearCount = totalClearCount - 1
		if totalClearCount > 0 then
			return
		end
		-- 格子全部消除结束
		-- cclog("================================================ clear grid list end")
		EventCenter:post(EventDef["ED_CLEAR_END"], totalElementDatas)
	end
	-- step1:消除受影响的隔板
	for i, boardInfo in pairs(clearInfo.affected_board_list) do
		local _, board = self:getBoard(boardInfo.coord.row, boardInfo.coord.col, boardInfo.direct)
		self:clearBoard(board, false)
	end
	-- step2:消除被触摸的格子
	for i, coord in pairs(clearInfo.touched_coord_list) do
		local _, grid = self:getGrid(coord.row, coord.col)
		if nil == grid then
			clearCF({})
		else
			grid:onClear(clearCF, i, false, clearType)
		end
	end
	-- step3:消除受影响的格子
	for i, coord in pairs(clearInfo.affected_coord_list) do
		local _, grid = self:getGrid(coord.row, coord.col)
		if nil == grid then
			clearCF({})
		else
			grid:onClear(clearCF, clearInfo.touched_count + i, false, clearType)
		end
	end
end

-- 炸弹全部消除
function GridController:clearAllGrid(clearInfo, clearType, bombCoord)
	if not clearInfo.can_clear_flag or 0 == clearInfo.touched_count then
		return
	end
	-- 预设置
	self:setTouchEnabled(false)
	-- cclog("================================================ clear all grid begin")
	EventCenter:post(EventDef["ED_CLEAR_BEGIN"])
	-- 获取周围格子
	local rangeCount = self.mRow
	if self.mCol > rangeCount then
		rangeCount = self.mCol
	end
	-- 格子消除回调
	local totalClearCount = 0
	for row, rowGrids in pairs(self.mGridNodes) do
		for col, grid in pairs(rowGrids) do
			if grid and not grid:isBorn() then
				totalClearCount = totalClearCount + 1
			end
		end
	end
	local totalElementDatas = {}
	local function clearCF(elementDataList)
		EventCenter:post(EventDef["ED_CLEAR_GRID"], elementDataList)
		for i, elementData in pairs(elementDataList) do
			table.insert(totalElementDatas, elementData)
		end
		totalClearCount = totalClearCount - 1
		if totalClearCount > 0 then
			return
		end
		-- 格子全部消除结束
		-- cclog("================================================ clear all grid end")
		EventCenter:post(EventDef["ED_CLEAR_END"], totalElementDatas)
	end
	-- 消除隔板
	for row, rowBoards in pairs(self.mBoardNodes) do
		for col, colBoards in pairs(rowBoards) do
			for direct, board in pairs(colBoards) do
				self:clearBoard(board, true)
			end
		end
	end
	-- 消除炸弹
	for row, rowGrids in pairs(self.mGridNodes) do
		for col, grid in pairs(rowGrids) do
			if grid and not grid:isBorn() and ElementType["special"] == grid:getShowElement():getType() and ElementSpecialType["bomb"] == grid:getShowElement():getSubType() then
				grid:onAffectExit(2)
				grid:onClear(clearCF, 1, true, clearType)
			end
		end
	end
	-- 消除格子
	for range=1, rangeCount do
		local rangeCoordList = Core:getRangeCoord(bombCoord, range)
		for i, rangeCoord in pairs(rangeCoordList) do
			local _, grid = self:getGrid(rangeCoord.row, rangeCoord.col)
			if grid and not grid:isBorn() and not (ElementType["special"] == grid:getShowElement():getType() and ElementSpecialType["bomb"] == grid:getShowElement():getSubType()) then
				grid:onClear(clearCF, range*2, true, clearType)
			end
		end
	end
end

-- 掉落格子列表
function GridController:dropGridList(dropInfoList, dropTimes, flag)
	if nil == dropInfoList or nil == dropTimes then
		self:setTouchEnabled(false)
		dropInfoList, dropTimes = dropInfoList or {}, dropTimes or 0
		-- cclog("================================================ drop begin")
		EventCenter:post(EventDef["ED_DROP_BEGIN"])
	end
	-- 从下向上遍历可掉落格子
	for row=self.mRow-1, 1, -1 do
		for col=1, self.mCol do
			local data, grid = self:getGrid(row, col)
			local dropPath = Core:searchGridDropPath(grid, self.mRow, self.mCol, self.mGridDatas, self.mGridNodes, self.mBoardDatas)
			local dropPathLength = #dropPath
			if dropPathLength > 0 then
				-- 格子数据置换
				local targetCoord = dropPath[dropPathLength]
				self:setGrid(row, col, nil, nil)
				self:setGrid(targetCoord.row, targetCoord.col, data, grid)
				grid:setCoord(targetCoord.row, targetCoord.col)
				-- 格子掉落信息
				local dropInfo = {
					grid = grid,				-- 格子
					path = dropPath,			-- 掉落路径
					times = dropTimes,			-- 第n批次掉落
				}
				table.insert(dropInfoList, dropInfo)
			end
		end
	end
	dropTimes = dropTimes + 1
	-- 生成随机格子
	if self:getSibling("BornController"):generateRandomGrid() then
		self:dropGridList(dropInfoList, dropTimes, flag)
		return
	end
	-- 掉落格子列表
	local totalDropCount = #dropInfoList
	local dropEndParam = {
		is_drop = totalDropCount > 0,	-- 是否有掉落
		flag = flag,					-- 标识
	}
	if 0 == totalDropCount then
		-- cclog("================================================ drop end 1, flag: "..tostring(flag))
		EventCenter:post(EventDef["ED_DROP_END"], dropEndParam)
		return
	end
	for i, dropInfo in pairs(dropInfoList) do
		local coord = dropInfo.grid:getCoord()
		dropInfo.grid:onDrop(dropInfo.times, dropInfo.path, function()
			totalDropCount = totalDropCount - 1
			if totalDropCount > 0 then
				return
			end
			-- cclog("================================================ drop end 2, flag: "..tostring(flag))
			EventCenter:post(EventDef["ED_DROP_END"], dropEndParam)
		end)
	end
end

-- 重新排列格子列表
function GridController:arrangeGridList()
	-- 不需要重新排列
	if self:getClearPath() then
		self:setTouchEnabled(true)
		local isRoundValid = self.mTouchedType > 0
		-- cclog("================================================ round over, is round valid: "..tostring(isRoundValid))
		EventCenter:post(EventDef["ED_ROUND_OVER"], isRoundValid)
		return
	end
	-- 游戏结束
	if self:isGameOver() then
		-- cclog("================================================ game over")
		EventCenter:post(EventDef["ED_GAME_OVER"])
		return
	end
	-- cclog("================================================ arrange")
	-- 筛选可重新排列坐标
	local arrangeCoords = {}
	for row, rowGrids in pairs(self.mGridNodes) do
		for col, grid in pairs(rowGrids) do
			if not grid:isBorn() and grid:isCanReset() then
				table.insert(arrangeCoords, grid:getCoord())
			end
		end
	end
	-- 重新排列
	local moveCount = 2
	local function moveCF()
		moveCount = moveCount - 1
		if 0 == moveCount then
			self:arrangeGridList()
		end
	end
	local arrangeCount = #arrangeCoords
	local index1 = math.random(1, math.ceil(arrangeCount/2))
	local index2 = math.random(math.ceil(arrangeCount/2) + 1, arrangeCount)
	local coord1, coord2 = arrangeCoords[index1], arrangeCoords[index2]
	local data1, grid1 = self:getGrid(coord1.row, coord1.col)
	local data2, grid2 = self:getGrid(coord2.row, coord2.col)
	grid1:setCoord(coord2.row, coord2.col)
	self:setGrid(coord2.row, coord2.col, data1, grid1)
	grid1:onReset({coord2}, moveCF)
	grid2:setCoord(coord1.row, coord1.col)
	self:setGrid(coord1.row, coord1.col, data2, grid2)
	grid2:onReset({coord1}, moveCF)
	if self:getClearPath() then
		-- 提示
		local tipLabelBMFont = cc.Label:createWithBMFont("font_01.fnt", "REARRANGE")
		tipLabelBMFont:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 350))
		self:getMaster():getTopLayer():addChild(tipLabelBMFont, G.TOP_ZORDER_TIP)
		Actions:moveScaleAction02(tipLabelBMFont, cc.p(G.VISIBLE_SIZE.width/2, 600))
	end
end

-- 搜索可连接路径
function GridController:searchConnectPath(beginGrid)
	local searchedList = {}
	local connectPath = {}
	local function doSearch(grid)
		if nil == grid or Core:isCoordExist(searchedList, grid:getCoord()) then
			return false
		end
		table.insert(connectPath, grid:getCoord())
		Core:addCoord(searchedList, grid:getCoord())
		local allAroundGrids = self:getAllAroundGrids(grid:getCoord())
		for direct, aroundGrid in pairs(allAroundGrids) do
			if not aroundGrid:isBorn() and self:canConnect(grid, aroundGrid) and doSearch(aroundGrid) then
				return true
			end
		end
		return true
	end
	doSearch(beginGrid)
	return connectPath
end

-- 获取可消除的路径
function GridController:getClearPath()
	for row=self.mRow, 2, -1 do
		for col=1, self.mCol do
			local _, grid = self:getGrid(row, col)
			local normalType = nil
			if grid then
				local showElementType = grid:getShowElement():getType()
				if ElementType["normal"] == showElementType then
					normalType = grid:getShowElement():getSubType()
				elseif ElementType["skill"] == showElementType then
					normalType = grid:getShowElement():getExtraType()
				end
			end
			if normalType then
				local gridCoordPath = self:searchConnectPath(grid)
				local gridCoordCount = #gridCoordPath
				if gridCoordCount >= self:getMinCollect(normalType) then
					return gridCoordPath
				elseif gridCoordCount >= 2 then
					local _, secondGrid = self:getGrid(gridCoordPath[2].row, gridCoordPath[2].col)
					if ElementType["skill"] == secondGrid:getShowElement():getType() and ElementSkillType["discolor"] == secondGrid:getShowElement():getSubType() then
						local secondCoord = secondGrid:getCoord()
						local allAroundGrids = self:getAllAroundGrids(secondGrid:getCoord())
						for direct, aroundGrid in pairs(allAroundGrids) do
							if not aroundGrid:isBorn() and nil == aroundGrid:getCoverElement() and
								ElementType["normal"] == aroundGrid:getShowElement():getType() and
								normalType ~= aroundGrid:getShowElement():getSubType() and
								Core:isCanContact(secondCoord, aroundGrid:getCoord(), self.mBoardDatas) then
								return gridCoordPath
							end
						end
					end
				end
			end
		end
	end
end

-- 游戏是否结束
function GridController:isGameOver()
	local remainCountTable = {}
	for row, rowGrids in pairs(self.mGridNodes) do
		for col, grid in pairs(rowGrids) do
			if grid and not grid:isBorn() and nil == grid:getCoverElement() then
				local showElement = grid:getShowElement()
				local showElementType = showElement:getType()
				if ElementType["normal"] == showElementType then		-- 普通元素
					local normalType = showElement:getSubType()
					remainCountTable[normalType] = (remainCountTable[normalType] or 0) + 1
					if remainCountTable[normalType] >= self:getMinCollect(normalType) then
						return false
					end
				elseif ElementType["skill"] == showElementType then		-- 技能元素
					local normalType = showElement:getExtraType()
					if ElementSkillType["discolor"] == showElement:getSubType() then	-- 变色技能球
						remainCountTable[normalType] = (remainCountTable[normalType] or 0) + 2
					else
						remainCountTable[normalType] = (remainCountTable[normalType] or 0) + 1
					end
					if remainCountTable[normalType] >= self:getMinCollect(normalType) then
						return false
					end
				end
			end
		end
	end
	return true
end

-- 获取剩余步数随机格子
function GridController:getRemainRoundGrid()
	local normalGridList, skillGridList = {}, {}
	for row, rowGrids in pairs(self.mGridNodes) do
		for col, grid in pairs(rowGrids) do
			if grid and not grid:isBorn() and nil == grid:getFixedElement() and nil == grid:getCoverElement() then
				local showElementType = grid:getShowElement():getType()
				if ElementType["normal"] == showElementType then
					table.insert(normalGridList, grid)
				elseif ElementType["skill"] == showElementType then
					table.insert(skillGridList, grid)
				end
			end
		end
	end
	if #skillGridList > 0 then
		return CommonFunc:getRandom(skillGridList)
	end
	return CommonFunc:getRandom(normalGridList)
end

