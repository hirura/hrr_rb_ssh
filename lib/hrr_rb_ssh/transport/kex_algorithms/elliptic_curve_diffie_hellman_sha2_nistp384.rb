module HrrRbSsh
  class Transport
    class KexAlgorithms
      class EllipticCurveDiffieHellmanSha2Nistp384
        NAME = 'ecdh-sha2-nistp384'
        PREFERENCE = 110
        DIGEST = 'sha384'
        CURVE_NAME = 'secp384r1'
        include EllipticCurveDiffieHellman
      end
    end
  end
end
