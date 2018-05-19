# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2'

module HrrRbSsh
  module Algorithm
    class Publickey
      class EcdsaSha2Nistp521 < Publickey
        NAME = 'ecdsa-sha2-nistp521'
        DIGEST = 'sha512'
        IDENTIFIER = 'nistp521'
        CURVE_NAME = 'secp521r1'

        include EcdsaSha2
      end
    end
  end
end
