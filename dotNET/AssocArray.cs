/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| AssocArray.cs                                            |
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

/* AssocArray class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

namespace org.phprpc.util {
    using System;
    using System.Collections;
    using System.Globalization;

    public class AssocArray : IDictionary, IList, ICollection, IEnumerable
#if !SILVERLIGHT
    , ICloneable
#endif
    {
        private static readonly IFormatProvider provider = CultureInfo.InvariantCulture;
        private ArrayList arrayList;
        private Hashtable hashtable;
        private Int32 arrayLength;
        private Int32 maxNumber;

        public AssocArray() {
            arrayList = new ArrayList();
            hashtable = new Hashtable();
            arrayLength = 0;
            maxNumber = -1;
        }

        public AssocArray(Int32 capacity) {
            arrayList = new ArrayList(capacity);
            hashtable = new Hashtable(capacity);
            arrayLength = 0;
            maxNumber = -1;
        }

        public AssocArray(Int32 capacity, Single loadFactor) {
            arrayList = new ArrayList(capacity);
            hashtable = new Hashtable(capacity, loadFactor);
            arrayLength = 0;
            maxNumber = -1;
        }

        public AssocArray(ICollection c) {
            arrayList = new ArrayList(c);
            arrayLength = arrayList.Count;
            maxNumber = arrayLength - 1;
            hashtable = new Hashtable(arrayLength);
            for (Int32 i = 0; i < arrayLength; i++) {
                hashtable[i] = arrayList[i];
            }
        }

        public AssocArray(IDictionary d) {
            Int32 len = d.Count;
            arrayList = new ArrayList(len);
            hashtable = new Hashtable(len);
            arrayLength = 0;
            maxNumber = -1;
            if (len == 0) {
                return;
            }
            IEnumerator keys = d.Keys.GetEnumerator();
            keys.Reset();
            while (keys.MoveNext()) {
                Object key = keys.Current;
                if ((key is Int32) ||
                    (key is SByte) ||
                    (key is Byte) ||
                    (key is Int16) ||
                    (key is UInt16) ||
                    (key is UInt32) ||
                    (key is Int64) ||
                    (key is UInt64)) {
                    Int32 k;
                    try {
                        k = (Int32)Convert.ChangeType(key, TypeCode.Int32, provider);
                    }
                    catch (InvalidCastException) {
                        continue;
                    }
                    if (k > -1) {
                        arrayLength++;
                        if (maxNumber < k) {
                            maxNumber = k;
                        }
                    }
                    hashtable[k] = d[key];
                }
                else if (key is String) {
                    hashtable[key] = d[key];
                }
            }
            setArrayList();
        }

        public virtual Object this[String key] {
            get {
                return hashtable[key];
            }
            set {
                hashtable[key] = value;
            }
        }

        private void setArrayList() {
            Int32 len = arrayList.Count;
            if (len < arrayLength) {
                if (maxNumber + 1 == arrayLength) {
                    for (Int32 i = len; i < arrayLength; i++) {
                        arrayList.Add(hashtable[i]);
                    }
                }
                else {
                    while (hashtable.ContainsKey(len)) {
                        arrayList.Add(hashtable[len++]);
                    }
                }
            }
        }

        public virtual ArrayList toArrayList() {
            setArrayList();
            return arrayList;
        }

        public virtual Hashtable toHashtable() {
            return hashtable;
        }


        #region IDictionary & IList Members

        public virtual void Clear() {
            hashtable.Clear();
            arrayList.Clear();
            arrayLength = 0;
            maxNumber = -1;
        }

        public virtual Boolean IsFixedSize {
            get {
                return false;
            }
        }

        public virtual Boolean IsReadOnly {
            get {
                return false;
            }
        }
        #endregion

        #region IDictionary Members

        public void Add(Object key, Object value) {
            if ((key is Int32) ||
                (key is SByte) ||
                (key is Byte) ||
                (key is Int16) ||
                (key is UInt16) ||
                (key is UInt32) ||
                (key is Int64) ||
                (key is UInt64)) {
                Int32 k = (Int32)Convert.ChangeType(key, TypeCode.Int32, provider);
                hashtable.Add(k, value);
                if (k > -1) {
                    arrayLength++;
                    if (maxNumber < k) {
                        maxNumber = k;
                    }
                }
            }
            else {
                hashtable.Add(key.ToString(), value);
            }
        }
        
        public virtual Boolean Contains(Object key) {
            if (key is Int32) {
                return hashtable.Contains(key);
            }
            else if ((key is Byte) ||
                (key is Int16) ||
                (key is UInt16) ||
                (key is UInt32) ||
                (key is Int64) ||
                (key is UInt64)) {
                try {
                    Int32 k = (Int32)Convert.ChangeType(key, TypeCode.Int32, provider);
                    return hashtable.Contains(k);
                }
                catch (InvalidCastException) {
                    return false;
                }
            }
            return hashtable.Contains(key.ToString());
        }

        public virtual IDictionaryEnumerator GetEnumerator() {
            return hashtable.GetEnumerator();
        }


        public virtual ICollection Keys {
            get {
                return hashtable.Keys;
            }
        }

        public virtual void Remove(Object key) {
            if ((key is Int32) ||
                (key is SByte) ||
                (key is Byte) ||
                (key is Int16) ||
                (key is UInt16) ||
                (key is UInt32) ||
                (key is Int64) ||
                (key is UInt64)) {
                Int32 k;
                try {
                    k = (Int32)Convert.ChangeType(key, TypeCode.Int32, provider);
                }
                catch (InvalidCastException) {
                    return;
                }
                ((IList)this).RemoveAt(k);
            }
            else {
                hashtable.Remove(key.ToString());
            }
        }

        public virtual ICollection Values {
            get {
                return hashtable.Values;
            }
        }

        public virtual Object this[Object key] {
            get {
                if ((key is String) || (key is Int32)) {
                    return hashtable[key];
                }
                else if ((key is SByte) ||
                    (key is Byte) ||
                    (key is Int16) ||
                    (key is UInt16) ||
                    (key is UInt32) ||
                    (key is Int64) ||
                    (key is UInt64)) {
                    Int32 k;
                    try {
                        k = (Int32)Convert.ChangeType(key, TypeCode.Int32, provider);
                    }
                    catch (InvalidCastException) {
                        return null;
                    }
                    return hashtable[k];
                }
                return hashtable[key.ToString()];
            }
            set {
                if (key is String) {
                    hashtable[key] = value;
                }
                if ((key is Int32) ||
                    (key is SByte) ||
                    (key is Byte) ||
                    (key is Int16) ||
                    (key is UInt16) ||
                    (key is UInt32) ||
                    (key is Int64) ||
                    (key is UInt64)) {
                    Int32 k = (Int32)Convert.ChangeType(key, TypeCode.Int32, provider);
                    this[k] = value;
                }
                else {
                    hashtable[key.ToString()] = value;
                }
            }
        }

        #endregion

        #region ICollection Members
        public virtual void CopyTo(Array array, Int32 index) {
            hashtable.CopyTo(array, index);
        }

        public virtual Int32 Count {
            get {
                return hashtable.Count;
            }
        }

        public virtual Boolean IsSynchronized {
            get {
                return false;
            }
        }

        public virtual Object SyncRoot {
            get {
                return hashtable.SyncRoot;
            }
        }

        #endregion

        #region IList Members

        public virtual Int32 Add(Object value) {
            Int32 key = arrayList.Count;
            arrayList.Add(value);
            if (!hashtable.ContainsKey(key)) {
                arrayLength++;
                if (maxNumber < key) {
                    maxNumber = key;
                }
            }
            hashtable[key] = value;
            return key;
        }

        public virtual Int32 IndexOf(Object value) {
            setArrayList();
            return arrayList.IndexOf(value);
        }

        public virtual void Insert(Int32 index, Object value) {
            setArrayList();
            arrayList.Insert(index, value);
            arrayLength++;
            if (maxNumber < index) {
                maxNumber = index;
            }
            for (Int32 i = arrayList.Count - 1; i >= index; i--) {
                hashtable[i] = arrayList[i];
            }
        }

        public virtual void RemoveAt(Int32 index) {
            if (index > -1) {
                if (hashtable.ContainsKey(index)) {
                    arrayLength--;
                    Int32 lastIndex = arrayList.Count - 1;
                    if (index <= lastIndex) {
                        for (Int32 i = lastIndex; i >= index; i--) {
                            arrayList.Remove(i);
                        }
                        if (maxNumber == index) {
                            maxNumber--;
                        }
                    }
                    else if (maxNumber == index) {
                        do {
                            index--;
                        } while ((index > lastIndex) && !hashtable.ContainsKey(index));
                        maxNumber = index;
                    }
                }
                else {
                    return;
                }
            }
            hashtable.Remove(index);
        }

        public virtual Object this[Int32 index] {
            get {
                return hashtable[index];
            }
            set {
                if (index > -1) {
                    if (index < arrayList.Count) {
                        arrayList[index] = value;
                    }
                    else if (!hashtable.ContainsKey(index)) {
                        arrayLength++;
                        if (maxNumber < index) {
                            maxNumber = index;
                        }
                    }
                }
                hashtable[index] = value;
            }
        }

        Boolean IList.Contains(Object value) {
            setArrayList();
            return arrayList.Contains(value);
        }

        void IList.Remove(Object value) {
            Int32 index = this.IndexOf(value);
            if (index > -1) {
                arrayList.Remove(value);
                arrayLength--;
                if (maxNumber == index) {
                    maxNumber--;
                }
                Int32 lastIndex = arrayList.Count;
                for (Int32 i = index; i < lastIndex; i++) {
                    hashtable[i] = arrayList[i];
                }
                hashtable.Remove(lastIndex);
            }
        }

        #endregion
#if !SILVERLIGHT
        #region ICloneable Members

        public virtual Object Clone() {
            AssocArray result = new AssocArray();
            result.arrayList = (ArrayList)arrayList.Clone();
            result.hashtable = (Hashtable)hashtable.Clone();
            result.arrayLength = arrayLength;
            result.maxNumber = maxNumber;
            return result;
        }

        #endregion
#endif
        #region IEnumerable Members

        IEnumerator IEnumerable.GetEnumerator() {
            return hashtable.GetEnumerator();
        }

        #endregion
    }
}