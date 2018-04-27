# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/mac_algorithm/functionable'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      class HmacSha2_256 < MacAlgorithm
        NAME       = 'hmac-sha2-256'
        PREFERENCE = 50
        DIGEST     = 'sha256'
        DIGEST_LENGTH = 32
        KEY_LENGTH    = 32
        include Functionable
      end
    end
  end
end
