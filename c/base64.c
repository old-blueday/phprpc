/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| base64.c                                                 |
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
* LastModified: Dec 19, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#include "base64.h"

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

/**
 * Method:   base64_encode
 * @data:    Data to be encoded
 * @len:     Length of the data to be encoded
 * Returns:  Encoded data or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer.
 */
char * base64_encode(const unsigned char * data, size_t len)
{
	char *out, *pos;
	const unsigned char *in = data;
	size_t i, quot, rem;
	int c;

	if (!len) return NULL;
	
	quot = len / 3;
	rem  = len % 3;
	out = (char *)malloc((quot + (rem ? 1 : 0)) * 4 + 1);
	if (!out) return NULL;

	pos = out;
	
	for (i = 0; i < quot; i++)
	{
		c  = (0x000000ff & *in++) << 16;
		c |= (0x000000ff & *in++) << 8;
		c |=  0x000000ff & *in++;
		*pos++ = Base64EncodeChars[c >> 18];
		*pos++ = Base64EncodeChars[c >> 12 & 0x3f];
		*pos++ = Base64EncodeChars[c >> 6  & 0x3f];
		*pos++ = Base64EncodeChars[c & 0x3f];
	}

	if (rem == 1)
	{
		c = 0x000000ff & *in++;
		*pos++ = Base64EncodeChars[c >> 2];
		*pos++ = Base64EncodeChars[(c & 0x03) << 4];
		*pos++ = '=';
		*pos++ = '=';
	}
	else if(rem == 2)
	{
		c  = (0x000000ff & *in++) << 8;
		c |=  0x000000ff & *in++;
		*pos++ = Base64EncodeChars[c >> 10];
		*pos++ = Base64EncodeChars[c >> 4 & 0x3f];
		*pos++ = Base64EncodeChars[(c & 0x0f) << 2];
		*pos++ = '=';
	}

	*pos = '\0';
	
	return out;
}

/**
 * Method:   base64_decode
 * @data:    Data to be decoded
 * @out_len: Pointer to output length variable
 * Returns:  Decoded data or %NULL on failure
 *
 * Caller is responsible for freeing the returned buffer.
 */
unsigned char * base64_decode(const char * data, size_t * out_len)
{
	unsigned char *out, *pos;
	const unsigned char *in = data;
	size_t i, len, quot, rem, paddings = 0;
	int c;
	
	len = strlen(data);
	if (!len) return NULL;
	
	rem = len % 4;
	if (rem) return NULL; // invalid size
	
	quot = len / 4;
	if (data[len - 2] == '=')
		paddings = 2;
	else if (data[len - 1] == '=')
		paddings = 1;
	out = (unsigned char *)malloc(quot * 3 - paddings + 1);
	if (!out) return NULL;

	pos = out;	
	
	for (i = 0; i < quot; i++)
	{
		c  = Base64DecodeChars[(int)*in++] << 18;
		c += Base64DecodeChars[(int)*in++] << 12;
		*pos++ = (c & 0x00ff0000) >> 16;

		if (*in != '=')
		{
			c += Base64DecodeChars[(int)*in++] << 6;
			*pos++ = (c & 0x0000ff00) >> 8;

			if (*in != '=')
			{
				c += Base64DecodeChars[(int)*in++];
				*pos++ = c & 0x000000ff;
			}
		}
	}
	
	*pos = '\0';
	*out_len = pos - out;
	
	return out;
}

#ifdef PHPRPC_UNITTEST
void base64_encode_test_io(const char * in, const char * known)
{
	char *out;
	
	out = base64_encode((unsigned char *)in, strlen(in));
	assert(strcmp(out, known) == 0);
	free(out);
}

void base64_encode_test()
{
	base64_encode_test_io("f", "Zg==");
	base64_encode_test_io("fo", "Zm8=");
	base64_encode_test_io("foo", "Zm9v");
	base64_encode_test_io("foos", "Zm9vcw==");
	base64_encode_test_io("all your base64 are belong to foo", "YWxsIHlvdXIgYmFzZTY0IGFyZSBiZWxvbmcgdG8gZm9v");
}

void base64_decode_test_io(const char * in)
{
	char *encode_out;
	unsigned char *decode_out;
	size_t out_len;

	encode_out = base64_encode((unsigned char *)in, strlen(in));
	decode_out = base64_decode(encode_out, &out_len);
	assert((strcmp((char *)decode_out, in) == 0) && (out_len == strlen(in)));
	free(encode_out);
	free(decode_out);
}

void base64_decode_test()
{
	base64_decode_test_io("f");
	base64_decode_test_io("fo");
	base64_decode_test_io("foo");
	base64_decode_test_io("foos");
	base64_decode_test_io("all your base64 are belong to foo");
}
#endif