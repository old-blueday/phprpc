/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Server.cs                                         |
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

/* PHPRPC Server library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Mar 10, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */

#if !(PocketPC || Smartphone || WindowsCE || ClientOnly)
namespace org.phprpc {
    using System;
    using System.IO;
    using System.Collections;
    using System.Reflection;
    using System.Text;
    using System.Text.RegularExpressions;
    using System.Web;
    using System.Web.SessionState;
    using org.phprpc.util;
    using System.Globalization;
    using System.Collections.Specialized;

    public class PHPRPC_Server {
        private class RemoteFunction {
            public Object obj;
            public MethodInfo[] functions;
            public RemoteFunction(Object obj, MethodInfo[] functions) {
                this.obj = obj;
                this.functions = functions;
            }
        }

        private HttpRequest request = HttpContext.Current.Request;
        private HttpResponse response = HttpContext.Current.Response;
        private HttpSessionState session = HttpContext.Current.Session;
        private HttpServerUtility server = HttpContext.Current.Server;
        private Hashtable functions = new Hashtable();
        private PHPFormatter formatter = null;
        private Boolean debug = false;
        private Encoding encoding = new UTF8Encoding();
        private Boolean encode = true;
        private Boolean byref = false;
        private Boolean encrypt = false;
        private Byte encryptMode = 0;
        private Byte[] key = null;
        private UInt32 keylen = 128;
        private BigInteger y = null;
        private String output = String.Empty;
        private String callback = String.Empty;
        private Int32 errno = 0;
        private String errstr = String.Empty;
        private String cid = String.Empty;
        private StringBuilder buffer = new StringBuilder();
        private static Regex test = new Regex(@"[\0-\037\042\047\134\177]", RegexOptions.Compiled);
        private static Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
        private static Hashtable globalFunctions = new Hashtable();

        public PHPRPC_Server() {
            formatter = new PHPFormatter(encoding, assemblies);
        }

        public static Boolean AddGlobal(Object obj) {
            Type type = obj.GetType();
            return AddGlobal(GetAllFunctions(type, BindingFlags.Instance), obj, type, null);
        }

        public static Boolean AddGlobal(Type type) {
            return AddGlobal(GetAllFunctions(type, BindingFlags.Static), null, type, null);
        }

        public static Boolean AddGlobal(Object obj, Type type) {
            return AddGlobal(GetAllFunctions(type, BindingFlags.Instance), obj, type, null);
        }

        public static Boolean AddGlobal(String function, Object obj) {
            return AddGlobal(new String[] { function }, obj, obj.GetType(), null);
        }

        public static Boolean AddGlobal(String function, Object obj, String alias) {
            return AddGlobal(new String[] { function }, obj, obj.GetType(), new String[] { alias });
        }

        public static Boolean AddGlobal(String[] functions, Object obj) {
            return AddGlobal(functions, obj, obj.GetType(), null);
        }

        public static Boolean AddGlobal(String[] functions, Object obj, String[] aliases) {
            return AddGlobal(functions, obj, obj.GetType(), aliases);
        }

        public static Boolean AddGlobal(String function, Type type) {
            return AddGlobal(new String[] { function }, null, type, null);
        }

        public static Boolean AddGlobal(String function, Type type, String alias) {
            return AddGlobal(new String[] { function }, null, type, new String[] { alias });
        }

        public static Boolean AddGlobal(String[] functions, Type type) {
            return AddGlobal(functions, null, type, null);
        }

        public static Boolean AddGlobal(String[] functions, Type type, String[] aliases) {
            return AddGlobal(functions, null, type, aliases);
        }

        public static Boolean AddGlobal(String function, Object obj, Type type, String alias) {
            return AddGlobal(new String[] { function }, obj, type, new String[] { alias });
        }

        public static Boolean AddGlobal(String[] funcnames, Object obj, Type type, String[] aliases) {
            return Add(funcnames, obj, type, aliases, globalFunctions);
        }

        public Boolean Add(Object obj) {
            Type type = obj.GetType();
            return Add(GetAllFunctions(type, BindingFlags.Instance), obj, type, null);
        }

        public Boolean Add(Type type) {
            return Add(GetAllFunctions(type, BindingFlags.Static), null, type, null);
        }

        public Boolean Add(Object obj, Type type) {
            return Add(GetAllFunctions(type, BindingFlags.Instance), obj, type, null);
        }

        public Boolean Add(String function, Object obj) {
            return Add(new String[] { function }, obj, obj.GetType(), null);
        }

        public Boolean Add(String function, Object obj, String alias) {
            return Add(new String[] { function }, obj, obj.GetType(), new String[] { alias });
        }

        public Boolean Add(String[] functions, Object obj) {
            return Add(functions, obj, obj.GetType(), null);
        }

        public Boolean Add(String[] functions, Object obj, String[] aliases) {
            return Add(functions, obj, obj.GetType(), aliases);
        }

        public Boolean Add(String function, Type type) {
            return Add(new String[] { function }, null, type, null);
        }

        public Boolean Add(String function, Type type, String alias) {
            return Add(new String[] { function }, null, type, new String[] { alias });
        }

        public Boolean Add(String[] functions, Type type) {
            return Add(functions, null, type, null);
        }

        public Boolean Add(String[] functions, Type type, String[] aliases) {
            return Add(functions, null, type, aliases);
        }

        public Boolean Add(String function, Object obj, Type type, String alias) {
            return Add(new String[] { function }, obj, type, new String[] { alias });
        }

        public Boolean Add(String[] funcnames, Object obj, Type type, String[] aliases) {
            return Add(funcnames, obj, type, aliases, functions);
        }

        public void Start() {
            buffer = new StringBuilder();
            try {
                InitErrorHandler();
                InitClientID();
                InitEncode();
                InitCallback();
                InitRef();
                InitEncrypt();
                if (request.Params["phprpc_func"] != null) {
                    CallFunction();
                }
                else if (encrypt != false || y != null) {
                    KeyExchange();
                }
                else {
                    SendFunctions();
                }
            }
            catch (Exception e) {
                errno = 1;
                if (debug) {
                    errstr = e.ToString();
                }
                else {
                    errstr = e.Message;
                }
                SendError();
            }
        }

        public String Charset {
            get {
                return encoding.WebName;
            }
            set {
                encoding = Encoding.GetEncoding(value);
                formatter.Encoding = encoding;
            }
        }

        public Boolean DebugMode {
            get {
                return debug;
            }
            set {
                debug = value;
            }
        }

        private static String[] GetAllFunctions(Type type, BindingFlags bindingFlags) {
            MethodInfo[] methods = type.GetMethods(BindingFlags.Public | BindingFlags.DeclaredOnly | bindingFlags);
            ArrayList names = new ArrayList();
            for (Int32 i = 0, n = methods.Length; i < n; i++) {
                String fn = methods[i].Name.ToLower(CultureInfo.InvariantCulture);
                if (!names.Contains(fn)) {
                    names.Add(fn);
                }
            }
            return (String[])names.ToArray(typeof(String));
        }

        private static Boolean Add(String[] funcnames, Object obj, Type type, String[] aliases, Hashtable functions) {
            if (funcnames == null) {
                return false;
            }
            if (aliases == null) {
                aliases = funcnames;
            }
            if (funcnames.Length != aliases.Length) {
                return false;
            }
            BindingFlags bindingflags = BindingFlags.Public;
            if (obj == null) {
                bindingflags |= BindingFlags.Static;
            }
            else {
                bindingflags |= BindingFlags.Instance;
            }
            MethodInfo[] methods = type.GetMethods(bindingflags);
            for (Int32 i = 0, n = funcnames.Length; i < n; i++) {
                ArrayList fs = new ArrayList();
                for (Int32 j = 0, m = methods.Length; j < m; j++) {
                    MethodInfo method = methods[j];
                    if (funcnames[i].ToLower(CultureInfo.InvariantCulture).Equals(method.Name.ToLower(CultureInfo.InvariantCulture))) {
                        fs.Add(method);
                    }
                }
                functions[aliases[i].ToLower(CultureInfo.InvariantCulture)] = new RemoteFunction(obj, (MethodInfo[])fs.ToArray(typeof(MethodInfo)));
            }
            return true;
        }

        private String JsReplace(Match m) {
            return String.Format("\\x{0:x2}", (Int32)m.Value[0]);
        }

        private String AddJsSlashes(String str) {
            return test.Replace(str, new MatchEvaluator(JsReplace));
        }

        private String AddJsSlashes(Byte[] data) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0, n = data.Length; i < n; i++) {
                if (data[i] <= 31 || data[i] == 34 || data[i] == 39 || data[i] == 92 || data[i] >= 127) {
                    sb.Append(String.Format("\\x{0:x2}", data[i]));
                }
                else {
                    sb.Append((Char)data[i]);
                }
            }
            return sb.ToString();
        }

        private String EncodeString(String str) {
            if (encode) {
                return Convert.ToBase64String(encoding.GetBytes(str));
            }
            else {
                return AddJsSlashes(str);
            }
        }

        private String EncodeString(Byte[] data) {
            if (encode) {
                return Convert.ToBase64String(data);
            }
            else {
                return AddJsSlashes(data);
            }
        }

        private Byte[] Base64Decode(String data) {
            if (data == null) {
                return null;
            }
            if (data == String.Empty) {
                return new Byte[0];
            }
            return Convert.FromBase64String(data);
        }

        private Byte[] EncryptString(Byte[] data, Byte level) {
            if (encryptMode >= level) {
                data = XXTEA.Encrypt(data, key);
            }
            return data;
        }

        private Byte[] DecryptString(Byte[] data, Byte level) {
            if (encryptMode >= level) {
                data = XXTEA.Decrypt(data, key);
            }
            return data;
        }

        private Byte[] Serialize(Object obj) {
            MemoryStream ms = new MemoryStream();
            formatter.Serialize(ms, obj);
            Byte[] result = ms.ToArray();
            ms.Close();
            return result;
        }

        private Object Deserialize(Byte[] data) {
            MemoryStream ms = new MemoryStream(data);
            ms.Position = 0;
            Object result = formatter.Deserialize(ms);
            ms.Close();
            return result;
        }

        private void SendURL() {
            if (session.IsNewSession) {
                StringBuilder url = new StringBuilder(request.Url.ToString());
                String[] keys = request.QueryString.AllKeys;
                if (keys.Length > 0) {
                    url.Append('?');
                    foreach (String key in keys) {
                        if (!key.ToLower().StartsWith("phprpc_")) {
                            String[] values = request.QueryString.GetValues(key);
                            for (Int32 i = 0, n = values.Length; i < n; i++) {
                                url.Append(key).Append('=').Append(server.UrlEncode(values[i])).Append('&');
                            }
                        }
                    }
                    url.Length--;
                }
                buffer.Append("phprpc_url=\"");
                buffer.Append(EncodeString(response.ApplyAppPathModifier(url.ToString())));
                buffer.Append("\";\r\n");
            }
        }

        private void SendCallback() {
            buffer.Append(callback);
            Byte[] data = encoding.GetBytes(buffer.ToString());
            SendHeader();
            response.AppendHeader("Content-Length", data.Length.ToString());
            response.Clear();
            if (data.Length > 0) {
                response.BinaryWrite(data);
            }
        }

        private void SendFunctions() {
            buffer.Append("phprpc_functions=\"");
            foreach (DictionaryEntry de in globalFunctions) {
                functions.Add(de.Key, de.Value);
            }
            buffer.Append(EncodeString(Serialize(functions.Keys)));
            buffer.Append("\";\r\n");
            SendCallback();
        }

        private void SendOutput() {
            if (encryptMode >= 3) {
                buffer.Append("phprpc_output=\"");
                buffer.Append(EncodeString(XXTEA.Encrypt(encoding.GetBytes(output), key)));
                buffer.Append("\";\r\n");
            }
            else {
                buffer.Append("phprpc_output=\"");
                buffer.Append(EncodeString(output));
                buffer.Append("\";\r\n");
            }
        }

        private void SendError() {
            buffer.Append("phprpc_errno=\"");
            buffer.Append(errno);
            buffer.Append("\";\r\n");
            buffer.Append("phprpc_errstr=\"");
            buffer.Append(EncodeString(errstr));
            buffer.Append("\";\r\n");
            SendOutput();
            SendCallback();
        }

        private void SendHeader() {
            response.ContentType = "text/plain; charset=" + Charset;
            response.AppendHeader("P3P", "CP=\"CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV\"");
            response.AppendHeader("X-Powered-By", "PHPRPC Server/3.0");
            response.Cache.SetExpires(DateTime.Now);
            response.Cache.SetNoStore();
            response.Cache.AppendCacheExtension("no-cache");
            response.Cache.AppendCacheExtension("must-revalidate");
            response.Cache.SetMaxAge(new TimeSpan(0));
        }

        private Byte[] Call(MethodInfo function, Object obj, ArrayList arguments) {
            ParameterInfo[] p = function.GetParameters();
            String funcname = function.Name;
            MemoryStream ms = new MemoryStream();
            StreamWriter sw = new StreamWriter(ms, encoding);
            Int32 size = arguments.Count;
            if (p.Length != size) {
                if (p.Length == size + 1) {
                    Type type = p[p.Length - 1].ParameterType;
                    if (type == typeof(TextWriter) || type == typeof(StreamWriter)) {
                        arguments.Add(sw);
                    }
                    else {
                        throw new ArgumentException("number of arguments mismatch for " + funcname + "().");
                    }
                }
                else {
                    throw new ArgumentException("number of arguments mismatch for " + funcname + "().");
                }
            }
            Object[] args = arguments.ToArray();
            if (size < arguments.Count) {
                arguments.RemoveAt(size);
            }
            for (Int32 i = 0, n = args.Length; i < n; i++) {
                if (args[i] != null) {
                    args[i] = PHPConvert.ChangeType(args[i], p[i].ParameterType, encoding);
                }
            }
            Byte[] result = Serialize(function.Invoke(obj, args));
            sw.Close();
            output = encoding.GetString(ms.ToArray());
            ms.Close();
            for (Int32 i = 0; i < size; i++) {
                arguments[i] = args[i];
            }
            return result;
        }

        private Boolean GetBooleanRequest(String name) {
            Boolean var = true;
            if (request.Params[name] != null &&
                request.Params[name].ToLower(CultureInfo.InvariantCulture).Equals("false")) {
                var = false;
            }
            return var;
        }

        private void InitEncode() {
            encode = GetBooleanRequest("phprpc_encode");
        }

        private void InitRef() {
            byref = GetBooleanRequest("phprpc_ref");
        }

        private void InitErrorHandler() {
            errno = 0;
            errstr = String.Empty;
            output = String.Empty;
        }

        private void InitCallback() {
            if (request.Params["phprpc_callback"] != null) {
                callback = encoding.GetString(Base64Decode(request.Params["phprpc_callback"]));
            }
            else {
                callback = String.Empty;
            }
        }

        private void InitClientID() {
            cid = "0";
            if (request.Params["phprpc_id"] != null) {
                cid = request.Params["phprpc_id"];
            }
            cid = "phprpc_" + cid;
        }

        private void InitKeylen() {
            if (request.Params["phprpc_keylen"] != null) {
                keylen = UInt32.Parse(request.Params["phprpc_keylen"]);
            }
            else {
                Hashtable sessionObject = (Hashtable)session.Contents[cid];
                keylen = 128;
                if (sessionObject != null) {
                    lock (sessionObject.SyncRoot) {
                        if (sessionObject["keylen"] != null) {
                            keylen = (UInt32)sessionObject["keylen"];
                        }
                    }
                }
            }
        }

        private void InitEncrypt() {
            encrypt = false;
            encryptMode = 0;
            y = null;
            if (request.Params["phprpc_encrypt"] != null) {
                String enc = request.Params["phprpc_encrypt"].ToLower(CultureInfo.InvariantCulture);
                switch (enc) {
                case "true":
                    encrypt = true;
                    break;
                case "false":
                    encrypt = false;
                    break;
                case "0":
                    encryptMode = 0;
                    break;
                case "1":
                    encryptMode = 1;
                    break;
                case "2":
                    encryptMode = 2;
                    break;
                case "3":
                    encryptMode = 3;
                    break;
                default:
                    y = BigInteger.Parse(enc);
                    break;
                }
            }
        }

        private void InitKey() {
            Hashtable sessionObject = null;
            if (session != null) {
                sessionObject = (Hashtable)session.Contents[cid];
            }
            if (sessionObject != null) {
                lock (sessionObject.SyncRoot) {
                    key = (Byte[])sessionObject["key"];
                }
            }
            if (key == null && encryptMode > 0) {
                encryptMode = 0;
                throw new Exception("Can't find the key for decryption.");
            }
        }

        private ArrayList GetArguments() {
            ArrayList arguments;
            if (request.Params["phprpc_args"] != null) {
                arguments = ((AssocArray)Deserialize(DecryptString(Base64Decode(request.Params["phprpc_args"]), 1))).toArrayList();
            }
            else {
                arguments = new ArrayList();
            }
            return arguments;
        }

        private void CallFunction() {
            String funcname = request.Params["phprpc_func"].ToLower(CultureInfo.InvariantCulture);
            RemoteFunction rf = null;
            if (functions.ContainsKey(funcname)) {
                rf = (RemoteFunction)functions[funcname];
            }
            else if (globalFunctions.ContainsKey(funcname)) {
                rf = (RemoteFunction)globalFunctions[funcname];
            }
            else {
                throw new Exception("Can't find this function " + request.Params["phprpc_func"] + "().");
            }

            InitKey();
            ArrayList arguments = GetArguments();
            String result = null;
            for (Int32 i = 0, n = rf.functions.Length; i < n; i++) {
                try {
                    result = EncodeString(EncryptString(Call(rf.functions[i], rf.obj, arguments), 2));
                    break;
                }
                catch (Exception e) {
                    if (i == n - 1) {
                        errstr = String.Empty;
                        throw e;
                    }
                    else {
                        errno = 2;
                        if (debug) {
                            errstr += e.ToString() + "\r\n";
                        }
                        else {
                            errstr += e.Message + "\r\n";
                        }
                    }
                }
            }
            buffer.Append("phprpc_result=\"");
            buffer.Append(result);
            buffer.Append("\";\r\n");
            if (byref) {
                buffer.Append("phprpc_args=\"");
                buffer.Append(EncodeString(EncryptString(Serialize(arguments), 1)));
                buffer.Append("\";\r\n");
            }
            SendError();
        }

        private void KeyExchange() {
            if (session == null) {
                throw new Exception("Session seems not start, Please start Session first.");
            }
            Hashtable sessionObject;
            InitKeylen();
            if (encrypt) {
                DHParams dhParams = new DHParams(keylen);
                keylen = dhParams.GetL();
                BigInteger p = dhParams.GetP();
                BigInteger g = dhParams.GetG();
                BigInteger x = dhParams.GetX();
                BigInteger y = g.ModPow(x, p);
                sessionObject = new Hashtable();
                sessionObject["x"] = x;
                sessionObject["p"] = p;
                sessionObject["keylen"] = keylen;
                session.Contents[cid] = sessionObject;
                Hashtable dhp = dhParams.GetDHParams();
                dhp["y"] = y.ToString();
                buffer.Append("phprpc_encrypt=\"");
                buffer.Append(EncodeString(Serialize(dhp)));
                buffer.Append("\";\r\n");
                if (keylen != 128) {
                    buffer.Append("phprpc_keylen=\"");
                    buffer.Append(keylen);
                    buffer.Append("\";\r\n");
                }
                SendURL();
            }
            else {
                sessionObject = (Hashtable)session.Contents[cid];
                lock (sessionObject.SyncRoot) {
                    BigInteger x = (BigInteger)sessionObject["x"];
                    BigInteger p = (BigInteger)sessionObject["p"];
                    if (keylen == 128) {
                        key = new byte[16];
                        Byte[] k = y.ModPow(x, p).GetBytes();
                        for (Int32 i = 1, n = Math.Min(k.Length, 16); i <= n; i++) {
                            this.key[16 - i] = k[n - i];
                        }

                    }
                    else {
                        key = MD5.Hash(Encoding.ASCII.GetBytes(y.ModPow(x, p).ToString()));
                    }
                    sessionObject["key"] = key;
                    sessionObject.Remove("x");
                    sessionObject.Remove("p");
                    session.Contents[cid] = sessionObject;
                }
            }
            SendCallback();
        }
    }
}
#endif