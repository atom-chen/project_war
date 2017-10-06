----------------------------------------------------------------------
-- Author:	jaron.ho
-- Date:	2014-05-30
-- Brief:	log functions
----------------------------------------------------------------------
function CreateLog()
	function printLocal(...)
		print(...)
	end
	function keyToText(key)
		if "string" == type(key) then
			return "[\""..key.."\"]"
		elseif "number" == type(key) then
			return "["..key.."]"
		else
			return "unknown -- not support key type "..type(key)
		end
	end
	function valueToText(value)
		if nil == value then
			return "nil"
		elseif "string" == type(value) then
			return "\""..value.."\""
		elseif "number" == type(value) then
			return value
		elseif "boolean" == type(value) then
			return tostring(value)
		else
			return "unknown -- not support value type "..type(value)
		end
	end
	function logTableKV(k, obj, tabCount, parentDic)
		local strOut = string.rep(' ', tabCount * 4)
		-- check if is table
		if "table" ~= type(obj) then
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
	function logOne(obj)
		if "table" == type(obj) then
			local parentDic = {}	-- record parent node
			parentDic[obj] = true
			printLocal("{")
			for key, value in pairs(obj) do
				logTableKV(key, value, 1, parentDic)
			end
			printLocal("}")
		elseif "string" == type(obj) then
			printLocal("\""..obj.."\"")
		elseif "number" == type(obj) then
			printLocal(obj)
		elseif "boolean" == type(obj) then
			printLocal(obj)
		else
			printLocal(type(obj))
		end
	end
	return function(...)
		printLocal("Log begin [[ ****************************************")
		for i, arg in pairs({...}) do
			logOne(arg)
		end
		printLocal("****************************************** ]] Log end")
	end
end
----------------------------------------------------------------------
Log = CreateLog()