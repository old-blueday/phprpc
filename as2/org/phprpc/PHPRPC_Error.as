/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Error.as                                          |
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
/* PHPRPC_Error for ActionScript 2.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.0
 * LastModified: Jan 14, 2008
 * This library is free.  You can redistribute it and/or modify it.
 */
class org.phprpc.PHPRPC_Error extends Error {
	private var _number:Number;
	private var _message:String;
	public function PHPRPC_Error(number:Number, message:String) {
		this.name = "PHPRPC_Error";
		this._number = number;
		this._message = message;
	}
	/*
	 * Return the error number.
	 */
	public function getNumber():Number {
		return this._number;
	}
	public function get number():Number {
		return this._number;
	}
	/*
	 * Return the error message.
	 */
	public function getMessage():String {
		return this._message;
	}
	public function get message():String {
		return this._message;
	}
	/*
	 * Return a string which include the error number and the error message.
	 */
	public function toString():String {
		return this._number + ":" + this._message;
	}
}
