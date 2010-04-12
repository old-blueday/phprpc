############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# scgi_server.rb                                           #
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
# PHPRPC SCGIServer library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Apr 12, 2010
# This library is free.  You can redistribute it and/or modify it under GPL.

require 'thread'
require 'scgi'
require 'phprpc/base_server'

module PHPRPC

  class SCGIProcessor <  SCGI::Processor

    def initialize(options = {})
      @app = options[:app]
      if not options.key?(:logfile) then
        @log = Object.new
        def @log.info(*args); end
        def @log.error(*args); end
      end
      super(options)
    end

    def process_request(request, input_body, socket)
      env = {}.replace(request)
      env["REQUEST_PATH"], env["QUERY_STRING"] = env["REQUEST_URI"].split('?', 2)
      env["QUERY_STRING"] ||= ""
      env["HTTP_VERSION"] ||= env["SERVER_PROTOCOL"]
      env["SCRIPT_NAME"] = env["PATH_INFO"] = env["REQUEST_PATH"]
      env["rack.input"] = StringIO.new(input_body)
      env["rack.multithread"] = true # this variable only used for rack pool session on debug mode
      env["rack.url_scheme"] = ["yes", "on", "1"].include?(env["HTTPS"]) ? "https" : "http"
      status, headers, body = @app.call(env)
      socket.write("Status: #{status}\r\n")
      headers.each { |k, v| socket.write("#{k}: #{v}\r\n") }
      socket.write("\r\n")
      socket.write(body)
    end

  end # class SCGIProcessor

  class SCGIServer < BaseServer

    def initialize(options = {})
      super()
      @options = {
        :host                 => '0.0.0.0',
        :port                 => 9999,
        :maxconns             => 2**30 - 1,
        :session_mode         => :file,
        :path                 => "/",
        :expire_after         => 1800,
      }.update(options)
      @opts = OptionParser.new
      @opts.banner = "Usage: #{@opts.program_name} scgi [options]"
      @opts.separator ""
      @opts.separator "Server options:"
      @opts.on('-a', '--address IP', String, "Bind SCGI to the specified ip.", "(default: #{@options[:host]})") { |ip| @options[:host] = ip }
      @opts.on('-p', '--port PORT', Integer, "Run SCGI on the specified port.", "(default: #{@options[:port]})") { |port| @options[:port] = port }
      @opts.on('-l', '--logfile FILE', String, "Where to write log messages.") { |file| @options[:logfile] = file }
      @opts.on('-n', '--maxconns NUM', Integer, "Allow this many max connections,", "more than this are redirected to /busy.html", "(default: #{@options[:maxconns]})") { |num| @options[:maxconns] = num }
      @opts.separator ""
      @opts.separator "Session options:"
      @opts.on('-s', '--session-mode MODE', [:file, :memcache, :pool], "Select Session mode (file, memcache, pool)", "(default: #{@options[:session_mode].to_s})") { |mode| @options[:session_mode] = mode }
      @opts.on('-e','--expire-after TIME', Integer, "Session expire after (default: #{@options[:expire_after]})") { |time| @options[:expire_after] = time }
      @opts.on('-m','--memcache_server SERVER', String, "Memcache server used by session in", "memcache mode (default: localhost:11211)") { |server| @options[:memcache_server] = server }
      @opts.on('--prefix PATH', String, "Mount the PHPRPC Server under PATH", "(start with /)") { |path| @options[:path] = path }
      @opts.separator ""
      @opts.separator "Common options:"
      @opts.on_tail('-D', '--debug', "Set debbuging on") { self.debug = true }
      @opts.on_tail('-?', '-h', '--help', "Show this help message.") { puts @opts; exit }
      begin
        @opts.parse!(ARGV)
      rescue OptionParser::ParseError
        puts @opts
        exit
      end
    end

    def start
      app = self
      if [:memcache, :pool].include?(@options[:session_mode]) then
        begin
          require 'rack'
          if @options[:session_mode] == :memcache then
            app = Rack::Session::Memcache.new(self, @options)
          else
            app = Rack::Session::Pool.new(self, @options)
          end
        rescue Exception
          app = self
        end
      end
      puts "## PHPRPC SCGI Server 3.0.0"
      puts "## Listening on #{@options[:host]}:#{@options[:port]}, CTRL+C to stop"
      begin
        SCGIProcessor.new(@options.update({:app => app})).listen
      rescue SystemExit
        exit
      rescue Exception => e
        puts "## #{@options[:host]}:#{@options[:port]} #{e.message}"
        puts @opts
        exit
      end
    end

  end # class SCGIServer

end # module PHPRPC