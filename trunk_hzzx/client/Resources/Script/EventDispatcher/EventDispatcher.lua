----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2013-11-19
-- Brief:	event dispathcer system
----------------------------------------------------------------------
local mEventMap = {}	-- 事件映射表
EventDispatcher = {}
----------------------------------------------------------------------
-- 注册事件,eventId(number或string类型)-事件标识;func(function类型)-事件回调函数;priority(number类型)-触发优先级顺序,值越低,优先级越高
function EventDispatcher:subscribe(eventId, func, priority)
	assert("number" == type(eventId) or "string" == type(eventId), "EventCenter -> subscribe() -> eventId is not number or string, it's type is "..type(eventId))
	assert("function" == type(func), "EventCenter -> subscribe(eventId, func) -> func is not function, it's type is "..type(func))
	local handlers = mEventMap[eventId]
	-- 事件未注册
	if nil == handlers then
		local handlers = {}			-- 构造事件的处理函数集
		table.insert(handlers, {func = func, priority = priority or #handlers})
		mEventMap[eventId] = handlers
		return
	end
	-- 事件已注册
	for key, handler in pairs(handlers) do
		if func == handler.func then	-- 处理函数已注册
			return
		end
	end
	table.insert(mEventMap[eventId], {func = func, priority = priority or #handlers})
	table.sort(mEventMap[eventId], function(a, b) return a.priority < b.priority end)
end
----------------------------------------------------------------------
-- 取消事件注册,eventId(number或string类型)-事件标识;func(function类型)-要取消注册的事件回调函数
function EventDispatcher:unsubscribe(eventId, func)
	assert("number" == type(eventId) or "string" == type(eventId), "EventCenter -> unsubscribe() -> eventId is not number or string, it's type is "..type(eventId))
	local handlers = mEventMap[eventId]
	-- 事件未注册
	if nil == handlers then
		return
	end
	-- 事件已注册
	if nil == func then		-- 移除事件
		mEventMap[eventId] = nil
		return
	end
	-- 移除事件处理函数
	for key, handler in pairs(handlers) do
		if func == handler.func then
			table.remove(mEventMap[eventId], key)
			return
		end
	end
end
----------------------------------------------------------------------
-- 发布事件,eventId(number或string类型)-事件标识;...(任意类型)-参数列表
function EventDispatcher:post(eventId, ...)
	assert("number" == type(eventId) or "string" == type(eventId), "EventCenter -> post() -> eventId is not number or string, it's type is "..type(eventId))
	local handlers = mEventMap[eventId]
	-- 事件未注册
	if nil == handlers then
		return
	end
	-- 事件已注册
	for key, handler in pairs(handlers) do
		handler.func(...)	-- 执行事件对应处理函数
	end
end
----------------------------------------------------------------------