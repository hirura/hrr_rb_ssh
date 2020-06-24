RSpec.describe HrrRbSsh::Transport::MacAlgorithm::None do
  let(:name){ 'none' }
  let(:mac_algorithm){ described_class.new }
  let(:sequence_number){ 0 }
  let(:unencrypted_packet){ "dummy unencrypted_packet" }

  it "can be looked up in HrrRbSsh::Transport::MacAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::MacAlgorithm[name] ).to eq described_class
  end

  it "is registered in HrrRbSsh::Transport::MacAlgorithm.list_supported" do
    expect( HrrRbSsh::Transport::MacAlgorithm.list_supported ).to include name
  end

  it "not appears in HrrRbSsh::Transport::MacAlgorithm.list_preferred" do
    expect( HrrRbSsh::Transport::MacAlgorithm.list_preferred ).not_to include name
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
