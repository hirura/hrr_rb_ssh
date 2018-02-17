# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::CompressionAlgorithm do
  describe 'self#[]' do
    it "has none algorithm loaded" do
      expect( HrrRbSsh::Transport::CompressionAlgorithm['none'] ).to eq HrrRbSsh::Transport::CompressionAlgorithm::None
    end
  end

  describe 'self#name_list' do
    it "contains none algorithm loaded" do
      expect( HrrRbSsh::Transport::CompressionAlgorithm.name_list ).to include 'none'
    end
  end
end
