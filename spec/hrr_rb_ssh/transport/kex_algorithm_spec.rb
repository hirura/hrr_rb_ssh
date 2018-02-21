# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::KexAlgorithm do
  describe 'self#[]' do
    it "returns nil for dummy key" do
      expect( HrrRbSsh::Transport::KexAlgorithm['dummy key'] ).to be nil
    end
  end

  describe 'self#name_list' do
    it "returns an instance of Array" do
      expect( HrrRbSsh::Transport::KexAlgorithm.name_list ).to be_an_instance_of Array
    end
  end
end
