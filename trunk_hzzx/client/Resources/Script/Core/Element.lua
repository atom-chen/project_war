----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 元素
----------------------------------------------------------------------
Element = class("Element")

local function toBoolean(val)
	if "boolean" == type(val) then return val end
	if "number" == type(val) then
		if val > 0 then return true else return false end
	end
	assert(nil, "Element -> toBoolean() not support "..type(val))
end

-- 构造函数
function Element:ctor()
	self.mData = nil						-- 元素数据
	self.mType = 0							-- 元素类型,对应:ElementType
	self.mSubType = 0						-- 元素子类型,依赖:mType
	self.mExtraType = 0						-- 元素附加类型,依赖:mSubType
	self.mCanTouch = false					-- 元素是否可触摸
	self.mCanConnect = false				-- 元素是否可连接
	self.mCanDrop = false					-- 元素是否可掉落
	self.mCanClear = false					-- 元素是否可消除
	self.mCanReset = false					-- 元素是否可重置(重新排列)
	self.mCanChange = false					-- 元素是否可变换(类型变换)
	self.mSprite = nil						-- 元素精灵节点(cc.Sprite)
	self.mDoingClear = false				-- 是否在执行清除操作
end

-- 销毁函数
function Element:destroy()
	if self.mSprite then
		self.mSprite:removeFromParent()
		self.mSprite = nil
	end
end

-- 设置元素数据
function Element:setData(data)
	self.mData = data
end

-- 获取元素数据
function Element:getData()
	return self.mData
end

-- 设置元素类型
function Element:setType(typeValue)
	assert("number" == type(typeValue), "Element:setType() not support "..type(typeValue))
	self.mType = typeValue
end

-- 获取元素类型
function Element:getType()
	return self.mType
end

-- 设置元素子类型
function Element:setSubType(subType)
	assert("number" == type(subType), "Element:setSubType() not support "..type(subType))
	self.mSubType = subType
end

-- 获取元素子类型
function Element:getSubType()
	return self.mSubType
end

-- 设置元素附加类型
function Element:setExtraType(extraType)
	assert("number" == type(extraType), "Element:setExtraType() not support "..type(extraType))
	self.mExtraType = extraType
end

-- 获取元素附加类型
function Element:getExtraType()
	return self.mExtraType
end

-- 设置元素是否可触摸
function Element:setCanTouch(canTouch)
	self.mCanTouch = toBoolean(canTouch)
end

-- 元素是否可触摸
function Element:isCanTouch()
	return self.mCanTouch
end

-- 设置元素是否可连接
function Element:setCanConnect(canConnect)
	self.mCanConnect = toBoolean(canConnect)
end

-- 元素是否可连接
function Element:isCanConnect()
	return self.mCanConnect
end

-- 设置元素是否可掉落
function Element:setCanDrop(canDrop)
	self.mCanDrop = toBoolean(canDrop)
end

-- 元素是否可掉落
function Element:isCanDrop()
	return self.mCanDrop
end

-- 设置元素是否可消除
function Element:setCanClear(canClear)
	self.mCanClear = toBoolean(canClear)
end

-- 元素是否可消除
function Element:isCanClear()
	return self.mCanClear
end

-- 设置元素是否可重置
function Element:setCanReset(canReset)
	self.mCanReset = toBoolean(canReset)
end

-- 元素是否可重置
function Element:isCanReset()
	return self.mCanReset
end

-- 设置元素是否可变换
function Element:setCanChange(canChange)
	self.mCanChange = toBoolean(canChange)
end

-- 元素是否可变换
function Element:isCanChange()
	return self.mCanChange
end

-- 设置表现精灵
function Element:setSprite(sprite)
	if self.mSprite then
		local parent = self.mSprite:getParent()
		local anchorPoint = self.mSprite:getAnchorPoint()
		local xPos, yPos = self.mSprite:getPosition()
		self:destroy()
		sprite:setAnchorPoint(anchorPoint)
		sprite:setPosition(cc.p(xPos, yPos))
		if parent then
			parent:addChild(sprite)
		end
	end
	self.mSprite = sprite
end

-- 获取表现精灵
function Element:getSprite()
	return self.mSprite
end

-- 执行消除
function Element:clear(param, actionBeginCF, actionEndCF)
	if not self.mCanClear or nil == self.mSprite or self.mDoingClear then
		return
	end
	self.mDoingClear = true
	self:destroy()
	if "function" == type(actionBeginCF) then
		actionBeginCF()
	end
	local hasExecuteActionEndCF = false
	self:clearAction(param, function()
		if hasExecuteActionEndCF then
			return
		end
		hasExecuteActionEndCF = true
		self.mDoingClear = false
		if "function" == type(actionEndCF) then
			actionEndCF()
		end
	end)
end

-- 消除动作(内部调用),类似虚函数,子类若需要,则重写此函数
function Element:clearAction(param, actionEndCF)
	if "function" == type(actionEndCF) then
		actionEndCF()
	end
end

-- 初始化,类似虚函数,子类若需要,则重写此函数
function Element:onInit(param)
end

-- 受波及,类似虚函数,子类若需要,则重写此函数
function Element:onAffect(param)
end

-- 进入聚焦状态,类似虚函数,子类若需要,则重写此函数
function Element:onFocusEnter(param)
end

-- 退出聚焦状态,类似虚函数,子类若需要,则重写此函数
function Element:onFocusExit(param)
end

-- 进入激活状态,类似虚函数,子类若需要,则重写此函数
function Element:onActiveEnter(param)
end

-- 退出激活状态,类似虚函数,子类若需要,则重写此函数
function Element:onActiveExit(param)
end

