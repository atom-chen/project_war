----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-01-23
-- Brief: 炸弹
----------------------------------------------------------------------
ElementSpecialBomb = class("ElementSpecialBomb", Element)

-- 构造函数
function ElementSpecialBomb:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

-- 进入激活状态
function ElementSpecialBomb:onActiveEnter(param)
	if 2 ~= param.affect_type then
		return
	end
	local coord = param.grid:getCoord()
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	gridController:addBombCoord(coord)
	skillController:increaseBomb()
	local gridNodes = gridController:getGridNodes()
	for row, rowNodes in pairs(gridNodes) do
		for col, grid in pairs(rowNodes) do
			if not grid:isBorn() and not (coord.row == row and coord.col == col) and not skillController:isAffected(grid) then
				grid:showTipCircle(true)
			end
		end
	end
end

-- 退出激活状态
function ElementSpecialBomb:onActiveExit(param)
	if 2 ~= param.affect_type then
		return
	end
	local coord = param.grid:getCoord()
	local gridController = MapManager:getComponent("GridController")
	local skillController = MapManager:getComponent("SkillController")
	gridController:removeBombCoord(coord)
	skillController:decreaseBomb()
	local gridNodes = gridController:getGridNodes()
	for row, rowNodes in pairs(gridNodes) do
		for col, grid in pairs(rowNodes) do
			if not grid:isBorn() and not (coord.row == row and coord.col == col) and not skillController:isAffected(grid) then
				grid:showTipCircle(false)
			end
		end
	end
end

