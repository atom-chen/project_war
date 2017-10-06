----------------------------------------------------------------------
-- Author: yejt
-- Date: 2014-12-30
-- Brief: 副本界面
----------------------------------------------------------------------
UIMain = {
	csbFile = "copy.csb"
}

------------------------------------------------------------------------------------
-- 策划配置区域
------------------------------------------------------------------------------------
function UIMain:configData()
	self.CAN_LOOK_OTHER		= 1							-- 可以看到上面的几瓶
	self.COME_NACK_TIME		= 0.5						-- 会弹时间
	self.COME_BACK_MORE		= 0.1						-- 会弹再回弹的时间
end

-- 通过一个会弹量计算再次会弹的量
function UIMain:calcMoreBack( nBack )
	return 0--nBack*0.2/960
end

------------------------------------------------------------------------------------
-- 程序执行区域
------------------------------------------------------------------------------------
function UIMain:onStart(ui, param)
	self.mScrollView = UIManager:seekNodeByName( ui.root, "ScrollView_1" )
	self.mScrollView:setBounceEnabled(false)
	self.mRoot = UIManager:seekNodeByName( ui.root, "Node" )
	self:onGameInit(param)
	ChannelProxy:recordCustom("stat_enter_main")	-- 友盟统计
	
	AudioMgr:playMusic(1001)					-- 主页音乐
end

function UIMain:onTouch(touch, event, eventCode)
	
end

function UIMain:onUpdate(dt)
end

function UIMain:onDestroy()
end

-- 界面初始化  整个界面从这里开始
function UIMain:onGameInit(param)
	self:initData()			-- 初始化数据
	self:initView()			-- 初始化界面
	self:initEvent()		-- 初始化事件
end

-- 初始化事件
function UIMain:initEvent()
	local function handleScroll( _sender, _type )
		if 0 == _type then
			self:dealScroll()
		elseif 1 == _type then
			self:createSomeScreenDown()
		elseif 4 == _type then
			if not self.bTouch and self.bAutoSel then
				self.mScrollView:stopAllActions()
				Actions:delayWith(self.mScrollView, 0.1, function() self:scrollToSel() self.bAutoSel = false self.mScrollView:stopAllActions() end)
				--self.mScrollView:runAction(cc.Sequence:create({ cc.DelayTime:create(0.1), cc.CallFunc:create(function() self:scrollToSel() self.mScrollView:stopAllActions() end) }))
			end
		end
	end
	self.mScrollView:addEventListener( function( ... ) handleScroll( ... )  end )
	
	local function handleTouch( _sender, _type )
		if ccui.TouchEventType.ended == _type or ccui.TouchEventType.canceled == _type then
			self.mScrollView:stopAllActions()
			self:scrollToSel()
			self.bTouch	= false
			self.bAutoSel = true
		elseif ccui.TouchEventType.began == _type then
			self.mScrollView:stopAllActions()
			self.bTouch	= true
			self.bAutoSel = false
		end
	end
	self.mScrollView:addTouchEventListener( function( ... ) handleTouch( ... ) end )
	
	self:subscribeEvent(EventDef["ED_UPDATA_COPY_BTN"], function( nCopyId ) 
		local btnCopy = UIManager:seekNodeByName( self.mScrollView, "btnCopy" .. nCopyId )
		btnCopy:removeAllChildren(true)
		self:createCopyID(btnCopy, nCopyId, false)
	end)
end

-- 初始化数据
function UIMain:initData()
	self:configData()
	
	self.m_nCurScreen 		= 0							-- 当前创建到了几屏
	self.CREATE_ONECE 		= 5							-- 一次创建几屏
	self.m_bIsCreate  		= false						-- 是否正在创建
	self.nMastCopy			= self:getMostCopy()		-- 获取当前打到的最高的层数
	self.m_nAllCount 		= self:calcCurSumScreen()	-- 总共的屏幕数
	self.m_nCurLowScreen	= 0							-- 当前最低的一屏的Id
	self.nCurSelScreen		= self:getCurCanFightScreen()
	self.bTouch				= false						-- 判断当前是否有按住
	self.bAutoSel			= false						-- 是否自动移动回原来的
	
	self.mScreenHeight		= 960--self:getScreenHeight()	-- 当前屏幕的大小
	
	self:calcEnterScreen()
end

-- 初始化界面
function UIMain:initView()
	self.uiTime	= ccui.Widget:create()					-- 创建一个倒计时的控件
	self.mRoot:addChild(self.uiTime)
	
	self.layerContent = cc.Layer:create()				-- 创建添加内容的layer
	-- self.mScrollView:addChild( self.layerContent )	-- 添加内容的layer
	self:createSomeScreenUp()
	self:removeUiUp( self.nCurSelScreen )
	--self.mScrollView:jumpToBottom()					-- 初试状态显示在最下面
	
	self:createFuncShow()								-- 界面功能显示
	
	self.contain = self.mScrollView:getInnerContainer()
	self.contain:addChild(self.layerContent)
	-- self.mScrollView:setSwallowTouches(false)
	-- self:createSomeScreen()
	
end

function UIMain:setScorllViewTouch(enabled)
	self.mScrollView:setTouchEnabled(enabled)
end

----------------------------------------------------------------------------------------
-- 数据处理区域
----------------------------------------------------------------------------------------
-- 计算总共的屏幕数量 根据资源
function UIMain:calcSumSceen()
	-- local nRetCount = 1
	-- while( cc.FileUtils:getInstance():isFileExist( "copy_" .. nRetCount .. ".jpg" ) ) do
		-- nRetCount = nRetCount + 1
	-- end
	-- return nRetCount - 1
	local tbMap = LogicTable:getAll("map_tplt")
	return #tbMap
end

-- 设置每一屏的大小  按照第一屏的大小决定
function UIMain:getScreenHeight()
	local tbMap = LogicTable:getAll("map_tplt", 1)
	if tbMap then
		local picTemp = ccui.ImageView:create("background_image")
		return picTemp:getContentSize().height
	end
	return 960
end

-- 计算每一屏的y坐标
function UIMain:calcYPosByIdx( nIndex )
	return (nIndex - 1)*self.mScreenHeight
end

-- 计算进入要到达的屏幕
function UIMain:calcEnterScreen()
	local nSum = self:calcSumSceen()
	local nCurSum = self:calcCurSumScreen()
	local nDiff = nSum - nCurSum
	if nDiff <= self.CAN_LOOK_OTHER and nSum >= self.CREATE_ONECE then
		self.m_nCurScreen = nSum - self.CREATE_ONECE
		self.m_nCurLowScreen = nSum - self.CREATE_ONECE
	elseif nCurSum < self.CREATE_ONECE then
		self.m_nCurScreen = 0
		self.m_nCurLowScreen = 0
	else
		self.m_nCurScreen = nCurSum - (self.CREATE_ONECE - self.CAN_LOOK_OTHER)
		self.m_nCurLowScreen = nCurSum - (self.CREATE_ONECE - self.CAN_LOOK_OTHER)
	end
end

-- 获取当前打到的最高的层数
function UIMain:getMostCopy()
	-- 获取数据库 当前已经打到了的最高关卡
	local nCanPlay = DataMap:getMaxPass() + 1
	local csvMap 		= LogicTable:getAll("copy_tplt")
	if nCanPlay < #csvMap then
		return nCanPlay
	else
		return #csvMap
	end
end

-- 获取当前可以打的屏幕
function UIMain:getCurCanFightScreen()
	local nMostCopy = self.nMastCopy
	if 0 == nMostCopy then
		return 1
	end
	local csvMap 		= LogicTable:get("copy_tplt", nMostCopy, true)
	if csvMap["main_map_icon_pos"][1][2] < 450 and csvMap["main_map_index"] == 1 then
		return csvMap["main_map_index"]
	else
		return (csvMap["main_map_icon_pos"][1][2]/960 - 0.5) + csvMap["main_map_index"]
	end
	return --csvMap["main_map_index"]
end

-- 计算当前最大的屏幕编号
function UIMain:calcCurSumScreen()
	-- 通过最高层书 查表获得最高层数的编号
	local nMostScreen = 1
	
	if self.nMastCopy ~= 0 then
		local csvMap 		= LogicTable:get("copy_tplt", self.nMastCopy, true)
		nMostScreen 	= csvMap["main_map_index"]
	end
	
	local nSumScreen	= self:calcSumSceen()
	if nMostScreen + self.CAN_LOOK_OTHER < nSumScreen then
		return (nMostScreen + self.CAN_LOOK_OTHER)
	else
		return nSumScreen
	end
end

-- 判断副本是否解锁
function UIMain:isCopyUnLock( tbMap )
	if tbMap["unlocks"][1][2] == 0 then
		return true
	end
	return  not DataLevelInfo:showCopyUnlockUI(tbMap["unlocks"][1],tbMap["id"])
end

-- 获取影响解锁的数量
function UIMain:getHeroUnlockCount( nLevel )
	local nRet = 0
	for nKey, heroId in pairs( DataHeroInfo:getHeroTb() ) do
		if DataHeroInfo:isHeroUnlock(heroId) then
			local tbHero = LogicTable:get("hero_tplt", heroId, true)
			if tbHero[level] >= nLevel then
				nRet = nRet + 1
			end
		end
	end
	return nRet
end

----------------------------------------------------------------------------------------
-- 界面处理区域
----------------------------------------------------------------------------------------
-- 创建每一屏的背景文件
function UIMain:createScreen( nIndex )
	local tbMap = LogicTable:get("map_tplt", nIndex, true)
	local picScreen = cc.Sprite:create(tbMap["background_image"])--ccui.ImageView:create( tbMap["background_image"] )
	picScreen:setAnchorPoint( cc.p( 0, 0 ) )

	return picScreen
end

-- 创建每一屏的动画
function UIMain:createScreenAc( nIndex )
	local picScreen = cc.Node:create()
	picScreen:setAnchorPoint( cc.p( 0, 0 ) )

	-- 鱼动画
	local tbAcFishInfos = LogicTable:getCondition("map_fish_animation_tplt", function( val ) return  val.main_map_index == nIndex end)
	for nKey, tbAcInfo in pairs( tbAcFishInfos ) do
		local uiAc = self:createFish( 
										cc.p(tbAcInfo.pos_start[1],tbAcInfo.pos_start[2]), 
										cc.p(tbAcInfo.pos_control1[1], tbAcInfo.pos_control1[2]), 
										cc.p(tbAcInfo.pos_contol2[1], tbAcInfo.pos_contol2[2]), 
										cc.p(tbAcInfo.pos_end[1], tbAcInfo.pos_end[2]), 
										tbAcInfo.display, 
										tbAcInfo.scale_x, tbAcInfo.scale_y, 
										cc.p(tbAcInfo.anchor[1], tbAcInfo.anchor[2]), 
										tbAcInfo.time,
										tbAcInfo.duran_times )
		picScreen:addChild(uiAc)
	end
	
	-- 动画
	local tbAcInfos = LogicTable:getCondition("map_animation_tplt", function( val ) return  val.main_map_index == nIndex end)
	for nKey, tbAcInfo in pairs( tbAcInfos ) do
		local uiAc = Utils:createArmatureNode(tbAcInfo.display,G.MONSTER_IDLE,true)
		uiAc:setPosition( cc.p( tbAcInfo.pos[1][1], tbAcInfo.pos[1][2] ) )
		picScreen:addChild(uiAc)
	end
	
	-- 当前副本提示
	local tbMapInfo = LogicTable:get("copy_tplt", self.nMastCopy, false)
	if tbMapInfo and nIndex == tbMapInfo.main_map_index then
		local spLight = self:createCurAcTip()
		spLight:setPosition( cc.p(tbMapInfo.main_map_icon_pos[1][1] + 2, tbMapInfo.main_map_icon_pos[1][2] + 4) )
		picScreen:addChild(spLight)
	end
	
	return picScreen
end

-- 创建一屏的按钮
function UIMain:createScreenBtn( nIndex )
	local picScreen  = cc.Node:create()
	local tbMapInfo = LogicTable:getCondition("copy_tplt", function( val ) return  val.main_map_index == nIndex end)
	for nKey, tbCopy in pairs( tbMapInfo ) do
		local btnCopy = self:createCopyBtn( tbCopy )
		picScreen:addChild( btnCopy )
	end
	
	return picScreen
end

-- 创建副本进入按钮
function UIMain:createCopyBtn( tbMap )
	local nIndex = tbMap.id
	local tbPos = tbMap.main_map_icon_pos
	
	-- 添加副本按钮
	local btnCopy = nil
	if nIndex < self.nMastCopy then
		btnCopy = ccui.ImageView:create( "unlocked_level_icon.png")
		btnCopy:setTouchEnabled( true )
	elseif nIndex == self.nMastCopy then
		btnCopy = ccui.ImageView:create( "unlocked_level_icon.png")
		btnCopy:setTouchEnabled( true )
		self:addLock( btnCopy, tbMap )
	else
		btnCopy = ccui.ImageView:create( "locked_level_icon.png")
		btnCopy:setTouchEnabled( false )
		self:addLock( btnCopy, tbMap )
	end
	
	if self:isCopyUnLock(tbMap) or nIndex < self.nMastCopy then
		self:createCopyID(btnCopy, nIndex, nIndex > self.nMastCopy)
	end
	
	btnCopy:setName("btnCopy" .. nIndex)
	btnCopy:setAnchorPoint( cc.p( 0.5, 0.5 ) )
	btnCopy:setPosition( cc.p( tbPos[1][1], tbPos[1][2] ) )
	btnCopy:setSwallowTouches(false)
	btnCopy:addTouchEventListener( function( _sender, _type ) self:dealCopyBtn( btnCopy, _type, function() self:handleEnterGame( nIndex ) end ) end )
	
	return btnCopy
end

-- 为按钮添加锁
function UIMain:addLock( btnCopy, tbMap )
	-- 加锁
	if not self:isCopyUnLock(tbMap) then
		local picLock = ccui.ImageView:create("copy_lock.png")
		picLock:setPosition( cc.p(40, 48) )
		btnCopy:addChild(picLock)
	end
end

-- 处理关卡按钮  如果检测到移动  则不触发事件
function UIMain:dealCopyBtn( uiNode, _type, func )
	if 0 == _type then
		uiNode.nMovePos = self.contain:getPositionY()
	elseif 2 == _type then
		local nDiff = self.contain:getPositionY() - uiNode.nMovePos
		if nDiff < 5 and nDiff > -5 then
			func()
		end
	end
end

-- 创建触摸曾
function UIMain:createTouchLayer()
	self.touchLayer = cc.Layer:create()
	self.mRoot:addChild( self.touchLayer )
end

-- 增加屏幕
function UIMain:addScreen( nIndex )
	local picScreen = self:createScreen( nIndex )
	picScreen:setPosition( cc.p( 0, self:calcYPosByIdx( nIndex ) ) )
	self.layerContent:addChild( picScreen )
	picScreen:setTag( nIndex )
	
	local picBtnScreen = self:createScreenBtn( nIndex )
	picBtnScreen:setPosition( cc.p( 0, self:calcYPosByIdx( nIndex ) ) )
	picBtnScreen:setLocalZOrder(10)
	self.layerContent:addChild( picBtnScreen )
	picBtnScreen:setTag( nIndex + 1000 )
	
	local picAcScreen = self:createScreenAc( nIndex )
	picAcScreen:setPosition( cc.p( 0, self:calcYPosByIdx( nIndex ) ) )
	picAcScreen:setLocalZOrder(5)
	self.layerContent:addChild( picAcScreen )
	picAcScreen:setTag( nIndex + 2000 )
end

-- 移除屏幕
function UIMain:destoryScreen( nIndex )
	local uiChild = self.layerContent:getChildByTag( nIndex )
	if not tolua.isnull( uiChild ) then
		self.layerContent:removeChild( uiChild, true )
	end
	local uiChild = self.layerContent:getChildByTag( 1000 + nIndex )
	if not tolua.isnull( uiChild ) then
		self.layerContent:removeChild( uiChild, true )
	end
	local uiChild = self.layerContent:getChildByTag( 2000 + nIndex )
	if not tolua.isnull( uiChild ) then
		self.layerContent:removeChild( uiChild, true )
	end
end

-- 一次性创建几屏	parameters: bUp true	-- 向上创建
function UIMain:createSomeScreenUp( bUp )
	if self.m_nCurScreen >= self.m_nAllCount then
		return
	end
	if self.m_bIsCreate == false then
		self.m_bIsCreate = true
		self.mScrollView:setTouchEnabled( false )
		local nAddCount = 0
		for nIndex = 1, self.CREATE_ONECE, 1 do
			-- 如果创建达到了总共的屏幕数 弹出
			if self.m_nCurScreen >= self.m_nAllCount then
				break
			end
			nAddCount = nAddCount + 1					-- 记录当前增加的屏幕数量
			self.m_nCurScreen = self.m_nCurScreen + 1	-- 向上的屏数增加
			self:addScreen( self.m_nCurScreen )			-- 增加屏幕
		end
		self:removeUiUp( self.m_nCurScreen - nAddCount )
		
		self.m_bIsCreate = false
		self.mScrollView:setTouchEnabled( true )
	end
end

-- 一次性创建几屏	parameters: bUp true	-- 向下创建
function UIMain:createSomeScreenDown( bUp )
	if self.m_nCurLowScreen <= 0 then
		return
	end
	if self.m_bIsCreate == false then
		self.m_bIsCreate = true
		self.mScrollView:setTouchEnabled( false )
		local nAddCount = 0
		for nIndex = 1, self.CREATE_ONECE, 1 do
			-- 如果创建达到了总共的屏幕数 弹出
			nAddCount = nAddCount + 1
			self:addScreen( self.m_nCurLowScreen )			-- 增加屏幕
			self.m_nCurLowScreen = self.m_nCurLowScreen - 1
			if self.m_nCurLowScreen == 0 then
				break;
			end
			-- cclog( "add Screen	" .. self.m_nCurLowScreen )
		end
		self:removeUiDown( self.m_nCurLowScreen + nAddCount )
		
		self.m_bIsCreate = false
		self.mScrollView:setTouchEnabled( true )
	end
end

-- 消除一些控件 确保内存 向上删除
function UIMain:removeUiUp( curTag )
	local nCurHave = self.m_nCurScreen - self.m_nCurLowScreen
	if nCurHave > self.CREATE_ONECE*2 then
		self.m_nCurLowScreen = self.m_nCurLowScreen + self.CREATE_ONECE
		for nIndex = 1, self.m_nCurLowScreen - 1, 1 do
			self:destoryScreen( nIndex )
		end
	end	
	self.mScrollView:setInnerContainerSize( cc.size( 720, ( self.m_nCurScreen - self.m_nCurLowScreen )*self.mScreenHeight ) )
	self.layerContent:setPosition( 0, -self.m_nCurLowScreen*self.mScreenHeight )
	self.mScrollView:jumpToPercentVertical( 100 - 100*(curTag - self.m_nCurLowScreen-1)/( self.m_nCurScreen - self.m_nCurLowScreen-1) )
end

-- 消除一些控件 确保内存 向下删除
function UIMain:removeUiDown( curTag )
	local nCurHave = self.m_nCurScreen - self.m_nCurLowScreen
	if nCurHave > self.CREATE_ONECE*2 then
		self.m_nCurScreen = self.m_nCurScreen - self.CREATE_ONECE
		for nIndex = self.m_nAllCount, self.m_nCurScreen + 1, -1 do
			self:destoryScreen( nIndex )
		end
	end	
	self.mScrollView:setInnerContainerSize( cc.size( 720, ( self.m_nCurScreen - self.m_nCurLowScreen )*self.mScreenHeight ) )
	self.layerContent:setPosition( 0, -self.m_nCurLowScreen*self.mScreenHeight )
	self.mScrollView:jumpToPercentVertical( 100 - 100*(curTag - self.m_nCurLowScreen-1)/( self.m_nCurScreen - self.m_nCurLowScreen - 1 ) )
end

-- 让ScrollView 旋转回去原来的地方
function UIMain:scrollToSel( nBack )
	local nDetPosY = self.contain:getPositionY()
	local nDiff = nDetPosY +(self:getCurCanFightScreen() - self.m_nCurLowScreen - 1)*self.mScreenHeight
	--cclog(nDetPosY ,(self:getCurCanFightScreen() - self.m_nCurLowScreen - 1)*self.mScreenHeight)
	-- cclog("nDiff", nDiff)
	if nDiff <= -0.1 then
		self.mScrollView:setInertiaScrollEnabled(false)
		self.mScrollView:scrollToPercentVertical(100-((self.nCurSelScreen - self.m_nCurLowScreen - 1 - self:calcMoreBack(-nDiff) )*100)/(self.m_nCurScreen - self.m_nCurLowScreen-1), self.COME_NACK_TIME,false)
		Actions:delayWith( self.mRoot, self.COME_NACK_TIME, function() self.mScrollView:scrollToPercentVertical(100-(self.nCurSelScreen - self.m_nCurLowScreen-1)*100/(self.m_nCurScreen - self.m_nCurLowScreen-1), self.COME_BACK_MORE,false) end )
		Actions:delayWith( self.uiTime, self.COME_NACK_TIME, function() self.mScrollView:setInertiaScrollEnabled(true) end )
	end
end

-- 创建显示副本ID的控件
function UIMain:createCopyID(btnCopy, nCopyId, isBlack)
	local txtIdx = nil
	if isBlack then
		txtIdx = cc.Label:createWithBMFont("font_07.fnt", nCopyId .. "", cc.TEXT_ALIGNMENT_CENTER)
	else
		txtIdx = cc.Label:createWithBMFont("font_06.fnt", nCopyId .. "", cc.TEXT_ALIGNMENT_CENTER)
	end
	if nCopyId > 9 and nCopyId < 100 then
		txtIdx:setScale(0.9)
	elseif nCopyId >= 99 then
		txtIdx:setScale(0.7)
	elseif nCopyId > 999 then
		txtIdx:setScale(0.5)
	end
	txtIdx:setPosition( cc.p( btnCopy:getContentSize().width/2 + 2, btnCopy:getContentSize().height/2 + 5 ) )
	btnCopy:addChild( txtIdx )
end

-- 绑定scrollView的监听
function UIMain:dealScroll()
	self:createSomeScreenUp()
end

function UIMain:createFuncShow()
	if cc.PLATFORM_OS_WINDOWS == G.PLATORM then
		--地图编辑器按钮
		local btnMap = ccui.Button:create()
		btnMap:loadTextures( "btn_1.png", "btn_1.png", "btn_1.png" )
		btnMap:setAnchorPoint( cc.p( 0.5, 0.5 ) )
		btnMap:setTitleText(LanguageStr("MAP_EDIT"))
		Utils:setPosPercentCenter( btnMap, -0.4, 0)
		self.mRoot:addChild( btnMap )
		btnMap:setTouchEnabled( true )
		Utils:addTouchEvent(btnMap, function(sender)
			self:handleMapEdit()
		end, true, true, 0)
	end
end

function UIMain:createCurAcTip()
	local node = cc.Node:create()
	local light1 = cc.Sprite:create("light_quan.png")
	local light2 = cc.Sprite:create("light_quan.png")
	local light3 = cc.Sprite:create("light_quan.png")
	light1:setScale(0)
	light2:setScale(0)
	light3:setScale(0)
	node:addChild(light1)
	node:addChild(light2)
	node:addChild(light3)
	local nLightT = 0.9
	local function handler()
		light1:setScale(0)
		light2:setScale(0)
		light3:setScale(0)
		light1:setOpacity(255)
		light2:setOpacity(255)
		light3:setOpacity(255)
		light1:runAction(cc.Spawn:create({
			cc.EaseSineOut:create(cc.ScaleTo:create(nLightT,1)),
			cc.FadeOut:create(1)    
		}))
		light2:runAction(cc.Sequence:create({
			cc.DelayTime:create(0.3),
			cc.Spawn:create({
				cc.EaseSineOut:create(cc.ScaleTo:create(nLightT,1)),
				cc.FadeOut:create(nLightT)
			})
		}))
		light3:runAction(cc.Sequence:create({
			cc.DelayTime:create(0.5),
			cc.Spawn:create({
				cc.EaseSineOut:create(cc.ScaleTo:create(nLightT,1)),
				cc.FadeOut:create(nLightT)
			})
		}))
	end
	node:runAction( cc.RepeatForever:create(cc.Sequence:create({
			cc.CallFunc:create(handler),
            cc.DelayTime:create(1.5)
        })) )
	return node
end

-- 创建一只鱼
function UIMain:createFish( posStart, posControl1, posControl2, posEnd, sAcName, nScaleX, nScaleY, anchorPos, nTime, tbFade )
	local uiTime = cc.Node:create()
	local prePosX, prePosY = posStart.x, posStart.y
	local spFish = Utils:createArmatureNode(sAcName, G.HERO_IDLE, true)
	spFish:setOpacity(0)
	spFish:setAnchorPoint(anchorPos)
	spFish:setScale(nScaleX, nScaleY)
	spFish:addChild( uiTime )
	spFish:setPosition( posStart )
	-- 走的路线
	local bezier ={
        posControl1,
        posControl2,
        posEnd
    }
	
	-- spFish:setRotation(fDeg)
    local bezierTo = cc.BezierTo:create(nTime, bezier)
	local function handler()
		curPosX, curPosY = spFish:getPosition()
		local fDeg = 3.14/2
		if curPosY < prePosY and curPosX >= prePosX then
			fDeg = math.atan( (curPosX - prePosX)/(curPosY - prePosY) ) - 3.14
		elseif curPosY ~= prePosY then
			fDeg = math.atan( (curPosX - prePosX)/(curPosY - prePosY) )
		end
		spFish:setRotation(math.deg(fDeg))
		prePosX, prePosY = curPosX, curPosY
	end
	local function handlerFish()
		prePosX, prePosY = posStart.x, posStart.y
		spFish:setOpacity(0)
	end
	local arrayFade = {cc.FadeIn:create(0.5)}
	if tbFade[1] then
		local curTime = 0.5
		for _k, _t in pairs(tbFade) do
			table.insert(arrayFade, cc.DelayTime:create(_t[1] - curTime) )
			table.insert(arrayFade, cc.FadeOut:create(0.5) )
			table.insert(arrayFade, cc.DelayTime:create(_t[2]) )
			table.insert(arrayFade, cc.FadeIn:create(0.5) )
			cclog("_t[2]",_t[1],_t[2])
			curTime = _t[1] + 1 + _t[2]
		end
		table.insert(arrayFade, cc.DelayTime:create(nTime - curTime - 0.5) )
	else
		table.insert(arrayFade, cc.DelayTime:create(nTime - 1) )
	end
	table.insert(arrayFade, cc.FadeOut:create(0.5) )
	spFish:runAction( cc.RepeatForever:create( cc.Sequence:create({ 
													cc.Spawn:create({
																	bezierTo, 
																	cc.Sequence:create( arrayFade ),
																	}),  
													cc.Place:create( posStart ), 
													cc.CallFunc:create(handlerFish), 
													cc.DelayTime:create(1 + math.random(30)/10 ) 
											}) ))
	uiTime:runAction( cc.RepeatForever:create( cc.Sequence:create({ cc.CallFunc:create(handler) }) ) )
	return spFish
end

----------------------------------------------------------------------------------------
-- 事件处理区域
----------------------------------------------------------------------------------------
--地图编辑器按钮事件
function UIMain:handleMapEdit()
	UIManager:openFront(UIMapEdit, true)
end

-- 进入游戏
function UIMain:handleEnterGame( nIndex )
	-- cclog("我点击了**************")
	
	ChannelProxy:recordCustom("stat_copy_start")
	DataMap:setPass(nIndex)				--设置当前打的是第几关
	DataLevelInfo:init()
	CopyModel:init(DataMap:getPass())
	
	if DataLevelInfo:showCopyUnlockUI(DataLevelInfo:getUnlockCopyInfo(), DataLevelInfo:getCopyInfo().id) then
		UIManager:openFront(UICopyUnlock, true, {["unLockCopyId"] = nIndex})
		return
	end
	UIManager:openFront(UICopyInfo, true)
	
end



