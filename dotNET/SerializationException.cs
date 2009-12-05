/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| SerializationException.cs                                |
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

/* SerializationException class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Feb 12, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */

#if (PocketPC || Smartphone || WindowsCE) && !NETCF35
namespace System.Runtime.Serialization {
    using System;

    public class SerializationException : SystemException {
        public SerializationException()
            : base("An error occurred during (de)serialization") {
        }

        public SerializationException(String message)
            : base(message) {
        }

        public SerializationException(String message, Exception inner)
            : base(message, inner) {
        }
    }
}
#endif