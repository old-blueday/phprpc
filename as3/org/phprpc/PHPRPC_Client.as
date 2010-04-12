/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Client.as                                         |
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
/* PHPRPC Client for ActionScript 3.0.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

package org.phprpc {
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	import flash.utils.ByteArray;
	import org.phprpc.util.MD5;
	import org.phprpc.util.Base64;
	import org.phprpc.util.XXTEA;
	import org.phprpc.util.BigInteger;
	import org.phprpc.util.PHPSerializer;
	import org.phprpc.PHPRPC_Error;
	public dynamic class PHPRPC_Client extends Proxy {
       		private static var s_lastID:uint = 0;
	       	private var m_clientID:String;
	       	private var m_username:String = null;
	       	private var m_password:String = null;
	       	private var m_functions:Object = null;
	       	private var m_serverURL:String;
	       	private var m_key:ByteArray;
			private var m_charset:String;
	       	private var m_keyLength:uint;
	       	private var m_encryptMode:uint;
	       	private var m_keyExchanging:Boolean;
	       	private var m_taskQueue:Array;
	       	private var m_dataObject:Array;
		private var m_callbacks:Object;
		public function PHPRPC_Client(serverURL:String = null, functions:Array = null) {
			m_clientID = "as3_" + s_lastID + "_" + Math.round(Math.random()*(new Date()).valueOf());
			m_callbacks = {};
			s_lastID++;
			if (serverURL != null) {
				this.useService(serverURL, null, null, functions);
			}
		}
		flash_proxy override function callProperty(name:*, ...rest):* {
			try {
				rest.unshift(name);
				this.invoke.apply(this, rest);
			}
			catch (e:Error) {
				return new PHPRPC_Error(e.message, e.errorID);
			}
		}
		flash_proxy override function getProperty(name:*):* {
			return m_callbacks[name];
		}
		flash_proxy override function setProperty(name:*, value:*):void {
			m_callbacks[name] = value;
		}
		flash_proxy override function deleteProperty(name:*):Boolean {
			return delete m_callbacks[name];
		}
		public function useService(serverURL:String, username:String = null, password:String = null, functions:Array = null):void {
			if (serverURL == null) {
				throw new Error("You should set serverURL first!");
			}
			m_serverURL = serverURL;
			m_username = username;
			m_password = password;
			_initService();
			if (functions == null) {
				m_functions = null;
			}
			else {
				m_functions = {};
				var n:uint = functions.length;
				for (var i:uint = 0; i < n; i++) {
					m_functions[functions[i]] = true;
				}
			}
		}
		public function setKeyLength(keyLength:uint):Boolean {
			if (m_key != null) {
				return false;
			}
			m_keyLength = keyLength;
			return true;
		}
		public function set keyLength(value:uint):void {
			setKeyLength(value);
		}
		public function getKeyLength():uint {
			return m_keyLength;
		}
		public function get keyLength():uint {
			return m_keyLength;
		}
		public function setEncryptMode(encryptMode:uint):Boolean {
			if (encryptMode <= 3) {
				m_encryptMode = encryptMode;
				return true;
			}
			else {
				m_encryptMode = 0;
				return false;
			}
		}
		public function set encryptMode(value:uint):void {
			setEncryptMode(value);
		}
		public function getEncryptMode():uint {
			return m_encryptMode;
		}
		public function get encryptMode():uint {
			return m_encryptMode;
		}
		public function setCharset(value:String):void {
			m_charset = value;
		}
		public function set charset(value:String):void {
			m_charset = value;
		}
		public function getCharset():String {
			return m_charset;
		}
		public function get charset():String {
			return m_charset;
		}
		public function toString(bin:ByteArray):String {
			bin.position = 0;
			return bin.readMultiByte(bin.length, m_charset);
		}
		public function invoke(func:String,...rest):void {
			var args:Array = rest;
			var ref:Boolean = false;
			var callback:Function = null;
			if (typeof (m_callbacks[func + '_callback']) == 'function') {
				callback = m_callbacks[func + '_callback'];
			}
			if (typeof (args[args.length - 1]) == 'boolean' && typeof (args[args.length - 2]) == 'function') {
				ref = args[args.length - 1];
				callback = args[args.length - 2];
				args.length -= 2;
			}
			else if (typeof (args[args.length - 1]) == 'function') {
				callback = args[args.length - 1];
				args.length--;
			}
			if (!_isExist(func) && callback != null) {
				var result:PHPRPC_Error = new PHPRPC_Error("Can't find this function " + func + "().", 1);
				callback(result, args, "", result);
			}
			else {
				var task:Function = function ():void {
					_call(func, args, ref, callback);
				};
				m_taskQueue.push(task);
				_keyExchange();
			}
		}
		private function _isExist(name:String):Boolean {
			if (m_functions != null) {
				if (m_functions[name]) {
					return true;
				}
				return false;
			}
			return true;
		}
		private function _initURL(url:String):void {
			var p:uint = 0;
			var protocol:String = null;
			var host:String = null;
			var path:String = null;
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
				var m:* = host.substring(0, host.indexOf('@'));
				if (m != "") {
					m = m.split(':');
					if (m_username == null) {
						m_username = decodeURIComponent(m[1]);
					}
					if (m_password == null) {
						m_password = decodeURIComponent(m[2]);
					}
					host = host.substr(host.indexOf('@') + 1);
				}
				path = url.substr(url.indexOf('/', p));
			}
			if ((p > 0) && (m_username != null) && (m_password != null)) {
				url = protocol + '//' + host + path;
			}
			var c:String = url.charAt(url.length - 1);
			while (c == '&' || c == '?') {
				url = url.substr(0, url.length - 1);
				c = url.charAt(url.length - 1);
			}
			m_serverURL = url;
		}
		private function _initService():void {
			m_key = null;
			m_keyLength = 128;
			m_keyExchanging = false;
			m_encryptMode = 0;
			m_charset = "utf-8";
			m_taskQueue = [];
			m_dataObject = [];
			_initURL(m_serverURL);
		}
		private function _getData(data:String):Object {
			var params:Array = data.split(";\r\n");
			var result:Object = {};
			var n:uint = params.length;
			for (var i:uint = 0; i < n; i++) {
				var p:int = params[i].indexOf('=');
				if (p >= 0) {
					var l:String = params[i].substr(0, p);
					var r:String = params[i].substring(p + 2, params[i].length - 1);
					if (l == "phprpc_errno" || l == "phprpc_keylen") {
						result[l] = parseInt(r);
					}
					else {
						result[l] = Base64.decode(r);
						if (l == "phprpc_errstr") {
							result[l] = toString(result[l]);
						}
					}
				}
			}
			return result;
		}
		private function _getHeader():Array {
			var header:Array = [];
			header.push(new URLRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=' + m_charset));
			if (m_username !== null) {
				var userpass:ByteArray = new ByteArray();
				userpass.writeUTFBytes(m_username + ':' + m_password);
				header.push(new URLRequestHeader('Authorization', 'Basic ' + Base64.encode(userpass)));
			}
			return header;
		}
		private function _keyExchange():void {
			if (m_keyExchanging) {
				return;
			}
			if (m_key == null && m_encryptMode > 0) {
				m_keyExchanging = true;
				var request:URLRequest = new URLRequest(m_serverURL);
				var variables:URLVariables = new URLVariables();
				variables.phprpc_id = m_clientID;
				variables.phprpc_encrypt = "true";
				variables.phprpc_keylen = m_keyLength;
				request.requestHeaders = _getHeader();
				request.data = variables;
				request.method = URLRequestMethod.POST;
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.TEXT;
				loader.addEventListener(Event.COMPLETE, _keyExchange2);
				loader.load(request);
			}
			else {
				_keyExchanged();
			}
		}
		private function _keyExchange2(event:Event):void {
			var data:Object = _getData(URLLoader(event.target).data);
			if (typeof (data.phprpc_url) != "undefined") {
				_initURL(data.phprpc_url);
			}
			if (typeof (data.phprpc_encrypt) == 'undefined') {
				m_key = null;
				m_encryptMode = 0;
				m_keyExchanging = false;
				_keyExchanged();
			}
			else {
				if (typeof (data.phprpc_keylen) != 'undefined') {
					m_keyLength = parseInt(String(data.phprpc_keylen));
				}
				else {
					m_keyLength = 128;
				}
				var encrypt:String = _getKey(PHPSerializer.unserialize(data.phprpc_encrypt, m_charset));
				var request:URLRequest = new URLRequest(m_serverURL);
				var variables:URLVariables = new URLVariables();
				variables.phprpc_id = m_clientID;
				variables.phprpc_encrypt = encrypt;
				request.requestHeaders = _getHeader();
				request.data = variables;
				request.method = URLRequestMethod.POST;
				var loader:URLLoader = new URLLoader();
				loader.dataFormat = URLLoaderDataFormat.TEXT;
				loader.addEventListener(Event.COMPLETE, _keyExchanged);
				loader.load(request);
			}
		}
		private function _getKey(encrypt:Array):String {
			var p:Array = BigInteger.dec2num(encrypt['p'].toString());
			var g:Array = BigInteger.dec2num(encrypt['g'].toString());
			var y:Array = BigInteger.dec2num(encrypt['y'].toString());
			var x:Array = BigInteger.rand(m_keyLength - 1, true);
			var k:Array = BigInteger.powmod(y, x, p);
			if (m_keyLength == 128) {
				var key:ByteArray = BigInteger.num2bin(k);
				var n:int = 16 - key.length;
				m_key = new ByteArray()
				for (var i:int = 0; i < n; i++) {
					m_key.writeByte(0);
				}
				m_key.writeBytes(key);
			}
			else {
				m_key = MD5.hash(BigInteger.num2dec(k), false);
			}
			return BigInteger.num2dec(BigInteger.powmod(g, x, p));
		}
		private function _keyExchanged(event:Event=null):void {
			m_keyExchanging = false;
			while (m_taskQueue.length > 0) {
				var task:* = m_taskQueue.shift();
				if (typeof (task) == 'function') {
					task.call(this);
				}
			}
		}
		private function _call(func:String, args:Array, ref:Boolean, callback:Function):void {
			var encrypt:uint = m_encryptMode;
			var request:URLRequest = new URLRequest(m_serverURL);
			var variables:URLVariables = new URLVariables();
			variables.phprpc_id = m_clientID;
			variables.phprpc_func = func;
			variables.phprpc_args = Base64.encode(_encryptData(PHPSerializer.serialize(args, m_charset), encrypt, 1));
			variables.phprpc_encrypt = encrypt;
			if (!ref) {
				variables.phprpc_ref = "false";
			}
			request.requestHeaders = _getHeader();
			request.data = variables;
			request.method = URLRequestMethod.POST;
			var loader:URLLoader = new URLLoader();
			loader.dataFormat = URLLoaderDataFormat.TEXT;
			loader.addEventListener(Event.COMPLETE, function(event:Event):void {
				_getResult(_getData(URLLoader(event.target).data), args, ref, encrypt, callback);
			});
			loader.load(request);
		}
		private function _encryptData(data:ByteArray, encrypt:Number, level:Number):ByteArray {
			if ((m_key != null) && (encrypt >= level)) {
				data = XXTEA.encrypt(data, m_key);
			}
			return data;
		}
		private function _decryptData(data:ByteArray, encrypt:Number, level:Number):ByteArray {
			if ((m_key != null) && (encrypt >= level)) {
				data = XXTEA.decrypt(data, m_key);
			}
			return data;
		}
		private function _getResult(data:Object, args:Array, ref:Boolean, encrypt:Number, callback:Function):void {
			if (callback != null) {
				var output:* = data.phprpc_output;
				if ((m_key !== null) && (encrypt > 2)) {
					output = XXTEA.decrypt(output, m_key);
					if (output === null) {
						output = data.phprpc_output;
					}
				}
				output = toString(output);
				var warning:PHPRPC_Error = new PHPRPC_Error(data.phprpc_errstr, data.phprpc_errno);
				var result:* = warning;
				if (typeof (data.phprpc_result) != 'undefined') {
					result = PHPSerializer.unserialize(_decryptData(data.phprpc_result, encrypt, 2), m_charset);
					if (ref && (typeof (data.phprpc_args) != 'undefined')) {
						args = PHPSerializer.unserialize(_decryptData(data.phprpc_args, encrypt, 1), m_charset);
					}
				}
				callback(result, args, output, warning);
			}
		}
	}
}