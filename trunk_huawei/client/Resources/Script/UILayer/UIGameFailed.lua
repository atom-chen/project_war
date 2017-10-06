----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-11
-- Brief: 战斗失败界面
----------------------------------------------------------------------
UIGameFailed = {
	csbFile = "GameFailed.csb"
}

function UIGameFailed:onStart(ui, param)
	AudioMgr:playEffect(2007)
	--描边
	local Text_get_item_l = UIManager:seekNodeByName(ui.root, "Text_get_item_l")
	Text_get_item_l:setString(LanguageStr("GAME_FAIL_GETITEM"))
	Text_get_item_l:enableOutline(cc.c4b(61,9,11,255),3)
	--根据当前打的副本，获得副本的信息
	self.copyInfo = LogicTable:get("copy_tplt", DataMap:getPass(), false)
	self.ballPanel = UIManager:seekNodeByName(ui.root, "Panel_ball")
	-- 重新开始按钮
	local btnRestart = UIManager:seekNodeByName(ui.root, "Button_restart")
	Utils:addTouchEvent(btnRestart, function(sender)
		if DataLevelInfo:canEnterCopy() == false then
			ChannelProxy:getStrInfo("buy_power_finish", function(productTb)
				if 0 == #productTb then
					UIPrompt:show(LanguageStr("QURERY_FAIL"))
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
		MapManager:destroy()
		UIManager:openFixed(UIGameGoal)		-- 打开中间界面
		DataLevelInfo:init()
		CopyModel:init(DataMap:getPass())
		ItemModel:clearCollect()
		MapManager:create(DataMap:getPass(),DataMap:getSelectedHeroIds())
		ChannelProxy:recordCustom("stat_copy_target")
		ChannelProxy:recordLevelStart(DataMap:getPass())
		AudioMgr:stopMusic()
		AudioMgr:playMusic(1002)			--主战音乐
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(UIGameGoal)
		UIManager:close(self)
		UIBuyMoves:setBuyMovesFlag(false)
		MapManager:destroy()
		UIManager:openFixed(UIMiddlePub)
		if ItemModel:getCollectKey() > 0 then
			UIManager:openBack(UIGetAward)	-- 打开中间界面
			UIMiddlePub:setSuccessBtn()
			return
		end
		UIManager:openBack(UIMain)			-- 打开中间界面
		UIMiddlePub:initBtns()
		DataLevelInfo:showDisCountDiamond()
	end, true, true, 0)
	-- 体力panel
	local powerPanel = UIManager:seekNodeByName(ui.root, "Panel_power")
	--设置消耗体力
	local power = UIManager:seekNodeByName(ui.root, "power")
	power:setString(self.copyInfo.hp)
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
	-- 失败特效
	self.topPanel = UIManager:seekNodeByName(ui.root, "Image_title")
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
