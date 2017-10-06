----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 普通元素
----------------------------------------------------------------------
ElementNormal = class("ElementNormal", Element)

-- 构造函数
function ElementNormal:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

-- 被选中调用
function ElementNormal:onFocusEnter()
	local data = self:getData()
	Utils:setSpriteTexture(self:getSprite(), data.touch_image)
end

-- 被取消选中调用
function ElementNormal:onFocusExit()
	local data = self:getData()
	Utils:setSpriteTexture(self:getSprite(), data.normal_image)
end

-- 消除动作
function ElementNormal:clearAction(param, actionEndCF)
	local data = self:getData()
	if MapManager:getComponent("HeroController"):flyToHero(self:getType(), self:getSubType(), data.id, param.coord, param.index, actionEndCF) then
		return
	end
	if MapManager:getComponent("HeroController"):elementAttack(self:getType(), self:getSubType(), data.id, param.coord, param.index, actionEndCF) then
		return
	end
	Animations:elementExplode01(param.coord, data.sound)
	Actions:delayWith(MapManager:getMap():getTopLayer(), (param.index - 1)*0.1, function()
		Utils:doCallback(actionEndCF)
	end)
end
