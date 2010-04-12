/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| AssocArray.java                                          |
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

/* AssocArray class for J2ME.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

package org.phprpc.util;

import java.util.Vector;
import java.util.Hashtable;

public class AssocArray {
    private Vector vector;
    private Hashtable hashtable;
    private Vector nullKeys = new Vector();
    private int arrayLength = 0;
    private int maxNumber = -1;

    public AssocArray() {
        vector = new Vector();
        hashtable = new Hashtable();
    }

    public AssocArray(int initialCapacity) {
        vector = new Vector(initialCapacity);
        hashtable = new Hashtable(initialCapacity);
    }

    private void setVector() {
        int len = vector.size();
        if (len < arrayLength) {
            if(maxNumber + 1 == arrayLength) {
                for (int i = len; i < arrayLength; i++) {
                    vector.addElement(hashtable.get(new Integer(i)));
                }
            }
            else {
                Integer key = new Integer(len);
                while (hashtable.containsKey(key) || nullKeys.contains(key)) {
                    vector.addElement(hashtable.get(key));
                    key = new Integer(++len);
                }
            }
        }
    }

    public Vector toVector() {
        setVector();
        return vector;
    }

    public Hashtable toHashtable() {
        return hashtable;
    }

    public int size() {
        return hashtable.size();
    }

    public boolean isEmpty() {
        return hashtable.isEmpty();
    }

    public void add(Object element) {
        int index = vector.size();
        vector.addElement(element);
        Integer key = new Integer(index);
        if (!hashtable.containsKey(key) && !nullKeys.contains(key)) {
            arrayLength++;
            if (maxNumber < index) {
                maxNumber = index;
            }
        }
        if (element != null) {
            hashtable.put(key, element);
        }
        else {
            if (!nullKeys.contains(key)) {
                nullKeys.addElement(key);
            }
            if (hashtable.containsKey(key)) {
                hashtable.remove(key);
            }
        }
    }

    public Object get(int index) {
        if (index < vector.size()) {
            return vector.elementAt(index);
        }
        else {
            return hashtable.get(new Integer(index));
        }
    }

    public Object get(Byte key) {
        return get(key.byteValue());
    }

    public Object get(Short key) {
        return get(key.shortValue());
    }

    public Object get(Integer key) {
        return get(key.intValue());
    }

    public Object get(String key) {
        return hashtable.get(key);
    }

    public Object set(int index, Object element) {
        Integer key = new Integer(index);
        if (index > -1) {
            int size = vector.size();
            if (size > index) {
                 vector.setElementAt(element, index);
            }
            else {
                if (size == index) {
                    vector.addElement(element);
                }
                if (!hashtable.containsKey(key) && !nullKeys.contains(key)) {
                    arrayLength++;
                    if (maxNumber < index) {
                        maxNumber = index;
                    }
                }
            }
        }
        if (element != null) {
            return hashtable.put(key, element);
        }
        else {
            if (!nullKeys.contains(key)) {
                nullKeys.addElement(key);
            }
            if (hashtable.containsKey(key)) {
                return hashtable.remove(key);
            }
            else {
                return null;
            }
        }
    }

    public Object set(Byte key, Object element) {
        return set(key.byteValue(), element);
    }

    public Object set(Short key, Object element) {
        return set(key.shortValue(), element);
    }

    public Object set(Integer key, Object element) {
        return set(key.intValue(), element);
    }

    public Object set(String key, Object element) {
        if (element != null) {
            return hashtable.put(key, element);
        }
        else {
            if (!nullKeys.contains(key)) {
                nullKeys.addElement(key);
            }
            if (hashtable.containsKey(key)) {
                return hashtable.remove(key);
            }
            else {
                return null;
            }
        }
    }

    public Object remove(int index) {
        Integer key = new Integer(index);
        if (index > -1) {
            if (hashtable.containsKey(key) || nullKeys.contains(key)) {
                arrayLength--;
                int lastIndex = vector.size() - 1;
                if (index <= lastIndex) {
                    for (int i = lastIndex; i >= index; i--) {
                        vector.removeElementAt(i);
                    }
                    if (maxNumber == index) {
                        maxNumber--;
                    }
                }
                else if (maxNumber == index) {
                    while ((--index > lastIndex) &&
                           !hashtable.containsKey(new Integer(index)) &&
                           !nullKeys.contains(new Integer(index))){};
                    maxNumber = index;
                }
            }
            else {
                return null;
            }
        }
        if (nullKeys.contains(key)) {
            nullKeys.removeElement(key);
        }
        return hashtable.remove(key);
    }

    public Object remove(Byte key) {
        return remove(key.byteValue());
    }

    public Object remove(Short key) {
        return remove(key.shortValue());
    }

    public Object remove(Integer key) {
        return remove(key.intValue());
    }

    public Object remove(String key) {
        if (nullKeys.contains(key)) {
            nullKeys.removeElement(key);
        }
        return hashtable.remove(key);
    }

    public void clear() {
        nullKeys.removeAllElements();
        vector.removeAllElements();
        hashtable.clear();
        arrayLength = 0;
        maxNumber = -1;
    }
}