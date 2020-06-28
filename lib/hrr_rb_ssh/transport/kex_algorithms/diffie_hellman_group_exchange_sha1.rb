module HrrRbSsh
  class Transport
    class KexAlgorithms
      class DiffieHellmanGroupExchangeSha1
        NAME = 'diffie-hellman-group-exchange-sha1'
        PREFERENCE = 30
        DIGEST = 'sha1'
        include DiffieHellmanGroupExchange
      end
    end
  end
end
