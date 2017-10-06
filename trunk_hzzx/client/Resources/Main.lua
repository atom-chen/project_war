----------------------------------------------------------------------
-- Author: jaron.ho
-- Date: 2014-12-4
-- Brief: entry for lua
----------------------------------------------------------------------
G = G or {}
G.PLATORM = cc.Application:getInstance():getTargetPlatform()	-- target platform type
G.DESIGN_WIDTH = 720											-- design resolution width
G.DESIGN_HEIGHT = 960											-- design resolution height
G.CONFIG = {}													-- json configuration table
----------------------------------------------------------------------
-- for CCLuaEngine traceback
local mTraceback = false
function __G__TRACKBACK__(msg)
	if true == mTraceback then
		return msg
	end
	mTraceback = true
	local errorMsgStart		= "----------------------------------------\n"
	local errorMsgContent	= "LUA ERROR:\n" .. tostring(msg) .. "\n"
	local errorMsgTraceback	= debug.traceback() .. "\n"
	local errorMsgEnd		= "----------------------------------------\n"
	print(errorMsgStart..errorMsgContent..errorMsgTraceback..errorMsgEnd)
	MessageBox(errorMsgStart..errorMsgContent..errorMsgTraceback..errorMsgEnd, "lua traceback")
    return msg
end
----------------------------------------------------------------------
-- cclog
function cclog(...)
	if G.CONFIG["showlog"] then
		print(...)
	end
end
----------------------------------------------------------------------
-- call global func
function globalcall(globalFunc)
	local status, msg = xpcall(globalFunc, __G__TRACKBACK__)
	return status, msg
end
----------------------------------------------------------------------
-- reload lua file
function reload(fileName)
	package.loaded[fileName] = nil
	return require(fileName)
end
----------------------------------------------------------------------
-- load json file
function loadJson(fileName)
	local configStr = cc.FileUtils:getInstance():getStringFromFile(fileName)
	return json.decode(configStr)
end
----------------------------------------------------------------------
-- start lua
globalcall(function()
	-- step1: set collect garbage
	collectgarbage("setpause", 200)
    collectgarbage("setstepmul", 2000)
	-- step2: set search paths
	local fixedPathArray = {"cocos", "Data", "Font", "Layout", "Map", "Particle", "Picture", "Script", "Shader", "Sound"}
	for i, fixedPath in pairs(fixedPathArray) do
		cc.FileUtils:getInstance():addSearchPath(fixedPath)
	end
	-- step3: require cocos and initialize director
	require("init")
	local director = cc.Director:getInstance()
	local glview = director:getOpenGLView()
	if nil == glview then
		local width, height = 0, 0
		if nil == width or width <= 0 then width = G.DESIGN_WIDTH end
		if nil == height or height <= 0 then height = G.DESIGN_HEIGHT end
		glview = cc.GLViewImpl:createWithRect("Client", cc.rect(0, 0, width, height))
		director:setOpenGLView(glview)
	end
	glview:setDesignResolutionSize(G.DESIGN_WIDTH, G.DESIGN_HEIGHT, cc.ResolutionPolicy.FIXED_HEIGHT)
	-- step4: set FPS. the default value is 1.0/60 if you don't call this
	director:setAnimationInterval(1.0/60)
	local function displayStats(display)
		director:setDisplayStats("boolean" == type(display) and display)
	end
	-- step5: run scene
	local gameScene = cc.Scene:create()
	if nil == director:getRunningScene() then
		director:runWithScene(gameScene)
	else
		director:replaceScene(gameScene)
	end
	-- ************************************************** step6: start logic call [[
	cc.FileUtils:getInstance():setPopupNotify(false)
	gameScene:runAction(cc.Sequence:create(cc.DelayTime:create(0.05), cc.CallFunc:create(function()
		-- set search paths
		local searchPathArray = {
			"Picture/Animation",
			"Picture/Copy",
			"Picture/Default",
			"Picture/Element",
			"Picture/Hero",
			"Picture/Monster",
			"Script/Core",
			"Script/EventDispatcher",
			"Script/Model",
			"Script/UILayer",
			"Script/Utils",
		}
		for i, searchPath in pairs(searchPathArray) do
			cc.FileUtils:getInstance():addSearchPath(searchPath)
		end
		-- app original version
		G.APPVERSION = cc.UserDefault:getInstance():getStringForKey("OriginalVersion")
		-- check run flow
		local function loadConfig()
			cc.FileUtils:getInstance():purgeCachedEntries()
			reload("ChannelProxy")
			local channelId = ChannelProxy:getChannelId()
			print("channel id: \""..tostring(channelId).."\"")
			G.CONFIG = loadJson("Config.json")[channelId]
			assert(G.CONFIG, "can't find config in Config.json for channel \""..tostring(channelId).."\"")
			G.CONFIG["native_info"] = cc.FileUtils:getInstance():getStringFromFile("NativeVersion.txt")
			displayStats(G.CONFIG["debug"])
			print("**************************************** config:")
			for key, val in pairs(G.CONFIG) do
				print("* ["..key.."] = "..tostring(val))
			end
			print("**************************************************")
		end
		loadConfig()
		ChannelProxy:login(function()
			local doUpdate = false
			if cc.PLATFORM_OS_ANDROID == G.PLATORM or cc.PLATFORM_OS_IPHONE == G.PLATORM or cc.PLATFORM_OS_IPAD == G.PLATORM then
				doUpdate = true
			end
			require("AutoUpdate")
			AutoUpdate_start(doUpdate, function()
				loadConfig()
				require("Game")
				Game:init()
			end)
		end)
	end)))
	-- ************************************************** ]] end logic call
end)
----------------------------------------------------------------------