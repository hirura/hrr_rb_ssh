# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup1Sha1 do
  let(:kex_algorithm){ described_class.new }

  it "is registered as diffie-hellman-group1-sha1-rsa in HrrRbSsh::Transport::KexAlgorithm.list" do
    expect( HrrRbSsh::Transport::KexAlgorithm['diffie-hellman-group1-sha1'] ).to eq described_class
  end

  it "appears as diffie-hellman-group1-sha1 in HrrRbSsh::Transport::KexAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::KexAlgorithm.name_list ).to include 'diffie-hellman-group1-sha1'
  end

  describe '#initialize' do
    it "can be instantiated" do
      expect( kex_algorithm ).to be_an_instance_of described_class
    end
  end
end
