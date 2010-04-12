/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPReader.cs                                             |
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

/* PHPReader class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

namespace org.phprpc.util {
    using System;
    using System.Collections;
    using System.IO;
    using System.Text;
    using System.Reflection;
    using System.Globalization;
    using System.Runtime.Serialization;

    internal sealed class PHPReader {
        private static readonly Type typeofObject = typeof(Object);
        private static Hashtable typecache = new Hashtable();
        private static Hashtable __wakeupcache = new Hashtable();
        private Encoding encoding;
        private Assembly[] assemblies;

        public PHPReader(Encoding encoding, Assembly[] assemblies) {
            this.encoding = encoding;
            this.assemblies = assemblies;
        }

        public Object Deserialize(Stream stream) {
            if (stream == null) {
                throw new ArgumentNullException("serializationStream");
            }
            if (!stream.CanRead) {
                throw new SerializationException("Can't read in the serialization stream");
            }
            if (stream.Length == 0) {
                throw new SerializationException("Attempting to deserialize an empty stream.");
            }
            return Deserialize(stream, new ArrayList());
        }

        private Object Deserialize(Stream stream, ArrayList objectContainer) {
            Int32 tag = stream.ReadByte();
            if (tag < 0) {
                throw new SerializationException("End of Stream encountered before parsing was completed.");
            }
            Object result;
            switch (tag) {
            case PHPSerializationTag.Null:
                result = ReadNull(stream);
                objectContainer.Add(result);
                return result;
            case PHPSerializationTag.Boolean:
                result = ReadBoolean(stream);
                objectContainer.Add(result);
                return result;
            case PHPSerializationTag.Integer:
                result = ReadInteger(stream);
                objectContainer.Add(result);
                return result;
            case PHPSerializationTag.Double:
                result = ReadDouble(stream);
                objectContainer.Add(result);
                return result;
            case PHPSerializationTag.BinaryString:
                result = ReadBinaryString(stream);
                objectContainer.Add(result);
                return result;
            case PHPSerializationTag.EscapedBinaryString:
                result = ReadEscapedBinaryString(stream);
                objectContainer.Add(result);
                return result;
            case PHPSerializationTag.UnicodeString:
                result = ReadUnicodeString(stream);
                objectContainer.Add(result);
                return result;
            case PHPSerializationTag.Reference:
                return ReadReference(stream, objectContainer);
            case PHPSerializationTag.PointerReference:
                return ReadPointerReference(stream, objectContainer);
            case PHPSerializationTag.AssocArray:
                return ReadAssocArray(stream, objectContainer);
            case PHPSerializationTag.Object:
                return ReadObject(stream, objectContainer);
            case PHPSerializationTag.CustomObject:
                return ReadCustomObject(stream, objectContainer);
            default:
                throw new SerializationException("Unknown Tag: '" + (Char)tag + "'.");
            }
        }

        private String ReadNumber(Stream stream) {
            StringBuilder sb = new StringBuilder();
            do {
                Int32 i = stream.ReadByte();
                switch (i) {
                case PHPSerializationTag.Semicolon:
                case PHPSerializationTag.Colon:
                    return sb.ToString();
                default:
                    sb.Append((Char)i);
                    break;
                }
            } while (true);
        }

        private Object ReadNull(Stream stream) {
            stream.Position++;
            return null;
        }

        private Boolean ReadBoolean(Stream stream) {
            stream.Position++;
            Boolean b = (stream.ReadByte() == PHPSerializationTag.One);
            stream.Position++;
            return b;
        }

        private Int32 ReadInteger(Stream stream) {
            stream.Position++;
            return Int32.Parse(ReadNumber(stream));
        }

        private Object ReadDouble(Stream stream) {
            stream.Position++;
            String d = ReadNumber(stream);
            if (d == "NAN")
                return Double.NaN;
            if (d == "INF")
                return Double.PositiveInfinity;
            if (d == "-INF")
                return Double.NegativeInfinity;

            if (d.IndexOfAny(new Char[] {'.', 'e', 'E'}) > 0) {
                return Double.Parse(d);
            }
            Int32 length = d.Length;
            Boolean sign = (d[0] == '-');
            if (!sign && (length < 10)) {
                return Int32.Parse(d);
            }
            else if (!sign && (length == 10)) {
                UInt64 t1 = UInt64.Parse(d);
                if (t1 > UInt32.MaxValue) {
                    return t1;
                }
                else {
                    return (UInt32)t1;
                }
            }
            else if (length <= 19) {
                if (sign) {
                    return Int64.Parse(d);
                }
                else {
                    UInt64 t2 = UInt64.Parse(d);
                    if (t2 > Int64.MaxValue) {
                        return t2;
                    }
                    else {
                        return (Int64)t2;
                    }
                }
            }
            else if (length == 20) {
                Decimal t3 = Decimal.Parse(d);
                if (sign) {
                    if (t3 < Int64.MinValue) {
                        return t3;
                    }
                    else {
                        return (Int64)t3;
                    }
                }
                else {
                    if (t3 > UInt64.MaxValue) {
                        return t3;
                    }
                    else {
                        return (UInt64)t3;
                    }
                }
            }
            else if ((length < 29) || (sign && (length < 30))) {
                return Decimal.Parse(d);
            }
            else {
                try {
                    return Decimal.Parse(d);
                }
                catch {
                    return Double.Parse(d);
                }
            }
        }

        private Byte[] ReadBinaryString(Stream stream) {
            Int32 len = ReadInteger(stream);
            stream.Position++;
            Byte[] buf = new Byte[len];
            stream.Read(buf, 0, len);
            stream.Position += 2;
            return buf;
        }

        private Byte[] ReadEscapedBinaryString(Stream stream) {
            Int32 len = ReadInteger(stream);
            stream.Position++;
            Byte[] buf = new Byte[len];
            for (Int32 i = 0; i < len; i++) {
                Int32 c = stream.ReadByte();
                if (c == PHPSerializationTag.Slash) {
                    Char c1 = (Char)stream.ReadByte();
                    Char c2 = (Char)stream.ReadByte();
                    buf[i] = Byte.Parse(String.Concat(c1, c2), NumberStyles.HexNumber);
                }
                else {
                    buf[i] = (Byte)c;
                }
            }
            stream.Position += 2;
            return buf;
        }

        private String ReadUnicodeString(Stream stream) {
            Int32 len = ReadInteger(stream);
            stream.Position++;
            StringBuilder sb = new StringBuilder(len);
            for (Int32 i = 0; i < len; i++) {
                Int32 c = stream.ReadByte();
                if (c == PHPSerializationTag.Slash) {
                    Char c1 = (Char)stream.ReadByte();
                    Char c2 = (Char)stream.ReadByte();
                    Char c3 = (Char)stream.ReadByte();
                    Char c4 = (Char)stream.ReadByte();
                    sb.Append((Char)Int32.Parse(String.Concat(c1, c2, c3, c4), NumberStyles.HexNumber));
                }
                else {
                    sb.Append((Char)c);
                }
            }
            stream.Position += 2;
            return sb.ToString();
        }

        private Object ReadReference(Stream stream, ArrayList objectContainer) {
            Object result = objectContainer[ReadInteger(stream) - 1];
            objectContainer.Add(result);
            return result;
        }

        private Object ReadPointerReference(Stream stream, ArrayList objectContainer) {
            return objectContainer[ReadInteger(stream) - 1];
        }

        private AssocArray ReadAssocArray(Stream stream, ArrayList objectContainer) {
            Int32 n = ReadInteger(stream);
            stream.Position++;
            AssocArray a = new AssocArray(n);
            objectContainer.Add(a);
            for (Int32 i = 0; i < n; i++) {
                Int32 tag = stream.ReadByte();
                if (tag < 0) {
                    throw new SerializationException("End of Stream encountered before parsing was completed.");
                }
                Int32 index;
                String key;
                switch (tag) {
                case PHPSerializationTag.Integer:
                    index = ReadInteger(stream);
                    a[index] = Deserialize(stream, objectContainer);
                    break;
                case PHPSerializationTag.BinaryString:
                    key = GetString(ReadBinaryString(stream));
                    a[key] = Deserialize(stream, objectContainer);
                    break;
                case PHPSerializationTag.EscapedBinaryString:
                    key = GetString(ReadEscapedBinaryString(stream));
                    a[key] = Deserialize(stream, objectContainer);
                    break;
                case PHPSerializationTag.UnicodeString:
                    key = ReadUnicodeString(stream);
                    a[key] = Deserialize(stream, objectContainer);
                    break;
                default:
                    throw new SerializationException("Unexpected Tag: '" + (Char)tag + "'.");
                }
            }
            stream.Position++;
            return a;
        }

        private DateTime ReadDateTime(Stream stream, ArrayList objectContainer) {
            Hashtable datetime = new Hashtable(7);
            for (Int32 i = 0; i < 7; i++) {
                String key = ReadKey(stream);
                if (stream.ReadByte() == PHPSerializationTag.Integer) {
                    datetime[key] = ReadInteger(stream);
                }
                else {
                    throw new SerializationException("An error occurred while deserializing the object. The serialized data is corrupt.");
                }
            }
            stream.Position++;
            DateTime result = new DateTime(
                (Int32)datetime["year"],
                (Int32)datetime["month"],
                (Int32)datetime["day"],
                (Int32)datetime["hour"],
                (Int32)datetime["minute"],
                (Int32)datetime["second"],
                (Int32)datetime["millisecond"]
            );
            objectContainer.Add(result);
            objectContainer.Add(datetime["year"]);
            objectContainer.Add(datetime["month"]);
            objectContainer.Add(datetime["day"]);
            objectContainer.Add(datetime["hour"]);
            objectContainer.Add(datetime["minute"]);
            objectContainer.Add(datetime["second"]);
            objectContainer.Add(datetime["millisecond"]);
            return result;
        }

        private Object ReadObject(Stream stream, ArrayList objectContainer) {
            String typeName = GetString(ReadBinaryString(stream));
            Int32 memberCount = Int32.Parse(ReadNumber(stream));
            stream.Position++;
            if (typeName.Equals("PHPRPC_Date")) {
                return ReadDateTime(stream, objectContainer);
            }
            Type type = GetTypeByAlias(typeName);
            Object result;
            if (type == null) {
                result = new Hashtable(memberCount);
                objectContainer.Add(result);
                for (Int32 i = 0; i < memberCount; i++) {
                    String key = ReadKey(stream);
                    if (key[0] == '\0') {
                        key = key.Substring(key.IndexOf('\0', 1) + 1);
                    }
                    ((Hashtable)result)[key] = Deserialize(stream, objectContainer);
                }
            }
            else {
                result = CreateInstance(type);
                objectContainer.Add(result);
                for (Int32 i = 0; i < memberCount; i++) {
                    FieldInfo field = GetField(type, ReadKey(stream));
                    Object value = Deserialize(stream, objectContainer);
                    if (field != null) {
                        field.SetValue(result, PHPConvert.ChangeType(value, field.FieldType, encoding));
                    }
                }
                MethodInfo __wakeup;
                if (__wakeupcache.ContainsKey(type)) {
                    __wakeup = (MethodInfo)__wakeupcache[type];
                }
                else {
                    BindingFlags bindingflags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.IgnoreCase;
                    __wakeup = type.GetMethod("__wakeup", bindingflags, null, new Type[0], new ParameterModifier[0]);
                    __wakeupcache[type] = __wakeup;
                }
                if (__wakeup != null) {
                    __wakeup.Invoke(result, null);
                }
            }
            stream.Position++;
            return result;
        }

        private Object ReadCustomObject(Stream stream, ArrayList objectContainer) {
            String typeName = GetString(ReadBinaryString(stream));
            Int32 length = Int32.Parse(ReadNumber(stream));
            stream.Position++;
            Type type = GetTypeByAlias(typeName);
            if (type == null) {
                throw new SerializationException("Unknown type " + typeName + ".");
            }
            Object result = CreateInstance(type);
            objectContainer.Add(result);
            if (result is Serializable) {
                Byte[] bytes = new Byte[length];
                stream.Read(bytes, 0, length);
                ((Serializable)result).Deserialize(bytes);
            }
            else {
                stream.Position += length;
            }
            stream.Position++;
            return result;
        }

        private String ReadKey(Stream stream) {
            String key;
            Int32 tag = stream.ReadByte();
            if (tag < 0) {
                throw new SerializationException("End of Stream encountered before parsing was completed.");
            }
            switch (tag) {
            case PHPSerializationTag.BinaryString:
                key = GetString(ReadBinaryString(stream));
                break;
            case PHPSerializationTag.EscapedBinaryString:
                key = GetString(ReadEscapedBinaryString(stream));
                break;
            case PHPSerializationTag.UnicodeString:
                key = ReadUnicodeString(stream);
                break;
            default:
                throw new SerializationException("Unexpected Tag: '" + (Char)tag + "'.");
            }
            return key;
        }

        private FieldInfo GetField(Type type, String fieldName) {
            if (fieldName[0] == '\0') {
                fieldName = fieldName.Substring(fieldName.IndexOf('\0', 1) + 1);
            }
            BindingFlags bindingflags = BindingFlags.Instance | BindingFlags.IgnoreCase | BindingFlags.NonPublic | BindingFlags.Public;
            FieldInfo field = null;
            while ((field == null) && (type != typeofObject) && IsSerializable(type)) {
                field = type.GetField(fieldName, bindingflags);
                type = type.BaseType;
            }
            return field;
        }

        private Type GetTypeByAlias(String typeName) {
            if (typecache.ContainsKey(typeName)) {
                return (Type)typecache[typeName];
            }
            ArrayList arraylist = new ArrayList();
            Int32 pos = typeName.IndexOf('_');
            while (pos > -1) {
                arraylist.Add(pos);
                pos = typeName.IndexOf('_', pos + 1);
            }
            Type type;
            if (arraylist.Count > 0) {
                Int32[] positions;
                positions = (Int32[])arraylist.ToArray(typeof(Int32));
                StringBuilder typename = new StringBuilder(typeName);
                type = GetType(typename, positions, 0, '.');
                if (type == null) {
                    type = GetType(typename, positions, 0, '_');
                }
                if (type == null) {
                    type = GetNestedType(typename, positions, 0, '+');
                }
            }
            else {
                type = GetType(typeName.ToString());
            }
            typecache[typeName] = type;
            return type;
        }

        private Type GetType(StringBuilder typeName, Int32[] positions, Int32 i, Char c) {
            Int32 length = positions.GetLength(0);
            Type type;
            if (i < length) {
                typeName[positions[i++]] = c;
                type = GetType(typeName, positions, i, '.');
                if (i < length) {
                    if (type == null) {
                        type = GetType(typeName, positions, i, '_');
                    }
                    if (type == null) {
                        type = GetNestedType(typeName, positions, i, '+');
                    }
                }
            }
            else {
                type = GetType(typeName.ToString());
            }
            return type;
        }

        private Type GetNestedType(StringBuilder typeName, Int32[] positions, Int32 i, Char c) {
            Int32 length = positions.GetLength(0);
            Type type;
            if (i < length) {
                typeName[positions[i++]] = c;
                type = GetNestedType(typeName, positions, i, '_');
                if (i < length && type == null) {
                    type = GetNestedType(typeName, positions, i, '+');
                }
            }
            else {
                type = GetType(typeName.ToString());
            }
            return type;
        }

        private Type GetType(String typeName) {
            Type type = null;
            for (Int32 i = 0, count = assemblies.GetLength(0); type == null && i < count; i++) {
                type = assemblies[i].GetType(typeName, false);
            }
            return type;
        }

        private Object CreateInstance(Type type) {
            try {
                return Activator.CreateInstance(type);
            }
            catch {
                BindingFlags bindingflags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.FlattenHierarchy;
                ConstructorInfo ctor = type.GetConstructor(bindingflags, null, new Type[0], null);
                return ctor.Invoke(new Object[0]);
            }
        }

        private string GetString(Byte[] bytes) {
            return encoding.GetString(bytes, 0, bytes.GetLength(0));
        }

        private Boolean IsSerializable(Type type) {
            return (type.Attributes & TypeAttributes.Serializable) == TypeAttributes.Serializable;
        }
    }
}