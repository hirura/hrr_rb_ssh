# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::ServerHostKeyAlgorithm::EcdsaSha2Nistp256 do
  let(:name){ 'ecdsa-sha2-nistp256' }
  let(:server_host_key_algorithm){ described_class.new }

  it "can be looked up in HrrRbSsh::Transport::ServerHostKeyAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm[name] ).to eq described_class
  end       

  it "is registered in HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported ).to include name
  end         

  it "appears in HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred ).to include name
  end

  describe '#server_public_host_key' do
    it "returns encoded \"ecdsa-sha2-nistp256\" || \"nistp256\" || Q" do
      encoded_server_public_host_key = \
        "00000013" "65636473" "612d7368" "61322d6e" \
        "69737470" "32353600" "0000086e" "69737470" \
        "32353600" "00004104" "b757a6f6" "4a3a0369" \
        "19145c15" "b4a810d3" "1a608198" "35ec4250" \
        "9a1173ec" "e6c636c6" "7c548144" "7341e04a" \
        "9342eaaa" "ea76151f" "5408ec17" "dcb93bfd" \
        "d9fcb1a1" "fe53538a"
      expect( server_host_key_algorithm.server_public_host_key ).to eq [encoded_server_public_host_key].pack("H*")
    end
  end

  describe '#verify' do
    let(:data){ 'testing' }

    context "with correct sign" do
      let(:sign){ server_host_key_algorithm.sign(data) }

      it "returns true" do
        expect( server_host_key_algorithm.verify sign, data ).to be true
      end
    end

    context "with not \"ecdsa-sha2-nistp256\"" do
      let(:encoded_data){
        "00000013" "01234567" "01234567" "01234567" \
        "01234567" "01234500" "00004900" "0000201b" \
        "6866cc78" "bfca96b6" "fc5a2c3c" "7b576268" \
        "28398e21" "137b945a" "bf62e288" "c4444b00" \
        "00002100" "ad13b8c7" "5c7aa574" "42ca9e33" \
        "ea992ea3" "34729c4b" "04d2af4d" "41b58de6" \
        "1cc3c978"
      }
      let(:sign){ [encoded_data].pack("H*") }

      it "returns false" do
        expect( server_host_key_algorithm.verify sign, data ).to be false
      end
    end

    context "with incorrect sign" do
      let(:encoded_data){
        "00000013" "65636473" "612d7368" "61322d6e" \
        "69737470" "32353600" "00004900" "0000201b" \
        "6866cc78" "bfca96b6" "fc5a2c3c" "7b576268" \
        "28398e21" "137b945a" "bf62e288" "c4444b00" \
        "00002100" "ad13b8c7" "5c7aa574" "42ca9e33" \
        "ea992ea3" "34729c4b" "04d2af4d" "41b58de6" \
        "01234567"
      }
      let(:sign){ [encoded_data].pack("H*") }

      it "returns false" do
        expect( server_host_key_algorithm.verify sign, data ).to be false
      end
    end
  end
end
