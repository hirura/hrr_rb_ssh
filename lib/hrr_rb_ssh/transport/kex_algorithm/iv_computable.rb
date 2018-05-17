# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/transport/encryption_algorithm'
require 'hrr_rb_ssh/transport/mac_algorithm'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      module IvComputable
        def build_key(_k, h, _x, session_id, key_length)
          k = DataType::Mpint.encode _k
          x = DataType::Byte.encode _x

          key = OpenSSL::Digest.digest(self.class::DIGEST, k + h + x + session_id)

          while key.length < key_length
            key = key + OpenSSL::Digest.digest(self.class::DIGEST, k + h + key )
          end

          key[0, key_length]
        end

        def iv_c_to_s transport, encryption_algorithm_c_to_s_name
          key_length = EncryptionAlgorithm[encryption_algorithm_c_to_s_name]::IV_LENGTH
          build_key(shared_secret, hash(transport), 'A'.ord, transport.session_id, key_length)
        end

        def iv_s_to_c transport, encryption_algorithm_s_to_c_name
          key_length = EncryptionAlgorithm[encryption_algorithm_s_to_c_name]::IV_LENGTH
          build_key(shared_secret, hash(transport), 'B'.ord, transport.session_id, key_length)
        end

        def key_c_to_s transport, encryption_algorithm_c_to_s_name
          key_length = EncryptionAlgorithm[encryption_algorithm_c_to_s_name]::KEY_LENGTH
          build_key(shared_secret, hash(transport), 'C'.ord, transport.session_id, key_length)
        end

        def key_s_to_c transport, encryption_algorithm_s_to_c_name
          key_length = EncryptionAlgorithm[encryption_algorithm_s_to_c_name]::KEY_LENGTH
          build_key(shared_secret, hash(transport), 'D'.ord, transport.session_id, key_length)
        end

        def mac_c_to_s transport, mac_algorithm_c_to_s_name
          key_length = MacAlgorithm[mac_algorithm_c_to_s_name]::KEY_LENGTH
          build_key(shared_secret, hash(transport), 'E'.ord, transport.session_id, key_length)
        end

        def mac_s_to_c transport, mac_algorithm_s_to_c_name
          key_length = MacAlgorithm[mac_algorithm_s_to_c_name]::KEY_LENGTH
          build_key(shared_secret, hash(transport), 'F'.ord, transport.session_id, key_length)
        end
      end
    end
  end
end
