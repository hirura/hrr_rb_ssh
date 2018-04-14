# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/mac_algorithm/functionable'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      class HmacMd5_96 < MacAlgorithm
        NAME       = 'hmac-md5-96'
        PREFERENCE = 10
        DIGEST     = 'md5'
        DIGEST_LENGTH = 12
        KEY_LENGTH    = 16
        include Functionable
      end
    end
  end
end
