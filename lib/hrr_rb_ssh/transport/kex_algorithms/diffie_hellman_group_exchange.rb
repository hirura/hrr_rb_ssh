module HrrRbSsh
  class Transport
    class KexAlgorithms
      module DiffieHellmanGroupExchange
        include Loggable
        include IvComputable

        def initialize logger: nil
          self.logger = logger
        end

        def start transport
          case transport.mode
          when Mode::SERVER
            message = receive_kex_dh_gex_request transport.receive
            @min = message[:'min']
            @n   = message[:'n']
            @max = message[:'max']
            initialize_dh
            @p = @dh.p.to_i
            @g = @dh.g.to_i
            send_kex_dh_gex_group transport
            @k_s = transport.server_host_key_algorithm.server_public_host_key
            @f   = @public_key
            message = receive_kex_dh_gex_init transport.receive
            @e   = message[:'e']
            @shared_secret = OpenSSL::BN.new(@dh.compute_key(OpenSSL::BN.new(@e)), 2).to_i
            send_kex_dh_gex_reply transport
          when Mode::CLIENT
            @min = 1024
            @n   = 2048
            @max = 8192
            send_kex_dh_gex_request transport
            message = receive_kex_dh_gex_group transport.receive
            @p   = message[:'p']
            @g   = message[:'g']
            initialize_dh [@p, @g]
            @e   = @public_key
            send_kex_dh_gex_init transport
            message = receive_kex_dh_gex_reply transport.receive
            @k_s = message[:'server public host key and certificates (K_S)']
            @f   = message[:'f']
            @shared_secret = OpenSSL::BN.new(@dh.compute_key(OpenSSL::BN.new(@f)), 2).to_i
          end
        end

        def initialize_dh pg=nil
          unless pg
            p_list = KexAlgorithms.constants.map{|c| KexAlgorithms.const_get(c)}.select{|c| c.respond_to?(:const_defined?) && c.const_defined?(:P)}.map{|c| [OpenSSL::BN.new(c::P,16).num_bits, c::P]}.sort_by{|e| e[0]}.reverse
            candidate = p_list.find{ |e| e[0] <= @n }
            raise unless (@min .. @max).include?(candidate[0])
            p, g = candidate[1], 2
          else
            p, g = pg
          end

          @dh = Compat::OpenSSL.new_dh_pkey(
            p: OpenSSL::BN.new(p, 16),
            g: OpenSSL::BN.new(g)
          )
          @public_key = @dh.pub_key.to_i
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
            :'min' => @min,
            :'n'   => @n,
            :'max' => @max,
            :'p'   => @p,
            :'g'   => @g,
            :'e'   => @e,
            :'f'   => @f,
            :'k'   => @shared_secret,
          }
          h0 = H0.new(logger: logger).encode h0_payload
          h = OpenSSL::Digest.digest self.class::DIGEST, h0
        end

        def sign transport
          h = hash transport
          s = transport.server_host_key_algorithm.sign h
        end

        def receive_kex_dh_gex_request payload
          Messages::SSH_MSG_KEX_DH_GEX_REQUEST.new(logger: logger).decode payload
        end

        def send_kex_dh_gex_group transport
          message = {
            :'message number' => Messages::SSH_MSG_KEX_DH_GEX_GROUP::VALUE,
            :'p'              => @p,
            :'g'              => @g,
          }
          payload = Messages::SSH_MSG_KEX_DH_GEX_GROUP.new(logger: logger).encode message
          transport.send payload
        end

        def receive_kex_dh_gex_init payload
          Messages::SSH_MSG_KEX_DH_GEX_INIT.new(logger: logger).decode payload
        end

        def send_kex_dh_gex_reply transport
          message = {
            :'message number'                                => Messages::SSH_MSG_KEX_DH_GEX_REPLY::VALUE,
            :'server public host key and certificates (K_S)' => @k_s,
            :'f'                                             => @f,
            :'signature of H'                                => sign(transport),
          }
          payload = Messages::SSH_MSG_KEX_DH_GEX_REPLY.new(logger: logger).encode message
          transport.send payload
        end

        def send_kex_dh_gex_request transport
          message = {
            :'message number' => Messages::SSH_MSG_KEX_DH_GEX_REQUEST::VALUE,
            :'min'            => @min,
            :'n'              => @n,
            :'max'            => @max,
          }
          payload = Messages::SSH_MSG_KEX_DH_GEX_REQUEST.new(logger: logger).encode message
          transport.send payload
        end

        def receive_kex_dh_gex_group payload
          Messages::SSH_MSG_KEX_DH_GEX_GROUP.new(logger: logger).decode payload
        end

        def send_kex_dh_gex_init transport
          message = {
            :'message number' => Messages::SSH_MSG_KEX_DH_GEX_INIT::VALUE,
            :'e'              => @e,
          }
          payload = Messages::SSH_MSG_KEX_DH_GEX_INIT.new(logger: logger).encode message
          transport.send payload
        end

        def receive_kex_dh_gex_reply payload
          Messages::SSH_MSG_KEX_DH_GEX_REPLY.new(logger: logger).decode payload
        end
      end
    end
  end
end

require 'hrr_rb_ssh/transport/kex_algorithms/diffie_hellman_group_exchange/h0'
