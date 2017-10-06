----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-11
-- Brief: 战斗失败界面
----------------------------------------------------------------------
UIDEFINE("UIGameFailed", "GameFailed.csb")
function UIGameFailed:onStart(ui, param)
	AudioMgr:playEffect(2007)
	--描边
	local Text_get_item_l = self:getChild("Text_get_item_l")
	Text_get_item_l:setString(LanguageStr("GAME_FAIL_GETITEM"))
	Text_get_item_l:enableOutline(cc.c4b(61,9,11,255),3)
	self.ballPanel = self:getChild("Panel_ball")
	-- 重新开始按钮
	local btnRestart = self:getChild("Button_restart")
	self:addTouchEvent(btnRestart, function(sender)
		ModelPub:restartGame(self)
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		UIGameGoal:close()
		self:close()
		UIBuyMoves:setBuyMovesFlag(false)
		MapManager:destroy()
		UIMiddlePub:openMiddle()
		if ModelItem:getCollectKey() > 0 then
			UIGetAward:openBack()	-- 打开中间界面
			UIMiddlePub:setSuccessBtn()
			return
		end
		UIMain:openBack()
		UIMiddlePub:initBtns()
		--ModelDiscount:showDisCountDiamond(ModelCopy:getShowDis())
		
	end, true, true, 0)
	-- 体力panel
	local powerPanel = self:getChild("Panel_power")
	--设置消耗体力
	local power = self:getChild("power")
	power:setString(ModelCopy:getHp())
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
		name:setString(specialCopyInfo.name or "")
	else
		name:setString((copyId or 0)..":"..(copyName or ""))
	end

	--失败提醒
	local showMsg = self:getChild("msg")
	local tipTable = {}
	
	if not ModelCopy:isKillGoalsComplete() then
		tipTable = LogicTable:getCondition("fail_tip_tplt", function(data)
			return 1 == data.type
		end)
	elseif not ModelCopy:isCollectGoalsComplete() then
		tipTable = LogicTable:getCondition("fail_tip_tplt",function(data)
			return 2 == data.type
		end)
	elseif not ModelCopy:isDamageGoalsComplete() then
		tipTable = LogicTable:getCondition("fail_tip_tplt",function(data)
			return 3 == data.type
		end)
	end
	local data = CommonFunc:getRandom(tipTable)
	--Log(data)
	showMsg:setString(data.content)
	
	local msgScaleMax = cc.ScaleTo:create(0.2,1.15)
	local msgDelTime2 = cc.DelayTime:create(1.8)
	local msgDelTime1 = cc.DelayTime:create(0.4)
	local msgScaleMin = cc.ScaleTo:create(0.2,1)
	local msgNormal = cc.ScaleTo:create(0.2,1)
	local seq = cc.Sequence:create(msgDelTime1,msgScaleMax,msgScaleMin,msgNormal,
		msgDelTime2,nil)
	showMsg:runAction(cc.RepeatForever:create(seq))
	
	-- 失败特效
	self.topPanel = self:getChild("Image_title")
	failEffect = Utils:createArmatureNode("copyfail", "idle", true, function(armatureBack, movementType, movementId)
		if ccs.MovementEventType.complete == movementType and "idle" == movementId then
			failEffect:removeFromParent()
		end
	end)
	failEffect:setAnchorPoint(cc.p(0.5,0.5))
	failEffect:setPosition(cc.p(213,105))
	self.topPanel:addChild(failEffect, 101)
end

function UIGameFailed:onTouch(touch, event, eventCode)
end

function UIGameFailed:onUpdate(dt)
end

function UIGameFailed:onDestroy()
end
