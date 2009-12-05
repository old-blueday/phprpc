/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_InvocationHandler.cs                              |
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

/* PHPRPC Invocation Handler.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Feb 18, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */
#if !(PocketPC || Smartphone || WindowsCE)
namespace org.phprpc {
    using System;
    using System.Reflection;
    using org.phprpc.util;

    internal class PHPRPC_InvocationHandler : IInvocationHandler {
        private PHPRPC_Client client;
        public PHPRPC_InvocationHandler(PHPRPC_Client client) {
            this.client = client;
        }
        private static Type[] ToTypes(ParameterInfo[] parameterInfos) {
            Type[] types = new Type[parameterInfos.Length];
            for (Int32 i = 0; i < parameterInfos.Length; i++) {
                types[i] = parameterInfos[i].ParameterType;
            }
            return types;
        }
        public Object Invoke(Object proxy, MethodInfo method, Object[] args) {
            Type[] paramTypes = ToTypes(method.GetParameters());
            Int32 n = paramTypes.Length;
            Boolean byRef = false;
            for (Int32 i = 0; i < n; i++) {
                if (paramTypes[i].IsByRef) {
                    byRef = true;
                    break;
                }
            }
#if !NET1
            if ((n > 0) && ((paramTypes[n - 1] == typeof(PHPRPC_Callback)) || ((paramTypes[n - 1].IsGenericType) && (paramTypes[n - 1].GetGenericTypeDefinition() == typeof(PHPRPC_Callback<>))))) {
                Object[] tmpargs = new Object[n - 1];
                Array.Copy(args, tmpargs, n - 1);
                client.Invoke(method.Name, tmpargs, (Delegate)args[n - 1], byRef, client.EncryptMode);
                return null;
            }
            else if ((n > 1) && ((paramTypes[n - 2] == typeof(PHPRPC_Callback)) || ((paramTypes[n - 2].IsGenericType) && (paramTypes[n - 2].GetGenericTypeDefinition() == typeof(PHPRPC_Callback<>)))) && (paramTypes[n - 1] == typeof(Byte))) {
                Object[] tmpargs = new Object[n - 2];
                Array.Copy(args, tmpargs, n - 2);
                client.Invoke(method.Name, tmpargs, (Delegate)args[n - 2], byRef, (Byte)args[n - 1]);
                return null;
            }
#endif
#if SILVERLIGHT
            throw new PHPRPC_Error(1, "SilverLight do not support synchronous invoke.");
#else
            Object result = client.Invoke(method.Name, args, byRef);
            if (result is PHPRPC_Error) {
                throw (PHPRPC_Error)result;
            }
            if (byRef) {
                for (Int32 i = 0; i < n; i++) {
                    if (paramTypes[i].IsByRef) {
                        args[i] = PHPConvert.ChangeType(args[i], paramTypes[i].GetElementType(), client.Charset);
                    }
                }
            }
            return PHPConvert.ChangeType(result, method.ReturnType, client.Charset);
#endif
        }
    }
}
#endif