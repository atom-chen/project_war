-- 字符串分割
local function stringSplit(str, delimiter, numberType)
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
-- 解析元组
local function parseTuple(stringTuple, delimiter, numberType)
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
			for key, value in pairs(blockTable) do
				innerParse(value, tempTuple, key)
			end
		end
	end
	local tupleTable = {}
	innerParse(stringTuple, tupleTable)
	return tupleTable
end
-- 序列化数据
local function serialize(data)
	local serializeStr = ""
	local function innerSerialize(value, keyFlag)
		local valueType = type(value)
		if "nil" == valueType or "boolean" == valueType then
			serializeStr = serializeStr..tostring(value)
		elseif "number" == valueType then
			if not keyFlag then
				serializeStr = serializeStr..value
			end
		elseif "string" == valueType then
			if keyFlag then
				serializeStr = serializeStr..value.."="
			else
				serializeStr = serializeStr..string.format("%q", value)
			end
		elseif "table" == valueType then
			serializeStr = serializeStr.."{"
			local index = 0
			for k, v in pairs(value) do
				index = index + 1
				serializeStr = serializeStr..(index > 1 and "," or "")
				innerSerialize(k, true)
				innerSerialize(v, false)
			end
			serializeStr = serializeStr.."}"
		else
			assert(nil, "cannot support type: "..valueType..", value: "..tostring(value))
		end
	end
	innerSerialize(data, false)
	return serializeStr
end
-- 写文件
local function writeFile(fileName, str)
	local file = assert(io.open(fileName, "wb"), "open or create file '"..fileName.."' error ...")
	if nil == file then
		return
	end
	file:write(str)
	file:close()
end
-- 分割字段类型和名称
local function splitTypeAndName(field)
	local sp, ep = string.find(field, ":")
	if nil == sp or 1 == sp or nil == ep or string.len(field) == ep then
		return nil
	end
	return string.sub(field, 1, sp - 1), string.sub(field, ep + 1, string.len(field))
end
-- 解析csv
local function parseCSV(fullFileName)
	local dataTable = dofile(fullFileName)
	assert("table" == type(dataTable), "file "..fullFileName.." is not table format")
	local fieldTable = dataTable[1]
	assert("table" == type(fieldTable), "file "..fullFileName.." field is error")
	local fieldCount, keyTable, row, dataStr = #fieldTable, {}, 0, "return{"
	for index=2, #dataTable do
		local valueTable = dataTable[index]
		if fieldCount == #valueTable then
			row = row + 1
			local key, data = nil, {}
			for i=1, fieldCount do
				local field, value = fieldTable[i], valueTable[i]
				local fieldType, fieldName = splitTypeAndName(field)
				if nil ~= tonumber(fieldName) then
					fieldName = tonumber(fieldName)
				end
				if "key_number" == fieldType then
					assert(nil == key, "file "..fullFileName.." exist two key field at index "..index)
					key = tonumber(value)
					data[fieldName] = key
				elseif "key_string" == fieldType then
					assert(nil == key, "file "..fullFileName.." exist two key field at index "..index)
					key = tostring(value)
					data[fieldName] = key
				elseif "number" == fieldType then
					data[fieldName] = tonumber(value)
				elseif "string" == fieldType then
					data[fieldName] = tostring(value)
				elseif "list_number" == fieldType then
					if "" == value or "nil" == value then
						data[fieldName] = {}
					else
						data[fieldName] = stringSplit(value, "|", true)
					end
				elseif "list_string" == fieldType then
					if "" == value or "nil" == value then
						data[fieldName] = {}
					else
						data[fieldName] = stringSplit(value, "|", false)
					end
				elseif "tuple_number" == fieldType then
					if "" == value or "nil" == value then
						data[fieldName] = {}
					else
						data[fieldName] = parseTuple(value, "|", true)
					end
				elseif "tuple_string" == fieldType then
					if "" == value or "nil" == value then
						data[fieldName] = {}
					else
						data[fieldName] = parseTuple(value, "|", false)
					end
				else
					assert(false, "file "..fullFileName.." field name \""..tostring(fieldName).."\" is error format")
				end
			end
			if nil == key then
				key = row
			end
			assert(not keyTable[key], "file "..fullFileName.." key "..key.." is duplicate at index "..index)
			keyTable[key] = true
			if row > 1 then
				dataStr = dataStr..","
			end
			dataStr = dataStr.."\n["..key.."]="..serialize(data)
		else
			print("Warning: file "..fullFileName.." value is error at index "..index)
		end
	end
	dataStr = dataStr.."\n}"
	writeFile(fullFileName, dataStr)
end
-- 解析xml
local function parseXML(fullFileName)
	local dataTable = dofile(fullFileName)
	assert("table" == type(dataTable), "file "..fullFileName.." is not table format")
	local keyTable, row, dataStr = {}, 0, "return{"
	for index=1, #dataTable do
		local valueTable = dataTable[index]
		row = row + 1
		local key, data = nil, {}
		for field, value in pairs(valueTable) do
			local fieldType, fieldName = splitTypeAndName(field)
			if nil ~= tonumber(fieldName) then
				fieldName = tonumber(fieldName)
			end
			if "key_number" == fieldType then
				assert(nil == key, "file "..fullFileName.." exist two key field at index "..index)
				key = tonumber(value)
				data[fieldName] = key
			elseif "key_string" == fieldType then
				assert(nil == key, "file "..fullFileName.." exist two key field at index "..index)
				key = tostring(value)
				data[fieldName] = key
			elseif "number" == fieldType then
				data[fieldName] = tonumber(value)
			elseif "string" == fieldType then
				data[fieldName] = tostring(value)
			elseif "list_number" == fieldType then
				if "" == value or "nil" == value then
					data[fieldName] = {}
				else
					data[fieldName] = stringSplit(value, "|", true)
				end
			elseif "list_string" == fieldType then
				if "" == value or "nil" == value then
					data[fieldName] = {}
				else
					data[fieldName] = stringSplit(value, "|", false)
				end
			elseif "tuple_number" == fieldType then
				if "" == value or "nil" == value then
					data[fieldName] = {}
				else
					data[fieldName] = parseTuple(value, "|", true)
				end
			elseif "tuple_string" == fieldType then
				if "" == value or "nil" == value then
					data[fieldName] = {}
				else
					data[fieldName] = parseTuple(value, "|", false)
				end
			else
				assert(false, "file "..fullFileName.." field name \""..tostring(fieldName).."\" is error format")
			end
		end
		if nil == key then
			key = row
		end
		assert(not keyTable[key], "file "..fullFileName.." key "..key.." is duplicate at index "..index)
		keyTable[key] = true
		if row > 1 then
			dataStr = dataStr..","
		end
		dataStr = dataStr.."\n["..key.."]="..serialize(data)
	end
	dataStr = dataStr.."\n}"
	writeFile(fullFileName, dataStr)
end
-- 遍历指定路径下的文件
local function traverseFile(path)
	local fileNameTable = {}
	for fullFileName in io.popen("dir "..path.." /b/s"):lines() do
		table.insert(fileNameTable, fullFileName)
	end
	return fileNameTable
end
-- 运行
local function run(path, fileType)
	assert("string" == type(path) and string.len(path) > 0, "path must be string and exist")
	local tb = traverseFile(path.."\\*.lua")
	for key, fullFileName in pairs(tb) do
		if "csv" == fileType then
			parseCSV(fullFileName)
		elseif "xml" == fileType then
			parseXML(fullFileName)
		end
	end
end
return run