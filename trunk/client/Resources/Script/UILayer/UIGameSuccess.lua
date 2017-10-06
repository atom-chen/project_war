----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-11
-- Brief: 战斗成功界面
----------------------------------------------------------------------
UIDEFINE("UIGameSuccess", "GameSuccess.csb")
function UIGameSuccess:onStart(ui, param)
	AudioMgr:playEffect(2007)
	
	local Text_cellect_l = self:getChild("Text_cellect_l")
	Text_cellect_l:setString(LanguageStr("GAME_FAIL_GETITEM"))
	Text_cellect_l:enableOutline(cc.c4b(61,9,11,255),3)
	
	--收集到的元素个数
	local ball = self:getChild("Text_ball")
	ball:setString(ModelItem:getCollectBall())
	local diamond = self:getChild("Text_diamond")
	diamond:setString(ModelItem:getCollectDiamond())
	local key = self:getChild("Text_key")
	key:setString(ModelItem:getCollectKey())
	local cookie = self:getChild("Text_cookie")
	cookie:setString(ModelItem:getCollectCookie())
	--关卡名
	local name = self:getChild("name")
	local copyId, copyName = ModelCopy:getId(), ModelCopy:getName()
	if CopyType["speical"] == ModelCopy:getType() then
		local specialCopyInfo = LogicTable:get("copy_special_tplt", copyId, true)
		--local copyInfo = LogicTable:get("copy_tplt", specialCopyInfo.copy_id, true)
		--copyId = specialCopyInfo.copy_id
		--copyName = copyInfo.name
		Text_cellect_l:setString(LanguageStr("SPECIAL_COPY_TITLE"))
		name:setString(specialCopyInfo.name)
	else
		name:setString((copyId or 0)..":"..(copyName or ""))
	end
	
	-- 返回主界面按钮
	local btnBack = self:getChild("Button_great")
	self:addTouchEvent(btnBack, function(sender)
		PowerManger:timerChangeCurPower()
		UIGameGoal:close()
		UIBuyMoves:setBuyMovesFlag(false)
		MapManager:destroy()
		if ModelItem:getCollectKey() > 0 then
			self:close()
			UIMiddlePub:openMiddle()
			UIGetAward:openBack()		
			UIMiddlePub:setSuccessBtn()
			return
		end
		self:close()
		UIMain:openBack()
		UIMiddlePub:openMiddle()
		UIMiddlePub:initBtns()
		ModelDiscount:showDisCountDiamond(ModelCopy:getShowDis())
		--开启每日签到界面
		ModelSignIn:showSignInUI()
	end, true, true, 0)
	-- 分享按钮
	local nShareCount = DataMap:getWinShareCount()
	if ChannelProxy:isEnglish() then
		self:getChild("Image_share_zuan"):setVisible(false)
	else
		if nShareCount >= G.SHARE_WIN_COUNT then
			self:getChild("Image_share_zuan"):setVisible(false)
		else
			self:getChild("Text_share_zuan"):setString("+" .. G.SHARE_WIN_GIVE_DIAMOND)
		end
	end
	self.shareBtn = self:getChild("Button_share")
	self:addTouchEvent(self.shareBtn, function(sender)
		local shareData = Utils:getShareContent()
		local function shareHandler(sResult)
			if ChannelProxy:isEnglish() then
			else
				if nShareCount < G.SHARE_WIN_COUNT then
					nShareCount = nShareCount + 1
					DataMap:setWinShareCount( nShareCount )
					ModelItem:appendTotalDiamond(G.SHARE_WIN_GIVE_DIAMOND)
					if nShareCount >= G.SHARE_WIN_COUNT and not tolua.isnull(self.shareBtn) then
						self:getChild("Image_share_zuan"):setVisible(false)
					end
				end
			end
			if ChannelProxy:isFeixin() then
				ChannelProxy:recordCustom(shareData["ums_id"])
			end
			ChannelProxy:recordCustom("stat_copy_end_share_success")		-- 友盟统计
		end
		ChannelProxy:shareEvent(shareData, shareHandler)
		ChannelProxy:recordCustom("stat_copy_end_share")		-- 友盟统计
	end, true, true, 1)
	local wxImage = self:getChild("Image_169")
	if ChannelProxy:isFeixin() then
		wxImage:setVisible(false)
	else
		wxImage:setVisible(true)
	end
	-- 成功特效
	self.topPanel = self:getChild("Image_back")
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


