----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-01-23
-- Brief: 钥匙
----------------------------------------------------------------------
ElementSpecialKey = class("ElementSpecialKey", Element)

-- 构造函数
function ElementSpecialKey:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

-- 进入激活状态
function ElementSpecialKey:onActiveEnter(param)
	if 1 == param.affect_type then
		param.grid:setGray(false)
	end
end

-- 退出激活状态
function ElementSpecialKey:onActiveExit(param)
	if 1 == param.affect_type then
		param.grid:setGray(true)
	end
end

