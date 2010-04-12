/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| MD5.cs                                                   |
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

/* MD5 class.
 *
 * Copyright: Ma Bingyao <andot@ujn.edu.cn>
 * Version: 3.0
 * LastModified: Apr 12, 2010
 * This library is free.  You can redistribute it and/or modify it under GPL.
 */

namespace org.phprpc.util {
    public sealed class MD5 {
        private MD5() {
        }
		private static uint bitrol(uint n, byte c) {
			return (n << c) | (n >> (32 - c));
		}
		private static uint cmn(uint q, uint a, uint b, uint x, byte s, uint t) {
			return bitrol(a + q + x + t, s) + b;
		}
		private static uint ff(uint a, uint b, uint c, uint d, uint x, byte s, uint t) {
			return cmn((b & c) | ((~b) & d), a, b, x, s, t);
		}
		private static uint gg(uint a, uint b, uint c, uint d, uint x, byte s, uint t) {
			return cmn((b & d) | (c & (~d)), a, b, x, s, t);
		}
		private static uint hh(uint a, uint b, uint c, uint d, uint x, byte s, uint t) {
			return cmn(b ^ c ^ d, a, b, x, s, t);
		}
        private static uint ii(uint a, uint b, uint c, uint d, uint x, byte s, uint t) {
			return cmn(c ^ (b | (~d)), a, b, x, s, t);
		}
        private static uint[] unpack(byte[] data) {
            int length = data.Length;
            int count = ((length + 72) >> 6) << 4;
            uint[] x = new uint[count];
            for (int i = 0; i < length; i++) {
                x[i >> 2] |= (uint)data[i] << ((i & 3) << 3);
            }
            x[length >> 2] |= (uint)(0x80) << ((length & 3) << 3);
            ulong bitlen = ((ulong)length) << 3;
            x[count - 2] = (uint)(bitlen & 0xffffffff);
            x[count - 1] = (uint)(bitlen >> 32);
            return x;
        }
        public static byte[] Hash(byte[] data) {
            uint[] x = unpack(data);
            uint a = 0x67452301;
            uint b = 0xefcdab89;
            uint c = 0x98badcfe;
            uint d = 0x10325476;
            for (int i = 0, count = x.Length; i < count; i += 16) {
                uint olda = a;
                uint oldb = b;
                uint oldc = c;
                uint oldd = d;
                a = ff(a, b, c, d, x[i + 0], 7, 0xd76aa478);    /* 1 */
                d = ff(d, a, b, c, x[i + 1], 12, 0xe8c7b756);   /* 2 */
                c = ff(c, d, a, b, x[i + 2], 17, 0x242070db);   /* 3 */
                b = ff(b, c, d, a, x[i + 3], 22, 0xc1bdceee);   /* 4 */
                a = ff(a, b, c, d, x[i + 4], 7, 0xf57c0faf);    /* 5 */
                d = ff(d, a, b, c, x[i + 5], 12, 0x4787c62a);   /* 6 */
                c = ff(c, d, a, b, x[i + 6], 17, 0xa8304613);   /* 7 */
                b = ff(b, c, d, a, x[i + 7], 22, 0xfd469501);   /* 8 */
                a = ff(a, b, c, d, x[i + 8], 7, 0x698098d8);    /* 9 */
                d = ff(d, a, b, c, x[i + 9], 12, 0x8b44f7af);  /* 10 */
                c = ff(c, d, a, b, x[i + 10], 17, 0xffff5bb1); /* 11 */
                b = ff(b, c, d, a, x[i + 11], 22, 0x895cd7be); /* 12 */
                a = ff(a, b, c, d, x[i + 12], 7, 0x6b901122);  /* 13 */
                d = ff(d, a, b, c, x[i + 13], 12, 0xfd987193); /* 14 */
                c = ff(c, d, a, b, x[i + 14], 17, 0xa679438e); /* 15 */
                b = ff(b, c, d, a, x[i + 15], 22, 0x49b40821); /* 16 */

                // Round 2
                a = gg(a, b, c, d, x[i + 1], 5, 0xf61e2562);   /* 17 */
                d = gg(d, a, b, c, x[i + 6], 9, 0xc040b340);   /* 18 */
                c = gg(c, d, a, b, x[i + 11], 14, 0x265e5a51); /* 19 */
                b = gg(b, c, d, a, x[i + 0], 20, 0xe9b6c7aa);  /* 20 */
                a = gg(a, b, c, d, x[i + 5], 5, 0xd62f105d);   /* 21 */
                d = gg(d, a, b, c, x[i + 10], 9, 0x2441453);   /* 22 */
                c = gg(c, d, a, b, x[i + 15], 14, 0xd8a1e681); /* 23 */
                b = gg(b, c, d, a, x[i + 4], 20, 0xe7d3fbc8);  /* 24 */
                a = gg(a, b, c, d, x[i + 9], 5, 0x21e1cde6);   /* 25 */
                d = gg(d, a, b, c, x[i + 14], 9, 0xc33707d6);  /* 26 */
                c = gg(c, d, a, b, x[i + 3], 14, 0xf4d50d87);  /* 27 */
                b = gg(b, c, d, a, x[i + 8], 20, 0x455a14ed);  /* 28 */
                a = gg(a, b, c, d, x[i + 13], 5, 0xa9e3e905);  /* 29 */
                d = gg(d, a, b, c, x[i + 2], 9, 0xfcefa3f8);   /* 30 */
                c = gg(c, d, a, b, x[i + 7], 14, 0x676f02d9);  /* 31 */
                b = gg(b, c, d, a, x[i + 12], 20, 0x8d2a4c8a); /* 32 */

                // Round 3
                a = hh(a, b, c, d, x[i + 5], 4, 0xfffa3942);   /* 33 */
                d = hh(d, a, b, c, x[i + 8], 11, 0x8771f681);  /* 34 */
                c = hh(c, d, a, b, x[i + 11], 16, 0x6d9d6122); /* 35 */
                b = hh(b, c, d, a, x[i + 14], 23, 0xfde5380c); /* 36 */
                a = hh(a, b, c, d, x[i + 1], 4, 0xa4beea44);   /* 37 */
                d = hh(d, a, b, c, x[i + 4], 11, 0x4bdecfa9);  /* 38 */
                c = hh(c, d, a, b, x[i + 7], 16, 0xf6bb4b60);  /* 39 */
                b = hh(b, c, d, a, x[i + 10], 23, 0xbebfbc70); /* 40 */
                a = hh(a, b, c, d, x[i + 13], 4, 0x289b7ec6);  /* 41 */
                d = hh(d, a, b, c, x[i + 0], 11, 0xeaa127fa);  /* 42 */
                c = hh(c, d, a, b, x[i + 3], 16, 0xd4ef3085);  /* 43 */
                b = hh(b, c, d, a, x[i + 6], 23, 0x4881d05);   /* 44 */
                a = hh(a, b, c, d, x[i + 9], 4, 0xd9d4d039);   /* 45 */
                d = hh(d, a, b, c, x[i + 12], 11, 0xe6db99e5); /* 46 */
                c = hh(c, d, a, b, x[i + 15], 16, 0x1fa27cf8); /* 47 */
                b = hh(b, c, d, a, x[i + 2], 23, 0xc4ac5665);  /* 48 */

                // Round 4
                a = ii(a, b, c, d, x[i + 0], 6, 0xf4292244);   /* 49 */
                d = ii(d, a, b, c, x[i + 7], 10, 0x432aff97);  /* 50 */
                c = ii(c, d, a, b, x[i + 14], 15, 0xab9423a7); /* 51 */
                b = ii(b, c, d, a, x[i + 5], 21, 0xfc93a039);  /* 52 */
                a = ii(a, b, c, d, x[i + 12], 6, 0x655b59c3);  /* 53 */
                d = ii(d, a, b, c, x[i + 3], 10, 0x8f0ccc92);  /* 54 */
                c = ii(c, d, a, b, x[i + 10], 15, 0xffeff47d); /* 55 */
                b = ii(b, c, d, a, x[i + 1], 21, 0x85845dd1);  /* 56 */
                a = ii(a, b, c, d, x[i + 8], 6, 0x6fa87e4f);   /* 57 */
                d = ii(d, a, b, c, x[i + 15], 10, 0xfe2ce6e0); /* 58 */
                c = ii(c, d, a, b, x[i + 6], 15, 0xa3014314);  /* 59 */
                b = ii(b, c, d, a, x[i + 13], 21, 0x4e0811a1); /* 60 */
                a = ii(a, b, c, d, x[i + 4], 6, 0xf7537e82);   /* 61 */
                d = ii(d, a, b, c, x[i + 11], 10, 0xbd3af235); /* 62 */
                c = ii(c, d, a, b, x[i + 2], 15, 0x2ad7d2bb);  /* 63 */
                b = ii(b, c, d, a, x[i + 9], 21, 0xeb86d391);  /* 64 */
                a += olda;
                b += oldb;
                c += oldc;
                d += oldd;
            }
            byte[] result = new byte[16];
            result[0] = (byte)(a & 0xff);
            result[1] = (byte)((a >> 8) & 0xff);
            result[2] = (byte)((a >> 16) & 0xff);
            result[3] = (byte)((a >> 24) & 0xff);
            result[4] = (byte)(b & 0xff);
            result[5] = (byte)((b >> 8) & 0xff);
            result[6] = (byte)((b >> 16) & 0xff);
            result[7] = (byte)((b >> 24) & 0xff);
            result[8] = (byte)(c & 0xff);
            result[9] = (byte)((c >> 8) & 0xff);
            result[10] = (byte)((c >> 16) & 0xff);
            result[11] = (byte)((c >> 24) & 0xff);
            result[12] = (byte)(d & 0xff);
            result[13] = (byte)((d >> 8) & 0xff);
            result[14] = (byte)((d >> 16) & 0xff);
            result[15] = (byte)((d >> 24) & 0xff);
            return result;
        }
        public static string HexHash(byte[] data) {
            byte[] d = Hash(data);
            string s = string.Empty;
            for (int i = 0; i < 16; i++) {
                s += d[i].ToString("x2");
            }
            return s;
        }
    }
}