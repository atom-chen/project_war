----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2015-02-04
-- Brief: �����ӿڶ���
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
-- ��ò����Żݵ��ۿ�ͼƬ
function ChannelPayCode:getDisMovDiscountImg()
	return self.mMoveDiscountImg
end
-------------------------------------------------------
-- ��ù������ļ۸�
function ChannelPayCode:getBuyMovPrice()
	return self.mMovPrice
end
-------------------------------------------------------
-- ��ù������Żݵļ۸�
function ChannelPayCode:getBuyDisMovPrice()
	return self.mDisMovPrice
end
-------------------------------------------------------
-- ��ò��������ļ۸�
function ChannelPayCode:getBuyPowerPrice()
	return self.mPowerPrice
end
-------------------------------------------------------
-- ��ò�����������(EMP)֧����
function ChannelPayCode:getBuyPowerDxCode()
	return self.mBuyPowerDxCode
end
-------------------------------------------------------
-- ����������֧ͨ����
function ChannelPayCode:getBuyPowerLtCode()
	return self.mBuyPowerLtCode
end
-------------------------------------------------------
-- ���������ƶ�֧����
function ChannelPayCode:getBuyPowerYdCode()
	return self.mBuyPowerYdCode
end
-------------------------------------------------------
-- �����Ż�����(EMP)֧����
function ChannelPayCode:getDisMovDxCode()
	return self.mDisMovDxCode
end
-------------------------------------------------------
-- �����Ż���֧ͨ����
function ChannelPayCode:getDisMovLtCode()
	return self.mDisMovLtCode
end
-------------------------------------------------------
-- �����Ż��ƶ�֧����
function ChannelPayCode:getDisMovYdCode()
	return self.mDisMovYdCode
end
-------------------------------------------------------
-- ����������(EMP)֧����
function ChannelPayCode:getMovDxCode()
	return self.mMovDxCode
end
-------------------------------------------------------
-- ��������֧ͨ����
function ChannelPayCode:getMovLtCode()
	return self.mMovLtCode
end
-------------------------------------------------------
-- �������ƶ�֧����
function ChannelPayCode:getMovYdCode()
	return self.mMovYdCode
end
-------------------------------------------------------
-- ����ƽ̨�����Ĭ�ϵ�������
function ChannelPayCode:getDefaultChannelId()
	if cc.PLATFORM_OS_ANDROID == G.PLATORM or cc.PLATFORM_OS_WINDOWS == G.PLATORM then
		return self.mAndroidChannelId
	else
		return self.mIosChannelId
	end
end
----------------------------------------------------------------
-- ��������֧����ͼ۸���Ϣ
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
-- ��������id����ʼ����Ӧ��֧����
function ChannelPayCode:initGlobalCode()
	local payData = LogicTable:getAll("pay_tplt")	 --�������е�����
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