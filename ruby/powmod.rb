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
# terms of the GNU General Public License (GPL) version    #
# 2.0 as published by the Free Software Foundation and     #
# appearing in the included file LICENSE.                  #
#                                                          #
############################################################
#
# Math.powmod
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 1.0
# LastModified: Apr 12, 2010
# This library is free.  You can redistribute it and/or modify it under GPL.

def Math.powmod(x, y, z)
  r = 1
  while y > 0
    r = (r * x) % z if (y & 1) == 1
    x = (x * x) % z
    y >>= 1
  end
  return r
end
