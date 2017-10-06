----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 连线特效
----------------------------------------------------------------------
EffectLine = class("EffectLine")

-- 构造函数
function EffectLine:ctor(startCoord, startPos, endCoord, endPos, parent)
	if (math.abs(startCoord.row - endCoord.row) > 1 or math.abs(startCoord.col - endCoord.col) > 1) then
		return
	end
	-- 计算连线位置,旋转
	local linePos, lineRotationX, lineRotationY = nil, 0, 0
	if startCoord.row == endCoord.row and startCoord.col > endCoord.col then			-- e在s正左方
		linePos = cc.p(startPos.x - (startPos.x - endPos.x)/2, startPos.y)
		lineRotationX = 90
		lineRotationY = 90
	elseif startCoord.row == endCoord.row and startCoord.col < endCoord.col then		-- e在s正右方
		linePos = cc.p(startPos.x + (endPos.x - startPos.x)/2, startPos.y)
		lineRotationX = 270
		lineRotationY = 270
	elseif startCoord.row > endCoord.row and startCoord.col == endCoord.col then		-- e在s正上方
		linePos = cc.p(startPos.x, startPos.y + (endPos.y - startPos.y)/2)
		lineRotationX = 180
		lineRotationY = 180
	elseif startCoord.row < endCoord.row and startCoord.col == endCoord.col then		-- e在s正下方
		linePos = cc.p(startPos.x, startPos.y - (startPos.y - endPos.y)/2)
		lineRotationX = 0
		lineRotationY = 0
	elseif startCoord.row > endCoord.row and startCoord.col > endCoord.col then			-- e在s左上角
		linePos = cc.p(startPos.x - (startPos.x - endPos.x)/2, startPos.y + (endPos.y - startPos.y)/2)
		lineRotationX = 135
		lineRotationY = 135
	elseif startCoord.row > endCoord.row and startCoord.col < endCoord.col then			-- e在s右上角
		linePos = cc.p(startPos.x + (endPos.x - startPos.x)/2, startPos.y + (endPos.y - startPos.y)/2)
		lineRotationX = 225
		lineRotationY = 225
	elseif startCoord.row < endCoord.row and startCoord.col > endCoord.col then			-- e在s左下角
		linePos = cc.p(startPos.x - (startPos.x - endPos.x)/2, startPos.y - (startPos.y - endPos.y)/2)
		lineRotationX = 45
		lineRotationY = 45
	elseif startCoord.row < endCoord.row and startCoord.col < endCoord.col then			-- e在s右下角
		linePos = cc.p(startPos.x + (endPos.x - startPos.x)/2, startPos.y - (startPos.y - endPos.y)/2)
		lineRotationX = 315
		lineRotationY = 315
	end
	--
	self.line_image = "line_001.png"
	-- 创建连线
	local lineSprite = cc.Sprite:create(self.line_image)
	lineSprite:setPosition(linePos)
	lineSprite:setRotationSkewX(lineRotationX)
	lineSprite:setRotationSkewY(lineRotationY)
	parent:addChild(lineSprite, G.MAP_ZORDER_LINE)
	-- 着色器
	local glProgramState = Utils:createShader(lineSprite, "common.vsh", "LightLineRender.fsh")
	glProgramState:setUniformFloatEx("offset", 0.1)
	local t = 0
	lineSprite:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.0002), cc.CallFunc:create(function()
		t = t + 1
		if 50 == t then
			t = 0
		end
		glProgramState:setUniformFloatEx("offset", t/50)
	end))))
	lineSprite:setGLProgramState(glProgramState)
	--	
	self.sprite = lineSprite
end

-- 销毁函数
function EffectLine:destroy()
	if self.sprite then
		self.sprite:removeFromParent()
		self.sprite = nil
	end
end

-- 设置粗
function EffectLine:setThick(thickLevel)
	if 1 == thickLevel then
		self.line_image = "line_001.png"
	elseif 2 == thickLevel then
		self.line_image = "line_001.png"
	elseif 3 == thickLevel then
		self.line_image = "line_001.png"
	else	-- thickLevel > 3
		self.line_image = "line_001.png"
	end
end

