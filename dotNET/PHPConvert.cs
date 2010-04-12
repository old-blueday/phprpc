/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPConvert.cs                                            |
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

/* PHP Convert library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

namespace org.phprpc.util {
    using System;
    using System.Text;
    using System.Globalization;
    using System.Collections;
#if !(PocketPC || Smartphone || WindowsCE || NET1)
    using System.Collections.Generic;
#endif
    using System.Reflection;

    public sealed class PHPConvert {
        private static readonly IFormatProvider provider;
        private static readonly Encoding UTF8;
        private static readonly Type typeofArrayList;
        private static readonly Type typeofAssocArray;
        private static readonly Type typeofBoolean;
        private static readonly Type typeofBigInteger;
        private static readonly Type typeofByte;
        private static readonly Type typeofByteArray;
        private static readonly Type typeofChar;
        private static readonly Type typeofCharArray;
        private static readonly Type typeofDateTime;
        private static readonly Type typeofDBNull;
        private static readonly Type typeofDecimal;
        private static readonly Type typeofDouble;
        private static readonly Type typeofHashtable;
        private static readonly Type typeofICollection;
        private static readonly Type typeofIDictionary;
        private static readonly Type typeofIList;
        private static readonly Type typeofInt16;
        private static readonly Type typeofInt32;
        private static readonly Type typeofInt64;
        private static readonly Type typeofObject;
        private static readonly Type typeofObjectArray;
        private static readonly Type typeofSByte;
        private static readonly Type typeofSingle;
        private static readonly Type typeofString;
        private static readonly Type typeofStringBuilder;
        private static readonly Type typeofUInt16;
        private static readonly Type typeofUInt32;
        private static readonly Type typeofUInt64;
#if (Mono)
        private static readonly Type typeofMonoBigInteger;
#endif
#if !(PocketPC || Smartphone || WindowsCE || NET1)
        private static readonly Type typeofGDictionary;
        private static readonly Type typeofGList;
#endif
        private static readonly Char[] m_trimmableChars;

        private PHPConvert() {
        }

        static PHPConvert() {
            provider = CultureInfo.InvariantCulture;
            UTF8 = new UTF8Encoding();
            typeofDBNull = typeof(System.DBNull);
            typeofString = typeof(String);
            typeofStringBuilder = typeof(StringBuilder);
            typeofBoolean = typeof(Boolean);
            typeofBigInteger = typeof(BigInteger);
            typeofByte = typeof(Byte);
            typeofByteArray = typeof(Byte[]);
            typeofChar = typeof(Char);
            typeofCharArray = typeof(Char[]);
            typeofDecimal = typeof(Decimal);
            typeofDouble = typeof(Double);
            typeofInt16 = typeof(Int16);
            typeofInt32 = typeof(Int32);
            typeofInt64 = typeof(Int32);
            typeofSByte = typeof(SByte);
            typeofSingle = typeof(Single);
            typeofDateTime = typeof(DateTime);
            typeofUInt16 = typeof(UInt16);
            typeofUInt32 = typeof(UInt32);
            typeofUInt64 = typeof(UInt64);
            typeofObject = typeof(Object);
            typeofObjectArray = typeof(Object[]);
            typeofArrayList = typeof(ArrayList);
            typeofHashtable = typeof(Hashtable);
            typeofAssocArray = typeof(AssocArray);
            typeofICollection = typeof(ICollection);
            typeofIDictionary = typeof(IDictionary);
            typeofIList = typeof(IList);
#if (Mono)
            typeofMonoBigInteger = typeof(Mono.Math.BigInteger);
#endif
#if !(PocketPC || Smartphone || WindowsCE || NET1)
            typeofGDictionary = typeof(Dictionary<,>);
            typeofGList = typeof(List<>);
#endif
            m_trimmableChars = new Char[] {(char)0x0, (char) 0x9, (char) 0xA, (char) 0xB, (char) 0xC, (char) 0xD,
			(char) 0x85, (char) 0x1680, (char) 0x2028, (char) 0x2029,
			(char) 0x20, (char) 0xA0, (char) 0x2000, (char) 0x2001, (char) 0x2002, (char) 0x2003, (char) 0x2004,
			(char) 0x2005, (char) 0x2006, (char) 0x2007, (char) 0x2008, (char) 0x2009, (char) 0x200A, (char) 0x200B,
			(char) 0x3000, (char) 0xFEFF };
        }

        #region ChangeType

        public static Object ChangeType(Object value, Type conversionType) {
            return ChangeType(value, conversionType, UTF8);
        }

        public static Object ChangeType(Object value, Type conversionType, String charset) {
            return ChangeType(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Object ChangeType(Object value, Type conversionType, Encoding encoding) {
            if (conversionType == null) {
                throw new ArgumentNullException("conversionType");
            }
            if (conversionType.IsByRef) {
                conversionType = conversionType.GetElementType();
            }
            if (value == null) {
                if (conversionType.IsValueType) {
                    throw new InvalidCastException("Null object cannot be converted to a value type.");
                }
                return null;
            }
            if ((conversionType == typeofObject) || conversionType.IsInstanceOfType(value)) {
                return value;
            }
            if (conversionType.IsEnum) {
                return ToEnum(value, conversionType);
            }
            if (conversionType == typeofBoolean) {
                return ToBoolean(value);
            }
            if (conversionType == typeofBigInteger) {
                return ToBigInteger(value);
            }
            if (conversionType == typeofChar) {
                return ToChar(value);
            }
            if (conversionType == typeofSByte) {
                return ToSByte(value);
            }
            if (conversionType == typeofByte) {
                return ToByte(value);
            }
            if (conversionType == typeofInt16) {
                return ToInt16(value);
            }
            if (conversionType == typeofUInt16) {
                return ToUInt16(value);
            }
            if (conversionType == typeofInt32) {
                return ToInt32(value);
            }
            if (conversionType == typeofUInt32) {
                return ToUInt32(value);
            }
            if (conversionType == typeofInt64) {
                return ToInt64(value);
            }
            if (conversionType == typeofUInt64) {
                return ToUInt64(value);
            }
            if (conversionType == typeofSingle) {
                return ToSingle(value);
            }
            if (conversionType == typeofDouble) {
                return ToDouble(value);
            }
            if (conversionType == typeofDecimal) {
                return ToDecimal(value);
            }
            if (conversionType == typeofDateTime) {
                return ToDateTime(value);
            }
            if (conversionType == typeofString) {
                return ToString(value, encoding);
            }
            if (conversionType == typeofStringBuilder) {
                return ToStringBuilder(value, encoding);
            }
            if (conversionType == typeofByteArray) {
                return ToByteArray(value, encoding);
            }
            if (conversionType == typeofCharArray) {
                return ToCharArray(value, encoding);
            }
            if (conversionType == typeofDBNull) {
                return DBNull.Value;
            }
            if (conversionType == typeofArrayList) {
                return ToArrayList(value);
            }
            if (conversionType == typeofHashtable) {
                return ToHashtable(value);
            }
            if (conversionType == typeofAssocArray) {
                return ToAssocArray(value);
            }
            if (conversionType.IsArray) {
                return ToArray(value, conversionType, encoding);
            }
#if (Mono)
            if (conversionType == typeofMonoBigInteger) {
                return ToMonoBigInteger(value);
            }
#endif
#if !(PocketPC || Smartphone || WindowsCE || NET1)
            if (conversionType.IsGenericType) {
                Type gtd = conversionType.GetGenericTypeDefinition();
                if (gtd == typeofGDictionary) {
                    return ToGDictionary(value, conversionType, encoding);
                }
                if (gtd == typeofGList) {
                    return ToGList(value, conversionType, encoding);
                }
            }
#endif
            if (typeofIDictionary.IsAssignableFrom(conversionType)) {
                return ToIDictionary(value, conversionType);
            }
            if (typeofIList.IsAssignableFrom(conversionType)) {
                return ToIList(value, conversionType);
            }
            if (typeofICollection.IsAssignableFrom(conversionType)) {
                return ToICollection(value, conversionType);
            }
            return ToObject(value, conversionType, encoding);
        }

        public static Object ChangeType(Object value, TypeCode typeCode) {
            return ChangeType(value, typeCode, UTF8);
        }

        public static Object ChangeType(Object value, TypeCode typeCode, String charset) {
            return ChangeType(value, typeCode, Encoding.GetEncoding(charset));
        }

        public static Object ChangeType(Object value, TypeCode typeCode, Encoding encoding) {
            switch (typeCode) {
            case TypeCode.Empty:
                return null;

            case TypeCode.Object:
                return value;

            case TypeCode.DBNull:
                return DBNull.Value;

            case TypeCode.Boolean:
                return ToBoolean(value);

            case TypeCode.Char:
                return ToChar(value);

            case TypeCode.SByte:
                return ToSByte(value);

            case TypeCode.Byte:
                return ToByte(value);

            case TypeCode.Int16:
                return ToInt16(value);

            case TypeCode.UInt16:
                return ToUInt16(value);

            case TypeCode.Int32:
                return ToInt32(value);

            case TypeCode.UInt32:
                return ToUInt32(value);

            case TypeCode.Int64:
                return ToInt64(value);

            case TypeCode.UInt64:
                return ToUInt64(value);

            case TypeCode.Single:
                return ToSingle(value);

            case TypeCode.Double:
                return ToDouble(value);

            case TypeCode.Decimal:
                return ToDecimal(value);

            case TypeCode.DateTime:
                return ToDateTime(value);

            case TypeCode.String:
                return ToString(value, encoding);
            }
            throw new ArgumentException("Unknown TypeCode value.");
        }

        #endregion

        #region ToBoolean

        public static Boolean ToBoolean(Boolean value) {
            return value;
        }

        public static Boolean ToBoolean(Byte value) {
            return (value != 0);
        }

        public static Boolean ToBoolean(Byte[] value) {
            if ((value == null) || (value.Length == 0) ||
                (value.Length == 1 && (value[0] == 0 || value[0] == 0x30))) {
                return false;
            }
            String s = ToString(value);
            if ("false".Equals(s) ||
                "false".Equals(s.Trim(m_trimmableChars).ToLower(CultureInfo.InvariantCulture))) {
                return false;
            }
            return true;
        }

        public static Boolean ToBoolean(Char value) {
            return (value != '\0') && (value != '0');
        }

        public static Boolean ToBoolean(Char[] value) {
            if ((value == null) || (value.Length == 0) ||
                (value.Length == 1 && (value[0] == '\0' || value[0] == '0'))) {
                return false;
            }
            String s = ToString(value);
            if ("false".Equals(s) ||
                "false".Equals(s.Trim(m_trimmableChars).ToLower(CultureInfo.InvariantCulture))) {
                return false;
            }
            return true;
        }

        public static Boolean ToBoolean(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Boolean'.");
        }

        public static Boolean ToBoolean(Decimal value) {
            return (value != 0M);
        }

        public static Boolean ToBoolean(Double value) {
            return (value != 0.0);
        }

        public static Boolean ToBoolean(Int16 value) {
            return (value != 0);
        }

        public static Boolean ToBoolean(Int32 value) {
            return (value != 0);
        }

        public static Boolean ToBoolean(Int64 value) {
            return (value != 0L);
        }

        public static Boolean ToBoolean(SByte value) {
            return (value != 0);
        }

        public static Boolean ToBoolean(Single value) {
            return (value != 0f);
        }

        public static Boolean ToBoolean(String value) {
            if ((value == null) || value.Equals("") || value.Equals("0") || "false".Equals(value) ||
                "false".Equals(value.Trim(m_trimmableChars).ToLower(CultureInfo.InvariantCulture))) {
                return false;
            }
            return true;
        }

        public static Boolean ToBoolean(StringBuilder value) {
            if (value == null) {
                return false;
            }
            return ToBoolean(value.ToString());
        }

        public static Boolean ToBoolean(UInt16 value) {
            return (value != 0);
        }

        public static Boolean ToBoolean(UInt32 value) {
            return (value != 0);
        }

        public static Boolean ToBoolean(UInt64 value) {
            return (value != 0L);
        }

        public static Boolean ToBoolean(Object value) {
            if (value == null) {
                return false;
            }
            if (value is Boolean) {
                return (Boolean)value;
            }
            if (value is Byte) {
                return ToBoolean((Byte)value);
            }
            if (value is Byte[]) {
                return ToBoolean(ToString((Byte[])value));
            }
            if (value is Char) {
                return ToBoolean((Char)value);
            }
            if (value is Char[]) {
                return ToBoolean(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToBoolean((DateTime)value);
            }
            if (value is Decimal) {
                return ToBoolean((Decimal)value);
            }
            if (value is Double) {
                return ToBoolean((Double)value);
            }
            if (value is Int16) {
                return ToBoolean((Int16)value);
            }
            if (value is Int32) {
                return ToBoolean((Int32)value);
            }
            if (value is Int64) {
                return ToBoolean((Int64)value);
            }
            if (value is SByte) {
                return ToBoolean((SByte)value);
            }
            if (value is Single) {
                return ToBoolean((Single)value);
            }
            if (value is String) {
                return ToBoolean((String)value);
            }
            if (value is StringBuilder) {
                return ToBoolean(value.ToString());
            }
            if (value is UInt16) {
                return ToBoolean((UInt16)value);
            }
            if (value is UInt32) {
                return ToBoolean((UInt32)value);
            }
            if (value is UInt64) {
                return ToBoolean((UInt64)value);
            }
            return ((IConvertible)value).ToBoolean(null);
        }

        #endregion

        #region ToBigInteger

        public static BigInteger ToBigInteger(BigInteger value) {
            return value;
        }

        public static BigInteger ToBigInteger(Byte value) {
            return (BigInteger)(UInt32)(value);
        }

        public static BigInteger ToBigInteger(Byte[] value) {
            if (value == null) {
                return new BigInteger(0);
            }
            return BigInteger.Parse(ToString(value));
        }

        public static BigInteger ToBigInteger(Boolean value) {
            return (BigInteger)(UInt32)(value ? 1 : 0);
        }

        public static BigInteger ToBigInteger(Char value) {
            return (BigInteger)(UInt32)value;
        }

        public static BigInteger ToBigInteger(Char[] value) {
            return BigInteger.Parse(ToString(value));
        }

        public static BigInteger ToBigInteger(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'BigInteger'.");
        }

        public static BigInteger ToBigInteger(Decimal value) {
            return BigInteger.Parse(value.ToString("#"));
        }

        public static BigInteger ToBigInteger(Double value) {
            return BigInteger.Parse(value.ToString("#"));
        }

        public static BigInteger ToBigInteger(Int16 value) {
            return BigInteger.Parse(value.ToString("#"));
        }

        public static BigInteger ToBigInteger(Int32 value) {
            return BigInteger.Parse(value.ToString("#"));
        }

        public static BigInteger ToBigInteger(Int64 value) {
            return BigInteger.Parse(value.ToString("#"));
        }

        public static BigInteger ToBigInteger(SByte value) {
            return BigInteger.Parse(value.ToString("#"));
        }

        public static BigInteger ToBigInteger(Single value) {
            return BigInteger.Parse(value.ToString("#"));
        }

        public static BigInteger ToBigInteger(String value) {
            if (value == null) {
                return new BigInteger(0);
            }
            return BigInteger.Parse(value);
        }

        public static BigInteger ToBigInteger(StringBuilder value) {
            if (value == null) {
                return new BigInteger(0);
            }
            return BigInteger.Parse(value.ToString());
        }

        public static BigInteger ToBigInteger(UInt16 value) {
            return (BigInteger)(UInt32)value;
        }

        public static BigInteger ToBigInteger(UInt32 value) {
            return (BigInteger)value;
        }

        public static BigInteger ToBigInteger(UInt64 value) {
            return (BigInteger)value;
        }

        public static BigInteger ToBigInteger(Object value) {
            if (value == null) {
                return new BigInteger(0);
            }
            if (value is BigInteger) {
                return (BigInteger)value;
            }
            if (value is Byte) {
                return (BigInteger)(UInt32)(Byte)value;
            }
            if (value is Boolean) {
                return (BigInteger)(UInt32)((Boolean)value ? 1 : 0);
            }
            if (value is Byte[]) {
                return BigInteger.Parse(ToString((Byte[])value));
            }
            if (value is Char) {
                return (BigInteger)(UInt32)(Char)value;
            }
            if (value is Char[]) {
                return BigInteger.Parse(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToBigInteger((DateTime)value);
            }
            if (value is Decimal) {
                return BigInteger.Parse(((Decimal)value).ToString("#"));
            }
            if (value is Double) {
                return BigInteger.Parse(((Double)value).ToString("#"));
            }
            if (value is Int16) {
                return BigInteger.Parse(((Int16)value).ToString("#"));
            }
            if (value is Int32) {
                return BigInteger.Parse(((Int32)value).ToString("#"));
            }
            if (value is Int64) {
                return BigInteger.Parse(((Int64)value).ToString("#"));
            }
            if (value is SByte) {
                return BigInteger.Parse(((SByte)value).ToString("#"));
            }
            if (value is Single) {
                return BigInteger.Parse(((Single)value).ToString("#"));
            }
            if (value is String) {
                return BigInteger.Parse((String)value);
            }
            if (value is StringBuilder) {
                return BigInteger.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (BigInteger)(UInt32)(UInt16)value;
            }
            if (value is UInt32) {
                return (BigInteger)(UInt32)value;
            }
            if (value is UInt64) {
                return (BigInteger)(UInt64)value;
            }
            return BigInteger.Parse(((IConvertible)value).ToString(null));
        }

        #endregion

        #region ToByte

        public static Byte ToByte(Byte value) {
            return value;
        }

        public static Byte ToByte(Boolean value) {
            return (Byte)(value ? 1 : 0);
        }

        public static Byte ToByte(Byte[] value) {
            return ToByte(ToString(value));
        }

        public static Byte ToByte(Char value) {
            return (Byte)value;
        }

        public static Byte ToByte(Char[] value) {
            return ToByte(ToString(value));
        }

        public static Byte ToByte(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Byte'.");
        }

        public static Byte ToByte(Decimal value) {
            return (Byte)value;
        }

        public static Byte ToByte(Double value) {
            return (Byte)value;
        }

        public static Byte ToByte(Int16 value) {
            return (Byte)value;
        }

        public static Byte ToByte(Int32 value) {
            return (Byte)value;
        }

        public static Byte ToByte(Int64 value) {
            return (Byte)value;
        }

        public static Byte ToByte(SByte value) {
            return (Byte)value;
        }

        public static Byte ToByte(Single value) {
            return (Byte)value;
        }

        public static Byte ToByte(String value) {
            if (value == null) {
                return 0;
            }
            return Byte.Parse(value);
        }

        public static Byte ToByte(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return Byte.Parse(value.ToString());
        }

        public static Byte ToByte(UInt16 value) {
            return (Byte)value;
        }

        public static Byte ToByte(UInt32 value) {
            return (Byte)value;
        }

        public static Byte ToByte(UInt64 value) {
            return (Byte)value;
        }

        public static Byte ToByte(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is Byte) {
                return (Byte)value;
            }
            if (value is Boolean) {
                return (Byte)((Boolean)value ? 1 : 0);
            }
            if (value is Byte[]) {
                return ToByte(ToString((Byte[])value));
            }
            if (value is Char) {
                return (Byte)(Char)value;
            }
            if (value is Char[]) {
                return ToByte(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToByte((DateTime)value);
            }
            if (value is Decimal) {
                return (Byte)(Decimal)value;
            }
            if (value is Double) {
                return (Byte)(Double)value;
            }
            if (value is Int16) {
                return (Byte)(Int16)value;
            }
            if (value is Int32) {
                return (Byte)(Int32)value;
            }
            if (value is Int64) {
                return (Byte)(Int64)value;
            }
            if (value is SByte) {
                return (Byte)(SByte)value;
            }
            if (value is Single) {
                return (Byte)(Single)value;
            }
            if (value is String) {
                return Byte.Parse((String)value);
            }
            if (value is StringBuilder) {
                return Byte.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (Byte)(UInt16)value;
            }
            if (value is UInt32) {
                return (Byte)(UInt32)value;
            }
            if (value is UInt64) {
                return (Byte)(UInt64)value;
            }
            return ((IConvertible)value).ToByte(null);
        }

        #endregion

        #region ToChar

        public static Char ToChar(Char value) {
            return value;
        }

        public static Char ToChar(Boolean value) {
            return (value ? '1' : '0');
        }

        public static Char ToChar(Byte value) {
            return (Char)value;
        }

        public static Char ToChar(Byte[] value) {
            if (value == null || value.Length == 0) {
                return '\0';
            }
            return ToString(value)[0];
        }

        public static Char ToChar(Char[] value) {
            if (value == null || value.Length == 0) {
                return '\0';
            }
            return value[0];
        }

        public static Char ToChar(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Char'.");
        }

        public static Char ToChar(Decimal value) {
            return (Char)(Int16)value;
        }

        public static Char ToChar(Double value) {
            return (Char)value;
        }

        public static Char ToChar(Int16 value) {
            return (Char)value;
        }

        public static Char ToChar(Int32 value) {
            return (Char)value;
        }

        public static Char ToChar(Int64 value) {
            return (Char)value;
        }

        public static Char ToChar(SByte value) {
            return (Char)value;
        }

        public static Char ToChar(Single value) {
            return (Char)value;
        }

        public static Char ToChar(String value) {
            if (value == null || value == "") {
                return '\0';
            }
            return value[0];
        }

        public static Char ToChar(StringBuilder value) {
            if (value == null || value.Length == 0) {
                return '\0';
            }
            return value.ToString()[0];
        }

        public static Char ToChar(UInt16 value) {
            return (Char)value;
        }

        public static Char ToChar(UInt32 value) {
            return (Char)value;
        }

        public static Char ToChar(UInt64 value) {
            return (Char)value;
        }

        public static Char ToChar(Object value) {
            if (value == null) {
                return '\0';
            }
            if (value is Char) {
                return (Char)value;
            }
            if (value is Boolean) {
                return ((Boolean)value ? '1' : '0');
            }
            if (value is Byte) {
                return (Char)(Byte)value;
            }
            if (value is Byte[]) {
                return ToChar((Byte[])value);
            }
            if (value is Char[]) {
                return ToChar((Char[])value);
            }
            if (value is DateTime) {
                return ToChar((DateTime)value);
            }
            if (value is Decimal) {
                return (Char)(Int16)(Decimal)value;
            }
            if (value is Double) {
                return (Char)(Double)value;
            }
            if (value is Int16) {
                return (Char)(Int16)value;
            }
            if (value is Int32) {
                return (Char)(Int32)value;
            }
            if (value is Int64) {
                return (Char)(Int64)value;
            }
            if (value is SByte) {
                return (Char)(SByte)value;
            }
            if (value is Single) {
                return (Char)(Single)value;
            }
            if (value is String) {
                return ToChar((String)value);
            }
            if (value is StringBuilder) {
                return ToChar(value.ToString());
            }
            if (value is UInt16) {
                return (Char)(UInt16)value;
            }
            if (value is UInt32) {
                return (Char)(UInt32)value;
            }
            if (value is UInt64) {
                return (Char)(UInt64)value;
            }
            return ((IConvertible)value).ToChar(null);
        }

        #endregion

        #region ToDateTime

        public static DateTime ToDateTime(Boolean value) {
            throw new InvalidCastException("Invalid cast from 'Boolean' to 'DateTime'.");
        }

        public static DateTime ToDateTime(Byte value) {
            throw new InvalidCastException("Invalid cast from 'Byte' to 'DateTime'.");
        }

        public static DateTime ToDateTime(Byte[] value) {
            if (value == null) {
                return DateTime.MinValue;
            }
            return DateTime.Parse(ToString(value));
        }

        public static DateTime ToDateTime(Char value) {
            throw new InvalidCastException("Invalid cast from 'Char' to 'DateTime'.");
        }

        public static DateTime ToDateTime(Char[] value) {
            if (value == null) {
                return DateTime.MinValue;
            }
            return DateTime.Parse(ToString(value));
        }

        public static DateTime ToDateTime(DateTime value) {
            return value;
        }

        public static DateTime ToDateTime(Decimal value) {
            throw new InvalidCastException("Invalid cast from 'Decimal' to 'DateTime'.");
        }

        public static DateTime ToDateTime(Double value) {
            throw new InvalidCastException("Invalid cast from 'Double' to 'DateTime'.");
        }

        public static DateTime ToDateTime(Int16 value) {
            throw new InvalidCastException("Invalid cast from 'Int16' to 'DateTime'.");
        }

        public static DateTime ToDateTime(Int32 value) {
            throw new InvalidCastException("Invalid cast from 'Int32' to 'DateTime'.");
        }

        public static DateTime ToDateTime(Int64 value) {
            throw new InvalidCastException("Invalid cast from 'Int64' to 'DateTime'.");
        }

        public static DateTime ToDateTime(SByte value) {
            throw new InvalidCastException("Invalid cast from 'SByte' to 'DateTime'.");
        }

        public static DateTime ToDateTime(Single value) {
            throw new InvalidCastException("Invalid cast from 'Single' to 'DateTime'.");
        }

        public static DateTime ToDateTime(String value) {
            if (value == null) {
                return DateTime.MinValue;
            }
            return DateTime.Parse(value);
        }

        public static DateTime ToDateTime(StringBuilder value) {
            if (value == null) {
                return DateTime.MinValue;
            }
            return DateTime.Parse(value.ToString());
        }

        public static DateTime ToDateTime(UInt16 value) {
            throw new InvalidCastException("Invalid cast from 'UInt16' to 'DateTime'.");
        }

        public static DateTime ToDateTime(UInt32 value) {
            throw new InvalidCastException("Invalid cast from 'UInt32' to 'DateTime'.");
        }

        public static DateTime ToDateTime(UInt64 value) {
            throw new InvalidCastException("Invalid cast from 'UInt64' to 'DateTime'.");
        }

        public static DateTime ToDateTime(Object value) {
            if (value == null) {
                return DateTime.MinValue;
            }
            if (value is Byte[]) {
                return DateTime.Parse(ToString((Byte[])value));
            }
            if (value is Char[]) {
                return DateTime.Parse(ToString((Char[])value));
            }
            if (value is String) {
                return DateTime.Parse((String)value);
            }
            if (value is StringBuilder) {
                return DateTime.Parse(value.ToString());
            }
            return ((IConvertible)value).ToDateTime(provider);
        }

        #endregion

        #region ToDecimal

        public static Decimal ToDecimal(Decimal value) {
            return value;
        }

        public static Decimal ToDecimal(Boolean value) {
            return (Decimal)(value ? 1 : 0);
        }

        public static Decimal ToDecimal(Byte value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(Byte[] value) {
            return ToDecimal(ToString(value));
        }

        public static Decimal ToDecimal(Char value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(Char[] value) {
            return ToDecimal(ToString(value));
        }

        public static Decimal ToDecimal(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Decimal'.");
        }

        public static Decimal ToDecimal(Double value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(Int16 value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(Int32 value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(Int64 value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(SByte value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(Single value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(String value) {
            if (value == null) {
                return 0;
            }
            return Decimal.Parse(value);
        }

        public static Decimal ToDecimal(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return Decimal.Parse(value.ToString());
        }

        public static Decimal ToDecimal(UInt16 value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(UInt32 value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(UInt64 value) {
            return (Decimal)value;
        }

        public static Decimal ToDecimal(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is Decimal) {
                return (Decimal)value;
            }
            if (value is Boolean) {
                return (Decimal)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (Decimal)(Byte)value;
            }
            if (value is Byte[]) {
                return ToDecimal(ToString((Byte[])value));
            }
            if (value is Char) {
                return (Decimal)(Char)value;
            }
            if (value is Char[]) {
                return ToDecimal(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToDecimal((DateTime)value);
            }
            if (value is Double) {
                return (Decimal)(Double)value;
            }
            if (value is Int16) {
                return (Decimal)(Int16)value;
            }
            if (value is Int32) {
                return (Decimal)(Int32)value;
            }
            if (value is Int64) {
                return (Decimal)(Int64)value;
            }
            if (value is SByte) {
                return (Decimal)(SByte)value;
            }
            if (value is Single) {
                return (Decimal)(Single)value;
            }
            if (value is String) {
                return Decimal.Parse((String)value);
            }
            if (value is StringBuilder) {
                return Decimal.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (Decimal)(UInt16)value;
            }
            if (value is UInt32) {
                return (Decimal)(UInt32)value;
            }
            if (value is UInt64) {
                return (Decimal)(UInt64)value;
            }
            return ((IConvertible)value).ToDecimal(null);
        }

        #endregion

        #region ToDouble

        public static Double ToDouble(Double value) {
            return value;
        }

        public static Double ToDouble(Boolean value) {
            return (Double)(value ? 1 : 0);
        }

        public static Double ToDouble(Byte value) {
            return (Double)value;
        }

        public static Double ToDouble(Byte[] value) {
            return ToDouble(ToString(value));
        }

        public static Double ToDouble(Char value) {
            return (Double)value;
        }

        public static Double ToDouble(Char[] value) {
            return ToDouble(ToString(value));
        }

        public static Double ToDouble(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Double'.");
        }

        public static Double ToDouble(Decimal value) {
            return (Double)value;
        }

        public static Double ToDouble(Int16 value) {
            return (Double)value;
        }

        public static Double ToDouble(Int32 value) {
            return (Double)value;
        }

        public static Double ToDouble(Int64 value) {
            return (Double)value;
        }

        public static Double ToDouble(SByte value) {
            return (Double)value;
        }

        public static Double ToDouble(Single value) {
            return (Double)value;
        }

        public static Double ToDouble(String value) {
            if (value == null) {
                return 0;
            }
            return Double.Parse(value);
        }

        public static Double ToDouble(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return Double.Parse(value.ToString());
        }

        public static Double ToDouble(UInt16 value) {
            return (Double)value;
        }

        public static Double ToDouble(UInt32 value) {
            return (Double)value;
        }

        public static Double ToDouble(UInt64 value) {
            return (Double)value;
        }

        public static Double ToDouble(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is Double) {
                return (Double)value;
            }
            if (value is Boolean) {
                return (Double)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (Double)(Byte)value;
            }
            if (value is Byte[]) {
                return ToDouble(ToString((Byte[])value));
            }
            if (value is Char) {
                return (Double)(Char)value;
            }
            if (value is Char[]) {
                return ToDouble(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToDouble((DateTime)value);
            }
            if (value is Decimal) {
                return (Double)(Decimal)value;
            }
            if (value is Int16) {
                return (Double)(Int16)value;
            }
            if (value is Int32) {
                return (Double)(Int32)value;
            }
            if (value is Int64) {
                return (Double)(Int64)value;
            }
            if (value is SByte) {
                return (Double)(SByte)value;
            }
            if (value is Single) {
                return (Double)(Single)value;
            }
            if (value is String) {
                return Double.Parse((String)value);
            }
            if (value is StringBuilder) {
                return Double.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (Double)(UInt16)value;
            }
            if (value is UInt32) {
                return (Double)(UInt32)value;
            }
            if (value is UInt64) {
                return (Double)(UInt64)value;
            }
            return ((IConvertible)value).ToDouble(null);
        }

        #endregion

        #region ToEnum

        public static Object ToEnum(Byte value, Type conversionType) {
            return Enum.ToObject(conversionType, value);
        }

        public static Object ToEnum(Boolean value, Type conversionType) {
            return Enum.ToObject(conversionType, (Byte)(value ? 1 : 0));
        }

        public static Object ToEnum(Char value, Type conversionType) {
            return Enum.ToObject(conversionType, (Int32)value);
        }

        public static Object ToEnum(DateTime value, Type conversionType) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to '" + conversionType.Name + "'.");
        }

        public static Object ToEnum(Decimal value, Type conversionType) {
            return Enum.ToObject(conversionType, (UInt64)value);
        }

        public static Object ToEnum(Double value, Type conversionType) {
            return Enum.ToObject(conversionType, (UInt64)value);
        }

        public static Object ToEnum(Int16 value, Type conversionType) {
            return Enum.ToObject(conversionType, value);
        }

        public static Object ToEnum(Int32 value, Type conversionType) {
            return Enum.ToObject(conversionType, value);
        }

        public static Object ToEnum(Int64 value, Type conversionType) {
            return Enum.ToObject(conversionType, value);
        }

        public static Object ToEnum(SByte value, Type conversionType) {
            return Enum.ToObject(conversionType, value);
        }

        public static Object ToEnum(Single value, Type conversionType) {
            return Enum.ToObject(conversionType, (UInt64)value);
        }

        public static Object ToEnum(UInt16 value, Type conversionType) {
            return Enum.ToObject(conversionType, value);
        }

        public static Object ToEnum(UInt32 value, Type conversionType) {
            return Enum.ToObject(conversionType, value);
        }

        public static Object ToEnum(UInt64 value, Type conversionType) {
            return Enum.ToObject(conversionType, value);
        }

#if !(NETCF1)
        public static Object ToEnum(Byte[] value, Type conversionType) {
            return Enum.Parse(conversionType, ToString(value), true);
        }

        public static Object ToEnum(Char[] value, Type conversionType) {
            return Enum.Parse(conversionType, ToString(value), true);
        }

        public static Object ToEnum(String value, Type conversionType) {
            if (value == null) {
                throw new InvalidCastException("Null object cannot be converted to a value type.");
            }
            return Enum.Parse(conversionType, value, true);
        }

        public static Object ToEnum(StringBuilder value, Type conversionType) {
            if (value == null) {
                throw new InvalidCastException("Null object cannot be converted to a value type.");
            }
            return Enum.Parse(conversionType, value.ToString(), true);
        }
#endif

        public static Object ToEnum(Object value, Type conversionType) {
            if (value == null) {
                throw new InvalidCastException("Null object cannot be converted to a value type.");
            }
            if (value.GetType() == conversionType) {
                return value;
            }
            if ((value is Byte) ||
                (value is SByte) ||
                (value is Int16) ||
                (value is Int32) ||
                (value is Int64) ||
                (value is UInt16) ||
                (value is UInt32) ||
                (value is UInt64)) {
                return Enum.ToObject(conversionType, value);
            }
            if (value is Boolean) {
                return Enum.ToObject(conversionType, (Byte)((Boolean)value ? 1 : 0));
            }
            if (value is Char) {
                return Enum.ToObject(conversionType, (Int32)(Char)value);
            }
            if (value is DateTime) {
                return ToEnum((DateTime)value, conversionType);
            }
            if (value is Decimal) {
                return Enum.ToObject(conversionType, (UInt64)(Decimal)value);
            }
            if (value is Double) {
                return Enum.ToObject(conversionType, (UInt64)(Double)value);
            }
            if (value is Single) {
                return Enum.ToObject(conversionType, (UInt64)(Single)value);
            }
#if !(NETCF1)
            if (value is Byte[]) {
                return Enum.Parse(conversionType, ToString((Byte[])value), true);
            }
            if (value is Char[]) {
                return Enum.Parse(conversionType, ToString((Char[])value), true);
            }
            if (value is String) {
                return Enum.Parse(conversionType, (String)value, true);
            }
            if (value is StringBuilder) {
                return Enum.Parse(conversionType, value.ToString(), true);
            }
#endif
            return Enum.ToObject(conversionType, ((IConvertible)value).ToUInt64(null));
        }

        #endregion

        #region ToInt16

        public static Int16 ToInt16(Int16 value) {
            return value;
        }

        public static Int16 ToInt16(Boolean value) {
            return (Int16)(value ? 1 : 0);
        }

        public static Int16 ToInt16(Byte value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(Byte[] value) {
            return ToInt16(ToString(value));
        }

        public static Int16 ToInt16(Char value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(Char[] value) {
            return ToInt16(ToString(value));
        }

        public static Int16 ToInt16(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Int16'.");
        }

        public static Int16 ToInt16(Decimal value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(Double value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(Int32 value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(Int64 value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(SByte value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(Single value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(String value) {
            if (value == null) {
                return 0;
            }
            return Int16.Parse(value);
        }

        public static Int16 ToInt16(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return Int16.Parse(value.ToString());
        }

        public static Int16 ToInt16(UInt16 value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(UInt32 value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(UInt64 value) {
            return (Int16)value;
        }

        public static Int16 ToInt16(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is Int16) {
                return (Int16)value;
            }
            if (value is Boolean) {
                return (Int16)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (Int16)(Byte)value;
            }
            if (value is Byte[]) {
                return ToInt16(ToString((Byte[])value));
            }
            if (value is Char) {
                return (Int16)(Char)value;
            }
            if (value is Char[]) {
                return ToInt16(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToInt16((DateTime)value);
            }
            if (value is Decimal) {
                return (Int16)(Decimal)value;
            }
            if (value is Double) {
                return (Int16)(Double)value;
            }
            if (value is Int32) {
                return (Int16)(Int32)value;
            }
            if (value is Int64) {
                return (Int16)(Int64)value;
            }
            if (value is SByte) {
                return (Int16)(SByte)value;
            }
            if (value is Single) {
                return (Int16)(Single)value;
            }
            if (value is String) {
                return Int16.Parse((String)value);
            }
            if (value is StringBuilder) {
                return Int16.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (Int16)(UInt16)value;
            }
            if (value is UInt32) {
                return (Int16)(UInt32)value;
            }
            if (value is UInt64) {
                return (Int16)(UInt64)value;
            }
            return ((IConvertible)value).ToInt16(null);
        }

        #endregion

        #region ToInt32

        public static Int32 ToInt32(Int32 value) {
            return value;
        }

        public static Int32 ToInt32(Boolean value) {
            return (Int32)(value ? 1 : 0);
        }

        public static Int32 ToInt32(Byte value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(Byte[] value) {
            return ToInt32(ToString(value));
        }

        public static Int32 ToInt32(Char value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(Char[] value) {
            return ToInt32(ToString(value));
        }

        public static Int32 ToInt32(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Int32'.");
        }

        public static Int32 ToInt32(Decimal value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(Double value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(Int16 value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(Int64 value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(SByte value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(Single value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(String value) {
            if (value == null) {
                return 0;
            }
            return Int32.Parse(value);
        }

        public static Int32 ToInt32(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return Int32.Parse(value.ToString());
        }

        public static Int32 ToInt32(UInt16 value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(UInt32 value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(UInt64 value) {
            return (Int32)value;
        }

        public static Int32 ToInt32(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is Int32) {
                return (Int32)value;
            }
            if (value is Boolean) {
                return (Int32)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (Int32)(Byte)value;
            }
            if (value is Byte[]) {
                return ToInt32(ToString((Byte[])value));
            }
            if (value is Char) {
                return (Int32)(Char)value;
            }
            if (value is Char[]) {
                return ToInt32(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToInt32((DateTime)value);
            }
            if (value is Decimal) {
                return (Int32)(Decimal)value;
            }
            if (value is Double) {
                return (Int32)(Double)value;
            }
            if (value is Int16) {
                return (Int32)(Int16)value;
            }
            if (value is Int64) {
                return (Int32)(Int64)value;
            }
            if (value is SByte) {
                return (Int32)(SByte)value;
            }
            if (value is Single) {
                return (Int32)(Single)value;
            }
            if (value is String) {
                return Int32.Parse((String)value);
            }
            if (value is StringBuilder) {
                return Int32.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (Int32)(UInt16)value;
            }
            if (value is UInt32) {
                return (Int32)(UInt32)value;
            }
            if (value is UInt64) {
                return (Int32)(UInt64)value;
            }
            return ((IConvertible)value).ToInt32(null);
        }

         #endregion

        #region ToInt64

        public static Int64 ToInt64(Int64 value) {
            return value;
        }

        public static Int64 ToInt64(Boolean value) {
            return (Int64)(value ? 1 : 0);
        }

        public static Int64 ToInt64(Byte value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(Byte[] value) {
            return ToInt64(ToString(value));
        }

        public static Int64 ToInt64(Char value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(Char[] value) {
            return ToInt64(ToString(value));
        }

        public static Int64 ToInt64(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Int64'.");
        }

        public static Int64 ToInt64(Decimal value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(Double value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(Int16 value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(Int32 value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(SByte value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(Single value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(String value) {
            if (value == null) {
                return 0;
            }
            return Int64.Parse(value);
        }

        public static Int64 ToInt64(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return Int64.Parse(value.ToString());
        }

        public static Int64 ToInt64(UInt16 value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(UInt32 value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(UInt64 value) {
            return (Int64)value;
        }

        public static Int64 ToInt64(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is Int64) {
                return (Int64)value;
            }
            if (value is Boolean) {
                return (Int64)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (Int64)(Byte)value;
            }
            if (value is Byte[]) {
                return ToInt64(ToString((Byte[])value));
            }
            if (value is Char) {
                return (Int64)(Char)value;
            }
            if (value is Char[]) {
                return ToInt64(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToInt64((DateTime)value);
            }
            if (value is Decimal) {
                return (Int64)(Decimal)value;
            }
            if (value is Double) {
                return (Int64)(Double)value;
            }
            if (value is Int16) {
                return (Int64)(Int16)value;
            }
            if (value is Int32) {
                return (Int64)(Int32)value;
            }
            if (value is SByte) {
                return (Int64)(SByte)value;
            }
            if (value is Single) {
                return (Int64)(Single)value;
            }
            if (value is String) {
                return Int64.Parse((String)value);
            }
            if (value is StringBuilder) {
                return Int64.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (Int64)(UInt16)value;
            }
            if (value is UInt32) {
                return (Int64)(UInt32)value;
            }
            if (value is UInt64) {
                return (Int64)(UInt64)value;
            }
            return ((IConvertible)value).ToInt64(null);
        }

         #endregion

        #region ToSByte

        public static SByte ToSByte(SByte value) {
            return value;
        }

        public static SByte ToSByte(Boolean value) {
            return (SByte)(value ? 1 : 0);
        }

        public static SByte ToSByte(Byte value) {
            return (SByte)value;
        }

        public static SByte ToSByte(Byte[] value) {
            return ToSByte(ToString(value));
        }

        public static SByte ToSByte(Char value) {
            return (SByte)value;
        }

        public static SByte ToSByte(Char[] value) {
            return ToSByte(ToString(value));
        }

        public static SByte ToSByte(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'SByte'.");
        }

        public static SByte ToSByte(Decimal value) {
            return (SByte)value;
        }

        public static SByte ToSByte(Double value) {
            return (SByte)value;
        }

        public static SByte ToSByte(Int16 value) {
            return (SByte)value;
        }

        public static SByte ToSByte(Int32 value) {
            return (SByte)value;
        }

        public static SByte ToSByte(Int64 value) {
            return (SByte)value;
        }

        public static SByte ToSByte(Single value) {
            return (SByte)value;
        }

        public static SByte ToSByte(String value) {
            if (value == null) {
                return 0;
            }
            return SByte.Parse(value);
        }

        public static SByte ToSByte(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return SByte.Parse(value.ToString());
        }

        public static SByte ToSByte(UInt16 value) {
            return (SByte)value;
        }

        public static SByte ToSByte(UInt32 value) {
            return (SByte)value;
        }

        public static SByte ToSByte(UInt64 value) {
            return (SByte)value;
        }

        public static SByte ToSByte(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is SByte) {
                return (SByte)value;
            }
            if (value is Boolean) {
                return (SByte)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (SByte)(Byte)value;
            }
            if (value is Byte[]) {
                return ToSByte(ToString((Byte[])value));
            }
            if (value is Char) {
                return (SByte)(Char)value;
            }
            if (value is Char[]) {
                return ToSByte(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToSByte((DateTime)value);
            }
            if (value is Decimal) {
                return (SByte)(Decimal)value;
            }
            if (value is Double) {
                return (SByte)(Double)value;
            }
            if (value is Int16) {
                return (SByte)(Int16)value;
            }
            if (value is Int32) {
                return (SByte)(Int32)value;
            }
            if (value is Int64) {
                return (SByte)(Int64)value;
            }
            if (value is Single) {
                return (SByte)(Single)value;
            }
            if (value is String) {
                return SByte.Parse((String)value);
            }
            if (value is StringBuilder) {
                return SByte.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (SByte)(UInt16)value;
            }
            if (value is UInt32) {
                return (SByte)(UInt32)value;
            }
            if (value is UInt64) {
                return (SByte)(UInt64)value;
            }
            return ((IConvertible)value).ToSByte(null);
        }

         #endregion

        #region ToSingle

        public static Single ToSingle(Single value) {
            return value;
        }

        public static Single ToSingle(Boolean value) {
            return (Single)(value ? 1 : 0);
        }

        public static Single ToSingle(Byte value) {
            return (Single)value;
        }

        public static Single ToSingle(Byte[] value) {
            return ToSingle(ToString(value));
        }

        public static Single ToSingle(Char value) {
            return (Single)value;
        }

        public static Single ToSingle(Char[] value) {
            return ToSingle(ToString(value));
        }

        public static Single ToSingle(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Single'.");
        }

        public static Single ToSingle(Decimal value) {
            return (Single)value;
        }

        public static Single ToSingle(Double value) {
            return (Single)value;
        }

        public static Single ToSingle(Int16 value) {
            return (Single)value;
        }

        public static Single ToSingle(Int32 value) {
            return (Single)value;
        }

        public static Single ToSingle(Int64 value) {
            return (Single)value;
        }

        public static Single ToSingle(SByte value) {
            return (Single)value;
        }

        public static Single ToSingle(String value) {
            if (value == null) {
                return 0;
            }
            return Single.Parse(value);
        }

        public static Single ToSingle(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return Single.Parse(value.ToString());
        }

        public static Single ToSingle(UInt16 value) {
            return (Single)value;
        }

        public static Single ToSingle(UInt32 value) {
            return (Single)value;
        }

        public static Single ToSingle(UInt64 value) {
            return (Single)value;
        }

        public static Single ToSingle(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is Single) {
                return (Single)value;
            }
            if (value is Boolean) {
                return (Single)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (Single)(Byte)value;
            }
            if (value is Byte[]) {
                return ToSingle(ToString((Byte[])value));
            }
            if (value is Char) {
                return (Single)(Char)value;
            }
            if (value is Char[]) {
                return ToSingle(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToSingle((DateTime)value);
            }
            if (value is Decimal) {
                return (Single)(Decimal)value;
            }
            if (value is Double) {
                return (Single)(Double)value;
            }
            if (value is Int16) {
                return (Single)(Int16)value;
            }
            if (value is Int32) {
                return (Single)(Int32)value;
            }
            if (value is Int64) {
                return (Single)(Int64)value;
            }
            if (value is SByte) {
                return (Single)(SByte)value;
            }
            if (value is String) {
                return Single.Parse((String)value);
            }
            if (value is StringBuilder) {
                return Single.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (Single)(UInt16)value;
            }
            if (value is UInt32) {
                return (Single)(UInt32)value;
            }
            if (value is UInt64) {
                return (Single)(UInt64)value;
            }
            return ((IConvertible)value).ToSingle(null);
        }

        #endregion

        #region ToString

        public static String ToString(Byte[] value) {
            return UTF8.GetString(value, 0, value.GetLength(0));
        }

        public static String ToString(Byte[] value, String charset) {
            return Encoding.GetEncoding(charset).GetString(value, 0, value.GetLength(0));
        }

        public static String ToString(Byte[] value, Encoding encoding) {
            return encoding.GetString(value, 0, value.GetLength(0));
        }

        public static String ToString(Object value) {
            return ToString(value, UTF8);
        }

        public static String ToString(Object value, String charset) {
            if (value == null) {
                return null;
            }
            if (value is String) {
                return (String)value;
            }
            if (value is Char[]) {
                return new String((Char[])value);
            }
            if (value is Byte[]) {
                return ToString((Byte[])value, charset);
            }
            return value.ToString();
        }

        public static String ToString(Object value, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (value is String) {
                return (String)value;
            }
            if (value is Char[]) {
                return new String((Char[])value);
            }
            if (value is Byte[]) {
                return ToString((Byte[])value, encoding);
            }
            return value.ToString();
        }

        #endregion

        #region ToStringBuilder

        public static StringBuilder ToStringBuilder(Object value) {
            return ToStringBuilder(value, UTF8);
        }

        public static StringBuilder ToStringBuilder(Object value, String charset) {
            if (value == null) {
                return null;
            }
            if (value is StringBuilder) {
                return (StringBuilder)value;
            }
            if (value is String) {
                return new StringBuilder((String)value);
            }
            if (value is Char[]) {
                return new StringBuilder().Append((Char[])value);
            }
            if (value is Byte[]) {
                return new StringBuilder(ToString((Byte[])value, charset));
            }
            return new StringBuilder().Append(value);
        }

        public static StringBuilder ToStringBuilder(Object value, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (value is StringBuilder) {
                return (StringBuilder)value;
            }
            if (value is String) {
                return new StringBuilder((String)value);
            }
            if (value is Char[]) {
                return new StringBuilder().Append((Char[])value);
            }
            if (value is Byte[]) {
                return new StringBuilder(ToString((Byte[])value, encoding));
            }
            return new StringBuilder().Append(value);
        }
        
        #endregion

        #region ToByteArray

        public static Byte[] ToByteArray(Object value) {
            return ToByteArray(value, UTF8);
        }

        public static Byte[] ToByteArray(Object value, String charset) {
            return ToByteArray(value, Encoding.GetEncoding(charset));
        }

        public static Byte[] ToByteArray(Object value, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (value is Byte[]) {
                return (Byte[])value;
            }
            if (value is Char[]) {
                return encoding.GetBytes((Char[])value);
            }
            if (value is String) {
                return encoding.GetBytes((String)value);
            }
            if (value is Array) {
                return (Byte[])ToArray((Array)value, typeofByteArray, encoding);
            }
            if (value is AssocArray) {
                return (Byte[])ToArray((AssocArray)value, typeofByteArray, encoding);
            }
            if (value is ArrayList) {
                return (Byte[])ToArray((ArrayList)value, typeofByteArray, encoding);
            }
            if (value is IDictionary) {
                return (Byte[])ToArray((IDictionary)value, typeofByteArray, encoding);
            }
            if (value is ICollection) {
                return (Byte[])ToArray((ICollection)value, typeofByteArray, encoding);
            }
            return encoding.GetBytes(value.ToString());
        }

        #endregion

        #region ToCharArray

        public static Char[] ToCharArray(Object value) {
            return ToCharArray(value, UTF8);
        }

        public static Char[] ToCharArray(Object value, String charset) {
            return ToCharArray(value, Encoding.GetEncoding(charset));
        }

        public static Char[] ToCharArray(Object value, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (value is Char[]) {
                return (Char[])value;
            }
            if (value is String) {
                return ((String)value).ToCharArray();
            }
            if (value is StringBuilder) {
                return value.ToString().ToCharArray();
            }
            if (value is Byte[]) {
                return encoding.GetChars((Byte[])value);
            }
            if (value is Array) {
                return (Char[])ToArray((Array)value, typeofCharArray, encoding);
            }
            if (value is AssocArray) {
                return (Char[])ToArray((AssocArray)value, typeofCharArray, encoding);
            }
            if (value is ArrayList) {
                return (Char[])ToArray((ArrayList)value, typeofCharArray, encoding);
            }
            if (value is IDictionary) {
                return (Char[])ToArray((IDictionary)value, typeofCharArray, encoding);
            }
            if (value is ICollection) {
                return (Char[])ToArray((ICollection)value, typeofCharArray, encoding);
            }
            return value.ToString().ToCharArray();
        }

        #endregion

        #region ToUInt16

        public static UInt16 ToUInt16(UInt16 value) {
            return value;
        }

        public static UInt16 ToUInt16(Boolean value) {
            return (UInt16)(value ? 1 : 0);
        }

        public static UInt16 ToUInt16(Byte value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(Byte[] value) {
            return ToUInt16(ToString(value));
        }

        public static UInt16 ToUInt16(Char value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(Char[] value) {
            return ToUInt16(ToString(value));
        }

        public static UInt16 ToUInt16(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'UInt16'.");
        }

        public static UInt16 ToUInt16(Decimal value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(Double value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(Int16 value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(Int32 value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(Int64 value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(SByte value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(Single value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(String value) {
            if (value == null) {
                return 0;
            }
            return UInt16.Parse(value);
        }

        public static UInt16 ToUInt16(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return UInt16.Parse(value.ToString());
        }

        public static UInt16 ToUInt16(UInt32 value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(UInt64 value) {
            return (UInt16)value;
        }

        public static UInt16 ToUInt16(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is UInt16) {
                return (UInt16)value;
            }
            if (value is Boolean) {
                return (UInt16)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (UInt16)(Byte)value;
            }
            if (value is Byte[]) {
                return ToUInt16(ToString((Byte[])value));
            }
            if (value is Char) {
                return (UInt16)(Char)value;
            }
            if (value is Char[]) {
                return ToUInt16(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToUInt16((DateTime)value);
            }
            if (value is Decimal) {
                return (UInt16)(Decimal)value;
            }
            if (value is Double) {
                return (UInt16)(Double)value;
            }
            if (value is Int16) {
                return (UInt16)(Int16)value;
            }
            if (value is Int32) {
                return (UInt16)(Int32)value;
            }
            if (value is Int64) {
                return (UInt16)(Int64)value;
            }
            if (value is SByte) {
                return (UInt16)(SByte)value;
            }
            if (value is Single) {
                return (UInt16)(Single)value;
            }
            if (value is String) {
                return UInt16.Parse((String)value);
            }
            if (value is StringBuilder) {
                return UInt16.Parse(value.ToString());
            }
            if (value is UInt32) {
                return (UInt16)(UInt32)value;
            }
            if (value is UInt64) {
                return (UInt16)(UInt64)value;
            }
            return ((IConvertible)value).ToUInt16(null);
        }

        #endregion

        #region ToUInt32

        public static UInt32 ToUInt32(UInt32 value) {
            return value;
        }

        public static UInt32 ToUInt32(Boolean value) {
            return (UInt32)(value ? 1 : 0);
        }

        public static UInt32 ToUInt32(Byte value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(Byte[] value) {
            return ToUInt32(ToString(value));
        }

        public static UInt32 ToUInt32(Char value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(Char[] value) {
            return ToUInt32(ToString(value));
        }

        public static UInt32 ToUInt32(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'UInt32'.");
        }

        public static UInt32 ToUInt32(Decimal value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(Double value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(Int16 value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(Int32 value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(Int64 value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(SByte value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(Single value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(String value) {
            if (value == null) {
                return 0;
            }
            return UInt32.Parse(value);
        }

        public static UInt32 ToUInt32(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return UInt32.Parse(value.ToString());
        }

        public static UInt32 ToUInt32(UInt16 value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(UInt64 value) {
            return (UInt32)value;
        }

        public static UInt32 ToUInt32(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is UInt32) {
                return (UInt32)value;
            }
            if (value is Boolean) {
                return (UInt32)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (UInt32)(Byte)value;
            }
            if (value is Byte[]) {
                return ToUInt32(ToString((Byte[])value));
            }
            if (value is Char) {
                return (UInt32)(Char)value;
            }
            if (value is Char[]) {
                return ToUInt32(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToUInt32((DateTime)value);
            }
            if (value is Decimal) {
                return (UInt32)(Decimal)value;
            }
            if (value is Double) {
                return (UInt32)(Double)value;
            }
            if (value is Int16) {
                return (UInt32)(Int16)value;
            }
            if (value is Int32) {
                return (UInt32)(Int32)value;
            }
            if (value is Int64) {
                return (UInt32)(Int64)value;
            }
            if (value is SByte) {
                return (UInt32)(SByte)value;
            }
            if (value is Single) {
                return (UInt32)(Single)value;
            }
            if (value is String) {
                return UInt32.Parse((String)value);
            }
            if (value is StringBuilder) {
                return UInt32.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (UInt32)(UInt16)value;
            }
            if (value is UInt64) {
                return (UInt32)(UInt64)value;
            }
            return ((IConvertible)value).ToUInt32(null);
        }

        #endregion

        #region ToUInt64

        public static UInt64 ToUInt64(UInt64 value) {
            return value;
        }

        public static UInt64 ToUInt64(Boolean value) {
            return (UInt64)(value ? 1 : 0);
        }

        public static UInt64 ToUInt64(Byte value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(Byte[] value) {
            return ToUInt64(ToString(value));
        }

        public static UInt64 ToUInt64(Char value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(Char[] value) {
            return ToUInt64(ToString(value));
        }

        public static UInt64 ToUInt64(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'UInt64'.");
        }

        public static UInt64 ToUInt64(Decimal value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(Double value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(Int16 value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(Int32 value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(Int64 value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(SByte value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(Single value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(String value) {
            if (value == null) {
                return 0;
            }
            return UInt64.Parse(value);
        }

        public static UInt64 ToUInt64(StringBuilder value) {
            if (value == null) {
                return 0;
            }
            return UInt64.Parse(value.ToString());
        }

        public static UInt64 ToUInt64(UInt16 value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(UInt32 value) {
            return (UInt64)value;
        }

        public static UInt64 ToUInt64(Object value) {
            if (value == null) {
                return 0;
            }
            if (value is UInt64) {
                return (UInt64)value;
            }
            if (value is Boolean) {
                return (UInt64)((Boolean)value ? 1 : 0);
            }
            if (value is Byte) {
                return (UInt64)(Byte)value;
            }
            if (value is Byte[]) {
                return ToUInt64(ToString((Byte[])value));
            }
            if (value is Char) {
                return (UInt64)(Char)value;
            }
            if (value is Char[]) {
                return ToUInt64(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToUInt64((DateTime)value);
            }
            if (value is Decimal) {
                return (UInt64)(Decimal)value;
            }
            if (value is Double) {
                return (UInt64)(Double)value;
            }
            if (value is Int16) {
                return (UInt64)(Int16)value;
            }
            if (value is Int32) {
                return (UInt64)(Int32)value;
            }
            if (value is Int64) {
                return (UInt64)(Int64)value;
            }
            if (value is SByte) {
                return (UInt64)(SByte)value;
            }
            if (value is Single) {
                return (UInt64)(Single)value;
            }
            if (value is String) {
                return UInt64.Parse((String)value);
            }
            if (value is StringBuilder) {
                return UInt64.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (UInt64)(UInt16)value;
            }
            if (value is UInt32) {
                return (UInt64)(UInt32)value;
            }
            return ((IConvertible)value).ToUInt64(null);
        }

        #endregion

        #region ToAssocArray

        public static AssocArray ToAssocArray(AssocArray value) {
            return value;
        }

        public static AssocArray ToAssocArray(IDictionary value) {
            if (value == null) {
                return null;
            }
            return new AssocArray(value);
        }

        public static AssocArray ToAssocArray(ICollection value) {
            if (value == null) {
                return null;
            }
            return new AssocArray(value);
        }

        public static AssocArray ToAssocArray(Object value) {
            if (value == null) {
                return null;
            }
            if (value is AssocArray) {
                return (AssocArray)value;
            }
            if (value is IDictionary) {
                return new AssocArray((IDictionary)value);
            }
            if (value is ICollection) {
                return new AssocArray((ICollection)value);
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to 'AssocArray'.");
        }

        #endregion

        #region ToArrayList

        public static ArrayList ToArrayList(ArrayList value) {
            return value;
        }

        public static ArrayList ToArrayList(AssocArray value) {
            if (value == null) {
                return null;
            }
            return value.toArrayList();
        }

        public static ArrayList ToArrayList(IDictionary value) {
            if (value == null) {
                return null;
            }
            return new AssocArray(value).toArrayList();
        }

        public static ArrayList ToArrayList(ICollection value) {
            if (value == null) {
                return null;
            }
            return new ArrayList(value);
        }

        public static ArrayList ToArrayList(Object value) {
            if (value == null) {
                return null;
            }
            if (value is ArrayList) {
                return (ArrayList)value;
            }
            if (value is AssocArray) {
                return ((AssocArray)value).toArrayList();
            }
            if (value is IDictionary) {
                return new AssocArray((IDictionary)value).toArrayList();
            }
            if (value is ICollection) {
                return new ArrayList((ICollection)value);
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to 'ArrayList'.");
        }
        
        #endregion

        #region ToHashtable

        public static Hashtable ToHashtable(Hashtable value) {
            return value;
        }

        public static Hashtable ToHashtable(AssocArray value) {
            if (value == null) {
                return null;
            }
            return value.toHashtable();
        }

        public static Hashtable ToHashtable(IDictionary value) {
            if (value == null) {
                return null;
            }
            return new Hashtable(value);
        }

        public static Hashtable ToHashtable(ICollection value) {
            if (value == null) {
                return null;
            }
            return new AssocArray(value).toHashtable();
        }

        public static Hashtable ToHashtable(Object value) {
            if (value == null) {
                return null;
            }
            if (value is Hashtable) {
                return (Hashtable)value;
            }
            if (value is AssocArray) {
                return ((AssocArray)value).toHashtable();
            }
            if (value is IDictionary) {
                return new Hashtable((IDictionary)value);
            }
            if (value is ICollection) {
                return new AssocArray((ICollection)value).toHashtable();
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to 'Hashtable'.");
        }

        #endregion

        #region ToArray

        public static Array ToArray(Array value, Type conversionType) {
            return ToArray(value, conversionType, UTF8);
        }

        public static Array ToArray(Array value, Type conversionType, String charset) {
            return ToArray(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Array ToArray(Array value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (conversionType == null) {
                throw new ArgumentNullException("conversionType");
            }
            if (!conversionType.IsArray) {
                throw new ArgumentException("Must be an array type.");
            }
            if (value.GetType() == conversionType) {
                return value;
            }
            if (value.Rank > 1) {
                throw new RankException("Only single dimension arrays are supported here.");
            }
            Int32 length = value.GetLength(0);
            Type elementType = conversionType.GetElementType();
            Array array = Array.CreateInstance(elementType, length);
            if (array.GetType() != conversionType) {
                throw new RankException("Only single dimension arrays are supported here.");
            }
            for (Int32 i = 0; i < length; i++) {
                array.SetValue(ChangeType(value.GetValue(i), elementType, encoding), i);
            }
            return array;
        }

        public static Array ToArray(AssocArray value, Type conversionType) {
            return ToArray(value, conversionType, UTF8);
        }

        public static Array ToArray(AssocArray value, Type conversionType, String charset) {
            return ToArray(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Array ToArray(AssocArray value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (conversionType == null) {
                throw new ArgumentNullException("conversionType");
            }
            if (!conversionType.IsArray) {
                throw new ArgumentException("Must be an array type.");
            }
            if (conversionType == typeofObjectArray) {
                return value.toArrayList().ToArray();
            }
            try {
                return value.toArrayList().ToArray(conversionType.GetElementType());
            }
            catch (InvalidCastException) {
                ArrayList arraylist = value.toArrayList();
                Int32 length = arraylist.Count;
                Type elementType = conversionType.GetElementType();
                Array array = Array.CreateInstance(elementType, length);
                if (array.GetType() != conversionType) {
                    throw new RankException("Only single dimension arrays are supported here.");
                }
                for (Int32 i = 0; i < length; i++) {
                    array.SetValue(ChangeType(arraylist[i], elementType, encoding), i);
                }
                return array;
            }
        }

        public static Array ToArray(ArrayList value, Type conversionType) {
            return ToArray(value, conversionType, UTF8);
        }

        public static Array ToArray(ArrayList value, Type conversionType, String charset) {
            return ToArray(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Array ToArray(ArrayList value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (conversionType == null) {
                throw new ArgumentNullException("conversionType");
            }
            if (!conversionType.IsArray) {
                throw new ArgumentException("Must be an array type.");
            }
            if (conversionType == typeofObjectArray) {
                return value.ToArray();
            }
            try {
                return value.ToArray(conversionType.GetElementType());
            }
            catch (InvalidCastException) {
                Int32 length = value.Count;
                Type elementType = conversionType.GetElementType();
                Array array = Array.CreateInstance(elementType, length);
                if (array.GetType() != conversionType) {
                    throw new RankException("Only single dimension arrays are supported here.");
                }
                for (Int32 i = 0; i < length; i++) {
                    array.SetValue(ChangeType(value[i], elementType, encoding), i);
                }
                return array;
            }
        }

        public static Array ToArray(IDictionary value, Type conversionType) {
            return ToArray(value, conversionType, UTF8);
        }

        public static Array ToArray(IDictionary value, Type conversionType, String charset) {
            return ToArray(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Array ToArray(IDictionary value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (conversionType == null) {
                throw new ArgumentNullException("conversionType");
            }
            if (!conversionType.IsArray) {
                throw new ArgumentException("Must be an array type.");
            }
            ArrayList arraylist = new AssocArray(value).toArrayList();
            if (conversionType == typeofObjectArray) {
                return arraylist.ToArray();
            }
            try {
                return arraylist.ToArray(conversionType.GetElementType());
            }
            catch (InvalidCastException) {
                Int32 length = arraylist.Count;
                Type elementType = conversionType.GetElementType();
                Array array = Array.CreateInstance(elementType, length);
                if (array.GetType() != conversionType) {
                    throw new RankException("Only single dimension arrays are supported here.");
                }
                for (Int32 i = 0; i < length; i++) {
                    array.SetValue(ChangeType(arraylist[i], elementType, encoding), i);
                }
                return array;
            }
        }

        public static Array ToArray(ICollection value, Type conversionType) {
            return ToArray(value, conversionType, UTF8);
        }

        public static Array ToArray(ICollection value, Type conversionType, String charset) {
            return ToArray(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Array ToArray(ICollection value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (conversionType == null) {
                throw new ArgumentNullException("conversionType");
            }
            if (!conversionType.IsArray) {
                throw new ArgumentException("Must be an array type.");
            }
            ArrayList arraylist = new AssocArray(value).toArrayList();
            if (conversionType == typeofObjectArray) {
                return arraylist.ToArray();
            }
            try {
                return arraylist.ToArray(conversionType.GetElementType());
            }
            catch (InvalidCastException) {
                Int32 length = arraylist.Count;
                Type elementType = conversionType.GetElementType();
                Array array = Array.CreateInstance(elementType, length);
                if (array.GetType() != conversionType) {
                    throw new RankException("Only single dimension arrays are supported here.");
                }
                for (Int32 i = 0; i < length; i++) {
                    array.SetValue(ChangeType(arraylist[i], elementType, encoding), i);
                }
                return array;
            }
        }

        public static Array ToArray(Object value, Type conversionType) {
            return ToArray(value, conversionType, UTF8);
        }

        public static Array ToArray(Object value, Type conversionType, String charset) {
            return ToArray(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Array ToArray(Object value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (value is Array) {
                return ToArray((Array)value, conversionType, encoding);
            }
            if (value is AssocArray) {
                return ToArray((AssocArray)value, conversionType, encoding);
            }
            if (value is ArrayList) {
                return ToArray((ArrayList)value, conversionType, encoding);
            }
            if (value is IDictionary) {
                return ToArray((IDictionary)value, conversionType, encoding);
            }
            if (value is ICollection) {
                return ToArray((ICollection)value, conversionType, encoding);
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to '" + conversionType.ToString() + "'.");
        }

        #endregion

        #region ToIDictionary

        public static IDictionary ToIDictionary(IDictionary value, Type conversionType) {
            if (value == null) {
                return null;
            }
            if (!typeofIDictionary.IsAssignableFrom(conversionType)) {
                throw new ArgumentException("Parent type was not extensible by the given type.");
            }
            return (IDictionary)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { value });
        }

        public static IDictionary ToIDictionary(ICollection value, Type conversionType) {
            if (value == null) {
                return null;
            }
            if (!typeofIDictionary.IsAssignableFrom(conversionType)) {
                throw new ArgumentException("Parent type was not extensible by the given type.");
            }
            return (IDictionary)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { new AssocArray(value) });
        }

        public static IDictionary ToIDictionary(Object value, Type conversionType) {
            if (value == null) {
                return null;
            }
            if (!typeofIDictionary.IsAssignableFrom(conversionType)) {
                throw new ArgumentException("Parent type was not extensible by the given type.");
            }
            if (value is IDictionary) {
                return (IDictionary)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { value });
            }
            if (value is ICollection) {
                return (IDictionary)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { new AssocArray((ICollection)value) });
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to 'IDictionary'.");
        }
        
        #endregion

        #region ToIList

        public static IList ToIList(IDictionary value, Type conversionType) {
            if (value == null) {
                return null;
            }
            if (!typeofIList.IsAssignableFrom(conversionType)) {
                throw new ArgumentException("Parent type was not extensible by the given type.");
            }
            return (IList)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { new AssocArray(value) });
        }

        public static IList ToIList(ICollection value, Type conversionType) {
            if (value == null) {
                return null;
            }
            if (!typeofIList.IsAssignableFrom(conversionType)) {
                throw new ArgumentException("Parent type was not extensible by the given type.");
            }
            return (IList)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { value });
        }

        public static IList ToIList(Object value, Type conversionType) {
            if (value == null) {
                return null;
            }
            if (!typeofIList.IsAssignableFrom(conversionType)) {
                throw new ArgumentException("Parent type was not extensible by the given type.");
            }
            if (value is IDictionary) {
                return (IList)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { new AssocArray((IDictionary)value) });
            }
            if (value is ICollection) {
                return (IList)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { value });
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to 'IList'.");
        }
        
        #endregion

        #region ToICollection

        public static ICollection ToICollection(IDictionary value, Type conversionType) {
            if (value == null) {
                return null;
            }
            if (!typeofICollection.IsAssignableFrom(conversionType)) {
                throw new ArgumentException("Parent type was not extensible by the given type.");
            }
            return (ICollection)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { new AssocArray(value) });
        }

        public static ICollection ToICollection(ICollection value, Type conversionType) {
            if (value == null) {
                return null;
            }
            if (!typeofICollection.IsAssignableFrom(conversionType)) {
                throw new ArgumentException("Parent type was not extensible by the given type.");
            }
            return (ICollection)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { value });
        }

        public static ICollection ToICollection(Object value, Type conversionType) {
            if (value == null) {
                return null;
            }
            if (!typeofICollection.IsAssignableFrom(conversionType)) {
                throw new ArgumentException("Parent type was not extensible by the given type.");
            }
            if (value is IDictionary) {
                return (ICollection)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { new AssocArray((IDictionary)value) });
            }
            if (value is ICollection) {
                return (ICollection)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { value });
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to 'ICollection'.");
        }
        
        #endregion

        #region ToObject

        public static Object ToObject(AssocArray value, Type conversionType) {
            return ToObject(value, conversionType, UTF8);
        }

        public static Object ToObject(AssocArray value, Type conversionType, String charset) {
            return ToObject(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Object ToObject(AssocArray value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            return ToObject(value.toHashtable(), conversionType, encoding);
        }

        public static Object ToObject(Hashtable value, Type conversionType) {
            return ToObject(value, conversionType, UTF8);
        }

        public static Object ToObject(Hashtable value, Type conversionType, String charset) {
            return ToObject(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Object ToObject(Hashtable value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if (conversionType == null) {
                throw new ArgumentNullException("conversionType");
            }
            Object result = CreateInstance(conversionType);
            IEnumerator keys = value.Keys.GetEnumerator();
            keys.Reset();
            while (keys.MoveNext()) {
                Object key = keys.Current;
                String fieldname = ToString(key, encoding);
                FieldInfo field = GetField(conversionType, fieldname);
                if (field != null) {
                    field.SetValue(result, PHPConvert.ChangeType(value[key], field.FieldType, encoding));
                }                
            }
            return result;
        }

        public static Object ToObject(Object value, Type conversionType) {
            return ToObject(value, conversionType, UTF8);
        }

        public static Object ToObject(Object value, Type conversionType, String charset) {
            return ToObject(value, conversionType, Encoding.GetEncoding(charset));
        }

        public static Object ToObject(Object value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            if ((conversionType == typeofObject) || conversionType.IsInstanceOfType(value)) {
                return value;
            }
            if (value is AssocArray) {
                return ToObject((AssocArray)value, conversionType, encoding);
            }
            if (value is Hashtable) {
                return ToObject((Hashtable)value, conversionType, encoding);
            }
            IConvertible convertible = value as IConvertible;
            if (convertible != null) {
                return convertible.ToType(conversionType, provider);
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to '" + conversionType.ToString() + "'.");
        }

        #endregion

#if (Mono)
        #region ToMonoBigInteger

        public static Mono.Math.BigInteger ToMonoBigInteger(Mono.Math.BigInteger value) {
            return value;
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(BigInteger value) {
            return Mono.Math.BigInteger.Parse(value.ToString(10));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Byte value) {
            return (Mono.Math.BigInteger)(UInt32)(value);
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Byte[] value) {
            if (value == null) {
                return new Mono.Math.BigInteger(0);
            }
            return Mono.Math.BigInteger.Parse(ToString(value));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Boolean value) {
            return (Mono.Math.BigInteger)(UInt32)(value ? 1 : 0);
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Char value) {
            return (Mono.Math.BigInteger)(UInt32)value;
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Char[] value) {
            return Mono.Math.BigInteger.Parse(ToString(value));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(DateTime value) {
            throw new InvalidCastException("Invalid cast from 'DateTime' to 'Mono.Math.BigInteger'.");
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Decimal value) {
            return Mono.Math.BigInteger.Parse(value.ToString("#"));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Double value) {
            return Mono.Math.BigInteger.Parse(value.ToString("#"));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Int16 value) {
            return Mono.Math.BigInteger.Parse(value.ToString("#"));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Int32 value) {
            return Mono.Math.BigInteger.Parse(value.ToString("#"));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Int64 value) {
            return Mono.Math.BigInteger.Parse(value.ToString("#"));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(SByte value) {
            return Mono.Math.BigInteger.Parse(value.ToString("#"));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Single value) {
            return Mono.Math.BigInteger.Parse(value.ToString("#"));
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(String value) {
            if (value == null) {
                return new Mono.Math.BigInteger(0);
            }
            return Mono.Math.BigInteger.Parse(value);
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(StringBuilder value) {
            if (value == null) {
                return new Mono.Math.BigInteger(0);
            }
            return Mono.Math.BigInteger.Parse(value.ToString());
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(UInt16 value) {
            return (Mono.Math.BigInteger)(UInt32)value;
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(UInt32 value) {
            return (Mono.Math.BigInteger)value;
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(UInt64 value) {
            return (Mono.Math.BigInteger)value;
        }

        public static Mono.Math.BigInteger ToMonoBigInteger(Object value) {
            if (value == null) {
                return new Mono.Math.BigInteger(0);
            }
            if (value is Mono.Math.BigInteger) {
                return (Mono.Math.BigInteger)value;
            }
            if (value is BigInteger) {
                return Mono.Math.BigInteger.Parse(((BigInteger)value).ToString(10));
            }
            if (value is Byte) {
                return (Mono.Math.BigInteger)(UInt32)(Byte)value;
            }
            if (value is Boolean) {
                return (Mono.Math.BigInteger)(UInt32)((Boolean)value ? 1 : 0);
            }
            if (value is Byte[]) {
                return Mono.Math.BigInteger.Parse(ToString((Byte[])value));
            }
            if (value is Char) {
                return (Mono.Math.BigInteger)(UInt32)(Char)value;
            }
            if (value is Char[]) {
                return Mono.Math.BigInteger.Parse(ToString((Char[])value));
            }
            if (value is DateTime) {
                return ToMonoBigInteger((DateTime)value);
            }
            if (value is Decimal) {
                return Mono.Math.BigInteger.Parse(((Decimal)value).ToString("#"));
            }
            if (value is Double) {
                return Mono.Math.BigInteger.Parse(((Double)value).ToString("#"));
            }
            if (value is Int16) {
                return Mono.Math.BigInteger.Parse(((Int16)value).ToString("#"));
            }
            if (value is Int32) {
                return Mono.Math.BigInteger.Parse(((Int32)value).ToString("#"));
            }
            if (value is Int64) {
                return Mono.Math.BigInteger.Parse(((Int64)value).ToString("#"));
            }
            if (value is SByte) {
                return Mono.Math.BigInteger.Parse(((SByte)value).ToString("#"));
            }
            if (value is Single) {
                return Mono.Math.BigInteger.Parse(((Single)value).ToString("#"));
            }
            if (value is String) {
                return Mono.Math.BigInteger.Parse((String)value);
            }
            if (value is StringBuilder) {
                return Mono.Math.BigInteger.Parse(value.ToString());
            }
            if (value is UInt16) {
                return (Mono.Math.BigInteger)(UInt32)(UInt16)value;
            }
            if (value is UInt32) {
                return (Mono.Math.BigInteger)(UInt32)value;
            }
            if (value is UInt64) {
                return (Mono.Math.BigInteger)(UInt64)value;
            }
            return Mono.Math.BigInteger.Parse(((IConvertible)value).ToString(null));
        }

        #endregion
#endif

#if !(PocketPC || Smartphone || WindowsCE || NET1)
        #region ToGDictionary
        private static Object ToGDictionary(Object value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            Type[] argsType = conversionType.GetGenericArguments();
            if (value is AssocArray) {
                value = ((AssocArray)value).toHashtable();
            }
            if (value is IDictionary) {
                IDictionary src = (IDictionary)value;
                IDictionary result = (IDictionary)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { src.Count });
                IEnumerator keys = src.Keys.GetEnumerator();
                keys.Reset();
                while (keys.MoveNext()) {
                    Object key = keys.Current;
                    result[ChangeType(key, argsType[0], encoding)] = ChangeType(src[key], argsType[1], encoding);
                }
                return result;
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to Generic Dictionary.");
        }
        #endregion

        #region ToGList
        private static object ToGList(Object value, Type conversionType, Encoding encoding) {
            if (value == null) {
                return null;
            }
            Type[] argsType = conversionType.GetGenericArguments();
            if (value is AssocArray) {
                value = ((AssocArray)value).toArrayList();
            }
            if (value is IList) {
                IList src = (IList)value;
                Int32 count = src.Count;
                IList result = (IList)conversionType.InvokeMember(null, BindingFlags.Instance | BindingFlags.Public | BindingFlags.CreateInstance, null, null, new Object[] { count });
                for (Int32 i = 0; i < count; i++) {
                    result.Add(ChangeType(src[i], argsType[0], encoding));
                }
                return result;
            }
            throw new InvalidCastException("Invalid cast from '" + value.GetType().ToString() + "' to Generic Dictionary.");
        }
        #endregion
#endif

        private static FieldInfo GetField(Type type, String fieldName) {
            BindingFlags bindingflags = BindingFlags.Instance | BindingFlags.IgnoreCase | BindingFlags.FlattenHierarchy | BindingFlags.NonPublic | BindingFlags.Public;
            return type.GetField(fieldName, bindingflags);
        }

        private static Object CreateInstance(Type type) {
            try {
                return Activator.CreateInstance(type);
            }
            catch {
                BindingFlags bindingflags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.FlattenHierarchy;
                ConstructorInfo ctor = type.GetConstructor(bindingflags, null, new Type[0], null);
                return ctor.Invoke(new Object[0]);
            }
        }
    }
}