----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-04-14
-- Brief:	timer
----------------------------------------------------------------------
local mTimerList = {}
----------------------------------------------------------------------
local function insertTimer(tm)
	table.insert(mTimerList, tm)
end
----------------------------------------------------------------------
local function removeTimer(tm)
	for key, val in pairs(mTimerList) do
		if tm == val then
			table.remove(mTimerList, key)
			break
		end
	end
end
----------------------------------------------------------------------
-- called every frame
function UpdateTimer()
	for key, val in pairs(mTimerList) do
		val:update()
	end
end
----------------------------------------------------------------------
-- clear timer list
function ClearTimer()
	mTimerList = {}
end
----------------------------------------------------------------------
-- create a timer
function CreateTimer(interval, count, runCF, overCF, target, param)
	-- private member variables
	local mTotalCount = count			-- number of intervals, if count <= 0, timer will repeat forever
	local mCurrentCount = 0				-- current interval count
	local mInterval = interval			-- interval duration in seconds
	local mStartTime = 0.0				-- start time for the current interval in seconds
	local mRunning = false				-- status of the timer
	local mIsPause = false				-- is timer paused
	local mRunCallFunc = runCF			-- called when current count changed
	local mOverCallFunc = overCF		-- called when timer is complete
	local mTarget = target				-- callback target
	local mParam = param				-- parameter
	local tm = {}
	-- public methods
	function tm:update()
		if false == mRunning then
			return
		end
		local currTime = os.clock()
		if true == mIsPause or currTime < mStartTime then
			mStartTime = currTime
			return
		end
		if mTotalCount <= 0 or mCurrentCount < mTotalCount then
			local deltaTime = math.abs(currTime - mStartTime)
			if deltaTime >= mInterval then
				local runCount = math.floor(deltaTime/mInterval)
				mCurrentCount = mCurrentCount + runCount
				mStartTime = currTime
				if "function" == type(mRunCallFunc) then
					if "table" == type(mTarget) or "userdata" == type(mTarget) then
						mRunCallFunc(mTarget, self, runCount)
					else
						mRunCallFunc(self, runCount)
					end
				end
			end
		else
			self:stop(true)
		end
	end
	function tm:start(executeFlag)
		if true == mRunning then
			return
		end
		mRunning = true
		mIsPause = false
		mCurrentCount = 0
		mStartTime = os.clock()
		if "function" == type(mRunCallFunc) and true == executeFlag then
			if "table" == type(mTarget) or "userdata" == type(mTarget) then
				mRunCallFunc(mTarget, self, 1)
			else
				mRunCallFunc(self, 1)
			end
		end
		insertTimer(self)
	end
	function tm:stop(executeFlag)
		if false == mRunning then
			return
		end
		mRunning = false
		mIsPause = true
		removeTimer(self)
		if "function" == type(mOverCallFunc) and true == executeFlag then
			if "table" == type(mTarget) or "userdata" == type(mTarget) then
				mOverCallFunc(mTarget, self)
			else
				mOverCallFunc(self)
			end
		end
	end
	function tm:resume()
		mIsPause = false
	end
	function tm:pause()
		mIsPause = true
	end
	function tm:getTotalCount() return mTotalCount end
	function tm:getCurrentCount() return mCurrentCount end
	function tm:isRunning() return mRunning end
	function tm:setParam(param) mParam = param end
	function tm:getParam() return mParam end
	return tm
end
----------------------------------------------------------------------
-- test code
--[[
local function timer1_CF1(tm, runCount)
	cclog("========== timer1 === param: "..tm:getParam().." === c: "..os.clock())
	tm:setParam("count_"..tm:getCurrentCount())
end
local function timer1_CF2(tm)
	cclog("========== timer1 is complete")
end
local timer1 = CreateTimer(1, 0, timer1_CF1, timer1_CF2)
timer1:setParam("hahaha")
timer1:start()
]]
----------------------------------------------------------------------