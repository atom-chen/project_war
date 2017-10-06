----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-12-29
-- Brief:	通用函数
----------------------------------------------------------------------
Utils = {}
----------------------------------------------------------------------
-- 设置节点相对坐标:x,y取值为0-1之间 从中间计算
function Utils:setPosPercentCenter(node, xPercent, yPercent)
	local xPos = G.VISIBLE_SIZE.width * xPercent
	local yPos = G.DESIGN_HEIGHT * yPercent
	node:setPosition(cc.p(xPos, yPos))
end
----------------------------------------------------------------------
-- 设置节点相对坐标:x,y取值为0-1之间 从左下角计算
function Utils:setPosPercent(node, xPercent, yPercent)
	local xPos = (G.DESIGN_WIDTH - G.VISIBLE_SIZE.width)/2 + G.VISIBLE_SIZE.width * xPercent
	local yPos = G.DESIGN_HEIGHT * yPercent
	node:setPosition(cc.p(xPos, yPos))
end
----------------------------------------------------------------------
-- 设置"cc.Sprite"的图片
function Utils:setSpriteTexture(sprite, fileName)
	if nil == sprite or nil == fileName then return end
	sprite:setTexture(cc.Director:getInstance():getTextureCache():addImage(fileName))
end
----------------------------------------------------------------------
-- 自动转换坐标
function Utils:autoChangePos(node)
	local oriX, oriY = node:getPosition()
	self:setPosPercent(node, oriX/G.DESIGN_WIDTH, oriY/G.DESIGN_HEIGHT)
end
----------------------------------------------------------------------
-- 坐标转换
function Utils:changePosition(pos)
	if nil == pos then return nil end
	local xPos = G.VISIBLE_SIZE.width*(pos.x/G.DESIGN_WIDTH)
	return cc.p(xPos, pos.y)
end
----------------------------------------------------------------------
-- 创建着色器,返回:GLProgramState
function Utils:createShader(node, vertShaderFileName, fragShaderFileName)
	if nil == node then return nil end
	local vertSource = cc.FileUtils:getInstance():getStringFromFile(vertShaderFileName)
	local fragSource = cc.FileUtils:getInstance():getStringFromFile(fragShaderFileName)
	local glProgram = cc.GLProgram:createWithByteArrays(vertSource, fragSource)
	local glProgramState = cc.GLProgramState:create(glProgram)
	node:setGLProgramState(glProgramState)
	return glProgramState
end
----------------------------------------------------------------------
-- 执行函数
function Utils:doCallback(callback, ...)
	if "function" == type(callback) then
		return callback(...)
	end
	return nil
end
----------------------------------------------------------------------
--将秒转化为倒计时形式
function Utils:secToString(seconds)
	local t = seconds
	local remain
	local days = math.floor(t / (60 * 60 * 24))
	remain = t % (60 * 60 * 24)
	local hours = remain / (60 * 60)
	remain = remain % (60 * 60)
	local mins = remain / 60
	remain = remain % 60
	local rt =""
	if (days >= 1) then
		rt = string.format("%d%s",days,LanguageStr("TIAN"))
	end
	hours = math.floor(hours)
	mins = math.floor(mins)
	remain = math.floor(remain)
	
	rt = rt..string.format("%02d:%02d:%02d", hours, mins, remain)
	if hours ==0 and days <= 0 then
		rt = string.format("%02d:%02d", mins, remain)
	end
	return rt
end
----------------------------------------------------------------------
-- 创建骨骼节点(fileName=.csb文件)
function Utils:createSkeletonNode(fileName, startIndex, endIndex, loop, frameEventCF)
	local skeletonNode = cc.CSLoader:createNode(fileName..".csb")
	local skeletonAction = cc.CSLoader:createTimeline(fileName..".csb")
	skeletonAction:setTag(1010)
	-- 要在指定的帧给指定的骨骼添加"帧事件",属性内添加一个字符串即可,该字符传将在帧事件回调函数内当做参数传入
	skeletonAction:setFrameEventCallFunc(function(frame)
		if frame and "function" == type(frameEventCF) then
			frameEventCF(frame)
		end
	end)
	skeletonAction:gotoFrameAndPlay(startIndex, endIndex, loop)
	skeletonNode:runAction(skeletonAction)
	return skeletonNode
end
----------------------------------------------------------------------
-- 播放骨骼动画
function Utils:playSkeletonAnimation(skeletonNode, startIndex, endIndex, loop, frameEventCF)
	if nil == skeletonNode then return end
	local skeletonAction = skeletonNode:getActionByTag(1010)
	if nil == skeletonAction then return end
	skeletonAction:stop()
	skeletonAction:setFrameEventCallFunc(function(frame)
		if frame and "function" == type(frameEventCF) then
			frameEventCF(frame)
		end
	end)
	skeletonAction:gotoFrameAndPlay(startIndex, endIndex, loop)
	skeletonAction:startWithTarget(skeletonNode)
end
----------------------------------------------------------------------
-- 创建骨骼节点(fileName=.ExportJson文件)
function Utils:createArmatureNode(fileName, animationName, loop, animationEventCF)
	ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(fileName..".ExportJson")
	local armatureNode = ccs.Armature:create(fileName)
	if armatureNode then
		armatureNode:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementId)
			if "function" == type(animationEventCF) then
				animationEventCF(armatureBack, movementType, movementId)
			end
		end)
		if animationName and loop then
			armatureNode:getAnimation():play(animationName, -1, 1)
		elseif animationName and not loop then
			armatureNode:getAnimation():play(animationName, -1, 0)
		end
	end
	return armatureNode
end
----------------------------------------------------------------------
-- 播放骨骼动画
function Utils:playArmatureAnimation(armatureNode, animationName, loop, animationEventCF)
	if nil == armatureNode then return end
	armatureNode:getAnimation():setMovementEventCallFunc(function(armatureBack, movementType, movementId)
		if "function" == type(animationEventCF) then
			animationEventCF(armatureBack, movementType, movementId)
		end
	end)
	if animationName and loop then
		armatureNode:getAnimation():play(animationName, -1, 1)
	elseif animationName and not loop then
		armatureNode:getAnimation():play(animationName, -1, 0)
	end
end
----------------------------------------------------------------------
-- 创建粒子节点
function Utils:createParticle(plistFile, autoRemove)
	local particle = cc.ParticleSystemQuad:create(plistFile)
	particle:setAutoRemoveOnFinish(autoRemove)
	return particle
end
----------------------------------------------------------------------
-- 获取分享的内容
function Utils:getShareContent()
	local tbShares = LogicTable:getAll("share_tplt")
	return tbShares[math.random(#tbShares)]
end
----------------------------------------------------------------------
-- 延迟执行
function Utils:delayExecute(duration, executeCF, param)
	if "function" ~= type(executeCF) then return end
	local runningScene = cc.Director:getInstance():getRunningScene()
	if nil == runningScene then
		executeCF(param)
		return
	end
	if "number" ~= type(duration) or duration <= 0 then
		duration = 0.001
	end
	runningScene:runAction(cc.Sequence:create({cc.DelayTime:create(duration), cc.CallFunc:create(function()
		executeCF(param)
	end)}))
end
----------------------------------------------------------------------
-- 注册触摸事件:scaleEnabled-开启缩放,soundEnabled-开启声音,touchGap-每次触摸的时间间隔
function Utils:addTouchEvent(widget, callback, scaleEnabled, soundEnabled, touchGap)
	local orignalScale = widget:getScale()
	local function onPressAction(isBegin)
		if not scaleEnabled then return end
		if isBegin then
			widget:setScale(orignalScale*0.9)
		else
			widget:setScale(orignalScale)
		end
	end
	UIManager:registerEvent(widget, function(sender)
		onPressAction(true)
		if soundEnabled then
			AudioMgr:playEffect(2001)
		end
	end, function(sender)
		onPressAction(false)
	end, function(sender)
		onPressAction(false)
	end, callback, nil, nil, touchGap, 0.25)
end
----------------------------------------------------------------------
