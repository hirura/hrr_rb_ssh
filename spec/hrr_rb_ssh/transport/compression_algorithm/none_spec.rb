# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::CompressionAlgorithm::None do
  let(:name){ 'none' }
  let(:compression_algorithm){ described_class.new }
  let(:test_data){ "test data" }

  it "can be looked up in HrrRbSsh::Transport::CompressionAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::CompressionAlgorithm[name] ).to eq described_class
  end

  it "is registered in HrrRbSsh::Transport::CompressionAlgorithm.list_supported" do
    expect( HrrRbSsh::Transport::CompressionAlgorithm.list_supported ).to include name
  end

  it "not appears in HrrRbSsh::Transport::CompressionAlgorithm.list_preferred" do
    expect( HrrRbSsh::Transport::CompressionAlgorithm.list_preferred ).to include name
  end

  context "when direction is not set" do
    after :example do
      compression_algorithm.close
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

    describe '#close' do
      it "does nothing and returns nil" do
        expect( compression_algorithm.close ).to be nil
      end
    end
  end
end
