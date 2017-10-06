----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-12-31
-- Brief: 英雄详细信息介绍界面
----------------------------------------------------------------------
UIDEFINE("UIHeroInfo", "HeroInfo.csb")
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
	local curBall = ModelItem:getTotalBall()
	local curCookie = ModelItem:getTotalCookie()
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
		local medalImg = self:getChild("medal_"..i)
		if i<= maxLevel then
			medalImg:setColor(cc.c3b(255,255,255))
		else
			medalImg:setColor(cc.c3b(150,100,100))
		end
	end
	
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
	self.root = ui.root
	local Text_attack_l = self:getChild("Text_attack_l")
	Text_attack_l:setString(LanguageStr("HERO_INFO_ATTACK"))
	local Text_skill_l = self:getChild("Text_skill_l")
	Text_skill_l:setString(LanguageStr("HERO_INFO_SKILL"))
	
	AudioMgr:playEffect(2007)
	self.tempBall,self.tempCookie = 0, 0
	self.curHeoInfo = UIHero:getCurHero()
	--Log(self.curHeoInfo)
	
	--底板
	local Image_gray = self:getChild("Image_gray")
	Image_gray:setOpacity(0)
	--名字
	local name = self:getChild("name")
	name:setString(self.curHeoInfo.name)
	--攻击力底板、技能底板、相关元素的根节点
	self.attackPanel = self:getChild("Panel_attack")
	self.skillPanel = self:getChild("Panel_skill")
	self.panelRoot = self:getChild("Image_115")
	--等级
	self.level = self:getChild("level")
	self.level:setString("LV"..self.curHeoInfo.level)				--等级有待再处理
	--元素图标
	local elementIcon = self:getChild("icon")
	elementIcon:loadTexture( DataHeroInfo:getFiveElementIcon()[self.curHeoInfo.type])
	--攻击力
	self.attack = self:getChild("attackValue")
	--特殊技能图标
	self.specilIcon = self:getChild("icon_special")
	--经验条
	self.loadingBar = self:getChild("LoadingBar_medal")
	--英雄的勋章
	--self.heroMedal = self:getChild("hero_medal")
	--英雄
	local node = Utils:createArmatureNode(self.curHeoInfo.display,"idle",true)
	node:setAnchorPoint(cc.p(0.5,0.5))
	node:setPosition(cc.p(256,237))
	node:setScale(1)
	self.panelRoot:addChild(node)
	self.heroIdleNode = node
	
	--Log("根节点************",node:getWorldPosition())
	--设置升级需要花费的材料
	self.ballNumber = self:getChild("Text_ball")
	self.cookieNumber = self:getChild("Text_cookie")
	self.diamondImg = self:getChild("Image_diamond")
	--升级按钮
	self.growBtn = self:getChild("Button_grow")
	local flag = UIHeroInfo:canGrow(self.curHeoInfo)
	self:addTouchEvent(self.growBtn, function(sender)
		UIHeroInfo:clickGrowBtn()
	end, true, true, 0)
	--最高等级
	self.maxText = self:getChild("Text_maxLevel")
	self.maxText:setString(LanguageStr("HERO_INFO_MAX_LEVEL"))
	self.Panel_ball = self:getChild("Panel_ball")
	self.Panel_cookie = self:getChild("Panel_cookie")
	
	self.level:setString("Lv"..self.curHeoInfo.level)
	self.attack:setString(self.curHeoInfo.attack)
	UIHeroInfo:setHeroInfoUI(self.curHeoInfo)
	-- 关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		if self.refreshFlag == true then
			UIHero:updateHeroInfo()
		end
		self:close()		
	end, true, true, 0)
	if GuideMgr:isUIGuideOpen() then
		GuideUI:parseUIStep(self)
	end
	self.refreshFlag = false			--表示是否有点击升级按钮
end

--点击升级按钮触发的函数
function UIHeroInfo:clickGrowBtn()
	local flag,newBall,newCookie,oldBall,oldCookie = UIHeroInfo:canGrow(self.curHeoInfo)
	if flag ==false then
		UIBuyMatrials:openFront(true)
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
		ModelItem:appendTotalBall(newBall - oldBall)
		
		--UIMiddlePub:getCollectNumberBall():setString(ModelItem:getTotalBall())
		--UIMiddlePub:getCollectNumberDiamond():setString(ModelItem:getTotalDiamond())
		local tb = {}
		tb.itemType = ItemType["ball"] 
		tb.oldAmount = oldBall
		tb.newAmount = newBall
		tb.flag = SignType["reduce"]
		EventCenter:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
	end
	if oldCookie ~= newCookie then
		ModelItem:appendTotalCookie(newCookie - oldCookie)
		
		--UIMiddlePub:getCollectNumberCookie():setString(ModelItem:getTotalCookie())
		local tb = {}
		tb.itemType = ItemType["cookie"] 
		tb.oldAmount = oldCookie
		tb.newAmount = newCookie
		tb.flag = SignType["reduce"]
		EventCenter:post(EventDef["ED_CHANGE_REWARD_DATA"],tb) 
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
	UIMiddlePub:getCollectNumberBall():setString(ModelItem:getTotalBall())
	UIMiddlePub:getCollectNumberCookie():setString(ModelItem:getTotalCookie())
	UIMiddlePub:getCollectNumberDiamond():setString(ModelItem:getTotalDiamond())
	
	self.refreshFlag = false
	self.attack = nil
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
function UIHeroInfo:numberChange(widget,currNumber,lastNumber)
	if isNil(widget) then return end
	widget:stopAllActions()
	changeCount = currNumber - lastNumber
	local function innerChange()
		changeCount = changeCount - 1
		if changeCount < 0 then return end
		lastNumber = lastNumber + 1
		Actions:delayWith(widget, 0.005, function()
			widget:setString(lastNumber)
			innerChange()
		end)
	end
	innerChange()
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
	if index == 1 then
		--self.level:setString("Lv"..self.curHeoInfo.level)
	elseif index == 2 then
		--self.attack:setString(self.curHeoInfo.attack)
		--UIHeroInfo:numberChange(self.attack,self.curHeoInfo.attack,self.curHeoInfo.attack - self.tempAttack)
		self.level:setString("Lv"..self.curHeoInfo.level)
	end
end

local heroActionFullFlag = false
local textActionFullFlag = false

--升级动画
function UIHeroInfo:levelUpAction()
	--self.heroIdleNode:setVisible(false)
	self.heroIdleNode:setOpacity(0)
	--底板
	local Image_gray = self:getChild("Image_gray")
	Image_gray:setTouchEnabled(true)
	
	Image_gray:runAction(cc.Spawn:create(cc.FadeIn:create(0.5),cc.CallFunc:create(function()
				--Image_gray:setOpacity(100)
			end)))
	--字体飞完以后的动画
	local arr = {LanguageStr("HERO_ATTACK"),LanguageStr("HERO_ATTACK"),LanguageStr("HERO_SKILL_UP")}
	local arrNumber = 2
	if UIHeroInfo:showSkillAction() then
		arrNumber = 3
	end
	--旋转的光线
	local Image_radiao = self:getChild("Image_radiao")
	Image_radiao:runAction(cc.RepeatForever:create(cc.RotateBy:create(1.0,30)))
	Image_radiao:setOpacity(255)
	Image_radiao:setScale(0.8)
	Image_radiao:runAction(cc.Sequence:create(cc.ScaleTo:create(0.4,0.5),cc.ScaleTo:create(0.1, 0.6)))
	Image_radiao:setOpacity(255)
	--Image_radiao:setScale(0.6)
	Image_radiao:setPosition(cc.p(360,582))
	
	--英雄
	local heroNode = Utils:createArmatureNode(self.curHeoInfo.display,"idle",false)
	heroNode:setAnchorPoint(cc.p(0.5,0.5))
	heroNode:setPosition(cc.p(400,583))
	--heroNode:setScale(1.5)
	local action1 = cc.Spawn:create(cc.ScaleTo:create(0.5,1.5),cc.MoveTo:create(0.5,cc.vertex2F(360, 583)))
	heroNode:runAction(cc.Sequence:create(action1, cc.CallFunc:create(function()
			Utils:playArmatureAnimation(heroNode, "win", false,function(armatureBack, movementType, movementId)
				
				if ccs.MovementEventType.complete == movementType and "win" == movementId then
					heroActionFullFlag =  true
					--cclog("text先完结",textActionFullFlag,heroActionFullFlag)
					if textActionFullFlag == true then
					--cclog("text先完结")
						Image_radiao:setScale(0)
						Image_gray:runAction(cc.Sequence:create(cc.FadeOut:create(1.0),cc.CallFunc:create(function()
							if isNil(heroNode) then return end
							heroNode:removeFromParent()
							Image_gray:setTouchEnabled(false)
							--self.heroIdleNode:setVisible(true)
							--self.heroIdleNode:setOpacity(255)
							self.heroIdleNode:runAction(cc.FadeIn:create(0.2))
							UIHeroInfo:numberChange(self.attack,self.curHeoInfo.attack,self.curHeoInfo.attack - self.tempAttack)
						end)))
						textActionFullFlag = false
						heroActionFullFlag = false
						--heroNode:removeFromParent()
					end
				end
				
			end)
	end)))
	Image_gray:addChild(heroNode)

	--升级成功图片
	local successImg = ccui.ImageView:create()	
	successImg:loadTexture("level_up_success.png")
	successImg:setPosition(cc.p(360,600))
	successImg:setAnchorPoint(cc.p(0.5,0.5))
	Image_gray:addChild(successImg)			
	--Image_gray:setOpacity(0)
	successImg:setOpacity(0)
	successImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeIn:create(0.1),
		cc.MoveTo:create(0.1, cc.vertex2F(360, 700)),
		cc.MoveTo:create(0.5, cc.vertex2F(360, 780)),
		cc.FadeOut:create(0.5),
		cc.CallFunc:create(function()
			successImg:removeFromParent()
	end)))

	--设置等级，文字向上飞
	for i = 2,arrNumber,1 do
		--提升的值设置
		local actionNode = UIHeroInfo:getActionNode(i)
		UIHeroInfo:setNodeString(i,actionNode)
		
		--增加提升的文字
		--[[
		local nameText = ccui.Text:create()
		nameText:setFontSize(18)
		nameText:enableOutline(cc.c4b(83,43,17,255),3)
		nameText:setString(arr[i])
		nameText:setAnchorPoint(cc.p(0.5,0.5))
		nameText:setPosition(cc.p(209, 602 -(i - 2)*100))
	]]
		local nameText = ccui.TextBMFont:create()
		if ChannelProxy:isEnglish() then
			nameText:setFntFile("font_01.fnt")
		else
			nameText:setFntFile("font_08.fnt")
		end
		nameText:setString(arr[i])
		nameText:setAnchorPoint(cc.p(0.5,0.5))
		--nameText:setScale(0.8)
		nameText:setPosition(cc.p(360, 600))
		
		if nil ~= self.tempAttack and i == 2 then	
			nameText:setString(arr[i]..self.tempAttack )
		end
		Image_gray:addChild(nameText)
		nameText:setOpacity(0)
		local delayTime = 1.2
		if i == 3 then
			delayTime = 2.0
		end
		nameText:runAction(cc.Sequence:create(cc.DelayTime:create(delayTime),cc.FadeIn:create(0.1),
			cc.MoveTo:create(0.1, cc.vertex2F(360,700)),
			cc.MoveTo:create(0.5, cc.vertex2F(360,780)),
			cc.FadeOut:create(0.5),
			cc.CallFunc:create(function()
				nameText:removeFromParent()
				
				--Image_radiao:setScale(0)
				--heroNode:removeFromParent()
				if arrNumber == i then
					textActionFullFlag = true 
					--cclog("hero先完结",textActionFullFlag,heroActionFullFlag)
				end
				if heroActionFullFlag == true and arrNumber == i then
					--cclog("hero先完结")
					Image_radiao:setScale(0)
					Image_gray:runAction(cc.Sequence:create(cc.FadeOut:create(1.0),cc.CallFunc:create(function()
							if isNil(heroNode) then return end
							heroNode:removeFromParent()
							Image_gray:setTouchEnabled(false)
							UIHeroInfo:numberChange(self.attack,self.curHeoInfo.attack,self.curHeoInfo.attack - self.tempAttack)
							--self.heroIdleNode:setVisible(true)
							
							self.heroIdleNode:runAction(cc.FadeIn:create(0.2))
							--self.heroIdleNode:setOpacity(255)
					end)))
					
					
					textActionFullFlag = false
					heroActionFullFlag = false
				end
			end)
		))
	end
end



