/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| BigInteger.as                                            |
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
/* PowMod BigInteger library.
 *
 * Copyright: Alexander Valyalkin <valyala@tut.by>
 *            Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.3
 * LastModified: Jan 14, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */
import org.phprpc.util.ByteArray;
class org.phprpc.util.BigInteger {
	private static var lowBitMasks:Array = new Array(0x0000, 0x0001, 0x0003, 0x0007, 0x000f, 0x001f, 0x003f, 0x007f, 0x00ff, 0x01ff, 0x03ff, 0x07ff, 0x0fff, 0x1fff, 0x3fff, 0x7fff);
	// result = a * b
	public static function mul(a:Array, b:Array):Array {
		var n:Number = a.length;
		var m:Number = b.length;
		var nm:Number = n + m;
		var i:Number;
		var j:Number;
		var c:Array = Array(nm);
		for (i = 0; i < nm; i++) {
			c[i] = 0;
		}
		for (i = 0; i < n; i++) {
			for (j = 0; j < m; j++) {
				c[i + j] += a[i] * b[j];
				c[i + j + 1] += (c[i + j] >> 16) & 0xffff;
				c[i + j] &= 0xffff;
			}
		}
		return c;
	}
	// isMod = false, result = a / b
	// isMod = true, result = a mod b
	public static function div(a:Array, b:Array, isMod:Boolean) {
		var n:Number = a.length;
		var m:Number = b.length;
		var d:Number = Math.floor(0x10000 / (b[m - 1] + 1));
		var i:Number;
		var j:Number;
		var tmp:Number;
		var qq:Number;
		var rr:Number;
		var c:Array = Array();
		a = mul(a, [d]);
		b = mul(b, [d]);
		for (j = n - m; j >= 0; j--) {
			tmp = a[j + m] * 0x10000 + a[j + m - 1];
			rr = tmp % b[m - 1];
			qq = Math.round((tmp - rr) / b[m - 1]);
			if (qq == 0x10000 || (m > 1 && qq * b[m - 2] > 0x10000 * rr + a[j + m - 2])) {
				qq--;
				rr += b[m - 1];
				if (rr < 0x10000 && qq * b[m - 2] > 0x10000 * rr + a[j + m - 2]) {
					qq--;
				}
			}
			for (i = 0; i < m; i++) {
				tmp = i + j;
				a[tmp] -= b[i] * qq;
				a[tmp + 1] += Math.floor(a[tmp] / 0x10000);
				a[tmp] &= 0xffff;
			}
			c[j] = qq;
			if (a[tmp + 1] < 0) {
				c[j]--;
				for (i = 0; i < m; i++) {
					tmp = i + j;
					a[tmp] += b[i];
					if (a[tmp] > 0xffff) {
						a[tmp + 1]++;
						a[tmp] &= 0xffff;
					}
				}
			}
		}
		if (!isMod) {
			return c;
		}
		b = Array();
		for (i = 0; i < m; i++) {
			b[i] = a[i];
		}
		return div(b, [d]);
	}
	// result = a^b mod c
	public static function powmod(a:Array, b:Array, c:Array):Array {
		var n:Number = b.length;
		var p:Array = [1];
		var i:Number;
		var j:Number;
		var tmp:Number;
		for (i = 0; i < n - 1; i++) {
			tmp = b[i];
			for (j = 0; j < 0x10; j++) {
				if (tmp & 1) {
					p = div(mul(p, a), c, true);
				}
				tmp >>= 1;
				a = div(mul(a, a), c, true);
			}
		}
		tmp = b[i];
		while (tmp) {
			if (tmp & 1) {
				p = div(mul(p, a), c, true);
			}
			tmp >>= 1;
			a = div(mul(a, a), c, true);
		}
		return p;
	}
	// PadLefts with 0
	private static function zerofill(str:String, num:Number):String {
		var n:Number = num - str.toString().length;
		var i:Number;
		var s:String = '';
		for (i = 0; i < n; i++) {
			s += '0';
		}
		return s + str;
	}
	// Converts decimal string to BigInteger number.
	public static function dec2num(str:String):Array {
		var n:Number = str.length;
		var a:Array = [0];
		var i:Number;
		var j:Number;
		var m:Number;
		n += 4 - (n % 4);
		str = zerofill(str, n);
		n >>= 2;
		for (i = 0; i < n; i++) {
			a = mul(a, [10000]);
			a[0] += parseInt(str.substr(i << 2, 4), 10);
			m = a.length;
			j = 0;
			a[m] = 0;
			while (j < m && a[j] > 0xffff) {
				a[j] &= 0xffff;
				j++;
				a[j]++;
			}
			while (a.length > 1 && !a[a.length - 1]) {
				a.length--;
			}
		}
		return a;
	}
	// Converts BigInteger number to decimal string.
	public static function num2dec(a:Array):String {
		var n:Number = a.length << 1;
		var b:Array = Array();
		var i:Number;
		for (i = 0; i < n; i++) {
			b[i] = zerofill(div(a, [10000], true)[0], 4);
			a = div(a, [10000], false);
		}
		while (b.length > 1 && !parseInt(b[b.length - 1], 10)) {
			b.length--;
		}
		n = b.length - 1;
		b[n] = parseInt(b[n], 10);
		b.reverse();
		return b.join('');
	}
	/*************************************************************/
	// Converts binary to BigInteger number.
	public static function bin2num(bin:ByteArray):Array {
		var len:Number = bin.length;
		if (len & 1) {
			bin.unshift(0);
			len++;
		}
		len >>= 1;
		var result:Array = Array();
		for (var i:Number = 0; i < len; i++) {
			result[len - i - 1] = bin[i << 1] << 8 | bin[(i << 1) + 1];
		}
		return result;
	}
	// Converts BigInteger number to binary.
	public static function num2bin(num:Array):ByteArray {
		var n:Number = num.length;
		var len:Number = n << 1;
		var result:ByteArray = new ByteArray();
		for (var i:Number = n - 1; i >= 0; i--) {
			result.writeByte(num[i] >> 8);
			result.writeByte(num[i]);
		}
		return result;
	}
	// Generates n-bit Random Number, if s = true, sets bit number n - 1.
	public static function rand(n:Number, s:Boolean):Array {
		var r:Number = n % 16;
		var q:Number = n >> 4;
		var result:Array = Array();
		for (var i:Number = 0; i < q; i++) {
			result[i] = Math.floor(Math.random() * 0xffff);
		}
		if (r != 0) {
			result[q] = Math.floor(Math.random() * lowBitMasks[r]);
			if (s) {
				result[q] |= 1 << (r - 1);
			}
		}
		else if (s) {
			result[q - 1] |= 0x8000;
		}
		return result;
	}
}
