############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# webrick_server.rb                                        #
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
# PHPRPC WEBrickServer library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Sep 12, 2008
# This library is free.  You can redistribute it and/or modify it.

require 'webrick'
require "phprpc/base_server"

module PHPRPC

  class WEBrickServlet < BaseServer

    def get_instance(*a)
      self
    end

    def service(request, response)
      env = request.meta_vars
      env.delete_if { |k, v| v.nil? }
      env["HTTPS"] = ENV["HTTPS"]
      env["rack.input"] = StringIO.new(request.body.to_s)
      env['rack.multithread'] = true # this variable only used for rack pool session on debug mode
      env["rack.url_scheme"] = ["yes", "on", "1"].include?(ENV["HTTPS"]) ? "https" : "http"
      env["HTTP_VERSION"] ||= env["SERVER_PROTOCOL"]
      env["QUERY_STRING"] ||= ""
      env["REQUEST_PATH"] ||= "/"
      status, headers, body = @app.call(env)
      response.status = status.to_i
      headers.each { |k, v| response[k] = v }
      response.body = body
    end

  end # class WEBrickServlet

  class WEBrickServer < WEBrickServlet

    def initialize(options = {})
      super()
      @app = self
      @options = {
        :BindAddress    => '0.0.0.0',
        :Port           => 3000,
        :Logger         => nil,
        :MaxClients     => 100,
        :RequestTimeout => 30,
        :session_mode   => :file,
        :path           => "/",
        :expire_after   => 1800,
      }.update(options)
      @opts = OptionParser.new
      @opts.banner = "Usage: #{@opts.program_name} webrick [options]"
      @opts.separator ""
      @opts.separator "Server options:"
      @opts.on('-a', '--address IP', String, "Address to bind to (default: #{@options[:BindAddress]})") { |ip| @options[:BindAddress] = ip }
      @opts.on('-p', '--port PORT', Integer, "Which port to bind to (default: #{@options[:Port]})") { |port| @options[:Port] = port }
      @opts.on('-l', '--log FILE', String, "File to redirect output") { |file| @options[:Logger] = WEBrick::Log.new(file); }
      @opts.on('-L', '--accesslog FILE', String, "File to redirect access info") { |file|
        file = open(file, "a+")
        @options[:AccessLog] = [
          [ file, WEBrick::AccessLog::COMMON_LOG_FORMAT ],
          [ file, WEBrick::AccessLog::REFERER_LOG_FORMAT ]
        ]
      }
      @opts.separator ""
      @opts.separator "Tuning options:"
      @opts.on('-n', '--max-clients INT', Integer, "Maximum number of the concurrent", "connections (default: #{@options[:MaxClients]})") { |num| @options[:MaxClients] = num }
      @opts.on('-t', '--timeout TIME', Integer, "Request timeout (in seconds)", "(default: #{@options[:RequestTimeout]})") { |time| @options[:RequestTimeout] = time }
      @opts.separator ""
      @opts.separator "Session options:"
      @opts.on('-s', '--session-mode MODE', [:file, :memcache, :pool], "Select Session mode (file, memcache, pool)", "(default: #{@options[:session_mode].to_s})") { |mode| @options[:session_mode] = mode }
      @opts.on('-e','--expire-after TIME', Integer, "Session expire after (default: #{@options[:expire_after]})") { |time| @options[:expire_after] = time }
      @opts.on('-m','--memcache_server SERVER', String, "Memcache server used by session in", "memcache mode (default: localhost:11211)") { |server| @options[:memcache_server] = server }
      @opts.on('--prefix PATH', String, "Mount the PHPRPC Server under PATH", "(start with /)") { |path| @options[:path] = path }
      @opts.separator ""
      @opts.separator "Common options:"
      @opts.on_tail('-D', '--debug', "Set debbuging on (default: disabled)") { self.debug = true }
      @opts.on_tail('-?', '-h', '--help', "Show this help message.") { puts @opts; exit }
      @opts.on_tail('-v', '--version', "Show version") { puts "WEBrick/#{WEBrick::VERSION} (Ruby/#{RUBY_VERSION}/#{RUBY_RELEASE_DATE})"; exit }
      begin
        @opts.parse!(ARGV)
      rescue OptionParser::ParseError
        puts @opts
        exit
      end
    end

    def start
      if [:memcache, :pool].include?(@options[:session_mode]) then
        old_app = @app
        begin
          require 'rubygems'
          require 'rack'
          if @options[:session_mode] == :memcache then
            @app = Rack::Session::Memcache.new(@app, @options)
          else
            @app = Rack::Session::Pool.new(@app, @options)
          end
        rescue Exception
          @app = old_app
        end
      end
      @options.delete(:ServerType)
      @options.delete(:DocumentRoot)
      @options.delete(:RequestCallback)
      @options.delete(:RequestHandler)
      server = WEBrick::HTTPServer.new(@options)
      server.mount(@options[:path], self)
      trap(:INT) { server.shutdown }
      server.start
    end

  end # class WEBrickServer

end # module PHPRPC