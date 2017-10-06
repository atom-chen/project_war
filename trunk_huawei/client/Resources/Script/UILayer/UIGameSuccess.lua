----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-11
-- Brief: 战斗成功界面
----------------------------------------------------------------------
UIGameSuccess = {
	csbFile = "GameSuccess.csb"
}

function UIGameSuccess:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self:subscribeEvent(EventDef["ED_GAME_INIT"], self.onGameInit)
	
	local Text_cellect_l = UIManager:seekNodeByName(ui.root, "Text_cellect_l")
	Text_cellect_l:setString(LanguageStr("GAME_FAIL_GETITEM"))
	Text_cellect_l:enableOutline(cc.c4b(61,9,11,255),3)
	
	--根据当前打的副本，获得副本的信息
	self.copyInfo = LogicTable:get("copy_tplt", DataMap:getPass(), false)
	--收集到的元素个数
	local ball = UIManager:seekNodeByName(ui.root, "Text_ball")
	ball:setString(ItemModel:getCollectBall())
	local diamond = UIManager:seekNodeByName(ui.root, "Text_diamond")
	diamond:setString(ItemModel:getCollectDiamond())
	local key = UIManager:seekNodeByName(ui.root, "Text_key")
	key:setString(ItemModel:getCollectKey())
	local cookie = UIManager:seekNodeByName(ui.root, "Text_cookie")
	cookie:setString(ItemModel:getCollectCookie())
	--关卡名
	local name = UIManager:seekNodeByName(ui.root, "name")
	name:setString(CopyModel:getName())
	-- 返回主界面按钮
	local btnBack = UIManager:seekNodeByName(ui.root, "Button_great")
	Utils:addTouchEvent(btnBack, function(sender)
		PowerManger:timerChangeCurPower()
		UIManager:close(UIGameGoal)
		UIBuyMoves:setBuyMovesFlag(false)
		MapManager:destroy()
		if ItemModel:getCollectKey() > 0 then
			UIManager:close(self)
			UIManager:openFixed(UIMiddlePub)
			UIManager:openBack(UIGetAward)		
			UIMiddlePub:setSuccessBtn()
			return
		end
		UIManager:close(self)
		UIManager:openBack(UIMain)		
		UIManager:openFixed(UIMiddlePub)
		UIMiddlePub:initBtns()
		DataLevelInfo:showDisCountDiamond()
	end, true, true, 0)
	-- 分享按钮
	local nShareCount = DataMap:getWinShareCount()
	if ChannelProxy:isEnglish() then
		UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
	else
		if nShareCount >= G.SHARE_WIN_COUNT then
			UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
		else
			UIManager:seekNodeByName(ui.root, "Text_share_zuan"):setString("+" .. G.SHARE_WIN_GIVE_DIAMOND)
		end
	end
	self.shareBtn = UIManager:seekNodeByName(ui.root, "Button_share")
	Utils:addTouchEvent(self.shareBtn, function(sender)
		local shareData = Utils:getShareContent()
		local function shareHandler(sResult)
			if ChannelProxy:isEnglish() then
			else
				if nShareCount < G.SHARE_WIN_COUNT then
					nShareCount = nShareCount + 1
					DataMap:setWinShareCount( nShareCount )
					ItemModel:appendTotalDiamond(G.SHARE_WIN_GIVE_DIAMOND)
					if nShareCount >= G.SHARE_WIN_COUNT and not tolua.isnull(self.shareBtn) then
						UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
					end
				end
			end
			if ChannelProxy:isFeixin() then
				ChannelProxy:recordCustom(shareData["ums_id"])
			end
			ChannelProxy:recordCustom("stat_copy_end_share_success")		-- 友盟统计
		end
		if ChannelProxy:isFeixin() then
			ChannelProxy:shareEvent(shareData, shareHandler)
		else
			ChannelProxy:shareEventAndCapture(shareHandler)		-- 截图分享
		end
		ChannelProxy:recordCustom("stat_copy_end_share")		-- 友盟统计
	end, true, true, 1)
	local wxImage = UIManager:seekNodeByName(self.shareBtn, "Image_169")
	if ChannelProxy:isFeixin() then
		wxImage:setVisible(false)
	else
		wxImage:setVisible(true)
	end
	-- 成功特效
	self.topPanel = UIManager:seekNodeByName(ui.root, "Image_back")
	successEffect = Utils:createArmatureNode("copysuccess", "idle", true, function(armatureBack, movementType, movementId)
		if ccs.MovementEventType.complete == movementType and "idle" == movementId then
			successEffect:removeFromParent()
		end
	end)
	successEffect:setAnchorPoint(cc.p(0.5,0.5))
	successEffect:setPosition(cc.p(248,490))
	self.topPanel:addChild(successEffect, 101)
	local count = DataMap:getRemarkShowCount()
	if 0 == count and 8 == DataMap:getPass() then
		DataMap:setRemarkShowCount(count + 1)
		ChannelProxy:remark()
	end
end

function UIGameSuccess:onTouch(touch, event, eventCode)
end

function UIGameSuccess:onUpdate(dt)
end

function UIGameSuccess:onDestroy()
end

function UIGameSuccess:onGameInit(param)
end

