# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/mac_algorithm/functionable'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      class HmacSha2_512 < MacAlgorithm
        NAME       = 'hmac-sha2-512'
        PREFERENCE = 60
        DIGEST     = 'sha512'
        DIGEST_LENGTH = 64
        KEY_LENGTH    = 64
        include Functionable
      end
    end
  end
end
