----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-11
-- Brief: 战斗失败界面
----------------------------------------------------------------------
UIGameFailed = {
	csbFile = "GameFailed.csb"
}

--设置消耗体力
function UIGameFailed:setPower()
	if nil == self.power then
		return
	end
	self.power:setString(CopyModel:getCostHp())
end

function UIGameFailed:onStart(ui, param)
	self:subscribeEvent(EventDef["ED_FREE_POWER_end"], self.setPower)
	AudioMgr:playEffect(2007)
	self.root = ui.root
	local Text_get_item_l = UIManager:seekNodeByName(ui.root, "Text_get_item_l")
	Text_get_item_l:setString(LanguageStr("GAME_FAIL_GETITEM"))
	
	self.ballIcon = UIManager:seekNodeByName(ui.root, "Image_ball")
	self.diamondIcon = UIManager:seekNodeByName(ui.root, "Image_diamond")
	self.cookieIcon = UIManager:seekNodeByName(ui.root, "Image_cookie")
	self.keyIcon = UIManager:seekNodeByName(ui.root, "Image_key")
	--根据当前打的副本，获得副本的信息
	--self.copyInfo = LogicTable:get("copy_tplt", DataMap:getPass(), false)
	self.ballPanel = UIManager:seekNodeByName(ui.root, "Panel_ball")
	
	-- 重新开始按钮
	local btnRestart = UIManager:seekNodeByName(ui.root, "Button_restart")
	Utils:addTouchEvent(btnRestart, function(sender)
		if DataLevelInfo:canEnterCopy() == false then
			--UIFreePower:setEnterMode(2)
			UIManager:openFront(UIBuyPowerNew,true)		-- 打开购买体力界面
			return
		end
		UIManager:close(self)
		UIManager:close(UIGameGoal)
		MapManager:destroy()
		MapManager:create(DataMap:getPass(),DataMap:getSelectedHeroIds())
		UIManager:openFixed(UIGameGoal)		-- 打开中间界面
		DataLevelInfo:init()
		CopyModel:init(DataMap:getPass())
		ItemModel:clearCollect()
		
		PowerManger:setCurPower(PowerManger:getCurPower() - CopyModel:getCostHp())
		PowerManger:timerChangeCurPower()
		
		ChannelProxy:recordCustom("stat_copy_target")
		ChannelProxy:recordLevelStart(DataMap:getPass())
		AudioMgr:stopMusic()
		AudioMgr:playMusic(1002)--主战音乐
	end, true, true, 0)
	
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(UIGameGoal)
		UIManager:close(self)
		MapManager:destroy()
		UIManager:openFixed(UIMiddlePub)
		if ItemModel:getCollectKey() > 0 then
			UIManager:openBack(UIGetAward)		-- 打开中间界面
			UIMiddlePub:setSuccessBtn()
			UIMiddlePub:hideFlyIcon()
			return
		end
		UIManager:openBack(UIMain)		-- 打开中间界面
		UIMiddlePub:initBtns()
		--DataLevelInfo:showDisCountDiamond()
	end, true, true, 0)
	
	-- 体力panel
	local powerPanel = UIManager:seekNodeByName(ui.root, "Panel_power")
	--设置消耗体力
	self.power = UIManager:seekNodeByName(ui.root, "power")
	self.power:setString(CopyModel:getCostHp())
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
	
	UIGameFailed:setCollectPos()
end

--设置各个图标的位置
function UIGameFailed:setCollectPos()
	self.x1= self.ballIcon:getWorldPosition().x
	self.y1 = self.ballIcon:getWorldPosition().y
	self.x2 = self.diamondIcon:getWorldPosition().x
	self.y2 = self.diamondIcon:getWorldPosition().y
	self.x3 = self.cookieIcon:getWorldPosition().x
	self.y3 = self.cookieIcon:getWorldPosition().y
end

--获得毛球图标和饼干图标的位置
function UIGameFailed:getCollectPos()
	return self.x1,self.y1,self.x2,self.y2,self.x3,self.y3
end

function UIGameFailed:onTouch(touch, event, eventCode)
end

function UIGameFailed:onUpdate(dt)
end

function UIGameFailed:onDestroy()
	self.power = nil
end
