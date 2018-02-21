# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      name_list = [
        'diffie-hellman-group1-sha1'
      ]

      class DiffieHellmanGroup1Sha1
        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = DiffieHellmanGroup1Sha1
      end
    end
  end
end
