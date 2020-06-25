module HrrRbSsh
  module OpenSslSecureRandom
    N_BYTES = 1024
    OpenSSL::Random.seed SecureRandom.random_bytes(N_BYTES)
  end
end
