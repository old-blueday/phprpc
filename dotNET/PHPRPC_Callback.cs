/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Callback.cs                                       |
|                                                          |
| Release 3.0.2                                            |
| Copyright by Team-PHPRPC                                 |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  Ma Bingyao <andot@ujn.edu.cn>                  |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* PHPRPC Callback delegate.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Dec 19, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */

#if !(PocketPC || Smartphone || WindowsCE || NET1)
namespace org.phprpc {
    using System;
    public delegate void PHPRPC_Callback<T>(T Result, Object[] args, String output, PHPRPC_Error error, Boolean failure);
    public delegate void PHPRPC_Callback(Object Result, Object[] args, String output, PHPRPC_Error warning);
}
#endif