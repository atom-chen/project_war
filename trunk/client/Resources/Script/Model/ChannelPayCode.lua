----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-04
-- Brief: 渠道接口定义
----------------------------------------------------------------------
ChannelPayCode = {
	mBuyPowerDxCode = nil,
	mBuyPowerLtCode = nil,
	mBuyPowerYdCode = nil,
	mBuyPowerAsCode = nil,
	mBuyPowerGpCode = nil,
	mBuyPowerCkCode = nil,
	mMovDxCode = nil,
	mMovLtCode = nil,
	mMovYdCode = nil,
	mMovAsCode = nil,
	mMovGpCode = nil,
	mMovCkCode = nil,
	mDisMovDxCode = nil,
	mDisMovLtCode = nil,
	mDisMovYdCode = nil,
	mDisMovAsCode = nil,
	mDisMovGpCode = nil,
	mDisMovCkCode = nil,
	mPowerPrice = 0,
	mMovPrice = 0,
	mDisMovPrice = 0,
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
	return ModelPub:changeYDCode(self.mBuyPowerYdCode)  
end
-------------------------------------------------------
-- 补满体力AppStore支付码
function ChannelPayCode:getBuyPowerAsCode()
	return self.mBuyPowerAsCode
end
-------------------------------------------------------
-- 补满体力GooglePlay支付码
function ChannelPayCode:getBuyPowerGpCode()
	return self.mBuyPowerGpCode
end
-------------------------------------------------------
-- 补满体力触控支付码
function ChannelPayCode:getBuyPowerCkCode()
	return self.mBuyPowerCkCode
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
	return ModelPub:changeYDCode(self.mDisMovYdCode) 
end
-------------------------------------------------------
-- 步数优惠AppStore支付码
function ChannelPayCode:getDisMovAsCode()
	return self.mDisMovAsCode
end
-------------------------------------------------------
-- 步数优惠GooglePlay支付码
function ChannelPayCode:getDisMovGpCode()
	return self.mDisMovGpCode
end
-------------------------------------------------------
-- 步数优惠触控支付码
function ChannelPayCode:getDisMovCkCode()
	return self.mDisMovCkCode
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
	return ModelPub:changeYDCode(self.mMovYdCode)  
end
-------------------------------------------------------
-- 购买步数AppStore支付码
function ChannelPayCode:getMovAsCode()
	return self.mMovAsCode
end
-------------------------------------------------------
-- 购买步数GooglePlay支付码
function ChannelPayCode:getMovGpCode()
	return self.mMovGpCode
end
-------------------------------------------------------
-- 购买步数触控支付码
function ChannelPayCode:getMovCkCode()
	return self.mMovCkCode
end
-------------------------------------------------------
-- 根据平台,获得货币符号
function ChannelPayCode:getMoneySign()
	local sign = "￥"
	local channelId = ChannelProxy:getChannelId()
	if channelId == "10271" or channelId == "20002" then	--google play,IOS Google, 10301华为（拉美）
		sign = "$"
	elseif channelId == "10291" then	--Coda印度尼西亚
		sign = "Rp."
	end
	return sign
end
----------------------------------------------------------------
-- 根据平台,获取格式化后的价格字符串
function ChannelPayCode:getFormatPrice(price)
	local moneySign = self:getMoneySign()
	local priceString = tostring(price)
	local channelId = ChannelProxy:getChannelId()
	if "10321" == channelId then	-- Cocos
		priceString = string.format("%0.2f", price)
	end
	return moneySign..priceString
end
----------------------------------------------------------------
-- 设置渠道支付码和价格信息
function ChannelPayCode:setGlobalCode(val)
	local powerCodeInfo, movesCodeInfo, disMovescodeInfo = {}, {}, {}
	if 0 ~= val.power_code then
		powerCodeInfo = LogicTable:get("code_tplt", val.power_code, true)
	end
	if 0 ~= val.moves_code then
		movesCodeInfo = LogicTable:get("code_tplt", val.moves_code, true)
	end
	if 0 ~= val.dis_moves_code then
		disMovescodeInfo = LogicTable:get("code_tplt", val.dis_moves_code, true)
	end
	self.mBuyPowerDxCode = powerCodeInfo.dx_code
	self.mBuyPowerLtCode = powerCodeInfo.lt_code
	self.mBuyPowerYdCode = powerCodeInfo.yd_code
	self.mBuyPowerAsCode = powerCodeInfo.as_code
	self.mBuyPowerGpCode = powerCodeInfo.gp_code
	self.mBuyPowerCkCode = powerCodeInfo.ck_code
	self.mMovDxCode	= movesCodeInfo.dx_code
	self.mMovLtCode	= movesCodeInfo.lt_code
	self.mMovYdCode	= movesCodeInfo.yd_code
	self.mMovAsCode = movesCodeInfo.as_code
	self.mMovGpCode = movesCodeInfo.gp_code
	self.mMovCkCode = movesCodeInfo.ck_code
	self.mDisMovDxCode = disMovescodeInfo.dx_code
	self.mDisMovLtCode = disMovescodeInfo.lt_code
	self.mDisMovYdCode = disMovescodeInfo.yd_code
	self.mDisMovAsCode = disMovescodeInfo.as_code
	self.mDisMovGpCode = disMovescodeInfo.gp_code
	self.mDisMovCkCode = disMovescodeInfo.ck_code
	self.mPowerPrice = val.power_price
	self.mMovPrice = val.moves_price
	self.mDisMovPrice = val.dis_moves_price
	self.mMoveDiscountImg = val.moves_discount_img
end
----------------------------------------------------------------------
-- 根据渠道id,初始化相应的支付码
function ChannelPayCode:initGlobalCode()
	local payData = LogicTable:getAll("pay_tplt")	 -- 表中所有的数据
	local channelId, defaultChannelId = ChannelProxy:getChannelId()
	for key, val in pairs(payData) do
		if channelId == val.channel_id then
			self:setGlobalCode(val)
			return
		end
	end
	for key, val in pairs(payData) do
		if defaultChannelId == val.channel_id then
			self:setGlobalCode(val)
			return
		end
	end
end
----------------------------------------------------------------------