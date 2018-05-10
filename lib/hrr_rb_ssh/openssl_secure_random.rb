# coding: utf-8
# vim: et ts=2 sw=2

require 'securerandom'
require 'openssl'

module HrrRbSsh
  module OpenSslSecureRandom
    N_BYTES = 1024
    OpenSSL::Random.seed SecureRandom.random_bytes(N_BYTES)
  end
end
