----------------------------------------------------------------------
-- 创建扩展列表控件
-- scrollView:	列表控件
-- dataTB:		顺序数据表,如:{"aaa","bbb","ccc","ddd"}
-- createCF:	单元格创建函数,如:function(cell, index, data)
-- scrollCF:	滚动回调函数,如:function(scrollView)
-- target:		回调函数宿主对象
-- direction:	滚动方向,如:"H"水平滚动;"V"垂直滚动
-- cellW:		格子宽,如:120
-- cellH:		格子高,如:120
-- margin:		间隔(如果垂直滑动,则表示垂直间隔;如果水平滑动,则表示水平间隔),如:10
-- blockSize:	块大小(如果垂直滑动,则表示每行个数;如果水平滑动,则表示每列个数),如:3
-- dynamic:		是否动态创建,如:true,false
-- bounce:		是否开启回弹,如:true,false
----------------------------------------------------------------------
function UIScrollViewEx(scrollView, dataTB, createCF, scrollCF, target, direction, cellW, cellH, margin, blockSize, dynamic, bounce)
	assert("table" == type(dataTB) and "function" == type(createCF) and ("H" == direction or "V" == direction))
	assert("number" == type(cellW) and "number" == type(cellH) and "number" == type(margin))
	assert("number" == type(blockSize) and blockSize > 0)
	scrollView:addEventListener(function(sender, eventType)end)
	scrollView:removeAllChildren()
	scrollView:setInnerContainerSize(scrollView:getContentSize())
	scrollView:setTouchEnabled(true)
	scrollView:setVisible(true)
	scrollView:setEnabled(true)
	if "H" == direction then
		scrollView:setDirection(ccui.ScrollViewDir.horizontal)
	elseif "V" == direction then
		scrollView:setDirection(ccui.ScrollViewDir.vertical)
	end
	scrollView:setBounceEnabled(bounce or false)
	local mScrollViewWidth = scrollView:getInnerContainerSize().width		-- 列表宽
	local mScrollViewHeight = scrollView:getInnerContainerSize().height		-- 列表高
	local mXPosTable = {}													-- x轴坐标
	local mYPosTable = {}													-- y轴坐标
	local mTotalBlocks = 0													-- 总块数
	local mInitBlocks = 0													-- 初始显示块数
	local mCellTable = {}													-- 格子列表
	local mViewTable = {}													-- 当前可视列表
	----------------------------------------------------------------------
	-- 初始化参数(内部接口)
	local function init()
		mTotalBlocks = math.ceil(#dataTB/blockSize)
		if "H" == direction then		-- 水平滚动
			mInitBlocks = math.ceil(scrollView:getContentSize().width/(cellW + margin))
			-- 计算x轴坐标
			local scrollViewWidth = mTotalBlocks*cellW + (mTotalBlocks+1)*margin
			if mScrollViewWidth < scrollViewWidth then
				mScrollViewWidth = scrollViewWidth
			end
			for i=1, mTotalBlocks do
				mXPosTable[i] = i*margin + (i-1)*cellW + cellW/2
			end
			-- 计算y轴坐标
			local marginV = 0
			if mScrollViewHeight > cellH * blockSize then
				marginV = (mScrollViewHeight%(cellH * blockSize))/(blockSize + 1)
			end
			for i=1, blockSize do
				mYPosTable[i] = mScrollViewHeight - (i*marginV + (i-1)*cellH + cellH/2)
			end
		elseif "V" == direction then	-- 垂直滚动
			mInitBlocks = math.ceil(scrollView:getContentSize().height/(cellH + margin))
			-- 计算x轴坐标
			local marginH = 0
			if mScrollViewWidth > cellW * blockSize then
				marginH = (mScrollViewWidth%(cellW * blockSize))/(blockSize + 1)
			end
			for i=1, blockSize do
				mXPosTable[i] = i*marginH + (i-1)*cellW + cellW/2
			end
			-- 计算y轴坐标
			local scrollViewHeight = mTotalBlocks*cellH + (mTotalBlocks+1)*margin
			if mScrollViewHeight < scrollViewHeight then
				mScrollViewHeight = scrollViewHeight
			end
			for i=1, mTotalBlocks do
				mYPosTable[i] = mScrollViewHeight - (i*margin + (i-1)*cellH + cellH/2)
			end
		end
		if not dynamic or mInitBlocks > mTotalBlocks then
			mInitBlocks = mTotalBlocks
		end
		-- 设置列表宽高
		scrollView:setInnerContainerSize(cc.size(mScrollViewWidth, mScrollViewHeight))
	end
	----------------------------------------------------------------------
	-- 根据索引值获取坐标(内部接口)
	local function getPos(index)
		local xPos, yPos = 0, 0
		if "H" == direction then		-- 水平滚动
			xPos = mXPosTable[math.ceil(index/blockSize)]
			yPos = mYPosTable[index%blockSize] or mYPosTable[blockSize]
		elseif "V" == direction then	-- 垂直滚动
			xPos = mXPosTable[index%blockSize] or mXPosTable[blockSize]
			yPos = mYPosTable[math.ceil(index/blockSize)]
		end
		return xPos, yPos
	end
	----------------------------------------------------------------------
	-- 单元格是否需要显示(内部接口)
	local function isNeedShow(xPos, yPos)
		local x, y = scrollView:getInnerContainer():getPosition()
		if "H" == direction then		-- 水平滚动
			local leftScrollViewPosX = math.abs(x)
			if x > 0 then
				leftScrollViewPosX = 0
			end
			local rightScrollViewPosX = leftScrollViewPosX + scrollView:getContentSize().width
			return xPos >= leftScrollViewPosX - cellW/2 and xPos <= rightScrollViewPosX + cellW/2
		elseif "V" == direction then	-- 垂直滚动
			local bottomScrollViewPosY = math.abs(y)
			if y > 0 then
				bottomScrollViewPosY = 0
			end
			local topScrollViewPosY = bottomScrollViewPosY + scrollView:getContentSize().height
			return yPos >= bottomScrollViewPosY - cellH/2 and yPos <= topScrollViewPosY + cellH/2
		end
		return false
	end
	----------------------------------------------------------------------
	-- 创建单元格(内部接口)
	local function createCell(index)
		local cell = mCellTable[index]
		local xPos, yPos = getPos(index)
		if "table" == type(target) or "userdata" == type(target) then
			cell = createCF(target, cell, index, dataTB[index])
		else
			cell = createCF(cell, index, dataTB[index])
		end
		if not tolua.isnull(cell) then
			cell:setAnchorPoint(cc.p(0.5, 0.5))
			cell:setPosition(cc.p(xPos, yPos))
			cell:setVisible(true)
			if nil == cell:getParent() then
				scrollView:addChild(cell)
			end
			mCellTable[index] = cell
		end
	end
	----------------------------------------------------------------------
	-- 动态显示/隐藏单元格(内部接口)
	local function dynamicShowCell()
		mViewTable = {}
		local dataCount = #dataTB
		for i=1, dataCount do
			local xPos, yPos = getPos(i)
			if isNeedShow(xPos, yPos) then
				if nil == mCellTable[i] then
					createCell(i)
				else
					mCellTable[i]:setVisible(true)
				end
				table.insert(mViewTable, {["cell"] = mCellTable[i], ["index"] = i, ["data"] = dataTB[i]})
			else
				if mCellTable[i] then
					mCellTable[i]:setVisible(false)
				end
			end
		end
	end
	----------------------------------------------------------------------
	-- 初始显示块(内部接口)
	local function initBlockCells()
		local dataCount = #dataTB
		local endIndex = mInitBlocks * blockSize
		if endIndex > dataCount then
			endIndex = dataCount
		end
		for i=1, endIndex do
			createCell(i)
		end
	end
	----------------------------------------------------------------------
	-- 列表滚动事件(内部接口)
	local function eventHandler(sender, eventType)
		if ccui.ScrollviewEventType.scrolling == eventType or 9 == eventType then	-- 4.SCROLLING,9.CONTAINER_MOVED
			dynamicShowCell()
		end
		if "function" == type(scrollCF) then
			if "table" == type(target) or "userdata" == type(target) then
				scrollCF(target, sender, eventType)
			else
				scrollCF(sender, eventType)
			end
		end
	end
	----------------------------------------------------------------------
	-- 获取可视表(外部接口)
	function scrollView:getViewMap()
		local viewMap = {}
		for i, view in pairs(mViewTable) do
			local idx = math.ceil(i/blockSize)
			viewMap[idx] = viewMap[idx] or {}
			table.insert(viewMap[idx], view)
		end
		return viewMap
	end
	----------------------------------------------------------------------
	-- 刷新单元格(外部接口)
	function scrollView:refreshCell(index, data, refreshCF, target)
		if "number" ~= type(index) or index < 1 or index > #dataTB then
			return
		end
		dataTB[index] = data
		local cell = mCellTable[index]
		if not tolua.isnull(cell) and "function" == type(refreshCF) then
			local xPos, yPos = cell:getPosition()
			if "table" == type(target) or "userdata" == type(target) then
				cell = refreshCF(target, cell, index, data)
			else
				cell = refreshCF(cell, index, data)
			end
			if not tolua.isnull(cell) then
				cell:setAnchorPoint(cc.p(0.5, 0.5))
				cell:setPosition(cc.p(xPos, yPos))
				cell:setVisible(true)
				if nil == cell:getParent() then
					scrollView:addChild(cell)
				end
				mCellTable[index] = cell
			end
		end
	end
	----------------------------------------------------------------------
	init()
	initBlockCells()
	scrollView:addEventListener(eventHandler)
	if "H" == direction then		-- 水平滚动
		scrollView:jumpToLeft()
	elseif "V" == direction then	-- 垂直滚动
		scrollView:jumpToTop()
	end
end
----------------------------------------------------------------------
-- 创建滚动索引
-- scrollView:	列表控件
-- dataCount:	数据数
-- direction:	滚动方向,如:"H"水平滚动;"V"垂直滚动
-- cellW:		格子宽,如:120
-- cellH:		格子高,如:120
-- margin:		间隔(如果垂直滑动,则表示垂直间隔;如果水平滑动,则表示水平间隔),如:10
-- blockSize:	块大小(如果垂直滑动,则表示每行个数;如果水平滑动,则表示每列个数)
----------------------------------------------------------------------
function UIScrollViewIndex(scrollView, dataCount, direction, cellW, cellH, margin, blockSize)
	assert("number" == type(dataCount) and dataCount >= 0 and ("H" == direction or "V" == direction))
	assert("number" == type(cellW) and "number" == type(cellH) and "number" == type(margin))
	assert("number" == type(blockSize) and blockSize > 0)
	local viewWidth = scrollView:getContentSize().width
	local viewHeight = scrollView:getContentSize().height
	local innerWidth = scrollView:getInnerContainerSize().width
	local innerHeight = scrollView:getInnerContainerSize().height
	----------------------------------------------------------------------
	-- 计算目标位置(内部接口)
	local function calcTargetPosPercent(index)
		if index <= 1 then
			return 0
		elseif index >= dataCount then
			return 100
		end
		index = math.ceil(index/blockSize)
		local percent = 0
		if "H" == direction then
			local widthOffset = innerWidth - viewWidth
			local xPosOffset = (cellW + margin)*index - cellW/2 - viewWidth/2
			percent = (xPosOffset/widthOffset)*100
		elseif "V" == direction then
			local heightOffset = innerHeight - viewHeight
			local yPosOffset = (cellH + margin)*index - cellH/2 - viewHeight/2
			percent = (yPosOffset/heightOffset)*100
		end
		if percent < 0 then
			return 0
		elseif percent > 100 then
			return 100
		end
		return percent
	end
	----------------------------------------------------------------------
	-- 跳转到index处(外部接口)
	function scrollView:jumpTo(index)
		assert("number" == type(index) and index > 0)
		local percent = calcTargetPosPercent(index)
		if "H" == direction then
			scrollView:jumpToPercentHorizontal(percent)
		elseif "V" == direction then
			scrollView:jumpToPercentVertical(percent)
		end
	end
	----------------------------------------------------------------------
	-- 滚动到index处(外部接口)
	function scrollView:scrollTo(index, second, attenuated, scrollCF, target)
		assert("number" == type(index) and index > 0)
		assert(nil == second or ("number" == type(second) and second >= 0))
		assert(nil == attenuated or "boolean" == type(attenuated))
		local percent = calcTargetPosPercent(index)
		second = second or 0.5
		attenuated = attenuated or false
		if "H" == direction then
			scrollView:scrollToPercentHorizontal(percent, second, attenuated)
		elseif "V" == direction then
			scrollView:scrollToPercentVertical(percent, second, attenuated)
		end
		scrollView:runAction(cc.Sequence:create(cc.DelayTime:create(second), cc.CallFunc:create(function()
			if "function" == type(scrollCF) then
				if "table" == type(target) or "userdata" == type(target) then
					scrollCF(target)
				else
					scrollCF()
				end
			end
		end)))
	end
end
----------------------------------------------------------------------
-- 设置列表控件弹性动作,只支持一个子节点
-- scrollView:	列表控件
-- child:		子节点
-- bounceSize:	弹性大小,如:{width:300, height:400}
-- bounceTime:	回弹时间(秒数),如:1.0
----------------------------------------------------------------------
function UIScrollViewBounce(scrollView, child, bounceSize, bounceTime)
	if "number" ~= type(bounceTime) or bounceTime <= 0 then
		bounceTime = 0.5
	end
	local direction = scrollView:getDirection()
	local displaySize = scrollView:getCustomSize()
	if ccui.ScrollViewDir.horizontal == direction and bounceSize.width < displaySize.width then
		bounceSize.width = displaySize.width
	elseif ccui.ScrollViewDir.vertical == direction and bounceSize.height < displaySize.height then
		bounceSize.height = displaySize.height
	end
	scrollView:setInnerContainerSize(bounceSize)
	local xPos, yPos = 0, 0
	if ccui.ScrollViewDir.horizontal == direction then
		xPos = -(bounceSize.width - displaySize.width)/2
	elseif ccui.ScrollViewDir.vertical == direction then
		yPos = -(bounceSize.height - displaySize.height)/2
	end
	scrollView:getInnerContainer():setPosition(cc.p(xPos, yPos))
	scrollView:addTouchEventListener(function(sender, eventType)
		if ccui.TouchEventType.began == eventType then
			scrollView:getInnerContainer():stopAllActions()
		elseif ccui.TouchEventType.canceled == eventType or ccui.TouchEventType.ended == eventType then
			local bounceAction = cc.EaseExponentialOut:create(cc.MoveTo:create(bounceTime, cc.p(xPos, yPos)))
			scrollView:getInnerContainer():runAction(cc.Sequence:create(bounceAction, cc.CallFunc:create(function()
				scrollView:getInnerContainer():setPosition(cc.p(xPos, yPos))
			end)))
		end
	end)
	scrollView:addChild(child)
	child:setPosition(cc.p(bounceSize.width/2, bounceSize.height/2))
end
----------------------------------------------------------------------