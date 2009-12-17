/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| md5.hpp                                                  |
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
* LastModified: Nov 30, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef MD5_INCLUDED
#define MD5_INCLUDED

#include "common.hpp"

#define ROL(Val, Shift) (((Val) << (Shift)) | ((Val) >> (32 - (Shift))))

namespace phprpc
{
	static const uint Md5Sine[64] = 
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
  
	class md5
	{
	public:

		/**
		 * Method:   raw
		 * FullName: phprpc::md5::raw<Type>
		 * Access:   public static
		 * $Type:    std::string, std::vector<char>, std::vector<signed char>, std::vector<unsigned char>
		 * @data:    Data to be digested
		 * Returns:  Raw digested data
		 */
		template<typename Type>		 
		static std::string raw(const Type & data)
		{
			std::vector<uint> x;
			
			uint len = data.size();
			uint count = ((len + 72) >> 6) << 4;
			
			x.resize(count);
			
			for (uint i = 0; i < len; i++)
			{
				x[i >> 2] |= ((ubyte)data[i]) << ((i & 3) << 3);
			}
			x[len >> 2] |= (uint)0x00000080 << ((len & 3) << 3);
			x[count - 2] = (len & 0x1fffffff) << 3;
			x[count - 1] = len >> 29;
  
			uint a = 0x67452301;
			uint b = 0xefcdab89;
			uint c = 0x98badcfe;
			uint d = 0x10325476;
			
			uint i = 0;
			while (i < count)
			{
				uint oa = a;
				uint ob = b;
				uint oc = c;
				uint od = d;

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

			std::string retval;
			
			retval.reserve(16);
			retval.push_back((char)(a & 0xff));
			retval.push_back((char)((a >>  8) & 0xff));
			retval.push_back((char)((a >> 16) & 0xff));
			retval.push_back((char)((a >> 24) & 0xff));
			retval.push_back((char)(b & 0xff));
			retval.push_back((char)((b >>  8) & 0xff));
			retval.push_back((char)((b >> 16) & 0xff));
			retval.push_back((char)((b >> 24) & 0xff));
			retval.push_back((char)(c & 0xff));
			retval.push_back((char)((c >>  8) & 0xff));
			retval.push_back((char)((c >> 16) & 0xff));
			retval.push_back((char)((c >> 24) & 0xff));
			retval.push_back((char)(d & 0xff));
			retval.push_back((char)((d >>  8) & 0xff));
			retval.push_back((char)((d >> 16) & 0xff));
			retval.push_back((char)((d >> 24) & 0xff));

			return retval;
		}

		/**
		 * Method:   hex
		 * FullName: phprpc::md5::hex<Type>
		 * Access:   public static
		 * $Type:    std::string, std::vector<char>, std::vector<signed char>, std::vector<unsigned char>
		 * @data:    Data to be digested
		 * Returns:  Hex digested data
		 */
		template<typename Type>		
		static std::string hex(const Type & data)
		{
			std::ostringstream ss;

			std::string bin = raw(data);
			std::string::const_iterator iter = bin.begin();
			
			ss << std::setfill('0');
			
			while (iter != bin.end())
			{
				ss << std::hex << std::setw(2) << (int)(ubyte)*iter++;
			}
			
			return ss.str();
		}
	
	}; // class md5

} // namespace phprpc

#endif