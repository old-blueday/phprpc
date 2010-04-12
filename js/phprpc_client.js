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
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/

/* PHPRPC Client for browser JavaScript
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

/*
 * Interfaces:
 * function myCallback(result, args, output, warning) {
 *     if (result instanceof PHPRPC_Error) {
 *         alert(result.getNumber());
 *         alert(result.getMessage());
 *         alert(result.toString());
 *     }
 *     else {
 *         alert(result);  // or do any other things.
 *         alert(args[1]);
 *         alert(output);
 *         alert(warning.getNumber());
 *         alert(warning.getMessage());
 *         alert(warning.toString());
 *     }
 * }
 * var rpc = new PHPRPC_Client('http://domain.com/rpcserver.php', ['rf1', 'rf2'...]);
 * rpc.setKeyLength(96);
 * rpc.setEncryptMode(3);
 * rpc.rf1(args1, args2, ..., myCallback, true);
 * rpc.rf2(args1, args2, ..., function (result) {
 *     alert(result);
 * });
 *
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
         * Only IE use it.
         */
        var s_XMLHttpNameCache = null;

        // static private methods

        /*
         * the function createXMLHttp() modified from
         * http://webfx.eae.net/dhtml/xmlextras/xmlextras.html and
         * http://www.ugia.cn/?p=85
         */
        function createXMLHttp() {
            if (window.XMLHttpRequest) {
                var objXMLHttp = new XMLHttpRequest();
                // some older versions of Moz did not support the readyState property
                // and the onreadystate event so we patch it!
                if (objXMLHttp.readyState == null) {
                    objXMLHttp.readyState = 0;
                    objXMLHttp.addEventListener(
                        "load",
                        function () {
                            objXMLHttp.readyState = 4;
                            if (typeof(objXMLHttp.onreadystatechange) == "function") {
                                objXMLHttp.onreadystatechange();
                            }
                        },
                        false
                    );
                }
                return objXMLHttp;
            }
            else if (s_XMLHttpNameCache != null) {
                // Use the cache name first.
                 return new ActiveXObject(s_XMLHttpNameCache);
            }
            else {
                var MSXML = ['MSXML2.XMLHTTP.6.0',
                             'MSXML2.XMLHTTP.5.0',
                             'MSXML2.XMLHTTP.4.0',
                             'MSXML2.XMLHTTP.3.0',
                             'MsXML2.XMLHTTP.2.6',
                             'MSXML2.XMLHTTP',
                             'Microsoft.XMLHTTP.1.0',
                             'Microsoft.XMLHTTP.1',
                             'Microsoft.XMLHTTP'];
                var n = MSXML.length;
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

        /*
         * abort the specified remote procedure on the specified PHPRPC client.
         * clientID is the PHPRPC client id.
         * id is the remote procedure id.
         */
        function abort(clientID, id) {
            if (typeof(s_clientList[clientID]) != "undefined") {
                s_clientList[clientID].abort(id);
            }
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
            var m_ready    = false;
            var m_preID    = 'js' + Math.floor((new Date()).getTime() * Math.random());
            var m_clientID = s_clientList.length;
            var m_timeout  = 30000;
            var m_ajax;
            var m_clientName;
            var m_username;
            var m_password;
            var m_serverURL;
            var m_key;
            var m_keyLength;
            var m_encryptMode;
            var m_reqHeap;
            var m_taskQueue;
            var m_dataObject;
            var m_keyExchanging;

            // public methods
            /*
             * Abort all remoting functions and then kill itself.
             */
            this.dispose = function() {
                this.abort();
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
                    useService(this.onready);
                }
                else {
                    setFunctions(functions, this.onready);
                }
                return true;
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
             * string remoteFunctionName(arg1, arg2, ..., argN);
             * string remoteFunctionName(arg1, arg2, ..., argN, callbackFunction);
             * string remoteFunctionName(arg1, arg2, ..., argN, callbackFunction, byRef);
             *
             * The other is:
             *
             * string invoke(remoteFunctionName, arg1, arg2, ..., argN);
             * string invoke(remoteFunctionName, arg1, arg2, ..., argN, callbackFunction);
             * string invoke(remoteFunctionName, arg1, arg2, ..., argN, callbackFunction, byRef);
             *
             * The invoke method is similar to use the remote function name directly to invoke the remote function.
             * The difference is the invoke method is available before the getReady() becomes true,
             * that is to say, the invoke method can be called after using useService method immediately.
             * The return value is remote function id,
             * you can use abort method to abort the remote function with this value.
             * If you want to pass the arguments by reference, set byRef to be true.
             * You can specify a callback function, when the remote function completed,
             * this callback function will be call automatically. If you didn't specify a callback function,
             * the default callback function is remoteFunctionName_callback(), You can define it separately.
             * the callback function can be defined like this:
             *
             * callbackFunction = function (result, args, output, warning) {
             *     ...
             * }
             *
             * The parameter result is the result of the remote function,
             * when an error occurred during invoking remote function,
             * this parameter is a PHPRPC_Error object.
             * The parameter args is the remote function arguments,
             * you can get the changed arguments with it when passing the arguments by reference.
             * The parameter output is the output of the server console.
             * The parameter warning is the warning of the remote function, it is a PHPRPC_Error object.
             */
            this.invoke = function() {
                var args = argsToArray(arguments);
                var func = args.shift();
                return invoke(func, args);
            }

            /*
             * If you use this method with a specified remote function id parameter,
             * it would abort the remote function you specified only,
             * otherwise it would abort all of the remote functions.
             */
            this.abort = function(id) {
                if (typeof(id) == "undefined") {
                    for (id in m_reqHeap) {
                        this.abort(id);
                    }
                }
                else if (typeof(m_reqHeap[id]) != "undefined") {
                    if (m_ajax) {
                        if ((m_reqHeap[id] != null) && (typeof(m_reqHeap[id].abort) == "function")) {
                            m_reqHeap[id].onreadystatechange = function() {};
                            m_reqHeap[id].abort();
                        }
                        deleteReqHeap(id);
                    }
                    else {
                        removeScript(id);
                        deleteReqHeap(id);
                    }
                }
            }

            /*
             * Set the number of milliseconds a remote function is allowed to invoke.
             * The default limit is 30 seconds.
             * If the timeout parameter is set to zero or null, no time limit is imposed.
             */
            this.setTimeout = function(timeout) {
                m_timeout = timeout;
            }

            /*
             * Get the timeout in milliseconds for invoking a remote function.
             */
            this.getTimeout = function() {
                return m_timeout;
            }

            /*
             * When the useService method completes,
             * this method return true, otherwise return false.
             */
            this.getReady = function() {
                return m_ready;
            }


            // public methods but not supplied to the developer

            this.__getFunctions = function(id) {
                var functions = phprpc_functions;
                delete phprpc_functions;
                setFunctions(m_php.unserialize(functions), this.onready);
                removeScript(id);
            }

            this.__keyExchange = function(id) {
                if (typeof(phprpc_url) != "undefined") {
                    initURL(phprpc_url);
                    delete phprpc_url;
                }
                if (typeof(phprpc_encrypt) == 'undefined') {
                    removeScript(id);
                    m_key = null;
                    m_encryptMode = 0;
                    m_keyExchanging = false;
                    keyExchanged();
                }
                else {
                    if (typeof(phprpc_keylen) != 'undefined') {
                        m_keyLength = parseInt(phprpc_keylen);
                        delete phprpc_keylen;
                    }
                    else {
                        m_keyLength = 128;
                    }
                    var encrypt = phprpc_encrypt;
                    delete phprpc_encrypt;
                    removeScript(id);
                    var callback = btoa((m_clientName + ".__keyExchange2('" + id + "');").toUTF8());
                    var request = 'phprpc_encrypt=' + getKey(m_php.unserialize(encrypt))
                        + '&phprpc_encode=false&phprpc_callback=' + callback;
                    appendScript(id, request);
                }
            }

            this.__keyExchange2 = function(id) {
                removeScript(id);
                m_keyExchanging = false;
                keyExchanged();
            }

            this.__callback = function(id) {
                if (typeof(m_reqHeap[id]) == 'undefined') return;
                var data = {};
                data.phprpc_errno = phprpc_errno;
                data.phprpc_errstr = phprpc_errstr;
                data.phprpc_output = phprpc_output;
                delete phprpc_errno;
                delete phprpc_errstr;
                delete phprpc_output;
                if (typeof(phprpc_result) != 'undefined') {
                    data.phprpc_result = phprpc_result;
                    delete phprpc_result;
                }
                if (typeof(phprpc_args) != 'undefined') {
                    data.phprpc_args = phprpc_args;
                    delete phprpc_args;
                }
                m_dataObject[id] = data;
                var script = document.getElementById('script_' + id);
                getResult(id, script.args, script.ref, script.encrypt, script.callback);
                deleteDataObject(id);
                deleteReqHeap(id);
                removeScript(id);
            }

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
                if (((protocol == null) || (location.protocol == 'file:')
                    || (protocol == location.protocol && host == location.host))
                    && createXMLHttp() != null) {
                    m_ajax = true;
                }
                else {
                    m_ajax = false;
                }
                if ((p > 0) && (m_username != null) && (m_password != null)) {
                    url = protocol + '//';
                    if (!m_ajax) {
                        url += encodeURIComponent(m_username) + ':' + encodeURIComponent(m_password) + '@';
                    }
                    url += host + path;
                }
                m_serverURL = url.replace(/[\&\?]+$/g, '');
                m_serverURL += (m_serverURL.indexOf('?', 0) == -1) ? '?' : '&';
                m_serverURL += 'phprpc_id=' + m_preID + m_clientID + '&';
            }

            function initService() {
                m_ready = false;
                m_key = null;
                m_keyLength = 128;
                m_keyExchanging = false;
                m_encryptMode = 0;
                m_reqHeap = [];
                m_taskQueue = [];
                m_dataObject = [];
                initURL(m_serverURL);
            }

            function useService(onready) {
                if (m_ajax) {
                    var xmlhttp = createXMLHttp();
                    var xmlhttpDone = false;
                    xmlhttp.onreadystatechange = function() {
                        if (xmlhttp.readyState == 4 && !xmlhttpDone) {
                            xmlhttpDone = true;
                            if (xmlhttp.responseText) {
                                var id = createID();
                                createDataObject(xmlhttp.responseText, id);
                                setFunctions(m_php.unserialize(m_dataObject[id].phprpc_functions), onready);
                                deleteDataObject(id);
                            }
                            xmlhttp = null;
                        }
                    }
                    try {
                        xmlhttp.open('GET', m_serverURL + 'phprpc_encode=false', true);
                        if (m_username !== null) {
                            xmlhttp.setRequestHeader('Authorization', 'Basic ' + btoa(m_username + ":" + m_password));
                        }
                        xmlhttp.send(null);
                    }
                    catch (e) {
                        xmlhttp = null;
                        m_ajax = false;
                        useService(onready);
                    }
                }
                else {
                    var id = createID();
                    var callback = btoa((m_clientName + ".__getFunctions('" + id + "');").toUTF8());
                    var request = 'phprpc_encode=false&phprpc_callback=' + callback;
                    appendScript(id, request);
                }
            }

            function appendScript(id, request, args, ref, encrypt, callback) {
                var script = document.createElement('script');
                script.id = 'script_' + id;
                script.src = m_serverURL + request.replace(/\+/g, '%2B');
                script.charset = "UTF-8";
                script.defer = true;
                script.type = 'text/javascript';
                script.args = args;
                script.ref = ref;
                script.encrypt = encrypt;
                script.callback = callback;
                var head = document.getElementsByTagName('head');
                if (head[0]) {
                    head[0].appendChild(script);
                }
                else {
                    document.body.appendChild(script);
                }
            }

            function removeScript(id) {
                var script = document.getElementById('script_' + id);
                if (script) {
                    try {
                        script.parentNode.removeChild(script);
                    }
                    catch (e) {}
                }
            }

            function argsToArray(args) {
                var n = args.length;
                var argArray = new Array(n);
                for (var i = 0; i < n; i++) {
                    argArray[i] = args[i];
                }
                return argArray;
            }

            function createDataObject(string, id) {
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
                m_dataObject[id] = result;
            }

            function deleteDataObject(id) {
                if (m_dataObject[id]) {
                    delete m_dataObject[id];
                }
            }

            function deleteReqHeap(id) {
                if (typeof(m_reqHeap[id]) != 'undefined') {
                    m_reqHeap[id] = null;
                    delete m_reqHeap[id];
                }
            }

            function invoke(func, args) {
                var id = createID();
                m_reqHeap[id] = null;
                var task = function() {
                    if (m_timeout) {
                        setTimeout(function() {
                            abort(m_clientID, id);
                        }, m_timeout);
                    }
                    call(id, func, args);
                };
                m_taskQueue.push(task);
                keyExchange();
                return id;
            }

            function setFunction(func) {
                return function() {
                    return invoke(func, argsToArray(arguments));
                }
            }

            function setFunctions(functions, onready) {
                for (var i = 0; i < functions.length; i++) {
                    s_clientList[m_clientID][functions[i]] = setFunction(functions[i]);
                }
                m_ready = true;
                if (typeof(onready) == 'function') {
                    /*
                     * This is a event. You can define it before you called useService method.
                     * When the useService method completes, this event will be fired.
                     * If you define it after you called useService method, this event may not be fired.
                     */
                    onready();
                }
            }

            function keyExchange() {
                if (m_keyExchanging) return;
                if (m_key == null && m_encryptMode > 0) {
                    m_keyExchanging = true;
                    if (m_ajax) {
                        var xmlhttp = createXMLHttp();
                        var xmlhttpDone = false;
                        xmlhttp.onreadystatechange = function () {
                            if (xmlhttp.readyState == 4 && !xmlhttpDone) {
                                xmlhttpDone = true;
                                if (xmlhttp.responseText) {
                                    var id = createID();
                                    createDataObject(xmlhttp.responseText, id);
                                    keyExchange2(id);
                                    deleteDataObject(id);
                                }
                                xmlhttp = null;
                            }
                        }
                        xmlhttp.open('GET', m_serverURL + 'phprpc_encrypt=true&phprpc_encode=false&phprpc_keylen=' + m_keyLength, true);
                        if (m_username !== null) {
                            xmlhttp.setRequestHeader('Authorization', 'Basic ' + btoa(m_username + ':' + m_password));
                        }
                        xmlhttp.send(null);
                    }
                    else {
                        var id = createID();
                        var callback = btoa((m_clientName + ".__keyExchange('" + id + "');").toUTF8());
                        var request = 'phprpc_encrypt=true&phprpc_encode=false&phprpc_keylen=' + m_keyLength + '&phprpc_callback=' + callback;
                        appendScript(id, request);
                    }
                }
                else {
                    keyExchanged();
                }
            }

            function keyExchange2(id) {
                if (typeof(m_dataObject[id].phprpc_url) != "undefined") {
                    initURL(m_dataObject[id].phprpc_url);
                }
                var data = m_dataObject[id];
                if (typeof(data.phprpc_encrypt) == 'undefined') {
                    m_key = null;
                    m_encryptMode = 0;
                    m_keyExchanging = false;
                    keyExchanged();
                }
                else {
                    if (typeof(data.phprpc_keylen) != 'undefined') {
                        m_keyLength = parseInt(data.phprpc_keylen);
                    }
                    else {
                        m_keyLength = 128;
                    }
                    var encrypt = getKey(m_php.unserialize(data.phprpc_encrypt));
                    var xmlhttp = createXMLHttp();
                    var xmlhttpDone = false;
                    xmlhttp.onreadystatechange = function () {
                        if (xmlhttp.readyState == 4 && !xmlhttpDone) {
                            xmlhttpDone = true;
                            m_keyExchanging = false;
                            keyExchanged();
                            xmlhttp = null;
                        }
                    }
                    xmlhttp.open('GET', m_serverURL + 'phprpc_encode=false&phprpc_encrypt=' + encrypt, true);
                    if (m_username !== null) {
                        xmlhttp.setRequestHeader('Authorization', 'Basic ' + btoa(m_username + ":" + m_password));
                    }
                    xmlhttp.send(null);
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

            function keyExchanged() {
                while (m_taskQueue.length > 0) {
                    var task = m_taskQueue.shift();
                    if (typeof(task) == 'function') {
                        task();
                    }
                }
            }

            function call(id, func, args) {
                if (typeof(m_reqHeap[id]) == 'undefined') return;
                var ref = false;
                var encrypt = m_encryptMode;
                var callback = s_clientList[m_clientID][func + '_callback'];
                if (typeof(callback) != 'function') {
                    callback = null;
                }
                if (typeof(args[args.length - 1]) == 'boolean' &&
                    typeof(args[args.length - 2]) == 'function') {
                    ref = args[args.length - 1];
                    callback = args[args.length - 2];
                    args.length -= 2;
                }
                else if (typeof(args[args.length - 1]) == 'function') {
                    callback = args[args.length - 1];
                    args.length--;
                }
                var request = 'phprpc_func=' + func
                            + '&phprpc_args=' + btoa(encryptString(m_php.serialize(args), encrypt, 1))
                            + '&phprpc_encode=false'
                            + '&phprpc_encrypt=' + encrypt;
                if (!ref) {
                    request += '&phprpc_ref=false';
                }

                if (m_ajax) {
                    if (typeof(m_reqHeap[id]) == 'undefined') return;
                    var xmlhttp = createXMLHttp();
                    m_reqHeap[id] = xmlhttp;
                    var xmlhttpDone = false;
                    xmlhttp.onreadystatechange = function () {
                        if (xmlhttp.readyState == 4 && !xmlhttpDone) {
                            xmlhttpDone = true;
                            if (xmlhttp.responseText) {
                                createDataObject(xmlhttp.responseText, id);
                                getResult(id, args, ref, encrypt, callback);
                                deleteDataObject(id);
                            }
                            deleteReqHeap(id);
                            xmlhttp = null;
                        }
                    }
                    xmlhttp.open('POST', m_serverURL, true);
                    xmlhttp.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
                    if (m_username !== null) {
                        xmlhttp.setRequestHeader('Authorization', 'Basic ' + btoa(m_username + ":" + m_password));
                    }
                    xmlhttp.send(request.replace(/\+/g, '%2B'));
                }
                else {
                    request += '&phprpc_callback=' + btoa((m_clientName + ".__callback('" + id + "');").toUTF8());
                    if (typeof(m_reqHeap[id]) == 'undefined') return;
                    appendScript(id, request, args, ref, encrypt, callback);
                }
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

            function getResult(id, args, ref, encrypt, callback) {
                if (typeof(callback) == 'function' && typeof(m_reqHeap[id]) != 'undefined') {
                    var data = m_dataObject[id];
                    var output = data.phprpc_output;
                    if ((m_key !== null) && (encrypt > 2)) {
                        output = m_xxtea.decrypt(output, m_key);
                        if (output === null) {
                            output = data.phprpc_output;
                        }
                        else {
                            output = output.toUTF16();
                        }
                    }
                    var result = new PHPRPC_Error(data.phprpc_errno, data.phprpc_errstr);
                    var warning = result;
                    if (typeof(data.phprpc_result) != 'undefined') {
                        result = m_php.unserialize(decryptString(data.phprpc_result, encrypt, 2));
                        if (ref && (typeof(data.phprpc_args) != 'undefined')) {
                            args = m_php.unserialize(decryptString(data.phprpc_args, encrypt, 1));
                        }
                    }
                    callback(result, args, output, warning);
                }
            }

            /* constructor */ {
                s_clientList[m_clientID] = this;
                m_clientName = 'PHPRPC_Client.__getClient(' + m_clientID + ')';
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

        // static public method but not supplied to the developer
        PHPRPC_Client.__getClient = function(clientID) {
            return s_clientList[clientID];
        }

        return PHPRPC_Client;
    })();
})();