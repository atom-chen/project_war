----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-12-31
-- Brief: 设置界面
----------------------------------------------------------------------
UIDEFINE("UISetUp", "SetUp.csb")
function UISetUp:onStart(ui, param)
	AudioMgr:playEffect(2007)
	
	self.mIsMusicOn = AudioMgr:isMusicEnabled()
	self.mIsEffectOn = AudioMgr:isEffectEnabled()
	--cclog("我有开着吗********",self.mIsMusicOn,self.mIsEffectOn)
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
	
	--制作人员按钮
	local staffBtn = self:getChild("Button_staff")
	self:addTouchEvent(staffBtn, function(sender)
		self:close()
		UIProductStaff:openFront(true)
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		self:close()
	end, true, true, 0)
	-- 版本号
	local versionLabel = self:getChild("Text_version")
	local nativeInfo = json.decode(G.CONFIG["native_info"])
	local resrouceFlag = ""
	if 1 == G.CONFIG["update_type"] then
		resrouceFlag = "(内网)"
	elseif 2 == G.CONFIG["update_type"] then
		resrouceFlag = "(外网)"
	end
	versionLabel:setString(LanguageStr("VERSION")..(nativeInfo["version"] or "0").."."..(nativeInfo["build"] or "0")..resrouceFlag)
end

function UISetUp:onTouch(touch, event, eventCode)
end

function UISetUp:onUpdate(dt)
end

function UISetUp:onDestroy()
end

