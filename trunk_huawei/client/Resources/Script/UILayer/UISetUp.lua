----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-12-31
-- Brief: 设置界面
----------------------------------------------------------------------
UISetUp = {
	csbFile = "SetUp.csb"	--csbFile = "heroItem.csb"
}

function UISetUp:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self:subscribeEvent(EventDef["ED_GAME_INIT"], self.onGameInit)
	
	self.mIsMusicOn = AudioMgr:isMusicEnabled()
	self.mIsEffectOn = AudioMgr:isEffectEnabled()
	--cclog("我有开着吗********",self.mIsMusicOn,self.mIsEffectOn)
	--音乐按钮
	local checkBoxMusic = UIManager:seekNodeByName(ui.root, "CheckBox_music")
	Utils:addTouchEvent(checkBoxMusic, function(sender)
		self.mIsMusicOn = not self.mIsMusicOn
		sender:setBright(self.mIsMusicOn)
		AudioMgr:setMusicEnabled(self.mIsMusicOn)
		if self.mIsMusicOn then
			AudioMgr:playMusic(1001)		-- 主页音乐
		end
	end, true, true, 0)
	checkBoxMusic:setBright(self.mIsMusicOn)
	
	--音效按钮
	local checkBoxEffect = UIManager:seekNodeByName(ui.root, "CheckBox_effect")
	Utils:addTouchEvent(checkBoxEffect, function(sender)
		self.mIsEffectOn = not self.mIsEffectOn
		sender:setBright(self.mIsEffectOn)
		AudioMgr:setEffectEnabled(self.mIsEffectOn)
	end, true, true, 0)
	checkBoxEffect:setBright(self.mIsEffectOn)
	
	--联系客服按钮
	local contactBtn = UIManager:seekNodeByName(ui.root, "Button_contact")
	Utils:addTouchEvent(contactBtn, function(sender)
		UIManager:close(self)
		UIManager:openFront(UIContactService,true)
	end, true, true, 0)
	
	--制作人员按钮
	local staffBtn = UIManager:seekNodeByName(ui.root, "Button_staff")
	Utils:addTouchEvent(staffBtn, function(sender)
		UIManager:close(self)
		UIManager:openFront(UIProductStaff,true)
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	-- 版本号
	local versionLabel = UIManager:seekNodeByName(ui.root, "Text_version")
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

function UISetUp:onGameInit(param)
	cclog("---------------11111 UISetUp",param)
end

