/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| ArrayList.cs                                             |
|                                                          |
| Release 3.0.2                                            |
| Copyright: by Team-PHPRPC                                |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  Ma Bingyao <andot@ujn.edu.cn>                  |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/

/* ArrayList class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

#if SILVERLIGHT
namespace System.Collections {
    using System;
    public class ArrayList: System.Collections.Generic.List<Object> {
        private Object syncRoot = new Object();

        public ArrayList() : base() {
        }
        public ArrayList(Int32 capacity) : base(capacity) {
        }
        public ArrayList(ICollection collection) : base((System.Collections.Generic.IEnumerable<Object>)collection) {
        }
        public new int Add(Object item) {
            base.Add(item);
            return base.Count - 1;
        }
        public Array ToArray(Type type) {
            Array result = Array.CreateInstance(type, Count);
            base.ToArray().CopyTo(result, 0);
            return result;
        }
        public virtual Object SyncRoot {
            get {
                return syncRoot;
            }
        }
    }
}
#endif