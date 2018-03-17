# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/authentication/method/none'

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
