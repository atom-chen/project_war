----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-05-30
-- Brief:	log functions
----------------------------------------------------------------------

local function printLocal(...)
	print(...)
end

local function keyToText(key)
	local keyType = type(key)
	if "string" == keyType then
		return "[\""..key.."\"]"
	elseif 'number' == keyType then
		return "["..key.."]"
	else
		return "unknown -- not support key type "..keyType
	end
end

local function valueToText(value)
	local valueType = type(value)
	if "string" == valueType then
		return "\""..value.."\""
	elseif "number" == valueType then
		return value
	elseif true == value then
		return "true"
	elseif false == value then
		return "false"
	else
		return "unknown -- not support value type "..valueType
	end
end
	
local function logTableKV(k, obj, tabCount, parentDic)
	local strOut = string.rep(' ', tabCount * 4)
	-- check if is table
	local objType = type(obj)
	if 'table' ~= objType then
		strOut = strOut..keyToText(k).." = "..valueToText(obj)..","
		printLocal(strOut)
		return
	end
	-- check if parent node exist endless loop
	if parentDic[obj] then
		strOut = strOut..keyToText(k).." = ".."unknown"..",".." -- can not printLocal parent table"
		printLocal(strOut)
		return
	end
	-- 
	parentDic[obj] = true		-- record parent node
	tabCount = tabCount + 1		-- tab count + 1
	printLocal(strOut..keyToText(k).." = ")
	printLocal(strOut.."{")
	for key, value in pairs(obj) do
		logTableKV(key, value, tabCount, parentDic)
	end
	printLocal(strOut.."},")
	parentDic[obj] = nil		-- remove record
end

local function logOne(obj)
	local objType = type(obj)
	if "table" == objType then
		local parentDic = {}	-- record parent node
		parentDic[obj] = true
		printLocal("{")
		for key, value in pairs(obj) do
			logTableKV(key, value, 1, parentDic)
		end
		printLocal("}")
	elseif "string" == objType then
		printLocal("\""..obj.."\"")
	elseif "number" == objType then
		printLocal(obj)
	elseif "boolean" == objType then
		printLocal(obj)
	else
		printLocal(objType)
	end
end

function Log(...)
	if not G.CONFIG["showlog"] then
		return
	end
	printLocal("Log begin [[ ****************************************")
	for i, arg in pairs({...}) do
		printLocal("****************************** arg["..i.."]")
		logOne(arg)
	end
	printLocal("**************************************** ]] Log end")
end

