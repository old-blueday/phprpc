/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| phprpc_server.js                                         |
|                                                          |
| Release 3.0.1                                            |
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

/* PHPRPC Server for ASP
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Dec 19, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */

/*
 * JScript interfaces:
 * server.asp
 * <%@ CodePage = 65001 %>
 * <script runat="server" language="JScript" type="text/javascript" src="phprpc_server.js"></script>
 * <script runat="server" language="JScript">
 * function add(a, b) {
 *     return a + b;
 * }

 * function subtract(a, b) {
 *     return a - b;
 * }
 * rpc_server = PHPRPC_Server.create();
 * rpc_server.add("add");
 * rpc_server.add(subtract, null, "sub");
 * rpc_server.start();
 * </script>
 *
 * VBScript interfaces:
 * <%@ CodePage = 65001 %>
 * <script runat="server" language="JScript" type="text/javascript" src="phprpc_server.js"></script>
 * <%
 * function add(a, b)
 *     add = a + b
 * end function

 * function subtract(a, b)
 *     subtract = a - b
 * end function
 * dim rpc_server
 * set rpc_server = PHPRPC_Server.create()
 * rpc_server.add "add"
 * rpc_server.add "subtract", null, "sub"
 * rpc_server.start()
 * %>
 */

var FakeResponse = new function() {
    var buffer = [''];
    var bufferStr = null;
    this.Get = function() {
        if (bufferStr == null) {
            bufferStr = buffer.join('');
        }
        return bufferStr;
    };
    this.Clear = function() {
        buffer = [''];
        bufferStr = null;
    };
    this.Write = function(s) {
        bufferStr = null;
        buffer.push(s.toString());
    };
    this.Charset = function(s) {
        return Response.Charset(s);
    };
    this.IsClientConnected = function () {
        return Response.IsClientConnected();
    };
    this.BinaryWrite = function() {};
    this.AddHeader = function() {};
    this.AppendToLog = function() {}
    this.Redirect = function() {};
    this.End = function() {};
    this.Flush = function() {};
    this.PICS = function() {};
    this.Buffer = true;
    this.Cookies = new ActiveXObject("Scripting.Dictionary");
    this.CacheControl = Response.CacheControl;
    this.ContentType = Response.ContentType;
    this.Expires = Response.Expires;
    this.ExpiresAbsolute = Response.ExpireAbsolute;
    this.Status = Response.Status;
    this.LCID = Response.LCID;
}

var PHPRPC_Server = (function () {
    var s_php = PHPSerializer;

    function DHParams(len) {
        var m_len;
        var m_dhParams;
        function getNearest(n, a) {
            var j = 0;
            var m = Math.abs(a[0] - n);
            for (var i = 1; i < a.length; i++) {
                var t = Math.abs(a[i] - n);
                if (m > t) {
                    m = t;
                    j = i;
                }
            }
            return a[j];
        }

        this.getL = function() {
            return m_len;
        }

        this.getDHParams = function() {
            return m_dhParams;
        }

        /* constructor */ {
            var a = [96, 128, 160];
            m_len = getNearest(len, a);
            var dhParams;
            if (typeof(Application("PHPRPC_DHParam_" + m_len) == "undefined")) {
                var fso = Server.CreateObject("Scripting.FileSystemObject");
                var f = fso.OpenTextFile(Server.MapPath('dhparams/' + m_len + '.dhp'), 1, false);
                var dhp = f.ReadAll();
                f.Close();
                Application.lock();
                Application("PHPRPC_DHParam_" + m_len) = dhp;
                Application.unlock();
            }
            dhParams = s_php.unserialize(Application("PHPRPC_DHParam_" + m_len));
            m_dhParams = dhParams[Math.floor(Math.random() * dhParams.length)];
        }
    }

    return function PHPRPC_Server() {
        var m_xxtea  = XXTEA;
        var m_bigint = BigInteger;
        var m_callback;
        var m_encode;
        var m_ref;
        var m_encrypt;
        var m_keylen;
        var m_key;
        var m_output;
        var m_errno;
        var m_errstr;
        var m_functions;
        var m_cid;
        var m_buffer;


        this.__addJsSlashes = function(string, flag) {
            var test;
            if (flag == false) {
                test = /([\0-\037\042\047\134\177])/g;
            }
            else {
                test = /([\0-\037\042\047\134\177-\377])/g;
            }
            return string.replace(test, function ($1) {
                var s = $1.charCodeAt(0).toString(16);
                return '\\x' + ((s.length == 1) ? "0" : "") + s;
            });
        }

        this.__encodeString = function(string, flag) {
            if (m_encode) {
                if (!flag) {
                    string = string.toUTF8();
                }
                return btoa(string);
            }
            else {
                return this.__addJsSlashes(string, flag);
            }
        }

        this.__encryptString = function(string, level) {
            if (m_encrypt >= level) {
                string = m_xxtea.encrypt(string, m_key);
            }
            return string;
        }

        this.__decryptString = function(string, level) {
            if (m_encrypt >= level) {
                string = m_xxtea.decrypt(string, m_key);
            }
            return string;
        }

        this.__getGMTDate = function(date) {
            var week = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"];
            return week[date.getUTCDay()] + ", " + date.toGMTString();
        }

        this.__IsEmpty = function(o) {
            return (typeof(o) == "object" && String(o) == "undefined");
        }

        this.__sendHeader = function() {
            var date = this.__getGMTDate(new Date());
            Response.ContentType = "text/plain";
            Response.Charset = "utf-8";
            Response.AddHeader('P3P', 'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV"');
            Response.AddHeader("X-Powered-By", "PHPRPC Server/3.0");
            Response.AddHeader("Expires", date);
            Response.AddHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
        }

        this.__sendCallback = function() {
            m_buffer.push(m_callback);
            Response.Write(m_buffer.join(''));
            Response.End();
        }

        this.__sendFunctions = function() {
            var functions = [];
            for (var name in m_functions) {
                functions.push(name);
            }
            m_buffer.push('phprpc_functions="', this.__encodeString(s_php.serialize(functions), true), '";\r\n');
            this.__sendCallback();
        }

        this.__sendOutput = function() {
            if (m_encrypt >= 3) {
                m_buffer.push('phprpc_output="', this.__encodeString(m_xxtea.encrypt(m_output, m_key), true), '";\r\n');
            }
            else {
                m_buffer.push('phprpc_output="', this.__encodeString(m_output, false), '";\r\n');
            }
        }

        this.__sendError = function() {
            m_buffer.push('phprpc_errno="', m_errno, '";\r\n');
            m_buffer.push('phprpc_errstr="' , this.__encodeString(m_errstr, false), '";\r\n');
            this.__sendOutput();
            this.__sendCallback();
        }

        this.__call = function(func, obj, args) {
            var result;
            if (typeof(func) == "function") {
                result = func.apply(obj, args);
            }
            else if (obj == null) {
                try {
                    result = eval(func).apply(null, args);
                }
                catch (e) {
                    var a = [];
                    for (var i = 0, n = args.length; i < n; i++) {
                        a[i] = 'args[' + i + ']';
                    }
                    result = eval(func + "(" + a.join(', ') + ")");
                }
            }
            else {
                result = obj[func].apply(obj, args);
            }
            m_output = FakeResponse.Get();
            return result;
        }

        this.__getBooleanRequest = function(name) {
            var result = true;
            if (!this.__IsEmpty(Request(name))) {
                result = !(String(Request(name)).toLowerCase() == "false");
            }
            return result;
        }

        this.__initEncode = function() {
            m_encode = this.__getBooleanRequest('phprpc_encode');
        }

        this.__initRef = function() {
            m_ref = this.__getBooleanRequest('phprpc_ref');
        }

        this.__initCallback = function() {
            if (!this.__IsEmpty(Request('phprpc_callback'))) {
                m_callback = atob(String(Request('phprpc_callback'))).toUTF16();
            }
            else {
                m_callback = "";
            }
        }

        this.__initKeylen = function() {
            m_keylen = 128;
            if (!this.__IsEmpty(Request('phprpc_keylen'))) {
                m_keylen = parseInt(String(Request('phprpc_keylen')));
            }
            else if (typeof(Session(m_cid)) != "undefined") {
                var session = Session(m_cid);
                if (typeof(session.keylen) != "undefined") {
                    m_keylen = session.keylen;
                }
            }
        }

        this.__initClientID = function() {
            m_cid = 0;
            if (!this.__IsEmpty(Request('phprpc_id'))) {
                m_cid = String(Request('phprpc_id'));
            }
            m_cid = "phprpc_" + m_cid;
        }

        this.__initEncrypt = function() {
            m_encrypt = false;
            if (!this.__IsEmpty(Request('phprpc_encrypt'))) {
                m_encrypt = String(Request('phprpc_encrypt'));
                if (m_encrypt === "true") m_encrypt = true;
                if (m_encrypt === "false") m_encrypt = false;
            }
        }

        this.__initKey = function() {
            if (typeof(Session(m_cid)) != "undefined") {
                var session = Session(m_cid);
                if (typeof(session.key) != "undefined") {
                    m_key = session.key;
                    return;
                }
            }
            if (m_encrypt > 0) {
                m_errno = 1;
                m_errstr = "Can't find the key for decryption.";
                m_encrypt = 0;
                this.__sendError();
            }
        }

        this.__getArguments = function() {
            var args = [];
            if (!this.__IsEmpty(Request('phprpc_args'))) {
                args = s_php.unserialize(this.__decryptString(atob(String(Request('phprpc_args'))), 1));
            }
            return args;
        }

        this.__callFunction = function() {
            var func = String(Request('phprpc_func')).toLowerCase();
            if (typeof(m_functions[func]) != "undefined") {
                this.__initKey();
                var obj = m_functions[func].obj;
                func = m_functions[func].func;
                var args = this.__getArguments();
                var result = this.__encodeString(this.__encryptString(s_php.serialize(this.__call(func, obj, args)), 2), true);
                m_buffer.push('phprpc_result="', result, '";\r\n');
                if (m_ref) {
                    args = this.__encodeString(this.__encryptString(s_php.serialize(args), 1), true);
                    m_buffer.push('phprpc_args="', args, '";\r\n');
                }
            }
            else {
                m_errno = 1;
                m_errstr = "Can't find this function " + func + "().";
            }
            this.__sendError();
        }

        this.__keyExchange = function() {
            this.__initKeylen();
            var dhParams, encrypt, x, y, g, p, session, key;
            if (m_encrypt === true) {
                dhParams = new DHParams(m_keylen);
                m_keylen = dhParams.getL();
                encrypt = dhParams.getDHParams();
                x = m_bigint.rand(m_keylen - 1, 1);
                session = {};
                session.x = m_bigint.num2dec(x);
                session.p = encrypt.p;
                session.keylen = m_keylen;
                Session(m_cid) = session;
                g = m_bigint.dec2num(encrypt.g);
                p = m_bigint.dec2num(encrypt.p);
                encrypt.y = m_bigint.num2dec(m_bigint.powmod(g, x, p));
                m_buffer.push('phprpc_encrypt="', this.__encodeString(s_php.serialize(encrypt), true), '";\r\n');
                if (m_keylen != 128) {
                    m_buffer.push('phprpc_keylen="', m_keylen, '";\r\n');
                }
            }
            else {
                session = Session(m_cid);
                y = m_bigint.dec2num(m_encrypt);
                x = m_bigint.dec2num(session.x);
                p = m_bigint.dec2num(session.p);
                key = m_bigint.powmod(y, x, p);
                if (m_keylen == 128) {
                    key = m_bigint.num2str(key);
                    var n = 16 - key.length;
                    var k = [];
                    for (var i = 0; i < n; i++) {
                        k[i] = '\0';
                    }
                    k[n] = key;
                    key = k.join('');
                }
                else {
                    key = m_bigint.num2dec(key).md5();
                }
                session.key = key;
                Session(m_cid) = session;
            }
            this.__sendCallback();
        }

        /* constructor */ {
            m_functions = [];
            m_errno = 0;
            m_errstr = "";
            m_output = "";
            m_buffer = [];
            Session.CodePage = 65001;
            Response.CodePage = 65001;
            Response.Buffer = true;
        }

        // public methods

        this.add = function(functions, obj, aliases) {
            var alias, name, i;
            if (typeof(functions) == "undefined") {
                return false;
            }
            if (typeof(functions) == "function" && typeof(aliases) != "string") {
                return false;
            }
            if (typeof(obj) == "undefined") {
                obj = null;
            }
            if (typeof(aliases) == "undefined") {
                aliases = null;
            }
            if (typeof(functions) != typeof(aliases) && typeof(functions) != "function" && aliases != null) {
                return false;
            }
            if (typeof(functions) == "object") {
                obj = functions;
                functions = [];
                aliases = [];
                for (name in obj) {
                    if (typeof(obj[name]) == "function") {
                        functions[functions.length] = obj[name];
                        aliases[aliases.length] = name;
                    }
                }
            }
            if (aliases == null) {
                aliases = functions;
            }
            if (typeof(functions) == "string" || typeof(functions) == "function") {
                alias = aliases.toLowerCase();
                m_functions[alias] = {};
                m_functions[alias].func = functions;
                m_functions[alias].obj = obj;
                return true;
            }
            if (functions instanceof VBArray) {
                functions = functions.toArray();
                aliases = aliases.toArray();
            }
            if (functions instanceof Array) {
                if (functions.length == aliases.length) {
                    for (i = 0; i < functions.length; i++) {
                        alias = aliases[i].toLowerCase();
                        m_functions[alias] = {};
                        m_functions[alias].func = functions[i];
                        m_functions[alias].obj = obj;
                    }
                    return true;
                }
            }
            return false;
        }
        this.start = function() {
            Response.Clear();
            Response.Clear();
            this.__sendHeader();
            try {
                this.__initEncode();
                this.__initCallback();
                this.__initRef();
                this.__initClientID();
                this.__initEncrypt();
                if (!this.__IsEmpty(Request('phprpc_func'))) {
                    this.__callFunction();
                }
                else if (m_encrypt != false) {
                    this.__keyExchange();
                }
                else {
                    this.__sendFunctions();
                }
            }
            catch (e) {
                m_errno = 1;
                if (e) {
                    m_errstr = e.description;
                }
                else {
                    m_errstr = "Unknown Error!";
                }
                this.__sendError();
            }
        }
    }
})();

PHPRPC_Server.create = function() {
    return new PHPRPC_Server();
}