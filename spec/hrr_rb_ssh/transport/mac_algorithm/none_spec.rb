# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::MacAlgorithm::None do
  let(:mac_algorithm){ described_class.new }
  let(:sequence_number){ 0 }
  let(:unencrypted_packet){ "dummy unencrypted_packet" }

  it "is registered as none in list of HrrRbSsh::Transport::MacAlgorithm" do
    expect( HrrRbSsh::Transport::MacAlgorithm['none'] ).to eq HrrRbSsh::Transport::MacAlgorithm::None
  end

  it "appears as none in HrrRbSsh::Transport::MacAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::MacAlgorithm.name_list ).to include 'none'
  end

  describe '#compute' do
    it "returns #{String.new.inspect}" do
      expect( mac_algorithm.compute sequence_number, unencrypted_packet ).to eq String.new
    end
  end

  describe '#digest_length' do
    it "returns 0" do
      expect( mac_algorithm.digest_length ).to eq 0
    end
  end

  describe '#key_length' do
    it "returns 0" do
      expect( mac_algorithm.key_length ).to eq 0
    end
  end
end
