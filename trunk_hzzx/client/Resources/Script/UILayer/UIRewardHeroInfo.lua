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
	--[[
	--测试代码
	itemInfo ={}
	itemInfo.award_type = 2
	itemInfo.name = "))))))"
	itemInfo.image = "touming.png"
	itemInfo.display = "hero_02"
	itemInfo.count =1
	itemInfo.level = 1
	itemInfo.attack = 1
	itemInfo.skill_id = 1301
	itemInfo.type = 2
	]]--
	--进入界面的动画
	ui.root:setOpacity(0)
	ui.root:runAction(cc.Sequence:create(cc.FadeIn:create(2)))
	--Log(self.curHeoInfo)
	--名字
	--local name = UIManager:seekNodeByName(ui.root, "name")
	--name:setString(self.curHeoInfo.name)
	--等级
	--self.level = UIManager:seekNodeByName(ui.root, "level")
	--self.level:setString("LV"..1)				--等级有待再处理
	--描述
	local des = UIManager:seekNodeByName(ui.root, "Text_des")
	des:setString(self.curHeoInfo.description)
	--元素图标
	local elementIcon = UIManager:seekNodeByName(ui.root, "icon")
	elementIcon:loadTexture( DataHeroInfo:getFiveElementIcon()[self.curHeoInfo.type])
	--攻击力
	self.attack = UIManager:seekNodeByName(ui.root, "attackValue")
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
	if nShareCount >= G.SHARE_GET_HERO_COUNT then
		UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
	else
		UIManager:seekNodeByName(ui.root, "Text_share_zuan"):setString("+" .. G.SHARE_HERO_GET_DIAMOND)
	end
	self.shareBtn = UIManager:seekNodeByName(ui.root, "Button_share")
	Utils:addTouchEvent(self.shareBtn, function(sender)
		local function shareHandler(sResult)
			if nil == sResult or "" == sResult or ChannelProxy.SHARE_SUCCESS == sResult then
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
				ChannelProxy:recordCustom("stat_get_award_share_success")	-- 友盟统计
			end
		end
		ChannelProxy:shareEventAndCapture(shareHandler)
		ChannelProxy:recordCustom("stat_get_award_share")	-- 友盟统计
	end, true, true, 1)	
end

function UIRewardHeroInfo:onTouch(touch, event, eventCode)
end

function UIRewardHeroInfo:onUpdate(dt)
end

function UIRewardHeroInfo:onDestroy()
end




