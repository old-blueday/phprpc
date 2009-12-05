/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPWriter.cs                                             |
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

/* PHPWriter class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Mar 23, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */

namespace org.phprpc.util {
    using System;
    using System.Collections;
    using System.IO;
    using System.Text;
    using System.Reflection;
    using System.Runtime.Serialization;

    internal sealed class PHPWriter {
        private static readonly Type typeofObject = typeof(Object);
        private static Hashtable fieldscache = new Hashtable();
        private static Hashtable __sleepcache = new Hashtable();
#if SILVERLIGHT
        private static Encoding utf8 = new UTF8Encoding();
#endif
        private Stream stream;
        private Encoding encoding;

        public PHPWriter(Stream stream, Encoding encoding) {
            this.stream = stream;
            this.encoding = encoding;
        }

        public void Serialize(Object graph) {
            if (stream == null) {
                throw new ArgumentNullException("serializationStream");
            }
            if (!stream.CanWrite) {
                throw new SerializationException("Can't write in the serialization stream");
            }
            Int32 objectID = 1;
            Serialize(graph, new Hashtable(), ref objectID);
        }

        private void Serialize(Object graph, Hashtable objectContainer, ref Int32 objectID) {
            if (graph == null) {
                WriteNull();
                objectID++;
            }
            else if (graph is Boolean) {
                WriteBoolean((Boolean)graph);
                objectID++;
            }
            else if ((graph is Byte) || (graph is SByte) || (graph is Int16) || (graph is UInt16) || (graph is Int32)) {
                WriteInteger(graph);
                objectID++;
            }
            else if ((graph is UInt32) || (graph is Int64) || (graph is UInt64) || (graph is Decimal)) {
                WriteDouble(graph);
                objectID++;
            }
            else if (graph is Single) {
                WriteDouble((Single)graph);
                objectID++;
            }
            else if (graph is Double) {
                WriteDouble((Double)graph);
                objectID++;
            }
            else if (graph is Enum) {
                WriteEnum((Enum)graph);
                objectID++;
            }
            else if (graph is Byte[]) {
                if (objectContainer.ContainsKey(graph)) {
                    WriteReference(objectContainer[graph]);
                }
                else {
                    objectContainer.Add(graph, objectID);
                    WriteBinaryString((Byte[])graph);
                }
                objectID++;
            }
            else if ((graph is Char) || (graph is String) || (graph is StringBuilder) || (graph is BigInteger)
#if (Mono)
                 || (graph is Mono.Math.BigInteger)
#endif
                ) {
                if (objectContainer.ContainsKey(graph)) {
                    WriteReference(objectContainer[graph]);
                }
                else {
                    objectContainer.Add(graph, objectID);
                    WriteString(graph.ToString());
                }
                objectID++;
            }
            else if (graph is Char[]) {
                if (objectContainer.ContainsKey(graph)) {
                    WriteReference(objectContainer[graph]);
                }
                else {
                    objectContainer.Add(graph, objectID);
                    WriteBinaryString(encoding.GetBytes((Char[])graph));
                }
                objectID++;
            }
            else if (graph is DateTime) {
                if (objectContainer.ContainsKey(graph)) {
                    WriteReference(objectContainer[graph]);
                    objectID++;
                }
                else {
                    objectContainer.Add(graph, objectID);
                    WriteDateTime((DateTime)graph);
                    objectID += 8;
                }
            }
            else if (graph is ICollection) {
                if (objectContainer.ContainsKey(graph)) {
                    WritePointerReference(objectContainer[graph]);
                }
                else if (graph is Array) {
                    objectContainer.Add(graph, objectID++);
                    WriteArray((Array)graph, objectContainer, ref objectID);
                }
                else if (graph is IDictionary) {
                    objectContainer.Add(graph, objectID++);
                    WriteIDictionary((IDictionary)graph, objectContainer, ref objectID);
                }
                else if (graph is IList) {
                    objectContainer.Add(graph, objectID++);
                    WriteIList((IList)graph, objectContainer, ref objectID);
                }
                else {
                    objectContainer.Add(graph, objectID++);
                    WriteIList(new ArrayList((ICollection)graph), objectContainer, ref objectID);
                }
            }
            else if (IsSerializable(graph.GetType())) {
                if (objectContainer.ContainsKey(graph)) {
                    WriteReference(objectContainer[graph]);
                    objectID++;
                }
                else if (graph is ISerializable) {
                    throw new SerializationException("PHP Serialization is not available for ISerializable object.");
                }
                else if (graph is Serializable) {
                    objectContainer.Add(graph, objectID++);
                    WriteCustomObject(graph);
                }
                else {
                    objectContainer.Add(graph, objectID++);
                    WriteObject(graph, objectContainer, ref objectID);
                }
            }
            else {
                throw new SerializationException("The given type is not serializable.");
            }
        }

        private void WriteNull() {
            stream.WriteByte(PHPSerializationTag.Null);
            stream.WriteByte(PHPSerializationTag.Semicolon);
        }

        private void WriteBoolean(Boolean value) {
            stream.WriteByte(PHPSerializationTag.Boolean);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte((Byte)(value ? PHPSerializationTag.One : PHPSerializationTag.Zero));
            stream.WriteByte(PHPSerializationTag.Semicolon);
        }

        private void WriteNumber(Object value) {
#if SILVERLIGHT
            Byte[] buf = utf8.GetBytes(value.ToString());
#else
            Byte[] buf = Encoding.ASCII.GetBytes(value.ToString());
#endif
            stream.Write(buf, 0, buf.GetLength(0));
        }

        private void WriteNumber(String value) {
#if SILVERLIGHT
            Byte[] buf = utf8.GetBytes(value);
#else
            Byte[] buf = Encoding.ASCII.GetBytes(value);
#endif
            stream.Write(buf, 0, buf.GetLength(0));
        }

        private void WriteInteger(Object graph) {
            stream.WriteByte(PHPSerializationTag.Integer);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(graph);
            stream.WriteByte(PHPSerializationTag.Semicolon);
        }

        private void WriteDouble(Object graph) {
            stream.WriteByte(PHPSerializationTag.Double);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(graph);
            stream.WriteByte(PHPSerializationTag.Semicolon);
        }

        private void WriteDouble(Single value) {
            stream.WriteByte(PHPSerializationTag.Double);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber((Single.IsNaN(value) ? "NAN" :
                       (Single.IsPositiveInfinity(value) ? "INF" :
                       (Single.IsNegativeInfinity(value) ? "-INF" : value.ToString()))));
            stream.WriteByte(PHPSerializationTag.Semicolon);
        }

        private void WriteDouble(Double value) {
            stream.WriteByte(PHPSerializationTag.Double);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber((Double.IsNaN(value) ? "NAN" :
                       (Double.IsPositiveInfinity(value) ? "INF" :
                       (Double.IsNegativeInfinity(value) ? "-INF" : value.ToString()))));
            stream.WriteByte(PHPSerializationTag.Semicolon);
        }

        private void WriteEnum(Enum value) {
            Type entype = value.GetType();
            Type undertype = Enum.GetUnderlyingType(entype);
            Object graph = Convert.ChangeType(value, undertype, null);
            if ((graph is Byte) || (graph is SByte) || (graph is Int16) || (graph is UInt16) || (graph is Int32)) {
                WriteInteger(graph);
            }
            else {
                WriteDouble(graph);
            }
        }

        private void WritePointerReference(Object value) {
            stream.WriteByte(PHPSerializationTag.PointerReference);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(value);
            stream.WriteByte(PHPSerializationTag.Semicolon);
        }

        private void WriteReference(Object value) {
            stream.WriteByte(PHPSerializationTag.Reference);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(value);
            stream.WriteByte(PHPSerializationTag.Semicolon);
        }

        private void WriteBinaryString(Byte[] value) {
            Int32 length = value.GetLength(0);
            stream.WriteByte(PHPSerializationTag.BinaryString);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(length);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.Quote);
            stream.Write(value, 0, length);
            stream.WriteByte(PHPSerializationTag.Quote);
            stream.WriteByte(PHPSerializationTag.Semicolon);
        }

        private void WriteString(String value) {
            WriteBinaryString(encoding.GetBytes(value));
        }

        private void WriteDateTime(DateTime value) {
            Byte[] typename = encoding.GetBytes("PHPRPC_Date");
            Int32 length = typename.GetLength(0);
            stream.WriteByte(PHPSerializationTag.Object);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(length);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.Quote);
            stream.Write(typename, 0, length);
            stream.WriteByte(PHPSerializationTag.Quote);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte((Byte)'7');
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.LeftB);
            WriteString("year");
            WriteInteger(value.Year);
            WriteString("month");
            WriteInteger(value.Month);
            WriteString("day");
            WriteInteger(value.Day);
            WriteString("hour");
            WriteInteger(value.Hour);
            WriteString("minute");
            WriteInteger(value.Minute);
            WriteString("second");
            WriteInteger(value.Second);
            WriteString("millisecond");
            WriteInteger(value.Millisecond);
            stream.WriteByte(PHPSerializationTag.RightB);
        }

        private void WriteArray(Array array, Hashtable objectContainer, ref Int32 objectID) {
            if (array.Rank > 1) {
                throw new RankException("Only single dimension arrays are supported here.");
            }
            stream.WriteByte(PHPSerializationTag.AssocArray);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(array.GetLength(0));
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.LeftB);
            Int32 lowerBound = array.GetLowerBound(0);
            Int32 upperBound = array.GetUpperBound(0);
            for (Int32 i = lowerBound; i <= upperBound; i++) {
                WriteInteger(i);
                Serialize(array.GetValue(i), objectContainer, ref objectID);
            }
            stream.WriteByte(PHPSerializationTag.RightB);
        }

        private void WriteIDictionary(IDictionary dictionary, Hashtable objectContainer, ref Int32 objectID) {
            stream.WriteByte(PHPSerializationTag.AssocArray);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(dictionary.Count);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.LeftB);
            foreach (DictionaryEntry entry in dictionary) {
                if ((entry.Key is Byte) || (entry.Key is SByte) || (entry.Key is Int16) || (entry.Key is UInt16) || (entry.Key is Int32)) {
                    WriteInteger(entry.Key);
                }
                else {
                    WriteString(entry.Key.ToString());
                }
                Serialize(entry.Value, objectContainer, ref objectID);
            }
            stream.WriteByte(PHPSerializationTag.RightB);
        }

        private void WriteIList(IList list, Hashtable objectContainer, ref Int32 objectID) {
            Int32 count = list.Count;
            stream.WriteByte(PHPSerializationTag.AssocArray);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(count);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.LeftB);
            for (Int32 i = 0; i < count; i++) {
                WriteInteger(i);
                Serialize(list[i], objectContainer, ref objectID);
            }
            stream.WriteByte(PHPSerializationTag.RightB);
        }

        private void WriteCustomObject(Object graph) {
            Byte[] fullName = encoding.GetBytes(GetFullTypeName(graph.GetType().FullName));
            Int32 fullNameLength = fullName.GetLength(0);
            Byte[] buf = ((Serializable)graph).Serialize();
            Int32 bufLength = buf.GetLength(0);
            stream.WriteByte(PHPSerializationTag.CustomObject);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(fullNameLength);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.Quote);
            stream.Write(fullName, 0, fullNameLength);
            stream.WriteByte(PHPSerializationTag.Quote);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(bufLength);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.LeftB);
            stream.Write(buf, 0, bufLength);
            stream.WriteByte(PHPSerializationTag.RightB);
        }

        private void WriteObject(Object graph, Hashtable objectContainer, ref Int32 objectID) {
            Type type = graph.GetType();
            Byte[] fullName = encoding.GetBytes(GetFullTypeName(type.FullName));
            Int32 fullNameLength = fullName.GetLength(0);
            FieldInfo[] fields;
            Int32 fieldCount;
            MethodInfo __sleep;
            if (fieldscache.ContainsKey(type)) {
                fields = (FieldInfo[])fieldscache[type];
                fieldCount = fields.GetLength(0);
                if (__sleepcache.ContainsKey(type)) {
                    __sleep = (MethodInfo)__sleepcache[type];
                    __sleep.Invoke(graph, null);
                }
            }
            else {
                BindingFlags bindingflags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance | BindingFlags.IgnoreCase;
                __sleep = type.GetMethod("__sleep", bindingflags, null, new Type[0], new ParameterModifier[0]);
                if (__sleep != null) {
                    __sleepcache[type] = __sleep;
                    String[] fieldNames = (String[])__sleep.Invoke(graph, null);
                    fieldCount = fieldNames.GetLength(0);
                    fields = new FieldInfo[fieldCount];
                    for (Int32 i = 0; i < fieldCount; i++) {
                        fields[i] = type.GetField(fieldNames[i], bindingflags);
                    }
                }
                else {
                    fields = GetSerializableMembers(type);
                    fieldCount = fields.GetLength(0);
                }
                fieldscache[type] = fields;
            }
            stream.WriteByte(PHPSerializationTag.Object);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(fullNameLength);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.Quote);
            stream.Write(fullName, 0, fullNameLength);
            stream.WriteByte(PHPSerializationTag.Quote);
            stream.WriteByte(PHPSerializationTag.Colon);
            WriteNumber(fieldCount);
            stream.WriteByte(PHPSerializationTag.Colon);
            stream.WriteByte(PHPSerializationTag.LeftB);
            for (Int32 i = 0; i < fieldCount; i++) {
                FieldInfo field = fields[i];
                WriteString(field.Name);
                Serialize(field.GetValue(graph), objectContainer, ref objectID);
            }
            stream.WriteByte(PHPSerializationTag.RightB);
        }

        private String GetFullTypeName(String fullName) {
            return fullName.Replace('.', '_').Replace('+', '_');
        }

        private FieldInfo[] GetSerializableMembers(Type type) {
            ArrayList arraylist = new ArrayList();
            while ((type != typeofObject) && IsSerializable(type)) {
                BindingFlags bindingflags = BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance;
                FieldInfo[] fields = type.GetFields(bindingflags);
                foreach (FieldInfo field in fields) {
                    if (field != null && !field.IsNotSerialized) {
                        arraylist.Add(field);
                    }
                }
                type = type.BaseType;
            }
            FieldInfo[] result = new FieldInfo[arraylist.Count];
            arraylist.CopyTo(result);
            return result;
        }

        private Boolean IsSerializable(Type type) {
            return (type.Attributes & TypeAttributes.Serializable) == TypeAttributes.Serializable;
        }

    }
}