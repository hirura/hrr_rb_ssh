# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::KexAlgorithm::EllipticCurveDiffieHellmanSha2Nistp384 do
  let(:name){ 'ecdh-sha2-nistp384' }
  let(:digest){ 'sha384' }
  let(:curve_name){ 'secp384r1' }
  let(:digest_length){ OpenSSL::Digest.new(digest).digest_length }
  let(:kex_algorithm){ described_class.new }
  let(:remote_dh){
    dh = OpenSSL::PKey::EC.new(curve_name)
    dh.generate_key
    dh
  }
  let(:remote_dh_public_key){ 
    remote_dh.public_key.to_bn.to_i
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
 
  describe '::DIGEST' do
    it "has correct digest" do
      expect(described_class::DIGEST).to eq digest
    end
  end

  describe '::CURVE_NAME' do
    it "has correct curve name" do
      expect(described_class::CURVE_NAME).to eq curve_name
    end
  end

  describe '#initialize' do
    it "can be instantiated" do
      expect( kex_algorithm ).to be_an_instance_of described_class
    end
  end

  describe '#start' do
    let(:mock_t){ double('mock transport') }

    let(:remote_kexecdh_init_message){
      {
        :'message number' => HrrRbSsh::Message::SSH_MSG_KEXECDH_INIT::VALUE,
        :'Q_C'            => remote_dh_public_key,
      }
    }
    let(:remote_kexecdh_init_payload){
      HrrRbSsh::Message::SSH_MSG_KEXECDH_INIT.encode remote_kexecdh_init_message
    }
    let(:server_host_key_algorithm){ double('server host key algorithm') }
    let(:server_public_host_key){ 'server public host key' }
    let(:sign){ 'sign' }
    let(:local_kexecdh_reply_message){
      {
        :'message number' => HrrRbSsh::Message::SSH_MSG_KEXECDH_REPLY::VALUE,
        :'K_S'            => server_public_host_key,
        :'Q_S'            => kex_algorithm.public_key,
        :'signature of H' => sign,
      }
    }
    let(:local_kexecdh_reply_payload){
      HrrRbSsh::Message::SSH_MSG_KEXECDH_REPLY.encode local_kexecdh_reply_message
    }

    context "when transport mode is server" do
      it "exchanges public keys and gets shared secret" do
        expect(mock_t).to receive(:receive).with(no_args).and_return(remote_kexecdh_init_payload).once
        expect(mock_t).to receive(:send).with(local_kexecdh_reply_payload).once
        expect(mock_t).to receive(:server_host_key_algorithm).with(no_args).and_return(server_host_key_algorithm).once
        expect(server_host_key_algorithm).to receive(:server_public_host_key).with(no_args).and_return(server_public_host_key).once
        expect(kex_algorithm).to receive(:sign).with(mock_t).and_return(sign).once

        kex_algorithm.start mock_t, HrrRbSsh::Mode::SERVER

        expect(kex_algorithm.shared_secret).to eq OpenSSL::BN.new(remote_dh.dh_compute_key(OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC.new(curve_name).group, OpenSSL::BN.new(kex_algorithm.public_key))), 2).to_i
      end
    end
  end

  describe '#set_q_c' do
    it "updates remote_dh_public_key" do
      expect { kex_algorithm.set_q_c remote_dh_public_key }.to change { kex_algorithm.instance_variable_get('@q_c') }.from( nil ).to( remote_dh_public_key )
    end
  end

  describe '#shared_secret' do
    it "generates shared secret" do
      kex_algorithm.set_q_c remote_dh_public_key
      expect(kex_algorithm.shared_secret).to eq OpenSSL::BN.new(remote_dh.dh_compute_key(OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC.new(curve_name).group, OpenSSL::BN.new(kex_algorithm.public_key))), 2).to_i
    end
  end

  describe '#hash' do
    let(:mock_t){ double('mock transport') }

    context "when server host key algorithm is ssh-rsa" do
      let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

      it "returns hash" do
        kex_algorithm.set_q_c remote_dh_public_key

        expect(mock_t).to receive(:v_c).with(no_args).and_return("v_c").once
        expect(mock_t).to receive(:v_s).with(no_args).and_return("v_s").once
        expect(mock_t).to receive(:i_c).with(no_args).and_return("i_c").once
        expect(mock_t).to receive(:i_s).with(no_args).and_return("i_s").once
        expect(mock_t).to receive(:server_host_key_algorithm).with(no_args).and_return(server_host_key_algorithm).once

        expect( kex_algorithm.hash(mock_t).length ).to eq digest_length
      end
    end
  end

  describe '#sign' do
    let(:mock_t){ double('mock transport') }

    context "when server host key algorithm is ssh-rsa" do
      let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

      it "returns encoded \"ssh-rsa\" || signed hash" do
        kex_algorithm.set_q_c remote_dh_public_key

        expect(mock_t).to receive(:v_c).with(no_args).and_return("v_c").twice
        expect(mock_t).to receive(:v_s).with(no_args).and_return("v_s").twice
        expect(mock_t).to receive(:i_c).with(no_args).and_return("i_c").twice
        expect(mock_t).to receive(:i_s).with(no_args).and_return("i_s").twice
        expect(mock_t).to receive(:server_host_key_algorithm).with(no_args).and_return(server_host_key_algorithm).exactly(3).times

        expect( kex_algorithm.sign(mock_t) ).to eq server_host_key_algorithm.sign(kex_algorithm.hash(mock_t))
      end
    end
  end

  describe '#build_key' do
    let(:_k){ 1 }
    let(:h){ OpenSSL::Digest.digest(digest, '2') }
    let(:_x){ 'C'.ord }
    let(:session_id){ OpenSSL::Digest.digest(digest, '4') }

    context "with key_length equal to digest length" do
      let(:key_length){ digest_length }

      it "generates key with no digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["5d56eaaa78c11bd04d5679e154b1d33e2dd0659f3a90606944062f7c586d1bf287113f4c71dd4900303afc7b81250d4f"].pack("H*")
      end
    end

    context "with key_length shorter than digest length" do
      let(:key_length){ digest_length / 2 }

      it "generates key using first key_length charactors with no digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["5d56eaaa78c11bd04d5679e154b1d33e2dd0659f3a906069"].pack("H*")
      end
    end

    context "with key_length longer than digest length" do
      let(:key_length){ digest_length * 2 }

      it "generates key with digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["5d56eaaa78c11bd04d5679e154b1d33e2dd0659f3a90606944062f7c586d1bf287113f4c71dd4900303afc7b81250d4f15b7db4f9e1f2d3e134f480066717a38e4a4dcc7ac02952fabca47c904c62568ff1de1f676b2b48ab030b0b6ff238be5"].pack("H*")
      end
    end
  end

  describe '#iv_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates iv_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.iv_c_to_s(mock_t, encryption_algorithm_name) ).to eq ["8d3304168e5fb509bc0a14bddcb3ad4b"].pack("H*")
    end
  end

  describe '#iv_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates iv_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.iv_s_to_c(mock_t, encryption_algorithm_name) ).to eq ["0656f547090e4212b46c69f831667555"].pack("H*")
    end
  end

  describe '#key_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates key_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.key_c_to_s(mock_t, encryption_algorithm_name) ).to eq ["5d56eaaa78c11bd04d5679e154b1d33e"].pack("H*")
    end
  end

  describe '#key_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates key_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.key_s_to_c(mock_t, encryption_algorithm_name) ).to eq ["15d70f9c522b6435ffe259dde54f80e0"].pack("H*")
    end
  end

  describe '#mac_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:mac_algorithm_name){ 'hmac-sha1' }

    it "generates mac_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.mac_c_to_s(mock_t, mac_algorithm_name) ).to eq ["4201e9d575d6dcd028ad06b99ab463a1699d94c7"].pack("H*")
    end
  end

  describe '#mac_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:mac_algorithm_name){ 'hmac-sha1' }

    it "generates mac_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.mac_s_to_c(mock_t, mac_algorithm_name) ).to eq ["844e9971d16b4626888d29439026aaa3f3f1cfbd"].pack("H*")
    end
  end
end
