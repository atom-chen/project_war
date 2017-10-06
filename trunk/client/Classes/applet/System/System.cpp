/**********************************************************************
* Author:	jaron.ho
* Date:		2014-05-10
* Brief:	system
**********************************************************************/
#include "System.h"
#ifdef _WIN32
#include <direct.h>
#include <windows.h>
#include <io.h>
#else
#include <dirent.h>
#include <time.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <sys/time.h>
#endif

namespace System
{

double getTime(void)
{
#ifdef _WIN32
	FILETIME ft;
	double t;
	GetSystemTimeAsFileTime(&ft);
	/* Windows file time (time since January 1, 1601 (UTC)) */
	t = ft.dwLowDateTime/1.0e7 + ft.dwHighDateTime*(4294967296.0/1.0e7);
	/* convert to Unix Epoch time (time since January 1, 1970 (UTC)) */
	return (t - 11644473600.0);
#else
	struct timeval v;
	gettimeofday(&v, (struct timezone*)NULL);
	/* Unix Epoch time (time since January 1, 1970 (UTC)) */
	return v.tv_sec + v.tv_usec/1.0e6;
#endif
}

int swab32_int(int i)
{
	return ((i&0x000000ff) << 24) | ((i&0x0000ff00) << 8) | ((i&0x00ff0000) >> 8) | ((i&0xff000000) >> 24);
}

int swab32_string(unsigned char* s)
{
	return ((s[0] << 24) | (s[1] << 16) | (s[2] << 8) | s[3]);
}

}

