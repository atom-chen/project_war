----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 横消技能球
----------------------------------------------------------------------
ElementSkillHorizontal = class("ElementSkillHorizontal", ElementSkill)

-- 构造函数
function ElementSkillHorizontal:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

-- 进入触摸
function ElementSkillHorizontal:enterTouch(grid, inflictGrid)
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	-- 横消变竖消
	if 0 == self:getPreSkillId() and not gridController:isTouchedCoord(grid:getCoord()) and inflictGrid 
		and ElementType["skill"] == inflictGrid:getShowElement():getType() 
		and ElementSkillType["horizontal"] == inflictGrid:getShowElement():getSubType() then
		local verticalSkillId = Factory:getVerticalSkillId(self:getSkillId())
		local verticalSkillElement = Factory:createSkillElement(verticalSkillId)
		grid:setElement(verticalSkillElement)
		verticalSkillElement:setPreSkillId(self:getSkillId())
		verticalSkillElement:enterTouch(grid, inflictGrid)
		return
	end
	-- 设置影响格子
	skillController:increaseSkill()
	local coord = grid:getCoord()
	for i=1, self:getEffectRange() do
		-- 左边格子
		local _, leftGrid = gridController:getGrid(coord.row, coord.col - i)
		if leftGrid and not skillController:isAffectedBy(leftGrid, grid) then
			skillController:addAffectedInfo(leftGrid, grid)
			if ElementType["skill"] == leftGrid:getShowElement():getType() then
				leftGrid:getShowElement():enterTouch(leftGrid, grid)
			end
		end
		-- 右边格子
		local _, rightGrid = gridController:getGrid(coord.row, coord.col + i)
		if rightGrid and not skillController:isAffectedBy(rightGrid, grid) then
			skillController:addAffectedInfo(rightGrid, grid)
			if ElementType["skill"] == rightGrid:getShowElement():getType() then
				rightGrid:getShowElement():enterTouch(rightGrid, grid)
			end
		end
		-- 左边隔板
		skillController:addAffectedBoard(coord.row, coord.col - i + 1, BoardDirectType["vertical"])
		-- 右边隔板
		skillController:addAffectedBoard(coord.row, coord.col + i, BoardDirectType["vertical"])
	end
end

-- 退出触摸
function ElementSkillHorizontal:exitTouch(grid)
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	skillController:decreaseSkill()
	local coord = grid:getCoord()
	for i=1, self:getEffectRange() do
		-- 左边格子
		local _, leftGrid = gridController:getGrid(coord.row, coord.col - i)
		if leftGrid and skillController:isAffectedBy(leftGrid, grid) then
			skillController:removeAffectedInfo(leftGrid, grid)
			if ElementType["skill"] == leftGrid:getShowElement():getType() then
				if skillController:isAffected(leftGrid) then
				else
					leftGrid:getShowElement():exitTouch(leftGrid)
				end
			end
		end
		-- 右边格子
		local _, rightGrid = gridController:getGrid(coord.row, coord.col + i)
		if rightGrid and skillController:isAffectedBy(rightGrid, grid) then
			skillController:removeAffectedInfo(rightGrid, grid)
			if ElementType["skill"] == rightGrid:getShowElement():getType() then
				if skillController:isAffected(rightGrid) then
				else
					rightGrid:getShowElement():exitTouch(rightGrid)
				end
			end
		end
		-- 左边隔板
		skillController:removeAffectedBoard(coord.row, coord.col - i + 1, BoardDirectType["vertical"])
		-- 右边隔板
		skillController:removeAffectedBoard(coord.row, coord.col + i, BoardDirectType["vertical"])
	end
	if self:getPreSkillId() > 0 and nil == skillController:getInflictGrid(grid, ElementSkillType["vertical"]) then
		local verticalSkillElement = Factory:createSkillElement(self:getPreSkillId())
		grid:setElement(verticalSkillElement)
	end
end
