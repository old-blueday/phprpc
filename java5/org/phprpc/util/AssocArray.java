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

/* AssocArray class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Feb 16, 2009
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

package org.phprpc.util;

import java.io.Serializable;
import java.lang.reflect.ParameterizedType;
import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class AssocArray
    implements Cloneable, Serializable {
    private ArrayList arrayList;
    private LinkedHashMap hashMap;
    private int arrayLength;
    private int maxNumber;

    public AssocArray() {
        arrayList = new ArrayList();
        hashMap = new LinkedHashMap();
        arrayLength = 0;
        maxNumber = -1;
    }

    public AssocArray(int initialCapacity) {
        arrayList = new ArrayList(initialCapacity);
        hashMap = new LinkedHashMap(initialCapacity);
        arrayLength = 0;
        maxNumber = -1;
    }

    public AssocArray(int initialCapacity, float loadFactor) {
        arrayList = new ArrayList(initialCapacity);
        hashMap = new LinkedHashMap(initialCapacity, loadFactor);
        arrayLength = 0;
        maxNumber = -1;
    }

    public AssocArray(Collection c) {
        arrayList = new ArrayList(c);
        arrayLength = arrayList.size();
        maxNumber = arrayLength - 1;
        hashMap = new LinkedHashMap(arrayLength);
        for (int i = 0; i < arrayLength; i++) {
            hashMap.put(new Integer(i), arrayList.get(i));
        }
    }

    public AssocArray(Map m) {
        int len = m.size();
        arrayList = new ArrayList(len);
        hashMap = new LinkedHashMap(len);
        arrayLength = 0;
        maxNumber = -1;
        Iterator keys = m.keySet().iterator();
        while (keys.hasNext()) {
            Object key = keys.next();
            if ((key instanceof Integer) ||
                (key instanceof Short) ||
                (key instanceof Byte)) {
                int k = ((Number)key).intValue();
                if (k > -1) {
                    arrayLength++;
                    if (maxNumber < k) {
                        maxNumber = k;
                    }
                    // assert (maxNumber + 1 >= arrayLength);
                }
                hashMap.put(new Integer(k), m.get(key));
            }
            else if (key instanceof String) {
                hashMap.put(key, m.get(key));
            }
        }
        setArrayList();
    }

    private void setArrayList() {
        int len = arrayList.size();
        // assert (len <= arrayLength);
        if (len < arrayLength) {
            if(maxNumber + 1 == arrayLength) {
                for (int i = len; i < arrayLength; i++) {
                    arrayList.add(hashMap.get(new Integer(i)));
                }
            }
            else {
                Integer key = new Integer(len);
                while (hashMap.containsKey(key)) {
                    arrayList.add(hashMap.get(key));
                    key = new Integer(++len);
                }
            }
        }
    }

    public ArrayList toArrayList() {
        setArrayList();
        return arrayList;
    }

    public HashMap toHashMap() {
        return hashMap;
    }

    public LinkedHashMap toLinkedHashMap() {
        return hashMap;
    }

    public int size() {
        return hashMap.size();
    }

    public boolean isEmpty() {
        return hashMap.isEmpty();
    }

    public boolean add(Object element) {
        int index = arrayList.size();
        boolean result = arrayList.add(element);
        if (result) {
            Integer key = new Integer(index);
            if (!hashMap.containsKey(key)) {
                arrayLength++;
                if (maxNumber < index) {
                    maxNumber = index;
                }
                // assert (maxNumber + 1 >= arrayLength);
            }
            hashMap.put(key, element);
        }
        return result;
    }

    public boolean addAll(Collection c) {
        int len = c.size();
        int index = arrayList.size() - 1;
        boolean result = arrayList.addAll(c);
        if (result) {
            for (int i = 0; i < len; i++) {
                Integer key = new Integer(++index);
                if (!hashMap.containsKey(key)) {
                    arrayLength++;
                }
                hashMap.put(key, arrayList.get(index));
            }
            if (maxNumber < index) {
                maxNumber = index;
            }
            // assert (maxNumber + 1 >= arrayLength);
        }
        return result;
    }

    public void putAll(Map m) {
        Iterator keys = m.keySet().iterator();
        while (keys.hasNext()) {
            Object key = keys.next();
            if ((key instanceof Integer) ||
                (key instanceof Short) ||
                (key instanceof Byte)) {
                int k = ((Number)key).intValue();
                key = new Integer(k);
                if (k > -1 && !hashMap.containsKey(key)) {
                    arrayLength++;
                    if (maxNumber < k) {
                        maxNumber = k;
                    }
                    // assert (maxNumber + 1 >= arrayLength);
                }
                hashMap.put(key, m.get(key));
            }
            else if (key instanceof String) {
                hashMap.put(key, m.get(key));
            }
        }
        setArrayList();
    }

    public Object get(int index) {
        if (index < arrayList.size()) {
            return arrayList.get(index);
        }
        else {
            return hashMap.get(new Integer(index));
        }
    }

    public Object get(Byte key) {
        return get(key.intValue());
    }

    public Object get(Short key) {
        return get(key.intValue());
    }

    public Object get(Integer key) {
        return get(key.intValue());
    }

    public Object get(String key) {
        return hashMap.get(key);
    }

    public Object set(int index, Object element) {
        Integer key = new Integer(index);
        if (index > -1) {
            int size = arrayList.size();
            if (size > index) {
                 arrayList.set(index, element);
            }
            else {
                if (size == index) {
                    arrayList.add(element);
                }
                if (!hashMap.containsKey(key)) {
                    arrayLength++;
                    if (maxNumber < index) {
                        maxNumber = index;
                    }
                    // assert (maxNumber + 1 >= arrayLength);
                }
            }
        }
        return hashMap.put(key, element);
    }

    public Object set(Byte key, Object element) {
        return set(key.intValue(), element);
    }

    public Object set(Short key, Object element) {
        return set(key.intValue(), element);
    }

    public Object set(Integer key, Object element) {
        return set(key.intValue(), element);
    }

    public Object set(String key, Object element) {
        return hashMap.put(key, element);
    }

    public Object remove(int index) {
        Integer key = new Integer(index);
        if (index > -1) {
            if (hashMap.containsKey(key)) {
                arrayLength--;
                int lastIndex = arrayList.size() - 1;
                if (index <= lastIndex) {
                    for (int i = lastIndex; i >= index; i--) {
                        arrayList.remove(i);
                    }
                    if (maxNumber == index) {
                        maxNumber--;
                    }
                }
                else if (maxNumber == index) {
                    while ((--index > lastIndex) && !hashMap.containsKey(new Integer(index)));
                    maxNumber = index;
                }
                // assert (maxNumber + 1 >= arrayLength);
            }
            else {
                return null;
            }
        }
        return hashMap.remove(key);
    }

    public Object remove(Byte key) {
        return remove(key.intValue());
    }

    public Object remove(Short key) {
        return remove(key.intValue());
    }

    public Object remove(Integer key) {
        return remove(key.intValue());
    }

    public Object remove(String key) {
        return hashMap.remove(key);
    }

    public void clear() {
        arrayList.clear();
        hashMap.clear();
        arrayLength = 0;
        maxNumber = -1;
    }

    public Object clone() throws CloneNotSupportedException {
        AssocArray result = null;
        result = (AssocArray)super.clone();
        result.arrayList = (ArrayList)this.arrayList.clone();
        result.hashMap = (LinkedHashMap)this.hashMap.clone();
        result.arrayLength = this.arrayLength;
        result.maxNumber = this.maxNumber;
        return result;
    }
    
    //Added By Vincent
    //Set generic type data stored in Map/Collection to the CORRECT type
    //One Actual type argument for list, two for map
    public void Parameterize(ParameterizedType type)
    {
    	Type types[] = type.getActualTypeArguments();
    	int Size = types.length;
    	if (Size == 1)
    	{
    		Type targetType = types[0];
    		ArrayList al = new ArrayList();
    		al.addAll(arrayList);
    		clear();
    		arrayList.clear();
    		for(int i=0;i<al.size();i++)
    		{
    			Object obj = al.get(i);
    			if ((obj instanceof AssocArray) && (targetType instanceof ParameterizedType))
    			{
    				((AssocArray)obj).Parameterize((ParameterizedType)targetType);
    				Type rowType  =  ((ParameterizedType)targetType).getRawType();
    				if (rowType == ArrayList.class || rowType == List.class || rowType == Collection.class)
    					obj = ((AssocArray)obj).toArrayList();
    				if (rowType == HashMap.class || rowType == Map.class)
    					obj = ((AssocArray)obj).toHashMap();
    			}
    			else
    				obj = Cast.cast(obj, targetType.getClass());
    			this.add(obj);
    		}
    	}
    	if (Size==2)
    	{
    		Type KeyType = types[0];
    		Type ValueType = types[1];
    		LinkedHashMap lhm = new LinkedHashMap();
    		lhm.putAll(hashMap);
    		clear();
    		for(Object Key : lhm.keySet())
    		{
    			Object obj = lhm.get(Key);
    			if ((obj instanceof AssocArray) && (ValueType instanceof ParameterizedType))
    			{
    				((AssocArray)obj).Parameterize((ParameterizedType)ValueType);
    				Type rowType  =  ((ParameterizedType)ValueType).getRawType();
    				if (rowType == ArrayList.class || rowType == List.class || rowType == Collection.class)
    					obj = ((AssocArray)obj).toArrayList();
    				if (rowType == HashMap.class || rowType == Map.class)
    					obj = ((AssocArray)obj).toHashMap();
    			}
    			this.set(Key.toString(), Cast.cast(obj, ValueType.getClass()));
    		}
    	}
    }
}