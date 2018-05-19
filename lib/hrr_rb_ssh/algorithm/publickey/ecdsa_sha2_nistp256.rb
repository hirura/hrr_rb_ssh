# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2'

module HrrRbSsh
  module Algorithm
    class Publickey
      class EcdsaSha2Nistp256 < Publickey
        NAME = 'ecdsa-sha2-nistp256'
        DIGEST = 'sha256'
        IDENTIFIER = 'nistp256'
        CURVE_NAME = 'prime256v1'

        include EcdsaSha2
      end
    end
  end
end
