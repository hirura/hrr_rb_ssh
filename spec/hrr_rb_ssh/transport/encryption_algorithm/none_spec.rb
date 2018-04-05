# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::EncryptionAlgorithm::None do
  let(:encryption_algorithm){ HrrRbSsh::Transport::EncryptionAlgorithm::None.new }
  let(:test_data){ "test data" }

  it "is registered in HrrRbSsh::Transport::EncryptionAlgorithm.list" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm.list ).to include described_class
  end

  it "can be looked up as none in HrrRbSsh::Transport::EncryptionAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm['none'] ).to eq described_class
  end

  it "appears as none in HrrRbSsh::Transport::EncryptionAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm.name_list ).to include 'none'
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
