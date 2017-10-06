----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-04-14
-- Brief:	system time
----------------------------------------------------------------------
STime = {}
----------------------------------------------------------------------
-- 时间转日期:参数,整数(秒);返回值,{year, month[1-12], day[1-31], yday, wday[1,7], hour[1-23], min[0-59], sec[0-60], isdst}
function STime:timeToDate(osTime)
	local osDate = os.date("*t", osTime)
	osDate.wday = osDate.wday - 1
	if 0 == osDate.wday then
		osDate.wday = 7
	end
	return osDate
end
----------------------------------------------------------------------
-- 日期转时间:参数,{year, month, day, hour, min|minute, sec|second}
function STime:dateToTime(osDate)
	local hour = osDate.hour or 0
	local minute = osDate.min or osDate.minute or 0
	local second = osDate.sec or osDate.second or 0
	return os.time{year=osDate.year, month=osDate.month, day=osDate.day, hour=hour, min=minute, sec=second}
end
----------------------------------------------------------------------
-- 获取指定日期所在周
function STime:getWeekDate(year, month, day)
	local specTime = self:dateToTime({year=year, month=month, day=day})
	local specDate = self:timeToDate(specTime)
	local weekDateTable = {}
	for i=1, 7 do
		local dateDiff = i - specDate.wday
		local timeDiff = dateDiff * 24 * 3600
		table.insert(weekDateTable, self:timeToDate(specTime + timeDiff))
	end
	return weekDateTable
end
----------------------------------------------------------------------
-- 获取某年某月的天数
function STime:getMonthDays(year, month)
	local time1 = self:dateToTime({year=year, month=month, day=1})
	local nextYear, nextMonth = year, month + 1
	if nextMonth > 12 then
		nextYear = year + 1
		nextMonth = 1
	end
	local time2 = self:dateToTime({year=nextYear, month=nextMonth, day=1})
	return math.floor((time2 - time1)/(24*3600))
end
----------------------------------------------------------------------
-- 获取客户端时间
function STime:getClientTime()
	return os.time()
end
----------------------------------------------------------------------
-- 获取客户端日期
function STime:getClientDate()
	return self:timeToDate(self:getClientTime())
end
----------------------------------------------------------------------
-- 判断是否到期
function STime:isEnd(endTime)
	return (self:dateToTime(self:getClientDate()) - self:dateToTime(endTime)) > 0
end
----------------------------------------------------------------------
-- 创建每日定时器
function STime:createDailyTimer(hour, minute, second, callback)
	assert("number" == type(hour) and "number" == type(minute) and "number" == type(second) and "function" == type(callback))
	local function create(hour, minute, second, callback)
		local function dailyCF(tm)
			callback()
			create(hour, minute, second, callback)
		end
		local st = self:getClientDate()
		local tm = {year=st.year, month=st.month, day=st.day, hour=hour, min=minute, sec=second}
		local remainTimes = self:dateToTime(tm) - self:dateToTime(st)
		if remainTimes < 0 then
			tm = {year=st.year, month=st.month, day=st.day, hour=24, min=0, sec=0}
			remainTimes = self:dateToTime(tm) - self:dateToTime(st) + (hour * 3600 + minute * 60 + second)
		end
		local dailyTimer = CreateTimer(1, math.abs(remainTimes), nil, dailyCF)
		dailyTimer:start()
		return dailyTimer
	end
	return create(hour, minute, second, callback)
end
----------------------------------------------------------------------
-- 创建指定日期定时器
function STime:createDateTimer(year, month, day, hour, minute, second, callback)
	local specTime = self:dateToTime({year=year, month=month, day=day, hour=hour, min=minute, sec=second})
	local currTime = self:getClientTime()
	local remainTimes = specTime - currTime
	if remainTimes <= 0 then
		return
	end
	local dateTimer = CreateTimer(1, remainTimes, nil, function(tm) callback() end)
	dateTimer:start()
	return dateTimer
end
----------------------------------------------------------------------


