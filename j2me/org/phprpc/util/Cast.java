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

/* Cast library for J2ME.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Mar 15, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */
package org.phprpc.util;

import java.util.Calendar;
import java.util.Date;
import java.util.Vector;
import java.util.Hashtable;

public final class Cast {

    private Cast() {
    }

    static private boolean isNumber(Object obj) {
        return (obj instanceof Byte)
            || (obj instanceof Short)
            || (obj instanceof Integer)
            || (obj instanceof Long)
            || (obj instanceof Float)
            || (obj instanceof Double);
    }

    static public byte[] getBytes(Object obj, String charset) {
        if (obj instanceof byte[]) {
            return (byte[]) obj;
        }
        try {
            return obj.toString().getBytes(charset);
        } catch (Exception e) {
            return obj.toString().getBytes();
        }
    }

    static public byte[] getBytes(Object obj) {
        return getBytes(obj, "utf-8");
    }

    static public String toString(Object obj, String charset) {
        if (obj instanceof byte[]) {
            try {
                return new String((byte[]) obj, charset);
            } catch (Exception e) {
                return new String((byte[]) obj);
            }
        } else {
            return obj.toString();
        }
    }

    static public String toString(Object obj) {
        return toString(obj, "utf-8");
    }

    static public Object cast(String s, Class destClass, String charset) {
        if (destClass == char[].class) {
            return s.toCharArray();
        }
        if (destClass == byte[].class) {
            return getBytes(s, charset);
        }
        if (destClass == StringBuffer.class) {
            return new StringBuffer(s);
        }
        if (destClass == Byte.class) {
            return new Byte(Byte.parseByte(s));
        }
        if (destClass == Character.class) {
            return new Character(s.charAt(0));
        }
        if (destClass == Short.class) {
            return new Short(Short.parseShort(s));
        }
        if (destClass == Integer.class) {
            return new Integer(Integer.parseInt(s));
        }
        if (destClass == Long.class) {
            return new Long(Long.parseLong(s));
        }
        if (destClass == Float.class) {
            return new Float(Float.parseFloat(s));
        }
        if (destClass == Double.class) {
            return new Double(Double.parseDouble(s));
        }
        if (destClass == BigInteger.class) {
            return new BigInteger(s);
        }
        if (destClass == Boolean.class) {
            return new Boolean(!(s.equals("") || s.equals("0") || s.toLowerCase().equals("false")));
        }
        return s;
    }

    static public Object cast(String s, Class destClass) {
        return cast(s, destClass, "utf-8");
    }

    static public Object cast(AssocArray obj, Class destClass, String charset) {
        if (destClass == Vector.class) {
            return obj.toVector();
        }
        if (destClass == Hashtable.class) {
            return obj.toHashtable();
        }
        if (destClass == Object[].class) {
            return toArray(obj.toVector());
        }
        if (destClass == byte[].class) {
            return toByteArray(obj.toVector());
        }
        if (destClass == char[].class) {
            return toCharArray(obj.toVector());
        }
        if (destClass == short[].class) {
            return toShortArray(obj.toVector());
        }
        if (destClass == int[].class) {
            return toIntArray(obj.toVector());
        }
        if (destClass == long[].class) {
            return toLongArray(obj.toVector());
        }
        if (destClass == float[].class) {
            return toFloatArray(obj.toVector());
        }
        if (destClass == double[].class) {
            return toDoubleArray(obj.toVector());
        }
        if (destClass == boolean[].class) {
            return toBooleanArray(obj.toVector());
        }
        if (destClass == String[].class) {
            return toStringArray(obj.toVector(), charset);
        }
        return obj;
    }

    static private Object castNumber(Object obj, Class destClass) {
            byte b = 0;
            short s = 0;
            int i = 0;
            long l = 0;
            float f = 0;
            double d = 0;
            if (obj instanceof Byte) {
                b = ((Byte) obj).byteValue();
                d = f = l = i = s = b;
            }
            if (obj instanceof Short) {
                s = ((Short) obj).shortValue();
                b = (byte) s;
                d = f = l = i = s;
            }
            if (obj instanceof Integer) {
                b = ((Integer) obj).byteValue();
                s = ((Integer) obj).shortValue();
                i = ((Integer) obj).intValue();
                l = ((Integer) obj).longValue();
                f = ((Integer) obj).floatValue();
                d = ((Integer) obj).doubleValue();
            }
            if (obj instanceof Long) {
                l = ((Long) obj).longValue();
                i = (int) l;
                s = (short) l;
                b = (byte) l;
                f = ((Long) obj).floatValue();
                d = ((Long) obj).doubleValue();
            }
            if (obj instanceof Float) {
                b = ((Float) obj).byteValue();
                s = ((Float) obj).shortValue();
                i = ((Float) obj).intValue();
                l = ((Float) obj).longValue();
                f = ((Float) obj).floatValue();
                d = ((Float) obj).doubleValue();
            }
            if (obj instanceof Double) {
                b = ((Double) obj).byteValue();
                s = ((Double) obj).shortValue();
                i = ((Double) obj).intValue();
                l = ((Double) obj).longValue();
                f = ((Double) obj).floatValue();
                d = ((Double) obj).doubleValue();
            }
            if (destClass == Byte.class) {
                return new Byte(b);
            }
            if (destClass == Short.class) {
                return new Short(s);
            }
            if (destClass == Integer.class) {
                return new Integer(i);
            }
            if (destClass == Long.class) {
                return new Long(l);
            }
            if (destClass == Float.class) {
                return new Float(f);
            }
            if (destClass == Double.class) {
                return new Double(d);
            }
            if (destClass == Boolean.class) {
                return new Boolean(b != 0);
            }
            return obj;
    }

    static public Object cast(Object obj, Class destClass, String charset) {
        if (obj == null || destClass == null) {
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
        if (destClass == Character.class) {
            return new Character(obj.toString().charAt(0));
        }
        if ((obj instanceof Calendar) && (destClass == Date.class)) {
            return ((Calendar)obj).getTime();
        }
        if (obj instanceof AssocArray) {
            return cast((AssocArray) obj, destClass, charset);
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
        if ((obj instanceof Boolean)) {
            obj = new Integer((((Boolean) obj).booleanValue() == true) ? 1 : 0);
        }
        if (isNumber(obj)) {
            return castNumber(obj, destClass);
        }
        return obj;
    }

    static public Object cast(Object obj, Class destClass) {
        return cast(obj, destClass, "utf-8");
    }

    static public Object[] toArray(Vector v) {
        Object[] result = new Object[v.size()];
        v.copyInto(result);
        return result;
    }

    static public byte[] toByteArray(Vector v) {
        int n = v.size();
        byte[] result = new byte[n];
        for (int i = 0; i < n; i++) {
            result[i] = ((Integer)v.elementAt(i)).byteValue();
        }
        return result;
    }

    static public short[] toShortArray(Vector v) {
        int n = v.size();
        short[] result = new short[n];
        for (int i = 0; i < n; i++) {
            result[i] = ((Integer)v.elementAt(i)).shortValue();
        }
        return result;
    }

    static public int[] toIntArray(Vector v) {
        int n = v.size();
        int[] result = new int[n];
        for (int i = 0; i < n; i++) {
            result[i] = ((Integer)v.elementAt(i)).intValue();
        }
        return result;
    }

    static public char[] toCharArray(Vector v) {
        int n = v.size();
        char[] result = new char[n];
        for (int i = 0; i < n; i++) {
            result[i] = (char)((Integer)v.elementAt(i)).intValue();
        }
        return result;
    }

    static public long[] toLongArray(Vector v) {
        int n = v.size();
        long[] result = new long[n];
        for (int i = 0; i < n; i++) {
            result[i] = ((Long)castNumber(v.elementAt(i), Long.class)).longValue();
        }
        return result;
    }

    static public float[] toFloatArray(Vector v) {
        int n = v.size();
        float[] result = new float[n];
        for (int i = 0; i < n; i++) {
            result[i] = ((Float)castNumber(v.elementAt(i), Float.class)).floatValue();
        }
        return result;
    }

    static public double[] toDoubleArray(Vector v) {
        int n = v.size();
        double[] result = new double[n];
        for (int i = 0; i < n; i++) {
            result[i] = ((Double)castNumber(v.elementAt(i), Double.class)).doubleValue();
        }
        return result;
    }

    static public boolean[] toBooleanArray(Vector v) {
        int n = v.size();
        boolean[] result = new boolean[n];
        for (int i = 0; i < n; i++) {
            result[i] = ((Boolean)v.elementAt(i)).booleanValue();
        }
        return result;
    }

    static public String[] toStringArray(Vector v, String charset) {
        int n = v.size();
        String[] result = new String[n];
        for (int i = 0; i < n; i++) {
            result[i] = (String)Cast.cast(v.elementAt(i), String.class, charset);
        }
        return result;
    }
}