----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-4-3
-- Brief: 电信的设置界面
----------------------------------------------------------------------
UITelSetUp = {
	csbFile = "TelSetUp.csb"	--csbFile = "heroItem.csb"
}

function UITelSetUp:onStart(ui, param)
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
	
	--关于免责声明按钮
	local aboutBtn = UIManager:seekNodeByName(ui.root, "Button_about")
	Utils:addTouchEvent(aboutBtn, function(sender)
		cclog("免责声明")
		UIManager:close(self)
		UIManager:openFront(UIDisclaimer,true)
	end, true, true, 0)
	
	--更多按钮（功能有待实现？？？？？？？？？？？？？？？？？？）
	local moreBtn = UIManager:seekNodeByName(ui.root, "Button_more")
	Utils:addTouchEvent(moreBtn, function(sender)
		cclog("更多")
		ChannelProxy:openMore()
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
end

function UITelSetUp:onTouch(touch, event, eventCode)
end

function UITelSetUp:onUpdate(dt)
end

function UITelSetUp:onDestroy()
end

function UITelSetUp:onGameInit(param)
	cclog("---------------11111 UISetUp",param)
end

