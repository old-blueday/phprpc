/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_ClientInterceptor.java                            |
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

/* PHPRPC Client Interceptor for Spring.
 *
 * Copyright: squall <squall.liu@gmail.com>
 *            Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Feb 25, 2009
 * This library is free.  You can redistribute it and/or modify it.
 */
package org.phprpc.spring.remoting;

import java.lang.reflect.InvocationTargetException;
import java.net.MalformedURLException;
import org.phprpc.PHPRPC_Client;
import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;
import org.springframework.remoting.RemoteProxyFailureException;
import org.springframework.remoting.support.UrlBasedRemoteAccessor;

public class PHPRPC_ClientInterceptor extends UrlBasedRemoteAccessor implements MethodInterceptor {

    private PHPRPC_Client proxyFactory = null;
    private String proxy = null;
    private String charset = "utf-8";
    private int keyLength = 128;
    private int encryptMode = 0;
    private int timeout = 30000;
    private Object phprpcProxy = null;

    public void setWebProxy(String proxy) {
        this.proxy = proxy;
    }

    public void setCharset(String charset) {
        this.charset = charset;
    }

    public void setKeyLength(int keyLength) {
        this.keyLength = keyLength;
    }

    public void setEncryptMode(int encryptMode) {
        this.encryptMode = encryptMode;
    }

    public void setTimeout(int timeout) {
        this.timeout = timeout;
    }

    public void setProxyFactory(PHPRPC_Client proxyFactory) {
        this.proxyFactory = proxyFactory;
    }

    public void afterPropertiesSet() {
        super.afterPropertiesSet();
        prepare();
    }

    /**
     * Initialize the PHPRPC Client proxy for this interceptor.
     */
    public void prepare() {
        proxyFactory = new PHPRPC_Client(getServiceUrl());
        try {
            proxyFactory.setProxy(proxy);
        } catch (MalformedURLException ex) {
            proxy = null;
        }
        proxyFactory.setCharset(charset);
        proxyFactory.setKeyLength(keyLength);
        proxyFactory.setEncryptMode(encryptMode);
        proxyFactory.setTimeout(timeout);
        phprpcProxy = proxyFactory.useService(getServiceInterface());
    }

    public Object invoke(MethodInvocation invocation) throws Throwable {
        if (phprpcProxy == null) {
            throw new IllegalStateException("PHPRPC_ClientInterceptor is not properly initialized - "
                + "invoke 'prepare' before attempting any operations");
        }

        try {
            return invocation.getMethod().invoke(phprpcProxy, invocation.getArguments());
        }
        catch (InvocationTargetException ex) {
            throw ex.getTargetException();
        }
        catch (Throwable ex) {
            throw new RemoteProxyFailureException("Failed to invoke PHPRPC proxy for remote service [" + getServiceUrl() + "]", ex);
        }
    }
}
