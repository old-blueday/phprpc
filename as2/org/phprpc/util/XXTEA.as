/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| XXTEA.as                                                 |
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
/* XXTEA encryption arithmetic library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 1.7
 * LastModified: Jan 14, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */

import org.phprpc.util.ByteArray;
class org.phprpc.util.XXTEA {
	private static var delta:Number = 0x9E3779B9;
	private static function LongArrayToByteArray(data:Array, includeLength:Boolean):ByteArray {
		var length:Number = data.length;
		var n:Number = (length - 1) << 2;
		if (includeLength) {
			var m:Number = data[length - 1];
			if ((m < n - 3) || (m > n)) {
				return null;
			}
			n = m;
		}
		var result:ByteArray = new ByteArray();
		for (var i:Number = 0; i < length; i++) {
			result.writeByte(data[i]);
			result.writeByte(data[i] >>> 8);
			result.writeByte(data[i] >>> 16);
			result.writeByte(data[i] >>> 24);
		}
		if (includeLength) {
			result.length = n;
			return result;
		}
		else {
			return result;
		}
	}
	private static function ByteArrayToLongArray(data:ByteArray, includeLength:Boolean):Array {
		var length:Number = data.length;
		var n:Number = length >> 2;
		if (length % 4 > 0) {
			n++;
			data.length += (4 - (length % 4));
		}
		data.position = 0;
		var result:Array = [];
		for (var i:Number = 0; i < n; i++) {
			result[i] = data.readByte() | data.readByte() << 8 | data.readByte() << 16 | data.readByte() << 24;
		}
		if (includeLength) {
			result[n] = length;
		}
		data.length = length;
		return result;
	}
	public static function encrypt(data:ByteArray, key:ByteArray):ByteArray {
		if (data.length == 0) {
			return new ByteArray();
		}
		var v:Array = ByteArrayToLongArray(data, true);
		var k:Array = ByteArrayToLongArray(key, false);
		if (k.length < 4) {
			k.length = 4;
		}
		var n:Number = v.length - 1;
		var z:Number = v[n];
		var y:Number = v[0];
		var mx:Number;
		var e:Number;
		var p:Number;
		var q:Number = Math.floor(6 + 52 / (n + 1));
		var sum:Number = 0;
		while (0 < q--) {
			sum = sum + delta & 0xffffffff;
			e = sum >>> 2 & 3;
			for (p = 0; p < n; p++) {
				y = v[p + 1];
				mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
				z = v[p] = v[p] + mx & 0xffffffff;
			}
			y = v[0];
			mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
			z = v[n] = v[n] + mx & 0xffffffff;
		}
		return LongArrayToByteArray(v, false);
	}
	public static function decrypt(data:ByteArray, key:ByteArray):ByteArray {
		if (data.length == 0) {
			return new ByteArray();
		}
		var v:Array = ByteArrayToLongArray(data, false);
		var k:Array = ByteArrayToLongArray(key, false);
		if (k.length < 4) {
			k.length = 4;
		}
		var n:Number = v.length - 1;
		var z:Number = v[n - 1];
		var y:Number = v[0];
		var mx:Number;
		var e:Number;
		var p:Number;
		var q:Number = Math.floor(6 + 52 / (n + 1));
		var sum:Number = q * delta & 0xffffffff;
		while (sum != 0) {
			e = sum >>> 2 & 3;
			for (p = n; p > 0; p--) {
				z = v[p - 1];
				mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
				y = v[p] = v[p] - mx & 0xffffffff;
			}
			z = v[n];
			mx = (z >>> 5 ^ y << 2) + (y >>> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z);
			y = v[0] = v[0] - mx & 0xffffffff;
			sum = sum - delta & 0xffffffff;
		}
		return LongArrayToByteArray(v, true);
	}
}
