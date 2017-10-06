----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-11
-- Brief: 战斗目标界面
----------------------------------------------------------------------
UIDEFINE("UIGameGoal", "GameGoal.csb")
function UIGameGoal:onStart(ui, param)
	
	self.rootNode = ui.root
	self.mGoalLastCountList = {}
	self.mCanClick = true	-- 是否可点击按钮
	-- 根节点
	self.mRootNode = ui.root
	-- 目标面板
	self.mGoalPanel = self:getChild("Panel_goal")
	Utils:autoChangePos(self.mGoalPanel)
	-- 暂停面板
	self.mPausePanel = self:getChild("Panel_pause")
	Utils:autoChangePos(self.mPausePanel)
	-- 中间目标面板背景
	self.mGoalCenterBg = self:getChild("Panel_centerBg")
	Utils:autoChangePos(self.mGoalCenterBg)
	-- 中间目标面板
	self.mGoalCenterPanel = self:getChild("Panel_Goals_center")
	Utils:autoChangePos(self.mGoalCenterPanel)
	self:addTouchEvent(self.mGoalCenterPanel, function(sender)
		self:closeCenterPanel()
	end, false, false, 0)
	--中间数字面板
	self.mGoalCenterAmountPanel = self:getChild("Panel_amount")
	Utils:autoChangePos(self.mGoalCenterAmountPanel)
	self:addTouchEvent(self.mGoalCenterAmountPanel, function(sender)
		self:closeCenterPanel()
	end, false, false, 0)
	-- 剩余步数背景
	self.mLeftMovesBg = self:getChild("Image_moveBg")
	self.mLeftMovesBg:setVisible(false)
	-- 剩余步数文本框
	self.mLeftMovesLabel = self:getChild("Text_moves")
	self.mLeftMovesLabel:enableOutline(cc.c4b(83,43,17,255),3)
	self.mLeftMovesLabel:setString(ModelCopy:getMoves())
	-- 暂停按钮
	self.mBtnPause = self:getChild("Button_pause")
	self:addTouchEvent(self.mBtnPause, function(sender)
		if not self.mCanClick or MapManager:getTouchFlag() > 0 then
			return
		end
		self:closeCenterPanel()
		UIPauseGame:openFront(true)	-- 打开主界面
	end, true, true, 0)
	-- 快速过关按钮,快速失败按钮
	self.mIsQuickPass = false
	local btnQuickPass = self:getChild("Button_quickpass")
	Utils:autoChangePos(btnQuickPass)
	local btnQuickFail = self:getChild("Button_quickfail")
	Utils:autoChangePos(btnQuickFail)
	self:addTouchEvent(btnQuickPass, function(sender)
		if not self.mCanClick or MapManager:getTouchFlag() > 0 then
			return
		end
		self.mIsQuickPass = true
		self.mBtnPause:setTouchEnabled(false)
		btnQuickFail:setTouchEnabled(false)
		btnQuickPass:setVisible(false)
		local elementDatas = {}
		local killNum = 0
		local goals = ModelCopy:getGoals()
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
	self:addTouchEvent(btnQuickFail, function(sender)
		if not self.mCanClick or MapManager:getTouchFlag() > 0 then
			return
		end
		self.mBtnPause:setTouchEnabled(false)
		btnQuickPass:setTouchEnabled(false)
		btnQuickFail:setVisible(false)
		ModelCopy:setMoves(1)
		self:updateLeftMoves()
		self:checkGameOver(true)
	end, true, true, 0)
	if G.CONFIG["debug"] then
		btnQuickPass:setVisible(true)
		btnQuickFail:setVisible(true)
	else
		btnQuickPass:setVisible(false)
		btnQuickFail:setVisible(false)
	end
	-- 初始操作
	self:loadTopPanel()
	--self:loadCenterPanel()
	if ChannelProxy:isCocos() or "10181" == ChannelProxy:getChannelId() then
	else
		ModelDisMoves:showDiscountMoves()	-- 失败几次后会弹出打折步数界面
	end
	-- 收到此事件时,步数减1
	self:bind(EventDef["ED_CLEAR_BEGIN"], function()
		self:updateLeftMoves()
		self.mCanClick = false
	end)
	-- 收到此事件时,需要判断游戏是否结束(条件1:当目标都完成时成功,条件2:当步数为0时失败)
	self:bind(EventDef["ED_ROUND_OVER"], function(isRoundValid)
		if isRoundValid then
			self:checkGameOver(true)
		end
		self.mCanClick = true
	end)
	-- 收到此事件时,游戏结束且失败(这是因为地图没有可连接的元素)
	self:bind(EventDef["ED_GAME_OVER"], function()
		self:checkGameOver(false)
	end)
	-- 收到此事件时,需要更新收集目标,目标数减1,此事件会携带元素数据
	self:bind(EventDef["ED_CLEAR_END"], function(elementDatas)
		self:updateCollectGoals(elementDatas)
	end)
	-- 收到此事件时,怪物数量减1
	self:bind(EventDef["ED_KILL_MONSTER"], function()
		if self.mIsGameSuccess then
			return
		end
		self:updateKillGoals(1)
		
		if  nil ~= self.monstNode then
			local back = self:getChild("back_1")
			--self.monstNode:stopAllActions()
			self.monstNode:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.CallFunc:create(function()
				self.monstNode:removeFromParent()
				local display = MapManager:getMonsterDisplay()
				if nil ~= display then
					local back = self:getChild("back_1")
					local node = Utils:createArmatureNode(display)
					node:setScale(0.1)
					node:setAnchorPoint(cc.p(0.5,0.5))
					node:setPosition(cc.p(21,12))
					back:addChild(node)
					node:setOpacity(0)
					node:runAction(cc.FadeIn:create(0.5))
					self.monstNode = node
				else
					self.monstNode:removeFromParent()
					local monstImg = ccui.ImageView:create()	
					monstImg:loadTexture("small_monster.png")
					monstImg:setAnchorPoint(cc.p(0.5,0.5))
					monstImg:setPosition(cc.p(21,12))
					monstImg:setScale(0.5)
					back:addChild(monstImg)
				end	
			end)))	
		end
	end)
	self.mIsGameSuccess = false
	self.mIsFirstSuccess = false
	if not GuideMgr:isTipGoal() and  not ModelPub:isSpeLevel()then
		self:closeCenterPanel()
	else
		self:loadCenterPanel()
	end
end

function UIGameGoal:onTouch(touch, event, eventCode)
	self:closeCenterPanel_touch()
end

function UIGameGoal:onUpdate(dt)
end

function UIGameGoal:onDestroy()
	self.monstNode = nil
	local back = self:getChild("back_1")
	back:removeAllChildren()
	
	self.mLeftMovesLabel = nil 
	self.mLeftMovesBg = nil
end

-- 更新收集目标
function UIGameGoal:updateCollectGoals(elementDatas)
	local collectGoals = ModelCopy:updateColleteGoals(elementDatas)
	ModelItem:updateCollect(elementDatas)
	self:setTopGoalsAmount(collectGoals)
end

-- 更新击杀目标
function UIGameGoal:updateKillGoals(killNum)
	for i=1, killNum do
		local killGoals = ModelCopy:updateKillGoals()
		self:setTopGoalsAmount(killGoals)
	end
end

-- 加载顶部目标的的图片和剩余个数
function UIGameGoal:loadTopPanel()
	local goals = ModelCopy:getGoals()
	for i=1, 3 do
		local back = self:getChild("back_"..i)
		local icon = self:getChild("Image_"..i)
		local amount = self:getChild("number_"..i)
		local full = self:getChild("full_"..i)
		icon:setVisible(false)
		amount:setVisible(false)
		full:setVisible(false)
		back:setVisible(false)
		if #goals >= i then
			local iconStr = ModelPub:getIconStrById(goals[i].id)
			icon:loadTexture(iconStr)
			amount:setString(goals[i].count)
			self.mGoalLastCountList[i] = goals[i].count
		end
	end
end

-- 加载中间目标的的图片和剩余个数
function UIGameGoal:loadCenterPanel()
	local goals = ModelCopy:getGoals()
	for i=1, 3 do
		local back = self:getChild("back_"..i)
		local icon = self:getChild("Icon_"..i)
		local iconBg = self:getChild("ImageBg_"..i)
		local amount = self:getChild("amount_"..i)
		local des_text = self:getChild("des_"..i)
		icon:setVisible(false)
		amount:setVisible(false)
		iconBg:setVisible(false)
		back:setVisible(false)
		des_text:setVisible(false)
		if #goals >= i then
			local iconStr = ModelPub:getIconStrById(goals[i].id)
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
	local goals = ModelCopy:getGoals()
	self.mGoalCenterBg:setVisible(false)
	self.mGoalCenterPanel:setVisible(false)
	self.mGoalCenterAmountPanel:setVisible(false)
	for i=1,3,1 do
		local back = self:getChild("back_"..i)
		local icon = self:getChild("Image_"..i)
		local amount = self:getChild("number_"..i)
		local icon_center = self:getChild("Icon_"..i)
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
					node:setPosition(cc.p(21,12))
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
	local goals = ModelCopy:getGoals()
	self.mGoalCenterBg:setVisible(false)
	self.mGoalCenterPanel:setVisible(false)
	self.mGoalCenterAmountPanel:setVisible(false)
	for i=1,3,1 do
		local back = self:getChild("back_"..i)
		local icon = self:getChild("Image_"..i)
		local amount = self:getChild("number_"..i)
		local icon_center = self:getChild("Icon_"..i)
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
	local leftMoves = ModelCopy:getMoves() - 1
	--只要连了一步，体力就要扣除
	if leftMoves == ModelCopy:getOriMoves() - 1 and (UIBuyMoves:getBuyMovesFlag() == false)  then
		ModelDisMoves:isSameLevel()
		DataMap:setLastPass(ModelPub:getCurPass())
		PowerManger:setCurPower(PowerManger:getCurPower() - ModelCopy:getHp())
		PowerManger:timerChangeCurPower()
	end
	ModelCopy:setMoves(leftMoves)
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
	local completeFlag = ModelCopy:isGoalsComplete()
	local currMoves = ModelCopy:getMoves()
	if completeFlag and currMoves >= 0 then		-- 目标完成
		self.mIsGameSuccess = true
		self.mBtnPause:setTouchEnabled(false)
		MapManager:setTouch(false)
		EventCenter:post(EventDef["ED_GAME_SUCCESS"])
		self.mIsFirstSuccess = ModelDiscount:isFirstSuccess()
		if ModelPub:isSpeLevel() == false then
			DataMap:setMaxPass(DataMap:getPass())	-- 设置最大通关数
		end
		--为了配合新手，第一关打完后，强制出现第一只英雄
		if DataMap:getMaxPass() == 1 then
			strNow = string.sub(3101,1,2)
			if ModelLevelLottery:isSameClass(strNow) ==  false then
				DataHeroInfo:setUnlockHeroTb(3101,false)
				DataHeroInfo:setSelectHeroId(3101)
				DataHeroInfo:getSelectHeroId(true)
			end
		end
		
		ModelDiscount:setOpenDisDiaFlag(self.mIsFirstSuccess)	-- 设置是否显示砖石打折界面
		ModelSignIn:setOpenSignInFlag(self.mIsFirstSuccess)	-- 设置是否显示每日签到界面
		if GoalType["collect"] == ModelCopy:getGoalType() then
			MapManager:getComponent("HeroController"):winCheer()
		end
		-- 灰色背景
		local graySprite = cc.Sprite:create("gray_01.png")
		local size = graySprite:getContentSize()
		graySprite:setScaleX(G.VISIBLE_SIZE.width/size.width)
		graySprite:setScaleY(G.VISIBLE_SIZE.height/size.height)
		graySprite:setOpacity(0)
		self.node:addChild(graySprite, 100)
		DataMap:setCopyFailCount(DataMap:getPass(), 0)
		ChannelProxy:recordValue("success")
		if self.mIsFirstSuccess and currMoves > 0 and DataMap:getPass() > 6 and not self.mIsQuickPass then	-- 有剩余步数奖励
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
								currMoves = ModelCopy:getMoves()
								if 0 == currMoves then
									ModelPub:openUISuccess()
								end
							end)
						end)
					end
				end)
				successEffect:setAnchorPoint(cc.p(0.5, 0.5))
				self.node:addChild(successEffect, 101)
			end)
		else		-- 无剩余步数奖励
			ModelPub:openUISuccess()
		end
		AudioMgr:stopMusic()
		AudioMgr:playEffect(2010)
	elseif not completeFlag then 				-- 目标未完成
		if isCanConnect then	-- 有可连接的元素
			if currMoves <= 0 then		-- 步数用完
				local copyId = DataMap:getPass()
				DataMap:setCopyFailCount(copyId, DataMap:getCopyFailCount(copyId) + 1)
				ChannelProxy:recordValue("fail")
				UIPauseGame:close()
				if ModelPub:isSpeLevel() then
					ModelPub:openUIFailed()
				else
					-- 购买步数界面
					UIBuyMoves:openFront(true)
				end
				AudioMgr:stopMusic()
				AudioMgr:playEffect(2011)
			end
		else					-- 无可连接的元素
			local copyId = DataMap:getPass()
			DataMap:setCopyFailCount(copyId, DataMap:getCopyFailCount(copyId) + 1)
			ChannelProxy:recordValue("fail")
			cclog("******************* 无可连接的元素")
			UIPauseGame:close()
			UIGameGoal:close()
			ModelPub:openUIFailed()
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
			if completeFlag then
				numText:setVisible(false)
			end
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
		local currCount = ModelCopy:getRemainGoalCount(goal.id)
		if lastCount > 0 and lastCount ~= currCount then
			self.mGoalLastCountList[index] = currCount
			-- 界面展示
			local fullImage = self:getChild("full_"..index)
			local numText = self:getChild("number_"..index)
			numText:stopAllActions()
			fullImage:stopAllActions()	
			goalAction(lastCount, currCount, numText, fullImage)
		end
	end
end

-- 中间目标飞到顶部的动画
function UIGameGoal:nodeFlyToTarget()
	local goals = ModelCopy:getGoals()
	for i=1, 3 do
		local back = self:getChild("back_"..i)			--左上角的底板
		local iconBg = self:getChild("ImageBg_"..i)		--中间目标的底板
		local icon = self:getChild("Icon_"..i)			--中间目标的图片
		local image = self:getChild("Image_"..i)			--左上角的目标
		local amount = self:getChild("number_"..i)		--左上角的个数
		amount:enableOutline(cc.c4b(80,44,12,255),3)
		local img = self:getChild("Image_"..i)
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
				back:setVisible(true)
				image:setVisible(true)
				amount:setVisible(true)
				icon:setScale(0.5)
				icon:setVisible(false)
				local completeFlag = ModelCopy:isGoalsComplete()
				if completeFlag then
					amount:setVisible(false)
				end
				if goals[i].id == 0 then	--加载当前怪物的节点
					image:runAction(cc.Sequence:create(cc.FadeOut:create(0.3),cc.CallFunc:create(function()
						if nil ~= self.monstNode then
							self.monstNode:removeFromParent()
						end
						local display = MapManager:getMonsterDisplay()
						local node = Utils:createArmatureNode(display)
						node:setScale(0.1)
						node:setAnchorPoint(cc.p(0.5,0.5))
						node:setPosition(cc.p(21,12))
						back:addChild(node)
						node:runAction(cc.FadeIn:create(0.5))
						self.monstNode = node
					end)))
				end
			end)))
		end
	end
end


