----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 概率,根据权重
----------------------------------------------------------------------
math.randomseed(os.time())
-- create probability object,weightList:{{1,20},{2,60}},contains two random value: 1.value,20.weight;2.value,60.weight
function CreateProbability(weightList)
	assert("table" == type(weightList), "weightList is not table, it's type is "..type(weightList))
	-- private member variables
	local mValueList = {}
	local probability = {}
	-- public methods
	function probability:getValue()
		local count = #mValueList
		if 0 == count then
			return nil
		end
		return mValueList[math.random(1, count)]
	end
	-- initialize weight list
	for i, weightFactor in pairs(weightList) do
		local value, weight = weightFactor[1], weightFactor[2]
		for j=1, weight do
			table.insert(mValueList, value)
		end
	end
	-- wash weight list
	local count = #mValueList
	for i=1, count do
		local index = math.random(1, count)
		if index ~= i then
			local tempValue = mValueList[i]
			mValueList[i] = mValueList[index]
			mValueList[index] = tempValue
		end
	end
	return probability
end
----------------------------------------------------------------------
