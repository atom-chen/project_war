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
	self.mCurrHitCount = 0				-- 受攻击次数
	self.mTotalHitCount = 0				-- 受攻击总次数
	self.mTotalHitBlood = 0				-- 受攻击总掉血
	self.mHitBloodList = {}				-- 受攻击掉血列表
	self.mMultiple = 1					-- 受攻击翻倍数
	self.mIsOnClear = false				-- 是否在消除格子中
	self.mIsOnHit = false				-- 是否被击状态中
	self.mIsStartHurt = true			-- 是否开始受伤害
	self.mIsNewMonster = true			-- 是否是新怪物
	self.mCountLabel = nil				-- 翻倍数量
	self.mComboSprite = nil				-- 翻倍图片
	self.mDefenseShieldSprite = nil		-- 防御盾牌精灵
	self.mIsGameSuccess = false			-- 游戏是否成功
	-- 注册事件
	self:bind(EventDef["ED_TOUCH_GRID_BEGIN"], self.handleTouchGridBegin, self)
	self:bind(EventDef["ED_TOUCH_GRID_MOVE"], self.handleTouchGridMove, self)
	self:bind(EventDef["ED_TOUCH_GRID_END"], self.handleTouchGridEnd, self)
	self:bind(EventDef["ED_CLEAR_BEGIN"], self.handleClearBegin, self)
	self:bind(EventDef["ED_CLEAR_END"], self.handleClearEnd, self)
	self:bind(EventDef["ED_GAME_SUCCESS"], self.handleGameSuccess, self)
end

-- 初始化
function MonsterController:init(monsterIds)
	self.mMonsterIds = monsterIds
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
	EventCenter:post(EventDef["ED_KILL_MONSTER"])
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
			font_file = "font_01.fnt",		-- 字体文件
			font_png = "font_1.png",		-- 字体图片
			praise_tip = "good.png",		-- 表扬提示
			combo_png = "combo_1.png",		-- 翻倍图片
			scale_factor = 1.0,				-- 缩放系数
			sound_id = 2201,				-- 音效id
		},
		[1.2] = {
			font_file = "font_02.fnt",
			font_png = "font_1.png",
			praise_tip = "good.png",
			combo_png = "combo_1.png",
			scale_factor = 1.2,
			sound_id = 2201,
		},
		[1.5] = {
			font_file = "font_03.fnt",
			font_png = "font_2.png",
			praise_tip = "great.png",
			combo_png = "combo_2.png",
			scale_factor = 1.4,
			sound_id = 2202,
		},
		[2.0] = {
			font_file = "font_04.fnt",
			font_png = "font_3.png",
			praise_tip = "excellent.png",
			combo_png = "combo_3.png",
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

-- 翻倍数量
function MonsterController:createComboCount(fontPng)
	if not isNil(self.mCountLabel) then
		self.mCountLabel:removeFromParent()
	end
	self.mCountLabel = cc.LabelAtlas:_create("0", fontPng, 61, 74,  string.byte("0"))
	self.mCountLabel:setAnchorPoint(cc.p(0.5, 0.5))
	self.mCountLabel:setPosition(cc.p(50, 750))
	self.mCountLabel:setRotation(-23)
	self:getMaster():getSceneLayer():addChild(self.mCountLabel, G.SCENE_ZORDER_TIP)
end

-- 翻倍图片
function MonsterController:createComboSprite()
	if not isNil(self.mComboSprite) then
		self.mComboSprite:removeFromParent()
	end
	self.mComboSprite = cc.Sprite:create("combo.png")
	self.mComboSprite:setAnchorPoint(cc.p(0.5, 0.5))
	self.mComboSprite:setPosition(cc.p(160, 800))
	self.mComboSprite:setRotation(-23)
	self:getMaster():getSceneLayer():addChild(self.mComboSprite, G.SCENE_ZORDER_TIP)
	self.mComboSprite:setOpacity(0)
	Actions:fadeIn(self.mComboSprite, 0.5, function()
		Actions:moveBy(self.mComboSprite, 2, cc.p(5, 5), function()
			Actions:moveBy(self.mComboSprite, 5, cc.p(5, 5), function()
				Actions:moveBy(self.mComboSprite, 10, cc.p(5, 5))
			end)
		end)
	end)
end

-- 隐藏翻倍提示
function MonsterController:hideCombo()
	if not isNil(self.mCountLabel) then
		self.mCountLabel:removeFromParent()
		self.mCountLabel = nil
	end
	if not isNil(self.mComboSprite) then
		self.mComboSprite:removeFromParent()
		self.mComboSprite = nil
	end
end

-- 创建翻倍文本
function MonsterController:createComboLabel()
	if 1 == self.mMultiple then
		return
	end
	-- 闪光特效
	local flashSprite = cc.Sprite:create("flash.png")
	flashSprite:setAnchorPoint(cc.p(0.5, 0.5))
	flashSprite:setPosition(cc.p(120, 780))
	flashSprite:setRotation(-23)
	self:getMaster():getSceneLayer():addChild(flashSprite, G.SCENE_ZORDER_TIP)
	Actions:scaleFromTo(flashSprite, 0.2, 1, 1.8)
	Actions:fadeOut(flashSprite, 0.2, function()
		if not isNil(flashSprite) then flashSprite:removeFromParent() end
		-- 翻倍文本
		local node = cc.Node:create()
		node:setAnchorPoint(cc.p(0.5, 0.5))
		node:setPosition(cc.p(120, 780))
		node:setRotation(-23)
		self:getMaster():getSceneLayer():addChild(node, G.SCENE_ZORDER_TIP)
		local tipLabel = cc.Sprite:create("combo_text.png")
		tipLabel:setPosition(cc.p(0, 23))
		node:addChild(tipLabel)
		local multipleInfo = self:getMultipleInfo(self.mMultiple)
		local comboSprite = cc.Sprite:create(multipleInfo.combo_png)
		comboSprite:setPosition(cc.p(0, -23))
		node:addChild(comboSprite)
		Actions:scaleFromTo(node, 0.2, 1.7, 0.9, function()
			Actions:scaleFromTo(node, 0.2, 0.9, 1, function()
				Actions:fadeOut(node, 1.5, function()
					if not isNil(node) then node:removeFromParent() end
				end)
			end)
		end)
	end)
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
	-- 翻倍提示
	if 1 == multiple then
		self:hideCombo()
	elseif multiple > 1 then
		if multiple ~= self.mMultiple then
			self:createComboCount(multipleInfo.font_png)
		end
		if 1 == self.mMultiple then
			self:createComboSprite()
		end
		self.mCountLabel:setString(tostring(count))
		if count < 10 then
			Actions:comboCountScale(self.mCountLabel, 1)
		else
			Actions:comboCountScale(self.mCountLabel, 0.8)
		end
	end
end

-- 怪物受伤害
function MonsterController:onHurt(hitElement, index)
	self.mCurrHitCount = self.mCurrHitCount + 1
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
		if self.mCurrHitCount == self.mTotalHitCount then
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
		local xPos, yPos = self.mMonster:getNode():getPosition()
		local particle = Utils:createParticle("monsterhit.plist", true)
		particle:setPosition(cc.p(xPos, yPos + 60))
		self:getMaster():getSceneLayer():addChild(particle, G.SCENE_ZORDER_MONSTER)
		local hitEffect = nil
		hitEffect = Utils:createArmatureNode("monster_hit", "idle", false, function(armatureBack, movementType, movementId)
			if ccs.MovementEventType.complete == movementType and "idle" == movementId then
				hitEffect:removeFromParent()
			end
		end)
		hitEffect:setAnchorPoint(cc.p(0.5, 0.5))
		hitEffect:setPosition(cc.p(xPos, yPos + 80))
		self:getMaster():getSceneLayer():addChild(hitEffect, G.SCENE_ZORDER_MONSTER)
		-- 怪物被击音效
		AudioMgr:playEffect(2403)
	end
	self:onHitBlood(hitNormalType, hitBlood)
end

-- 播放怪物掉血特效
function MonsterController:playDropBloodEffect(hitNormalType, blood)
	local fontPngList = {"font_red.png", "font_yellow.png", "font_green.png", "font_blue.png", "font_purple.png"}
	local center, radius = cc.p(G.VISIBLE_SIZE.width/2, 740), 180
	local bloodLabel = cc.LabelAtlas:_create(tostring(blood), fontPngList[hitNormalType], 22, 26,  string.byte("0"))
	bloodLabel:setAnchorPoint(cc.p(0.5, 0.5))
	bloodLabel:setPosition(center)
	self:getMaster():getTopLayer():addChild(bloodLabel, G.TOP_ZORDER_TIP)
	local x = math.random(center.x - radius, center.x + radius)
	local y = center.y + math.sqrt(radius*radius-((x-center.x)*(x-center.x)))
	Actions:monsterDropOfBlood(bloodLabel, cc.p(x, y))
end

-- 怪物掉血
function MonsterController:onHitBlood(hitNormalType, hitBlood)
	local monsterHP = self.mMonster:getCurrHP()
	local remainHitBlood = hitBlood - monsterHP
	if self.mMonster:updateHP(hitBlood, false) then
		if remainHitBlood > 0 then
			self:reduceHitBlood(3, hitNormalType, monsterHP)
		else
			self:reduceHitBlood(3, hitNormalType, hitBlood)
		end
	end
	self:playDropBloodEffect(hitNormalType, hitBlood)
	-- 所有攻击结束
	if self.mCurrHitCount == self.mTotalHitCount then
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
			self:getSibling("GridController"):dropGridList(nil, nil, true)
		end
		self.mIsOnHit = false
		return
	end
	-- 怪物死亡
	self.mMonster:playDie(function()
		self:generateMonster(self.mMonsterIndex + 1)
		if not self.mIsOnClear then
			self:getSibling("GridController"):dropGridList(nil, nil, true)
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
		if self:getSibling("ThrowController"):throwToGrid(throwElementIds) then
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
			if self.mMonster:updateHP(monsterHP, true) then
				self:reduceHitBlood(4, nil, monsterHP)
			end
			self:playDropBloodEffect(self.mTouchedHitType, monsterHP)
		else
			if self.mMonster:updateHP(totalHitBlood, true) then
				self:reduceHitBlood(1, nil, nil)
			end
			self:playDropBloodEffect(self.mTouchedHitType, totalHitBlood)
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
	-- step1:计算受攻击信息
	local hitInfo = nil
	if nil == self.mMonster then
		hitInfo = self:calcHitInfo(touchParam.touched_type, touchParam.total_count_list, touchParam.normal_count_list, touchParam.skill_count_list, 0)
		self.mIsStartHurt = false
	else
		hitInfo = self:calcHitInfo(touchParam.touched_type, touchParam.total_count_list, touchParam.normal_count_list, touchParam.skill_count_list, self.mMonster:getDefenseNormalType())
		self.mIsStartHurt = true
	end
	-- step2:显示怪物血条
	self:showMonsterHP(touchParam.touched_type, hitInfo.total_hit_blood, hitInfo.count, hitInfo.multiple)
	-- step3:数据缓存
	self.mTouchedHitType = touchParam.touched_type
	self.mCurrHitCount = 0
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
	self:hideCombo()
	if touchParam.can_clear_flag then
		if self.mMonster then
			self:createComboLabel()
		end
	else
		if self.mMonster then
			self.mMonster:resetWillHP()
		end
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
		local praiseSprite = cc.Sprite:create(multipleInfo.praise_tip)	
		praiseSprite:setAnchorPoint(cc.p(0.5,0.5))
		praiseSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 450))
		praiseSprite:setOpacity(0)
		self:getMaster():getTopLayer():addChild(praiseSprite, G.TOP_ZORDER_TIP)
		Actions:moveScaleAction01(praiseSprite, cc.p(G.VISIBLE_SIZE.width/2, 350))
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
		if not self.mIsOnHit then
			self:getSibling("GridController"):dropGridList(nil, nil, true)
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

