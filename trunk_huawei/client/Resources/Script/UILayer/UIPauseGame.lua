----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-11
-- Brief: 战斗失败界面
----------------------------------------------------------------------
UIPauseGame = {
	csbFile = "GamePause.csb"
}

--音乐触发函数
function UIPauseGame:musicClick()
	local m_bMusic = AudioMgr:isMusicEnabled()
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
	local m_bEffect = AudioMgr:isEffectEnabled()
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
	self:subscribeEvent(EventDef["ED_GAME_INIT"], self.onGameInit)
	
	
	local Text_level_l = UIManager:seekNodeByName(ui.root, "Text_level_l")
	Text_level_l:setString(LanguageStr("GAME_PAUSE_LEVEL")..LanguageStr("PUBLIC_COLON"))
	
	--根据当前打的副本，获得副本的信息
	self.copyInfo = LogicTable:get("copy_tplt", DataMap:getPass(), false)
	--需要消耗体力
	local needPower = UIManager:seekNodeByName(ui.root, "needPower")
	needPower:setString(self.copyInfo.hp)
	--副本名
	local copyName = UIManager:seekNodeByName(ui.root, "copyName")
	copyName:setString(DataMap:getPass())
	-- 继续按钮
	local btnGoOn = UIManager:seekNodeByName(ui.root, "Button_goon")
	Utils:addTouchEvent(btnGoOn, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	
	-- 重新开始按钮
	local btnRestart = UIManager:seekNodeByName(ui.root, "Button_restart")
	Utils:addTouchEvent(btnRestart, function(sender)
		if DataLevelInfo:canEnterCopy() == false then
			ChannelProxy:getStrInfo("buy_power_finish", function(productTb)
				if 0 == #productTb then
					UIManager:close(self)
					UIManager:close(UIGameGoal)
					UIBuyMoves:setBuyMovesFlag(false)
					UIManager:openFixed(UIGameGoal)		-- 打开中间界面
					DataLevelInfo:init()
					CopyModel:init(DataMap:getPass())
					ItemModel:clearCollect()
					MapManager:create(DataMap:getPass(),DataMap:getSelectedHeroIds())
					ChannelProxy:recordCustom("stat_copy_target")
					ChannelProxy:recordLevelStart(DataMap:getPass())
					AudioMgr:stopMusic()
					AudioMgr:playMusic(1002)--主战音乐
				else
					UIManager:openFront(UIBuyPower, true ,{["product_tb"]=productTb})
					ChannelProxy:recordCustom("stat_hp")
				end
			end)
			return
		end
		UIManager:close(self)
		UIManager:close(UIGameGoal)
		UIBuyMoves:setBuyMovesFlag(false)
		UIManager:openFixed(UIGameGoal)		-- 打开中间界面
		DataLevelInfo:init()
		CopyModel:init(DataMap:getPass())
		ItemModel:clearCollect()
		MapManager:create(DataMap:getPass(),DataMap:getSelectedHeroIds())
		ChannelProxy:recordCustom("stat_copy_target")
		ChannelProxy:recordLevelStart(DataMap:getPass())
		AudioMgr:stopMusic()
		AudioMgr:playMusic(1002)--主战音乐
	end, true, true, 0)
	-- 放弃按钮
	local btnGiveUp = UIManager:seekNodeByName(ui.root, "Button_giveUp")
	Utils:addTouchEvent(btnGiveUp, function(sender)
		ChannelProxy:recordValue(UIGameGoal:getRecordValue("stat_copy_cancel"))
		UIManager:close(self)
		UIMiddlePub:openUIFailed()
		AudioMgr:stopMusic()
		AudioMgr:playEffect(2011)
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	
	-- 音乐图片
	self.imgMusic = UIManager:seekNodeByName(ui.root, "Image_music")
	Utils:addTouchEvent(self.imgMusic, function(sender)
		UIPauseGame:musicClick()
	end, true, true, 0)
	
	-- 音效图片
	self.imgEffect = UIManager:seekNodeByName(ui.root, "Image_effect")
	Utils:addTouchEvent(self.imgEffect, function(sender)
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

function UIPauseGame:onGameInit(param)
end

