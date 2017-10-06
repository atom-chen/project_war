----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-5
-- Brief: 抽奖信息展示界面
----------------------------------------------------------------------
UIItemInfo = {
	csbFile = "ItemInfo.csb"
}

function UIItemInfo:onStart(ui, param)
	AudioMgr:playEffect(2007)
	GetRewardModel:setOpenBag(true)
	
	local iconWidget,amountText,itemInfo,finalId,awardPondId,awardPondInfo,number,clickTimes = 
	param[1],param[2],param[3],param[4],param[5],param[6],param[7],param[8]
	
	ui.root:setOpacity(0)
	ui.root:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
	
	self.rootPanel = UIManager:seekNodeByName(ui.root, "Panel_1")
	--礼包的大图片
	self.Image_big = UIManager:seekNodeByName(ui.root, "Image_big")
	self.Image_big:loadTexture(itemInfo.image)
	if itemInfo.award_type == 2 then
		self.Image_big:setVisible(false)
		local node = Utils:createArmatureNode(itemInfo.display,"idle",true)
		node:setPosition(cc.p(246,366))
		self.rootPanel:addChild(node)
		node:setAnchorPoint(cc.p(0.5,0.5))
	end
	local str = LanguageStr("REWARD_GIFT_GE") 
	if itemInfo.id == 7 or itemInfo.id == 8 then
		str = LanguageStr("REWARD_GIFT_POINT")
	end
	
	--礼包的个数
	self.Text_amount = UIManager:seekNodeByName(ui.root, "Text_amount")
	if ChannelProxy:isEnglish() then
		self.Text_amount:setString(LanguageStr("REWARD_GIFT_GET")..itemInfo.count.." "..itemInfo.name..LanguageStr("PUBLIC_EXCLAMATION"))
	else
		self.Text_amount:setString(LanguageStr("REWARD_GIFT_GET")..itemInfo.count..str..itemInfo.name..LanguageStr("PUBLIC_EXCLAMATION"))
	end
	--确定按钮
	local sureBtn = UIManager:seekNodeByName(ui.root, "Button_sure")
	Utils:addTouchEvent(sureBtn, function(sender)
		local function CallFucnCallback1()
			UIManager:close(self)
			GetRewardModel:setOpenBag(false)
			UIManager:popDelay()
		end
		ui.root:runAction(cc.Spawn:create(cc.ScaleTo:create(0.5, 0,0),cc.CallFunc:create(CallFucnCallback1)))
		UIMiddlePub:getAwardFlyAction(iconWidget,amountText,itemInfo,finalId,awardPondId,awardPondInfo,clickTimes)
	end, true, true, 0)
	--分享按钮
	local nShareCount = DataMap:geGetGiftShareCount()
	if ChannelProxy:isEnglish() then
		UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
	else
		if nShareCount >= G.SHARE_GET_ITEM_COUNT then
			UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
		else
			UIManager:seekNodeByName(ui.root, "Text_share_zuan"):setString("+" .. G.SHARE_ITEM_GET_DIAMAND)
		end
	end
	self.shareBtn = UIManager:seekNodeByName(ui.root, "Button_share")
	Utils:addTouchEvent(self.shareBtn, function(sender)
		local shareData = Utils:getShareContent()
		local function shareHandler(sResult)
			if ChannelProxy:isEnglish() then
			else
				nShareCount = DataMap:geGetGiftShareCount()
				if nShareCount < G.SHARE_GET_ITEM_COUNT then
					nShareCount = nShareCount + 1
					DataMap:setGetGiftShareCount( nShareCount )
					ItemModel:appendTotalDiamond(G.SHARE_ITEM_GET_DIAMAND)
					GetRewardModel:updateRewardInfo()
					
					local tb = {}
					tb.itemType = ItemType["dia"] 
					tb.oldAmount = ItemModel:getTotalDiamond() - G.SHARE_ITEM_GET_DIAMAND
					tb.newAmount = ItemModel:getTotalDiamond()
					tb.flag = SignType["add"]
					EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
						
					if nShareCount >= G.SHARE_GET_ITEM_COUNT and not tolua.isnull(self.shareBtn) then
						UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
					end
				end
			end
			if ChannelProxy:isFeixin() then
				ChannelProxy:recordCustom(shareData["ums_id"])
			end
			ChannelProxy:recordCustom("stat_get_award_get_material_share_success")	-- 友盟统计
		end
		if ChannelProxy:isFeixin() then
			ChannelProxy:shareEvent(shareData, shareHandler)
		else
			ChannelProxy:shareEventAndCapture(shareHandler)
		end
		ChannelProxy:recordCustom("stat_get_award_get_material_share")	-- 友盟统计
	end, true, true, 1)
	local wxImage = UIManager:seekNodeByName(self.shareBtn, "Image_148")
	if ChannelProxy:isFeixin() then
		wxImage:setVisible(false)
	else
		wxImage:setVisible(true)
	end
end

function UIItemInfo:onTouch(touch, event, eventCode)
end

function UIItemInfo:onUpdate(dt)
end

function UIItemInfo:onDestroy()
	
end

