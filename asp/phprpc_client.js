/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| phprpc_client.js                                         |
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

/* PHPRPC Client for ASP.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.1
 * LastModified: Mar 4, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */

/*
 * Interfaces:
 * <%@ CodePage = 65001 %>
 * <script runat="server" language="jscript" src="phprpc_client.js"></script>
 * <script runat="server" language="jscript">
 * var rpc = PHPRPC_Client.create("http://www.phprpc.org/server.php", ['add']);
 * rpc.setProxy("202.194.64.82", 8000);
 * Response.Write(rpc.add(1,2));
 * </script>
 * <%
 * Dim rpc
 * Set rpc = PHPRPC_Client.create("http://www.phprpc.org/server.php")
 * rpc.setProxy("202.194.64.82:8000")
 * rpc.setKeyLength(96)
 * rpc.setEncryptMode(2)
 * Response.Write(rpc.invoke("sub", VBArrayToJSArray(array(1,2))))
 * rpc.showfile()
 * Response.Write(rpc.getWarning())
%>
 */

/*
 * public class PHPRPC_Error
 * You never need to create PHPRPC_Error object by yourself,
 * when an error occurred during invoking remote function,
 * this object will be created automatically as the result of callback function.
 */
function PHPRPC_Error(errno, errstr) {

    // public methods

    /*
     * Return the error number.
     */
    this.getNumber = function() {
        return errno;
    }
    /*
     * Return the error message.
     */
    this.getMessage = function() {
        return errstr;
    }
    /*
     * Return a string which include the error number and the error message.
     */
    this.toString = function() {
        return errno + ":" + errstr;
    }
}

/* public class PHPRPC_Client
 * static encapsulation environment for PHPRPC_Client
 */

var PHPRPC_Client = (function () {
    function freeEval(s) {
        return eval(s);
    }

    return (function() {
        // static private members

        /*
         * to save all PHPRPC clients of one page
         */
        var s_clientList = [];

        /*
         * to save the last remote procedure id
         */
        var s_lastID = 0;

        /*
         * the XMLHttp ActiveX object name cache
         */
        var s_XMLHttpNameCache = null;

        /*
         * the Global Cookie Manager
         */
        var s_cookies = {};
        var s_cookie = null;

        // static private methods

        /*
         * create a XMLHttp Object
         */
        function createXMLHttp() {
            if (s_XMLHttpNameCache != null) {
                // Use the cache name first.
                return new ActiveXObject(s_XMLHttpNameCache);
            }
            else {
                var MSXML = ['MSXML2.ServerXMLHTTP.6.0',
                             'MSXML2.ServerXMLHTTP.5.0',
                             'MSXML2.ServerXMLHTTP.4.0',
                             'MSXML2.ServerXMLHTTP.3.0',
                             'MSXML2.ServerXMLHTTP',
                             'Microsoft.ServerXMLHTTP'];
                var n = MSXML.length;
                var objXMLHttp;
                for(var i = 0; i < n; i++) {
                    try {
                        objXMLHttp = new ActiveXObject(MSXML[i]);
                        // Cache the XMLHttp ActiveX object name.
                        s_XMLHttpNameCache = MSXML[i];
                        return objXMLHttp;
                    }
                    catch(e) {}
                }
                return null;
            }
        }

        /*
         * create a remote procedure id
         */
        function createID() {
            return s_lastID++;
        }

        /* You can create a PHPRPC Client object by this constructor in javascript.
         * The username and password can be contained in serverURL for HTTP Basic Authorization,
         * but it is NOT recommended (see also useService method for the recommended usage).
         * If you hope that the PHPRPC Client initialize remote functions without connecting to the PHPRPC Server,
         * you can specify the functions parameter.
         */
        function PHPRPC_Client(serverURL, functions) {
            // private members
            var m_xxtea    = XXTEA;
            var m_bigint   = BigInteger;
            var m_php      = PHPSerializer;
            var m_preID    = 'asp' + Math.floor((new Date()).getTime() * Math.random());
            var m_clientID = s_clientList.length;
            var m_resolveTimeout = 5000;
            var m_connectTimeout = 5000;
            var m_sendTimeout = 15000;
            var m_receiveTimeout = 15000;
            var m_username = null;
            var m_password = null;
            var m_proxy = null;
            var m_proxyUsername = null;
            var m_proxyPassword = null;
            var m_serverURL;
            var m_key;
            var m_keyLength;
            var m_encryptMode;
            var m_keyExchanging;
            var m_warning = null;
            var m_output = "";

            // private methods

            function initURL(url) {
                var p = 0;
                var protocol = null;
                var host = null;
                var path = null;
                if (url.substr(0, 7).toLowerCase() == 'http://') {
                    protocol = 'http:';
                    p = 7;
                }
                else if (url.substr(0, 8).toLowerCase() == 'https://') {
                    protocol = 'https:';
                    p = 8;
                }
                if (p > 0) {
                    host = url.substring(p, url.indexOf('/', p));
                    var m = host.match(/^([^:]*):([^@]*)@(.*)$/);
                    if (m != null) {
                        if (m_username == null) {
                            m_username = decodeURIComponent(m[1]);
                        }
                        if (m_password == null) {
                            m_password = decodeURIComponent(m[2]);
                        }
                        host = m[3];
                    }
                    path = url.substr(url.indexOf('/', p));
                }
                if ((p > 0) && (m_username != null) && (m_password != null)) {
                    url = protocol + '//' + host + path;
                }
                m_serverURL = url.replace(/[\&\?]+$/g, '');
                m_serverURL += (m_serverURL.indexOf('?', 0) == -1) ? '?' : '&';
                m_serverURL += 'phprpc_id=' + m_preID + m_clientID + '&';
            }

            function initService() {
                m_key = null;
                m_keyLength = 128;
                m_keyExchanging = false;
                m_encryptMode = 0;
                initURL(m_serverURL);
            }

            function post(xmlhttp, request) {
                xmlhttp.setTimeouts(m_resolveTimeout, m_connectTimeout, m_sendTimeout, m_receiveTimeout);
                if (m_proxy == null) {
                    xmlhttp.setProxy(0, "", "");
                }
                else {
                    xmlhttp.setProxy(2, m_proxy);
                    if (m_proxyUsername != null) {
                        try {
                            xmlhttp.setProxyCredentials(m_proxyUsername, m_proxyPassword);
                        }
                        catch(e) {
                            xmlhttp.setRequestHeader('Proxy-Authorization', 'Basic ' + btoa(m_proxyUsername + ":" + m_proxyPassword));
                        }
                    }
                }
                xmlhttp.open('POST', m_serverURL, false);
                xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
                if (m_username !== null) {
                    xmlhttp.setRequestHeader('Authorization', 'Basic ' + btoa(m_username + ":" + m_password));
                }
                if (s_cookie != null) {
                    xmlhttp.setRequestHeader('Cookie', s_cookie);
                }
                xmlhttp.send(request);
                var headers = xmlhttp.getAllResponseHeaders().split("\r\n");
                var has_cookie = false;
                for (var key in headers) {
                    var header = headers[key];
                    if (header.match(/^set-cookie:/i)) {
                        has_cookie = true;
                        var cookie = header.replace(/^set-cookie:\s?/ig, '').split(/[;,]\s?/);
                        for (var k in cookie) {
                            var name = cookie[k];
                            var value = '';
                            var c = cookie[k].match(/^(.*?)=(.*)$/);
                            if (c) {
                                name = c[1];
                                value = c[2];
                            }
                            if ((name !='domain') && (name != 'expires') &&
                                (name != 'path') && (name != 'secure')) {
                                s_cookies[name] = value;
                            }
                        }
                    }
                }
                if (has_cookie) {
                    s_cookie = '';
                    for (var name in s_cookies) {
                        value = s_cookies[name];
                        s_cookie += name + '=' + value + '; ';
                    }
                }
            }

            function useService() {
                var xmlhttp = createXMLHttp();
                try {
                    post(xmlhttp, 'phprpc_encode=false');
                }
                catch (e) {
                    return false;
                }
                if (xmlhttp.responseText) {
                    var result = createDataObject(xmlhttp.responseText);
                    return setFunctions(m_php.unserialize(result.phprpc_functions));
                }
                return false;
            }

            function arrayCopy(a, b) {
                var n = a.length;
                for (var i = 0; i < n; i++) {
                    b[i] = a[i];
                }
            }

            function argsToArray(args) {
                var array = [];
                arrayCopy(args, array);
                return array;
            }

            function createDataObject(string) {
                var params = string.split(";\r\n");
                var result = {};
                var n = params.length;
                for (var i = 0; i < n; i++) {
                    var p = params[i].indexOf('=');
                    if (p >= 0) {
                        var l = params[i].substr(0, p);
                        var r = params[i].substr(p + 1);
                        result[l] = freeEval(r);
                    }
                }
                return result;
            }

            function invoke(func, args, ref) {
                var result = keyExchange();
                if (result instanceof PHPRPC_Error) {
                    return result;
                }
                var encrypt = m_encryptMode;
                var request = 'phprpc_func=' + func
                            + '&phprpc_args=' + btoa(encryptString(m_php.serialize(args), encrypt, 1))
                            + '&phprpc_encode=false'
                            + '&phprpc_encrypt=' + encrypt;
                if ((typeof(ref) == "undefined") || !ref) {
                    request += '&phprpc_ref=false';
                }
                var xmlhttp = createXMLHttp();
                try {
                    post(xmlhttp, request.replace(/\+/g, '%2B'));
                }
                catch (e) {
                    return new PHPRPC_Error(e.number, e.description);
                }
                if (xmlhttp.responseText) {
                    return getResult(createDataObject(xmlhttp.responseText), args, ref, encrypt);
                }
                return new PHPRPC_Error(1, 'Illegal PHPRPC server.');
            }

            function setFunction(func) {
                return function() {
                    return invoke(func, argsToArray(arguments));
                }
            }

            function setFunctions(functions) {
                for (var i = 0; i < functions.length; i++) {
                    if (typeof(s_clientList[m_clientID][functions[i]]) == "undefined") {
                        s_clientList[m_clientID][functions[i]] = setFunction(functions[i]);
                    }
                }
                return true;
            }

            function keyExchange() {
                if (m_key == null && m_encryptMode > 0) {
                    var xmlhttp = createXMLHttp();
                    try {
                        post(xmlhttp, 'phprpc_encrypt=true&phprpc_encode=false&phprpc_keylen=' + m_keyLength);
                    }
                    catch (e) {
                        return;
                    }
                    if (xmlhttp.responseText) {
                        var data = createDataObject(xmlhttp.responseText);
                        if (typeof(data.phprpc_url) != "undefined") {
                            initURL(data.phprpc_url);
                        }
                        if (typeof(data.phprpc_encrypt) == 'undefined') {
                            m_key = null;
                            m_encryptMode = 0;
                            m_keyExchanging = false;
                        }
                        else {
                            if (typeof(data.phprpc_keylen) != 'undefined') {
                                m_keyLength = parseInt(data.phprpc_keylen);
                            }
                            else {
                                m_keyLength = 128;
                            }
                            var encrypt = getKey(m_php.unserialize(data.phprpc_encrypt));
                            try {
                                post(createXMLHttp(), 'phprpc_encode=false&phprpc_encrypt=' + encrypt);
                            }
                            catch (e) {
                                m_key = null;
                                m_encryptMode = 0;
                                m_keyExchanging = false;
                            }
                        }
                    }
                }
            }

            function getKey(encrypt) {
                var p = m_bigint.dec2num(encrypt['p']);
                var g = m_bigint.dec2num(encrypt['g']);
                var y = m_bigint.dec2num(encrypt['y']);
                var x = m_bigint.rand(m_keyLength - 1, 1);
                var key = m_bigint.powmod(y, x, p);
                if (m_keyLength == 128) {
                    key = m_bigint.num2str(key);
                    var n = 16 - key.length;
                    var k = [];
                    for (var i = 0; i < n; i++) {
                        k[i] = '\0';
                    }
                    k[n] = key;
                    m_key = k.join('');
                }
                else {
                    m_key = m_bigint.num2dec(key).md5();
                }
                return m_bigint.num2dec(m_bigint.powmod(g, x, p));
            }

            function encryptString(string, encrypt, level) {
                if ((m_key != null) && (encrypt >= level)) {
                    string = m_xxtea.encrypt(string, m_key);
                }
                return string;
            }

            function decryptString(string, encrypt, level) {
                if ((m_key != null) && (encrypt >= level)) {
                    string = m_xxtea.decrypt(string, m_key);
                }
                return string;
            }

            function getResult(data, args, ref, encrypt) {
                var result = new PHPRPC_Error(data.phprpc_errno, data.phprpc_errstr);
                m_warning = result;
                m_output = data.phprpc_output;
                if ((m_key !== null) && (encrypt > 2)) {
                    m_output = m_xxtea.decrypt(m_output, m_key);
                    if (m_output === null) {
                        m_output = data.phprpc_output;
                    }
                    else {
                        m_output = m_output.toUTF16();
                    }
                }
                if (typeof(data.phprpc_result) != 'undefined') {
                    result = m_php.unserialize(decryptString(data.phprpc_result, encrypt, 2));
                    if (ref && (typeof(data.phprpc_args) != 'undefined')) {
                        arrayCopy(m_php.unserialize(decryptString(data.phprpc_args, encrypt, 1)), args);
                    }
                }
                return result;
            }

            // public methods
            /*
             * Kill itself.
             */
            this.dispose = function() {
                s_clientList[m_clientID] = null;
                delete s_clientList[m_clientID];
            }

            /*
             * Set the URL of the PHPRPC Server.
             * The username and password can be contained in serverURL for HTTP Basic Authorization,
             * but it is NOT recommended. It is recommended to specify the username and password by parameters.
             * If you hope that the PHPRPC Client initialize remote functions without connecting to the PHPRPC Server,
             * you can specify the functions parameter.
             */
            this.useService = function(serverURL, username, password, functions) {
                m_username = null;
                m_password = null;
                if (typeof(serverURL) == "undefined") {
                    return new PHPRPC_Error(1, "You should set serverURL first!");
                }
                m_serverURL = serverURL;
                if ((typeof(username) != "undefined") && (typeof(password) != "undefined")) {
                    m_username = username;
                    m_password = password;
                }
                initService();
                if ((typeof(functions) == "undefined") || (functions == null)) {
                    return useService();
                }
                return setFunctions(functions);
            }

            /*
             * Set the proxy server for the transfer. The address supports using username
             * and password for the HTTP Basic Authorization, but it is NOT recommend.
             * You can set the address to null to cancel the proxy server.
             */
            this.setProxy = function(host, port, username, password) {
                if (typeof(host) == "undefined" || host == null) {
                    m_proxy = null;
                }
                else if (typeof(port) == "undefined") {
                    var p1 = 0;
                    if (host.substr(0, 7).toLowerCase() == 'http://') {
                        p1 = 7;
                    }
                    var p2 = host.indexOf('/', p1);
                    if (p1 > 0 && p2 > 0) {
                        host = host.substring(p1, p2);
                        var m = host.match(/^([^:]*):([^@]*)@(.*)$/);
                        if (m != null) {
                            m_proxyUsername = decodeURIComponent(m[1]);
                            m_proxyPassword = decodeURIComponent(m[2]);
                            host = m[3];
                        }
                    }
                    m_proxy = host;
                }
                else {
                    m_proxy = host + ":" + port;
                    if (typeof(username) != "undefined") {
                        m_proxyUsername = username;
                    }
                    if (typeof(password) != "undefined") {
                        m_proxyPassword = password;
                    }
                }
            }

            /*
             * Set the key length for the key exchange.
             * This method will return false if the key exchange has already been completed.
             */
            this.setKeyLength = function(keyLength) {
                if (m_key != null) {
                    return false;
                }
                else {
                    m_keyLength = keyLength;
                    return true;
                }
            }

            /*
             * Get the key length.
             * This method will return the actual key length when the key exchange is completed.
             * Otherwise, you will get the default length or the length you set.
             */
            this.getKeyLength = function() {
                return m_keyLength;
            }

            /*
             * Set the encrypt mode.
             * 0 indicates encrypting nothing.
             * 1 indicates encrypting arguments.
             * 2 indicates encrypting arguments and result.
             * 3 indicates encrypting arguments, result and output of the server-side page.
             * If any invalid value are set, it would return false.
             */
            this.setEncryptMode = function(encryptMode) {
                if (encryptMode >= 0 && encryptMode <= 3) {
                    m_encryptMode = parseInt(encryptMode);
                    return true;
                }
                else {
                    m_encryptMode = 0;
                    return false;
                }
            }

            /*
             * Get the encrypt mode.
             * 0 indicates encrypting nothing.
             * 1 indicates encrypting arguments.
             * 2 indicates encrypting arguments and result.
             * 3 indicates encrypting arguments, result and output of the server-side page.
             */
            this.getEncryptMode = function() {
                return m_encryptMode;
            }

            /*
             * There are two ways to invoke the remote functions. One is:
             *
             * Object remoteFunctionName(arg1, arg2, ..., argN);
             *
             * The other is:
             *
             * Object invoke(String funcname, Object[] args);
             * Object invoke(String funcname, Object[] args, Boolean byRef);
             *
             * The invoke method is similar to use the remote function name directly to invoke the remote function.
             * The difference is the invoke method can pass the arguments by reference, when set byRef to be true.
             */
            this.invoke = invoke;

            /*
             * Set the number of milliseconds a remote function is allowed to invoke.
             * The default limit is 30 seconds.
             * If the timeout parameter is set to zero or null, no time limit is imposed.
             */
            this.setTimeout = function(timeout) {
                m_sendTimeout = timeout >> 1;
                m_receiveTimeout = timeout - m_sendTimeout;
            }

            /*
             * Get the timeout in milliseconds for invoking a remote function.
             */
            this.getTimeout = function() {
                return m_sendTimeout + m_receiveTimeout;
            }

            /*
             * Get the output of the server console after invoke the server function.
             */
            this.getOutput = function() {
                return m_output;
            }

            /*
             * Get the warning of the server function after invoke the server function.
             */
            this.getWarning = function() {
                return m_warning;
            }

            /* constructor */ {
                s_clientList[m_clientID] = this;
                if (typeof(serverURL) != "undefined") {
                    if (typeof(functions) == "undefined") {
                        functions = null;
                    }
                    this.useService(serverURL, null, null, functions);
                }
            }
        }

        // static public methods
        /*
         * This method is for VBScript to create PHPRPC Client object,
         * because VBScript can't use new keyword to create a JavaScript Object.
         * but you can use this method in JavaScript too.
         */
        PHPRPC_Client.create = function(serverURL, functions) {
            if (typeof(functions) == "undefined") {
                functions = null;
            }
            return new PHPRPC_Client(serverURL, functions);
        }

        return PHPRPC_Client;
    })();
})();