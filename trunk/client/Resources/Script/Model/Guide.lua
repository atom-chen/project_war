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
			STEPS:			步骤列表(op_type:1.显示对话,2.连线提示;op_value:对话文本/格子坐标;ex_value:额外配置)
		]]
		[1] = {
			["TIP_GOAL"] = false,
			["STEPS"] = {
				{op_type = 1, op_value = LanguageStr("GUIDE_1")},
				{op_type = 2, op_value = {{4, 5}, {4, 6}, {4, 7}}, ex_value = {}},
				{op_type = 1, op_value = LanguageStr("GUIDE_2"), 
					op_xoffset = 1, op_ori_pos = cc.p(-20, 808),op_des_pos = cc.p(94, 1000), op_radius = 35, op_segment = 50,op_finger_pos = cc.p(45, 900)},
				{op_type = 2, op_value = {{5, 5}, {4, 6}, {5, 7}, {5, 8}}, ex_value = {}},
			}
		},
		[2] = {
			["TIP_GOAL"] = false,
			["STEPS"] = {
				{op_type = 1, op_value = LanguageStr("GUIDE_4")},
				{op_type = 1, op_value = LanguageStr("GUIDE_5"),
					op_xoffset = 2,  op_ori_pos = cc.p(306, 530),op_des_pos = cc.p(411, 653), op_radius = 15, op_segment = 50,op_finger_pos = cc.p(373, 100)},
				{op_type = 2, op_value = {{4, 4}, {5, 5}, {6, 6}, {5, 7}, {6, 8}}, ex_value = {}},
				{op_type = 1, op_value = LanguageStr("GUIDE_6"),
					op_xoffset = 3, op_ori_pos = cc.p(625, 808),op_des_pos = cc.p(780, 1000), op_radius = 35, op_segment = 50,op_finger_pos = cc.p(653,76)},
			}
		},
		[3] = {
			["TIP_GOAL"] = false,
			["STEPS"] = {
				{op_type = 1, op_value = LanguageStr("GUIDE_7"), 
					op_xoffset = 1,  op_ori_pos = cc.p(-20, 808),op_des_pos = cc.p(94, 1000), op_radius = 35, op_segment = 50,op_finger_pos = cc.p(242, 73)},
				{op_type = 2, op_value = {{3, 4}, {4, 4}, {5, 5}, {6, 6}, {7, 5}, {8, 5}}, ex_value = {}},
				{op_type = 1, op_value = LanguageStr("GUIDE_8")},
			}
		},
		[4] = {
			["TIP_GOAL"] = false,
			["STEPS"] = {
				{op_type = 1, op_value = LanguageStr("GUIDE_9")},
				{op_type = 2, op_value = {{2, 6}, {3, 6}, {4, 6}}, ex_value = {}},
			}
		},
		[5] = {
			["TIP_GOAL"] = false,
			["STEPS"] = {
				{op_type = 2, op_value = {{2, 6}, {3, 5}, {4, 4},{5, 5},{6, 6},{7, 5},{8, 4},
					{8, 5},{8, 6},{8, 7},{8, 8},{7, 8},{6, 8},{5, 7},{4, 8},{3, 8}}, ex_value = {}},
				{op_type = 1, op_value = LanguageStr("GUIDE_10"), 
					op_xoffset = 2,  op_ori_pos = cc.p(176, 425),op_des_pos = cc.p(539, 500), op_radius = 20, op_segment = 50,op_finger_pos = cc.p(189, 578)},
			}
		},
		[6] = {
			["TIP_GOAL"] = false,
			["STEPS"] = {
				{op_type = 1, op_value = LanguageStr("GUIDE_12")},
				{op_type = 2, op_value = {{5, 6}, {4, 6}, {5, 5}, {4, 5}, {3, 5}, {3, 6}, {3, 7}, {4, 7}, {5, 7}}, ex_value = {}},
				{op_type = 1, op_value = LanguageStr("GUIDE_13"), 
					op_xoffset = 1,  op_ori_pos = cc.p(-20, 808),op_des_pos = cc.p(94, 1000), op_radius = 35, op_segment = 50,op_finger_pos = cc.p(353, 220)},
			}
		},
		[7] = {
			["TIP_GOAL"] = false,
			["STEPS"] = {
				{op_type = 1, op_value = LanguageStr("GUIDE_20"), 
					op_xoffset = 1,  op_ori_pos = cc.p(-20, 808),op_des_pos = cc.p(94, 1000), op_radius = 35, op_segment = 50,op_finger_pos = cc.p(653,76)},
				{op_type = 2, op_value = {{2, 4}, {3, 5}, {3, 6}, {3, 7}, {2, 8}}, ex_value = {}},	
				{op_type = 1, op_value = LanguageStr("GUIDE_21"), 
					op_xoffset = 0,  op_ori_pos = cc.p(183, -10),op_des_pos = cc.p(542, 130), op_radius = 20, op_segment = 50,op_finger_pos = cc.p(457, 430)},
				
			}
		},
		[8] = {
			["TIP_GOAL"] = false,
			["STEPS"] = {
				{op_type = 2, op_value = {{2, 6}, {3, 7}, {4, 8}, {5, 9}}, ex_value = {}},
				{op_type = 1, op_value = LanguageStr("GUIDE_22")},
			}
		},
		[14] = {
			["TIP_GOAL"] = false,
			["STEPS"] = {
				{op_type = 1, op_value = LanguageStr("GUIDE_23")},
				{op_type = 2, op_value = {{2,5}, {3, 4}, {4, 5}, {5, 5}, {6, 5}}, ex_value = {}},
			}
		},
	},
	["UIS"] = {
		--[[ 存放界面引导配置
			op_text:对话文本;op_xoffset:x位置偏移;op_pos:点击区域位置;op_radius:点击区域半径;op_scale:点击区域x方向缩放系数
		]]
		[6] = {
			{op_text = LanguageStr("GUIDE_14")},
			{op_text = LanguageStr("GUIDE_15"), op_xoffset = 1, op_ori_pos = cc.p(608, 30),op_des_pos = cc.p(700, 120), op_radius = 20, op_segment = 50, op_finger_pos = cc.p(653,76)},
			{op_text = "", op_xoffset = 0,  op_ori_pos = cc.p(210, 40),op_des_pos = cc.p(276, 105), op_radius = 20, op_segment = 50, op_finger_pos = cc.p(242, 73)},
			{op_text = "", op_xoffset = 2,  op_ori_pos = cc.p(155, 546),op_des_pos = cc.p(233, 606), op_radius = 30, op_segment = 50, op_finger_pos = cc.p(189, 578)},
			{op_text = LanguageStr("GUIDE_16"), op_xoffset = 0,  op_ori_pos = cc.p(265, 180),op_des_pos = cc.p(440, 255), op_radius = 20, op_segment = 50, op_finger_pos = cc.p(353, 220)},
			{op_text = LanguageStr("GUIDE_17")},
			{op_text = LanguageStr("GUIDE_18"), op_xoffset = 0,  op_ori_pos = cc.p(391, 390),op_des_pos = cc.p(531, 468), op_radius = 20, op_segment = 50, op_finger_pos = cc.p(457, 430)},
			{op_text = LanguageStr("GUIDE_19")},
		},
		[G.GUIDE_CHANGE_HERO] = {
			{op_text = LanguageStr("GUIDE_24"),op_showfinger = false, op_xoffset = 0, op_ori_pos = cc.p(145, 570),op_des_pos = cc.p(577, 720), op_radius = 20, op_segment = 50,op_finger_pos = cc.p(175, 430)},
			{op_text = "", op_xoffset = 0,op_showfinger = true,  op_ori_pos = cc.p(140, 355),op_des_pos = cc.p(580, 515), op_radius = 20, op_segment = 50, op_finger_pos = cc.p(175, 390)},	--需要特殊处理啊*******？？？？？？？
		},
		
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
	if nil == GuideConfig["COPYS"][DataMap:getPass()] then
		return true
	end
	return GuideConfig["COPYS"][DataMap:getPass()]["TIP_GOAL"]
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
	return step.op_type, step.op_value, step.ex_value, step.op_xoffset, CommonFunc:clone(step.op_ori_pos), CommonFunc:clone(step.op_des_pos), step.op_radius, step.op_segment, step.op_finger_pos
end

-- 获取界面引导步骤
function GuideMgr:getUIStep()
	if not self.mGuideFlag then
		return nil
	end
	local step = GuideConfig["UIS"][DataMap:getMaxPass()][self.mUIStep]
	if nil == step then
		self.mGuideFlag = false
		return nil
	end
	self.mUIStep = self.mUIStep + 1
	return step.op_text, step.op_xoffset, step.op_ori_pos, step.op_des_pos,step.op_radius, step.op_segment,step.op_showfinger,step.op_finger_pos
end

-- 判断界面UI有没有被引导过
function GuideMgr:isUIGuided()
	local guidedIds = DataMap:getUIGuideInfo()
	local maxCopyId = DataMap:getMaxPass()
	for key,val in pairs(guidedIds) do
		if val == maxCopyId then
			return true
		end
	end
	return false
end

-- 是否开启界面引导   判断界面UI有没有被引导过
function GuideMgr:isUIGuideOpen()
	if 6 == DataMap:getMaxPass() or G.GUIDE_CHANGE_HERO == DataMap:getMaxPass() then 
		return not self:isUIGuided()
	end
	return false	-- 第6关通过时引导
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
function GuideUI:createGrayBg(isSwallow, oriPos, desPos, radius, segments, touchCF, showFingerBool,op_finger_pos)
	-- 事件穿透处理
	local function onTouch(touch, event)
		if oriPos and showFingerBool then
			local x = touch:getLocation().x
			local y = touch:getLocation().y
			if x >= oriPos.x and x<= desPos.x and y >= oriPos.y and y <= desPos.y then
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
	backgroundSprite:setAnchorPoint(cc.p(0.5, 0.5))
	backgroundSprite:setPosition(cc.p(G.WIN_SIZE.width/2, G.WIN_SIZE.height/2))
	-- 裁剪操作
	if nil == oriPos then
		layer:addChild(backgroundSprite)
	else
		-- 绘画节点
		local drawNode = cc.DrawNode:create()
		self:drawRoundRect(oriPos,desPos,radius,segments, cc.c4f(0,0,1,1),drawNode)
		-- 裁剪节点
		local clippingNode = cc.ClippingNode:create()
		clippingNode:addChild(backgroundSprite)
		clippingNode:setStencil(drawNode)
		clippingNode:setInverted(true)
		layer:addChild(clippingNode)
		
		if showFingerBool then
			-- 手指提示
			local fingerSprite = cc.Sprite:create("finger.png")
			fingerSprite:setAnchorPoint(cc.p(0, 1))
			fingerSprite:setPosition(op_finger_pos)	--有待处理*************
			if DataMap:getPass() == (G.GUIDE_CHANGE_HERO + 1) then
				local action1 = cc.Spawn:create(cc.MoveBy:create(0.3, cc.p(0, 20)),cc.FadeOut:create(0.3))
				fingerSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(
					cc.MoveBy:create(1.0, cc.p(0, 80)),action1,cc.DelayTime:create(0.2),cc.CallFunc:create(function()
						fingerSprite:setPosition(op_finger_pos)	
						fingerSprite:runAction(cc.Sequence:create(cc.FadeIn:create(0.3)))
					end))))
			else
				fingerSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.7, cc.p(20, -20)), cc.MoveBy:create(0.8, cc.p(-20, 20)))))
			end
			layer:addChild(fingerSprite)
		end
	end
	return layer
end

-- 画圆角矩形
function GuideUI:drawRoundRect(oriPoint,destPoint,radius,segments,color,drawNode)
	--算出1/4圆
    local coef   = 0.5* math.pi/ segments	--系数
	local verticesTb = {}
    for i = 1,segments + 1,1 do
		local thisVertices = cc.p(0,0)
        local rads    = (segments - i)*coef
        thisVertices.x  = math.floor(radius * math.sin(rads))
        thisVertices.y  = math.floor(radius * math.cos(rads))
		table.insert(verticesTb,thisVertices)
	end
    local tagCenter = cc.p(0,0)
    local minX   = math.min(oriPoint.x, destPoint.x)	
    local maxX   = math.max(oriPoint.x, destPoint.x)	
    local minY   = math.min(oriPoint.y, destPoint.y)	
    local maxY   = math.max(oriPoint.y, destPoint.y)	
    local pPolygonPtArr = {}
	--左上角
    tagCenter.x   = minX + radius	
    tagCenter.y   = maxY - radius	
    for i = 1,segments + 1,1 do
		local thisPolygonPt = cc.p(0,0)
        thisPolygonPt.x  = tagCenter.x - verticesTb[i].x
        thisPolygonPt.y  = tagCenter.y + verticesTb[i].y
        table.insert(pPolygonPtArr,thisPolygonPt)
    end
	 --右上角
    tagCenter.x   = maxX - radius	
    tagCenter.y   = maxY - radius
    for i = 1, segments + 1, 1 do	
       local thisPolygonPt = cc.p(0,0)
       thisPolygonPt.x  = tagCenter.x + verticesTb[segments + 2 - i].x
       thisPolygonPt.y  = tagCenter.y + verticesTb[segments  + 2 - i].y
       table.insert(pPolygonPtArr,thisPolygonPt)
    end
	 --右下角
    tagCenter.x    = maxX - radius
    tagCenter.y    = minY + radius
    for i = 1, segments + 1, 1 do
       local thisPolygonPt = cc.p(0,0)
        thisPolygonPt.x  = tagCenter.x + verticesTb[i].x
        thisPolygonPt.y  = tagCenter.y - verticesTb[i].y
        table.insert(pPolygonPtArr,thisPolygonPt)
    end
	 --左下角
    tagCenter.x    = minX + radius
    tagCenter.y    = minY + radius
    for i = 1 ,segments + 1, 1 do
       local thisPolygonPt = cc.p(0,0)
        thisPolygonPt.x  = tagCenter.x - verticesTb[segments  + 2  - i].x
        thisPolygonPt.y  = tagCenter.y - verticesTb[segments  + 2 - i].y
        table.insert(pPolygonPtArr,thisPolygonPt)
    end
	drawNode:drawSolidPoly(pPolygonPtArr, #pPolygonPtArr, cc.c4f(0,0,1,1))
end

-- 检查界面引导(新手英雄升級)
function GuideUI:checkUIGuide(layer)
	if DataMap:isGuideComplete() or GuideMgr:isUIGuideOpen() == false then
		self.mGuideFlag = false
		return false
	end
	--沒有出現英雄2101，就不進行升級引導（英雄id  2101与关卡无关）
	if ModelLevelLottery:isSameClass("21") and 6 == DataMap:getMaxPass() then	
		GuideMgr:startUI()
		self:parseUIStep(layer)
		self.mGuideFlag = true
		return true
	else
		self.mGuideFlag = false
		return false
	end
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
	
	local opText, opXOffset, opOriPos, opDesPos,opRadius, opSegment, opShowfinger,op_finger_pos =  GuideMgr:getUIStep()
	if opShowfinger == nil then
		opShowfinger = true
	end
	
	if nil == opText and DataMap:getPass() == (G.GUIDE_CHANGE_HERO + 1) and DataMap:isGuideComplete() == false then
		self:parseUIStep(layer)
		return
	elseif nil == opText then
		removeGuideUI()
		return
	end
	removeGuideUI()

	if op_finger_pos then
		if 1 == opXOffset then
			local xOffset = G.DESIGN_WIDTH - op_finger_pos.x
			op_finger_pos.x = G.WIN_SIZE.width - xOffset
			local xOffset = G.DESIGN_WIDTH - opOriPos.x
			opOriPos.x = G.WIN_SIZE.width - xOffset
			local xOffset = G.DESIGN_WIDTH - opDesPos.x
			opDesPos.x = G.WIN_SIZE.width - xOffset	
		elseif 2 == opXOffset then
			op_finger_pos = Utils:changePosition(op_finger_pos)
			opOriPos = Utils:changePosition(opOriPos)
			opDesPos = Utils:changePosition(opDesPos)
		else
			local xOffset = G.WIN_SIZE.width - G.DESIGN_WIDTH
			op_finger_pos.x = op_finger_pos.x + xOffset/2
			opOriPos.x = opOriPos.x + xOffset/2
			opDesPos.x = opDesPos.x + xOffset/2	
		end
	end
	self.mGraySprite = self:createGrayBg(true, opOriPos, opDesPos, opRadius, opSegment, function()
		--if nil == opRadius then
			self:parseUIStep(layer)
		--end	
	end, opShowfinger,op_finger_pos)
	Game.NODE_UI_FRONT:addChild(self.mGraySprite)
	if string.len(opText) > 0 then
		self.mDialogNode = self:createDialog(opText)
		Game.NODE_UI_FRONT:addChild(self.mDialogNode)
	end
end

