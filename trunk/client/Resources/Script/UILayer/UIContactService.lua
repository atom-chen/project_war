----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-26
-- Brief: 联系客服界面
----------------------------------------------------------------------
UIDEFINE("UIContactService", "ContactService.csb")
function UIContactService:onStart(ui, param)
	AudioMgr:playEffect(2007)
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		self:close()
	end, true, true, 0)
	--qq
	local qqText = self:getChild("Text_qq_l")
	qqText:setString(LanguageStr("CONTACT_QQ"))
	--web
	local webText = self:getChild("Text_web_l")
	webText:setString(LanguageStr("CONTACT_WEB"))
	--email
	local emailText = self:getChild("Text_email_1")
	emailText:setString(LanguageStr("CONTACT_EMAIL"))
	--tel
	local telText = self:getChild("Text_tel_l")
	telText:setString(LanguageStr("CONTACT_TEL"))
	-- web Image
	local webImage = self:getChild("Image_14")
	--触控的基地不显示网站
	if ChannelProxy:isCocos() or "10181" == ChannelProxy:getChannelId() then
		webImage:setVisible(false)
		webText:setVisible(false)
	end
end

function UIContactService:onTouch(touch, event, eventCode)
end

function UIContactService:onUpdate(dt)
end

function UIContactService:onDestroy()
end


