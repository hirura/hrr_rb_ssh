# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::ServerHostKeyAlgorithm do
  describe 'self#[]' do
    it "returns nil for dummy key" do
      expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm['dummy key'] ).to be nil
    end
  end

  describe 'self#name_list' do
    it "returns an instance of Array" do
      expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list ).to be_an_instance_of Array
    end
  end
end
