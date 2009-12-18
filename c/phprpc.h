/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| phprpc.h                                                 |
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

/* PHPRPC library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Dec 18, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef PHPRPC_INCLUDED
#define PHPRPC_INCLUDED

#if (defined(_WIN32) || defined(__WIN32__)) && !defined(WIN32)
	#define WIN32
#endif

#if (defined(_USRDLL) || defined(BUILDING_DLL)) && !defined(USEDLL)
	#define USEDLL
#endif

#ifdef WIN32
	#ifdef USEDLL
		#ifdef PHPRPC_EXPORTS
			#define PHPRPCAPI __declspec(dllexport)
		#else
			#define PHPRPCAPI __declspec(dllimport)
		#endif
	#else
		#define PHPRPCAPI
	#endif
#else
	#if defined(__GNUC__) && __GNUC__ >= 4
		#define PHPRPCAPI __attribute__ ((visibility("default")))
	#else
		#define PHPRPCAPI
	#endif
#endif

#include <assert.h>
#include <malloc.h>
#include <string.h>

#endif