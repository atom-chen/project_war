----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-4
-- Brief: 消息框
----------------------------------------------------------------------
UIDEFINE("UIMessageBox", "MessageBox.csb")
function UIMessageBox:onStart(ui, param)
	AudioMgr:playEffect(2007)
	local btnOk = self:getChild("Button_ok")
	self:addTouchEvent(btnOk, function(sender)
		self:close()
	end, true, true, 0)
end

function UIMessageBox:onTouch(touch, event, eventCode)
end

function UIMessageBox:onUpdate(dt)
end

function UIMessageBox:onDestroy()
end
