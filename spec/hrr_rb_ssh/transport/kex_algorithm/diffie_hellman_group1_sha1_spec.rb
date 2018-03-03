# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup1Sha1 do
  let(:kex_algorithm){ described_class.new }
  let(:dh_group1_p){
    "FFFFFFFF" "FFFFFFFF" "C90FDAA2" "2168C234" \
    "C4C6628B" "80DC1CD1" "29024E08" "8A67CC74" \
    "020BBEA6" "3B139B22" "514A0879" "8E3404DD" \
    "EF9519B3" "CD3A431B" "302B0A6D" "F25F1437" \
    "4FE1356D" "6D51C245" "E485B576" "625E7EC6" \
    "F44C42E9" "A637ED6B" "0BFF5CB6" "F406B7ED" \
    "EE386BFB" "5A899FA5" "AE9F2411" "7C4B1FE6" \
    "49286651" "ECE65381" "FFFFFFFF" "FFFFFFFF"
  }
  let(:dh_group1_g){
    2
  }
  let(:remote_dh){
    dh = OpenSSL::PKey::DH.new
    dh.set_pqg OpenSSL::BN.new(dh_group1_p, 16), nil, OpenSSL::BN.new(dh_group1_g)
    dh.generate_key!
    dh
  }
  let(:remote_dh_pub_key){ 
    OpenSSL::BN.new(remote_dh.pub_key, 2).to_i
  }

  it "is registered as diffie-hellman-group1-sha1-rsa in HrrRbSsh::Transport::KexAlgorithm.list" do
    expect( HrrRbSsh::Transport::KexAlgorithm['diffie-hellman-group1-sha1'] ).to eq described_class
  end

  it "appears as diffie-hellman-group1-sha1 in HrrRbSsh::Transport::KexAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::KexAlgorithm.name_list ).to include 'diffie-hellman-group1-sha1'
  end

  describe '::P' do
    it "has diffie hellman group 1's p" do
      expect(described_class::P).to eq dh_group1_p
    end
  end

  describe '::G' do
    it "has diffie hellman group 1's g" do
      expect(described_class::G).to eq dh_group1_g
    end
  end

  describe '::DIGEST' do
    it "has digest sha1" do
      expect(described_class::DIGEST).to eq 'sha1'
    end
  end

  describe '#initialize' do
    it "can be instantiated" do
      expect( kex_algorithm ).to be_an_instance_of described_class
    end
  end

  describe '#set_e' do
    before :example do
      class HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup1Sha1
        def e
          @e
        end
      end
    end

    it "updates remote_dh_pub_key" do
      expect { kex_algorithm.set_e remote_dh_pub_key }.to change { kex_algorithm.e }.from( nil ).to( remote_dh_pub_key )
    end
  end

  describe '#shared_secret' do
    it "generates shared secret" do
      kex_algorithm.set_e remote_dh_pub_key
      expect( kex_algorithm.shared_secret ).to eq OpenSSL::BN.new(remote_dh.compute_key(kex_algorithm.pub_key), 2).to_i
    end
  end

  describe '#hash' do
    let(:mock_t){ double('mock transport') }

    context "when server host key algorithm is ssh-rsa" do
      let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

      it "returns hash" do
        kex_algorithm.set_e remote_dh_pub_key

        expect(mock_t).to receive(:v_c).with(no_args).and_return("v_c").once
        expect(mock_t).to receive(:v_s).with(no_args).and_return("v_s").once
        expect(mock_t).to receive(:i_c).with(no_args).and_return("i_c").once
        expect(mock_t).to receive(:i_s).with(no_args).and_return("i_s").once
        expect(mock_t).to receive(:server_host_key_algorithm).with(no_args).and_return(server_host_key_algorithm).once

        expect( kex_algorithm.hash(mock_t).length ).to eq 20
      end
    end
  end

  describe '#sign' do
    let(:mock_t){ double('mock transport') }

    context "when server host key algorithm is ssh-rsa" do
      let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

      it "returns encoded \"ssh-rsa\" || signed hash" do
        kex_algorithm.set_e remote_dh_pub_key

        expect(mock_t).to receive(:v_c).with(no_args).and_return("v_c").twice
        expect(mock_t).to receive(:v_s).with(no_args).and_return("v_s").twice
        expect(mock_t).to receive(:i_c).with(no_args).and_return("i_c").twice
        expect(mock_t).to receive(:i_s).with(no_args).and_return("i_s").twice
        expect(mock_t).to receive(:server_host_key_algorithm).with(no_args).and_return(server_host_key_algorithm).exactly(3).times

        expect( kex_algorithm.sign(mock_t) ).to eq server_host_key_algorithm.sign('sha1', kex_algorithm.hash(mock_t))
      end
    end
  end
end
