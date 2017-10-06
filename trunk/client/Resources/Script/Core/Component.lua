----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 组件
----------------------------------------------------------------------
Component = class("Component")

-- 构造函数(子类需显示调用父类构造函数,以传参数给父类)
function Component:ctor(name)
	self.component_type_flag = true			-- 组件类型标识
	self.mName = name or self.__cname		-- 组件名
	self.mMaster = nil						-- 宿主对象
	self.mComponentInfoList = {}			-- 子组件信息列表
	self.mSiblingComponentList = {}			-- 同级组件列表
	self.mTouchEnabled = true				-- 触摸启用
	self.mTouchSwallow = false				-- 触摸吞没
	self.mEventHandlerMap = {}				-- 事件处理句柄
end

-- 析构函数(当子类重定义时,需显示调用父类析构函数)
function Component:destroy()
	self.mMaster = nil
	for i, comInfo in pairs(self.mComponentInfoList) do
		comInfo.com:destroy()
	end
	self.mComponentInfoList = {}
	self.mSiblingComponentList = {}
	self.mTouchEnabled = false
	-- 取消注册关联的事件
	for eventId, handler in pairs(self.mEventHandlerMap) do
		EventCenter:unbind(eventId, handler)
	end
end

-- 开始触摸
function Component:onTouchBegan(touch, event, param)
	if not self.mTouchEnabled then return end
	for i, comInfo in pairs(self.mComponentInfoList) do
		comInfo.com:onTouchBegan(touch, event, param)
		if comInfo.com:isTouchSwallow() then
			return
		end
	end
end

-- 移动触摸
function Component:onTouchMoved(touch, event, param)
	if not self.mTouchEnabled then return end
	for i, comInfo in pairs(self.mComponentInfoList) do
		comInfo.com:onTouchMoved(touch, event, param)
		if comInfo.com:isTouchSwallow() then
			return
		end
	end
end

-- 结束触摸
function Component:onTouchEnded(touch, event, param)
	if not self.mTouchEnabled then return end
	for i, comInfo in pairs(self.mComponentInfoList) do
		comInfo.com:onTouchEnded(touch, event, param)
		if comInfo.com:isTouchSwallow() then
			return
		end
	end
end

-- 取消触摸
function Component:onTouchCancelled(touch, event, param)
	if not self.mTouchEnabled then return end
	for i, comInfo in pairs(self.mComponentInfoList) do
		comInfo.com:onTouchCancelled(touch, event, param)
		if comInfo.com:isTouchSwallow() then
			return
		end
	end
end

-- 获取名称
function Component:getName()
	return self.mName
end

-- 获取宿主
function Component:getMaster()
	return self.mMaster
end

-- 添加子组件,priority:值越低,优先级越高
function Component:addComponent(com, priority)
	assert(true == com.component_type_flag, "com must be component type")
	local comName = com:getName()
	assert(comName ~= self.mName, "can't add self '"..comName.."' to be component")
	if self.mMaster then	-- 不可添加宿主为子组件
		local masterName = self.mMaster:getName()
		assert(comName ~= masterName, "can't add master '"..comName.."' to be component")
	end
	for i, comInfo in pairs(self.mComponentInfoList) do
		if comName == comInfo.name then
			assert(nil, "can't repeat add component '"..comName.."'")
		end
		comInfo.com:addSibling(com)
	end
	com.mMaster = self
	local comInfo = {
		name = comName,											-- 组件名
		com = com,												-- 组件
		priority = priority or #self.mComponentInfoList + 1		-- 优先级
	}
	table.insert(self.mComponentInfoList, comInfo)
	table.sort(self.mComponentInfoList, function(a, b) return a.priority < b.priority end)
end

-- 移除子组件
function Component:removeComponent(name)
	for i, comInfo in pairs(self.mComponentInfoList) do
		if name == comInfo.name then
			comInfo.com.mMaster = nil
			table.remove(self.mComponentInfoList, i)
		end
		comInfo.com:removeSibling(name)
	end
end

-- 获取子组件
function Component:getComponent(name)
	for i, comInfo in pairs(self.mComponentInfoList) do
		if name == comInfo.name then
			return comInfo.com
		end
	end
	return nil
end

-- 添加同级组件
function Component:addSibling(com)
	assert(true == com.component_type_flag, "com must be component type")
	local comName = com:getName()
	if self.mSiblingComponentList[comName] then
		return
	end
	if self.mMaster then	-- 不可添加宿主为同级组件
		assert(comName ~= self.mMaster:getName(), "can't add master '"..comName.."' to be sibling")
	end
	self.mSiblingComponentList[comName] = com
	com:addSibling(self)
end

-- 移除同级组件
function Component:removeSibling(name)
	local sibling = self.mSiblingComponentList[name]
	if nil == sibling then
		return
	end
	self.mSiblingComponentList[name] = nil
	sibling:removeSibling(self.mName)
end

-- 获取同级组件
function Component:getSibling(name)
	local sibling = self.mSiblingComponentList[name]
	if sibling then
		return sibling
	end
	if nil == self.mMaster then
		return nil
	end
	return self.mMaster:getComponent(name)
end

-- 设置触摸启用
function Component:setTouchEnabled(enabled)
	self.mTouchEnabled = enabled
end

-- 触摸是否启用
function Component:isTouchEnabled()
	return self.mTouchEnabled
end

-- 设置触摸吞没
function Component:setTouchSwallow(swallow)
	self.mTouchSwallow = swallow
end

-- 触摸是否吞没
function Component:isTouchSwallow()
	return self.mTouchSwallow
end

-- 注册事件函数
function Component:bind(eventId, handler, target, priority)
	assert(nil == self.mEventHandlerMap[eventId], "a component can't bind two same event")
	self.mEventHandlerMap[eventId] = handler
	EventCenter:bind(eventId, self.mEventHandlerMap[eventId], target, priority)
end

