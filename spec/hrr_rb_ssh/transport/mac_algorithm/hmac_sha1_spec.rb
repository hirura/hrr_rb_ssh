# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::MacAlgorithm::HmacSha1 do
  let(:key){ [Array.new(20){ |i| "%02x" % i }.join].pack("H*") }
  let(:mac_algorithm){ described_class.new key }
  let(:sequence_number){ 0 }
  let(:unencrypted_packet){ "testing" }

  it "is registered as hmac-sha1 in list of HrrRbSsh::Transport::MacAlgorithm" do
    expect( HrrRbSsh::Transport::MacAlgorithm['hmac-sha1'] ).to eq described_class
  end

  it "appears as hmac-sha1 in HrrRbSsh::Transport::MacAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::MacAlgorithm.name_list ).to include 'hmac-sha1'
  end

  describe '#compute' do
    it "returns 94 c9 a1 af 46 02 92 a7 06 8d 10 9e 63 f8 e0 8b 86 18 96 f8" do
      expect( mac_algorithm.compute sequence_number, unencrypted_packet ).to eq ["94c9a1af460292a7068d109e63f8e08b861896f8"].pack("H*")
    end
  end

  describe '#digest_length' do
    it "returns 20" do
      expect( mac_algorithm.digest_length ).to eq 20
    end
  end

  describe '#key_length' do
    it "returns 20" do
      expect( mac_algorithm.key_length ).to eq 20
    end
  end
end
