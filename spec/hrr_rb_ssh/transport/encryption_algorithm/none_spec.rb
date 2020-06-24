RSpec.describe HrrRbSsh::Transport::EncryptionAlgorithm::None do
  let(:name){ 'none' }
  let(:encryption_algorithm){ described_class.new }
  let(:test_data){ "test data" }

  it "can be looked up in HrrRbSsh::Transport::EncryptionAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm[name] ).to eq described_class
  end

  it "is registered in HrrRbSsh::Transport::EncryptionAlgorithm.list_supported" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm.list_supported ).to include name
  end

  it "not appears in HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred ).not_to include name
  end

  describe '#block_size' do
    it "returns 0" do
      expect( encryption_algorithm.block_size ).to eq 0
    end
  end

  describe '#iv_length' do
    it "returns 0" do
      expect( encryption_algorithm.iv_length ).to eq 0
    end
  end

  describe '#key_length' do
    it "returns 0" do
      expect( encryption_algorithm.key_length ).to eq 0
    end
  end

  describe '#encrypt' do
    it "returns data without encryption" do
      expect( encryption_algorithm.encrypt test_data ).to eq test_data
    end
  end

  describe '#decrypt' do
    it "returns data without decryption" do
      expect( encryption_algorithm.decrypt test_data ).to eq test_data
    end
  end
end
