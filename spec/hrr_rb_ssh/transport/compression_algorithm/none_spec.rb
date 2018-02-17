# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::CompressionAlgorithm::None do
  let(:compression_algorithm){ HrrRbSsh::Transport::CompressionAlgorithm::None.new }
  let(:test_data){ "test data" }

  it "is registered as none in HrrRbSsh::Transport::CompressionAlgorithm.list" do
    expect( HrrRbSsh::Transport::CompressionAlgorithm['none'] ).to eq HrrRbSsh::Transport::CompressionAlgorithm::None
  end

  it "appears as none in HrrRbSsh::Transport::CompressionAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::CompressionAlgorithm.name_list ).to include 'none'
  end

  describe '#deflate' do
    it "returns data without deflate" do
      expect( compression_algorithm.deflate test_data ).to eq test_data
    end
  end

  describe '#inflate' do
    it "returns data without inflate" do
      expect( compression_algorithm.inflate test_data ).to eq test_data
    end
  end
end
