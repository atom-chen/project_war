----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-03-02
-- Brief: 引导
----------------------------------------------------------------------
-- 配置
GuideConfig = {
	["COPYS"] = {
		--[[ 存放副本引导配置
			TIP_GOAL:		该关卡是否显示出场目标提示
			SHOW_DETAIL:	该关卡是否显示详细信息(点击英雄是否有效)
			STEPS:			步骤列表(op_type:1.显示对话,2.连线提示;op_value:对话文本/格子坐标;ex_value:额外配置)
		]]
		[1] = {
			["TIP_GOAL"] = false,
			["SHOW_DETAIL"] = false,
			["STEPS"] = {
				{op_type = 1, op_value = LanguageStr("GUIDE_1")},
				{op_type = 2, op_value = {{4, 5}, {4, 6}, {4, 7}}, ex_value = {}},
				{op_type = 2, op_value = {{5, 5}, {4, 6}, {5, 7}, {5, 8}}, ex_value = {}},
			}
		},
		[2] = {
			["TIP_GOAL"] = false,
			["SHOW_DETAIL"] = false,
			["STEPS"] = {
				{op_type = 2, op_value = {{4, 4}, {5, 5}, {6, 6}, {5, 7}, {6, 8}}, ex_value = {}},
			}
		},
		[3] = {
			["TIP_GOAL"] = false,
			["SHOW_DETAIL"] = true,
			["STEPS"] = {
				{op_type = 1, op_value = LanguageStr("GUIDE_2")},
				{op_type = 2, op_value = {{3, 5}, {4, 5}, {5, 4}, {6, 4}, {7, 5}, {7, 6}, {8, 6}}, ex_value = {}},
				{op_type = 1, op_value = LanguageStr("GUIDE_3")},
				{op_type = 2, op_value = {{5, 3}, {5, 4}, {6, 4}, {7, 4}, {7, 5}, {7, 6}, {8, 5}}, ex_value = {}},
			}
		},
		[4] = {
			["TIP_GOAL"] = true,
			["SHOW_DETAIL"] = true,
			["STEPS"] = {
				{op_type = 2, op_value = {{2, 6}, {3, 6}, {4, 6}}, ex_value = {}},
			}
		},
		[6] = {
			["TIP_GOAL"] = true,
			["SHOW_DETAIL"] = true,
			["STEPS"] = {
				{op_type = 2, op_value = {{5, 6}, {4, 6}}, ex_value = {{3, 6}, {5, 5}, {4, 5}, {3, 5}, {5, 7}, {4, 7}, {3, 7}}},
			}
		},
	},
	["UIS"] = {
		--[[ 存放界面引导配置
			op_text:对话文本;op_xoffset:x位置偏移;op_pos:点击区域位置;op_radius:点击区域半径;op_scale:点击区域x方向缩放系数
		]]
		{op_text = LanguageStr("GUIDE_4")},
		{op_text = LanguageStr("GUIDE_5"), op_xoffset = 1, op_pos = cc.p(653, 76), op_radius = 60, op_scale = 1.0},
		{op_text = "", op_xoffset = 0, op_pos = cc.p(242, 73), op_radius = 40, op_scale = 1.0},
		{op_text = "", op_xoffset = 2, op_pos = cc.p(189, 578), op_radius = 40, op_scale = 1.0},
		{op_text = LanguageStr("GUIDE_6"), op_xoffset = 0, op_pos = cc.p(353, 220), op_radius = 55, op_scale = 1.8},
		{op_text = LanguageStr("GUIDE_7")},
		{op_text = LanguageStr("GUIDE_8"), op_xoffset = 0, op_pos = cc.p(457, 430), op_radius = 45, op_scale = 1.5},
		{op_text = LanguageStr("GUIDE_9")},
	}
}
----------------------------------------------------------------------
-- 管理器
GuideMgr = {
	mGuideFlag = false,		-- 引导标识
	mCopyId = 0,			-- 副本id
	mCopyStep = 0,			-- 副本步骤
	mUIStep = 0,			-- 界面步骤
}

-- 是否在引导中
function GuideMgr:isInGuide()
	return self.mGuideFlag
end

-- 开始副本引导
function GuideMgr:startCopy(copyId)
	if nil == GuideConfig["COPYS"][copyId] then
		self.mGuideFlag = false
		return
	end
	self.mGuideFlag = true
	self.mCopyId = copyId
	self.mCopyStep = 1
end

-- 开始界面引导
function GuideMgr:startUI()
	self.mGuideFlag = true
	self.mUIStep = 1
end

-- 是否提示目标
function GuideMgr:isTipGoal()
	if nil == GuideConfig["COPYS"][self.mCopyId] then
		return true
	end
	return GuideConfig["COPYS"][self.mCopyId]["TIP_GOAL"]
end

-- 是否显示详细信息
function GuideMgr:isShowDetail()
	if nil == GuideConfig["COPYS"][self.mCopyId] then
		return true
	end
	return GuideConfig["COPYS"][self.mCopyId]["SHOW_DETAIL"]
end

-- 获取副本引导步骤
function GuideMgr:getCopyStep()
	if not self.mGuideFlag or nil == GuideConfig["COPYS"][self.mCopyId] then
		self.mGuideFlag = false
		return nil
	end
	local step = GuideConfig["COPYS"][self.mCopyId]["STEPS"][self.mCopyStep]
	if nil == step then
		self.mGuideFlag = false
		return nil
	end
	self.mCopyStep = self.mCopyStep + 1
	return step.op_type, step.op_value, step.ex_value
end

-- 获取界面引导步骤
function GuideMgr:getUIStep()
	if not self.mGuideFlag then
		return nil
	end
	local step = GuideConfig["UIS"][self.mUIStep]
	if nil == step then
		self.mGuideFlag = false
		return nil
	end
	self.mUIStep = self.mUIStep + 1
	return step.op_text, step.op_xoffset, step.op_pos, step.op_radius, step.op_scale
end

-- 是否开启界面引导
function GuideMgr:isUIGuideOpen()
	return 6 == DataMap:getMaxPass()	-- 第6关通过时引导
end

-- 是否开启英雄按钮
function GuideMgr:isHeroOpen()
	return DataMap:getMaxPass() >= 6	-- 通过第6关开启
end

-- 是否开启抽奖按钮
function GuideMgr:isLotteryOpen()
	return DataMap:getMaxPass() >= 7	-- 通过第7关开启
end
----------------------------------------------------------------------
-- 界面
GuideUI = {
	mGraySprite = nil,
	mDialogNode = nil
}

-- 创建对话框
function GuideUI:createDialog(textString)
	local node = cc.Node:create()
	-- 角色图片
	local roleSprite = cc.Sprite:create("guide_role.png")
	roleSprite:setAnchorPoint(cc.p(0, 0))
	roleSprite:setPosition(cc.p(0, 15))
	-- roleSprite:setRotationSkewY(180)
	node:addChild(roleSprite)
	-- 对话框
	local frameSprite = ccui.Scale9Sprite:create("guide_frame.png")
	frameSprite:setScale9Enabled(true)
	frameSprite:setCapInsets(cc.rect(60, 15, 170, 40))
	frameSprite:setAnchorPoint(cc.p(0.5, 1))
	frameSprite:setPosition(cc.p(G.WIN_SIZE.width/2, 400))
	frameSprite:setRotationSkewY(180)
	node:addChild(frameSprite)
	-- 对话文本
	local textTTF = cc.Label:createWithSystemFont(textString or "", "", 24)
	textTTF:setAnchorPoint(cc.p(0.5, 1))
	textTTF:setHorizontalAlignment(cc.TEXT_ALIGNMENT_CENTER)
	textTTF:setTextColor(cc.c4b(144, 55, 15, 255))
	-- textTTF:setMaxLineWidth(300)
	textTTF:setWidth(300)
	textTTF:setRotationSkewY(180)
	frameSprite:addChild(textTTF)
	-- 动态设置对话框高度
	local frameSize = frameSprite:getContentSize()
	local textSize = textTTF:getContentSize()
	if 350 > frameSize.width then
		frameSize.width = 350
	end
	if textSize.height + 100 > frameSize.height then
		frameSize.height = textSize.height + 100
	end
	frameSprite:setContentSize(frameSize)
	textTTF:setPosition(cc.p(frameSize.width/2, frameSize.height - (frameSize.height - 40 - textSize.height)/2))
	return node
end

-- 创建灰色背景
function GuideUI:createGrayBg(isSwallow, circlePos, circleRadius, circleXS, touchCF)
	-- 事件穿透处理
	local function onTouch(touch, event)
		if circlePos then
			if cc.pGetDistance(touch:getLocation(), circlePos) <= circleRadius then
				if cc.EventCode.ENDED == event:getEventCode() then
					Utils:doCallback(touchCF)
				end
				return false
			end
			return true
		end
		if cc.EventCode.ENDED == event:getEventCode() then
			Utils:doCallback(touchCF)
		end
		return true
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_ENDED)
	listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_CANCELLED)
	listener:setSwallowTouches(true)
	local layer = cc.Layer:create()
	if isSwallow then
		layer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, layer)
		layer:setTouchEnabled(true)
	else
		layer:setTouchEnabled(false)
	end
	-- 灰色背景
	local backgroundSprite = cc.Sprite:create("gray_01.png")
	local backgroundSize = backgroundSprite:getContentSize()
	backgroundSprite:setScaleX(G.WIN_SIZE.width/backgroundSize.width)
	backgroundSprite:setScaleY(G.WIN_SIZE.height/backgroundSize.height)
	backgroundSprite:setAnchorPoint(cc.p(0, 0))
	-- 裁剪操作
	if nil == circlePos then
		layer:addChild(backgroundSprite)
	else
		-- 绘画节点
		local oriRadius, zoomIn = circleRadius, true
		local drawNode = cc.DrawNode:create()
		drawNode:drawSolidCircle(circlePos, circleRadius, 0, 100, circleXS or 1.0, 1.0, cc.c4f(0.0, 0.0, 0.0, 0.0))
		-- 裁剪节点
		local clippingNode = cc.ClippingNode:create()
		clippingNode:addChild(backgroundSprite)
		clippingNode:setStencil(drawNode)
		clippingNode:setInverted(true)
		layer:addChild(clippingNode)
		-- 手指提示
		local fingerSprite = cc.Sprite:create("finger.png")
		fingerSprite:setAnchorPoint(cc.p(0, 1))
		fingerSprite:setPosition(circlePos)
		fingerSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.7, cc.p(20, -20)), cc.MoveBy:create(0.8, cc.p(-20, 20)))))
		layer:addChild(fingerSprite)
	end
	return layer
end

-- 检查界面引导
function GuideUI:checkUIGuide(layer)
	if not GuideMgr:isUIGuideOpen() or DataMap:isGuideComplete() then
		return false
	end
	if not DataLevelInfo:isSameClass("21") then
		DataMap:setGuideComplete()
		return false
	end
	GuideMgr:startUI()
	self:parseUIStep(layer)
	return true
end

-- 解析界面引导步骤
function GuideUI:parseUIStep(layer)
	local function removeGuideUI()
		if self.mGraySprite then
			self.mGraySprite:removeFromParent()
			self.mGraySprite = nil
		end
		if self.mDialogNode then
			self.mDialogNode:removeFromParent()
			self.mDialogNode = nil
		end
	end
	local opText, opXOffset, opPos, opRadius, opScale = GuideMgr:getUIStep()
	if nil == opText then
		removeGuideUI()
		return
	end
	removeGuideUI()
	if opPos then
		if 1 == opXOffset then
			local xOffset = G.DESIGN_WIDTH - opPos.x
			opPos.x = G.WIN_SIZE.width - xOffset
		elseif 2 == opXOffset then
			opPos = Utils:changePosition(opPos)
		else
			local xOffset = G.WIN_SIZE.width - G.DESIGN_WIDTH
			opPos.x = opPos.x + xOffset/2
		end
	end
	self.mGraySprite = self:createGrayBg(true, opPos, opRadius, opScale, function()
		if nil == opRadius then
			self:parseUIStep(layer)
		end
	end)
	Game.NODE_UI_FRONT:addChild(self.mGraySprite)
	if string.len(opText) > 0 then
		self.mDialogNode = self:createDialog(opText)
		Game.NODE_UI_FRONT:addChild(self.mDialogNode)
	end
end

