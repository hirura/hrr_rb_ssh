# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group14_sha1'

module HrrRbSsh
  class Transport
    class KexAlgorithm
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
