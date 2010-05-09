/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| DHParams.java                                            |
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

/* Diffie-Hellman Parameters for PHPRPC.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0.2
 * LastModified: Feb 25, 2009
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

package org.phprpc.util;

import java.io.InputStream;
import java.io.IOException;
import java.io.ByteArrayOutputStream;
import java.math.BigInteger;
import java.util.HashMap;
import java.util.Random;

public final class DHParams {
    private int length;
    private HashMap dhParams;
    private static final int[] lengths = {96, 128, 160, 192, 256, 512, 768, 1024, 1536, 2048, 3072, 4096};
    private static final HashMap dhParamsGen = new HashMap();
    static {
        try {
            PHPSerializer phpser = new PHPSerializer();
            for (int i = 0, n = lengths.length; i < n; i++) {
                String path = "/dhparams/" + lengths[i] + ".dhp";
                byte[] data = getBinaryFileFromJar(path);
                HashMap[] dhParams = (HashMap[])phpser.unserialize(data, HashMap[].class);
                dhParamsGen.put(new Integer(lengths[i]), dhParams);
            }
        }
        catch (Exception e) {
            e.printStackTrace();
        }
    }
    private static byte[] getBinaryFileFromJar(String path) throws IOException {
        InputStream is = DHParams.class.getResourceAsStream(path);
        if (is != null) {
            ByteArrayOutputStream bs = new ByteArrayOutputStream();
            byte[] bytes = new byte[4096];
            int read = 0;
            while ((read = is.read(bytes)) >= 0) {
                bs.write(bytes, 0, read);
            }
            return bs.toByteArray();
        }
        return null;
    }

    public static int getNearest(int n) {
        int j = 0;
        int m = Math.abs(lengths[0] - n);
        for (int i = 1; i < lengths.length; i++) {
            int t = Math.abs(lengths[i] - n);
            if (m > t) {
                m = t;
                j = i;
            }
        }
        return lengths[j];
    }
    public static HashMap getDHParams(int len) {
        HashMap[] dhParams = (HashMap[])dhParamsGen.get(new Integer(len));
        return dhParams[(int)Math.floor(Math.random() * dhParams.length)];
    }
    public DHParams(int len) {
        length = DHParams.getNearest(len);
        dhParams = DHParams.getDHParams(length);
    }
    public int getL() {
        return length;
    }
    public BigInteger getP() {
        return new BigInteger(Cast.toString(dhParams.get("p")));
    }
    public BigInteger getG() {
        return new BigInteger(Cast.toString(dhParams.get("g")));
    }
    public BigInteger getX() {
        return (new BigInteger(length - 1, new Random())).setBit(length - 2);
    }
    public HashMap getDHParams() {
        return dhParams;
    }
}