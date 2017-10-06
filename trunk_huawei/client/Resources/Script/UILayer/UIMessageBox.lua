----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-4
-- Brief: 消息框
----------------------------------------------------------------------
UIMessageBox = {
	csbFile = "MessageBox.csb"
}

function UIMessageBox:onStart(ui, param)
	AudioMgr:playEffect(2007)
	local btnOk = UIManager:seekNodeByName(ui.root, "Button_ok")
	Utils:addTouchEvent(btnOk, function(sender)
		UIManager:close(self)
	end, true, true, 0)
end

function UIMessageBox:onTouch(touch, event, eventCode)
end

function UIMessageBox:onUpdate(dt)
end

function UIMessageBox:onDestroy()
end
