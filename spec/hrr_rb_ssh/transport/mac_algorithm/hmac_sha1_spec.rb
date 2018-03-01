# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::MacAlgorithm::HmacSha1 do
  let(:incoming_key){ [Array.new(20){|i| "%02x" % i     }.join].pack("H*") }
  let(:outgoing_key){ [Array.new(20){|i| "%02x" % (19-i)}.join].pack("H*") }
  let(:mac_algorithm){ described_class.new incoming_key, outgoing_key }
  let(:sequence_number){ 0 }
  let(:unencrypted_packet){ "testing" }

  it "is registered as hmac-sha1 in list of HrrRbSsh::Transport::MacAlgorithm" do
    expect( HrrRbSsh::Transport::MacAlgorithm['hmac-sha1'] ).to eq described_class
  end

  it "appears as hmac-sha1 in HrrRbSsh::Transport::MacAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::MacAlgorithm.name_list ).to include 'hmac-sha1'
  end

  describe '#compute' do
    it "returns e4 98 9f d2 f7 3a f3 e9 75 05 e5 5a 88 52 fe 77 2e ff e3 be" do
      expect( mac_algorithm.compute sequence_number, unencrypted_packet ).to eq ["e4989fd2f73af3e97505e55a8852fe772effe3be"].pack("H*")
    end
  end

  describe '#valid?' do
    context "when mac is 94 c9 a1 af 46 02 92 a7 06 8d 10 9e 63 f8 e0 8b 86 18 96 f8" do
      let(:mac){ ["94c9a1af460292a7068d109e63f8e08b861896f8"].pack("H*") }

      it "returns true" do
        expect( mac_algorithm.valid? sequence_number, unencrypted_packet, mac ).to be true
      end
    end

    context "when mac is e4 98 9f d2 f7 3a f3 e9 75 05 e5 5a 88 52 fe 77 2e ff e3 be" do
      let(:mac){ ["e4989fd2f73af3e97505e55a8852fe772effe3be"].pack("H*") }

      it "returns false" do
        expect( mac_algorithm.valid? sequence_number, unencrypted_packet, mac ).to be false
      end
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
