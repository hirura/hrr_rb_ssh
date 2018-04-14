# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/mac_algorithm/functionable'

module HrrRbSsh
  class Transport
    class MacAlgorithm
      class HmacMd5 < MacAlgorithm
        NAME       = 'hmac-md5'
        PREFERENCE = 30
        DIGEST     = 'md5'
        DIGEST_LENGTH = 16
        KEY_LENGTH    = 16
        include Functionable
      end
    end
  end
end
