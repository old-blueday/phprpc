############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# thin_server.rb                                           #
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
# PHPRPC ThinServer library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Apr 12, 2010
# This library is free.  You can redistribute it and/or modify it under GPL.

require 'thin'
require "phprpc/base_server"

module PHPRPC

  class ThinServer < BaseServer

    def initialize(options = {})
      super()
      @options = {
        :address              => '0.0.0.0',
        :port                 => Thin::Server::DEFAULT_PORT,
        :timeout              => Thin::Server::DEFAULT_TIMEOUT,
        :daemonize            => false,
        :log                  => 'log/thin.log',
        :pid                  => 'log/thin.pid',
        :max_conns            => Thin::Server::DEFAULT_MAXIMUM_CONNECTIONS,
        :max_persistent_conns => Thin::Server::DEFAULT_MAXIMUM_PERSISTENT_CONNECTIONS,
        :threaded             => false,
        :chdir                => Dir.pwd,
        :session_mode         => :file,
        :path                 => "/",
        :expire_after         => 1800,
        :debug                => false,
        :trace                => false,
      }.update(options)
      @opts = OptionParser.new
      @opts.banner = "Usage: #{@opts.program_name} thin [options]"
      @opts.separator ""
      @opts.separator "Server options:"
      @opts.on("-a", "--address HOST", "Bind to HOST address (default: #{@options[:address]})") { |host| @options[:address] = host }
      @opts.on("-p", "--port PORT", "Use PORT (default: #{@options[:port]})") { |port| @options[:port] = port.to_i }
      @opts.on("-S", "--socket FILE", "Bind to unix domain socket") { |file| @options[:socket] = file }
      @opts.on("-y", "--swiftiply [KEY]", "Run using swiftiply") { |key| @options[:swiftiply] = key }
      @opts.on("-c", "--chdir DIR", "Change to dir before starting") { |dir| @options[:chdir] = File.expand_path(dir) }
      @opts.on("--stats PATH", "Mount the Stats adapter under PATH") { |path| @options[:stats] = path }
      unless Thin.win? # Daemonizing not supported on Windows
        @opts.separator ""
        @opts.separator "Daemon options:"
        @opts.on("-d", "--daemonize", "Run daemonized in the background") { @options[:daemonize] = true }
        @opts.on("-l", "--log FILE", "File to redirect output", "(default: #{@options[:log]})") { |file| @options[:log] = file }
        @opts.on("-P", "--pid FILE", "File to store PID", "(default: #{@options[:pid]})") { |file| @options[:pid] = file }
        @opts.on("-u", "--user NAME", "User to run daemon as (use with -g)") { |user| @options[:user] = user }
        @opts.on("-g", "--group NAME", "Group to run daemon as (use with -u)") { |group| @options[:group] = group }
      end
      @opts.separator ""
      @opts.separator "Tuning options:"
      @opts.on("-b", "--backend CLASS", "Backend to use, full classname") { |name| @options[:backend] = name }
      @opts.on("-t", "--timeout SEC", "Request or command timeout in sec", "(default: #{@options[:timeout]})") { |sec| @options[:timeout] = sec.to_i }
      @opts.on("--max-conns NUM", "Maximum number of connections", "(default: #{@options[:max_conns]})",
                                  "Might require sudo to set higher then 1024")  { |num| @options[:max_conns] = num.to_i } unless Thin.win?
      @opts.on("--max-persistent-conns NUM", "Maximum number of persistent connections",
                                       "(default: #{@options[:max_persistent_conns]})") { |num| @options[:max_persistent_conns] = num.to_i }
      @opts.on("--threaded", "Call the Rack application in threads", "[experimental]") { @options[:threaded] = true }
      @opts.separator ""
      @opts.separator "Session options:"
      @opts.on('-s', '--session-mode MODE', [:file, :memcache, :pool], "Select Session mode (file, memcache, pool)", "(default: #{@options[:session_mode].to_s})") { |mode| @options[:session_mode] = mode }
      @opts.on('-e','--expire-after TIME', Integer, "Session expire after (default: #{@options[:expire_after]})") { |time| @options[:expire_after] = time }
      @opts.on('-m','--memcache_server SERVER', String, "Memcache server used by session in", "memcache mode (default: localhost:11211)") { |server| @options[:memcache_server] = server }
      @opts.on('--prefix PATH', String, "Mount the PHPRPC Server under PATH", "(start with /)") { |path| @options[:path] = path }
      @opts.separator ""
      @opts.separator "Common options:"
      @opts.on_tail("-D", "--debug", "Set debbuging on") { @options[:debug] = true }
      @opts.on_tail("-V", "--trace", "Set tracing on (log raw request/response)") { @options[:trace] = true }
      @opts.on_tail("-?", "-h", "--help", "Show this message") { puts @opts; exit }
      @opts.on_tail('-v', '--version', "Show version") { puts Thin::SERVER; exit }
      begin
        @opts.parse!(ARGV)
      rescue OptionParser::ParseError
        puts @opts
        exit
      end
      @app = PHPRPC::BaseServer.new
      self.debug = @options[:debug]
    end

    def start()
      @options[:backend] = eval(@options[:backend], TOPLEVEL_BINDING) if @options[:backend]
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
      Dir.chdir(@options[:chdir])
      Thin::Logging.debug = @options[:debug]
      Thin::Logging.trace = @options[:trace]
      server = Thin::Server.new(@options[:socket] || @options[:address], # Server detects kind of socket
                                  @options[:port],                         # Port ignored on UNIX socket
                                  @options,
                                  app)

      # Set options
      server.pid_file                       = @options[:pid]
      server.log_file                       = @options[:log]
      server.timeout                        = @options[:timeout]
      server.maximum_connections            = @options[:max_conns]
      server.maximum_persistent_connections = @options[:max_persistent_conns]
      server.threaded                       = @options[:threaded]

      # Detach the process, after this line the current process returns
      server.daemonize if @options[:daemonize]

      # +config+ must be called before changing privileges since it might require superuser power.
      server.config

      server.change_privilege @options[:user], @options[:group] if @options[:user] && @options[:group]

      # If a prefix is required, wrap in Rack URL mapper
      server.app = Rack::URLMap.new(@options[:path] => server.app) if @options[:path]

      # If a stats URL is specified, wrap in Stats adapter
      server.app = Thin::Stats::Adapter.new(server.app, @options[:stats]) if @options[:stats]

      # Register restart procedure which just start another process with same options,
      # so that's why this is done here.
      server.on_restart { Thin::Command.run(:start, @options) }

      server.start
    end

  end # class ThinServer

end # module PHPRPC