# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Transport
    class KexAlgorithm
      def self.list
        KexAlgorithm.list
      end

      def self.name_list
        KexAlgorithm.name_list
      end

      def self.[] key
        KexAlgorithm[key]
      end
    end
  end
end

require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group1_sha1'
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group14_sha1'
