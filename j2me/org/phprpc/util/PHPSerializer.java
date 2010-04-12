/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPSerializer.java                                       |
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

/* PHP serialize/unserialize library for J2ME.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
package org.phprpc.util;

import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.util.Calendar;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Vector;

public final class PHPSerializer {

    private static final Hashtable clscache = new Hashtable();
    private static final byte __Quote = 34;
    private static final byte __0 = 48;
    private static final byte __1 = 49;
    private static final byte __Colon = 58;
    private static final byte __Semicolon = 59;
    private static final byte __C = 67;
    private static final byte __N = 78;
    private static final byte __O = 79;
    private static final byte __R = 82;
    private static final byte __S = 83;
    private static final byte __U = 85;
    private static final byte __Slash = 92;
    private static final byte __a = 97;
    private static final byte __b = 98;
    private static final byte __d = 100;
    private static final byte __i = 105;
    private static final byte __r = 114;
    private static final byte __s = 115;
    private static final byte __LeftB = 123;
    private static final byte __RightB = 125;
    private static final String __NAN = "NAN";
    private static final String __INF = "INF";
    private static final String __NINF = "-INF";
    private String charset = "UTF-8";

    public PHPSerializer() {
        clscache.put("stdClass", stdClass.class);
    }

    public String getCharset() {
        return charset;
    }

    public void setCharset(String charset) {
        this.charset = charset;
    }

    public byte[] serialize(Object obj) {
        Hashtable ht = new Hashtable();
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        serialize(stream, obj, ht, 1);
        byte[] result = stream.toByteArray();
        return result;
    }

    private int serialize(ByteArrayOutputStream stream, Object obj, Hashtable ht, int hv) {
        if (obj == null) {
            hv++;
            writeNull(stream);
        } else if (obj instanceof Boolean) {
            hv++;
            writeBoolean(stream, ((Boolean) obj).booleanValue() ? __1 : __0);
        } else if ((obj instanceof Byte) ||
                (obj instanceof Short) ||
                (obj instanceof Integer)) {
            hv++;
            writeInteger(stream, getAsciiBytes(obj));
        } else if (obj instanceof Long) {
            hv++;
            writeDouble(stream, getAsciiBytes(obj));
        } else if (obj instanceof Float) {
            hv++;
            Float f = (Float) obj;
            obj = f.isNaN() ? __NAN : (!f.isInfinite() ? obj : (f.floatValue() > 0 ? __INF : __NINF));
            writeDouble(stream, getAsciiBytes(obj));
        } else if (obj instanceof Double) {
            hv++;
            Double d = (Double) obj;
            obj = d.isNaN() ? __NAN : (!d.isInfinite() ? obj : (d.doubleValue() > 0 ? __INF : __NINF));
            writeDouble(stream, getAsciiBytes(obj));
        } else if (obj instanceof byte[]) {
            if (ht.containsKey(obj)) {
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                writeString(stream, (byte[])obj);
            }
            hv++;
        } else if (obj instanceof char[]) {
            if (ht.containsKey(obj)) {
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                writeString(stream, getBytes(new String((char[]) obj)));
            }
            hv++;
        } else if ((obj instanceof Character) ||
                (obj instanceof String) ||
                (obj instanceof StringBuffer)) {
            if (ht.containsKey(obj)) {
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                writeString(stream, getBytes(obj));
            }
            hv++;
        } else if (obj instanceof BigInteger) {
            if (ht.containsKey(obj)) {
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                writeString(stream, getAsciiBytes(obj));
            }
            hv++;
        } else if (obj instanceof Date) {
            if (ht.containsKey(obj)) {
                hv++;
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                hv += 8;
                writeDate(stream, (Date)obj);
            }
        } else if (obj instanceof Calendar) {
            if (ht.containsKey(obj)) {
                hv++;
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                hv += 8;
                writeCalendar(stream, (Calendar)obj);
            }
        } else if (obj instanceof short[]) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                writeShortArray(stream, (short[]) obj, hv);
            }
        } else if (obj instanceof int[]) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                writeIntArray(stream, (int[]) obj, hv);
            }
        } else if (obj instanceof long[]) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                writeLongArray(stream, (long[]) obj, hv);
            }
        } else if (obj instanceof float[]) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                writeFloatArray(stream, (float[]) obj, hv);
            }
        } else if (obj instanceof double[]) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                writeDoubleArray(stream, (double[]) obj, hv);
            }
        } else if (obj instanceof boolean[]) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                writeBooleanArray(stream, (boolean[]) obj, hv);
            }
        } else if (obj instanceof String[]) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                writeStringArray(stream, (String[]) obj, hv);
            }
        } else if (obj instanceof Object[]) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                hv = writeArray(stream, (Object[]) obj, ht, hv);
            }
        } else if (obj instanceof Vector) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                hv = writeVector(stream, (Vector) obj, ht, hv);
            }
        } else if (obj instanceof Hashtable) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                hv = writeHashtable(stream, (Hashtable) obj, ht, hv);
            }
        } else if (obj instanceof AssocArray) {
            obj = ((AssocArray) obj).toHashtable();
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                hv = writeHashtable(stream, (Hashtable) obj, ht, hv);
            }
        } else {
            if (ht.containsKey(obj)) {
                hv++;
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            } else {
                ht.put(obj, new Integer(hv++));
                hv = writeObject(stream, obj, ht, hv);
            }
        }
        return hv;
    }

    private void writeNull(ByteArrayOutputStream stream) {
        stream.write(__N);
        stream.write(__Semicolon);
    }

    private void writeRef(ByteArrayOutputStream stream, byte[] r) {
        stream.write(__r);
        stream.write(__Colon);
        stream.write(r, 0, r.length);
        stream.write(__Semicolon);
    }

    private void writePointRef(ByteArrayOutputStream stream, byte[] p) {
        stream.write(__R);
        stream.write(__Colon);
        stream.write(p, 0, p.length);
        stream.write(__Semicolon);
    }

    private void writeBoolean(ByteArrayOutputStream stream, byte b) {
        stream.write(__b);
        stream.write(__Colon);
        stream.write(b);
        stream.write(__Semicolon);
    }

    private void writeInteger(ByteArrayOutputStream stream, byte[] i) {
        stream.write(__i);
        stream.write(__Colon);
        stream.write(i, 0, i.length);
        stream.write(__Semicolon);
    }

    private void writeDouble(ByteArrayOutputStream stream, byte[] d) {
        stream.write(__d);
        stream.write(__Colon);
        stream.write(d, 0, d.length);
        stream.write(__Semicolon);
    }

    private void writeString(ByteArrayOutputStream stream, byte[] s) {
        byte[] slen = getAsciiBytes(new Integer(s.length));
        stream.write(__s);
        stream.write(__Colon);
        stream.write(slen, 0, slen.length);
        stream.write(__Colon);
        stream.write(__Quote);
        stream.write(s, 0, s.length);
        stream.write(__Quote);
        stream.write(__Semicolon);
    }

    private void writeCalendar(ByteArrayOutputStream stream, Calendar calendar) {
        byte[] typeName = getBytes("PHPRPC_Date");
        byte[] classNameLen = getAsciiBytes(new Integer(typeName.length));
        stream.write(__O);
        stream.write(__Colon);
        stream.write(classNameLen, 0, classNameLen.length);
        stream.write(__Colon);
        stream.write(__Quote);
        stream.write(typeName, 0, typeName.length);
        stream.write(__Quote);
        stream.write(__Colon);
        stream.write(0x37);
        stream.write(__Colon);
        stream.write(__LeftB);
        writeString(stream, getBytes("year"));
        writeInteger(stream, getAsciiBytes(new Integer(calendar.get(Calendar.YEAR))));
        writeString(stream, getBytes("month"));
        writeInteger(stream, getAsciiBytes(new Integer(calendar.get(Calendar.MONTH) + 1)));
        writeString(stream, getBytes("day"));
        writeInteger(stream, getAsciiBytes(new Integer(calendar.get(Calendar.DATE))));
        writeString(stream, getBytes("hour"));
        writeInteger(stream, getAsciiBytes(new Integer(calendar.get(Calendar.HOUR_OF_DAY))));
        writeString(stream, getBytes("minute"));
        writeInteger(stream, getAsciiBytes(new Integer(calendar.get(Calendar.MINUTE))));
        writeString(stream, getBytes("second"));
        writeInteger(stream, getAsciiBytes(new Integer(calendar.get(Calendar.SECOND))));
        writeString(stream, getBytes("millisecond"));
        writeInteger(stream, getAsciiBytes(new Integer(0)));
        stream.write(__RightB);
    }

    private void writeDate(ByteArrayOutputStream stream, Date date) {
        Calendar calendar = Calendar.getInstance();
        calendar.setTime(date);
        writeCalendar(stream, calendar);
    }

    private int writeArray(ByteArrayOutputStream stream, Object[] a, Hashtable ht, int hv) {
        int len = a.length;
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            hv = serialize(stream, a[i], ht, hv);
        }
        stream.write(__RightB);
        return hv;
    }

    private int writeShortArray(ByteArrayOutputStream stream, short[] a, int hv) {
        int len = a.length;
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            writeInteger(stream, getAsciiBytes(new Short(a[i])));
        }
        stream.write(__RightB);
        return hv + len;
    }

    private int writeIntArray(ByteArrayOutputStream stream, int[] a, int hv) {
        int len = a.length;
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            writeInteger(stream, getAsciiBytes(new Integer(a[i])));
        }
        stream.write(__RightB);
        return hv + len;
    }

    private int writeLongArray(ByteArrayOutputStream stream, long[] a, int hv) {
        int len = a.length;
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            writeDouble(stream, getAsciiBytes(new Long(a[i])));
        }
        stream.write(__RightB);
        return hv + len;
    }

    private int writeFloatArray(ByteArrayOutputStream stream, float[] a, int hv) {
        int len = a.length;
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        Object obj;
        Float f;
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            obj = f = new Float(a[i]);
            obj = f.isNaN() ? __NAN : (!f.isInfinite() ? obj : (f.floatValue() > 0 ? __INF : __NINF));
            writeDouble(stream, getAsciiBytes(obj));
        }
        stream.write(__RightB);
        return hv + len;
    }

    private int writeDoubleArray(ByteArrayOutputStream stream, double[] a, int hv) {
        int len = a.length;
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        Object obj;
        Double d;
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            obj = d = new Double(a[i]);
            obj = d.isNaN() ? __NAN : (!d.isInfinite() ? obj : (d.floatValue() > 0 ? __INF : __NINF));
            writeDouble(stream, getAsciiBytes(obj));
        }
        stream.write(__RightB);
        return hv + len;
    }

    private int writeBooleanArray(ByteArrayOutputStream stream, boolean[] a, int hv) {
        int len = a.length;
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            writeBoolean(stream, new Boolean(a[i]).booleanValue() ? __1 : __0);
        }
        stream.write(__RightB);
        return hv + len;
    }

    private int writeStringArray(ByteArrayOutputStream stream, String[] a, int hv) {
        int len = a.length;
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            writeString(stream, getBytes(a[i]));
        }
        stream.write(__RightB);
        return hv + len;
    }

    private int writeVector(ByteArrayOutputStream stream, Vector a, Hashtable ht, int hv) {
        int len = a.size();
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            hv = serialize(stream, a.elementAt(i), ht, hv);
        }
        stream.write(__RightB);
        return hv;
    }

    private int writeHashtable(ByteArrayOutputStream stream, Hashtable h, Hashtable ht, int hv) {
        int len = h.size();
        byte[] hlen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(hlen, 0, hlen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (Enumeration keys = h.keys(); keys.hasMoreElements();) {
            Object key = keys.nextElement();
            if ((key instanceof Byte) ||
                    (key instanceof Short) ||
                    (key instanceof Integer)) {
                writeInteger(stream, getAsciiBytes(key));
            } else if (key instanceof Boolean) {
                writeInteger(stream, new byte[]{((Boolean) key).booleanValue() ? __1 : __0});
            } else {
                writeString(stream, getBytes(key));
            }
            hv = serialize(stream, h.get(key), ht, hv);
        }
        stream.write(__RightB);
        return hv;
    }

    private int writeObject(ByteArrayOutputStream stream, Object obj, Hashtable ht, int hv) {
        Class cls = obj.getClass();
        byte[] className;
        if (cls == stdClass.class) {
            className = getBytes("stdClass");
        } else {
            className = getBytes(getClassName(cls));
        }
        byte[] classNameLen = getAsciiBytes(new Integer(className.length));
        if (obj instanceof org.phprpc.util.stdClass) {
            stdClass o = (stdClass) obj;
            String[] fields = o.__sleep();
            int length = fields.length;
            byte[] flen = getAsciiBytes(new Integer(length));
            stream.write(__O);
            stream.write(__Colon);
            stream.write(classNameLen, 0, classNameLen.length);
            stream.write(__Colon);
            stream.write(__Quote);
            stream.write(className, 0, className.length);
            stream.write(__Quote);
            stream.write(__Colon);
            stream.write(flen, 0, flen.length);
            stream.write(__Colon);
            stream.write(__LeftB);
            for (int i = 0; i < length; i++) {
                writeString(stream, getBytes(fields[i]));
                hv = serialize(stream, o.get(fields[i]), ht, hv);
            }
            stream.write(__RightB);
        }
        if (obj instanceof org.phprpc.util.Serializable) {
            byte[] cs = ((org.phprpc.util.Serializable) obj).serialize();
            byte[] cslen = getAsciiBytes(new Integer(cs.length));
            stream.write(__C);
            stream.write(__Colon);
            stream.write(classNameLen, 0, classNameLen.length);
            stream.write(__Colon);
            stream.write(__Quote);
            stream.write(className, 0, className.length);
            stream.write(__Quote);
            stream.write(__Colon);
            stream.write(cslen, 0, cslen.length);
            stream.write(__Colon);
            stream.write(__LeftB);
            stream.write(cs, 0, cs.length);
            stream.write(__RightB);
        } else {
            writeNull(stream);
        }
        return hv;
    }

    private byte[] getBytes(Object obj) {
        try {
            return obj.toString().getBytes(charset);
        } catch (Exception e) {
            return obj.toString().getBytes();
        }
    }

    private byte[] getAsciiBytes(Object obj) {
        try {
            return obj.toString().getBytes("US-ASCII");
        } catch (Exception e) {
            return null;
        }
    }

    private String getString(byte[] b) {
        try {
            return new String(b, charset);
        } catch (Exception e) {
            return new String(b);
        }
    }

    private Class getInnerClass(StringBuffer className, int[] pos, int i, char c) {
        if (i < pos.length) {
            int p = pos[i];
            className.setCharAt(p, c);
            Class cls = getInnerClass(className, pos, i + 1, '_');
            if (i + 1 < pos.length && cls == null) {
                cls = getInnerClass(className, pos, i + 1, '$');
            }
            return cls;
        } else {
            try {
                return Class.forName(className.toString());
            } catch (Exception e) {
                return null;
            }
        }
    }

    private Class getClass(StringBuffer className, int[] pos, int i, char c) {
        if (i < pos.length) {
            int p = pos[i];
            className.setCharAt(p, c);
            Class cls = getClass(className, pos, i + 1, '.');
            if (i + 1 < pos.length) {
                if (cls == null) {
                    cls = getClass(className, pos, i + 1, '_');
                }
                if (cls == null) {
                    cls = getInnerClass(className, pos, i + 1, '$');
                }
            }
            return cls;
        } else {
            try {
                return Class.forName(className.toString());
            } catch (Exception e) {
                return null;
            }
        }
    }

    public Class getClass(String className) {
        if (clscache.containsKey(className)) {
            return (Class) clscache.get(className);
        }
        StringBuffer cn = new StringBuffer(className);
        Vector v = new Vector();
        int p = className.indexOf(" ");
        while (p > -1) {
            v.addElement(new Integer(p));
            p = className.indexOf("_", p + 1);
        }
        Class cls = null;
        if (v.size() > 0) {
            try {
                int[] pos = Cast.toIntArray(v);
                cls = getClass(cn, pos, 0, '.');
                if (cls == null) {
                    cls = getClass(cn, pos, 0, '_');
                }
                if (cls == null) {
                    cls = getInnerClass(cn, pos, 0, '$');
                }
            } catch (Exception e) {
            }
        } else {
            try {
                cls = Class.forName(className.toString());
            } catch (Exception e) {
            }
        }
        clscache.put(className, cls);
        return cls;
    }

    private String getClassName(Class cls) {
        return cls.getName().replace('.', '_').replace('$', '_');
    }

    public static Object newInstance(Class cls) {
        try {
            Object obj = cls.newInstance();
            if (obj instanceof stdClass || obj instanceof Serializable) {
                return obj;
            } else {
                return null;
            }
        } catch (Exception e) {
            return null;
        }
    }

    public Object unserialize(byte[] ss) throws IllegalAccessException {
        return unserialize(ss, Object.class);
    }

    public Object unserialize(byte[] ss, Class cls) throws IllegalAccessException {
        ByteArrayInputStream stream = new ByteArrayInputStream(ss);
        Object result = unserialize(stream, new Vector());
        return Cast.cast(result, cls, charset);
    }

    private Object unserialize(ByteArrayInputStream stream, Vector objectContainer) throws IllegalAccessException {
        Object obj;
        switch (stream.read()) {
            case __N:
                obj = readNull(stream);
                objectContainer.addElement(obj);
                return obj;
            case __b:
                obj = readBoolean(stream);
                objectContainer.addElement(obj);
                return obj;
            case __i:
                obj = readInteger(stream);
                objectContainer.addElement(obj);
                return obj;
            case __d:
                obj = readDouble(stream);
                objectContainer.addElement(obj);
                return obj;
            case __s:
                obj = readString(stream);
                objectContainer.addElement(obj);
                return obj;
            case __S:
                obj = readEscapedString(stream);
                objectContainer.addElement(obj);
                return obj;
            case __U:
                obj = readUnicodeString(stream);
                objectContainer.addElement(obj);
                return obj;
            case __r:
                return readRef(stream, objectContainer);
            case __R:
                return readPointRef(stream, objectContainer);
            case __a:
                return readAssocArray(stream, objectContainer);
            case __O:
                return readObject(stream, objectContainer);
            case __C:
                return readCustomObject(stream, objectContainer);
            default:
                return null;
        }
    }

    private String readNumber(ByteArrayInputStream stream) {
        StringBuffer sb = new StringBuffer();
        int i = stream.read();
        while ((i != __Semicolon) && (i != __Colon)) {
            sb.append((char) i);
            i = stream.read();
        }
        return sb.toString();
    }

    private Object readNull(ByteArrayInputStream stream) {
        stream.skip(1);
        return null;
    }

    private Boolean readBoolean(ByteArrayInputStream stream) {
        stream.skip(1);
        Boolean b = new Boolean(stream.read() == __1);
        stream.skip(1);
        return b;
    }

    private Integer readInteger(ByteArrayInputStream stream) {
        stream.skip(1);
        return new Integer(Integer.parseInt(readNumber(stream)));
    }

    private Object readDouble(ByteArrayInputStream stream) {
        stream.skip(1);
        String d = readNumber(stream);
        if (d.equals(__NAN)) {
            return new Double(Double.NaN);
        }
        if (d.equals(__INF)) {
            return new Double(Double.POSITIVE_INFINITY);
        }
        if (d.equals(__NINF)) {
            return new Double(Double.NEGATIVE_INFINITY);
        }
        if ((d.indexOf('.') > 0) || (d.indexOf('e') > 0) || (d.indexOf('E') > 0)) {
            return new Double(Double.parseDouble(d));
        }
        try {
            return new Long(Long.parseLong(d));
        }
        catch (Exception e) {
            return new Double(Double.parseDouble(d));
        }
    }

    private byte[] readString(ByteArrayInputStream stream) {
        stream.skip(1);
        int len = Integer.parseInt(readNumber(stream));
        stream.skip(1);
        byte[] buf = new byte[len];
        stream.read(buf, 0, len);
        stream.skip(2);
        return buf;
    }

    private byte[] readEscapedString(ByteArrayInputStream stream) {
        stream.skip(1);
        int len = Integer.parseInt(readNumber(stream));
        stream.skip(1);
        byte[] buf = new byte[len];
        int c;
        for (int i = 0; i < len; i++) {
            if ((c = stream.read()) == __Slash) {
                char c1 = (char) stream.read();
                char c2 = (char) stream.read();
                buf[i] = (byte) (Integer.parseInt(new String(new char[]{c1, c2}), 16) & 0xff);
            } else {
                buf[i] = (byte) (c & 0xff);
            }
        }
        stream.skip(2);
        return buf;
    }

    private String readUnicodeString(ByteArrayInputStream stream) {
        stream.skip(1);
        int len = Integer.parseInt(readNumber(stream));
        stream.skip(1);
        StringBuffer sb = new StringBuffer(len);
        int c;
        for (int i = 0; i < len; i++) {
            if ((c = stream.read()) == __Slash) {
                char c1 = (char) stream.read();
                char c2 = (char) stream.read();
                char c3 = (char) stream.read();
                char c4 = (char) stream.read();
                sb.append(
                        (char) (Integer.parseInt(
                        new String(new char[]{c1, c2, c3, c4}), 16)));
            } else {
                sb.append((char) c);
            }
        }
        stream.skip(2);
        return sb.toString();
    }

    private Object readRef(ByteArrayInputStream stream, Vector objectContainer) {
        stream.skip(1);
        Object obj = objectContainer.elementAt(Integer.parseInt(readNumber(stream)) - 1);
        objectContainer.addElement(obj);
        return obj;
    }

    private Object readPointRef(ByteArrayInputStream stream, Vector objectContainer) {
        stream.skip(1);
        Object obj = objectContainer.elementAt(Integer.parseInt(readNumber(stream)) - 1);
        return obj;
    }

    private Object readAssocArray(ByteArrayInputStream stream, Vector objectContainer) throws IllegalAccessException {
        stream.skip(1);
        int n = Integer.parseInt(readNumber(stream));
        stream.skip(1);
        AssocArray a = new AssocArray(n);
        objectContainer.addElement(a);
        for (int i = 0; i < n; i++) {
            Object key;
            switch (stream.read()) {
                case __i:
                    key = Cast.cast(readInteger(stream), Integer.class);
                    break;
                case __s:
                    key = Cast.cast(readString(stream), String.class, charset);
                    break;
                case __S:
                    key = Cast.cast(readEscapedString(stream), String.class, charset);
                    break;
                case __U:
                    key = readUnicodeString(stream);
                    break;
                default:
                    return null;
            }
            Object result = unserialize(stream, objectContainer);
            if (key instanceof Integer) {
                a.set((Integer) key, result);
            } else {
                a.set((String) key, result);
            }
        }
        stream.skip(1);
        return a;
    }

    private Calendar readCalendar(ByteArrayInputStream stream, Vector objectContainer, int n) {
        Hashtable dt = new Hashtable(n);
        String key;
        for (int i = 0; i < n; i++) {
            switch (stream.read()) {
                case __s:
                    key = getString(readString(stream));
                    break;
                case __S:
                    key = getString(readEscapedString(stream));
                    break;
                case __U:
                    key = readUnicodeString(stream);
                    break;
                default:
                    return null;
            }
            if (stream.read() == __i) {
                dt.put(key, Cast.cast(readInteger(stream), Integer.class));
            } else {
                return null;
            }
        }
        stream.skip(1);
        Calendar calendar = Calendar.getInstance();
        calendar.set(Calendar.YEAR, ((Integer) dt.get("year")).intValue());
        calendar.set(Calendar.MONTH, ((Integer) dt.get("month")).intValue() - 1);
        calendar.set(Calendar.DATE, ((Integer) dt.get("day")).intValue());
        calendar.set(Calendar.HOUR_OF_DAY, ((Integer) dt.get("hour")).intValue());
        calendar.set(Calendar.MINUTE, ((Integer) dt.get("minute")).intValue());
        calendar.set(Calendar.SECOND, ((Integer) dt.get("second")).intValue());
        objectContainer.addElement(calendar);
        objectContainer.addElement(dt.get("year"));
        objectContainer.addElement(dt.get("month"));
        objectContainer.addElement(dt.get("day"));
        objectContainer.addElement(dt.get("hour"));
        objectContainer.addElement(dt.get("minute"));
        objectContainer.addElement(dt.get("second"));
        objectContainer.addElement(dt.get("millisecond"));
        return calendar;
    }

    private Object readObject(ByteArrayInputStream stream, Vector objectContainer) throws IllegalAccessException {
        stream.skip(1);
        int len = Integer.parseInt(readNumber(stream));
        stream.skip(1);
        byte[] buf = new byte[len];
        stream.read(buf, 0, len);
        String cn = getString(buf);
        stream.skip(2);
        int n = Integer.parseInt(readNumber(stream));
        stream.skip(1);
        if (cn.equals("PHPRPC_Date")) {
            return readCalendar(stream, objectContainer, n);
        }
        Class cls = getClass(cn);
        Object o;
        if (cls != null) {
            if ((o = newInstance(cls)) == null) {
                o = new Hashtable(n);
            }
        } else {
            o = new Hashtable(n);
        }
        objectContainer.addElement(o);
        for (int i = 0; i < n; i++) {
            String key;
            switch (stream.read()) {
                case __s:
                    key = getString(readString(stream));
                    break;
                case __S:
                    key = getString(readEscapedString(stream));
                    break;
                case __U:
                    key = readUnicodeString(stream);
                    break;
                default:
                    return null;
            }
            if (key.charAt(0) == (char) 0) {
                key = key.substring(key.indexOf("\0", 1) + 1);
            }
            Object result = unserialize(stream, objectContainer);
            if (o instanceof Hashtable) {
                ((Hashtable) o).put(key, result);
            } else {
                ((stdClass) o).set(key, result);
            }
        }
        stream.skip(1);
        if (o instanceof stdClass) {
            ((stdClass) o).__wakeup();
        }
        return o;
    }

    private Object readCustomObject(ByteArrayInputStream stream, Vector objectContainer) {
        stream.skip(1);
        int len = Integer.parseInt(readNumber(stream));
        stream.skip(1);
        byte[] buf = new byte[len];
        stream.read(buf, 0, len);
        String cn = getString(buf);
        stream.skip(2);
        int n = Integer.parseInt(readNumber(stream));
        stream.skip(1);
        Class cls = getClass(cn);
        Object o;
        if (cls != null) {
            o = newInstance(cls);
        } else {
            o = null;
        }
        objectContainer.addElement(o);
        if (o == null) {
            stream.skip(n);
        } else if (o instanceof org.phprpc.util.Serializable) {
            byte[] b = new byte[n];
            stream.read(b, 0, n);
            ((org.phprpc.util.Serializable) o).unserialize(b);
        } else {
            stream.skip(n);
        }
        stream.skip(1);
        return o;
    }
}
