# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::EncryptionAlgorithm::Aes128Cbc do
  let(:iv){ [Array.new(16){ |i| "%02x" % i }.join].pack("H*") }
  let(:key){ [Array.new(16){ |i| "%02x" % i }.join].pack("H*") }
  let(:encryption_algorithm){ described_class.new iv, key }
  let(:data){ "1234567890123456" }

  it "is registered as aes128-cbc in HrrRbSsh::Transport::EncryptionAlgorithm.list" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm['aes128-cbc'] ).to eq described_class
  end

  it "appears as aes128-cbc in HrrRbSsh::Transport::EncryptionAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm.name_list ).to include 'aes128-cbc'
  end

  describe '#block_size' do
    it "returns 16" do
      expect( encryption_algorithm.block_size ).to eq 16
    end
  end

  describe '#iv_length' do
    it "returns 16" do
      expect( encryption_algorithm.iv_length ).to eq 16
    end
  end

  describe '#key_length' do
    it "returns 16" do
      expect( encryption_algorithm.key_length ).to eq 16
    end
  end

  describe '#encrypt' do
    it "returns not original data" do
      expect( encryption_algorithm.encrypt data ).to_not eq data
    end
  end

  describe '#decrypt' do
    it "returns not original data" do
      expect( encryption_algorithm.decrypt data ).to_not eq data
    end

    it "returns original data for encrypted data" do
      encrypted_data = encryption_algorithm.encrypt(data)
      expect( encryption_algorithm.decrypt encrypted_data ).to eq data
    end
  end
end
