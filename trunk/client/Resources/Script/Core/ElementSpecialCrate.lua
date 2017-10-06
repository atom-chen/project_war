----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-01-23
-- Brief: 木箱
----------------------------------------------------------------------
ElementSpecialCrate = class("ElementSpecialCrate", Element)

-- 构造函数
function ElementSpecialCrate:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

