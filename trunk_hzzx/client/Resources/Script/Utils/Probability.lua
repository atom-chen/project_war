----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-23
-- Brief: 概率,根据权重
----------------------------------------------------------------------
math.randomseed(os.time())
Probability = class("Probability")

-- 构造函数,weightList:权重列表,格式:{{1,20},{2,60}},两个随机数,第1个随机数值1,权重值20,第2个随机数值2,权重值60
function Probability:ctor(weightList)
	assert("table" == type(weightList), "weightList is not table, it's type is "..type(weightList))
	if 0 == #weightList then return end
	assert("table" == type(weightList[1]), "weightList format is error")
	self.mValueList = {}
	for i, weightFactor in pairs(weightList) do
		local value, weight = weightFactor[1], weightFactor[2]
		for j=1, weight do
			table.insert(self.mValueList, value)
		end
	end
	-- 洗牌
	local count = #self.mValueList
	for i=1, count do
		local index = math.random(1, count)
		if index ~= i then
			local tempValue = self.mValueList[i]
			self.mValueList[i] = self.mValueList[index]
			self.mValueList[index] = tempValue
		end
	end
end

-- 获取随机值
function Probability:getValue()
	local count = #self.mValueList
	if 0 == count then
		return nil
	end
	return self.mValueList[math.random(1, count)]
end

