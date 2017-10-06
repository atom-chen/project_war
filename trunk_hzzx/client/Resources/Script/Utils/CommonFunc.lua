----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2013-11-29
-- Brief:	common functions
----------------------------------------------------------------------
math.randomseed(os.time())
CommonFunc = {}
----------------------------------------------------------------------
-- 变量是否为空
function isNil(variable)
	if nil == variable then
		return true
	elseif "userdata" == type(variable) then
		return tolua.isnull(variable)
	end
	return false
end
----------------------------------------------------------------------
-- 重新包含模块
function CommonFunc:reload(fileName)
	package.loaded[fileName] = nil
	require(fileName)
end
----------------------------------------------------------------------
-- 生成枚举类型,tb - {"aaaa", "bbbb", "cccc", ...},返回{"aaaa"=1, "bbbb"=2, "cccc"=3, ...}
function CommonFunc:enum(tb)
	local enum = {}
	for k, v in pairs(tb) do
		enum[v] = k
	end
	return enum
end
----------------------------------------------------------------------
-- 深度拷贝
function CommonFunc:clone(obj)
    local lookupTable = {}
    local function copyObj(obj)
        if "table" ~= type(obj) then
            return obj
        elseif lookupTable[obj] then
            return lookupTable[obj]
        end
        local newTable = {}
        lookupTable[obj] = newTable
        for key, value in pairs(obj) do
            newTable[copyObj(key)] = copyObj(value)
        end
        return setmetatable(newTable, getmetatable(obj))
    end
    return copyObj(obj)
end
----------------------------------------------------------------------
-- 分割字符串,str - 字符串,delimiter - 分隔符,numberType - 是否为数字类型
function CommonFunc:stringSplit(str, delimiter, numberType)
    if "string" ~= type(str) or '' == str or "" == str or "string" ~= type(delimiter) or '' == delimiter or "" == delimiter then
		return {str}
	end
	local arr = {}
	while true do
		local pos = string.find(str, delimiter)
		if (not pos) then
			if true == numberType then
				arr[#arr + 1] = tonumber(str)
			else
				arr[#arr + 1] = str
			end
			break
		end
		local value = string.sub(str, 1, pos - 1)
		if true == numberType then
			arr[#arr + 1] = tonumber(value)
		else
			arr[#arr + 1] = value
		end
		str = string.sub(str, pos + 1, #str)
	end
	return arr
end
----------------------------------------------------------------------
-- 检查单个字符占位数
function CommonFunc:characterPlaceholder(ch)
	local charsets = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	local i = #charsets
	while charsets[i] do
		if ch >= charsets[i] then
			return i
		end
		i = i - 1
	end
end
----------------------------------------------------------------------
-- 计算字符串的长度,总长度,单字节个数,多字节个数
function CommonFunc:stringLength(str)
	if "string" ~= type(str) or '' == str or "" == str then
		return 0
	end
	local totalCount, singleCount, multiCount = 0, 0, 0
	local startPos = 1
	while startPos <= string.len(str) do
		local placeholder = CommonFunc.characterPlaceholder(string.byte(str, startPos))
		startPos = startPos + placeholder
		if 1 == placeholder then	-- single byte character
			singleCount = singleCount + 1
		else						-- multibyte character
			multiCount = multiCount + 1
		end
		totalCount = totalCount + 1
	end
	return totalCount, singleCount, multiCount
end
----------------------------------------------------------------------
-- 概率值,percentage:百分比,如:0.02表示0.02%,返回:true,false
function CommonFunc:probability(percentage)
	assert("number" == type(percentage), "not support for "..type(percentage))
	assert(percentage >= 0 and percentage <= 1, "range of percentage is worng")
	local randomValue = math.random()
	return randomValue > 0 and randomValue <= percentage
end
----------------------------------------------------------------------
-- 从数组中随机获得一个数
function CommonFunc:getRandom(valueArray)
	assert("table" == type(valueArray), "not support for "..type(valueArray))
	local valueCount = #valueArray
	if 0 == valueCount then
		return nil
	end
	return valueArray[math.random(1, valueCount)]
end
----------------------------------------------------------------------
-- 四舍五入
function CommonFunc:mathRound(num)
    if "number" ~= type(num) then
		return 0
	end
	if num >= 0 then
		return math.floor(num + 0.5)
	end
	return math.floor(num - 0.5)
end
----------------------------------------------------------------------
-- 十进制数字转为二进制字符串格式,115转为"1110011"
function CommonFunc:decimalismToBinary(decimalism)
	local binary = ""
	local function innerFunc(val)
		local divisor = math.floor(val/2)
		local mod = val % 2
		binary = mod..binary
		if 0 == divisor then
			return binary
		end
		return innerFunc(divisor)
	end
	return innerFunc(math.floor(decimalism))
end
----------------------------------------------------------------------
-- 二进制字符串转为十进制数字,"1110011"转为115
function CommonFunc:binaryToDecimalism(binary)
	local decimalism = 0
	local length = string.len(binary)
	for i=1, length do
		local b = string.byte(binary, i) - 48
		decimalism = decimalism + b*(2^(length-i))
	end
	return decimalism
end
----------------------------------------------------------------------
-- 十六进制颜色值转为rgb格式,"#FF00FF"转为{r=255, g=0, b=255}
function CommonFunc:colorHexToRgb(colorHex)
	assert("string" == type(colorHex) and 7 == string.len(colorHex) and "#" == string.sub(colorHex, 1, 1), "colorHex = ["..colorHex.."] format error")
	local red = tonumber(string.sub(colorHex, 2, 3), 16)
	local green = tonumber(string.sub(colorHex, 4, 5), 16)
	local blue = tonumber(string.sub(colorHex, 6, 7), 16)
	assert(red and red <= 255 and green and green <= 255 and blue and blue <= 255, "colorHex = ["..colorHex.."] format error")
	return {r=red, g=green, b=blue}
end
----------------------------------------------------------------------
-- rgb格式转为十六进制颜色值,r=255, g=0, b=255转为"#FF00FF"
function CommonFunc:colorRgbToHex(r, g, b)
	assert("number" == type(r) and r >=0 and r <= 255 and "number" == type(g) and g >=0 and g <= 255 and "number" == type(b) and b >=0 and b <= 255, "r = ["..r.."], g = ["..g.."], b = ["..b.."] format error")
	local redHex = string.upper(string.format("%02x", r))
	local greenHex = string.upper(string.format("%02x", g))
	local blueHex = string.upper(string.format("%02x", b))
	return "#"..redHex..greenHex..blueHex
end
----------------------------------------------------------------------
-- 解析字符串元组格式,{{1,2,3},{4,5,6}}或{{"a","b","c"},{"d","e","f"}}
function CommonFunc:parseTuple(stringTuple, delimiter, numberType)
	local function removeLRBracket(str)
		local leftB, rightB, pos, count = 0, 0, 1, 0
		while pos <= string.len(str) do
			local ch = string.sub(str, pos, pos)
			if "{" == ch then
				count = count + 1
				if 0 == leftB then
					leftB = pos
				end
			elseif "}" == ch then
				count = count - 1
			end
			if 0 == count then
				rightB = pos
				break
			end
			pos = pos + 1
		end
		if 1 == leftB and string.len(str) == rightB then
			return string.sub(str, leftB + 1, rightB - 1), true
		end
		return str, false
	end
	local function innerParse(str, tuple, index)
		index = index or 1
		local tempStr, removeFlag = removeLRBracket(str)
		local tempTuple = nil
		if true == removeFlag then
			tuple[index] = {}
			tempTuple = tuple[index]
		else
			tempTuple = tuple
		end
		if nil == string.find(tempStr, delimiter) then
			if true == removeFlag then
				if true == numberType then
					table.insert(tempTuple, tonumber(tempStr))
				else
					table.insert(tempTuple, tempStr)
				end
			else
				if true == numberType then
					tempTuple[index] = tonumber(tempStr)
				else
					tempTuple[index] = tempStr
				end
			end
		else
			local blockTable, blockStr, startPos, left, right = {}, "", 1, 0, 0
			while startPos <= string.len(tempStr) do
				local character = string.sub(tempStr, startPos, startPos)
				startPos = startPos + 1
				if delimiter == character and left == right then
					table.insert(blockTable, blockStr)
					character, blockStr, left, right = "", "", 0, 0
				elseif "{" == character then
					left = left + 1
				elseif "}" == character then
					right = right + 1
				end
				blockStr = blockStr..character
			end
			assert(left == right, stringTuple.." format is error")
			table.insert(blockTable, blockStr)
			for key, val in pairs(blockTable) do
				innerParse(val, tempTuple, key)
			end
		end
	end
	local tupleTable = {}
	innerParse(stringTuple, tupleTable)
	return tupleTable
end
----------------------------------------------------------------------
-- 截取文件名,后缀名
function CommonFunc:stripFileName(fileName)
	assert("string" == type(fileName), "not support type "..type(fileName))
	local index = fileName:match(".+()%.%w+$")
	if nil == index then
		return fileName, ""
	end
	return fileName:sub(1, index - 1), fileName:sub(index, string.len(fileName))
end
----------------------------------------------------------------------
-- 读取文件内容
function CommonFunc:readFile(fileName)
	local file, errorMsg = io.open(fileName, "rb")
	if nil == file then
		return nil, errorMsg
	end
	local str = file:read("*all")
	file:close()
	return str, errorMsg
end
----------------------------------------------------------------------
-- 写入文件内容
function CommonFunc:writeFile(fileName, str)
	local file = assert(io.open(fileName, "wb"), "open or create file '"..fileName.."' error ...")
	if nil == file then
		return
	end
	file:write(str)
	file:close()
end
----------------------------------------------------------------------
-- 序列化数据
function CommonFunc:serialize(data)
	local serializeStr = ""
	local function innerSerialize(value)
		local valueType = type(value)
		if "nil" == valueType then
			serializeStr = serializeStr.."nil"
		elseif "boolean" == valueType then
			serializeStr = serializeStr..(value and "true" or "false")
		elseif "number" == valueType then
			serializeStr = serializeStr..value
		elseif "string" == valueType then
			serializeStr = serializeStr..string.format("%q", value)
		elseif "table" == valueType then
			serializeStr = serializeStr.."{"
			for k, v in pairs(value) do
				serializeStr = serializeStr.."["
				innerSerialize(k)
				serializeStr = serializeStr.."]="
				innerSerialize(v)
				serializeStr = serializeStr..","
			end
			serializeStr = serializeStr.."}"
		else
			assert(nil, "cannot support type "..valueType)
		end
	end
	innerSerialize(data)
	return serializeStr
end
----------------------------------------------------------------------
-- 反序列化数据
function CommonFunc:deserialize(str)
	local deserializeStr = "do local data = "..str.." return data end"
	local func = loadstring(deserializeStr)
	if "function" == type(func) then
		return func()
	end
	return nil
end
----------------------------------------------------------------------

