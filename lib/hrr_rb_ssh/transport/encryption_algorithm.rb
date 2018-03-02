# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/encryption_algorithm/none'
require 'hrr_rb_ssh/transport/encryption_algorithm/aes_128_cbc'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
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
