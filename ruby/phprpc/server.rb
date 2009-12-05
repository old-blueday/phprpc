############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# server.rb                                                #
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
# PHPRPC Server library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Mar 8, 2009
# This library is free.  You can redistribute it and/or modify it.

module PHPRPC

  autoload :BaseServer, 'phprpc/base_server'
  autoload :CGIServer, 'phprpc/cgi_server'
  autoload :MongrelServer, 'phprpc/mongrel_server'
  autoload :ThinServer, 'phprpc/thin_server'
  autoload :FCGIServer, 'phprpc/fcgi_server'
  autoload :SCGIServer, 'phprpc/scgi_server'
  autoload :LSAPIServer, 'phprpc/lsapi_server'
  autoload :EbbServer, 'phprpc/ebb_server'
  autoload :WEBrickServer, 'phprpc/webrick_server'
  autoload :FakeServer, 'phprpc/fake_server'

  ARGV[0] = '' if ARGV[0].nil?
  Server = case ARGV[0].downcase
  when 'mongrel' then MongrelServer
  when 'thin' then ThinServer
  when 'fcgi' then FCGIServer
  when 'scgi' then SCGIServer
  when 'lsapi' then LSAPIServer
  when 'ebb' then EbbServer
  when 'webrick' then WEBrickServer
  else (ENV['GATEWAY_INTERFACE'] =~ /CGI\/\d.\d/ ? CGIServer : FakeServer)
  end # class Server

end # module PHPRPC