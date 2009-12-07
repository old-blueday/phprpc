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
* LastModified: Dec 6, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef XXTEA_INCLUDED
#define XXTEA_INCLUDED

#include "common.hpp"

#define Mx (((z >> 5) ^ (y << 2)) + ((y >> 3) ^ (z << 4))) ^ ((sum ^ y) + (key[(p & 3) ^ e] ^ z))
#define Delta 0x9e3779b9

namespace phprpc
{
	class xxtea
	{
	public:

		/**
		 * Method:   encrypt
		 * FullName: phprpc::xxtea::encrypt<Type>
		 * Access:   public static
		 * $Type:    std::string, std::vector<char>, std::vector<signed char>, std::vector<unsigned char>		 
		 * @data:    Data to be encrypted
		 * @key:     Symmetric key
		 * Returns:  Encrypted data
		 */
		template<typename Type> 
		static Type encrypt(const Type & data, const std::string & key)
		{
			if (data.empty()) return data;

            std::vector<uint> data_array = to_uint_array(data, true);
            std::vector<uint> key_array  = to_uint_array(key, false);

			if (key_array.size() < 4) key_array.resize(4);
			
			return to_ubyte_array<std::string>(encrypt(data_array, key_array), false);
		}
		
		inline static std::string encrypt(const std::string & data, const std::string & key)
		{
			return encrypt<std::string>(data, key);
		}

		/**
		 * Method:   decrypt
		 * FullName: phprpc::xxtea::decrypt<Type>
		 * Access:   public static
		 * $Type:    std::string, std::vector<char>, std::vector<signed char>, std::vector<unsigned char>		 
		 * @data:    Data to be decrypted
		 * @key:     Symmetric key
		 * Returns:  Decrypted data
		 */
		template<typename Type>
		static Type decrypt(const Type & data, const std::string & key)
		{
			if (data.empty()) return data;

            std::vector<uint> data_array = to_uint_array(data, false);
            std::vector<uint> key_array  = to_uint_array(key, false);

			if (key_array.size() < 4) key_array.resize(4);
			
			return to_ubyte_array<Type>(decrypt(data_array, key_array), true);
		}

		inline static std::string decrypt(const std::string & data, const std::string & key)
		{
			return decrypt<std::string>(data, key);
		}		
		
	private:

		/**
		 * Method:   encrypt
		 * FullName: phprpc::xxtea::encrypt
		 * Access:   private static 
		 * @data:    Data to be encrypted
		 * @key:     Symmetric key
		 * Returns:  Encrypted data
		 */
		static std::vector<uint> & encrypt(std::vector<uint> & data, std::vector<uint> & key)
		{
			size_t n = data.size() - 1;

			if (n < 1) return data;
			
			uint z = data[n], y = data[0], p, q = 6 + 52 / (n + 1), sum = 0, e;

			while (0 < q--)
			{
				sum += Delta;
				e = sum >> 2 & 3;

				for (p = 0; p < n; p++)
				{
					y = data[p + 1];
					z = data[p] += Mx;
				}

				y = data[0];
				z = data[n] += Mx;
			}

			return data;
		}

		/**
		 * Method:   decrypt
		 * FullName: phprpc::xxtea::decrypt
		 * Access:   private static 
		 * @data:    Data to be decrypted
		 * @key:     Symmetric key
		 * Returns:  Decrypted data
		 */
		static std::vector<uint> & decrypt(std::vector<uint> & data, std::vector<uint> & key)
		{
			size_t n = data.size() - 1;

			if (n < 1) return data;

			uint z = data[n], y = data[0], p, q = 6 + 52 / (n + 1), sum = (uint)(q * Delta), e;

			while (sum != 0)
			{
				e = sum >> 2 & 3;

				for (p = n; p > 0; p--)
				{
					z = data[p - 1];
					y = data[p] -= Mx;
				}

				z = data[n];
				y = data[0] -= Mx;
				sum -= Delta;
			}

			return data;
		}

		/**
		 * Method:   to_uint_array
		 * FullName: phprpc::xxtea::to_uint_array<Type>
		 * Access:   private static
		 * $Type:    std::string, std::vector<char>, std::vector<signed char>, std::vector<unsigned char>		 
		 * @data:    Data to be converted
		 * @inc_len: Including the length of the information?
		 * Returns:  UInt array
		 */	
		template<typename Type>
		static std::vector<uint> to_uint_array(const Type & data, const bool inc_len)
		{
			std::vector<uint> retval;
			
            size_t len = data.size();
            size_t n = (((len & 3) == 0) ? (len >> 2) : ((len >> 2) + 1));

            if (inc_len)
			{
				retval.resize(n + 1);
                *retval.rbegin() = len;
            }
            else
			{
                retval.resize(n);
            }

            for (size_t i = 0; i < len; i++)
			{
                retval[i >> 2] |= (uint)(ubyte)(data[i]) << ((i & 3) << 3);
            }

            return retval;
		}

		/**
		 * Method:   to_ubyte_array
		 * FullName: phprpc::xxtea::to_ubyte_array<Type>
		 * Access:   private static
		 * $Type:    std::string, std::vector<char>, std::vector<signed char>, std::vector<unsigned char>		 
		 * @data:    Data to be converted
		 * @inc_len: Included the length of the information?
		 * Returns:  UByte array
		 */
		template<typename Type>		 
		static Type to_ubyte_array(const std::vector<uint> & data, const bool inc_len)
		{
			Type retval;
			
			size_t n = data.size() << 2;
			
			if (inc_len)
			{
				size_t m = *data.rbegin();
				if (m > n) return retval;
				n = m;
			}

			retval.reserve(n);

			for (size_t i = 0; i < n; i++)
			{
				retval.push_back(data[i >> 2] >> ((i & 3) << 3));
			}

			return retval;
		}

	}; // class xxtea

} // namespace phprpc

#endif
