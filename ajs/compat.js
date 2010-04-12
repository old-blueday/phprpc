/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| compat.js                                                |
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

/* Provides missing functionality for older versions of JScript.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

if (typeof(encodeURIComponent) == "undefined") {
    encodeURIComponent = function() {
        var URIEncodeTable = "%00|%01|%02|%03|%04|%05|%06|%07|%08|%09|%0A|%0B|%0C|%0D|%0E|%0F|%10|%11|%12|%13|%14|%15|%16|%17|%18|%19|%1A|%1B|%1C|%1D|%1E|%1F|%20|!|%22|%23|%24|%25|%26|'|(|)|*|%2B|%2C|-|.|%2F|0|1|2|3|4|5|6|7|8|9|%3A|%3B|%3C|%3D|%3E|%3F|%40|A|B|C|D|E|F|G|H|I|J|K|L|M|N|O|P|Q|R|S|T|U|V|W|X|Y|Z|%5B|%5C|%5D|%5E|_|%60|a|b|c|d|e|f|g|h|i|j|k|l|m|n|o|p|q|r|s|t|u|v|w|x|y|z|%7B|%7C|%7D|~|%7F".split('|');
        return function(str) {
            var out, i, j, len, c, c2;

            out = [];
            len = str.length;
            for(i = 0, j = 0; i < len; i++) {
                c = str.charCodeAt(i);
                if (c <= 0x007F) {
                    out[j++] = URIEncodeTable[c];
                    continue;
                }
                else if (c <= 0x7FF) {
                    out[j++] = '%' + (0xC0 | ((c >>  6) & 0x1F)).toString(16).toUpperCase();
                    out[j++] = '%' + (0x80 | (        c & 0x3F)).toString(16).toUpperCase();
                    continue;
                }
                else if (c < 0xD800 || c > 0xDFFF) {
                    out[j++] = '%' + (0xE0 | ((c >> 12) & 0x0F)).toString(16).toUpperCase();
                    out[j++] = '%' + (0x80 | ((c >>  6) & 0x3F)).toString(16).toUpperCase();
                    out[j++] = '%' + (0x80 |         (c & 0x3F)).toString(16).toUpperCase();
                    continue;
                }
                else {
                    if (++i < len) {
                        c2 = str.charCodeAt(i);
                        if (c <= 0xDBFF && 0xDC00 <= c2 && c2 <= 0xDFFF) {
                            c = ((c & 0x03FF) << 10 | (c2 & 0x03FF)) + 0x010000;
                            if (0x010000 <= c && c <= 0x10FFFF) {
                                out[j++] = '%' + (0xF0 | ((c >>> 18) & 0x3F)).toString(16).toUpperCase();
                                out[j++] = '%' + (0x80 | ((c >>> 12) & 0x3F)).toString(16).toUpperCase();
                                out[j++] = '%' + (0x80 | ((c >>>  6) & 0x3F)).toString(16).toUpperCase();
                                out[j++] = '%' + (0x80 |          (c & 0x3F)).toString(16).toUpperCase();
                                continue;
                            }
                        }
                    }
                }
                var e = new Error(-2146823264, "The URI to be encoded contains an invalid character");
                e.name = "URIError";
                e.message = e.description;
                throw e;
            }
            return out.join('');
        }
    }();
}

if (typeof(decodeURIComponent) == "undefined") {
    decodeURIComponent = function(str) {
        var out, i, j, len, c, d1, d2;
        out = [];
        len = str.length;
        i = j = 0;
        while(i < len) {
            c = str.charAt(i++);
            if (c == "%") {
                d1 = str.charAt(i++);
                d2 = str.charAt(i++);
                if (isNaN(parseInt(d1, 16)) || isNaN(parseInt(d2, 16))) {
                    var e = new Error(-2146823263, "The URI to be decoded is not a valid encoding");
                    e.name = "URIError";
                    e.message = e.description;
                    throw e;
                }
                out[j++] = String.fromCharCode(parseInt(d1 + d2, 16));
            }
            else {
                out[j++] = c;
            }
        }
        return out.join('').toUTF16();
    }
}

if (typeof(Array.prototype.push) == "undefined") {
    Array.prototype.push = function() {
        var curlen = this.length;
        for (var i = 0; i < arguments.length; i++) {
            this[curlen + i] = arguments[i];
        }
        return this.length;
    }
}

if (typeof(Array.prototype.shift) == "undefined") {
    Array.prototype.shift = function() {
        var returnValue = this[0];
        for (var i = 1; i < this.length; i++) {
            this[i - 1] = this[i];
        }
        this.length--;
        return returnValue;
    }
}