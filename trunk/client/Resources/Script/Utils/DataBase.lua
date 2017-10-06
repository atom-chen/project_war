----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2013-11-29
-- Brief:	database for native
----------------------------------------------------------------------
-- read database string from file
local function readDB(fileName)
	local file, errorMsg = io.open(fileName, "rb")
	if nil == file then
		return nil, errorMsg
	end
	local str = file:read("*all")
	file:close()
	return str, errorMsg
end
----------------------------------------------------------------------
-- write database string to file
local function writeDB(fileName, str)
	local file = assert(io.open(fileName, "wb"), "open or create file \""..tostring(fileName).."\" error ...")
	if nil == file then
		return
	end
	file:write(str)
	file:close()
end
----------------------------------------------------------------------
-- serialize database to string
local function serializeDB(data)
	local serializeStr = ""
	local function innerSerialize(value, keyFlag)
		local valueType = type(value)
		if "nil" == valueType or "boolean" == valueType then
			assert(not keyFlag, "cannot support type: "..valueType..", value: "..tostring(value).." as key")
			serializeStr = serializeStr..tostring(value)
		elseif "number" == valueType then
			if keyFlag then
				serializeStr = serializeStr.."["..value.."]="
			else
				serializeStr = serializeStr..value
			end
		elseif "string" == valueType then
			if keyFlag then
				serializeStr = serializeStr.."[\""..value.."\"]="
			else
				serializeStr = serializeStr..string.format("%q", value)
			end
		elseif "table" == valueType then
			assert(not keyFlag, "cannot support type: "..valueType..", value: "..tostring(value).." as key")
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
----------------------------------------------------------------------
-- deserialize database from string
local function deserializeDB(str)
	local deserializeStr = "do local data = "..str.." return data end"
	local func = loadstring(deserializeStr)
	if "function" == type(func) then
		return func()
	end
	return nil
end
----------------------------------------------------------------------
-- depth copy data
local function cloneData(obj)
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
-- generate check value
local function generateCheckValue(data)
	local function checkCode(str)
		local strLength, total = string.len(str), 0
		for i=1, strLength do
			total = total + string.byte(str, i)
		end
		return strLength..total
	end
	local function innerFunc(value)
		local valueType = type(value)
		if "boolean" == valueType or "number" == valueType or "string" == valueType then
			return checkCode(tostring(value))
		elseif "table" == valueType then
			local checkValue = {}
			for key, val in pairs(value) do
				checkValue[key] = innerFunc(val)
			end
			return checkValue
		end
		return nil
	end
	return innerFunc(data)
end
----------------------------------------------------------------------
-- compare check value
local function isEqualCheckValue(checkValue1, checkValue2)
	local function innerFunc(check1, check2)
		local type1, type2 = type(check1), type(check2)
		if type1 ~= type2 then
			return false
		end
		if "table" == type1 and "table" == type2 then
			for key, val in pairs(check1) do
				if not innerFunc(val, check2[key]) then
					return false
				end
			end
			return true
		else
			return check1 == check2
		end
	end
	return innerFunc(checkValue1, checkValue2)
end
----------------------------------------------------------------------
-- create database object
function CreateDataBase(name, readFunc, writeFunc, cryptoFunc, target)
	assert("string" == type(name) and string.len(name) > 0, "data file name \""..tostring(name).."\" is error")
	-- private member variables
	local mDB = {}						-- database table
	local mCheck = nil					-- database check
	local mIsChange = false				-- is data change
	local database = {}
	-- public methods
	function database:save()
		if not mIsChange then
			return false
		end
		mIsChange = false
		local localString = serializeDB(mDB)
		local resultString = nil
		if "function" == type(cryptoFunc) then
			if "table" == type(target) or "userdata" == type(target) then
				resultString = cryptoFunc(target, true, localString) or localString
			else
				resultString = cryptoFunc(true, localString) or localString
			end
		end
		if "function" == type(writeFunc) then
			if "table" == type(target) or "userdata" == type(target) then
				writeFunc(target, name, resultString)
			else
				writeFunc(name, resultString)
			end
		else
			writeDB(name, resultString)
		end
		return true
	end
	function database:clear()
		mDB = {}
		mCheck = generateCheckValue(mDB)
		mIsChange = true
		self:save()
	end
	function database:set(key, value)
		assert("string" == type(key) and string.len(key) > 0, "key \""..tostring(key).."\" is error")
		assert("userdata" ~= type(value) and "function" ~= type(value), "value \""..tostring(value).."\" is error")
		mDB[key] = cloneData(value)
		mCheck[key] = generateCheckValue(value)
		mIsChange = true
	end
	function database:get(key)
		assert("string" == type(key) and string.len(key) > 0, "key \""..tostring(key).."\" is error")
		local value = mDB[key]
		local checkValue = generateCheckValue(value)
		if isEqualCheckValue(checkValue, mCheck[key]) then
			return cloneData(value)
		end
		assert(nil, "data is modified by third party plugin, key: "..key)
	end
	function database:getAll()
		return cloneData(mDB)
	end
	-- load database
	local localString = nil
	if "function" == type(readFunc) then
		if "table" == type(target) or "userdata" == type(target) then
			localString = readFunc(target, name)
		else
			localString = readFunc(name)
		end
	else
		localString, _ = readDB(name)
	end
	if nil == localString then
		database:clear()
	else
		local resultString = nil
		if "function" == type(cryptoFunc) then
			if "table" == type(target) or "userdata" == type(target) then
				resultString = cryptoFunc(target, false, localString) or localString
			else
				resultString = cryptoFunc(false, localString) or localString
			end
		end
		local localDB = deserializeDB(resultString)
		if "table" == type(localDB) then
			mDB = localDB
			mCheck = generateCheckValue(mDB)
		else
			database:clear()
		end
	end
	return database
end
----------------------------------------------------------------------

