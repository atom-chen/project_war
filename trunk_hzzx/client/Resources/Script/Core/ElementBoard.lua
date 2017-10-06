----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 隔板元素
----------------------------------------------------------------------
ElementBoard = class("ElementBoard", Element)

-- 构造函数
function ElementBoard:ctor(image)
	self.super:ctor()
	self.mRow = 0				-- 所在隔板类型表的行索引值
	self.mCol = 0				-- 所在隔板类型表的列索引值
	self:setSprite(cc.Sprite:create(image))
end

-- 设置索引值
function ElementBoard:setCoord(row, col)
	self.mRow = row or self.mRow
	self.mCol = col or self.mCol
end

-- 获取索引值
function ElementBoard:getCoord()
	return {row = self.mRow, col = self.mCol}
end

-- 消除动作
function ElementBoard:clearAction(param, actionEndCF)
	Utils:doCallback(actionEndCF)
	local elementData = self:getData()
	-- 播放特效
	if "nil" ~= elementData.effect then
		local particle = Utils:createParticle(elementData.effect, true)
		particle:setPosition(param.pos)
		param.parent:addChild(particle, G.MAP_ZORDER_EFFECT)
	end
	-- 播放音效
	if elementData.sound > 0 then
		AudioMgr:playEffect(elementData.sound)
	end
end

