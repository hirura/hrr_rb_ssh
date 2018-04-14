# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/subclass_with_preference_listable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      @subclass_list = Array.new
      class << self
        include SubclassWithPreferenceListable
      end
    end
  end
end

require 'hrr_rb_ssh/transport/encryption_algorithm/none'
require 'hrr_rb_ssh/transport/encryption_algorithm/three_des_cbc'
require 'hrr_rb_ssh/transport/encryption_algorithm/blowfish_cbc'
require 'hrr_rb_ssh/transport/encryption_algorithm/aes128_cbc'
require 'hrr_rb_ssh/transport/encryption_algorithm/aes192_cbc'
require 'hrr_rb_ssh/transport/encryption_algorithm/aes256_cbc'
require 'hrr_rb_ssh/transport/encryption_algorithm/arcfour'
require 'hrr_rb_ssh/transport/encryption_algorithm/cast128_cbc'
require 'hrr_rb_ssh/transport/encryption_algorithm/aes128_ctr'
require 'hrr_rb_ssh/transport/encryption_algorithm/aes192_ctr'
require 'hrr_rb_ssh/transport/encryption_algorithm/aes256_ctr'
