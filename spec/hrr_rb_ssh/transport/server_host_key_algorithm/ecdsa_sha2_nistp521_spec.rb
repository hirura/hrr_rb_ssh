# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::ServerHostKeyAlgorithm::EcdsaSha2Nistp521 do
  let(:name){ 'ecdsa-sha2-nistp521' }

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
MIHcAgEBBEIByLZ82qYoJid43PwFAdhr3mSH7SalBTdrK8H6h4p3RKEisAsVhmVb
Sx+uGtgKVxxZT5s9tjr7W7Aqc6We5Fg9z7igBwYFK4EEACOhgYkDgYYABAFLHJ3H
6HBJyJFsN2PRsjJyRMfYE57BB8dmZgwTsHuSAXBkj+2g4ucwtF240zAWw6JOYdqE
V5O4BMNxGfYj+0ceKABJ4MgfUXQ3a1cXn8Dk2Q2uibbfVi7tQ7ET4k/A6B9f/Zwq
/zEM5OVWhfyc+vuEg+TfTtTqgVI2zJpLI7+mSjB/5Q==
-----END EC PRIVATE KEY-----
      EOB
    }

    describe '#server_public_host_key' do
      it "returns encoded \"ecdsa-sha2-nistp521\" || \"nistp521\" || Q" do
        encoded_server_public_host_key = \
          "00000013" "65636473" "612d7368" "61322d6e" \
          "69737470" "35323100" "0000086e" "69737470" \
          "35323100" "00008504" "014b1c9d" "c7e87049" \
          "c8916c37" "63d1b232" "7244c7d8" "139ec107" \
          "c766660c" "13b07b92" "0170648f" "eda0e2e7" \
          "30b45db8" "d33016c3" "a24e61da" "845793b8" \
          "04c37119" "f623fb47" "1e280049" "e0c81f51" \
          "74376b57" "179fc0e4" "d90dae89" "b6df562e" \
          "ed43b113" "e24fc0e8" "1f5ffd9c" "2aff310c" \
          "e4e55685" "fc9cfafb" "8483e4df" "4ed4ea81" \
          "5236cc9a" "4b23bfa6" "4a307fe5"
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

      context "with not \"ecdsa-sha2-nistp521\"" do
        let(:encoded_data){
          "00000013" "01234567" "01234567" "01234567" \
          "01234567" "01234500" "00008c00" "00004201" \
          "0de2cf59" "4c052025" "04a214ef" "12d0a98c" \
          "1cd4795c" "66f1af26" "e73d3e26" "d18e8dd2" \
          "c275f4cc" "f45f2d47" "e3da74c0" "9ecca2f0" \
          "8f19d4f3" "26e8be03" "a156af00" "4510a491" \
          "7d000000" "4200fb1b" "70b31376" "fc8f9da0" \
          "1ab4f281" "48f05b0d" "0712cc35" "bf24a549" \
          "68fd5269" "eb1f9da8" "4bb82bdf" "23720238" \
          "3db4cee9" "1610fd49" "cb47dd20" "f7c624d7" \
          "048dfd59" "a2f796"
        }
        let(:sign){ [encoded_data].pack("H*") }

        it "returns false" do
          expect( server_host_key_algorithm.verify sign, data ).to be false
        end
      end

      context "with incorrect sign" do
        let(:encoded_data){
          "00000013" "65636473" "612d7368" "61322d6e" \
          "69737470" "35323100" "00008c00" "00004201" \
          "0de2cf59" "4c052025" "04a214ef" "12d0a98c" \
          "1cd4795c" "66f1af26" "e73d3e26" "d18e8dd2" \
          "c275f4cc" "f45f2d47" "e3da74c0" "9ecca2f0" \
          "8f19d4f3" "26e8be03" "a156af00" "4510a491" \
          "7d000000" "4200fb1b" "70b31376" "fc8f9da0" \
          "1ab4f281" "48f05b0d" "0712cc35" "bf24a549" \
          "68fd5269" "eb1f9da8" "4bb82bdf" "23720238" \
          "3db4cee9" "1610fd49" "cb47dd20" "f7c624d7" \
          "01234567" "012345"
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
