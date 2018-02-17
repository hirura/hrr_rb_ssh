# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::MacAlgorithm do
  describe 'self#[]' do
    it "has none algorithm loaded" do
      expect( HrrRbSsh::Transport::MacAlgorithm['none'] ).to eq HrrRbSsh::Transport::MacAlgorithm::None
    end
  end

  describe 'self#name_list' do
    it "contains none algorithm loaded" do
      expect( HrrRbSsh::Transport::MacAlgorithm.name_list ).to include 'none'
    end
  end
end
