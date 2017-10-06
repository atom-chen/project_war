----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 格子
----------------------------------------------------------------------
Grid = class("Grid")

-- 构造函数
function Grid:ctor()
	self.mController = nil					-- 控制器
	self.mRow = 0							-- 行索引值
	self.mCol = 0							-- 列索引值
	self.mIsBorn = false					-- 是否在出生点
	self.mNode = cc.Node:create()			-- 创建节点
	self.mTipCircle = nil					-- 提示圈,放在格子节点第1层
	self.mShowElement = nil					-- 显示元素,放在格子节点第2层
	self.mFixedElement = nil				-- 固定元素,放在格子节点第3层
	self.mCoverElement = nil				-- 覆盖元素,放在格子节点第4层
	self.mIsOnSelectEnter = false			-- 是否选中状态
end

-- 清空元素
function Grid:destroyElements()
	if self.mTipCircle then
		self.mTipCircle:removeFromParent()
		self.mTipCircle = nil
	end
	if self.mShowElement then
		self.mShowElement:destroy()
		self.mShowElement = nil
	end
	if self.mFixedElement then
		self.mFixedElement:destroy()
		self.mFixedElement = nil
	end
	if self.mCoverElement then
		self.mCoverElement:destroy()
		self.mCoverElement = nil
	end
end

-- 销毁节点
function Grid:destroyNode()
	self:destroyElements()
	if self.mNode then
		self.mNode:removeFromParent()
		self.mNode = nil
	end
end

-- 销毁函数
function Grid:destroy()
	self.mController:setGrid(self.mRow, self.mCol, nil, nil)
	self:destroyNode()
end

-- 设置控制器
function Grid:setController(controller)
	self.mController = controller
end

-- 设置索引坐标
function Grid:setCoord(row, col)
	self.mRow = row or self.mRow
	self.mCol = col or self.mCol
	self.mIsBorn = self.mController:isBornCoord(Core:makeCoord(self.mRow, self.mCol))
end

-- 获取索引坐标
function Grid:getCoord()
	return Core:makeCoord(self.mRow, self.mCol)
end

-- 是否在出生点
function Grid:isBorn()
	return self.mIsBorn
end

-- 获取节点
function Grid:getNode()
	return self.mNode
end

-- 设置元素
function Grid:setElement(element)
	if nil == self.mNode or nil == element then
		return 0
	end
	local elementType, elementSubType = element:getType(), element:getSubType()
	if ElementType["throw"] == elementType and ElementThrowType["cover"] == elementSubType then			-- 覆盖元素
		element.is_cover = true
		if self.mCoverElement then
			self.mCoverElement:destroy()
			self.mCoverElement = nil
		end
		self.mCoverElement = element
		self.mNode:addChild(element:getSprite(), 4)
		return 3
	elseif ElementType["throw"] == elementType and ElementThrowType["fixed"] == elementSubType then		-- 固定元素
		element.is_fixed = true
		if self.mFixedElement then
			self.mFixedElement:destroy()
			self.mFixedElement = nil
		end
		self.mFixedElement = element
		self.mNode:addChild(element:getSprite(), 3)
		return 2
	else	-- 显示元素
		element.is_show = true
		if self.mShowElement then
			self.mShowElement:destroy()
			self.mShowElement = nil
		end
		self.mShowElement = element
		self.mNode:addChild(element:getSprite(), 2)
		return 1
	end
end

-- 获取显示元素
function Grid:getShowElement()
	return self.mShowElement
end

-- 获取固定元素
function Grid:getFixedElement()
	return self.mFixedElement
end

-- 获取覆盖元素
function Grid:getCoverElement()
	return self.mCoverElement
end

-- 设置灰态
function Grid:setGray(grayFlag)
	if nil == self.mShowElement then
		return
	end
	if grayFlag then
		self.mShowElement:getSprite():setOpacity(130)
		self.mNode:stopAllActions()
	else
		self.mShowElement:getSprite():setOpacity(255)
	end
end

-- 显示提示圈
function Grid:showTipCircle(show)
	if nil == self.mShowElement or ElementType["obstacle"] == self.mShowElement:getType() then
		return
	end
	if nil == self.mTipCircle and show then
		self.mTipCircle = cc.Sprite:create("tip_circle.png")
		self.mTipCircle:runAction(cc.RepeatForever:create(cc.RotateBy:create(0.2, -20)))
		self.mNode:addChild(self.mTipCircle, 1)
	elseif self.mTipCircle and not show then
		self.mTipCircle:removeFromParent()
		self.mTipCircle = nil
	end
end

-- 是否可触摸
function Grid:isCanTouch()
	if nil == self.mCoverElement or self.mCoverElement:isCanTouch() then		-- 覆盖元素为空,或者覆盖元素存在且可触摸
		return self.mShowElement and self.mShowElement:isCanTouch()				-- 显示元素存在且可触摸
	end
	return false
end

-- 是否可连接
function Grid:isCanConnect()
	if nil == self.mCoverElement or self.mCoverElement:isCanConnect() then		-- 覆盖元素为空,或者覆盖元素存在且可连接
		return self.mShowElement and self.mShowElement:isCanConnect()			-- 显示元素存在且可连接
	end
	return false
end

-- 是否可掉落
function Grid:isCanDrop()
	if nil == self.mCoverElement or self.mCoverElement:isCanDrop() then			-- 覆盖元素为空,或者覆盖元素存在且可掉落
		if nil == self.mFixedElement or self.mFixedElement:isCanDrop() then		-- 固定元素为空,或者固定元素存在且可掉落
			return self.mShowElement and self.mShowElement:isCanDrop()			-- 显示元素存在且可掉落
		end
	end
	return false
end

-- 是否可消除
function Grid:isCanClear()
	if nil == self.mCoverElement or self.mCoverElement:isCanClear() then		-- 覆盖元素为空,或者覆盖元素存在且可消除
		if nil == self.mFixedElement or self.mFixedElement:isCanClear() then	-- 固定元素为空,或者固定元素存在且可消除
			return self.mShowElement and self.mShowElement:isCanClear()			-- 显示元素存在且可消除
		end
	end
	return false
end

-- 是否可重置
function Grid:isCanReset()
	if nil == self.mCoverElement or self.mCoverElement:isCanReset() then		-- 覆盖元素为空,或者覆盖元素存在且可重置
		if nil == self.mFixedElement or self.mFixedElement:isCanReset() then	-- 固定元素为空,或者固定元素存在且可重置
			return self.mShowElement and self.mShowElement:isCanReset()			-- 显示元素存在且可重置
		end
	end
	return false
end

-- 显示奖励提示
function Grid:showAwardTip(awardId, pos, index)
	if 0 == awardId then
		return
	end
	local awardData = LogicTable:getAwardData(awardId)
	if AwardType["item"] == awardData.type then
		local itemData = LogicTable:get("item_tplt", awardData.sub_id, true)
		-- 奖励图片
		local imageSprite = cc.Sprite:create(itemData.image)
		imageSprite:setAnchorPoint(cc.p(1, 0.5))
		imageSprite:setPosition(pos)
		imageSprite:setVisible(false)
		MapManager:getMap():getTopLayer():addChild(imageSprite, G.TOP_ZORDER_TIP)
		Actions:delayWith(imageSprite, index*0.2, function()
			imageSprite:setVisible(true)
			Actions:scaleAction03(imageSprite)
		end)
		-- 奖励数量
		local countLabelBMfont = cc.Label:createWithBMFont("font_01.fnt", tostring(awardData.count), cc.TEXT_ALIGNMENT_CENTER)
		countLabelBMfont:setScale(1.8)
		countLabelBMfont:setAnchorPoint(cc.p(0, 0.5))
		countLabelBMfont:setPosition(pos)
		countLabelBMfont:setVisible(false)
		MapManager:getMap():getTopLayer():addChild(countLabelBMfont, G.TOP_ZORDER_TIP)
		Actions:delayWith(imageSprite, index*0.2, function()
			countLabelBMfont:setVisible(true)
			Actions:scaleAction03(countLabelBMfont)
		end)
		AudioMgr:playEffect(2015)
	end
end

-- 计算可消除的元素数据(遇到不可消除,则返回对应元素id)
function Grid:calcCanClearElementData(elementDataList, elementId)
	local elementData = LogicTable:get("element_tplt", elementId, true)
	if 0 == elementData.is_can_clear then	-- 不可消除
		return elementId
	else
		table.insert(elementDataList, elementData)
	end
	if 0 == elementData.next_id then
		return nil
	end
	return self:calcCanClearElementData(elementDataList, elementData.next_id)
end

-- 消除元素
function Grid:clearElement(element, clearCF, index, isForce, clearType)
	if nil == element then
		return false
	end
	-- 参数信息计算
	local xPos, yPos = self.mNode:getPosition()
	local param = {
		coord = self:getCoord(),			-- 索引坐标
		pos = cc.p(xPos, yPos),				-- 位置坐标
		parent = self.mNode:getParent(),	-- 父节点
		index = index,						-- 在消除列表中的索引
	}
	-- 判断格子元素是否都为空
	local function checkEmptyElement(element)
		if element.is_show then
			self.mShowElement = nil
		elseif element.is_fixed then
			self.mFixedElement = nil
		elseif element.is_cover then
			self.mCoverElement = nil
		end
		if nil == self.mShowElement and nil == self.mFixedElement and nil == self.mCoverElement then
			self:destroy()
		end
	end
	-- 生成下一个元素
	local function generateNextElement(element, nextElementId)
		self:setElement(Factory:createElement(nextElementId))
		local data, _ = self.mController:getGrid(self.mRow, self.mCol)
		if element.is_show then
			data[1] = nextElementId
		elseif element.is_fixed then
			data[2] = nextElementId
		elseif element.is_cover then
			data[3] = nextElementId
		end
		self.mController:setGrid(self.mRow, self.mCol, data, self)
	end
	-- 元素消除操作
	local elementDataList = {}	-- 操作一次可消除的元素数据列表
	element:clear(param, function()
		local elementData = element:getData()
		table.insert(elementDataList, elementData)
		-- 播放特效
		if "nil" ~= elementData.effect then
			local particle = Utils:createParticle(elementData.effect, true)
			particle:setPosition(cc.p(xPos, yPos))
			self.mNode:getParent():addChild(particle, G.MAP_ZORDER_EFFECT)
		end
		-- 播放音效
		if elementData.sound > 0 then
			if ElementType["normal"] ~= element:getType() and ElementType["skill"] ~= element:getType() then
				AudioMgr:playEffect(elementData.sound)
			end
		end
		-- 生成下一个指向元素
		local nextElementId = elementData.next_id
		if nextElementId > 0 then
			-- 强力消除,或格子被影响
			if isForce or self.mController:isPassiveCoord(self:getCoord()) then
				nextElementId = self:calcCanClearElementData(elementDataList, nextElementId)
				if nil == nextElementId then	-- 没有不可消除的元素
					checkEmptyElement(element)
					return
				end
			end
			generateNextElement(element, nextElementId)
		else
			checkEmptyElement(element)
		end
	end, function()
		-- 奖励特效
		for i, elementData in pairs(elementDataList) do
			if 2 == clearType then
				if ElementType["normal"] == elementData.type then		-- 普通元素,奖励1个毛球
					elementData.award_id = 1000
				elseif ElementType["skill"] == elementData.type then	-- 技能元素,奖励1个砖石
					elementData.award_id = 4001
				end
			end
			self:showAwardTip(elementData.award_id, cc.p(xPos, yPos), i)
		end
		Utils:doCallback(clearCF, elementDataList)
	end)
	return true
end

-- 格子消除
function Grid:onClear(clearCF, index, isForce, clearType)
	if nil == self.mNode then
		Utils:doCallback(clearCF, {})
		return
	end
	-- 强力消除
	if isForce then
		self:clearElement(self.mCoverElement, nil, index, true, clearType)
		self:clearElement(self.mFixedElement, nil, index, true, clearType)
		if self.mShowElement:isCanClear() then
			self:clearElement(self.mShowElement, clearCF, index, true, clearType)
		else
			self.mShowElement:onAffect()
			Utils:doCallback(clearCF, {})
		end
		return
	end
	-- 非强力消除
	if self:clearElement(self.mCoverElement, clearCF, index, false, clearType) then		-- 先消除覆盖元素
		return
	end
	if self:clearElement(self.mFixedElement, clearCF, index, false, clearType) then		-- 再消除固定元素
		self:onSelectExit()
		return
	end
	if self.mShowElement:isCanClear() then
		self:clearElement(self.mShowElement, clearCF, index, false, clearType)			-- 最后消除显示元素
	else
		self.mShowElement:onAffect()
		Utils:doCallback(clearCF, {})
	end
end

-- 格子选中
function Grid:onSelectEnter()
	if self.mShowElement and self.mShowElement:isCanTouch() then
		self.mShowElement:onFocusEnter()
		Actions:shakeAction01(self.mShowElement:getSprite())
	end
	self.mIsOnSelectEnter = true
end

-- 格子取消选中
function Grid:onSelectExit()
	if not self.mIsOnSelectEnter then
		return
	end
	self.mIsOnSelectEnter = false
	if self.mShowElement and self.mShowElement:isCanTouch() then
		self.mShowElement:onFocusExit()
		Actions:shakeAction01(self.mShowElement:getSprite())
	end
end

-- 格子受影响
function Grid:onAffectEnter(affectType)
	if self.mCoverElement or self.mFixedElement then
		return
	end
	local param = {
		grid = self,				-- 格子
		affect_type = affectType,	-- 影响类型(1.提示,2.技能)
	}
	if self.mShowElement then
		self.mShowElement:onActiveEnter(param)
	end
end

-- 格子取消受影响
function Grid:onAffectExit(affectType)
	if self.mCoverElement or self.mFixedElement then
		return
	end
	local param = {
		grid = self,				-- 格子
		affect_type = affectType,	-- 影响类型(1.提示,2.技能)
	}
	if self.mShowElement then
		self.mShowElement:onActiveExit(param)
	end
end

-- 格子掉落
function Grid:onDrop(batchTimes, dropCoordPath, dropCF)
	if nil == self.mNode or 0 == #dropCoordPath then
		Utils:doCallback(dropCF)
		return
	end
	self.mNode:setVisible(true)
	local pathArray = {}
	for i, coord in pairs(dropCoordPath) do
		local pos = MapManager:getMap():getGridPos(coord.row, coord.col)
		table.insert(pathArray, cc.p(pos.x, pos.y))
	end
	Actions:delayWith(self.mNode, 0.15*batchTimes, function()
		Actions:moveToWithPath(self.mNode, pathArray, 0.12, function()
			if self.mShowElement and self.mShowElement:isCanTouch() then
				Actions:shakeAction02(self.mShowElement:getSprite())
			end
			Utils:doCallback(dropCF)
		end)
	end)
end

-- 格子重置
function Grid:onReset(resetCoordPath, resetCF)
	if nil == self.mNode or 0 == #resetCoordPath then
		Utils:doCallback(resetCF)
		return
	end
	local pathArray = {}
	for i, coord in pairs(resetCoordPath) do
		local pos = MapManager:getMap():getGridPos(coord.row, coord.col)
		table.insert(pathArray, cc.p(pos.x, pos.y))
	end
	Actions:moveToWithPath(self.mNode, pathArray, 0.2, function()
		Utils:doCallback(resetCF)
	end)
end


