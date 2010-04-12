############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# mongrel_server.rb                                        #
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
# PHPRPC MongrelServer library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Apr 12, 2010
# This library is free.  You can redistribute it and/or modify it under GPL.

require 'mongrel'
require 'phprpc/base_server'

module PHPRPC

  class MongrelServer < Mongrel::HttpHandler

    def initialize(options = {})
      @options = {
        :host                 => '0.0.0.0',
        :port                 => 3000,
        :num_processors       => 1024,
        :throttle             => 0,
        :timeout              => 60,
        :debug                => false,
        :daemonize            => false,
        :cwd                  => Dir.pwd,
        :log_file             => 'log/mongrel.log',
        :pid_file             => 'log/mongrel.pid',
        :session_mode         => :file,
        :path                 => '/',
        :expire_after         => 1800,
      }.update(options)
      @opts = OptionParser.new
      @opts.banner = "Usage: #{@opts.program_name} mongrel [options]"
      @opts.separator ""
      @opts.separator "Server options:"
      @opts.on('-a', '--address IP', String, "Address to bind to (default: #{@options[:host]})") { |ip| @options[:host] = ip }
      @opts.on('-p', '--port PORT', Integer, "Which port to bind to (default: #{@options[:port]})") { |port| @options[:port] = port }
      @opts.on('-c', '--chdir PATH', String, "Change to dir before starting", "(will be expanded) (default: #{@options[:cwd]})") { |path| @options[:cwd] = File.expand_path(path) }
      @opts.on('-u', '--user USER', String, "User to run as") { |user| @options[:user] = user }
      @opts.on('-g', '--group GROUP', String, "Group to run as") { |group| @options[:group] = group }
      unless RUBY_PLATFORM =~ /mswin|mingw/ # Daemonizing not supported on Windows
        @opts.separator ""
        @opts.separator "Daemon options:"
        @opts.on('-d', '--daemonize', "Run daemonized in the background") { @options[:daemonize] = true }
        @opts.on('-l', '--log FILE', String, "Where to write log messages", "(default: #{@options[:log_file]})") { |file| @options[:log_file] = file }
        @opts.on("-P", "--pid FILE", String, "File to store PID", "(default: #{@options[:pid_file]})") { |file| @options[:pid_file] = file }
      end
      @opts.separator ""
      @opts.separator "Tuning options:"
      @opts.on('-n', '--num-processors INT', Integer, "Number of processors active", "before clients denied (default: #{@options[:num_processors]})") { |num| @options[:num_processors] = num }
      @opts.on('-t', '--throttle TIME', Integer, "Time to pause (in hundredths of a second)", "between accepting clients (default: #{@options[:throttle]})") { |time| @options[:throttle] = time }
      @opts.on('-o', '--timeout TIME', Integer, "Time to wait (in seconds) before killing", "a stalled thread (default: #{@options[:timeout]})") { |time| @options[:timeout] = time }
      @opts.separator ""
      @opts.separator "Session options:"
      @opts.on('-s', '--session-mode MODE', [:file, :memcache, :pool], "Select Session mode (file, memcache, pool)", "(default: #{@options[:session_mode].to_s})") { |mode| @options[:session_mode] = mode }
      @opts.on('-e','--expire-after TIME', Integer, "Session expire after (default: #{@options[:expire_after]})") { |time| @options[:expire_after] = time }
      @opts.on('-m','--memcache_server SERVER', String, "Memcache server used by session in", "memcache mode (default: localhost:11211)") { |server| @options[:memcache_server] = server }
      @opts.on('--prefix PATH', String, "Mount the PHPRPC Server under PATH", "(start with /)") { |path| @options[:path] = path }
      @opts.separator ""
      @opts.separator "Common options:"
      @opts.on_tail('-D', '--debug', "Set debbuging on (default: disabled)") { @options[:debug] = true }
      @opts.on_tail('-?', '-h', '--help', "Show this help message.") { puts @opts; exit }
      @opts.on_tail('-v', '--version', "Show version") { puts "Mongrel web server v#{Mongrel::Const::MONGREL_VERSION}"; exit }
      begin
        @opts.parse!(ARGV)
      rescue OptionParser::ParseError
        puts @opts
        exit
      end
      @app = PHPRPC::BaseServer.new
      @app.debug = @options[:debug]
    end

    def add(methodname, obj = nil, aliasname = nil, &block)
      @app.add(methodname, obj, aliasname, &block)
    end

    def charset
      @app.charset
    end

    def charset=(val)
      @app.charset = val
    end

    def debug
      @app.debug
    end

    def debug=(val)
      @app.debug = val
    end

    def start
      if [:memcache, :pool].include?(@options[:session_mode]) then
        old_app = @app
        begin
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
      @options[:handler] = self
      Mongrel::Configurator.new(@options) {
        daemonize if @defaults[:daemonize]
        log "Mongrel web server v#{Mongrel::Const::MONGREL_VERSION}"
        log "Listening on #{@defaults[:host]}:#{@defaults[:port]}"
        log "CTRL+C to stop" if @defaults[:daemonize]
        write_pid_file
        setup_signals
        listener {
          uri @defaults[:path]
          debug(@defaults[:path], [:access, :threads]) if @defaults[:debug]
        }
        run
        join
      }
    end

    def process(request, response)
      env = {}.replace(request.params)
      env["rack.input"] = request.body || StringIO.new("")
      env['rack.multithread'] = true # this variable only used for rack pool session on debug mode
      env["rack.url_scheme"] = "http"
      env["QUERY_STRING"] ||= ""
      status, headers, body = @app.call(env)
      begin
        response.status = status.to_i
        headers.each { |k, v|
          response.header[k] = v
        }
        response.body << body
        response.finished
      ensure
        body.close  if body.respond_to? :close
      end
    end

  end # class MongrelServer

end # module PHPRPC