############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# base_server.rb                                           #
#                                                          #
# Release 3.0.5                                            #
# Copyright by Team-PHPRPC                                 #
#                                                          #
# WebSite:  http://www.phprpc.org/                         #
#           http://www.phprpc.net/                         #
#           http://www.phprpc.com/                         #
#           http://sourceforge.net/projects/php-rpc/       #
#                                                          #
# Authors:  Ma Bingyao <andot@ujn.edu.cn>                  #
#                                                          #
# This file may be distributed and/or modified under the   #
# terms of the GNU General Public License (GPL) version    #
# 2.0 as published by the Free Software Foundation and     #
# appearing in the included file LICENSE.                  #
#                                                          #
############################################################
#
# PHPRPC BaseServer library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Apr 12, 2010
# This library is free.  You can redistribute it and/or modify it under GPL.

require "digest/md5"
require "php/formator"
require "crypt/xxtea"
require "powmod"
require "cgi"
require "cgi/session"
require "optparse"
require "thread"

module PHPRPC

  # String for carriage return
  CR  = "\015"

  # String for linefeed
  LF  = "\012"

  # Standard internet newline sequence
  EOL = CR + LF

  class BaseServer

    attr_accessor :charset, :debug

    def initialize()
      @methods = {}
      @charset = 'utf-8'
      @debug = $DEBUG
      @mutex = Mutex.new
    end

    def add(methodname, obj = nil, aliasname = nil, &block)
      raise TypeError, "methodname must be a string or a string list." if methodname.nil?
      aliasname = methodname if aliasname.nil?
      raise TypeError, "aliasname's type must match with methodname's type" if aliasname.class != methodname.class
      if methodname.kind_of?(String) then
        methodname = [methodname]
        aliasname = [aliasname]
      end
      raise RangeError, "aliasname's size must equal methodname's size" if methodname.size != aliasname.size
      obj = Object if obj.nil?
      methodname.each_with_index { |name, index|
        if block_given? then
          @methods[aliasname[index].downcase] = block
        elsif obj.respond_to?(name, true) then
          @methods[aliasname[index].downcase] = obj.method(name.to_sym)
        end
      }
    end

    def call(env)
      [200, *call!(env, PHPRPC::Request.new(env))]
    end

    def call!(env, request)
      body = ''
      callback = ''
      encode = true
      @mutex.synchronize {
        session = (env['rack.session'].is_a?(Hash) ? env['rack.session'] : CGI::Session.new(request))
        begin
          params = request.params
          callback = get_base64('phprpc_callback', params)
          encode = get_boolean('phprpc_encode', params)
          encrypt = get_encrypt(params)
          cid = "phprpc_#{(params.key?('phprpc_id') ? params['phprpc_id'][0] : '0')}"
          if params.key?('phprpc_func') then
            func = params['phprpc_func'][0].downcase
            if @methods.key?(func) then
              hash = get_session(session, cid)
              if hash.key?('key') then
                key = hash['key']
              elsif encrypt > 0 then
                encrypt = 0
                raise "Can't find the key for decryption."
              end
              ref = get_boolean('phprpc_ref', params)
              args = get_args(params, key, encrypt)
              result = encode_string(encrypt_string(PHP::Formator.serialize(invoke(func, args, session)), key, 2, encrypt), encode)
              body << 'phprpc_result="' << result << '";' << EOL
              if ref then
                args = encode_string(encrypt_string(PHP::Formator.serialize(args), key, 1, encrypt), encode)
                body << 'phprpc_args="' << args << '";' << EOL
              end
            else
              raise "Can't find this function #{func}()."
            end
            write_error(body, 0, '', callback, encode)
          elsif (encrypt != false) and (encrypt != 0) then
            hash = get_session(session, cid)
            keylen = get_keylength(params, hash)
            key_exchange(body, env, request, hash, callback, encode, encrypt, keylen)
            set_session(session, cid, hash)
          else
            write_functions(body, callback, encode)
          end
        rescue Exception => e
          body = ''
          if @debug then
            write_error(body, 1, e.backtrace.unshift(e.message).join(EOL), callback, encode)
          else
            write_error(body, 1, e.message, callback, encode)
          end
        ensure
          session.close if session.respond_to?(:close)
          return [header(request, body), body]
        end
      }
    end

    private

    def invoke(methodname, args, session)
      if @methods.key?(methodname) then
        m = @methods[methodname]
        m.call(*(((m.arity > 0) and (args.length + 1 == m.arity))? args + [session] : args))
      end
    end

    def add_js_slashes(str, flag)
      range = flag ? [0..31, 34, 39, 92, 127..255] : [0..31, 34, 39, 92, 127]
      result = ''
      str.each_byte { |c|
        result << case c
        when *range then
          '\x' << c.to_s(16).rjust(2, '0')
        else
          c.chr
        end
      }
      result
    end

    def encode_string(str, encode = true, flag = true)
      return str if str == ''
      encode ? [str].pack('m').delete!("\n") : add_js_slashes(str, flag)
    end

    def encrypt_string(str, key, level, encrypt)
      (encrypt >= level) ? Crypt::XXTEA.encrypt(str, key) : str
    end

    def decrypt_string(str, key, level, encrypt)
      (encrypt >= level) ? Crypt::XXTEA.decrypt(str, key) : str
    end

    def header(request, body)
      h = {
        'X-Powered-By' => 'PHPRPC Server/3.0',
        'P3P' => 'CP="CAO DSP COR CUR ADM DEV TAI PSA PSD IVAi IVDi CONi TELo OTPi OUR DELi SAMi OTRi UNRi PUBi IND PHY ONL UNI PUR FIN COM NAV INT DEM CNT STA POL HEA PRE GOV"',
        'Expires' => CGI::rfc1123_date(Time.now),
        'Cache-Control' => 'no-store, no-cache, must-revalidate, max-age=0',
        'Content-Type' => "text/plain; charset=#{@charset}",
        'Content-Length' => body.length.to_s,
      }
      output_cookies = request.instance_variable_get(:@output_cookies)
      if not output_cookies.nil? then
        h["Set-Cookie"] = output_cookies[0].to_s
        request.instance_variable_set(:@output_cookies, nil)
      end
      return h
    end

    def write_url(body, env, request, encode)
      output_hidden = request.instance_variable_get(:@output_hidden)
      output_hidden = { env['rack.session.options'][:id] => env['rack.session.options'][:key] } if env['rack.session.options'].is_a?(Hash)
      if (output_hidden) then
        scheme = env["rack.url_scheme"]
        scheme = (["yes", "on", "1"].include?(env["HTTPS"]) ? 'https': 'http') if scheme.nil? or scheme.empty?
        host = (env["HTTP_HOST"] || env["SERVER_NAME"]).gsub(/:\d+\z/, '')
        port = env['SERVER_PORT']
        path = env['SCRIPT_NAME']
        path = env['PATH_INFO'] if path.nil? or path.empty?
        path = env['REQUEST_PATH'] if path.nil? or path.empty?
        url = "#{scheme}://#{host}#{((port == '80') ? '' : ':' + port)}#{path}"
        url << '?'
        output_hidden.each { |key, value|
          url << "#{key}=#{CGI::escape(value)}&"
        }
        params = request.params
        if (params.size > 0) then
          params.each { |key, values|
            values.each { |value|
              url << "#{key}=#{CGI::escape(value)}&"
            } if not key.index(/^phprpc_/i)
          }
        end
        url[-1] = ''
        body << 'phprpc_url="' << encode_string(url, encode) << '";' << EOL
      end
    end

    def write_functions(body, callback, encode)
      body << 'phprpc_functions="' << encode_string(PHP::Formator.serialize(@methods.keys), encode) << '";' << EOL
      body << callback
    end

    def write_error(body, errno, errstr, callback, encode)
      body << 'phprpc_errno="' << errno.to_s << '";' << EOL
      body << 'phprpc_errstr="' << encode_string(errstr, encode, false) << '";' << EOL
      body << 'phprpc_output="";' << EOL
      body << callback
    end

    def get_boolean(name, params)
      (params.key?(name) ? (params[name][0].downcase != "false") : true)
    end

    def get_base64(name, params)
      (params.key?(name) ? params[name][0].unpack('m')[0] : '')
    end

    def get_encrypt(params)
      if params.key?('phprpc_encrypt') then
        encrypt = params['phprpc_encrypt'][0].downcase
        case encrypt
        when "true" then true
        when "false" then false
        else encrypt.to_i
        end
      else
        0
      end
    end

    def get_args(params, key, encrypt)
      args = []
      if params.key?('phprpc_args') then
        arguments = PHP::Formator.unserialize(decrypt_string(params['phprpc_args'][0].unpack('m')[0], key, 1, encrypt))
        arguments.size.times { |i|
          args[i] = arguments[i]
        }
      end
      return args
    end

    def set_session(session, cid, hash)
      session[cid] = PHP::Formator.serialize(hash)
    end

    def get_session(session, cid)
      str = session[cid]
      if str then
        PHP::Formator.unserialize(str)
      else
        {}
      end
    end

    def get_keylength(params, hash)
      (params.key?('phprpc_keylen') ? params['phprpc_keylen'][0].to_i : ((hash.key?('keylen')) ? hash['keylen'] : 128))
    end

    def key_exchange(body, env, request, hash, callback, encode, encrypt, keylen)
      if (encrypt == true) then
        keylen, encrypt = DHParams.get(keylen)
        x = rand(1 << (keylen - 1)) or (1 << (keylen - 2))
        hash['x'] = x.to_s
        hash['p'] = encrypt['p']
        hash['keylen'] = keylen
        encrypt['y'] = Math.powmod(encrypt['g'].to_i, x, encrypt['p'].to_i).to_s
        body << 'phprpc_encrypt="' << encode_string(PHP::Formator.serialize(encrypt), encode) << '";' << EOL
        body << 'phprpc_keylen="' << keylen.to_s << '";' << EOL if keylen != 128
        write_url(body, env, request, encode)
      else
        y = encrypt
        x = hash['x'].to_i
        p = hash['p'].to_i
        key = Math.powmod(y, x, p)
        hash['key'] = ((keylen == 128) ? [key.to_s(16).rjust(32, '0')].pack('H*') : Digest::MD5.digest(key.to_s))
      end
      body << callback
    end

  end # class BaseServer

  class Request

    attr_accessor :cookies
    attr :params

    def initialize(env)
      @params = env["QUERY_STRING"] ? CGI::parse(env["QUERY_STRING"].to_s) : {}
      if (env['REQUEST_METHOD'] == 'POST' and
      (env['CONTENT_TYPE'].nil? or
       env['CONTENT_TYPE'].split(/\s*[;,]\s*/, 2)[0].downcase ==
       'application/x-www-form-urlencoded')) then
        # fix ebb bug, the read method of ebb can't return all bytes from the I/O stream
        if input_body = env['rack.input'].read then
          while chunk = env['rack.input'].read(512) do
            input_body << chunk
          end
        else
          input_body = ''
        end
        @params.update(CGI::parse(input_body))
      end
      @cookies = if env["HTTP_COOKIE"] then CGI::Cookie::parse(env["HTTP_COOKIE"].to_s) else {} end
      @output_cookies = nil
      @output_hidden = nil
    end

    def [](key)
      params = @params[key]
      return '' unless params
      value = params[0]
      if value then value else "" end
    end

    def []=(key, val)
      @params[key] = val
    end

    def keys
      @params.keys
    end

    def has_key?(key)
      @params.has_key?(key)
    end

    alias key? has_key?

    alias include? has_key?

  end # class Request


  class DHParams

    class << self

      def get(length)
        length = get_nearest(length)
        dhparams = @dhparams_gen[length]
        [length, dhparams[rand(dhparams.size)]]
      end

      private

      def init
        @lengths = [96, 128, 160, 192, 256, 512, 768, 1024, 1536, 2048, 3072, 4096]
        @dhparams_gen = {}
        @lengths.each { |length|
          @dhparams_gen[length] = PHP::Formator.unserialize(IO.read("dhparams/#{length}.dhp"))
        }
      end

      def get_nearest(n)
        init if @lengths.nil?
        j = 0
        m = (@lengths[0] - n).abs
        1.upto(@lengths.size - 1) { |i|
          t = (@lengths[i] - n).abs
          if (m > t) then
            m = t
            j = i
          end
        }
        return @lengths[j]
      end

    end # class self

  end # class DHParams

end # module PHPRPC