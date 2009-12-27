/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| md5.h                                                    |
|                                                          |
| Release 3.0                                              |
| Copyright by Team-PHPRPC                                 |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  Chen fei <cf850118@163.com>                    |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* MD5 Library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Dec 27, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef MD5_INCLUDED
#define MD5_INCLUDED

#include "phprpc.h"

#ifdef  __cplusplus
extern "C" {
#endif

#define ROL(Val, Shift) (((Val) << (Shift)) | ((Val) >> (32 - (Shift))))

PHPRPCAPI unsigned char * raw_md5(const unsigned char * data, size_t len, unsigned char * md);
PHPRPCAPI char * hex_md5(const unsigned char * data, size_t len, char * md);

#ifdef PHPRPC_UNITTEST
PHPRPCAPI void md5_test();
#endif

#ifdef  __cplusplus
}
#endif

#endif