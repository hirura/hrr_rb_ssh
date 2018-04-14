# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/subclass_with_preference_listable'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      @subclass_list = Array.new
      class << self
        include SubclassWithPreferenceListable
      end
    end
  end
end

require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group1_sha1'
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group14_sha1'
