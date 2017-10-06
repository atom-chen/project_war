----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 地图视图
----------------------------------------------------------------------
-- 地图视图,坐标系以左上角为原点(从左->右,从上->下)
MapView = class("MapView", Component)

-- 构造函数
function MapView:ctor()
	self.super:ctor(self.__cname)
	self.mRowCount = 8								-- 行数
	self.mColCount = 7								-- 列数
	self.mGridWidth = 64							-- 格子宽度
	self.mGridHeight = 64							-- 格子高度
	self.mGridGap = 5								-- 格子间距
	self.mGridTouchGap = 5							-- 格子触摸间距
	self.mTouchArea = cc.rect(0, 0, 0, 0)			-- 触摸区域
	self.mTouchFlag = 0								-- 触摸标识
	self.mGridPosTable = {}							-- 格子坐标表
	self.mTouchLayer = nil							-- 触摸层(root)
	self.mSceneLayer = nil							-- 场景层(最下层)
	self.mMapLayer = nil							-- 地图层(中间层)
	self.mTopLayer = nil							-- 最顶层(最上层)
end

-- 初始化
function MapView:init(rowCount, colCount, gridW, gridH, gridGap, gridTouchGap, visibleW, visibleH, mapYOffset)
	self.mRowCount = rowCount
	self.mColCount = colCount
	self.mGridWidth = gridW
	self.mGridHeight = gridH
	self.mGridGap = gridGap
	self.mGridTouchGap = gridTouchGap
	local mapSize = cc.size(colCount*(gridW + gridGap) + gridGap, rowCount*(gridH + gridGap) + gridGap)
	self.mTouchArea = cc.rect((visibleW - mapSize.width)/2, visibleH - mapSize.height - mapYOffset, mapSize.width, mapSize.height)
	self.mGridPosTable = self:createGridPosTable(rowCount, colCount, gridW, gridH, gridGap, self.mTouchArea.x, mapYOffset)
	-- 触摸层
	self.mTouchLayer = self:createTouchLayer(function(touch, event)
		self:onTouch(touch, event, event:getEventCode())
		return true
	end)
	-- 场景层
	self.mSceneLayer = cc.Layer:create()
	self.mTouchLayer:addChild(self.mSceneLayer, 101)
	-- 地图层
	self.mMapLayer = cc.Layer:create()
	self.mTouchLayer:addChild(self.mMapLayer, 102)
	-- 最顶层
	self.mTopLayer = cc.Layer:create()
	self.mTouchLayer:addChild(self.mTopLayer, 103)
end

-- 创建格子坐标表
function MapView:createGridPosTable(rowCount, colCount, gridW, gridH, gridGap, xOffset, yOffset)
	local gridPosTable = {}
	for row = 1, rowCount do
		gridPosTable[row] = {}
		for col = 1, colCount do
			local xPos = col*gridGap + (col - 1)*gridW + gridW/2 + xOffset
			local yPos = (rowCount - row + 1)*gridGap + (rowCount - row)*gridH + gridH/2 + yOffset
			gridPosTable[row][col] = {
				x = xPos,											-- 格子x坐标
				y = yPos,											-- 格子y坐标
				up = cc.p(xPos, yPos + gridH/2 + gridGap/2),		-- 格子上隔板坐标
				right = cc.p(xPos + gridW/2 + gridGap/2, yPos),		-- 格子右隔板坐标
				down = cc.p(xPos, yPos - gridH/2 - gridGap/2),		-- 格子下隔板坐标
				left = cc.p(xPos - gridW/2 - gridGap/2, yPos),		-- 格子左隔板坐标
			}
		end
	end
	return gridPosTable
end

-- 创建触摸层
function MapView:createTouchLayer(onTouchCF)
	local listener = cc.EventListenerTouchOneByOne:create()
	listener:registerScriptHandler(onTouchCF, cc.Handler.EVENT_TOUCH_BEGAN)
	listener:registerScriptHandler(onTouchCF, cc.Handler.EVENT_TOUCH_MOVED)
	listener:registerScriptHandler(onTouchCF, cc.Handler.EVENT_TOUCH_ENDED)
	listener:registerScriptHandler(onTouchCF, cc.Handler.EVENT_TOUCH_CANCELLED)
	listener:setSwallowTouches(true)
	local touchLayer = cc.Layer:create()
	touchLayer:getEventDispatcher():addEventListenerWithSceneGraphPriority(listener, touchLayer)
	return touchLayer
end

-- 计算格子索引
function MapView:calcGridIndex(rowCount, colCount, gridW, gridH, gridGap, gridTouchGap, x, y)
	-- 限定触摸区域
	if x < 0 or x > colCount*(gridW + gridGap) + gridGap or y < 0 or y > rowCount*(gridH + gridGap) + gridGap then
		return 0, 0
	end
	-- 计算列索引
	local col = math.ceil(x/(gridW + gridGap))
	if 0 == col then
		col = 1
	elseif col > colCount then
		col = colCount
	end
	-- 限定格子触摸宽度
	local minColX, maxColX = col*gridGap + (col - 1)*gridW + gridTouchGap, col*gridGap + col*gridW - gridTouchGap
	if x < minColX or x > maxColX then
		col = 0
	end
	-- 计算行索引
	local row = math.ceil(y/(gridH + gridGap))
	if 0 == row then
		row = 1
	elseif row > rowCount then
		row = rowCount
	end
	-- 限定格子触摸高度
	local minRowY, maxRowY = row*gridGap + (row - 1)*gridH + gridTouchGap, row*gridGap + row*gridH - gridTouchGap
	if y < minRowY or y > maxRowY then
		row = 0
	end
	return row, col
end

-- 获取格子信息
function MapView:getGridInfo(x, y)
	if not cc.rectContainsPoint(self.mTouchArea, cc.p(x, y)) then
		return nil
	end
	x, y = x - self.mTouchArea.x, y - self.mTouchArea.y		-- 转换为在触摸区域的坐标
	local row, col = self:calcGridIndex(self.mRowCount, self.mColCount, self.mGridWidth, self.mGridHeight, self.mGridGap, self.mGridTouchGap, x, y)
	if 0 == row or 0 == col then
		return nil
	end
	local gridInfo = {
		row = row,											-- 格子行索引值
		col = col,											-- 格子列索引值
		pos = {
			x = self.mGridPosTable[row][col].x,				-- 格子x坐标
			y = self.mGridPosTable[row][col].y,				-- 格子y坐标
			up = self.mGridPosTable[row][col].up,			-- 格子上隔板坐标
			right = self.mGridPosTable[row][col].right,		-- 格子右隔板坐标
			down = self.mGridPosTable[row][col].down,		-- 格子下隔板坐标
			left = self.mGridPosTable[row][col].left		-- 格子左隔板坐标
		}
	}
	return gridInfo
end

-- 触摸
function MapView:onTouch(touch, event, eventCode)
	if not self:isTouchEnabled() then
		return
	end
	local locationInView = touch:getLocationInView()
	local gridInfo = self:getGridInfo(locationInView.x, locationInView.y)
	if cc.EventCode.BEGAN == eventCode then
		if 0 == self.mTouchFlag then
			self:onTouchBegan(touch, event, gridInfo)
		end
		self.mTouchFlag = self.mTouchFlag + 1
	elseif cc.EventCode.MOVED == eventCode then
		self:onTouchMoved(touch, event, gridInfo)
	elseif cc.EventCode.ENDED == eventCode then
		self.mTouchFlag = self.mTouchFlag - 1
		if 0 == self.mTouchFlag then
			self:onTouchEnded(touch, event, gridInfo)
		end
	elseif cc.EventCode.CANCELLED == eventCode then
		self.mTouchFlag = self.mTouchFlag - 1
		if 0 == self.mTouchFlag then
			self:onTouchCancelled(touch, event, gridInfo)
		end
	end
end

-- 获取行数,列数
function MapView:getRowCol()
	return self.mRowCount, self.mColCount
end

-- 获取格子坐标
function MapView:getGridPos(row, col)
	local pos = {
		x = self.mGridPosTable[row][col].x,				-- 格子x坐标
		y = self.mGridPosTable[row][col].y,				-- 格子y坐标
		up = self.mGridPosTable[row][col].up,			-- 格子上隔板坐标
		right = self.mGridPosTable[row][col].right,		-- 格子右隔板坐标
		down = self.mGridPosTable[row][col].down,		-- 格子下隔板坐标
		left = self.mGridPosTable[row][col].left		-- 格子左隔板坐标
	}
	return pos
end

-- 获取触摸区域
function MapView:getTouchArea()
	return cc.rect(self.mTouchArea.x, self.mTouchArea.y, self.mTouchArea.width, self.mTouchArea.height)
end

-- 获取触摸标识
function MapView:getTouchFlag()
	return self.mTouchFlag
end

-- 获取触摸层
function MapView:getLayer()
	return self.mTouchLayer
end

-- 获取场景层
function MapView:getSceneLayer()
	return self.mSceneLayer
end

-- 获取地图层
function MapView:getMapLayer()
	return self.mMapLayer
end

-- 获取最顶层
function MapView:getTopLayer()
	return self.mTopLayer
end

