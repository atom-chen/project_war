----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 怪物
----------------------------------------------------------------------
Monster = class("Monster")
MonsterHP = 0
-- 构造函数
function Monster:ctor(monsterId)
	-- 属性定义
	self.mMonsterId = monsterId				-- 怪物id
	self.mDisplay = ""						-- 怪物表现
	self.mMaxHP = 0							-- 最大生命值
	self.mCurrHP = 0						-- 当前生命值
	self.mThrowElementIdList = {}			-- 投放元素id列表
	self.mThrowTriggerType = 0				-- 投放元素触发类型(1.固定回合,2.随机回合)
	self.mThrowRound = 0					-- 投放回合数
	self.mCurrThrowRound = 0				-- 当前投放回合数(在达到该回合数时触发投放)
	self.mHitRound = 0						-- 当前受攻击回合数
	self.mThrowProbability = 0.0			-- 投放概率(当触发投放时,使用该概率来决定是否投放,该概率用万分比控制,如:0.02)
	self.mDefenseNormalType = 0				-- 可防御的普通元素类型
	self.mMonsterNode = nil					-- 怪物节点
	self.mBloodBgSprite = nil				-- 怪物血条背景精灵
	self.mCurrBloodProgress = nil			-- 怪物当前血条进度
	self.mGoalBloodProgress = nil			-- 怪物目标血条进度
	self.mHaveBloodLabelBMFont = nil		-- 怪物当前血条文本
	self.mWillBloodLabelBMFont = nil		-- 怪物未来血条文本
	self.mDefenseBgSprite = nil				-- 怪物防御背景精灵
	self.mDefenseSprite = nil				-- 怪物防御精灵
	-- 数据获取
	local monsterData = LogicTable:get("monster_tplt", monsterId, true)
	local defenseElementData = nil
	if monsterData.defense_element > 0 then
		defenseElementData = LogicTable:get("element_tplt", monsterData.defense_element, true)
	end
	self.mDisplay = monsterData.display
	-- 初始化怪物数据
	MonsterHP = monsterData.hp
	self.mMaxHP = monsterData.hp
	self.mCurrHP = self.mMaxHP
	self.mThrowElementIdList = monsterData.throw_id
	self.mThrowTriggerType = monsterData.throw_trigger_type
	self.mThrowRound = monsterData.round
	self.mCurrThrowRound = self:calcThrowRound(self.mThrowTriggerType, self.mThrowRound)
	self.mThrowProbability = monsterData.probability
	if defenseElementData then
		self.mDefenseNormalType = defenseElementData.sub_type
	end
	-- 创建怪物节点
	self.mMonsterNode = Utils:createArmatureNode(monsterData.display, G.MONSTER_IDLE, true)
	-- 创建怪物血条背景精灵
	if self.mCurrHP < G.HP1 then
		self.mBloodBgSprite = cc.Sprite:create("blood_01.png")
		self.mCurrBloodProgress = cc.ProgressTimer:create(cc.Sprite:create("blood_03.png"))
		self.mGoalBloodProgress = cc.ProgressTimer:create(cc.Sprite:create("blood_02.png"))
	elseif self.mCurrHP < G.HP2 and self.mCurrHP >= G.HP1 then
		self.mBloodBgSprite = cc.Sprite:create("blood_04.png")
		self.mCurrBloodProgress = cc.ProgressTimer:create(cc.Sprite:create("blood_06.png"))
		self.mGoalBloodProgress = cc.ProgressTimer:create(cc.Sprite:create("blood_05.png"))
	elseif self.mCurrHP < G.HP3 and self.mCurrHP >= G.HP2 then
		self.mBloodBgSprite = cc.Sprite:create("blood_07.png")
		self.mCurrBloodProgress = cc.ProgressTimer:create(cc.Sprite:create("blood_09.png"))
		self.mGoalBloodProgress = cc.ProgressTimer:create(cc.Sprite:create("blood_08.png"))
	else
		self.mBloodBgSprite = cc.Sprite:create("blood_10.png")
		self.mCurrBloodProgress = cc.ProgressTimer:create(cc.Sprite:create("blood_12.png"))
		self.mGoalBloodProgress = cc.ProgressTimer:create(cc.Sprite:create("blood_11.png"))
	end
	-- 创建怪物当前血条进度
	self.mCurrBloodProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	self.mCurrBloodProgress:setMidpoint(cc.p(0, 0.5))
	self.mCurrBloodProgress:setBarChangeRate(cc.p(1, 0))
	self.mCurrBloodProgress:setPercentage(100)
	-- 创建怪物目标血条进度
	self.mGoalBloodProgress:setType(cc.PROGRESS_TIMER_TYPE_BAR)
	self.mGoalBloodProgress:setMidpoint(cc.p(0, 0.5))
	self.mGoalBloodProgress:setBarChangeRate(cc.p(1, 0))
	self.mGoalBloodProgress:setPercentage(100)
	-- 创建怪物当前血条文本
	self.mHaveBloodLabelBMFont = cc.Label:createWithBMFont("font_01.fnt", "")
	self.mHaveBloodLabelBMFont:setVisible(false)
	-- 创建怪物未来血条文本
	self.mWillBloodLabelBMFont = cc.Label:createWithBMFont("font_01.fnt", "")
	self.mWillBloodLabelBMFont:setVisible(false)
	if self.mDefenseNormalType > 0 then
		-- 创建怪物防御背景精灵
		self.mDefenseBgSprite = cc.Sprite:create("defense_image.png")
		self.mDefenseBgSprite:setVisible(false)
		-- 创建怪物防御精灵
		self.mDefenseSprite = Factory:createDefenseSprite(self.mDefenseNormalType)
	end
end

-- 销毁函数
function Monster:destroy()
	MonsterHP = 0
	if self.mMonsterNode then
		self.mMonsterNode:removeFromParent()
		self.mMonsterNode = nil
	end
	if self.mBloodBgSprite then
		self.mBloodBgSprite:removeFromParent()
		self.mBloodBgSprite = nil
	end
	if self.mCurrBloodProgress then
		self.mCurrBloodProgress:removeFromParent()
		self.mCurrBloodProgress = nil
	end
	if self.mGoalBloodProgress then
		self.mGoalBloodProgress:removeFromParent()
		self.mGoalBloodProgress = nil
	end
	if self.mHaveBloodLabelBMFont then
		self.mHaveBloodLabelBMFont:removeFromParent()
		self.mHaveBloodLabelBMFont = nil
	end
	if self.mWillBloodLabelBMFont then
		self.mWillBloodLabelBMFont:removeFromParent()
		self.mWillBloodLabelBMFont = nil
	end
	if self.mDefenseBgSprite then
		self.mDefenseBgSprite:removeFromParent()
		self.mDefenseBgSprite = nil
	end
	if self.mDefenseSprite then
		self.mDefenseSprite:removeFromParent()
		self.mDefenseSprite = nil
	end
end

-- 怪物死亡效果
function Monster:deadEffect(effectCF)
	self.mBloodBgSprite:setVisible(false)
	self.mCurrBloodProgress:setVisible(false)
	self.mGoalBloodProgress:setVisible(false)
	if self.mDefenseBgSprite then
		self.mDefenseBgSprite:setVisible(false)
	end
	if self.mDefenseSprite then
		self.mDefenseSprite:setVisible(false)
	end
	Actions:fadeOut(self.mMonsterNode, 0.3, function()
		self:destroy()
		Utils:doCallback(effectCF)
	end)
end

-- 怪物预出生效果
function Monster:preBornEffect()
	self.mMonsterNode:setOpacity(0)
	self.mBloodBgSprite:setVisible(false)
	self.mCurrBloodProgress:setVisible(false)
	self.mGoalBloodProgress:setVisible(false)
	if self.mDefenseBgSprite then
		self.mDefenseBgSprite:setVisible(false)
	end
	if self.mDefenseSprite then
		self.mDefenseSprite:setVisible(false)
	end
end

-- 怪物出生效果
function Monster:bornEffect()
	Actions:fadeIn(self.mMonsterNode, 0.5, function()
		self.mBloodBgSprite:setVisible(true)
		self.mCurrBloodProgress:setVisible(true)
		self.mGoalBloodProgress:setVisible(true)
		if self.mDefenseBgSprite then
			self.mDefenseBgSprite:setVisible(true)
		end
		if self.mDefenseSprite then
			self.mDefenseSprite:setVisible(true)
		end
	end)
end

-- 计算投放回合数
function Monster:calcThrowRound(triggerType, round)
	if round <= 0 then
		return 0
	end
	if 1 == triggerType then			-- 固定回合
		return round
	elseif 2 == triggerType then		-- 随机回合
		return math.random(1, round)
	end
	return round
end

-- 获取怪物id
function Monster:getId()
	return self.mMonsterId 
end

-- 获取怪物表现
function Monster:getDisplay()
	return self.mDisplay
end

-- 获取怪物当前生命值
function Monster:getCurrHP()
	return self.mCurrHP
end

-- 获取怪物可防御的普通元素类型
function Monster:getDefenseNormalType()
	return self.mDefenseNormalType
end

-- 获取怪物节点
function Monster:getNode()
	return self.mMonsterNode
end

-- 获取怪物血条背景精灵
function Monster:getBloodBgSprite()
	return self.mBloodBgSprite
end

-- 获取怪物当前血条进度
function Monster:getCurrBloodProgress()
	return self.mCurrBloodProgress
end

-- 获取怪物目标血条进度
function Monster:getGoalBloodProgress()
	return self.mGoalBloodProgress
end

-- 获取怪物当前血条文本
function Monster:getHaveBloodLabelBMFont()
	return self.mHaveBloodLabelBMFont
end

-- 获取怪物未来血条文本
function Monster:getWillBloodLabelBMFont()
	return self.mWillBloodLabelBMFont
end

-- 获取怪物防御背景精灵
function Monster:getDefenseBgSprite()
	return self.mDefenseBgSprite
end

-- 获取怪物防御精灵
function Monster:getDefenseSprite()
	return self.mDefenseSprite
end

-- 怪物待机
function Monster:playIdle()
	Utils:playArmatureAnimation(self.mMonsterNode, G.MONSTER_IDLE, true)
end

-- 怪物攻击
function Monster:playAttack(attackCF)
	Utils:playArmatureAnimation(self.mMonsterNode, G.MONSTER_ATTACK, false, function(armatureBack, movementType, movementId)
		if ccs.MovementEventType.complete == movementType and G.MONSTER_ATTACK == movementId then
			self:playIdle()
			Utils:doCallback(throwCF)
		end
	end)
end

-- 怪物被击
function Monster:playHit(hitCF)
	Utils:playArmatureAnimation(self.mMonsterNode, G.MONSTER_HIT, false, function(armatureBack, movementType, movementId)
		if ccs.MovementEventType.complete == movementType and G.MONSTER_HIT == movementId then
			self:playIdle()
			Utils:doCallback(hitCF)
		end
	end)
end

-- 怪物死亡
function Monster:playDie(dieCF)
	AudioMgr:playEffect(2402)
	Utils:playArmatureAnimation(self.mMonsterNode, G.MONSTER_DIE, false, function(armatureBack, movementType, movementId)
		if ccs.MovementEventType.complete == movementType and G.MONSTER_DIE == movementId then
			Utils:doCallback(dieCF)
		end
	end)
end

-- 怪物是否死亡
function Monster:isDeath()
	return self.mCurrHP <= 0
end

-- 更新怪物生命值
function Monster:updateHP(hitBlood, all)
	if 0 == hitBlood or 0 == self.mCurrHP then
		return false
	end
	if hitBlood >= self.mCurrHP then
		hitBlood = hitBlood - self.mCurrHP
		self.mCurrHP = 0
	else
		self.mCurrHP = self.mCurrHP - hitBlood
	end
	MonsterHP = self.mCurrHP
	local hpPercent = self.mCurrHP/self.mMaxHP
	if hpPercent > 1 then
		hpPercent = 1
	end
	self.mCurrBloodProgress:setPercentage(hpPercent * 100)
	if all then
		self.mGoalBloodProgress:setPercentage(hpPercent * 100)
	end
	return true
end

-- 显示怪物当前生命值
function Monster:showHaveHp()
	-- 血条精灵
	local currPercent = self.mCurrHP/self.mMaxHP
	if currPercent > 1 then
		currPercent = 1
	end
	self.mCurrBloodProgress:setPercentage(currPercent * 100)
	-- 血条文本
	self.mHaveBloodLabelBMFont:setString(self.mCurrHP.."/"..self.mMaxHP)
	self.mHaveBloodLabelBMFont:setVisible(true)
end

-- 隐藏怪物当前生命值
function Monster:hideHaveHp()
	self.mHaveBloodLabelBMFont:setVisible(false)
end

-- 显示怪物下一刻生命值
function Monster:showWillHP(hitBlood)
	-- 血条精灵
	local willHP = self.mCurrHP - hitBlood
	local willPercent = willHP/self.mMaxHP
	if willPercent > 1 then
		willPercent = 1
	end
	self.mGoalBloodProgress:setPercentage(willPercent * 100)
	-- 血条文本
	self.mWillBloodLabelBMFont:setString(hitBlood.."/"..self.mMaxHP)
	self.mWillBloodLabelBMFont:setVisible(true)
end

-- 重置怪物下一刻生命值
function Monster:resetWillHP()
	self.mGoalBloodProgress:setPercentage((self.mCurrHP/self.mMaxHP) * 100)
	self.mWillBloodLabelBMFont:setVisible(false)
end

-- 显示怪物防御背景精灵
function Monster:showDefenseBgSprite()
	if self.mDefenseBgSprite then
		self.mDefenseBgSprite:setVisible(true)
	end
end

-- 隐藏怪物防御背景精灵
function Monster:hideDefenseBgSprite()
	if self.mDefenseBgSprite then
		self.mDefenseBgSprite:setVisible(false)
	end
end

-- 更新受攻击回合数,返回投放元素id列表
function Monster:updateHitRound()
	if 0 == self.mCurrThrowRound then
		return {}
	end
	self.mHitRound = self.mHitRound + 1		-- 受攻击回合数增加
	if self.mHitRound == self.mCurrThrowRound then	-- 达到投放回合数
		-- 重新计算下一次投放回合数
		self.mCurrThrowRound = self:calcThrowRound(self.mThrowTriggerType, self.mThrowRound)
		self.mHitRound = 0
		-- 计算投放概率
		if CommonFunc:probability(self.mThrowProbability) then
			return CommonFunc:clone(self.mThrowElementIdList)
		end
	end
	return {}
end


