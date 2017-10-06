----------------------------------------------------------------------
-- Author: Lihq
-- Date: 2015-04-24
-- Brief: 两小时内不耗费体力管理器
----------------------------------------------------------------------
FreePowerManger = {}

local tempCount = 0		
local continueHour = 60*60*2   --10			--60*60*2  --(两小时)

--判断离线时”不耗费体力“是否已经结束,获得剩余的次数
function FreePowerManger:getLeftCount()
	local lastSec = DataMap:getFreePowerStartDate()
	local nowSec =  STime:getClientTime()
	local temp = nowSec - lastSec		--两小时已经走过的秒数
	if temp > continueHour or lastSec == "0" then			--倒计时结束
		return 0
	else								--两小时还有剩余
		return continueHour - temp
	end
end

--体力初始化
function FreePowerManger:init()
	self.timerCount = FreePowerManger:getLeftCount()		--两小时倒计时剩余时间
	tempCount = self.timerCount
	if self.timerCount == 0 then
		self.mLeftTime = "00:00"							--两小时剩余的秒数
	else
		self.mLeftTime =Utils:secToString(self.timerCount)
		self:timerChangeStart()
	end
end

--获得体力的倒计时时间
function FreePowerManger:getLeftTime()
	return self.mLeftTime 
end

--设置体力的倒计时时间
function FreePowerManger:setLeftTime(times)
	self.mLeftTime = times
end

----------------------------------------------------体力倒计时------------------------------------------------------
--获得当前定时器次数
function FreePowerManger:getTimerCount()
	return self.timerCount
end

--设置当前定时器次数
function FreePowerManger:setTimerCount(count)
	self.timerCount = count
end

--获得当前定时器
function FreePowerManger:getTimer()
	return self.timer
end

--设置当前定时器
function FreePowerManger:setTimer()
	if self.timer ~= nil then
		self.timer:stop()
	end
	self.timer = nil
end

--倒计时进行中
local function timer1_CF1(tm, runCount)
	if runCount == 1 and tempCount > 0 then
		--cclog("正常运行**************",tempCount)
		tempCount = tempCount - 1
	elseif runCount > 1 and tempCount > 0 then	--进入后台再进入前台，要把原有的定时器停止掉
		--cclog("进入后台的运行时间**********",tempCount,runCount)
		
		local count = tempCount			--表示进入后台再进入前台，还剩多少秒
		if runCount >= tempCount then
			count = 0
		else
			count = tempCount - runCount
		end
		
		FreePowerManger:setTimer()
		FreePowerManger:setTimerCount(count)
		tempCount = count
			
		if count == 0 then
			FreePowerManger:setLeftTime("00:00:00")
			EventDispatcher:post(EventDef["ED_FREE_POWER"], "00:00")
			EventDispatcher:post(EventDef["ED_FREE_POWER_end"])
			CopyModel:setCostHp()
			return
		else
			FreePowerManger:setLeftTime(Utils:secToString(count))
			EventDispatcher:post(EventDef["ED_FREE_POWER"], Utils:secToString(count))
			FreePowerManger:timerChangeStart()
			return
		end
	end
	--cclog("倒计时进行中*************",runCount,tempCount,Utils:secToString(tempCount))
	--设置两小时免费体力剩余时间（中间界面）
	local leftTime = Utils:secToString(tempCount)
	FreePowerManger:setLeftTime(leftTime)
	EventDispatcher:post(EventDef["ED_FREE_POWER"], leftTime)
end

--倒计时结束
local function timer1_CF2(tm)
	--设置所有用到体力值得地方和体力数据源（copyModel）
	CopyModel:setCostHp()
	FreePowerManger:setTimer()
	FreePowerManger:setLeftTime("00:00")
	EventDispatcher:post(EventDef["ED_FREE_POWER"], "00:00")
	EventDispatcher:post(EventDef["ED_FREE_POWER_end"])
end

--开始2小时免费体力倒计时
function FreePowerManger:timerChangeStart()
	print("FreePowerManger:timerChangeStart()*********",self.timerCount,self.timer)
	if nil ~= self.timer then
		self:setTimer()
		FreePowerManger:setTimerCount(continueHour)	
		
		print("***55555555************",self.timerCount,continueHour)
	end
	if 0 == self.timerCount then
		FreePowerManger:setTimerCount(continueHour)	
		print("***66666666************",self.timerCount,continueHour)
	end
	tempCount =  self.timerCount
	self.timer = CreateTimer(1, self.timerCount, timer1_CF1, timer1_CF2)
	self.timer:start()
	
	print("***4444444************",self.timerCount)
end




