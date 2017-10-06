----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 核心函数
----------------------------------------------------------------------
Core = {}

-- 创建索引坐标
function Core:makeCoord(row, col)
	local coord = {
		row = row,		-- 行坐标
		col = col		-- 列坐标
	}
	return coord
end

-- 索引坐标是否相等
function Core:equalCoord(coord1, coord2)
	return coord1 and coord2 and coord1.row == coord2.row and coord1.col == coord2.col
end

-- 添加坐标
function Core:addCoord(coordList, coord)
	for i, tempCoord in pairs(coordList) do
		if tempCoord.row == coord.row and tempCoord.col == coord.col then
			return
		end
	end
	table.insert(coordList, coord)
end

-- 移除坐标
function Core:removeCoord(coordList, coord)
	for i, tempCoord in pairs(coordList) do
		if tempCoord.row == coord.row and tempCoord.col == coord.col then
			table.remove(coordList, i)
			return
		end
	end
end

-- 坐标是否存在
function Core:isCoordExist(coordList, coord)
	for i, tempCoord in pairs(coordList) do
		if tempCoord.row == coord.row and tempCoord.col == coord.col then
			return true
		end
	end
	return false
end

-- 添加隔板信息
function Core:addBoardInfo(boardInfoList, coord, direct)
	for i, boardInfo in pairs(boardInfoList) do
		if boardInfo.coord.row == coord.row and boardInfo.coord.col == coord.col and boardInfo.direct == direct then
			return
		end
	end
	local boardInfo = {
		coord = coord,		-- 坐标
		direct = direct		-- 方向
	}
	table.insert(boardInfoList, boardInfo)
end

-- 移除隔板信息
function Core:removeBoardInfo(boardInfoList, coord, direct)
	for i, boardInfo in pairs(boardInfoList) do
		if boardInfo.coord.row == coord.row and boardInfo.coord.col == coord.col and boardInfo.direct == direct then
			table.remove(boardInfoList, i)
			return
		end
	end
end

-- 隔板信息是否存在
function Core:isBoardInfoExist(boardInfoList, coord, direct)
	for i, boardInfo in pairs(boardInfoList) do
		if boardInfo.coord.row == coord.row and boardInfo.coord.col == coord.col and boardInfo.direct == direct then
			return true
		end
	end
	return false
end

-- 递增数量
function Core:increaseCount(countList, increaseType, count)
	if nil == increaseType then
		return
	end
	if nil == countList[increaseType] then
		countList[increaseType] = 0
	end
	countList[increaseType] = countList[increaseType] + (count or 1)
end

-- 递减数量
function Core:decreaseCount(countList, decreaseType, count)
	if nil == decreaseType or nil == countList[decreaseType] then
		return
	end
	countList[decreaseType] = countList[decreaseType] - (count or 1)
	if countList[decreaseType] <= 0 then
		countList[decreaseType] = nil
	end
end

-- 获取第N环坐标
function Core:getRangeCoord(coord, range)
	local rangeCoordList = {}
	if range <= 0 then
		return rangeCoordList
	end
	-- up
	table.insert(rangeCoordList, {row = coord.row - range, col = coord.col})
	-- right
	table.insert(rangeCoordList, {row = coord.row, col = coord.col + range})
	-- down
	table.insert(rangeCoordList, {row = coord.row + range, col = coord.col})
	-- left
	table.insert(rangeCoordList, {row = coord.row, col = coord.col - range})
	-- corner
	table.insert(rangeCoordList, {row = coord.row - range, col = coord.col - range})
	table.insert(rangeCoordList, {row = coord.row - range, col = coord.col + range})
	table.insert(rangeCoordList, {row = coord.row + range, col = coord.col + range})
	table.insert(rangeCoordList, {row = coord.row + range, col = coord.col - range})
	for i=1, range - 1 do
		-- up
		table.insert(rangeCoordList, {row = coord.row - range, col = coord.col - i})
		table.insert(rangeCoordList, {row = coord.row - range, col = coord.col + i})
		-- right
		table.insert(rangeCoordList, {row = coord.row - i, col = coord.col + range})
		table.insert(rangeCoordList, {row = coord.row + i, col = coord.col + range})
		-- down
		table.insert(rangeCoordList, {row = coord.row + range, col = coord.col - i})
		table.insert(rangeCoordList, {row = coord.row + range, col = coord.col + i})
		-- left
		table.insert(rangeCoordList, {row = coord.row - i, col = coord.col - range})
		table.insert(rangeCoordList, {row = coord.row + i, col = coord.col - range})
	end
	return rangeCoordList
end

-- 两个坐标是否可联系(只有距离和隔板才会影响)
function Core:isCanContact(coord1, coord2, boardDatas)
	--[[
		coord = {				-- 坐标结构
			row = 1,				-- 行
			col = 1,				-- 列
		}
		boardDatas = {			-- 隔板数据组结构
			{{1, 1}, ...},			-- 行1(列1(索引值1:竖型隔板,索引值2:横型隔板), ...)
			...						-- 行2(列1(索引值1:竖型隔板,索引值2:横型隔板), ...)
		}
	]]
	-- 格子不相邻
	if nil == coord1 or nil == coord2 or math.abs(coord1.row - coord2.row) > 1 or math.abs(coord1.col - coord2.col) > 1 then
		return false
	end
	-- 格子1周围隔板数据
	local aroundBoardData1 = {up = 0, right = 0, down = 0, left = 0}
	if boardDatas[coord1.row] and boardDatas[coord1.row][coord1.col] then
		aroundBoardData1.up = boardDatas[coord1.row][coord1.col][2]
	end
	if boardDatas[coord1.row] and boardDatas[coord1.row][coord1.col + 1] then
		aroundBoardData1.right = boardDatas[coord1.row][coord1.col + 1][1]
	end
	if boardDatas[coord1.row + 1] and boardDatas[coord1.row + 1][coord1.col] then
		aroundBoardData1.down = boardDatas[coord1.row + 1][coord1.col][2]
	end
	if boardDatas[coord1.row] and boardDatas[coord1.row][coord1.col] then
		aroundBoardData1.left = boardDatas[coord1.row][coord1.col][1]
	end
	-- 格子2周围隔板数据
	local aroundBoardData2 = {up = 0, right = 0, down = 0, left = 0}
	if boardDatas[coord2.row] and boardDatas[coord2.row][coord2.col] then
		aroundBoardData2.up = boardDatas[coord2.row][coord2.col][2]
	end
	if boardDatas[coord2.row] and boardDatas[coord2.row][coord2.col + 1] then
		aroundBoardData2.right = boardDatas[coord2.row][coord2.col + 1][1]
	end
	if boardDatas[coord2.row + 1] and boardDatas[coord2.row + 1][coord2.col] then
		aroundBoardData2.down = boardDatas[coord2.row + 1][coord2.col][2]
	end
	if boardDatas[coord2.row] and boardDatas[coord2.row][coord2.col] then
		aroundBoardData2.left = boardDatas[coord2.row][coord2.col][1]
	end
	-- 以格子1为中心,判断格子2的方位
	if coord1.row == coord2.row and coord1.col > coord2.col then		-- 2在1正左方
		return aroundBoardData1.left <= 0
	elseif coord1.row == coord2.row and coord1.col < coord2.col then	-- 2在1正右方
		return aroundBoardData1.right <= 0
	elseif coord1.row > coord2.row and coord1.col == coord2.col then	-- 2在1正上方
		return aroundBoardData1.up <= 0
	elseif coord1.row < coord2.row and coord1.col == coord2.col then	-- 2在1正下方
		return aroundBoardData1.down <= 0
	elseif coord1.row > coord2.row and coord1.col > coord2.col then		-- 2在1左上角
		if not ((aroundBoardData1.up > 0 and aroundBoardData1.left > 0) or
				(aroundBoardData2.down > 0 and aroundBoardData2.right > 0) or
				(aroundBoardData1.up > 0 and aroundBoardData2.down > 0) or
				(aroundBoardData1.left > 0 and aroundBoardData2.right > 0)) then
			return true
		end
	elseif coord1.row > coord2.row and coord1.col < coord2.col then		-- 2在1右上角
		if not ((aroundBoardData1.up > 0 and aroundBoardData1.right > 0) or
				(aroundBoardData2.down > 0 and aroundBoardData2.left > 0) or
				(aroundBoardData1.up > 0 and aroundBoardData2.down > 0) or
				(aroundBoardData1.right > 0 and aroundBoardData2.left > 0)) then
			return true
		end
	elseif coord1.row < coord2.row and coord1.col > coord2.col then		-- 2在1左下角
		if not ((aroundBoardData1.down > 0 and aroundBoardData1.left > 0) or
				(aroundBoardData2.up > 0 and aroundBoardData2.right > 0) or
				(aroundBoardData1.down > 0 and aroundBoardData2.up > 0) or
				(aroundBoardData1.left > 0 and aroundBoardData2.right > 0)) then
			return true
		end
	elseif coord1.row < coord2.row and coord1.col < coord2.col then		-- 2在1右下角
		if not ((aroundBoardData1.down > 0 and aroundBoardData1.right > 0) or
				(aroundBoardData2.up > 0 and aroundBoardData2.left > 0) or
				(aroundBoardData1.down > 0 and aroundBoardData2.up > 0) or
				(aroundBoardData1.right > 0 and aroundBoardData2.left > 0)) then
			return true
		end
	end
	return false
end

-- 坐标1的格子是否可移动到坐标2位置
function Core:isCanMoveTo(coord1, coord2, boardDatas, gridDatas)
	if not self:isCanContact(coord1, coord2, boardDatas) then
		return false
	end
	local rowCount, colCount = #gridDatas, #gridDatas[1]
	if ((coord1.row < 1 or coord1.row > rowCount or coord1.col < 1 or coord1.col > colCount) or
		(coord2.row < 1 or coord2.row > rowCount or coord2.col < 1 or coord2.col > colCount)) then
		return false
	end
	local targetData = gridDatas[coord2.row][coord2.col]
	if nil == targetData or nil == targetData[1] or targetData[1] <= 0 then
		return true
	end
	return false
end

-- 检查坐标垂直方向是否有可掉落的格子
function Core:checkDropGrid(coord, gridNodes, boardDatas)
	for row=coord.row, 1, -1 do
		-- 第1行
		if 1 == row then
			return true
		end
		-- 空格子上边有隔板
		if boardDatas[row][coord.col][BoardDirectType["horizontal"]] > 0 then
			return false
		end
		-- 空格子上边有格子,判断是否可掉落
		local upGrid = gridNodes[row - 1][coord.col]
		if upGrid then
			return upGrid:isCanDrop()
		end
	end
	return true
end

-- 搜索格子掉落路径
function Core:searchGridDropPath(grid, rowCount, colCount, gridDatas, gridNodes, boardDatas)
	local dropPath = {}
	-- 格子为空,或格子不可掉落
	if nil == grid or not grid:isCanDrop() then
		return dropPath
	end
	-- 小于第1行,或大于等于倒数第1行,或小于第1列,或大于最后列,则不可掉落
	local coord = grid:getCoord()
	if coord.row < 1 or coord.row >= rowCount or coord.col < 1 or coord.col > colCount then
		return dropPath
	end
	-- 遍历可掉落位置
	local currCol = coord.col
	for row=coord.row, rowCount do
		if row >= rowCount then	-- 最后一行,不可再掉落
			break
		end
		local currCoord = {row = row, col = currCol}				-- 当前位置
		local downCoord = {row = row + 1, col = currCol}			-- 正下位置
		local leftDownCoord = {row = row + 1, col = currCol - 1}	-- 左下位置
		local rightDownCoord = {row = row + 1, col = currCol + 1}	-- 右下位置
		if self:isCanMoveTo(currCoord, downCoord, boardDatas, gridDatas) then
			table.insert(dropPath, downCoord)
			currCol = downCoord.col
		elseif self:isCanMoveTo(currCoord, leftDownCoord, boardDatas, gridDatas) and not self:checkDropGrid(leftDownCoord, gridNodes, boardDatas) then
			table.insert(dropPath, leftDownCoord)
			currCol = leftDownCoord.col
		elseif self:isCanMoveTo(currCoord, rightDownCoord, boardDatas, gridDatas) and not self:checkDropGrid(rightDownCoord, gridNodes, boardDatas) then
			table.insert(dropPath, rightDownCoord)
			currCol = rightDownCoord.col
		else
			break
		end
	end
	return dropPath
end

