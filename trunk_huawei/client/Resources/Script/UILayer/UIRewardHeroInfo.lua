----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-2-28
-- Brief: 抽奖出现的英雄详细信息介绍界面
----------------------------------------------------------------------
UIRewardHeroInfo = {
	csbFile = "RewardHeroInfo.csb"
}

function UIRewardHeroInfo:onStart(ui, param)
	AudioMgr:playEffect(2007)
	GetRewardModel:setOpenHero(true)
	local iconWidget,amountText,itemInfo,finalId,awardPondId,awardPondInfo,number,clickTimes = 
	param[1],param[2],param[3],param[4],param[5],param[6],param[7],param[8]
	
	self.curHeoInfo = itemInfo
	if tonumber(self.curHeoInfo.award_type) ~= 2 then
		UIManager:close(self)
		 GetRewardModel:setOpenHero(flag)
		UIManager:popDelay()
		return
	end
	--进入界面的动画
	ui.root:setOpacity(0)
	ui.root:runAction(cc.Sequence:create(cc.FadeIn:create(2)))
	--描述
	local des = UIManager:seekNodeByName(ui.root, "Text_des")
	des:setString(self.curHeoInfo.description)
	--元素图标
	local elementIcon = UIManager:seekNodeByName(ui.root, "icon")
	elementIcon:loadTexture( DataHeroInfo:getFiveElementIcon()[self.curHeoInfo.type])
	--攻击力
	self.attack = UIManager:seekNodeByName(ui.root, "attackValue")
	self.attack:enableOutline(cc.c4b(98,48,11,255),3)
	self.attack:setString(self.curHeoInfo.attack)
	--特殊技能图标
	self.specilIcon = UIManager:seekNodeByName(ui.root, "icon_special")
	local iconString = DataHeroInfo:getSkillIconById(self.curHeoInfo.skill_id)
	self.specilIcon:loadTexture(iconString)
	--英雄
	local panelRoot = UIManager:seekNodeByName(ui.root, "Image_node")
	local node = Utils:createArmatureNode(self.curHeoInfo.display,"idle",true)
	node:setAnchorPoint(cc.p(0.5,0.5))
	node:setPosition(cc.p(0,0))
	node:setScale(0.7)
	panelRoot:addChild(node)
	
	-- 确定按钮
	local btnSure = UIManager:seekNodeByName(ui.root, "Button_sure")
	Utils:addTouchEvent(btnSure, function(sender)
		local function CallFucnCallback1()
			local function CallFucnCallback2()
				UIManager:close(self)
				GetRewardModel:setOpenHero(false)
				UIManager:popDelay()
			end
			ui.root:runAction(cc.Spawn:create(cc.FadeOut:create(0.1),cc.CallFunc:create(CallFucnCallback2)))
			UIMiddlePub:getAwardFlyAction(iconWidget,amountText,itemInfo,finalId,awardPondId,awardPondInfo,clickTimes)
		end
		ui.root:runAction(cc.CallFunc:create(CallFucnCallback1))
		AudioMgr:playEffect(2012)
	end, true, true, 0)
	--分享按钮
	local nShareCount = DataMap:geGetHeroShareCount()
	if ChannelProxy:isEnglish() then
		UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
	else
		if nShareCount >= G.SHARE_GET_HERO_COUNT then
			UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
		else
			UIManager:seekNodeByName(ui.root, "Text_share_zuan"):setString("+" .. G.SHARE_HERO_GET_DIAMOND)
		end
	end
	self.shareBtn = UIManager:seekNodeByName(ui.root, "Button_share")
	Utils:addTouchEvent(self.shareBtn, function(sender)
		local shareData = Utils:getShareContent()
		local function shareHandler(sResult)
			if ChannelProxy:isEnglish() then
			else
				if nShareCount < G.SHARE_GET_HERO_COUNT then
					nShareCount = nShareCount + 1
					DataMap:setGetHeroShareCount( nShareCount )
					ItemModel:appendTotalDiamond(G.SHARE_HERO_GET_DIAMOND)
					GetRewardModel:updateRewardInfo()
					
					local tb = {}
					tb.itemType = ItemType["dia"] 
					tb.oldAmount = ItemModel:getTotalDiamond() - G.SHARE_HERO_GET_DIAMOND
					tb.newAmount = ItemModel:getTotalDiamond()
					tb.flag = SignType["add"]
					EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
							
					if nShareCount >= G.SHARE_GET_HERO_COUNT and not tolua.isnull(self.shareBtn) then
						UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
					end
				end
			end
			if ChannelProxy:isFeixin() then
				ChannelProxy:recordCustom(shareData["ums_id"])
			end
			ChannelProxy:recordCustom("stat_get_award_share_success")	-- 友盟统计
		end
		if ChannelProxy:isFeixin() then
			ChannelProxy:shareEvent(shareData, shareHandler)
		else
			ChannelProxy:shareEventAndCapture(shareHandler)
		end
		ChannelProxy:recordCustom("stat_get_award_share")	-- 友盟统计
	end, true, true, 1)	
	local wxImage = UIManager:seekNodeByName(self.shareBtn, "Image_170")
	if ChannelProxy:isFeixin() then
		wxImage:setVisible(false)
	else
		wxImage:setVisible(true)
	end
end

function UIRewardHeroInfo:onTouch(touch, event, eventCode)
end

function UIRewardHeroInfo:onUpdate(dt)
end

function UIRewardHeroInfo:onDestroy()
end




