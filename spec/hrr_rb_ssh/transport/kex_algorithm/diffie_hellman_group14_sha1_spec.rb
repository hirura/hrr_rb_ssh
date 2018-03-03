# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup14Sha1 do
  let(:kex_algorithm){ described_class.new }
  let(:remote_dh){
    dh = OpenSSL::PKey::DH.new
    dh.set_pqg OpenSSL::BN.new( kex_algorithm.p, 16 ), nil, OpenSSL::BN.new( kex_algorithm.g )
    dh.generate_key!
    dh
  }
  let(:remote_dh_pub_key){ 
    OpenSSL::BN.new(remote_dh.pub_key, 2).to_i
  }

  it "is registered as diffie-hellman-group14-sha1-rsa in HrrRbSsh::Transport::KexAlgorithm.list" do
    expect( HrrRbSsh::Transport::KexAlgorithm['diffie-hellman-group14-sha1'] ).to eq described_class
  end

  it "appears as diffie-hellman-group14-sha1 in HrrRbSsh::Transport::KexAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::KexAlgorithm.name_list ).to include 'diffie-hellman-group14-sha1'
  end

  describe '#initialize' do
    it "can be instantiated" do
      expect( kex_algorithm ).to be_an_instance_of described_class
    end
  end

  describe '#set_e' do
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
