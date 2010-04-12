/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| bigint.js                                                |
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

/* PowMod BigInteger library.
 *
 * Copyright: Alexander Valyalkin <valyala@tut.by>
 *            Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.2
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

var BigInteger = new function() {
    // result = a * b
    function mul(a, b) {
        var n = a.length, m = b.length, nm = n + m, i, j, c = Array(nm);
        for (i = 0; i < nm; i++) c[i] = 0;
        for (i = 0; i < n; i++) {
            for (j = 0; j < m; j++) {
                c[i + j] += a[i] * b[j];
                c[i + j + 1] += (c[i + j] >> 16) & 0xffff;
                c[i + j] &= 0xffff;
            }
        }
        return c;
    }

    // is_mod = 0, result = a / b
    // is_mod = 1, result = a mod b
    function div(a, b, is_mod) {
        var n = a.length, m = b.length, i, j, d, tmp, qq, rr, c = Array();
        d = Math.floor(0x10000 / (b[m - 1] + 1));
        a = mul(a, [d]);
        b = mul(b, [d]);
        for (j = n - m; j >= 0; j--) {
            tmp = a[j + m] * 0x10000 + a[j + m - 1];
            rr = tmp % b[m - 1];
            qq = Math.round((tmp - rr) / b[m - 1]);
            if (qq == 0x10000 || (m > 1 && qq * b[m - 2] > 0x10000 * rr + a[j + m - 2])) {
                qq--;
                rr += b[m - 1];
                if (rr < 0x10000 && qq * b[m - 2] > 0x10000 * rr + a[j + m - 2]) qq--;
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
        if (!is_mod) return c;
        b = Array();
        for (i = 0; i < m; i++) b[i] = a[i];
        return div(b, [d]);
    }

    // result = a^b mod c
    function powmod(a, b, c) {
        var n = b.length, p = [1], i, j, tmp;
        for (i = 0; i < n - 1; i++) {
            tmp = b[i];
            for (j = 0; j < 0x10; j++) {
                if (tmp & 1) p = div(mul(p, a), c, 1);
                tmp >>= 1;
                a = div(mul(a, a), c, 1);
            }
        }
        tmp = b[i];
        while (tmp) {
            if (tmp & 1) p = div(mul(p, a), c, 1);
            tmp >>= 1;
            a = div(mul(a, a), c, 1);
        }
        return p;
    }

/*************************************************************/

    // PadLefts with 0
    function zerofill(str, num) {
        var n = num - str.toString().length, i, s = '';
        for (i = 0; i < n; i++) s += '0';
        return s + str;
    }

    // Converts decimal string to BigInteger number.
    function dec2num(str) {
        var n = str.length, a = [0], i, j, m;
        n += 4 - (n % 4);
        str = zerofill(str, n);
        n >>= 2;
        for (i = 0; i < n; i++) {
            a = mul(a, [10000]);
            a[0] += parseInt(str.substr(i << 2, 4), 10);
            m = a.length;
            j = a[m] = 0;
            while (j < m && a[j] > 0xffff) {
                a[j] &= 0xffff;
                j++;
                a[j]++;
            }
            while (a.length > 1 && !a[a.length - 1]) a.length--;
        }
        return a;
    }

    // Converts BigInteger number to decimal string.
    function num2dec(a) {
        var n = a.length << 1, b = Array(), i;
        for (i = 0; i < n; i++) {
            b[i] = zerofill(div(a, [10000], 1)[0], 4);
            a = div(a, [10000]);
        }
        while (b.length > 1 && !parseInt(b[b.length - 1], 10)) b.length--;
        n = b.length - 1;
        b[n] = parseInt(b[n], 10);
        b = b.reverse().join('');
        return b;
    }

/*************************************************************/

    // Converts binary string to BigInteger number.
    function str2num(str) {
        var len = str.length;
        if (len & 1) {
            str = "\0" + str;
            len++;
        }
        len >>= 1;
        var result = Array();
        for (var i = 0; i < len; i++) {
            result[len - i - 1] = str.charCodeAt(i << 1) << 8 | str.charCodeAt((i << 1) + 1);
        }
        return result;
    }

    // Converts BigInteger number to binary string.
    function num2str(num) {
        var n = num.length;
        var s = Array();
        for (var i = 0; i < n; i++) {
            s[n - i - 1] = String.fromCharCode(num[i] >> 8 & 0xff, num[i] & 0xff);
        }
        return s.join('');
    }

    // Generates n-bit Random Number, if s = true, sets bit number n - 1.
    function rand(n, s) {
        var lowBitMasks = new Array(0x0000, 0x0001, 0x0003, 0x0007,
                                    0x000f, 0x001f, 0x003f, 0x007f,
                                    0x00ff, 0x01ff, 0x03ff, 0x07ff,
                                    0x0fff, 0x1fff, 0x3fff, 0x7fff);

        var r = n % 16;
        var q = n >> 4;
        var result = Array();
        for (var i = 0; i < q; i++) {
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

    //public methods
    this.mul = mul;
    this.div = div;
    this.powmod = powmod;
    this.dec2num = dec2num;
    this.num2dec = num2dec;
    this.str2num = str2num;
    this.num2str = num2str;
    this.rand = rand;
}