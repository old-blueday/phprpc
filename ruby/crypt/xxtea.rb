############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# xxtea.rb                                                 #
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
# XXTEA encryption arithmetic library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 1.0
# LastModified: Sep 30, 2008
# This library is free.  You can redistribute it and/or modify it.

module Crypt

  class XXTEA

    class << self

      private

      Delta = 0x9E3779B9

      def long2str(v, w)
        n = (v.size - 1) << 2
        if w then
          m = v.last
          if (m < n - 3) or (m > n) then return '' end
          n = m
        end
        s = v.pack("V*")
        return w ? s[0, n] : s
      end

      def str2long(s, w)
        n = s.length
        v = s.ljust((4 - (n & 3) & 3) + n, "\0").unpack("V*")
        if w then v[v.size] = n end
        return v
      end

      public

      def encrypt(str, key)
        if str.empty? then return str end
        v = str2long(str, true)
        k = str2long(key.ljust(16, "\0"), false)
        n = v.size - 1
        z = v[n]
        y = v[0]
        sum = 0
        (6 + 52 / (n + 1)).downto(1) { |q|
          sum = (sum + Delta) & 0xffffffff
          e = sum >> 2 & 3
          for p in (0...n)
            y = v[p + 1]
            z = v[p] = (v[p] +  ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff
          end
          y = v[0]
          z = v[n] = (v[n] +  ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[n & 3 ^ e] ^ z))) & 0xffffffff
        }
        long2str(v, false)
      end

      def decrypt(str, key)
        if str.empty? then return str end
        v = str2long(str, false)
        k = str2long(key.ljust(16, "\0"), false)
        n = v.size - 1
        z = v[n]
        y = v[0]
        q = 6 + 52 / (n + 1)
        sum = (q * Delta) & 0xffffffff
        while (sum != 0)
          e = sum >> 2 & 3
          n.downto(1) { |p|
            z = v[p - 1]
            y = v[p] = (v[p] -  ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff
          }
          z = v[n]
          y = v[0] = (v[0] -  ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[0 & 3 ^ e] ^ z))) & 0xffffffff
          sum = (sum - Delta) & 0xffffffff
        end
        long2str(v, true)
      end

    end

  end

end