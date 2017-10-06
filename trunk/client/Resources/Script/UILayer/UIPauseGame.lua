----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-11
-- Brief: 战斗失败界面
----------------------------------------------------------------------
UIDEFINE("UIPauseGame", "GamePause.csb")
--音乐触发函数
function UIPauseGame:musicClick()
	local m_bMusic = self.mIsMusicOn
	m_bMusic = not m_bMusic
	AudioMgr:setMusicEnabled(m_bMusic)
	if m_bMusic then
		self.imgMusic:loadTexture("Psuse_music.png")
		AudioMgr:playMusic(1002)	--主战音乐					
	else
		self.imgMusic:loadTexture("Psuse_nomusic.png")
	end 
end

--音效触发函数
function UIPauseGame:effectClick()
	local m_bEffect = self.mIsEffectOn
	m_bEffect = not m_bEffect
	AudioMgr:setEffectEnabled(m_bEffect)
	if m_bEffect then
		self.imgEffect:loadTexture("Psuse_sound.png")
	else
		self.imgEffect:loadTexture("Psuse_nosound.png")
	end 
end

function UIPauseGame:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self.mIsMusicOn = AudioMgr:isMusicEnabled()
	self.mIsEffectOn = AudioMgr:isEffectEnabled()
	
	local Text_level_l = self:getChild("Text_level_l")
	Text_level_l:setString(LanguageStr("GAME_PAUSE_LEVEL")..LanguageStr("PUBLIC_COLON"))
	
	--需要消耗体力
	local needPower = self:getChild("needPower")
	needPower:setString(ModelCopy:getHp())
	--副本名
	local copyName = self:getChild("copyName")
	if CopyType["speical"] == ModelCopy:getType() then
		copyName:setString(ModelCopy:getName())
	else
		copyName:setString(ModelCopy:getId())
	end
	if ChannelProxy:isEnglish() then
		copyName:setFontSize(20)
	end
	-- 继续按钮
	local btnGoOn = self:getChild("Button_goon")
	self:addTouchEvent(btnGoOn, function(sender)
		self:close()
	end, true, true, 0)
	
	-- 重新开始按钮
	local btnRestart = self:getChild("Button_restart")
	self:addTouchEvent(btnRestart, function(sender)
		ModelPub:restartGame(self)
	end, true, true, 0)
	-- 放弃按钮
	local btnGiveUp = self:getChild("Button_giveUp")
	self:addTouchEvent(btnGiveUp, function(sender)
		ChannelProxy:recordValue("cancel")
		self:close()
		ModelPub:openUIFailed()
		AudioMgr:stopMusic()
		AudioMgr:playEffect(2011)
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		self:close()
	end, true, true, 0)
	
	-- 音乐图片
	self.imgMusic = self:getChild("Image_music")
	self:addTouchEvent(self.imgMusic, function(sender)
		UIPauseGame:musicClick()
	end, true, true, 0)
	
	-- 音效图片
	self.imgEffect = self:getChild("Image_effect")
	self:addTouchEvent(self.imgEffect, function(sender)
		UIPauseGame:effectClick()
	end, true, true, 0)
	
	if AudioMgr:isMusicEnabled() then
		self.imgMusic:loadTexture("Psuse_music.png")
	else
		self.imgMusic:loadTexture("Psuse_nomusic.png")
	end
	
	if AudioMgr:isEffectEnabled() then
		self.imgEffect:loadTexture("Psuse_sound.png")	
	else
		self.imgEffect:loadTexture("Psuse_nosound.png")	
	end
	
end

function UIPauseGame:onTouch(touch, event, eventCode)
end

function UIPauseGame:onUpdate(dt)
end

function UIPauseGame:onDestroy()
end

