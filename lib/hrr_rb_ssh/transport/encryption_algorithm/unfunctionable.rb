# coding: utf-8
# vim: et ts=2 sw=2

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      module Unfunctionable
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
