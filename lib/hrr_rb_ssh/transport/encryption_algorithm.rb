require 'hrr_rb_ssh/subclass_with_preference_listable'

module HrrRbSsh
  class Transport
    class EncryptionAlgorithm
      @subclass_list = Array.new
      class << self
        include SubclassWithPreferenceListable
      end
    end
  end
end

# OpenSSL 3 does not currently support loading various encryption algorithms
# https://www.openssl.org/docs/man3.0/man7/OSSL_PROVIDER-legacy.html
def safe_require(path)
  require path
rescue OpenSSL::Cipher::CipherError
  # noop
end

safe_require 'hrr_rb_ssh/transport/encryption_algorithm/none'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/three_des_cbc'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/blowfish_cbc'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/aes128_cbc'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/aes192_cbc'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/aes256_cbc'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/arcfour'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/cast128_cbc'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/aes128_ctr'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/aes192_ctr'
safe_require 'hrr_rb_ssh/transport/encryption_algorithm/aes256_ctr'
