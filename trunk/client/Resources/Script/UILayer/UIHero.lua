----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-7
-- Brief: 英雄界面
----------------------------------------------------------------------
UIDEFINE("UIHero", "Hero.csb")
local grayColor = cc.c3b(150,100,100)		--暗色
local formColor = cc.c3b(255,255,255)		--正常色
local scale = 1.0							--英雄的缩放比例

--创建已经解锁了的英雄panel
function UIHero:createUnlockPanel(cellBg,val,key,i)
	local platformImg = ccui.ImageView:create()	
	platformImg:loadTexture("hero_platform.png")
	platformImg:setPosition(cc.p(-12,25))
	platformImg:setAnchorPoint(cc.p(0,0))
	cellBg:addChild(platformImg)
		
	local node = Utils:createArmatureNode(val.display,"idle",true)
	node:setScale(scale)
	node:setAnchorPoint(cc.p(0.5,0))
	node:setPosition(cc.p(115,112))
	node:setColor(formColor)
	platformImg:addChild(node)
	--英雄的点击区域
	local nodeAdd = ccui.ImageView:create()	
	nodeAdd:loadTexture("touming.png")	
	nodeAdd:setScale9Enabled(true)
	nodeAdd:setCapInsets(cc.rect(0, 0, 0, 0))
	nodeAdd:setContentSize(cc.size(180,193))
	nodeAdd:setPosition(cc.p(115,112))
	nodeAdd:setAnchorPoint(cc.p(0.5,0))
	nodeAdd:setTouchEnabled(true)
	platformImg:addChild(nodeAdd)
	self:addTouchEvent(nodeAdd, function(sender)
		self.selectedInfo = val
		self.enterIndex = key
		self.inPage = i
		UIHeroInfo:openFront(true)
	end, true, true, 0)
	--选中某只英雄的粒子效果
	--[[
	if DataHeroInfo:isUnlockSelected(val.id) then
		local particleNode = cc.ParticleSystemQuad:create("defaultParticle.plist")
		particleNode:setPosition(cc.p(77,255 ))
		Utils:autoChangePos(particleNode)
		cellBg:addChild(particleNode)
	end
	]]--
	
	local enterBg = ccui.ImageView:create()	
	enterBg:loadTexture("hero_bag_bg.png")	
	enterBg:setPosition(cc.p(108,25))
	enterBg:setAnchorPoint(cc.p(0.5,0.5))
	platformImg:addChild(enterBg)
	
	
	local medalImg = ccui.ImageView:create()	
	medalImg:setName("page_"..key.."_medalImg")
	local maxLevel = DataHeroInfo:getMedalLevel(val)
	medalImg:loadTexture("medal_"..maxLevel..".png")	
	medalImg:setPosition(cc.p(8,-5.33))
	medalImg:setAnchorPoint(cc.p(0.5,0))
	enterBg:addChild(medalImg)
	
	local levelText = ccui.TextBMFont:create()
	levelText:setFntFile("font_01.fnt")
	levelText:setName("page_"..key.."_levelText")
	levelText:setString(val.level)
	levelText:setAnchorPoint(cc.p(0.5,0.5))
	--nameText:setScale(0.8)
	levelText:setPosition(cc.p(53, 20))
	medalImg:addChild(levelText)
	--[[
	local levelText = ccui.Text:create(val.level, "", 20)
	levelText:setName("page_"..key.."_levelText")
	levelText:setPosition(cc.p(35, 25))		
	levelText:setAnchorPoint(cc.p(0.5,0.5))
	enterBg:addChild(levelText)
	]]--
	local nameText = ccui.Text:create(val.name, "", 20)
	nameText:setPosition(cc.p(84, 10))
	nameText:setAnchorPoint(cc.p(0.5,0))
	enterBg:addChild(nameText)
	
	local btn = ccui.Button:create("enterHero.png")
	btn:setPosition(cc.p(79,72))
	btn:setTitleColor(cc.c3b(0, 255, 0))
	btn:setPropagateTouchEvents(false)
	self:addTouchEvent(btn, function(sender)
		self.selectedInfo = val
		self.enterIndex = key
		self.inPage = i
		UIHeroInfo:openFront(true)
	end, true, true, 0)
	enterBg:addChild(btn)
	
	local tipImg = ccui.ImageView:create()	
	tipImg:loadTexture("tip.png")	
	tipImg:setPosition(cc.p(7,56))
	tipImg:setAnchorPoint(cc.p(0.5,0.5))
	btn:addChild(tipImg)
	if DataHeroInfo:isMaterialEnough(val) == true then
		tipImg:setVisible(true)
		Actions:scaleAction04(btn, 2)
	else
		tipImg:setVisible(false)
	end
end

function UIHero:initPageView()
	--往翻页里面添加英雄
	local tb = DataHeroInfo:getHeroTb()
	for i=1,5,1 do
		local page = self:getChild("Panel_page_"..i)
		self.root:reorderChild(page,100)
		page:removeAllChildren()
		for key,val in pairs(tb[i]) do
			--panel：等级、名字、节点，按钮
			cellBg = ccui.Layout:create()
			cellBg:setContentSize(cc.size(201,250))
			local pos = {195,540}
			if key == 1 or key == 2 then
				cellBg:setPosition(cc.p(pos[key],630))
			elseif key == 3 or key == 4 then
				cellBg:setPosition(cc.p((pos[key - 2]),290))
			end
			cellBg:setAnchorPoint(cc.p(0.5,0.5))
			page:addChild(cellBg)
			Utils:autoChangePos(cellBg)
			if DataHeroInfo:isHeroUnlock(val.id) == true then
				UIHero:createUnlockPanel(cellBg,val,key,i)
			else
				local platformImg = ccui.ImageView:create()	
				platformImg:loadTexture("hero_platform.png")
				platformImg:setPosition(cc.p(-12,25))
				platformImg:setAnchorPoint(cc.p(0,0))
				--platformImg:setColor( cc.c3b(0,0,0))
				cellBg:addChild(platformImg)
				
				local node = Utils:createArmatureNode(val.display)
				node:setScale(scale)
				--node:setOpacity(65)
				node:setAnchorPoint(cc.p(0.5,0))
				node:setPosition(cc.p(115,112))
				node:setColor( cc.c3b(0,0,0))
				platformImg:addChild(node)
				
				--增加的点击解锁按钮
				if G.CONFIG["debug"] then
					local btn = ccui.Button:create("enterHero.png")
					btn:setPosition(cc.p(109,48))
					btn:setTitleText(LanguageStr("HERO_TIP_1"))
					btn:setTitleColor(cc.c3b(0,0,0))
					btn:setTitleFontSize(30)
					self:addTouchEvent(btn, function(sender)
						btn:setTouchEnabled(false)
						DataHeroInfo:setUnlockHeroTb(val.id)
						DataHeroInfo:setSelectHeroId(val.id,false)
						DataHeroInfo:getSelectHeroId()	
						
						self.inPage = i
						UIHero:initFiveElement(self.inPage)
						UIHero:initPageView()
						self.pageView:scrollToPage(self.inPage - 1)
					end, true, true, 0)
					platformImg:addChild(btn)
				end
			end
		end
	end
end

--根据元素是第几个，默认切换到第几页
function UIHero:initFiveElement(index)
--五个元素
	for i=1,5,1 do
		local icon =  self:getChild("icon_"..i)
		local tipBg = self:getChild("tipbg_"..i)
		local tipNumber = self:getChild("tip_"..i)
		local iconTb = DataHeroInfo:getFiveElementIcon()
		local number = DataHeroInfo:getGrowNumberByType(i)
		if number == 0 then
			tipBg:setVisible(false)
		else
			tipBg:setVisible(true)
			tipNumber:setString(number)
		end
		if i == index then
			icon:setColor(formColor)
		else
			icon:setColor(grayColor)
		end
		icon:loadTexture(iconTb[i])
		self:addTouchEvent(icon, function(sender)
			if self.selectedIndex == i then
				return
			end
			local iconLast = self:getChild("icon_"..self.selectedIndex)
			iconLast:setColor(grayColor)
			icon:setColor(formColor) 	
			self.selectedIndex = i	
			self.inPage = i			
			self.pageView:scrollToPage(i-1)
			if GuideMgr:isUIGuideOpen() then
				GuideUI:parseUIStep(self)
				self:setPageViewScroll(false)
			end
			AudioMgr:playEffect(2007)
		end, true, true, 0)
	end
end

function UIHero:onStart(ui, param)
	UIMiddlePub:showBackBtn(true)
	AudioMgr:playEffect(2007)
	if GuideMgr:isUIGuideOpen() then
		GuideUI:parseUIStep(self)
		self:setInitPage(3)
	end
	self.selectedIndex = self.initPage 
	--五个元素背景
	self.Panel_icon =  self:getChild("Panel_icon")
	--翻页容器
	self.pageView =  self:getChild("PageView")
	--Log(self.pageView:getPage)
	self.pageView:setCustomScrollThreshold(50)				--滑到一半，就变色(设置控件滑动的阀值)
	self.pageView:addEventListener( function( _sender, _type ) 
		local index = self.pageView:getCurPageIndex()
		if self.selectedIndex == index+1 then
			return
		end
		local iconLast = self:getChild("icon_"..self.selectedIndex)
		iconLast:setColor(grayColor)
		local icon = self:getChild("icon_"..index+1)
		icon:setColor(formColor)
		self.selectedIndex = index+1
		AudioMgr:playEffect(2007)
	end )
	self.pageView:setTouchEnabled(false)
	Utils:autoChangePos(self.pageView)
	
	--加上粒子效果
	local paricleTb = LogicTable:get("hero_scene", 1, true)
	for i, particle in pairs(paricleTb.particle) do
		local particlePos = paricleTb.paticle_pos[i]
		local particleNode = cc.ParticleSystemQuad:create(particle)
		particleNode:setPosition(cc.p(particlePos[1], particlePos[2]))
		Utils:autoChangePos(particleNode)
		self.pageView:addChild(particleNode,0)
	end
	UIHero:initFiveElement(self.initPage)
	--往翻页里面添加英雄
	UIHero:initPageView()
	self.pageView:scrollToPage(self.initPage - 1)
	
end

--设置默认切换到的页面
function UIHero:setInitPage(index)
	self.initPage = index or 1
end

--设置pageView可否活动
function UIHero:setPageViewScroll(flag)
	self.pageView:setTouchEnabled(flag)
	for key,val in pairs(self.pageView:getPages()) do
		local page = self:getChild("Panel_page_"..key)
		local btn = self:getChild("btn_pageview_"..key)
		if btn ~= nil then
			btn:setPropagateTouchEvents(false)
		end
		val:setTouchEnabled(flag)
	end
end

function UIHero:onTouch(touch, event, eventCode)
end

function UIBuyPower:onUpdate(dt)
end

function UIHero:onDestroy()
	
end

--更新当前选中的英雄信息
function UIHero:updateHeroInfo()
	UIMiddlePub:showBackBtn(true)
	UIHero:initFiveElement(self.inPage)
	UIHero:initPageView()
	self.pageView:scrollToPage(self.inPage - 1)
end

--获得当前选中的英雄信息
function UIHero:getCurHero()
	return self.selectedInfo,self.enterIndex
end

