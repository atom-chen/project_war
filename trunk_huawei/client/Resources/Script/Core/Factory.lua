----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 工厂
----------------------------------------------------------------------
Factory = {}

-- 创建元素
function Factory:createElement(elementId)
	assert("number" == type(elementId) and elementId > 0, "element id "..elementId.." is not number or not > 0")
	local data = LogicTable:get("element_tplt", elementId, true)
	local element = nil
	if ElementType["obstacle"] == data.type then			-- 障碍物
		element = Element.new()
		element:setSprite(cc.Sprite:create(data.normal_image))
		if 1001 == data.id or 1003 == data.id then	-- 草地
			element:getSprite():setPosition(cc.p(0, 13))
		end
	elseif ElementType["normal"] == data.type then			-- 普通元素
		element = ElementNormal.new(data.normal_image)
	elseif ElementType["skill"] == data.type then			-- 技能元素
		if ElementSkillType["discolor"] == data.sub_type then			-- 变色技能球
			element = ElementSkillDiscolor.new(data.normal_image)
		elseif ElementSkillType["horizontal"] == data.sub_type then		-- 横消技能球
			element = ElementSkillHorizontal.new(data.normal_image)
		elseif ElementSkillType["vertical"] == data.sub_type then		-- 竖消技能球
			element = ElementSkillVertical.new(data.normal_image)
		elseif ElementSkillType["cross"] == data.sub_type then			-- 十字消技能球
			element = ElementSkillCross.new(data.normal_image)
		elseif ElementSkillType["samecolor"] == data.sub_type then		-- 同色消技能球
			element = ElementSkillSamecolor.new(data.normal_image)
		elseif ElementSkillType["step"] == data.sub_type then			-- 步数技能球
			element = ElementSkillStep.new(data.normal_image)
		elseif ElementSkillType["connect"] == data.sub_type then		-- 连接器技能球
			element = ElementSkillConnect.new(data.normal_image)
		end
	elseif ElementType["throw"] == data.type then			-- 投放元素
		element = ElementThrow.new(data.normal_image)
	elseif ElementType["special"] == data.type then			-- 特殊元素
		if ElementSpecialType["diamond"] == data.sub_type then			-- 砖石
			element = ElementSpecialDiamond.new(data.normal_image)
		elseif ElementSpecialType["bomb"] == data.sub_type then			-- 炸弹
			element = ElementSpecialBomb.new(data.normal_image)
		elseif ElementSpecialType["key"] == data.sub_type then			-- 钥匙
			element = ElementSpecialKey.new(data.normal_image)
		elseif ElementSpecialType["crate"] == data.sub_type then		-- 木箱
			element = ElementSpecialCrate.new(data.normal_image)
		end
	elseif ElementType["board"] == data.type then			-- 隔板元素
		element = ElementBoard.new(data.normal_image)
	else
		assert(nil, "data type is error, element id: "..elementId)
	end
	if nil == element then
		assert(nil, "element is nil, element id: "..elementId)
	end
	-- 设置元素属性
	element:setData(data)
	element:setType(data.type)
	element:setSubType(data.sub_type)
	element:setExtraType(data.extra_type)
	element:setCanTouch(data.is_can_touch)
	element:setCanConnect(data.is_can_connect)
	element:setCanDrop(data.is_can_drop)
	element:setCanClear(data.is_can_clear)
	element:setCanReset(data.is_can_reset)
	element:setCanChange(data.is_can_change_sub_type)
	element:onInit()
	return element
end

-- 根据普通元素类型获取普通元素id
function Factory:getNormalId(normalType)
	local normalElementIds = {2001, 2002, 2003, 2004, 2005}
	return normalElementIds[normalType]
end

-- 创建普通元素
function Factory:createNormalElement(normalType)
	return self:createElement(self:getNormalId(normalType))
end

-- 创建技能元素
function Factory:createSkillElement(skillId)
	local data = LogicTable:get("skill_tplt", skillId, true)
	local skillElement = self:createElement(data.element_id)
	if nil == skillElement then
		return nil
	end
	skillElement:setSkillId(skillId)
	skillElement:setEffectRange(data.level)
	return skillElement
end

-- 创建防御精灵
function Factory:createDefenseSprite(normalType)
	local defenseImages = {
		"defense_red.png",
		"defense_yellow.png",
		"defense_green.png",
		"defense_blue.png",
		"defense_purple.png"
	}
	return cc.Sprite:create(defenseImages[normalType])
end

-- 获取横消技能对应的竖消技能
function Factory:getVerticalSkillId(horizontalSkillId)
	return horizontalSkillId + 100
end

-- 获取竖消技能对应的横消技能
function Factory:getHorizontalSkillId(verticalSkillId)
	return verticalSkillId - 100
end

-- 创建英雄
function Factory:createHero(heroId, parent)
	local hero = Hero.new(heroId)
	local heroNode = hero:getNode()
	local skillSprite = hero:getSkillSprite()
	local currProgress = hero:getCurrProgress()
	local goalProgress = hero:getGoalProgress()
	local normalType = hero:getNormalType()
	local normalSprite = hero:getNormalSprite()
	-- 计算坐标
	local xHeroPos, yHeroPos = G.VISIBLE_SIZE.width/2, 550
	local xSkillPos, ySkillPos = G.VISIBLE_SIZE.width/2, 520
	local xNormalPos, yNormalPos = G.VISIBLE_SIZE.width/2, 600
	if ElementNormalType["red"] == normalType then
		xHeroPos = xHeroPos - 187
		xSkillPos = xSkillPos - 187
		xNormalPos = xNormalPos - 187
	elseif ElementNormalType["yellow"] == normalType then
		xHeroPos = xHeroPos - 90
		xSkillPos = xSkillPos - 90
		xNormalPos = xNormalPos - 90
	elseif ElementNormalType["green"] == normalType then
	elseif ElementNormalType["blue"] == normalType then
		xHeroPos = xHeroPos + 98
		xSkillPos = xSkillPos + 98
		xNormalPos = xNormalPos + 98
	elseif ElementNormalType["purple"] == normalType then
		xHeroPos = xHeroPos + 198
		xSkillPos = xSkillPos + 198
		xNormalPos = xNormalPos + 198
	end
	-- 设置英雄坐标
	heroNode:setAnchorPoint(cc.p(0.5, 0))
	heroNode:setScale(0.6)
	heroNode:setPosition(cc.p(xHeroPos, yHeroPos))
	parent:addChild(heroNode, G.TOP_ZORDER_HERO + normalType - 1)
	-- 设置技能元素坐标
	skillSprite:setScale(0.6)
	skillSprite:setPosition(cc.p(xSkillPos, ySkillPos))
	parent:addChild(skillSprite, G.TOP_ZORDER_SKILL)
	-- 当前进度
	currProgress:setScale(0.57)
	currProgress:setPosition(cc.p(xSkillPos, ySkillPos+2))
	parent:addChild(currProgress, G.TOP_ZORDER_SKILL)
	-- 目标进度
	goalProgress:setScale(0.57)
	goalProgress:setPosition(cc.p(xSkillPos, ySkillPos+2))
	parent:addChild(goalProgress, G.TOP_ZORDER_SKILL)
	-- 设置普通元素坐标
	normalSprite:setScale(0.7)
	normalSprite:setPosition(cc.p(xNormalPos, yNormalPos))
	parent:addChild(normalSprite, G.TOP_ZORDER_NORMAL)
	local touchW, touchH = 60, 80
	return hero, cc.rect(xHeroPos - touchW/2, yHeroPos, touchW, touchH)
end

-- 创建怪物
function Factory:createMonster(monsterId, pos, parent)
	local monster = Monster.new(monsterId)
	local monsterNode = monster:getNode()
	local bloodBgSprite = monster:getBloodBgSprite()
	local currBloodProgress = monster:getCurrBloodProgress()
	local goalBloodProgress = monster:getGoalBloodProgress()
	local haveBloodLabelBMFont = monster:getHaveBloodLabelBMFont()
	local willBloodLabelBMFont = monster:getWillBloodLabelBMFont()
	local defenseBgSprite = monster:getDefenseBgSprite()
	local defenseSprite = monster:getDefenseSprite()
	-- 设置怪物坐标
	monsterNode:setAnchorPoint(cc.p(0.5, 0))
	monsterNode:setScale(0.7)
	monsterNode:setPosition(cc.p(pos.x, pos.y - 80))
	if "monster_05" == monster:getDisplay() then	-- 灯笼鱼
		monsterNode:setRotationSkewY(180)
	end
	local x, y = monsterNode:getPosition()
	parent:addChild(monsterNode, G.SCENE_ZORDER_MONSTER)
	-- 设置怪物信息展示坐标
	local yOffset = 0
	if monster:getDefenseNormalType() > 0 then	-- 可防御
		yOffset = 50
	end
	bloodBgSprite:setPosition(cc.p(pos.x, pos.y + yOffset + 130))
	parent:addChild(bloodBgSprite, G.SCENE_ZORDER_MONSTER)
	currBloodProgress:setPosition(cc.p(pos.x, pos.y + yOffset + 130))
	parent:addChild(currBloodProgress, G.SCENE_ZORDER_MONSTER)
	goalBloodProgress:setPosition(cc.p(pos.x, pos.y + yOffset + 130))
	parent:addChild(goalBloodProgress, G.SCENE_ZORDER_MONSTER)
	willBloodLabelBMFont:setAnchorPoint(cc.p(0.5, 0))
	willBloodLabelBMFont:setPosition(cc.p(pos.x, pos.y + yOffset + 140))
	parent:addChild(willBloodLabelBMFont, G.SCENE_ZORDER_MONSTER)
	haveBloodLabelBMFont:setAnchorPoint(cc.p(0.5, 0))
	haveBloodLabelBMFont:setPosition(cc.p(pos.x, pos.y + yOffset + 140))
	parent:addChild(haveBloodLabelBMFont, G.SCENE_ZORDER_MONSTER)
	if defenseBgSprite then
		defenseBgSprite:setScale(0.7)
		defenseBgSprite:setPosition(cc.p(pos.x, pos.y + yOffset + 101))
		parent:addChild(defenseBgSprite, G.SCENE_ZORDER_MONSTER)
	end
	if defenseSprite then
		defenseSprite:setPosition(cc.p(pos.x, pos.y + yOffset + 98))
		parent:addChild(defenseSprite, G.SCENE_ZORDER_MONSTER)
	end
	return monster
end


