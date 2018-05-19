# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/algorithm/publickey/ecdsa_sha2'

module HrrRbSsh
  module Algorithm
    class Publickey
      class EcdsaSha2Nistp384 < Publickey
        NAME = 'ecdsa-sha2-nistp384'
        DIGEST = 'sha384'
        IDENTIFIER = 'nistp384'
        CURVE_NAME = 'secp384r1'

        include EcdsaSha2
      end
    end
  end
end
