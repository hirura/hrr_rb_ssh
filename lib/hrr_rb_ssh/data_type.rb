# coding: utf-8
# vim: et ts=2 sw=2

require 'openssl'

module HrrRbSsh
  module DataType
    class Byte
      def self.encode arg
        case arg
        when 0x00..0xff
          [arg].pack("C")
        else
          raise ArgumentError, "must be in #{0x00}..#{0xff}, but got #{arg.inspect}"
        end
      end

      def self.decode io
        io.read(1).unpack("C")[0]
      end
    end

    class Boolean
      def self.encode arg
        case arg
        when false
          [0].pack("C")
        when true
          [1].pack("C")
        else
          raise ArgumentError, "must be #{true} or #{false}, but got #{arg.inspect}"
        end
      end

      def self.decode io
        if 0 == io.read(1).unpack("C")[0]
          false
        else
          true
        end
      end
    end

    class Uint32
      def self.encode arg
        case arg
        when 0x0000_0000..0xffff_ffff
          [arg].pack("N")
        else
          raise ArgumentError, "must be in #{0x0000_0000}..#{0xffff_ffff}, but got #{arg.inspect}"
        end
      end

      def self.decode io
        io.read(4).unpack("N")[0]
      end
    end

    class Uint64
      def self.encode arg
        case arg
        when 0x0000_0000_0000_0000..0xffff_ffff_ffff_ffff
          [arg >> 32].pack("N") + [arg & 0x0000_0000_ffff_ffff].pack("N")
        else
          raise ArgumentError, "must be in #{0x0000_0000_0000_0000}..#{0xffff_ffff_ffff_ffff}, but got #{arg.inspect}"
        end
      end

      def self.decode io
        (io.read(4).unpack("N")[0] << 32) + (io.read(4).unpack("N")[0])
      end
    end

    class String
      def self.encode arg
        unless arg.kind_of? ::String
          raise ArgumentError, "must be a kind of String, but got #{arg.inspect}"
        end
        if arg.length > 0xffff_ffff
          raise ArgumentError, "must be shorter than or equal to #{0xffff_ffff}, but got length #{arg.length}"
        end
        [arg.length, arg].pack("Na*")
      end

      def self.decode io
        length = io.read(4).unpack("N")[0]
        io.read(length).unpack("a*")[0]
      end
    end

    class Mpint
      def self.encode arg
        unless arg.kind_of? ::Integer
          raise ArgumentError, "must be a kind of Integer, but got #{arg.inspect}"
        end
        bn = ::OpenSSL::BN.new(arg)
        if bn < 0
          # get 2's complement
          tc = bn.to_i & ((1 << (bn.num_bytes * 8)) - 1)
          # get hex representation
          hex_str = "%x" % tc

          if tc[(bn.num_bytes * 8) - 1] == 1
            [bn.num_bytes, hex_str].pack("NH*")
          else
            [bn.num_bytes + 1, "ff" + hex_str].pack("NH*")
          end
        else
          bn.to_s(0)
        end
      end

      def self.decode io
        length = io.read(4).unpack("N")[0]
        hex_str = io.read(length).unpack("H*")[0]
        # get temporal integer value
        value = hex_str.hex
        if length == 0
          0
        elsif value[(length * 8) - 1] == 0
          value
        else
          num_bytes = if hex_str.start_with?("ff") then length - 1 else length end
          - (((~ value) & ((1 << (num_bytes * 8)) - 1)) + 1)
        end
      end
    end

    class NameList
      def self.encode arg
        unless arg.kind_of? Array
          raise ArgumentError, "must be a kind of Array, but got #{arg.inspect}"
        end
        unless (arg.map(&:class) - [::String]).empty?
          raise ArgumentError, "must be with all elements of String, but got #{arg.inspect}"
        end
        joined_arg = arg.join(',')
        if joined_arg.length > 0xffff_ffff
          raise ArgumentError, "must be shorter than or equal to #{0xffff_ffff}, but got length #{joined_arg.length}"
        end
        [joined_arg.length, joined_arg].pack("Na*")
      end

      def self.decode io
        length = io.read(4).unpack("N")[0]
        io.read(length).unpack("a*")[0].split(',')
      end
    end
  end
end
