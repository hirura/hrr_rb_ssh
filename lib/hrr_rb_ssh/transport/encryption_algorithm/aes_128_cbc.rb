# coding: utf-8
# vim: et ts=2 sw=2

require 'openssl'

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      name_list = [
        'aes128-cbc'
      ]

      class Aes128Cbc
        CIPHER_NAME = "AES-128-CBC"

        BLOCK_SIZE  = OpenSSL::Cipher.new(CIPHER_NAME).block_size
        IV_LENGTH   = OpenSSL::Cipher.new(CIPHER_NAME).iv_len
        KEY_LENGTH  = OpenSSL::Cipher.new(CIPHER_NAME).key_len

        def initialize iv, key
          @logger = HrrRbSsh::Logger.new self.class.name

          @encryptor = OpenSSL::Cipher.new(CIPHER_NAME)
          @encryptor.encrypt
          @encryptor.padding = 0
          @encryptor.iv  = iv
          @encryptor.key = key

          @decryptor = OpenSSL::Cipher.new(CIPHER_NAME)
          @decryptor.decrypt
          @decryptor.padding = 0
          @decryptor.iv  = iv
          @decryptor.key = key
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
          @encryptor.update(data) + @encryptor.final
        end

        def decrypt data
          @decryptor.update(data) + @decryptor.final
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = Aes128Cbc
      end
    end
  end
end
