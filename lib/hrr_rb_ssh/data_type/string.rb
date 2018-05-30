# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class DataType
    # String provides methods to convert Ruby's string value and binary string each other.
    class String < DataType
      # Convert Ruby's string value into binary string.
      #
      # @param [::String] arg Ruby's string value to be converted
      # @raise [::ArgumentError] when arg is not string
      # @raise [::ArgumentError] when length of arg is longer than 0xffff_ffff
      # @return [::String] converted binary string
      def self.encode arg
        unless arg.kind_of? ::String
          raise ArgumentError, "must be a kind of String, but got #{arg.inspect}"
        end
        if arg.length > 0xffff_ffff
          raise ArgumentError, "must be shorter than or equal to #{0xffff_ffff}, but got length #{arg.length}"
        end
        [arg.length, arg].pack("Na*")
      end

      # Convert binary string into Ruby's string value.
      #
      # @param [::IO] io IO instance that has buffer to be read
      # @return [::String] converted Ruby's string value
      def self.decode io
        length = io.read(4).unpack("N")[0]
        io.read(length).unpack("a*")[0]
      end
    end
  end
end
