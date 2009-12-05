/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Client.java                                       |
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
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* PHPRPC_Client class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Mar 21, 2009
 * This library is free.  You can redistribute it and/or modify it.
 *
/*
 * Example usage:
 *
import org.phprpc.PHPRPC_Client;

interface remoteFunctions {
    public int add(int a, int b);
    public double add(double a, double b);
    public String add(String a, String b);
}

public class SinTest
{
    public static void main(String[] args) {
        PHPRPC_Client rpc = new PHPRPC_Client("http://www.phprpc.org/server.php");
        remoteFunctions rf = (remoteFunctions)rpc.useService(remoteFunctions.class);
        rpc.setKeyLength(1024);
        rpc.setEncryptMode(2);
        System.out.println(rf.add(1, 2));
        System.out.println(rf.add(1.5, 2.6));
        System.out.println(rf.add("1", "2"));
    }
}
 *
 */

package org.phprpc;

import java.io.BufferedOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.lang.reflect.InvocationHandler;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Proxy;
import java.math.BigInteger;
import java.net.URL;
import java.net.Socket;
import java.net.MalformedURLException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Random;
import java.util.zip.GZIPInputStream;
import javax.net.SocketFactory;
import javax.net.ssl.SSLSocketFactory;
import org.phprpc.util.Base64;
import org.phprpc.util.XXTEA;
import org.phprpc.util.Cast;
import org.phprpc.util.PHPSerializer;

final class PHPRPC_InvocationHandler implements InvocationHandler {
    private PHPRPC_Client rpc;
    PHPRPC_InvocationHandler(PHPRPC_Client rpc) {
        this.rpc = rpc;
    }

    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
        Class[] paramTypes = method.getParameterTypes();
        int n = paramTypes.length;
        String function = method.getName();
        Object result = null;
        if ((n > 0) && (paramTypes[n - 1] == PHPRPC_Callback.class)) {
            PHPRPC_Callback callback = (PHPRPC_Callback)args[n - 1];
            Object[] tmpargs = new Object[n - 1];
            System.arraycopy(args, 0, tmpargs, 0, n - 1);
            rpc.invoke(function, tmpargs, callback);
        }
        else if ((n > 1) && (paramTypes[n - 2] == PHPRPC_Callback.class) && (paramTypes[n - 1] == Boolean.TYPE)) {
            PHPRPC_Callback callback = (PHPRPC_Callback)args[n - 2];
            boolean byRef = ((Boolean)args[n - 1]).booleanValue();
            Object[] tmpargs = new Object[n - 2];
            System.arraycopy(args, 0, tmpargs, 0, n - 2);
            rpc.invoke(function, tmpargs, callback, byRef);
        }
        else if ((n > 2) && (paramTypes[n - 3] == PHPRPC_Callback.class) && (paramTypes[n - 2] == Boolean.TYPE) && (paramTypes[n - 1] == Integer.TYPE)) {
            PHPRPC_Callback callback = (PHPRPC_Callback)args[n - 3];
            boolean byRef = ((Boolean)args[n - 2]).booleanValue();
            int encryptMode = ((Integer)args[n - 1]).intValue();
            Object[] tmpargs = new Object[n - 3];
            System.arraycopy(args, 0, tmpargs, 0, n - 3);
            rpc.invoke(function, tmpargs, callback, byRef, encryptMode);
        }
        else {
            result = rpc.invoke(function, args);
            if (result instanceof PHPRPC_Error) {
                throw (PHPRPC_Error)result;
            }
            result = Cast.cast(result, method.getReturnType(), rpc.getCharset());
        }
        return result;
    }
}

final class SocketPool {
    private LinkedList sockets = new LinkedList();
    private SocketFactory socketFactory;
    private String host;
    private int port;
    private int timeout;

    SocketPool(SocketFactory socketFactory, String host, int port, int timeout) {
        this.socketFactory = socketFactory;
        this.host = host;
        this.port = port;
        this.timeout = timeout;
    }

    private final Socket newSocket() throws IOException {
        Socket socket = socketFactory.createSocket(host, port);
        socket.setSoTimeout(timeout);
        socket.setTcpNoDelay(true);
        socket.setKeepAlive(true);
        return socket;
    }

    public final synchronized Socket getConnect() throws IOException {
        Socket socket = null;
        if (!sockets.isEmpty()) {
            socket = (Socket)sockets.removeFirst();
        }
        if (socket == null ||
            socket.isClosed() ||
            socket.isInputShutdown() ||
            socket.isOutputShutdown() ||
            socket.isConnected()) {
            if (socket != null) {
                try {
                    socket.close();
                }
                catch (IOException e) {}
            }
            socket = newSocket();
        }
        return socket;
    }

    public final synchronized void freeConnect(Socket socket, boolean keepAlive) {
        if (keepAlive) {
            sockets.addLast(socket);
        }
        else if (socket != null) {
            try {
                socket.close();
            }
            catch (IOException e) {}
        }
    }

    public final synchronized void clearConnect() {
        while (!sockets.isEmpty()) {
            Socket socket = (Socket)sockets.removeLast();
            if (socket != null) {
                try {
                    socket.close();
                }
                catch (IOException e) {}
            }
        }
        sockets.clear();
    }

    public final void finalize() throws Throwable {
        super.finalize();
        clearConnect();
    }
}

public class PHPRPC_Client {
    protected PHPSerializer __phpser = null;
    private HashMap __server = null;
    private HashMap __proxy = null;
    private int __timeout = 30000;
    private PHPRPC_Error __warning = null;
    private byte[] __key = null;
    private int __keylen = 128;
    private int __encryptMode = 0;
    private boolean __keyExchanged = false;
    private String __charset = "utf-8";
    private String __output = "";
    private SocketPool __socketPool = null;
    private boolean __keepAlive = true;
    private String __clientID = "";
    private static int __sID = 0;
    private static String __cookie = null;
    private static final HashMap __cookies = new HashMap();

    public PHPRPC_Client() {
        __clientID = "java" + String.valueOf(new Random().nextInt())
                            + String.valueOf(new Date().getTime())
                            + String.valueOf(__sID++);
    }

    public PHPRPC_Client(String serverURL) {
        this();
        useService(serverURL);
    }

    public final Object useService(Class type) {
        PHPRPC_InvocationHandler handler = new PHPRPC_InvocationHandler(this);
        if (type.isInterface()) {
            return Proxy.newProxyInstance(type.getClassLoader(), new Class[] { type }, handler);
        }
        else {
            return Proxy.newProxyInstance(type.getClassLoader(), type.getInterfaces(), handler);
        }
    }

    public final Object useService(Class[] interfaces) {
        PHPRPC_InvocationHandler handler = new PHPRPC_InvocationHandler(this);
        return Proxy.newProxyInstance(interfaces[0].getClassLoader(), interfaces, handler);
    }

    public final boolean useService(String serverURL) {
        return useService(serverURL, null, null);
    }

    public final Object useService(String serverURL, Class type) {
        if (useService(serverURL, null, null)) {
            return useService(type);
        }
        else {
            return null;
        }
    }

    public final Object useService(String serverURL, Class[] interfaces) {
        if (useService(serverURL, null, null)) {
            return useService(interfaces);
        }
        else {
            return null;
        }
    }

    public final boolean useService(String serverURL, String username, String password) {
        URL url;
        try {
            url = new URL(serverURL);
        }
        catch (MalformedURLException e) {
            return false;
        }
        if (!url.getProtocol().equals("http") && !url.getProtocol().equals("https")) {
            return false;
        }
        __server = new HashMap();
        __server.put("scheme", url.getProtocol());
        __server.put("host", url.getHost());
        __server.put("port", new Integer((url.getPort() == -1) ? url.getDefaultPort() : url.getPort()));
        String path = url.getFile();
        if (path.indexOf((int)'?') > -1) {
            path = path + "&phprpc_id=" + __clientID;
        }
        else {
            path = path + "?phprpc_id=" + __clientID;
        }
        __server.put("path", path);
        __server.put("userinfo", ((username == null) ? url.getUserInfo() : username + ':' + password));

        __socketPool = null;
        __keepAlive = true;
        __key = null;
        __keylen = 128;
        __encryptMode = 0;
        __keyExchanged = false;
        __phpser = new PHPSerializer();
        setCharset("utf-8");
        return true;
    }

    public final Object useService(String serverURL, String username, String password, Class type) {
        if (useService(serverURL, username, password)) {
            return useService(type);
        }
        else {
            return null;
        }
    }

    public final Object useService(String serverURL, String username, String password, Class[] interfaces) {
        if (useService(serverURL, username, password)) {
            return useService(interfaces);
        }
        else {
            return null;
        }
    }

    public final void setProxy(String address) throws MalformedURLException {
        if (address == null) {
            __proxy = null;
        }
        else {
            URL url = new URL(address);
            setProxy(url.getHost(), ((url.getPort() == -1) ? url.getDefaultPort() : url.getPort()), url.getUserInfo());
        }
    }

    public final void setProxy(String host, int port) {
        setProxy(host, port, null);
    }

    public final void setProxy(String host, int port, String username, String password) {
        setProxy(host, port, ((username == null) ? null : username + ':' + password));
    }

    private final void setProxy(String host, int port, String userinfo) {
        __proxy = new HashMap();
        __proxy.put("host", host);
        __proxy.put("port", new Integer(port));
        __proxy.put("userinfo", userinfo);
    }

    public final boolean setKeyLength(int keyLength) {
        if (__key != null) {
            return false;
        }
        else {
            __keylen = keyLength;
            return true;
        }
    }

    public final int getKeyLength() {
        return __keylen;
    }

    public final boolean setEncryptMode(int encryptMode) {
        if ((encryptMode >= 0) && (encryptMode <= 3)) {
            __encryptMode = encryptMode;
            return true;
        }
        else {
            __encryptMode = 0;
            return false;
        }
    }

    public final int getEncryptMode() {
        return __encryptMode;
    }

    public final synchronized void setCharset(String charset) {
        __charset = charset;
        __phpser.setCharset(__charset);
    }

    public final String getCharset() {
        return __charset;
    }

    public final void setTimeout(int timeout) {
        __timeout = timeout;
    }

    public final int getTimeout() {
        return __timeout;
    }

    public final String getOutput() {
        return __output;
    }

    public final PHPRPC_Error getWarning() {
        return __warning;
    }

    public final Object invoke(String function, Object[] args) {
        return invoke(function, args, false);
    }

    public final Object invoke(String function, Object[] args, boolean byRef) {
        HashMap response = invoke(function, args, byRef, __encryptMode);
        __output = (String)response.get("output");
        __warning = (PHPRPC_Error)response.get("warning");
        return response.get("result");
    }

    public final void invoke(String function, Object[] args, PHPRPC_Callback callback) {
        invoke(function, args, callback, false);
    }

    public final void invoke(String function, Object[] args, PHPRPC_Callback callback, boolean byRef) {
        invoke(function, args, callback, byRef, __encryptMode);
    }

    public final void invoke(final String function, final Object[] args, final PHPRPC_Callback callback, final boolean byRef, final int encryptMode) {
        final PHPRPC_Client self = this;
        new Thread(new Runnable() {
            public void run() {
                HashMap response = self.invoke(function, args, byRef, encryptMode);
                if (response.get("result") instanceof PHPRPC_Error) {
                    callback.errorHandler((PHPRPC_Error)response.get("result"));
                    return;
                }
                try {
                    Method[] methods = callback.getClass().getDeclaredMethods();
                    for (int i = 0, m = methods.length; i < m; i++) {
                        Method method = methods[i];
                        if (!method.isAccessible()) {
                            method.setAccessible(true);
                        }
                        Class[] paramTypes = method.getParameterTypes();
                        int len = paramTypes.length;
                        if (len > 0) {
                            Object result = Cast.cast(response.get("result"), paramTypes[0]);
                            switch (len) {
                                case 1: {
                                    if (!method.getName().equals("errorHandler") || paramTypes[0] != Throwable.class) {
                                        method.invoke(callback, new Object[] { result });
                                    }
                                    break;
                                }
                                case 2: {
                                    method.invoke(callback, new Object[] { result, args });
                                    break;
                                }
                                case 3: {
                                    method.invoke(callback, new Object[] { result, args, response.get("output") });
                                    break;
                                }
                                case 4: {
                                    method.invoke(callback, new Object[] { result, args, response.get("output"), response.get("warning") });
                                    break;
                                }
                            }
                        }
                    }
                }
                catch (Exception ex) {
                    callback.errorHandler(ex);
                }
            }
        }).start();
    }

    public final HashMap invoke(String function, Object[] args, boolean byRef, int encryptMode) {
        HashMap response = new HashMap();
        try {
            encryptMode = __keyExchange(encryptMode);
            StringBuffer requestBody = new StringBuffer();
            requestBody.append("phprpc_func=").append(function);
            if (args != null && args.length > 0) {
                requestBody.append("&phprpc_args=");
                requestBody.append(Base64.encode(__encrypt(__phpser.serialize(args), 1, encryptMode)).replaceAll("\\+", "%2B"));
            }
            requestBody.append("&phprpc_encrypt=").append(encryptMode);
            if (!byRef) {
                requestBody.append("&phprpc_ref=false");
            }
            HashMap result = __post(requestBody.toString());
            int errno = Integer.parseInt((String) result.get("phprpc_errno"));
            if (errno > 0) {
                String errstr = new String(Base64.decode((String) result.get("phprpc_errstr")), __charset);
                response.put("warning", new PHPRPC_Error(errno, errstr));
            }
            else {
                response.put("warning", null);
            }
            if (result.containsKey("phprpc_output")) {
                byte[] output = Base64.decode((String) result.get("phprpc_output"));
                if (Double.parseDouble((String) __server.get("version")) >= 3) {
                    output = __decrypt(output, 3, encryptMode);
                }
                response.put("output", new String(output, __charset));
            }
            else {
                response.put("output", "");
            }
            if (result.containsKey("phprpc_result")) {
                if (result.containsKey("phprpc_args")) {
                    Object[] arguments = (Object[]) __phpser.unserialize(__decrypt(Base64.decode((String) result.get("phprpc_args")), 1, encryptMode), Object[].class);
                    for (int i = 0; i < Math.min(args.length, arguments.length); i++) {
                        args[i] = arguments[i];
                    }
                }
               response.put("result", __phpser.unserialize(__decrypt(Base64.decode((String) result.get("phprpc_result")), 2, encryptMode)));
            }
            else {
                response.put("result", __warning);
            }
        }
        catch (PHPRPC_Error e) {
            response.put("result", e);
        }
        catch (Throwable e) {
            StackTraceElement[] st = e.getStackTrace();
            StringBuffer es = new StringBuffer(e.toString()).append("\r\n");
            for (int i = 0, n = st.length; i < n; i++) {
                es.append(st[i].toString()).append("\r\n");
            }
            response.put("result", new PHPRPC_Error(1, es.toString()));
        }
        return response;
    }

    private final void __initSocketPool() throws IOException {
        SocketFactory socketFactory;
        if (((String) __server.get("scheme")).equals("https")) {
            socketFactory = SSLSocketFactory.getDefault();
        }
        else {
            socketFactory = SocketFactory.getDefault();
        }
        String host;
        int port;
        if (__proxy != null) {
            host = (String) __proxy.get("host");
            port = ((Integer) __proxy.get("port")).intValue();
        }
        else {
            host = (String) __server.get("host");
            port = ((Integer) __server.get("port")).intValue();
        }
        __socketPool = new SocketPool(socketFactory, host, port, __timeout);
    }

    private final void __sendRequest(String requestBody, Socket socket) throws IOException {
        StringBuffer url = new StringBuffer();
        StringBuffer connection = new StringBuffer();
        if (__proxy == null) {
            url.append(__server.get("path"));
            connection.append("Connection: ");
            connection.append(__keepAlive ? "Keep-Alive" : "close");
            connection.append("\r\n");
            connection.append("Pragma: no-cache\r\n");
            connection.append("Cache-Control: no-cache\r\n");
        }
        else {
            url.append(__server.get("scheme"));
            url.append("://");
            url.append(__server.get("host"));
            url.append(":");
            url.append(__server.get("port"));
            url.append(__server.get("path"));
            connection.append("Proxy-Connection: ");
            connection.append(__keepAlive ? "Keep-Alive" : "close");
            connection.append("\r\n");
            if (__proxy.get("userinfo") != null) {
                connection.append("Proxy-Authorization: Basic ");
                connection.append(Base64.encode(((String) __proxy.get("userinfo")).getBytes(__charset)));
                connection.append("\r\n");
            }
        }
        StringBuffer auth = new StringBuffer();
        if (__server.get("userinfo") != null) {
            auth.append("Authorization: Basic ");
            auth.append(Base64.encode(((String) __server.get("userinfo")).getBytes(__charset)));
            auth.append("\r\n");
        }
        StringBuffer cookie = new StringBuffer();
        if (__cookie != null) {
            cookie.append("Cookie: ");
            cookie.append(__cookie);
            cookie.append("\r\n");
        }
        byte[] rb = requestBody.getBytes();
        StringBuffer requestHeader = new StringBuffer();
        requestHeader.append("POST ").append(url).append(" HTTP/1.1\r\n");
        requestHeader.append("Host: ").append(__server.get("host")).append(':').append(__server.get("port")).append("\r\n");
        requestHeader.append("User-Agent: PHPRPC Client 3.0 for Java\r\n");
        requestHeader.append(auth).append(connection).append(cookie);
        requestHeader.append("Accept: */*\r\n");
        requestHeader.append("Accept-Encoding: gzip,deflate\r\n");
        requestHeader.append("Content-Type: application/x-www-form-urlencoded; charset=").append(__charset).append("\r\n");
        requestHeader.append("Content-Length: ").append(rb.length).append("\r\n");
        requestHeader.append("\r\n");
        __sendRequest(requestHeader.toString().getBytes(), rb, socket);
    }

    private final void __sendRequest(byte[] header, byte[] body, Socket socket) throws IOException {
        BufferedOutputStream os = new BufferedOutputStream(socket.getOutputStream());
        os.write(header);
        os.write(body);
        os.flush();
    }

    private final void __parseHeader(HashMap responseHeader) throws PHPRPC_Error {
        ArrayList xPowerdBy = (ArrayList)responseHeader.get("x-powered-by");
        if (xPowerdBy == null) {
            throw new PHPRPC_Error(1, "Illegal PHPRPC server.");
        }

        __server.put("version", "0");
        String version = null;
        for (int i = 0; i < xPowerdBy.size(); i++) {
            String s = (String) xPowerdBy.get(i);
            if (s.startsWith("PHPRPC Server/")) {
                version = s.substring(14);
            }
        }
        if (version == null) {
            throw new PHPRPC_Error(1, "Illegal PHPRPC server.");
        }
        else {
            __server.put("version", version);
        }
        if (responseHeader.containsKey("content-type")) {
            ArrayList contentType = (ArrayList)responseHeader.get("content-type");
            for (int i = 0; i < contentType.size(); i++) {
                String s = (String) contentType.get(i);
                if (s.startsWith("text/plain; charset=")) {
                    setCharset(s.substring(20));
                }
            }
        }
        if (responseHeader.containsKey("set-cookie")) {
            synchronized(__cookies) {
                String name, value;
                ArrayList setCookie = (ArrayList)responseHeader.get("set-cookie");
                for (int i = 0; i < setCookie.size(); i++) {
                    String s = (String) setCookie.get(i);
                    String[] cookies = s.split("[;,]\\s?");
                    for (int j = 0; j < cookies.length; j++) {
                        String[] pair = cookies[j].split("=", 2);
                        if (pair.length == 2) {
                            name = pair[0];
                            value = pair[1];
                        }
                        else {
                            name = pair[0];
                            value = "";
                        }
                        if (!name.equals("domain") && !name.equals("expires") &&
                            !name.equals("path") && !name.equals("secure")) {
                            __cookies.put(name, value);
                        }
                    }
                }
                __cookie = "";
                for (Iterator keys = __cookies.keySet().iterator(); keys.hasNext();) {
                    name = (String) keys.next();
                    value = (String) __cookies.get(name);
                    __cookie += name + "=" + value + "; ";
                }
            }
        }
        if (responseHeader.containsKey("content-encoding")) {
            responseHeader.put("content-encoding", ((ArrayList) responseHeader.get("content-encoding")).get(0));
        }
        if (responseHeader.containsKey("transfer-encoding")) {
            responseHeader.put("transfer-encoding", ((ArrayList) responseHeader.get("transfer-encoding")).get(0));
        }
        if (responseHeader.containsKey("content-length")) {
            responseHeader.put("content-length", ((ArrayList) responseHeader.get("content-length")).get(0));
        }
        if (responseHeader.containsKey("connection")) {
            responseHeader.put("connection", ((ArrayList) responseHeader.get("connection")).get(0));
        }
    }

    private final String __readLine(InputStream is) throws IOException {
        StringBuffer sb = new StringBuffer();
        int c;
        while ((c = is.read()) > -1) {
            if (c == 13) {
                c = is.read();
                if (c != 10) {
                    throw new IOException();
                }
                else {
                    return sb.toString();
                }
            }
            else {
                sb.append((char) c);
            }
        }
        return sb.toString();
    }

    private final boolean __readCRLF(InputStream is) throws IOException {
        if (is.read() != 13) {
            return false;
        }
        if (is.read() != 10) {
            return false;
        }
        return true;
    }

    private final HashMap __readResponseHeader(String requestBody, Socket socket) throws IOException, PHPRPC_Error {
        return __readResponseHeader(requestBody, socket, 0);
    }

    private final HashMap __readResponseHeader(String requestBody, Socket socket, int times) throws IOException, PHPRPC_Error {
        __sendRequest(requestBody, socket);
        HashMap responseHeader;
        InputStream is = socket.getInputStream();
        String statuscode = null, status = "";
        do {
            responseHeader = new HashMap();
            String buf, name, value;
            while (!(buf = __readLine(is)).equals("")) {
                if (buf.startsWith("HTTP/")) {
                    statuscode = buf.substring(9, 12);
                    status = buf.substring(13);
                }
                else {
                    int pos = buf.indexOf(":");
                    if (pos > -1) {
                        name = buf.substring(0, pos).toLowerCase();
                        value = buf.substring(pos + 1).trim();
                        ArrayList a;
                        if (responseHeader.containsKey(name)) {
                            a = (ArrayList)responseHeader.get(name);
                        }
                        else {
                            a = new ArrayList();
                        }
                        a.add(value);
                        responseHeader.put(name, a);
                    }
                }
            }
            try {
                if (statuscode == null) {
                   throw new PHPRPC_Error(1, "Illegal HTTP server.");
                }
                if (!statuscode.equals("100") && !statuscode.equals("200")) {
                    try {
                        throw new PHPRPC_Error(Integer.parseInt(statuscode), status);
                    }
                    catch(NumberFormatException e) {
                        throw new PHPRPC_Error(1, statuscode + ":" + status);
                    }
                }
                if (statuscode.equals("200")) {
                    __parseHeader(responseHeader);
                }
            }
            catch (PHPRPC_Error e) {
                __socketPool.freeConnect(socket, false);
                throw e;
            }
        } while (statuscode.equals("100"));
        return responseHeader;
    }

    private final byte[] __ungzip(HashMap responseHeader, byte[] responseBodyByteArray) throws IOException, PHPRPC_Error {
        String contentEncoding = (String) responseHeader.get("content-encoding");
        if (contentEncoding != null && contentEncoding.toLowerCase().equals("gzip")) {
            ByteArrayInputStream bais = new ByteArrayInputStream(responseBodyByteArray);
            GZIPInputStream gzipis = new GZIPInputStream(bais);
            ByteArrayOutputStream baos = new ByteArrayOutputStream();
            int n = responseBodyByteArray.length;
            byte[] buf = new byte[n];
            int len;
            while ((len = gzipis.read(buf, 0, n)) > -1) {
                baos.write(buf, 0, len);
            }
            responseBodyByteArray = baos.toByteArray();
        }
        return responseBodyByteArray;
    }

    private final HashMap __parseBody(byte[] responseBodyByteArray) throws IOException, PHPRPC_Error {
        ByteArrayInputStream is = new ByteArrayInputStream(responseBodyByteArray);
        HashMap result = new HashMap();
        String buf;
        while (!(buf = __readLine(is)).equals("")) {
            int p = buf.indexOf("=");
            if (p > -1) {
                result.put(buf.substring(0, p), buf.substring(p + 2, buf.length() - 2));
            }
        }
        return result;
    }

    private final HashMap __readResponseBody(HashMap responseHeader, Socket socket) throws IOException, PHPRPC_Error {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        InputStream is = socket.getInputStream();
        String te = (String) responseHeader.get("transfer-encoding");
        if (te != null && te.toLowerCase().equals("chunked")) {
            String s = __readLine(is);
            if (s.equals("")) {
                return new HashMap();
            }
            int n = Integer.parseInt(s, 16);
            while (n > 0) {
                byte[] b = new byte[n];
                int len;
                while (n > 0 && (len = is.read(b, 0, n)) > -1) {
                    baos.write(b, 0, len);
                    n -= len;
                }
                if (!__readCRLF(is)) {
                    __socketPool.freeConnect(socket, false);
                    throw new PHPRPC_Error(1, "Response is incorrect.");
                }
                n = Integer.parseInt(__readLine(is), 16);
            }
            __readLine(is);
        }
        else if (responseHeader.get("content-length") != null) {
            int n = Integer.parseInt((String) responseHeader.get("content-length"));
            byte[] b = new byte[n];
            int len;
            while (n > 0 && (len = is.read(b, 0, n)) > -1) {
                baos.write(b, 0, len);
                n -= len;
            }
        }
        else {
            byte[] b = new byte[2048];
            int len;
            while ((len = is.read(b, 0, 2048)) > -1) {
                baos.write(b, 0, len);
            }
            __keepAlive = false;
        }
        return __parseBody(__ungzip(responseHeader, baos.toByteArray()));
    }

    private final HashMap __post(String requestBody) throws IOException, PHPRPC_Error {
        if (__socketPool == null) {
            __initSocketPool();
        }
        Socket socket = __socketPool.getConnect();
        HashMap responseHeader, responseBody;
        try {
            responseHeader = __readResponseHeader(requestBody, socket);
            responseBody = __readResponseBody(responseHeader, socket);
        }
        catch (IOException e) {
            __socketPool.freeConnect(socket, false);
            throw e;
        }
        String connection = (String) responseHeader.get("connection");
        if (__keepAlive && connection != null && connection.equals("close")) {
            __keepAlive = false;
        }
        __socketPool.freeConnect(socket, __keepAlive);
        return responseBody;
    }

    private final synchronized int __keyExchange(int encryptMode)
            throws IOException, IllegalAccessException, IllegalArgumentException,
            InvocationTargetException, NoSuchAlgorithmException, PHPRPC_Error {
        if (__key != null || encryptMode == 0) {
            return encryptMode;
        }
        if (__key == null && __keyExchanged) {
            return 0;
        }
        HashMap result = __post("phprpc_encrypt=true&phprpc_keylen=" + __keylen);
        if (result.containsKey("phprpc_keylen")) {
            __keylen = Integer.parseInt((String) result.get("phprpc_keylen"));
        }
        else {
            __keylen = 128;
        }
        if (result.containsKey("phprpc_encrypt")) {
            HashMap encrypt = (HashMap) __phpser.unserialize(Base64.decode((String) result.get("phprpc_encrypt")), HashMap.class);
            BigInteger x = (new BigInteger(__keylen - 1, new Random())).setBit(__keylen - 2);
            BigInteger y = new BigInteger(Cast.toString(encrypt.get("y")));
            BigInteger p = new BigInteger(Cast.toString(encrypt.get("p")));
            BigInteger g = new BigInteger(Cast.toString(encrypt.get("g")));
            BigInteger k = y.modPow(x, p);
            byte[] key1, key2;
            if (__keylen == 128) {
                key1 = k.toByteArray();
            }
            else {
                MessageDigest md5 = MessageDigest.getInstance("MD5");
                md5.update(k.toString().getBytes());
                key1 = md5.digest();
            }
            key2 = new byte[16];
            for (int i = 1, n = Math.min(key1.length, 16); i <= n; i++) {
                key2[16 - i] = key1[key1.length - i];
            }
            __post("phprpc_encrypt=" + g.modPow(x, p).toString());
            __key = key2;
        }
        else {
            __key = null;
            __keyExchanged = true;
            encryptMode = 0;
        }
        return encryptMode;
    }

    private final byte[] __encrypt(byte[] s, int level, int encryptMode) {
        if (__key != null && encryptMode >= level) {
            s = XXTEA.encrypt(s, __key);
        }
        return s;
    }

    private final byte[] __decrypt(byte[] s, int level, int encryptMode) {
        if (__key != null && encryptMode >= level) {
            s = XXTEA.decrypt(s, __key);
        }
        return s;
    }
}