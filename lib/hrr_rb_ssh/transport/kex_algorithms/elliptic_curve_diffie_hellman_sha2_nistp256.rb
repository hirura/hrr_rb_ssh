module HrrRbSsh
  class Transport
    class KexAlgorithms
      class EllipticCurveDiffieHellmanSha2Nistp256
        NAME = 'ecdh-sha2-nistp256'
        PREFERENCE = 100
        DIGEST = 'sha256'
        CURVE_NAME = 'prime256v1'
        include EllipticCurveDiffieHellman
      end
    end
  end
end
