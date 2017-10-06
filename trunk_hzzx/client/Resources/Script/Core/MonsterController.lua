----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 怪物控制器
----------------------------------------------------------------------
MonsterController = class("MonsterController", Component)

-- 构造函数
function MonsterController:ctor()
	self.super:ctor(self.__cname)
	self.mMonsterIds = {}				-- 怪物id列表
	self.mMonsterIndex = 0				-- 当前怪物索引
	self.mMonster = nil					-- 当前怪物
	self.mTouchedHitType = 0			-- 触摸攻击类型
	self.mTotalHitCount = 0				-- 受攻击总次数
	self.mTotalHitBlood = 0				-- 受攻击总掉血
	self.mHitBloodList = {}				-- 受攻击掉血列表
	self.mMultiple = 1					-- 受攻击翻倍数
	self.mIsOnClear = false				-- 是否在消除格子中
	self.mIsOnHit = false				-- 是否被击状态中
	self.mIsStartHurt = true			-- 是否开始受伤害
	self.mIsNewMonster = true			-- 是否是新怪物
	self.mComboLabelBMFont = nil		-- 翻倍提示文本
	self.mDefenseShieldSprite = nil		-- 防御盾牌精灵
	self.mIsGameSuccess = false			-- 游戏是否成功
	-- 注册事件
	self:subscribeEvent(EventDef["ED_TOUCH_GRID_BEGIN"], self.handleTouchGridBegin)
	self:subscribeEvent(EventDef["ED_TOUCH_GRID_MOVE"], self.handleTouchGridMove)
	self:subscribeEvent(EventDef["ED_TOUCH_GRID_END"], self.handleTouchGridEnd)
	self:subscribeEvent(EventDef["ED_CLEAR_BEGIN"], self.handleClearBegin)
	self:subscribeEvent(EventDef["ED_CLEAR_END"], self.handleClearEnd)
	self:subscribeEvent(EventDef["ED_GAME_SUCCESS"], self.handleGameSuccess)
end

-- 初始化
function MonsterController:init(monsterIds)
	self.mMonsterIds = monsterIds
	-- 翻倍提示文本
	local comboLabelBMFont = cc.Label:createWithBMFont("font_01.fnt", "", cc.TEXT_ALIGNMENT_CENTER)
	comboLabelBMFont:setAnchorPoint(cc.p(0.5, 1))
	comboLabelBMFont:setPosition(cc.p(80, 780))
	comboLabelBMFont:setVisible(false)
	self:getMaster():getSceneLayer():addChild(comboLabelBMFont, G.SCENE_ZORDER_MONSTER)
	self.mComboLabelBMFont = comboLabelBMFont
	-- 防御盾牌
	local defenseShieldSprite = cc.Sprite:create("defense_image.png")
	defenseShieldSprite:setVisible(false)
	self:getMaster():getTopLayer():addChild(defenseShieldSprite, G.TOP_ZORDER_TIP)
	Actions:scaleAction02(defenseShieldSprite, 1.15)
	self.mDefenseShieldSprite = defenseShieldSprite
end

-- 生成怪物
function MonsterController:generateMonster(index, destroyCF)
	local oldMonster = self.mMonster
	self.mMonster = nil
	if nil == self.mMonsterIds[index] then
		self:destroyMonster(oldMonster, destroyCF)
		return false
	end
	-- 位置
	local boothSprite = self:getSibling("SceneController"):getBoothSprite()
	local boothSize = boothSprite:getContentSize()
	local xPos, yPos = boothSprite:getPosition()
	-- 怪物
	self.mMonsterIndex = index
	self.mMonster = Factory:createMonster(self.mMonsterIds[index], cc.p(xPos, yPos + boothSize.height/2 + 10), self:getMaster():getSceneLayer())
	self.mMonster:preBornEffect()
	self.mIsNewMonster = true
	self:destroyMonster(oldMonster, function()
		self.mMonster:bornEffect()
		Utils:doCallback(destroyCF)
	end)
	return true
end

-- 销毁怪物
function MonsterController:destroyMonster(monster, destroyCF)
	if nil == monster then
		Utils:doCallback(destroyCF)
		return
	end
	local xPos, yPos = monster:getNode():getPosition()
	monster:deadEffect(function()
		if nil == self.mMonster then
			Utils:doCallback(destroyCF)
			return
		end
		-- 光束
		local appearEffect = Utils:createArmatureNode("monster_appear")
		appearEffect:setScale(1.7)
		appearEffect:setOpacity(100)
		appearEffect:setPosition(cc.p(xPos, yPos + 30))
		self:getMaster():getSceneLayer():addChild(appearEffect, G.SCENE_ZORDER_PARTICLE_OUT)
		Utils:playArmatureAnimation(appearEffect, "idle", false, function(armatureBack, movementType, movementId)
			if ccs.MovementEventType.complete == movementType and "idle" == movementId then
				appearEffect:removeFromParent()
				Utils:doCallback(destroyCF)
			end
		end)
		-- 粒子
		Actions:delayWith(self:getMaster():getSceneLayer(), 0.3, function()
			local particleNode = Utils:createParticle("test.plist", true)
			particleNode:setPosition(cc.p(xPos, yPos + 60))
			self:getMaster():getSceneLayer():addChild(particleNode, G.SCENE_ZORDER_PARTICLE_OUT)
		end)
	end)
	self:getSibling("HeroController"):winCheer()
	EventDispatcher:post(EventDef["ED_KILL_MONSTER"])
end

-- 获取怪物
function MonsterController:getMonster()
	return self.mMonster
end

-- 计算普通元素攻击力
function MonsterController:calcNormalAttack(normalType)
	local hero = self:getSibling("HeroController"):getHero(normalType)
	if nil == hero then		-- 普通攻击
		return G.NORMAL_BASE_ATTACK
	end
	-- 英雄攻击
	return hero:getData().attack
end

-- 计算技能元素攻击力
function MonsterController:calcSkillAttack(normalType)
	local hero = self:getSibling("HeroController"):getHero(normalType)
	if nil == hero then		-- 普通攻击
		return G.SKILL_BASE_ATTACK
	end
	-- 英雄攻击
	local skillAttack = G.SKILL_BASE_ATTACK
	for i=1, hero:getData().level do
		if i > 1 and i <= 4 then
			skillAttack = skillAttack + G.SKILL_DELTA_ATTACK1
		elseif i >= 5 and i <= 9 then
			skillAttack = skillAttack + G.SKILL_DELTA_ATTACK2
		elseif i >= 10 and i <= 14 then
			skillAttack = skillAttack + G.SKILL_DELTA_ATTACK3
		elseif i >= 15 and i <= 20 then
			skillAttack = skillAttack + G.SKILL_DELTA_ATTACK4
		end
	end
	return skillAttack
end

-- 根据连接个数计算倍数
function MonsterController:calcMultiple(count)
	if count >= 6 and count < 10 then
		return 1.2
	elseif count >= 10 and count < 15 then
		return 1.5
	elseif count >= 15 then
		return 2.0
	end
	return 1.0
end

-- 获取翻倍信息
function MonsterController:getMultipleInfo(multiple)
	local multipleInfoList = {
		[1.0] = {
			font_file = "font_01.fnt",		-- 字体
			combo_tip_s = "Combo ",			-- 翻倍提示1
			combo_tip_e = "\nx1",			-- 翻倍提示2
			praise_tip = "GOOD!",			-- 表扬提示
			scale_factor = 1.0,				-- 缩放系数
			sound_id = 2201,				-- 音效id
		},
		[1.2] = {
			font_file = "font_02.fnt",
			combo_tip_s = "Combo ",
			combo_tip_e = "\nx1.2",
			praise_tip = "GOOD!",
			scale_factor = 1.2,
			sound_id = 2201,
		},
		[1.5] = {
			font_file = "font_03.fnt",
			combo_tip_s = "Combo ",
			combo_tip_e = "\nx1.5",
			praise_tip = "GREAT!",
			scale_factor = 1.4,
			sound_id = 2202,
		},
		[2.0] = {
			font_file = "font_04.fnt",
			combo_tip_s = "Combo ",
			combo_tip_e = "\nx2",
			praise_tip = "EXCELLENT!",
			scale_factor = 1.6,
			sound_id = 2203,
		}
	}
	return multipleInfoList[multiple]
end

-- 计算受攻击信息
function MonsterController:calcHitInfo(touchedType, totalCountList, normalCountList, skillCountList, monsterDefenseType)
	local hitInfo = {
		total_hit_count = 0,		-- 总攻击次数
		total_hit_blood = 0,		-- 总攻击血量
		hit_blood_list = {},		-- 每种元素总攻击去血列表
		count = 0,					-- 个数
		multiple = 1,				-- 倍数
	}
	for normalType, count in pairs(totalCountList) do
		hitInfo.total_hit_count = hitInfo.total_hit_count + count
		local normalHitBlood = self:calcNormalAttack(normalType)*(normalCountList[normalType] or 0)
		local skillHitBlood = self:calcSkillAttack(normalType)*(skillCountList[normalType] or 0)
		local hitBlood = normalHitBlood + skillHitBlood
		if normalType == touchedType then
			hitInfo.count = count
			hitInfo.multiple = self:calcMultiple(count)
			hitBlood = math.ceil(hitBlood * hitInfo.multiple)
		end
		if normalType == monsterDefenseType then
			hitBlood = 0
		end
		hitInfo.total_hit_blood = hitInfo.total_hit_blood + hitBlood
		hitInfo.hit_blood_list[normalType] = hitBlood
	end
	return hitInfo
end

-- 减少受攻击血量(reduceType:1.全部清空,2.清空指定类型,3.减少指定类型,4.减少总量)
function MonsterController:reduceHitBlood(reduceType, normalType, reduceBlood)
	if 1 == reduceType then
		self.mHitBloodList = {}
	elseif 2 == reduceType or nil == reduceBlood then
		self.mHitBloodList[normalType] = nil
	elseif 3 == reduceType then
		Core:decreaseCount(self.mHitBloodList, normalType, reduceBlood)
	elseif 4 == reduceType then
		for normalType, hitBlood in pairs(self.mHitBloodList) do
			if reduceBlood >= hitBlood then
				self.mHitBloodList[normalType] = nil
				reduceBlood = reduceBlood - hitBlood
			else
				self.mHitBloodList[normalType] = hitBlood - reduceBlood
				reduceBlood = 0
			end
		end
	end
end

-- 获取总受攻击血量
function MonsterController:getTotalHitBlood()
	local totalHitBlood = 0
	for normalType, hitBlood in pairs(self.mHitBloodList) do
		totalHitBlood = totalHitBlood + (hitBlood or 0)
	end
	return totalHitBlood
end

-- 显示怪物血条
function MonsterController:showMonsterHP(touchedHitType, totalHitBlood, count, multiple)
	local multipleInfo = self:getMultipleInfo(multiple)
	if self.mMonster then
		self.mMonster:showWillHP(totalHitBlood)
		-- 怪物未来血条文本
		local monsterWillBloodLabelBMFont = self.mMonster:getWillBloodLabelBMFont()
		monsterWillBloodLabelBMFont:setBMFontFilePath(multipleInfo.font_file)
		monsterWillBloodLabelBMFont:stopAllActions()
		monsterWillBloodLabelBMFont:setScale(multipleInfo.scale_factor)
		if totalHitBlood > self.mTotalHitBlood then		-- 掉血增加
			Actions:scaleAction01(monsterWillBloodLabelBMFont, multipleInfo.scale_factor*1.2)
		end
		-- 防御类型
		if touchedHitType > 0 and touchedHitType == self.mMonster:getDefenseNormalType() then
			-- 怪物防御背景精灵
			local monsterDefenseBgSprite = self.mMonster:getDefenseBgSprite()
			if monsterDefenseBgSprite then
				self.mMonster:showDefenseBgSprite()
				monsterDefenseBgSprite:stopAllActions()
				monsterDefenseBgSprite:setScale(0.7)
				Actions:scaleAction01(monsterDefenseBgSprite, monsterDefenseBgSprite:getScale()*1.8)
			end
			-- 怪物防御精灵
			local monsterDefenseSprite = self.mMonster:getDefenseSprite()
			if monsterDefenseSprite then
				monsterDefenseSprite:stopAllActions()
				monsterDefenseSprite:setScale(1)
				Actions:scaleAction01(monsterDefenseSprite, monsterDefenseSprite:getScale()*1.8)
			end
			self.mDefenseShieldSprite:setVisible(true)
		end
	end
	-- 翻倍提示文本
	self.mComboLabelBMFont:setString(multipleInfo.combo_tip_s..count..multipleInfo.combo_tip_e)
	if 1 == multiple then
		self.mComboLabelBMFont:setVisible(false)
	elseif multiple > 1 and (multiple ~= self.mMultiple or not self.mComboLabelBMFont:isVisible()) then
		self.mComboLabelBMFont:setBMFontFilePath(multipleInfo.font_file)
		self.mComboLabelBMFont:stopAllActions()
		self.mComboLabelBMFont:setScale(1)
		self.mComboLabelBMFont:setVisible(true)
		Actions:scaleAction02(self.mComboLabelBMFont, multipleInfo.scale_factor)
	end
end

-- 怪物受伤害
function MonsterController:onHurt(hitElement, index)
	self.mTotalHitCount = self.mTotalHitCount - 1
	self.mIsOnHit = true
	local hitNormalType, hitBlood = 0, 0
	if ElementType["normal"] == hitElement:getType() then
		hitNormalType = hitElement:getSubType()
		hitBlood = self:calcNormalAttack(hitNormalType)
	elseif ElementType["skill"] == hitElement:getType() then
		hitNormalType = hitElement:getExtraType()
		if hitElement:isCanTouch() then
			hitBlood = self:calcSkillAttack(hitNormalType)
		else
			hitBlood = self:calcNormalAttack(hitNormalType)
		end
	end
	-- 可防御
	if hitNormalType == self.mMonster:getDefenseNormalType() then
		self:reduceHitBlood(2, hitNormalType, nil)
		-- 怪物防御精灵
		local monsterDefenseSprite = self.mMonster:getDefenseSprite()
		monsterDefenseSprite:stopAllActions()
		monsterDefenseSprite:setScale(1)
		Actions:scaleAction01(monsterDefenseSprite, 1.5)
		if 0 == index % 2 then	-- 攻击元素飞向左边
			Actions:moveScaleAction03(hitElement:getSprite(), cc.p(0, 600))
		else					-- 攻击元素飞向右边
			Actions:moveScaleAction03(hitElement:getSprite(), cc.p(G.VISIBLE_SIZE.width, 600))
		end
		-- 怪物防御音效
		AudioMgr:playEffect(2404)
		-- 所有攻击结束
		if 0 == self.mTotalHitCount then
			self.mComboLabelBMFont:setVisible(false)
			self.mMonster:resetWillHP()
			self:checkDeath()
		end
		return
	end
	-- 不可防御
	hitElement:destroy()
	if hitNormalType == self.mTouchedHitType then
		hitBlood = math.ceil(hitBlood * self.mMultiple)
	end
	if self.mIsStartHurt then
		self.mIsStartHurt = false
		self.mMonster:playHit()
		-- 怪物被击特效
		local particle = Utils:createParticle("monsterhit.plist", true)
		local xPos, yPos = self.mMonster:getNode():getPosition()
		particle:setPosition(cc.p(xPos, yPos + 60))
		self:getMaster():getSceneLayer():addChild(particle, G.SCENE_ZORDER_MONSTER)
		-- 怪物被击音效
		AudioMgr:playEffect(2403)
	end
	self:onHitBlood(hitNormalType, hitBlood)
end

-- 怪物掉血
function MonsterController:onHitBlood(hitNormalType, hitBlood)
	local monsterHP = self.mMonster:getCurrHP()
	local remainHitBlood = hitBlood - monsterHP
	if self.mMonster:updateHP(hitBlood) then
		if remainHitBlood > 0 then
			self:reduceHitBlood(3, hitNormalType, monsterHP)
		else
			self:reduceHitBlood(3, hitNormalType, hitBlood)
		end
	end
	-- 所有攻击结束
	if 0 == self.mTotalHitCount then
		self.mComboLabelBMFont:setVisible(false)
		self.mMonster:resetWillHP()
		self:checkDeath()
	end
end

-- 检查死亡
function MonsterController:checkDeath()
	-- 怪物活着
	if not self.mMonster:isDeath() then
		self.mIsNewMonster = false
		if not self.mIsOnClear then
			self:getSibling("GridController"):startDropGridList(nil, nil, true)
		end
		self.mIsOnHit = false
		return
	end
	-- 怪物死亡
	self.mMonster:playDie(function()
		self:generateMonster(self.mMonsterIndex + 1)
		if not self.mIsOnClear then
			self:getSibling("GridController"):startDropGridList(nil, nil, true)
		end
		self.mIsOnHit = false
	end)
end

-- 怪物攻击
function MonsterController:monsterAttack(doDrop)
	-- 怪物不存在
	if nil == self.mMonster then
		self:getSibling("ThrowController"):triggerThrowReplace()
		return
	end
	-- 老怪物
	if not self.mIsNewMonster then
		local throwElementIds = {}
		if doDrop then
			throwElementIds = self.mMonster:updateHitRound()
		end
		local throwFlag = self:getSibling("ThrowController"):throwToGrid(throwElementIds, function()
			self:getSibling("ThrowController"):triggerThrowReplace()
		end)
		if throwFlag then
			self.mMonster:playAttack()
		end
		return
	end
	-- 新怪物(检测被击余波)
	self.mIsNewMonster = false
	local function checkHitRemain()
		if nil == self.mMonster then
			self:getSibling("ThrowController"):triggerThrowReplace()
			return
		end
		self:reduceHitBlood(2, self.mMonster:getDefenseNormalType(), nil)
		local totalHitBlood = self:getTotalHitBlood()
		if 0 == totalHitBlood then
			self:getSibling("ThrowController"):triggerThrowReplace()
			return
		end
		-- 新怪物掉血
		local monsterHP = self.mMonster:getCurrHP()
		if totalHitBlood > monsterHP then
			if self.mMonster:updateHP(monsterHP) then
				self:reduceHitBlood(4, nil, monsterHP)
			end
		else
			if self.mMonster:updateHP(totalHitBlood) then
				self:reduceHitBlood(1, nil, nil)
			end
		end
		-- 新怪物活着
		if not self.mMonster:isDeath() then
			self:getSibling("ThrowController"):triggerThrowReplace()
			return
		end
		-- 新怪物死亡
		self.mMonster:playDie(function()
			self:generateMonster(self.mMonsterIndex + 1, function()
				checkHitRemain()
			end)
		end)
	end
	checkHitRemain()
end

-- 处理触摸格子开始事件
function MonsterController:handleTouchGridBegin(touchParam)
	self:handleTouchGridMove(touchParam)
end

-- 处理触摸格子移动事件
function MonsterController:handleTouchGridMove(touchParam)
	-- 计算受攻击信息
	local hitInfo = nil
	if nil == self.mMonster then
		hitInfo = self:calcHitInfo(touchParam.touched_type, touchParam.total_count_list, touchParam.normal_count_list, touchParam.skill_count_list, 0)
		self.mIsStartHurt = false
	else
		hitInfo = self:calcHitInfo(touchParam.touched_type, touchParam.total_count_list, touchParam.normal_count_list, touchParam.skill_count_list, self.mMonster:getDefenseNormalType())
		self.mIsStartHurt = true
	end
	-- 显示怪物血条
	self:showMonsterHP(touchParam.touched_type, hitInfo.total_hit_blood, hitInfo.count, hitInfo.multiple)
	-- 数据缓存
	self.mTouchedHitType = touchParam.touched_type
	self.mTotalHitCount = hitInfo.total_hit_count
	self.mTotalHitBlood = hitInfo.total_hit_blood
	self.mHitBloodList = hitInfo.hit_blood_list
	self.mMultiple = hitInfo.multiple
end

-- 处理触摸格子结束事件
function MonsterController:handleTouchGridEnd(touchParam)
	self.mTotalHitBlood = 0
	if self.mMonster then
		self.mMonster:hideDefenseBgSprite()
	end
	if not touchParam.can_clear_flag then
		if self.mMonster then
			self.mMonster:resetWillHP()
		end
		self.mComboLabelBMFont:setVisible(false)
	end
end

-- 处理消除开始事件
function MonsterController:handleClearBegin()
	if self.mIsGameSuccess then
		return
	end
	self.mIsOnClear = true
	if self.mMultiple > 1 then
		local multipleInfo = self:getMultipleInfo(self.mMultiple)
		local praiseLabelBMFont = cc.Label:createWithBMFont(multipleInfo.font_file, multipleInfo.praise_tip)
		praiseLabelBMFont:setAnchorPoint(cc.p(0.5, 1))
		praiseLabelBMFont:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 500))
		praiseLabelBMFont:setScale(2)
		self:getMaster():getTopLayer():addChild(praiseLabelBMFont, G.TOP_ZORDER_TIP)
		Actions:moveScaleAction01(praiseLabelBMFont, cc.p(G.VISIBLE_SIZE.width/2, 900))
		if multipleInfo.sound_id > 0 then
			AudioMgr:playEffect(multipleInfo.sound_id)
		end
	end
end

-- 处理消除结束
function MonsterController:handleClearEnd()
	if self.mIsGameSuccess then
		return
	end
	if nil == self.mMonster then
		self.mComboLabelBMFont:setVisible(false)
		if not self.mIsOnHit then
			self:getSibling("GridController"):startDropGridList(nil, nil, true)
		end
	end
	self.mIsOnClear = false
end

-- 处理游戏成功
function MonsterController:handleGameSuccess()
	self.mIsGameSuccess = true
end

-- 触摸开始
function MonsterController:onTouchBegan(touch, event, gridInfo)
	self:onTouchMoved(touch, event, gridInfo)
end

-- 触摸移动
function MonsterController:onTouchMoved(touch, event, gridInfo)
	if nil == self.mMonster then
		return
	end
	self.mDefenseShieldSprite:setPosition(touch:getLocation())
end

-- 触摸结束
function MonsterController:onTouchEnded(touch, event, gridInfo)
	if nil == self.mMonster then
		return
	end
	self.mDefenseShieldSprite:setVisible(false)
end

-- 触摸取消
function MonsterController:onTouchCancelled(touch, event, gridInfo)
	self:onTouchEnded(touch, event, gridInfo)
end

