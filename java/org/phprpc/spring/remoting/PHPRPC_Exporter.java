/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Exporter.java                                     |
|                                                          |
| Release 3.0.2                                            |
| Copyright by Team-PHPRPC                                 |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  squall <squall.liu@gmail.com>                  |
|           Ma Bingyao <andot@ujn.edu.cn>                  |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* PHPRPC Exporter for Spring.
 *
 * Copyright: squall <squall.liu@gmail.com>
 *            Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Mar 9, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */

package org.phprpc.spring.remoting;

import java.io.IOException;
import java.util.Iterator;
import java.util.Map;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.phprpc.PHPRPC_Server;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.remoting.support.RemoteExporter;
import org.springframework.web.HttpRequestHandler;

public class PHPRPC_Exporter extends RemoteExporter implements InitializingBean, HttpRequestHandler {

    private Map aliases;

    public void afterPropertiesSet() throws Exception {
        prepare();
    }

    /**
     * Initialize this service exporter.
     */
    public void prepare() {
        checkService();
        checkServiceInterface();
        Object service = getService();
        Class cls = getServiceInterface();
        if (aliases != null && aliases.size() > 0) {
            String[] functions = PHPRPC_Server.getAllFunctions(cls);
            for (Iterator itor = aliases.keySet().iterator(); itor.hasNext();) {
                String methodName = (String)(itor.next());
                PHPRPC_Server.addGlobal(methodName, service, cls, (String)(aliases.get(methodName)));
                for (int i = 0; i < functions.length; i++) {
                    if (functions[i].equals(methodName.toLowerCase())) {
                        functions[i] = "";
                        break;
                    }
                }
            }
            for (int i = 0; i < functions.length; i++) {
                if (!functions[i].equals("")) {
                    PHPRPC_Server.addGlobal(new String[] { functions[i] }, service, cls, null);      
                }
            }
            return;
        }
        PHPRPC_Server.addGlobal(service, cls);
    }

    /**
     * Processes the incoming PHPRPC request and creates a PHPRPC response.
     */
    public void handleRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        new PHPRPC_Server().start(request, response);
    }
    
    public void setAliases(Map aliases) {
        this.aliases = aliases;
    }    
}
