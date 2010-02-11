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
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* PHP serialize/unserialize library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Apr 26, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */

package org.phprpc.util;

import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ObjectStreamClass;
import java.lang.reflect.Array;
import java.lang.reflect.Field;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Collection;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

public final class PHPSerializer {
    private static final HashMap clscache = new HashMap();
    private static final HashMap fieldcache = new HashMap();
    private static final HashMap __sleepcache = new HashMap();
    private static final HashMap __wakeupcache = new HashMap();
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

    private static Class enumClass;
    private static Field enumOrdinal;

    static {
        try {
            enumClass = Class.forName("java.lang.Enum");
            enumOrdinal = enumClass.getDeclaredField("ordinal");
            enumOrdinal.setAccessible(true);
        }
        catch (Exception e) {
            enumClass = null;
            enumOrdinal = null;
        }
    }

    public PHPSerializer() {}

    public String getCharset() {
        return charset;
    }

    public void setCharset(String charset) {
        this.charset = charset;
    }

    public byte[] serialize(Object obj) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        HashMap ht = new HashMap();
        ByteArrayOutputStream stream = new ByteArrayOutputStream();
        int hv = serialize(stream, obj, ht, 1);
        byte[] result = stream.toByteArray();
        return result;
    }

    private int serialize(ByteArrayOutputStream stream, Object obj, HashMap ht, int hv) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        if (obj == null) {
            hv++;
            writeNull(stream);
        }
        else if (obj instanceof Boolean) {
            hv++;
            writeBoolean(stream, ((Boolean) obj).booleanValue() ? __1 : __0);
        }
        else if ((obj instanceof Byte) ||
                 (obj instanceof Short) ||
                 (obj instanceof Integer)) {
            hv++;
            writeInteger(stream, getAsciiBytes(obj));
        }
        else if (obj instanceof Long) {
            hv++;
            writeDouble(stream, getAsciiBytes(obj));
        }
        else if (obj instanceof Float) {
            hv++;
            Float f = (Float) obj;
            obj = f.isNaN() ? __NAN :
                 (!f.isInfinite() ? obj :
                 (f.floatValue() > 0 ? __INF : __NINF));
            writeDouble(stream, getAsciiBytes(obj));
        }
        else if (obj instanceof Double) {
            hv++;
            Double d = (Double) obj;
            obj = d.isNaN() ? __NAN :
                 (!d.isInfinite() ? obj :
                 (d.doubleValue() > 0 ? __INF : __NINF));
            writeDouble(stream, getAsciiBytes(obj));
        }
        else if (obj instanceof byte[]) {
            if (ht.containsKey(obj)) {
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                writeString(stream, (byte[])obj);
            }
            hv++;
        }
        else if (obj instanceof char[]) {
            if (ht.containsKey(obj)) {
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                writeString(stream, getBytes(new String((char[]) obj)));
            }
            hv++;
        }
        else if ((obj instanceof Character) ||
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
        }
        else if ((obj instanceof BigInteger) ||
                (obj instanceof BigDecimal) ||
                (obj instanceof Number)) {
           if (ht.containsKey(obj)) {
               writeRef(stream, getAsciiBytes(ht.get(obj)));
           }
           else {
               ht.put(obj, new Integer(hv));
               writeString(stream, getAsciiBytes(obj));
           }
           hv++;
        }
        else if (obj instanceof Date) {
            if (ht.containsKey(obj)) {
                hv++;
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                hv += 8;
                writeDate(stream, (Date)obj);
            }
        }
        else if (obj instanceof Calendar) {
            if (ht.containsKey(obj)) {
                hv++;
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv));
                hv += 8;
                writeCalendar(stream, (Calendar)obj);
            }
        }
        else if (!(obj instanceof java.io.Serializable)) {
            writeNull(stream);
        }
        else if (obj instanceof AssocArray) {
            obj = ((AssocArray)obj).toHashMap();
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv++));
                hv = writeMap(stream, (Map) obj, ht, hv);
            }
        }
        else if (obj.getClass().isArray()) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv++));
                hv = writeArray(stream, obj, ht, hv);
            }
        }
        else if (obj instanceof List) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv++));
                hv = writeList(stream, (List) obj, ht, hv);
            }
        }
        else if (obj instanceof Collection) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv++));
                hv = writeCollection(stream, (Collection) obj, ht, hv);
            }
        }
        else if (obj instanceof Map) {
            if (ht.containsKey(obj)) {
                writePointRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
                ht.put(obj, new Integer(hv++));
                hv = writeMap(stream, (Map) obj, ht, hv);
            }
        }
        else if ((enumClass != null) && enumClass.isAssignableFrom(obj.getClass())) {
            hv++;
            writeInteger(stream, getAsciiBytes(enumOrdinal.get(obj)));
        }
        else {
            if (ht.containsKey(obj)) {
                hv++;
                writeRef(stream, getAsciiBytes(ht.get(obj)));
            }
            else {
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
        GregorianCalendar calendar = new GregorianCalendar();
        calendar.setTime(date);
        writeCalendar(stream, calendar);
    }

    private int writeArray(ByteArrayOutputStream stream, Object a, HashMap ht, int hv) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        int len = Array.getLength(a);
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            hv = serialize(stream, Array.get(a, i), ht, hv);
        }
        stream.write(__RightB);
        return hv;
    }

    private int writeCollection(ByteArrayOutputStream stream, Collection c, HashMap ht, int hv) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        int len = c.size();
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        int i = 0;
        for (Iterator values = c.iterator(); values.hasNext();) {
            writeInteger(stream, getAsciiBytes(new Integer(i++)));
            Object value = values.next();
            hv = serialize(stream, value, ht, hv);
        }
        stream.write(__RightB);
        return hv;
    }

    private int writeList(ByteArrayOutputStream stream, List a, HashMap ht, int hv) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        int len = a.size();
        byte[] alen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(alen, 0, alen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (int i = 0; i < len; i++) {
            writeInteger(stream, getAsciiBytes(new Integer(i)));
            hv = serialize(stream, a.get(i), ht, hv);
        }
        stream.write(__RightB);
        return hv;
    }

    private int writeMap(ByteArrayOutputStream stream, Map h, HashMap ht, int hv) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        int len = h.size();
        byte[] hlen = getAsciiBytes(new Integer(len));
        stream.write(__a);
        stream.write(__Colon);
        stream.write(hlen, 0, hlen.length);
        stream.write(__Colon);
        stream.write(__LeftB);
        for (Iterator keys = h.keySet().iterator(); keys.hasNext();) {
            Object key = keys.next();
            if ((key instanceof Byte) ||
                (key instanceof Short) ||
                (key instanceof Integer)) {
                writeInteger(stream, getAsciiBytes(key));
            }
            else if (key instanceof Boolean) {
                writeInteger(stream, new byte[] { ((Boolean) key).booleanValue() ? __1 : __0 });
            }
            else {
                writeString(stream, getBytes(key));
            }
            hv = serialize(stream, h.get(key), ht, hv);
        }
        stream.write(__RightB);
        return hv;
    }

    private int writeObject(ByteArrayOutputStream stream, Object obj, HashMap ht, int hv) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        Class cls = obj.getClass();
        byte[] className = getBytes(getClassName(cls));
        byte[] classNameLen = getAsciiBytes(new Integer(className.length));
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
        }
        else {
            HashMap f;
            Method __sleep = null;
            if (fieldcache.containsKey(cls)) {
                f = (HashMap)fieldcache.get(cls);
                // __sleep need to run
                if (__sleepcache.containsKey(cls)) {
                    __sleep = (Method)__sleepcache.get(cls);
                    __sleep.invoke(obj, new Object[0]);
                }
            }
            else {
                try {
                    __sleep = cls.getMethod("__sleep", new Class[0]);
                    __sleep.setAccessible(true);
                    __sleepcache.put(cls, __sleep);
                }
                catch(Exception e) {}
                if (__sleep != null) {
                    String[] fieldNames = (String[])__sleep.invoke(obj, new Object[0]);
                    f = getFields(obj, fieldNames);
                }
                else {
                    f = getFields(obj);
                }
                fieldcache.put(cls, f);
            }
            byte[] flen = getAsciiBytes(new Integer(f.size()));
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
            for (Iterator keys = f.keySet().iterator(); keys.hasNext();) {
                String key = (String)keys.next();
                Object o = ((Field)f.get(key)).get(obj);
                writeString(stream, getBytes(key));
                hv = serialize(stream, o, ht, hv);
            }
            stream.write(__RightB);
        }
        return hv;
    }

    private byte[] getBytes(Object obj) {
        try {
            return obj.toString().getBytes(charset);
        }
        catch (Exception e) {
            return obj.toString().getBytes();
        }
    }

    private byte[] getAsciiBytes(Object obj) {
        try {
            return obj.toString().getBytes("US-ASCII");
        }
        catch (Exception e) {
            return null;
        }
    }

    private String getString(byte[] b) {
        try {
            return new String(b, charset);
        }
        catch (Exception e) {
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
        }
        else {
            try {
                return Class.forName(className.toString());
            }
            catch (Exception e) {
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
        }
        else {
            try {
                return Class.forName(className.toString());
            }
            catch (Exception e) {
                return null;
            }
        }
    }

    public Class getClass(String className) {
        if (clscache.containsKey(className)) {
            return (Class)clscache.get(className);
        }
        StringBuffer cn = new StringBuffer(className);
        ArrayList al = new ArrayList();
        int p = cn.indexOf("_");
        while (p > -1) {
            al.add(new Integer(p));
            p = cn.indexOf("_", p + 1);
        }
        Class cls = null;
        if (al.size() > 0) {
            try {
                int[] pos = (int[])Cast.toArray(al, Integer.TYPE, charset);
                cls = getClass(cn, pos, 0, '.');
                if (cls == null) {
                    cls = getClass(cn, pos, 0, '_');
                }
                if (cls == null) {
                    cls = getInnerClass(cn, pos, 0, '$');
                }
            }
            catch (Exception e) {}
        }
        else {
            try {
                cls = Class.forName(className.toString());
            }
            catch (Exception e) {}
        }
        clscache.put(className, cls);
        return cls;
    }

    public static String getClassName(Class cls) {
        String className = cls.getName().replace('.', '_').replace('$', '_');
        if (!clscache.containsKey(className)) {
            clscache.put(className, cls);
        }
        return className;
    }

    public static Field getField(Object obj, String fieldName) {
        for (Class cls = obj.getClass(); cls != null; cls = cls.getSuperclass()) {
            try {
                Field field = cls.getDeclaredField(fieldName);
                int mod = field.getModifiers();
                if (Modifier.isTransient(mod) || Modifier.isStatic(mod)) {
                    return null;
                }
                field.setAccessible(true);
                return field;
            }
            catch (Exception e) {}
        }
        return null;
    }

    private HashMap getFields(Object obj, String[] fieldNames) {
        if (fieldNames == null) {
            return getFields(obj);
        }
        int n = fieldNames.length;
        HashMap fields = new HashMap(n);
        for (int i = 0; i < n; i++) {
            Field f = getField(obj, fieldNames[i]);
            if (f != null) {
                fields.put(fieldNames[i], f);
            }
        }
        return fields;
    }

    private HashMap getFields(Object obj) {
        HashMap fields = new HashMap();
        for (Class cls = obj.getClass(); cls != null; cls = cls.getSuperclass()) {
            Field[] fs = cls.getDeclaredFields();
            for (int i = 0; i < fs.length; i++) {
                Field field = fs[i];
                int mod = fs[i].getModifiers();
                if (!Modifier.isTransient(mod) && !Modifier.isStatic(mod)) {
                    field.setAccessible(true);
                    if (fields.get(field.getName()) == null) {
                        fields.put(field.getName(), field);
                    }
                }
            }
        }
        return fields;
    }

    public static Object newInstance(Class cls) {
        return newInstance(cls, true);
    }

    private static Object newInstance(Class cls, boolean tryagain) {
        try {
            if (tryagain) {
                return cls.newInstance();
            }
            ObjectStreamClass desc = ObjectStreamClass.lookup(cls);
            Method m = ObjectStreamClass.class.getDeclaredMethod("newInstance", new Class[] {});
            m.setAccessible(true);
            return m.invoke(desc, new Object[] {});
        }
        catch (Exception e) {
            if (tryagain) {
                return newInstance(cls, false);
            }
            else {
                return null;
            }
        }
    }

    public Object unserialize(byte[] ss) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        return unserialize(ss, Object.class);
    }

    public Object unserialize(byte[] ss, Class cls) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        ByteArrayInputStream stream = new ByteArrayInputStream(ss);
        Object result = unserialize(stream, new ArrayList());
        return Cast.cast(result, cls, charset);
    }

    private Object unserialize(ByteArrayInputStream stream, ArrayList objectContainer) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        Object obj;
        switch (stream.read()) {
        case __N:
            obj = readNull(stream);
            objectContainer.add(obj);
            return obj;
        case __b:
            obj = readBoolean(stream);
            objectContainer.add(obj);
            return obj;
        case __i:
            obj = readInteger(stream);
            objectContainer.add(obj);
            return obj;
       case __d:
            obj = readDouble(stream);
            objectContainer.add(obj);
            return obj;
        case __s:
            obj = readString(stream);
            objectContainer.add(obj);
            return obj;
        case __S:
            obj = readEscapedString(stream);
            objectContainer.add(obj);
            return obj;
        case __U:
            obj = readUnicodeString(stream);
            objectContainer.add(obj);
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

    private Number readInteger(ByteArrayInputStream stream) {
        stream.skip(1);
        return new Integer(readNumber(stream));
    }

    private Number readDouble(ByteArrayInputStream stream) {
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
            return new Double(d);
        }
        int len = d.length();
        char c = d.charAt(0);
        if ((len < 19) || ((c == '-') && (len < 20))) {
            return new Long(d);
        }
        if ((len > 20) || ((c != '-') && (len > 19))) {
            return new Double(d);
        }
        try {
            return new Long(d);
        }
        catch (Exception e) {
            return new Double(d);
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
                buf[i] = (byte) (Integer.parseInt(new String(new char[] { c1, c2 }), 16) & 0xff);
            }
            else {
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
                                new String(new char[] { c1, c2, c3, c4 }), 16)));
            }
            else {
                sb.append((char) c);
            }
        }
        stream.skip(2);
        return sb.toString();
    }

    private Object readRef(ByteArrayInputStream stream, ArrayList objectContainer) {
        stream.skip(1);
        Object obj = objectContainer.get(Integer.parseInt(readNumber(stream)) - 1);
        objectContainer.add(obj);
        return obj;
    }

    private Object readPointRef(ByteArrayInputStream stream, ArrayList objectContainer) {
        stream.skip(1);
        return objectContainer.get(Integer.parseInt(readNumber(stream)) - 1);
    }

    private AssocArray readAssocArray(ByteArrayInputStream stream, ArrayList objectContainer) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        stream.skip(1);
        int n = Integer.parseInt(readNumber(stream));
        stream.skip(1);
        AssocArray a = new AssocArray(n);
        objectContainer.add(a);
        for (int i = 0; i < n; i++) {
            Object key;
            switch (stream.read()) {
            case __i:
                key = new Integer(readInteger(stream).intValue());
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
                a.set((Integer)key, result);
            }
            else {
                a.set((String)key, result);
            }
        }
        stream.skip(1);
        return a;
    }

    private Calendar readCalendar(ByteArrayInputStream stream, ArrayList objectContainer, int n) {
        HashMap dt = new HashMap(n);
        String key;
        for (int i = 0; i < n; i++)
        {
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
            }
            else {
                return null;
            }
        }
        stream.skip(1);
        GregorianCalendar calendar = new GregorianCalendar(
            ((Integer) dt.get("year")).intValue(),
            ((Integer) dt.get("month")).intValue() - 1,
            ((Integer) dt.get("day")).intValue(),
            ((Integer) dt.get("hour")).intValue(),
            ((Integer) dt.get("minute")).intValue(),
            ((Integer) dt.get("second")).intValue()
        );
        objectContainer.add(calendar);
        objectContainer.add(dt.get("year"));
        objectContainer.add(dt.get("month"));
        objectContainer.add(dt.get("day"));
        objectContainer.add(dt.get("hour"));
        objectContainer.add(dt.get("minute"));
        objectContainer.add(dt.get("second"));
        objectContainer.add(dt.get("millisecond"));
        return calendar;
    }

    private Object readObject(ByteArrayInputStream stream, ArrayList objectContainer) throws IllegalAccessException, IllegalArgumentException, InvocationTargetException {
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
        HashMap fields = null;
        if (cls != null) {
            if ((o = newInstance(cls)) == null) {
                o = new HashMap(n);
            }
            else {
                fields = (HashMap)fieldcache.get(cls);
            }
        }
        else {
            o = new HashMap(n);
        }
        objectContainer.add(o);
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
            if (o instanceof HashMap) {
                ((HashMap) o).put(key, result);
            }
            else {
                Field f;
                if (fields == null) {
                    f = getField(o, key);
                }
                else {
                    f = (Field)fields.get(key);
                }
                if (f != null) {
                    f.set(o, Cast.cast(result, f.getType(), charset));
                }
            }
        }
        stream.skip(1);
        if (!(o instanceof HashMap)) {
            Method __wakeup = null;
            if (__wakeupcache.containsKey(cls)) {
                __wakeup = (Method)__wakeupcache.get(cls);
            }
            else {
                try {
                    __wakeup = cls.getMethod("__wakeup", new Class[0]);
                    __wakeup.setAccessible(true);
                }
                catch (Exception e) {}
                __wakeupcache.put(cls, __wakeup);
            }
            if (__wakeup != null) {
                __wakeup.invoke(o, new Object[] {});
            }
        }
        return o;
    }

    private Object readCustomObject(ByteArrayInputStream stream, ArrayList objectContainer) {
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
        }
        else {
            o = null;
        }
        objectContainer.add(o);
        if (o == null) {
            stream.skip(n);
        }
        else if (o instanceof org.phprpc.util.Serializable) {
            byte[] b = new byte[n];
            stream.read(b, 0, n);
            ((org.phprpc.util.Serializable) o).unserialize(b);
        }
        else {
            stream.skip(n);
        }
        stream.skip(1);
        return o;
    }
}