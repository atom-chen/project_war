----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-12-29
-- Brief:	动作集
----------------------------------------------------------------------
Actions = {}
----------------------------------------------------------------------
-- 移动轨迹
function Actions:moveToWithPath(node, posArray, duration, moveToCF, param)
	assert(node, "node is nil")
	local moveToActionArray = {}
	for i, pos in pairs(posArray) do
		table.insert(moveToActionArray, cc.MoveTo:create(duration, cc.vertex2F(pos.x, pos.y)))
	end
	table.insert(moveToActionArray, cc.CallFunc:create(function()
		node:setPosition(posArray[#posArray])
		Utils:doCallback(moveToCF, param)
	end))
	return node:runAction(cc.Sequence:create(moveToActionArray))
end
----------------------------------------------------------------------
-- 贝塞尔曲线运动
function Actions:bezierTo(node, bezierCfg, duration, bezierToCF, param)
	assert(node, "node is nil")
	node:setPosition(bezierCfg[1])
	node:runAction(cc.Sequence:create(cc.BezierTo:create(duration, bezierCfg), cc.CallFunc:create(function()
		node:setPosition(bezierCfg[3])
		Utils:doCallback(bezierToCF, param)
	end)))
end
----------------------------------------------------------------------
-- 延迟动作
function Actions:delayWith(node, delayTime, delayCF, param)
	assert(node, "node is nil")
	if "number" ~= type(delayTime) or delayTime <= 0 then
		delayTime = 0.001
	end
	return node:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function()
		Utils:doCallback(delayCF, param)
	end)))
end
----------------------------------------------------------------------
-- 淡入动作
function Actions:fadeIn(node, duration, fadeInCF, param)
	assert(node, "node is nil")
	if 255 == node:getOpacity() then
		Utils:doCallback(fadeInCF, param)
		return
	end
	node:setCascadeOpacityEnabled(true)
	node:setOpacity(0)
	return node:runAction(cc.Sequence:create(cc.FadeIn:create(duration), cc.CallFunc:create(function()
		Utils:doCallback(fadeInCF, param)
	end)))
end
----------------------------------------------------------------------
-- 淡出动作
function Actions:fadeOut(node, duration, fadeOutCF, param)
	assert(node, "node is nil")
	if 0 == node:getOpacity() then
		Utils:doCallback(fadeOutCF, param)
		return
	end
	node:setCascadeOpacityEnabled(true)
	node:setOpacity(255)
	return node:runAction(cc.Sequence:create(cc.FadeOut:create(duration), cc.CallFunc:create(function()
		Utils:doCallback(fadeOutCF, param)
	end)))
end
----------------------------------------------------------------------
-- 缩放动作
function Actions:scaleFromTo(node, duration, fromScale, toScale, scaleFromToCF, param)
	assert(node, "node is nil")
	node:setScale(fromScale)
	return node:runAction(cc.Sequence:create(cc.ScaleTo:create(duration, toScale), cc.CallFunc:create(function()
		Utils:doCallback(scaleFromToCF, param)
	end)))
end
----------------------------------------------------------------------
-- 掉落一个格子高度
function Actions:dropOneGridHeight(node, dropCF, param)
	if nil == node then return end
	local xPos, yPos = node:getPosition()
	node:setPosition(cc.p(xPos, yPos + G.GRID_HEIGHT + G.GRID_GAP))
	return node:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.MoveTo:create(0.1, cc.vertex2F(xPos, yPos)), cc.CallFunc:create(function()
		node:setPosition(cc.p(xPos, yPos))
		Utils:doCallback(dropCF, param)
	end)))
end
----------------------------------------------------------------------
-- 晃动动画01
function Actions:shakeAction01(node, shakeCF, param)
	if nil == node then return end
	local shakeActionArray = {}
	local duration = 0.17
	-- table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.9, 1.1))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.05, 0.9))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.85, 1.05))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.00, 0.96))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.88, 1.02))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.00, 0.98))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.89, 1.01))
	table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1, 1))
	table.insert(shakeActionArray, cc.DelayTime:create(1))
	table.insert(shakeActionArray, cc.CallFunc:create(function()
		Utils:doCallback(shakeCF, param)
	end))
	node:stopAllActions()
	return node:runAction(cc.Sequence:create(shakeActionArray))
end
----------------------------------------------------------------------
-- 晃动动画02
function Actions:shakeAction02(node, shakeCF, param)
	if nil == node then return end
	local shakeActionArray = {}
	local duration = 0.17
	table.insert(shakeActionArray, cc.MoveBy:create(0.05, cc.p(0, -10)))
	table.insert(shakeActionArray, cc.MoveBy:create(0.05, cc.p(0, 10)))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration + 0.04, 1.1, 0.9))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration + 0.03, 0.92, 1.08))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration + 0.02, 1.06, 0.94))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration + 0.01, 0.96, 1.04))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.02, 0.98))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.99, 1.01))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1, 1))
    table.insert(shakeActionArray, cc.DelayTime:create(1))
	table.insert(shakeActionArray, cc.CallFunc:create(function()
		Utils:doCallback(shakeCF, param)
	end))
	node:stopAllActions()
	return node:runAction(cc.Sequence:create(shakeActionArray))
end
----------------------------------------------------------------------
-- 晃动动画03
function Actions:shakeAction03(node, shakeCF, param)
	if nil == node then return end
	local shakeActionArray = {}
	local duration = 0.10
    table.insert(shakeActionArray, cc.ScaleTo:create(duration + 0.02, 1.2, 0.8))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration + 0.15, 0.9, 1.1))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration + 0.01, 1.0, 0.9))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration + 0.05, 0.9, 1.1))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1.02, 0.98))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration, 0.99, 1.01))
    table.insert(shakeActionArray, cc.ScaleTo:create(duration, 1, 1))
	table.insert(shakeActionArray, cc.CallFunc:create(function()
		Utils:doCallback(shakeCF, param)
	end))
	node:stopAllActions()
	return node:runAction(cc.Sequence:create(shakeActionArray))
end
----------------------------------------------------------------------
-- 场景晃动
function Actions:shakeAction04(node)
	if true then return end
	if nil == node then return end
	local shakeLength = 15
	local xPos, yPos = node:getPosition()
	local shakeActionArray = {}
	table.insert(shakeActionArray, cc.EaseExponentialOut:create(cc.MoveTo:create(0.03, cc.p(xPos + shakeLength, yPos))))
	table.insert(shakeActionArray, cc.EaseExponentialOut:create(cc.MoveTo:create(0.03, cc.p(xPos, yPos + shakeLength))))
	table.insert(shakeActionArray, cc.EaseExponentialOut:create(cc.MoveTo:create(0.03, cc.p(xPos - shakeLength, yPos))))
	table.insert(shakeActionArray, cc.EaseExponentialOut:create(cc.MoveTo:create(0.03, cc.p(xPos, yPos - shakeLength))))
	table.insert(shakeActionArray, cc.EaseExponentialOut:create(cc.MoveTo:create(0.02, cc.p(xPos, yPos))))
	return node:runAction(cc.Sequence:create(shakeActionArray))
end
----------------------------------------------------------------------
-- 缩放动作01
function Actions:scaleAction01(node, targetScale)
	if nil == node then return end
	local oriScale = node:getScale()
	node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.12, targetScale), cc.ScaleTo:create(0.1, oriScale)))
end
----------------------------------------------------------------------
-- 缩放动作02
function Actions:scaleAction02(node, targetScale)
	if nil == node then return end
	local oriScale = node:getScale()
	node:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.ScaleTo:create(0.4, targetScale), cc.ScaleTo:create(0.4, oriScale))))
end
----------------------------------------------------------------------
-- 缩放动作03
function Actions:scaleAction03(node)
	if nil == node then return end
	local xPos, yPos = node:getPosition()
	if xPos > G.VISIBLE_SIZE.width/2 then
		xPos = xPos - G.GRID_WIDTH
	elseif xPos < G.VISIBLE_SIZE.width/2 then
		xPos = xPos + G.GRID_WIDTH
	end
	local oriScale = node:getScale()
	node:runAction(cc.ScaleTo:create(1.5, oriScale*1.3))
	node:runAction(cc.Sequence:create(cc.MoveTo:create(1.5, cc.p(xPos, yPos + G.GRID_HEIGHT)),cc.CallFunc:create(function()
		node:removeFromParent()
	end)))
end
----------------------------------------------------------------------
-- 缩放动作04
function Actions:scaleAction04(node, internal)
	if nil == node then return end
	local action = cc.Sequence:create(cc.ScaleTo:create(internal/5, 0.9, 0.9), cc.ScaleTo:create(internal/5, 1.0, 1.0))
	node:stopAllActions()
	node:runAction(cc.RepeatForever:create(action))
end
----------------------------------------------------------------------
-- 移动缩放动作01
function Actions:moveScaleAction01(node, pos)
	if nil == node then return end
	node:setOpacity(255)
	
	local action1 = cc.MoveTo:create(0.2, cc.vertex2F(pos.x, pos.y + 170))
	node:runAction(cc.Speed:create(action1,1.0))

	node:runAction(cc.Sequence:create(
			cc.CallFunc:create(function()
				local action2 = cc.MoveTo:create(0.8, cc.vertex2F(pos.x, pos.y + 185))
				node:runAction(cc.Speed:create(action2,1.0))
	end)))	

	node:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),
			cc.FadeOut:create(0.1),
			cc.CallFunc:create(function()
				node:removeFromParent()
	end)))	
end
----------------------------------------------------------------------
-- 移动缩放动作02
function Actions:moveScaleAction02(node, pos)
	if nil == node then return end
	node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3, 1.2), cc.ScaleTo:create(0.4, 0.8)))
	node:runAction(cc.Sequence:create(cc.MoveTo:create(0.7, cc.vertex2F(pos.x, pos.y)), cc.CallFunc:create(function()
		node:removeFromParent()
	end)))
end
----------------------------------------------------------------------
-- 移动缩放动作03
function Actions:moveScaleAction03(node, pos)
	if nil == node then return end
	node:runAction(cc.ScaleTo:create(0.3, 0.4))
	node:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.vertex2F(pos.x, pos.y)), cc.CallFunc:create(function()
		node:removeFromParent()
	end)))
end
----------------------------------------------------------------------

