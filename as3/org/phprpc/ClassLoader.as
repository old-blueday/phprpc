/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| ClassLoader.as                                           |
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
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/
/* PHPRPC Client ClassLoader for ActionScript 3.0.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Nov 5, 2007
 * This library is free.  You can redistribute it and/or modify it.
 */

package org.phprpc {
	import flash.display.MovieClip;
	public class ClassLoader extends MovieClip {
		public function export():void {
			org.phprpc.PHPRPC_Client;
		}
	}
}