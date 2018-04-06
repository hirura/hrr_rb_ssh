# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      module Functionable
        def initialize direction, iv, key
          super

          @cipher = OpenSSL::Cipher.new(self.class::CIPHER_NAME)
          case direction
          when HrrRbSsh::Transport::Direction::OUTGOING
            @cipher.encrypt
          when HrrRbSsh::Transport::Direction::INCOMING
            @cipher.decrypt
          end
          @cipher.padding = 0
          @cipher.iv  = iv
          @cipher.key = key
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
