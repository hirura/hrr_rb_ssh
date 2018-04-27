# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/subclass_with_preference_listable'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      @subclass_list = Array.new
      class << self
        include SubclassWithPreferenceListable
      end
    end
  end
end

require 'hrr_rb_ssh/transport/mac_algorithm/none'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_sha1'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_sha1_96'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_md5'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_md5_96'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_sha2_256'
require 'hrr_rb_ssh/transport/mac_algorithm/hmac_sha2_512'
