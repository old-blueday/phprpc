/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| PHPRPC_Server.java                                       |
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

/* PHPRPC_Server class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Mar 19, 2009
 * This library is free.  You can redistribute it and/or modify it.
 *
/*
 * Example usage:
 *
 * rpc.jsp
 <%@ page import="java.lang.*" %>
 <%@ page import="org.phprpc.*" %>
 <%
 PHPRPC_Server phprpc_server = new PHPRPC_Server();
 phprpc_server.add("min", Math.class);
 phprpc_server.add(new String[] { "sin", "cos" }, Math.class);
 phprpc_server.start(request, response);
 %>
 */
package org.phprpc;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.OutputStreamWriter;
import java.io.PrintStream;
import java.io.PrintWriter;
import java.io.UnsupportedEncodingException;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.lang.reflect.Modifier;
import java.math.BigInteger;
import java.net.URLEncoder;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.ArrayList;
import java.util.Date;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.zip.GZIPOutputStream;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;

import org.phprpc.util.Base64;
import org.phprpc.util.Cast;
import org.phprpc.util.DHParams;
import org.phprpc.util.PHPSerializer;
import org.phprpc.util.XXTEA;

final class RemoteFunction {
    public Object obj;
    public Method[] functions;
    public RemoteFunction(Object obj, Method[] functions) {
        this.obj = obj;
        this.functions = functions;
    }
}

final public class PHPRPC_Server {
    private HttpServletRequest request;
    private HttpServletResponse response;
    private HttpSession session;
    private PHPSerializer phpser;
    private HashMap functions;
    private boolean debug;
    private String charset;
    private boolean encode;
    private boolean byref;
    private boolean encrypt;
    private boolean enableGZIP;
    private int encryptMode;
    private byte[] key;
    private int keylen;
    private BigInteger y;
    private String output;
    private String callback;
    private int errno;
    private String errstr;
    private String cid;
    private StringBuffer buffer;
    private static HashMap globalFunctions = new HashMap();

    private static boolean add(String[] funcnames, Object obj, Class cls, String[] aliases, HashMap functions) {
        if (aliases == null) {
            aliases = funcnames;
        }
        if (funcnames.length != aliases.length) {
            return false;
        }
        Method[] methods = cls.getMethods();
        for (int i = 0, n = funcnames.length; i < n; i++) {
            ArrayList fs = new ArrayList();
            for (int j = 0, m = methods.length; j < m; j++) {
                int mod = methods[j].getModifiers();
                if (funcnames[i].toLowerCase().equals(methods[j].getName().toLowerCase())
                    && Modifier.isPublic(mod) && (obj == null) == (Modifier.isStatic(mod))) {
                    fs.add(methods[j]);
                }
            }
            if (fs.size() > 0) {
                functions.put(aliases[i].toLowerCase(), new RemoteFunction(obj, (Method[])fs.toArray(new Method[fs.size()])));
            }
        }
        return true;
    }
    /**add by ice*/
    private static boolean add(Method[] funcs, Object obj, String[] aliases, HashMap functions) {
        if (aliases == null) {
            aliases = new String[funcs.length];
            for (int i = 0; i < funcs.length; i++) {
                aliases[i] = funcs[i].getName();
            }
        }
        if (funcs.length != aliases.length) {
            return false;
        }
        for (int i = 0; i < funcs.length; i++) {
            int mod = funcs[i].getModifiers();
            if (Modifier.isPublic(mod) && (obj == null) == (Modifier.isStatic(mod))) {
                functions.put(aliases[i].toLowerCase(), new RemoteFunction(obj, new Method[] {funcs[i]}));
            }
        }
        return true;
    }
    public static String[] getAllFunctions(Class cls) {
        Method[] methods = cls.getDeclaredMethods();
        HashMap names = new HashMap();
        for (int i = 0, n = methods.length; i < n; i++) {
            if (Modifier.isPublic(methods[i].getModifiers())) {
                String fn = methods[i].getName().toLowerCase();
                names.put(fn, fn);
            }
        }
        Object[] fo = names.keySet().toArray();
        String[] fs = new String[fo.length];
        System.arraycopy(fo, 0, fs, 0, fo.length);
        return fs;
    }
    private String toHexString(int n) {
        return ((n < 16) ? "0" : "") + Integer.toHexString(n);
    }
    private String addJsSlashes(String str) {
        char[] s = str.toCharArray();
        StringBuffer sb = new StringBuffer();
        for (int i = 0, n = s.length; i < n; i++) {
            if (s[i] <= 31 ||
                s[i] == 34 ||
                s[i] == 39 ||
                s[i] == 92 ||
                s[i] == 127) {
                sb.append("\\x");
                sb.append(toHexString((int)s[i] & 0xff));
            }
            else {
                sb.append(s[i]);
            }
        }
        return sb.toString();
    }
    private String addJsSlashes(byte[] s) {
        StringBuffer sb = new StringBuffer();
        for (int i = 0, n = s.length; i < n; i++) {
            if (s[i] <= 31 ||
                s[i] == 34 ||
                s[i] == 39 ||
                s[i] == 92 ||
                s[i] >= 127) {
                sb.append("\\x");
                sb.append(toHexString((int)s[i] & 0xff));
            }
            else {
                sb.append((char)s[i]);
            }
        }
        return sb.toString();
    }
    private String encodeString(String s) throws UnsupportedEncodingException {
        if (encode) {
            return Base64.encode(s.getBytes(charset));
        }
        else {
            return addJsSlashes(s);
        }
    }
    private String encodeString(byte[] s) {
        if (encode) {
            return Base64.encode(s);
        }
        else {
            return addJsSlashes(s);
        }
    }
    private byte[] encryptString(byte[] s, int level) {
        if (encryptMode >= level) {
            s = XXTEA.encrypt(s, key);
        }
        return s;
    }
    private byte[] decryptString(byte[] s, int level) {
        if (encryptMode >= level) {
            s = XXTEA.decrypt(s, key);
        }
        return s;
    }
    private void sendURL() throws UnsupportedEncodingException {
        if (!request.isRequestedSessionIdValid() || session.isNew()) {
            StringBuffer url = request.getRequestURL();
            Enumeration e = request.getParameterNames();
            if (e.hasMoreElements()) {
                url.append('?');
                do {
                    String query = (String)e.nextElement();
                    if (!query.toLowerCase().startsWith("phprpc_")) {
                        String[] values = request.getParameterValues(query);
                        for (int i = 0, n = values.length; i < n; i++) {
                            url.append(query).append('=').append(URLEncoder.encode(values[i], charset)).append('&');
                        }
                    }
                } while (e.hasMoreElements());
                url.setLength(url.length() - 1);
            }
            buffer.append("phprpc_url=\"");
            buffer.append(encodeString(response.encodeURL(url.toString())));
            buffer.append("\";\r\n");
        }
    }
    private void gzip(byte[] s) throws IOException {
        String acceptEncoding = request.getHeader("Accept-Encoding");
        if (acceptEncoding != null && acceptEncoding.indexOf("gzip") != -1) {
            ByteArrayOutputStream bs = new ByteArrayOutputStream();
            GZIPOutputStream gzips = new GZIPOutputStream(bs);
            gzips.write(s);
            gzips.finish();
            if (s.length > bs.size()) {
                response.setHeader("Content-Encoding", "gzip");
                response.setContentLength(bs.size());
                bs.writeTo(response.getOutputStream());
                return;
            }
        }
        response.setContentLength(s.length);
        response.getOutputStream().write(s);
    }
    private void sendCallback() throws IOException {
        buffer.append(callback);
        String buf = buffer.toString();
        if (enableGZIP) {
            gzip(buf.getBytes(charset));
        }
        else {
            response.getWriter().write(buf);
        }
        response.flushBuffer();
    }
    private void sendFunctions() throws IOException, IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        buffer.append("phprpc_functions=\"");
        functions.putAll(globalFunctions);
        buffer.append(encodeString(phpser.serialize(functions.keySet().toArray())));
        buffer.append("\";\r\n");
        sendCallback();
    }
    private void sendOutput() throws IOException {
        if (encryptMode >= 3) {
            buffer.append("phprpc_output=\"");
            buffer.append(encodeString(XXTEA.encrypt(output.getBytes(charset), key)));
            buffer.append("\";\r\n");
        }
        else {
            buffer.append("phprpc_output=\"");
            buffer.append(encodeString(output));
            buffer.append("\";\r\n");
        }
    }
    private void sendError() throws IOException {
        buffer.append("phprpc_errno=\"");
        buffer.append(errno);
        buffer.append("\";\r\n");
        buffer.append("phprpc_errstr=\"");
        buffer.append(encodeString(errstr));
        buffer.append("\";\r\n");
        sendOutput();
        sendCallback();
    }
    private void sendHeader() {
        response.setContentType("text/plain; charset=" + charset);
        response.setHeader("P3P", "CP=\"CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV\"");
        response.setHeader("X-Powered-By", "PHPRPC Server/3.0");
        response.setDateHeader("Expires", (new Date()).getTime());
        response.setHeader("Cache-Control", "no-store, no-cache, must-revalidate, max-age=0");
    }
    private byte[] call(Method function, Object obj, ArrayList arguments) throws Throwable {
        Class[] p = function.getParameterTypes();
        String funcname = function.getName();
        ByteArrayOutputStream bs = new ByteArrayOutputStream();
        PrintStream ps = new PrintStream(bs, false, charset);
        PrintWriter pw = new PrintWriter(new OutputStreamWriter(bs, charset), false);
        int size = arguments.size();
        if (p.length != size) {
            if (session == null) {
                session = request.getSession(true);
            }
            if (p.length == size + 1) {
                String className = p[p.length - 1].getName();
                if (className.equals("javax.servlet.http.HttpServletRequest")) {
                    arguments.add(request);
                }
                else if (className.equals("javax.servlet.http.HttpSession")) {
                    arguments.add(session);
                }
                else if (className.equals("javax.servlet.ServletContext")) {
                    arguments.add(session.getServletContext());
                }
                else if (className.equals("java.io.PrintStream")) {
                    arguments.add(ps);
                }
                else if (className.equals("java.io.PrintWriter")) {
                    arguments.add(pw);
                }
                else {
                    throw new IllegalArgumentException("number of arguments mismatch for " + funcname + "().");
                }
            }
            else if (p.length == size + 2) {
                String className1 = p[p.length - 2].getName();
                String className2 = p[p.length - 1].getName();
                if (className1.equals("javax.servlet.http.HttpServletRequest") &&
                    className2.equals("java.io.PrintStream")) {
                    arguments.add(request);
                    arguments.add(ps);
                }
                else if (className1.equals("javax.servlet.http.HttpServletRequest") &&
                    className2.equals("java.io.PrintWriter")) {
                    arguments.add(request);
                    arguments.add(pw);
                }
                else if (className1.equals("java.io.PrintStream") &&
                    className2.equals("javax.servlet.http.HttpServletRequest")) {
                    arguments.add(ps);
                    arguments.add(request);
                }
                else if (className1.equals("java.io.PrintWriter") &&
                    className2.equals("javax.servlet.http.HttpServletRequest")) {
                    arguments.add(pw);
                    arguments.add(request);
                }
                else if (className1.equals("javax.servlet.http.HttpSession") &&
                    className2.equals("java.io.PrintStream")) {
                    arguments.add(session);
                    arguments.add(ps);
                }
                else if (className1.equals("javax.servlet.http.HttpSession") &&
                    className2.equals("java.io.PrintWriter")) {
                    arguments.add(session);
                    arguments.add(pw);
                }
                else if (className1.equals("java.io.PrintStream") &&
                    className2.equals("javax.servlet.http.HttpSession")) {
                    arguments.add(ps);
                    arguments.add(session);
                }
                else if (className1.equals("java.io.PrintWriter") &&
                    className2.equals("javax.servlet.http.HttpSession")) {
                    arguments.add(pw);
                    arguments.add(session);
                }
                else if (className1.equals("javax.servlet.ServletContext") &&
                    className2.equals("java.io.PrintStream")) {
                    arguments.add(session.getServletContext());
                    arguments.add(ps);
                }
                else if (className1.equals("javax.servlet.ServletContext") &&
                    className2.equals("java.io.PrintWriter")) {
                    arguments.add(session.getServletContext());
                    arguments.add(pw);
                }
                else if (className1.equals("java.io.PrintStream") &&
                    className2.equals("javax.servlet.ServletContext")) {
                    arguments.add(ps);
                    arguments.add(session.getServletContext());
                }
                else if (className1.equals("java.io.PrintWriter") &&
                    className2.equals("javax.servlet.ServletContext")) {
                    arguments.add(pw);
                    arguments.add(session.getServletContext());
                }
                else {
                    throw new IllegalArgumentException("number of arguments mismatch for " + funcname + "().");
                }
            }
            else {
                throw new IllegalArgumentException("number of arguments mismatch for " + funcname + "().");
            }
        }
        Object[] args = arguments.toArray();
        while (size < arguments.size()) {
            arguments.remove(size);
        }
        for (int i = 0, n = args.length; i < n; i++) {
            if (args[i] != null) {
                args[i] = Cast.cast(args[i], p[i], charset);
            }
        }
        byte[] result = null;
        try {
            result = phpser.serialize(function.invoke(obj, args));
        }
        catch (IllegalAccessException e1) {
            throw new IllegalArgumentException(e1.getMessage() + " for " + funcname + "().");
        }
        catch (IllegalArgumentException e2) {
            throw new IllegalArgumentException(e2.getMessage() + " for " + funcname + "().");
        }
        catch (NullPointerException e3) {
            throw new NullPointerException(e3.getMessage() + " for " + funcname + "().");
        }
        catch (ExceptionInInitializerError e4) {
            Throwable e5 = e4.getCause();
            if (e5 != null) {
                throw e5;
            }
            throw new ExceptionInInitializerError(e4.getMessage() + " for " + funcname + "().");
        }
        catch (InvocationTargetException e6) {
            Throwable e7 = e6.getCause();
            if (e7 != null) {
                throw e7;
            }
            throw new InvocationTargetException(null, e6.getMessage() + " for " + funcname + "().");
        }
        ps.close();
        pw.close();
        output = new String(bs.toByteArray(), charset);
        return result;
    }
    private boolean getBooleanRequest(String name) {
        boolean var = true;
        if (request.getParameter(name) != null &&
            request.getParameter(name).toLowerCase().equals("false")) {
            var = false;
        }
        return var;
    }
    private void initEncode() {
        encode = getBooleanRequest("phprpc_encode");
    }
    private void initRef() {
        byref = getBooleanRequest("phprpc_ref");
    }
    private void initErrorHandler() {
        errno = 0;
        errstr = "";
        output = "";
    }
    private void initCallback() throws UnsupportedEncodingException {
        if (request.getParameter("phprpc_callback") != null) {
            callback = new String(Base64.decode(request.getParameter("phprpc_callback")), charset);
        }
        else {
            callback = "";
        }
    }
    private void initClientID() {
        cid = "0";
        if (request.getParameter("phprpc_id") != null) {
            cid = request.getParameter("phprpc_id");
        }
        cid = "phprpc_" + cid;
    }
    private void initKeylen() {
       if (request.getParameter("phprpc_keylen") != null) {
            keylen = Integer.parseInt(request.getParameter("phprpc_keylen"));
        }
        else {
            HashMap sessionObject = (HashMap)session.getAttribute(cid);
            if (sessionObject != null && sessionObject.get("keylen") != null){
                keylen = ((Integer)sessionObject.get("keylen")).intValue();
            }
            else {
                keylen = 128;
            }
        }
    }
    private void initEncrypt() {
        encrypt = false;
        encryptMode = 0;
        y = null;
        if (request.getParameter("phprpc_encrypt") != null) {
            String enc = request.getParameter("phprpc_encrypt").toLowerCase();
            if (enc.equals("true")) {
                encrypt = true;
            }
            else if (enc.equals("false")) {
                encrypt = false;
            }
            else if (enc.equals("0")) {
                encryptMode = 0;
            }
            else if (enc.equals("1")) {
                encryptMode = 1;
            }
            else if (enc.equals("2")) {
                encryptMode = 2;
            }
            else if (enc.equals("3")) {
                encryptMode = 3;
            }
            else {
                y = new BigInteger(enc);
            }
        }
    }
    private void initKey() throws Exception {
        if (encryptMode > 0) {
            if (session == null) {
                session = request.getSession(true);
            }
            HashMap sessionObject = (HashMap)session.getAttribute(cid);
            if (sessionObject != null && sessionObject.get("key") != null) {
                key = (byte[])sessionObject.get("key");
            }
            else {
                encryptMode = 0;
                throw new Exception("Can't find the key for decryption.");
            }
        }
    }
    private ArrayList getArguments() throws UnsupportedEncodingException, IllegalAccessException, IllegalArgumentException, InvocationTargetException {
        ArrayList arguments;
        if (request.getParameter("phprpc_args") != null) {
            arguments = (ArrayList)phpser.unserialize(decryptString(Base64.decode(request.getParameter("phprpc_args")), 1), ArrayList.class);
        }
        else {
            arguments = new ArrayList();
        }
        return arguments;
    }
    private void callFunction() throws Throwable {
        String funcname = request.getParameter("phprpc_func").toLowerCase();
        RemoteFunction rf = null;
        if (functions.containsKey(funcname)) {
            rf = (RemoteFunction)functions.get(funcname);
        }
        else if (globalFunctions.containsKey(funcname)) {
            rf = (RemoteFunction)globalFunctions.get(funcname);
        }
        else {
            throw new NoSuchMethodException("Can't find this function " + request.getParameter("phprpc_func") + "().");
        }
        initKey();
        ArrayList arguments = getArguments();
        String result = null;
        for (int i = 0, n = rf.functions.length; i < n; i++) {
            try {
                result = encodeString(encryptString(call(rf.functions[i], rf.obj, arguments), 2));
                break;
            }
            catch (Throwable e) {
                if (i == n - 1) {
                    errstr = "";
                    throw e;
                }
                else {
                    errno = 2;
                    if (debug) {
                        StackTraceElement[] st = e.getStackTrace();
                        StringBuffer es = new StringBuffer(e.toString()).append("\r\n");
                        for (int j = 0, m = st.length; j < m; j++) {
                            es.append(st[j].toString()).append("\r\n");
                        }
                        errstr += es.toString();
                    }
                    else {
                        errstr += e.toString();
                    }
                }
            }
        }
        buffer.append("phprpc_result=\"");
        buffer.append(result);
        buffer.append("\";\r\n");
        if (byref) {
            buffer.append("phprpc_args=\"");
            buffer.append(encodeString(encryptString(phpser.serialize(arguments), 1)));
            buffer.append("\";\r\n");
        }
        sendError();
    }
    private void keyExchange() throws IOException, IllegalAccessException, NoSuchAlgorithmException, IllegalArgumentException, InvocationTargetException {
        HashMap sessionObject;
        if (session == null) {
            session = request.getSession(true);
        }
        initKeylen();
        if (encrypt) {
            DHParams dhParams = new DHParams(keylen);
            keylen = dhParams.getL();
            BigInteger p = dhParams.getP();
            BigInteger g = dhParams.getG();
            BigInteger x = dhParams.getX();
            BigInteger y = g.modPow(x, p);
            sessionObject = new HashMap();
            sessionObject.put("x", x);
            sessionObject.put("p", p);
            sessionObject.put("keylen", new Integer(keylen));
            session.setAttribute(cid, sessionObject);
            HashMap dhp = dhParams.getDHParams();
            dhp.put("y", y.toString());
            buffer.append("phprpc_encrypt=\"");
            buffer.append(encodeString(phpser.serialize(dhp)));
            buffer.append("\";\r\n");
            if (keylen != 128) {
                buffer.append("phprpc_keylen=\"");
                buffer.append(keylen);
                buffer.append("\";\r\n");
            }
            sendURL();
        }
        else {
            sessionObject = (HashMap)session.getAttribute(cid);
            BigInteger x = (BigInteger)sessionObject.get("x");
            BigInteger p = (BigInteger)sessionObject.get("p");
            BigInteger k = y.modPow(x, p);
            byte[] tempkey;
            if (keylen == 128) {
                tempkey = k.toByteArray();
            }
            else {
                MessageDigest md5 = MessageDigest.getInstance("MD5");
                md5.update(k.toString().getBytes());
                tempkey = md5.digest();
            }
            key = new byte[16];
            for (int i = 1, n = Math.min(tempkey.length, 16); i <= n; i++) {
                key[16 - i] = tempkey[tempkey.length - i];
            }
            sessionObject.put("key", key);
            sessionObject.remove("x");
            sessionObject.remove("p");
            session.setAttribute(cid, sessionObject);
        }
        sendCallback();
    }
    public PHPRPC_Server() {
        phpser = new PHPSerializer();
        functions = new HashMap();
        charset = "UTF-8";
        debug = false;
        enableGZIP = false;
    }
    public static boolean addGlobal(Object obj) {
        Class cls = obj.getClass();
        return addGlobal(getAllFunctions(cls), obj, cls, null);
    }
    public static boolean addGlobal(Class cls) {
        return addGlobal(getAllFunctions(cls), null, cls, null);
    }
    public static boolean addGlobal(Object obj, Class cls) {
        return addGlobal(getAllFunctions(cls), obj, cls, null);
    }
    public static boolean addGlobal(String function, Object obj) {
        return addGlobal(new String[] { function }, obj, obj.getClass(), null);
    }
    public static boolean addGlobal(String function, Object obj, String alias) {
        return addGlobal(new String[] { function }, obj, obj.getClass(), new String[] { alias });
    }
    /**add by ice*/
    public static boolean addGlobal(Method function, Object obj) {
        return addGlobal(new Method[] { function }, obj, null);
    }
    /**add by ice*/
    public static boolean addGlobal(Method function, Object obj, String alias) {
        return addGlobal(new Method[] { function }, obj, new String[] { alias });
    }
    /**add by ice*/
    public static boolean addGlobal(Method[] funcs, Object obj, String[] alias) {
        return add(funcs, obj, alias, globalFunctions);
    }
    public static boolean addGlobal(String[] functions, Object obj) {
        return addGlobal(functions, obj, obj.getClass(), null);
    }
    public static boolean addGlobal(String[] functions, Object obj, String[] aliases) {
        return addGlobal(functions, obj, obj.getClass(), aliases);
    }
    public static boolean addGlobal(String function, Class cls) {
        return addGlobal(new String[] { function }, null, cls, null);
    }
    public static boolean addGlobal(String function, Class cls, String alias) {
        return addGlobal(new String[] { function }, null, cls, new String[] { alias });
    }
    public static boolean addGlobal(String[] functions, Class cls) {
        return addGlobal(functions, null, cls, null);
    }
    public static boolean addGlobal(String[] functions, Class cls, String[] aliases) {
        return addGlobal(functions, null, cls, aliases);
    }
    public static boolean addGlobal(String function, Object obj, Class cls, String alias) {
        return addGlobal(new String[] { function }, obj, cls, new String[] { alias });
    }
    public static boolean addGlobal(String[] funcnames, Object obj, Class cls, String[] aliases) {
        return add(funcnames, obj, cls, aliases, globalFunctions);
    }
    public boolean add(Object obj) {
        Class cls = obj.getClass();
        return add(getAllFunctions(cls), obj, cls, null);
    }
    public boolean add(Class cls) {
        return add(getAllFunctions(cls), null, cls, null);
    }
    public boolean add(Object obj, Class cls) {
        return add(getAllFunctions(cls), obj, cls, null);
    }
    public boolean add(String function, Object obj) {
        return add(new String[] { function }, obj, obj.getClass(), null);
    }
    public boolean add(String function, Object obj, String alias) {
        return add(new String[] { function }, obj, obj.getClass(), new String[] { alias });
    }
    public boolean add(String[] functions, Object obj) {
        return add(functions, obj, obj.getClass(), null);
    }
    public boolean add(String[] functions, Object obj, String[] aliases) {
        return add(functions, obj, obj.getClass(), aliases);
    }
    public boolean add(String function, Class cls) {
        return add(new String[] { function }, null, cls, null);
    }
    public boolean add(String function, Class cls, String alias) {
        return add(new String[] { function }, null, cls, new String[] { alias });
    }
    public boolean add(String[] functions, Class cls) {
        return add(functions, null, cls, null);
    }
    public boolean add(String[] functions, Class cls, String[] aliases) {
        return add(functions, null, cls, aliases);
    }
    public boolean add(String function, Object obj, Class cls, String alias) {
        return add(new String[] { function }, obj, cls, new String[] { alias });
    }
    public boolean add(String[] funcnames, Object obj, Class cls, String[] aliases) {
        return add(funcnames, obj, cls, aliases, functions);
    }
    public void setCharset(String charset) {
        this.charset = charset;
        phpser.setCharset(charset);
    }
    public void setDebugMode(boolean debug) {
        this.debug = debug;
    }
    public void setEnableGZIP(boolean enableGZIP) {
        this.enableGZIP = enableGZIP;
    }
    public void start(HttpServletRequest request, HttpServletResponse response) throws IOException {
        this.request = request;
        this.response = response;
        response.resetBuffer();
        session = null;
        buffer = new StringBuffer();
        try {
            initErrorHandler();
            sendHeader();
            initClientID();
            initEncode();
            initCallback();
            initRef();
            initEncrypt();
            if (request.getParameter("phprpc_func") != null) {
                callFunction();
            }
            else if (encrypt != false || y != null) {
                keyExchange();
            }
            else {
                sendFunctions();
            }
        }
        catch (Throwable e) {
            errno = 1;
            if (debug) {
                StackTraceElement[] st = e.getStackTrace();
                StringBuffer es = new StringBuffer(e.toString()).append("\r\n");
                for (int i = 0, n = st.length; i < n; i++) {
                    es.append(st[i].toString()).append("\r\n");
                }
                errstr = es.toString();
            }
            else {
                errstr = e.toString();
            }
            sendError();
        }
    }
    /**add by ice*/
    public String getErrstr() {
        return errstr;
    }
}