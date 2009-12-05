############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# fcgi_server.rb                                           #
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
# terms of the GNU Lesser General Public License (LGPL)    #
# version 3.0 as published by the Free Software Foundation #
# and appearing in the included file LICENSE.              #
#                                                          #
############################################################
#
# PHPRPC FCGIServer library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Sep 14, 2008
# This library is free.  You can redistribute it and/or modify it.

require 'fcgi'
require 'phprpc/base_server'

module PHPRPC

  class FCGIServer < BaseServer

    def initialize(options = {})
      super()
      @options = {
        :session_mode         => :file,
        :path                 => "/",
        :expire_after         => 1800,
      }.update(options)
      @opts = OptionParser.new
      @opts.banner = "Usage: #{@opts.program_name} fcgi [options]"
      @opts.separator ""
      @opts.separator "Server options:"
      @opts.on('-a', '--address IP', String, "Bind FCGI to the specified ip.") { |ip| @options[:host] = ip }
      @opts.on('-p', '--port PORT', Integer, "Run FCGI on the specified port.") { |port| @options[:port] = port }
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

    def start()
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
      begin
        if @options[:port] then
          @options[:host] = '0.0.0.0' if @options[:host].nil?
          puts "## PHPRPC FCGI Server 3.0.0"
          STDIN.reopen(TCPServer.new(@options[:host], @options[:port]))
          puts "## Listening on #{@options[:host]}:#{@options[:port]}, CTRL+C to stop"
        end
        trap(:INT) { exit }
        FCGI.each { |request|
          env = request.env
          env["rack.input"] = request.in
          env["rack.multithread"] = false # this variable only used for rack pool session on debug mode
          env["rack.url_scheme"] = ["yes", "on", "1"].include?(env["HTTPS"]) ? "https" : "http"
          env["QUERY_STRING"] ||= ""
          env["HTTP_VERSION"] ||= env["SERVER_PROTOCOL"]
          env["REQUEST_PATH"] ||= "/"
          status, headers, body = app.call(env)
          begin
            out = request.out
            out.print "Status: #{status}\r\n"
            headers.each { |k, v|
              out.print "#{k}: #{v}\r\n"
            }
            out.print "\r\n"
            out.flush
            out.print body
            out.flush
          ensure
            request.finish
          end
        }
      rescue SystemExit
        exit
      rescue Exception => e
        puts "## #{@options[:host]}:#{@options[:port]} #{e.message}"
        puts @opts
        exit
      end
    end

  end # class FCGIServer

end # module PHPRPC