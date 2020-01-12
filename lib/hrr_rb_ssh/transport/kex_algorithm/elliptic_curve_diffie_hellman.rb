# coding: utf-8
# vim: et ts=2 sw=2

require 'openssl'
require 'hrr_rb_ssh/loggable'
require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/transport/kex_algorithm/iv_computable'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      module EllipticCurveDiffieHellman
        include Loggable
        include IvComputable

        def initialize logger: nil
          self.logger = logger
          @dh = OpenSSL::PKey::EC.new(self.class::CURVE_NAME)
          @dh.generate_key
          @public_key = @dh.public_key.to_bn.to_i
        end

        def start transport
          case transport.mode
          when Mode::SERVER
            @k_s = transport.server_host_key_algorithm.server_public_host_key
            @q_s = @public_key
            message = receive_kexecdh_init transport.receive
            @q_c = message[:'Q_C']
            @shared_secret = OpenSSL::BN.new(@dh.dh_compute_key(OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC.new(self.class::CURVE_NAME).group, OpenSSL::BN.new(@q_c))), 2).to_i
            send_kexecdh_reply transport
          when Mode::CLIENT
            @q_c = @public_key
            send_kexecdh_init transport
            message = receive_kexecdh_reply transport.receive
            @k_s = message[:'K_S']
            @q_s = message[:'Q_S']
            @shared_secret = OpenSSL::BN.new(@dh.dh_compute_key(OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC.new(self.class::CURVE_NAME).group, OpenSSL::BN.new(@q_s))), 2).to_i
          end
        end

        def shared_secret
          @shared_secret
        end

        def hash transport
          h0_payload = {
            :'V_C' => transport.v_c,
            :'V_S' => transport.v_s,
            :'I_C' => transport.i_c,
            :'I_S' => transport.i_s,
            :'K_S' => @k_s,
            :'Q_C' => @q_c,
            :'Q_S' => @q_s,
            :'K'   => @shared_secret,
          }
          h0 = H0.new(logger: logger).encode h0_payload
          h  = OpenSSL::Digest.digest self.class::DIGEST, h0
        end

        def sign transport
          h = hash transport
          s = transport.server_host_key_algorithm.sign h
        end

        def receive_kexecdh_init payload
          Message::SSH_MSG_KEXECDH_INIT.new(logger: logger).decode payload
        end

        def send_kexecdh_reply transport
          message = {
            :'message number' => Message::SSH_MSG_KEXECDH_REPLY::VALUE,
            :'K_S'            => @k_s,
            :'Q_S'            => @q_s,
            :'signature of H' => sign(transport),
          }
          payload = Message::SSH_MSG_KEXECDH_REPLY.new(logger: logger).encode message
          transport.send payload
        end

        def send_kexecdh_init transport
          message = {
            :'message number' => Message::SSH_MSG_KEXECDH_INIT::VALUE,
            :'Q_C'            => @q_c,
          }
          payload = Message::SSH_MSG_KEXECDH_INIT.new(logger: logger).encode message
          transport.send payload
        end

        def receive_kexecdh_reply payload
          Message::SSH_MSG_KEXECDH_REPLY.new(logger: logger).decode payload
        end
      end
    end
  end
end

require 'hrr_rb_ssh/transport/kex_algorithm/elliptic_curve_diffie_hellman/h0'
