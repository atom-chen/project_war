----------------------------------------------------------------------
-- Author: Yejt
-- Date: 2014-2-5
-- Brief: 制作人员名单
----------------------------------------------------------------------
UIDEFINE("UIProductStaff", "ShowPeople.csb")
function UIProductStaff:onStart(ui, param)
	AudioMgr:playEffect(2007)
	self.ui = ui
	self.m_nScrollTime = 15
	self.mScrollView = self:getChild("ScrollView_1")
	self.mContent = self.mScrollView:getInnerContainer()
	self.mScrollViewHeight = self.mScrollView:getContentSize().height
	self:initEvent()
	self:initView()
end

-- 初始化界面
function UIProductStaff:initView()
	self:initScrollView()
	self.nContentX, self.nContentY = self.mContent:getPosition()
	self:scrollAction()
end

-- 初始化按钮事件
function UIProductStaff:initEvent()
	--关闭按钮
	local btnClose = self:getChild("Button_close")
	self:addTouchEvent(btnClose, function(sender)
		local function CallFucnCallback1()
			self:close()
		end
		self.ui.root:runAction(cc.Spawn:create(cc.ScaleTo:create(0.5, 0,0),cc.CallFunc:create(CallFucnCallback1)))
	end, true, true, 0)
	
	-- scrollview
	local function handleTouch( _sender, _type )
		if ccui.TouchEventType.ended == _type or ccui.TouchEventType.canceled == _type then
			self.mScrollView:setBounceEnabled(true)
			self:scrollAction()
		elseif ccui.TouchEventType.began == _type then
			self.mScrollView:setBounceEnabled(false)
			self.mContent:stopAllActions()
		end
	end
	self.mScrollView:addTouchEventListener( function( ... ) handleTouch( ... ) end )
end

-- 设置scrollview显示的内容
function UIProductStaff:initScrollView()
	local tbCellData = {}
	for _k, tbStaff in pairs(G.PRODUCT_STAFF) do
		table.insert(tbCellData, {["ui"] = self:createText( tbStaff["title"] ), ["diff"] = 35 })
		for _k2, sStaff in pairs(tbStaff["staff"]) do
			table.insert(tbCellData,  {["ui"] = self:createText( sStaff ), ["diff"] = 25 } )
		end
		if  _k ~= #G.PRODUCT_STAFF then
			local imgSpit = ccui.ImageView:create("public_line.png")
			imgSpit:setScale9Enabled(true)
			imgSpit:setContentSize( cc.size(350, 7) )
			table.insert(tbCellData, {["ui"] = imgSpit, ["diff"] = 10 })
		end
	end
	
	local nInnerHight = 0
	local nPosx = self.mContent:getContentSize().width
	for _k, uiData in pairs( tbCellData ) do
		nInnerHight = nInnerHight + uiData.diff
	end
	self.mScrollView:setInnerContainerSize(cc.size(self.mScrollView:getContentSize().width, nInnerHight))
	local curHeight = 0
	for _k, uiData in pairs(tbCellData) do
		curHeight = curHeight + uiData.diff
		uiData.ui:setPosition( cc.p(nPosx/2, nInnerHight - curHeight + uiData.diff/2) )
		self.mScrollView:addChild(uiData.ui)
	end
end

-- 创建一个文本
function UIProductStaff:createText( sText )
	local txt = ccui.Text:create(sText, "", 20)
	txt:setColor( cc.c3b(131, 35, 12) )
	return txt
end

-- 执行滑动动画
function UIProductStaff:scrollAction()
	local nCurContentY = self.mContent:getPositionY()
	
	local function handler()
		self.mContent:runAction( cc.RepeatForever:create( cc.Sequence:create({ 
			cc.MoveTo:create(self.m_nScrollTime, cc.p(self.nContentX, self.mScrollViewHeight) ),
			cc.Place:create(cc.p(self.nContentX, self.nContentY - self.mScrollViewHeight)) 
		}) ) )
	end
	cclog("self.m_nScrollTime*(self.mScrollViewHeight - nCurContentY)/self.mContent:getContentSize().height", self.m_nScrollTime*(self.mScrollViewHeight - nCurContentY)/self.mContent:getContentSize().height)
	self.mContent:runAction( cc.Sequence:create(
		cc.MoveTo:create(self.m_nScrollTime*(self.mScrollViewHeight - nCurContentY)/(self.mContent:getContentSize().height + self.mScrollViewHeight ), cc.p(self.nContentX, self.mScrollViewHeight)),
		cc.Place:create(cc.p(self.nContentX, self.nContentY - self.mScrollViewHeight)),
		cc.CallFunc:create(handler)
	) )
	
end

function UIProductStaff:onTouch(touch, event, eventCode)
	
end

function UIProductStaff:onUpdate(dt)
end

function UIProductStaff:onDestroy()
	
end

