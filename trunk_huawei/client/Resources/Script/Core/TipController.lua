----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 提示控制器
----------------------------------------------------------------------
TipController = class("TipController", Component)

-- 构造函数
function TipController:ctor()
	self.super:ctor(self.__cname)
	self.mAutoTipTimer = CreateTimer(4, 0, function(tm)
		self:autoTipGrid()
	end, nil)
	self.mAutoTipTimer:start()
	self.mAutoTipOpen = true
	self.mAutoTipPath = nil
	self.mMaskSprite = nil					-- 遮罩精灵
	self.mGrayBgSprite = nil				-- 灰色背景精灵
	self.mDialogNode = nil					-- 对话框节点
	self.mFingerSprite = nil				-- 新手引导手指
	self.mGuideCoordList = {}				-- 新手引导坐标列表(路径)
	self.mValidCoordList = {}				-- 新手引导坐标列表(有效)
	self.mIsOnGuide = false					-- 是否在新手引导中
	self.mIsGameSuccess = false
	-- 注册事件
	self:subscribeEvent(EventDef["ED_TOUCH_GRID_BEGIN"], self.handleTouchGridBegin)
	self:subscribeEvent(EventDef["ED_TOUCH_GRID_MOVE"], self.handleTouchGridMove)
	self:subscribeEvent(EventDef["ED_TOUCH_GRID_END"], self.handleTouchGridEnd)
	self:subscribeEvent(EventDef["ED_CLEAR_BEGIN"], self.handleClearBegin)
	self:subscribeEvent(EventDef["ED_CLEAR_END"], self.handleClearEnd)
	self:subscribeEvent(EventDef["ED_DROP_BEGIN"], self.handleDropBegin)
	self:subscribeEvent(EventDef["ED_ROUND_OVER"], self.handleRoundOver)
	self:subscribeEvent(EventDef["ED_GAME_SUCCESS"], self.handleGameSuccess)
end

-- 销毁函数
function TipController:destroy()
	self.super:destroy()
	self.mAutoTipTimer:stop()
	self.mAutoTipTimer = nil
	self.mAutoTipOpen = false
	self:hideDialog()
end

-- 开始触摸
function TipController:onTouchBegan(touch, event, gridInfo)
	self:guideTouchBegan(touch, event, gridInfo)
end

-- 移动触摸
function TipController:onTouchMoved(touch, event, gridInfo)
	self:guideTouchMoved(touch, event, gridInfo)
end

-- 触摸结束
function TipController:onTouchEnded(touch, event, gridInfo)
	self.mAutoTipPath = nil
	if self:hideDialog() then
		self:parsetGuideStep()
	else
		self:guideTouchEnded(touch, event, gridInfo)
	end
end

-- 取消触摸
function TipController:onTouchCancelled(touch, event, gridInfo)
	self:onTouchEnded(touch, event, gridInfo)
end

-- 唤醒自动提示器
function TipController:resumeAutoTipTimer()
	self.mAutoTipTimer:resume()
	self.mAutoTipOpen = true
end

-- 暂停自动提示器
function TipController:pauseAutoTipTimer()
	self.mAutoTipTimer:pause()
	self.mAutoTipOpen = false
end

-- 自动提示
function TipController:autoTipGrid()
	if self.mIsGameSuccess then
		return
	end
	self.mAutoTipTimer:pause()
	local gridController = self:getSibling("GridController")
	if nil == self.mAutoTipPath then
		self.mAutoTipPath = gridController:getClearPath()
		if nil == self.mAutoTipPath then
			return
		end
	end
	local _, firstGrid = gridController:getGrid(self.mAutoTipPath[1].row, self.mAutoTipPath[1].col)
	local normalType = nil
	if ElementType["normal"] == firstGrid:getShowElement():getType() then
		normalType = firstGrid:getShowElement():getSubType()
	elseif ElementType["skill"] == firstGrid:getShowElement():getType() then
		normalType = firstGrid:getShowElement():getExtraType()
	end
	if nil == normalType then
		return
	end
	local minCount = gridController:getMinCollect(normalType)
	self:shakeGridList(self.mAutoTipPath, minCount, function()
		if self.mAutoTipOpen then
			self.mAutoTipTimer:resume()
		end
	end)
end

-- 格子抖动
function TipController:shakeGridList(coordList, shakeCount, overCF)
	local coordCount = #coordList
	if 0 == coordCount then
		return
	end
	if nil == shakeCount or shakeCount > coordCount then
		shakeCount = coordCount
	end
	local gridController = self:getSibling("GridController")
	local function shakeCF(index)
		index = index + 1
		if index > shakeCount then
			Utils:doCallback(overCF)
			return
		end
		local _, grid = gridController:getGrid(coordList[index].row, coordList[index].col)
		if nil == grid then
			return
		end
		Actions:shakeAction03(grid:getShowElement():getSprite(), shakeCF, index)
	end
	local _, firstGrid = gridController:getGrid(coordList[1].row, coordList[1].col)
	if nil == firstGrid then
		return
	end
	Actions:shakeAction03(firstGrid:getShowElement():getSprite(), shakeCF, 1)
end

-- 灰色提示
function TipController:showGrayTip(show)
	local gridController = self:getSibling("GridController")
	local gridNodes = gridController:getGridNodes()
	for row, rowNodes in pairs(gridNodes) do
		for col, grid in pairs(rowNodes) do
			if not grid:isBorn() then
				grid:setGray(false)
				local showElement = grid:getShowElement()
				if showElement then
					if ElementType["normal"] == showElement:getType() then
						if show and gridController:getTouchedType() ~= showElement:getSubType() then
							grid:setGray(true)
						end
					elseif ElementType["skill"] == showElement:getType() then
						if show and gridController:getTouchedType() ~= showElement:getExtraType() then
							grid:setGray(true)
						end
					elseif ElementType["special"] == showElement:getType() then
						if show then
							grid:setGray(true)
						end
					else
						if show and showElement:isCanReset() then
							grid:setGray(true)
						end
					end
				end
			end
		end
	end
end

-- 显示遮罩
function TipController:showMask(show)
	if show then
		if nil == self.mMaskSprite then
			local blackSprite = cc.Sprite:create("gray_01.png")
			local size = blackSprite:getContentSize()
			blackSprite:setScaleX(G.VISIBLE_SIZE.width/size.width)
			blackSprite:setScaleY(self:getMaster():getTouchArea().height/size.height)
			blackSprite:setAnchorPoint(cc.p(0.5, 0))
			blackSprite:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 0))
			self:getMaster():getMapLayer():addChild(blackSprite, G.MAP_ZORDER_MASK)
			self.mMaskSprite = blackSprite
		end
		Actions:fadeIn(self.mMaskSprite, 0.3)
	else
		if self.mMaskSprite then
			self.mMaskSprite:stopAllActions()
			self.mMaskSprite:setOpacity(0)
		end
	end
end

-- 处理触摸格子开始事件
function TipController:handleTouchGridBegin(touchParam)
	if self.mIsOnGuide then
		return
	end
	self:pauseAutoTipTimer()
	self:showGrayTip(true)
	self:handleTouchGridMove(touchParam)
end

-- 处理触摸格子开始事件
function TipController:handleTouchGridMove(touchParam)
	if self.mIsOnGuide then
		return
	end
	self:showGrayTip(true)
	self:showHoverStatus(touchParam.touched_coord_list, true)
end

-- 处理触摸格子结束事件
function TipController:handleTouchGridEnd(touchParam)
	if self.mIsOnGuide then
		return
	end
	if not touchParam.can_clear_flag then
		self:resumeAutoTipTimer()
		self:showGrayTip(false)
		self:showHoverStatus(touchParam.touched_coord_list, false)
	end
end

-- 处理消除开始事件
function TipController:handleClearBegin()
	if self.mIsGameSuccess then
		return
	end
	if self.mIsOnGuide then
		self:hideGuideTip()
		return
	end
	self:showMask(true)
end

-- 处理消除结束事件
function TipController:handleClearEnd()
	if self.mIsGameSuccess or self.mIsOnGuide then
		return
	end
	self:showGrayTip(false)
end

-- 处理回合结束事件
function TipController:handleRoundOver(isRoundValid)
	if self.mIsGameSuccess or self:parsetGuideStep() then
		return
	end
	if self.mIsOnGuide then
		return
	end
	self:resumeAutoTipTimer()
end

-- 处理游戏成功
function TipController:handleGameSuccess()
	self.mIsGameSuccess = true
end

-- 处理掉落开始事件
function TipController:handleDropBegin()
	if self.mIsGameSuccess or self.mIsOnGuide then
		return
	end
	self:showMask(false)
end

-- 显示受影响状态
function TipController:showHoverStatus(touchCoordList, show)
	local gridController = self:getSibling("GridController")
	local gridNodes = gridController:getGridNodes()
	for row, rowNodes in pairs(gridNodes) do
		for col, grid in pairs(rowNodes) do
			if not grid:isBorn() then
				if show then
					grid:onAffectExit(1)
				else
					grid:onAffectEnter(1)
				end
			end
		end
	end
	if not show then
		return
	end
	local boardDatas = gridController:getBoardDatas()
	for i, touchCoord in pairs(touchCoordList) do
		local aroundGrids = gridController:getAroundGrids(touchCoord)
		for i, aroundGrid in pairs(aroundGrids) do
			if aroundGrid and not aroundGrid:isBorn() and not gridController:isTouchedCoord(aroundGrid:getCoord()) and Core:isCanContact(touchCoord, aroundGrid:getCoord(), boardDatas) then
				aroundGrid:onAffectEnter(1)
			end
		end
	end
end

-- 显示对话框
function TipController:showDialog(textString, opOriPos, opDesPos, opRadius, opSegment,op_finger_pos)
	if self.mGrayBgSprite or self.mDialogNode then
		return
	end
	self:setTouchSwallow(true)
	self.mGrayBgSprite = GuideUI:createGrayBg(false, opOriPos,opDesPos, opRadius, opSegment,nil, false,op_finger_pos)
	Game.NODE_UI_FIXED:addChild(self.mGrayBgSprite)
	self.mDialogNode = GuideUI:createDialog(textString)
	Game.NODE_UI_FIXED:addChild(self.mDialogNode)
	if not isNil(UIGameGoal.mBtnPause) then
		UIGameGoal.mBtnPause:setTouchEnabled(false)
	end
end

-- 隐藏对话框
function TipController:hideDialog()
	if self.mGrayBgSprite and self.mDialogNode then
		self.mGrayBgSprite:removeFromParent()
		self.mGrayBgSprite = nil
		self.mDialogNode:removeFromParent()
		self.mDialogNode = nil
		self:setTouchSwallow(false)
		if not isNil(UIGameGoal.mBtnPause) then
			UIGameGoal.mBtnPause:setTouchEnabled(true)
		end
		return true
	end
	return false
end

-- 显示引导提示
function TipController:showGuideTip(guideCoordList, validCoordList)
	if self.mFingerSprite or 0 == #guideCoordList then
		return
	end
	self:pauseAutoTipTimer()
	self:setTouchSwallow(true)
	self.mIsOnGuide = true
	-- 生成位置路径
	local startPos, guidePosPath = nil, {}
	for i, coord in pairs(guideCoordList) do
		local pos = self:getMaster():getGridPos(coord.row, coord.col)
		local guidePos = cc.pAdd(cc.p(pos.x, pos.y), cc.p(33, -33))
		if 1 == i then
			startPos = guidePos
		else
			table.insert(guidePosPath, guidePos)
		end
	end
	-- 手指滑动效果
	local fingerSprite = cc.Sprite:create("finger.png")
	local function fingerMove()
		fingerSprite:setPosition(startPos)
		Actions:delayWith(fingerSprite, 0.5, function()
			Actions:moveToWithPath(fingerSprite, guidePosPath, 0.5, function()
				Actions:delayWith(fingerSprite, 0.5, function()
					fingerMove()
				end)
			end)
		end)
	end
	fingerMove()
	self:getMaster():getTopLayer():addChild(fingerSprite, G.TOP_ZORDER_GUIDE)
	-- 目标格子抖动
	local function gridShake()
		self:shakeGridList(guideCoordList, nil, function()
			Actions:delayWith(fingerSprite, 3, function()
				gridShake()
			end)
		end)
	end
	gridShake()
	-- 是否为引导坐标
	local function isGuideCoord(coord)
		for i, guideCoord in pairs(guideCoordList) do
			if Core:equalCoord(coord, guideCoord) then
				return true
			end
		end
		return false
	end
	-- 其他格子变灰
	local gridController = self:getSibling("GridController")
	local gridNodes = gridController:getGridNodes()
	for row, rowNodes in pairs(gridNodes) do
		for col, grid in pairs(rowNodes) do
			if not isGuideCoord(Core:makeCoord(row, col)) and not grid:isBorn() and grid:getShowElement():isCanReset() then
				grid:setGray(true)
			end
		end
	end
	--
	self.mFingerSprite = fingerSprite
	self.mGuideCoordList = guideCoordList
	self.mValidCoordList = validCoordList
end

-- 隐藏引导提示
function TipController:hideGuideTip()
	if self.mFingerSprite then
		self.mFingerSprite:stopAllActions()
		self.mFingerSprite:removeFromParent()
		self.mFingerSprite = nil
		self.mGuideCoordList = {}
		self.mIsOnGuide = false
		self:showGrayTip(false)
		self:resumeAutoTipTimer()
		self:setTouchSwallow(false)
	end
end

-- 引导触摸开始
function TipController:guideTouchBegan(touch, event, gridInfo)
	if nil == gridInfo or not self.mIsOnGuide then
		return
	end
	local firstCoord = self.mGuideCoordList[1]
	if firstCoord.row == gridInfo.row and firstCoord.col == gridInfo.col then
		self:getSibling("GridController"):onTouchBegan(touch, event, gridInfo)
	end
	self:getSibling("MonsterController"):onTouchBegan(touch, event, gridInfo)
end

-- 引导触摸移动
function TipController:guideTouchMoved(touch, event, gridInfo)
	if nil == gridInfo or not self.mIsOnGuide then
		return
	end
	self:getSibling("MonsterController"):onTouchMoved(touch, event, gridInfo)
	for i, coord in pairs(self.mGuideCoordList) do
		if coord.row == gridInfo.row and coord.col == gridInfo.col then
			self:getSibling("GridController"):onTouchMoved(touch, event, gridInfo)
			return
		end
	end
	for i, coord in pairs(self.mValidCoordList) do
		if coord.row == gridInfo.row and coord.col == gridInfo.col then
			self:getSibling("GridController"):onTouchMoved(touch, event, gridInfo)
			return
		end
	end
end

-- 引导触摸结束
function TipController:guideTouchEnded(touch, event, gridInfo)
	if not self.mIsOnGuide then
		return
	end
	if nil == gridInfo then
		gridInfo = {}
	end
	gridInfo.min_collect = #self.mGuideCoordList
	self:getSibling("GridController"):onTouchEnded(touch, event, gridInfo)
	self:getSibling("MonsterController"):onTouchEnded(touch, event, gridInfo)
end

-- 是否引导中
function TipController:isOnGuide()
	return self.mIsOnGuide
end

-- 解析引导
function TipController:parsetGuideStep()
	local opType, opValue, exValue, opXOffset, opOriPos, opDesPos, opRadius, opSegment, op_finger_pos  = GuideMgr:getCopyStep()
	if nil == opType then
		self:getSibling("HeroController"):setShowHeroDetail(true)
		return false
	end
	self:getSibling("HeroController"):setShowHeroDetail(false)
	if opOriPos then
		if 1 == opXOffset then		--战斗左上角
		elseif 2 == opXOffset then
			opOriPos = Utils:changePosition(opOriPos)
			opDesPos = Utils:changePosition(opDesPos)
		elseif 3 == opXOffset then	--战斗右上角
			opOriPos.x = G.VISIBLE_SIZE.width - (G.DESIGN_WIDTH - opOriPos.x )
		else						--永远处于屏幕中间
			local xOffset = G.WIN_SIZE.width - G.DESIGN_WIDTH
			opOriPos.x = opOriPos.x + xOffset/2
			opDesPos.x = opDesPos.x + xOffset/2	
		end
	end
	if 1 == opType then
		self:showDialog(opValue,opOriPos, opDesPos, opRadius, opSegment,op_finger_pos)
	elseif 2 == opType then
		local guideCoordList = {}
		for i, coordCfg in pairs(opValue) do
			table.insert(guideCoordList, Core:makeCoord(coordCfg[1], coordCfg[2]))
		end
		local validCoordList = {}
		for i, coordCfg in pairs(exValue) do
			table.insert(validCoordList, Core:makeCoord(coordCfg[1], coordCfg[2]))
		end
		self:showGuideTip(guideCoordList, validCoordList)
	end
	return true
end
