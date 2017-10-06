/**********************************************************************
* Author:	jaron.ho
* Date:		2014-05-10
* Brief:	system
**********************************************************************/
#ifndef _SYSTEM_H_
#define _SYSTEM_H_

#include <string>
#include <vector>

namespace System
{

double getTime(void);
int swab32_int(int i);
int swab32_string(unsigned char* s);

}

#endif	// _SYSTEM_H_

