/**********************************************************************
* Author:	jaron.ho
* Date:		2014-12-11
* Brief:	applet interface for lua
**********************************************************************/
#include <memory.h>
#include <stdlib.h>
#include "lua_applet.h"
#include "cocos2d.h"

//--------------------------------------------------------------------
// md5
//--------------------------------------------------------------------
#include "MD5/MD5.h"

int lua_md5_value(lua_State* L)
{
	const char* data = (char*)luaL_checkstring(L, 1);
	if (NULL == data)
		return 0;

	unsigned int dataSize = strlen(data);
	char* str = MD5_sign((unsigned char*)data, dataSize);
	lua_pushstring(L, str);
	return 1;
}

//--------------------------------------------------------------------
// packet crypto
//--------------------------------------------------------------------
#include "PacketCrypto/PacketCrypto.h"

#define XOR_KEY		0x2FDB3CED
#define SHIFT_KEY	0xAFD33C8D

int lua_packet_encode(lua_State* L)
{
	const char* data = (char*)luaL_checkstring(L, 1);
	if (NULL == data)
		return 0;

	unsigned int dataSize = strlen(data);
	unsigned int destSize = 0;
	static unsigned char packetEncodeCount = 0;
	char* dest = PacketCryptoEncode(data, dataSize, &destSize, XOR_KEY, SHIFT_KEY, ++packetEncodeCount);
	if (NULL == dest)
	{
		lua_pushstring(L, "");
	}
	else
	{
		lua_pushlstring(L, dest, destSize);
		free(dest);
		dest = NULL;
	}
	return 1;
}

int lua_packet_decode(lua_State* L)
{
	const char* p = (char*)luaL_checkstring(L, 1);
	if (NULL == p)
		return 0;

	unsigned int dataSize = strlen(p);
	char* data = (char*)malloc((dataSize + 1)*sizeof(char));
	memset(data, 0, dataSize + 1);
	memcpy(data, p, dataSize);
	unsigned int destSize = 0;
	unsigned char packet_encode_count = 0;
	char* dest = PacketCryptoDecode(data, dataSize, &destSize, XOR_KEY, SHIFT_KEY, &packet_encode_count);
	if (NULL == dest)
	{
		lua_pushstring(L, "");
	}
	else
	{
		lua_pushlstring(L, dest, destSize);
		free(dest);
		dest = NULL;
	}
	if (data)
	{
		free(data);
		data = NULL;
	}
	return 1;
}

//--------------------------------------------------------------------
// rc4
//--------------------------------------------------------------------
#include "RC4/RC4.h"

int lua_rc4_crypto(lua_State* L)
{
	const char* data = (char*)luaL_checkstring(L, 1);
	const char* key = (char*)luaL_checkstring(L, 2);

	if (NULL == data)
		return 0;

	if (NULL == key)
	{
		lua_pushstring(L, data);
		return 1;
	}

	unsigned int dataSize = strlen(data);
	char* input = (char*)malloc((dataSize + 1)*sizeof(char));
	memset(input, 0, dataSize + 1);
	memcpy(input, data, dataSize);
	rc4_crypto((unsigned char*)input, dataSize, (unsigned char*)key);
	lua_pushstring(L, input);
	free(input);
	input = NULL;
	return 1;
}

//--------------------------------------------------------------------
// string filter
//--------------------------------------------------------------------
#include "StringFilter/StringFilter.h"

static StringFilter s_string_filter;

int lua_stringfilter_load(lua_State* L)
{
	char errorBuf[256] = {0};
	const char* filename = (char*)luaL_checkstring(L, 1);
	if (NULL == filename)
	{
		sprintf(errorBuf, "error in function 'stringfilter_load', arg1 is not string");
		return 0;
	}
	std::string content = cocos2d::FileUtils::getInstance()->getStringFromFile(filename);
	if (content.empty())
	{
		sprintf(errorBuf, "error in function 'stringfilter_load', file %s is empty", filename);
		return 0;
	}
	bool res = s_string_filter.parse(content.c_str());
	lua_pushboolean(L, res ? 1 : 0);
	return 1;
}

int lua_stringfilter_shield(lua_State* L)
{
	const char* str = (char*)luaL_checkstring(L, 1);
	if (NULL == str)
		return 0;
	
	const char* mask = (char*)luaL_checkstring(L, 2);
	const std::string &dest = s_string_filter.censor(str, NULL == mask ? '*' : *mask);
	lua_pushstring(L, dest.c_str());
	return 1;
}

//--------------------------------------------------------------------
// system
//--------------------------------------------------------------------
#include "System/System.h"

int lua_system_gettime(lua_State* L)
{
	lua_pushnumber(L, System::getTime());
	return 1;
}

int lua_system_swab32_int(lua_State *L)
{
	int i = (int)luaL_checkinteger(L, 1);
	lua_pushinteger(L, System::swab32_int(i));
	return 1;
}

int lua_system_swab32_string(lua_State *L)
{
	unsigned char* s = (unsigned char*)luaL_checkstring(L, 1);
	lua_pushinteger(L, System::swab32_string(s));
	return 1;
}

int lua_system_int64_to_string(lua_State *L)
{
	long long* val = (long long*)luaL_checkstring(L, 1);
	char buff[64] = {0};
	sprintf(buff, "%lld", *val);
	lua_pushstring(L, buff);
	return 1;
}

//--------------------------------------------------------------------
// cocos2d
//--------------------------------------------------------------------

int lua_message_box(lua_State* L)
{
	const char* msg = (char*)luaL_checkstring(L, 1);
	if (NULL == msg)
		return 0;
	
	const char* title = (char*)luaL_checkstring(L, 2);
	if (NULL == title)
	{
		cocos2d::MessageBox(msg, "client");
	}
	else
	{
		cocos2d::MessageBox(msg, title);
	}
	return 0;
}

//--------------------------------------------------------------------