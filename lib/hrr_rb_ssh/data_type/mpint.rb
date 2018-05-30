# coding: utf-8
# vim: et ts=2 sw=2

require 'openssl'

module HrrRbSsh
  class DataType
    # Mpint provides methods to convert integer value and multiple precision integer in two's complement as binary string each other.
    class Mpint < DataType
      # Convert integer value into multiple precision integer in two's complement as binary string.
      #
      # @param [::Integer] arg integer value to be converted
      # @raise [::ArgumentError] when arg is not an integer value
      # @return [::String] converted multiple precision integer in two's complement as binary string
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

      # Convert multiple precision integer in two's complement as binary string into integer value.
      #
      # @param [::IO] io IO instance that has buffer to be read
      # @return [::Integer] converted integer value
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
  end
end
