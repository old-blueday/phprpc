/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| phprpc_client.hpp                                        |
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

/* PHPRPC Client class.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Nov 30, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef PHPRPC_CLIENT_INCLUDED
#define PHPRPC_CLIENT_INCLUDED

#include "base64.hpp"
#include "bigint.hpp"
#include "md5.hpp"
#include "utf8.hpp"
#include "xxtea.hpp"
#include "http_client.hpp"
#include "php_formator.hpp"

namespace phprpc
{
	class phprpc_error
	{
	public: // structors

		phprpc_error()
		  : number(0)
		{
		}

		phprpc_error(int number)
		  : number(number)
		{
		}

		phprpc_error(int number, const std::string & message)
		  : number(number), message(message)
		{
		}

	public: // properties

		inline const int & get_number() const
		{
			return number;
		}

		inline const std::string & get_message() const
		{
			return message;
		}

		inline void set_number(int number)
		{
			this->number = number;
		}

		inline void set_message(const std::string & message)
		{
			this->message = message;
		}

	public:

		std::string to_string() const
		{
			std::stringstream ss;
			ss << *this;
			return ss.str();
		}

		friend std::ostream & operator<<(std::ostream & os, const phprpc_error & error)
		{
			return os << error.number << ":" << error.message;
		}

	private:

		int number;
		std::string message;

	}; // class phprpc_error

	typedef void (*phprpc_callback_func1)(const any & result);
	typedef void (*phprpc_callback_func2)(const any & result, const std::vector<any> & args);
	typedef void (*phprpc_callback_func3)(const any & result, const std::vector<any> & args, const std::string & output);
	typedef void (*phprpc_callback_func4)(const any & result, const std::vector<any> & args, const std::string & output, const phprpc_error & warning);

	class phprpc_callback
	{
	public: // structors

		phprpc_callback(const phprpc_callback_func1 callback_func1)
		  : callback_func1(callback_func1)
		{
		}

		phprpc_callback(const phprpc_callback_func2 callback_func2)
			: callback_func2(callback_func2)
		{
		}

		phprpc_callback(const phprpc_callback_func3 callback_func3)
			: callback_func3(callback_func3)
		{
		}

		phprpc_callback(const phprpc_callback_func4 callback_func4)
			: callback_func4(callback_func4)
		{
		}

	public:

		void do_callback()
		{
			if (callback_func1)
			{
				((phprpc_callback_func1)callback_func1)(result);
			}
			else if (callback_func1)
			{
				((phprpc_callback_func2)callback_func2)(result, args);
			}
			else if (callback_func3)
			{
				((phprpc_callback_func3)callback_func3)(result, args, output);
			}
			else if (callback_func4)
			{
				((phprpc_callback_func4)callback_func4)(result, args, output, warning);
			}
		}

	private:

		any result;
		std::vector<any> args;
		std::string output;
		phprpc_error warning;

		phprpc_callback_func1 callback_func1;
		phprpc_callback_func2 callback_func2;
		phprpc_callback_func3 callback_func3;
		phprpc_callback_func4 callback_func4;

	}; // class phprpc_callback

	class phprpc_client
	{
	public: // structors

		phprpc_client()
		{
			construct(std::string());
		}

		phprpc_client(const char * url)
		{
			construct(std::string(url));
		}

		phprpc_client(const std::string & url)
		{
			construct(url);
		}

	public: // properties

		inline const int & get_key_length() const
		{
			return key_length;
		}

		inline const int & get_encrypt_mode() const
		{
			return encrypt_mode;
		}

		inline const std::string & get_charset() const
		{
			return charset;
		}

		inline const std::string & get_output() const
		{
			return output;
		}

		inline bool set_key_length(int key_length)
		{
			if (!key.empty())
			{
				return false;
			}
			else
			{
				this->key_length = key_length;
				return true;
			}
		}

		inline bool set_encrypt_mode(int encrypt_mode)
		{
			if ((encrypt_mode >= 0) && (encrypt_mode <= 3))
			{
				this->encrypt_mode = encrypt_mode;
				return true;
			}
			else
			{
				this->encrypt_mode = 0;
				return false;
			}
		}

		inline void set_charset(const char * charset)
		{
			this->charset = charset;
		}

		inline void set_proxy(const char * proxy)
		{
			this->proxy = proxy;
		}

		inline void set_proxy_userpwd(const char * proxy_userpwd)
		{
			this->proxy_userpwd = proxy_userpwd;
		}

		inline void set_proxy_type(const curl_proxytype proxy_type)
		{
			this->proxy_type = proxy_type;
		}

	public:

		inline void use_service(const char * url)
		{
			use_service(std::string(url));
		}

		void use_service(const std::string & url)
		{
			this->url = url + ((url.find('?') == std::string::npos) ? "?phprpc_id=" : "&phprpc_id=") + client_id;
			encrypt_mode = 0;
			key.clear();
			key_length = 128;
			key_exchanged = false;
		}

		void invoke(const char * func_name, std::vector<any> * args, const phprpc_callback & callback, bool by_ref, int encrypt_mode)
		{
			//
		}

		any invoke(const char * func_name, std::vector<any> * args = NULL, bool by_ref = false)
		{
			any retval;

			any_unordered_map data = invoke(func_name, args, by_ref, encrypt_mode);

			if (data.find("warning") != data.end())
			{
				warning = data["warning"];
			}

			if (data.find("output") != data.end())
			{
				output = data["output"].value<std::string>();
			}
			else
			{
				output = "";
			}

			if (data.find("result") != data.end())
			{
				retval = data["result"];
			}

			return retval;
		}

		any_unordered_map invoke(const char * func_name, std::vector<any> * args, bool by_ref, int encrypt_mode)
		{
			std::stringstream buffer;

			encrypt_mode = key_exchange(encrypt_mode);

			buffer << "phprpc_func=" << func_name;;
			if ((args != NULL) && (!args->empty()))
			{
				std::string encode_args = base64::encode(encrypt(php_writer().serialize(args), 1, encrypt_mode));
				string_replace_all(encode_args, "+", "%2B");
				buffer << "&phprpc_args=" << encode_args;
			}
			buffer << "&phprpc_encrypt=" << encrypt_mode << "&phprpc_ref=" << std::boolalpha << by_ref << std::noboolalpha;

			any_unordered_map retval;
			any_unordered_map data = post(buffer.str());

			try
			{
				int err_no = data["phprpc_errno"];
				if (err_no)
				{
					retval["warning"] = phprpc_error(err_no, data["phprpc_errstr"]);
				}

				if (data.find("phprpc_output") != data.end())
				{
					std::string out_put = data["phprpc_output"];
					version >= 3
						? retval["output"] = decrypt(out_put, 3, encrypt_mode)
						: retval["output"] = out_put;
				}

				if (data.find("phprpc_result") != data.end())
				{
					if (data.find("phprpc_args") != data.end())
					{
						any_unordered_map * arguments = php_reader().unserialize(decrypt(data["phprpc_args"], 1, encrypt_mode));

						for (uint i = 0; i < args->size(); i++)
						{
							(*args)[i] = (*arguments)[i];
						}

						delete arguments;
					}
					retval["result"] = php_reader().unserialize(decrypt(data["phprpc_result"], 2, encrypt_mode));
				}
				else
				{
					retval["result"] = retval["warning"];
				}
			}
			catch (phprpc_error & e)
			{
				retval["warning"] = phprpc_error(1, e.to_string());
				retval["result"]  = retval["warning"];
			}

			return retval;
		}

	protected:

		any_unordered_map post(const std::string & data)
		{
			http_client client;
			any_unordered_map retval;

			try
			{
				client.clear_header();
				client.set_cache_control("no-cache");
				client.set_connection("keep-alive");
				client.set_content_type(("application/x-www-form-urlencoded; charset=" + charset).c_str());
				client.set_encoding("");
				client.set_user_agent("phprpc client for cpp");
				client.set_cookies(cookies.c_str());

				if (!proxy.empty())
				{
					client.set_proxy(proxy.c_str());

					if (proxy_type != CURLPROXY_HTTP) client.set_proxy_type(proxy_type);
					if (!proxy_userpwd.empty()) client.set_proxy_userpwd(proxy_userpwd.c_str());
				}

				client.post(url, data);

				double version = 0;

				if (client.get_curl_code() == CURLE_OK)
				{
					if (client.get_response_code() == 200)
					{
						std::string line;

						std::stringstream & header = client.get_header();
						while (getline(header, line, ':'))
						{
							transform(line.begin(), line.end(), line.begin(), tolower);
							if (line == "x-powered-by")
							{
								std::string strval;
								header.seekg(1, std::ios::cur);
								getline(header, strval, '/');
								transform(strval.begin(), strval.end(), strval.begin(), tolower);
								if (strval == "phprpc server")
								{
									header >> version;
								}
							}
							else if (line == "set-cookie")
							{
								header.seekg(1, std::ios::cur);
								getline(header, cookies);
							}
							header.ignore(1000, '\n');
						}

						if (version == 0)
						{
							throw phprpc_exception("Illegal PHPRPC Server!");
						}
						else
						{
							this->version = version;
						}

						std::stringstream & document = client.get_document();
						while (getline(document, line, '='))
						{
							if (line == "phprpc_errno" || line == "phprpc_keylen")
							{
								int intval;
								document.seekg(1, std::ios::cur);
								document >> intval;
								retval[line] = intval;
							}
							else
							{
								std::string strval;
								document.seekg(1, std::ios::cur);
								getline(document, strval, '"');
								retval[line] = base64::decode(strval);
							};
							document.ignore(100, '\n');
						}
					}
					else
					{
						retval["phprpc_errno"]  = client.get_response_code();
						retval["phprpc_errstr"] = client.get_response_code_desc();
					}
				}
				else
				{
					retval["phprpc_errno"]  = client.get_curl_code();
					retval["phprpc_errstr"] = client.get_curl_code_desc();
				}
			}
			catch(phprpc_error & e)
			{
				retval["phprpc_errno"]  = 1;
				retval["phprpc_errstr"] = e.to_string();
			}

			return retval;
		}

	private:

		void construct(const std::string & url)
		{
			srand(static_cast<uint>(time(0)));
			std::ostringstream ss;
			ss << "Cpp" << rand(0, MaxInt) << time(0);
			client_id = ss.str();
			charset = "utf-8";
			version = 3.0;
			use_service(url);
		}

		int key_exchange(int encrypt_mode)
		{
			if (!key.empty() || (encrypt_mode == 0))
			{
				return encrypt_mode;
			}

			if (key.empty() && key_exchanged)
			{
				return 0;
			}

			std::stringstream buffer;

			buffer << "phprpc_encrypt=true&phprpc_keylen=" << key_length;

			any_unordered_map data = post(buffer.str());

			key_length = (data.find("phprpc_keylen") != data.end())
				? (int)data["phprpc_keylen"]
				: key_length = 128;

			if (data.find("phprpc_encrypt") != data.end())
			{
				any_unordered_map * encrypt = php_reader().unserialize(data["phprpc_encrypt"]);

				bigint x(bigint::random(key_length - 1));
				bigint y((*encrypt)["y"].value<std::string>());
				bigint p((*encrypt)["p"].value<std::string>());
				bigint g((*encrypt)["g"].value<std::string>());

				delete encrypt;

				if (key_length == 128)
				{
					key.resize(16);
					std::string k = bigint::powmod(y, x, p).to_bin();
					const size_t & n = std::min<size_t>(k.size(), 16);
					for (uint i = 0; i < n; i++)
					{
						key[15 - i] = k[n - i - 1];
					}
				}
				else
				{
					key = md5::raw(bigint::powmod(y, x, p).to_string());
				}

				post("phprpc_encrypt=" + bigint::powmod(g, x, p).to_string());
			}
			else
			{
				key = "";
				key_exchanged = true;
				encrypt_mode = 0;
			}

			return encrypt_mode;
		}

		std::string encrypt(const std::string & data, int level, int encryptMode)
		{
			if ((!key.empty()) && (encrypt_mode >= level))
			{
				return xxtea::encrypt(data, key);
			}
			else
			{
				return data;
			}
		}

		std::string decrypt(const std::string & data, int level, int encryptMode)
		{
			if ((!key.empty()) && (encrypt_mode >= level))
			{
				return xxtea::decrypt(data, key);
			}
			else
			{
				return data;
			}
		}

	private:

		std::string client_id;
		std::string charset;
		std::string url;
		std::string key;
		std::string output;

		std::string cookies;

		curl_proxytype proxy_type;
		std::string proxy;
		std::string proxy_userpwd;

		bool key_exchanged;
		int  key_length;
		int  encrypt_mode;

		double version;

		phprpc_error warning;

	}; // class phprpc_client

} // namespace phprpc

#endif
