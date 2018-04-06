# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::CompressionAlgorithm::Zlib do
  let(:name){ 'zlib' }
  let(:compression_algorithm){ described_class.new direction }

  it "is registered in HrrRbSsh::Transport::CompressionAlgorithm.list" do
    expect( HrrRbSsh::Transport::CompressionAlgorithm.list ).to include described_class
  end

  it "can be looked up in HrrRbSsh::Transport::CompressionAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::CompressionAlgorithm[name] ).to eq described_class
  end

  it "appears in HrrRbSsh::Transport::CompressionAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::CompressionAlgorithm.name_list ).to include name
  end

  context "when direction is outgoing" do
    let(:direction){ HrrRbSsh::Transport::Direction::OUTGOING }

    describe '#deflate' do
      context "deflate once" do
        let(:test_data){ "test data" }
        let(:first_deflated){ ["789c2a492d2e5148492c4904000000ffff"].pack("H*") }

        it "returns deflated data" do
          expect( compression_algorithm.deflate test_data ).to eq first_deflated
        end
      end

      context "deflate multiple times" do
        let(:test_data){ "test data" }
        let(:first_deflated) { ["789c2a492d2e5148492c4904000000ffff"].pack("H*") }
        let(:second_deflated){ ["2a813100000000ffff"].pack("H*") }
        let(:third_deflated) { ["823300000000ffff"].pack("H*") }
        let(:fourth_deflated){ ["823300000000ffff"].pack("H*") }

        it "returns deflated data" do
          expect( compression_algorithm.deflate test_data ).to eq first_deflated
          expect( compression_algorithm.deflate test_data ).to eq second_deflated
          expect( compression_algorithm.deflate test_data ).to eq third_deflated
          expect( compression_algorithm.deflate test_data ).to eq fourth_deflated
        end
      end
    end
  end

  context "when direction is incoming" do
    let(:direction){ HrrRbSsh::Transport::Direction::INCOMING }

    describe '#inflate' do
      context "inflate once" do
        let(:test_data){ "test data" }
        let(:first_deflated){ ["789c2a492d2e5148492c4904000000ffff"].pack("H*") }

        it "returns data without inflate" do
          expect( compression_algorithm.inflate first_deflated ).to eq test_data
        end
      end

      context "inflate multiple times" do
        let(:test_data){ "test data" }
        let(:first_deflated ){ ["789c2a492d2e5148492c4904000000ffff"].pack("H*") }
        let(:second_deflated){ ["2a813100000000ffff"].pack("H*") }
        let(:third_deflated ){ ["823300000000ffff"].pack("H*") }
        let(:fourth_deflated){ ["823300000000ffff"].pack("H*") }

        it "returns inflated data" do
          expect( compression_algorithm.inflate first_deflated  ).to eq test_data
          expect( compression_algorithm.inflate second_deflated ).to eq test_data
          expect( compression_algorithm.inflate third_deflated  ).to eq test_data
          expect( compression_algorithm.inflate fourth_deflated ).to eq test_data
        end
      end
    end
  end
end
