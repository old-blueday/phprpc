/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| xxtea.hpp                                                |
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
* LastModified: Nov 28, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef XXTEA_INCLUDED
#define XXTEA_INCLUDED

#include "common.hpp"

#define Delta 0x9e3779b9

namespace phprpc
{
	class xxtea
	{
	public:

		static std::string encrypt(const std::string & data, const std::string & key)
		{
			if (data.empty())
			{
				return data;
			}

            std::vector<uint> data_array = str_to_array(data, true);
            std::vector<uint> key_array  = str_to_array(key, false);

			return array_to_str(encrypt(data_array, key_array), false);
		}

		static std::string decrypt(const std::string & data, const std::string & key)
		{
			if (data.empty())
			{
				return data;
			}

            std::vector<uint> data_array = str_to_array(data, false);
            std::vector<uint> key_array  = str_to_array(key, false);

			return array_to_str(decrypt(data_array, key_array), true);
		}

	private:

		static std::vector<uint> encrypt(std::vector<uint> & v, std::vector<uint> & k)
		{
			int n = v.size() - 1;

			if (n < 1)
			{
				return v;
			}

			if (k.size() < 4)
			{
				k.resize(4);
			}

			uint z = v[n], y = v[0], sum = 0, e;
			int p, q = 6 + 52 / (n + 1);

			while (0 < q--)
			{
				sum += Delta;
				e = sum >> 2 & 3;

				for (p = 0; p < n; p++)
				{
					y = v[p + 1];
					z = v[p] += (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (k[(p & 3) ^ e] ^ z));
				}

				y = v[0];
				z = v[n] += (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (k[(p & 3) ^ e] ^ z));
			}

			return v;
		}

		static std::vector<uint> decrypt(std::vector<uint> & v, std::vector<uint> & k)
		{
			int n = v.size() - 1;

			if (n < 1)
			{
				return v;
			}

			if (k.size() < 4)
			{
				k.resize(4);
			}

			uint z = v[n], y = v[0], sum, e;
			int p, q = 6 + 52 / (n + 1);

			sum = (uint)(q * Delta);

			while (sum != 0)
			{
				e = sum >> 2 & 3;

				for (p = n; p > 0; p--)
				{
					z = v[p - 1];
					y = v[p] -= (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (k[(p & 3) ^ e] ^ z));
				}

				z = v[n];
				y = v[0] -= (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (k[(p & 3) ^ e] ^ z));
				sum -= Delta;
			}

			return v;
		}

		static std::vector<uint> str_to_array(const std::string & data, const bool include_length)
		{
            int length = data.size();
            int n = (((length & 3) == 0) ? (length >> 2) : ((length >> 2) + 1));

			std::vector<uint> retval;

            if (include_length)
			{
				retval.resize(n + 1);
                retval[n] = length;
            }
            else
			{
                retval.resize(n);
            }

            for (int i = 0; i < length; i++)
			{
                retval[i >> 2] |= (ubyte)data[i] << ((i & 3) << 3);
            }

            return retval;
		}

		static std::string array_to_str(const std::vector<uint> & data, const bool include_length)
		{
			int length = data.size();
			int n = length << 2;

			std::string retval;

			if (include_length)
			{
				int m = (int)data[length - 1];
				if (m > n)
				{
					return retval;
				}
				else
				{
					n = m;
				}
			}

			retval.resize(n);

			for (int i = 0; i < n; i++)
			{
				retval[i] = (char)(data[i >> 2] >> ((i & 3) << 3));
			}

			return retval;
		}

	}; // class xxtea

} // namespace phprpc

#endif
