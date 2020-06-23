# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup17Sha512 do
  let(:name){ 'diffie-hellman-group17-sha512' }
  let(:kex_algorithm){ described_class.new }
  let(:dh_group17_p){
    "FFFFFFFF" "FFFFFFFF" "C90FDAA2" "2168C234" "C4C6628B" "80DC1CD1 29024E08" \
    "8A67CC74" "020BBEA6" "3B139B22" "514A0879" "8E3404DD" "EF9519B3 CD3A431B" \
    "302B0A6D" "F25F1437" "4FE1356D" "6D51C245" "E485B576" "625E7EC6 F44C42E9" \
    "A637ED6B" "0BFF5CB6" "F406B7ED" "EE386BFB" "5A899FA5" "AE9F2411 7C4B1FE6" \
    "49286651" "ECE45B3D" "C2007CB8" "A163BF05" "98DA4836" "1C55D39A 69163FA8" \
    "FD24CF5F" "83655D23" "DCA3AD96" "1C62F356" "208552BB" "9ED52907 7096966D" \
    "670C354E" "4ABC9804" "F1746C08" "CA18217C" "32905E46" "2E36CE3B E39E772C" \
    "180E8603" "9B2783A2" "EC07A28F" "B5C55DF0" "6F4C52C9" "DE2BCBF6 95581718" \
    "3995497C" "EA956AE5" "15D22618" "98FA0510" "15728E5A" "8AAAC42D AD33170D" \
    "04507A33" "A85521AB" "DF1CBA64" "ECFB8504" "58DBEF0A" "8AEA7157 5D060C7D" \
    "B3970F85" "A6E1E4C7" "ABF5AE8C" "DB0933D7" "1E8C94E0" "4A25619D CEE3D226" \
    "1AD2EE6B" "F12FFA06" "D98A0864" "D8760273" "3EC86A64" "521F2B18 177B200C" \
    "BBE11757" "7A615D6C" "770988C0" "BAD946E2" "08E24FA0" "74E5AB31 43DB5BFC" \
    "E0FD108E" "4B82D120" "A9210801" "1A723C12" "A787E6D7" "88719A10 BDBA5B26" \
    "99C32718" "6AF4E23C" "1A946834" "B6150BDA" "2583E9CA" "2AD44CE8 DBBBC2DB" \
    "04DE8EF9" "2E8EFC14" "1FBECAA6" "287C5947" "4E6BC05D" "99B2964F A090C3A2" \
    "233BA186" "515BE7ED" "1F612970" "CEE2D7AF" "B81BDD76" "2170481C D0069127" \
    "D5B05AA9" "93B4EA98" "8D8FDDC1" "86FFB7DC" "90A6C08F" "4DF435C9 34028492" \
    "36C3FAB4" "D27C7026" "C1D4DCB2" "602646DE" "C9751E76" "3DBA37BD F8FF9406" \
    "AD9E530E" "E5DB382F" "413001AE" "B06A53ED" "9027D831" "179727B0 865A8918" \
    "DA3EDBEB" "CF9B14ED" "44CE6CBA" "CED4BB1B" "DB7F1447" "E6CC254B 33205151" \
    "2BD7AF42" "6FB8F401" "378CD2BF" "5983CA01" "C64B92EC" "F032EA15 D1721D03" \
    "F482D7CE" "6E74FEF6" "D55E702F" "46980C82" "B5A84031" "900B1C9E 59E7C97F" \
    "BEC7E8F3" "23A97A7E" "36CC88BE" "0F1D45B7" "FF585AC5" "4BD407B2 2B4154AA" \
    "CC8F6D7E" "BF48E1D8" "14CC5ED2" "0F8037E0" "A79715EE" "F29BE328 06A1D58B" \
    "B7C5DA76" "F550AA3D" "8A1FBFF0" "EB19CCB1" "A313D55C" "DA56C9EC 2EF29632" \
    "387FE8D7" "6E3C0468" "043E8F66" "3F4860EE" "12BF2D5B" "0B7474D6 E694F91E" \
    "6DCC4024" "FFFFFFFF" "FFFFFFFF"
  }
  let(:dh_group17_g){
    2
  }
  let(:remote_dh){
    dh = OpenSSL::PKey::DH.new
    if dh.respond_to?(:set_pqg)
      dh.set_pqg OpenSSL::BN.new(dh_group17_p, 16), nil, OpenSSL::BN.new(dh_group17_g)
    else
      dh.p = OpenSSL::BN.new(dh_group17_p, 16)
      dh.g = OpenSSL::BN.new(dh_group17_g)
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
    it "has diffie hellman group 17's p" do
      expect(described_class::P).to eq dh_group17_p
    end
  end

  describe '::G' do
    it "has diffie hellman group 17's g" do
      expect(described_class::G).to eq dh_group17_g
    end
  end

  describe '::DIGEST' do
    it "has digest sha512" do
      expect(described_class::DIGEST).to eq 'sha512'
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
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEXDH_INIT::VALUE,
          :'e'              => remote_dh_pub_key,
        }
      }
      let(:remote_kexdh_init_payload){
        HrrRbSsh::Messages::SSH_MSG_KEXDH_INIT.new.encode remote_kexdh_init_message
      }
      let(:server_host_key_algorithm){ double('server host key algorithm') }
      let(:server_public_host_key){ 'server public host key' }
      let(:sign){ 'sign' }
      let(:local_kexdh_reply_message){
        {
          :'message number'                                => HrrRbSsh::Messages::SSH_MSG_KEXDH_REPLY::VALUE,
          :'server public host key and certificates (K_S)' => server_public_host_key,
          :'f'                                             => kex_algorithm.instance_variable_get('@public_key'),
          :'signature of H'                                => sign,
        }
      }
      let(:local_kexdh_reply_payload){
        HrrRbSsh::Messages::SSH_MSG_KEXDH_REPLY.new.encode local_kexdh_reply_message
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
          :'message number' => HrrRbSsh::Messages::SSH_MSG_KEXDH_INIT::VALUE,
          :'e'              => kex_algorithm.instance_variable_get('@public_key'),
        }
      }
      let(:local_kexdh_init_payload){
        HrrRbSsh::Messages::SSH_MSG_KEXDH_INIT.new.encode local_kexdh_init_message
      }
      let(:server_public_host_key){ 'server public host key' }
      let(:sign){ 'sign' }
      let(:remote_kexdh_reply_message){
        {
          :'message number'                                => HrrRbSsh::Messages::SSH_MSG_KEXDH_REPLY::VALUE,
          :'server public host key and certificates (K_S)' => server_public_host_key,
          :'f'                                             => remote_dh_pub_key,
          :'signature of H'                                => sign,
        }
      }
      let(:remote_kexdh_reply_payload){
        HrrRbSsh::Messages::SSH_MSG_KEXDH_REPLY.new.encode remote_kexdh_reply_message
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

        expect( kex_algorithm.hash(mock_t).length ).to eq 64
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
    let(:h){ OpenSSL::Digest.digest('sha512', '2') }
    let(:_x){ 'C'.ord }
    let(:session_id){ OpenSSL::Digest.digest('sha512', '4') }

    context "with key_length equal to digest length" do
      let(:key_length){ 64 }

      it "generates key with no digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["f343d58ca39b69d0fab8765fcf5a19759bed391c1bad06c0da1d18f1666b1f0b666dd6e4b517c7f197a16abbf9bdbba94e25da2840a3339f6b427192d4204377"].pack("H*")
      end
    end

    context "with key_length shorter than digest length" do
      let(:key_length){ 32 }

      it "generates key using first key_length charactors with no digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["f343d58ca39b69d0fab8765fcf5a19759bed391c1bad06c0da1d18f1666b1f0b"].pack("H*")
      end
    end

    context "with key_length longer than digest length" do
      let(:key_length){ 128 }

      it "generates key with digesting loop" do
        expect( kex_algorithm.build_key(_k, h, _x, session_id, key_length) ).to eq ["f343d58ca39b69d0fab8765fcf5a19759bed391c1bad06c0da1d18f1666b1f0b666dd6e4b517c7f197a16abbf9bdbba94e25da2840a3339f6b427192d42043776c7d43e9c8ead1a1d4666c5d6a019e84809b3c76b6d91d3fbe2e685ddc3f97ca57ee98ba3d85e642ea3a5e81ff7d830a7f1a515ca6e11befaf3e68189ca2c873"].pack("H*")
      end
    end
  end

  describe '#iv_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates iv_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha512', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha512', '4') ).once

      expect( kex_algorithm.iv_c_to_s(mock_t, encryption_algorithm_name) ).to eq ["447412191cfdd527225a19e5890e96c9"].pack("H*")
    end
  end

  describe '#iv_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates iv_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha512', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha512', '4') ).once

      expect( kex_algorithm.iv_s_to_c(mock_t, encryption_algorithm_name) ).to eq ["41ae51dc0c78301c0a9b923f02551b6c"].pack("H*")
    end
  end

  describe '#key_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates key_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha512', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha512', '4') ).once

      expect( kex_algorithm.key_c_to_s(mock_t, encryption_algorithm_name) ).to eq ["f343d58ca39b69d0fab8765fcf5a1975"].pack("H*")
    end
  end

  describe '#key_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:encryption_algorithm_name){ 'aes128-cbc' }

    it "generates key_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha512', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha512', '4') ).once

      expect( kex_algorithm.key_s_to_c(mock_t, encryption_algorithm_name) ).to eq ["fe493020f895a6c99b0c5f908a7004b4"].pack("H*")
    end
  end

  describe '#mac_c_to_s' do
    let(:mock_t){ double('mock transport') }
    let(:mac_algorithm_name){ 'hmac-sha1' }

    it "generates mac_c_to_s" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha512', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha512', '4') ).once

      expect( kex_algorithm.mac_c_to_s(mock_t, mac_algorithm_name) ).to eq ["12d198581ac1834c94b49b88cbdaa825842bc8bd"].pack("H*")
    end
  end

  describe '#mac_s_to_c' do
    let(:mock_t){ double('mock transport') }
    let(:mac_algorithm_name){ 'hmac-sha1' }

    it "generates mac_s_to_c" do
      expect(kex_algorithm).to receive(:shared_secret).with(no_args).and_return( 1 ).once
      expect(kex_algorithm).to receive(:hash).with(mock_t).and_return( OpenSSL::Digest.digest('sha512', '2') ).once
      expect(mock_t).to receive(:session_id).with(no_args).and_return( OpenSSL::Digest.digest('sha512', '4') ).once

      expect( kex_algorithm.mac_s_to_c(mock_t, mac_algorithm_name) ).to eq ["dc20cffd76e84d0395b4dbe1240e7223e4aaf634"].pack("H*")
    end
  end
end
