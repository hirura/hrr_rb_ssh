# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport/data_type'

module HrrRbSsh
  class Transport
    class KexAlgorithm
      name_list = [
        'diffie-hellman-group14-sha1'
      ]

      class DiffieHellmanGroup14Sha1
        P = \
          "FFFFFFFF" "FFFFFFFF" "C90FDAA2" "2168C234" \
          "C4C6628B" "80DC1CD1" "29024E08" "8A67CC74" \
          "020BBEA6" "3B139B22" "514A0879" "8E3404DD" \
          "EF9519B3" "CD3A431B" "302B0A6D" "F25F1437" \
          "4FE1356D" "6D51C245" "E485B576" "625E7EC6" \
          "F44C42E9" "A637ED6B" "0BFF5CB6" "F406B7ED" \
          "EE386BFB" "5A899FA5" "AE9F2411" "7C4B1FE6" \
          "49286651" "ECE45B3D" "C2007CB8" "A163BF05" \
          "98DA4836" "1C55D39A" "69163FA8" "FD24CF5F" \
          "83655D23" "DCA3AD96" "1C62F356" "208552BB" \
          "9ED52907" "7096966D" "670C354E" "4ABC9804" \
          "F1746C08" "CA18217C" "32905E46" "2E36CE3B" \
          "E39E772C" "180E8603" "9B2783A2" "EC07A28F" \
          "B5C55DF0" "6F4C52C9" "DE2BCBF6" "95581718" \
          "3995497C" "EA956AE5" "15D22618" "98FA0510" \
          "15728E5A" "8AACAA68" "FFFFFFFF" "FFFFFFFF"
        G = 2
        DIGEST = 'sha1'

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

          prime     = OpenSSL::BN.new( P, 16 )
          generator = OpenSSL::BN.new( G )
          @dh.set_pqg prime, nil, generator

          @dh.generate_key!
        end

        def p
          P
        end

        def g
          G
        end

        def digest
          DIGEST
        end

        def encode definition, payload
          definition.map{ |data_type, field_name|
            field_value = if payload[field_name].instance_of? ::Proc then payload[field_name].call else payload[field_name] end
            HrrRbSsh::Transport::DataType[data_type].encode( field_value )
          }.join
        end

        def set_e e
          @e = e
        end

        def e
          @e
        end

        def shared_secret
          k = OpenSSL::BN.new( @dh.compute_key( @e ), 2 ).to_i

          k
        end

        def pub_key
          f = @dh.pub_key.to_i

          f
        end

        def hash transport
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

          h = OpenSSL::Digest.digest digest, h0

          h
        end

        def sign transport
          h = hash transport
          s = transport.server_host_key_algorithm.sign digest, h

          s
        end
      end

      @@list ||= Hash.new
      name_list.each do |name|
        @@list[name] = DiffieHellmanGroup14Sha1
      end
    end
  end
end
