/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Error.as                                          |
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
/* PHPRPC_Error for ActionScript 3.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */
package org.phprpc {
	public class PHPRPC_Error extends Error {
		private var _number:int;
		private var _message:String;
		public function PHPRPC_Error(message:String, id:int) {
			this.name = "PHPRPC_Error";
			this._number = id;
			this.message = message;
		}
		/*
		 * Return the error number.
		 */
		public function getNumber():int {
			return this._number;
		}
		public function get number():int {
			return this._number;
		}
		public override function get errorID():int {
			return this._number;
		}
		/*
		 * Return the error message.
		 */
		public function getMessage():String {
			return this.message;
		}
		/*
		 * Return a string which include the error number and the error message.
		 */
		public function toString():String {
			return this.number + ":" + this.message;
		}
	}
}