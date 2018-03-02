# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      name_list = [
        'none'
      ]

      class None
        BLOCK_SIZE  = 0
        IV_LENGTH   = 0
        KEY_LENGTH  = 0

        def initialize iv=nil, key=nil
          @logger = HrrRbSsh::Logger.new self.class.name
        end

        def block_size
          BLOCK_SIZE
        end

        def iv_length
          IV_LENGTH
        end

        def key_length
          KEY_LENGTH
        end

        def encrypt data
          data
        end

        def decrypt data
          data
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = None
      end
    end
  end
end
