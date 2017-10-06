----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 英雄控制器
----------------------------------------------------------------------
HeroController = class("HeroController", Component)

-- 构造函数
function HeroController:ctor()
	self.super:ctor(self.__cname)
	self.mHeroTable = {}					-- 英雄表
	self.mHeroTouchAreaTable = {}			-- 英雄触摸区域列表
	self.mHeroInfoPanel = nil				-- 英雄信息面板
	self.mHeroSkillTable = {}				-- 英雄技能表
	self.mBeginTouchType = 0				-- 开始触摸的普通元素类型
	self.mElementCountList = {}				-- 元素数量列表
	self.mElementList = {}					-- 元素列表
	-- 注册事件
	self:subscribeEvent(EventDef["ED_TOUCH_GRID_BEGIN"], self.handleTouchGridBegin)
	self:subscribeEvent(EventDef["ED_TOUCH_GRID_MOVE"], self.handleTouchGridMove)
	self:subscribeEvent(EventDef["ED_TOUCH_GRID_END"], self.handleTouchGridEnd)
	self:subscribeEvent(EventDef["ED_CLEAR_GRID"], self.handleClearGrid)
	self:subscribeEvent(EventDef["ED_DROP_END"], self.handleDropEnd)
end

-- 添加英雄
function HeroController:addHero(heroId)
	local hero, heroTouchArea = Factory:createHero(heroId, self:getMaster():getTopLayer())
	local normalType = hero:getNormalType()
	if nil == self.mHeroTable[normalType] then
		self.mHeroTable[normalType] = hero
		self.mHeroTouchAreaTable[normalType] = heroTouchArea
	else
		hero:destroy()
		assert(nil, "exist normal type: "..normalType.." which hero id: "..self.mHeroTable[normalType]:getData().id..", error hero id: "..heroId)
	end
end

-- 获取英雄
function HeroController:getHero(normalType)
	return self.mHeroTable[normalType]
end

-- 英雄杀死怪欢呼
function HeroController:winCheer()
	for normalType, hero in pairs(self.mHeroTable) do
		hero:playWin()
	end
end

-- 查找技能投放索引位置
function HeroController:searchThrowCoord(skillElement)
	if nil == skillElement then
		return nil
	end
	local rowCount, colCount = self:getMaster():getRowCol()
	for row=2, rowCount do
		local highPriorityCoords, lowerPriorityCoords = {}, {}
		for col=1, colCount do
			local _, grid = self:getSibling("GridController"):getGrid(row, col)
			if grid and nil == grid:getFixedElement() and nil == grid:getCoverElement() and ElementType["normal"] == grid:getShowElement():getType() then
				if skillElement:getExtraType() == grid:getShowElement():getType() then
					table.insert(highPriorityCoords, grid:getCoord())
				else
					table.insert(lowerPriorityCoords, grid:getCoord())
				end
			end
		end
		if #highPriorityCoords > 0 then
			return CommonFunc:getRandom(highPriorityCoords)
		elseif #lowerPriorityCoords > 0 then
			return CommonFunc:getRandom(lowerPriorityCoords)
		end
	end
	return nil
end

-- 设置技能
function HeroController:setSkillGrid(skillElement, setCF)
	local coord = self:searchThrowCoord(skillElement)
	local xPos, yPos = skillElement:getSprite():getPosition()
	local pos = self:getMaster():getGridPos(coord.row, coord.col)
	local cfg = {
		cc.p(xPos, yPos),
		cc.p(xPos + (pos.x - xPos)*2/3, yPos + 50),
		cc.p(pos.x, pos.y),
	}
	Actions:bezierTo(skillElement:getSprite(), cfg, 0.25, function()
		skillElement:destroy()
		local _, grid = self:getSibling("GridController"):getGrid(coord.row, coord.col)
		grid:destroyElements()
		grid:setElement(Factory:createSkillElement(skillElement:getSkillId()))
		self:getSibling("GridController"):setGrid(coord.row, coord.col, {skillElement:getData().id}, grid)
		Utils:doCallback(setCF)
	end)
end

-- 生成技能
function HeroController:generateSkill(generateCF)
	local heroList = {}
	for i, hero in pairs(self.mHeroTable) do
		if hero:isCanGenerateSkill() then
			table.insert(heroList, hero)
		end
	end
	local heroCount = #heroList
	if 0 == heroCount then
		Utils:doCallback(generateCF)
		return
	end
	local effectIdList = {2302, 2303, 2304, 2305, 2306}
	for i, hero in pairs(heroList) do
		local skillElement = Factory:createSkillElement(hero:getSkillId())
		local xPos, yPos = hero:getSkillSprite():getPosition()
		skillElement:getSprite():setPosition(cc.p(xPos, yPos))
		self:getMaster():getTopLayer():addChild(skillElement:getSprite(), G.TOP_ZORDER_SKILL)
		self:setSkillGrid(skillElement, function()
			heroCount = heroCount - 1
			if 0 == heroCount then
				Utils:doCallback(generateCF)
			end
		end)
		AudioMgr:playEffect(effectIdList[hero:getNormalType()])
	end
end

-- 显示技能精灵
function HeroController:showSkillSprites(normalCountList)
	self:hideSkillSprites()
	for normalType, count in pairs(normalCountList) do
		if self.mHeroTable[normalType] and count > 0 then
			self.mHeroTable[normalType]:showSkillRound()
			self.mHeroTable[normalType]:showSkillAppendRound(count)
		end
	end
end

-- 隐藏技能精灵
function HeroController:hideSkillSprites()
	for i, hero in pairs(self.mHeroTable) do
		hero:hideSkillSprite()
	end
end

-- 处理触摸格子开始事件
function HeroController:handleTouchGridBegin(touchParam)
	if self.mHeroTable[touchParam.touched_type] then
		self.mHeroTable[touchParam.touched_type]:playPreAttack()
	end
	self:handleTouchGridMove(touchParam)
end

-- 处理触摸格子移动事件
function HeroController:handleTouchGridMove(touchParam)
	self.mElementList = {}
	self.mElementCountList = touchParam.total_count_list
	self:showSkillSprites(self.mElementCountList)
end

-- 处理触摸格子结束事件
function HeroController:handleTouchGridEnd(touchParam)
	if not touchParam.can_clear_flag then
		if self.mHeroTable[touchParam.touched_type] then
			self.mHeroTable[touchParam.touched_type]:playIdle()
		end
		self:hideSkillSprites()
	end
end

-- 处理消除格子事件
function HeroController:handleClearGrid(elementDataList)
	local function handleElementData(elementData)
		local normalType = nil
		if ElementType["normal"] == elementData.type then
			normalType = elementData.sub_type
		elseif ElementType["skill"] == elementData.type then
			normalType = elementData.extra_type
		end
		if nil == normalType then
			return
		end
		for i, hero in pairs(self.mHeroTable) do
			if normalType == hero:getNormalType() then
				hero:updateSkillRound()
				hero:showSkillRound()
			end
		end
	end
	for i, elementData in pairs(elementDataList) do
		handleElementData(elementData)
	end
end

-- 处理掉落结束事件
function HeroController:handleDropEnd(param)
	if not param.flag then
		self:getSibling("GridController"):arrangeGridList()
		return
	end
	self:hideSkillSprites()
	self:generateSkill(function()
		self:getSibling("MonsterController"):monsterAttack(param.is_drop)
	end)
end

-- 创建英雄信息面板
function HeroController:createHeroInfoPanel()
	-- 信息面板
	local infoPanel = cc.Sprite:create("hero_info_panel.png")
	infoPanel:setAnchorPoint(cc.p(0.5, 0))
	infoPanel:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 0))
	infoPanel:setVisible(false)
	self:getMaster():getTopLayer():addChild(infoPanel, G.TOP_ZORDER_HERO_INFO)
	self.mHeroInfoPanel = infoPanel
	local panelWidth = infoPanel:getBoundingBox().width
	local topHeight = infoPanel:getBoundingBox().height
	-- 普通元素
	for i=1, 5 do
		local xPos = panelWidth/2 + (i-3)*95
		local basicAttack = G.NORMAL_BASE_ATTACK
		local heroName = ""
		local hero = self.mHeroTable[i]
		if hero then
			heroName = hero:getData().name
			basicAttack = hero:getData().attack
			-- 英雄技能
			local skillElement = Factory:createSkillElement(hero:getSkillId())
			local glProgramState = Utils:createShader(skillElement:getSprite(), "common.vsh", "show_per.fsh")
			glProgramState:setUniformFloatEx("fHave", hero:getSkillCurrRound()/hero:getSkillTriggerRound())
			glProgramState:setUniformFloatEx("fWill", hero:getSkillCurrRound()/hero:getSkillTriggerRound())
			skillElement:getSprite():setGLProgramState(glProgramState)
			skillElement:getSprite():setPosition(cc.p(xPos, topHeight - 40))
			skillElement:getSprite():setScale(0.8)
			infoPanel:addChild(skillElement:getSprite())
			self.mHeroSkillTable[i] = skillElement
			-- 英雄勋章
			local heroLevel = hero:getData().level
			local _, medalImage = DataHeroInfo:getMedalLevel({level=heroLevel})
			local medalSprite = cc.Sprite:create(medalImage)
			medalSprite:setPosition(cc.p(xPos, topHeight - 85))
			infoPanel:addChild(medalSprite)
			-- 英雄等级
			local levelLabelBMFont = cc.Label:createWithBMFont("font_01.fnt", tostring(heroLevel))
			levelLabelBMFont:setPosition(cc.p(xPos + 13, topHeight - 100))
			levelLabelBMFont:setScale(0.8)
			infoPanel:addChild(levelLabelBMFont)
		end
		-- 名字
		local nameLabel = cc.Label:createWithSystemFont(heroName, "", 32)
		nameLabel:setPosition(cc.p(xPos, topHeight - 135))
		nameLabel:setScale(0.7)
		infoPanel:addChild(nameLabel)
		-- 普通元素
		local normalElement = Factory:createElement(Factory:getNormalId(i))
		normalElement:getSprite():setPosition(cc.p(xPos, topHeight - 175))
		normalElement:getSprite():setScale(0.8)
		infoPanel:addChild(normalElement:getSprite())
		-- 攻击力
		local attackLabelBMFont = cc.Label:createWithBMFont("font_01.fnt", tostring(basicAttack))
		attackLabelBMFont:setPosition(cc.p(xPos, topHeight - 175))
		attackLabelBMFont:setScale(0.8)
		infoPanel:addChild(attackLabelBMFont)
	end
end

-- 显示英雄信息面板
function HeroController:showHeroInfoPanel()
	if not GuideMgr:isShowDetail() then
		return
	end
	for normalType, hero in pairs(self.mHeroTable) do
		local skillElement = self.mHeroSkillTable[normalType]
		skillElement:getSprite():getGLProgramState():setUniformFloatEx("fHave", hero:getSkillCurrRound()/hero:getSkillTriggerRound())
		skillElement:getSprite():getGLProgramState():setUniformFloatEx("fWill", hero:getSkillCurrRound()/hero:getSkillTriggerRound())
	end
	self:setTouchSwallow(true)
	self.mHeroInfoPanel:setVisible(true)
	local monster = self:getSibling("MonsterController"):getMonster()
	if monster then
		monster:showHaveHp()
	end
end

-- 隐藏英雄信息面板
function HeroController:hideHeroInfoPanel()
	self.mHeroInfoPanel:setVisible(false)
	self:setTouchSwallow(false)
	local monster = self:getSibling("MonsterController"):getMonster()
	if monster then
		monster:hideHaveHp()
	end
end

-- 触摸开始
function HeroController:onTouchBegan(touch, event, gridInfo)
	local location = touch:getLocation()
	for normalType, touchArea in pairs(self.mHeroTouchAreaTable) do
		if cc.rectContainsPoint(touchArea, cc.p(location.x, location.y)) then
			self.mBeginTouchType = normalType
			break
		end
	end
end

-- 触摸结束
function HeroController:onTouchEnded(touch, event, gridInfo)
	local endTouchType = 0
	local location = touch:getLocation()
	for normalType, touchArea in pairs(self.mHeroTouchAreaTable) do
		if cc.rectContainsPoint(touchArea, cc.p(location.x, location.y)) then
			endTouchType = normalType
			break
		end
	end
	if self.mHeroInfoPanel:isVisible() then
		if endTouchType > 0 or cc.rectContainsPoint(self.mHeroInfoPanel:getBoundingBox(), cc.p(location.x, location.y)) then
			self:hideHeroInfoPanel()
		end
	else
		if self.mBeginTouchType > 0 and self.mBeginTouchType == endTouchType then
			self:showHeroInfoPanel()
		end
	end
	self.mBeginTouchType = 0
end

-- 飞向英雄
function HeroController:flyToHero(elementType, normalType, id, coord, index, flyCF)
	local hero = self.mHeroTable[normalType]
	if nil == hero then		-- 没有英雄
		return false
	end
	-- 临时元素
	local targetX, targetY = hero:getNormalSprite():getPosition()
	local currPos = self:getMaster():getGridPos(coord.row, coord.col)
	local tempElement = nil
	if ElementType["normal"] == elementType then
		tempElement = Factory:createElement(id)
	elseif ElementType["skill"] == elementType then
		tempElement = Factory:createSkillElement(id)
	else
		return false
	end
	if normalType == self:getSibling("GridController"):getTouchedType() then
		tempElement:onFocusEnter()
	else
		tempElement:getSprite():setOpacity(130)
	end
	tempElement:getSprite():setPosition(cc.p(currPos.x, currPos.y))
	self:getMaster():getTopLayer():addChild(tempElement:getSprite(), G.TOP_ZORDER_NORMAL)
	-- 动作
	Actions:delayWith(tempElement:getSprite(), (index - 1)*0.12 + 0.1, function()
		Animations:elementExplode01(coord, tempElement:getData().sound)
		tempElement:onFocusEnter()
		tempElement:getSprite():setOpacity(255)
		local moveDuration = cc.pGetDistance(cc.p(currPos.x, currPos.y), cc.p(targetX, targetY))/1700
		Actions:delayWith(tempElement:getSprite(), 0.1, function()
			local bezierCfg = {
				cc.p(currPos.x, currPos.y),
				cc.p(currPos.x + CommonFunc:getRandom({-66, -33, 0, 33, 66}), currPos.y + (targetY - currPos.y)/3),
				cc.p(targetX, targetY),
			}
			Actions:bezierTo(tempElement:getSprite(), bezierCfg, moveDuration, function()
				Utils:doCallback(flyCF)
				if nil == self.mElementList[normalType] then
					self.mElementList[normalType] = {}
				end
				tempElement:getSprite():setVisible(false)
				table.insert(self.mElementList[normalType], tempElement)
				if #self.mElementList[normalType] == self.mElementCountList[normalType] then
					self:heroAttack(self.mElementList[normalType], hero)
				end
			end)
		end)
	end)
	return true
end

-- 英雄攻击
function HeroController:heroAttack(elementList, hero)
	local monster = self:getSibling("MonsterController"):getMonster()
	if nil == monster then	-- 没有怪物
		for i, element in pairs(elementList) do
			element:destroy()
		end
		hero:playIdle()
		return
	end
	-- 播放攻击动作
	hero:playAttack()
	-- 攻击怪物
	local xPos, yPos = monster:getNode():getPosition()
	local sPosX, sPosY = hero:getNormalSprite():getPosition()
	local ePos = cc.p(xPos, yPos + 60)
	local remainCount = #elementList
	local xOffset = CommonFunc:getRandom({-66, -33, 0, 33, 66})
	for i, element in pairs(elementList) do
		element:onFocusEnter()
		element:getSprite():setScale(0.8)
		element:getSprite():setPosition(cc.p(sPosX, sPosY))
		element:getSprite():setVisible(true)
		-- 攻击
		local moveDuration = cc.pGetDistance(cc.p(sPosX, sPosY), ePos)/700
		Actions:delayWith(element:getSprite(), 0.5 + (i - 1)*0.05, function()
			local bezierCfg = {
				cc.p(sPosX, sPosY),
				cc.p(sPosX + xOffset, sPosY + (ePos.y - sPosY)/3),
				cc.p(ePos.x, ePos.y),
			}
			Actions:bezierTo(element:getSprite(), bezierCfg, moveDuration, function()
				remainCount = remainCount - 1
				self:getSibling("MonsterController"):onHurt(element, remainCount)
			end)
			if 1 == i then
				AudioMgr:playEffect(2301)
			end
		end)
	end
end

-- 元素攻击
function HeroController:elementAttack(elementType, normalType, id, coord, index, flyCF)
	local monster = self:getSibling("MonsterController"):getMonster()
	if nil == monster then		-- 没有怪物
		return false
	end
	local xPos, yPos = monster:getNode():getPosition()
	-- 临时元素
	local startPos = self:getMaster():getGridPos(coord.row, coord.col)
	local ePos = cc.p(xPos, yPos + 60)
	local tempElement = nil
	if ElementType["normal"] == elementType then
		tempElement = Factory:createElement(id)
	elseif ElementType["skill"] == elementType then
		tempElement = Factory:createSkillElement(id)
	else
		return false
	end
	if normalType == self:getSibling("GridController"):getTouchedType() then
		tempElement:onFocusEnter()
	else
		tempElement:getSprite():setOpacity(130)
	end
	tempElement:getSprite():setPosition(cc.p(startPos.x, startPos.y))
	self:getMaster():getTopLayer():addChild(tempElement:getSprite(), G.TOP_ZORDER_TIP)
	-- 攻击
	Actions:delayWith(tempElement:getSprite(), (index - 1)*0.1 + 0.1, function()
		Animations:elementExplode01(coord, tempElement:getData().sound)
		tempElement:onFocusEnter()
		tempElement:getSprite():setOpacity(255)
		local moveDuration = cc.pGetDistance(cc.p(startPos.x, startPos.y), ePos)/1500
		Actions:delayWith(tempElement:getSprite(), 0.1, function()
			local bezierCfg = {
				cc.p(startPos.x, startPos.y),
				cc.p(startPos.x + CommonFunc:getRandom({-66, -33, 0, 33, 66}), startPos.y + (ePos.y - startPos.y)/3),
				cc.p(ePos.x, ePos.y),
			}
			Actions:bezierTo(tempElement:getSprite(), bezierCfg, moveDuration, function()
				Utils:doCallback(flyCF)
				self:getSibling("MonsterController"):onHurt(tempElement, index)
			end)
		end)
	end)
	return true
end

