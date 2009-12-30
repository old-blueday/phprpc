/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| utf8.hpp                                                 |
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

/* UTF8 encode/decode library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Nov 30, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef UTF8_INCLUDED
#define UTF8_INCLUDED

#include "common.hpp"
#ifdef WIN32
#include <windows.h>
#define UTF8Encode(data) ansi_to_utf8((data))
#define UTF8Decode(data) utf8_to_ansi((data))
#else
#define UTF8Encode(data) (data)
#define UTF8Decode(data) (data)
#endif

namespace phprpc
{
	std::string utf16_to_utf8(const std::wstring & data)
	{
		std::string retval;

		retval.reserve(data.size() * 3);
		std::wstring::const_iterator iter = data.begin();

		while (iter != data.end())
		{
			ushort wc = (ushort)*iter++;

			if (wc < 0x00000080)
			{
				retval.push_back((char)wc);
			}
			else if (wc < 0x00000800)
			{
				retval.push_back((char)(0xC0 | ((wc >> 6) & 0x1F)));
				retval.push_back((char)(0x80 | (wc & 0x3F)));
			}
			else
			{
				retval.push_back((char)(0xE0 | ((wc >> 12) & 0x0F)));
				retval.push_back((char)(0x80 | ((wc >> 6) & 0x3F)));
				retval.push_back((char)(0x80 | (wc & 0x3F)));
			}
		}

		return retval;
	}

	std::wstring utf8_to_utf16(const std::string & data)
	{
		std::wstring retval;

		retval.reserve(data.size());
		std::string::const_iterator iter = data.begin();

		while (iter != data.end())
		{
			char mb = *iter++;
			uint cc = 0;
			uint wc;

			while ((cc < 7) && (mb & (1 << (7 - cc))))
			{
				cc++;
			}

			if (cc == 1 || cc > 6)
			{
				continue;
			}

			if (cc == 0)
			{
				wc = mb;
			}
			else
			{
				wc = (mb & ((1 << (7 - cc)) - 1)) << ((cc - 1) * 6);
				while (--cc > 0)
				{
					mb = *iter++;
					if (((mb >> 6) & 0x03) != 2 )
					{
						return retval;
					}
					wc |= (mb & 0x3F) << ((cc - 1) * 6);
				}
			}

			if (wc & 0xFFFF0000)
			{
				wc = L'?';
			}
			retval.push_back(wc);
		}

		return retval;
	}

#ifdef WIN32
	std::string ansi_to_utf8(const std::string & data)
	{
		if (data.empty())
		{
			return "";
		}

		size_t len = data.size() + 1;
        wchar * ws = new wchar[len];

		MultiByteToWideChar(CP_ACP, 0, data.c_str(), (int)len, ws, (int)len * 2);

        std::string retval = utf16_to_utf8(ws);
        delete ws;

		return retval;
	}

	std::string utf8_to_ansi(const std::string & data)
	{
		if (data.empty())
		{
			return "";
		}

		size_t len = data.size() + 1;
		char * s = new char[len * 2];

		WideCharToMultiByte(CP_ACP, 0, utf8_to_utf16(data).c_str(), -1, s, (int)len * 2, NULL, NULL);

        std::string retval(s);
        delete s;

		return retval;
	}
#endif

} // namespace phprpc

#endif
