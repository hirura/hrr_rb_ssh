# coding: utf-8
# vim: et ts=2 sw=2

require 'openssl'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/transport/kex_algorithm/iv_computable'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      module EllipticCurveDiffieHellman
        include IvComputable

        def initialize
          @logger = Logger.new(self.class.name)
          @dh = OpenSSL::PKey::EC.new(self.class::CURVE_NAME)
          @dh.generate_key
        end

        def start transport, mode
          case mode
          when Mode::SERVER
            receive_kexecdh_init transport.receive
            send_kexecdh_reply transport
          else
            raise "unsupported mode"
          end
        end

        def set_q_c q_c
          @q_c = q_c
        end

        def shared_secret
          k = OpenSSL::BN.new(@dh.dh_compute_key(OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC.new(self.class::CURVE_NAME).group, OpenSSL::BN.new(@q_c))), 2).to_i
        end

        def public_key
          f = @dh.public_key.to_bn.to_i
        end

        def hash transport
          q_c = @q_c
          q_s = public_key
          k   = shared_secret

          h0_payload = {
            :'V_C' => transport.v_c,
            :'V_S' => transport.v_s,
            :'I_C' => transport.i_c,
            :'I_S' => transport.i_s,
            :'K_S' => transport.server_host_key_algorithm.server_public_host_key,
            :'Q_C' => q_c,
            :'Q_S' => q_s,
            :'K'   => k,
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

        def receive_kexecdh_init payload
          message = Message::SSH_MSG_KEXECDH_INIT.decode payload
          set_q_c message[:'Q_C']
        end

        def send_kexecdh_reply transport
          message = {
            :'message number' => Message::SSH_MSG_KEXECDH_REPLY::VALUE,
            :'K_S'            => transport.server_host_key_algorithm.server_public_host_key,
            :'Q_S'            => public_key,
            :'signature of H' => sign(transport),
          }
          payload = Message::SSH_MSG_KEXECDH_REPLY.encode message
          transport.send payload
        end
      end
    end
  end
end

require 'hrr_rb_ssh/transport/kex_algorithm/elliptic_curve_diffie_hellman/h0'
