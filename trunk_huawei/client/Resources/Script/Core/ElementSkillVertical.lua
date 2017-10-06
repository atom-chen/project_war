----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 竖消技能球
----------------------------------------------------------------------
ElementSkillVertical = class("ElementSkillVertical", ElementSkill)

-- 构造函数
function ElementSkillVertical:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

-- 进入触摸
function ElementSkillVertical:enterTouch(grid, inflictGrid)
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	-- 竖消变横消
	if 0 == self:getPreSkillId() and not gridController:isTouchedCoord(grid:getCoord()) and inflictGrid 
		and ElementType["skill"] == inflictGrid:getShowElement():getType() 
		and ElementSkillType["vertical"] == inflictGrid:getShowElement():getSubType() then
		local horizontalSkillId = Factory:getHorizontalSkillId(self:getSkillId())
		local horizontalSkillElement = Factory:createSkillElement(horizontalSkillId)
		grid:setElement(horizontalSkillElement)
		horizontalSkillElement:setPreSkillId(self:getSkillId())
		horizontalSkillElement:enterTouch(grid, inflictGrid)
		return
	end
	-- 设置影响格子
	skillController:increaseSkill()
	local coord = grid:getCoord()
	for i=1, self:getEffectRange() do
		-- 上边格子
		local _, upGrid = gridController:getGrid(coord.row - i, coord.col)
		if upGrid and not skillController:isAffectedBy(upGrid, grid) then
			skillController:addAffectedInfo(upGrid, grid)
			if ElementType["skill"] == upGrid:getShowElement():getType() then
				upGrid:getShowElement():enterTouch(upGrid, grid)
			end
		end
		-- 下边格子
		local _, downGrid = gridController:getGrid(coord.row + i, coord.col)
		if downGrid and not skillController:isAffectedBy(downGrid, grid) then
			skillController:addAffectedInfo(downGrid, grid)
			if ElementType["skill"] == downGrid:getShowElement():getType() then
				downGrid:getShowElement():enterTouch(downGrid, grid)
			end
		end
		-- 上边隔板
		skillController:addAffectedBoard(coord.row - i + 1, coord.col, BoardDirectType["horizontal"])
		-- 下边隔板
		skillController:addAffectedBoard(coord.row + i, coord.col, BoardDirectType["horizontal"])
	end
end

-- 退出触摸
function ElementSkillVertical:exitTouch(grid)
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	skillController:decreaseSkill()
	local coord = grid:getCoord()
	for i=1, self:getEffectRange() do
		-- 上边格子
		local _, upGrid = gridController:getGrid(coord.row - i, coord.col)
		if upGrid and skillController:isAffectedBy(upGrid, grid) then
			skillController:removeAffectedInfo(upGrid, grid)
			if ElementType["skill"] == upGrid:getShowElement():getType() then
				if skillController:isAffected(upGrid) then
				else
					upGrid:getShowElement():exitTouch(upGrid)
				end
			end
		end
		-- 下边格子
		local _, downGrid = gridController:getGrid(coord.row + i, coord.col)
		if downGrid and skillController:isAffectedBy(downGrid, grid) then
			skillController:removeAffectedInfo(downGrid, grid)
			if ElementType["skill"] == downGrid:getShowElement():getType() then
				if skillController:isAffected(downGrid) then
				else
					downGrid:getShowElement():exitTouch(downGrid)
				end
			end
		end
		-- 上边隔板
		skillController:removeAffectedBoard(coord.row - i + 1, coord.col, BoardDirectType["horizontal"])
		-- 下边隔板
		skillController:removeAffectedBoard(coord.row + i, coord.col, BoardDirectType["horizontal"])
	end
	if self:getPreSkillId() > 0 and nil == skillController:getInflictGrid(grid, ElementSkillType["horizontal"]) then
		local horizontalSkillElement = Factory:createSkillElement(self:getPreSkillId())
		grid:setElement(horizontalSkillElement)
	end
end
