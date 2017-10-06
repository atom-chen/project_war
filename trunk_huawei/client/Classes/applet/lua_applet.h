/**********************************************************************
* Author:	jaron.ho
* Date:		2014-12-11
* Brief:	applet interface for lua
**********************************************************************/
#ifndef _LUA_APPLET_H_
#define _LUA_APPLET_H_

#ifdef __cplusplus
extern "C"
{
#endif

#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"

// lua call c++ interface
int lua_md5_value(lua_State* L);
int lua_packet_encode(lua_State* L);
int lua_packet_decode(lua_State* L);
int lua_rc4_crypto(lua_State* L);
int lua_stringfilter_load(lua_State* L);
int lua_stringfilter_shield(lua_State* L);
int lua_system_gettime(lua_State* L);
int lua_system_swab32_int(lua_State *L);
int lua_system_swab32_string(lua_State *L);
int lua_system_int64_to_string(lua_State *L);
int lua_message_box(lua_State* L);

static int lua_applet_register(lua_State* L)
{
	lua_register(L, "md5_value",				lua_md5_value);
	lua_register(L, "packet_encode",			lua_packet_encode);
	lua_register(L, "packet_decode",			lua_packet_decode);
	lua_register(L, "rc4_crypto",				lua_rc4_crypto);
	lua_register(L, "stringfilter_load",		lua_stringfilter_load);
	lua_register(L, "stringfilter_shield",		lua_stringfilter_shield);
	lua_register(L, "system_gettime",			lua_system_gettime);
	lua_register(L, "system_swab32_int",		lua_system_swab32_int);
	lua_register(L, "system_swab32_string",		lua_system_swab32_string);
	lua_register(L, "system_int64_to_string",	lua_system_int64_to_string);
	lua_register(L, "MessageBox",				lua_message_box);
	return 1;
}

#ifdef __cplusplus
}
#endif

#endif	// _LUA_APPLET_H_
