############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# ebb_server.rb                                            #
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
# PHPRPC EbbServer library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Apr 12, 2010
# This library is free.  You can redistribute it and/or modify it under GPL.

require 'ebb_ffi'
require 'ebb'
require "phprpc/base_server"

module PHPRPC
  class EbbServer < BaseServer

    def initialize(options = {})
      super()
      @options = {
        :port                 => 3000,
        :session_mode         => :file,
        :path                 => "/",
        :expire_after         => 1800,
      }.update(options)
      @opts = OptionParser.new
      @opts.banner = "Usage: #{@opts.program_name} ebb [options]"
      @opts.separator ""
      @opts.separator "Server options:"
      @opts.on('-p', '--port PORT', Integer, "Which port to bind to (default: #{@options[:port]})") { |port| @options[:port] = port }
      @opts.on('--ssl_cert FILE', String, "SSL certificate file") { |file| @options[:ssl_cert] = file }
      @opts.on('--ssl_key FILE', String, "SSL key file") { |file| @options[:ssl_key] = file }
      @opts.separator ""
      @opts.separator "Session options:"
      @opts.on('-s', '--session-mode MODE', [:file, :memcache, :pool], "Select Session mode (file, memcache, pool)", "(default: #{@options[:session_mode].to_s})") { |mode| @options[:session_mode] = mode }
      @opts.on('-e','--expire-after TIME', Integer, "Session expire after (default: #{@options[:expire_after]})") { |time| @options[:expire_after] = time }
      @opts.on('-m','--memcache_server SERVER', String, "Memcache server used by session in", "memcache mode (default: localhost:11211)") { |server| @options[:memcache_server] = server }
      @opts.on('--prefix PATH', String, "Mount the PHPRPC Server under PATH", "(start with /)") { |path| @options[:path] = path }
      @opts.separator ""
      @opts.separator "Common options:"
      @opts.on_tail("-D", "--debug", "Set debbuging on") { self.debug = true }
      @opts.on_tail('-?', '-h', '--help', "Show this help message.") { puts @opts; exit }
      @opts.on_tail('-v', '--version', "Show version") { puts Ebb::VERSION_STRING; exit }
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
      Ebb.start_server(app, @options)
    end
  end
end