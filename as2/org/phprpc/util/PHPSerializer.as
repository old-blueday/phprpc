/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPSerializer.as                                         |
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
/* PHP serialize/unserialize library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 4.1
 * LastModified: Feb 8, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */
import org.phprpc.util.ByteArray;
class org.phprpc.util.PHPSerializer {
	private static function isInteger(n):Boolean {
		var i:Number;
		var s:String = n.toString();
		var l:Number = s.length;
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
		return !(n < -2147483648 || n > 2147483647);
	}
	public static function serialize(o):ByteArray {
		var sb:ByteArray = new ByteArray();
		var ht:Array = [];
		var hv:Number = 1;
		function inHashTable(o):Number {
			var k:Number;
			for (k in ht) {
				if (ht[k] === o) {
					return k;
				}
			}
			return 0;
		}
		function _serializeNull():Void {
			sb.writeASCIIBytes('N;');
		}
		function _serializeBoolean(b:Boolean):Void {
			sb.writeASCIIBytes(b ? 'b:1;' : 'b:0;');
		}
		function _serializeInteger(i:Number):Void {
			sb.writeASCIIBytes('i:' + i + ';');
		}
		function _serializeDouble(d:Number):Void {
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
			sb.writeASCIIBytes('d:' + s + ';');
		}
		function _serializeByteArray(ba:ByteArray):Void {
			ba.position = 0;
			sb.writeASCIIBytes('s:' + ba.length + ':"');
			sb.writeBytes(ba);
			sb.writeASCIIBytes('";');
		}
		function _serializeString(s:String):Void {
			var utf8:ByteArray = new ByteArray();
			utf8.writeUTFBytes(s);
			_serializeByteArray(utf8);
		}
		function _serializeDate(dt:Date):Void {
			sb.writeASCIIBytes('O:11:"PHPRPC_Date":7:{');
			sb.writeASCIIBytes('s:4:"year";');
			_serializeInteger(dt.getFullYear());
			sb.writeASCIIBytes('s:5:"month";');
			_serializeInteger(dt.getMonth() + 1);
			sb.writeASCIIBytes('s:3:"day";');
			_serializeInteger(dt.getDate());
			sb.writeASCIIBytes('s:4:"hour";');
			_serializeInteger(dt.getHours());
			sb.writeASCIIBytes('s:6:"minute";');
			_serializeInteger(dt.getMinutes());
			sb.writeASCIIBytes('s:6:"second";');
			_serializeInteger(dt.getSeconds());
			sb.writeASCIIBytes('s:11:"millisecond";');
			_serializeInteger(dt.getMilliseconds());
			sb.writeASCIIBytes('}');
		}
		function _serializeArray(a:Object):Void {
			var k:String;
			var l:Number = 0;
			for (k in a) {
				if (typeof(a[k]) != 'function') {
					l++;
				}
			}
			sb.writeASCIIBytes('a:' + l + ':{');
			for (k in a) {
				if (typeof (a[k]) != 'function') {
					isInteger(k) ? _serializeInteger(k) : _serializeString(k);
					_serialize(a[k]);
				}
			}
			sb.writeASCIIBytes('}');
		}
		function _serializePointRef(R:Number):Void {
			sb.writeASCIIBytes('R:' + R + ';');
		}
		function _serialize(o):Void {
			if (typeof (o) == "undefined" || o == null || o.constructor == Function) {
				hv++;
				_serializeNull();
				return;
			}
			if (o instanceof ByteArray) {
				hv++;
				_serializeByteArray(o);
				return;
			}
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
			case Date :
				hv += 8;
				_serializeDate(o);
				break;
			default :
				var r:Number = inHashTable(o);
				if (r > 0) {
					_serializePointRef(r);
				}
				else {
					ht[hv++] = o;
					_serializeArray(o);
				}
				break;
			}
		}
		_serialize(o);
		return sb;
	}
	public static function unserialize(sb:ByteArray) {
		var ht:Array = [];
		var hv:Number = 1;
		function _readNumber():String {
	        var s:String = '';
	        var c:String = String.fromCharCode(sb.readByte());
	        while ((c != ';') && (c != ':')) {
       		    s += c;
	            c = String.fromCharCode(sb.readByte());
       		}
	        return s;
	    }
		function _unserializeNull():Object {
			sb.position++;
			return null;
		}
		function _unserializeBoolean():Boolean {
			sb.position++;
			var b:Boolean = (sb.readByte() == 0x31);  // 0x31 == '1'
			sb.position++;
			return b;
		}
		function _unserializeInteger():Number {
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
			var l:Number = parseInt(_readNumber());
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
			var l:Number = parseInt(_readNumber());
			sb.position++;
			var s:String = sb.readUTFBytes(l);
			sb.position += 2;
			return s;
		}
		function _unserializeEscapedString(len:Number):String {
			sb.position++;
			var l:Number = parseInt(_readNumber());
			sb.position++;
			var i:Number;
			var s:Array = new Array(l);
			for (i = 0; i < l; i++) {
				if ((s[i] = sb.readUTFBytes(1)) == '\\') {
					s[i] = String.fromCharCode(parseInt(sb.readASCIIBytes(len), 16));
				}
			}
			sb.position += 2;
			return s.join('');
		}
		function _unserializeArray():Array {
			sb.position++;
			var n:Number = parseInt(_readNumber());
			sb.position++;
			var i:Number;
			var k;
			var a:Array = [];
			ht[hv++] = a;
			for (i = 0; i < n; i++) {
				switch (String.fromCharCode(sb.readByte())) {
				case 'i' :
					k = _unserializeInteger();
					break;
				case 's' :
					k = _unserializeString();
					break;
				case 'S' :
					k = _unserializeEscapedString(2);
					break;
				case 'U' :
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
		function _unserializeDate(n):Date {
			var i:Number;
			var k:String;
			var a:Object = {};
			for (i = 0; i < n; i++) {
				switch (String.fromCharCode(sb.readByte())) {
				case 's' :
					k = _unserializeString();
					break;
				case 'S' :
					k = _unserializeEscapedString(2);
					break;
				case 'U' :
					k = _unserializeEscapedString(4);
					break;
				default :
					return null;
				}
				if (String.fromCharCode(sb.readByte()) == 'i') {
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
		function _unserializeObject() {
				sb.position++;
				var l:Number = parseInt(_readNumber());
				sb.position++;
				var cn:String = sb.readUTFBytes(l);
				sb.position += 2;
				var n:Number = parseInt(_readNumber());
				sb.position++;
				if (cn == "PHPRPC_Date") {
					return _unserializeDate(n);
				}
				var i:Number;
				var j:Number;
				var k;
				var o:Object = { name:cn };
				ht[hv++] = o;
				for (i = 0; i < n; i++) {
					switch (String.fromCharCode(sb.readByte())) {
					case 's' :
						k = _unserializeByteArray();
						if (k[0] == 0) {
							for (j = 1; k[j] > 0; j++) {};
							j++;
							k.position = j;
							k = k.readUTFBytes(k.length - j);
						}
						else {
							k = k.toString();
						}
						break;
					case 'S' :
						k = _unserializeEscapedString(2);
						break;
					case 'U' :
						k = _unserializeEscapedString(4);
						break;
					default :
						return false;
					}
					o[k] = _unserialize();
				}
				sb.position++;
				return o;
		}
		function _unserializeCustomObject() {
			sb.position++;
			var l:Number = parseInt(_readNumber());
			sb.position++;
			var cn:String = sb.readUTFBytes(l);
			sb.position += 2;
			var n:Number = parseInt(_readNumber());
			sb.position++;
			var d:ByteArray = new ByteArray();
			sb.readBytes(d, 0, n);
			sb.position++;
			var o:Object = { name:cn, data:d };
			return o;
		}
		function _unserializeRef() {
			sb.position++;
			var r:Number = parseInt(_readNumber());
			return ht[r];
		}
		function _unserialize() {
				var result;
				switch (String.fromCharCode(sb.readByte())) {
				case 'N' :
					result = _unserializeNull();
					ht[hv] = result;
					hv++;
					return result;
				case 'b' :
					result = _unserializeBoolean();
					ht[hv] = result;
					hv++;
					return result;
				case 'i' :
					result = _unserializeInteger();
					ht[hv] = result;
					hv++;
					return result;
				case 'd' :
					result = _unserializeDouble();
					ht[hv] = result;
					hv++;
					return result;
				case 's' :
					result = _unserializeByteArray();
					ht[hv] = result;
					hv++;
					return result;
				case 'S' :
					result = _unserializeEscapedString(2);
					ht[hv] = result;
					hv++;
					return result;
				case 'U' :
					result = _unserializeEscapedString(4);
					ht[hv] = result;
					hv++;
					return result;
				case 'r' :
					result = _unserializeRef();
					ht[hv] = result;
					hv++;
					return result;
				case 'a' :
					return _unserializeArray();
				case 'O' :
					return _unserializeObject();
				case 'C' :
					return _unserializeCustomObject();
				case 'R' :
					return _unserializeRef();
				}
				return false;
		}
		sb.position = 0;
		return _unserialize();
	}
}
