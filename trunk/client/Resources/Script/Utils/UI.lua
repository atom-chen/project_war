----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2015-08-11
-- Brief:	ui manager
----------------------------------------------------------------------
function UIManager()
	local mUITable = {}
	local manager = {}
	function manager:createUI(file, isCCSFile, onTouchCF, target, swallow)
		assert(not mUITable[file], "exist ui ["..file.."] aleady")
		local visibleSize = cc.Director:getInstance():getVisibleSize()
		local node = nil
		if isCCSFile then
			node = cc.CSLoader:createNode(file)
			assert(not tolua.isnull(node), "can't load ui ["..file.."]")
		else
			node = cc.Node:create()
		end
		node:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
		local function onTouch(touch, event)
			if "function" == type(onTouchCF) then
				if "object" == type(target) or "userdata" == type(target) then
					onTouchCF(target, touch, event, event:getEventCode())
				else
					onTouchCF(touch, event, event:getEventCode())
				end
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
		root:addChild(node, 2)	-- add to zOrder 2
		local ui = {file = file, root = root, node = node}
		mUITable[file] = ui
		return ui
	end
	function manager:destroyUI(file)
		local ui = mUITable[file]
		if not ui then
			return
		end
		ui.root:removeFromParent()
		mUITable[file] = nil
	end
	function manager:destroyAllUI()
		for file, ui in pairs(mUITable) do
			ui.root:removeFromParent()
		end
		mUITable = {}
	end
	function manager:getUI(file)
		return mUITable[file]
	end
	return manager
end
----------------------------------------------------------------------
UI = UI or UIManager()
UI.mLayerTable = UI.mLayerTable or {}
----------------------------------------------------------------------
-- open ui
function UI:open(layer, file, isCCSFile, modal, touchCF, parent, param)
	local ui = self:getUI(file)
	if ui then
		return ui
	end
	ui = self:createUI(file, isCCSFile, function(touch, event, eventCode)
		if "function" == type(touchCF) then
			touchCF(touch, event, eventCode)
		end
		if "function" == type(layer.onTouch) then
			layer:onTouch(touch, event, eventCode)
		end
	end, nil, modal)
	if parent then
		parent:addChild(ui.root)
	end
	EventDispatcherHang(layer)
	layer.root = ui.root
	layer.node = ui.node
	if "function" == type(layer.onStart) then
		layer:onStart(ui, param)
	end
	table.insert(self.mLayerTable, layer)
	return ui
end
----------------------------------------------------------------------
-- close single ui
function UI:close(layer, file)
	local ui = self:getUI(file)
	if not ui then
		return false
	end
	if "function" == type(layer.unbind) then
		layer:unbind()
	end
	if "function" == type(layer.onDestroy) then
		layer:onDestroy()
	end
	layer.root = nil
	layer.node = nil
	self:destroyUI(file)
	for key, val in pairs(self.mLayerTable) do
		if layer == val then
			table.remove(self.mLayerTable, key)
			break
		end
	end
	return true
end
----------------------------------------------------------------------
-- close all ui
function UI:closeAll()
	for key, layer in pairs(self.mLayerTable) do
		if "function" == type(layer.unbind) then
			layer:unbind()
		end
		if "function" == type(layer.onDestroy) then
			layer:onDestroy()
		end
		layer.root = nil
		layer.node = nil
	end
	self:destroyAllUI()
	self.mLayerTable = {}
end
----------------------------------------------------------------------
-- update ui per frames
function UI:update(dt)
	for key, layer in pairs(self.mLayerTable) do
		if "function" == type(layer.onUpdate) then
			layer:onUpdate(dt)
		end
	end
end
----------------------------------------------------------------------
-- get latest ui
function UI:getLatest()
	local count = #(self.mLayerTable)
	if 0 == count then
		return nil
	end
	return self.mLayerTable[count]
end
----------------------------------------------------------------------
-- check is ui open
function UI:isOpened(layer)
	if not layer then
		return false
	end
	for key, val in pairs(self.mLayerTable) do
		if layer == val then
			return true
		end
	end
	return false
end
----------------------------------------------------------------------
-- 注册控件事件:widget-控件
-- beganCF-触摸开始回调,moveCF-触摸滑动回调,endCF-触摸结束回调,cancelCF-触摸取消回调,
-- clickCF-单击回调,pressBeganCF-长按开始回调,pressEndCF-长按结束回调,
-- gap-每次按下间隔(0),delay-触发长按间隔(0.25)
function UI:registerEvent(widget, beganCF, moveCF, endCF, cancelCF, clickCF, pressBeganCF, pressEndCF, gap, delay)
	assert(not tolua.isnull(widget) and "function" == type(widget.addTouchEventListener), "not support for none widget type")
	if "number" ~= type(gap) or gap < 0 then
		gap = 0
	end
	if "number" ~= type(delay) or delay < 0 then
		delay = 0.25
	end
	-- 长按状态检测
	local pressStatus = 0	-- 长按状态:0.未按下,1.开始长按,2.长按中
	local function onPressBegin()
		if 0 == pressStatus and "function" == type(pressBeganCF) then
			pressStatus = 1
			local pressAction = cc.Sequence:create(
				cc.DelayTime:create(delay),
				cc.CallFunc:create(function()
					if 1 == pressStatus then
						pressStatus = 2
						pressBeganCF(widget)
					end
				end)
			)
			pressAction:setTag(1010101)
			widget:runAction(pressAction)
		end
	end
	local function onPressEnd()
		local isPressEnd = 2 == pressStatus
		if 1 == pressStatus then
			widget:stopActionByTag(1010101)
		elseif 2 == pressStatus then
			if "function" == type(pressEndCF) then
				pressEndCF(widget)
			end
		end
		pressStatus = 0
		return isPressEnd
	end
	-- 点击事件处理
	local touchBegan = false
	local touchEndClock = 0
	widget:addTouchEventListener(function(sender, eventType)
		local currClock = os.clock()
		if touchEndClock > currClock then
			touchEndClock = currClock - gap
		end
		if ccui.TouchEventType.began == eventType and currClock - touchEndClock >= gap then
			touchBegan = true
			if "function" == type(beganCF) then
				beganCF(widget)
			end
			onPressBegin()
		elseif ccui.TouchEventType.moved == eventType and touchBegan then
			if "function" == type(moveCF) then
				moveCF(widget)
			end
		elseif ccui.TouchEventType.ended == eventType and touchBegan then
			touchBegan = false
			touchEndClock = currClock
			if "function" == type(endCF) then
				endCF(widget)
			end
			if not onPressEnd() then
				if "function" == type(clickCF) then
					clickCF(widget)
				end
			end
		elseif ccui.TouchEventType.canceled == eventType and touchBegan then
			touchBegan = false
			touchEndClock = currClock
			if "function" == type(cancelCF) then
				cancelCF(widget)
			end
			onPressEnd()
		end
	end)
end
----------------------------------------------------------------------