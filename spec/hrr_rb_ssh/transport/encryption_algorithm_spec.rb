# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::EncryptionAlgorithm do
  describe '[key]' do
    it "has none algorithm loaded" do
      expect( described_class['none'] ).to eq described_class::None
    end
  end

  describe '.list_supported' do
    it "contains none algorithm loaded" do
      expect( described_class.list_supported ).to include 'none'
    end
  end

  describe '.list_preferred' do
    it "contains none algorithm loaded" do
      expect( described_class.list_preferred ).not_to include 'none'
    end
  end
end
