# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/subclass_without_preference_listable'

module HrrRbSsh
  module Algorithm
    class Publickey
      @subclass_list = Array.new
      class << self
        include SubclassWithoutPreferenceListable
      end
    end
  end
end

require 'hrr_rb_ssh/algorithm/publickey/ssh_dss'
require 'hrr_rb_ssh/algorithm/publickey/ssh_rsa'
require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2_nistp256'
require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2_nistp384'
require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2_nistp521'
