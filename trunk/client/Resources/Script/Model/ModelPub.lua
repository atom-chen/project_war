----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-6-23
-- Brief: 一些界面的公共函数
----------------------------------------------------------------------
ModelPub = {
	
}

--根据元素的id，获得元素的图标(抽奖)
function ModelPub:getIconStrById(iconId)
	local iconStr = ""
	if iconId == 0 then				--怪物
		iconStr = "small_monster.png"
	elseif iconId == 5006 then		--木箱
		iconStr = "crate_01.png"
	else
		local elementInfo = LogicTable:get("element_tplt", iconId, true)
		iconStr = elementInfo.normal_image
	end
	return iconStr
end

--设置控件显示与触摸（middlePub）
function ModelPub:setWidgetVisible(widget,isVisible)
	widget:setVisible(isVisible)
	widget:setTouchEnabled(isVisible)
end

-- 打开成功界面
function ModelPub:openUISuccess()
	--特殊关卡奖励次数限制
	if ModelCopy:getRewardTimes() ~= 0 then
		local tb = DataMap:getCopyAwardTimesInfo()
		local speInfo = LogicTable:get("copy_special_tplt", ModelCopy:getId(), true)
		local key = ModelCopy:getId().."_"..speInfo.copy_id
		if nil == tb[key] then
			tb[key] = 0
		end
		if nil ~= tb[key] and ModelCopy:getRewardTimes() > tb[key] then
			tb[key] = tb[key] + 1
			DataMap:setCopyAwardTimesInfo(tb)
			ModelItem:updatePassAward(ModelCopy:getAwards())			-- 过关奖励
		end
	else
		ModelItem:updatePassAward(ModelCopy:getAwards())				-- 过关奖励
	end
	
	UIPauseGame:close()			--临界，多界面情况
	CreateTimer(1.6, 1, nil, function(tm)
		UIGameSuccess:openFront(true)
	end):start()
	if not ModelPub:isSpeLevel() then
		ChannelProxy:recordCustom("stat_copy_end_success")
		ChannelProxy:recordLevelFinish(ModelPub:getCurPass())
	end
end

--打开失败界面
function ModelPub:openUIFailed()
	UIPauseGame:close()			--临界，多界面情况
	UIGameFailed:openFront(true)
	if not ModelPub:isSpeLevel() then
		ChannelProxy:recordCustom("stat_copy_end_failure")
		ChannelProxy:recordLevelFail(ModelPub:getCurPass())
	end
end

--重新开始（coypInfo，暂停、失败）
function ModelPub:restartGame(selfTb)
	if ModelCopy:canEnterCopy() == false then
		UIBuyPower:openFront(true)		-- 打开购买体力界面
		return
	end
	DataHeroInfo:getSelectHeroId()
	if tostring(ModelPub:getCurPass()) ~= tostring(DataMap:getLastPass()) then
		ModelDisMoves:setFailTimes(0)
	end
	selfTb:close()
	UIGameGoal:close()
	UIMain:close()
	UIMiddlePub:close()
	UIBuyMoves:setBuyMovesFlag(false)
	MapManager:destroy()
	ModelItem:clearCollect()
	--DataMap:setLevel(level)			--？？？？？？
	local copyId = DataMap:getPass()
	local copyInfo = nil
	if ModelPub:isSpeLevel() then
		copySr = DataMap:getSpePass()
		copyTb = CommonFunc:stringSplit(copySr, "_", false)
		copyId = tonumber(copyTb[2]) 
		copyInfo = LogicTable:get("copy_special_tplt", copyId, true)
		ModelCopy:init(CopyType["speical"], copyInfo)	
		MapManager:create(copyInfo, {})
	else
		copyInfo = LogicTable:get("copy_tplt", copyId, true)
		ModelCopy:init(CopyType["normal"], copyInfo)		
		GuideMgr:startCopy(copyId)
		MapManager:create(copyInfo, DataMap:getSelectedHeroIds())
	end
	UIGameGoal:openMiddle()		-- 打开中间界面
	AudioMgr:stopMusic()
	AudioMgr:playMusic(1002)--主战音乐
	if not ModelPub:isSpeLevel() then
		ChannelProxy:recordLevelStart(ModelPub:getCurPass())
		ChannelProxy:recordCustom("stat_copy_target")
	end
end

--判断是不是特殊关卡
function ModelPub:isSpeLevel()
	local speLevel = DataMap:getSpePass()
	if tonumber(speLevel) ~= 0 then
		return true
	end
	return false
end

--获得当前选择的关卡
function ModelPub:getCurPass()
	if self:isSpeLevel() then		--注意：这里是字符串，“20_1”
		return DataMap:getSpePass()
	else
		return DataMap:getPass()
	end
end

--获得音乐是否开启
function ModelPub:initSound()
	if (ChannelProxy:isCocos() and ChannelProxy:getOperatorType()== 0) or
		"10181" == ChannelProxy:getChannelId()	then	--触控的游戏基地
		local flag = true
		local str = ChannelProxy:isSoundOn()
		if str == "true" then
			flag = true
		elseif str == "false" then
			flag = false
		end
		AudioMgr:setMusicEnabled(flag)
		AudioMgr:setEffectEnabled(flag)
	end
end

--转化触控--移动基地的支付码
function ModelPub:changeYDCode(str)
	if "10181" == ChannelProxy:getChannelId() then
		if 1 == string.len(str) then
			str = "00"..str
		elseif 2 == string.len(str) then
			str = "0"..str
		end
	end
	return str
end
