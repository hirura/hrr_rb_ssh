# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Authentication
    module Method
      @@list ||= Hash.new

      def self.[] key
        @@list[key]
      end

      def self.name_list
        @@list.keys
      end
    end
  end
end
