----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2015-02-02
-- Brief:	命令模块
----------------------------------------------------------------------
Command = {}

function Command:init(parent)
	local textField = ccui.TextField:create()
	textField:setFontSize(42)
	textField:setTextColor(cc.c4b(255, 255, 255, 0))
	textField:setPlaceHolderColor(cc.c4b(255, 255, 255, 0))
	textField:setPlaceHolder("input cmd here")
	textField:setAnchorPoint(cc.p(0.5, 0))
	textField:setPosition(cc.p(G.VISIBLE_SIZE.width/2, 10))
	textField:setVisible(false)
	parent:addChild(textField, 8888)
	-- 事件监听
	local function onKeyboardPressed(keyCode, event)
		if 6 == keyCode then		-- ESC,关闭命令框
			textField:setVisible(false)
		elseif 35 == keyCode then	-- 回车,执行命令
			if textField:isVisible() then
				-- 命令如:"Command.lua","item_tplt.csv","grid_001.csv false"
				local strText = textField:getString()
				local strTable = CommonFunc:stringSplit(strText, " ")
				local name, ext = CommonFunc:stripFileName(strTable[1] or strText)
				if "" == name or "" == ext then
					return
				end
				if ".lua" == ext then		-- 重新加载lua
					reload(name..ext)
				elseif ".csv" == ext then	-- 重新加载csv
					if "false" == strTable[2] then
						LogicTable:reloadCsv(name, false)
					else
						LogicTable:reloadCsv(name, true)
					end
				end
			end
		elseif 47 == keyCode then	-- F1,打开命令框
			textField:setVisible(true)
		end
	end
	local listener = cc.EventListenerKeyboard:create()
	listener:registerScriptHandler(onKeyboardPressed, cc.Handler.EVENT_KEYBOARD_PRESSED)
	cc.Director:getInstance():getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, textField)
end

return Command
