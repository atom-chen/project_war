----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-7-28
-- Brief: 7日签到逻辑
----------------------------------------------------------------------
ModelSignIn = {
	mSignTb = {},					-- 七天签到的数据
	mOpenSignInFlag = false,		-- 是否打开每日签到界面
	mTodaySignInFlag = false,		-- 今日有没有签到的标记
	mDailyTimerFlag = false,		-- 定时器
}

--设置7天签到的数据
function ModelSignIn:setSignTb(nowDate)
	mSignTb[#mSignTb + 1] = nowDate 
	DataMap:setSignInData(mSignTb)
	self:setTodaySignIn(true)
end

--获取签到数据
function ModelSignIn:getSignTb()
	return mSignTb
end

--判断7天签到有没有完成
function ModelSignIn:isFinishSignIn()
	if 7 <= #mSignTb then
		return true
	end
	return false
end

--判断活动按钮要不要显示（主界面上的Icon）
function ModelSignIn:showSignInBtn()
	if (G.SIGNIN_LEVEL <= DataMap:getMaxPass()) and (self:isFinishSignIn() == false) then
		return true
	end
	return false
end

--判断今日有没有签到
function ModelSignIn:isTodaySignIn()
	return mTodaySignInFlag
end

--设置今日签到flag
function ModelSignIn:setTodaySignIn(flag)
	mTodaySignInFlag = flag
	DataMap:setTodaySignFlag(flag)
end
---------------------------------用户在成功通过指定关卡后，签到功能开启。-------------------------------------------------
--设置是否打开7日签到界面
function ModelSignIn:setOpenSignInFlag(flag)
	mOpenSignInFlag = flag
end

--获得是否打开7日签到界面
function ModelSignIn:getOpenSignInFlag()
	return mOpenSignInFlag
end

--判断是不是要显示7日签到买界面（12关打完后）
function ModelSignIn:showSignInUI()
	local maxPass = DataMap:getMaxPass()
	if self:getOpenSignInFlag() and DataMap:getPass() == G.SIGNIN_LEVEL and maxPass == G.SIGNIN_LEVEL then
		UISignIn:openFront(true)
		self:setOpenSignInFlag(false)
	end
end
-----------------------------------------------------------------------------------
-- 当天到达24:00:00
function ModelSignIn:dailyTimerOver()
	self:initSignInData()
	UIMiddlePub:showSignInBtn()
	UISignIn:initSignUI()
end

--初始化7天签到数据tb
function ModelSignIn:initSignInData()
	local signTb = DataMap:getSignInData()
	--Log("ModelSignIn:initSignInData()*******",signTb)
	mTodaySignInFlag = DataMap:getTodaySignFlag()
	if  0 ~= #signTb and #signTb <= 7 then
		local lastSignDate = signTb[#signTb]
		local refreshFlag = self:refreshTodaySignFlag(lastSignDate)
		if true == refreshFlag then
			self:setTodaySignIn(false)
		end	
	end
	mSignTb = signTb
	-- 当天到达24:00:00
	local function dailyTimerOver()
		self:setTodaySignIn(false)
		self:initSignInData()
		UIMiddlePub:showSignInBtn()
		UISignIn:initSignUI()
	end
	if nil == mDailyTimerFlag then
		mDailyTimerFlag =  false
	end
	if false == mDailyTimerFlag then
		mDailyTimerFlag = true
		STime:createDailyTimer(24, 0, 0, dailyTimerOver)
	end
end

--根据最后一次签到的时间，刷新今日签到标签
function ModelSignIn:refreshTodaySignFlag(lastDate)
	local nowDate = STime:getClientDate()
	if nowDate.year - lastDate.year < 1 then
		if nowDate.month - lastDate.month < 1 then
			if nowDate.day - lastDate.day < 1 then
				return false
			else						--解决第二天登陆问题
				return true
			end
		elseif nowDate.month - lastDate.month >= 1 then
			return true
		end
	elseif nowDate.year - lastDate.year >= 1 then
		return true
	end
end
-------------------------------------------------------------------------------

