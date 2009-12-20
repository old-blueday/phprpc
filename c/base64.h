/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| base64.h                                                 |
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

/* Base64 library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Dec 19, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef BASE64_INCLUDED
#define BASE64_INCLUDED

#include "phprpc.h"

#ifdef  __cplusplus
extern "C" {
#endif

PHPRPCAPI char * base64_encode(const unsigned char * data, size_t len);
PHPRPCAPI unsigned char * base64_decode(const char * data, size_t * out_len);

#ifdef PHPRPC_UNITTEST
PHPRPCAPI void base64_encode_test();
PHPRPCAPI void base64_decode_test();
#endif

#ifdef  __cplusplus
}
#endif

#endif