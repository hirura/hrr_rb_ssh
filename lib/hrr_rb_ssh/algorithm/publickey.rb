# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  module Algorithm
    class Publickey
      @subclass_list = Array.new
      class << self
        def inherited klass
          @subclass_list.push klass if @subclass_list
        end

        def [] key
          __subclass_list__(__method__).find{ |klass| klass::NAME == key }
        end

        def __subclass_list__ method_name
          send(:method_missing, method_name) unless @subclass_list
          @subclass_list
        end

        private :__subclass_list__
      end
    end
  end
end

require 'hrr_rb_ssh/algorithm/publickey/ssh_dss'
require 'hrr_rb_ssh/algorithm/publickey/ssh_rsa'
require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2_nistp256'
require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2_nistp384'
require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2_nistp521'
