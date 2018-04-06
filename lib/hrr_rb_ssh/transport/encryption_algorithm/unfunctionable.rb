# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      module Unfunctionable
        def block_size
          0
        end

        def iv_length
          0
        end

        def key_length
          0
        end

        def encrypt data
          data
        end

        def decrypt data
          data
        end
      end
    end
  end
end
