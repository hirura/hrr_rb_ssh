# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup14Sha256 do
  let(:name){ 'diffie-hellman-group14-sha256' }
  let(:kex_algorithm){ described_class.new }
  let(:dh_group14_p){
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
  let(:dh_group14_g){
    2
  }
  let(:remote_dh){
    dh = OpenSSL::PKey::DH.new
    if dh.respond_to?(:set_pqg)
      dh.set_pqg OpenSSL::BN.new(dh_group14_p, 16), nil, OpenSSL::BN.new(dh_group14_g)
    else
      dh.p = OpenSSL::BN.new(dh_group14_p, 16)
      dh.g = OpenSSL::BN.new(dh_group14_g)
    end
    dh.generate_key!
    dh
  }
  let(:remote_dh_pub_key){
    remote_dh.pub_key.to_i
  }

  it "can be looked up in HrrRbSsh::Transport::KexAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::KexAlgorithm[name] ).to eq described_class
  end

  it "is registered in HrrRbSsh::Transport::KexAlgorithm.list_supported" do
    expect( HrrRbSsh::Transport::KexAlgorithm.list_supported ).to include name
  end

  it "appears in HrrRbSsh::Transport::KexAlgorithm.list_preferred" do
    expect( HrrRbSsh::Transport::KexAlgorithm.list_preferred ).to include name
  end

  describe '::P' do
    it "has diffie hellman group 14's p" do
      expect(described_class::P).to eq dh_group14_p
    end
  end

  describe '::G' do
    it "has diffie hellman group 14's g" do
      expect(described_class::G).to eq dh_group14_g
    end
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

  describe '#start' do
    let(:mock_t){ double('mock transport') }

    context "when transport mode is server" do
      let(:mode){ HrrRbSsh::Mode::SERVER }
      let(:remote_kexdh_init_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_KEXDH_INIT::VALUE,
          :'e'              => remote_dh_pub_key,
        }
      }
      let(:remote_kexdh_init_payload){
        HrrRbSsh::Message::SSH_MSG_KEXDH_INIT.encode remote_kexdh_init_message
      }
      let(:server_host_key_algorithm){ double('server host key algorithm') }
      let(:server_public_host_key){ 'server public host key' }
      let(:sign){ 'sign' }
      let(:local_kexdh_reply_message){
        {
          :'message number'                                => HrrRbSsh::Message::SSH_MSG_KEXDH_REPLY::VALUE,
          :'server public host key and certificates (K_S)' => server_public_host_key,
          :'f'                                             => kex_algorithm.instance_variable_get('@public_key'),
          :'signature of H'                                => sign,
        }
      }
      let(:local_kexdh_reply_payload){
        HrrRbSsh::Message::SSH_MSG_KEXDH_REPLY.encode local_kexdh_reply_message
      }

      it "exchanges public keys and gets shared secret" do
        expect(mock_t).to receive(:mode).with(no_args).and_return(mode).once
        expect(mock_t).to receive(:receive).with(no_args).and_return(remote_kexdh_init_payload).once
        expect(mock_t).to receive(:send).with(local_kexdh_reply_payload).once
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

    context "when transport mode is client" do
      let(:mode){ HrrRbSsh::Mode::CLIENT }
      let(:local_kexdh_init_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_KEXDH_INIT::VALUE,
          :'e'              => kex_algorithm.instance_variable_get('@public_key'),
        }
      }
      let(:local_kexdh_init_payload){
        HrrRbSsh::Message::SSH_MSG_KEXDH_INIT.encode local_kexdh_init_message
      }
      let(:server_public_host_key){ 'server public host key' }
      let(:sign){ 'sign' }
      let(:remote_kexdh_reply_message){
        {
          :'message number'                                => HrrRbSsh::Message::SSH_MSG_KEXDH_REPLY::VALUE,
          :'server public host key and certificates (K_S)' => server_public_host_key,
          :'f'                                             => remote_dh_pub_key,
          :'signature of H'                                => sign,
        }
      }
      let(:remote_kexdh_reply_payload){
        HrrRbSsh::Message::SSH_MSG_KEXDH_REPLY.encode remote_kexdh_reply_message
      }

      it "exchanges public keys and gets shared secret" do
        expect(mock_t).to receive(:mode).with(no_args).and_return(mode).once
        expect(mock_t).to receive(:send).with(local_kexdh_init_payload).once
        expect(mock_t).to receive(:receive).with(no_args).and_return(remote_kexdh_reply_payload).once

        kex_algorithm.start mock_t

        expect(kex_algorithm.instance_variable_get('@k_s')          ).to eq server_public_host_key
        expect(kex_algorithm.instance_variable_get('@e')            ).to eq kex_algorithm.instance_variable_get('@public_key')
        expect(kex_algorithm.instance_variable_get('@f')            ).to eq remote_dh_pub_key
        expect(kex_algorithm.instance_variable_get('@shared_secret')).to eq OpenSSL::BN.new(remote_dh.compute_key(kex_algorithm.instance_variable_get('@public_key')), 2).to_i
      end
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

    context "when server host key algorithm is ssh-rsa" do
      let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

      it "returns hash" do
        kex_algorithm.instance_variable_set('@k_s', server_host_key_algorithm.server_public_host_key)
        kex_algorithm.instance_variable_set('@e', remote_dh_pub_key)
        kex_algorithm.instance_variable_set('@f', kex_algorithm.instance_variable_get('@public_key'))
        kex_algorithm.instance_variable_set('@shared_secret', OpenSSL::BN.new(kex_algorithm.instance_variable_get('@dh').compute_key(OpenSSL::BN.new(remote_dh_pub_key)), 2).to_i)

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

    context "when server host key algorithm is ssh-rsa" do
      let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

      it "returns encoded \"ssh-rsa\" || signed hash" do
        kex_algorithm.instance_variable_set('@k_s', server_host_key_algorithm.server_public_host_key)
        kex_algorithm.instance_variable_set('@e', remote_dh_pub_key)
        kex_algorithm.instance_variable_set('@f', kex_algorithm.instance_variable_get('@public_key'))
        kex_algorithm.instance_variable_set('@shared_secret', OpenSSL::BN.new(kex_algorithm.instance_variable_get('@dh').compute_key(OpenSSL::BN.new(remote_dh_pub_key)), 2).to_i)

        expect(mock_t).to receive(:v_c).with(no_args).and_return("v_c").twice
        expect(mock_t).to receive(:v_s).with(no_args).and_return("v_s").twice
        expect(mock_t).to receive(:i_c).with(no_args).and_return("i_c").twice
        expect(mock_t).to receive(:i_s).with(no_args).and_return("i_s").twice
        expect(mock_t).to receive(:server_host_key_algorithm).with(no_args).and_return(server_host_key_algorithm).once

        expect( kex_algorithm.sign(mock_t) ).to eq server_host_key_algorithm.sign(kex_algorithm.hash(mock_t))
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
