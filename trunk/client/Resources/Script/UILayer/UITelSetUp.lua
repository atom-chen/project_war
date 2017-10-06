----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-4-3
-- Brief: 电信的设置界面
----------------------------------------------------------------------
UIDEFINE("UITelSetUp", "TelSetUp.csb")
function UITelSetUp:onStart(ui, param)
	AudioMgr:playEffect(2007)
	
	self.mIsMusicOn = AudioMgr:isMusicEnabled()
	self.mIsEffectOn = AudioMgr:isEffectEnabled()

	--音乐按钮
	local checkBoxMusic = self:getChild("CheckBox_music")
	self:addTouchEvent(checkBoxMusic, function(sender)
		self.mIsMusicOn = not self.mIsMusicOn
		sender:setBright(self.mIsMusicOn)
		AudioMgr:setMusicEnabled(self.mIsMusicOn)
		if self.mIsMusicOn then
			AudioMgr:playMusic(1001)		-- 主页音乐
		end
	end, true, true, 0)
	checkBoxMusic:setBright(self.mIsMusicOn)
	
	--音效按钮
	local checkBoxEffect = self:getChild("CheckBox_effect")
	self:addTouchEvent(checkBoxEffect, function(sender)
		self.mIsEffectOn = not self.mIsEffectOn
		sender:setBright(self.mIsEffectOn)
		AudioMgr:setEffectEnabled(self.mIsEffectOn)
	end, true, true, 0)
	checkBoxEffect:setBright(self.mIsEffectOn)
	
	--联系客服按钮
	local contactBtn = self:getChild("Button_contact")
	self:addTouchEvent(contactBtn, function(sender)
		self:close()
		UIContactService:openFront(true)
	end, true, true, 0)
	
	-- 版本号
	local nativeInfo = json.decode(G.CONFIG["native_info"])
	local resrouceFlag = ""
	if 1 == G.CONFIG["update_type"] then
		resrouceFlag = "(内网)"
	elseif 2 == G.CONFIG["update_type"] then
		resrouceFlag = "(外网)"
	end
	local versionInfo = (nativeInfo["version"] or "0").."."..(nativeInfo["build"] or "0")..resrouceFlag
	local content = LanguageStr("About",versionInfo)
	
	--关于免责声明按钮
	local aboutBtn = self:getChild("Button_about")
	self:addTouchEvent(aboutBtn, function(sender)
		if ChannelProxy:isDianxin() then
			ChannelProxy:showAbout(content)
		else
			self:close()
			UIDisclaimer:openFront(true)
		end
	end, true, true, 0)
	
	--更多按钮
	local moreBtn = self:getChild("Button_more")
	self:addTouchEvent(moreBtn, function(sender)
		ChannelProxy:openMore()
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		self:close()
	end, true, true, 0)
	
	--制作人员按钮
	local staffBtn = self:getChild("Button_staff")
	self:addTouchEvent(staffBtn, function(sender)
		self:close()
		UIProductStaff:openFront(true)
	end, true, true, 0)
	
	if ChannelProxy:isCocos() then	--触控
		if ChannelProxy:isDianxin() then	--更多游戏。免责声明。联系客服。需要三个按钮
			ModelPub:setWidgetVisible(staffBtn,false)
			aboutBtn:setPosition(cc.p(3.29,60.87))
		elseif ChannelProxy:getOperatorType()== 0 then	--要接入 “isSoundOn”(游戏基地)和更多游戏（moreApp）（两个按钮）
			contactBtn:setPosition(cc.p(3.29,139.54))
			moreBtn:setPosition(cc.p(3.29,60.87))
			ModelPub:setWidgetVisible(aboutBtn,false)
			ModelPub:setWidgetVisible(staffBtn,false)
		--elseif ChannelProxy:isLiantong() then
		else								-- 正常只需要一个按钮
			contactBtn:setPosition(cc.p(3.29,103.87))
			ModelPub:setWidgetVisible(aboutBtn,false)
			ModelPub:setWidgetVisible(staffBtn,false)
			ModelPub:setWidgetVisible(moreBtn,false)
		end
	end	
	if "10181" == ChannelProxy:getChannelId() then	--要接入 “isSoundOn”(游戏基地)和更多游戏（moreApp）（两个按钮）
		contactBtn:setPosition(cc.p(3.29,139.54))
		moreBtn:setPosition(cc.p(3.29,60.87))
		ModelPub:setWidgetVisible(aboutBtn,false)
		ModelPub:setWidgetVisible(staffBtn,false)
	end
end

function UITelSetUp:onTouch(touch, event, eventCode)
end

function UITelSetUp:onUpdate(dt)
end

function UITelSetUp:onDestroy()
end

function UITelSetUp:onTouch(touch, event, eventCode)
end
