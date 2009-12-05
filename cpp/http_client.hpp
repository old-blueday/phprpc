/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| http_client.hpp                                          |
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

/* http client library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Nov 27, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef HTTP_CLIENT_INCLUDED
#define HTTP_CLIENT_INCLUDED

#include "common.hpp"

namespace phprpc
{
	class http_client
	{
	public: // structors

		http_client()
		{
			curl_handle = curl_easy_init();

			curl_easy_setopt(curl_handle, CURLOPT_HTTP_VERSION, CURL_HTTP_VERSION_1_1);

			curl_easy_setopt(curl_handle, CURLOPT_HEADERFUNCTION, writer);
			curl_easy_setopt(curl_handle, CURLOPT_HEADERDATA, &header);

			curl_easy_setopt(curl_handle, CURLOPT_WRITEFUNCTION, writer);
			curl_easy_setopt(curl_handle, CURLOPT_WRITEDATA, &document);

			header_list = NULL;

			curl_easy_setopt(curl_handle, CURLOPT_HTTPHEADER, header_list);

			curl_easy_setopt(curl_handle, CURLOPT_SSLENGINE_DEFAULT, 1);
			curl_easy_setopt(curl_handle, CURLOPT_SSL_VERIFYPEER, 0);
			curl_easy_setopt(curl_handle, CURLOPT_SSL_VERIFYHOST, 0);
			curl_easy_setopt(curl_handle, CURLOPT_NOPROGRESS, 1);
			curl_easy_setopt(curl_handle, CURLOPT_NOSIGNAL, 1);
		}

		~http_client()
		{
			clear_header();
			curl_easy_cleanup(curl_handle);
		}

	public: // properties

		inline std::stringstream & get_header()
		{
			return header;
		}

		inline std::stringstream & get_document()
		{
			return document;
		}

		inline const CURLcode & get_curl_code() const
		{
			return curl_code;
		}

		inline const std::string & get_curl_code_desc() const
		{
			return curl_code_desc;
		}

		inline const int & get_response_code() const
		{
			return response_code;
		}

		inline const std::string & get_response_code_desc() const
		{
			return response_code_desc;
		}

	public:

		void set_cache_control(const char * cache_control)
		{
			append_header("Cache-Control", cache_control);
		}

		void set_connection(const char * connection)
		{
			append_header("Connection", connection);
		}

		void set_content_type(const char * content_type)
		{
			append_header("Content-Type", content_type);
		}

		inline void set_cookies(const char * cookies)
		{
			curl_easy_setopt(curl_handle, CURLOPT_COOKIE, cookies);
		}
		
		inline void set_encoding(const char * encoding)
		{
			curl_easy_setopt(curl_handle, CURLOPT_ENCODING, encoding);
		}

		inline void set_user_agent(const char * user_agent)
		{
			curl_easy_setopt(curl_handle, CURLOPT_USERAGENT, user_agent);
		}
		
		inline void set_proxy(const char * proxy)
		{
			curl_easy_setopt(curl_handle, CURLOPT_PROXY, proxy);
		}	
		
		inline void set_proxy_userpwd(const char * proxy_userpwd)
		{
			curl_easy_setopt(curl_handle, CURLOPT_PROXYUSERPWD, proxy_userpwd);
		}

		inline void set_proxy_type(const curl_proxytype proxy_type)
		{
			curl_easy_setopt(curl_handle, CURLOPT_PROXYTYPE, proxy_type);
		}
		
		void append_header(const std::string data)
		{
			header_list = curl_slist_append(header_list, data.c_str());
		}

		inline void append_header(const std::string name, const std::string value)
		{
			append_header(name + ": " + value);
		}

		void clear_header()
		{
			if (header_list)
			{
				curl_slist_free_all(header_list);
				header_list = NULL;
			}
		}

		std::stringstream & post(const std::string & url, const std::string & source)
		{
			curl_easy_setopt(curl_handle, CURLOPT_URL, url.c_str());

			curl_easy_setopt(curl_handle, CURLOPT_POST, true);
			curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDS, source.c_str());
			curl_easy_setopt(curl_handle, CURLOPT_POSTFIELDSIZE, source.size());

			header.clear();
			document.clear();

			curl_code = curl_easy_perform(curl_handle);

			if (curl_code == CURLE_OK)
			{
				curl_easy_getinfo(curl_handle, CURLINFO_RESPONSE_CODE, &response_code);

				getline(header, response_code_desc);
				std::ostringstream ss;
				ss << response_code;
				uint index = response_code_desc.find_first_of(ss.str());
				
				if (index != std::string::npos)
				{
					response_code_desc = response_code_desc.substr(index + ss.str().size() + 1);
				}
			}
			else
			{
				curl_code_desc = curl_easy_strerror(curl_code);
			}

			return document;
		}

	private:

		static uint writer(void * data, uint size, uint nmemb, std::stringstream & content)
		{
			uint sizes = size * nmemb;
			content << std::setw(sizes) << (char *)data;
			return sizes;
		}

	private:

		CURL * curl_handle;
		curl_slist * header_list;

		std::stringstream header;
		std::stringstream document;

		CURLcode curl_code;
		std::string curl_code_desc;

		int response_code;
		std::string response_code_desc;

	}; // class http_client
	
} // namespace phprpc

#endif
