----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-12-23
-- Brief: 地图编辑器界面
----------------------------------------------------------------------
UIMapEdit = {
	csbFile = "MapEdit.csb",
}

local allData = {}			--保存元素表中的所有值
local tempAllData = {}
local mGridData = {}	--保存所有格子的数据类型
local mRoot = nil
local mTextField = nil			--文件名输入框
local mCheckBoxIndex = 0 		--表示选中的是第几个checkBox
local mBlockType = 0			--表示选中的block的类型		

--一些特殊元素的id
local speElement ={
	["giftBag"] = 4002,			-- 礼包id
	["fence"] = 4008,			-- 栅栏id
	["ink"] = 4001,				-- 墨汁id
	["ink_2"] = 4009,			-- 墨汁2id
}

local mBoardId = {6001,6002,6003,6004,6005,6006,6007,6008,-1,-2}

local mBoardIcon = {}			--阻挡类型的图片


--初始化格子数据表
local function initGridData()
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


--根据元素的id，获得它是元素中的第几个
local function getIndexById(id)
	for key,val in pairs(allData) do
		if val.id == id then
			return key
		end
	end
end

--根据index，获得数据的图片
local function getIconById(id)
	if id == (#allData -1)  then
		return "block_h.png"
	elseif id == #allData then
		return "block_v.png"
	end
	
	local temp = DataTable:getRow(tempAllData, id, true)
	--local temp =  LogicTable:get("element_tplt", id, true)
	if temp.normal_image == "nil" then
		temp.normal_image ="ImageFile.png"
	end
	return temp.normal_image
end

--设置阻挡类型的图片
local function setBoardIcon()
	for key,val in pairs(mBoardId) do
		local temp = DataTable:getRow(tempAllData,  getIndexById(val), true)
		--local temp = LogicTable:get("element_tplt", getIndexById(val), true)
		table.insert(mBoardIcon,temp.normal_image)
	end
end	
 
--根据元素类型/方向和位置，设置格子的数据(如果是阻挡，index为阻挡的类型，如过不是为MapElementType内的index)
local function setGridDataByElement(index,i,j,direct)
	if direct == "V"then		--设置左右两个方向
		local tempRowData = mGridData[i]
		if allData[index].id == -1 or allData[index].id == -2 then
			allData[index].id = 0
		end
		if j-1 == 0 then		--是最左边
			tempRowData[j].left = allData[index].id
		elseif j == 12 then	--是最右边
			tempRowData[j-1].right = allData[index].id
		else
			tempRowData[j-1].right = allData[index].id
			tempRowData[j].left = allData[index].id	
		end
	elseif direct == "H" then	--设置上下两个方向
		if allData[index].id == -1 or allData[index].id == -2 then
			allData[index].id = 0
		end
		if i-1 == 0 then		--不是最上边边
			local tempRowData = mGridData[i]
			tempRowData[j].up = allData[index].id
		elseif i == 9 then	--不是最下边
			local tempRowData = mGridData[i-1]
			tempRowData[j].down = allData[index].id
		else
			local tempRowData = mGridData[i]
			local tempRowData1 = mGridData[i-1]
			tempRowData[j].up = allData[index].id
			tempRowData1[j].down = allData[index].id
		end	
	else						-- 设置格子
		local tempRowData = mGridData[i]
		if index == getIndexById(speElement["ink"])  then
			local fixValue = 0
			if tempRowData[j].fix == 0 then
				 tempRowData[j].center = string.format("%s|%s|%s",tempRowData[j].center,fixValue,speElement["ink"])
			else
				tempRowData[j].center = string.format("%s|%s",tempRowData[j].center,speElement["ink"])
			end
			tempRowData[j].cover = 1
		elseif index == getIndexById(speElement["ink_2"])  then
			local fixValue = 0
			if tempRowData[j].fix == 0 then
				 tempRowData[j].center = string.format("%s|%s|%s",tempRowData[j].center,fixValue,speElement["ink_2"])
			else
				tempRowData[j].center = string.format("%s|%s",tempRowData[j].center,speElement["ink_2"])
			end
			tempRowData[j].cover = 3
		elseif  index ==  getIndexById(speElement["giftBag"]) then			--礼包
			local fixValue = 0
			if tempRowData[j].fix == 0 then
				 tempRowData[j].center = string.format("%s|%s|%s",tempRowData[j].center,fixValue,speElement["giftBag"])
			else
				tempRowData[j].center = string.format("%s|%s",tempRowData[j].center,speElement["giftBag"])
			end
			tempRowData[j].cover = 2
		elseif index ==  getIndexById(speElement["fence"])  then
			tempRowData[j].center = string.format("%s|%s",tempRowData[j].center,speElement["fence"])
			tempRowData[j].fix = 1
		else
			tempRowData[j].center = allData[index].id
		end
	end
end

--获得格子周边的数据,通过二维数组的下标
local function getGridAroundDataByCoord(i,j)						--2,3
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

--获得格子的数据,通过二维数组的下标
local function getGridDataByCoord(i,j)	
	local rowData = mGridData[i]
	return rowData[j].center  
end
-----------------------------------------------写入csv格式文件-------------------------------------------------------------
local function saveToCSV()
	local fileName = UIManager:seekNodeByName(mRoot, "fileName")
	local nameStr = fileName:getString()
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
			csv_set_row_field(j, getGridDataByCoord(i,j))
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
			csv_set_row_field(j, getGridAroundDataByCoord(i,j))
		end
	end
	local str2 = string.format("Data/board_%s.csv",nameStr)
	csv_save(str2)
end
-------------------------------------------导入csv格式文件的数据设置-------------------------------------------------------------------------------
--根据数据表中的数值，获得它是什么元素，进而加载对应的图片
local function getIconByElement(content)
	if tonumber(content) == 0 then
		return
	end
	local index =  getIndexById(content)
	local rowData = DataTable:getRow(tempAllData, index, false)
	--local rowData = LogicTable:get("element_tplt", index, false)
	return rowData.normal_image
end

--根据导入的数据设置数据表
local function setCSVDataByImport(allGridData,allBoardData)
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
			
			--Log(boardRow)
			
			tb[j].up = boardCell[2]
			tb[j].right = boardRow[tostring(j+1)][1]
			tb[j].down = boardCellNext[2]
			tb[j].left = boardCell[1]
			--Log(tb)
		end
	end
	--Log("setCSVDataByImport****",mGridData)
end

--根据数据表设置界面
local function setUIByImportData()
	for i =1,8,1 do
		for j= 1,11,1 do
			local grid = UIManager:seekNodeByName(mRoot,string.format("grid_%d_%d",i,j))
			local cover = UIManager:seekNodeByName(mRoot,string.format("cover_%d_%d",i,j))
			local fix = UIManager:seekNodeByName(mRoot,string.format("fixed_%d_%d",i,j))
			local block_up = UIManager:seekNodeByName(mRoot,string.format("block_H_%d_%d",i,j))
			local block_right = UIManager:seekNodeByName(mRoot,string.format("block_V_%d_%d",i,j+1))
			local block_down = UIManager:seekNodeByName(mRoot,string.format("block_H_%d_%d",i+1,j))
			local block_left = UIManager:seekNodeByName(mRoot,string.format("block_V_%d_%d",i,j))
			
			local arr = CommonFunc:stringSplit(mGridData[i][j].center, "|", false)
			if grid ~= nil or cover ~= nil then
				if mGridData[i][j].center ~= 0 then
					local image = getIconByElement(tonumber(arr[1]))
					grid:loadTexture(image)
				end
				--设置覆盖
				if tonumber(mGridData[i][j].cover) ~= 0 then				
					cover:loadTexture(getIconByElement(tonumber(arr[3])))
				else
					cover:loadTexture("touming.png")
				end
				--设置固定
				if tonumber(mGridData[i][j].fix) ~= 0 then
					fix:loadTexture(getIconByElement(tonumber(arr[2])))
				else
					fix:loadTexture("touming.png")
				end
			end
			
			if block_up ~= nil and tonumber(mGridData[i][j].up) ~= 0 then
				local img = getIconByElement(mGridData[i][j].up)
				block_up:loadTexture(img)
			end
			if block_left ~= nil and tonumber(mGridData[i][j].left) ~= 0 then
				local img = getIconByElement(mGridData[i][j].left)
				block_left:loadTexture(img)
			end
			
			
			
			if block_right ~= nil and tonumber(mGridData[i][j].right) ~= 0 and j == 7 then
				local img = getIconByElement(mGridData[i][j].right)
				block_right:loadTexture(img)
			end
			
			if block_down ~= nil and tonumber(mGridData[i][j].down) ~= 0 and i == 8 then
				local img = getIconByElement(mGridData[i][j].down)
				block_down:loadTexture(img)
			end
			
			
		end
	end
end

--读取csv文件
local function importToCSV()
	--获取csv的数据
	local fileName = mTextField:getString()
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
	
	--Log(allBoardData) 
	--Log(allGridData)
	--根据导入的数据设置数据表
	setCSVDataByImport(allGridData,allBoardData)
	--根据数据表设置界面
	setUIByImportData()
end

-----------------------------------------------------设置界面的元素----------------------------------------------------------
--根据选中的图片，设置cell加载对应的元素
local function setImgBySelectedIcon()
	if mCheckBoxIndex == 0 or nil == allData[mCheckBoxIndex].normal_image then
		return 
	elseif nil ~= allData[mCheckBoxIndex].normal_image then
		return allData[mCheckBoxIndex].normal_image
	end
end

--根据选中的类型，加载对应的图片
local function loadIconBySelectedType(sender)
	local arr = CommonFunc:stringSplit(sender:getName(), "_", false)		--"cover_4_5"
	local row_i = tonumber(arr[2])
	local row_j = tonumber(arr[3])
	
	--选中的是覆盖类
	if allData[mCheckBoxIndex].normal_image == getIconById(getIndexById(speElement["ink"])) or
		allData[mCheckBoxIndex].normal_image == getIconById(getIndexById(speElement["giftBag"])) or 
		allData[mCheckBoxIndex].normal_image == getIconById(getIndexById(speElement["ink_2"])) then
		local str = string.sub(sender:getName(),6,-1)
		local name =string.format("cover%s",str)
		local cover = UIManager:seekNodeByName(mRoot, name)
		cover:loadTexture(allData[mCheckBoxIndex].normal_image)
		setGridDataByElement(mCheckBoxIndex,row_i,row_j,"")	
	elseif  allData[mCheckBoxIndex].normal_image == getIconById(getIndexById(speElement["fence"])) then --"fixed_4_5"
		local str = string.sub(sender:getName(),6,-1)
		local name =string.format("fixed%s",str)
		local fix = UIManager:seekNodeByName(mRoot, name)
		fix:loadTexture(allData[mCheckBoxIndex].normal_image)
		setGridDataByElement(mCheckBoxIndex,row_i,row_j,"")	
	elseif  allData[mCheckBoxIndex].normal_image == "ImageFile.png" then --空的元素
		local str = string.sub(sender:getName(),6,-1)
		local name =string.format("grid%s",str)
		local grid = UIManager:seekNodeByName(mRoot, name)
		grid:loadTexture(allData[mCheckBoxIndex].normal_image)
		local cover = UIManager:seekNodeByName(mRoot, string.format("cover%s",str))
		local fix = UIManager:seekNodeByName(mRoot, string.format("fixed%s",str))
		sender:loadTexture(setImgBySelectedIcon())
		cover:loadTexture("touming.png")
		fix:loadTexture("touming.png")
		mGridData[row_i][row_j].center = 0
	else
		local str = string.sub(sender:getName(),6,-1)
		local name =string.format("grid%s",str)
		local grid = UIManager:seekNodeByName(mRoot, name)
		grid:loadTexture(allData[mCheckBoxIndex].normal_image)
		setGridDataByElement(mCheckBoxIndex,row_i,row_j,"")	
	end
end


--点击覆盖类触发函数							--???????????????????????????????????
local function coverClick(sender)
	--cclog("coverClick*************",sender:getName())
	loadIconBySelectedType(sender)
end

--创建覆盖类grid(墨汁)
local function addCoverImg(widget)
	local imageView = ccui.ImageView:create()
    imageView:loadTexture("touming.png")	--("ink_01.png")
	imageView:setAnchorPoint(cc.p(0,0))
    imageView:setPosition(cc.p(0,0))
	imageView:setTag(widget:getTag()*200000)
	imageView:setTouchEnabled(true)
	Utils:addTouchEvent(imageView, coverClick, true, true, 0)
	local str = string.sub(widget:getName(),5,-1)
	imageView:setName(string.format("cover%s",str))
    widget:addChild(imageView)
	return imageView
end

--点击固定类触发函数								--????????????????????????????????
local function fixedClick(sender)
	--cclog("fixedClick*************",sender:getName())
	loadIconBySelectedType(sender)	
end

--创建固定类grid(栅栏)
local function addFixImg(widget)
	local imageView = ccui.ImageView:create()
    imageView:loadTexture("touming.png")	--("ink_01.png")
	imageView:setAnchorPoint(cc.p(0,0))
    imageView:setPosition(cc.p(0,0))
	imageView:setTag(widget:getTag()*100000)
	imageView:setTouchEnabled(true)
	Utils:addTouchEvent(imageView, coverClick, true, true, 0)
	local str = string.sub(widget:getName(),5,-1)
	imageView:setName(string.format("fixed%s",str))
    widget:addChild(imageView)
	return imageView
end

----------------------------------------------三层点击会有什么反应呢？？？？？？？？？？？？？？？？
--判断图片是否是阻碍类型
local function judgeBloc(img)
	local temp = false
	for key,val in pairs(mBoardIcon) do
		if img == val then
			temp = true
			return temp
		end
	end
	return temp
end

--点击各个grid和block触发的函数					--需要限制block阻挡的时候，点击cover////fix？？？？？？？？？？？？？
local function cellClick(sender)
	--cclog("cellClick**********",sender:getName())
	if mCheckBoxIndex == 0 then
		UIPrompt:show("请先选中需要的元素")
		return
	end
	local img = setImgBySelectedIcon()
	if  string.sub(sender:getName(),1,4) == "grid"  and (judgeBloc(img) == true)  then
		UIPrompt:show("此种类型只能用于阻碍，不能用于格子")
		return
	end

	local str = string.sub(sender:getName(),5,-1)
	local name =string.format("cover%s",str)
	local cover = UIManager:seekNodeByName(mRoot, name)
	local fix = UIManager:seekNodeByName(mRoot, string.format("fixed%s",str))
	
	if judgeBloc(img) == false and (string.sub(sender:getName(),1,4) == "bloc")then
		UIPrompt:show("此种类型只能用于格子，不能用于阻碍")
		return
	end
	
	local i,j,direct = 0,0,""
	local arr = CommonFunc:stringSplit(sender:getName(), "_", false)
	if string.sub(sender:getName(),7,7) == "V" or string.sub(sender:getName(),7,7) == "H" then -- “block_V_4_2”		--“block_H_5_3”
		direct = arr[2]
		i = arr[3]
		j= arr[4]
	else										--“grid_1_3”	--"cover_1_1"  -- "fixed_1_1"
		i = arr[2]
		j = arr[3]
	end

	if setImgBySelectedIcon() == "ImageFile.png" then
		sender:loadTexture(setImgBySelectedIcon())
		cover:loadTexture("touming.png")
		fix:loadTexture("touming.png")
		mGridData[tonumber(i)][tonumber(j)].center = 0
		return
	end
	
	local firstCenterString = string.sub(mGridData[tonumber(i)][tonumber(j)].center,1,1)
	if tonumber(firstCenterString) == 0 and (allData[mCheckBoxIndex].normal_image == "ink_01.png" or 
			allData[mCheckBoxIndex].normal_image == "ink_02.png" or 
			allData[mCheckBoxIndex].normal_image == "gif_01.png" or 
			allData[mCheckBoxIndex].normal_image == "fence_01.png") then
		UIPrompt:show("请先设置底部的元素，再设置覆盖类（墨水.爪子、礼包）")
		return
	end
	
	--cclog("cellClick************",sender:getName())
	if setImgBySelectedIcon() == getIconById(getIndexById(speElement["ink"])) and cover ~= nil then	--(墨汁，覆盖类要特殊处理)
		cover:loadTexture(getIconById(getIndexById(speElement["ink"])))  
	elseif  setImgBySelectedIcon() == getIconById(getIndexById(speElement["ink_2"])) and cover ~= nil then	--(墨汁2，覆盖类要特殊处理)
		cover:loadTexture(getIconById(getIndexById(speElement["ink_2"]))) 
	elseif setImgBySelectedIcon() == getIconById(getIndexById(speElement["giftBag"]))  and cover ~= nil then	--(礼包，覆盖类要特殊处理)
		cover:loadTexture(getIconById(getIndexById(speElement["giftBag"])))   
	elseif setImgBySelectedIcon() == getIconById(getIndexById(speElement["fence"]))   and fix ~= nil then	--(栅栏，覆盖类要特殊处理)
		fix:loadTexture(getIconById(getIndexById(speElement["fence"])))
	else
		sender:loadTexture(setImgBySelectedIcon())
	end
	--cclog("cellClick************",index,i,j,direct,sender:getName(),cover,fix)
	setGridDataByElement(mCheckBoxIndex,tonumber(i),tonumber(j),direct)
end

--刚加入时，初始化地图(并开启和注册点击事件)
local function initEmptyCell()
	--获得 8*7的元素图片
	for i=1,8,1 do
		for j = 1,11,1 do
			local name = string.format("grid_%d_%d",i,j)
			local grid = UIManager:seekNodeByName(mRoot, name)
			grid:loadTexture("ImageFile.png")
			grid:setTouchEnabled(true)
			grid:removeAllChildren()
			
			local fixed = addFixImg(grid)
			addCoverImg(grid)
			Utils:addTouchEvent(grid, cellClick, true, true, 0)
		end
	end
	--获得垂直方向的阻挡（8*12）
	for i=1,8,1 do
		for j = 1,12,1 do
			local name = string.format("block_V_%d_%d",i,j)
			local blockV = UIManager:seekNodeByName(mRoot, name)
			blockV:loadTexture("block_v.png")
			blockV:setTouchEnabled(true)
			blockV:setScale9Enabled(true)
			blockV:setAnchorPoint(cc.p(0.5,0.5))
			blockV:setContentSize(cc.size(6,64))
			blockV:setRotation(0)
			blockV:removeAllChildren()
			Utils:addTouchEvent(blockV, cellClick, true, true, 0)
		end
	end
	
	--获得水平方向的阻挡（9*11）
	for i=1,9,1 do
		for j = 1,11,1 do
			local name = string.format("block_H_%d_%d",i,j)
			local blockH = UIManager:seekNodeByName(mRoot, name)
			blockH:loadTexture("block_h.png")
			blockH:setTouchEnabled(true)
			blockH:setScale9Enabled(true)
			blockH:setAnchorPoint(cc.p(0.5,0.5))
			blockH:setContentSize(cc.size(64,6))
			blockH:setRotation(0)
			blockH:removeAllChildren()
			Utils:addTouchEvent(blockH, cellClick, true, true, 0)
		end
	end
end

--点击checkBox回调
local function checkBoxClick(sender,eventType)
	if eventType == ccui.CheckBoxEventType.selected then
		
		--把所有的选中框还原
		if mCheckBoxIndex ~= 0 then
			local name = string.format("checkBox_%d",mCheckBoxIndex)
			local lastSelctBox = UIManager:seekNodeByName(mRoot, name)
			lastSelctBox:setSelected(false)
		end
		mBlockType = 0
		local str = string.sub(sender:getName(),-2,-1)
		if string.sub(str,1,1) == "_" then
			mCheckBoxIndex = tonumber(string.sub(str,-1,-1))
		else
			mCheckBoxIndex = tonumber(str)
		end
		if allData[mCheckBoxIndex].normal_image == "ink_01.png" or 
			allData[mCheckBoxIndex].normal_image == "ink_02.png" or 
			allData[mCheckBoxIndex].normal_image == "gif_01.png" or 
			allData[mCheckBoxIndex].normal_image == "fence_01.png" then
			UIPrompt:show("请先设置底部的元素，再设置覆盖类（墨水.爪子、礼包）")
		end	
	elseif eventType == ccui.CheckBoxEventType.unselected then
		mCheckBoxIndex = 0
	end
end

--初始化滚动图层														
local function initScrollCheckBox()
	local scrollView = UIManager:seekNodeByName(mRoot,"ScrollView_2") --"ScrollView_item"
	
	local data = {}
	for key,val in pairs(allData) do
		local ItemData = {}
		ItemData.icon = getIconById(key)
		ItemData.index = key
		table.insert(data,ItemData)
	end
	
	--创建列表单元格
	local function createCell(cellBg, ItemData, index)
		cellBg = ccui.Layout:create()
		cellBg:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
		cellBg:setContentSize(cc.size(130,70))
		cellBg:setBackGroundColor(cc.c3b(129, 177 , 208))
		local icon = ccui.ImageView:create()
		icon:loadTexture(ItemData.icon)	
		icon:setAnchorPoint(cc.p(0.5,0.5))
		icon:setPosition(cc.p(43.1,35.2))
		icon:setName(string.format("icon_%d",ItemData.index))
		cellBg:addChild(icon)
		
		local checkBox = ccui.CheckBox:create()
		checkBox:setTouchEnabled(true)
		checkBox:setSelected(false)
		checkBox:setAnchorPoint(cc.p(0.5,0.5))
		checkBox:loadTextures("CheckBox_Normal.png", "CheckBox_Press.png",
								   "CheckBoxNode_Normal.png", "CheckBox_Disable.png",
								   "CheckBoxNode_Disable.png")
		checkBox:setPosition(cc.p(104.4, 29.51))
		checkBox:setName(string.format("checkBox_%d",ItemData.index))
		checkBox:addEventListener(checkBoxClick) 
		cellBg:addChild(checkBox)
		return cellBg
	end
	
	UIScrollViewEx.show(scrollView, data, createCell,"V", 130, 70, 2,4, 50, false, nil, true, false)
end

--初始化界面的一些数据和布局
local function clearData()
	allData = {}			--保存元素表中的所有值
	tempAllData = {}
	tempAllData =DataTable:loadFile("element_tplt"..".csv", false)
	--allData = LogicTable:getAll("element_tplt")
	allData = tempAllData.map
	local temp1 = {["id"] = -1,["normal_image"]= "block_h.png"}			--空白的水平格子图片
	local temp2 = {["id"] = -2,["normal_image"]= "block_v.png"}			--空白的垂直格子图片
	table.insert(allData,temp1)
	table.insert(allData,temp2)
end

--初始化界面的一些数据和布局
local function initMapUI()
	--刚加入时，初始化地图(并开启点击事件)
	initEmptyCell()
	--初始化滚动图层
	initScrollCheckBox()
	mCheckBoxIndex = 0
	mTextField:setString("")
	
	setBoardIcon()	
	--初始化格子数据表
	mGridData = {}
	initGridData()
end

--保存按钮触发的事件
local function saveBtnClick(sender)
	if mTextField:getString() == "" then
		UIPrompt:show("请输入保存的文件名")
	else
		--存文件为csv格式
		saveToCSV()
		clearData()
		--初始化数据
		initMapUI()
		
		UIPrompt:show("保存成功，请在resource|data目录下查看")
	end
end

--导入按钮触发的事件
local function importBtnClick(sender)
	if mTextField:getString() == "" then
		UIPrompt:show("请输入导入的文件名")
	else
		--刚加入时，初始化地图(并开启点击事件)
		initEmptyCell()
		--初始化格子数据表
		mGridData = {}
		initGridData()
		importToCSV()
		
		UIPrompt:show("导入文件成功")
		mTextField:setString("")
	end
end

function UIMapEdit:onStart(ui, param)
	
	self:subscribeEvent(EventDef["ED_GAME_INIT"], self:onGameInit())
	mRoot = ui.root
	--保存的文件名
	mTextField = UIManager:seekNodeByName(mRoot, "fileName")
	
	--local temp = LogicTable:loadCsv("element_tplt", false)
	tempAllData =DataTable:loadFile("element_tplt"..".csv", false)
	--allData = LogicTable:getAll("element_tplt")
	allData = tempAllData.map
	local temp1 = {["id"] = -1,["normal_image"]= "block_h.png"}			--空白的水平格子图片
	local temp2 = {["id"] = -2,["normal_image"]= "block_v.png"}			--空白的垂直格子图片
	table.insert(allData,temp1)
	table.insert(allData,temp2)
	
	--Log(allData)
	
	-- 保存按钮
	local saveBtn = UIManager:seekNodeByName(ui.root, "Button_save")
	Utils:addTouchEvent(saveBtn, saveBtnClick, true, true, 0)
	
	--导入按钮
	local importBtn = UIManager:seekNodeByName(ui.root, "import")
	Utils:addTouchEvent(importBtn,importBtnClick, true, true, 0)
	
	--初始化数据
	initMapUI()
	
	--关闭按钮
	local btnClose = UIManager:seekNodeByName(ui.root, "Button_close")
	Utils:addTouchEvent(btnClose, function(sender)
		UIManager:close(self)
	end, true, true, 0)
	
end

function UIMapEdit:onTouch(touch, event, eventCode)
end

function UIMapEdit:onUpdate(dt)
end

function UIMapEdit:onDestroy()
end

function UIMapEdit:onGameInit(param)
	cclog("---------------11111 UIMapEdit",param)
end
