/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| Hashtable.cs                                             |
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
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/

/* Hashtable class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

#if SILVERLIGHT
namespace System.Collections {
    using System;
    public class Hashtable : System.Collections.Generic.Dictionary<Object, Object> {
        private Object syncRoot = new Object();
        public Hashtable() : base() {
        }
        public Hashtable(Int32 capacity) : base(capacity) {
        }
        public Hashtable(Int32 capacity, Single loadFactor) : base(capacity) {
        }
        public Hashtable(IDictionary value) : base((System.Collections.Generic.IDictionary<Object, Object>)value) {
        }
        public bool Contains(Object key) {
            return base.ContainsKey(key);
        }
        public virtual Object SyncRoot {
            get {
                return syncRoot;
            }
        }
        public virtual void CopyTo(Array array, Int32 index) {
            Object[] tmp = new Object[Count];
            Values.CopyTo(tmp, 0);
            tmp.CopyTo(array, index);
        }
    }
}
#endif