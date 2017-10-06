----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 同色消技能球
----------------------------------------------------------------------
ElementSkillSamecolor = class("ElementSkillSamecolor", ElementSkill)

-- 构造函数
function ElementSkillSamecolor:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
end

