# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa do
  let(:server_host_key_algorithm){ HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa.new }

  it "is registered as ssh-rsa in HrrRbSsh::Transport::ServerHostKeyAlgorithm.list" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm['ssh-rsa'] ).to eq HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa
  end

  it "appears as ssh-rsa in HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list ).to include 'ssh-rsa'
  end

  describe '#initialize' do
    it "can be instantiated" do
      expect( server_host_key_algorithm ).to be_an_instance_of HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa
    end
  end
end
