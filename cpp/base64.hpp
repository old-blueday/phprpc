/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| base64.hpp                                               |
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

/* Base64 library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Dec 5, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef BASE64_INCLUDED
#define BASE64_INCLUDED

#include "common.hpp"

namespace phprpc
{
	static const char Base64EncodeChars[] =
	{
		'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H',
		'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
		'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X',
		'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
		'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n',
		'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
		'w', 'x', 'y', 'z', '0', '1', '2', '3',
		'4', '5', '6', '7', '8', '9', '+', '/'
	};

	static const char Base64DecodeChars[] =
	{
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1,
		-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 62, -1, -1, -1, 63,
		52, 53, 54, 55, 56, 57, 58, 59, 60, 61, -1, -1, -1, -1, -1, -1,
		-1,  0,  1,  2,  3,  4,  5,  6,  7,  8,  9, 10, 11, 12, 13, 14,
		15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, -1, -1, -1, -1, -1,
		-1, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
		41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, -1, -1, -1, -1, -1
	};

	class base64
	{
	public:

		/**
		 * Method:   encode
		 * FullName: phprpc::base64::encode<Type>
		 * Access:   public static
         * $Type:    std::string, std::vector<char>, std::vector<signed char>, std::vector<unsigned char>		 
		 * @data:    Data to be encoded
		 * Returns:  Encoded data
		 */
		template<typename Type>
		static std::string encode(const Type & data)
		{
			std::string retval;

			if (data.empty()) return retval;

			size_t quot = data.size() / 3;
			size_t rem  = data.size() % 3;
			retval.reserve((quot + 1) * 4);

			Type::const_iterator iter = data.begin();

			for (size_t i = 0; i < quot; i++)
			{
				int c = (0x000000ff & *iter++) << 16 |
						(0x000000ff & *iter++) << 8  |
						(0x000000ff & *iter++);
				retval.push_back(Base64EncodeChars[c >> 18]);
				retval.push_back(Base64EncodeChars[c >> 12 & 0x3f]);
				retval.push_back(Base64EncodeChars[c >> 6  & 0x3f]);
				retval.push_back(Base64EncodeChars[c & 0x3f]);
			}

			if (rem == 1)
			{
				int c = 0x000000ff & *iter++;
				retval.push_back(Base64EncodeChars[c >> 2]);
				retval.push_back(Base64EncodeChars[(c & 0x03) << 4]);
				retval.push_back('=');
				retval.push_back('=');
			}
			else if(rem == 2)
			{
				int c = (0x000000ff & *iter++) << 8 |
						(0x000000ff & *iter++);
				retval.push_back(Base64EncodeChars[c >> 10]);
				retval.push_back(Base64EncodeChars[c >> 4 & 0x3f]);
				retval.push_back(Base64EncodeChars[(c & 0x0f) << 2]);
				retval.push_back('=');
			}

			return retval;
		}

		inline static std::string encode(const std::string & data)
		{
			return encode<std::string>(data);
		}
		
		/**
		 * Method:   decode
		 * FullName: phprpc::base64::decode<Type>
		 * Access:   public static
         * $Type:    std::string, std::vector<char>, std::vector<signed char>, std::vector<unsigned char>		 
		 * @data:    Data to be decodeed
		 * Returns:  Decodeed data
		 */
		template<typename Type>
		static Type decode(const std::string & data)
		{
			Type retval;

			if (data.empty()) return retval;

			size_t rem  = data.size() % 4;
			if (rem) return retval;
			
			size_t quot = data.size() / 4;
			retval.reserve(quot * 3);
			
			std::string::const_iterator iter = data.begin();

			for (size_t i = 0; i < quot; i++)
			{
				int c  = Base64DecodeChars[(int)*iter++] << 18;
					c += Base64DecodeChars[(int)*iter++] << 12;
				retval.push_back((c & 0x00ff0000) >> 16);

				if (*iter != '=')
				{
					c += Base64DecodeChars[(int)*iter++] << 6;
					retval.push_back((c & 0x0000ff00) >> 8);

					if (*iter != '=')
					{
						c += Base64DecodeChars[(int)*iter++];
						retval.push_back(c & 0x000000ff);
					}
				}
			}

			return retval;
		}

		inline static std::string decode(const std::string & data)
		{
			return decode<std::string>(data);
		}		
		
	}; // class base64
	
} // namespace phprpc

#endif