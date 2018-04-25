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
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group_exchange_sha1'
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group_exchange_sha256'
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group14_sha256'
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group15_sha512'
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group16_sha512'
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group17_sha512'
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group18_sha512'
require 'hrr_rb_ssh/transport/kex_algorithm/elliptic_curve_diffie_hellman_sha2_nistp256'
require 'hrr_rb_ssh/transport/kex_algorithm/elliptic_curve_diffie_hellman_sha2_nistp384'
require 'hrr_rb_ssh/transport/kex_algorithm/elliptic_curve_diffie_hellman_sha2_nistp521'
