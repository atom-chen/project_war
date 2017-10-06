----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-1-15
-- Brief: 战斗信息界面
----------------------------------------------------------------------
UICopyInfo = {
	csbFile = "CopyInfo.csb"
}

local mScrollSkillTb = {}		--保存scrollView所有技能球控件
--加载顶部目标的的图片和剩余个数
function UICopyInfo:loadGoals()
	for i=1,3,1 do
		local icon = UIManager:seekNodeByName(self.root, "Icon_"..i)
		local amount = UIManager:seekNodeByName(self.root, "Text_goal_"..i)
		local iconBg = UIManager:seekNodeByName(self.root, "ImageBg_"..i)
		local goals = CopyModel:getGoals()
		if #goals >= i then
			local iconStr = DataLevelInfo:getIconStrById(goals[i].id)
			icon:loadTexture(iconStr)
			amount:setString(tostring(goals[i].count))
		else
			icon:setVisible(false)
			amount:setVisible(false)
			iconBg:setVisible(false)
		end
	end
end

--添加英雄信息
function UICopyInfo:addPanel()
	local page = UIManager:seekNodeByName(self.root, "Panel_info")
	if page ~= nil then
		page:removeFromParent()
	end
	local pane_1 = UIManager:seekNodeByName(self.root, "Image_26")
	local page = ccui.Layout:create()
	page:setName("Panel_info")
	page:setContentSize(cc.size(407,63))
	page:setBackGroundImageScale9Enabled(true)
	page:setBackGroundImageCapInsets(cc.rect(30, 30, 30, 30))
	page:setPosition(cc.p(250.81, 130))
	page:setAnchorPoint(cc.p(0.5,0.5))
	pane_1:addChild(page)
	local skillImg = ccui.ImageView:create()	
	skillImg:loadTexture("touming.png")
	skillImg:setTouchEnabled(true)
	skillImg:setName("elementIcon")
	skillImg:setPosition(cc.p(36.67,31.11))
	skillImg:setScale(0.4)
	skillImg:setAnchorPoint(cc.p(0.5,0.5))
	page:addChild(skillImg)
	local levelText = ccui.Text:create("", "", 20)
	levelText:setPosition(cc.p(192, 33.34))
	levelText:setName("heroInfo")
	levelText:setColor(cc.c3b(64,10,10))
	levelText:setAnchorPoint(cc.p(0.5,0.5))
	page:addChild(levelText)
end

--获取添加英雄信息
function UICopyInfo:getData(id)
	local pageData,unlockCount = DataHeroInfo:getAllUnlockTypeTb(id)
	local data = {}
	for key,val in pairs(pageData) do
		local ItemData = val
		ItemData.unlock = DataHeroInfo:isHeroUnlock(val.id)
		--表示是同类英雄中的第几个
		local heroIndex = DataHeroInfo:getIndexById(val.id)
		ItemData.heroIndex = heroIndex
		if	ItemData.unlock == true then
			table.insert(data,ItemData)
		end
	end
	return data,unlockCount
end

--获取添加英雄信息
function UICopyInfo:showHeroInfoAction(ItemData)
	UICopyInfo:addPanel()
	local selectTip = UIManager:seekNodeByName(self.root, "text_select")
	if nil ~= selectTip then
		selectTip:setVisible(false)
	end
	local panelInfo = UIManager:seekNodeByName(self.root, "Panel_info")
	panelInfo:stopAllActions()
	local function CallFucnCallback1()
		panelInfo:removeFromParent()
		if nil ~= selectTip then
			selectTip:setVisible(true)
		end
	end
	local icon = UIManager:seekNodeByName(self.root, "elementIcon")
	local heroInfo = UIManager:seekNodeByName(self.root, "heroInfo")
	local iconString = DataHeroInfo:getFiveElementIcon()[ItemData.type]
	icon:loadTexture(iconString)
	heroInfo:setString(ItemData.name..LanguageStr("COPYINFO_LEVEL")..ItemData.level..LanguageStr("COPYINFO_ATTACK")..ItemData.attack)
	DataHeroInfo:setSelectHeroId(ItemData.id,true)
	panelInfo:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(1.5),cc.CallFunc:create(CallFucnCallback1)))
end

--根据i和j的个数，判断是第几个值(i == 第几个scrollview，j == scroll中的第几个)
function UICopyInfo:getIndexByNumber(i,j)
	local pageData,unlockCount = DataHeroInfo:getAllUnlockTypeTbByType(i)
	local data = {}
	for key,val in pairs(pageData) do
		local ItemData = val
		ItemData.unlock = DataHeroInfo:isHeroUnlock(val.id)
		--表示是同类英雄中的第几个
		local heroIndex = DataHeroInfo:getIndexById(val.id)
		ItemData.heroIndex = heroIndex
		if	ItemData.unlock == true then
			table.insert(data,ItemData)
		end
	end
	local index = data[j].heroIndex
	return (i - 1)* 3 + index
end

--显示与隐藏技能图标(row == 第几个scrollview，realIndex == scroll中的第几个，count == scroll中cell的个数)
function UICopyInfo:showHideSkillIcon(row,realIndex,count)
	local index = UICopyInfo:getIndexByNumber(row,realIndex) 	
	local skillImg = mScrollSkillTb[index]
	if "" ~= skillImg then 	
		skillImg:setVisible(true)
		Actions:fadeIn(skillImg, 0.5)
		for key = 1,count,1 do 
			if key ~= realIndex then
				local index = UICopyInfo:getIndexByNumber(row,key)
				local skillImg = mScrollSkillTb[index]
				if isNil(skillImg) then return end
				Actions:fadeOut(skillImg, 0.5)
			end
		end	
	end
end

--根据个数和第几个，设置滑到的位置
function UICopyInfo:scrollToPercent(pageView,heroIndex,count,internal)
	pageView:stopAllActions()
	if heroIndex == 1 then
		pageView:scrollToPercentVertical(0, internal, false)
	elseif	heroIndex == 2 and count == 3 then
		pageView:scrollToPercentVertical(50, internal, false)
	elseif heroIndex == count then
		pageView:scrollToPercentVertical(100, internal, false)
	end
end

function UICopyInfo:setIndexByY(posiY,count)
	local realIndex = 0
	if posiY >= -187 and posiY < -160 and count == 3 then
		realIndex = 1
	end
	if posiY >= -107 and posiY < -10 and count == 2 then
		realIndex = 1
	end
	return realIndex
end

--加载英雄信息
function UICopyInfo:initUIScrollViews()
	local unlockHeroId = DataMap:getSelectedHeroIds()
	for i=1,5,1 do
		local pageView = UIManager:seekNodeByName(self.root, "ScrollView_"..i)
		pageView:removeAllChildren()
		pageView.nCurOffect = 0
		pageView:setInertiaScrollEnabled(false)

		if unlockHeroId[i] ~= nil then		--加载一页或多页
			local data,count = UICopyInfo:getData(unlockHeroId[i])
			local startH,endH = 0,0				--必须写在外面，容易被移动的时候改变
			--创建列表单元格
			local function createCell(page, ItemData, index)
				local page = ccui.Layout:create()
				page:setContentSize(cc.size(77,80))
				page:setName("scroll_panel_"..index)
				page:setPosition(cc.p(0,0))
				page:setAnchorPoint(cc.p(0,0))
				page:setTouchEnabled(true)
				page:addTouchEventListener( function( _sender, _type )	
					if  _type == ccui.TouchEventType.began  then
						 startH = pageView:getInnerContainer():getPositionY()
					elseif _type == ccui.TouchEventType.moved  then
						
						movedH = pageView:getInnerContainer():getPositionY()                                                                                                                             
						local tempH = movedH - startH			--滑过的高度
						local offset = math.floor(math.abs(tempH)/40)		--偏移的英雄个数 45为半个cell高度
						if 0 == offset then 
							self:showHideSkillIcon(i,index,count)
							return	
						end
						local realIndex = index				--滑动后，应该选中的英雄的index
						if tempH >0 then			--向上滑
							realIndex = realIndex + offset
						elseif tempH < 0 then		--向下滑
							realIndex = realIndex - offset
						end
						newIndex = UICopyInfo:setIndexByY(movedH,count)
						if newIndex ~= 0 then
							realIndex = newIndex
						end
						if realIndex <= 1 then
							realIndex = 1
						elseif realIndex >= count then
							realIndex = count
						end
						--显示与隐藏技能图标
						self:showHideSkillIcon(i,realIndex,count)			
					elseif _type == ccui.TouchEventType.ended or _type == ccui.TouchEventType.canceled then
						endH = pageView:getInnerContainer():getPositionY()                                                                                                                             
						local tempH = endH - startH			--滑过的高度
						local offset = math.floor(math.abs(tempH)/40)	--偏移的英雄个数 45为半个cell高度
						local realIndex = index				--滑动后，应该选中的英雄的index
						if tempH >0 then			--向上滑
							realIndex = realIndex + offset
						elseif tempH < 0 then		--向下滑
							realIndex = realIndex - offset
						end
						
						if realIndex <= 1 then
							realIndex = 1
						elseif realIndex >= count then
							realIndex = count
						end	
						
						newIndex = UICopyInfo:setIndexByY(endH,count)
						if newIndex ~= 0 then
							realIndex = newIndex
						end
						--滑到对应的位置
						self:scrollToPercent(pageView,realIndex,count,0.01)
						--显示与隐藏技能图标,只点击的时候肯定调用
						self:showHideSkillIcon(i,realIndex,count)
						-- 显示英雄信息
						UICopyInfo:showHeroInfoAction(data[realIndex])	
						if DataMap:isGuideComplete() == false and DataMap:getPass() == (G.GUIDE_CHANGE_HERO + 1) and data[realIndex].id ~= 1101 then
							DataMap:setGuideComplete()			--新手新增
							DataMap:setUIGuideInfo({6,22})
							local imageShield = UIManager:seekNodeByName(self.root, "Image_sheild")
							imageShield:setVisible(false)
							imageShield:setTouchEnabled(false)
							GuideUI:parseUIStep(self)
						end
						--统计更换英雄（第一次）
						if DataMap:getChangeHeroFlag() == false then	
							ChannelProxy:recordCustom("stat_copy_start_choice_hero")
							DataMap:setChangeHeroFlag(true)	
						end			
					end	
				end )
				pageView:addChild(page)
				--英雄
				local heroImg = Utils:createArmatureNode(ItemData.display)
				heroImg:setPosition(cc.p(38,15))
				heroImg:setAnchorPoint(cc.p(0.5,0))
				heroImg:setScale(0.35)
				page:addChild(heroImg)
				--技能
				local skillImg = ccui.ImageView:create()	
				local imgstring = DataHeroInfo:getSkillIconById(ItemData.skill_id)
				skillImg:loadTexture(imgstring)
				skillImg:setPosition(cc.p(38,10.5))
				skillImg:setScale(0.45)
				skillImg:setName("skill_"..i..index)
				skillImg:setAnchorPoint(cc.p(0.5,0.5))
				page:addChild(skillImg)
				--初始化技能球控件tb
				mScrollSkillTb[(i - 1)*3 + ItemData.heroIndex] = skillImg
				return page
			end
			UIScrollViewEx.show(pageView, data, createCell,"V", 77, 80, 0, 1, 3, false, nil, true, true)
			
			local realIndex = 1	--获得选择的英雄是三只英雄中的那一只
			local idTb = {}
			for key,val in pairs(data) do
				table.insert(idTb,val.id)
			end
			for key,val in pairs(idTb) do
				if val == unlockHeroId[i] then
					realIndex = key
				end
			end
			
			--根据上次选中的英雄，滑到对应的位置，并显示上翻或下翻的图片
			local heroIndex = DataHeroInfo:getIndexById(unlockHeroId[i])
			self:showHideSkillIcon(i,realIndex,count)	
			if heroIndex > count then
				heroIndex = count
			end
			self:scrollToPercent(pageView,heroIndex,count,0.05)		
		else								--加载加锁的一页
			local imageView = ccui.ImageView:create()	
			imageView:loadTexture("Lock_01.png")
			imageView:setPosition(cc.p(38,42))
			imageView:setAnchorPoint(cc.p(0.5,0.5))
			pageView:addChild(imageView)
			pageView:scrollToPercentVertical(90, 0.1, false)
			pageView:addTouchEventListener( function( _sender, _type )	
				if _type == ccui.TouchEventType.ended or _type == ccui.TouchEventType.canceled then
					self:clickUnlockCell()
				end
			end )
		end
	end
end

--点击未解锁英雄的锁
function UICopyInfo:clickUnlockCell()
	self:addLockTipPanel()
	local panelInfo = UIManager:seekNodeByName(self.root, "Panel_info")
	panelInfo:stopAllActions()
	
	local selectTip = UIManager:seekNodeByName(self.root, "text_select")
	if nil ~= selectTip then
		selectTip:setVisible(false)
	end
	local function CallFucnCallback1()
		panelInfo:removeFromParent()
		if nil ~= selectTip then
			selectTip:setVisible(true)
		end
	end
	panelInfo:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.FadeOut:create(1.5),cc.CallFunc:create(CallFucnCallback1)))
end

--添加未解锁提示信息
function UICopyInfo:addLockTipPanel()
	local page = UIManager:seekNodeByName(self.root, "Panel_info")
	if page ~= nil then	page:removeFromParent()	end
	local pane_1 = UIManager:seekNodeByName(self.root, "Image_26")
	local page = ccui.Layout:create()
	page:setName("Panel_info")
	page:setContentSize(cc.size(407,63))
	page:setBackGroundImageScale9Enabled(true)
	page:setBackGroundImageCapInsets(cc.rect(30, 30, 30, 30))
	page:setPosition(cc.p(250.81, 130))
	page:setAnchorPoint(cc.p(0.5,0.5))
	pane_1:addChild(page)
	local levelText = ccui.Text:create(LanguageStr("COPY_INFO_LOCK_TIP"), "", 20)
	levelText:setPosition(cc.p(192, 33.34))
	levelText:setName("heroInfo")
	levelText:setColor(cc.c3b(64,10,10))
	levelText:setAnchorPoint(cc.p(0.5,0.5))
	page:addChild(levelText)
end

function UICopyInfo:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self:subscribeEvent(EventDef["ED_GAME_INIT"], self.onGameInit)
	--初始化15个技能球的控件
	for i=1,5,1 do
		for j = 1,3,1 do
			table.insert(mScrollSkillTb,"")
		end
	end
	
	local temp = UIManager:seekNodeByName(ui.root, "Image_26")
	--根据当前打的副本，获得副本的信息
	self.copyInfo = LogicTable:get("copy_tplt", DataMap:getPass(), false)
	--选择英雄建立你的队伍
	self.Text_select = UIManager:seekNodeByName(ui.root, "Text_select")
	self.Text_select:enableOutline(cc.c4b(62,11,10,255),3)
	self.Text_select:setString(LanguageStr("COPYINFO_TEAM"))
	--最大步数
	self.mLeftMoves = UIManager:seekNodeByName(ui.root, "Text_move")
	self.mLeftMoves:setString(self.copyInfo.moves)
	--副本名
	local copyName = UIManager:seekNodeByName(ui.root, "Text_name")
	copyName:setString(DataMap:getPass())
	
	create_message_background(ui.root)
	-- 关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		DataHeroInfo:getSelectHeroId()
		UIManager:close(self)
	end, true, true, 0)
	-- 开始按钮
	local btnRestart = UIManager:seekNodeByName(ui.root, "Button_start")
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
		DataHeroInfo:getSelectHeroId()
		if DataMap:getPass() ~= DataMap:getLastPass() then
			DataLevelInfo:setFailTimes(0)
		end
		UIManager:close(self)
		UIManager:close(UIMain)
		UIManager:close(UIMiddlePub)
		ItemModel:clearCollect()
		UIManager:openFixed(UIGameGoal)		-- 打开中间界面
		DataMap:setLevel(level)
		MapManager:create(DataMap:getPass(),DataMap:getSelectedHeroIds())
		AudioMgr:playMusic(1002)--主战音乐		
		ChannelProxy:recordCustom("stat_copy_target")
		ChannelProxy:recordLevelStart(DataMap:getPass())
	end, true, true, 0)
	--设置消耗体力
	local power = UIManager:seekNodeByName(ui.root, "Text_power")
	power:setString(self.copyInfo.hp)
	self:loadGoals()
	UICopyInfo:initUIScrollViews()
	
	--为新手增加的遮罩层
	local imageShield = UIManager:seekNodeByName(ui.root, "Image_sheild")
	imageShield:setVisible(false)
	imageShield:setTouchEnabled(false)
	
	--游戏目标
	local Text_game_goal_l = UIManager:seekNodeByName(ui.root, "Text_game_goal_l")
	Text_game_goal_l:setString(LanguageStr("COPYINFO_GAME_GOALS"))
	--步数
	local Text_moves_l = UIManager:seekNodeByName(ui.root, "Text_moves_l")
	Text_moves_l:setString(LanguageStr("COPYINFO_GAME_MOVES"))
	
	if GuideMgr:isUIGuideOpen() and DataMap:isGuideComplete() == false and DataMap:getPass() == (G.GUIDE_CHANGE_HERO + 1) then
		GuideMgr:startUI()
		GuideUI:parseUIStep(self)
		
		imageShield:setVisible(true)
		imageShield:setTouchEnabled(true)
	end
end

--创建消息框背景图片
function create_message_background(root)
	local page = UIManager:seekNodeByName(root, "Panel_info")
	if page ~= nil then
		page:removeFromParent()
	end
	local pane_1 = UIManager:seekNodeByName(root, "Image_26")
	
	local message_background = ccui.Layout:create()
	message_background:setContentSize(cc.size(407,63))
	message_background:setBackGroundImageScale9Enabled(true)
	message_background:setBackGroundImage("public_4.png")
	message_background:setBackGroundImageCapInsets(cc.rect(30, 30, 30, 30))
	message_background:setPosition(cc.p(250.81, 130))
	message_background:setAnchorPoint(cc.p(0.5,0.5))
	pane_1:addChild(message_background)
	
	if DataHeroInfo:canShowScrollTip() then
		local levelText = ccui.Text:create(LanguageStr("COPY_INFO_SELECT_TIP"), "", 20)
		levelText:setPosition(cc.p(208, 33.34))
		levelText:setName("text_select")
		levelText:setColor(cc.c3b(64,10,10))
		levelText:setAnchorPoint(cc.p(0.5,0.5))
		message_background:addChild(levelText)
	end
end

function UICopyInfo:onTouch(touch, event, eventCode)
end

function UICopyInfo:onUpdate(dt)
end

function UICopyInfo:onDestroy()
	mScrollSkillTb = {}
end

function UICopyInfo:onGameInit(param)

end

