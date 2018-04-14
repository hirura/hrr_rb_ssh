# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/mac_algorithm/functionable'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      class HmacSha1 < MacAlgorithm
        NAME       = 'hmac-sha1'
        PREFERENCE = 40
        DIGEST     = 'sha1'
        DIGEST_LENGTH = 20
        KEY_LENGTH    = 20
        include Functionable
      end
    end
  end
end
