----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-04
-- Brief: 渠道接口定义
----------------------------------------------------------------------
ChannelPayCode = {
	mAndroidChannelId = "10001",
	mIosChannelId = "20001",
	mBuyPowerDxCode = nil,
	mBuyPowerLtCode = nil,
	mBuyPowerYdCode = nil,
	mDisMovDxCode = nil,
	mDisMovLtCode = nil,
	mDisMovYdCode = nil,
	mMovDxCode = nil,
	mMovLtCode = nil,
	mMovYdCode = nil,
	mMovPrice = 0,
	mDisMovPrice = 0,
	mPowerPrice = 0,
	mMoveDiscountImg = 0,
}
-------------------------------------------------------
-- 获得步数优惠的折扣图片
function ChannelPayCode:getDisMovDiscountImg()
	return self.mMoveDiscountImg
end
-------------------------------------------------------
-- 获得购买步数的价格
function ChannelPayCode:getBuyMovPrice()
	return self.mMovPrice
end
-------------------------------------------------------
-- 获得购买步数优惠的价格
function ChannelPayCode:getBuyDisMovPrice()
	return self.mDisMovPrice
end
-------------------------------------------------------
-- 获得补满体力的价格
function ChannelPayCode:getBuyPowerPrice()
	return self.mPowerPrice
end
-------------------------------------------------------
-- 获得补满体力天翼(EMP)支付码
function ChannelPayCode:getBuyPowerDxCode()
	return self.mBuyPowerDxCode
end
-------------------------------------------------------
-- 补满体力联通支付码
function ChannelPayCode:getBuyPowerLtCode()
	return self.mBuyPowerLtCode
end
-------------------------------------------------------
-- 补满体力移动支付码
function ChannelPayCode:getBuyPowerYdCode()
	return self.mBuyPowerYdCode
end
-------------------------------------------------------
-- 步数优惠天翼(EMP)支付码
function ChannelPayCode:getDisMovDxCode()
	return self.mDisMovDxCode
end
-------------------------------------------------------
-- 步数优惠联通支付码
function ChannelPayCode:getDisMovLtCode()
	return self.mDisMovLtCode
end
-------------------------------------------------------
-- 步数优惠移动支付码
function ChannelPayCode:getDisMovYdCode()
	return self.mDisMovYdCode
end
-------------------------------------------------------
-- 购买步数天翼(EMP)支付码
function ChannelPayCode:getMovDxCode()
	return self.mMovDxCode
end
-------------------------------------------------------
-- 购买步数联通支付码
function ChannelPayCode:getMovLtCode()
	return self.mMovLtCode
end
-------------------------------------------------------
-- 购买步数移动支付码
function ChannelPayCode:getMovYdCode()
	return self.mMovYdCode
end
-------------------------------------------------------
-- 根据平台，获得默认的渠道号
function ChannelPayCode:getDefaultChannelId()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM or cc.PLATFORM_OS_WINDOWS == G.PLATORM then
		return self.mAndroidChannelId
	else
		return self.mIosChannelId
	end
end
----------------------------------------------------------------
-- 设置渠道支付码和价格信息
function ChannelPayCode:setGlobalCode(val)
	self.mBuyPowerDxCode = val.dx_code_power
	self.mBuyPowerLtCode = val.lt_code_power			
	self.mBuyPowerYdCode = val.yd_code_power			
	self.mDisMovDxCode = val.dx_code_dis_moves
	self.mDisMovLtCode = val.lt_code_dis_moves	
	self.mDisMovYdCode = val.yd_code_dis_moves	
	self.mMovDxCode	= val.dx_code_moves			
	self.mMovLtCode	= val.lt_code_moves			
	self.mMovYdCode	= val.yd_code_moves	
	self.mMovPrice = val.moves_price
	self.mDisMovPrice = val.dis_moves_price
	self.mPowerPrice = val.power_price
	self.mMoveDiscountImg = val.moves_discount_img
end
----------------------------------------------------------------------
-- 根据渠道id，初始化相应的支付码
function ChannelPayCode:initGlobalCode()
	local payData = LogicTable:getAll("pay_tplt")	 --表中所有的数据
	local flag = false
	for key,val in pairs(payData) do
		if val.channel_id == ChannelProxy:getChannelId() then
			flag = true
			self:setGlobalCode(val)		
		end
	end
	if flag == false then
		local needChannelId = self:getDefaultChannelId()
		for key,val in pairs(payData) do
			if val.channel_id == needChannelId then
				self:setGlobalCode(val)		
			end
		end
	end
end
----------------------------------------------------------------------