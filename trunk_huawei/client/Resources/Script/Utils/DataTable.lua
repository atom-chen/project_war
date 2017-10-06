----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-12
-- Brief: 数据表解析
----------------------------------------------------------------------
DataTable = {}
----------------------------------------------------------------------
-- 加载数据表,fileName - 文件名,返回{name - 文件名, map - 数据集(非线性), size - 数据量, fields - 每条数据字段数}
function DataTable:loadFile(fileName, needKeyField)
	assert(string.len(fileName) > 4, "DataTable -> load() -> "..fileName.." is invalid")
	local dataTB = nil
	local extName = string.sub(fileName, -3, -1)
	if "csv" == string.lower(extName) then
		dataTB = csv_load(fileName)
	elseif "xml" == string.lower(extName) then
		dataTB = xml_load(fileName)
	end
	assert(dataTB, "DataTable -> load() -> load file '"..fileName.."' failed")
	local function splitTypeAndName(value)
		local sp, ep = string.find(value, ":")
		if nil == sp or 1 == sp or nil == ep or string.len(value) == ep then
			return nil
		end
		return string.sub(value, 1, sp - 1), string.sub(value, ep + 1, string.len(value))
	end
	local tb = {name = fileName, map = {}, size = 0, fields = 0}
	for index, rowData in pairs(dataTB) do
		local key, data, fieldCount = nil, {}, 0
		for name, val in pairs(rowData) do
			fieldCount = fieldCount + 1
			local valueType, valueName = splitTypeAndName(name)
			if "key_number" == valueType then
				assert(nil == key, "DataTable -> load() -> exist two key field at index '"..index.."' in file '"..fileName.."'")
				key = tonumber(val)
				data[valueName] = key
			elseif "key_string" == valueType then
				assert(nil == key, "DataTable -> load() -> exist two key field at index '"..index.."' in file '"..fileName.."'")
				key = tostring(val)
				data[valueName] = key
			elseif "number" == valueType then
				data[valueName] = tonumber(val)
			elseif "string" == valueType then
				data[valueName] = tostring(val)
			elseif "list_number" == valueType then
				if "" == val or "nil" == val then
					data[valueName] = {}
				else
					data[valueName] = CommonFunc:stringSplit(val, "|", true)
				end
			elseif "list_string" == valueType then
				if "" == val or "nil" == val then
					data[valueName] = {}
				else
					data[valueName] = CommonFunc:stringSplit(val, "|", false)
				end
			elseif "tuple_number" == valueType then
				if "" == val or "nil" == val then
					data[valueName] = {}
				else
					data[valueName] = CommonFunc:parseTuple(val, "|", true)
				end
			elseif "tuple_string" == valueType then
				if "" == val or "nil" == val then
					data[valueName] = {}
				else
					data[valueName] = CommonFunc:parseTuple(val, "|", false)
				end
			else
				assert(nil, "DataTable -> load() -> key '"..name.."' is error format at index '"..index.."' in file '"..fileName.."'")
			end
		end
		if fieldCount > 0 and 0 == tb.fields then
			tb.fields = fieldCount
		end
		if fieldCount > 0 and fieldCount == tb.fields then
			if true == needKeyField then
				assert(nil ~= key, "DataTable -> load() -> key is error at index '"..index.."' in file '"..fileName.."', fields: "..tb.fields..", key: "..tostring(key))
			else
				key = index
			end
			assert(nil == tb.map[key], "DataTable -> load() -> key '"..key.."' is duplicate at index '"..index.."' in file '"..fileName.."'")
			tb.map[key] = data
			tb.size = tb.size + 1
		end
	end
	return tb
end
----------------------------------------------------------------------
-- 获取指定行数据,tb(table) - loadFile的返回值;key(number/string) - 键值;dumpNil(bool) - true(不允许查找不到结果),false或不填(允许查找不到结果)
function DataTable:getRow(tb, key, dumpNil)
	assert("number" == type(key) or "string" == type(key), "DataTable -> getRow() -> key '"..tostring(key).."' is error when  find in file '"..tb.name.."'")
	local rowData = tb.map[key]
	if nil == rowData then
		if true == dumpNil then
			assert(nil, "DataTable -> getRow() -> can't find key '"..key.."' in file '"..tb.name.."'")
		end
		return nil
	end
	return rowData
end
----------------------------------------------------------------------
-- 功  能：获取指定行数据,tb(table) - loadFile的返回值,condition(function) - 条件函数(返回值为布尔型)
function DataTable:getRowArray(tb, condition)
	assert("function" == type(condition), "DataTable -> getRowArray() -> condition is not function")
	local rowTB = {}
	for key, val in pairs(tb.map) do
		if true == condition(val) then
			table.insert(rowTB, val)
		end
	end
	return rowTB
end
----------------------------------------------------------------------