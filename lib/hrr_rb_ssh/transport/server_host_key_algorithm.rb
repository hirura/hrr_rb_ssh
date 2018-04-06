# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      def self.list
        ServerHostKeyAlgorithm.list
      end

      def self.name_list
        ServerHostKeyAlgorithm.name_list
      end

      def self.[] key
        ServerHostKeyAlgorithm[key]
      end
    end
  end
end

require 'hrr_rb_ssh/transport/server_host_key_algorithm/ssh_rsa'
