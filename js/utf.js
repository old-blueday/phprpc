/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| utf.js                                                   |
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

/* UTF-8 <=> UTF-16 convertion library.
 *
/* Copyright: Masanao Izumo <iz@onicos.co.jp>
 *            Ma Bingyao <andot@ujn.edu.cn>
 * Version: 2.4
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

/*
 * Interfaces:
 * var utf8, utf16;
 * utf16 = "我爱中国";
 * utf8 = utf16.toUTF8();
 * utf16 = utf8.toUTF16();
 */

String.prototype.toUTF8 = function() {
    var str = this;
    if (str.match(/^[\x00-\x7f]*$/) != null) {
        return str.toString();
    }
    var out, i, j, len, c, c2;
    out = [];
    len = str.length;
    for (i = 0, j = 0; i < len; i++, j++) {
        c = str.charCodeAt(i);
        if (c <= 0x7f) {
            out[j] = str.charAt(i);
        }
        else if (c <= 0x7ff) {
            out[j] = String.fromCharCode(0xc0 | (c >>> 6),
                                         0x80 | (c & 0x3f));
        }
        else if (c < 0xd800 || c > 0xdfff) {
            out[j] = String.fromCharCode(0xe0 | (c >>> 12),
                                         0x80 | ((c >>> 6) & 0x3f),
                                         0x80 | (c & 0x3f));
        }
        else {
            if (++i < len) {
                c2 = str.charCodeAt(i);
                if (c <= 0xdbff && 0xdc00 <= c2 && c2 <= 0xdfff) {
                    c = ((c & 0x03ff) << 10 | (c2 & 0x03ff)) + 0x010000;
                    if (0x010000 <= c && c <= 0x10ffff) {
                        out[j] = String.fromCharCode(0xf0 | ((c >>> 18) & 0x3f),
                                                     0x80 | ((c >>> 12) & 0x3f),
                                                     0x80 | ((c >>> 6) & 0x3f),
                                                     0x80 | (c & 0x3f));
                    }
                    else {
                       out[j] = '?';
                    }
                }
                else {
                    i--;
                    out[j] = '?';
                }
            }
            else {
                i--;
                out[j] = '?';
            }
        }
    }
    return out.join('');
}

String.prototype.toUTF16 = function() {
    var str = this;
    if ((str.match(/^[\x00-\x7f]*$/) != null) ||
        (str.match(/^[\x00-\xff]*$/) == null)) {
        return str.toString();
    }
    var out, i, j, len, c, c2, c3, c4, s;

    out = [];
    len = str.length;
    i = j = 0;
    while (i < len) {
        c = str.charCodeAt(i++);
        switch (c >> 4) {
            case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
            // 0xxx xxxx
            out[j++] = str.charAt(i - 1);
            break;
            case 12: case 13:
            // 110x xxxx   10xx xxxx
            c2 = str.charCodeAt(i++);
            out[j++] = String.fromCharCode(((c  & 0x1f) << 6) |
                                            (c2 & 0x3f));
            break;
            case 14:
            // 1110 xxxx  10xx xxxx  10xx xxxx
            c2 = str.charCodeAt(i++);
            c3 = str.charCodeAt(i++);
            out[j++] = String.fromCharCode(((c  & 0x0f) << 12) |
                                           ((c2 & 0x3f) <<  6) |
                                            (c3 & 0x3f));
            break;
            case 15:
            switch (c & 0xf) {
                case 0: case 1: case 2: case 3: case 4: case 5: case 6: case 7:
                // 1111 0xxx  10xx xxxx  10xx xxxx  10xx xxxx
                c2 = str.charCodeAt(i++);
                c3 = str.charCodeAt(i++);
                c4 = str.charCodeAt(i++);
                s = ((c  & 0x07) << 18) |
                    ((c2 & 0x3f) << 12) |
                    ((c3 & 0x3f) <<  6) |
                     (c4 & 0x3f) - 0x10000;
                if (0 <= s && s <= 0xfffff) {
                    out[j++] = String.fromCharCode(((s >>> 10) & 0x03ff) | 0xd800,
                                                  (s         & 0x03ff) | 0xdc00);
                }
                else {
                    out[j++] = '?';
                }
                break;
                case 8: case 9: case 10: case 11:
                // 1111 10xx  10xx xxxx  10xx xxxx  10xx xxxx  10xx xxxx
                i+=4;
                out[j++] = '?';
                break;
                case 12: case 13:
                // 1111 110x  10xx xxxx  10xx xxxx  10xx xxxx  10xx xxxx  10xx xxxx
                i+=5;
                out[j++] = '?';
                break;
            }
        }
    }
    return out.join('');
}