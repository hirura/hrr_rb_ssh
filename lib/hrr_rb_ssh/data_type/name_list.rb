# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class DataType
    # NameList provides methods to convert a comma-separated list of names and binary string each other.
    class NameList < DataType
      # Convert a comma-separated list of names into binary string.
      #
      # @param [::Array] arg an array that containes names to be converted
      # @raise [::ArgumentError] when arg is not an array
      # @raise [::ArgumentError] when arg array containes an instance of not string
      # @return [::String] converted binary string
      def self.encode arg
        unless arg.kind_of? ::Array
          raise ArgumentError, "must be a kind of Array, but got #{arg.inspect}"
        end
        unless arg.all?{ |e| e.kind_of? ::String }
          raise ArgumentError, "must be with all elements of String, but got #{arg.inspect}"
        end
        joined_arg = arg.join(',')
        if joined_arg.length > 0xffff_ffff
          raise ArgumentError, "must be shorter than or equal to #{0xffff_ffff}, but got length #{joined_arg.length}"
        end
        [joined_arg.length, joined_arg].pack("Na*")
      end

      # Convert binary string into a comma-separated list of names.
      #
      # @param [::IO] io IO instance that has buffer to be read
      # @return [::Array] converted a comma-separated list of names
      def self.decode io
        length = io.read(4).unpack("N")[0]
        io.read(length).unpack("a*")[0].split(',')
      end
    end
  end
end
