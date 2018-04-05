# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      module Functionable
        def initialize iv, key
          super

          @encryptor = OpenSSL::Cipher.new(self.class::CIPHER_NAME)
          @encryptor.encrypt
          @encryptor.padding = 0
          @encryptor.iv  = iv
          @encryptor.key = key

          @decryptor = OpenSSL::Cipher.new(self.class::CIPHER_NAME)
          @decryptor.decrypt
          @decryptor.padding = 0
          @decryptor.iv  = iv
          @decryptor.key = key
        end

        def encrypt data
          if data.empty?
            data
          else
            @encryptor.update(data) + @encryptor.final
          end
        end

        def decrypt data
          if data.empty?
            data
          else
            @decryptor.update(data) + @decryptor.final
          end
        end
      end
    end
  end
end
