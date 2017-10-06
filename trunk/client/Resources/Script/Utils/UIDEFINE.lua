----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2015-08-11
-- Brief:	ui define
----------------------------------------------------------------------
UI = UI or UIManager()
UI.mDelayLayerTable = UI.mDelayLayerTable or {}
UI.mCurrDelayLayer = UI.mCurrDelayLayer or nil
UI.mFrontGrayTable = UI.mFrontGrayTable or {}
----------------------------------------------------------------------
-- 清空界面
function UICLEAR()
	UI:closeAll()
	UI.mDelayLayerTable = {}
	UI.mCurrDelayLayer = nil
	UI.mFrontGrayTable = {}
end
----------------------------------------------------------------------
-- 更新界面
function UIUPDATE(dt)
	if "table" == type(UI) and "function" == type(UI.update) then
		UI:update(dt)
	end
end
----------------------------------------------------------------------
-- 定义界面
function UIDEFINE(className, fileName)
	assert("string" == type(className), "not support for className type '"..type(className).."'")
	assert(string.len(className) > 0, "not support for empty className")
	_G[className] = _G[className] or {}
	local cls = _G[className]
	cls._className = className
	if "string" == type(fileName) and string.len(fileName) > 0 then
		cls._fileName = fileName
	else
		cls._fileName = className
	end
	-- 打开底层界面(显示在底层)
	function cls:openBack(param)
		if UI:isOpened(cls) then
			return
		end
		print("open back ui >>> className: "..cls._className..", fileName: "..cls._fileName)
		cls._children = {}
		UI:open(cls, cls._fileName, string.find(cls._fileName, ".csb"), false, nil, Game.NODE_UI_BACK, param)
		DataMap:saveDataBase()
	end
	-- 打开中间界面(显示在中间层,触摸事件可穿透给低层界面)
	function cls:openMiddle(param)
		if UI:isOpened(cls) then
			return
		end
		print("open middle ui >>> className: "..cls._className..", fileName: "..cls._fileName)
		cls._children = {}
		UI:open(cls, cls._fileName, string.find(cls._fileName, ".csb"), false, nil, Game.NODE_UI_MIDDLE, param)
		DataMap:saveDataBase()
	end
	-- 打开上层界面(显示在上层,并吞吃低层界面的触摸事件)
	function cls:openFront(focus, param, showGray, showBounce)
		if UI:isOpened(cls) then
			return
		end
		print("open front ui >>> className: "..cls._className..", fileName: "..cls._fileName)
		cls._children = {}
		local ui = UI:open(cls, cls._fileName, string.find(cls._fileName, ".csb"), true, function(touch, event, eventCode)
			if cc.EventCode.ENDED == eventCode and not focus then
				cls:close()
			end
		end, Game.NODE_UI_FRONT, param)
		-- 显示灰色背景
		if "boolean" ~= type(showGray) or showGray then
			local graySprite = cc.Sprite:create("gray_01.png")
			local size = graySprite:getContentSize()
			local visibleSize = cc.Director:getInstance():getVisibleSize()
			graySprite:setScale(visibleSize.width/size.width, visibleSize.height/size.height)
			graySprite:setPosition(cc.p(visibleSize.width/2, visibleSize.height/2))
			ui.root:addChild(graySprite, 1)
			-- 灰色背景管理
			local length = #UI.mFrontGrayTable
			if length > 0 then
				UI.mFrontGrayTable[length].sprite:setVisible(false)
			end
			table.insert(UI.mFrontGrayTable, {name = cls._className, sprite = graySprite})
		end
		-- 弹性效果
		if "boolean" ~= type(showBounce) or showBounce then
			local orignalScale = ui.node:getScale()
			ui.node:runAction(cc.Sequence:create(cc.ScaleTo:create(0.12, orignalScale*1.1), cc.ScaleTo:create(0.12, orignalScale)))
		end
		DataMap:saveDataBase()
	end
	-- 打开顶层界面(显示在顶层,触摸事件可穿透给低层界面)
	function cls:openTop(param)
		if UI:isOpened(cls) then
			return
		end
		print("open top ui >>> className: "..cls._className..", fileName: "..cls._fileName)
		cls._children = {}
		UI:open(cls, cls._fileName, string.find(cls._fileName, ".csb"), false, nil, Game.NODE_UI_TOP, param)
		DataMap:saveDataBase()
	end
	-- 关闭界面
	function cls:close()
		if not UI:isOpened(cls) then
			return
		end
		print("close ui <<< className: "..cls._className..", fileName: "..cls._fileName)
		UI:close(cls, cls._fileName)
		for key, val in pairs(cls) do
			if "function" ~= type(val) and "_className" ~= key and "_fileName" ~= key then
				cls[key] = nil
			end
		end
		cls._children = {}
		-- 灰色背景管理
		for key, val in pairs(UI.mFrontGrayTable) do
			if val.name == cls._className then
				table.remove(UI.mFrontGrayTable, key)
				break
			end
		end
		local length = #UI.mFrontGrayTable
		if length > 0 then
			UI.mFrontGrayTable[length].sprite:setVisible(true)
		end
		DataMap:saveDataBase()
	end
	-- 注册触摸事件:scaleEnabled-开启缩放,soundEnabled-开启声音,touchGap-每次触摸的时间间隔
	function cls:addTouchEvent(widget, callback, scaleEnabled, soundEnabled, touchGap)
		if tolua.isnull(widget) or "function" ~= type(callback) then
			return
		end
		local orignalScale = widget:getScale()
		local function onPressAction(scale)
			if not scaleEnabled then
				return
			end
			widget:setScale(orignalScale*(scale or 1))
		end
		UI:registerEvent(widget, function(sender)
			onPressAction(0.9)
			if soundEnabled then
				AudioMgr:playEffect(2001)
			end
		end, function(sender)
		end, function(sender)
			onPressAction(1)
		end, function(sender)
			onPressAction(1)
		end, function(sender)
			callback(sender)
		end, nil, nil, touchGap, 0.25)
	end
	-- 获取子节点
	function cls:getChild(childName)
		if not tolua.isnull(cls._children[childName]) then
			return cls._children[childName]
		end
		local function getChildImpl(node)
			if tolua.isnull(node) then
				return nil
			end
			for key, child in pairs(node:getChildren()) do
				local name = child:getName()
				cls._children[name] = child
				if childName == name then
					return child
				end
				child = getChildImpl(child)
				if not tolua.isnull(child) then
					return child
				end
			end
		end
		return getChildImpl(cls.root)
		-- cls.node:enumerateChildren("//"..childName, function(node)
			-- cls._children[childName] = node
		-- end)
	end
end
----------------------------------------------------------------------
-- 添加延迟界面
function UIDELAYPUSH(layer, param, focus, showGray, showBounce)
	local delay = {}
	delay.layer = layer
	delay.param = param
	delay.focus = focus
    delay.show_gray = showGray
    delay.show_bounce = showBounce
	table.insert(UI.mDelayLayerTable, delay)
end
----------------------------------------------------------------------
-- 弹出延迟界面
function UIDELAYPOP(layer)
	if UI:isOpened(layer) or UI:isOpened(UI.mCurrDelayLayer) then
		return false
	end
	for key, delay in pairs(UI.mDelayLayerTable) do
		if nil == layer or layer == delay.layer then
			UI.mCurrDelayLayer = delay.layer
			delay.layer:openFront(delay.focus, delay.param, delay.show_gray, delay.show_bounce)
			table.remove(UI.mDelayLayerTable, key)
			return true
		end
	end
	UI.mCurrDelayLayer = nil
	return false
end
----------------------------------------------------------------------