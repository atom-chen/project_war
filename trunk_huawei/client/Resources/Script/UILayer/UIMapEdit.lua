----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2014-12-23
-- Brief: 地图编辑器界面
----------------------------------------------------------------------
UIMapEdit = {
	csbFile = "MapEdit.csb",
}

local mRoot = nil				-- 界面根节点
local mGridPanel = nil			-- 上部分格子根节点
local mTextField = nil			-- 文件名输入框
local mCheckBoxIndex = 0 		-- 表示选中的是第几个checkBox
local mBlockType = 0			-- 表示选中的block的类型		

--一些特殊元素的id
speElement ={
	["giftBag"] = 4002,			-- 礼包 id
	["fence"] = 4008,			-- 栅栏 id
	["ink"] = 4001,				-- 墨汁 id
	["ink_2"] = 4009,			-- 墨汁2 id
}
function UIMapEdit:onStart(ui, param)
	self:subscribeEvent(EventDef["ED_GAME_INIT"], self:onGameInit())
	mRoot = ui.root
	mGridPanel = UIManager:seekNodeByName(mRoot, "Panel_3")
	UIMapEditElementData:initElementData()
	--保存的文件名
	mTextField = UIManager:seekNodeByName(mRoot, "fileName")
	--初始化数据
	self:initMapUI()
	
	-- 保存按钮
	local saveBtn = UIManager:seekNodeByName(ui.root, "Button_save")
	Utils:addTouchEvent(saveBtn, function(sender)
		self:saveBtnClick(sender)
	end, true, true, 0)
	
	--导入按钮
	local importBtn = UIManager:seekNodeByName(ui.root, "import")
	Utils:addTouchEvent(importBtn, function(sender)
		self:importBtnClick(sender)
	end, true, true, 0)
	
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
end
----------------------------------------------------根据数据表设置界面----------------------------------------
--根据数据表设置界面
function UIMapEdit:setUIByImportData(tempData)
	for i =1,8,1 do
		for j= 1,11,1 do
			local grid = UIManager:seekNodeByName(mGridPanel,string.format("grid_%d_%d",i,j))
			local cover = UIManager:seekNodeByName(mGridPanel,string.format("cover_%d_%d",i,j))
			local fix = UIManager:seekNodeByName(mGridPanel,string.format("fixed_%d_%d",i,j))
			local block_up = UIManager:seekNodeByName(mGridPanel,string.format("block_H_%d_%d",i,j))
			local block_right = UIManager:seekNodeByName(mGridPanel,string.format("block_V_%d_%d",i,j+1))
			local block_down = UIManager:seekNodeByName(mGridPanel,string.format("block_H_%d_%d",i+1,j))
			local block_left = UIManager:seekNodeByName(mGridPanel,string.format("block_V_%d_%d",i,j))
			
			local arr = CommonFunc:stringSplit(tempData[i][j].center, "|", false)
			if grid ~= nil or cover ~= nil then
				if tempData[i][j].center ~= 0 then
					local image = UIMapEditElementData:getIconByElement(tonumber(arr[1]))
					grid:loadTexture(image)
				end
				--设置覆盖
				if tonumber(tempData[i][j].cover) ~= 0 then				
					cover:loadTexture(UIMapEditElementData:getIconByElement(tonumber(arr[3])))
				else
					cover:loadTexture("touming.png")
				end
				--设置固定
				if tonumber(tempData[i][j].fix) ~= 0 then
					fix:loadTexture(UIMapEditElementData:getIconByElement(tonumber(arr[2])))
				else
					fix:loadTexture("touming.png")
				end
			end
			
			if block_up ~= nil and tonumber(tempData[i][j].up) ~= 0 then
				local img = UIMapEditElementData:getIconByElement(tempData[i][j].up)
				block_up:loadTexture(img)
			end
			if block_left ~= nil and tonumber(tempData[i][j].left) ~= 0 then
				local img = UIMapEditElementData:getIconByElement(tempData[i][j].left)
				block_left:loadTexture(img)
			end
			
			if block_right ~= nil and tonumber(tempData[i][j].right) ~= 0 and j == 7 then
				local img = UIMapEditElementData:getIconByElement(tempData[i][j].right)
				block_right:loadTexture(img)
			end
			
			if block_down ~= nil and tonumber(tempData[i][j].down) ~= 0 and i == 8 then
				local img = UIMapEditElementData:getIconByElement(tempData[i][j].down)
				block_down:loadTexture(img)
			end	
		end
	end
end
--------------------------------------------------------------------------------------------------
--根据选中的图片，设置cell加载对应的元素
function UIMapEdit:setImgBySelectedIcon()
	local elementIconStr =  UIMapEditElementData:getNormalImgByIndex(mCheckBoxIndex)
	if mCheckBoxIndex == 0 or nil == elementIconStr then
		return 
	elseif nil ~= elementIconStr then
		return elementIconStr
	end
end
--------------------------------------------------------------------------------------------------
--根据选中的类型，加载对应的图片
function UIMapEdit:loadIconBySelectedType(sender)
	local arr = CommonFunc:stringSplit(sender:getName(), "_", false)		--"cover_4_5"
	local row_i = tonumber(arr[2])
	local row_j = tonumber(arr[3])
	local elementIconStr = UIMapEditElementData:getNormalImgByIndex(mCheckBoxIndex)
	--选中的是覆盖类
	if elementIconStr == UIMapEditElementData:getElementIconById(speElement["ink"]) or
	   elementIconStr == UIMapEditElementData:getElementIconById(speElement["giftBag"])  or 
	   elementIconStr == UIMapEditElementData:getElementIconById(speElement["ink_2"]) then
		local str = string.sub(sender:getName(),6,-1)
		local name =string.format("cover%s",str)
		local cover = UIManager:seekNodeByName(mGridPanel, name)
		cover:loadTexture(elementIconStr)
		UIMapEditGridData:setGridDataByElement(mCheckBoxIndex,row_i,row_j,"")	
	elseif  elementIconStr == UIMapEditElementData:getElementIconById(speElement["fence"])  then --"fixed_4_5"
		local str = string.sub(sender:getName(),6,-1)
		local name =string.format("fixed%s",str)
		local fix = UIManager:seekNodeByName(mGridPanel, name)
		fix:loadTexture(elementIconStr)
		UIMapEditGridData:setGridDataByElement(mCheckBoxIndex,row_i,row_j,"")	
	elseif  elementIconStr == "ImageFile.png" then --空的元素
		local str = string.sub(sender:getName(),6,-1)
		local name =string.format("grid%s",str)
		local grid = UIManager:seekNodeByName(mGridPanel, name)
		grid:loadTexture(elementIconStr)
		local cover = UIManager:seekNodeByName(mGridPanel, string.format("cover%s",str))
		local fix = UIManager:seekNodeByName(mGridPanel, string.format("fixed%s",str))
		sender:loadTexture(self:setImgBySelectedIcon())
		cover:loadTexture("touming.png")
		fix:loadTexture("touming.png")
		UIMapEditGridData:setGridData(row_i,row_j)
	else
		local str = string.sub(sender:getName(),6,-1)
		local name =string.format("grid%s",str)
		local grid = UIManager:seekNodeByName(mGridPanel, name)
		grid:loadTexture(elementIconStr)
		UIMapEditGridData:setGridDataByElement(mCheckBoxIndex,row_i,row_j,"")	
	end
end
--------------------------------------------------------------------------------------------------
--创建覆盖类grid(墨汁)
function UIMapEdit:addCoverImg(widget)
	local imageView = ccui.ImageView:create()
    imageView:loadTexture("touming.png")	--("ink_01.png")
	imageView:setAnchorPoint(cc.p(0,0))
    imageView:setPosition(cc.p(0,0))
	imageView:setTag(widget:getTag()*200000)
	imageView:setTouchEnabled(true)
	--点击覆盖类触发函数	
	Utils:addTouchEvent(imageView, function(sender)
		self:loadIconBySelectedType(sender)
	end, true, true, 0)
	
	local str = string.sub(widget:getName(),5,-1)
	imageView:setName(string.format("cover%s",str))
    widget:addChild(imageView)
	return imageView
end
--------------------------------------------------------------------------------------------------
--创建固定类grid(栅栏)
function UIMapEdit:addFixImg(widget)
	local imageView = ccui.ImageView:create()
    imageView:loadTexture("touming.png")	--("ink_01.png")
	imageView:setAnchorPoint(cc.p(0,0))
    imageView:setPosition(cc.p(0,0))
	imageView:setTag(widget:getTag()*100000)
	imageView:setTouchEnabled(true)
	--点击固定类触发函数
	Utils:addTouchEvent(imageView, function(sender)
		self:loadIconBySelectedType(sender)
	end, true, true, 0)
	
	local str = string.sub(widget:getName(),5,-1)
	imageView:setName(string.format("fixed%s",str))
    widget:addChild(imageView)
	return imageView
end
---------------------------------------------点击函数-----------------------------------------------
--点击各个grid和block触发的函数					
function UIMapEdit:cellClick(sender)
	if mCheckBoxIndex == 0 then
		UIPrompt:show("请先选中需要的元素")
		return
	end
	local imgStr = self:setImgBySelectedIcon()
	if  string.sub(sender:getName(),1,4) == "grid"  and (UIMapEditElementData:judgeBloc(imgStr) == true)  then
		UIPrompt:show("此种类型只能用于阻碍，不能用于格子")
		return
	end

	local str = string.sub(sender:getName(),5,-1)
	local name =string.format("cover%s",str)
	local cover = UIManager:seekNodeByName(mGridPanel, name)
	local fix = UIManager:seekNodeByName(mGridPanel, string.format("fixed%s",str))
	
	if UIMapEditElementData:judgeBloc(imgStr) == false and (string.sub(sender:getName(),1,4) == "bloc")then
		UIPrompt:show("此种类型只能用于格子，不能用于阻碍")
		return
	end
	
	local i,j,direct = 0,0,""
	local arr = CommonFunc:stringSplit(sender:getName(), "_", false)
	
	if string.sub(sender:getName(),7,7) == "V" or string.sub(sender:getName(),7,7) == "H" then 
		direct = arr[2]					-- “block_V_4_2”	--“block_H_5_3”
		i = arr[3]
		j= arr[4]
	else								--“grid_1_3”	--"cover_1_1"  -- "fixed_1_1"
		i = arr[2]
		j = arr[3]
	end

	if imgStr == "ImageFile.png" then
		sender:loadTexture(imgStr)
		cover:loadTexture("touming.png")
		fix:loadTexture("touming.png")
		UIMapEditGridData:setGridData(i,j)
		return
	end
	
	local gridData = UIMapEditGridData:getGridData()
	local firstCenterString = string.sub(gridData[tonumber(i)][tonumber(j)].center,1,1)
	
	local elementIconStr = UIMapEditElementData:getNormalImgByIndex(mCheckBoxIndex)
	
	if tonumber(firstCenterString) == 0 and (elementIconStr == "ink_01.png" or 
			elementIconStr == "ink_02.png" or elementIconStr == "gif_01.png" or 
			elementIconStr == "fence_01.png") then
		UIPrompt:show("请先设置底部的元素，再设置覆盖类（墨水.爪子、礼包）")
		return
	end
	local iconStr = self:setImgBySelectedIcon()
	if iconStr == UIMapEditElementData:getElementIconById(speElement["ink"])  and cover ~= nil then	--(墨汁，覆盖类要特殊处理)
		cover:loadTexture( UIMapEditElementData:getElementIconById(speElement["ink"]) ) 
	elseif  iconStr == UIMapEditElementData:getElementIconById(speElement["ink_2"]) and cover ~= nil then	--(墨汁2，覆盖类要特殊处理)
		cover:loadTexture( UIMapEditElementData:getElementIconById(speElement["ink_2"]) ) 
	elseif iconStr == UIMapEditElementData:getElementIconById(speElement["giftBag"])  and cover ~= nil then	--(礼包，覆盖类要特殊处理)
		cover:loadTexture( UIMapEditElementData:getElementIconById(speElement["giftBag"]) )   
	elseif iconStr == UIMapEditElementData:getElementIconById(speElement["fence"])  and fix ~= nil then	--(栅栏，覆盖类要特殊处理)
		fix:loadTexture( UIMapEditElementData:getElementIconById(speElement["fence"]) )
	else
		sender:loadTexture(iconStr)
	end
	--cclog("cellClick************",index,i,j,direct,sender:getName(),cover,fix)
	UIMapEditGridData:setGridDataByElement(mCheckBoxIndex,tonumber(i),tonumber(j),direct)
end
--------------------------------------------------------------------------------------------------
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
		local elementIconStr = UIMapEditElementData:getNormalImgByIndex(mCheckBoxIndex)
		if elementIconStr == "ink_01.png" or elementIconStr == "ink_02.png" or 
			elementIconStr == "gif_01.png" or elementIconStr == "fence_01.png" then
			UIPrompt:show("请先设置底部的元素，再设置覆盖类（墨水.爪子、礼包）")
		end	
	elseif eventType == ccui.CheckBoxEventType.unselected then
		mCheckBoxIndex = 0
	end
end
--------------------------------------------------------------------------------------------------
--保存按钮触发的事件
function UIMapEdit:saveBtnClick(sender)
	if mTextField:getString() == "" then
		UIPrompt:show("请输入保存的文件名")
	else
		--存文件为csv格式
		local fileName = UIManager:seekNodeByName(mRoot, "fileName")
		local nameStr = fileName:getString()
		UIMapEditGridData:saveToCSV(nameStr)
		
		UIMapEditElementData:initElementData()
		--初始化数据
		self:initMapUI()
		UIPrompt:show("保存成功，请在resource|data目录下查看")
	end
end
--------------------------------------------------------------------------------------------------
--导入按钮触发的事件
function UIMapEdit:importBtnClick(sender)
	if mTextField:getString() == "" then
		UIPrompt:show("请输入导入的文件名")
	else
		--刚加入时，初始化地图(并开启点击事件)
		self:initEmptyCell()
		--初始化格子数据表
		UIMapEditGridData:initGridData()
		UIMapEditGridData:importToCSV(mTextField)
		--根据数据表设置界面
		self:setUIByImportData(UIMapEditGridData:getGridData())
		UIPrompt:show("导入文件成功")
		mTextField:setString("")
	end
end
-------------------------------------------初始化界面信息-------------------------------------------
--初始化滚动图层														
function UIMapEdit:initScrollCheckBox()
	local scrollView = UIManager:seekNodeByName(mRoot,"ScrollView_2") --"ScrollView_item"
	
	local allElementData =  UIMapEditElementData:getElementData()
	local data = {}
	for key,val in pairs(allElementData) do
		local ItemData = {}
		ItemData.icon = UIMapEditElementData:getIconById(key)
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
--------------------------------------------------------------------------------------------------
--初始化界面的一些数据和布局
function UIMapEdit:initMapUI()
	--刚加入时，初始化地图(并开启点击事件)
	self:initEmptyCell()
	--初始化滚动图层
	self:initScrollCheckBox()
	mCheckBoxIndex = 0
	mTextField:setString("")
	--初始化元素数据
	UIMapEditElementData:setBoardIcon()
	--初始化格子数据表
	UIMapEditGridData:initGridData()
end
--------------------------------------------------------------------------------------------------
--刚加入时，初始化地图(并开启和注册点击事件)
function UIMapEdit:initEmptyCell()
	--获得 8*7的元素图片
	for i=1,8,1 do
		for j = 1,11,1 do
			local name = string.format("grid_%d_%d",i,j)
			local grid = UIManager:seekNodeByName(mGridPanel, name)
			grid:loadTexture("ImageFile.png")
			grid:setTouchEnabled(true)
			grid:removeAllChildren()
			
			local fixed = self:addFixImg(grid)
			self:addCoverImg(grid)
			Utils:addTouchEvent(grid,  function(sender)
				self:cellClick(sender)
			end, true, true, 0)
		end
	end
	--获得垂直方向的阻挡（8*12）
	for i=1,8,1 do
		for j = 1,12,1 do
			local name = string.format("block_V_%d_%d",i,j)
			local blockV = UIManager:seekNodeByName(mGridPanel, name)
			blockV:loadTexture("block_v.png")
			blockV:setTouchEnabled(true)
			blockV:setScale9Enabled(true)
			blockV:setAnchorPoint(cc.p(0.5,0.5))
			blockV:setContentSize(cc.size(6,64))
			blockV:setRotation(0)
			blockV:removeAllChildren()
			Utils:addTouchEvent(blockV, function(sender)
				self:cellClick(sender)
			end, true, true, 0)
		end
	end
	
	--获得水平方向的阻挡（9*11）
	for i=1,9,1 do
		for j = 1,11,1 do
			local name = string.format("block_H_%d_%d",i,j)
			local blockH = UIManager:seekNodeByName(mGridPanel, name)
			blockH:loadTexture("block_h.png")
			blockH:setTouchEnabled(true)
			blockH:setScale9Enabled(true)
			blockH:setAnchorPoint(cc.p(0.5,0.5))
			blockH:setContentSize(cc.size(64,6))
			blockH:setRotation(0)
			blockH:removeAllChildren()
			Utils:addTouchEvent(blockH,  function(sender)
				self:cellClick(sender)
			end, true, true, 0)
		end
	end
end
--------------------------------------------------------------------------------------------------
