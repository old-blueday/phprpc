/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| php_formator.hpp                                         |
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

/* PHP serialize/unserialize library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Nov 30, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef PHP_FORMATOR_INCLUDED
#define PHP_FORMATOR_INCLUDED

#include "common.hpp"

namespace phprpc
{
	// exceptions
	DeclareException(bad_serialize);
	DeclareException(bad_unserialize);

	// php serialize
	class php_writer
	{
	public:

		std::string serialize(const any & value)
		{
			buffer.str("");
			object_container.resize(1);

			serialize_any(value);

			return buffer.str();
		}

	private:

		void serialize_any(const any & value)
		{
			object_container.resize(object_container.size() + 1);

			const std::type_info & vtype = value.type();

			if (vtype == typeid(void))
			{
				serialize_null();
			}
			else if (vtype == typeid(bool))
			{
				serialize_bool(value);
			}
			else if (vtype == typeid(int))
			{
				serialize_int(value);
			}
			else if (vtype == typeid(int64))
			{
				serialize_int64((int64)value);
			}
			else if (vtype == typeid(uint64))
			{
				serialize_int64((uint64)value);
			}
			else if (vtype == typeid(real))
			{
				serialize_real(value);
			}
			else if (vtype == typeid(std::string))
			{
				serialize_string(value.value<std::string>());
			}
			else if (vtype == typeid(std::wstring))
			{
				serialize_string(value.value<std::wstring>());
			}
			else if (vtype == typeid(std::vector<any> *))
			{
				serialize_vector(value);
			}
			else if (vtype == typeid(any_unordered_map *))
			{
				serialize_hash_map(value);
			}
			else if (vtype == typeid(phprpc_object *))
			{
				serialize_object(value);
			}
			else
			{
				throw bad_serialize("this value can not to be serialize!");
			}
		}

		inline void serialize_null()
		{
			buffer << "N;";
		}

		inline void serialize_bool(const bool & value)
		{
			buffer << (value ? "b:1;" : "b:0;");
		}

		inline void serialize_int(const int & value)
		{
			buffer << "i:" << value << ";";
		}

		template<typename Type>
		inline void serialize_int64(const Type & value)
		{
			buffer << "d:" << value << ";";
		}

		inline void serialize_real(const real & value)
		{
			if (value != value)
			{
				buffer << "d:NAN;";
			}
			else if (value == Infinity)
			{
				buffer << "d:INF;";
			}
			else if (value == NegInfinity)
			{
				buffer << "d:-INF;";
			}
			else
			{
				buffer << "d:" << value << ";";
			}
		}

		inline void serialize_raw_string(const std::string & data)
		{
			buffer << "s:" << data.size() << ":\"" << data << "\";";
		}

		inline void serialize_raw_string(const std::wstring & data)
		{
			buffer << std::setfill('0');
			buffer << "U:" << data.size() << ":\"";

			std::wstring::const_iterator iter = data.begin();

			while (iter != data.end())
			{
				*iter > 127
					? (buffer << '\\' << std::hex << std::setw(4) << *iter++)
					: buffer << (char)*iter++;
			}

			buffer << "\";";
		}

		template<typename Type>
		void serialize_string(const Type & data)
		{
			int index = vector_index_of(object_container, data);

			if (index == -1)
			{
				*object_container.rbegin() = data;
				serialize_raw_string(data);
			}
			else
			{
				seiralize_ref(index);
			}
		}

		inline void seiralize_ref(int value)
		{
			buffer << "r:" << value << ";";
		}

		inline void seiralize_pointer_ref(int value)
		{
			buffer << "R:" << value << ";";
		}

		template<typename Type>
		inline void serialize_int64_key(const Type & value)
		{
			std::ostringstream ss;
			ss << value;
			serialize_raw_string(ss.str());
		}

		inline void serialize_real_key(const real & value)
		{
			if (value != value)
			{
				serialize_raw_string("NAN");
			}
			else if (value == Infinity)
			{
				serialize_raw_string("INF");
			}
			else if (value == NegInfinity)
			{
				serialize_raw_string("-INF");
			}
			else
			{
				std::ostringstream ss;
				serialize_raw_string(ss.str());
			}
		}

		void serialize_vector(std::vector<any> * data)
		{
			int index = vector_index_of(object_container, data);

			if (index == -1)
			{
				*object_container.rbegin() = data;

				buffer << "a:" << data->size() << ":{";

				for (size_t i = 0; i < data->size(); i++)
				{
					buffer << "i:" << i << ";";
					serialize_any((*data)[i]);
				}

				buffer << "}";
			}
			else
			{
				seiralize_pointer_ref(index);
			}
		}

		void serialize_hash_map(any_unordered_map * data)
		{
			int index = vector_index_of(object_container, data);

			if (index == -1)
			{
				*object_container.rbegin() = data;

				buffer << "a:" << data->size() << ":{";

				for (any_unordered_map::const_iterator iter = data->begin(); iter != data->end(); iter++)
				{
					const any & value = iter->first;
					const std::type_info & vtype = value.type();

					if (vtype == typeid(int))
					{
						serialize_int(value);
					}
					else if (vtype == typeid(int64))
					{
						serialize_int64_key((int64)value);
					}
					else if (vtype == typeid(uint64))
					{
						serialize_int64_key((uint64)value);
					}
					else if (vtype == typeid(real))
					{
						serialize_real_key(value);
					}
					else if (vtype == typeid(std::string))
					{
						serialize_raw_string(value.value<std::string>());
					}
					else if (vtype == typeid(std::wstring))
					{
						serialize_raw_string(value.value<std::wstring>());
					}
					else
					{
						continue; // ignore other type keys;
					}

					serialize_any(iter->second);
				}
				buffer << "}";
			}
			else
			{
				seiralize_pointer_ref(index);
			}
		}

		void serialize_object(phprpc_object *)
		{
			//
		}

	private:

		std::ostringstream buffer;
		std::vector<any> object_container;

	};

	// php unserialize
	class php_reader
	{
	public:

		any unserialize(const std::string & data)
		{
			buffer.str(data);
			object_container.clear();
			return unserialize_any();
		}

	private:

		any unserialize_any()
		{
			any retval;
			switch (char tag = buffer.rdbuf()->sbumpc())
			{
			case 'N':
				retval = NULL;
				object_container.push_back(retval);
				break;
			case 'b':
				retval = unserialize_bool();
				object_container.push_back(retval);
				break;
			case 'i':
				retval = unserialize_int();
				object_container.push_back(retval);
				break;
			case 'd':
				retval = unserialize_real();
				object_container.push_back(retval);
				break;
			case 's':
				retval = unserialize_string();
				object_container.push_back(retval);
				break;
			case 'S':
				retval = unserialize_encoded_string<std::string, char>();
				object_container.push_back(retval);
				break;
			case 'U':
				retval = unserialize_encoded_string<std::wstring, short>();
				object_container.push_back(retval);
				break;
			case 'r':
				retval = unserialize_ref();
				object_container.push_back(retval);
				break;
			case 'R':
				retval = unserialize_ref();
				break;
			case 'a':
				{
					int count = object_container.size();
					retval = unserialize_hash_map();
					object_container[count] = retval;
				}
				break;
			case 'O':
				{
					int count = object_container.size();
					retval = unserialize_object();
					object_container[count] = retval;
				}
				break;
			case 'C':
				break;
			default:
				throw bad_unserialize((std::string("Unexpected Tag: \"") + tag + std::string("\".")).c_str());
			}

			return retval;
		}

		bool unserialize_bool()
		{
			buffer.seekg(1, std::ios::cur);
			char value = buffer.rdbuf()->sbumpc();
			buffer.seekg(1, std::ios::cur);
			return value == '1';
		}

		int unserialize_int()
		{
			buffer.seekg(1, std::ios::cur);
			int value;
			buffer >> value;
			buffer.seekg(1, std::ios::cur);
			return value;
		}

		real unserialize_real()
		{
			buffer.seekg(1, std::ios::cur);
			real value;
			switch (buffer.rdbuf()->sbumpc())
			{
			case 'N':
				value = NaN;
				buffer.seekg(2, std::ios::cur);
				break;
			case 'I':
				value = Infinity;
				buffer.seekg(2, std::ios::cur);
				break;
			case '-':
				if (buffer.rdbuf()->sgetc() == 'I')
				{
					value = NegInfinity;
					buffer.seekg(3, std::ios::cur);
				}
				else
				{
					buffer.rdbuf()->sungetc();
					buffer >> value;
				}
				break;
			default:
				buffer.rdbuf()->sungetc();
				buffer >> value;
			};
			buffer.seekg(1, std::ios::cur);
			return value;
		}

		std::string unserialize_string()
		{
			std::string value;
			value.reserve(unserialize_int());
			buffer.seekg(1, std::ios::cur);
			std::getline(buffer, value, '"');
			buffer.seekg(1, std::ios::cur);
			return value;
		}

		template<typename StringType, typename ElemType>
		StringType unserialize_encoded_string()
		{
			StringType value;
			value.reserve(unserialize_int());
			buffer.seekg(1, std::ios::cur);
			std::istringstream conv;
			for (;;)
			{
				char c = buffer.rdbuf()->sbumpc();
				if (c == '\\')
				{
					char buf[sizeof(ElemType) * 2 + 1];
					for (uint i = 0; i < sizeof(ElemType) * 2; i++)
					{
						buf[i] = buffer.rdbuf()->sbumpc();
					}
					buf[sizeof(ElemType) * 2] = '\0';
					conv.str(buf);
					conv.seekg(0, std::ios::beg);
					ElemType elem;
					conv >> std::hex >> elem;
					value.push_back(elem);
				}
				else if (c == '"')
				{
					break;
				}
				else
				{
					value.push_back(c);
				}
			}
			buffer.seekg(1, std::ios::cur);
			return value;
		}

		any unserialize_ref()
		{
			return object_container[unserialize_int() - 1];
		}

		any_unordered_map * unserialize_hash_map()
		{
			any_unordered_map * value = new any_unordered_map;
			int len = unserialize_int();
			buffer.seekg(1, std::ios::cur);
			object_container.resize(object_container.size() + 1);
			any key;
			for (int i = 0; i < len; i++)
			{
				switch (char tag = buffer.rdbuf()->sbumpc())
				{
				case 'i':
					key = unserialize_int();
					break;
				case 's':
					key = unserialize_string();
					break;
				case 'S':
					key = unserialize_encoded_string<std::string, char>();
					break;
				case 'U':
					key = unserialize_encoded_string<std::wstring, short>();
					break;
				default:
					throw bad_unserialize((std::string("Unexpected Tag: \"") + tag + std::string("\".")).c_str());
				}
				(*value)[key] = unserialize_any();
			}
			buffer.seekg(1, std::ios::cur);
			return value;
		}

		phprpc_object * unserialize_object()
		{
			phprpc_object * value = reinterpret_cast<phprpc_object *>(phprpc_factory::create_object(unserialize_string()));

			if (value)
			{
				buffer.seekg(-1, std::ios::cur);
				int property_count = unserialize_int();
				buffer.seekg(1, std::ios::cur);

				for (int i = 0; i < property_count; i++)
				{
					buffer.seekg(1, std::ios::cur);
					std::string name = unserialize_string();
					(*value)[name] = unserialize_any();
				}

				return value;
			}
			else
			{
				return NULL;
			}
		}

	private:

		std::istringstream buffer;
		std::vector<any> object_container;

	};

}

#endif
