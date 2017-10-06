#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "lua_module_register.h"
#include "applet/lua_applet.h"
#include "applet/lua_resource.h"

using namespace CocosDenshion;

USING_NS_CC;
using namespace std;

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
    SimpleAudioEngine::end();
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching()
{
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

    // If you want to use Quick-Cocos2d-X, please uncomment below code
    // register_all_quick_manual(L);

	const char* ORIGIN_VERSION = "OriginVersion";
	const char* NATIVE_VERSION = "NativeVersion.txt";
	const char* NATIVE_FILELIST = "NativeFileList.txt";
	std::string resourceDir = FileUtils::getInstance()->getWritablePath() + "resdir/";
	// step1:clear garbage data cache
	std::string nativeVersionStr = FileUtils::getInstance()->getStringFromFile(NATIVE_VERSION);
	if (nativeVersionStr != UserDefault::getInstance()->getStringForKey(ORIGIN_VERSION)) {
		UserDefault::getInstance()->setStringForKey(ORIGIN_VERSION, nativeVersionStr);
		FileUtils::getInstance()->removeDirectory(resourceDir);
	}
	// step2:set first search path
	FileUtils::getInstance()->createDirectory(resourceDir);
	std::vector<std::string> searchPaths = FileUtils::getInstance()->getSearchPaths();
	searchPaths.insert(searchPaths.begin(), resourceDir);
	FileUtils::getInstance()->setSearchPaths(searchPaths);
	// step3:register lua module
	lua_applet_register(L);
	lua_resdownload_register(L, resourceDir);
	if (!FileUtils::getInstance()->isFileExist(resourceDir + NATIVE_VERSION)) {
		ResourceUpdate::writeDataToFile(nativeVersionStr.c_str(), nativeVersionStr.size(), resourceDir + NATIVE_VERSION);
	}
	if (!FileUtils::getInstance()->isFileExist(resourceDir + NATIVE_FILELIST)) {
		std::string nativeFileListStr = FileUtils::getInstance()->getStringFromFile(NATIVE_FILELIST);
		ResourceUpdate::writeDataToFile(nativeFileListStr.c_str(), nativeFileListStr.size(), resourceDir + NATIVE_FILELIST);
	}
	lua_resupdate_register(L, resourceDir, NATIVE_VERSION, NATIVE_FILELIST);
	// step4:set xxtea key and sign
	const char* key = "m~;(v(9/3|q4Hrh0YZgDo^GLt2A9I[*go`cmquW[D04p|~`B2#!dfZR83{9o7M9|ICC-hSt47ABav?`KuC*2g6Z093*W48T~Zm2we>C81T}uI[6}:222Vi4n&6$8ZND3pe6>}uC+-VOK8_9Yn6<BXY#Hb27GO3NCL8&gHbD2eK5vRZM^,c?0og4&zZMe,UNP1f3T38597gfco994jaU53(TF/[g0~w8+38|cg4Z8,Z751v'b}7*c74iK?ZwH3>6|";
	const char* sign = "onekes";
	LuaEngine::getInstance()->getLuaStack()->setXXTEAKeyAndSign(key, strlen(key), sign, strlen(sign));
	// step5:start lua
    if (LuaEngine::getInstance()->executeScriptFile("Main.lua")) {
        return false;
    }
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    //SimpleAudioEngine::getInstance()->pauseBackgroundMusic();
	LuaEngine::getInstance()->executeGlobalFunction("applicationDidEnterBackground");
}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    //SimpleAudioEngine::getInstance()->resumeBackgroundMusic();
	LuaEngine::getInstance()->executeGlobalFunction("applicationWillEnterForeground");
}
