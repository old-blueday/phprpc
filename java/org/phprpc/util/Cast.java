/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| Cast.java                                                |
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

/* Cast library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Mar 15, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */

package org.phprpc.util;

import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.Method;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

public final class Cast {

    private static Class enumClass;
    private static Method getEnumConstants;

    static {
        try {
            enumClass = Class.forName("java.lang.Enum");
            getEnumConstants = Class.class.getDeclaredMethod("getEnumConstants", new Class[0]);
            getEnumConstants.setAccessible(true);
        }
        catch (Exception e) {
            enumClass = null;
            getEnumConstants = null;
        }
    }

    private Cast() {};

    public static byte[] getBytes(Object obj, String charset) {
        if (obj instanceof byte[]) {
            return (byte[])obj;
        }
        try {
            return obj.toString().getBytes(charset);
        }
        catch (Exception e) {
            return obj.toString().getBytes();
        }
    }

    public static byte[] getBytes(Object obj) {
        return getBytes(obj, "utf-8");
    }

    public static String toString(Object obj, String charset) {
        if (obj instanceof byte[]) {
            try {
                return new String((byte[]) obj, charset);
            }
            catch (Exception e) {
                return new String((byte[]) obj);
            }
        }
        else {
            return obj.toString();
        }
    }

    public static String toString(Object obj) {
        return toString(obj, "utf-8");
    }

    public static Object cast(Number n, Class destClass) {
        if (destClass == Byte.class || destClass == Byte.TYPE) {
            return new Byte(n.byteValue());
        }
        if (destClass == Short.class || destClass == Short.TYPE) {
            return new Short(n.shortValue());
        }
        if (destClass == Integer.class || destClass == Integer.TYPE) {
            return new Integer(n.intValue());
        }
        if (destClass == Long.class || destClass == Long.TYPE) {
            return new Long(n.longValue());
        }
        if (destClass == Float.class || destClass == Float.TYPE) {
            return new Float(n.floatValue());
        }
        if (destClass == Double.class || destClass == Double.TYPE) {
            return new Double(n.doubleValue());
        }
        if (destClass == Boolean.class || destClass == Boolean.TYPE) {
            return new Boolean(n.byteValue() != 0);
        }
        if ((enumClass != null) && enumClass.isAssignableFrom(destClass)) {
            try {
                Object o = getEnumConstants.invoke(destClass, new Object[0]);
                return Array.get(o, n.intValue());
            }
            catch (Throwable e) {
                return null;
            }
        }
        return n;
    }

    public static Object cast(String s, Class destClass, String charset) {
        if (destClass == char[].class) {
            return s.toCharArray();
        }
        if (destClass == byte[].class) {
            return getBytes(s, charset);
        }
        if (destClass == StringBuffer.class) {
            return new StringBuffer(s);
        }
        if (destClass == Character.class || destClass == Character.TYPE) {
            return new Character(s.charAt(0));
        }
        if (destClass == Byte.class || destClass == Byte.TYPE) {
            return new Byte(s);
        }
        if (destClass == Short.class || destClass == Short.TYPE) {
            return new Short(s);
        }
        if (destClass == Integer.class || destClass == Integer.TYPE) {
            return new Integer(s);
        }
        if (destClass == Long.class || destClass == Long.TYPE) {
            return new Long(s);
        }
        if (destClass == Float.class || destClass == Float.TYPE) {
            return new Float(s);
        }
        if (destClass == Double.class || destClass == Double.TYPE) {
            return new Double(s);
        }
        if (destClass == Boolean.class || destClass == Boolean.TYPE) {
            return new Boolean(!(s.equals("") || s.equals("0") || s.toLowerCase().equals("false")));
        }
        if (destClass == BigInteger.class) {
            return new BigInteger(s);
        }
        if (destClass == BigDecimal.class || destClass == Number.class) {
            return new BigDecimal(s);
        }
        if (destClass == Boolean.class || destClass == Boolean.TYPE) {
            return new Boolean(!(s.equals("") || s.equals("0") || s.toLowerCase().equals("false")));
        }
        return s;
    }

    public static Object cast(String s, Class destClass) {
        return cast(s, destClass, "utf-8");
    }

    public static Object cast(AssocArray obj, Class destClass, String charset) {
        if (destClass == AssocArray.class) {
            return obj;
        }
        if (destClass == ArrayList.class || destClass == List.class || destClass == Collection.class) {
            return obj.toArrayList();
        }
        if (destClass == Set.class) {
            return new HashSet(obj.toArrayList());
        }
        if (destClass == HashMap.class || destClass == Map.class) {
            return obj.toHashMap();
        }
        if (destClass == LinkedHashMap.class) {
            return obj.toLinkedHashMap();
        }
        if (destClass.isArray()) {
            return toArray(obj.toArrayList(), destClass.getComponentType(), charset);
        }
        if (Collection.class.isAssignableFrom(destClass)) {
            try {
                Method addAll = destClass.getMethod("addAll", new Class[] { Collection.class });
                Object o = PHPSerializer.newInstance(destClass);
                if (o != null) {
                    addAll.setAccessible(true);
                    addAll.invoke(o, new Object[] { obj.toArrayList() });
                }
                return o;
            }
            catch (Throwable e) {
                return null;
            }
        }
        if (Map.class.isAssignableFrom(destClass)) {
            try {
                Method putAll = destClass.getMethod("putAll", new Class[] { Map.class });
                Object o = PHPSerializer.newInstance(destClass);
                if (o != null) {
                    putAll.setAccessible(true);
                    putAll.invoke(o, new Object[] { obj.toHashMap() });
                }
                return o;
            }
            catch (Throwable e) {
                return null;
            }
        }
        return cast(obj.toHashMap(), destClass, charset);
    }
    private static Object cast(HashMap obj, Class destClass, String charset) {
        try {
            PHPSerializer.getClassName(destClass);
            Object o = PHPSerializer.newInstance(destClass);
            for (Iterator keys = obj.keySet().iterator(); keys.hasNext();) {
                Object key = keys.next();
                String name = key.toString();
                Object value = obj.get(key);
                Field f = PHPSerializer.getField(o, name);
                if (f != null) {
                    f.setAccessible(true);
                    f.set(o, Cast.cast(value, f.getType(), charset));
                }
            }
            return o;
        }
        catch (Throwable e) {
            return null;
        }
    }
    public static Object cast(Object obj, Class destClass, String charset) {
        if (obj == null || destClass == null || destClass == Void.class || destClass == Void.TYPE) {
            return null;
        }
        if (destClass.isInstance(obj)) {
            return obj;
        }
        if (obj instanceof byte[]) {
            return cast(toString(obj, charset), destClass, charset);
        }
        if (obj instanceof char[]) {
            return cast(new String((char[]) obj), destClass, charset);
        }
        if (obj instanceof StringBuffer) {
            return cast(obj.toString(), destClass, charset);
        }
        if (obj instanceof String) {
            return cast((String) obj, destClass, charset);
        }
        if (destClass == Character.class || destClass == Character.TYPE) {
            return new Character(obj.toString().charAt(0));
        }
        if ((obj instanceof Calendar) && Date.class.isAssignableFrom(destClass)) {
            return toDate(((Calendar)obj).getTimeInMillis(), destClass);
        }
        if (obj instanceof AssocArray) {
            return cast((AssocArray)obj, destClass, charset);
        }
        if (obj instanceof HashMap) {
            return cast((HashMap)obj, destClass, charset);
        }
        if ((obj instanceof Boolean) && Number.class.isAssignableFrom(destClass)) {
            return cast(new Integer((((Boolean) obj).booleanValue() == true) ? 1 : 0), destClass);
        }
        if (destClass == String.class) {
            return obj.toString();
        }
        if (destClass == StringBuffer.class) {
            return new StringBuffer(obj.toString());
        }
        if (!obj.getClass().isArray() && destClass == byte[].class) {
            return getBytes(obj);
        }
        if (!obj.getClass().isArray() && destClass == char[].class) {
            return obj.toString().toCharArray();
        }
        if (obj instanceof Number) {
            return cast((Number) obj, destClass);
        }
        return obj;
    }

    public static Object cast(Object obj, Class destClass) {
        return cast(obj, destClass, "utf-8");
    }

    public static Object toArray(ArrayList obj, Class componentType, String charset) {
        int n = obj.size();
        Object a = Array.newInstance(componentType, n);

        for (int i = 0; i < n; i++) {
            Array.set(a, i, cast(obj.get(i), componentType, charset));
        }
        return a;
    }

    public static Date toDate(long time, Class destClass) {
        if (destClass == Date.class) {
            return new Date(time);
        }
        if (destClass == java.sql.Date.class) {
            return new java.sql.Date(time);
        }
        if (destClass == java.sql.Time.class) {
            return new java.sql.Time(time);
        }
        if (destClass == java.sql.Timestamp.class) {
            return new java.sql.Timestamp(time);
        }
        else {
            try {
                return (Date)(destClass.getConstructor(new Class[] { Long.TYPE }).newInstance(new Object[] { new Long(time) }));

            }
            catch (Throwable e) {
                return null;
            }
        }
    }
};