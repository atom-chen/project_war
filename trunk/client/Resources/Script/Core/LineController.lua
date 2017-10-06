----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 连线控制器
----------------------------------------------------------------------
LineController = class("LineController", Component)

-- 构造函数
function LineController:ctor()
	self.super:ctor(self.__cname)
	self.mConnectLineList = {}		-- 连线列表
	self.mLineNeedCount = 0			-- 需要至少n个格子才会连线
	-- 注册事件
	self:bind(EventDef["ED_TOUCH_GRID_BEGIN"], self.handleTouchGridBegin, self)
	self:bind(EventDef["ED_TOUCH_GRID_MOVE"], self.handleTouchGridMove, self)
	self:bind(EventDef["ED_TOUCH_GRID_END"], self.handleTouchGridEnd, self)
end

-- 设置需要至少n个才会连线
function LineController:setNeedCount(needCount)
	self.mLineNeedCount = needCount or 0
end

-- 添加连线
function LineController:addLine(touchCoordList)
	local function createLine(index)
		local startCoord = touchCoordList[index - 1]
		local endCoord = touchCoordList[index]
		if nil == startCoord or nil == endCoord then
			return
		end
		local startPos = self:getMaster():getGridPos(startCoord.row, startCoord.col)
		local endPos = self:getMaster():getGridPos(endCoord.row, endCoord.col)
		local line = EffectLine.new(startCoord, startPos, endCoord, endPos, self:getMaster():getMapLayer())
		table.insert(self.mConnectLineList, line)
	end
	local touchCount = #touchCoordList
	self:lineMusic(touchCount)
	-- 连线效果
	if touchCount < self.mLineNeedCount then
		return
	elseif touchCount == self.mLineNeedCount then
		for i=2, touchCount do
			createLine(i)
		end
	else
		createLine(touchCount)
	end
	for key, line in pairs(self.mConnectLineList) do
		line:update(touchCount)
	end
end

-- 移除连线
function LineController:removeLine(touchCount)
	self:lineMusic(touchCount)
	-- 取消所有连线
	if touchCount < self.mLineNeedCount then
		self:clearLines()
		return
	end
	-- 减去最后一条连线
	local lineCount = #self.mConnectLineList
	self.mConnectLineList[lineCount]:destroy()
	self.mConnectLineList[lineCount] = nil
	for key, line in pairs(self.mConnectLineList) do
		line:update(touchCount)
	end
end

-- 清空连线
function LineController:clearLines()
	for i, line in pairs(self.mConnectLineList) do
		line:destroy()
	end
	self.mConnectLineList = {}
end

-- 连线音效
function LineController:lineMusic(count)
	local effectIdList = {2101, 2102, 2103, 2104, 2105, 2106, 2107, 2108, 2109, 2110, 2111, 2112, 2113, 2114, 2115}
	local effectIdCount = #effectIdList
	if count > effectIdCount then
		count = effectIdCount
	end
	AudioMgr:playEffect(effectIdList[count])
end

-- 处理触摸格子开始事件
function LineController:handleTouchGridBegin(touchParam)
	self:setNeedCount(touchParam.touched_min_count)
end

-- 处理触摸格子移动事件
function LineController:handleTouchGridMove(touchParam)
	if touchParam.touched_advance then	-- 前进
		self:addLine(touchParam.touched_coord_list)
	else	-- 后退
		self:removeLine(touchParam.touched_count)
	end
end

-- 处理触摸格子结束事件
function LineController:handleTouchGridEnd(touchParam)
	self:clearLines()
end
