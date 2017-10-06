----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-6-23
-- Brief: 步数打折优惠信息
----------------------------------------------------------------------
ModelDisMoves = {
	["failTimes"] = 0,				-- 记录当前关卡失败的次数
}

--设置该关出现失败的次数
function ModelDisMoves:setFailTimes(times)
	self.failTimes = times
end

--判断上一次和这一次打的关卡是否相同
function ModelDisMoves:isSameLevel()
	local cur = tostring(ModelPub:getCurPass())
	local last = tostring(DataMap:getLastPass())
	if cur == last then
		ModelDisMoves:setFailTimes(self.failTimes + 1)
	else
		ModelDisMoves:setFailTimes(1)
	end
end

--如果失败了三次打第四次的时候，弹出打折购买步数界面
function ModelDisMoves:showDiscountMoves()
	if self.failTimes  == G.DIS_MOVES_TIMES and tostring(ChannelPayCode:getBuyDisMovPrice()) ~= "0"then
		UIGameGoal:closeCenterPanel()
		UIDiscountMoves:openFront(true)
	end
end
