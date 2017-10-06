----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 连接器技能球
----------------------------------------------------------------------
ElementSkillConnect = class("ElementSkillConnect", ElementSkill)

-- 构造函数
function ElementSkillConnect:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

