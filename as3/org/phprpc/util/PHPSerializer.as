/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPSerializer.as                                         |
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
/* PHP serialize/unserialize library for ActionScript 3.0.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 4.5
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
package org.phprpc.util {
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	import flash.utils.describeType;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	public class PHPSerializer {
	    private static const _Quote:int = 34;
	    private static const _0:int = 48;
	    private static const _1:int = 49;
	    private static const _Colon:int = 58;
	    private static const _Semicolon:int = 59;
	    private static const _C:int = 67;
	    private static const _N:int = 78;
	    private static const _O:int = 79;
	    private static const _R:int = 82;
	    private static const _S:int = 83;
	    private static const _U:int = 85;
	    private static const _Slash:int = 92;
	    private static const _a:int = 97;
	    private static const _b:int = 98;
	    private static const _d:int = 100;
	    private static const _i:int = 105;
	    private static const _r:int = 114;
	    private static const _s:int = 115;
	    private static const _LeftB:int = 123;
	    private static const _RightB:int = 125;
		private static var typeCache:Object = new Object();
		private static function getPropertyNames(target:*):Array {
			var className:String = getQualifiedClassName(target);
			if (className in typeCache)	return typeCache[className];
			var propertyNames:Array = [];
			var typeInfo:XML = flash.utils.describeType(target is Class ? target : getDefinitionByName(className) as Class);
			var properties:XMLList = typeInfo.factory..accessor.(@access == "readwrite") + typeInfo..variable;
			for each (var propertyInfo:XML in properties) propertyNames.push(propertyInfo.@name.toString());
			typeCache[className] = propertyNames;
			return propertyNames;
		}
		private static function isInteger(s:String):Boolean {
			var i:int;
			var l:int = s.length;
			if (l > 11) {
				return false;
			}
			for (i = (s.charAt(0) == '-') ? 1 : 0; i < l; i++) {
				switch (s.charAt(i)) {
				case '0' :
				case '1' :
				case '2' :
				case '3' :
				case '4' :
				case '5' :
				case '6' :
				case '7' :
				case '8' :
				case '9' :
					break;
				default :
					return false;
				}
			}
			var n:Number = Number(s);
			return !(n < -2147483648 || n > 2147483647);
		}
		public static function getClassName(o:*):String {
			var className:String = getQualifiedClassName(o);
			return className.replace(/\./g, '_').replace(/\:\:/g, '_');
		}
		private static function getObjectOfClass(cn:Array, poslist:Array, i:uint, c:String):Object {
			if (i < poslist.length) {
				var pos:uint = poslist[i];
				cn[pos] = c;
				var obj:Object = getObjectOfClass(cn, poslist, i + 1, '.');
				if (i + 1 < poslist.length) {
					if (obj == null) {
						obj = getObjectOfClass(cn, poslist, i + 1, '_');
					}
				}
				return obj;
			}
			var classname:String = cn.join('');
			try {
				return new (flash.utils.getDefinitionByName(classname) as Class);
			}
			catch (e:Error) { };
			return null;
		}
		public static function createObjectOfClass(classname:String):Object {
			try {
				return new (flash.utils.getDefinitionByName(classname) as Class);
			}
			catch (e:Error) {}
			var poslist:Array = [];
			var pos:int = classname.indexOf("_");
			while (pos > -1) {
				poslist[poslist.length] = pos;
				pos = classname.indexOf("_", pos + 1);
			}
			if (poslist.length > 0) {
				var cn:Array = classname.split('');
				var obj:Object = getObjectOfClass(cn, poslist, 0, '.');
				if (obj == null) {
					obj = getObjectOfClass(cn, poslist, 0, '_');
				}
				if (obj != null) {
					return obj;
				}
			}
			return {name:classname};
		}
		public static function serialize(o:*, charset:String = "utf-8"):ByteArray {
			var sb:ByteArray = new ByteArray();
			var ht:Dictionary = new Dictionary();
			var hv:uint = 1;
			function _writeASCIIBytes(s:String):void {
				sb.writeMultiByte(s, "iso-8859-1");
			}
			function _serializeNull():void {
				sb.writeByte(_N);
				sb.writeByte(_Semicolon);
			}
			function _serializeBoolean(b:Boolean):void {
				sb.writeByte(_b);
				sb.writeByte(_Colon);
				sb.writeByte(b ? _1 : _0);
				sb.writeByte(_Semicolon);
			}
			function _serializeInteger(i:Number):void {
				sb.writeByte(_i);
				sb.writeByte(_Colon);
				_writeASCIIBytes(i);
				sb.writeByte(_Semicolon);
			}
			function _serializeDouble(d:Number):void {
				var s:String;
				if (isNaN(d)) {
					s = 'NAN';
				}
				else if (d == Number.POSITIVE_INFINITY) {
					s = 'INF';
				}
				else if (d == Number.NEGATIVE_INFINITY) {
					s = '-INF';
				}
				else {
					s = d.toString(10);
				}
				sb.writeByte(_d);
				sb.writeByte(_Colon);
				_writeASCIIBytes(s);
				sb.writeByte(_Semicolon);
			}
			function _serializeByteArray(ba:ByteArray):void {
				ba.position = 0;
				sb.writeByte(_s);
				sb.writeByte(_Colon);
				_writeASCIIBytes(ba.length);
				sb.writeByte(_Colon);
				sb.writeByte(_Quote);
				sb.writeBytes(ba);
				sb.writeByte(_Quote);
				sb.writeByte(_Semicolon);
			}
			function _serializeString(s:String):void {
				var utf8:ByteArray = new ByteArray();
				utf8.writeMultiByte(s, charset);
				_serializeByteArray(utf8);
			}
			function _serializeDate(dt:Date):void {
				_writeASCIIBytes('O:11:"PHPRPC_Date":7:');
				sb.writeByte(_LeftB);
				_writeASCIIBytes('s:4:"year";');
				_serializeInteger(dt.getFullYear());
				_writeASCIIBytes('s:5:"month";');
				_serializeInteger(dt.getMonth() + 1);
				_writeASCIIBytes('s:3:"day";');
				_serializeInteger(dt.getDate());
				_writeASCIIBytes('s:4:"hour";');
				_serializeInteger(dt.getHours());
				_writeASCIIBytes('s:6:"minute";');
				_serializeInteger(dt.getMinutes());
				_writeASCIIBytes('s:6:"second";');
				_serializeInteger(dt.getSeconds());
				_writeASCIIBytes('s:11:"millisecond";');
				_serializeInteger(dt.getMilliseconds());
				sb.writeByte(_RightB);
			}
			function _serializeArray(a:Object):void {
				var k:String;
				var l:uint = 0;
				for (k in a) {
					if (typeof(a[k]) != 'function') {
						l++;
					}
				}
				sb.writeByte(_a);
				sb.writeByte(_Colon);
				_writeASCIIBytes(l);
				sb.writeByte(_Colon);
				sb.writeByte(_LeftB);
				for (k in a) {
					if (typeof (a[k]) != 'function') {
						isInteger(k) ? _serializeInteger(k) : _serializeString(k);
						_serialize(a[k]);
					}
				}
				sb.writeByte(_RightB);
			}
			function _serializeObject(o:Object, cn:String):void {
				var c:Serializable = o as Serializable;
				var cnb:ByteArray = new ByteArray();
				cnb.writeMultiByte(cn, charset);
				if (c == null) {
					sb.writeByte(_O);
					sb.writeByte(_Colon);
					_writeASCIIBytes(cnb.length);
					sb.writeByte(_Colon);
					sb.writeByte(_Quote);
					sb.writeBytes(cnb);
                    var sleep:Boolean;
                    try {
                        sleep = (typeof(o.__sleep) == 'function');
                    }
                    catch (e:Error) {
                    	sleep = false;
                    }
					var k:String;
                    var p:Array;
                    if (sleep) {
                        p = o.__sleep();
                    }
                    else {
					    p = getPropertyNames(o);
                    }
					var l:uint = p.length;
                    if (!sleep) {
                        for (k in o) {
                            if (typeof(o[k]) != 'function') {
                                l++;
                            }
                        }
                    }
					sb.writeByte(_Quote);
					sb.writeByte(_Colon);
					_writeASCIIBytes(l);
					sb.writeByte(_Colon);
					sb.writeByte(_LeftB);
					for (k in p) {
						k = p[k];
						_serializeString(k);
						_serialize(o[k]);
					}
                    if (!sleep) {
                        for (k in o) {
                            if (typeof(o[k]) != 'function') {
                                _serializeString(k);
                                _serialize(o[k]);
                            }
                        }
                    }
					sb.writeByte(_RightB);
				}
				else {
					var data:ByteArray = c.serialize();
					sb.writeByte(_C);
					sb.writeByte(_Colon);
					_writeASCIIBytes(cnb.length);
					sb.writeByte(_Colon);
					sb.writeByte(_Quote);
					sb.writeBytes(cnb);
					sb.writeByte(_Quote);
					sb.writeByte(_Colon);
					_writeASCIIBytes(data.length);
					sb.writeByte(_Colon);
					sb.writeByte(_LeftB);
					sb.writeBytes(data);
					sb.writeByte(_RightB);
				}
			}
			function _serializePointRef(R:uint):void {
				sb.writeByte(_R);
				sb.writeByte(_Colon);
				_writeASCIIBytes(R);
				sb.writeByte(_Semicolon);
			}
			function _serializeRef(r:uint):void {
				sb.writeByte(_r);
				sb.writeByte(_Colon);
				_writeASCIIBytes(r);
				sb.writeByte(_Semicolon);

			}
			function _serialize(o:*):void {
				if (typeof (o) == "undefined" || o == null || o.constructor == Function) {
					hv++;
					_serializeNull();
					return;
				}
				var className:String = getClassName(o);
				switch (o.constructor) {
				case Boolean :
					hv++;
					_serializeBoolean(o);
					break;
				case Number :
					hv++;
					isInteger(o) ? _serializeInteger(o) : _serializeDouble(o);
					break;
				case String :
					hv++;
					_serializeString(o);
					break;
				case ByteArray :
					hv++;
					_serializeByteArray(o);
					break;
				case Date :
					hv += 8;
					_serializeDate(o);
					break;
				default :
					var r:int = ht[o];
					if (className == "Object" || o.constructor == Array) {
						if (r) {
							_serializePointRef(r);
						}
						else {
							ht[o] = hv++;
							_serializeArray(o);
						}
					}
					else {
						if (r) {
							hv++;
							_serializeRef(r);
						}
						else {
							ht[o] = hv++;
							_serializeObject(o, className);
						}
					}
					break;
				}
			}
			_serialize(o);
			return sb;
		}
		public static function unserialize(sb:ByteArray, charset:String="utf-8"):* {
			var ht:Array = [];
			var hv:int = 1;
			function _readASCIIBytes(len:uint):String {
				return sb.readMultiByte(len, "iso-8859-1");
			}
			function _readNumber():String {
		        var s:Array = [];
				var i:int = 0;
		        var c:int = sb.readByte();
		        while ((c != _Semicolon) && (c != _Colon)) {
        		    s[i++] = String.fromCharCode(c);
		            c = sb.readByte();
        		}
		        return s.join('');
		    }
			function _unserializeNull():Object {
				sb.position++;
				return null;
			}
			function _unserializeBoolean():Boolean {
				sb.position++;
				var b:Boolean = (sb.readByte() == _1);
				sb.position++;
				return b;
			}
			function _unserializeInteger():int {
				sb.position++;
				return parseInt(_readNumber());
			}
			function _unserializeDouble():Number {
				sb.position++;
				var d:Number;
				var s:String = _readNumber();
				switch (s) {
				case 'NAN' :
					d = Number.NaN;
					break;
				case 'INF' :
					d = Number.POSITIVE_INFINITY;
					break;
				case '-INF' :
					d = Number.NEGATIVE_INFINITY;
					break;
				default :
					d = parseFloat(s);
				}
				return d;
			}
			function _unserializeByteArray():ByteArray {
				sb.position++;
				var l:uint = parseInt(_readNumber());
				sb.position++;
				var ba:ByteArray = new ByteArray();
				if (l > 0) {
					sb.readBytes(ba, 0, l);
				}
				sb.position += 2;
				return ba;
			}
			function _unserializeString():String {
				sb.position++;
				var len:uint = parseInt(_readNumber());
				sb.position++;
				var s:String = sb.readMultiByte(len, charset);
				sb.position += 2;
				return s;
			}
			function _unserializeEscapedString(len:int):String {
				sb.position++;
				var l:uint = parseInt(_readNumber());
				sb.position++;
				var i:int;
				var s:Array = new Array(l);
				for (i = 0; i < l; i++) {
					if ((s[i] = String.fromCharCode(sb.readByte())) == '\\') {
						s[i] = String.fromCharCode(parseInt(_readASCIIBytes(len), 16));
					}
				}
				sb.position += 2;
				return s.join('');
			}
			function _unserializeArray():Array {
				sb.position++;
				var n:int = parseInt(_readNumber());
				sb.position++;
				var i:int;
				var k:*;
				var a:Array = [];
				ht[hv++] = a;
				for (i = 0; i < n; i++) {
					switch (sb.readByte()) {
					case _i :
						k = _unserializeInteger();
						break;
					case _s :
						k = _unserializeString();
						break;
					case _S :
						k = _unserializeEscapedString(2);
						break;
					case _U :
						k = _unserializeEscapedString(4);
						break;
					default :
						return null;
					}
					a[k] = _unserialize();
				}
				sb.position++;
				return a;
			}
			function _unserializeDate(n:int):Date {
				var i:int;
				var k:String;
				var a:Object = {};
				for (i = 0; i < n; i++) {
					switch (sb.readByte()) {
					case _s :
						k = _unserializeString();
						break;
					case _S :
						k = _unserializeEscapedString(2);
						break;
					case _U :
						k = _unserializeEscapedString(4);
						break;
					default :
						return null;
					}
					if (sb.readByte() == _i) {
						a[k] = _unserializeInteger();
					}
					else {
						return null;
					}
				}
				sb.position++;
				var dt:Date = new Date(a.year, a.month - 1, a.day, a.hour, a.minute, a.second, a.millisecond);
				ht[hv++] = dt;
				ht[hv++] = a.year;
				ht[hv++] = a.month;
				ht[hv++] = a.day;
				ht[hv++] = a.hour;
				ht[hv++] = a.minute;
				ht[hv++] = a.second;
				ht[hv++] = a.millisecond;
				return dt;
			}
			function _unserializeObject():* {
				sb.position++;
				var l:uint = parseInt(_readNumber());
				sb.position++;
				var cn:String = sb.readMultiByte(l, charset);
				sb.position += 2;
				var n:uint = parseInt(_readNumber());
				sb.position++;
				if (cn == "PHPRPC_Date") {
					return _unserializeDate(n);
				}
				var i:int;
				var k:String;
				var o:Object = createObjectOfClass(cn);
				ht[hv++] = o;
				for (i = 0; i < n; i++) {
					switch (sb.readByte()) {
					case _s :
						k = _unserializeByteArray();
						break;
					case _S :
						k = _unserializeEscapedString(2);
						break;
					case _U :
						k = _unserializeEscapedString(4);
						break;
					default :
						return null;
					}
					if (k.charCodeAt(0) == 0) {
						k = k.substring(k.indexOf(String.fromCharCode(0), 1) + 1, k.length);
					}
					try {
						o[k] = _unserialize();
					}
					catch (e: Error) {}
				}
				sb.position++;
				try {
                	if (typeof(o.__wakeup) == 'function') {
                    	o.__wakeup();
                	}
                }
                catch (e: Error) {}
				return o;
			}
			function _unserializeCustomObject():* {
				sb.position++;
				var l:uint = parseInt(_readNumber());
				sb.position++;
				var cn:String = sb.readMultiByte(l, charset);
				sb.position += 2;
				var n:uint = parseInt(_readNumber());
				sb.position++;
				var data:ByteArray = new ByteArray();
				sb.readBytes(data, 0, n);
				sb.position++;
				var o:Object = createObjectOfClass(cn);
				var c:Serializable = o as Serializable;
				if (c == null) {
					o.data = data;
					return o;
				}
				c.unserialize(data);
				return c;
			}
			function _unserializeRef():* {
				sb.position++;
				var r:uint = parseInt(_readNumber());
				return ht[r];
			}
			function _unserialize():* {
				var result:*;
				switch (sb.readByte()) {
				case _N :
					result = _unserializeNull();
					ht[hv] = result;
					hv++;
					return result;
				case _b :
					result = _unserializeBoolean();
					ht[hv] = result;
					hv++;
					return result;
				case _i :
					result = _unserializeInteger();
					ht[hv] = result;
					hv++;
					return result;
				case _d :
					result = _unserializeDouble();
					ht[hv] = result;
					hv++;
					return result;
				case _s :
					result = _unserializeByteArray();
					ht[hv] = result;
					hv++;
					return result;
				case _S :
					result = _unserializeEscapedString(2);
					ht[hv] = result;
					hv++;
					return result;
				case _U :
					result = _unserializeEscapedString(4);
					ht[hv] = result;
					hv++;
					return result;
				case _r :
					result = _unserializeRef();
					ht[hv] = result;
					hv++;
					return result;
				case _a :
					return _unserializeArray();
				case _O :
					return _unserializeObject();
				case _C :
					return _unserializeCustomObject();
				case _R :
					return _unserializeRef();
				}
				return null;
			}
			sb.position = 0;
			return _unserialize();
		}
	}
}
