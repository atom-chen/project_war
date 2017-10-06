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
	
	
	--根据当前打的副本，获得副本的信息
	--self.copyInfo = LogicTable:get("copy_tplt", DataMap:getPass(), false)
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
		MapManager:destroy()
		if ItemModel:getCollectKey() > 0 then
			UIManager:close(self)
			UIManager:openFixed(UIMiddlePub)
			UIManager:openBack(UIGetAward)		-- 打开中间界面
			UIMiddlePub:setSuccessBtn()
			UIMiddlePub:hideFlyIcon()
			return
		end
		UIManager:close(self)
		UIManager:openBack(UIMain)		-- 打开中间界面
		UIManager:openFixed(UIMiddlePub)
		UIMiddlePub:initBtns()
		--DataLevelInfo:showDisCountDiamond()
	end, true, true, 0)
	-- 分享按钮*****************************有待填充************
	local nShareCount = DataMap:getWinShareCount()
	if nShareCount >= G.SHARE_WIN_COUNT then
		UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
	else
		UIManager:seekNodeByName(ui.root, "Text_share_zuan"):setString("+" .. G.SHARE_WIN_GIVE_DIAMOND)
	end
	self.shareBtn = UIManager:seekNodeByName(ui.root, "Button_share")
	Utils:addTouchEvent(self.shareBtn, function(sender)
		local function shareHandler(sResult)
			if nil == sResult or "" == sResult or ChannelProxy.SHARE_SUCCESS == sResult then
				if nShareCount < G.SHARE_WIN_COUNT then
					nShareCount = nShareCount + 1
					DataMap:setWinShareCount( nShareCount )
					ItemModel:appendTotalDiamond(G.SHARE_WIN_GIVE_DIAMOND)
					if nShareCount >= G.SHARE_WIN_COUNT and not tolua.isnull(self.shareBtn) then
						UIManager:seekNodeByName(ui.root, "Image_share_zuan"):setVisible(false)
					end
				end
				ChannelProxy:recordCustom("stat_copy_end_share_success")		-- 友盟统计
			end
		end
		ChannelProxy:shareEventAndCapture(shareHandler)		-- 截图分享
		ChannelProxy:recordCustom("stat_copy_end_share")		-- 友盟统计
	end, true, true, 1)
	
	self.ballIcon = UIManager:seekNodeByName(ui.root, "Image_ball")
	self.diamondIcon = UIManager:seekNodeByName(ui.root, "Image_diamond")
	self.cookieIcon = UIManager:seekNodeByName(ui.root, "Image_cookie")
	self.keyIcon = UIManager:seekNodeByName(ui.root, "Image_key")
	
	self.rootPanel = UIManager:seekNodeByName(ui.root, "Panel_1")
	
	UIGameSuccess:setCollectPos()
end

--设置各个图标的位置
function UIGameSuccess:setCollectPos()
	self.x1= self.ballIcon:getWorldPosition().x
	self.y1 = self.ballIcon:getWorldPosition().y
	self.x2 = self.diamondIcon:getWorldPosition().x
	self.y2 = self.diamondIcon:getWorldPosition().y
	self.x3 = self.cookieIcon:getWorldPosition().x
	self.y3 = self.cookieIcon:getWorldPosition().y
end

--获得毛球图标和饼干图标的位置
function UIGameSuccess:getCollectPos()
	return self.x1,self.y1,self.x2,self.y2,self.x3,self.y3
end

function UIGameSuccess:onTouch(touch, event, eventCode)
end

function UIGameSuccess:onUpdate(dt)
end

function UIGameSuccess:onDestroy()
end

function UIGameSuccess:onGameInit(param)
	cclog("---------------11111 login ui",param)
end

