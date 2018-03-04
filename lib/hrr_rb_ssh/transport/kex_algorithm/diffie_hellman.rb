# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/data_type'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      class DiffieHellman
        H0_DEFINITION = [
          ['string', 'V_C'],
          ['string', 'V_S'],
          ['string', 'I_C'],
          ['string', 'I_S'],
          ['string', 'K_S'],
          ['mpint',  'e'],
          ['mpint',  'f'],
          ['mpint',  'k'],
        ]

        def initialize
          @logger = HrrRbSsh::Logger.new self.class.name

          @dh = OpenSSL::PKey::DH.new
          @dh.set_pqg OpenSSL::BN.new(self.class::P, 16), nil, OpenSSL::BN.new(self.class::G)
          @dh.generate_key!
        end

        def encode definition, payload
          definition.map{ |data_type, field_name|
            field_value = if payload[field_name].instance_of? ::Proc then payload[field_name].call else payload[field_name] end
            HrrRbSsh::Transport::DataType[data_type].encode(field_value)
          }.join
        end

        def set_e e
          @e = e
        end

        def shared_secret
          k = OpenSSL::BN.new(@dh.compute_key(@e), 2).to_i

          k
        end

        def pub_key
          f = @dh.pub_key.to_i

          f
        end

        def hash transport
          e = @e
          k = shared_secret
          f = pub_key

          h0_payload = {
            'V_C' => transport.v_c,
            'V_S' => transport.v_s,
            'I_C' => transport.i_c,
            'I_S' => transport.i_s,
            'K_S' => transport.server_host_key_algorithm.server_public_host_key,
            'e'   => e,
            'f'   => f,
            'k'   => k,
          }
          h0 = encode H0_DEFINITION, h0_payload

          h = OpenSSL::Digest.digest self.class::DIGEST, h0

          h
        end

        def sign transport
          h = hash transport
          s = transport.server_host_key_algorithm.sign self.class::DIGEST, h

          s
        end

        def build_key(_k, h, _x, session_id, key_length)
          k = HrrRbSsh::Transport::DataType::Mpint.encode _k
          x = HrrRbSsh::Transport::DataType::Byte.encode _x

          key = OpenSSL::Digest.digest(self.class::DIGEST, k + h + x + session_id)

          while key.length < key_length
            key = key + OpenSSL::Digest.digest(self.class::DIGEST, k + h + key )
          end

          key[0, key_length]
        end

        def iv_c_to_s transport, encryption_algorithm_c_to_s_name
          key_length = HrrRbSsh::Transport::EncryptionAlgorithm[encryption_algorithm_c_to_s_name]::IV_LENGTH
          build_key(shared_secret, hash(transport), 'A'.ord, transport.session_id, key_length)
        end

        def iv_s_to_c transport, encryption_algorithm_s_to_c_name
          key_length = HrrRbSsh::Transport::EncryptionAlgorithm[encryption_algorithm_s_to_c_name]::IV_LENGTH
          build_key(shared_secret, hash(transport), 'B'.ord, transport.session_id, key_length)
        end

        def key_c_to_s transport, encryption_algorithm_c_to_s_name
          key_length = HrrRbSsh::Transport::EncryptionAlgorithm[encryption_algorithm_c_to_s_name]::KEY_LENGTH
          build_key(shared_secret, hash(transport), 'C'.ord, transport.session_id, key_length)
        end

        def key_s_to_c transport, encryption_algorithm_s_to_c_name
          key_length = HrrRbSsh::Transport::EncryptionAlgorithm[encryption_algorithm_s_to_c_name]::KEY_LENGTH
          build_key(shared_secret, hash(transport), 'D'.ord, transport.session_id, key_length)
        end

        def mac_c_to_s transport, mac_algorithm_c_to_s_name
          key_length = HrrRbSsh::Transport::MacAlgorithm[mac_algorithm_c_to_s_name]::KEY_LENGTH
          build_key(shared_secret, hash(transport), 'E'.ord, transport.session_id, key_length)
        end

        def mac_s_to_c transport, mac_algorithm_s_to_c_name
          key_length = HrrRbSsh::Transport::MacAlgorithm[mac_algorithm_s_to_c_name]::KEY_LENGTH
          build_key(shared_secret, hash(transport), 'F'.ord, transport.session_id, key_length)
        end

      end
    end
  end
end
