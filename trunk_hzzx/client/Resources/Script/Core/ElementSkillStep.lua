----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 步数技能球
----------------------------------------------------------------------
ElementSkillStep = class("ElementSkillStep", ElementSkill)

-- 构造函数
function ElementSkillStep:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

