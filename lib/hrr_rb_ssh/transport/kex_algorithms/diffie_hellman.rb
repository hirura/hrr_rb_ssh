module HrrRbSsh
  class Transport
    class KexAlgorithms
      module DiffieHellman
        include Loggable
        include IvComputable

        def initialize logger: nil
          self.logger = logger
          @dh = Compat::OpenSSL.new_dh_pkey(
            p: OpenSSL::BN.new(self.class::P, 16),
            g: OpenSSL::BN.new(self.class::G)
          )
          @public_key = @dh.pub_key.to_i
        end

        def start transport
          case transport.mode
          when Mode::SERVER
            @k_s = transport.server_host_key_algorithm.server_public_host_key
            @f   = @public_key
            message = receive_kexdh_init transport.receive
            @e = message[:'e']
            @shared_secret = OpenSSL::BN.new(@dh.compute_key(OpenSSL::BN.new(@e)), 2).to_i
            send_kexdh_reply transport
          when Mode::CLIENT
            @e   = @public_key
            send_kexdh_init transport
            message = receive_kexdh_reply transport.receive
            @k_s = message[:'server public host key and certificates (K_S)']
            @f   = message[:'f']
            @shared_secret = OpenSSL::BN.new(@dh.compute_key(OpenSSL::BN.new(@f)), 2).to_i
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
            :'e'   => @e,
            :'f'   => @f,
            :'k'   => @shared_secret,
          }
          h0 = H0.new(logger: logger).encode h0_payload
          h  = OpenSSL::Digest.digest self.class::DIGEST, h0
        end

        def sign transport
          h = hash transport
          s = transport.server_host_key_algorithm.sign h
        end

        def receive_kexdh_init payload
          Messages::SSH_MSG_KEXDH_INIT.new(logger: logger).decode payload
        end

        def send_kexdh_reply transport
          message = {
            :'message number'                                => Messages::SSH_MSG_KEXDH_REPLY::VALUE,
            :'server public host key and certificates (K_S)' => @k_s,
            :'f'                                             => @f,
            :'signature of H'                                => sign(transport),
          }
          payload = Messages::SSH_MSG_KEXDH_REPLY.new(logger: logger).encode message
          transport.send payload
        end

        def send_kexdh_init transport
          message = {
            :'message number' => Messages::SSH_MSG_KEXDH_INIT::VALUE,
            :'e'              => @e,
          }
          payload = Messages::SSH_MSG_KEXDH_INIT.new(logger: logger).encode message
          transport.send payload
        end

        def receive_kexdh_reply payload
          Messages::SSH_MSG_KEXDH_REPLY.new(logger: logger).decode payload
        end
      end
    end
  end
end

require 'hrr_rb_ssh/transport/kex_algorithms/diffie_hellman/h0'
