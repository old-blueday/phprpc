--[[
/**********************************************************\
|                                                          |
| The implementation of PHPRPC Protocol 3.0                |
|                                                          |
| phprpc_client.lua                                        |
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

/* PHPRPC Client library.
*
* Copyright: Chen fei <cf850118@163.com>
* Version: 3.0
* LastModified: Nov 25, 2009
* This library is free.  You can redistribute it and/or modify it.
*/
--]]

require('base64')
require('luacurl')
require('php')

phprpc_client_id = 0

phprpc_error = {
	number = 0,
	message = ''
}

function phprpc_error:new(number, message)
	o = {}
	setmetatable(o, self)
	self.__index = self
	o.number = number or 0
	o.message = message or ''
	return o
end

phprpc_client = {
	id = '',
	charset = 'utf-8',
	key = '',
	url = '',
	output = '',
	version = 3.0,
	key_exchanged = false,
	key_length = 128,
	encrypt_mode = 0,
	warning = phprpc_error:new()
}

function phprpc_client:new(url)
	o = {}
	setmetatable(o, self)
	self.__index = self
	math.randomseed(os.time())
	o.id = 'Lua' .. math.random(2147483647) .. os.date('%Y%m%d%H%M%S') .. phprpc_client_id
	phprpc_client_id = phprpc_client_id + 1
	o:use_service(url)
	return o
end

function phprpc_client:use_service(url)
	if string.find(url, '?') == nil then
		self.url = url .. '?phprpc_id=' .. self.id
	else
		self.url = url .. '&phprpc_id=' .. self.id
	end
end

function phprpc_client:invoke(func_name, args, by_ref, encrypt_mode)
	local fixed_args = {}
	local count = 0
	for i, v in ipairs(args) do
		fixed_args[i - 1] = v
		count = count + 1
	end

	local buffer = 'phprpc_func=' .. func_name
	if count > 0 then
		buffer = buffer .. '&phprpc_args=' .. string.gsub(base64.encode(serialize(fixed_args)), '+', '%%2B')
	end
	buffer = buffer .. '&phprpc_encrypt=' .. encrypt_mode 
	buffer = buffer .. '&phprpc_ref=' .. tostring(by_ref)
	
	local retval = {}
	local data = self:post(buffer)
	
	if data.phprpc_errno > 0 then
		retval.warning = phprpc_error:new(data.phprpc_errno, data.phprpc_errstr)
	end
	
	if data.phprpc_output ~= nil then
		retval.output = data.phprpc_output
	end
	
	if data.phprpc_result ~= nil then
		retval.result = unserialize(data.phprpc_result)
	else
		retval.result = retval.warning
	end
	
	return retval
end

function phprpc_client:post(data)

	local function writer(content, buffer)
		content.data = content.data .. buffer
		return #buffer
	end
	
	local header = {data = ''}
	local document = {data = ''}

	local c = curl.new()
	c:setopt(curl.OPT_HTTP_VERSION, 1.1);
	c:setopt(curl.OPT_HEADERFUNCTION, writer);
	c:setopt(curl.OPT_HEADERDATA, header);
	c:setopt(curl.OPT_WRITEFUNCTION, writer);
	c:setopt(curl.OPT_WRITEDATA, document);
	c:setopt(curl.OPT_HTTPHEADER,
		'Cache-Control: no-cache',
		'Connection: keep-alive',
		'Content-Type: application/x-www-form-urlencoded; charset=' .. self.charset
	);
	c:setopt(curl.OPT_ENCODING, '');
	c:setopt(curl.OPT_USERAGENT, 'phprpc client for lua');
	c:setopt(curl.OPT_SSLENGINE_DEFAULT, true);
	c:setopt(curl.OPT_SSL_VERIFYPEER, false);
	c:setopt(curl.OPT_SSL_VERIFYHOST, 0);
	c:setopt(curl.OPT_NOPROGRESS, true);
	c:setopt(curl.OPT_NOSIGNAL, true);
	c:setopt(curl.OPT_URL, self.url);
	c:setopt(curl.OPT_POST, true);
	c:setopt(curl.OPT_POSTFIELDS, data);
	c:setopt(curl.OPT_POSTFIELDSIZE, #data);
	c:perform()

	local version = 0
	local retval = {}
	
	local response_code = c:getinfo(curl.INFO_RESPONSE_CODE)
	local response_desc = string.match(header.data, 'HTTP/%d%.%d%s+' .. response_code .. '%s+([^\r]+)')

	if response_code == 200 then	
		for key, value in string.gmatch(header.data, '([%a%-]+):%s*([^\r]+)') do
			if string.lower(key) == 'x-powered-by' then
				version = string.match(string.lower(value), 'phprpc server/(%d%.%d)')
				break
			end
		end
		if version == 0 then
			error('Illegal PHPRPC Server!')
		else
			self.version = version
		end		
		for key, value in string.gmatch(document.data, '([%a_]+)=\"([^\r]+)\"') do
			if key == 'phprpc_errno' or key == 'phprpc_keylen' then
				retval[key] = tonumber(value)
			else
				retval[key] = base64.decode(value)
			end
		end
	else
		retval.phprpc_errno = response_code
		retval.phprpc_errstr = response_desc
	end
	
	return retval
end

function phprpc_client:set_key_length(key_length)
	if self.key == '' then
		return false
	else 
		self.key_length = key_length;
		return true
	end
end

function phprpc_client:set_encrypt_mode(encrypt_mode)
	if encrypt_mode >= 0 and encrypt_mode <= 3 then 
		self.encrypt_mode = encrypt_mode
		return true
	else 
		self.encrypt_mode = 0
		return false
	end
end
