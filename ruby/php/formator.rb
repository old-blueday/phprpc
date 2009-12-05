############################################################
#                                                          #
# The implementation of PHPRPC Protocol 3.0                #
#                                                          #
# formator.rb                                              #
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
# PHP serialize/unserialize library.
#
# Copyright: Ma Bingyao <andot@ujn.edu.cn>
# Version: 1.3
# LastModified: Feb 27, 2009
# This library is free.  You can redistribute it and/or modify it.

require 'stringio'

module PHP

  class Formator

    class << self

      public

      def serialize(obj)
        _serialize(obj, Array.new(1, nil))
      end

      def unserialize(str)
        _unserialize(StringIO.new(str), Array.new)
      end

      private

      @@classCache = Hash.new

      def serialize_int(i)
        (-2147483648..2147483647) === i ? "i:#{i};": serialize_string(i.to_s)
      end

      def serialize_double(d)
        case d.infinite?
        when -1 then 'd:-INF;'
        when 1 then 'd:INF;'
        else d.nan? ? 'd:NAN;' : "d:#{d};"
        end
      end

      def serialize_string(s)
        "s:#{s.length}:\"#{s}\";"
      end

      def serialize_time(time, obj_container)
        obj_container.push(nil, nil, nil, nil, nil, nil, nil)
        s = 'O:11:"PHPRPC_Date":7:{'
        s << serialize_string('year') << serialize_int(time.year)
        s << serialize_string('month') << serialize_int(time.month)
        s << serialize_string('day') << serialize_int(time.day)
        s << serialize_string('hour') << serialize_int(time.hour)
        s << serialize_string('minute') << serialize_int(time.min)
        s << serialize_string('second') << serialize_int(time.sec)
        s << serialize_string('millisecond') << serialize_int(time.usec / 1000)
        s << '}'
      end

      def serialize_array(a, obj_container)
        s = "a:#{a.size}:{"
        a.each_with_index { |item, index|
          s << "i:#{index};#{_serialize(item, obj_container)}"
        }
        s << '}'
      end

      def serialize_hash(h, obj_container)
        s = "a:#{h.size}:{"
        h.each { |key, value|
          s << case key
          when Integer then (-2147483648..2147483647) === key ? "i:#{key};" : serialize_string(key.to_s)
          when String then serialize_string(key)
          else serialize_string(key.to_s)
          end << _serialize(value, obj_container)
        }
        s << '}'
      end

      def serialize_struct(obj, obj_container)
        classname = obj.class.to_s
        classname['Struct::'] = ''
        @@classCache[classname] = obj.class
        members = obj.members
        s = "O:#{classname.length}:\"#{classname.to_s}\":#{members.length}:{"
        members.each { |member|
          s << "#{serialize_string(member)}#{_serialize(obj[member], obj_container)}"
        }
        s << '}'
      end

      def serialize_object(obj, obj_container)
        classname = obj.class.to_s.split('::').join('_')
        @@classCache[classname] = obj.class
        if obj.respond_to?(:serialize) and obj.respond_to?(:unserialize) then
          s = obj.serialize
          "C:#{classname.length}:\"#{classname.to_s}\":#{s.length}:{#{s}}"
        else
          vars = obj.instance_variables
          if obj.respond_to?(:__sleep, true) then
            svars = obj.send(:__sleep)
            s = "O:#{classname.length}:\"#{classname.to_s}\":#{svars.length}:{"
            svars.each { |var|
              s << serialize_string(var.to_s)
              if obj.respond_to?(var.to_sym) then
                s << _serialize(obj.send(var.to_sym), obj_container)
              elsif vars.include?('@' + var.to_s) then
                s << _serialize(obj.instance_variable_get(('@' + var.to_s).to_sym), obj_container)
              else
                s << _serialize(nil, obj_container)
              end
            }
            s << '}'
          else
            s = "O:#{classname.length}:\"#{classname.to_s}\":#{vars.length}:{"
            vars.each { |var|
              s << "#{serialize_string(var.delete('@'))}#{_serialize(obj.instance_variable_get(var), obj_container)}"
            }
            s << '}'
          end
        end
      end

      def _serialize(obj, obj_container = nil)
        obj_id = obj_container.size
        obj_container.push(nil)
        case obj
        when NilClass then 'N;'
        when FalseClass then "b:0;"
        when TrueClass then "b:1;"
        when Integer then serialize_int(obj)
        when Float then serialize_double(obj)
        when String then
          if obj_container.include?(obj) then
            "r:#{obj_container.index(obj)};"
          else
            obj_container[obj_id] = obj
            serialize_string(obj)
          end
        when Symbol then
          if obj_container.include?(obj) then
            "r:#{obj_container.index(obj)};"
          else
            obj_container[obj_id] = obj
            serialize_string(obj.to_s)
          end
        when Time then
          if obj_container.include?(obj) then
            "r:#{obj_container.index(obj)};"
          else
            obj_container[obj_id] = obj
            serialize_time(obj, obj_container)
          end
        when Array then
          if obj_container.include?(obj) then
            obj_container.pop
            "R:#{obj_container.index(obj)};"
          else
            obj_container[obj_id] = obj
            serialize_array(obj, obj_container)
          end
        when Hash then
          if obj_container.include?(obj) then
            obj_container.pop
            "R:#{obj_container.index(obj)};"
          else
            obj_container[obj_id] = obj
            serialize_hash(obj, obj_container)
          end
        when Struct then
          if obj_container.include?(obj) then
            "r:#{obj_container.index(obj)};"
          else
            obj_container[obj_id] = obj
            serialize_struct(obj, obj_container)
          end
        else
          if obj_container.include?(obj) then
            "r:#{obj_container.index(obj)};"
          else
            obj_container[obj_id] = obj
            serialize_object(obj, obj_container)
          end
        end
      end

      def get_class(name)
        begin
          name.split('.').inject(Object) {|x,y| x.const_get(y) }
        rescue
          nil
        end
      end

      def get_class2(name, ps, i, c)
        if i < ps.size then
          p = ps[i]
          name[p] = c
          cls = get_class2(name, ps, i + 1, '.')
          if (i + 1 < ps.size) and (cls.nil?) then
            cls = get_class2(name, ps, i + 1, '_')
          end
          return cls
        else
          get_class(name)
        end
      end

      def get_class_by_alias(name)
        if @@classCache.has_key?(name) then
          @@classCache[name]
        else
          cls = get_class(name)
          if cls.nil? then
            ps = []
            p = name.index('_')
            while not p.nil?
              ps.push(p)
              p = name.index('_', p + 1)
            end
            cls = get_class2(name, ps, 0, '.')
          end
          if not cls.nil? then
            @@classCache[name] = cls
          else
            @@classCache[name] = Object.const_set(name.to_sym, Class.new)
          end
        end
      end

      def read_number(string)
        num = ''
        loop do
          c = string.read(1)
          break if (c == ':') or (c == ';')
          num << c
        end
        num
      end

      def unserialize_boolean(string)
        string.read(1)
        result = (string.read(1) == true)
        string.read(1)
        result
      end

      def unserialize_int(string)
        string.read(1)
        read_number(string).to_i
      end

      def unserialize_double(string)
        string.read(1)
        d = read_number(string)
        case d
        when 'NAN' then 0.0/0.0
        when 'INF' then +1.0/0.0
        when '-INF' then -1.0/0.0
        else (d.delete('.eE') == d) ? d.to_i : d.to_f
        end
      end

      def unserialize_string(string)
        len = unserialize_int(string)
        string.read(len + 3)[1...-2]
      end

      def unserialize_escaped_string(string)
        len = unserialize_int(string)
        s = ''
        string.read(1)
        len.times {
          c = string.read(1)
          s << (c == "\\" ? string.read(2).to_i(16).chr : c)
        }
        string.read(2)
        return s
      end

      def unserialize_unicode_string(string)
        len = unserialize_int(string)
        s = ''
        string.read(1)
        len.times {
          c = string.read(1)
          s << (c == "\\" ? [string.read(4).to_i(16)].pack("U") : c)
        }
        string.read(2)
        return s
      end

      def unserialize_hash(string, obj_container)
        count = unserialize_int(string)
        obj = Hash.new
        obj_container.push(obj)
        string.read(1)
        count.times {
          tag = string.read(1)
          if tag.nil? then
            raise 'End of Stream encountered before parsing was completed.'
          end
          key = case tag
          when 'i' then unserialize_int(string)
          when 's' then unserialize_string(string)
          when 'S' then unserialize_escaped_string(string)
          when 'U' then unserialize_unicode_string(string)
          else raise 'Unexpected Tag: "' + tag + '".'
          end
          obj[key] = _unserialize(string, obj_container)
        }
        string.read(1)
        return obj
      end

      def unserialize_key(string)
        tag = string.read(1)
        if tag.nil? then
          raise 'End of Stream encountered before parsing was completed.'
        end
        case tag
        when 's' then unserialize_string(string)
        when 'S' then unserialize_escaped_string(string)
        when 'U' then unserialize_unicode_string(string)
        else raise 'Unexpected Tag: "' + tag + '".'
        end
      end

      def unserialize_date(string, obj_container)
        obj_id = obj_container.size
        obj_container.push(nil)
        h = Hash.new
        count = unserialize_int(string)
        string.read(1)
        count.times {
          key = unserialize_key(string)
          h[key] = _unserialize(string, obj_container)
        }
        string.read(1)
        time = Time.mktime(h['year'], h['month'], h['day'], h['hour'], h['minute'], h['second'], h['millisecond'] * 1000)
        obj_container[obj_id] = time
      end

      def unserialize_object(string, obj_container)
        classname = unserialize_string(string)
        string.pos -= 1
        if classname == 'PHPRPC_Date' then
          unserialize_date(string, obj_container)
        else
          cls = get_class_by_alias(classname)
          obj = cls.new
          obj_container.push(obj)
          count = unserialize_int(string)
          string.read(1)
          vars = obj.instance_variables
          count.times {
            key = unserialize_key(string)
            if key[0] == 0 then
              key = key[key.index("\0", 1) + 1...key.length]
            end
            value = _unserialize(string, obj_container)
            var = '@' << key
            begin
              obj[key] = value
            rescue
              if not vars.include?(var) then
                cls.send(:attr_accessor, key)
                cls.send(:public, key, key + '=')
              end
              obj.instance_variable_set(var.to_sym, value)
            end
          }
          string.read(1)
          obj.send(:__wakeup) if obj.respond_to?(:__wakeup, true)
          obj
        end
      end

      def unserialize_custom_object(string, obj_container)
        classname = unserialize_string(string)
        string.pos -= 1
        cls = get_class_by_alias(classname)
        obj = cls.new
        obj_container.push(obj)
        len = unserialize_int(string)
        str = string.read(len + 2)[1...-1]
        if !obj.respond_to?(:serialize) or !obj.respond_to?(:unserialize) then
          cls.send(:attr_accessor, :data)
          cls.send(:public, :data, :data=)
          cls.send(:alias_method, :serialize, :data)
          cls.send(:alias_method, :unserialize, :data=)
        end
        obj.unserialize(str)
        obj
      end

      def _unserialize(string, obj_container)
        tag = string.read(1)
        if tag.nil? then
          raise 'End of Stream encountered before parsing was completed.'
        end
        case tag
        when 'N' then
          string.read(1)
          obj = nil
          obj_container.push(obj)
        when 'b' then
          obj = unserialize_boolean(string)
          obj_container.push(obj)
        when 'i' then
          obj = unserialize_int(string)
          obj_container.push(obj)
        when 'd' then
          obj = unserialize_double(string)
          obj_container.push(obj)
        when 's' then
          obj = unserialize_string(string)
          obj_container.push(obj)
        when 'S' then
          obj = unserialize_escaped_string(string)
          obj_container.push(obj)
        when 'U' then
          obj = unserialize_unicode_string(string)
          obj_container.push(obj)
        when 'r' then
          obj = obj_container[unserialize_int(string) - 1]
          obj_container.push(obj)
        when 'R' then
          obj = obj_container[unserialize_int(string) - 1]
        when 'a' then
          obj = unserialize_hash(string, obj_container)
        when 'O' then
          obj = unserialize_object(string, obj_container)
        when 'C' then
          obj = unserialize_custom_object(string, obj_container)
        else
          raise 'Unexpected Tag: "' + tag + '".'
        end
        obj
      end

    end # class self

  end # class Formator

end # module PHP