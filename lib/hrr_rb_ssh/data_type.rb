# coding: utf-8
# vim: et ts=2 sw=2

require 'openssl'

module HrrRbSsh
  module DataType
    def self.[] key
      case key
      when 'byte'
        Byte
      when 'boolean'
        Boolean
      when 'uint32'
        Uint32
      when 'uint64'
        Uint64
      when 'string'
        String
      when 'mpint'
        Mpint
      when 'name-list'
        NameList
      end
    end

    class Byte
      def self.encode arg
        case arg
        when 0x00..0xff
          [arg].pack("C")
        else
          raise
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
          raise
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
          raise
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
          raise
        end
      end

      def self.decode io
        (io.read(4).unpack("N")[0] << 32) + (io.read(4).unpack("N")[0])
      end
    end

    class String
      def self.encode arg
        raise unless arg.kind_of? ::String
        raise if     arg.length > 0xffff_ffff
        [arg.length, arg].pack("Na*")
      end

      def self.decode io
        length = io.read(4).unpack("N")[0]
        io.read(length).unpack("a*")[0]
      end
    end

    class Mpint
      def self.encode arg
        raise unless arg.kind_of? ::Integer
        raise if     arg.size > 0xffff_ffff
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
        raise unless arg.kind_of? Array
        raise unless (arg.map(&:class) - [::String]).empty?
        raise if     arg.join(',').length > 0xffff_ffff
        [arg.join(',').length, arg.join(',')].pack("Na*")
      end

      def self.decode io
        length = io.read(4).unpack("N")[0]
        io.read(length).unpack("a*")[0].split(',')
      end
    end
  end
end
