/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| SerializableAttribute.cs                                 |
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

/* SerializableAttribute class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Feb 18, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */

#if (PocketPC || Smartphone || WindowsCE || SILVERLIGHT) && !NETCF20 && !NETCF35
namespace System {
    using System.Runtime.InteropServices;

    [AttributeUsage(AttributeTargets.Class | AttributeTargets.Struct
        | AttributeTargets.Enum | AttributeTargets.Delegate,
        Inherited = false, AllowMultiple = false)]
    public sealed class SerializableAttribute : Attribute {
    }
}
#endif