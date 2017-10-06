----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 投放元素
----------------------------------------------------------------------
ElementThrow = class("ElementThrow", Element)

-- 构造函数
function ElementThrow:ctor(image)
	self.super:ctor()
	self:setSprite(cc.Sprite:create(image))
	self.mVolcanoCD = 0			-- 火山冷却回合(0.活火山;>0.死火山,冷却中)
end

-- 初始化
function ElementThrow:onInit(param)
	if ElementThrowType["replace"] == self:getSubType() then
		local armatureFile = nil
		local extraType = self:getExtraType()
		if ElementThrowReplaceType["wetland"] == extraType then			-- 沼泽地
			armatureFile = "zhaoze"
		elseif ElementThrowReplaceType["volcano_black"] == extraType then	-- 黑色火山
			armatureFile = "heihuoshan"
		elseif ElementThrowReplaceType["volcano_silver"] == extraType then	-- 银色火山
			armatureFile = "lanhuoshan"
		end
		if armatureFile then
			self:setSprite(Utils:createArmatureNode(armatureFile, "idle", true))
		end
	end
end

-- 消除动作
function ElementThrow:clearAction(param, actionEndCF)
	if ElementThrowType["replace"] == self:getSubType() then
		local extraType = self:getExtraType()
		-- 沼泽地
		if ElementThrowReplaceType["wetland"] == extraType then
			MapManager:getComponent("ThrowController"):wetlandCold()
		end
	end
	Utils:doCallback(actionEndCF)
end

-- 受波及
function ElementThrow:onAffect(param)
	if ElementThrowType["replace"] == self:getSubType() then
		local extraType = self:getExtraType()
		-- 黑色火山|银色火山
		if (ElementThrowReplaceType["volcano_black"] == extraType or ElementThrowReplaceType["volcano_silver"] == extraType) then
			if 0 == self.mVolcanoCD then	-- 开始冷却
				self:setSprite(cc.Sprite:create(self:getData().touch_image))
			end
			self.mVolcanoCD = 2			-- 1回合冷却(值=1+冷却回合数)
		end
	end
end

-- 火山是否冷却中
function ElementThrow:isVolcanoCooling()
	return self.mVolcanoCD > 0
end

-- 更新火山冷却回合数
function ElementThrow:updateVolcanoCD()
	if 0 == self.mVolcanoCD then
		return
	end
	self.mVolcanoCD = self.mVolcanoCD - 1
	if 0 == self.mVolcanoCD then	-- 冷却结束
		if ElementThrowType["replace"] == self:getSubType() then
			local armatureFile = nil
			local extraType = self:getExtraType()
			if ElementThrowReplaceType["volcano_black"] == extraType then			-- 黑色火山
				armatureFile = "heihuoshan"
			elseif ElementThrowReplaceType["volcano_silver"] == extraType then		-- 银色火山
				armatureFile = "lanhuoshan"
			end
			if armatureFile then
				self:setSprite(Utils:createArmatureNode(armatureFile, "idle", true))
			end
		end
	end
end
