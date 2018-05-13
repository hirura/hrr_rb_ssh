# coding: utf-8
# vim: et ts=2 sw=2

require 'openssl'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/data_type'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      module DiffieHellmanGroupExchange
        def initialize
          @logger = Logger.new(self.class.name)
        end

        def start transport, mode
          case mode
          when Mode::SERVER
            receive_kex_dh_gex_request transport.receive
            set_dh
            send_kex_dh_gex_group transport
            receive_kex_dh_gex_init transport.receive
            send_kex_dh_gex_reply transport
          else
            raise "unsupported mode"
          end
        end

        def set_dh
          p_list = KexAlgorithm.list_supported.map{ |e| KexAlgorithm[e] }.select{ |e| e.const_defined?(:P) }.map{ |e| [OpenSSL::BN.new(e::P,16).num_bits, e::P] }.sort_by{ |e| e[0] }.reverse
          candidate = p_list.find{ |e| e[0] <= @n }
          raise unless (@min .. @max).include?(candidate[0])
          p = candidate[1]
          g = 2
          @dh = OpenSSL::PKey::DH.new
          if @dh.respond_to?(:set_pqg)
            @dh.set_pqg OpenSSL::BN.new(p, 16), nil, OpenSSL::BN.new(g)
          else
            @dh.p = OpenSSL::BN.new(p, 16)
            @dh.g = OpenSSL::BN.new(g)
          end
          @dh.generate_key!
        end

        def set_e e
          @e = e
        end

        def shared_secret
          k = OpenSSL::BN.new(@dh.compute_key(OpenSSL::BN.new(@e)), 2).to_i
        end

        def pub_key
          f = @dh.pub_key.to_i
        end

        def hash transport
          e = @e
          k = shared_secret
          f = pub_key

          h0_payload = {
            :'V_C' => transport.v_c,
            :'V_S' => transport.v_s,
            :'I_C' => transport.i_c,
            :'I_S' => transport.i_s,
            :'K_S' => transport.server_host_key_algorithm.server_public_host_key,
            :'min' => @min,
            :'n'   => @n,
            :'max' => @max,
            :'p'   => @dh.p.to_i,
            :'g'   => @dh.g.to_i,
            :'e'   => e,
            :'f'   => f,
            :'k'   => k,
          }
          h0 = H0.encode h0_payload

          h = OpenSSL::Digest.digest self.class::DIGEST, h0

          h
        end

        def sign transport
          h = hash transport
          s = transport.server_host_key_algorithm.sign h
          s
        end

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

        def receive_kex_dh_gex_request payload
          message = Message::SSH_MSG_KEX_DH_GEX_REQUEST.decode payload
          @min = message[:'min']
          @n   = message[:'n']
          @max = message[:'max']
        end

        def send_kex_dh_gex_group transport
          message = {
            :'message number' => Message::SSH_MSG_KEX_DH_GEX_GROUP::VALUE,
            :'p'              => @dh.p.to_i,
            :'g'              => @dh.g.to_i,
          }
          payload = Message::SSH_MSG_KEX_DH_GEX_GROUP.encode message
          transport.send payload
        end

        def receive_kex_dh_gex_init payload
          message = Message::SSH_MSG_KEX_DH_GEX_INIT.decode payload
          set_e message[:'e']
        end

        def send_kex_dh_gex_reply transport
          message = {
            :'message number'                                => Message::SSH_MSG_KEX_DH_GEX_REPLY::VALUE,
            :'server public host key and certificates (K_S)' => transport.server_host_key_algorithm.server_public_host_key,
            :'f'                                             => pub_key,
            :'signature of H'                                => sign(transport),
          }
          payload = Message::SSH_MSG_KEX_DH_GEX_REPLY.encode message
          transport.send payload
        end
      end
    end
  end
end

require 'hrr_rb_ssh/transport/kex_algorithm/diffie_hellman_group_exchange/h0'
