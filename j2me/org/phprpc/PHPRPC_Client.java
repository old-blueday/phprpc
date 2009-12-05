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

/* PHPRPC_Client class for J2ME.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Mar 8, 2009
 * This library is free.  You can redistribute it and/or modify it.
 *
/*
 * Example usage:
 *
import org.phprpc.PHPRPC_Client;

public class Test
{
    public static void main(String[] args) {
        PHPRPC_Client rpc = new PHPRPC_Client("http://www.phprpc.org/server.php");
        rpc.setKeyLength(1024);
        rpc.setEncryptMode(2);
        System.out.println(rf.invoke("add", new Object[2]{new Integer(1), new Integer(2)});
        System.out.println(rf.invoke("add", new Object[2]{new Double(1.5), new Integer(2)});
    }
}
 *
 */

package org.phprpc;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.security.DigestException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Date;
import java.util.Enumeration;
import java.util.Hashtable;
import java.util.Random;
import javax.microedition.io.Connector;
import javax.microedition.io.HttpConnection;
import org.phprpc.util.Base64;
import org.phprpc.util.BigInteger;
import org.phprpc.util.XXTEA;
import org.phprpc.util.Cast;
import org.phprpc.util.PHPSerializer;

public class PHPRPC_Client {
    protected PHPSerializer __phpser = null;
    private String __server = "";
    private PHPRPC_Error __warning = null;
    private byte[] __key = null;
    private int __keylen = 128;
    private int __encryptMode = 0;
    private boolean __keyExchanged = false;
    private String __charset = "utf-8";
    private String __output = "";
    private double __version = 3.0;
    private String __clientID = "";
    private static int __sID = 0;
    private static String __cookie = null;
    private static final Hashtable __cookies = new Hashtable();

    public PHPRPC_Client() {
        __clientID = "j2me" + String.valueOf(new Random().nextInt())
                            + String.valueOf(new Date().getTime())
                            + String.valueOf(__sID++);
    }

    public PHPRPC_Client(String serverURL) {
        this();
        useService(serverURL);
    }

    public final boolean useService(String serverURL) {
        __server = serverURL;
        if (__server.indexOf((int)'?') > -1) {
            __server = __server + "&phprpc_id=" + __clientID;
        }
        else {
            __server = __server + "?phprpc_id=" + __clientID;
        }
        __key = null;
        __keylen = 128;
        __encryptMode = 0;
        __keyExchanged = false;
        __phpser = new PHPSerializer();
        setCharset("utf-8");
        return true;
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

    public final void setCharset(String charset) {
        __charset = charset;
        __phpser.setCharset(__charset);
    }

    public final String getCharset() {
        return __charset;
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
        Hashtable response = invoke(function, args, byRef, __encryptMode);
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
                Hashtable response = self.invoke(function, args, byRef, encryptMode);
                if (response.get("result") instanceof PHPRPC_Error) {
                    callback.errorHandler((PHPRPC_Error)response.get("result"));
                }
                else {
                    try {
                        callback.handler(response.get("result"), args, (String)response.get("output"), (PHPRPC_Error)response.get("warning"));
                    }
                    catch (Exception ex) {
                        callback.errorHandler(ex);
                    }
                }
            }
        }).start();
    }

    public final Hashtable invoke(String function, Object[] args, boolean byRef, int encryptMode) {
        Hashtable response = new Hashtable();
        try {
            encryptMode = __keyExchange(encryptMode);
            StringBuffer requestBody = new StringBuffer();
            requestBody.append("phprpc_func=").append(function);
            if (args != null && args.length > 0) {
                requestBody.append("&phprpc_args=");
                requestBody.append(replaceAll(Base64.encode(__encrypt(__phpser.serialize(args), 1, encryptMode)), '+', "%2B"));
            }
            requestBody.append("&phprpc_encrypt=").append(encryptMode);
            if (!byRef) {
                requestBody.append("&phprpc_ref=false");
            }
            Hashtable result = __post(requestBody.toString());
            int errno = Integer.parseInt((String) result.get("phprpc_errno"));
            if (errno > 0) {
                String errstr = new String(Base64.decode((String) result.get("phprpc_errstr")), __charset);
                response.put("warning", new PHPRPC_Error(errno, errstr));
            }
            if (result.containsKey("phprpc_output")) {
                byte[] output = Base64.decode((String) result.get("phprpc_output"));
                if (__version >= 3) {
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
                Object r = __phpser.unserialize(__decrypt(Base64.decode((String) result.get("phprpc_result")), 2, encryptMode));
                if (r != null) {
                    response.put("result", r);
                }
            }
            else {
                if (response.get("warning") != null) {
                    response.put("result", response.get("warning"));
                }
            }
        }
        catch (PHPRPC_Error e) {
            response.put("result", e);
        }
        catch (Throwable e) {
            response.put("result", new PHPRPC_Error(1, e.toString()));
        }
        return response;
    }

    private final void __sendRequest(HttpConnection connection, String requestBody) throws IOException {
        byte[] rb = requestBody.getBytes();
        connection.setRequestMethod(HttpConnection.POST);
        connection.setRequestProperty("Connection", "close");
        connection.setRequestProperty("User-Agent", "PHPRPC Client 3.0 for J2ME");
        connection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded; charset=" + __charset);
        connection.setRequestProperty("Content-Length", new Integer(rb.length).toString());
        connection.setRequestProperty("Pragma", "no-cache");
        connection.setRequestProperty("Cache-Control", "no-cache");
        if (__cookie != null) {
            connection.setRequestProperty("Cookie", __cookie);
        }
        connection.setRequestProperty("Accept", "*/*");
        OutputStream os = connection.openOutputStream();
        os.write(rb);
        os.close();
    }

    private final void __addCookie(String cookie) {
        int p = cookie.indexOf('=');
        String name, value;
        if (p > -1) {
            name = cookie.substring(0, p);
            value = cookie.substring(p + 1);
        }
        else {
            name = cookie;
            value = "";
        }
        if (!name.equals("domain") && !name.equals("expires") &&
            !name.equals("path") && !name.equals("secure")) {
            __cookies.put(name, value);
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

    private final void __readResponseHeader(HttpConnection connection, String requestBody) throws IOException, PHPRPC_Error {
        __sendRequest(connection, requestBody);
        if (connection.getResponseCode() != connection.HTTP_OK) {
            throw new PHPRPC_Error(connection.getResponseCode(), connection.getResponseMessage());
        }
        int i = 0;
        String key, value;
        boolean hasCookie = false;
        double version = 0;
        while ((key = connection.getHeaderFieldKey(i)) != null) {
            key = key.toLowerCase();
            if (key.equals("x-powered-by")) {
                value = connection.getHeaderField(i);
                if (value.startsWith("PHPRPC Server/")) {
                    version = Double.parseDouble(value.substring(14));
                }
            }
            if (key.equals("set-cookie")) {
                hasCookie = true;
                synchronized(__cookies) {
                    value = connection.getHeaderField(i);
                    int p;
                    while ((p = value.indexOf(';', 0)) >= 0) {
                        String cookie = value.substring(0, p);
                        value = value.substring(p + 1).trim();
                        __addCookie(cookie);
                    }
                    if (!value.equals("")) {
                        __addCookie(value);
                    }
                }
            }
            i++;
        }
        if (version < 0) {
            throw new PHPRPC_Error(1, "Illegal PHPRPC server.");
        }
        else {
            __version = version;
        }
        if (hasCookie) {
            synchronized(__cookies) {
                __cookie = "";
                for (Enumeration keys = __cookies.keys(); keys.hasMoreElements();) {
                    key = (String) keys.nextElement();
                    value = (String) __cookies.get(key);
                    __cookie += key + "=" + value + "; ";
                }
            }
        }
        String contentType = connection.getType();
        if (contentType.toLowerCase().startsWith("text/plain; charset=")) {
            setCharset(contentType.substring(20));
        }
    }

    private final Hashtable __parseBody(byte[] responseBodyByteArray) throws IOException, PHPRPC_Error {
        ByteArrayInputStream is = new ByteArrayInputStream(responseBodyByteArray);
        Hashtable result = new Hashtable();
        String buf;
        while (!(buf = __readLine(is)).equals("")) {
            int p = buf.indexOf('=');
            if (p > -1) {
                result.put(buf.substring(0, p), buf.substring(p + 2, buf.length() - 2));
            }
        }
        return result;
    }

    private final Hashtable __readResponseBody(HttpConnection connection) throws IOException, PHPRPC_Error {
        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        InputStream is = connection.openInputStream();
        String te = connection.getHeaderField("transfer-encoding");
        if (te != null && te.toLowerCase().equals("chunked")) {
            String s = __readLine(is);
            if (s.equals("")) {
                is.close();
                connection.close();
                return new Hashtable();
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
                    is.close();
                    connection.close();
                    throw new PHPRPC_Error(1, "Response is incorrect.");
                }
                n = Integer.parseInt(__readLine(is), 16);
            }
            __readLine(is);
        }
        else if (connection.getLength() > 0) {
            int n = (int)connection.getLength();
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
        }
        is.close();
        connection.close();
        return __parseBody(baos.toByteArray());
    }

    private final Hashtable __post(String requestBody) throws IOException, PHPRPC_Error {
        HttpConnection connection = (HttpConnection)Connector.open(__server, Connector.READ_WRITE, true);
        Hashtable responseBody;
        try {
            __readResponseHeader(connection, requestBody);
            responseBody = __readResponseBody(connection);
        }
        catch (IOException e) {
            connection.close();
            throw e;
        }
        return responseBody;
    }

    private final synchronized int __keyExchange(int encryptMode) throws IOException, IllegalAccessException, NoSuchAlgorithmException, DigestException, PHPRPC_Error {
        if (__key != null || encryptMode == 0) {
            return encryptMode;
        }
        if (__key == null && __keyExchanged) {
            return 0;
        }
        Hashtable result = __post("phprpc_encrypt=true&phprpc_keylen=" + __keylen);
        if (result.containsKey("phprpc_keylen")) {
            __keylen = Integer.parseInt((String) result.get("phprpc_keylen"));
        }
        else {
            __keylen = 128;
        }
        if (result.containsKey("phprpc_encrypt")) {
            Hashtable encrypt = (Hashtable) __phpser.unserialize(Base64.decode((String) result.get("phprpc_encrypt")), Hashtable.class);
            BigInteger x = (new BigInteger(__keylen - 1, new Random())).setBit(__keylen - 2);
            BigInteger y = new BigInteger(Cast.toString(encrypt.get("y")));
            BigInteger p = new BigInteger(Cast.toString(encrypt.get("p")));
            BigInteger g = new BigInteger(Cast.toString(encrypt.get("g")));
            BigInteger k = y.modPow(x, p);
            byte[] key1, key2;
            if (__keylen == 128) {
                key1 = k.toByteArray();
                key2 = new byte[16];
                for (int i = 1, n = Math.min(key1.length, 16); i <= n; i++) {
                    key2[16 - i] = key1[key1.length - i];
                }
            }
            else {
                MessageDigest md5 = MessageDigest.getInstance("MD5");
                key1 = k.toString().getBytes();
                md5.update(key1, 0, key1.length);
                key2 = new byte[16];
                md5.digest(key2, 0, key2.length);
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

    private final String replaceAll(String s, char c, String r) {
        char[] cs = s.toCharArray();
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < cs.length; i++) {
            if (cs[i] == c) {
                sb.append(r);
            }
            else {
                sb.append(cs[i]);
            }
        }
        return sb.toString();
    }
}