module HrrRbSsh
  class Transport
    class KexAlgorithms
      class DiffieHellmanGroupExchangeSha256
        NAME = 'diffie-hellman-group-exchange-sha256'
        PREFERENCE = 40
        DIGEST = 'sha256'
        include DiffieHellmanGroupExchange
      end
    end
  end
end
