# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/kex_algorithm/elliptic_curve_diffie_hellman'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      class EllipticCurveDiffieHellmanSha2Nistp384 < KexAlgorithm
        NAME = 'ecdh-sha2-nistp384'
        PREFERENCE = 110
        DIGEST = 'sha384'
        CURVE_NAME = 'secp384r1'
        include EllipticCurveDiffieHellman
      end
    end
  end
end
