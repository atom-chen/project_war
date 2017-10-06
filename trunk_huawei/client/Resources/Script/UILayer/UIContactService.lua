----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-26
-- Brief: 联系客服界面
----------------------------------------------------------------------
UIContactService = {
	csbFile = "ContactService.csb"
}

function UIContactService:onStart(ui, param)
	AudioMgr:playEffect(2007)
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	--qq
	local qqText = UIManager:seekNodeByName(ui.root, "Text_qq_l")
	qqText:setString(LanguageStr("CONTACT_QQ"))
	--web
	local webText = UIManager:seekNodeByName(ui.root, "Text_web_l")
	webText:setString(LanguageStr("CONTACT_WEB"))
	--email
	local emailText = UIManager:seekNodeByName(ui.root, "Text_email_1")
	emailText:setString(LanguageStr("CONTACT_EMAIL"))
	--tel
	local telText = UIManager:seekNodeByName(ui.root, "Text_tel_l")
	telText:setString(LanguageStr("CONTACT_TEL"))
end

function UIContactService:onTouch(touch, event, eventCode)
end

function UIContactService:onUpdate(dt)
end

function UIContactService:onDestroy()
end


