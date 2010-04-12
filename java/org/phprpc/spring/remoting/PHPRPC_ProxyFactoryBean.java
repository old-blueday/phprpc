/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_ProxyFactoryBean.java                             |
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
| terms of the GNU General Public License (GPL) version    |
| 2.0 as published by the Free Software Foundation and     |
| appearing in the included file LICENSE.                  |
|                                                          |
\**********************************************************/

/* PHPRPC Proxy FactoryBean for Spring.
 *
 * Copyright: squall <squall.liu@gmail.com>
 *            Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

package org.phprpc.spring.remoting;

import org.springframework.aop.framework.ProxyFactory;
import org.springframework.beans.factory.FactoryBean;
import org.springframework.util.ClassUtils;

public class PHPRPC_ProxyFactoryBean extends PHPRPC_ClientInterceptor implements FactoryBean {

	private ClassLoader beanClassLoader = ClassUtils.getDefaultClassLoader();

	private Object serviceProxy;


	public void setBeanClassLoader(ClassLoader classLoader) {
		this.beanClassLoader = classLoader;
	}

	public void afterPropertiesSet() {
		super.afterPropertiesSet();
		this.serviceProxy = new ProxyFactory(getServiceInterface(), this).getProxy(this.beanClassLoader);
	}

    public Object getObject() {
        return serviceProxy;
    }

    public Class getObjectType() {
        return getServiceInterface();
    }

    public boolean isSingleton() {
        return true;
    }
}
