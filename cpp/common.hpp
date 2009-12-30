/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| common.hpp                                               |
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

/* Common type defines.
*
* phprpc::any modified from boost::any(Copyright: Kevlin Henney)
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Dec 18, 2009
* This library is free.  You can redistribute it and/or modify it.
*/

#ifndef PHPRPC_COMMON_INCLUDED
#define PHPRPC_COMMON_INCLUDED

#include <curl/curl.h>

#include <algorithm>
#include <iomanip>
#include <sstream>
#include <typeinfo>
#include <vector>

#ifdef __BORLANDC__
#include <unordered_map>
#include <boost/functional/hash.hpp>
#else
#include <boost/unordered_map.hpp>
#endif

// compatibility

#ifdef __BORLANDC__
#define UnorderdMap    std::tr1::unordered_map
#define AnyCast(Type)  const Type &
#else
#define UnorderdMap    boost::unordered_map
#define AnyCast(Type)  Type
#endif

// some useful macros

#ifdef __BORLANDC__
#define NaN           0.0/0.0
#define Infinity      1.0/1.0
#define NegInfinity (-1.0/1.0)
#else
#define NaN           std::log((real)-1)
#define Infinity    (-std::log((real) 0))
#define NegInfinity   std::log((real) 0)
#endif

#define MaxInt        2147483647
#define MinInt      (-2147483647-1)

inline void * operator new(size_t size, void * ptr, int le, char ch)
{     
	return ptr;
};

namespace phprpc
{
	// type defines

	typedef wchar_t            wchar;
	typedef signed char        byte;
	typedef unsigned char      ubyte;
	typedef unsigned short     ushort;
	typedef unsigned int       uint;
	typedef unsigned long      ulong;
	typedef long long          int64;
	typedef unsigned long long uint64;
	typedef long double        real;

	// base of all phprpc exceptions
	class phprpc_exception: public std::exception
	{
	public:

		explicit phprpc_exception(const char * message)
		  : message(message)
		{
		}

		virtual ~phprpc_exception() throw()
		{
		}

		virtual const char * what() const throw()
		{
			return this->message.c_str();
		}

	private:

		std::string message;

	};

#define DeclareException(ClassName) \
	class ClassName: public phprpc_exception \
	{ \
	public: \
		explicit ClassName(const char * message) : phprpc_exception(message) {} \
		virtual ~ClassName() throw() {} \
	}
	
	DeclareException(bad_any_cast);

	class any
	{
	public: // structors

		any()
		  : content(0)
		{
		}

		any(const bool & value)
		  : content(new holder<bool>(value))
		{
		}

		any(const byte & value)
		  : content(new holder<int>((int)value))
		{
		}

		any(const ubyte & value)
		 : content(new holder<int>((int)value))
		{
		}

		any(const short & value)
		 : content(new holder<int>((int)value))
		{
		}

		any(const ushort & value)
		  : content(new holder<int>((int)value))
		{
		}

		any(const long & value)
		{
			if (sizeof(long) == sizeof(int))
			{
				content = new holder<int>((int)value);
			}
			else
			{
				if ((value >= MinInt) && (value <= MaxInt))
				{
					content = new holder<int>((int)value);
				}
				else
				{
					content = new holder<int64>(value);
				}
			}
		}

		any(const int64 & value)
		{
			if ((value >= MinInt) && (value <= MaxInt))
			{
				content = new holder<int>((int)value);
			}
			else
			{
				content = new holder<int64>(value);
			}
		}

		any(const uint & value)
		{
			if ((value) <= MaxInt)
			{
				content = new holder<int>((int)value);
			}
			else
			{
				content = new holder<uint64>((uint64)value);
			}
		}

		any(const ulong & value)
		{
			if ((value) <= MaxInt)
			{
				content = new holder<int>((int)value);
			}
			else
			{
				content = new holder<uint64>((uint64)value);
			}
		}

		any(const uint64 & value)
		{
			if ((value) <= MaxInt)
			{
				content = new holder<int>((int)value);
			}
			else
			{
				content = new holder<uint64>(value);
			}
		}

		any(const float & value)
		  : content(new holder<real>((real)value))
		{
		}

		any(const double & value)
		  : content(new holder<real>((real)value))
		{
		}

		any(const char & value)
		{
			std::string s;
			s.push_back(value);
			content = new holder<std::string>(s);
		}

		any(char * value)
		  : content(new holder<std::string>(std::string(value)))
		{
		}

		any(const char * value)
		  : content(new holder<std::string>(std::string(value)))
		{
		}

		any(const wchar & value)
		{
			std::wstring ws;
			ws.push_back(value);
			content = new holder<std::wstring>(ws);
		}

		any(wchar * value)
		  : content(new holder<std::wstring>(std::wstring(value)))
		{
		}

		any(const wchar * value)
		  : content(new holder<std::wstring>(std::wstring(value)))
		{
		}

		template<typename Type>
		any(const Type * value)
		  : content(new holder<Type *>(const_cast<Type *>(value)))
		{
		}

        template<typename Type>
        any(const Type & value)
          : content(new holder<Type>(value))
        {
        }

		any(const any & value)
		  : content(value.content ? value.content->clone() : 0)
		{
		}

		~any()
		{
			delete content;
		}

	public: // convertors

		template<typename Type>
		operator AnyCast(Type)() const
		{
			if (type() == typeid(Type))
			{
				return value<Type>();
			}
			else
			{
				throw bad_any_cast("failed conversion using phprpc::any_cast");
			}
		}

	public: // modifiers

		any & swap(any & rhs)
		{
			std::swap(content, rhs.content);
			return *this;
		}

		template<typename Type>
		any & operator=(const Type & rhs)
		{
			any(rhs).swap(*this);
			return *this;
		}

	    any & operator=(any rhs)
        {
            rhs.swap(*this);
            return *this;
        }

	public: // queries

		bool empty() const
		{
			return !content;
		}

		const std::type_info & type() const
		{
			return content ? content->type() : typeid(void);
		}

	public:

		template<typename Type>
		inline const Type & value() const
		{
			return static_cast<holder<Type> *>(content)->held;
		}

	public:

        class placeholder
        {
        public: // structors

            virtual ~placeholder()
			{
            }

		public: // queries

			virtual const std::type_info & type() const = 0;

			virtual placeholder * clone() const = 0;

        };

        template<typename Type>
        class holder : public placeholder
        {
        public: // structors

            holder(const Type & value)
              : held(value)
            {
			}

		public: // queries

            virtual const std::type_info & type() const
            {
				return typeid(Type);
            }

		    virtual placeholder * clone() const
            {
                return new holder(held);
            }

        public: // representation

            Type held;

        private: // intentionally left unimplemented

            holder & operator=(const holder &);

        };

	private:

		placeholder * content;

	}; // class any

	DeclareException(bad_key_type);

	struct any_hash
	{
		size_t operator()(const any & value) const
		{
			const std::type_info & vtype = value.type();

			if (vtype == typeid(int))
			{
				return boost::hash_value((int)value);
			}
			else if (vtype == typeid(int64))
			{
				return boost::hash_value((int64)value);
			}
			else if (vtype == typeid(uint64))
			{
				return boost::hash_value((uint64)value);
			}
			else if (vtype == typeid(real))
			{
				return boost::hash_value((real)value);
			}
			else if (vtype == typeid(std::string))
			{
				return boost::hash_value(value.value<std::string>());
			}
			else if (vtype == typeid(std::wstring))
			{
				return boost::hash_value(value.value<std::wstring>());
			}
			else
			{
				throw bad_key_type("bad key type!");
			}
			return 0;
		}
	};

	struct any_compare
	{
		bool operator()(const any & a1, const any & a2) const
		{
			if (a1.type() == a2.type())
			{
				const std::type_info & vtype = a1.type();

				if (vtype == typeid(int))
				{
					return (int)a1 == (int)a2;
				}
				else if (vtype == typeid(int64))
				{
					return (int64)a1 == (int64)a2;
				}
				else if (vtype == typeid(uint64))
				{
					return (uint64)a1 == (uint64)a2;
				}
				else if (vtype == typeid(real))
				{
					return (real)a1 == (real)a2;
				}
				else if (vtype == typeid(std::string))
				{
					return a1.value<std::string>() == a2.value<std::string>();
				}
				else if (vtype == typeid(std::wstring))
				{
					return a1.value<std::wstring>() == a2.value<std::wstring>();
				}
				else
				{
					throw bad_key_type("bad key type!");
				}
			}
			else
			{
				return false;
			}
		}
	};

	typedef UnorderdMap<any, any, any_hash, any_compare> any_unordered_map;
	

	typedef void (* constructor)(void * ptr); 
	typedef void (*  destructor)(void * ptr);

	struct runtime
	{
		runtime(const char * name, const int objsize, const constructor construct, const destructor destruct)
		  : name(name), objsize(objsize), construct(construct), destruct(destruct)  
		{
			head(this);
		}
		
		const char * name;
		int objsize;
		constructor construct;
		destructor destruct;
		runtime * next;
		
		static runtime * head(runtime * value = NULL)
		{
			static runtime * ghead;
			if (value)
			{
				value->next = ghead;
				ghead = value;
			}
			return ghead;
		}
	};
	
	class ISerializable
	{
		virtual std::string serialize() const = 0;
		virtual void unserialize(const std::string & data) = 0;	
	};
	
	class phprpc_object
	{
	public: // structors

        virtual ~phprpc_object()
        {
        }

	public:
	
		any & operator[](const std::string & key)
		{
			return properties[key];
		}
	
	protected:
		
		virtual std::vector<std::string> __sleep()
		{
			return std::vector<std::string>();
		}
		
		virtual void __wakeup()
		{
		}
		
	protected:

		UnorderdMap<std::string, any> properties;
		
	};
	
	class phprpc_factory
	{
	public:   
	  
		static void * create_object(const char * name)
		{
			runtime * r = runtime::head();
			
			while (r)
			{
				if (strcmp(r->name, name) == 0)
				{
					void * p = malloc(r->objsize);
					r->construct(p);
					return p;
				}
				r = r->next;
			}
			
			return NULL;
		};
		
		inline static void * create_object(const std::string & name)
		{
			return create_object(name.c_str());
		}
		
	};
	
#define DeclareClass(ClassName, AliasName) \
	void default_##ClassName##_constructor(void * ptr) \
	{ \
		new(ptr, (int)0, (char)0) ClassName; \
	}; \
    void default_##ClassName##_destructor(void * ptr) \
	{ \
		ClassName * pointer = (ClassName *)ptr; \
		pointer->~ClassName(); \
	}; \
	runtime ClassName##_runtime(#AliasName, sizeof(ClassName), default_##ClassName##_constructor, default_##ClassName##_destructor);
	
#define DeclareProperty(Name, Value) \
	(*this)[#Name] = Value;

	// global functions

	template<typename Type>
	inline Type rand(Type min, Type max)
	{
		return (Type)((double)std::rand() / (RAND_MAX + 1) * (max - min) + min);
	}

	template<typename Type>
	void string_replace_all(Type & data, const char * search, const char * format)
    {
		size_t index;

		while ((index = data.find(search)) != Type::npos)
		{
			data.replace(index, strlen(search), format);
		}
    }

	template<typename Type>
	int vector_index_of(const std::vector<any> & container, const Type & data)
	{
		std::vector<any>::const_iterator iter = container.begin();

		while (iter != container.end())
		{
			if ((*iter).type() == typeid(Type))
			{
				if (iter->value<Type>() == data)
				{
					return (int)(iter - container.begin());
				}
			}
			iter++;
		}

		return -1;
	}

} // namespace phprpc

#endif
