/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| xxtea.h                                                  |
|                                                          |
| Release 3.0                                              |
| Copyright by Team-PHPRPC                                 |
|                                                          |
| WebSite:  http://www.phprpc.org/                         |
|           http://www.phprpc.net/                         |
|           http://www.phprpc.com/                         |
|           http://sourceforge.net/projects/php-rpc/       |
|                                                          |
| Authors:  Chen fei <cf850118@163.com>                    |
|                                                          |
| This file may be distributed and/or modified under the   |
| terms of the GNU Lesser General Public License (LGPL)    |
| version 3.0 as published by the Free Software Foundation |
| and appearing in the included file LICENSE.              |
|                                                          |
\**********************************************************/

/* XXTEA encryption arithmetic library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Dec 7, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

module phprpc.util.XXTEA;

final class XXTEA
{
    private const uint delta = 0x9e3779b9;

    private this() {}

    /**
     * Method:   encrypt
     * FullName: XXTEA.encrypt
     * Access:   public static
     * @data:    Data to be encrypted
     * @key:     Symmetric key
     * Returns:  Encrypted data
     */
    public static ubyte[] encrypt(ubyte[] data, ubyte[] key)
    {
        if (data.length == 0) return data;

        return toUByteArray(encrypt(toUIntArray(data, true), toUIntArray(key, false)), false);
    }

    /**
     * Method:   decrypt
     * FullName: XXTEA.decrypt
     * Access:   public static
     * @data:    Data to be decrypted
     * @key:     Symmetric key
     * Returns:  Decrypted data
     */
    public static ubyte[] decrypt(ubyte[] data, ubyte[] key)
    {
        if (data.length == 0) return data;

        return toUByteArray(decrypt(toUIntArray(data, false), toUIntArray(key, false)), true);
    }

    /**
     * Method:   encrypt
     * FullName: XXTEA.encrypt
     * Access:   private static
     * @data:    Data to be encrypted
     * @key:     Symmetric key
     * Returns:  Encrypted data
     */
    private static uint[] encrypt(uint[] data, uint[] key)
    {
        uint n = data.length - 1;

        if (n < 1) return data;

        if (key.length < 4) key.length = 4;

        uint z = data[n], y = data[0], p, q = 6 + 52 / (n + 1), sum = 0, e;

        while (0 < q--)
        {
            sum += delta;
            e = sum >> 2 & 3;

            for (p = 0; p < n; p++)
            {
                y = data[p + 1];
                z = data[p] += (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (key[(p & 3) ^ e] ^ z));
            }

            y = data[0];
            z = data[n] += (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (key[(p & 3) ^ e] ^ z));
        }

        return data;
    }

    /**
     * Method:   decrypt
     * FullName: XXTEA.decrypt
     * Access:   private static
     * @data:    Data to be decrypted
     * @key:     Symmetric key
     * Returns:  Decrypted data
     */
    private static uint[] decrypt(uint[] data, uint[] key)
    {
        uint n = data.length - 1;

        if (n < 1) return data;

        if (key.length < 4) key.length = 4;

        uint z = data[n], y = data[0], p, q = 6 + 52 / (n + 1), sum = q * delta, e;

        while (sum != 0)
        {
            e = sum >> 2 & 3;

            for (p = n; p > 0; p--)
            {
                z = data[p - 1];
                y = data[p] -= (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (key[(p & 3) ^ e] ^ z));
            }

            z = data[n];
            y = data[0] -= (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (key[(p & 3) ^ e] ^ z));
            sum -= delta;
        }

        return data;
    }

    /**
     * Method:   toUIntArray
     * FullName: XXTEA.toUIntArray
     * Access:   private static
     * @data:    Data to be converted
     * @incLen: Including the length of the information?
     * Returns:  UInt array
     */
    private static uint[] toUIntArray(ubyte[] data, bool incLen)
    {
        uint[] result;

        uint len = data.length;
        uint n = (((len & 3) == 0) ? (len >> 2) : ((len >> 2) + 1));

        if (incLen)
        {
            result.length = n + 1;
            result[n] = len;
        }
        else
        {
            result.length = n;
        }

        for (uint i = 0; i < len; i++)
        {
            result[i >> 2] |= data[i] << ((i & 3) << 3);
        }

        return result;
    }

    /**
     * Method:   toUByteArray
     * FullName: XXTEA.toUByteArray
     * Access:   private static
     * @data:    Data to be converted
     * @incLen: Included the length of the information?
     * Returns:  UByte array
     */
    private static ubyte[] toUByteArray(uint[] data, bool incLen)
    {
        ubyte[] result;

        uint n = data.length << 2;

        if (incLen)
        {
            uint m = data[length - 1];
            if (m > n) return result;
            n = m;
        }

        result.length = n;

        for (uint i = 0; i < n; i++)
        {
            result[i] = data[i >> 2] >> ((i & 3) << 3);
        }

        return result;
    }

}
