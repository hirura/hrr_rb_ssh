RSpec.describe HrrRbSsh::Transport::KexAlgorithms::DiffieHellmanGroupExchangeSha256 do
  let(:name){ 'diffie-hellman-group-exchange-sha256' }
  let(:kex_algorithm){ described_class.new }

  it "is registered in HrrRbSsh::Transport::KexAlgorithms#list_supported" do
    expect( HrrRbSsh::Transport::KexAlgorithms.new.list_supported ).to include name
  end

  it "appears in HrrRbSsh::Transport::KexAlgorithms#list_preferred" do
    expect( HrrRbSsh::Transport::KexAlgorithms.new.list_preferred ).to include name
  end

  describe '::DIGEST' do
    it "has digest sha256" do
      expect(described_class::DIGEST).to eq 'sha256'
    end
  end

  describe '#initialize' do
    it "can be instantiated" do
      expect( kex_algorithm ).to be_an_instance_of described_class
    end
  end

  context "when transport mode is server" do
    let(:mode){ HrrRbSsh::Mode::SERVER }

    [1024, 2048].each{ |requested_n|
      context "when request is #{requested_n} bit" do
        case requested_n
        when 1024
          let(:dh_p){
            "FFFFFFFF" "FFFFFFFF" "C90FDAA2" "2168C234" \
            "C4C6628B" "80DC1CD1" "29024E08" "8A67CC74" \
            "020BBEA6" "3B139B22" "514A0879" "8E3404DD" \
            "EF9519B3" "CD3A431B" "302B0A6D" "F25F1437" \
            "4FE1356D" "6D51C245" "E485B576" "625E7EC6" \
            "F44C42E9" "A637ED6B" "0BFF5CB6" "F406B7ED" \
            "EE386BFB" "5A899FA5" "AE9F2411" "7C4B1FE6" \
            "49286651" "ECE65381" "FFFFFFFF" "FFFFFFFF"
          }
          let(:dh_g){
            2
          }
          let(:remote_dh){
            dh = HrrRbSsh::Compat::OpenSSL.new_dh_pkey(
              p: OpenSSL::BN.new(dh_p, 16),
              g: OpenSSL::BN.new(dh_g)
            )
            dh
          }
          let(:remote_dh_pub_key){
            remote_dh.pub_key.to_i
          }
        else
          let(:dh_p){
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
          }
          let(:dh_g){
            2
          }
          let(:remote_dh){
            dh = HrrRbSsh::Compat::OpenSSL.new_dh_pkey(
              p: OpenSSL::BN.new(dh_p, 16),
              g: OpenSSL::BN.new(dh_g)
            )
            dh
          }
          let(:remote_dh_pub_key){
            remote_dh.pub_key.to_i
          }
        end

        describe '#start' do
          let(:mock_t){ double('mock transport') }
          let(:remote_kex_dh_gex_request_message){
            {
              :'message number' => HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_REQUEST::VALUE,
              :'min'            => 1024,
              :'n'              => requested_n,
              :'max'            => 8192,
            }
          }
          let(:remote_kex_dh_gex_request_payload){
            HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_REQUEST.new.encode remote_kex_dh_gex_request_message
          }
          let(:remote_kex_dh_gex_init_message){
            {
              :'message number' => HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_INIT::VALUE,
              :'e'              => remote_dh_pub_key,
            }
          }
          let(:remote_kex_dh_gex_init_payload){
            HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_INIT.new.encode remote_kex_dh_gex_init_message
          }
          let(:local_kex_dh_gex_group_message){
            {
              :'message number' => HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_GROUP::VALUE,
              :'p'              => dh_p.to_i(16),
              :'g'              => dh_g,
            }
          }
          let(:local_kex_dh_gex_group_payload){
            HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_GROUP.new.encode local_kex_dh_gex_group_message
          }
          let(:server_host_key_algorithm){ double('server host key algorithm') }
          let(:server_public_host_key){ 'server public host key' }
          let(:sign){ 'sign' }
          let(:local_kex_dh_gex_reply_message){
            {
              :'message number'                                => HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_REPLY::VALUE,
              :'server public host key and certificates (K_S)' => server_public_host_key,
              :'f'                                             => kex_algorithm.instance_variable_get('@public_key'),
              :'signature of H'                                => sign,
            }
          }
          let(:local_kex_dh_gex_reply_payload){
            HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_REPLY.new.encode local_kex_dh_gex_reply_message
          }

          it "exchanges public keys and gets shared secret" do
            expect(mock_t).to receive(:mode).with(no_args).and_return(mode).once
            expect(mock_t).to receive(:receive).with(no_args).and_return(remote_kex_dh_gex_request_payload, remote_kex_dh_gex_init_payload).twice
            expect(mock_t).to receive(:send).with(local_kex_dh_gex_group_payload).once
            expect(mock_t).to receive(:send).with(any_args).once
            expect(mock_t).to receive(:server_host_key_algorithm).with(no_args).and_return(server_host_key_algorithm).once
            expect(server_host_key_algorithm).to receive(:server_public_host_key).with(no_args).and_return(server_public_host_key).once
            expect(kex_algorithm).to receive(:sign).with(mock_t).and_return(sign).once

            kex_algorithm.start mock_t

            expect(kex_algorithm.instance_variable_get('@k_s')          ).to eq server_public_host_key
            expect(kex_algorithm.instance_variable_get('@e')            ).to eq remote_dh_pub_key
            expect(kex_algorithm.instance_variable_get('@f')            ).to eq kex_algorithm.instance_variable_get('@public_key')
            expect(kex_algorithm.instance_variable_get('@shared_secret')).to eq OpenSSL::BN.new(remote_dh.compute_key(kex_algorithm.instance_variable_get('@public_key')), 2).to_i
          end
        end

        describe '#shared_secret' do
          let(:shared_secret){ 'shared secret value' }

          it "returns @shared_secret value" do
            kex_algorithm.instance_variable_set('@shared_secret', shared_secret)
            expect( kex_algorithm.shared_secret ).to be shared_secret
          end
        end

        describe '#hash' do
          let(:mock_t){ double('mock transport') }

          before :example do
            kex_algorithm.instance_variable_set('@min', 1024)
            kex_algorithm.instance_variable_set('@n',   requested_n)
            kex_algorithm.instance_variable_set('@max', 8192)
            kex_algorithm.initialize_dh
            kex_algorithm.instance_variable_set('@p', kex_algorithm.instance_variable_get('@dh').p.to_i)
            kex_algorithm.instance_variable_set('@g', kex_algorithm.instance_variable_get('@dh').g.to_i)
            kex_algorithm.instance_variable_set('@k_s', server_host_key_algorithm.server_public_host_key)
            kex_algorithm.instance_variable_set('@e', remote_dh_pub_key)
            kex_algorithm.instance_variable_set('@f', kex_algorithm.instance_variable_get('@public_key'))
            kex_algorithm.instance_variable_set('@shared_secret', OpenSSL::BN.new(kex_algorithm.instance_variable_get('@dh').compute_key(OpenSSL::BN.new(remote_dh_pub_key)), 2).to_i)
          end

          context "when server host key algorithm is ssh-rsa" do
            let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

            it "returns hash" do
              expect(mock_t).to receive(:v_c).with(no_args).and_return("v_c").once
              expect(mock_t).to receive(:v_s).with(no_args).and_return("v_s").once
              expect(mock_t).to receive(:i_c).with(no_args).and_return("i_c").once
              expect(mock_t).to receive(:i_s).with(no_args).and_return("i_s").once

              expect( kex_algorithm.hash(mock_t).length ).to eq 32
            end
          end
        end

        describe '#sign' do
          let(:mock_t){ double('mock transport') }

          before :example do
            kex_algorithm.instance_variable_set('@min', 1024)
            kex_algorithm.instance_variable_set('@n',   requested_n)
            kex_algorithm.instance_variable_set('@max', 8192)
            kex_algorithm.initialize_dh
            kex_algorithm.instance_variable_set('@p', kex_algorithm.instance_variable_get('@dh').p.to_i)
            kex_algorithm.instance_variable_set('@g', kex_algorithm.instance_variable_get('@dh').g.to_i)
            kex_algorithm.instance_variable_set('@k_s', server_host_key_algorithm.server_public_host_key)
            kex_algorithm.instance_variable_set('@e', remote_dh_pub_key)
            kex_algorithm.instance_variable_set('@f', kex_algorithm.instance_variable_get('@public_key'))
            kex_algorithm.instance_variable_set('@shared_secret', OpenSSL::BN.new(kex_algorithm.instance_variable_get('@dh').compute_key(OpenSSL::BN.new(remote_dh_pub_key)), 2).to_i)
          end

          context "when server host key algorithm is ssh-rsa" do
            let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

            it "returns encoded \"ssh-rsa\" || signed hash" do
              expect(mock_t).to receive(:v_c).with(no_args).and_return("v_c").twice
              expect(mock_t).to receive(:v_s).with(no_args).and_return("v_s").twice
              expect(mock_t).to receive(:i_c).with(no_args).and_return("i_c").twice
              expect(mock_t).to receive(:i_s).with(no_args).and_return("i_s").twice
              expect(mock_t).to receive(:server_host_key_algorithm).with(no_args).and_return(server_host_key_algorithm).once

              expect( kex_algorithm.sign(mock_t) ).to eq server_host_key_algorithm.sign(kex_algorithm.hash(mock_t))
            end
          end
        end
      end
    }
  end

  context "when transport mode is client" do
    let(:mode){ HrrRbSsh::Mode::CLIENT }

    describe '#start' do
      let(:mock_t){ double('mock transport') }
      let(:dh_p){
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
      }
      let(:dh_g){
        2
      }
      let(:remote_dh){
        dh = HrrRbSsh::Compat::OpenSSL.new_dh_pkey(
          p: OpenSSL::BN.new(dh_p, 16),
          g: OpenSSL::BN.new(dh_g)
        )
        dh
      }
      let(:remote_dh_pub_key){
        remote_dh.pub_key.to_i
      }
      let(:local_kex_dh_gex_request_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_REQUEST::VALUE,
          :'min'            => 1024,
          :'n'              => 2048,
          :'max'            => 8192,
        }
      }
      let(:local_kex_dh_gex_request_payload){
        HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_REQUEST.new.encode local_kex_dh_gex_request_message
      }
      let(:local_kex_dh_gex_init_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_INIT::VALUE,
          :'e'              => kex_algorithm.instance_variable_get('@public_key'),
        }
      }
      let(:local_kex_dh_gex_init_payload){
        HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_INIT.new.encode local_kex_dh_gex_init_message
      }
      let(:remote_kex_dh_gex_group_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_GROUP::VALUE,
          :'p'              => dh_p.to_i(16),
          :'g'              => dh_g,
        }
      }
      let(:remote_kex_dh_gex_group_payload){
        HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_GROUP.new.encode remote_kex_dh_gex_group_message
      }
      let(:server_public_host_key){ 'server public host key' }
      let(:sign){ 'sign' }
      let(:remote_kex_dh_gex_reply_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_REPLY::VALUE,
          :'server public host key and certificates (K_S)' => server_public_host_key,
          :'f'                                             => remote_dh_pub_key,
          :'signature of H'                                => sign,
        }
      }
      let(:remote_kex_dh_gex_reply_payload){
        HrrRbSsh::Messages::SSH_MSG_KEX_DH_GEX_REPLY.new.encode remote_kex_dh_gex_reply_message
      }

      it "exchanges public keys and gets shared secret" do
        expect(mock_t).to receive(:mode).with(no_args).and_return(mode).once
        expect(mock_t).to receive(:send).with(local_kex_dh_gex_request_payload).once
        expect(mock_t).to receive(:receive).with(no_args).and_return(remote_kex_dh_gex_group_payload, remote_kex_dh_gex_reply_payload).twice
        expect(mock_t).to receive(:send).with(any_args).once

        kex_algorithm.start mock_t

        expect(kex_algorithm.instance_variable_get('@min')          ).to eq 1024
        expect(kex_algorithm.instance_variable_get('@n')            ).to eq 2048
        expect(kex_algorithm.instance_variable_get('@max')          ).to eq 8192
        if RUBY_VERSION > "2.0.0"
          expect(kex_algorithm.instance_variable_get('@p')            ).to eq kex_algorithm.instance_variable_get('@dh').p.to_i
          expect(kex_algorithm.instance_variable_get('@g')            ).to eq kex_algorithm.instance_variable_get('@dh').g.to_i
          expect(kex_algorithm.instance_variable_get('@k_s')          ).to eq server_public_host_key
          expect(kex_algorithm.instance_variable_get('@e')            ).to eq kex_algorithm.instance_variable_get('@public_key')
          expect(kex_algorithm.instance_variable_get('@f')            ).to eq remote_dh_pub_key
          expect(kex_algorithm.instance_variable_get('@shared_secret')).to eq OpenSSL::BN.new(remote_dh.compute_key(kex_algorithm.instance_variable_get('@public_key')), 2).to_i
        end
      end
    end
  end

  describe '#build_key' do
    let(:_k){ 1 }
    let(:h){ OpenSSL::Digest.digest('sha256', '2') }
    let(:_x){ 'C'.ord }
    let(:session_id){ OpenSSL::Digest.digest('sha256', '4') }

    context "with key_length equal to digest length" do
      let(:key_length){ 32 }

      it "generates key with no digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["8215c2e0ae2f4250d995766d14594b1dee59087da4e8f50e926a6049c051fb2e"].pack("H*")
      end
    end

    context "with key_length shorter than digest length" do
      let(:key_length){ 16 }

      it "generates key using first key_length charactors with no digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["8215c2e0ae2f4250d995766d14594b1d"].pack("H*")
      end
    end

    context "with key_length longer than digest length" do
      let(:key_length){ 64 }

      it "generates key with digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["8215c2e0ae2f4250d995766d14594b1dee59087da4e8f50e926a6049c051fb2e8a3ca2de1c65a72ffb3534f21b935504b8a1f57f7883d89fd63cf9c062d00df3"].pack("H*")
      end
    end
  end

  describe '#iv_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates iv_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha256', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha256', '4') ).once

      expect( kex_algorithm.iv_c_to_s(mock_t, encryption_algorithm_name) ).to eq ["9b131e37551e2da171aa2db4bddd7e3e"].pack("H*")
    end
  end

  describe '#iv_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates iv_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha256', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha256', '4') ).once

      expect( kex_algorithm.iv_s_to_c(mock_t, encryption_algorithm_name) ).to eq ["bd4829f8805888b45431bc4f2da398b1"].pack("H*")
    end
  end

  describe '#key_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates key_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha256', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha256', '4') ).once

      expect( kex_algorithm.key_c_to_s(mock_t, encryption_algorithm_name) ).to eq ["8215c2e0ae2f4250d995766d14594b1d"].pack("H*")
    end
  end

  describe '#key_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates key_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha256', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha256', '4') ).once

      expect( kex_algorithm.key_s_to_c(mock_t, encryption_algorithm_name) ).to eq ["94bd604304def5520ad7e51479507518"].pack("H*")
    end
  end

  describe '#mac_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:mac_algorithm_name){ 'hmac-sha1' }

    it "generates mac_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha256', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha256', '4') ).once

      expect( kex_algorithm.mac_c_to_s(mock_t, mac_algorithm_name) ).to eq ["6e3452445a6298bb147af10a51f1206fdf479fd8"].pack("H*")
    end
  end

  describe '#mac_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:mac_algorithm_name){ 'hmac-sha1' }

    it "generates mac_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha256', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha256', '4') ).once

      expect( kex_algorithm.mac_s_to_c(mock_t, mac_algorithm_name) ).to eq ["1f9aa6ff84da01a90f9f9c56e8274c62fafdefa8"].pack("H*")
    end
  end
end
