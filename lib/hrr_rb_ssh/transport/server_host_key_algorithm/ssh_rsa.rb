# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class ServerHostKeyAlgorithm
      name_list = [
        'ssh-rsa'
      ]

      class SshRsa
        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = SshRsa
      end
    end
  end
end
