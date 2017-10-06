----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-11
-- Brief: 战斗目标界面
----------------------------------------------------------------------
UIGameGoal = {
	csbFile = "GameGoal.csb"
}

function UIGameGoal:onStart(ui, param)
	
	self.rootNode = ui.root
	local Text_goal_l = UIManager:seekNodeByName(ui.root, "Text_goal_l")
	Text_goal_l:setString(LanguageStr("GAME_GOAL"))
	local Text_move_l = UIManager:seekNodeByName(ui.root, "Text_move_l")
	Text_move_l:setString(LanguageStr("COPYINFO_GAME_MOVES")..LanguageStr("PUBLIC_COLON"))
	
	-- 根据当前打的副本,获得副本的信息
	local copyInfo = LogicTable:get("copy_tplt", DataMap:getPass(), false)
	self.mGoalLastCountList = {}
	-- 根节点
	self.mRootNode = ui.root
	-- 目标面板
	self.mGoalPanel = UIManager:seekNodeByName(ui.root, "Panel_goal")
	Utils:autoChangePos(self.mGoalPanel)
	-- 暂停面板
	self.mPausePanel = UIManager:seekNodeByName(ui.root, "Panel_pause")
	Utils:autoChangePos(self.mPausePanel)
	-- 中间目标面板背景
	self.mGoalCenterBg = UIManager:seekNodeByName(ui.root, "Panel_centerBg")
	Utils:autoChangePos(self.mGoalCenterBg)
	-- 中间目标面板
	self.mGoalCenterPanel = UIManager:seekNodeByName(ui.root, "Panel_Goals_center")
	Utils:autoChangePos(self.mGoalCenterPanel)
	Utils:addTouchEvent(self.mGoalCenterPanel, function(sender)
		self:closeCenterPanel()
	end, false, false, 0)
	--中间数字面板
	self.mGoalCenterAmountPanel = UIManager:seekNodeByName(ui.root, "Panel_amount")
	Utils:autoChangePos(self.mGoalCenterAmountPanel)
	Utils:addTouchEvent(self.mGoalCenterAmountPanel, function(sender)
		self:closeCenterPanel()
	end, false, false, 0)
	-- 剩余步数背景
	self.mLeftMovesBg = UIManager:seekNodeByName(ui.root, "Image_moveBg")
	self.mLeftMovesBg:setVisible(false)
	-- 剩余步数文本框
	self.mLeftMovesLabel = UIManager:seekNodeByName(ui.root, "Text_moves")
	self.mLeftMovesLabel:setString(copyInfo.moves)
	-- 暂停按钮
	self.mBtnPause = UIManager:seekNodeByName(ui.root, "Button_pause")
	Utils:addTouchEvent(self.mBtnPause, function(sender)
		self:closeCenterPanel()
		UIManager:openFront(UIPauseGame, true)	-- 打开主界面
	end, true, true, 0)
	-- 快速过关按钮
	local btnQuickPass = UIManager:seekNodeByName(ui.root, "Button_quickpass")
	Utils:autoChangePos(btnQuickPass)
	Utils:addTouchEvent(btnQuickPass, function(sender)
		self.mBtnPause:setTouchEnabled(false)
		btnQuickPass:setVisible(false)
		local elementDatas = {}
		local killNum = 0
		local goals = CopyModel:getGoals()
		for i, goal in pairs(goals) do
			if goal.id > 0 then		-- 收集目标
				local elementData = LogicTable:get("element_tplt", goal.id, true)
				for i=1, goal.count do
					table.insert(elementDatas, elementData)
				end
			else					-- 击杀目标
				killNum = killNum + goal.count
			end
		end
		self:updateCollectGoals(elementDatas)
		self:updateKillGoals(killNum)
		self:checkGameOver(true)
	end, true, true, 0)
	if G.CONFIG["debug"] then
		btnQuickPass:setVisible(true)
	else
		btnQuickPass:setVisible(false)
	end
	-- 初始操作
	self:loadTopPanel()
	self:loadCenterPanel()
	DataLevelInfo:showDiscountMoves()	-- 失败几次后会弹出打折步数界面
	-- 收到此事件时,步数减1
	self:subscribeEvent(EventDef["ED_CLEAR_BEGIN"], function()
		self:updateLeftMoves()
	end)
	-- 收到此事件时,需要判断游戏是否结束(条件1:当目标都完成时成功,条件2:当步数为0时失败)
	self:subscribeEvent(EventDef["ED_ROUND_OVER"], function(isRoundValid)
		if isRoundValid then
			self:checkGameOver(true)
		end
	end)
	-- 收到此事件时,游戏结束且失败(这是因为地图没有可连接的元素)
	self:subscribeEvent(EventDef["ED_GAME_OVER"], function()
		self:checkGameOver(false)
	end)
	-- 收到此事件时,需要更新收集目标,目标数减1,此事件会携带元素数据
	self:subscribeEvent(EventDef["ED_CLEAR_END"], function(elementDatas)
		self:updateCollectGoals(elementDatas)
	end)
	-- 收到此事件时,怪物数量减1
	self:subscribeEvent(EventDef["ED_KILL_MONSTER"], function()
		if self.mIsGameSuccess then
			return
		end
		self:updateKillGoals(1)
		
		if  nil ~= self.monstNode then
			local back = UIManager:seekNodeByName(self.mRootNode, "back_1")
			--self.monstNode:stopAllActions()
			self.monstNode:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.CallFunc:create(function()
				self.monstNode:removeFromParent()
				local display = MapManager:getMonsterDisplay()
				if nil ~= display then
					local back = UIManager:seekNodeByName(self.mRootNode, "back_1")
					local node = Utils:createArmatureNode(display)
					node:setScale(0.1)
					node:setAnchorPoint(cc.p(0.5,0.5))
					node:setPosition(cc.p(21,18.78))
					back:addChild(node)
					node:setOpacity(0)
					node:runAction(cc.FadeIn:create(0.5))
					self.monstNode = node
				else
					self.monstNode:removeFromParent()
					local monstImg = ccui.ImageView:create()	
					monstImg:loadTexture("small_monster.png")
					monstImg:setAnchorPoint(cc.p(0.5,0.5))
					monstImg:setPosition(cc.p(21,18.78))
					monstImg:setScale(0.5)
					back:addChild(monstImg)
				end	
			end)))	
		end
	end)
	self.mIsGameSuccess = false
	self.mIsFirstSuccess = false
	if not GuideMgr:isTipGoal() then
		self:closeCenterPanel()
	end
end

function UIGameGoal:onTouch(touch, event, eventCode)
	self:closeCenterPanel_touch()
end

function UIGameGoal:onUpdate(dt)
end

function UIGameGoal:onDestroy()
	self.monstNode = nil
	local back = UIManager:seekNodeByName(self.mRootNode, "back_1")
	back:removeAllChildren()
	
	self.mLeftMovesLabel = nil 
	self.mLeftMovesBg = nil
end

-- 更新收集目标
function UIGameGoal:updateCollectGoals(elementDatas)
	local collectGoals = CopyModel:updateColleteGoals(elementDatas)
	ItemModel:updateCollect(elementDatas)
	self:setTopGoalsAmount(collectGoals)
end

-- 更新击杀目标
function UIGameGoal:updateKillGoals(killNum)
	for i=1, killNum do
		local killGoals = CopyModel:updateKillGoals()
		self:setTopGoalsAmount(killGoals)
	end
end

-- 加载顶部目标的的图片和剩余个数
function UIGameGoal:loadTopPanel()
	local goals = CopyModel:getGoals()
	for i=1, 3 do
		local back = UIManager:seekNodeByName(self.mRootNode, "back_"..i)
		local icon = UIManager:seekNodeByName(self.mRootNode, "Image_"..i)
		local amount = UIManager:seekNodeByName(self.mRootNode, "number_"..i)
		local full = UIManager:seekNodeByName(self.mRootNode, "full_"..i)
		icon:setVisible(false)
		amount:setVisible(false)
		full:setVisible(false)
		back:setVisible(false)
		if #goals >= i then
			local iconStr = DataLevelInfo:getIconStrById(goals[i].id)
			icon:loadTexture(iconStr)
			amount:setString(goals[i].count)
			self.mGoalLastCountList[i] = goals[i].count
		end
	end
end

-- 加载中间目标的的图片和剩余个数
function UIGameGoal:loadCenterPanel()
	local goals = CopyModel:getGoals()
	for i=1, 3 do
		local back = UIManager:seekNodeByName(self.mRootNode, "back_"..i)
		local icon = UIManager:seekNodeByName(self.mRootNode, "Icon_"..i)
		local iconBg = UIManager:seekNodeByName(self.mRootNode, "ImageBg_"..i)
		local amount = UIManager:seekNodeByName(self.mRootNode, "amount_"..i)
		local des_text = UIManager:seekNodeByName(self.mRootNode, "des_"..i)
		icon:setVisible(false)
		amount:setVisible(false)
		iconBg:setVisible(false)
		back:setVisible(false)
		des_text:setVisible(false)
		if #goals >= i then
			local iconStr = DataLevelInfo:getIconStrById(goals[i].id)
			icon:loadTexture(iconStr)
			amount:setString(goals[i].count)
			icon:setVisible(true)
			amount:setVisible(true)
			iconBg:setVisible(true)
			back:setVisible(true)
			des_text:setVisible(true)
			if goals[i].id == 0 then
				des_text:setString(LanguageStr("GOAL_TEXT_KILL"))
			else
				des_text:setString(LanguageStr("GOAL_TEXT_COLLECT"))
			end
		end
	end
	-- 从上往下掉的动画
	local function dropAction(widget)
		widget:setOpacity(0)
		local distance, droptime = 250, 0.3
		local posX, posY = widget:getPosition()
		local actionArray ={}
		table.insert(actionArray, cc.Place:create(cc.p(posX, posY + distance)))
		table.insert(actionArray, cc.Spawn:create(cc.FadeIn:create(1.0), cc.MoveBy:create(droptime, cc.p(0, -distance))))
		widget:runAction(cc.Sequence:create(actionArray))
	end
	dropAction(self.mGoalCenterBg)
	dropAction(self.mGoalCenterPanel)
	dropAction(self.mGoalCenterAmountPanel)
	self.mGoalCenterBg:runAction(cc.Sequence:create(cc.DelayTime:create(1.5), cc.CallFunc:create(function()
		self:nodeFlyToTarget()
	end)))
end

-- 直接跳过中间的动画
function UIGameGoal:closeCenterPanel()
	if not self.mGoalCenterBg:isVisible() then
		return
	end
	local goals = CopyModel:getGoals()
	self.mGoalCenterBg:setVisible(false)
	self.mGoalCenterPanel:setVisible(false)
	self.mGoalCenterAmountPanel:setVisible(false)
	for i=1,3,1 do
		local back = UIManager:seekNodeByName(self.mRootNode, "back_"..i)
		local icon = UIManager:seekNodeByName(self.mRootNode, "Image_"..i)
		local amount = UIManager:seekNodeByName(self.mRootNode, "number_"..i)
		local icon_center = UIManager:seekNodeByName(self.mRootNode, "Icon_"..i)
		icon_center:stopAllActions()
		if #goals >= i then
			icon:setVisible(true)
			back:setVisible(true)
			amount:setVisible(true)
			
			if goals[i].id == 0 then	--加载当前怪物的节点
				icon:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.CallFunc:create(function()
					if nil ~= self.monstNode then
						self.monstNode:removeFromParent()
					end
					local display = MapManager:getMonsterDisplay()
					local node = Utils:createArmatureNode(display)
					node:setScale(0.1)
					node:setAnchorPoint(cc.p(0.5,0.5))
					node:setPosition(cc.p(21,18.78))
					back:addChild(node)
					node:runAction(cc.FadeIn:create(0.5))
					self.monstNode = node
				end)))
			end
			
		end
	end
end

-- 直接跳过中间的动画
function UIGameGoal:closeCenterPanel_touch()
	if not self.mGoalCenterBg:isVisible() then
		return
	end
	local goals = CopyModel:getGoals()
	self.mGoalCenterBg:setVisible(false)
	self.mGoalCenterPanel:setVisible(false)
	self.mGoalCenterAmountPanel:setVisible(false)
	for i=1,3,1 do
		local back = UIManager:seekNodeByName(self.mRootNode, "back_"..i)
		local icon = UIManager:seekNodeByName(self.mRootNode, "Image_"..i)
		local amount = UIManager:seekNodeByName(self.mRootNode, "number_"..i)
		local icon_center = UIManager:seekNodeByName(self.mRootNode, "Icon_"..i)
		--icon_center:stopAllActions()
		if #goals >= i then
			icon:setVisible(true)
			back:setVisible(true)
			amount:setVisible(true)	
		end
	end
end

-- 缩放动作04
function UIGameGoal:scaleAction04(node, internal)
	if nil == node then return end
	local action = cc.Sequence:create(cc.ScaleTo:create(internal/5, 1.5, 1.5), cc.ScaleTo:create(internal/5, 1.0, 1.0))
	node:stopAllActions()
	node:runAction(cc.RepeatForever:create(action))
end

-- 更新剩余步数
function UIGameGoal:updateLeftMoves()
	local leftMoves = CopyModel:getCurrMoves() - 1
	
	--只要连了一步，体力就要扣除
	local copyInfo = DataLevelInfo:getCopyInfo()
	if leftMoves == copyInfo.moves - 1 then
		DataLevelInfo:isSameLevel()
		DataMap:setLastPass(DataMap:getPass())
	end
	
	CopyModel:setCurrMoves(leftMoves)
	-- 界面表现
	if nil == self.mLeftMovesLabel or nil == self.mLeftMovesBg then
		UIPrompt:show(LanguageStr("GOAL_TIP_1"))
		return
	end
	self.mLeftMovesLabel:setString(leftMoves)
	if leftMoves > 5 then	
		self.mLeftMovesLabel:setColor(cc.c3b(255,255,255))
	elseif leftMoves == 5 and self.mIsFirstSuccess == false then
		self:scaleAction04(self.mLeftMovesLabel, 2)
		self.mLeftMovesLabel:setColor(cc.c3b(252,255,0))
		-- 剩余五步特效
		local fivestepEffect = nil
		fivestepEffect = Utils:createArmatureNode("fivestep", "idle", false, function(armatureBack, movementType, movementId)
			if ccs.MovementEventType.complete == movementType and "idle" == movementId then
				fivestepEffect:removeFromParent()
			end
		end)
		fivestepEffect:setScale(0.7)
		fivestepEffect:setAnchorPoint(cc.p(0,0))
		Utils:autoChangePos(fivestepEffect)
		fivestepEffect:setPosition(cc.p(-325,20))
		self.rootNode:addChild(fivestepEffect, 101)	
	elseif leftMoves > 3 and leftMoves < 5 then
		self:scaleAction04(self.mLeftMovesLabel, 2)
		self.mLeftMovesLabel:setColor(cc.c3b(252,255,0))
	elseif leftMoves > 0 and leftMoves <= 3 then
		self:scaleAction04(self.mLeftMovesLabel, 2)
		self.mLeftMovesLabel:setColor(cc.c3b(252,0,3))
	elseif 0 == leftMoves then
		self.mLeftMovesLabel:stopAllActions()
	end
end

-- 检查游戏是否结束
function UIGameGoal:checkGameOver(isCanConnect)
	local completeFlag = CopyModel:isGoalsComplete()
	local currMoves = CopyModel:getCurrMoves()
	if completeFlag and currMoves >= 0 then		-- 目标完成
		self.mIsGameSuccess = true
		self.mBtnPause:setTouchEnabled(false)
		MapManager:setTouch(false)
		EventDispatcher:post(EventDef["ED_GAME_SUCCESS"])
		self.mIsFirstSuccess = DataLevelInfo:isFirstSuccess()
		DataMap:setMaxPass(DataMap:getPass())	-- 设置最大通关数
		if GoalType["collect"] == CopyModel:getLatestGoalType() then
			MapManager:getComponent("HeroController"):winCheer()
		end
		-- 灰色背景
		local graySprite = cc.Sprite:create("gray_01.png")
		local size = graySprite:getContentSize()
		graySprite:setScaleX(G.VISIBLE_SIZE.width/size.width)
		graySprite:setScaleY(G.VISIBLE_SIZE.height/size.height)
		graySprite:setOpacity(0)
		self.node:addChild(graySprite, 100)
		
		ChannelProxy:recordValue(self:getRecordValue("stat_copy_success"))
		if self.mIsFirstSuccess and currMoves > 0 and DataMap:getPass() > 6 then	-- 有剩余步数奖励
			-- 渐现
			Actions:fadeIn(graySprite, 0.25, function()
				-- 成功特效
				local successEffect = nil
				successEffect = Utils:createArmatureNode("success", "idle", false, function(armatureBack, movementType, movementId)
					if ccs.MovementEventType.complete == movementType and "idle" == movementId then
						successEffect:removeFromParent()
						-- 渐隐
						Actions:fadeOut(graySprite, 0.3, function()
							graySprite:removeFromParent()
							MapManager:remainRoundAward(currMoves, function(elementDatas)
								self:updateCollectGoals(elementDatas)
								for i=1, #elementDatas do
									self:updateLeftMoves()
								end
								currMoves = CopyModel:getCurrMoves()
								if 0 == currMoves then
									UIMiddlePub:openUISuccess()
								end
							end)
						end)
					end
				end)
				successEffect:setAnchorPoint(cc.p(0.5, 0.5))
				self.node:addChild(successEffect, 101)
			end)
		else		-- 无剩余步数奖励
			UIMiddlePub:openUISuccess()
		end
		AudioMgr:stopMusic()
		AudioMgr:playEffect(2010)
	elseif not completeFlag then 				-- 目标未完成
		if isCanConnect then	-- 有可连接的元素
			if currMoves <= 0 then		-- 步数用完
				ChannelProxy:recordValue(self:getRecordValue("stat_copy_fail"))
				UIManager:close(UIPauseGame)
				-- 购买步数界面
				UIManager:openFront(UIBuyMoves, true)
				AudioMgr:stopMusic()
				AudioMgr:playEffect(2011)
			end
		else					-- 无可连接的元素
			cclog("******************* 无可连接的元素")
			ChannelProxy:recordValue(self:getRecordValue("stat_copy_fail"))
			UIManager:close(UIPauseGame)
			UIManager:close(UIGameGoal)
			UIMiddlePub:openUIFailed()
			AudioMgr:stopMusic()
			AudioMgr:playEffect(2011)
		end
	end
end

-- 设置顶部剩余目标的个数(第几个目标,目标上次个数,目标现在的个数)
function UIGameGoal:setTopGoalsAmount(newGoals)
	local function goalAction(lastCount, currCount, numText, fullImage)
		lastCount = lastCount - 1
		numText:setString(tostring(lastCount))
		numText:setVisible(true)
		fullImage:setVisible(false)
		local action1 = cc.EaseElasticIn:create(cc.ScaleTo:create(0.05, 1.5, 1.5))
		local action2 = cc.ScaleTo:create(0.15, 1.0, 1.0)
		numText:runAction(cc.Sequence:create(action1, action2, cc.CallFunc:create(function()
			if lastCount > currCount then
				goalAction(lastCount, currCount, numText, fullImage)
			elseif lastCount <= 0 then
				numText:setVisible(false)
				fullImage:setVisible(true)
				fullImage:setScale(0)
				fullImage:runAction(cc.EaseIn:create(cc.ScaleTo:create(0.5, 1.0), 2.5))
			end
		end)))
	end
	for index, goal in pairs(newGoals) do
		local lastCount = self.mGoalLastCountList[index] or 0
		local currCount = CopyModel:getRemainGoalCount(goal.id)
		if lastCount > 0 and lastCount ~= currCount then
			self.mGoalLastCountList[index] = currCount
			-- 界面展示
			local fullImage = UIManager:seekNodeByName(self.mRootNode, "full_"..index)
			local numText = UIManager:seekNodeByName(self.mRootNode, "number_"..index)
			numText:stopAllActions()
			fullImage:stopAllActions()	
			goalAction(lastCount, currCount, numText, fullImage)
		end
	end
end

-- 中间目标飞到顶部的动画
function UIGameGoal:nodeFlyToTarget()
	local goals = CopyModel:getGoals()
	for i=1, 3 do
		local back = UIManager:seekNodeByName(self.mRootNode, "back_"..i)
		local iconBg = UIManager:seekNodeByName(self.mRootNode, "ImageBg_"..i)
		local icon = UIManager:seekNodeByName(self.mRootNode, "Icon_"..i)
		local image = UIManager:seekNodeByName(self.mRootNode, "Image_"..i)
		local amount = UIManager:seekNodeByName(self.mRootNode, "number_"..i)
		local img = UIManager:seekNodeByName(self.mRootNode, "Image_"..i)
		local internal = 0.2
		if #goals >= i then
			local action1 = cc.DelayTime:create(internal*i)
			local action2 = cc.ScaleTo:create(internal, 1.3, 1.3)
			local action3 = cc.ScaleTo:create(internal + 0.2, 1.0, 1.0)
			if #goals == i then
				action3 = cc.Spawn:create(action3, cc.CallFunc:create(function()
					-- 隐藏掉中间目标背景
					self.mGoalCenterBg:runAction(cc.Sequence:create(cc.FadeOut:create(1.2), cc.CallFunc:create(function()
						self.mGoalCenterBg:setVisible(false)
						self.mGoalCenterPanel:setVisible(false)
						self.mGoalCenterAmountPanel:setVisible(false)
					end)))
					self.mGoalCenterAmountPanel:runAction(cc.Sequence:create(cc.FadeOut:create(1.2)))
				end))
			end
			local action4 = cc.DelayTime:create(internal*i)
			local oldPos = icon:getWorldPosition()
			local newPos = img:getWorldPosition()
			local action5 = cc.MoveBy:create(0.5, cc.pSub(newPos, oldPos))
			local action6 = cc.ScaleTo:create(0.5, 0.5)
			local action7 = cc.Spawn:create(action5, action6)
			icon:runAction(cc.Sequence:create(action1, action2, action3, action4, action7, cc.CallFunc:create(function()
				-- 展现顶部目标
				back:setVisible(true)
				image:setVisible(true)
				amount:setVisible(true)
				icon:setScale(0.5)
				icon:setVisible(false)
				if goals[i].id == 0 then	--加载当前怪物的节点
					image:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.CallFunc:create(function()
						if nil ~= self.monstNode then
							self.monstNode:removeFromParent()
						end
						local display = MapManager:getMonsterDisplay()
						local node = Utils:createArmatureNode(display)
						node:setScale(0.1)
						node:setAnchorPoint(cc.p(0.5,0.5))
						node:setPosition(cc.p(21,18.78))
						back:addChild(node)
						node:runAction(cc.FadeIn:create(0.5))
						self.monstNode = node
					end)))
				end
			end)))
		end
	end
end

-- 获取关卡记录信息
function UIGameGoal:getRecordValue(event)
	local key = "level_"..DataMap:getPass()
	local valueTable = {}
	valueTable["event"] = event
	valueTable[key] = "heros="
	-- 英雄id,等级
	local heroIds = DataMap:getSelectedHeroIds()
	for i, heroId in pairs(heroIds) do
		local heroData = LogicTable:get("hero_tplt", heroId, true)
		valueTable[key] = valueTable[key].."("..heroId..":"..heroData.level..")"
	end
	valueTable[key] = valueTable[key]..",goals="
	-- 目标剩余数
	local goals = CopyModel:getGoals()
	for i, goal in pairs(goals) do
		local count = CopyModel:getRemainGoalCount(goal.id)
		valueTable[key] = valueTable[key].."("..goal.id..":"..count..")"
	end
	valueTable[key] = valueTable[key]..",steps="..CopyModel:getCurrMoves()
	return valueTable
end

