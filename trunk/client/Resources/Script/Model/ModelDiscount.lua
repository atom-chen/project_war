----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-6-19
-- Brief: 限时打折的数据（通过等级解锁）
----------------------------------------------------------------------
ModelDiscount = {
	mOpenDisDiaFlag = false,		-- 是否打开砖石打折界面
}

--设置是否打开限时打折界面
function ModelDiscount:setOpenDisDiaFlag(flag)
	self.mOpenDisDiaFlag = flag
end

--获得是否打开限时打折界面
function ModelDiscount:getOpenDisDiaFlag()
	return self.mOpenDisDiaFlag
end

--判断该关卡是不是第一次成功通过
function ModelDiscount:isFirstSuccess()
	if DataMap:getPass() > DataMap:getMaxPass() and ModelPub:isSpeLevel() == false then
		return true
	end
	return false
end

--判断是不是要显示限时打折购买界面（12关打完后）
function ModelDiscount:showDisCountDiamond(showDis)
	if self:getOpenDisDiaFlag() and showDis ~= 0 then
		self:saveDisDiaData()
		UIDiscountDiamond:openFront(true)
		self:setOpenDisDiaFlag(false)
	end
end
-------------------------------------------------------------------------------
--判断活动按钮要不要显示（主界面上的Icon）
function ModelDiscount:showActivityBtn()
	-- 没有开启的情况
	local maxPass = DataMap:getMaxPass()
	if maxPass < G.DIS_DIA_LEVEL then
		return false
	end
	local dataTb = DataMap:getDisDiamondInfo()
	-- 只要等级够,还没有保存到数据库中,就显示按钮
	if 0 == #dataTb then
		if maxPass >= G.DIS_DIA_LEVEL then
			self:saveDisDiaData()
			return true
		end
		return false
	end
	local nowSec = STime:getClientTime()
	local endSec = nowSec
	-- 上次保存是table,容错处理
	if "table" ~= type(dataTb[1].end_time) then
		endSec = dataTb[1].end_time
	end
	-- 如果在后台时间够了,就重新随机一个出来
	if nowSec >= endSec then
		self:saveDisDiaData()
	end
	return true
end
-------------------------------------------------------------------------------
--根据活动持续时间，和客户端开启时间，计算活动结束时间
function ModelDiscount:getDisDiaEndTime(tb)
	local start_time = tb.start_time
	local dis_dia_info = tb.dis_dia_info  
	
	--ModelDiscount:setDisDiamondInfo(dis_dia_info)
	local endSec = start_time + dis_dia_info.times*60*60
	
	return endSec
end

--获取渠道数据
function ModelDiscount:getChannelData()
	local allTb = LogicTable:getAll("discount_diamond_tplt")
	local channelTb = {}
	local channelId, defaultChannelId = ChannelProxy:getChannelId()
	for key, val in pairs(allTb) do
		if channelId == val.channel_id then
			table.insert(channelTb, val)
		end	
	end
	if 0 == #channelTb then
		for key, val in pairs(allTb) do
			if defaultChannelId == val.channel_id then
				table.insert(channelTb, val)
			end
		end
	end
	return channelTb
end

--设置打折数据库
function ModelDiscount:saveDisDiaData()
	local tb = {}
	tb.start_time = STime:getClientTime()
	tb.dis_dia_info = CommonFunc:getRandom(self:getChannelData())
	tb.end_time = self:getDisDiaEndTime(tb)
	
	local tempTb = {tb}
	DataMap:setDisDiamondInfo(tempTb)
end

--获取活动剩余时间
function ModelDiscount:getActivityLeftTime()
	local dataTb = DataMap:getDisDiamondInfo()
	local nowSec = STime:getClientTime()  		
	local endSec = dataTb[1].end_time
	local temp = endSec - nowSec
	if temp <= 0 then
		return 0
	end
	return temp
end
-------------------------------------------------------------------------------

