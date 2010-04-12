/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Client.cs                                         |
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

/* PHPRPC Client library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

namespace org.phprpc {
    using System;
    using System.Collections;
    using System.IO;
    using System.Net;
    using System.Reflection;
    using System.Text;
    using System.Text.RegularExpressions;
    using System.Threading;
    using org.phprpc.util;
#if !(PocketPC || Smartphone || WindowsCE || NET1)
    using System.Collections.Generic;

    internal class RequestState {
        public String function;
        public Object[] args;
        public Boolean byRef;
        public Byte encryptMode;
        public Byte[] bufferWrite;
        public HttpWebRequest request;
        public HttpWebResponse response;
        public SynchronizationContext context;
        public SendOrPostCallback asyncCallback;
        public Delegate syncCallback;
        public RequestState() {
            this.function = null;
            this.args = null;
            this.byRef = false;
            this.encryptMode = 0;
            this.bufferWrite = null;
            this.request = null;
            this.response = null;
            this.context = null;
            this.asyncCallback = null;
            this.syncCallback = null;
        }
    }
#endif

    public class PHPRPC_Client {
        private Int32 timeout = 30000;
        private Byte[] key = null;
        private Uri url = null;
        private UInt32 keylen = 128;
        private Byte encryptMode = 0;
        private Encoding encoding = new UTF8Encoding();
        private Boolean keyExchanged = false;
        private Boolean keyExchanging = false;
        private String output = String.Empty;
        private PHPRPC_Error warning = null;
#if !SILVERLIGHT
        private IWebProxy proxy = null;
        private ICredentials credentials = null;
        private static Hashtable cookies = new Hashtable();
        private static String cookie = null;
#endif
        private static Int32 sid = 0;
        private String clientID = "";
        private Double serverVersion = 0;

#if !(PocketPC || Smartphone || WindowsCE || NET1)
        private Queue<RequestState> requestQueue = new Queue<RequestState>();
#endif

#if (PocketPC || Smartphone || WindowsCE || SILVERLIGHT)
        private static Assembly[] assemblies = new Assembly[] { Assembly.GetCallingAssembly(), Assembly.GetExecutingAssembly() };
#else
        private static Assembly[] assemblies = AppDomain.CurrentDomain.GetAssemblies();
#endif
        private PHPFormatter formatter = null;

        public PHPRPC_Client() {
            formatter = new PHPFormatter(encoding, assemblies);
            clientID = "dotNET" + new Random().Next().ToString() + DateTime.Now.Ticks.ToString() + (sid++).ToString();
#if !SILVERLIGHT
            try {
#if (PocketPC || Smartphone || WindowsCE || NET1)
                proxy = GlobalProxySelection.GetEmptyWebProxy();
#else
                proxy = HttpWebRequest.DefaultWebProxy;
#endif
            }
            catch {
                proxy = null;
            }
#endif
        }

        public PHPRPC_Client(String serverURL)
            : this() {
            UseService(serverURL);
        }

        public UInt32 KeyLength {
            get {
                return keylen;
            }
            set {
                if (key == null) {
                    keylen = value;
                }
            }
        }

        public Byte EncryptMode {
            get {
                return encryptMode;
            }
            set {
                if ((value >= 0) && (value <= 3)) {
                    encryptMode = value;
                }
                else {
                    encryptMode = 0;
                }
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

        public Int32 Timeout {
            get {
                return timeout;
            }
            set {
                timeout = value;
            }
        }

        public String Output {
            get {
                return output;
            }
        }

        public PHPRPC_Error Warning {
            get {
                return warning;
            }
        }
#if !SILVERLIGHT
        public IWebProxy Proxy {
            get {
                return proxy;
            }
            set {
                proxy = value;
            }
        }

        public ICredentials Credentials {
            get {
                return credentials;
            }
            set {
                credentials = value;
            }
        }
#endif
        public Boolean UseService(String serverURL) {
            url = new Uri(serverURL);
            if (!url.Scheme.Equals("http") && !url.Scheme.Equals("https")) {
                url = null;
                return false;
            }
            key = null;
            keylen = 128;
            encryptMode = 0;
            keyExchanged = false;
            encoding = new UTF8Encoding();
            formatter.Encoding = encoding;
            if (url.Query == "") {
                url = new Uri(serverURL + "?phprpc_id=" + clientID);
            }
            else {
                url = new Uri(serverURL + "&phprpc_id=" + clientID);
            }
            return true;
        }

#if !(PocketPC || Smartphone || WindowsCE)
        public Object UseService(Type type) {
            PHPRPC_InvocationHandler handler = new PHPRPC_InvocationHandler(this);
            if (type.IsInterface) {
                return DynamicProxy.NewInstance(AppDomain.CurrentDomain, new Type[] { type }, handler);
            }
            else {
                return DynamicProxy.NewInstance(AppDomain.CurrentDomain, type.GetInterfaces(), handler);
            }
        }

        public Object UseService(Type[] interfaces) {
            PHPRPC_InvocationHandler handler = new PHPRPC_InvocationHandler(this);
            return DynamicProxy.NewInstance(AppDomain.CurrentDomain, interfaces, handler);
        }

        public Object UseService(String serverURL, Type type) {
            if (UseService(serverURL)) {
                return UseService(type);
            }
            else {
                return null;
            }
        }

        public Object UseService(String serverURL, Type[] interfaces) {
            if (UseService(serverURL)) {
                return UseService(interfaces);
            }
            else {
                return null;
            }
        }
#endif

#if !SILVERLIGHT
        public Object Invoke(String function, Object[] args) {
            return Invoke(function, args, false);
        }

        public Object Invoke(String function, Object[] args, Boolean byRef) {
            Hashtable data = Invoke(function, args, byRef, encryptMode);
            warning = (PHPRPC_Error)data["warning"];
            output = (String)data["output"];
            return data["result"];
        }

        public Hashtable Invoke(String function, Object[] args, Boolean byRef, Byte encryptMode) {
            Hashtable data = new Hashtable();
            data["warning"] = null;
            data["output"] = String.Empty;
            try {
                KeyExchange(ref encryptMode);
                StringBuilder requestBody = new StringBuilder();
                requestBody.Append("phprpc_func=").Append(function);
                if (args != null && args.Length > 0) {
                    requestBody.Append("&phprpc_args=");
                    requestBody.Append(Base64Encode(Encrypt(Serialize(args), 1, encryptMode)).Replace("+", "%2B"));
                }
                requestBody.Append("&phprpc_encrypt=").Append(encryptMode);
                if (!byRef) {
                    requestBody.Append("&phprpc_ref=false");
                }
                Hashtable result = POST(requestBody.ToString());
                Int32 errno = (Int32)result["phprpc_errno"];
                if (errno > 0) {
                    String errstr = (String)result["phprpc_errstr"];
                    data["warning"] = new PHPRPC_Error(errno, errstr);
                }
                if (result.ContainsKey("phprpc_output")) {
                    data["output"] = (String)result["phprpc_output"];
                }
                if (result.ContainsKey("phprpc_result")) {
                    if (result.ContainsKey("phprpc_args")) {
                        Object[] arguments = (Object[])PHPConvert.ToArray((AssocArray)Deserialize(Decrypt((Byte[])result["phprpc_args"], 1, encryptMode)), typeof(Object[]), encoding);
                        for (Int32 i = 0; i < Math.Min(args.Length, arguments.Length); i++) {
                            args[i] = arguments[i];
                        }
                    }
                    data["result"] = Deserialize(Decrypt((Byte[])result["phprpc_result"], 2, encryptMode));
                }
                else {
                    data["result"] = warning;
                }
            }
            catch (PHPRPC_Error e) {
                data["result"] = e;
            }
            catch (Exception e) {
                data["result"] = new PHPRPC_Error(1, e.ToString());
            }
            return data;
        }

        private void KeyExchange(ref Byte encryptMode) {
            while (keyExchanging) {
                Thread.Sleep(1);
            }
            if (key != null || encryptMode == 0) {
                return;
            }
            if ((key == null) && keyExchanged) {
                encryptMode = 0;
                return;
            }
            keyExchanging = true;
            Hashtable result = POST("phprpc_encrypt=true&phprpc_keylen=" + keylen);
            if (result.ContainsKey("phprpc_keylen")) {
                keylen = (UInt32)result["phprpc_keylen"];
            }
            else {
                keylen = 128;
            }
            if (result.ContainsKey("phprpc_encrypt")) {
                AssocArray encrypt = (AssocArray)Deserialize((Byte[])result["phprpc_encrypt"]);
                BigInteger x = BigInteger.GenerateRandom((Int32)keylen - 1);
                x.SetBit(keylen - 2);
                BigInteger y = BigInteger.Parse(PHPConvert.ToString(encrypt["y"]));
                BigInteger p = BigInteger.Parse(PHPConvert.ToString(encrypt["p"]));
                BigInteger g = BigInteger.Parse(PHPConvert.ToString(encrypt["g"]));
                if (keylen == 128) {
                    this.key = new byte[16];
                    Byte[] k = y.ModPow(x, p).GetBytes();
                    for (Int32 i = 1, n = Math.Min(k.Length, 16); i <= n; i++) {
                        this.key[16 - i] = k[n - i];
                    }
                }
                else {
                    key = MD5.Hash(encoding.GetBytes(y.ModPow(x, p).ToString()));
                }
                POST("phprpc_encrypt=" + g.ModPow(x, p).ToString());
            }
            else {
                key = null;
                keyExchanged = true;
                encryptMode = 0;
            }
            keyExchanging = false;
        }

        private Hashtable POST(String requestString) {
            HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
            request.Method = "POST";
            request.Accept = "*.*";
            request.AllowWriteStreamBuffering = true;
            request.SendChunked = false;
            request.KeepAlive = false;
#if (PocketPC || Smartphone || WindowsCE)
            request.UserAgent = "PHPRPC Client 3.0 for .NET Compact Framework";
#else
            request.UserAgent = "PHPRPC Client 3.0 for .NET Framework";
#endif
            request.ContentType = String.Concat("application/x-www-form-urlencoded; charset=", Charset);
            if (proxy != null) {
                request.Proxy = proxy;
            }
            if (cookie != null) {
                request.Headers["Cookie"] = cookie;
            }
            request.Credentials = credentials;
            request.Timeout = timeout;
            Byte[] buf = encoding.GetBytes(requestString);
            request.ContentLength = buf.Length;
            Stream rs = request.GetRequestStream();
            rs.Write(buf, 0, buf.Length);
            rs.Close();
            HttpWebResponse response = request.GetResponse() as HttpWebResponse;
            Boolean hasCookie = false;
            Double version = -1;
            for (Int32 i = 0; i < response.Headers.Count; ++i) {
                if (response.Headers.Keys[i].ToLower() == "x-powered-by") {
                    String xPoweredBy = response.Headers[i];
                    Int32 pos = xPoweredBy.IndexOf("PHPRPC Server/");
                    if (pos >= 0) {
                        version = Double.Parse(xPoweredBy.Substring(pos + 14));
                    }
                }
                if (response.Headers.Keys[i].ToLower() == "set-cookie") {
                    lock (cookies.SyncRoot) {
                        hasCookie = true;
                        Regex regex = new Regex("=");
                        foreach (String c in Regex.Split(response.Headers[i], @"[;,]\s?")) {
                            String name, value;
                            if (c.IndexOf('=') > -1) {
                                String[] pair = regex.Split(c, 2);
                                name = pair[0];
                                value = pair[1];
                            }
                            else {
                                name = c;
                                value = "";
                            }
                            if ((name != "domain") && (name != "expires") &&
                                (name != "path") && (name != "secure")) {
                                cookies[name] = value;
                            }
                        }
                    }
                }
            }
            if (version < 0) {
                response.Close();
                throw new PHPRPC_Error(1, "Illegal PHPRPC Server!");
            }
            else {
                serverVersion = version;
            }
            if (hasCookie) {
                lock (cookies.SyncRoot) {
                    String mcookie = "";
                    foreach (DictionaryEntry entry in cookies) {
                        mcookie += entry.Key.ToString() + "=" + entry.Value.ToString() + "; ";
                    }
                    cookie = mcookie;
                }
            }
            return GetResponseBody(response, encryptMode);
        }
#endif

#if !(PocketPC || Smartphone || WindowsCE || NET1)
        public void Invoke<T>(String function, Object[] args, PHPRPC_Callback<T> callback) {
            Invoke(function, args, callback, false);
        }
        public void Invoke<T>(String function, Object[] args, PHPRPC_Callback<T> callback, Boolean byRef) {
            Invoke(function, args, callback, byRef, encryptMode);
        }
        public void Invoke<T>(String function, Object[] args, PHPRPC_Callback<T> callback, Boolean byRef, Byte encryptMode) {
            Invoke(function, args, (Delegate)callback, byRef, encryptMode);
        }
        public void Invoke(String function, Object[] args, PHPRPC_Callback callback) {
            Invoke(function, args, callback, false);
        }
        public void Invoke(String function, Object[] args, PHPRPC_Callback callback, Boolean byRef) {
            Invoke(function, args, callback, byRef, encryptMode);
        }
        public void Invoke(String function, Object[] args, PHPRPC_Callback callback, Boolean byRef, Byte encryptMode) {
            Invoke(function, args, (Delegate)callback, byRef, encryptMode);
        }
        internal void Invoke(String function, Object[] args, Delegate callback, Boolean byRef, Byte encryptMode) {
            RequestState requestState = new RequestState();
            requestState.function = function;
            requestState.args = args;
            requestState.syncCallback = callback;
            requestState.byRef = byRef;
            requestState.encryptMode = encryptMode;
            requestQueue.Enqueue(requestState);
            BeginKeyExchange();
        }
        private void BeginKeyExchange() {
            if (keyExchanging) return;
            if ((key == null) && (encryptMode > 0)) {
                keyExchanging = true;
                RequestState requestState = new RequestState();
                requestState.bufferWrite = encoding.GetBytes("phprpc_encrypt=true&phprpc_keylen=" + keylen);
                requestState.asyncCallback = new SendOrPostCallback(NextKeyExchange);
                POST(requestState);
            }
            else {
                EndKeyExchange(null);
            }
        }
        private void NextKeyExchange(Object state) {
            RequestState requestState = state as RequestState;
            Hashtable result = GetResponseBody(requestState.response, 0);
#if SILVERLIGHT
            if (result.ContainsKey("phprpc_url")) {
                String phprpc_url = (String)result["phprpc_url"];
                url = new Uri(phprpc_url);
                if (url.Query == "") {
                    url = new Uri(phprpc_url + "?phprpc_id=" + clientID);
                }
                else {
                    url = new Uri(phprpc_url + "&phprpc_id=" + clientID);
                }
            }
#endif
            if (result.ContainsKey("phprpc_keylen")) {
                keylen = (UInt32)result["phprpc_keylen"];
            }
            else {
                keylen = 128;
            }
            if (result.ContainsKey("phprpc_encrypt")) {
                AssocArray encrypt = (AssocArray)Deserialize((Byte[])result["phprpc_encrypt"]);
                BigInteger x = BigInteger.GenerateRandom((Int32)keylen - 1);
                x.SetBit(keylen - 2);
                BigInteger y = BigInteger.Parse(PHPConvert.ToString(encrypt["y"]));
                BigInteger p = BigInteger.Parse(PHPConvert.ToString(encrypt["p"]));
                BigInteger g = BigInteger.Parse(PHPConvert.ToString(encrypt["g"]));
                if (keylen == 128) {
                    this.key = new byte[16];
                    Byte[] k = y.ModPow(x, p).GetBytes();
                    for (Int32 i = 1, n = Math.Min(k.Length, 16); i <= n; i++) {
                        this.key[16 - i] = k[n - i];
                    }
                }
                else {
                    key = MD5.Hash(encoding.GetBytes(y.ModPow(x, p).ToString()));
                }
                requestState = new RequestState();
                requestState.bufferWrite = encoding.GetBytes("phprpc_encrypt=" + g.ModPow(x, p).ToString());
                requestState.asyncCallback = new SendOrPostCallback(EndKeyExchange);
                POST(requestState);
            }
            else {
                key = null;
                requestState.encryptMode = 0;
                keyExchanged = true;
                EndKeyExchange(null);
            }
        }
        private void EndKeyExchange(Object state) {
            keyExchanging = false;
            RequestState requestState;
            if (state != null) {
                requestState = state as RequestState;
                requestState.response.Close();
            }
            while (requestQueue.Count > 0) {
                requestState = requestQueue.Dequeue();
                if ((key == null) && keyExchanged) {
                    requestState.encryptMode = 0;
                }
                StringBuilder requestBody = new StringBuilder();
                requestBody.Append("phprpc_func=").Append(requestState.function);
                if (requestState.args != null && requestState.args.Length > 0) {
                    requestBody.Append("&phprpc_args=");
                    requestBody.Append(Base64Encode(Encrypt(Serialize(requestState.args), 1, requestState.encryptMode)).Replace("+", "%2B"));
                }
                requestBody.Append("&phprpc_encrypt=").Append(requestState.encryptMode);
                if (!requestState.byRef) {
                    requestBody.Append("&phprpc_ref=false");
                }
                requestState.bufferWrite = encoding.GetBytes(requestBody.ToString());
                requestState.asyncCallback = new SendOrPostCallback(InvokeCallback);
                POST(requestState);
            }
        }
        private void InvokeCallback(Object state) {
            RequestState requestState = state as RequestState;
            Hashtable result = GetResponseBody(requestState.response, requestState.encryptMode);
            PHPRPC_Error error;
            Int32 errno = (Int32)result["phprpc_errno"];
            if (errno > 0) {
                String errstr = (String)result["phprpc_errstr"];
                error = new PHPRPC_Error(errno, errstr);
            }
            else {
                error = null;
            }
            if (result.ContainsKey("phprpc_output")) {
                output = (String)result["phprpc_output"];
            }
            else {
                output = String.Empty;
            }
            if (requestState.syncCallback != null) {
                Delegate callback = (Delegate)requestState.syncCallback;
                Type callbackType = callback.GetType();
                Object[] args = requestState.args;
                Object retval = error;
                if (result.ContainsKey("phprpc_result")) {
                    if (result.ContainsKey("phprpc_args")) {
                        args = (Object[])PHPConvert.ToArray((AssocArray)Deserialize(Decrypt((Byte[])result["phprpc_args"], 1, requestState.encryptMode)), typeof(Object[]), encoding);
                    }
                    retval = Deserialize(Decrypt((Byte[])result["phprpc_result"], 2, requestState.encryptMode));
                }
                if (callbackType.IsGenericType) {
                    Type resultType = callbackType.GetGenericArguments()[0];
                    if (retval != error) {
                        callback.DynamicInvoke(PHPConvert.ChangeType(retval, resultType, encoding), args, output, error, false);
                    }
                    else {
                        callback.DynamicInvoke(null, args, output, error, true);
                    }
                }
                else {
                    ((PHPRPC_Callback)callback)(retval, args, output, error);
                }
            }
        }
        private void GetResponseCallback(IAsyncResult asyncResult) {
            RequestState requestState = (RequestState)asyncResult.AsyncState;
            HttpWebResponse response = (HttpWebResponse)requestState.request.EndGetResponse(asyncResult);
#if !SILVERLIGHT
            Boolean hasCookie = false;
            for (Int32 i = 0; i < response.Headers.Count; ++i) {
                if (response.Headers.Keys[i].ToLower() == "set-cookie") {
                    lock (cookies.SyncRoot) {
                        hasCookie = true;
                        Regex regex = new Regex("=");
                        foreach (String c in Regex.Split(response.Headers[i], @"[;,]\s?")) {
                            String name, value;
                            if (c.IndexOf('=') > -1) {
                                String[] pair = regex.Split(c, 2);
                                name = pair[0];
                                value = pair[1];
                            }
                            else {
                                name = c;
                                value = "";
                            }
                            if ((name != "domain") && (name != "expires") &&
                                (name != "path") && (name != "secure")) {
                                cookies[name] = value;
                            }
                        }
                    }
                }
            }
            if (hasCookie) {
                lock (cookies.SyncRoot) {
                    String mcookie = "";
                    foreach (DictionaryEntry entry in cookies) {
                        mcookie += entry.Key.ToString() + "=" + entry.Value.ToString() + "; ";
                    }
                    cookie = mcookie;
                }
            }
#endif
            requestState.response = response;
            requestState.context.Post(requestState.asyncCallback, requestState);
        }
        private void GetRequestStreamCallback(IAsyncResult asyncResult) {
            RequestState requestState = (RequestState)asyncResult.AsyncState;
            Stream rs = requestState.request.EndGetRequestStream(asyncResult);
            rs.Write(requestState.bufferWrite, 0, requestState.bufferWrite.Length);
            rs.Close();
            requestState.request.BeginGetResponse(new AsyncCallback(GetResponseCallback), requestState);
        }
        private void POST(RequestState requestState) {
            HttpWebRequest request = WebRequest.Create(url) as HttpWebRequest;
            request.Method = "POST";
            request.ContentType = String.Concat("application/x-www-form-urlencoded; charset=", Charset);
            request.Accept = "*.*";
#if !SILVERLIGHT
            request.SendChunked = false;
            request.KeepAlive = false;
            request.UserAgent = "PHPRPC Client 3.0 for .NET Framework";
            if (proxy != null) {
                request.Proxy = proxy;
            }
            if (cookie != null) {
                request.Headers["Cookie"] = cookie;
            }
            request.Credentials = credentials;
            request.Timeout = timeout;
#endif
            requestState.request = request;
            requestState.context = SynchronizationContext.Current;
            request.BeginGetRequestStream(new AsyncCallback(GetRequestStreamCallback), requestState);
        }
#endif

        private Hashtable GetResponseBody(HttpWebResponse response, Byte encryptMode) {
            StreamReader sr = new StreamReader(response.GetResponseStream());
            Hashtable result = new Hashtable();
            String buf;
            while ((buf = sr.ReadLine()) != null) {
                Int32 pos = buf.IndexOf('=');
                if (pos > -1) {
                    String left = buf.Substring(0, pos);
                    String right = buf.Substring(pos + 2, buf.Length - pos - 4);
                    if (left.Equals("phprpc_errno")) {
                        result[left] = Int32.Parse(right);
                    }
                    else if (left.Equals("phprpc_keylen")) {
                        result[left] = UInt32.Parse(right);
                    }
                    else {
                        result[left] = Base64Decode(right);
                        if (left.Equals("phprpc_errstr") || left.Equals("phprpc_url")) {
                            Byte[] bytes = (Byte[])result[left];
                            result[left] = encoding.GetString(bytes, 0, bytes.Length);
                        }
                        else if (left.Equals("phprpc_output")) {
                            Byte[] bytes = (Byte[])result[left];
                            if (serverVersion >= 3) {
                                bytes = Decrypt(bytes, 3, encryptMode);
                            }
                            result[left] = encoding.GetString(bytes, 0, bytes.Length);
                        }
                    }
                }
            }
            sr.Close();
            response.Close();
            return result;
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

        private Byte[] Encrypt(Byte[] data, Byte level, Byte encryptMode) {
            if (key != null && encryptMode >= level) {
                data = XXTEA.Encrypt(data, key);
            }
            return data;
        }

        private Byte[] Decrypt(Byte[] data, Byte level, Byte encryptMode) {
            if (key != null && encryptMode >= level) {
                data = XXTEA.Decrypt(data, key);
            }
            return data;
        }

        private String Base64Encode(Byte[] data) {
            return Convert.ToBase64String(data, 0, data.Length);
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

    }
}
