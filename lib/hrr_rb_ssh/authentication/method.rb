# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Authentication
    module Method
      def self.list
        Method.list
      end

      def self.name_list
        Method.name_list
      end

      def self.[] key
        Method[key]
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/method'
require 'hrr_rb_ssh/authentication/method/none'
require 'hrr_rb_ssh/authentication/method/password'
require 'hrr_rb_ssh/authentication/method/publickey'
