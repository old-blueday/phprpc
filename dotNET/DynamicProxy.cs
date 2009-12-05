/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| DynamicProxy.cs                                          |
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

/* DynamicProxy class.
 * Copyright (C) 2005 Kazuya Ujihara <http://www.ujihara.jp/>
 * All rights reserved.
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Dec 18, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */

#if !(PocketPC || Smartphone || WindowsCE)
namespace org.phprpc.util {
    using System;
    using System.Reflection;
    using System.Reflection.Emit;
    using System.Collections;
    using System.Globalization;

    public class DynamicProxy {
        protected IInvocationHandler handler;

        private static ArrayList methodsTable = new ArrayList();
        private static readonly Type[] Types_InvocationHandler = new Type[] { typeof(IInvocationHandler) };
        private static readonly FieldInfo FieldInfo_handler = typeof(DynamicProxy).GetField("handler", BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic);
        private static readonly ConstructorInfo DynamicProxy_Ctor = typeof(DynamicProxy).GetConstructor(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance, null, new Type[] { typeof(IInvocationHandler) }, null);
        private static readonly MethodInfo DynamicProxy_Invoke = typeof(IInvocationHandler).GetMethod("Invoke", new Type[] { typeof(Object), typeof(MethodInfo), typeof(Object[]) });
        private static readonly MethodInfo MethodInfo_GetMethod = typeof(DynamicProxy).GetMethod("GetMethod", BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Static, null, new Type[] { typeof(Int32) }, null);
        private static readonly Type typeofInt8 = typeof(sbyte);
        private static readonly Type typeofUInt8 = typeof(byte);
        private static readonly Type typeofBoolean = typeof(bool);
        private static readonly Type typeofInt16 = typeof(short);
        private static readonly Type typeofUInt16 = typeof(ushort);
        private static readonly Type typeofChar = typeof(char);
        private static readonly Type typeofInt32 = typeof(int);
        private static readonly Type typeofUInt32 = typeof(uint);
        private static readonly Type typeofInt64 = typeof(long);
        private static readonly Type typeofUInt64 = typeof(ulong);
        private static readonly Type typeofSingle = typeof(float);
        private static readonly Type typeofDouble = typeof(double);


        private static Int32 countDymamicAssembly = 0;

        private static Hashtable proxyCache = new Hashtable();

        protected DynamicProxy(IInvocationHandler handler) {
            this.handler = handler;
        }
#if !SILVERLIGHT
        private static Boolean flagCreateFile = false;

        public static Boolean FlagCreateFile {
            get {
                return flagCreateFile;
            }
            set {
                lock (typeof(DynamicProxy)) {
                    flagCreateFile = value;
                }
            }
        }
#endif
        public static Boolean IsProxyType(Type type) {
            if (type == null) {
                throw new ArgumentNullException();
            }
            return proxyCache.ContainsValue(type);
        }

        public static IInvocationHandler GetInvocationHandler(Object proxy) {
            if (proxy == null) {
                throw new ArgumentNullException();
            }
            if (!IsProxyType(proxy.GetType())) {
                throw new ArgumentException();
            }

            return ((DynamicProxy)proxy).handler;
        }

        public static Object NewInstance(AppDomain domain, Type[] interfaces, IInvocationHandler handler) {
            return GetProxy(domain, interfaces)
                .GetConstructor(Types_InvocationHandler)
                .Invoke(new Object[] { handler });
        }

        public static Type GetProxy(AppDomain domain, params Type[] interfaces) {
            lock (typeof(DynamicProxy)) {
                ProxyKey proxyKey = new ProxyKey(domain, interfaces);

                Type proxy = null;
                
                if (proxyCache.ContainsKey(proxyKey)) {
                    proxy = (Type)proxyCache[proxyKey];
                }

                if (proxy == null) {
                    interfaces = SumUpInterfaces(interfaces);

                    String dynamicAssemblyName;
                    String dynamicModuleName;
                    String dynamicProxyTypeName;
                    String strNumber = countDymamicAssembly.ToString(NumberFormatInfo.InvariantInfo);
                    dynamicAssemblyName = "$DynamicAssembly" + strNumber;
                    dynamicModuleName = "$DynamicModule" + strNumber;
                    dynamicProxyTypeName = "$Proxy" + strNumber;
                    countDymamicAssembly++;

                    AssemblyBuilder assemblyBuilder;
                    AssemblyName assemblyName = new AssemblyName();
                    assemblyName.Name = dynamicAssemblyName;
#if !SILVERLIGHT
                    assemblyBuilder = domain.DefineDynamicAssembly(assemblyName, FlagCreateFile ? AssemblyBuilderAccess.RunAndSave : AssemblyBuilderAccess.Run);
#else
                    assemblyBuilder = domain.DefineDynamicAssembly(assemblyName, AssemblyBuilderAccess.Run);
#endif
                    ModuleBuilder moduleBuilder;
#if !SILVERLIGHT
                    if (FlagCreateFile) {
                        moduleBuilder = assemblyBuilder.DefineDynamicModule(dynamicModuleName, dynamicModuleName + ".dll");
                    }
                    else {
                        moduleBuilder = assemblyBuilder.DefineDynamicModule(dynamicModuleName);
                    }
#else
                    moduleBuilder = assemblyBuilder.DefineDynamicModule(dynamicModuleName);
#endif
                    TypeBuilder typeBuilder = moduleBuilder.DefineType(dynamicProxyTypeName, TypeAttributes.Public, typeof(DynamicProxy), interfaces);

                    //build .ctor
                    ConstructorBuilder ctorBuilder = typeBuilder.DefineConstructor(MethodAttributes.Public | MethodAttributes.HideBySig, CallingConventions.Standard, Types_InvocationHandler);
                    ILGenerator gen = ctorBuilder.GetILGenerator();
                    gen.Emit(OpCodes.Ldarg_0);
                    gen.Emit(OpCodes.Ldarg_1);
                    gen.Emit(OpCodes.Call, DynamicProxy_Ctor);
                    gen.Emit(OpCodes.Ret);

                    MakeMethods(typeBuilder, typeof(Object), true);

                    foreach (Type interfac in interfaces) {
                        MakeMethods(typeBuilder, interfac, false);
                    }

                    proxy = typeBuilder.CreateType();

                    proxyCache.Add(proxyKey, proxy);

#if !SILVERLIGHT
                    if (FlagCreateFile) {
                        assemblyBuilder.Save(dynamicAssemblyName + ".dll");
                    }
#endif
                }

                return proxy;
            }
        }

        private static Type[] SumUpInterfaces(Type[] interfaces) {
            ArrayList flattenedInterfaces = new ArrayList();
            SumUpInterfaces(flattenedInterfaces, interfaces);
            return (Type[])flattenedInterfaces.ToArray(typeof(Type));
        }

        private static void SumUpInterfaces(ArrayList types, Type[] interfaces) {
            foreach (Type interfac in interfaces) {
                if (!interfac.IsInterface) {
                    throw new ArgumentException();
                }
                if (!types.Contains(interfac)) {
                    types.Add(interfac);
                }
                Type[] baseInterfaces = interfac.GetInterfaces();
                if (baseInterfaces.Length > 0) {
                    SumUpInterfaces(types, baseInterfaces);
                }
            }
        }

        private static Type[] ToTypes(ParameterInfo[] parameterInfos) {
            Type[] types = new Type[parameterInfos.Length];
            for (Int32 i = 0; i < parameterInfos.Length; i++) {
                types[i] = parameterInfos[i].ParameterType;
            }
            return types;
        }

        private static void MakeMethods(TypeBuilder typeBuilder, Type type, Boolean createPublic) {
            Hashtable methodToMB = new Hashtable();

            foreach (MethodInfo method in type.GetMethods(BindingFlags.Instance | BindingFlags.Public)) {
                MethodBuilder mdb = MakeMethod(typeBuilder, method, createPublic);
                methodToMB.Add(method, mdb);
            }

            foreach (PropertyInfo property in type.GetProperties(BindingFlags.Instance | BindingFlags.Public)) {
                PropertyBuilder pb = typeBuilder.DefineProperty(property.Name, property.Attributes, property.PropertyType, ToTypes(property.GetIndexParameters()));
                MethodInfo getMethod = property.GetGetMethod();
                if (getMethod != null && methodToMB.ContainsKey(getMethod)) {
                    pb.SetGetMethod((MethodBuilder)methodToMB[getMethod]);
                }
                MethodInfo setMethod = property.GetSetMethod();
                if (setMethod != null && methodToMB.ContainsKey(setMethod)) {
                    pb.SetSetMethod((MethodBuilder)methodToMB[setMethod]);
                }
            }
        }

        private static MethodBuilder MakeMethod(TypeBuilder typeBuilder, MethodInfo method, Boolean createPublic) {
            Int32 methodNum = DynamicProxy.Register(method);

            Type[] paramTypes = ToTypes(method.GetParameters());
            Int32 paramNum = paramTypes.Length;
            Boolean[] paramsByRef = new Boolean[paramNum];

            MethodBuilder b;
            String name;
            MethodAttributes methodAttr;
            if (createPublic) {
                name = method.Name;
                methodAttr = MethodAttributes.Public | MethodAttributes.Virtual | MethodAttributes.HideBySig;
            }
            else {
                name = method.DeclaringType.FullName + "." + method.Name;
                methodAttr = MethodAttributes.Private | MethodAttributes.Virtual | MethodAttributes.HideBySig | MethodAttributes.NewSlot | MethodAttributes.Final;
            }
            b = typeBuilder.DefineMethod(name, methodAttr, method.CallingConvention, method.ReturnType, paramTypes);

            ILGenerator gen = b.GetILGenerator();
            LocalBuilder parameters = gen.DeclareLocal(typeof(Object[]));
            LocalBuilder result = gen.DeclareLocal(typeof(Object));
            LocalBuilder retval = null;
            if (!method.ReturnType.Equals(typeof(void))) {
                retval = gen.DeclareLocal(method.ReturnType);
            }
            gen.Emit(OpCodes.Ldarg_0);
            gen.Emit(OpCodes.Ldfld, FieldInfo_handler); //this.handler
            gen.Emit(OpCodes.Ldarg_0);

            gen.Emit(OpCodes.Ldc_I4, methodNum);
            gen.Emit(OpCodes.Call, MethodInfo_GetMethod);

            gen.Emit(OpCodes.Ldc_I4, paramNum);
            gen.Emit(OpCodes.Newarr, typeof(Object)); // new Object[]
            if (paramNum > 0) {
                gen.Emit(OpCodes.Stloc, parameters);

                for (Int32 i = 0; i < paramNum; i++) {
                    gen.Emit(OpCodes.Ldloc, parameters);
                    gen.Emit(OpCodes.Ldc_I4, i);
                    gen.Emit(OpCodes.Ldarg, i + 1);
                    if (paramTypes[i].IsByRef) {
                        paramTypes[i] = paramTypes[i].GetElementType();
                        if (paramTypes[i] == typeofInt8 || paramTypes[i] == typeofBoolean) {
                            gen.Emit(OpCodes.Ldind_I1);
                        }
                        else if (paramTypes[i] == typeofUInt8) {
                            gen.Emit(OpCodes.Ldind_U1);
                        }
                        else if (paramTypes[i] == typeofInt16) {
                            gen.Emit(OpCodes.Ldind_I2);
                        }
                        else if (paramTypes[i] == typeofUInt16 || paramTypes[i] == typeofChar) {
                            gen.Emit(OpCodes.Ldind_U2);
                        }
                        else if (paramTypes[i] == typeofInt32) {
                            gen.Emit(OpCodes.Ldind_I4);
                        }
                        else if (paramTypes[i] == typeofUInt32) {
                            gen.Emit(OpCodes.Ldind_U4);
                        }
                        else if (paramTypes[i] == typeofInt64 || paramTypes[i] == typeofUInt64) {
                            gen.Emit(OpCodes.Ldind_I8);
                        }
                        else if (paramTypes[i] == typeofSingle) {
                            gen.Emit(OpCodes.Ldind_R4);
                        }
                        else if (paramTypes[i] == typeofDouble) {
                            gen.Emit(OpCodes.Ldind_R8);
                        }
                        else if (paramTypes[i].IsValueType) {
                            gen.Emit(OpCodes.Ldobj, paramTypes[i]);
                        }
                        else {
                            gen.Emit(OpCodes.Ldind_Ref);
                        }
                        paramsByRef[i] = true;
                    }
                    else {
                        paramsByRef[i] = false;
                    }
                    if (paramTypes[i].IsValueType) {
                        gen.Emit(OpCodes.Box, paramTypes[i]);
                    }
                    gen.Emit(OpCodes.Stelem_Ref);
                }

                gen.Emit(OpCodes.Ldloc, parameters);
            }

            // base.Invoke(this, method, parameters);
            gen.Emit(OpCodes.Callvirt, DynamicProxy_Invoke);
            gen.Emit(OpCodes.Stloc, result);

            for (Int32 i = 0; i < paramNum; i++) {
                if (paramsByRef[i]) {
                    gen.Emit(OpCodes.Ldarg, i + 1);
                    gen.Emit(OpCodes.Ldloc, parameters);
                    gen.Emit(OpCodes.Ldc_I4, i);
                    gen.Emit(OpCodes.Ldelem_Ref);
                    if (paramTypes[i].IsValueType) {
#if NET1
                        gen.Emit(OpCodes.Unbox, paramTypes[i]);
                        gen.Emit(OpCodes.Ldobj, paramTypes[i]);
#else
                        gen.Emit(OpCodes.Unbox_Any, paramTypes[i]);
#endif
                    }
                    else {
                        gen.Emit(OpCodes.Castclass, paramTypes[i]);
                    }
                    if (paramTypes[i] == typeofInt8 || paramTypes[i] == typeofUInt8 || paramTypes[i] == typeofBoolean) {
                        gen.Emit(OpCodes.Stind_I1);
                    }
                    else if (paramTypes[i] == typeofInt16 || paramTypes[i] == typeofUInt16 || paramTypes[i] == typeofChar) {
                        gen.Emit(OpCodes.Stind_I2);
                    }
                    else if (paramTypes[i] == typeofInt32 || paramTypes[i] == typeofUInt32) {
                        gen.Emit(OpCodes.Stind_I4);
                    }
                    else if (paramTypes[i] == typeofInt64 || paramTypes[i] == typeofUInt64) {
                        gen.Emit(OpCodes.Stind_I8);
                    }
                    else if (paramTypes[i] == typeofSingle) {
                        gen.Emit(OpCodes.Stind_R4);
                    }
                    else if (paramTypes[i] == typeofDouble) {
                        gen.Emit(OpCodes.Stind_R8);
                    }
                    else if (paramTypes[i].IsValueType) {
                        gen.Emit(OpCodes.Stobj, paramTypes[i]);
                    }
                    else {
                        gen.Emit(OpCodes.Stind_Ref);
                    }
                }
            }

            if (!method.ReturnType.Equals(typeof(void))) {
                gen.Emit(OpCodes.Ldloc, result);
                if (method.ReturnType.IsValueType) {
#if NET1
                    gen.Emit(OpCodes.Unbox, method.ReturnType);
                    gen.Emit(OpCodes.Ldobj, method.ReturnType);
#else
                    gen.Emit(OpCodes.Unbox_Any, method.ReturnType);
#endif
                }
                else {
                    gen.Emit(OpCodes.Castclass, method.ReturnType);
                }
                gen.Emit(OpCodes.Stloc_S, retval);
                gen.Emit(OpCodes.Ldloc_S, retval);
            }
            gen.Emit(OpCodes.Ret);

            if (!createPublic) {
                typeBuilder.DefineMethodOverride(b, method);
            }

            return b;
        }

        private static Int32 Register(MethodInfo method) {
            lock (methodsTable.SyncRoot) {
                Int32 index = methodsTable.IndexOf(method);
                if (index < 0) {
                    index = methodsTable.Add(method);
                }
                return index;
            }
        }

        protected static MethodInfo GetMethod(Int32 index) {
            return (MethodInfo)methodsTable[index];
        }

        private struct ProxyKey {
            private AppDomain domain;
            private Type[] interfaces;

            public ProxyKey(AppDomain domain, Type[] interfaces) {
                this.domain = domain;
                this.interfaces = interfaces;
            }

            public static Boolean operator ==(ProxyKey p1, ProxyKey p2) {
                if (!p1.domain.Equals(p2.domain))
                    return false;
                if (p1.interfaces.Length != p2.interfaces.Length)
                    return false;
                for (Int32 i = 0; i < p1.interfaces.Length; i++)
                    if (!p1.interfaces[i].Equals(p2.interfaces[i]))
                        return false;
                return true;
            }

            public static Boolean operator !=(ProxyKey p1, ProxyKey p2) {
                return !(p1 == p2);
            }

            public override Boolean Equals(Object obj) {
                if (!(obj is ProxyKey))
                    return false;

                return this == (ProxyKey)obj;
            }

            public override Int32 GetHashCode() {
                Int32 hash = domain.GetHashCode();
                foreach (Type type in interfaces)
                    hash = hash * 31 + type.GetHashCode();
                return hash;
            }
        }
    }

    public interface IInvocationHandler {
        Object Invoke(Object proxy, MethodInfo method, Object[] args);
    }
}
#endif
