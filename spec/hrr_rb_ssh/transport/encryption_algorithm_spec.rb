# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::EncryptionAlgorithm do
  describe 'self#[]' do
    it "has none algorithm loaded" do
      expect( HrrRbSsh::Transport::EncryptionAlgorithm['none'] ).to eq HrrRbSsh::Transport::EncryptionAlgorithm::None
    end
  end

  describe 'self#name_list' do
    it "contains none algorithm loaded" do
      expect( HrrRbSsh::Transport::EncryptionAlgorithm.name_list ).to include 'none'
    end
  end
end
