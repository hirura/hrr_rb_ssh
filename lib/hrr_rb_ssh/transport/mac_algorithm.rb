# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Transport
    class MacAlgorithm
      def self.list
        MacAlgorithm.list
      end

      def self.name_list
        MacAlgorithm.name_list
      end

      def self.[] key
        MacAlgorithm[key]
      end
    end
  end
end

require 'hrr_rb_ssh/transport/mac_algorithm/mac_algorithm'
require 'hrr_rb_ssh/transport/mac_algorithm/none'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_sha1'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_sha1_96'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_md5'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_md5_96'
