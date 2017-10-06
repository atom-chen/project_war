----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-06-09
-- Brief: 地图编辑器元素数据
----------------------------------------------------------------------
UIMapEditElementData = {
}

local allData = {}				--保存元素表中的所有值
local mBoardId = {6001,6002,6003,6004,6005,6006,6007,6008,-1,-2}
local mBoardIcon = {}			--阻挡类型的图片
--------------------------------------------------------------------------------------------------
--根据index,获得元素的正常图片
function UIMapEditElementData:getNormalImgByIndex(index)
	return allData[index].normal_image
end
--------------------------------------------------------------------------------------------------
--根据数据表中的数值，获得它是什么元素，进而加载对应的图片
function UIMapEditElementData:getIconByElement(content)
	if tonumber(content) == 0 then
		return
	end
	local index = UIMapEditElementData:getIndexById(content)
	local data = CommonFunc:query(allData, function(k, v) return index == k end)
	return data.normal_image
end
--------------------------------------------------------------------------------------------------
--设置阻挡类型的图片
function UIMapEditElementData:setBoardIcon()
	for key,val in pairs(mBoardId) do
		local index = UIMapEditElementData:getIndexById(val)
		local data = CommonFunc:query(allData, function(k, v) return index == k end)
		table.insert(mBoardIcon, data.normal_image)
	end
end	
--------------------------------------------------------------------------------------------------
--判断图片是否是阻碍类型
function UIMapEditElementData:judgeBloc(img)
	local temp = false
	for key,val in pairs(mBoardIcon) do
		if img == val then
			temp = true
			return temp
		end
	end
	return temp
end
--------------------------------------------------------------------------------------------------
--根据元素的id，获得数据的图片
function UIMapEditElementData:getElementIconById(id)
	local index = UIMapEditElementData:getIndexById(id)
	return UIMapEditElementData:getIconById(index)
end
--------------------------------------------------------------------------------------------------
--根据元素的id，获得它是元素中的第几个
function UIMapEditElementData:getIndexById(id)
	for key,val in pairs(allData) do
		if val.id == id then
			return key
		end
	end
end
--------------------------------------------------------------------------------------------------
--根据index，获得数据的图片
function UIMapEditElementData:getIconById(index)
	if index == (#allData -1)  then
		return "block_h.png"
	elseif index == #allData then
		return "block_v.png"
	end
	local data = CommonFunc:query(allData, function(k, v) return index == k end)
	if data.normal_image == "nil" then
		data.normal_image ="ImageFile.png"
	end
	return data.normal_image
end
--------------------------------------------------------------------------------------------------
--初始化所有的元素数据
function UIMapEditElementData:initElementData()
	local elementTable = reload("element_tplt.lua")
	allData = {}
	for key, val in pairs(elementTable) do
		table.insert(allData, val)
	end
	table.sort(allData, function(a, b) return a.id < b.id end)
	local temp1 = {["id"] = -1,["normal_image"]= "block_h.png"}			--空白的水平格子图片
	local temp2 = {["id"] = -2,["normal_image"]= "block_v.png"}			--空白的垂直格子图片
	table.insert(allData, temp1)
	table.insert(allData, temp2)
end
--------------------------------------------------------------------------------------------------
--获取所有的元素数据
function UIMapEditElementData:getElementData()
	return allData
end
--------------------------------------------------------------------------------------------------