----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 投放控制器
----------------------------------------------------------------------
ThrowController = class("ThrowController", Component)

-- 构造函数
function ThrowController:ctor()
	self.super:ctor(self.__cname)
	self.mThrowCoordList = {}			-- 投放坐标列表
	self.mNewThrowCoordList = {}		-- 当前回合新投放的坐标
	self.mWetlandCD = 0					-- 沼泽地冷却回合(0.激活中;>0.冷却中)
end

-- 获取可投放格子
function ThrowController:getCanThrowGrids(throwElementId)
	if nil == throwElementId or 0 == throwElementId then
		return {}
	end
	local data = LogicTable:get("element_tplt", throwElementId, true)
	if ElementType["throw"] ~= data.type then
		return {}
	end
	-- 遍历格子
	local canThrowGrids = {}
	local gridNodes = self:getSibling("GridController"):getGridNodes()
	for row, rowGrids in pairs(gridNodes) do
		for col, grid in pairs(rowGrids) do
			local showElementType = grid:getShowElement():getType()
			local fixedElement = grid:getFixedElement()
			local coverElement = grid:getCoverElement()
			-- 格子可消除,普通元素,特殊元素
			if not grid:isBorn() and grid:isCanClear() and not Core:isCoordExist(self.mThrowCoordList, grid:getCoord()) and (ElementType["normal"] == showElementType or ElementType["special"] == showElementType) then
				if ElementThrowType["cover"] == data.sub_type and nil == coverElement then	-- 覆盖元素,且格子无覆盖元素
					table.insert(canThrowGrids, grid)
				elseif ElementThrowType["replace"] == data.sub_type and nil == fixedElement and nil == coverElement then	-- 替换元素,且格子无固定元素和覆盖元素
					if grid:getShowElement():isCanTouch() then
						table.insert(canThrowGrids, grid)
					end
				elseif ElementThrowType["fixed"] == data.sub_type and nil == fixedElement then		-- 固定元素,且格子无固定元素
					if grid:getShowElement():isCanTouch() then
						table.insert(canThrowGrids, grid)
					end
				end
			end
		end
	end
	return canThrowGrids
end

-- 获取随机投放格子
function ThrowController:getRandomThrowGrid(throwElementId)
	local canThrowGrids = self:getCanThrowGrids(throwElementId)
	if 0 == #canThrowGrids then
		return nil
	end
	local index = math.random(1, #canThrowGrids)
	return canThrowGrids[index]
end

-- 设置投放格子
function ThrowController:setThrowGrid(grid, throwElement, setCF)
	local elementId = throwElement:getData().id
	local xPos, yPos = throwElement:getSprite():getPosition()
	local coord = grid:getCoord()
	local pos = self:getMaster():getGridPos(coord.row, coord.col)
	local cfg = {
		cc.p(xPos, yPos),
		cc.p(xPos + (pos.x - xPos)*2/3, yPos + 60),
		cc.p(pos.x, pos.y),
	}
	Actions:delayWith(throwElement:getSprite(), 0.5, function()
		throwElement:getSprite():setVisible(true)
		Actions:bezierTo(throwElement:getSprite(), cfg, 0.3, function()
			throwElement:destroy()
			local data, _ = self:getSibling("GridController"):getGrid(coord.row, coord.col)
			local index = grid:setElement(Factory:createElement(elementId))
			if index > 0 then
				data[index] = elementId
			end
			self:getSibling("GridController"):setGrid(coord.row, coord.col, data, grid)
			table.insert(self.mNewThrowCoordList, coord)
			Utils:doCallback(setCF)
		end)
		AudioMgr:playEffect(2401)
	end)
end

-- 投放到格子
function ThrowController:throwToGrid(throwElementIds)
	self.mThrowCoordList = {}
	local totalThrowCount = #throwElementIds
	if 0 == totalThrowCount then
		self:triggerThrowReplace()
		return false
	end
	local throwFlag = false
	local monsterController = self:getSibling("MonsterController")
	local xPos, yPos = monsterController:getMonster():getNode():getPosition()
	local monsterDisplay = monsterController:getMonster():getDisplay()
	for i, throwElementId in pairs(throwElementIds) do
		local grid = self:getRandomThrowGrid(throwElementId)
		if grid then
			throwFlag = true
			Core:addCoord(self.mThrowCoordList, grid:getCoord())
			local throwElement = Factory:createElement(throwElementId)
			self:getMaster():getTopLayer():addChild(throwElement:getSprite(), G.TOP_ZORDER_THROW)
			if "monster_01" == monsterDisplay then		-- 螃蟹
				throwElement:getSprite():setPosition(cc.p(xPos, yPos + 60))
			elseif "monster_02" == monsterDisplay then	-- 章鱼
				throwElement:getSprite():setPosition(cc.p(xPos - 40, yPos + 60))
			elseif "monster_03" == monsterDisplay then	-- 鲨鱼
				throwElement:getSprite():setPosition(cc.p(xPos - 40, yPos + 60))
			elseif "monster_04" == monsterDisplay then	-- 河豚
				throwElement:getSprite():setPosition(cc.p(xPos - 60, yPos + 110))
			elseif "monster_05" == monsterDisplay then	-- 灯笼鱼
				throwElement:getSprite():setPosition(cc.p(xPos - 90, yPos + 110))
			else
				throwElement:getSprite():setPosition(cc.p(xPos, yPos + 60))
			end
			throwElement:getSprite():setVisible(false)
			self:setThrowGrid(grid, throwElement, function()
				totalThrowCount = totalThrowCount - 1
				if 0 == totalThrowCount then
					self:triggerThrowReplace()
				end
			end)
		end
	end
	if throwFlag then
		return true
	end
	self:triggerThrowReplace()
	return false
end

-- 计算替换信息
function ThrowController:calcReplaceInfo()
	local replaceInfo = {
		empty_coord_list = {},		-- 空格子的坐标列表
		valid_coord_list = {},		-- 可被替换的坐标列表
		trigger_grid_list = {},		-- 触发替换的格子列表
	}
	local gridController = self:getSibling("GridController")
	local rowCount, colCount = self:getMaster():getRowCol()
	for row=rowCount, 2, -1 do
		for col=1, colCount do
			local _, grid = gridController:getGrid(row, col)
			if nil == grid then
				table.insert(replaceInfo.empty_coord_list, Core:makeCoord(row, col))
			elseif not grid:isBorn() then
				local showElement = grid:getShowElement()
				-- 无固定元素,无覆盖元素,普通元素|技能元素,非出生点
				if nil == grid:getFixedElement() and nil == grid:getCoverElement() and
					(ElementType["normal"] == showElement:getType() or ElementType["skill"] == showElement:getType()) then
					table.insert(replaceInfo.valid_coord_list, grid:getCoord())
				end
				-- 投放元素,替换类,非新投放
				if ElementType["throw"] == showElement:getType() and ElementThrowType["replace"] == showElement:getSubType() and not Core:isCoordExist(self.mNewThrowCoordList, grid:getCoord()) then
					local replaceType = showElement:getExtraType()
					-- 食人怪,沼泽地,黑色大炮,银色大炮
					if ElementThrowReplaceType["cannibal"] == replaceType or ElementThrowReplaceType["wetland"] == replaceType or
						ElementThrowReplaceType["volcano_black"] == replaceType or ElementThrowReplaceType["volcano_silver"] == replaceType then
						if nil == replaceInfo.trigger_grid_list[replaceType] then
							replaceInfo.trigger_grid_list[replaceType] = {}
						end
						table.insert(replaceInfo.trigger_grid_list[replaceType], grid)
					end
				end
			end
		end
	end
	self.mNewThrowCoordList = {}
	return replaceInfo
end

-- 沼泽地冷却
function ThrowController:wetlandCold()
	self.mWetlandCD = 2			-- 1回合冷却(值=1+冷却回合数)
end

-- 搜索沼泽地
function ThrowController:searchWetland(triggerGridList, validCoordList, boardDatas)
	local wetlandGridList = triggerGridList[ElementThrowReplaceType["wetland"]]
	if nil == wetlandGridList then
		return nil
	end
	if self.mWetlandCD > 0 then
		self.mWetlandCD = self.mWetlandCD - 1
		return nil
	end
	local wetlandRandomInfoList = {}
	for key, grid in pairs(wetlandGridList) do
		for k, validCoord in pairs(validCoordList) do
			local coord = grid:getCoord()
			if Core:isCanContact(coord, validCoord, boardDatas) then
				local wetlandRandomInfo = {
					coord = coord,				-- 起始坐标
					target = validCoord			-- 目的坐标
				}
				table.insert(wetlandRandomInfoList, wetlandRandomInfo)
			end
		end
	end
	local wetlandRandomInfoCount = #wetlandRandomInfoList
	if 0 == wetlandRandomInfoCount then
		return nil
	end
	local wetlandRandomInfo = wetlandRandomInfoList[math.random(1, wetlandRandomInfoCount)]
	Core:removeCoord(validCoordList, wetlandRandomInfo.target)
	return wetlandRandomInfo
end

-- 触发沼泽地
function ThrowController:triggerWetland(wetlandRandomInfo, gridController, triggerCF)
	if nil == wetlandRandomInfo then
		return
	end
	local coord, target = wetlandRandomInfo.coord, wetlandRandomInfo.target
	local _, grid = gridController:getGrid(target.row, target.col)
	local newGrid = gridController:createGrid(target.row, target.col, {4010})
	Actions:fadeOut(grid:getNode(), 0.2, function()
		grid:destroyNode()
	end)
	Actions:scaleFromTo(newGrid:getNode(), 0.5, 0, 1, function()
		triggerCF()
	end)
end

-- 搜索食人怪
function ThrowController:searchCannibal(triggerGridList, validCoordList)
	local cannibalGridList = triggerGridList[ElementThrowReplaceType["cannibal"]]
	if nil == cannibalGridList then
		return {}
	end
	local cannibalRandomInfoList = {}
	for key, grid in pairs(cannibalGridList) do
		local validCoordCount = #validCoordList
		if validCoordCount > 0 then
			local targetCoord = validCoordList[math.random(1, validCoordCount)]
			local cannibalRandomInfo = {
				coord = grid:getCoord(),	-- 起始坐标
				target = targetCoord		-- 目的坐标
			}
			Core:removeCoord(validCoordList, targetCoord)
			table.insert(cannibalRandomInfoList, cannibalRandomInfo)
		end
	end
	return cannibalRandomInfoList
end

-- 触发食人怪
function ThrowController:triggerCannibal(cannibalRandomInfoList, gridController, triggerCF)
	for key, cannibalRandomInfo in pairs(cannibalRandomInfoList) do
		local coord, target = cannibalRandomInfo.coord, cannibalRandomInfo.target
		local data, grid = gridController:getGrid(coord.row, coord.col)
		if grid and nil == grid:getFixedElement() and nil == grid:getCoverElement() then
			local _, targetGrid = gridController:getGrid(target.row, target.col)
			local sPos = self:getMaster():getGridPos(coord.row, coord.col)
			local ePos = self:getMaster():getGridPos(target.row, target.col)
			grid:getNode():setLocalZOrder(G.MAP_ZORDER_GRID + 1)
			local bezierCfg = {
				cc.p(sPos.x, sPos.y),
				cc.p(sPos.x + (ePos.x - sPos.x)/2 + 66, sPos.y + (ePos.y - sPos.y)/2 + 66),
				cc.p(ePos.x, ePos.y),
			}
			grid:getShowElement():setSprite(Utils:createArmatureNode("zhaoya", "idle", true))
			Actions:bezierTo(grid:getNode(), bezierCfg, 0.15, function()
				targetGrid:destroy()
				gridController:setGrid(coord.row, coord.col, nil, nil)
				gridController:setGrid(target.row, target.col, data, grid)
				grid:setCoord(target.row, target.col)
				grid:getShowElement():setSprite(cc.Sprite:create(grid:getShowElement():getData().normal_image))
				local cannibalEffect = nil
				cannibalEffect = Utils:createArmatureNode("chi", "idle", false, function(armatureBack, movementType, movementId)
					if ccs.MovementEventType.complete == movementType and "idle" == movementId then
						cannibalEffect:removeFromParent()
					end
				end)
				cannibalEffect:setPosition(cc.p(ePos.x, ePos.y))
				self:getMaster():getMapLayer():addChild(cannibalEffect, G.MAP_ZORDER_LINE)
				triggerCF()
			end)
		else
			triggerCF()
		end
	end
end

-- 搜索黑色火山
function ThrowController:searchVolcanoBlack(triggerGridList, validCoordList, boardDatas)
	local volcanoBlackGridList = triggerGridList[ElementThrowReplaceType["volcano_black"]]
	if nil == volcanoBlackGridList then
		return {}
	end
	local volcanoBlackRandomInfoList = {}
	for key, grid in pairs(volcanoBlackGridList) do
		if grid:getShowElement():isVolcanoCooling() then	-- 死火山
			grid:getShowElement():updateVolcanoCD()
		else												-- 活火山
			local coord = grid:getCoord()
			local volcanoBlackRandomCoordList = {}
			for k, validCoord in pairs(validCoordList) do
				if Core:isCanContact(coord, validCoord, boardDatas) then
					table.insert(volcanoBlackRandomCoordList, validCoord)
				end
			end
			local volcanoBlackRandomCoordCount = #volcanoBlackRandomCoordList
			if volcanoBlackRandomCoordCount > 0 then
				local volcanoBlackRandomCoord = volcanoBlackRandomCoordList[math.random(1, volcanoBlackRandomCoordCount)]
				local volcanoBlackRandomInfo = {
					coord = coord,						-- 起始坐标
					target = volcanoBlackRandomCoord	-- 目的坐标
				}
				Core:removeCoord(validCoordList, volcanoBlackRandomCoord)
				table.insert(volcanoBlackRandomInfoList, volcanoBlackRandomInfo)
			end	
		end
	end
	return volcanoBlackRandomInfoList
end

-- 触发黑色火山
function ThrowController:triggerVolcanoBlack(volcanoBlackRandomInfoList, gridController, triggerCF)
	if nil == volcanoBlackRandomInfoList then
		return
	end
	for key, volcanoBlackRandomInfo in pairs(volcanoBlackRandomInfoList) do
		local coord, target = volcanoBlackRandomInfo.coord, volcanoBlackRandomInfo.target
		local sPos = MapManager:getMap():getGridPos(coord.row, coord.col)
		local ePos = MapManager:getMap():getGridPos(target.row, target.col)
		local _, volcanoBlackGrid = gridController:getGrid(coord.row, coord.col)
		local _, grid = gridController:getGrid(target.row, target.col)
		if nil == volcanoBlackGrid:getCoverElement() then
			local newGrid = gridController:createGrid(target.row, target.col, {4010})
			Actions:bezierTo(newGrid:getNode(), self:calcVolcanoThrowPath(sPos, ePos), 0.3, function()
				grid:destroyNode()
				triggerCF()
			end)
			AudioMgr:playEffect(2006)
		else
			triggerCF()
		end
	end
end

-- 搜索银色火山
function ThrowController:searchVolcanoSilver(triggerGridList, emptyCoordList, boardDatas)
	local volcanoSilverGridList = triggerGridList[ElementThrowReplaceType["volcano_silver"]]
	if nil == volcanoSilverGridList then
		return {}
	end
	local volcanoSilverRandomInfoList = {}
	for key, grid in pairs(volcanoSilverGridList) do
		if grid:getShowElement():isVolcanoCooling() then	-- 死火山
			grid:getShowElement():updateVolcanoCD()
		else												-- 活火山
			local gridCoord = grid:getCoord()
			local volcanoSilverRandomCoordList = {}
			for k, emptyCoord in pairs(emptyCoordList) do
				if Core:isCanContact(gridCoord, emptyCoord, boardDatas) and
					((gridCoord.row == emptyCoord.row and gridCoord.col == emptyCoord.col - 1) or
					(gridCoord.row == emptyCoord.row and gridCoord.col == emptyCoord.col + 1) or
					(gridCoord.row == emptyCoord.row - 1 and gridCoord.col == emptyCoord.col) or
					(gridCoord.row == emptyCoord.row + 1 and gridCoord.col == emptyCoord.col)) then
					table.insert(volcanoSilverRandomCoordList, emptyCoord)
				end
			end
			local volcanoSilverRandomCoordCount = #volcanoSilverRandomCoordList
			if volcanoSilverRandomCoordCount > 0 then
				local volcanoSilverRandomCoord = volcanoSilverRandomCoordList[math.random(1, volcanoSilverRandomCoordCount)]
				local volcanoSilverRandomInfo = {
					coord = gridCoord,					-- 起始坐标
					target = volcanoSilverRandomCoord	-- 目的坐标
				}
				Core:removeCoord(emptyCoordList, volcanoSilverRandomCoord)
				table.insert(volcanoSilverRandomInfoList, volcanoSilverRandomInfo)
			end
		end
	end
	return volcanoSilverRandomInfoList
end

-- 触发银色火山
function ThrowController:triggerVolcanoSilver(volcanoSilverRandomInfoList, gridController, triggerCF)
	if nil == volcanoSilverRandomInfoList then
		return
	end
	for key, volcanoSilverRandomInfo in pairs(volcanoSilverRandomInfoList) do
		local coord, target = volcanoSilverRandomInfo.coord, volcanoSilverRandomInfo.target
		local sPos = MapManager:getMap():getGridPos(coord.row, coord.col)
		local ePos = MapManager:getMap():getGridPos(target.row, target.col)
		local _, volcanoSilverGrid = gridController:getGrid(coord.row, coord.col)
		if nil == volcanoSilverGrid:getCoverElement() then
			local newGrid = gridController:createGrid(target.row, target.col, {5002})
			Actions:bezierTo(newGrid:getNode(), self:calcVolcanoThrowPath(sPos, ePos), 0.3, function()
				triggerCF()
			end)
			AudioMgr:playEffect(2006)
		else
			triggerCF()
		end
	end
end

-- 触发投放替换类元素
function ThrowController:triggerThrowReplace()
	local gridController = self:getSibling("GridController")
	if 0 == gridController:getTouchedType() then
		gridController:dropGridList(nil, nil, false)
		return
	end
	local boardDatas = gridController:getBoardDatas()
	local replaceInfo = self:calcReplaceInfo()
	local triggerTocalCount = 0
	-- 搜索操作
	local wetlandRandomInfo = self:searchWetland(replaceInfo.trigger_grid_list, replaceInfo.valid_coord_list, boardDatas)
	if wetlandRandomInfo then
		triggerTocalCount = triggerTocalCount + 1
	end
	local volcanoBlackRandomInfoList = self:searchVolcanoBlack(replaceInfo.trigger_grid_list, replaceInfo.valid_coord_list, boardDatas)
	triggerTocalCount = triggerTocalCount + #volcanoBlackRandomInfoList
	local volcanoSilverRandomInfoList = self:searchVolcanoSilver(replaceInfo.trigger_grid_list, replaceInfo.empty_coord_list, boardDatas)
	triggerTocalCount = triggerTocalCount + #volcanoSilverRandomInfoList
	local cannibalRandomInfoList = self:searchCannibal(replaceInfo.trigger_grid_list, replaceInfo.valid_coord_list)
	triggerTocalCount = triggerTocalCount + #cannibalRandomInfoList
	-- 替换回调
	if 0 == triggerTocalCount then
		gridController:dropGridList(nil, nil, false)
		return
	end
	local function triggerThrowCF()
		triggerTocalCount = triggerTocalCount - 1
		if triggerTocalCount > 0 then return end
		gridController:dropGridList(nil, nil, false)
	end
	-- 替换操作
	self:triggerWetland(wetlandRandomInfo, gridController, triggerThrowCF)
	self:triggerVolcanoBlack(volcanoBlackRandomInfoList, gridController, triggerThrowCF)
	self:triggerVolcanoSilver(volcanoSilverRandomInfoList, gridController, triggerThrowCF)
	self:triggerCannibal(cannibalRandomInfoList, gridController, triggerThrowCF)
end

-- 计算火山喷发弹道
function ThrowController:calcVolcanoThrowPath(sPos, ePos)
	local mPosX, mPosY = sPos.x, sPos.y
	local xOffset, yOffset = G.GRID_WIDTH, G.GRID_HEIGHT
	if sPos.x == ePos.x	and sPos.y > ePos.y then		-- 在火山正下
		mPosX = sPos.x + xOffset
		mPosY = sPos.y - (sPos.y - ePos.y)/2
	elseif sPos.x == ePos.x and sPos.y < ePos.y then	-- 在火山正上
		mPosX = sPos.x + xOffset
		mPosY = sPos.y + (ePos.y - sPos.y)/2
	elseif sPos.y == ePos.y and sPos.x > ePos.x then	-- 在火山正左
		mPosX = sPos.x - (sPos.x - ePos.x)/2
		mPosY = sPos.y + yOffset
	elseif sPos.y == ePos.y and sPos.x < ePos.x then	-- 在火山正右
		mPosX = sPos.x + (ePos.x - sPos.x)/2
		mPosY = sPos.y + yOffset
	elseif sPos.x > ePos.x and sPos.y < ePos.y then		-- 在火山左上
		mPosX = sPos.x - (ePos.x - sPos.x)/2
		mPosY = ePos.y + yOffset
	elseif sPos.x < ePos.x and sPos.y < ePos.y then		-- 在火山右上
		mPosX = sPos.x + (ePos.x - sPos.x)/2
		mPosY = ePos.y + yOffset
	elseif sPos.x > ePos.x and sPos.y > ePos.y then		-- 在火山左下
		mPosX = sPos.x - (sPos.x - ePos.x)/2
		mPosY = sPos.y + yOffset
	elseif sPos.x < ePos.x and sPos.y > ePos.y then		-- 在火山右下
		mPosX = sPos.x + (sPos.x - ePos.x)/2
		mPosY = sPos.y + yOffset
	end
	local cfg = {
		cc.p(sPos.x, sPos.y),
		cc.p(mPosX, mPosY),
		cc.p(ePos.x, ePos.y),
	}
	return cfg
end
