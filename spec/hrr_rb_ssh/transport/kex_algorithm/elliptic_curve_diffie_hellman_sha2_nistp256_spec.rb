RSpec.describe HrrRbSsh::Transport::KexAlgorithm::EllipticCurveDiffieHellmanSha2Nistp256 do
  let(:name){ 'ecdh-sha2-nistp256' }
  let(:digest){ 'sha256' }
  let(:curve_name){ 'prime256v1' }
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

    context "when transport mode is server" do
      let(:mode){ HrrRbSsh::Mode::SERVER }
      let(:remote_kexecdh_init_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEXECDH_INIT::VALUE,
          :'Q_C'            => remote_dh_public_key,
        }
      }
      let(:remote_kexecdh_init_payload){
        HrrRbSsh::Messages::SSH_MSG_KEXECDH_INIT.new.encode remote_kexecdh_init_message
      }
      let(:server_host_key_algorithm){ double('server host key algorithm') }
      let(:server_public_host_key){ 'server public host key' }
      let(:sign){ 'sign' }
      let(:local_kexecdh_reply_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEXECDH_REPLY::VALUE,
          :'K_S'            => server_public_host_key,
          :'Q_S'            => kex_algorithm.instance_variable_get('@public_key'),
          :'signature of H' => sign,
        }
      }
      let(:local_kexecdh_reply_payload){
        HrrRbSsh::Messages::SSH_MSG_KEXECDH_REPLY.new.encode local_kexecdh_reply_message
      }

      it "exchanges public keys and gets shared secret" do
        expect(mock_t).to receive(:mode).with(no_args).and_return(mode).once
        expect(mock_t).to receive(:receive).with(no_args).and_return(remote_kexecdh_init_payload).once
        expect(mock_t).to receive(:send).with(local_kexecdh_reply_payload).once
        expect(mock_t).to receive(:server_host_key_algorithm).with(no_args).and_return(server_host_key_algorithm).once
        expect(server_host_key_algorithm).to receive(:server_public_host_key).with(no_args).and_return(server_public_host_key).once
        expect(kex_algorithm).to receive(:sign).with(mock_t).and_return(sign).once

        kex_algorithm.start mock_t

        expect(kex_algorithm.shared_secret).to eq OpenSSL::BN.new(remote_dh.dh_compute_key(OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC.new(curve_name).group, OpenSSL::BN.new(kex_algorithm.instance_variable_get('@public_key')))), 2).to_i
      end
    end

    context "when transport mode is client" do
      let(:mode){ HrrRbSsh::Mode::CLIENT }
      let(:local_kexecdh_init_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEXECDH_INIT::VALUE,
          :'Q_C'            => kex_algorithm.instance_variable_get('@public_key'),
        }
      }
      let(:local_kexecdh_init_payload){
        HrrRbSsh::Messages::SSH_MSG_KEXECDH_INIT.new.encode local_kexecdh_init_message
      }
      let(:server_host_key_algorithm){ double('server host key algorithm') }
      let(:server_public_host_key){ 'server public host key' }
      let(:sign){ 'sign' }
      let(:remote_kexecdh_reply_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEXECDH_REPLY::VALUE,
          :'K_S'            => server_public_host_key,
          :'Q_S'            => remote_dh_public_key,
          :'signature of H' => sign,
        }
      }
      let(:remote_kexecdh_reply_payload){
        HrrRbSsh::Messages::SSH_MSG_KEXECDH_REPLY.new.encode remote_kexecdh_reply_message
      }

      it "exchanges public keys and gets shared secret" do
        expect(mock_t).to receive(:mode).with(no_args).and_return(mode).once
        expect(mock_t).to receive(:send).with(local_kexecdh_init_payload).once
        expect(mock_t).to receive(:receive).with(no_args).and_return(remote_kexecdh_reply_payload).once

        kex_algorithm.start mock_t

        expect(kex_algorithm.shared_secret).to eq OpenSSL::BN.new(remote_dh.dh_compute_key(OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC.new(curve_name).group, OpenSSL::BN.new(kex_algorithm.instance_variable_get('@public_key')))), 2).to_i
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
        kex_algorithm.instance_variable_set('@q_c', remote_dh_public_key)
        kex_algorithm.instance_variable_set('@q_s', kex_algorithm.instance_variable_get('@public_key'))
        kex_algorithm.instance_variable_set('@shared_secret', OpenSSL::BN.new(kex_algorithm.instance_variable_get('@dh').dh_compute_key(OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC.new(curve_name).group, OpenSSL::BN.new(remote_dh_public_key))), 2).to_i)

        expect(mock_t).to receive(:v_c).with(no_args).and_return("v_c").once
        expect(mock_t).to receive(:v_s).with(no_args).and_return("v_s").once
        expect(mock_t).to receive(:i_c).with(no_args).and_return("i_c").once
        expect(mock_t).to receive(:i_s).with(no_args).and_return("i_s").once

        expect( kex_algorithm.hash(mock_t).length ).to eq digest_length
      end
    end
  end

  describe '#sign' do
    let(:mock_t){ double('mock transport') }

    context "when server host key algorithm is ssh-rsa" do
      let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

      it "returns encoded \"ssh-rsa\" || signed hash" do
        kex_algorithm.instance_variable_set('@k_s', server_host_key_algorithm.server_public_host_key)
        kex_algorithm.instance_variable_set('@q_c', remote_dh_public_key)
        kex_algorithm.instance_variable_set('@q_s', kex_algorithm.instance_variable_get('@public_key'))
        kex_algorithm.instance_variable_set('@shared_secret', OpenSSL::BN.new(kex_algorithm.instance_variable_get('@dh').dh_compute_key(OpenSSL::PKey::EC::Point.new(OpenSSL::PKey::EC.new(curve_name).group, OpenSSL::BN.new(remote_dh_public_key))), 2).to_i)

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
    let(:h){ OpenSSL::Digest.digest(digest, '2') }
    let(:_x){ 'C'.ord }
    let(:session_id){ OpenSSL::Digest.digest(digest, '4') }

    context "with key_length equal to digest length" do
      let(:key_length){ digest_length }

      it "generates key with no digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["8215c2e0ae2f4250d995766d14594b1dee59087da4e8f50e926a6049c051fb2e"].pack("H*")
      end
    end

    context "with key_length shorter than digest length" do
      let(:key_length){ digest_length / 2 }

      it "generates key using first key_length charactors with no digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["8215c2e0ae2f4250d995766d14594b1d"].pack("H*")
      end
    end

    context "with key_length longer than digest length" do
      let(:key_length){ digest_length * 2 }

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
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.iv_c_to_s(mock_t, encryption_algorithm_name) ).to eq ["9b131e37551e2da171aa2db4bddd7e3e"].pack("H*")
    end
  end

  describe '#iv_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates iv_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.iv_s_to_c(mock_t, encryption_algorithm_name) ).to eq ["bd4829f8805888b45431bc4f2da398b1"].pack("H*")
    end
  end

  describe '#key_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates key_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.key_c_to_s(mock_t, encryption_algorithm_name) ).to eq ["8215c2e0ae2f4250d995766d14594b1d"].pack("H*")
    end
  end

  describe '#key_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates key_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.key_s_to_c(mock_t, encryption_algorithm_name) ).to eq ["94bd604304def5520ad7e51479507518"].pack("H*")
    end
  end

  describe '#mac_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:mac_algorithm_name){ 'hmac-sha1' }

    it "generates mac_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.mac_c_to_s(mock_t, mac_algorithm_name) ).to eq ["6e3452445a6298bb147af10a51f1206fdf479fd8"].pack("H*")
    end
  end

  describe '#mac_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:mac_algorithm_name){ 'hmac-sha1' }

    it "generates mac_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest(digest, '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest(digest, '4') ).once

      expect( kex_algorithm.mac_s_to_c(mock_t, mac_algorithm_name) ).to eq ["1f9aa6ff84da01a90f9f9c56e8274c62fafdefa8"].pack("H*")
    end
  end
end
