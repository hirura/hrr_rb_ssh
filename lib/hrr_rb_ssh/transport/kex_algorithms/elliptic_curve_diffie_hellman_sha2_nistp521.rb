module HrrRbSsh
  class Transport
    class KexAlgorithms
      class EllipticCurveDiffieHellmanSha2Nistp521
        NAME = 'ecdh-sha2-nistp521'
        PREFERENCE = 120
        DIGEST = 'sha512'
        CURVE_NAME = 'secp521r1'
        include EllipticCurveDiffieHellman
      end
    end
  end
end
