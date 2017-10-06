----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-12-31
-- Brief: 英雄详细信息介绍界面
----------------------------------------------------------------------
UIHeroInfo = {
	csbFile = "HeroInfo.csb"
}
--计算需要的材料个数，钱
function UIHeroInfo:getNeedMaterials()
	return self.tempBall,self.tempCookie
end

--获得升级需要的材料个数
function UIHeroInfo:getGrowNeedMaterials(curHeoInfo)
	local ballString =0
	local cookieString = 0
	if curHeoInfo.materials[1][1] == 1  then
		ballString = curHeoInfo.materials[1][2]
	end
	if #curHeoInfo.materials >=2 and curHeoInfo.materials[2][1] == 1  then
		ballString = curHeoInfo.materials[2][2]
	end
	if curHeoInfo.materials[1][1] == 2  then
		cookieString = curHeoInfo.materials[1][2]
	end
	if #curHeoInfo.materials >=2 and curHeoInfo.materials[2][1] == 2  then
		cookieString = curHeoInfo.materials[2][2]
	end
	if #curHeoInfo.materials >=2 and curHeoInfo.materials[1][1] == curHeoInfo.materials[2][1] then
		UIPrompt:show(LanguageStr("HERO_TIP_2"))
	end
	return ballString,cookieString
end

--根据材料是否足够，判断是否可以升级
function UIHeroInfo:canGrow(curHeoInfo)
	local ballString,cookieString = UIHeroInfo:getGrowNeedMaterials(curHeoInfo)
	local curBall = ItemModel:getTotalBall()
	local curCookie = ItemModel:getTotalCookie()
	if curBall < ballString or curCookie < cookieString then
		self.diamondImg:setVisible(true)
		self.tempBall = ballString - curBall
		self.tempCookie = cookieString - curCookie
		return false
	else
		local newBall = curBall - ballString
		local newCookie = curCookie - cookieString
		self.diamondImg:setVisible(false)
		return true,newBall,newCookie,curBall,curCookie
	end
end

--获得升级需要的材料个数
function UIHeroInfo:loadGrowBtn()
	UIHeroInfo:canGrow(self.curHeoInfo)
end

--设置英雄信息界面
function UIHeroInfo:setHeroInfoUI(curHeoInfo)
	local ballString,cookieString = UIHeroInfo:getGrowNeedMaterials(curHeoInfo)
	self.ballNumber:setString(ballString)
	self.cookieNumber:setString(cookieString)
	
	local iconString = DataHeroInfo:getSkillIconById(curHeoInfo.skill_id)
	self.specilIcon:loadTexture(iconString)
	if curHeoInfo.level*100/20 >= 100 then
		self.loadingBar:setPercent(100)
	else
		self.loadingBar:setPercent(curHeoInfo.level*100/20)
	end
	
	
	local maxLevel = DataHeroInfo:getMedalLevel(curHeoInfo)
	for i=1,5,1 do
		local medalImg = UIManager:seekNodeByName(self.root, "medal_"..i)
		local fullImg = UIManager:seekNodeByName(self.root, "full_"..i)
		local levelText = UIManager:seekNodeByName(self.root, "level_"..i)
		if i<= maxLevel then
			medalImg:setColor(cc.c3b(255,255,255))
			fullImg:setVisible(true)
			levelText:setVisible(false)
		else
			medalImg:setColor(cc.c3b(150,100,100))
			fullImg:setVisible(false)
			levelText:setVisible(true)
		end
	end
	
	--self.heroMedal:loadTexture("medal_"..maxLevel..".png")
	if curHeoInfo.next_id == 0 then
		self.maxText:setVisible(true)
		self.growBtn:setVisible(false)
		self.growBtn:setTouchEnabled(false)
		self.Panel_ball:setVisible(false)
		self.Panel_cookie:setVisible(false)
	else
		local ballString,cookieString = UIHeroInfo:getGrowNeedMaterials(curHeoInfo)
		self.ballNumber:setString(ballString)
		self.cookieNumber:setString(cookieString)
		self.maxText:setVisible(false)
		self.growBtn:setVisible(true)
		self.growBtn:setTouchEnabled(true)
		UIHeroInfo:canGrow(curHeoInfo)
		self.Panel_ball:setVisible(true)
		self.Panel_cookie:setVisible(true)
	end
end

function UIHeroInfo:onStart(ui, param)

	local Text_attack_l = UIManager:seekNodeByName(ui.root, "Text_attack_l")
	Text_attack_l:setString(LanguageStr("HERO_INFO_ATTACK"))
	local Text_skill_l = UIManager:seekNodeByName(ui.root, "Text_skill_l")
	Text_skill_l:setString(LanguageStr("HERO_INFO_SKILL"))
	
	AudioMgr:playEffect(2007)
	self.tempBall,self.tempCookie = 0, 0
	self.curHeoInfo = UIHero:getCurHero()
	--Log(self.curHeoInfo)
	--名字
	local name = UIManager:seekNodeByName(ui.root, "name")
	name:setString(self.curHeoInfo.name)
	--攻击力底板、技能底板、相关元素的根节点
	self.attackPanel = UIManager:seekNodeByName(ui.root, "Panel_attack")
	self.skillPanel = UIManager:seekNodeByName(ui.root, "Panel_skill")
	self.panelRoot = UIManager:seekNodeByName(ui.root, "Image_115")
	--等级
	self.level = UIManager:seekNodeByName(ui.root, "level")
	self.level:setString("LV"..self.curHeoInfo.level)				--等级有待再处理
	--元素图标
	local elementIcon = UIManager:seekNodeByName(ui.root, "icon")
	elementIcon:loadTexture( DataHeroInfo:getFiveElementIcon()[self.curHeoInfo.type])
	--攻击力
	self.attack = UIManager:seekNodeByName(ui.root, "attackValue")
	--特殊技能图标
	self.specilIcon = UIManager:seekNodeByName(ui.root, "icon_special")
	--经验条
	self.loadingBar = UIManager:seekNodeByName(ui.root, "LoadingBar_medal")
	--英雄的勋章
	--self.heroMedal = UIManager:seekNodeByName(ui.root, "hero_medal")
	--英雄
	local node = Utils:createArmatureNode(self.curHeoInfo.display,"idle",true)
	node:setAnchorPoint(cc.p(0.5,0.5))
	node:setPosition(cc.p(256,237))
	node:setScale(1)
	self.panelRoot:addChild(node)
	
	--设置升级需要花费的材料
	self.ballNumber = UIManager:seekNodeByName(ui.root, "Text_ball")
	self.cookieNumber = UIManager:seekNodeByName(ui.root, "Text_cookie")
	self.diamondImg = UIManager:seekNodeByName(ui.root, "Image_diamond")
	--升级按钮
	self.growBtn = UIManager:seekNodeByName(ui.root, "Button_grow")
	local flag = UIHeroInfo:canGrow(self.curHeoInfo)
	Utils:addTouchEvent(self.growBtn, function(sender)
		UIHeroInfo:clickGrowBtn()
	end, true, true, 0)
	--最高等级
	self.maxText = UIManager:seekNodeByName(ui.root, "Text_maxLevel")
	self.maxText:setString(LanguageStr("HERO_INFO_MAX_LEVEL"))
	self.Panel_ball = UIManager:seekNodeByName(ui.root, "Panel_ball")
	self.Panel_cookie = UIManager:seekNodeByName(ui.root, "Panel_cookie")
	
	self.level:setString("Lv"..self.curHeoInfo.level)
	self.attack:setString(self.curHeoInfo.attack)
	UIHeroInfo:setHeroInfoUI(self.curHeoInfo)
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		if self.refreshFlag == true then
			UIHero:updateHeroInfo()
		end
		UIManager:close(self)		
	end, true, true, 0)
	if GuideMgr:isInGuide() then
		GuideUI:parseUIStep(self)
	end
	self.refreshFlag = false			--表示是否有点击升级按钮
end

--点击升级按钮触发的函数
function UIHeroInfo:clickGrowBtn()
	local flag,newBall,newCookie,oldBall,oldCookie = UIHeroInfo:canGrow(self.curHeoInfo)
	if flag ==false then
		UIManager:openFront(UIBuyMatrials,true)
		return
	end
	self.refreshFlag = true
	self.growBtn:setTouchEnabled(false)
	local newHeroInfo = LogicTable:get("hero_tplt", self.curHeoInfo.next_id, true)
	DataHeroInfo:updateHeroGrowInfo(self.curHeoInfo,newHeroInfo)
	
	self.tempAttack = newHeroInfo.attack - self.curHeoInfo.attack
	self.curHeoInfo = newHeroInfo
	
	ChannelProxy:recordCustom("stat_hero_upgrade")
	
	--cclog(flag,newBall,newCookie,oldBall,oldCookie)
	if oldBall ~= newBall then
		ItemModel:appendTotalBall(newBall - oldBall)
		
		local tb = {}
		tb.itemType = ItemType["ball"] 
		tb.oldAmount = oldBall
		tb.newAmount = newBall
		tb.flag = SignType["reduce"]
		EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
	end
	if oldCookie ~= newCookie then
		ItemModel:appendTotalCookie(newCookie - oldCookie)
		local tb = {}
		tb.itemType = ItemType["cookie"] 
		tb.oldAmount = oldCookie
		tb.newAmount = newCookie
		tb.flag = SignType["reduce"]
		EventDispatcher:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
	end
	UIHeroInfo:setHeroInfoUI(newHeroInfo)
	UIHeroInfo:levelUpAction()
	local effectIdList = {2307, 2308, 2309, 2310, 2311}
	local skillData = LogicTable:get("skill_tplt", newHeroInfo.skill_id, true)
	local skillElementData = LogicTable:get("element_tplt", skillData.element_id, true)
	--Log(skillElementData.extra_type,effectIdList[skillElementData.extra_type])
	AudioMgr:playEffect(effectIdList[skillElementData.extra_type])
	ChannelProxy:recordCustom("stat_hero_upgrade_success")
end

function UIHeroInfo:onTouch(touch, event, eventCode)
end

function UIHeroInfo:onUpdate(dt)
end

function UIHeroInfo:onDestroy()
	UIMiddlePub:getCollectNumberBall():stopAllActions()
	UIMiddlePub:getCollectNumberCookie():stopAllActions()
	UIMiddlePub:getCollectNumberDiamond():stopAllActions()
	UIMiddlePub:getCollectNumberBall():setString(ItemModel:getTotalBall())
	UIMiddlePub:getCollectNumberCookie():setString(ItemModel:getTotalCookie())
	UIMiddlePub:getCollectNumberDiamond():setString(ItemModel:getTotalDiamond())
	self.refreshFlag = false
end

--判断是否显示技能的动画
function UIHeroInfo:showSkillAction()
	local medalLevel = {1,5,10,15,20}
	for key,val in pairs (medalLevel) do
		if self.curHeoInfo.level == val  then
			return true
		end
	end
	return false
end

--获得动画的节点
function UIHeroInfo:getActionNode(index)
	if index == 1 then
		return self.level
	elseif index == 2 then
		return self.attackPanel
	elseif index == 3 then
		return self.skillPanel
	end
end

--设置动画节点的值
function UIHeroInfo:setNodeString(index,node)
	local particle = Utils:createParticle("hero_level_up.plist", true)
	particle:setPosition(cc.p(40,40))
	particle:setAnchorPoint(cc.p(0,0))
	if index == 1 then
		self.level:setString("Lv"..self.curHeoInfo.level)
	elseif index == 2 then
		self.attack:setString(self.curHeoInfo.attack)
	end
	--node:addChild(particle)
end

--升级动画
function UIHeroInfo:levelUpAction()
	local arr = {LanguageStr("HERO_LEVEL_UP"),LanguageStr("HERO_ATTACK"),LanguageStr("HERO_SKILL_UP")}
	local arrNumber = 2
	if UIHeroInfo:showSkillAction() then
		arrNumber = 3
	end
	for i = 1,arrNumber,1 do
		--提升的值设置
		local actionNode = UIHeroInfo:getActionNode(i)
		actionNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.5*(i -1)),cc.ScaleTo:create(0.3, 1.2), cc.CallFunc:create(function()
			UIHeroInfo:setNodeString(i,actionNode)
		end), cc.ScaleTo:create(0.3, 1.0)  ))
		
		--增加提升的文字
		local nameText = ccui.TextBMFont:create()
		nameText:setFntFile("font_08.fnt")
		nameText:setString(arr[i])
		nameText:setAnchorPoint(cc.p(0.5,0.5))
		nameText:setPosition(cc.p(255, 238))
		
		if i == 2 and nil ~= self.tempAttack then
			nameText:setString(arr[i]..self.tempAttack )
		end
		
		self.panelRoot:addChild(nameText)
		nameText:setOpacity(0)

		nameText:runAction(cc.Sequence:create(cc.DelayTime:create(0.5*(i -1)),cc.FadeIn:create(0.1),cc.ScaleTo:create(0.3, 1.5),cc.FadeOut:create(0.3)))
		nameText:runAction(cc.Sequence:create(cc.DelayTime:create(0.5*(i -1)),cc.FadeIn:create(0.1),
			cc.MoveTo:create(2, cc.vertex2F(G.VISIBLE_SIZE.width/2, 550)),
			cc.CallFunc:create(function()
			nameText:removeFromParent()
		end)))
	end
end



