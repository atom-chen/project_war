----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-01-23
-- Brief: 砖石
----------------------------------------------------------------------
ElementSpecialDiamond = class("ElementSpecialDiamond", Element)

-- 构造函数
function ElementSpecialDiamond:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

-- 进入激活状态
function ElementSpecialDiamond:onActiveEnter(param)
	if 1 == param.affect_type then
		param.grid:setGray(false)
	end
end

-- 退出激活状态
function ElementSpecialDiamond:onActiveExit(param)
	if 1 == param.affect_type then
		param.grid:setGray(true)
	end
end

