/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| ByteArray.as                                             |
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
/* ByteArray for ActionScript 2.0.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 1.0
 * LastModified: Jan 14, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */
dynamic class org.phprpc.util.ByteArray extends Array {
	public var position:Number = 0;
	public function readByte():Number {
		return this[this.position++];
	}
	public function readBytes(bytes:ByteArray, offset:Number, length:Number):Void {
		if (offset == undefined) {
			offset = 0;
		}
		if (length == undefined || length == 0) {
			length = this.length - this.position;
		}
		var endOffset = offset + length;
		for (var i:Number = offset; i < endOffset; i++) {
			bytes[i] = this[this.position++];
		}
	}
	public function readASCIIBytes(length:Number):String {
		var result:Array = [];
		for (var i:Number = 0; i < length; i++) {
			result[i] = String.fromCharCode(this[this.position++]);
		}
		return result.join("");
	}
	public function readUTFBytes(length:Number):String {
		var result:String = readUTF8Bytes(this.position, length);
		this.position += length;
		return result;
	}
	private function readUTF8Bytes(position:Number, length:Number):String {
		var out:Array = [];
		var i:Number = 0;
		var c:Number;
		var c2:Number;
		var c3:Number;
		var c4:Number;
		var s:Number;
		var lastOffset = position + length;
		while (position < lastOffset) {
			c = this[position++];
			switch (c >> 4) {
			case 0 :
			case 1 :
			case 2 :
			case 3 :
			case 4 :
			case 5 :
			case 6 :
			case 7 :
				// 0xxx xxxx
				out[i++] = String.fromCharCode(c);
				break;
			case 12 :
			case 13 :
				// 110x xxxx   10xx xxxx
				c2 = this[position++];
				out[i++] = String.fromCharCode(((c & 0x1f) << 6) | (c2 & 0x3f));
				break;
			case 14 :
				// 1110 xxxx  10xx xxxx  10xx xxxx
				c2 = this[position++];
				c3 = this[position++];
				out[i++] = String.fromCharCode(((c & 0x0f) << 12) | ((c2 & 0x3f) << 6) | (c3 & 0x3f));
				break;
			case 15 :
				switch (c & 0xf) {
				case 0 :
				case 1 :
				case 2 :
				case 3 :
				case 4 :
				case 5 :
				case 6 :
				case 7 :
					// 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
					c2 = this[position++];
					c3 = this[position++];
					c4 = this[position++];
					s = ((c & 0x07) << 18) | ((c2 & 0x3f) << 12) | ((c3 & 0x3f) << 6) | (c4 & 0x3f) - 0x10000;
					if (0 <= s && s <= 0xfffff) {
						out[i++] = String.fromCharCode(((s >>> 10) & 0x03ff) | 0xd800, (s & 0x03ff) | 0xdc00);
					}
					else {
						out[i++] = '?';
					}
					break;
				case 8 :
				case 9 :
				case 10 :
				case 11 :
					// 1111 10xx  10xx xxxx  10xx xxxx  10xx xxxx  10xx xxxx
					position += 4;
					out[i++] = '?';
					break;
				case 12 :
				case 13 :
					// 1111 110x  10xx xxxx  10xx xxxx  10xx xxxx  10xx xxxx  10xx xxxx
					position += 5;
					out[i++] = '?';
					break;
				}
			}
		}
		return out.join("");
	}
	public function toString():String {
		return readUTF8Bytes(0, this.length);
	}
	public function writeByte(value:Number):Void {
		this[this.position++] = value & 0xff;
	}
	public function writeBytes(bytes:ByteArray, offset:Number, length:Number):Void {
		if (offset == undefined || offset < 0 || offset >= bytes.length) {
			offset = 0;
		}
		var endOffset;
		if (length == undefined || length == 0) {
			endOffset = bytes.length;
		}
		else {
			endOffset = offset + length;
			if (endOffset < 0 || endOffset > bytes.length) {
				endOffset = bytes.length;
			}
		}
		for (var i:Number = offset; i < endOffset; i++) {
			this[this.position++] = bytes[i];
		}
	}
	public function writeASCIIBytes(value:String):Void {
		var length:Number = value.length;
		for (var i:Number = 0; i < length; i++) {
			this[this.position++] = value.charCodeAt(i) & 0xff;
		}
	}
	public function writeUTFBytes(value:String):Void {
		var i:Number;
		var length:Number;
		var c:Number;
		var c2:Number;
		length = value.length;
		for (i = 0; i < length; i++) {
			c = value.charCodeAt(i);
			if (c <= 0x7f) {
				this[this.position++] = c;
			}
			else if (c <= 0x7ff) {
				this[this.position++] = 0xc0 | (c >>> 6);
				this[this.position++] = 0x80 | (c & 0x3f);
			}
			else if (c < 0xd800 || c > 0xdfff) {
				this[this.position++] = 0xe0 | (c >>> 12);
				this[this.position++] = 0x80 | ((c >>> 6) & 0x3f);
				this[this.position++] = 0x80 | (c & 0x3f);
			}
			else {
				if (++i < len) {
					c2 = value.charCodeAt(i);
					if (c <= 0xdbff && 0xdc00 <= c2 && c2 <= 0xdfff) {
						c = ((c & 0x03ff) << 10 | (c2 & 0x03ff)) + 0x010000;
						if (0x010000 <= c && c <= 0x10ffff) {
							this[this.position++] = 0xf0 | ((c >>> 18) & 0x3f);
							this[this.position++] = 0x80 | ((c >>> 12) & 0x3f);
							this[this.position++] = 0x80 | ((c >>> 6) & 0x3f);
							this[this.position++] = 0x80 | (c & 0x3f);
						}
						else {
							this[this.position++] = 0x3f;  // '?'
						}
					}
					else {
						i--;
						this[this.position++] = 0x3f;  // '?'
					}
				}
				else {
					i--;
					this[this.position++] = 0x3f;  // '?'
				}
			}
		}
	}
}
