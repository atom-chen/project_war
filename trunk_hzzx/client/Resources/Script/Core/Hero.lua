----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 英雄
----------------------------------------------------------------------
Hero = class("Hero")

-- 构造函数
function Hero:ctor(heroId)
	-- 属性定义
	self.mHeroData = nil				-- 英雄数据
	self.mHeroNode = nil				-- 英雄节点
	self.mSkillId = 0					-- 技能id
	self.mSkillTriggerRound = 0			-- 技能触发回合数
	self.mSkillCurrRound = 0			-- 技能当前回合数
	self.mSkillCreateFlag = false		-- 技能创建标识
	self.mSkillElement = nil			-- 技能元素
	self.mNormalType = 0				-- 普通元素类型
	self.mNormalElement = nil			-- 普通元素
	-- 数据获取
	local heroData = LogicTable:get("hero_tplt", heroId, true)
	local skillData = LogicTable:get("skill_tplt", heroData.skill_id, true)
	local skillElementData = LogicTable:get("element_tplt", skillData.element_id, true)
	-- 初始化英雄
	self.mHeroData  = heroData
	self.mHeroNode = Utils:createArmatureNode(heroData.display, G.HERO_IDLE, true)
	-- 初始化技能元素
	self.mSkillId = skillData.id
	self.mSkillTriggerRound = skillData.round
	self.mSkillElement = Factory:createSkillElement(self.mSkillId)
	local glProgramState = Utils:createShader(self.mSkillElement:getSprite(), "common.vsh", "show_per.fsh")
	glProgramState:setUniformFloatEx("fHave", self.mSkillCurrRound/self.mSkillTriggerRound)
	glProgramState:setUniformFloatEx("fWill", self.mSkillCurrRound/self.mSkillTriggerRound)
	self.mSkillElement:getSprite():setGLProgramState(glProgramState)
	self.mSkillElement:getSprite():setVisible(false)
	-- 初始化普通元素
	self.mNormalType = skillElementData.extra_type
	self.mNormalElement = Factory:createNormalElement(self.mNormalType)
	self.mNormalElement:onFocusEnter()
	self.mNormalElement:getSprite():setVisible(false)
end

-- 销毁函数
function Hero:destroy()
	if self.mHeroNode then
		self.mHeroNode:removeFromParent()
		self.mHeroNode = nil
	end
	if self.mSkillElement then
		self.mSkillElement:destroy()
		self.mSkillElement = nil
	end
	if self.mNormalElement then
		self.mNormalElement:destroy()
		self.mNormalElement = nil
	end
end

-- 获取影响数据
function Hero:getData()
	return self.mHeroData
end

-- 获取英雄节点
function Hero:getNode()
	return self.mHeroNode
end

-- 英雄待机
function Hero:playIdle()
	Utils:playArmatureAnimation(self.mHeroNode, G.HERO_IDLE, true)
end

-- 英雄准备攻击
function Hero:playPreAttack()
	Utils:playArmatureAnimation(self.mHeroNode, G.HERO_PREPARE, true)
end

-- 英雄攻击
function Hero:playAttack(attackCF)
	Utils:playArmatureAnimation(self.mHeroNode, G.HERO_ATTACK, false, function(armatureBack, movementType, movementId)
		if ccs.MovementEventType.complete == movementType and G.HERO_ATTACK == movementId then
			self:playIdle()
			Utils:doCallback(attackCF)
		end
	end)
end

-- 英雄胜利
function Hero:playWin()
	Utils:playArmatureAnimation(self.mHeroNode, G.HERO_WIN, false, function(armatureBack, movementType, movementId)
		if ccs.MovementEventType.complete == movementType and G.HERO_WIN == movementId then
			self:playIdle()
		end
	end)
end

-- 获取技能id
function Hero:getSkillId()
	return self.mSkillId
end

-- 获取技能触发回合
function Hero:getSkillTriggerRound()
	return self.mSkillTriggerRound
end

-- 获取技能当前回合
function Hero:getSkillCurrRound()
	return self.mSkillCurrRound
end

-- 获取技能元素精灵
function Hero:getSkillSprite()
	return self.mSkillElement:getSprite()
end

-- 隐藏技能元素精灵
function Hero:hideSkillSprite()
	self.mSkillElement:getSprite():setVisible(false)
end

-- 更新技能回合数
function Hero:updateSkillRound()
	if self.mSkillCreateFlag then
		return
	end
	self.mSkillCurrRound = self.mSkillCurrRound + 1
	if self.mSkillCurrRound >= self.mSkillTriggerRound then
		self.mSkillCreateFlag = true
	end
end

-- 显示技能回合数
function Hero:showSkillRound()
	local roundPercent = self.mSkillCurrRound/self.mSkillTriggerRound
	if roundPercent > 1 then
		roundPercent = 1
	end
	self.mSkillElement:getSprite():getGLProgramState():setUniformFloatEx("fHave", roundPercent)
	self.mSkillElement:getSprite():setVisible(true)
end

-- 显示技能追加回合数
function Hero:showSkillAppendRound(appendRound)
	local roundPercent = (self.mSkillCurrRound + appendRound)/self.mSkillTriggerRound
	if roundPercent > 1 then
		roundPercent = 1
	end
	self.mSkillElement:getSprite():getGLProgramState():setUniformFloatEx("fWill", roundPercent)
	self.mSkillElement:getSprite():setVisible(true)
end

-- 是否可生成技能
function Hero:isCanGenerateSkill()
	if self.mSkillCreateFlag then
		self.mSkillCreateFlag = false
		self.mSkillCurrRound = 0
		return true
	end
	return false
end

-- 获取普通元素类型
function Hero:getNormalType()
	return self.mNormalType
end

-- 获取普通元素精灵
function Hero:getNormalSprite()
	return self.mNormalElement:getSprite()
end

