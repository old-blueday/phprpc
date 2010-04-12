############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# fake_server.rb                                           #
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
# PHPRPC FakeServer library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Apr 12, 2010
# This library is free.  You can redistribute it and/or modify it under GPL.

require 'optparse'

module PHPRPC
  class FakeServer

    def initialize
      @opts = OptionParser.new
      @opts.banner = "Usage: #{@opts.program_name} [ServerName] [options]"
      @opts.separator ""
      @opts.separator "ServerName: (mongrel, thin, fcgi, scgi, lsapi, ebb, webrick)"
      @opts.separator ""
      @opts.separator "options:"
      @opts.on_tail('-?', '-h', '--help', "Show this help message.", "Show more messages with ServerName.") { puts @opts; exit }
      puts @opts
      exit
    end

  end # class FakeServer

end
