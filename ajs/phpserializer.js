/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| phpserializer.js                                         |
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

/* PHP serialize/unserialize library.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 4.2
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

var PHPSerializer = (function () {

    function freeEval(s) {
        return eval(s);
    }
    var prototypePropertyOfArray = function() {
        var result = {};
        for (var p in []) {
            result[p] = true;
        }
        return result;
    }();
    var prototypePropertyOfObject = function() {
        var result = {};
        for (var p in {}) {
            result[p] = true;
        }
        return result;
    }();

    return {
        serialize : function(o) {
            var p = 0, sb = [], ht = [], hv = 1;
            function getClassName(o) {
                if (typeof(o) == 'undefined' || typeof(o.constructor) == 'undefined') return '';
                var c = o.constructor.toString();
                c = c.substr(0, c.indexOf('(')).replace(/(^\s*function\s*)|(\s*$)/ig, '').toUTF8();
                return ((c == '') ? 'Object' : c);
            }
            function isInteger(n) {
                var i, s = n.toString(), l = s.length;
                if (l > 11) return false;
                for (i = (s.charAt(0) == '-') ? 1 : 0; i < l; i++) {
                    switch (s.charAt(i)) {
                        case '0':
                        case '1':
                        case '2':
                        case '3':
                        case '4':
                        case '5':
                        case '6':
                        case '7':
                        case '8':
                        case '9': break;
                        default : return false;
                    }
                }
                return !(n < -2147483648 || n > 2147483647);
            }
            function inHashTable(o) {
                for (var i = 0; i < ht.length; i++) if (ht[i] === o) return i;
                return false;
            }
            function serializeNull() {
                sb[p++] = 'N;';
            }
            function serializeBoolean(b) {
                sb[p++] = (b ? 'b:1;' : 'b:0;');
            }
            function serializeInteger(i) {
                sb[p++] = 'i:' + i + ';';
            }
            function serializeDouble(d) {
                if (isNaN(d)) d = 'NAN';
                else if (d == Number.POSITIVE_INFINITY) d = 'INF';
                else if (d == Number.NEGATIVE_INFINITY) d = '-INF';
                sb[p++] = 'd:' + d + ';';
            }
            function serializeString(s) {
                var utf8 = s.toUTF8();
                sb[p++] = 's:' + utf8.length + ':"';
                sb[p++] = utf8;
                sb[p++] = '";';
            }
            function serializeDate(dt) {
                sb[p++] = 'O:11:"PHPRPC_Date":7:{';
                sb[p++] = 's:4:"year";';
                serializeInteger(dt.getFullYear());
                sb[p++] = 's:5:"month";';
                serializeInteger(dt.getMonth() + 1);
                sb[p++] = 's:3:"day";';
                serializeInteger(dt.getDate());
                sb[p++] = 's:4:"hour";';
                serializeInteger(dt.getHours());
                sb[p++] = 's:6:"minute";';
                serializeInteger(dt.getMinutes());
                sb[p++] = 's:6:"second";';
                serializeInteger(dt.getSeconds());
                sb[p++] = 's:11:"millisecond";';
                serializeInteger(dt.getMilliseconds());
                sb[p++] = '}';
            }
            function serializeArray(a) {
                sb[p++] = 'a:';
                var k, lp = p;
                sb[p++] = 0;
                sb[p++] = ':{';
                for (k in a) {
                    if ((typeof(a[k]) != 'function') && !prototypePropertyOfArray[k]) {
                        isInteger(k) ? serializeInteger(k) : serializeString(k);
                        serialize(a[k]);
                        sb[lp]++;
                    }
                }
                sb[p++] = '}';
            }
            function serializeObject(o) {
                var cn = getClassName(o);
                if (cn == '') serializeNull();
                else if (typeof(o.serialize) != 'function') {
                    sb[p++] = 'O:' + cn.length + ':"' + cn + '":';
                    var lp = p;
                    sb[p++] = 0;
                    sb[p++] = ':{';
                    var k;
                    if (typeof(o.__sleep) == 'function') {
                        var a = o.__sleep();
                        for (k in a) {
                            serializeString(a[k]);
                            serialize(o[a[k]]);
                            sb[lp]++;
                        }
                    }
                    else {
                        for (k in o) {
                            if (typeof(o[k]) != 'function' && !prototypePropertyOfObject[k]) {
                                serializeString(k);
                                serialize(o[k]);
                                sb[lp]++;
                            }
                        }
                    }
                    sb[p++] = '}';
                }
                else {
                    var cs = o.serialize();
                    sb[p++] = 'C:' + cn.length + ':"' + cn + '":' + cs.length + ':{' +cs + '}';
                }
            }
            function serializePointRef(R) {
                sb[p++] = 'R:' + R + ';';
            }
            function serializeRef(r) {
                sb[p++] = 'r:' + r + ';';
            }
            function serialize(o) {
                if (typeof(o) == "undefined" || o == null ||
                    o.constructor == Function) {
                    hv++;
                    serializeNull();
                    return;
                }
                var className = getClassName(o);
                switch (o.constructor) {
                    case Boolean: {
                        hv++;
                        serializeBoolean(o);
                        break;
                    }
                    case Number: {
                        hv++;
                        isInteger(o) ? serializeInteger(o) : serializeDouble(o);
                        break;
                    }
                    case String: {
                        hv++;
                        serializeString(o);
                        break;
                    }
                    case Date: {
                        hv += 8;
                        serializeDate(o);
                        break;
                    }
                    default: {
                        if (className == "Object" || o.constructor == Array) {
                            var r = inHashTable(o);
                            if (r) {
                                serializePointRef(r);
                            }
                            else {
                                ht[hv++] = o;
                                serializeArray(o);
                            }
                            break;
                        }
                        else {
                            var r = inHashTable(o);
                            if (r) {
                                hv++;
                                serializeRef(r);
                            }
                            else {
                                ht[hv++] = o;
                                serializeObject(o);
                            }
                        }
                    }
                }
            }
            serialize(o);
            return sb.join('');
        },
        unserialize : function(ss) {
            var p = 0, ht = [], hv = 1;
            function unserializeNull() {
                p++;
                return null;
            }
            function unserializeBoolean() {
                p++;
                var b = (ss.charAt(p++) == '1');
                p++;
                return b;
            }
            function unserializeInteger() {
                p++;
                var i = parseInt(ss.substring(p, p = ss.indexOf(';', p)));
                p++;
                return i;
            }
            function unserializeDouble() {
                p++;
                var d = ss.substring(p, p = ss.indexOf(';', p));
                switch (d) {
                    case 'NAN': d = NaN; break;
                    case 'INF': d = Number.POSITIVE_INFINITY; break;
                    case '-INF': d = Number.NEGATIVE_INFINITY; break;
                    default: d = parseFloat(d);
                }
                p++;
                return d;
            }
            function unserializeString() {
                p++;
                var l = parseInt(ss.substring(p, p = ss.indexOf(':', p)));
                p += 2;
                var s = ss.substring(p, p += l).toUTF16();
                p += 2;
                return s;
            }
            function unserializeEscapedString(len) {
                p++;
                var l = parseInt(ss.substring(p, p = ss.indexOf(':', p)));
                p += 2;
                var i, sb = new Array(l);
                for (i = 0; i < l; i++) {
                    if ((sb[i] = ss.charAt(p++)) == '\\') {
                        sb[i] = String.fromCharCode(parseInt(ss.substring(p, p += len), 16));
                    }
                }
                p += 2;
                return sb.join('');
            }
            function unserializeArray() {
                p++;
                var n = parseInt(ss.substring(p, p = ss.indexOf(':', p)));
                p += 2;
                var i, k, a = [];
                ht[hv++] = a;
                for (i = 0; i < n; i++) {
                    switch (ss.charAt(p++)) {
                        case 'i': k = unserializeInteger(); break;
                        case 's': k = unserializeString(); break;
                        case 'S': k = unserializeEscapedString(2); break;
                        case 'U': k = unserializeEscapedString(4); break;
                        default: return false;
                    }
                    a[k] = unserialize();
                }
                p++;
                return a;
            }
            function unserializeDate(n) {
                var i, k, a = {};
                for (i = 0; i < n; i++) {
                    switch (ss.charAt(p++)) {
                        case 's': k = unserializeString(); break;
                        case 'S': k = unserializeEscapedString(2); break;
                        case 'U': k = unserializeEscapedString(4); break;
                        default: return false;
                    }
                    if (ss.charAt(p++) == 'i') {
                        a[k] = unserializeInteger();
                    }
                    else {
                        return false;
                    }
                }
                p++;
                var dt = new Date(
                    a.year,
                    a.month - 1,
                    a.day,
                    a.hour,
                    a.minute,
                    a.second,
                    a.millisecond
                );
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
            function unserializeObject() {
                p++;
                var l = parseInt(ss.substring(p, p = ss.indexOf(':', p)));
                p += 2;
                var cn = ss.substring(p, p += l).toUTF16();
                p += 2;
                var n = parseInt(ss.substring(p, p = ss.indexOf(':', p)));
                p += 2;
                if (cn == "PHPRPC_Date") {
                    return unserializeDate(n);
                }
                var i, k, o = createObjectOfClass(cn);
                ht[hv++] = o;
                for (i = 0; i < n; i++) {
                    switch (ss.charAt(p++)) {
                        case 's': k = unserializeString(); break;
                        case 'S': k = unserializeEscapedString(2); break;
                        case 'U': k = unserializeEscapedString(4); break;
                        default: return false;
                    }
                    if (k.charAt(0) == '\0') {
                        k = k.substring(k.indexOf('\0', 1) + 1, k.length);
                    }
                    o[k] = unserialize();
                }
                p++;
                if (typeof(o.__wakeup) == 'function') o.__wakeup();
                return o;
            }
            function unserializeCustomObject() {
                p++;
                var l = parseInt(ss.substring(p, p = ss.indexOf(':', p)));
                p += 2;
                var cn = ss.substring(p, p += l).toUTF16();
                p += 2;
                var n = parseInt(ss.substring(p, p = ss.indexOf(':', p)));
                p += 2;
                var o = createObjectOfClass(cn);
                ht[hv++] = o;
                if (typeof(o.unserialize) != 'function') p += n;
                else o.unserialize(ss.substring(p, p += n));
                p++;
                return o;
            }
            function unserializeRef() {
                p++;
                var r = parseInt(ss.substring(p, p = ss.indexOf(';', p)));
                p++;
                return ht[r];
            }
            function getObjectOfClass(cn, poslist, i, c) {
                if (i < poslist.length) {
                    var pos = poslist[i];
                    cn[pos] = c;
                    var obj = getObjectOfClass(cn, poslist, i + 1, '.');
                    if (i + 1 < poslist.length) {
                        if (obj == null) {
                            obj = getObjectOfClass(cn, poslist, i + 1, '_');
                        }
                    }
                    return obj;
                }
                var classname = cn.join('');
                try {
                    return freeEval('new ' + classname + '()');
                }
                catch (e) {
                    return null;
                }
            }
            function createObjectOfClass(classname) {
                if (freeEval('typeof(' + classname + ') == "function"')) {
                    return freeEval('new ' + classname + '()');
                }
                var poslist = [];
                var pos = classname.indexOf("_");
                while (pos > -1) {
                    poslist[poslist.length] = pos;
                    pos = classname.indexOf("_", pos + 1);
                }
                if (poslist.length > 0) {
                    var cn = classname.split('');
                    var obj = getObjectOfClass(cn, poslist, 0, '.');
                    if (obj == null) {
                        obj = getObjectOfClass(cn, poslist, 0, '_');
                    }
                    if (obj != null) {
                        return obj;
                    }
                }
                return freeEval('new function ' + classname + '(){};');
            }
            function unserialize() {
                switch (ss.charAt(p++)) {
                    case 'N': return ht[hv++] = unserializeNull();
                    case 'b': return ht[hv++] = unserializeBoolean();
                    case 'i': return ht[hv++] = unserializeInteger();
                    case 'd': return ht[hv++] = unserializeDouble();
                    case 's': return ht[hv++] = unserializeString();
                    case 'S': return ht[hv++] = unserializeEscapedString(2);
                    case 'U': return ht[hv++] = unserializeEscapedString(4);
                    case 'r': return ht[hv++] = unserializeRef();
                    case 'a': return unserializeArray();
                    case 'O': return unserializeObject();
                    case 'C': return unserializeCustomObject();
                    case 'R': return unserializeRef();
                    default: return false;
                }
            }
            return unserialize();
        }
    }
})();