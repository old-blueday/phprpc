/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| MD5.as                                                   |
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
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/
/* A ActionScript 2.0 implementation of MD5, as defined in RFC 1321.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.2
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
import org.phprpc.util.ByteArray;
class org.phprpc.util.MD5 {
	private static function add32(x:Number, y:Number):Number {
		var lsw:Number = (x & 0xFFFF) + (y & 0xFFFF);
		var msw:Number = (x >> 16) + (y >> 16) + (lsw >> 16);
		return (msw << 16) | (lsw & 0xFFFF);
	}
	private static function bitrol(n:Number, c:Number):Number {
		return (n << c) | (n >>> (32 - c));
	}
	private static function cmn(q:Number, a:Number, b:Number, x:Number, s:Number, t:Number):Number {
		return add32(bitrol(add32(add32(a, q), add32(x, t)), s), b);
	}
	private static function ff(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number {
		return cmn((b & c) | ((~b) & d), a, b, x, s, t);
	}
	private static function gg(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number {
		return cmn((b & d) | (c & (~d)), a, b, x, s, t);
	}
	private static function hh(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number {
		return cmn(b ^ c ^ d, a, b, x, s, t);
	}
	private static function ii(a:Number, b:Number, c:Number, d:Number, x:Number, s:Number, t:Number):Number {
		return cmn(c ^ (b | (~d)), a, b, x, s, t);
	}
	private static function pack(b:Array, isHex:Boolean) {
		var l:Number = b.length << 2;
		var s:Array = new Array(l);
		var result:ByteArray = new ByteArray(l);
		var n:Number;
		for (var i:Number = 0; i < l; i++) {
			n = (b[i >> 2] >>> ((i % 4) << 3)) & 255;
			if (isHex) {
				s[i] = (n < 16 ? "0" : "") + n.toString(16);
			}
			else {
				result[i] = n;
			}
		}
		if (isHex) {
			return s.join("");
		}
		else {
			return result;
		}
	}
	private static function unpack(s:String):Array {
		var l:Number = s.length;
		var b:Array = new Array();
		for (var i = 0; i < l; i++) {
			b[i >> 2] |= (s.charCodeAt(i) & 0xff) << ((i % 4) << 3);
		}
		return b;
	}
	public static function hash(string:String, isHex:Boolean) {
		var x:Array = unpack(string);
		var len:Number = string.length << 3;
		x[len >> 5] |= 0x80 << ((len) % 32);
		x[(((len + 64) >>> 9) << 4) + 14] = len;
		var a:Number = 1732584193;
		var b:Number = -271733879;
		var c:Number = -1732584194;
		var d:Number = 271733878;
		len = x.length;
		for (var i:Number = 0; i < len; i += 16) {
			var olda:Number = a;
			var oldb:Number = b;
			var oldc:Number = c;
			var oldd:Number = d;
			a = ff(a, b, c, d, x[i + 0], 7, -680876936);
			d = ff(d, a, b, c, x[i + 1], 12, -389564586);
			c = ff(c, d, a, b, x[i + 2], 17, 606105819);
			b = ff(b, c, d, a, x[i + 3], 22, -1044525330);
			a = ff(a, b, c, d, x[i + 4], 7, -176418897);
			d = ff(d, a, b, c, x[i + 5], 12, 1200080426);
			c = ff(c, d, a, b, x[i + 6], 17, -1473231341);
			b = ff(b, c, d, a, x[i + 7], 22, -45705983);
			a = ff(a, b, c, d, x[i + 8], 7, 1770035416);
			d = ff(d, a, b, c, x[i + 9], 12, -1958414417);
			c = ff(c, d, a, b, x[i + 10], 17, -42063);
			b = ff(b, c, d, a, x[i + 11], 22, -1990404162);
			a = ff(a, b, c, d, x[i + 12], 7, 1804603682);
			d = ff(d, a, b, c, x[i + 13], 12, -40341101);
			c = ff(c, d, a, b, x[i + 14], 17, -1502002290);
			b = ff(b, c, d, a, x[i + 15], 22, 1236535329);
			a = gg(a, b, c, d, x[i + 1], 5, -165796510);
			d = gg(d, a, b, c, x[i + 6], 9, -1069501632);
			c = gg(c, d, a, b, x[i + 11], 14, 643717713);
			b = gg(b, c, d, a, x[i + 0], 20, -373897302);
			a = gg(a, b, c, d, x[i + 5], 5, -701558691);
			d = gg(d, a, b, c, x[i + 10], 9, 38016083);
			c = gg(c, d, a, b, x[i + 15], 14, -660478335);
			b = gg(b, c, d, a, x[i + 4], 20, -405537848);
			a = gg(a, b, c, d, x[i + 9], 5, 568446438);
			d = gg(d, a, b, c, x[i + 14], 9, -1019803690);
			c = gg(c, d, a, b, x[i + 3], 14, -187363961);
			b = gg(b, c, d, a, x[i + 8], 20, 1163531501);
			a = gg(a, b, c, d, x[i + 13], 5, -1444681467);
			d = gg(d, a, b, c, x[i + 2], 9, -51403784);
			c = gg(c, d, a, b, x[i + 7], 14, 1735328473);
			b = gg(b, c, d, a, x[i + 12], 20, -1926607734);
			a = hh(a, b, c, d, x[i + 5], 4, -378558);
			d = hh(d, a, b, c, x[i + 8], 11, -2022574463);
			c = hh(c, d, a, b, x[i + 11], 16, 1839030562);
			b = hh(b, c, d, a, x[i + 14], 23, -35309556);
			a = hh(a, b, c, d, x[i + 1], 4, -1530992060);
			d = hh(d, a, b, c, x[i + 4], 11, 1272893353);
			c = hh(c, d, a, b, x[i + 7], 16, -155497632);
			b = hh(b, c, d, a, x[i + 10], 23, -1094730640);
			a = hh(a, b, c, d, x[i + 13], 4, 681279174);
			d = hh(d, a, b, c, x[i + 0], 11, -358537222);
			c = hh(c, d, a, b, x[i + 3], 16, -722521979);
			b = hh(b, c, d, a, x[i + 6], 23, 76029189);
			a = hh(a, b, c, d, x[i + 9], 4, -640364487);
			d = hh(d, a, b, c, x[i + 12], 11, -421815835);
			c = hh(c, d, a, b, x[i + 15], 16, 530742520);
			b = hh(b, c, d, a, x[i + 2], 23, -995338651);
			a = ii(a, b, c, d, x[i + 0], 6, -198630844);
			d = ii(d, a, b, c, x[i + 7], 10, 1126891415);
			c = ii(c, d, a, b, x[i + 14], 15, -1416354905);
			b = ii(b, c, d, a, x[i + 5], 21, -57434055);
			a = ii(a, b, c, d, x[i + 12], 6, 1700485571);
			d = ii(d, a, b, c, x[i + 3], 10, -1894986606);
			c = ii(c, d, a, b, x[i + 10], 15, -1051523);
			b = ii(b, c, d, a, x[i + 1], 21, -2054922799);
			a = ii(a, b, c, d, x[i + 8], 6, 1873313359);
			d = ii(d, a, b, c, x[i + 15], 10, -30611744);
			c = ii(c, d, a, b, x[i + 6], 15, -1560198380);
			b = ii(b, c, d, a, x[i + 13], 21, 1309151649);
			a = ii(a, b, c, d, x[i + 4], 6, -145523070);
			d = ii(d, a, b, c, x[i + 11], 10, -1120210379);
			c = ii(c, d, a, b, x[i + 2], 15, 718787259);
			b = ii(b, c, d, a, x[i + 9], 21, -343485551);
			a = add32(a, olda);
			b = add32(b, oldb);
			c = add32(c, oldc);
			d = add32(d, oldd);
		}
		return pack([a, b, c, d], isHex);
	}
}
