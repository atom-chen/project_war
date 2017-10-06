----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 变色技能球
----------------------------------------------------------------------
ElementSkillDiscolor = class("ElementSkillDiscolor", ElementSkill)

-- 构造函数
function ElementSkillDiscolor:ctor(image)
	self.super:ctor()
	self.mAffectedGridInfoList = {}				-- 受技能影响的格子信息表
	self:setSprite(cc.Sprite:create(image))
end

-- 添加受范围1影响格子
function ElementSkillDiscolor:addAffected1(gridController, row, col, affectedGrids)
	local grid = nil
	-- 正上
	_, grid = gridController:getGrid(row - 1, col)
	table.insert(affectedGrids, grid)
	-- 正右
	_, grid = gridController:getGrid(row, col + 1)
	table.insert(affectedGrids, grid)
	-- 正下
	_, grid = gridController:getGrid(row + 1, col)
	table.insert(affectedGrids, grid)
	-- 正左
	_, grid = gridController:getGrid(row, col - 1)
	table.insert(affectedGrids, grid)
	-- 左上
	_, grid = gridController:getGrid(row - 1, col - 1)
	table.insert(affectedGrids, grid)
	-- 右上
	_, grid = gridController:getGrid(row - 1, col + 1)
	table.insert(affectedGrids, grid)
	-- 右下
	_, grid = gridController:getGrid(row + 1, col + 1)
	table.insert(affectedGrids, grid)
	-- 左下
	_, grid = gridController:getGrid(row + 1, col - 1)
	table.insert(affectedGrids, grid)
end

-- 添加受范围2影响格子
function ElementSkillDiscolor:addAffected2(gridController, row, col, affectedGrids)
	local grid = nil
	-- 正上
	_, grid = gridController:getGrid(row - 2, col)
	table.insert(affectedGrids, grid)
	-- 正右
	_, grid = gridController:getGrid(row, col + 2)
	table.insert(affectedGrids, grid)
	-- 正下
	_, grid = gridController:getGrid(row + 2, col)
	table.insert(affectedGrids, grid)
	-- 正左
	_, grid = gridController:getGrid(row, col - 2)
	table.insert(affectedGrids, grid)
end

-- 添加受范围3影响格子
function ElementSkillDiscolor:addAffected3(gridController, row, col, affectedGrids)
	local grid = nil
	-- 左上
	_, grid = gridController:getGrid(row - 1, col - 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row - 2, col - 1)
	table.insert(affectedGrids, grid)
	-- 右上
	_, grid = gridController:getGrid(row - 1, col + 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row - 2, col + 1)
	table.insert(affectedGrids, grid)
	-- 右下
	_, grid = gridController:getGrid(row + 1, col + 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row + 2, col + 1)
	table.insert(affectedGrids, grid)
	-- 左下
	_, grid = gridController:getGrid(row + 1, col - 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row + 2, col - 1)
	table.insert(affectedGrids, grid)
end

-- 添加受范围4影响格子
function ElementSkillDiscolor:addAffected4(gridController, row, col, affectedGrids)
	local grid = nil
	-- 正上
	_, grid = gridController:getGrid(row - 3, col)
	table.insert(affectedGrids, grid)
	-- 正右
	_, grid = gridController:getGrid(row, col + 3)
	table.insert(affectedGrids, grid)
	-- 正下
	_, grid = gridController:getGrid(row + 3, col)
	table.insert(affectedGrids, grid)
	-- 正左
	_, grid = gridController:getGrid(row, col - 3)
	table.insert(affectedGrids, grid)
end

-- 添加受范围5影响格子
function ElementSkillDiscolor:addAffected5(gridController, row, col, affectedGrids)
	local grid = nil
	-- 左上
	_, grid = gridController:getGrid(row - 1, col - 3)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row - 2, col - 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row - 3, col - 1)
	table.insert(affectedGrids, grid)
	-- 右上
	_, grid = gridController:getGrid(row - 1, col + 3)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row - 2, col + 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row - 3, col + 1)
	table.insert(affectedGrids, grid)
	-- 右下
	_, grid = gridController:getGrid(row + 1, col + 3)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row + 2, col + 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row + 3, col + 1)
	table.insert(affectedGrids, grid)
	-- 左下
	_, grid = gridController:getGrid(row + 1, col - 3)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row + 2, col - 2)
	table.insert(affectedGrids, grid)
	_, grid = gridController:getGrid(row + 3, col - 1)
	table.insert(affectedGrids, grid)
end

-- 进入触摸
function ElementSkillDiscolor:enterTouch(grid, inflictGrid)
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	local touchNormalId = Factory:getNormalId(gridController:getTouchedType())
	if inflictGrid then
		local normalType = nil
		if ElementType["normal"] == inflictGrid:getShowElement():getType() then
			normalType = inflictGrid:getShowElement():getSubType()
		elseif ElementType["skill"] == inflictGrid:getShowElement():getType() then
			normalType = inflictGrid:getShowElement():getExtraType()
		end
		if normalType ~= grid:getShowElement():getExtraType() then
			return
		end
	end
	local addAffectedTable = {
		self.addAffected1,
		self.addAffected2,
		self.addAffected3,
		self.addAffected4,
		self.addAffected5,
	}
	local coord = grid:getCoord()
	local affectedGrids = {}
	for i=1, self:getEffectRange() do
		Utils:doCallback(addAffectedTable[i], self, gridController, coord.row, coord.col, affectedGrids)
	end
	for i, affectedGrid in pairs(affectedGrids) do
		if affectedGrid and nil == affectedGrid:getFixedElement() and nil == affectedGrid:getCoverElement() and affectedGrid:getShowElement() and affectedGrid:getShowElement():isCanChange() then
			local data = affectedGrid:getShowElement():getData()
			if ElementType["skill"] ~= affectedGrid:getShowElement():getType() and touchNormalId ~= data.id then
				local affectedGridInfo = {
					element_id = data.id,
					grid = affectedGrid
				}
				affectedGrid:setElement(Factory:createElement(touchNormalId))
				table.insert(self.mAffectedGridInfoList, affectedGridInfo)
				local affectedCoord = affectedGrid:getCoord()
				gridController:setGrid(affectedCoord.row, affectedCoord.col, {touchNormalId}, affectedGrid)
			end
		end
	end
end

-- 退出触摸
function ElementSkillDiscolor:exitTouch(grid)
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	local tipController = MapManager:getComponent("TipController")
	for i, affectedGridInfo in pairs(self.mAffectedGridInfoList) do
		affectedGridInfo.grid:setElement(Factory:createElement(affectedGridInfo.element_id))
		local affectedCoord = affectedGridInfo.grid:getCoord()
		gridController:setGrid(affectedCoord.row, affectedCoord.col, {affectedGridInfo.element_id}, affectedGridInfo.grid)
		if tipController:isOnGuide() then
			affectedGridInfo.grid:setGray(true)
		end
	end
	self.mAffectedGridInfoList = {}
end
