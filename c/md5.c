/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| md5.c                                                    |
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

/* MD5 Library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Dec 27, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#include "md5.h"

static const unsigned int Md5Sine[64] = 
{
	// Round 1.
	0xd76aa478, 0xe8c7b756, 0x242070db, 0xc1bdceee, 0xf57c0faf, 0x4787c62a,
	0xa8304613, 0xfd469501, 0x698098d8, 0x8b44f7af, 0xffff5bb1, 0x895cd7be,
	0x6b901122, 0xfd987193, 0xa679438e, 0x49b40821,
	// Round 2. 
	0xf61e2562, 0xc040b340, 0x265e5a51, 0xe9b6c7aa, 0xd62f105d, 0x02441453,
	0xd8a1e681, 0xe7d3fbc8, 0x21e1cde6, 0xc33707d6, 0xf4d50d87, 0x455a14ed,
	0xa9e3e905, 0xfcefa3f8, 0x676f02d9, 0x8d2a4c8a,
	// Round 3.
	0xfffa3942, 0x8771f681, 0x6d9d6122, 0xfde5380c, 0xa4beea44, 0x4bdecfa9,
	0xf6bb4b60, 0xbebfbc70, 0x289b7ec6, 0xeaa127fa, 0xd4ef3085, 0x04881d05,
	0xd9d4d039, 0xe6db99e5, 0x1fa27cf8, 0xc4ac5665,
	// Round 4.
	0xf4292244, 0x432aff97, 0xab9423a7, 0xfc93a039, 0x655b59c3, 0x8f0ccc92,
	0xffeff47d, 0x85845dd1, 0x6fa87e4f, 0xfe2ce6e0, 0xa3014314, 0x4e0811a1,
	0xf7537e82, 0xbd3af235, 0x2ad7d2bb, 0xeb86d391
};

/**
 * Method:   raw_md5
 * @data:    Data to be digested
 * @len:     Length of the data to be digested
 * @md:      Raw digested result buffer
 * Returns:  Raw digested data or %NULL on failure
 */
unsigned char * raw_md5(const unsigned char * data, size_t len, unsigned char * md)
{
	static char m[16];
	size_t i, count;
	unsigned int *x;
	unsigned int a = 0x67452301, b = 0xefcdab89, c = 0x98badcfe, d = 0x10325476;
	unsigned int oa, ob, oc, od;
	
	if (!md) md = m;
	count = ((len + 72) >> 6) << 4;
	x = (unsigned int *)calloc(count, sizeof(unsigned int));
	if (!x) return NULL;
	
	for (i = 0; i < len; i++)
	{
		x[i >> 2] |= data[i] << ((i & 3) << 3);
	}
	x[len >> 2] |= 0x00000080 << ((len & 3) << 3);
	x[count - 2] = (len & 0x1fffffff) << 3;
	x[count - 1] = (unsigned int)len >> 29;
		
	i = 0;
	while (i < count)
	{
		oa = a;
		ob = b;
		oc = c;
		od = d;

		// Round 1.
		a = ROL(a + (((d ^ c) & b) ^ d) + x[i +  0] + Md5Sine[ 0],  7) + b;
		d = ROL(d + (((c ^ b) & a) ^ c) + x[i +  1] + Md5Sine[ 1], 12) + a;
		c = ROL(c + (((b ^ a) & d) ^ b) + x[i +  2] + Md5Sine[ 2], 17) + d;
		b = ROL(b + (((a ^ d) & c) ^ a) + x[i +  3] + Md5Sine[ 3], 22) + c;
		a = ROL(a + (((d ^ c) & b) ^ d) + x[i +  4] + Md5Sine[ 4],  7) + b;
		d = ROL(d + (((c ^ b) & a) ^ c) + x[i +  5] + Md5Sine[ 5], 12) + a;
		c = ROL(c + (((b ^ a) & d) ^ b) + x[i +  6] + Md5Sine[ 6], 17) + d;
		b = ROL(b + (((a ^ d) & c) ^ a) + x[i +  7] + Md5Sine[ 7], 22) + c;
		a = ROL(a + (((d ^ c) & b) ^ d) + x[i +  8] + Md5Sine[ 8],  7) + b;
		d = ROL(d + (((c ^ b) & a) ^ c) + x[i +  9] + Md5Sine[ 9], 12) + a;
		c = ROL(c + (((b ^ a) & d) ^ b) + x[i + 10] + Md5Sine[10], 17) + d;
		b = ROL(b + (((a ^ d) & c) ^ a) + x[i + 11] + Md5Sine[11], 22) + c;
		a = ROL(a + (((d ^ c) & b) ^ d) + x[i + 12] + Md5Sine[12],  7) + b;
		d = ROL(d + (((c ^ b) & a) ^ c) + x[i + 13] + Md5Sine[13], 12) + a;
		c = ROL(c + (((b ^ a) & d) ^ b) + x[i + 14] + Md5Sine[14], 17) + d;
		b = ROL(b + (((a ^ d) & c) ^ a) + x[i + 15] + Md5Sine[15], 22) + c;

		// Round 2.
		a = ROL(a + (c ^ (d & (b ^ c))) + x[i +  1] + Md5Sine[16],  5) + b;
		d = ROL(d + (b ^ (c & (a ^ b))) + x[i +  6] + Md5Sine[17],  9) + a;
		c = ROL(c + (a ^ (b & (d ^ a))) + x[i + 11] + Md5Sine[18], 14) + d;
		b = ROL(b + (d ^ (a & (c ^ d))) + x[i +  0] + Md5Sine[19], 20) + c;
		a = ROL(a + (c ^ (d & (b ^ c))) + x[i +  5] + Md5Sine[20],  5) + b;
		d = ROL(d + (b ^ (c & (a ^ b))) + x[i + 10] + Md5Sine[21],  9) + a;
		c = ROL(c + (a ^ (b & (d ^ a))) + x[i + 15] + Md5Sine[22], 14) + d;
		b = ROL(b + (d ^ (a & (c ^ d))) + x[i +  4] + Md5Sine[23], 20) + c;
		a = ROL(a + (c ^ (d & (b ^ c))) + x[i +  9] + Md5Sine[24],  5) + b;
		d = ROL(d + (b ^ (c & (a ^ b))) + x[i + 14] + Md5Sine[25],  9) + a;
		c = ROL(c + (a ^ (b & (d ^ a))) + x[i +  3] + Md5Sine[26], 14) + d;
		b = ROL(b + (d ^ (a & (c ^ d))) + x[i +  8] + Md5Sine[27], 20) + c;
		a = ROL(a + (c ^ (d & (b ^ c))) + x[i + 13] + Md5Sine[28],  5) + b;
		d = ROL(d + (b ^ (c & (a ^ b))) + x[i +  2] + Md5Sine[29],  9) + a;
		c = ROL(c + (a ^ (b & (d ^ a))) + x[i +  7] + Md5Sine[30], 14) + d;
		b = ROL(b + (d ^ (a & (c ^ d))) + x[i + 12] + Md5Sine[31], 20) + c;
		
		// Round 3.
		a = ROL(a + (b ^ c ^ d) + x[i +  5] + Md5Sine[32],  4) + b;
		d = ROL(d + (a ^ b ^ c) + x[i +  8] + Md5Sine[33], 11) + a;
		c = ROL(c + (d ^ a ^ b) + x[i + 11] + Md5Sine[34], 16) + d;
		b = ROL(b + (c ^ d ^ a) + x[i + 14] + Md5Sine[35], 23) + c;
		a = ROL(a + (b ^ c ^ d) + x[i +  1] + Md5Sine[36],  4) + b;
		d = ROL(d + (a ^ b ^ c) + x[i +  4] + Md5Sine[37], 11) + a;
		c = ROL(c + (d ^ a ^ b) + x[i +  7] + Md5Sine[38], 16) + d;
		b = ROL(b + (c ^ d ^ a) + x[i + 10] + Md5Sine[39], 23) + c;
		a = ROL(a + (b ^ c ^ d) + x[i + 13] + Md5Sine[40],  4) + b;
		d = ROL(d + (a ^ b ^ c) + x[i +  0] + Md5Sine[41], 11) + a;
		c = ROL(c + (d ^ a ^ b) + x[i +  3] + Md5Sine[42], 16) + d;
		b = ROL(b + (c ^ d ^ a) + x[i +  6] + Md5Sine[43], 23) + c;
		a = ROL(a + (b ^ c ^ d) + x[i +  9] + Md5Sine[44],  4) + b;
		d = ROL(d + (a ^ b ^ c) + x[i + 12] + Md5Sine[45], 11) + a;
		c = ROL(c + (d ^ a ^ b) + x[i + 15] + Md5Sine[46], 16) + d;
		b = ROL(b + (c ^ d ^ a) + x[i +  2] + Md5Sine[47], 23) + c;

		// Round 4.
		a = ROL(a + ((b | (~d)) ^ c) + x[i +  0] + Md5Sine[48],  6) + b;
		d = ROL(d + ((a | (~c)) ^ b) + x[i +  7] + Md5Sine[49], 10) + a;
		c = ROL(c + ((d | (~b)) ^ a) + x[i + 14] + Md5Sine[50], 15) + d;
		b = ROL(b + ((c | (~a)) ^ d) + x[i +  5] + Md5Sine[51], 21) + c;
		a = ROL(a + ((b | (~d)) ^ c) + x[i + 12] + Md5Sine[52],  6) + b;
		d = ROL(d + ((a | (~c)) ^ b) + x[i +  3] + Md5Sine[53], 10) + a;
		c = ROL(c + ((d | (~b)) ^ a) + x[i + 10] + Md5Sine[54], 15) + d;
		b = ROL(b + ((c | (~a)) ^ d) + x[i +  1] + Md5Sine[55], 21) + c;
		a = ROL(a + ((b | (~d)) ^ c) + x[i +  8] + Md5Sine[56],  6) + b;
		d = ROL(d + ((a | (~c)) ^ b) + x[i + 15] + Md5Sine[57], 10) + a;
		c = ROL(c + ((d | (~b)) ^ a) + x[i +  6] + Md5Sine[58], 15) + d;
		b = ROL(b + ((c | (~a)) ^ d) + x[i + 13] + Md5Sine[59], 21) + c;
		a = ROL(a + ((b | (~d)) ^ c) + x[i +  4] + Md5Sine[60],  6) + b;
		d = ROL(d + ((a | (~c)) ^ b) + x[i + 11] + Md5Sine[61], 10) + a;
		c = ROL(c + ((d | (~b)) ^ a) + x[i +  2] + Md5Sine[62], 15) + d;
		b = ROL(b + ((c | (~a)) ^ d) + x[i +  9] + Md5Sine[63], 21) + c;

		a += oa;
		b += ob;
		c += oc;
		d += od;
		i += 16;
	}
	
	free(x);
	
	md[ 0] = a & 0xff;
	md[ 1] = (a >>  8) & 0xff;
	md[ 2] = (a >> 16) & 0xff;
	md[ 3] = (a >> 24) & 0xff;
	md[ 4] = b & 0xff;
	md[ 5] = (b >>  8) & 0xff;
	md[ 6] = (b >> 16) & 0xff;
	md[ 7] = (b >> 24) & 0xff;
	md[ 8] = c & 0xff;
	md[ 9] = (c >>  8) & 0xff;
	md[10] = (c >> 16) & 0xff;
	md[11] = (c >> 24) & 0xff;
	md[12] = d & 0xff;
	md[13] = (d >>  8) & 0xff;
	md[14] = (d >> 16) & 0xff;
	md[15] = (d >> 24) & 0xff;
	
	return md;
}

/**
 * Method:   hex_md5
 * @data:    Data to be digested
 * @len:     Length of the data to be digested
 * @md:      Hex digested result buffer
 * Returns:  Hex digested data or %NULL on failure
 */
char * hex_md5(const unsigned char * data, size_t len, char * md)
{
	static char m[33];
	unsigned char buf[16];
	int i;
	
	if (!md) md = m;
	if (!raw_md5(data, len, buf)) return NULL;
	
	for (i = 0; i < 16; i++)
	{
		sprintf(&md[i * 2], "%02x", buf[i]);
	}

	return md;
}

#ifdef PHPRPC_UNITTEST
void md5_test()
{
	char md[33];
	
    assert(strcmp(hex_md5((unsigned char *)"", 0, md), "d41d8cd98f00b204e9800998ecf8427e") == 0);
	assert(strcmp(hex_md5((unsigned char *)"a", 1, md), "0cc175b9c0f1b6a831c399e269772661") == 0);
	assert(strcmp(hex_md5((unsigned char *)"abc", 3, md), "900150983cd24fb0d6963f7d28e17f72") == 0);
	assert(strcmp(hex_md5((unsigned char *)"message digest", 14, md), "f96b697d7cb7938d525a2f31aaf161d0") == 0);
	assert(strcmp(hex_md5((unsigned char *)"abcdefghijklmnopqrstuvwxyz", 26, md), "c3fcd3d76192e4007dfb496cca67e13b") == 0);
	assert(strcmp(hex_md5((unsigned char *)"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789", 62, md), "d174ab98d277d9f5a5611c2c9f419d9f") == 0);
}
#endif