LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE := cocos2dlua_shared

LOCAL_MODULE_FILENAME := libcocos2dlua

LOCAL_SRC_FILES := client/main.cpp \
                   ../../Classes/AppDelegate.cpp \
                   ../../Classes/applet/lua_applet.cpp \
				   ../../Classes/applet/lua_resource.cpp \
				   ../../Classes/applet/AutoUpdate/CURLEx.cpp \
				   ../../Classes/applet/AutoUpdate/FileDownload.cpp \
				   ../../Classes/applet/AutoUpdate/HttpClient.cpp \
				   ../../Classes/applet/AutoUpdate/ResourceUpdate.cpp \
                   ../../Classes/applet/MD5/MD5.cpp \
                   ../../Classes/applet/PacketCrypto/PacketCrypto.c \
                   ../../Classes/applet/RC4/RC4.c \
                   ../../Classes/applet/StringFilter/StringFilter.cpp \
                   ../../Classes/applet/StringFilter/Trie.cpp \
                   ../../Classes/applet/StringFilter/TrieNode.cpp \
                   ../../Classes/applet/System/System.cpp


LOCAL_C_INCLUDES := $(LOCAL_PATH)/../../Classes
					
LOCAL_STATIC_LIBRARIES := cocos2d_lua_static

include $(BUILD_SHARED_LIBRARY)

$(call import-module,scripting/lua-bindings/proj.android)
