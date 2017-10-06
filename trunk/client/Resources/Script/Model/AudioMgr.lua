----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-11
-- Brief: 音频管理器
----------------------------------------------------------------------
AudioMgr = {
	mMusicTable = {},				-- 音乐列表
	mMusicPreloadTable = {},		-- 音乐预加载列表
	mEffectTable = {},				-- 音效列表
	mEffectPreloadTable = {},		-- 音效预加载列表
	mIsMusicEnabled = true,			-- 音乐是否开启
	mIsEffectEnabled = true,		-- 音效是否开启
	mCurrMusicId = 0,				-- 当前播放的音乐id
}

-- 初始化
function AudioMgr:init()
	local dataTable = LogicTable:getAll("music_tplt")
	for key, data in pairs(dataTable) do
		if AudioType["music"] == data.type then			-- 音乐
			self.mMusicTable[key] = data
			if 1 == data.preload then
				self.mMusicPreloadTable[key] = data
			end
		elseif AudioType["effect"] == data.type then	-- 音效
			self.mEffectTable[key] = data
			if 1 == data.preload then
				self.mEffectPreloadTable[key] = data
			end
		end
	end
	-- 预加载音乐
	for key, data in pairs(self.mMusicPreloadTable) do
		local musicFile = cc.FileUtils:getInstance():fullPathForFilename(data.file)
		cc.SimpleAudioEngine:getInstance():preloadMusic(musicFile)
		self.mMusicTable[key].file = musicFile
	end
	-- 预加载音效
	for key, data in pairs(self.mEffectPreloadTable) do
		local effectFile = cc.FileUtils:getInstance():fullPathForFilename(data.file)
		cc.SimpleAudioEngine:getInstance():preloadEffect(effectFile)
		self.mEffectTable[key].file = effectFile
	end
	-- 初始音乐
	if self:isMusicEnabled() then
		self:setMusicVolume(self:getMusicVolume())
		self:setMusicEnabled(true)
	else
		self:setMusicEnabled(false)
	end
	-- 初始音效
	if self:isEffectEnabled() then
		self:setEffectVolume(self:getEffectVolume())
		self:setEffectEnabled(true)
	else
		self:setEffectEnabled(false)
	end
end

-- 暂停声音
function AudioMgr:pause()
	cc.SimpleAudioEngine:getInstance():pauseMusic()
	cc.SimpleAudioEngine:getInstance():pauseAllEffects()
end

-- 恢复声音
function AudioMgr:resume()
	if self:isMusicEnabled() then
		cc.SimpleAudioEngine:getInstance():resumeMusic()
	end
	if self:isEffectEnabled() then
		cc.SimpleAudioEngine:getInstance():resumeEffect(0)
	end
end

-- 设置音乐音量
function AudioMgr:setMusicVolume(volume)
	cc.SimpleAudioEngine:getInstance():setMusicVolume(volume)
	cc.UserDefault:getInstance():setFloatForKey("MusicVolume", volume)
	cc.UserDefault:getInstance():flush()
end

-- 设置音效音量
function AudioMgr:setEffectVolume(volume)
	cc.SimpleAudioEngine:getInstance():setEffectsVolume(volume)
	cc.UserDefault:getInstance():setFloatForKey("EffectVolume", volume)
	cc.UserDefault:getInstance():flush()
end

-- 获取音乐音量
function AudioMgr:getMusicVolume()
	return cc.UserDefault:getInstance():getFloatForKey("MusicVolume", 0.5)
end

-- 获取音效音量
function AudioMgr:getEffectVolume()
	return cc.UserDefault:getInstance():getFloatForKey("EffectVolume", 0.5)
end

-- 设置音乐开启
function AudioMgr:setMusicEnabled(enabled)
	if "boolean" ~= type(enabled) then
		enabled = true
	end
	if enabled then
		cc.SimpleAudioEngine:getInstance():resumeMusic()
	else
		cc.SimpleAudioEngine:getInstance():pauseMusic()
	end
	cc.UserDefault:getInstance():setBoolForKey("MusicOpen", enabled)
	cc.UserDefault:getInstance():flush()
	self.mIsMusicEnabled = enabled
end

-- 设置音效开启
function AudioMgr:setEffectEnabled(enabled)
	if "boolean" ~= type(enabled) then
		enabled = true
	end
	if enabled then
		cc.SimpleAudioEngine:getInstance():resumeEffect(0)
	else
		cc.SimpleAudioEngine:getInstance():pauseAllEffects()
	end
	cc.UserDefault:getInstance():setBoolForKey("EffectOpen", enabled)
	cc.UserDefault:getInstance():flush()
	self.mIsEffectEnabled = enabled
end

-- 音乐是否开启
function AudioMgr:isMusicEnabled()
	return cc.UserDefault:getInstance():getBoolForKey("MusicOpen", true)
end

-- 音效是否开启
function AudioMgr:isEffectEnabled()
	return cc.UserDefault:getInstance():getBoolForKey("EffectOpen", true)
end

-- 获取音乐
function AudioMgr:getMusic(musicId)
	local musicData = self.mMusicTable[musicId]
	if nil == musicData then
		musicData = LogicTable:get("music_tplt", musicId, true)
		assert(AudioType["music"] == musicData.type, "data type is not music, id: "..musicId)
		local musicFile = cc.FileUtils:getInstance():fullPathForFilename(musicData.file)
		cc.SimpleAudioEngine:getInstance():preloadMusic(musicFile)
		musicData.file = musicFile
		self.mMusicTable[musicId] = musicData
	end
	return musicData.file
end

-- 获取音效
function AudioMgr:getEffect(effectId)
	local effectData = self.mEffectTable[effectId]
	if nil == effectData then
		effectData = LogicTable:get("music_tplt", effectId, true)
		assert(AudioType["effect"] == effectData.type, "data type is not effect, id: "..effectId)
		local musicFile = cc.FileUtils:getInstance():fullPathForFilename(effectData.file)
		cc.SimpleAudioEngine:getInstance():preloadMusic(musicFile)
		effectData.file = musicFile
		self.mEffectTable[effectId] = effectData
	end
	return effectData.file
end

-- 播放音乐
function AudioMgr:playMusic(musicId)
	self:stopMusic()
	if not self.mIsMusicEnabled then
		return
	end
	cc.SimpleAudioEngine:getInstance():playMusic(self:getMusic(musicId), true)
	self.mCurrMusicId = musicId
end

-- 停止音乐
function AudioMgr:stopMusic()
	if 0 == self.mCurrMusicId then
		return
	end
	local musicData = self.mMusicTable[self.mCurrMusicId]
	if nil == musicData then
		self.mCurrMusicId = 0
		return
	end
	cc.SimpleAudioEngine:getInstance():stopMusic(true)
	self.mMusicTable[self.mCurrMusicId] = nil
	self.mCurrMusicId = 0
end

-- 播放音效
function AudioMgr:playEffect(effectId)
	if not self.mIsEffectEnabled then
		return
	end
	cc.SimpleAudioEngine:getInstance():playEffect(self:getEffect(effectId))
end

