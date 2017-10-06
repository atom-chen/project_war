----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-4
-- Brief: 界面管理器
----------------------------------------------------------------------
-- 内部接口
----------------------------------------------------------------------
local mUITable = {}			-- UI表
-- 创建UI,name-csb文件名
local function createUI(name, onTouchCF, swallow)
	assert(nil == mUITable[name], "exist ui ["..name.."] aleady")
	local node = cc.CSLoader:createNode(name)
	if tolua.isnull(node) or nil == node then return nil end
	-- 触摸事件层
	local function onTouch(touch, event)
		if "function" == type(onTouchCF) then
			onTouchCF(touch, event, event:getEventCode())
		end
		return true
	end
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_ENDED)
	listener:registerScriptHandler(onTouch, cc.Handler.EVENT_TOUCH_CANCELLED)
	if "boolean" == type(swallow) then
		listener:setSwallowTouches(swallow)
	else
		listener:setSwallowTouches(false)
	end
	local root = cc.Layer:create()
	root:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, root)
	root:setTouchEnabled(true)
	local visibleSize = cc.Director:getInstance():getVisibleSize()
	node:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
	root:addChild(node, 2)	-- 添加在第2层,第1层为预留层
	-- 构造ui
	local ui = {}
	ui.name = name			-- csb文件名(string)
	ui.root = root			-- 根节点(Layer)
	ui.node = node			-- csb节点(Node)
	mUITable[name] = ui
	return ui
end
-- 销毁UI,name-csb文件名
local function destroyUI(name)
	local ui = mUITable[name]
	if nil == ui then return end
	ui.root:removeFromParent()
	mUITable[name] = nil
end
-- 获取UI,name-csb文件名
local function getUI(name)
	return mUITable[name]
end
----------------------------------------------------------------------
-- 外部接口
----------------------------------------------------------------------
UIManager = {
	mLayerTable = {},
	mDelayLayerTable = {},
	mCurrDelayLayer = nil,
}
----------------------------------------------------------------------
-- 打开界面(该接口不直接调用,除非你明确知道要干什么,请调用下面三个接口)
function UIManager:open(parent, layer, touchCF, modal, param)
	cclog("open ui "..layer.csbFile)
	local ui = getUI(layer.csbFile)
	if ui then return ui end
	ui = createUI(layer.csbFile, function(touch, event, eventCode)
		if "function" == type(touchCF) then
			touchCF(touch, event, eventCode)
		end
		if "function" == type(layer.onTouch) then
			layer:onTouch(touch, event, eventCode)
		end
	end, modal)
	if nil == ui then return nil end
	if parent then
		parent:addChild(ui.root)
	end
	layer.root = ui.root
	layer.node = ui.node
	-- 给界面添加注册事件函数
	function layer:subscribeEvent(eventId, handler, priority)
		layer.EventHandlerMap = layer.EventHandlerMap or {}
		assert(eventId, "event id must not be nil")
		assert(nil == layer.EventHandlerMap[eventId], "a layer can't subscribe two same event")
		layer.EventHandlerMap[eventId] = function(param)
			for key, val in pairs(layer) do
				if handler == val then
					handler(layer, param)
					return
				end
			end
			handler(param)
		end
		EventDispatcher:subscribe(eventId, layer.EventHandlerMap[eventId], priority)
	end
	-- 给界面添加解注册事件函数
	function layer:unsubscribeEvent(eventId)
		layer.EventHandlerMap = layer.EventHandlerMap or {}
		local handler = layer.EventHandlerMap[eventId]
		if handler then
			EventDispatcher:unsubscribe(eventId, handler)
		end
	end
	-- 执行界面开始函数
	if "function" == type(layer.onStart) then
		layer:onStart(ui, param)
	end
	table.insert(self.mLayerTable, layer)
	return ui
end
-- 打开后端界面(显示在最底层)
function UIManager:openBack(layer, param)
	self:open(Game.NODE_UI_BACK, layer, nil, true, param)
	DataMap:saveDataBase()
end
-- 打开固定界面(显示在中间层,触摸事件可穿透给低层界面)
function UIManager:openFixed(layer, param)
	self:open(Game.NODE_UI_FIXED, layer, nil, false, param)
	DataMap:saveDataBase()
end
-- 打开前端界面(显示在最顶层,并吞吃其底层界面的触摸事件)
function UIManager:openFront(layer, focus, param, showGray, showBounce)
	local ui = self:open(Game.NODE_UI_FRONT, layer, function(touch, event, eventCode)
		if cc.EventCode.ENDED == eventCode and not focus then
			self:close(layer)
		end
	end, true, param)
	if nil == ui then return end
	-- 显示灰色背景
	if "boolean" ~= type(showGray) or showGray then
		local graySprite = cc.Sprite:create("gray_01.png")
		local size = graySprite:getContentSize()
		local visibleSize = cc.Director:getInstance():getVisibleSize()
		graySprite:setScaleX(visibleSize.width/size.width)
		graySprite:setScaleY(visibleSize.height/size.height)
		graySprite:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
		ui.root:addChild(graySprite, 1)
	end
	-- 弹性效果
	if "boolean" ~= type(showBounce) or showBounce then
		local orignalScale = ui.node:getScale()
		ui.node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.12, orignalScale*1.1), cc.ScaleTo:create(0.12, orignalScale)))
	end
	DataMap:saveDataBase()
end
----------------------------------------------------------------------
-- 关闭界面
function UIManager:close(layer)
	cclog("close ui "..layer.csbFile)
	local ui = getUI(layer.csbFile)
	if nil == ui then return false end
	-- 取消注册界面关联的事件
	for eventId, handler in pairs(layer.EventHandlerMap or {}) do
		EventDispatcher:unsubscribe(eventId, handler)
	end
	layer.EventHandlerMap = {}
	-- 执行界面销毁函数
	if "function" == type(layer.onDestroy) then
		layer:onDestroy()
	end
	for key, val in pairs(layer) do
		if "userdata" == type(val) then
			layer[key] = nil
		end
	end
	-- 从内存删除界面
	destroyUI(layer.csbFile)
	for key, val in pairs(self.mLayerTable) do
		if layer.csbFile == val.csbFile then
			table.remove(self.mLayerTable, key)
			break
		end
	end
	DataMap:saveDataBase()
	return true
end
----------------------------------------------------------------------
-- 销毁所有界面
function UIManager:destroyAll()
	for key, layer in pairs(self.mLayerTable) do
		-- 取消注册界面关联的事件
		for eventId, handler in pairs(layer.EventHandlerMap or {}) do
			EventDispatcher:unsubscribe(eventId, handler)
		end
		layer.EventHandlerMap = {}
		-- 执行界面销毁函数
		if "function" == type(layer.onDestroy) then
			layer:onDestroy()
		end
		for k, val in pairs(layer) do
			if "userdata" == type(val) then
				layer[k] = nil
			end
		end
		-- 从内存删除界面
		destroyUI(layer.csbFile)
	end
	self.mLayerTable = {}
end
----------------------------------------------------------------------
-- 更新界面(每帧更新)
function UIManager:update(dt)
	for key, layer in pairs(self.mLayerTable) do
		if "function" == type(layer.onUpdate) then
			layer:onUpdate(dt)
		end
	end
end
----------------------------------------------------------------------
-- 获取最新打开的界面
function UIManager:getLatestLayer()
	local count = #(self.mLayerTable)
	if 0 == count then
		return nil
	end
	return self.mLayerTable[count]
end
----------------------------------------------------------------------
-- 界面是否已打开
function UIManager:isLayerOpen(layer)
	if nil == layer then
		return false
	end
	for key, tmpLayer in pairs(self.mLayerTable) do
		if tmpLayer.csbFile == layer.csbFile then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 添加延迟界面
function UIManager:addDelay(layer, param)
	local delay = {}
	delay.layer = layer
	delay.param = param
	table.insert(self.mDelayLayerTable, delay)
end
----------------------------------------------------------------------
-- 弹出延迟界面
function UIManager:popDelay(layer)
	if self:isLayerOpen(layer) or self:isLayerOpen(self.mCurrDelayLayer) then
		return false
	end
	for key, val in pairs(self.mDelayLayerTable) do
		if nil == layer or val.layer.csbFile == layer.csbFile then
			self.mCurrDelayLayer = val.layer
			self:openFront(val.layer, true, val.param, true)
			table.remove(self.mDelayLayerTable, key)
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 递归搜索子节点
function UIManager:seekNodeByName(parent, childName)
	local child = nil
	parent:enumerateChildren("//"..childName, function(node)
		child = node
	end)
	return child
end
----------------------------------------------------------------------
-- 注册控件事件:widget-控件
-- touchBeganCF-触摸开始回调,touchEndCF-触摸结束回调,touchCancelCF-触摸取消回调,
-- shortClick-单击回调,longTriggerClick-长按触发回调,longEndClick-长按结束回调,
-- pressGap-每次按下间隔(0),pressDelay-触发长按间隔(0.25)
function UIManager:registerEvent(widget, touchBeganCF, touchEndCF, touchCancelCF, shortClick, longTriggerClick, longEndClick, pressGap, pressDelay)
	if tolua.isnull(widget) or nil == widget then return end
	if "number" ~= type(pressGap) then
		pressGap = 0
	end
	if "number" ~= type(pressDelay) then
		pressDelay = 0.25
	end
	-- 长按状态检测
	local longClickStatus = 0	-- 长按状态:0.未按下,1.开始长按,2.长按中
	local function onLongClickBegin()
		if 0 == longClickStatus and "function" == type(longTriggerClick) then
			longClickStatus = 1
			local longAction = cc.Sequence:create(cc.DelayTime:create(pressDelay), cc.CallFunc:create(function()
				if 1 == longClickStatus then
					longClickStatus = 2
					longTriggerClick(widget)
				end
			end))
			longAction:setTag(10101)
			widget:runAction(longAction)
		end
	end
	local function onLongClickEnd()
		if 2 == longClickStatus then
			longClickStatus = 0
			if "function" == type(longEndClick) then
				longEndClick(widget)
			end
			return true
		end
		longClickStatus = 0
		widget:stopActionByTag(10101)
		return false
	end
	-- 点击事件处理
	local touchBegan, touchEndClock = false, 0
	widget:addTouchEventListener(function(sender, eventType)
		local currClock = os.clock()
		if touchEndClock > currClock then
			touchEndClock = currClock - pressGap
		end
		if ccui.TouchEventType.began == eventType and currClock - touchEndClock >= pressGap then
			touchBegan = true
			if "function" == type(touchBeganCF) then
				touchBeganCF(widget)
			end
			onLongClickBegin()
		elseif ccui.TouchEventType.ended == eventType and touchBegan then
			touchBegan, touchEndClock = false, currClock
			if "function" == type(touchEndCF) then
				touchEndCF(widget)
			end
			if not onLongClickEnd() and "function" == type(shortClick) then
				shortClick(widget)
			end
		elseif ccui.TouchEventType.canceled == eventType and touchBegan then
			touchBegan, touchEndClock = false, currClock
			if "function" == type(touchCancelCF) then
				touchCancelCF(widget)
			end
			onLongClickEnd()
		end
	end)
end
----------------------------------------------------------------------
-- 示例代码
--[[
UILogin = {
	csbFile = "Login.csb"
}
function UILogin:onStart(ui, param)
	-- print("================= UILogin onStart")
end
function UILogin:onTouch(touch, event, eventCode)
	-- print("---------------- UILogin onTouch")
end
function UILogin:onUpdate(dt)
	-- print("---------------- UILogin onUpdate")
end
function UILogin:onDestroy()
	-- print("================= UILogin onDestroy")
end
]]--
--[[
UIManager:openFixed(UILogin)
]]--
----------------------------------------------------------------------