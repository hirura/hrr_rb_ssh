# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshEd25519 do
  let(:name){ 'ssh-ed25519' }

  it "can be looked up in HrrRbSsh::Transport::ServerHostKeyAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm[name] ).to eq described_class
  end

  it "is registered in HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported ).to include name
  end

  it "appears in HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred" do
    expect( HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred ).to include name
  end

  context "when secret_key is specified" do
    let(:server_host_key_algorithm){ described_class.new secret_key }
    let(:secret_key){
      <<-'EOB'
-----BEGIN PRIVATE KEY-----
MC4CAQAwBQYDK2VwBCIEIO8BvFjQCQGGsNbq0c7uh81pvpNhun6uAPTz3lb/cXHA
-----END PRIVATE KEY-----
      EOB
    }

    describe '#server_public_host_key' do
      it "returns encoded \"ssh-ed25519\" || key" do
        encoded_server_public_host_key = \
          "0000000b" "7373682d" "65643235" "35313900" \
          "000020d3" "132fee17" "40163bf6" "43a68b38" \
          "6f4f3f47" "4d5e6f6a" "907195ed" "67b03209" \
          "75a5c1"
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

      context "with not \"ssh-ed25519\"" do
        let(:encoded_data){
          "0000000b" "01234567" "01234567" "01234500" \
          "00004057" "7acbc656" "661751c2" "4ab9fc97" \
          "fb074018" "e2e2b23f" "48c95ec4" "c207cd75" \
          "6b544830" "f2019ffa" "2c054317" "87bb5f81" \
          "1afc6ad5" "a46778aa" "4c973c17" "e89d5d64" \
          "51c40a"
        }
        let(:sign){ [encoded_data].pack("H*") }

        it "returns false" do
          expect( server_host_key_algorithm.verify sign, data ).to be false
        end
      end

      context "with incorrect sign" do
        let(:encoded_data){
          "0000000b" "7373682d" "65643235" "35313900" \
          "00004057" "7acbc656" "661751c2" "4ab9fc97" \
          "fb074018" "e2e2b23f" "48c95ec4" "c207cd75" \
          "6b544830" "f2019ffa" "2c054317" "87bb5f81" \
          "1afc6ad5" "a46778aa" "4c973c17" "e89d5d64" \
          "012345"
        }
        let(:sign){ [encoded_data].pack("H*") }

        it "returns false" do
          expect( server_host_key_algorithm.verify sign, data ).to be false
        end
      end
    end
  end

  context "when secret_key is specified" do
    let(:server_host_key_algorithm){ described_class.new }

    describe '#verify' do
      let(:data){ 'testing' }

      context "with correct sign" do
        let(:sign){ server_host_key_algorithm.sign(data) }

        it "returns true" do
          expect( server_host_key_algorithm.verify sign, data ).to be true
        end
      end
    end
  end
end
