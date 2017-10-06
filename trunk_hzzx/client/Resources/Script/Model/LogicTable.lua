----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-12
-- Brief: 逻辑数据表
----------------------------------------------------------------------
LogicTable = {
	LOGIC_DATA_MAP = {},			-- 数据映射表
	mLoading = true,				-- 是否在加载数据表
	mPreLoadFile = {				-- 预加载文件列表,预加载的文件大小应控制在128K以内
		"element_tplt",					-- 元素表
		"item_tplt",					-- 物品表
		"award_tplt",					-- 奖励表
		"skill_tplt",					-- 技能表
		"hero_tplt",					-- 英雄表
		"monster_tplt",					-- 怪物表
		"copy_resource_tplt",			-- 副本资源表
		"copy_scene_tplt",				-- 副本场景表
		"copy_tplt",					-- 副本表
		"music_tplt",					-- 音乐音效表
		"hero_scene",					-- 英雄效果表
		"award_base_tplt",				-- 奖励基础表
		"award_pond_tplt",				-- 奖励池表
		"gift_bag_tplt",				-- 礼包表
		"cg_tplt",						-- 四格漫画图片表
		"shop_tplt",					-- 商城表
		"discount_diamond_tplt",		-- 过关后砖石限时折扣表
		"pay_tplt",						-- 渠道支付码表
	},
}
----------------------------------------------------------------------
-- 分批加载文件(避免一帧执行过多操作造成卡顿影响)
function LogicTable:updateLoad(loadEndCF)
	if false == mLoading then
		return
	end
	for key, val in pairs(self.mPreLoadFile) do
		if self:loadCsv(val) then
			return
		end
	end
	mLoading = false
	if "function" == type(loadEndCF) then
		loadEndCF()
	end
end
----------------------------------------------------------------------
-- 重新加载csv文件
function LogicTable:reloadCsv(fileName, needKeyField)
	if nil == fileName then
		return
	end
	if nil == needKeyField then
		needKeyField = true
	end
	self.LOGIC_DATA_MAP[fileName] = DataTable:loadFile(fileName..".csv", needKeyField)
end
----------------------------------------------------------------------
-- 加载csv文件
function LogicTable:loadCsv(fileName, needKeyField)
	if fileName and nil == self.LOGIC_DATA_MAP[fileName] then
		if nil == needKeyField then
			needKeyField = true
		end
		self.LOGIC_DATA_MAP[fileName] = DataTable:loadFile(fileName..".csv", needKeyField)
		return self.LOGIC_DATA_MAP[fileName]
	end
	return nil
end
----------------------------------------------------------------------
-- 获取单条数据
function LogicTable:get(fileName, key, mustExist)
	self:loadCsv(fileName)
	local fileData = self.LOGIC_DATA_MAP[fileName]
	local row = DataTable:getRow(fileData, key, allowNil)
	if nil == row and true == mustExist then
		assert(nil, "LogicTable -> get() -> can't find key '"..key.."' in file '"..fileData.name.."'")
	end
	return CommonFunc:clone(row)
end
----------------------------------------------------------------------
-- 按条件获取数据
function LogicTable:getCondition(fileName, conditionFunc)
	self:loadCsv(fileName)
	return CommonFunc:clone(DataTable:getRowArray(self.LOGIC_DATA_MAP[fileName], conditionFunc))
end
----------------------------------------------------------------------
-- 获取所有数据
function LogicTable:getAll(fileName)
	self:loadCsv(fileName)
	return CommonFunc:clone(self.LOGIC_DATA_MAP[fileName].map)
end
----------------------------------------------------------------------
-- 获取奖励数据
function LogicTable:getAwardData(awardId)
	local awardData = LogicTable:get("award_tplt", awardId, true)
	-- 计算随机数量
	local areaNum = #awardData.count_area
	if 1 == areaNum then
		awardData.count = awardData.count_area[1]
	else
		local sCount, eCount = awardData.count_area[1], awardData.count_area[areaNum]
		local countArea = {}
		for i=sCount, eCount do
			table.insert(countArea, i)
		end
		awardData.count = CommonFunc:getRandom(countArea)
	end
	return awardData
end
----------------------------------------------------------------------