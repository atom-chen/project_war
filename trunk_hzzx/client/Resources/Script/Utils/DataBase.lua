----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2013-11-29
-- Brief:	data base for native
----------------------------------------------------------------------
-- read data base string from file
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
-- write data base string to file
local function writeDB(fileName, str)
	local file = assert(io.open(fileName, "wb"), "open or create file \""..tostring(fileName).."\" error ...")
	if nil == file then
		return
	end
	file:write(str)
	file:close()
end
----------------------------------------------------------------------
-- serialize data base to string
local function serializeDB(data)
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
-- deserialize data base from string
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
-- create data base object
function CreateDataBase(fileName, cryptoFunc)
	assert("string" == type(fileName) and string.len(fileName) > 0, "data file name \""..tostring(fileName).."\" is error")
	-- private member variables
	local mDB = {}						-- data base table
	local mCheck = nil					-- data base check
	local mIsChange = false				-- is data change
	local database = {}
	-- public methods
	function database:save()
		if not mIsChange then
			return false
		end
		mIsChange = false
		local str = serializeDB(mDB)
		if "function" == type(cryptoFunc) then
			str = cryptoFunc(str) or str
		end
		writeDB(fileName, str)
		return true
	end
	function database:clear()
		mDB = {}
		mCheck = generateCheckValue(mDB)
		mIsChange = true
		self:save()
	end
	function database:setUserInfo(key, value)
		assert("string" == type(key) and string.len(key) > 0, "key \""..tostring(key).."\" is error")
		assert("userdata" ~= type(value) and "function" ~= type(value), "value \""..tostring(value).."\" is error")
		mDB[key] = cloneData(value)
		mCheck[key] = generateCheckValue(value)
		mIsChange = true
	end
	function database:getUserInfo(key)
		assert("string" == type(key) and string.len(key) > 0, "key \""..tostring(key).."\" is error")
		local userInfo = mDB[key]
		local checkValue = generateCheckValue(userInfo)
		if isEqualCheckValue(checkValue, mCheck[key]) then
			return cloneData(userInfo)
		end
		assert(nil, "data is modified by third party plugin, key: "..key..", userInfo: "..tostring(userInfo))
	end
	-- load data base
	local str, errorMsg = readDB(fileName)
	if nil == str then
		database:clear()
	else
		if "function" == type(cryptoFunc) then
			str = cryptoFunc(str) or str
		end
		local localDB = deserializeDB(str)
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
