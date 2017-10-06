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
	-- 创建连线
	local frameNameList = {}
	for i=1, 24 do
		table.insert(frameNameList, string.format("line_%03d.png", i))
	end
	local lineSprite = Animations:create("line_effect.plist", frameNameList, 1/30, nil)
	lineSprite:setPosition(linePos)
	lineSprite:setRotationSkewX(lineRotationX)
	lineSprite:setRotationSkewY(lineRotationY)
	parent:addChild(lineSprite, G.MAP_ZORDER_LINE)
	self.sprite = lineSprite
end

-- 销毁函数
function EffectLine:destroy()
	if self.sprite then
		self.sprite:removeFromParent()
		self.sprite = nil
	end
end

