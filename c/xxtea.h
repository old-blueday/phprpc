/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| xxtea.h                                                  |
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

/* XXTEA encryption arithmetic library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Dec 7, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef XXTEA_INCLUDED
#define XXTEA_INCLUDED

#include "phprpc.h"

#define MX (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (key[(p & 3) ^ e] ^ z))
#define DELTA 0x9e3779b9

PHPRPCAPI unsigned char * xxtea_encrypt(const unsigned char * data, size_t len, const unsigned char * key, size_t * out_len);
PHPRPCAPI unsigned char * xxtea_decrypt(const unsigned char * data, size_t len, const unsigned char * key, size_t * out_len);

#endif