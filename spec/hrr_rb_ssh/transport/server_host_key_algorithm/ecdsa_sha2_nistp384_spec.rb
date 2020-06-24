RSpec.describe HrrRbSsh::Transport::ServerHostKeyAlgorithm::EcdsaSha2Nistp384 do
  let(:name){ 'ecdsa-sha2-nistp384' }

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
-----BEGIN EC PRIVATE KEY-----
MIGkAgEBBDCKZ6ulBka9rUw+gqKiQdVBG6fzH1klswyMrxrzCcfwRfoc5CGnj8e7
emk+IHyUsd6gBwYFK4EEACKhZANiAATnWMWRgfp3DFiBmdT7LunyBk9YIBYqPsrk
Zil+AWvlISusiW2JcZVB+Hz79tyrgzfwp6n6k9r5s31EIGTGf/n7UMwISrUCfcx+
xVrnYV8pOoy+dcUiGb9okf1jc41bLHc=
-----END EC PRIVATE KEY-----
      EOB
    }

    describe '#server_public_host_key' do
      it "returns encoded \"ecdsa-sha2-nistp384\" || \"nistp384\" || Q" do
        encoded_server_public_host_key = \
          "00000013" "65636473" "612d7368" "61322d6e" \
          "69737470" "33383400" "0000086e" "69737470" \
          "33383400" "00006104" "e758c591" "81fa770c" \
          "588199d4" "fb2ee9f2" "064f5820" "162a3eca" \
          "e466297e" "016be521" "2bac896d" "89719541" \
          "f87cfbf6" "dcab8337" "f0a7a9fa" "93daf9b3" \
          "7d442064" "c67ff9fb" "50cc084a" "b5027dcc" \
          "7ec55ae7" "615f293a" "8cbe75c5" "2219bf68" \
          "91fd6373" "8d5b2c77"
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

      context "with not \"ecdsa-sha2-nistp384\"" do
        let(:encoded_data){
          "00000013" "01234567" "01234567" "01234567" \
          "01234567" "01234500" "00006a00" "00003100" \
          "c6d21193" "92f1de9d" "f755fd38" "366d5b9a" \
          "c095d71a" "5da47768" "8e4cfb8a" "3c5caa25" \
          "8bb3d802" "1d9b87d1" "130f433f" "e611719b" \
          "00000031" "00e3f674" "71237534" "633612bc" \
          "0f5f886c" "bbcc25e6" "74becf67" "525710aa" \
          "af82dff1" "5f9c0277" "dd9f069b" "ea45511f" \
          "d442921c" "2c"
        }
        let(:sign){ [encoded_data].pack("H*") }

        it "returns false" do
          expect( server_host_key_algorithm.verify sign, data ).to be false
        end
      end

      context "with incorrect sign" do
        let(:encoded_data){
          "00000013" "65636473" "612d7368" "61322d6e" \
          "69737470" "33383400" "00006a00" "00003100" \
          "c6d21193" "92f1de9d" "f755fd38" "366d5b9a" \
          "c095d71a" "5da47768" "8e4cfb8a" "3c5caa25" \
          "8bb3d802" "1d9b87d1" "130f433f" "e611719b" \
          "00000031" "00e3f674" "71237534" "633612bc" \
          "0f5f886c" "bbcc25e6" "74becf67" "525710aa" \
          "af82dff1" "5f9c0277" "dd9f069b" "ea45511f" \
          "01234567" "01"
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
