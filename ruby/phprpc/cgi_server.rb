############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# cgi_server.rb                                            #
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
# PHPRPC CGIServer library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Apr 12, 2010
# This library is free.  You can redistribute it and/or modify it under GPL.

require "phprpc/base_server"

module PHPRPC

  class CGIServer < BaseServer

    def start()
      cgi = CGI::new
      header, body = call!(ENV, cgi)
      header['type'] = header['Content-Type']
      cgi.out(header) { body }
    end

  end # class CGIServer

end # module PHPRPC