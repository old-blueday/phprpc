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

import tango.io.Stdout;

final class XXTEA
{
    private static const uint Delta = 0x9e3779b9;

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

        uint[] data_array = to_uint_array(data, true);
        uint[] key_array  = to_uint_array(key, false);

        if (key_array.length < 4) key_array.length = 4;

        return to_ubyte_array(encrypt(data_array, key_array), false);
    }

    /**
     * Method:   decrypt
     * FullName: XXTEA.decrypt<Type>
     * Access:   public static
     * @data:    Data to be decrypted
     * @key:     Symmetric key
     * Returns:  Decrypted data
     */
    public static ubyte[] decrypt(ubyte[] data, ubyte[] key)
    {
        if (data.length == 0) return data;

        uint[] data_array = to_uint_array(data, false);
        uint[] key_array  = to_uint_array(key, false);

        if (key_array.length < 4) key_array.length = 4;

        return to_ubyte_array(decrypt(data_array, key_array), true);
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

        uint z = data[n], y = data[0], p, q = 6 + 52 / (n + 1), sum = 0, e;

        while (0 < q--)
        {
            sum += Delta;
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

        uint z = data[n], y = data[0], p, q = 6 + 52 / (n + 1), sum = q * Delta, e;

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
            sum -= Delta;
        }

        return data;
    }

    /**
     * Method:   to_uint_array
     * FullName: XXTEA.to_uint_array
     * Access:   private static
     * @data:    Data to be converted
     * @inc_len: Including the length of the information?
     * Returns:  UInt array
     */
    private static uint[] to_uint_array(ubyte[] data, bool inc_len)
    {
        uint[] rtn;

        uint len = data.length;
        uint n = (((len & 3) == 0) ? (len >> 2) : ((len >> 2) + 1));

        if (inc_len)
        {
            rtn.length = n + 1;
            rtn[n] = len;
        }
        else
        {
            rtn.length = n;
        }

        for (uint i = 0; i < len; i++)
        {
            rtn[i >> 2] |= cast(uint) data[i] << ((i & 3) << 3);
        }

        return rtn;
    }

    /**
     * Method:   to_ubyte_array
     * FullName: XXTEA.to_ubyte_array
     * Access:   private static
     * @data:    Data to be converted
     * @inc_len: Included the length of the information?
     * Returns:  UByte array
     */
    private static ubyte[] to_ubyte_array(uint[] data, bool inc_len)
    {
        ubyte[] rtn;

        uint n = data.length << 2;

        if (inc_len)
        {
            uint m = data[length - 1];
            if (m > n) return rtn;
            n = m;
        }

        rtn.length = n;

        for (uint i = 0; i < n; i++)
        {
            rtn[i] = cast(uint) (data[i >> 2] >> ((i & 3) << 3));
        }

        return rtn;
    }

}
