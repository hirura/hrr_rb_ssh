# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group_exchange'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      class DiffieHellmanGroupExchangeSha1 < KexAlgorithm
        NAME = 'diffie-hellman-group-exchange-sha1'
        PREFERENCE = 30
        DIGEST = 'sha1'
        include DiffieHellmanGroupExchange
      end
    end
  end
end
