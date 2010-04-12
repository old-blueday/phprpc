/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| flashrequest.js                                          |
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

/* GET and POST data to HTTP Server (using Flash)
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

/*
 * Interfaces:
 * FlashRequest.post(url, data, username, password, callback);
 */

/* public class FlashRequest
 * static encapsulation environment for FlashRequest
 */

var FlashRequest = (function() {
    // static private members

    /*
     * to save Flash Request
     */
    var s_request = null;

    /*
     * to save all request callback functions
     */
    var s_callbackList = [];

    /*
     * to save FlashRequest tasks.
     */
    var s_jsTaskQueue = [];
    var s_swfTaskQueue = [];

    /*
     * to save js & swf status.
     */
    var s_jsReady = false;
    var s_swfReady = false;

    function get(url, data, username, password, callbackid) {
        if (s_swfReady) {
            s_request.get(url, data, username, password, callbackid);
        }
        else {
            var task = function() {
                s_request.get(url, data, username, password, callbackid);
            };
            s_swfTaskQueue.push(task);
        }
    }

    function post(url, data, username, password, callbackid) {
        if (s_swfReady) {
            s_request.post(url, data, username, password, callbackid);
        }
        else {
            var task = function() {
                s_request.post(url, data, username, password, callbackid);
            };
            s_swfTaskQueue.push(task);
        }
    }

    var FlashRequest = {};

    FlashRequest.get = function (url, data, username, password, callback) {
        var callbackid = -1;
        if (callback) {
            callbackid = s_callbackList.length;
            s_callbackList[callbackid] = callback;
        }
        if (s_jsReady) {
            get(url, data, username, password, callbackid);
        }
        else {
            var task = function() {
                get(url, data, username, password, callbackid);
            };
            s_jsTaskQueue.push(task);
        }
    }

    FlashRequest.post = function (url, data, username, password, callback) {
        var callbackid = -1;
        if (callback) {
            callbackid = s_callbackList.length;
            s_callbackList[callbackid] = callback;
        }
        if (s_jsReady) {
            post(url, data, username, password, callbackid);
        }
        else {
            var task = function() {
                post(url, data, username, password, callbackid);
            };
            s_jsTaskQueue.push(task);
        }
    }

    FlashRequest.__callback = function(callbackid, data) {
        if (typeof(s_callbackList[callbackid]) == 'function') {
            s_callbackList[callbackid](data);
        }
        delete s_callbackList[callbackid];
    }

    FlashRequest.__jsReady = function () {
        return s_jsReady;
    }

    FlashRequest.__setJsReady = function () {
        var id = 'flashrequest_as3';
        s_request = window[id] || document[id];
        while (s_jsTaskQueue.length > 0) {
            var task = s_jsTaskQueue.shift();
            if (typeof(task) == 'function') {
                task();
            }
        }
        s_jsReady = true;
    }

    FlashRequest.__setSwfReady = function () {
        while (s_swfTaskQueue.length > 0) {
            var task = s_swfTaskQueue.shift();
            if (typeof(task) == 'function') {
                task();
            }
        }
        s_swfReady = true;
    }

    return FlashRequest;
})();

if (window.attachEvent) {
    window.attachEvent('onload', function () {FlashRequest.__setJsReady();});
}
else {
    window.addEventListener('load', function () {FlashRequest.__setJsReady();}, false);
}