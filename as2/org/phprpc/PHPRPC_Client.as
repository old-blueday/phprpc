/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Client.as                                         |
|                                                          |
| Release 3.0.0                                            |
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
/* PHPRPC Client for ActionScript 2.0.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.0
 * LastModified: Jan 14, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */
import org.phprpc.util.MD5;
import org.phprpc.util.Base64;
import org.phprpc.util.ByteArray;
import org.phprpc.util.URI;
import org.phprpc.util.XXTEA;
import org.phprpc.util.BigInteger;
import org.phprpc.util.PHPSerializer;
import org.phprpc.PHPRPC_Error;
dynamic class org.phprpc.PHPRPC_Client extends Object {
	private static var s_lastID:Number = 0;
	private var m_clientID:String;
	private var m_username:String = null;
	private var m_password:String = null;
	private var m_functions:Object = null;
	private var m_serverURL:String;
	private var m_key:ByteArray;
	private var m_keyLength:Number;
	private var m_encryptMode:Number;
	private var m_keyExchanging:Boolean;
	private var m_taskQueue:Array;
	private var m_dataObject:Array;
	public function PHPRPC_Client(serverURL:String, functions:Array) {
		m_clientID = "as2_" + s_lastID + "_" + random((new Date()).valueOf());
		s_lastID++;
		if (typeof (serverURL) != "undefined") {
			if (typeof (functions) == "undefined") {
				functions = null;
			}
			this.useService(serverURL, null, null, functions);
		}
	}
	private function __resolve(name:String):Function {
		return function ():Void {
			arguments.unshift(name);
			this.invoke.apply(this, arguments);
		};
	}
	public function useService(serverURL:String, username:String, password:String, functions:Array):Void {
		m_username = null;
		m_password = null;
		if (typeof (serverURL) == "undefined") {
			throw new Error("You should set serverURL first!");
		}
		m_serverURL = serverURL;
		if ((typeof (username) != "undefined") && (typeof (password) != "undefined")) {
			m_username = username;
			m_password = password;
		}
		_initService();
		if ((typeof (functions) == "undefined") || (functions == null)) {
			m_functions = null;
		}
		else {
			m_functions = {};
			var n:Number = functions.length;
			for (var i:Number = 0; i < n; i++) {
				m_functions[functions[i]] = true;
			}
		}
	}
	public function setKeyLength(keyLength:Number):Boolean {
		if (m_key != null) {
			return false;
		}
		m_keyLength = keyLength;
		return true;
	}
	public function set keyLength(value:Number) {
		setKeyLength(value);
	}
	public function getKeyLength():Number {
		return m_keyLength;
	}
	public function get keyLength():Number {
		return m_keyLength;
	}
	public function setEncryptMode(encryptMode:Number):Boolean {
		if (encryptMode >= 0 && encryptMode <= 3) {
			m_encryptMode = Math.floor(encryptMode);
			return true;
		}
		else {
			m_encryptMode = 0;
			return false;
		}
	}
	public function set encryptMode(value:Number) {
		setEncryptMode(value);
	}
	public function getEncryptMode():Number {
		return m_encryptMode;
	}
	public function get encryptMode():Number {
		return m_encryptMode;
	}
	public function invoke():Void {
		var args:Array = _argsToArray(arguments);
		var func:String = args.shift().toString();
		var ref:Boolean = false;
		var callback:Function = this[func + '_callback'];
		if (typeof (callback) != 'function') {
			callback = null;
		}
		if (typeof (args[args.length - 1]) == 'boolean' && typeof (args[args.length - 2]) == 'function') {
			ref = Boolean(args[args.length - 1]);
			callback = args[args.length - 2];
			args.length -= 2;
		}
		else if (typeof (args[args.length - 1]) == 'function') {
			callback = args[args.length - 1];
			args.length--;
		}
		if (!_isExist(func) && callback != null) {
			var result = new PHPRPC_Error(1, "Can't find this function " + func + "().");
			callback(result, args, "", result);
		}
		else {
			var task:Function = function ():Void {
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
	private function _initURL(url:String) {
		var p:Number = 0;
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
			var m = host.substring(0, host.indexOf('@'));
			if (m != "") {
				m = m.split(':');
				if (m_username == null) {
					m_username = URI.decodeURIComponent(m[1]);
				}
				if (m_password == null) {
					m_password = URI.decodeURIComponent(m[2]);
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
	private function _initService() {
		m_key = null;
		m_keyLength = 128;
		m_keyExchanging = false;
		m_encryptMode = 0;
		m_taskQueue = [];
		m_dataObject = [];
		_initURL(m_serverURL);
	}
	private function _argsToArray(args):Array {
		var n:Number = args.length;
		var argArray:Array = new Array(n);
		for (var i:Number = 0; i < n; i++) {
			argArray[i] = args[i];
		}
		return argArray;
	}
	private function _getHTTPStatus(httpStatus:Number) {
		this.phprpc_errno = httpStatus;
		if (httpStatus < 100) {
			this.phprpc_errstr = "flashError";
		}
		else if (httpStatus < 200) {
			this.phprpc_errstr = "informational";
		}
		else if (httpStatus < 300) {
			this.phprpc_errstr = "Illegal PHPRPC server.";
		}
		else if (httpStatus < 400) {
			this.phprpc_errstr = "redirection";
		}
		else if (httpStatus < 500) {
			this.phprpc_errstr = "clientError";
		}
		else if (httpStatus < 600) {
			this.phprpc_errstr = "serverError";
		}
	}
	private function _getData(data:String) {
		var params:Array = data.split(";\r\n");
		var n:Number = params.length;
		for (var i:Number = 0; i < n; i++) {
			var p:Number = params[i].indexOf('=');
			if (p >= 0) {
				var l:String = params[i].substr(0, p);
				var r:String = params[i].substring(p + 2, params[i].length - 1);
				if (l == "phprpc_errno" || l == "phprpc_keylen") {
					this[l] = parseInt(r);
				}
				else {
					this[l] = Base64.decode(r);
					if (l == "phprpc_errstr") {
						this[l] = this[l].toString();
					}
				}
			}
		}
		this.onLoad(true);
	}
	private function _post(send_lv:LoadVars, receive_lv:LoadVars) {
		send_lv.addRequestHeader('Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8');
		if (m_username !== null) {
			var userpass:ByteArray = new ByteArray();
			userpass.writeUTFBytes(m_username + ':' + m_password);
			send_lv.addRequestHeader("Authorization", 'Basic ' + Base64.encode(userpass));
		}
		send_lv.sendAndLoad(m_serverURL, receive_lv, "POST");
	}
	private function _keyExchange() {
		if (m_keyExchanging) {
			return;
		}
		if (m_key == null && m_encryptMode > 0) {
			m_keyExchanging = true;
			var receive_lv:LoadVars = new LoadVars();
			var send_lv:LoadVars = new LoadVars();
			var self = this;
			receive_lv.onHTTPStatus = _getHTTPStatus;
			receive_lv.onData = _getData;
			receive_lv.onLoad = function(success:Boolean) {
				self._keyExchange2(receive_lv);
			};
			send_lv.phprpc_id = m_clientID;
			send_lv.phprpc_encrypt = "true";
			send_lv.phprpc_keylen = m_keyLength;
			_post(send_lv, receive_lv);
		}
		else {
			_keyExchanged();
		}
	}
	private function _keyExchange2(data:LoadVars) {
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
			var encrypt:String = _getKey(PHPSerializer.unserialize(data.phprpc_encrypt));
			var receive_lv:LoadVars = new LoadVars();
			var send_lv:LoadVars = new LoadVars();
			var self = this;
			receive_lv.onHTTPStatus = _getHTTPStatus;
			receive_lv.onData = _getData;
			receive_lv.onLoad = function(success:Boolean) {
				self._keyExchanged();
			};
			send_lv.phprpc_id = m_clientID;
			send_lv.phprpc_encrypt = encrypt;
			_post(send_lv, receive_lv);
		}
	}
	private function _getKey(encrypt:Array):String {
		var p:Array = BigInteger.dec2num(encrypt['p'].toString());
		var g:Array = BigInteger.dec2num(encrypt['g'].toString());
		var y:Array = BigInteger.dec2num(encrypt['y'].toString());
		var x:Array = BigInteger.rand(m_keyLength - 1, true);
		var k:Array = BigInteger.powmod(y, x, p);
		var key:ByteArray;
		var i:Number;
		if (m_keyLength == 128) {
			key = BigInteger.num2bin(k);
			var n:Number = 16 - key.length;
			for (i = 0; i < n; i++) {
				key.unshift(0);
			}
		}
		else {
			key = MD5.hash(BigInteger.num2dec(k), false);
		}
		m_key = key;
		return BigInteger.num2dec(BigInteger.powmod(g, x, p));
	}
	private function _keyExchanged() {
		m_keyExchanging = false;
		while (m_taskQueue.length > 0) {
			var task = m_taskQueue.shift();
			if (typeof (task) == 'function') {
				task.call(this);
			}
		}
	}
	private function _call(func:String, args:Array, ref:Boolean, callback:Function):Void {
		var encrypt:Number = m_encryptMode;
		var receive_lv:LoadVars = new LoadVars();
		var send_lv:LoadVars = new LoadVars();
		var self = this;
		receive_lv.onHTTPStatus = _getHTTPStatus;
		receive_lv.onData = _getData;
		receive_lv.onLoad = function(success:Boolean) {
			self._getResult(receive_lv, args, ref, encrypt, callback);
		};
		send_lv.phprpc_id = m_clientID;
		send_lv.phprpc_func = func;
		send_lv.phprpc_args = Base64.encode(_encryptData(PHPSerializer.serialize(args), encrypt, 1));
		send_lv.phprpc_encrypt = encrypt;
		if (!ref) {
			send_lv.phprpc_ref = "false";
		}
		_post(send_lv, receive_lv);
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
	private function _getResult(data:LoadVars, args:Array, ref:Boolean, encrypt:Number, callback) {
		if (typeof (callback) == "function") {
			var output = data.phprpc_output;
			if ((m_key !== null) && (encrypt > 2)) {
				output = XXTEA.decrypt(output, m_key);
				if (output === null) {
					output = data.phprpc_output;
				}
			}
			output = output.toString();
			var warning = new PHPRPC_Error(data.phprpc_errno, data.phprpc_errstr);
			var result = warning;
			if (typeof (data.phprpc_result) != 'undefined') {
				result = PHPSerializer.unserialize(_decryptData(data.phprpc_result, encrypt, 2));
				if (ref && (typeof (data.phprpc_args) != 'undefined')) {
					args = PHPSerializer.unserialize(_decryptData(data.phprpc_args, encrypt, 1));
				}
			}
			callback(result, args, output, warning);
		}
	}
}
