############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# phprpc.rb                                                #
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
# PHPRPC library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 3.0
# LastModified: Sep 13, 2008
# This library is free.  You can redistribute it and/or modify it.

$: << File.expand_path(File.dirname(__FILE__))

module Crypt
  autoload :XXTEA, 'crypt/xxtea'
end

module PHP
  autoload :Formator, 'php/formator'
end

module PHPRPC

  VERSION = [3,0]

  def self.version
    VERSION.join(".")
  end

  def self.release
    "1.0"
  end

  autoload :Client, 'phprpc/client'
  autoload :Server, 'phprpc/server'
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
end