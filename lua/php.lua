--[[
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| php.lua                                                  |
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
* LastModified: Nov 25, 2009
* This library is free.  You can redistribute it and/or modify it.
*/
--]]

local function serialize_any(value, object_container)

	local function serialize_null()
		return 'N;'
	end

	local function serialize_boolean(value)
		return value and 'b:1;' or 'b:0;'
	end
	
	local function serialize_number(value)
		if (math.ceil(value) == math.floor(value)) then
			if value >= -2147483648 and value <= 2147483647 then
				return string.format('i:%d;', value)
			else
				return string.format('d:%.0f;', value)
			end
		else
			if value ~= value then
				return 'd:NAN;'
			elseif value == -math.log(0) then
				return 'd:INF;'
			elseif value == math.log(0) then
				return 'd:-INF;'
			else
				return string.format('d:%f;', value)
			end	
		end
	end
	
	local function serialize_string(value, object_container)
		local index = 0
		for i = 1, #object_container do
			if object_container[i] == value then
				index = i
				break
			end
		end
		local retval = ''
		if index > 0 then
			retval = string.format('r:%d;', index)
		else
			object_container[#object_container] = value
			retval = string.format('s:%d:"%s";', #value, value)
		end
		return retval, object_container
	end

	local function serialize_table(value, object_container)
		local index = 0
		for i = 1, #object_container do
			if object_container[i] == value then
				index = i
				break
			end
		end
		local retval = ''
		if index > 0 then
			retval = string.format('R:%d;', index)
		else	
			local buffer = ''
			local count = 0
			for k, v in pairs(value) do
				buffer = buffer .. serialize_any(k, {})
				local temp = ''
				temp, object_container = serialize_any(v, object_container)
				buffer = buffer .. temp
				count = count + 1
			end
			retval = 'a:' .. count .. ':{' .. buffer .. '}'
		end
		return retval, object_container
	end	
	
	local retval = ''
	local vtype = type(value)
	object_container[#object_container + 1] = ''
	if value == nil then
		retval = serialize_null()
	elseif vtype == 'boolean' then
		retval = serialize_boolean(value)
	elseif vtype == 'number' then
		retval = serialize_number(value)
	elseif vtype == 'string' then
		retval, object_container = serialize_string(value, object_container)
	elseif vtype == 'table' then
		retval, object_container = serialize_table(value, object_container)
	else
		error('this value can not to be serialize!')
	end
	return retval, object_container
end

function serialize(value)
	return serialize_any(value, {})	
end

local function unserialize_any(data, object_container)
	
	local function unserialize_bool(data)
		return string.sub(data, 3, 3) == '1'
	end

	local function unserialize_number(data)
		local value = string.sub(data, 3, string.find(data, ';', 3) - 1)
		if value == 'NAN' then
			return math.log(-1)
		elseif value == 'INF' then
			return -math.log(0)
		elseif value == '-INF' then
			return math.log(0)
		else
			return tonumber(value)
		end
	end	
	
	local function unserialize_string(data)
		return string.match(data, 's:%d+:\"(.*)\"')
	end	

	local function unserialize_escaped_string(data)
		local value = string.match(data, 'S:%d+:\"([^%z]*)\"')
		return string.gsub(value, '\\(%x+)', function(h)
				return string.char(tonumber(h, 16))
			end)
	end
	
	local function unserialize_unicode_string(data)
		local value = string.match(data, 'U:%d+:\"([^%z]*)\"')
		return string.gsub(value, '\\(%x+)', function(h)
				return tostring(tonumber(h, 16)) --unicode
			end)
	end		
	
	local function unserialize_ref(data, object_container)
		local value = string.sub(data, 3, string.find(data, ';', 3) - 1)
		return object_container[tonumber(value)]
	end
	
	local function unserialize_table(data, object_container)
		local index = string.find(data, ':', 3)
		local len = string.sub(data, 3, index - 1)
		index = index + 2
		local retval = {}
		for i = 1, tonumber(len) do
			local etag = string.find(data, ';', index)
			local key = string.sub(data, index, etag), {}
			local tag = string.sub(key, 1, 1)
			if tag == 'i' then
				key = unserialize_number(key)
			elseif tag == 's' then
				key = unserialize_string(key)
			elseif tag == 'S' then
				key = unserialize_escaped_string(key)
			elseif tag == 'U' then
				key = unserialize_unicode_string(key)
			else
				error('Unexpected Tag: \"' .. tag .. '\".')				
			end
			if string.sub(data, etag + 1, etag + 1) == 'a' then
				index = string.find(data, '}', etag + 1) + 1
			else
				index = string.find(data, ';', etag + 1) + 1
			end
			retval[key], object_container = unserialize_any(string.sub(data, etag + 1, index - 1), object_container)
		end
		return retval, object_container
	end

	local function unserialize_object(data)
	end
	
	local retval = nil
	local tag = string.sub(data, 1, 1)
	
	if tag == 'N' then
		retval = nil
		object_container[#object_container + 1] = retval
	elseif tag == 'b' then
		retval = unserialize_bool(data)
		object_container[#object_container + 1] = retval
	elseif tag == 'i' then
		retval = unserialize_number(data)
		object_container[#object_container + 1] = retval
	elseif tag == 'd' then
		retval = unserialize_number(data)
		object_container[#object_container + 1] = retval
	elseif tag == 's' then
		retval = unserialize_string(data)
		object_container[#object_container + 1] = retval
	elseif tag == 'S' then
		retval = unserialize_escaped_string(data)
		object_container[#object_container + 1] = retval
	elseif tag == 'U' then
		retval = unserialize_unicode_string(data)
		object_container[#object_container + 1] = retval
	elseif tag == 'r' then
		retval = unserialize_ref(data, object_container)
		object_container[#object_container + 1] = retval
	elseif tag == 'R' then
		retval = unserialize_ref(data, object_container)
	elseif tag == 'a' then
		local index = #object_container + 1
		object_container[index] = {}
		retval, object_container = unserialize_table(data, object_container)
		object_container[index] = retval
	elseif tag == 'O' then
		retval = unserialize_object(data)
	elseif tag == 'C' then
		retval = unserialize_string(data)
	else
		error('Unexpected Tag: \"' .. tag .. '\".')
	end
	return retval, object_container
end

function unserialize(data)
	return unserialize_any(data, {})
end