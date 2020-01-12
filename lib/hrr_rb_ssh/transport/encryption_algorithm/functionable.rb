# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      module Functionable
        include Loggable

        def self.included klass
          cipher = OpenSSL::Cipher.new(klass::CIPHER_NAME)
          klass.const_set(:IV_LENGTH,  cipher.iv_len)
          klass.const_set(:KEY_LENGTH, cipher.key_len)
        end

        def initialize direction, iv, key, logger: nil
          self.logger = logger
          @cipher = OpenSSL::Cipher.new(self.class::CIPHER_NAME)
          case direction
          when Direction::OUTGOING
            @cipher.encrypt
          when Direction::INCOMING
            @cipher.decrypt
          end
          @cipher.padding = 0
          @cipher.iv  = iv
          @cipher.key = key
        end

        def block_size
          self.class::BLOCK_SIZE
        end

        def iv_length
          self.class::IV_LENGTH
        end

        def key_length
          self.class::KEY_LENGTH
        end

        def encrypt data
          if data.empty?
            data
          else
            @cipher.update(data) + @cipher.final
          end
        end

        def decrypt data
          if data.empty?
            data
          else
            @cipher.update(data) + @cipher.final
          end
        end
      end
    end
  end
end
