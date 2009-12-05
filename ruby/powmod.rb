############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# powmod.rb                                                #
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
# Math.powmod
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 1.0
# LastModified: Aug 21, 2008
# This library is free.  You can redistribute it and/or modify it.

def Math.powmod(x, y, z)
  r = 1
  while y > 0
    r = (r * x) % z if (y & 1) == 1
    x = (x * x) % z
    y >>= 1
  end
  return r
end
