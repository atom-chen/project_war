----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 十字消技能球
----------------------------------------------------------------------
ElementSkillCross = class("ElementSkillCross", ElementSkill)

-- 构造函数
function ElementSkillCross:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

-- 添加受范围1影响格子,隔板
function ElementSkillCross:addAffected1(gridController, row, col, affectedGrids, affectedBoards)
	local grid = nil
	-- 正上
	_, grid = gridController:getGrid(row - 1, col)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col, direct = BoardDirectType["horizontal"]})
	-- 正右
	_, grid = gridController:getGrid(row, col + 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col + 1, direct = BoardDirectType["vertical"]})
	-- 正下
	_, grid = gridController:getGrid(row + 1, col)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row + 1, col = col, direct = BoardDirectType["horizontal"]})
	-- 正左
	_, grid = gridController:getGrid(row, col - 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col, direct = BoardDirectType["vertical"]})
end

-- 添加受范围2影响格子,隔板
function ElementSkillCross:addAffected2(gridController, row, col, affectedGrids, affectedBoards)
	local grid = nil
	-- 左上
	_, grid = gridController:getGrid(row - 1, col - 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col - 1, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row - 1, col = col, direct = BoardDirectType["vertical"]})
	-- 右上
	_, grid = gridController:getGrid(row - 1, col + 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col + 1, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row - 1, col = col + 1, direct = BoardDirectType["vertical"]})
	-- 右下
	_, grid = gridController:getGrid(row + 1, col + 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row + 1, col = col + 1, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row + 1, col = col + 1, direct = BoardDirectType["vertical"]})
	-- 左下
	_, grid = gridController:getGrid(row + 1, col - 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row + 1, col = col - 1, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row + 1, col = col, direct = BoardDirectType["vertical"]})
end

-- 添加受范围3影响格子,隔板
function ElementSkillCross:addAffected3(gridController, row, col, affectedGrids, affectedBoards)
	local grid = nil
	-- 正上
	_, grid = gridController:getGrid(row - 2, col)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row - 1, col = col, direct = BoardDirectType["horizontal"]})
	-- 正右
	_, grid = gridController:getGrid(row, col + 2)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col + 2, direct = BoardDirectType["vertical"]})
	-- 正下
	_, grid = gridController:getGrid(row + 2, col)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row + 2, col = col, direct = BoardDirectType["horizontal"]})
	-- 正左
	_, grid = gridController:getGrid(row, col - 2)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col - 1, direct = BoardDirectType["vertical"]})
end

-- 添加受范围4影响格子,隔板
function ElementSkillCross:addAffected4(gridController, row, col, affectedGrids, affectedBoards)
	local grid = nil
	-- 左上
	_, grid = gridController:getGrid(row - 1, col - 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row - 2, col - 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row - 2, col = col, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row - 1, col = col - 1, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row - 1, col = col - 1, direct = BoardDirectType["vertical"]})
	table.insert(affectedBoards, {row = row - 2, col = col, direct = BoardDirectType["vertical"]})
	-- 右上
	_, grid = gridController:getGrid(row - 1, col + 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row - 2, col + 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col + 2, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row - 1, col = col + 1, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row - 1, col = col + 2, direct = BoardDirectType["vertical"]})
	table.insert(affectedBoards, {row = row - 2, col = col + 1, direct = BoardDirectType["vertical"]})
	-- 右下
	_, grid = gridController:getGrid(row + 1, col + 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row + 2, col + 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row + 1, col = col + 2, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row + 2, col = col + 1, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row + 1, col = col + 2, direct = BoardDirectType["vertical"]})
	table.insert(affectedBoards, {row = row + 2, col = col + 1, direct = BoardDirectType["vertical"]})
	-- 左下
	_, grid = gridController:getGrid(row + 1, col - 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row + 2, col - 1)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row + 1, col = col - 2, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row + 2, col = col - 1, direct = BoardDirectType["horizontal"]})
	table.insert(affectedBoards, {row = row + 1, col = col - 1, direct = BoardDirectType["vertical"]})
	table.insert(affectedBoards, {row = row + 2, col = col, direct = BoardDirectType["vertical"]})
end

-- 添加受范围5影响格子,隔板
function ElementSkillCross:addAffected5(gridController, row, col, affectedGrids, affectedBoards)
	local grid = nil
	-- 正上
	_, grid = gridController:getGrid(row - 3, col)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row - 2, col = col, direct = BoardDirectType["horizontal"]})
	-- 正右
	_, grid = gridController:getGrid(row, col + 3)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col + 3, direct = BoardDirectType["vertical"]})
	-- 正下
	_, grid = gridController:getGrid(row + 3, col)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row + 3, col = col, direct = BoardDirectType["horizontal"]})
	-- 正左
	_, grid = gridController:getGrid(row, col - 3)
	table.insert(affectedGrids, grid)
	table.insert(affectedBoards, {row = row, col = col - 2, direct = BoardDirectType["vertical"]})
end

-- 进入触摸
function ElementSkillCross:enterTouch(grid, inflictGrid)
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	skillController:addAffectedInfo(grid, inflictGrid)
	skillController:increaseSkill()
	local addAffectedTable = {
		self.addAffected1,
		self.addAffected2,
		self.addAffected3,
		self.addAffected4,
		self.addAffected5,
	}
	local coord = grid:getCoord()
	local affectedGrids, affectedBoards = {}, {}
	for i=1, self:getEffectRange() do
		Utils:doCallback(addAffectedTable[i], self, gridController, coord.row, coord.col, affectedGrids, affectedBoards)
	end
	for i, affectedGrid in pairs(affectedGrids) do
		if affectedGrid and ElementType["skill"] == affectedGrid:getShowElement():getType() and not skillController:isAffectedBy(affectedGrid, grid) then
			skillController:addAffectedInfo(affectedGrid, grid)
			affectedGrid:getShowElement():enterTouch(affectedGrid, grid)
		else
			skillController:addAffectedInfo(affectedGrid, grid)
		end
	end
	for i, affectedBoard in pairs(affectedBoards) do
		skillController:addAffectedBoard(affectedBoard.row, affectedBoard.col, affectedBoard.direct)
	end
end

-- 退出触摸
function ElementSkillCross:exitTouch(grid)
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	skillController:decreaseSkill()
	local addAffectedTable = {
		self.addAffected1,
		self.addAffected2,
		self.addAffected3,
		self.addAffected4,
		self.addAffected5,
	}
	local coord = grid:getCoord()
	local affectedGrids, affectedBoards = {}, {}
	for i=1, self:getEffectRange() do
		Utils:doCallback(addAffectedTable[i], self, gridController, coord.row, coord.col, affectedGrids, affectedBoards)
	end
	for i, affectedGrid in pairs(affectedGrids) do
		if affectedGrid and skillController:isAffectedBy(affectedGrid, grid) then
			skillController:removeAffectedInfo(affectedGrid, grid)
			if ElementType["skill"] == affectedGrid:getShowElement():getType() then
				affectedGrid:getShowElement():exitTouch(affectedGrid)
			end
		end
	end
	for i, affectedBoard in pairs(affectedBoards) do
		skillController:removeAffectedBoard(affectedBoard.row, affectedBoard.col, affectedBoard.direct)
	end
end
