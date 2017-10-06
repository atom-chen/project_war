----------------------------------------------------------------------
-- Author: yejt
-- Date: 2014-12-30
-- Brief: 副本界面
----------------------------------------------------------------------
UIDEFINE("UIMain", "copy.csb")
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
	self.mScrollView = self:getChild("ScrollView_1")
	self.mScrollView:setBounceEnabled(false)
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
			self:createSomeScreenUp()
		elseif 1 == _type then
			self:createSomeScreenDown()
		elseif 4 == _type then
			if not self.bTouch and self.bAutoSel then
				self.mScrollView:stopAllActions()
				Actions:delayWith(self.mScrollView, 0.1, function() self:scrollToOriginal() self.bAutoSel = false self.mScrollView:stopAllActions() end)
				--self.mScrollView:runAction(cc.Sequence:create({ cc.DelayTime:create(0.1), cc.CallFunc:create(function() self:scrollToOriginal() self.mScrollView:stopAllActions() end) }))
			end
		end
	end
	self.mScrollView:addEventListener( function( ... ) handleScroll( ... )  end )
	
	local function handleTouch( _sender, _type )
		if ccui.TouchEventType.ended == _type or ccui.TouchEventType.canceled == _type then
			self.mScrollView:stopAllActions()
			self:scrollToOriginal()
			self.bTouch	= false
			self.bAutoSel = true
		elseif ccui.TouchEventType.began == _type then
			self.mScrollView:stopAllActions()
			self.bTouch	= true
			self.bAutoSel = false
		end
	end
	self.mScrollView:addTouchEventListener( function( ... ) handleTouch( ... ) end )
	
	self:bind(EventDef["ED_UPDATA_COPY_BTN"], function( nCopyId ) 
		local btnCopy = self:getChild("copy_button_" .. nCopyId)
		btnCopy:removeAllChildren(true)
		self:showCopyIndex(btnCopy, nCopyId, false)
	end)
end

-- 初始化数据
function UIMain:initData()
	self:configData()
	
	self.m_nCurScreen 		= 0							-- 当前创建到了几屏
	self.CREATE_ONECE 		= 5							-- 一次创建几屏
	self.m_bIsCreate  		= false						-- 是否正在创建
	self.mPassCopy			= self:getPassCopy()		-- 获取当前打到的最高的层数
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
	self.node:addChild(self.uiTime)
	
	self.layerContent = cc.Layer:create()				-- 创建添加内容的layer
	-- self.mScrollView:addChild( self.layerContent )	-- 添加内容的layer
	self:createSomeScreenUp()
	self:removeUiUp( self.nCurSelScreen )
	--self.mScrollView:jumpToBottom()					-- 初试状态显示在最下面
	
	self:showMapEditButton()								-- 界面功能显示
	
	self.mScrollViewContainer = self.mScrollView:getInnerContainer()
	self.mScrollViewContainer:addChild(self.layerContent)
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

-- 获取当前已通过的副本数
function UIMain:getPassCopy()
	-- 获取数据库当前已经打到的最高关卡
	local nCanPlay = DataMap:getMaxPass() + 1
	local _, copyCount = LogicTable:getAll("copy_tplt")
	if nCanPlay < copyCount then
		return nCanPlay
	end
	return copyCount
end

-- 获取当前可以打的屏幕
function UIMain:getCurCanFightScreen()
	local nMostCopy = self.mPassCopy
	if 0 == nMostCopy then
		return 1
	end
	local mapData = LogicTable:get("copy_tplt", nMostCopy, true)
	if mapData["main_map_icon_pos"][1][2] < 450 and mapData["main_map_index"] == 1 then
		return mapData["main_map_index"]
	end
	return (mapData["main_map_icon_pos"][1][2]/960 - 0.5) + mapData["main_map_index"]
end

-- 计算当前最大的屏幕编号
function UIMain:calcCurSumScreen()
	-- 通过最高层书 查表获得最高层数的编号
	local nMostScreen = 1
	
	if self.mPassCopy ~= 0 then
		local mapData = LogicTable:get("copy_tplt", self.mPassCopy, true)
		nMostScreen = mapData["main_map_index"]
	end
	
	local nSumScreen	= self:calcSumSceen()
	if nMostScreen + self.CAN_LOOK_OTHER < nSumScreen then
		return (nMostScreen + self.CAN_LOOK_OTHER)
	else
		return nSumScreen
	end
end

-- 判断副本是否解锁
function UIMain:isCopyUnLock(copyInfo)
	if copyInfo["unlocks"][1][2] == 0 then
		return true
	end
	return not ModelUnlock:showCopyUnlockUI(copyInfo["unlocks"][1],copyInfo["id"])
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
		local uiAc = UIFactory:createFish( 
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
	local tbMapInfo = LogicTable:get("copy_tplt", self.mPassCopy, false)
	if tbMapInfo and nIndex == tbMapInfo.main_map_index then
		local spLight = UIFactory:createTipCircle()
		spLight:setPosition( cc.p(tbMapInfo.main_map_icon_pos[1][1] + 2, tbMapInfo.main_map_icon_pos[1][2] + 4) )
		picScreen:addChild(spLight)
	end
	
	return picScreen
end

-- 创建一屏副本按钮列表
function UIMain:createScreenCopyButton(nIndex)
	local picScreen  = cc.Node:create()
	local copyInfoTable = LogicTable:getCondition("copy_tplt", function(copyInfo)
		return nIndex == copyInfo.main_map_index
	end)
	for nKey, copyInfo in pairs(copyInfoTable) do
		local btnCopy = self:createCopyButton(copyInfo)
		picScreen:addChild(btnCopy)
	end
	local specialCopyInfoTable = LogicTable:getCondition("copy_special_tplt", function(copyInfo)
		return nIndex == copyInfo.main_map_index
	end)
	
	--local tb = DataMap:getCopyAwardTimesInfo()
	for nKey, copyInfo in pairs(specialCopyInfoTable) do
		--local key = copyInfo.id.."_"..copyInfo.copy_id
		--if nil == tb[key] then tb[key] = 0 end
		--if nil ~= tb[key] and copyInfo.reward_times > tb[key] then
			local specialCopy = self:createSpecialCopy(copyInfo)
			picScreen:addChild(specialCopy)
		--end
	end
	return picScreen
end

-- 创建普通副本按钮
function UIMain:createCopyButton(copyInfo)
	local copyId = copyInfo.id
	local tbPos = copyInfo.main_map_icon_pos
	-- 添加副本按钮
	local btnCopy = nil
	if copyId < self.mPassCopy then
		btnCopy = ccui.ImageView:create(copyInfo.copy_normal_icon)
		btnCopy:setTouchEnabled(true)
	elseif copyId == self.mPassCopy then
		btnCopy = ccui.ImageView:create(copyInfo.copy_normal_icon)
		btnCopy:setTouchEnabled(true)
		self:addLock(btnCopy, copyInfo)
	else
		btnCopy = ccui.ImageView:create(copyInfo.copy_gray_icon)
		btnCopy:setTouchEnabled(false)
		self:addLock(btnCopy, copyInfo)
	end
	if self:isCopyUnLock(copyInfo) or copyId < self.mPassCopy then
		self:showCopyIndex(btnCopy, copyId, copyId > self.mPassCopy)
	end
	btnCopy:setName("copy_button_"..copyId)
	btnCopy:setAnchorPoint(cc.p(0.5, 0.5))
	btnCopy:setPosition(cc.p(tbPos[1][1], tbPos[1][2]))
	btnCopy:setSwallowTouches(false)
	btnCopy:addTouchEventListener(function(_sender, _type)
		self:dealCopyBtn(btnCopy, _type, function()
			self:enterlCopy(copyInfo)
		end)
	end)
	return btnCopy
end

-- 创建特殊副本
function UIMain:createSpecialCopy(copyInfo)
	local copyNode = cc.Node:create()
	copyNode:setName("special_copy_button_"..copyInfo.id)
	copyNode:setPosition(cc.p(copyInfo.main_map_icon_pos[1][1], copyInfo.main_map_icon_pos[1][2]))
	local bubbleBox, bubbleShader = nil, nil
	local tb = DataMap:getCopyAwardTimesInfo()
	if copyInfo.copy_id <= self.mPassCopy then	-- 解锁(特殊副本关联的普通副本id <= 已解锁的普通副本id)
		local key = copyInfo.id.."_"..copyInfo.copy_id
		if nil == tb[key] then tb[key] = 0 end
		if nil ~= tb[key] and copyInfo.reward_times > tb[key] then
			bubbleBox = ccui.ImageView:create("bubble_box.png")		
		else
			bubbleBox = ccui.ImageView:create("bubble_box_open.png")
		end
		bubbleBox:setTouchEnabled(true)
	else	-- 未解锁
		bubbleBox = ccui.ImageView:create("bubble_box_gray.png")
		bubbleBox:setTouchEnabled(false)
	end
	bubbleShader = ccui.ImageView:create("bubble_shadow.png")
	UIFactory:playSpecialCopyAnimation(bubbleBox, bubbleShader)
	bubbleBox:setSwallowTouches(false)
	bubbleBox:addTouchEventListener(function(_sender, _type)
		self:dealCopyBtn(copyNode, _type, function()
			self:enterSpecialCopy(copyInfo)
		end)
	end)
	copyNode:addChild(bubbleShader)
	copyNode:addChild(bubbleBox)
	return copyNode
end

-- 为按钮添加锁
function UIMain:addLock(btnCopy, copyInfo)
	if not self:isCopyUnLock(copyInfo) then
		local picLock = ccui.ImageView:create("copy_lock.png")
		picLock:setPosition(cc.p(40, 48))
		btnCopy:addChild(picLock)
	end
end

-- 处理关卡按钮,如果检测到移动,则不触发事件
function UIMain:dealCopyBtn(uiNode, _type, func)
	if 0 == _type then
		uiNode.nMovePos = self.mScrollViewContainer:getPositionY()
	elseif 2 == _type then
		local nDiff = self.mScrollViewContainer:getPositionY() - uiNode.nMovePos
		if nDiff < 5 and nDiff > -5 then
			func()
		end
	end
end

-- 增加屏幕
function UIMain:addScreen(nIndex)
	local picScreen = self:createScreen(nIndex)
	picScreen:setPosition(cc.p(0, self:calcYPosByIdx(nIndex)))
	picScreen:setTag(nIndex)
	self.layerContent:addChild(picScreen)
	
	local picBtnScreen = self:createScreenCopyButton(nIndex)
	picBtnScreen:setPosition(cc.p(0, self:calcYPosByIdx(nIndex)))
	picBtnScreen:setLocalZOrder(10)
	picBtnScreen:setTag(nIndex + 1000)
	self.layerContent:addChild(picBtnScreen)
	
	local picAcScreen = self:createScreenAc(nIndex)
	picAcScreen:setPosition(cc.p(0, self:calcYPosByIdx(nIndex)))
	picAcScreen:setLocalZOrder(5)
	picAcScreen:setTag(nIndex + 2000)
	self.layerContent:addChild(picAcScreen)
end

-- 移除屏幕
function UIMain:destoryScreen(nIndex)
	local uiChild = self.layerContent:getChildByTag(nIndex)
	if not tolua.isnull(uiChild) then
		self.layerContent:removeChild(uiChild, true)
	end
	local uiChild = self.layerContent:getChildByTag(1000 + nIndex)
	if not tolua.isnull(uiChild) then
		self.layerContent:removeChild(uiChild, true)
	end
	local uiChild = self.layerContent:getChildByTag(2000 + nIndex)
	if not tolua.isnull(uiChild) then
		self.layerContent:removeChild(uiChild, true)
	end
end

-- 一次性创建几屏
function UIMain:createSomeScreenUp()
	if self.m_nCurScreen >= self.m_nAllCount then
		return
	end
	if self.m_bIsCreate == false then
		self.m_bIsCreate = true
		self.mScrollView:setTouchEnabled(false)
		local nAddCount = 0
		for nIndex = 1, self.CREATE_ONECE, 1 do
			-- 如果创建达到了总共的屏幕数 弹出
			if self.m_nCurScreen >= self.m_nAllCount then
				break
			end
			nAddCount = nAddCount + 1					-- 记录当前增加的屏幕数量
			self.m_nCurScreen = self.m_nCurScreen + 1	-- 向上的屏数增加
			self:addScreen(self.m_nCurScreen)			-- 增加屏幕
		end
		self:removeUiUp(self.m_nCurScreen - nAddCount)
		self.m_bIsCreate = false
		self.mScrollView:setTouchEnabled(true)
	end
end

-- 一次性创建几屏
function UIMain:createSomeScreenDown()
	if self.m_nCurLowScreen <= 0 then
		return
	end
	if self.m_bIsCreate == false then
		self.m_bIsCreate = true
		self.mScrollView:setTouchEnabled(false)
		local nAddCount = 0
		for nIndex = 1, self.CREATE_ONECE, 1 do
			-- 如果创建达到了总共的屏幕数,弹出
			nAddCount = nAddCount + 1
			self:addScreen(self.m_nCurLowScreen)			-- 增加屏幕
			self.m_nCurLowScreen = self.m_nCurLowScreen - 1
			if self.m_nCurLowScreen == 0 then
				break
			end
		end
		self:removeUiDown(self.m_nCurLowScreen + nAddCount)
		self.m_bIsCreate = false
		self.mScrollView:setTouchEnabled(true)
	end
end

-- 消除一些控件,确保内存,向上删除
function UIMain:removeUiUp(curTag)
	local nCurHave = self.m_nCurScreen - self.m_nCurLowScreen
	if nCurHave > self.CREATE_ONECE*2 then
		self.m_nCurLowScreen = self.m_nCurLowScreen + self.CREATE_ONECE
		for nIndex = 1, self.m_nCurLowScreen - 1, 1 do
			self:destoryScreen( nIndex )
		end
	end	
	self.mScrollView:setInnerContainerSize(cc.size(720, (self.m_nCurScreen - self.m_nCurLowScreen)*self.mScreenHeight))
	self.layerContent:setPosition(0, -self.m_nCurLowScreen*self.mScreenHeight)
	self.mScrollView:jumpToPercentVertical(100 - 100*(curTag - self.m_nCurLowScreen - 1)/(self.m_nCurScreen - self.m_nCurLowScreen - 1))
end

-- 消除一些控件,确保内存,向下删除
function UIMain:removeUiDown(curTag)
	local nCurHave = self.m_nCurScreen - self.m_nCurLowScreen
	if nCurHave > self.CREATE_ONECE*2 then
		self.m_nCurScreen = self.m_nCurScreen - self.CREATE_ONECE
		for nIndex = self.m_nAllCount, self.m_nCurScreen + 1, -1 do
			self:destoryScreen(nIndex)
		end
	end	
	self.mScrollView:setInnerContainerSize(cc.size(720, (self.m_nCurScreen - self.m_nCurLowScreen)*self.mScreenHeight))
	self.layerContent:setPosition(0, -self.m_nCurLowScreen*self.mScreenHeight)
	self.mScrollView:jumpToPercentVertical(100 - 100*(curTag - self.m_nCurLowScreen - 1)/(self.m_nCurScreen - self.m_nCurLowScreen - 1))
end

-- 地图列表滚动到原始位置
function UIMain:scrollToOriginal()
	local nDetPosY = self.mScrollViewContainer:getPositionY()
	local nDiff = nDetPosY + (self:getCurCanFightScreen() - self.m_nCurLowScreen - 1)*self.mScreenHeight
	if nDiff <= -0.1 then
		self.mScrollView:setInertiaScrollEnabled(false)
		self.mScrollView:scrollToPercentVertical(100 - ((self.nCurSelScreen - self.m_nCurLowScreen - 1 - self:calcMoreBack(-nDiff))*100)/(self.m_nCurScreen - self.m_nCurLowScreen - 1), self.COME_NACK_TIME, false)
		Actions:delayWith(self.node, self.COME_NACK_TIME, function()
			self.mScrollView:scrollToPercentVertical(100 - (self.nCurSelScreen - self.m_nCurLowScreen - 1)*100/(self.m_nCurScreen - self.m_nCurLowScreen - 1), self.COME_BACK_MORE, false)
		end)
		Actions:delayWith(self.uiTime, self.COME_NACK_TIME, function()
			self.mScrollView:setInertiaScrollEnabled(true)
		end)
	end
end

-- 显示副本索引值
function UIMain:showCopyIndex(btnCopy, nCopyId, isBlack)
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
	txtIdx:setPosition(cc.p(btnCopy:getContentSize().width/2 + 2, btnCopy:getContentSize().height/2 + 5))
	btnCopy:addChild(txtIdx)
end

-- 显示地图编辑器按钮
function UIMain:showMapEditButton()
	if cc.PLATFORM_OS_WINDOWS == G.PLATFORM then
		local btnMap = ccui.Button:create()
		btnMap:loadTextures("btn_1.png", "btn_1.png", "btn_1.png")
		btnMap:setAnchorPoint(cc.p(0.5, 0.5))
		btnMap:setTitleText(LanguageStr("MAP_EDIT"))
		Utils:setPosPercentCenter(btnMap, -0.4, 0)
		self.node:addChild(btnMap)
		btnMap:setTouchEnabled(true)
		self:addTouchEvent(btnMap, function(sender)
			UIMapEdit:openFront(true)
		end, true, true, 0)
	end
end

-- 进入普通关卡
function UIMain:enterlCopy(copyInfo)
	ChannelProxy:recordCustom("stat_copy_start")
	DataMap:setPass(copyInfo.id)				-- 设置当前打的是第几关
	DataMap:setSpePass(0)
	ModelCopy:init(CopyType["normal"], copyInfo)
	if ModelUnlock:showCopyUnlockUI(copyInfo.unlocks[1], copyInfo.id) then
		UICopyUnlock:openFront(true, {["unLockCopyId"] = copyInfo.id})
		return
	end
	UICopyInfo:openFront(true)
end

-- 进入特殊关卡(开启条件有待添加？？？？？？？？？？？？？)
function UIMain:enterSpecialCopy(copyInfo)
	ChannelProxy:recordCustom("stat_copy_start")
	DataMap:setSpePass(copyInfo.copy_id.."_"..copyInfo.id)				-- 设置当前打的是第几关
	ModelCopy:init(CopyType["speical"], copyInfo)
	UICopyInfoSpecial:openFront(true)
end
