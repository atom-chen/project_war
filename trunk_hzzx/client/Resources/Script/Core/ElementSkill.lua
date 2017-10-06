----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 技能元素
----------------------------------------------------------------------
ElementSkill = class("ElementSkill", Element)

-- 构造函数
function ElementSkill:ctor(image)
	self.super:ctor()
	self.mPreSkillId = 0				-- 前世技能id
	self.mSkillId = 0					-- 当前技能id
	self.mEffectRange = 1				-- 可影响范围
end

-- 设置前世技能id
function ElementSkill:setPreSkillId(preSkillId)
	self.mPreSkillId = preSkillId
end

-- 获取前世技能id
function ElementSkill:getPreSkillId()
	return self.mPreSkillId
end

-- 设置当前技能id
function ElementSkill:setSkillId(skillId)
	self.mSkillId = skillId
end

-- 获取当前技能id
function ElementSkill:getSkillId()
	return self.mSkillId
end

-- 设置可影响范围
function ElementSkill:setEffectRange(effectRagne)
	self.mEffectRange = effectRagne
end

-- 获取可影响范围
function ElementSkill:getEffectRange()
	return self.mEffectRange
end

-- 被选中调用
function ElementSkill:onFocusEnter()
	if self:isCanTouch() then
		local data = self:getData()
		Utils:setSpriteTexture(self:getSprite(), data.touch_image)
	end
end

-- 被取消选中调用
function ElementSkill:onFocusExit()
	if self:isCanTouch() then
		local data = self:getData()
		Utils:setSpriteTexture(self:getSprite(), data.normal_image)
	end
end

-- 消除动作
function ElementSkill:clearAction(param, actionEndCF)
	if MapManager:getComponent("HeroController"):flyToHero(self:getType(), self:getExtraType(), self.mSkillId, param.coord, param.index, actionEndCF) then
		return
	end
	if MapManager:getComponent("HeroController"):elementAttack(self:getType(), self:getExtraType(), self.mSkillId, param.coord, param.index, actionEndCF) then
		return
	end
	Animations:elementExplode01(param.coord, self:getData().sound)
	Actions:delayWith(MapManager:getMap():getTopLayer(), (param.index - 1)*0.1, function()
		Utils:doCallback(actionEndCF)
	end)
end
