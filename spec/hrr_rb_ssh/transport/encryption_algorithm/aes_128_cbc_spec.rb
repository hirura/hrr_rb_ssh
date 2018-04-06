# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport::EncryptionAlgorithm::Aes128Cbc do
  let(:iv){ [Array.new(16){ |i| "%02x" % i }.join].pack("H*") }
  let(:key){ [Array.new(16){ |i| "%02x" % i }.join].pack("H*") }
  let(:encryption_algorithm){ described_class.new direction, iv, key }
  let(:data){ "1234567890123456" }

  it "is registered in HrrRbSsh::Transport::EncryptionAlgorithm.list" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm.list ).to include described_class
  end

  it "can be looked up as aes128-cbc in HrrRbSsh::Transport::EncryptionAlgorithm dictionary" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm['aes128-cbc'] ).to eq described_class
  end

  it "appears as aes128-cbc in HrrRbSsh::Transport::EncryptionAlgorithm.name_list" do
    expect( HrrRbSsh::Transport::EncryptionAlgorithm.name_list ).to include 'aes128-cbc'
  end

  context "when direction is outgoing" do
    let(:direction){ HrrRbSsh::Transport::Direction::OUTGOING }

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

    describe '#decrypt' do
      context "when data length is 0" do
        let(:empty_string){ String.new }

        it "returns original data (empty string)" do
          expect( encryption_algorithm.decrypt empty_string ).to eq empty_string
        end
      end

      context "when data length is a multiple of block length" do
        let(:encrypted_data){
          cipher = OpenSSL::Cipher.new("AES-128-CBC")
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
          cipher = OpenSSL::Cipher.new("AES-128-CBC")
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
