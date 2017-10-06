----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-06-09
-- Brief: 地图编辑器格子数据
----------------------------------------------------------------------
UIMapEditGridData = {}

local mGridData = {}			--保存所有格子的数据类型
--------------------------------------------------------------------------------------------------
--根据元素类型/方向和位置，设置格子的数据(如果是阻挡，index为阻挡的类型，如过不是为MapElementType内的index)
function UIMapEditGridData:setGridDataByElement(index,i,j,direct)
	local allElementData = UIMapEditElementData:getElementData()
	if direct == "V"then		--设置左右两个方向
		local tempRowData = mGridData[i]
		local elementId = allElementData[index].id
		if elementId == -1 or elementId == -2 then
			allElementData[index].id = 0
		end
		if j-1 == 0 then		--是最左边
			tempRowData[j].left = allElementData[index].id
		elseif j == 12 then	--是最右边
			tempRowData[j-1].right = allElementData[index].id
		else
			tempRowData[j-1].right = allElementData[index].id
			tempRowData[j].left = allElementData[index].id	
		end
	elseif direct == "H" then	--设置上下两个方向
		if allElementData[index].id == -1 or allElementData[index].id == -2 then
			allElementData[index].id = 0
		end
		if i-1 == 0 then		--不是最上边边
			local tempRowData = mGridData[i]
			tempRowData[j].up = allElementData[index].id
		elseif i == 9 then	--不是最下边
			local tempRowData = mGridData[i-1]
			tempRowData[j].down = allElementData[index].id
		else
			local tempRowData = mGridData[i]
			local tempRowData1 = mGridData[i-1]
			tempRowData[j].up = allElementData[index].id
			tempRowData1[j].down = allElementData[index].id
		end	
	else						-- 设置格子
		local tempRowData = mGridData[i]
		if index == UIMapEditElementData:getIndexById(speElement["ink"])  then
			local fixValue = 0
			if tempRowData[j].fix == 0 then
				 tempRowData[j].center = string.format("%s|%s|%s",tempRowData[j].center,fixValue,speElement["ink"])
			else
				tempRowData[j].center = string.format("%s|%s",tempRowData[j].center,speElement["ink"])
			end
			tempRowData[j].cover = 1
		elseif index == UIMapEditElementData:getIndexById(speElement["ink_2"])  then
			local fixValue = 0
			if tempRowData[j].fix == 0 then
				 tempRowData[j].center = string.format("%s|%s|%s",tempRowData[j].center,fixValue,speElement["ink_2"])
			else
				tempRowData[j].center = string.format("%s|%s",tempRowData[j].center,speElement["ink_2"])
			end
			tempRowData[j].cover = 3
		elseif  index == UIMapEditElementData: getIndexById(speElement["giftBag"]) then			--礼包
			local fixValue = 0
			if tempRowData[j].fix == 0 then
				 tempRowData[j].center = string.format("%s|%s|%s",tempRowData[j].center,fixValue,speElement["giftBag"])
			else
				tempRowData[j].center = string.format("%s|%s",tempRowData[j].center,speElement["giftBag"])
			end
			tempRowData[j].cover = 2
		elseif index ==  UIMapEditElementData:getIndexById(speElement["fence"])  then
			tempRowData[j].center = string.format("%s|%s",tempRowData[j].center,speElement["fence"])
			tempRowData[j].fix = 1
		else
			tempRowData[j].center = allElementData[index].id
		end
	end
end
--------------------------------------------------------------------------------------------------
--获得格子周边的数据,通过二维数组的下标
function UIMapEditGridData:getGridAroundDataByCoord(i,j)						--2,3
	if i == 9 and j~=12 then
		return string.format("0|%s",mGridData[i-1][j].down)
	end
	if j == 12 and i~= 9 then
		return string.format("%s|0",mGridData[i][j-1].right)
	end
	if j == 12 and i== 9 then
		return string.format("%s|0",mGridData[i-1][j-1].right)
	end
	local rowData = mGridData[i]
	return string.format("%s|%s",rowData[j].left,rowData[j].up)
end
--------------------------------------------------------------------------------------------------
--获得格子的数据,通过二维数组的下标
function UIMapEditGridData:getGridDataByCoord(i,j)	
	local rowData = mGridData[i]
	return rowData[j].center  
end
--------------------------------------------------------------------------------------------------
--根据导入的数据设置数据表
function UIMapEditGridData:setCSVDataByImport(allGridData,allBoardData)
	for i =1,8,1 do
		for j= 1,11,1 do
			local tb = mGridData[i]			--当前数据表中的某一行
			local gridRow = allGridData[i]	--csv中的某一行
			local gridCell = gridRow[tostring(j)]		--csv中某一行的某一列
			
			if  #gridCell == 3  then		--固定类加覆盖类  或固定类为空
				tb[j].center = string.format("%s|%s|%s",gridCell[1],gridCell[2],gridCell[3])
				tb[j].cover = 1
				if tonumber(gridCell[2]) ~= 0  then
					tb[j].fix = 1
				end
			elseif #gridCell == 2  then			--固定类
				tb[j].center = string.format("%s|%s",gridCell[1],gridCell[2])
				tb[j].fix = 1
			else
				tb[j].center = string.format("%s",gridCell[1])
			end
			
			--设置阻挡
			local boardRow = allBoardData[i]
			local boardCell = boardRow[tostring(j)]	
			local boardRowNext = allBoardData[i+1]
			local boardCellNext = boardRowNext[tostring(j)]	
			
			tb[j].up = boardCell[2]
			tb[j].right = boardRow[tostring(j+1)][1]
			tb[j].down = boardCellNext[2]
			tb[j].left = boardCell[1]
		end
	end
end
--------------------------------------------------------------------------------------------------
--读取csv文件
function UIMapEditGridData:importToCSV(inputWidget)
	--获取csv的数据
	local fileName = inputWidget:getString()
	local gridName = fileName
	local boardName = fileName
	if string.sub(fileName,1,4) == "boar" then
		gridName = string.format("grid%s",string.sub(fileName,6,-1))
	elseif string.sub(fileName,1,4) == "grid" then
		boardName = string.format("board%s",string.sub(fileName,5,-1))
	end
	cclog("importToCSV******",fileName,gridName,boardName)
	LogicTable:loadCsv(gridName, false)
	LogicTable:loadCsv(boardName, false)
	
	local allGridData = LogicTable:getAll(gridName)
	local allBoardData = LogicTable:getAll(boardName)

	--根据导入的数据设置数据表
	self:setCSVDataByImport(allGridData,allBoardData)
end
--------------------------------------------------------------------------------------------------
--设置导入的数据
function UIMapEditGridData:setGridData(i,j)
	mGridData[tonumber(i)][tonumber(j)].center = 0
end
--------------------------------------------------------------------------------------------------
--获取导入的数据
function UIMapEditGridData:getGridData()
	return mGridData 
end
--------------------------------------------------------------------------------------------------
--初始化格子数据表
function UIMapEditGridData:initGridData()
	mGridData = {}
	for i =1,8,1 do
		local rowTb = {}			--保存每一行的数据
		for j= 1,11,1 do
			local tb ={}
			tb.center = 0
			tb.up = 0
			tb.right = 0
			tb.down = 0
			tb.left = 0
			tb.cover = 0		--没有为0，有墨水为1，有礼包为2
			tb.fix = 0			--没有为0，有栅栏为1
			table.insert(rowTb,tb)
		end
		table.insert(mGridData,rowTb)
	end
end
--------------------------------------------------------------------------------------------------
--写入csv格式文件
function UIMapEditGridData:saveToCSV(nameStr)
	--保存格子数据
	csv_create(7)
	--创建第一行
	csv_new_row()
	for i=1,11,1 do
		csv_set_row_field(i,string.format("list_number:%d",i))
	end
	
	for i =1,8,1 do
		csv_new_row()
		for j= 1,11,1 do
			csv_set_row_field(j, self:getGridDataByCoord(i,j))
		end
	end
	
	local str = string.format("Data/grid_%s.csv",nameStr)
	csv_save(str)
	
	--保存阻挡数据
	csv_create(8)
	--创建第一行
	csv_new_row()
	for i=1,12,1 do
		csv_set_row_field(i,string.format("list_number:%d",i))
	end
	
	for i =1,9,1 do
		csv_new_row()
		for j= 1,12,1 do
			csv_set_row_field(j, self:getGridAroundDataByCoord(i,j))
		end
	end
	local str2 = string.format("Data/board_%s.csv",nameStr)
	csv_save(str2)
end

