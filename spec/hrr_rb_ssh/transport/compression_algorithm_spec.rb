RSpec.describe HrrRbSsh::Transport::CompressionAlgorithm do
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
      expect( described_class.list_preferred ).to include 'none'
    end
  end
end
