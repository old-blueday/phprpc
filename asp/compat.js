/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| compat.js                                                |
|                                                          |
| Release 3.0.1                                            |
| Copyright: by Team-PHPRPC                                |
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

/* Provides some VBScript helper codes.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Jun 30, 2007
 * This library is free.  You can redistribute it and/or modify it.
 */

function IsDictionary(o) {
    return ((o != null) &&
    (typeof(o) == "object") &&
    (o instanceof ActiveXObject) &&
    (typeof(o.Add) == "unknown") &&
    (typeof(o.Exists) == "unknown") &&
    (typeof(o.Items) == "unknown") &&
    (typeof(o.Keys) == "unknown") &&
    (typeof(o.Remove) == "unknown") &&
    (typeof(o.RemoveAll) == "unknown") &&
    (typeof(o.Count) == "number") &&
    (typeof(o.Item) == "unknown") &&
    (typeof(o.Key) == "unknown"));
}

function IsVBArray(o) {
    return ((o != null) &&
    (typeof(o) == "unknown") &&
    (o.constructor == VBArray) &&
    (typeof(o.dimensions) == "function") &&
    (typeof(o.getItem) == "function") &&
    (typeof(o.lbound) == "function") &&
    (typeof(o.toArray) == "function") &&
    (typeof(o.ubound) == "function"));
}

function DictionaryToObject(dict) {
    var array, i, result;
    array = (new VBArray(dict.Keys())).toArray();
    result = {};
    for (i in array) {
        if (IsDictionary(dict(array[i]))) {
            result[array[i]] = DictionaryToObject(dict(array[i]));
        }
        else if (IsVBArray(dict(array[i]))) {
            result[array[i]] = VBArrayToJSArray(dict(array[i]));
        }
        else {
            result[array[i]] = dict(array[i]);
        }
     }
     return result;
}

function ObjectToDictionary(object) {
    var key, result;
    result = new ActiveXObject("Scripting.Dictionary");
    for (key in object) {
        result.Add(key, object[key]);
    }
    return result;
}

function VBArrayToJSArray(vbArray) {
    function toJSArray(vbarray, dimension, indices) {
        var rank = vbarray.dimensions();
        if (rank > dimension) {
            indices[dimension] = 0;
            dimension++;
        }
        var lb = vbarray.lbound(dimension);
        var ub = vbarray.ubound(dimension);
        var jsarray = [];
        for (var i = lb; i <= ub; i++) {
            indices[dimension - 1] = i;
            if (rank == dimension) {
                jsarray[i] = vbarray.getItem.apply(vbarray, indices);
            }
            else {
                jsarray[i] = toJSArray(vbarray, dimension, indices);
            }
        }
        return jsarray;
    }

    var vbarray = new VBArray(vbArray);
    if (vbarray.dimensions() == 1 && vbarray.lbound() == 0) {
        return vbarray.toArray();
    }
    return toJSArray(vbarray, 0, []);
}

function JSArrayToVBArray(jsarray) {
    return ObjectToDictionary(jsarray).Items();
}