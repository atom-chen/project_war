----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-01-06
-- Brief: 体力管理器
----------------------------------------------------------------------
PowerManger = {}
local tempCount = 0

--判断体力隔多少秒后补满
function PowerManger:getPowerFullLeftTime()
	local nowPower = self.mCurPower
	if nowPower >= DataMap:getMaxPower() then
		return 0
	end
	local startDateSec = DataMap:getDate()
	local nowSec = STime:getClientTime()
	local temp = G.POWER_RECOVER_TIME * (DataMap:getMaxPower() - nowPower)
	return startDateSec + temp - nowSec	
end

--判断离线时是否体力回满
function PowerManger:judgeIsFullPower()
	local lastSec = DataMap:getDate()
	local nowSec =  STime:getClientTime()
	
	local leftTime = "00:00"
	local count = G.POWER_RECOVER_TIME
	local addNumber = 0
	if type(lastSec) == "table" then		--容错处理
		return true,leftTime,count
	end
	
	local temp = nowSec - lastSec
	
	cclog("PowerManger:judgeIsFullPower()***************",lastSec,nowSec,temp)
	if lastSec == nowSec then		--第一次刚初始化的时候
		return true,leftTime,count,addNumber
	end
	cclog(DataMap:getPower() >= DataMap:getMaxPower(),lastSec == 0)
	if lastSec == 0 or DataMap:getPower() >= DataMap:getMaxPower() then			--离开时体力已经满的时候
		return true,leftTime,count,addNumber
	end
	
	local addTempPower = math.floor(temp/ G.POWER_RECOVER_TIME)
	local leftTempTime = temp % G.POWER_RECOVER_TIME
	
	cclog("****************************",addTempPower,leftTempTime)
	if DataMap:getPower()+ addTempPower >= DataMap:getMaxPower() then 
		cclog("我来设置最大值***************")
		return true,leftTime,count,addNumber
	else
		addNumber = addTempPower
		count = G.POWER_RECOVER_TIME - leftTempTime
		DataMap:setDate(lastSec + addTempPower * G.POWER_RECOVER_TIME)
		leftTime = Utils:secToString(G.POWER_RECOVER_TIME - leftTempTime)
		cclog("我来设置增加几个数***************",addTempPower,leftTime)
		return false,leftTime,count,addNumber
	end
end

--体力初始化
function PowerManger:init()
	local flag,leftTime,count,addNumber = PowerManger:judgeIsFullPower()
	if flag == true then
		if DataMap:getPower() >= DataMap:getMaxPower() then
			self.mCurPower = DataMap:getPower()
		else
			self.mCurPower = DataMap:getMaxPower()
		end
		DataMap:setPower(PowerManger:getCurPower())
		PowerManger:setMaxPower(DataMap:getMaxPower())
		self.timerCount = count
		tempCount = self.timerCount
	else
		self.mCurPower = DataMap:getPower()+ addNumber
		DataMap:setPower(DataMap:getPower() + addNumber)
		PowerManger:setMaxPower(DataMap:getMaxPower())
		self.timerCount = count
		tempCount = self.timerCount
		PowerManger:timerChangeCurPower()
	end
	PowerManger:setLeftTime(leftTime) 
	
	cclog("初始化le**************",PowerManger:getCurPower())
	EventCenter:post(EventDef["ED_POWER"])
end

--设置当前体力
function PowerManger:setCurPower(power)
	if power <= 0 then
		self.mCurPower = 0
	else
		self.mCurPower = power
	end
	DataMap:setPower(PowerManger:getCurPower())
end

--获取当前体力
function PowerManger:getCurPower()
	return self.mCurPower	
end

--设置最大体力
function PowerManger:setMaxPower(maxPower)
	self.mMaxPower = maxPower
	DataMap:setMaxPower(maxPower)
end

--获取体力上限
function PowerManger:getMaxPower()
	return self.mMaxPower
end

--设置改变当前体力（flag为“+”,"-"）(体力不够时要提前判断)
function PowerManger:setChangeCurPower(power,flag)
	if flag == "+" then
		self.mCurPower = (self.mCurPower or 0) + power
	elseif flag == "-" then
		self.mCurPower = (self.mCurPower or 0) - power
	end
end

--设置增加当前最大体力
function PowerManger:setAddMaxPower(addMaxpower)
	self.mMaxPower = (self.mMaxPower or 0) + addMaxpower
	DataMap:setPower(self.mMaxPower)
end

--获得体力的倒计时时间
function PowerManger:getLeftTime()
	return self.mLeftTime 
end

--设置体力的倒计时时间
function PowerManger:setLeftTime(times)
	self.mLeftTime = times
end

--获得当前体力与最大体力
function PowerManger:getCurAndMaxPower()
	return string.format("%d/%d",self.mCurPower,self.mMaxPower)
end

----------------------------------------------------体力倒计时------------------------------------------------------
--获得当前定时器次数
function PowerManger:getTimerCount()
	return self.timerCount
end

--设置当前定时器次数
function PowerManger:setTimerCount(count)
	self.timerCount = count
end

--获得当前定时器
function PowerManger:getTimer()
	return self.timer
end

--设置当前定时器
function PowerManger:setTimer()
	if self.timer ~= nil then
		self.timer:stop()
	end
	self.timer = nil
end

--当体力满时，需要处理的事情
function PowerManger:powerFullCallBack()
	if PowerManger:getCurPower() >= PowerManger:getMaxPower() then
		local timer = PowerManger:getTimer()
		if timer == nil then
			return
		end
		timer:stop()
		timer = nil
		DataMap:setDate(0)
		PowerManger:setLeftTime("00:00")
		PowerManger:setTimerCount(G.POWER_RECOVER_TIME)
		tempCount = PowerManger:getTimerCount()
		EventCenter:post(EventDef["ED_POWER_LEFT_TIME"],"00:00")
		return
	end
end

local function timer1_CF1(tm, runCount)
	--体力满后的处理
	local function setFullPower()
		PowerManger:setTimer()
		DataMap:setDate(0)
		PowerManger:setLeftTime("00:00")
		PowerManger:setTimerCount(G.POWER_RECOVER_TIME)
		tempCount = PowerManger:getTimerCount()
		EventCenter:post(EventDef["ED_POWER_LEFT_TIME"],"00:00")
		UIMiddlePub:setPower()
		UIMiddlePub:setLoadingBar()
	end
	
	if PowerManger:getCurPower() >= PowerManger:getMaxPower() then
		setFullPower()
		return
	end
	if runCount == 1 and tempCount > 0 then
		tempCount = tempCount - 1
	elseif runCount > 1 and tempCount > 0 then	--进入后台再进入前台，要把原有的定时器停止掉
		cclog("进入后台的运行时间**********",tempCount,runCount)
		local flag,leftTime,count,addNumber = PowerManger:judgeIsFullPower()
		if flag == true then
			PowerManger:setCurPower(DataMap:getMaxPower())
			DataMap:setPower(PowerManger:getCurPower())
			setFullPower()
			return
		else
			PowerManger:setTimer()
			PowerManger:setCurPower(DataMap:getPower()+ addNumber,false)
			DataMap:setPower(DataMap:getPower() + addNumber,false)
			PowerManger:setTimerCount(count)
			tempCount = PowerManger:getTimerCount()
			PowerManger:timerChangeCurPower()
			PowerManger:setLeftTime(leftTime) 
			UIMiddlePub:setPower()
			UIMiddlePub:setLoadingBar()
			return
		end
	end
	--cclog("倒计时进行中*************",runCount,tempCount,Utils:secToString(tempCount))
	local leftTime = Utils:secToString(tempCount)
	PowerManger:setLeftTime(leftTime)
	EventCenter:post(EventDef["ED_POWER_LEFT_TIME"], leftTime)
end

local function timer1_CF2(tm)
	PowerManger:setCurPower(PowerManger:getCurPower()+ 1)

	UIMiddlePub:setPower()
	UIMiddlePub:setLoadingBar()
	UIBuyPower:setPower()		--购买体力界面
	--抽奖界面时，更新体力
	ModelLottery:setCurRewardPower(PowerManger:getCurPower())
	cclog("走到这里来了*********timer1_CF2**",PowerManger:getCurPower())

	PowerManger:setLeftTime("00:00")
	PowerManger:setTimer()
	PowerManger:setTimerCount(G.POWER_RECOVER_TIME)
	tempCount = PowerManger:getTimerCount()
	PowerManger:timerChangeCurPower()
end

--改变当前体力
function PowerManger:timerChangeCurPower()
	if self.timer ~= nil then
		return
	end
	if PowerManger:getCurPower() < PowerManger:getMaxPower() then
		tempCount = PowerManger:getTimerCount()

		self.timer = CreateTimer(1, self.timerCount, timer1_CF1, timer1_CF2)
		self.timer:start()
		if self.timerCount == G.POWER_RECOVER_TIME then
			DataMap:setDate(STime:getClientTime())
		end
	end
end

--抽奖，根据抽取到的体力，判断要不要停止体力倒计时
function PowerManger:updateTimeByRewardPower()
	if PowerManger:getCurPower() >=  PowerManger:getMaxPower() then
		PowerManger:setTimer()					
		PowerManger:timerChangeCurPower()
		PowerManger:setLeftTime("00:00")
		EventCenter:post(EventDef["ED_POWER_LEFT_TIME"], "00:00")
		UIMiddlePub:setLoadingBar()
	else
		PowerManger:timerChangeCurPower()
	end
end

-- 添加体力倒计时通知
function PowerManger:pushNotify()
	local leftTime = self:getPowerFullLeftTime() or 0
	if leftTime <= 0 or DataMap:getPower() >= DataMap:getMaxPower() then	-- 体力已满
		return
	end
	local notifyMsgTable = {"NOTIFY_POWER_MSG_1", "NOTIFY_POWER_MSG_2", "NOTIFY_POWER_MSG_3", "NOTIFY_POWER_MSG_4"}
	local msgKey = CommonFunc:getRandom(notifyMsgTable)
	ChannelProxy:addNotify(1, 2, LanguageStr(msgKey), leftTime)
end

-- 移除体力倒计时通知
function PowerManger:popNotify()
	ChannelProxy:removeNotifyByKey(2)
end
