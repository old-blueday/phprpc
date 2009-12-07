/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| xxtea.c                                                  |
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

#include "xxtea.h"

/**
 * Method:   xxtea_to_uint_array 
 * @data:    Data to be converted
 * @len:     Length of the data to be converted
 * @inc_len: Including the length of the information?
 * @out_len: Pointer to output length variable
 * Returns:  UInt array or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer.
 */
unsigned int * xxtea_to_uint_array(const unsigned char * data, size_t len, int inc_len, size_t * out_len)
{
	unsigned int *out;
	size_t i, n;
    
	n = (((len & 3) == 0) ? (len >> 2) : ((len >> 2) + 1));

	if (inc_len)
	{
		out = (unsigned int *)calloc(n + 1, sizeof(unsigned int));
		if (!out) return NULL;
		out[n] = len;
		*out_len = n + 1;
	}
	else
	{
		out = (unsigned int *)calloc(n, sizeof(unsigned int));
		if (!out) return NULL;
		*out_len = n;
	}

	for (i = 0; i < len; i++)
	{
		out[i >> 2] |= (unsigned int)data[i] << ((i & 3) << 3);
	}

	return out;
}

/**
 * Method:   xxtea_to_ubyte_array	 
 * @data:    Data to be converted
 * @len:     Length of the data to be converted
 * @inc_len: Included the length of the information?
 * @out_len: Pointer to output length variable
 * Returns:  UByte array or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer.
 */
unsigned char * xxtea_to_ubyte_array(const unsigned int * data, size_t len, int inc_len, size_t * out_len)
{
	unsigned char *out;
	size_t i, m, n;
			
	n = len << 2;
			
	if (inc_len)
	{
		m = data[len - 1];
		if (m > n) return NULL;
		n = m;
	}

	out = (unsigned char *)malloc(n + 1);

	for (i = 0; i < n; i++)
	{
		out[i] = (unsigned char)(data[i >> 2] >> ((i & 3) << 3));
	}
	
	out[n] = '\0';
	*out_len = n;
	
	return out;
}

/**
 * Method:   xxtea_uint_encrypt
 * @data:    Data to be encrypted
 * @len:     Length of the data to be encrypted
 * @key:     Symmetric key
 * Returns:  Encrypted data
 */
unsigned int * xxtea_uint_encrypt(unsigned int * data, size_t len, unsigned int * key)
{
	size_t n = len - 1;
	unsigned int z = data[n], y = data[0], p, q = 6 + 52 / (n + 1), sum = 0, e;
	
	if (n < 1) return data;

	while (0 < q--)
	{
		sum += DELTA;
		e = sum >> 2 & 3;

		for (p = 0; p < n; p++)
		{
			y = data[p + 1];
			z = data[p] += MX;
		}

		y = data[0];
		z = data[n] += MX;
	}

	return data;
}

/**
 * Method:   xxtea_uint_decrypt
 * @data:    Data to be decrypted
 * @len:     Length of the data to be decrypted
 * @key:     Symmetric key
 * Returns:  Decrypted data
 */
unsigned int * xxtea_uint_decrypt(unsigned int * data, size_t len, unsigned int * key)
{
	size_t n = len - 1;
	unsigned int z = data[n], y = data[0], p, q = 6 + 52 / (n + 1), sum = (unsigned int)(q * DELTA), e;

	if (n < 1) return data;
	
	while (sum != 0)
	{
		e = sum >> 2 & 3;

		for (p = n; p > 0; p--)
		{
			z = data[p - 1];
			y = data[p] -= MX;
		}

		z = data[n];
		y = data[0] -= MX;
		sum -= DELTA;
	}

	return data;
}

/**
 * Method:   encrypt
 * @data:    Data to be encrypted
 * @len:     Length of the data to be encrypted
 * @key:     Symmetric key
 * @out_len: Pointer to output length variable 
 * Returns:  Encrypted data or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer.
 */
unsigned char * xxtea_encrypt(const unsigned char * data, size_t len, const unsigned char * key, size_t * out_len)
{
	unsigned int *data_array, *key_array;
	size_t data_len, key_len;
	
	if (!len) return NULL;

	data_array = xxtea_to_uint_array(data, len, 1, &data_len);
	key_array  = xxtea_to_uint_array(key, 16, 0, &key_len);

	if ((!data_array) || (!key_array)) return NULL;
	
	return xxtea_to_ubyte_array(xxtea_uint_encrypt(data_array, data_len, key_array), data_len, 0, out_len);
}

/**
 * Method:   decrypt
 * @data:    Data to be decrypted
 * @len:     Length of the data to be decrypted
 * @key:     Symmetric key
 * @out_len: Pointer to output length variable 
 * Returns:  Decrypted data or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer.
 */
unsigned char * xxtea_decrypt(const unsigned char * data, size_t len, const unsigned char * key, size_t * out_len)
{
	unsigned int *data_array, *key_array;
	size_t data_len, key_len;
	
	if (!len) return NULL;

	data_array = xxtea_to_uint_array(data, len, 0, &data_len);
	key_array  = xxtea_to_uint_array(key, 16, 0, &key_len);

	if ((!data_array) || (!key_array)) return NULL;
	
	return xxtea_to_ubyte_array(xxtea_uint_decrypt(data_array, data_len, key_array), data_len, 1, out_len);
}

