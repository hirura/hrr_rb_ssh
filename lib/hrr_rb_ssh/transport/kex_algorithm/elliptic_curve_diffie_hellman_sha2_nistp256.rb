# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/kex_algorithm/elliptic_curve_diffie_hellman'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      class EllipticCurveDiffieHellmanSha2Nistp256 < KexAlgorithm
        NAME = 'ecdh-sha2-nistp256'
        PREFERENCE = 100
        DIGEST = 'sha256'
        CURVE_NAME = 'prime256v1'
        include EllipticCurveDiffieHellman
      end
    end
  end
end
