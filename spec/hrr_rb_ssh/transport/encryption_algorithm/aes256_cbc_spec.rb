# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::EncryptionAlgorithm::Aes256Cbc do
  let(:name){ 'aes256-cbc' }
  let(:cipher_name){ "AES-256-CBC" }
  let(:block_size){ 16 }
  let(:iv_length){ 16 }
  let(:key_length){ 32 }
  let(:iv){ [Array.new(iv_length){ |i| "%02x" % i }.join].pack("H*") }
  let(:key){ [Array.new(key_length){ |i| "%02x" % i }.join].pack("H*") }
  let(:encryption_algorithm){ described_class.new direction, iv, key }
  let(:data){ ('a'..'z').to_a.sample(block_size).join }

  it "can be looked up in HrrRbSsh::Transport::EncryptionAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm[name] ).to eq described_class
  end       

  it "is registered in HrrRbSsh::Transport::EncryptionAlgorithm.list_supported" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm.list_supported ).to include name
  end         

  it "appears in HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred ).to include name
  end

  context "when direction is outgoing" do
    let(:direction){ HrrRbSsh::Transport::Direction::OUTGOING }

    describe '#block_size' do
      it "returns expected block size" do
        expect( encryption_algorithm.block_size ).to eq block_size
      end
    end

    describe '#iv_length' do
      it "returns expected iv length" do
        expect( encryption_algorithm.iv_length ).to eq iv_length
      end
    end

    describe '#key_length' do
      it "returns expected key length" do
        expect( encryption_algorithm.key_length ).to eq key_length
      end
    end

    describe '#encrypt' do
      context "when data length is 0" do
        let(:empty_string){ String.new }

        it "returns original data (empty string)" do
          expect( encryption_algorithm.encrypt empty_string ).to eq empty_string
        end
      end

      context "when data length is a multiple of block length" do
        it "returns not original data" do
          expect( encryption_algorithm.encrypt data ).to_not eq data
        end
      end

      context "when data length is not a multiple of block length" do
        let(:invalid_length_data){ data + 'z' }

        it "raises error" do
          expect { encryption_algorithm.encrypt invalid_length_data }.to raise_error OpenSSL::Cipher::CipherError
        end
      end
    end
  end

  context "when direction is incoming" do
    let(:direction){ HrrRbSsh::Transport::Direction::INCOMING }

    describe '#block_size' do
      it "returns expected block size" do
        expect( encryption_algorithm.block_size ).to eq block_size
      end
    end

    describe '#iv_length' do
      it "returns expected iv length" do
        expect( encryption_algorithm.iv_length ).to eq iv_length
      end
    end

    describe '#key_length' do
      it "returns expected key length" do
        expect( encryption_algorithm.key_length ).to eq key_length
      end
    end

    describe '#decrypt' do
      context "when data length is 0" do
        let(:empty_string){ String.new }

        it "returns original data (empty string)" do
          expect( encryption_algorithm.decrypt empty_string ).to eq empty_string
        end
      end

      context "when data length is a multiple of block length" do
        let(:encrypted_data){
          cipher = OpenSSL::Cipher.new(cipher_name)
          cipher.encrypt
          cipher.padding = 0
          cipher.iv  = iv
          cipher.key = key
          cipher.update(data) + cipher.final
        }

        it "returns original data for encrypted data" do
          expect( encryption_algorithm.decrypt encrypted_data ).to eq data
        end
      end

      context "when data length is not a multiple of block length" do
        let(:encrypted_data){
          cipher = OpenSSL::Cipher.new(cipher_name)
          cipher.encrypt
          cipher.padding = 0
          cipher.iv  = iv
          cipher.key = key
          cipher.update(data) + cipher.final
        }
        let(:invalid_length_encrypted_data){ encrypted_data + 'z' }

        it "raises error" do
          expect { encryption_algorithm.decrypt invalid_length_encrypted_data }.to raise_error OpenSSL::Cipher::CipherError
        end
      end
    end
  end
end
