----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-4-03
-- Brief: 关于免责声明界面
----------------------------------------------------------------------
UIDisclaimer = {
	csbFile = "Disclaimer.csb"	--csbFile = "heroItem.csb"
}

function UIDisclaimer:onStart(ui, param)
	--滚动条
	local ScrollView_1 = UIManager:seekNodeByName(ui.root, "ScrollView_1")
	--Utils:addTouchEvent(scrollView, function(sender)
	
	--end, true, true, 0)	
	
	--文字
	local scrollText = UIManager:seekNodeByName(ui.root, "scrollText")	--ccui.Helper:seekWidgetByName(ui.root, "scrollText") --
	print(ScrollView_1,scrollText)
	if nil ~= scrollText then
		scrollText:setString(LanguageStr("About",""))
	end
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
end

function UIDisclaimer:onTouch(touch, event, eventCode)
end

function UIDisclaimer:onUpdate(dt)
end

function UIDisclaimer:onDestroy()
end

function UIDisclaimer:onGameInit(param)
	cclog("---------------11111 UISetUp",param)
end

