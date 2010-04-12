/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| stdClass.java                                            |
|                                                          |
| Release 3.0.2                                            |
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

/* stdClass is the base Class of serialiable Objects for J2ME.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

package org.phprpc.util;

import java.util.Enumeration;
import java.util.Hashtable;

public class stdClass {
    Hashtable data = new Hashtable();

    public stdClass() {}

    void setProperty(String name, Object value) {}

    Object getProperty(String name) {
        return data.get(name);
    }

    public final void set(String name, Object value) {
        data.put(name, value);
        setProperty(name, value);
    }

    public final Object get(String name) {
        return getProperty(name);
    }

    public String[] __sleep() {
        String[] result = new String[data.size()];
        int i = 0;
        for (Enumeration keys = data.keys(); keys.hasMoreElements();) {
            result[i++] = keys.nextElement().toString();
        }
        return result;
    }

    public void __wakeup() {}
}
