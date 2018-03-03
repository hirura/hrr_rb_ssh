# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Transport do
  before :all do
    class MockSocket
      def initialize
        @incoming_read, @incoming_write = IO.pipe
        @outgoing_read, @outgoing_write = IO.pipe
      end
      def local_read   x; @incoming_read.read   x; end
      def local_write  x; @outgoing_write.write x; end
      def remote_read  x; @outgoing_read.read   x; end
      def remote_write x; @incoming_write.write x; end
      alias read  local_read
      alias write local_write
    end
  end

  describe '#initialize' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "takes two arguments: io and mode" do
      expect { transport }.not_to raise_error
    end

    it "initializes incoming_sequence_number readable" do
      expect(transport.incoming_sequence_number).to be_an_instance_of HrrRbSsh::Transport::SequenceNumber
      expect(transport.incoming_sequence_number.sequence_number).to eq 0
    end

    it "initializes outgoing_sequence_number readable" do
      expect(transport.outgoing_sequence_number).to be_an_instance_of HrrRbSsh::Transport::SequenceNumber
      expect(transport.outgoing_sequence_number.sequence_number).to eq 0
    end

    it "initializes incoming_encryption_algorithm readable" do
      expect(transport.incoming_encryption_algorithm).to be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::None
    end

    it "initializes incoming_mac_algorithm readable" do
      expect(transport.incoming_mac_algorithm).to be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::None
    end

    it "initializes incoming_compression_algorithm readable" do
      expect(transport.incoming_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
    end

    it "initializes outgoing_encryption_algorithm readable" do
      expect(transport.outgoing_encryption_algorithm).to be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::None
    end

    it "initializes outgoing_mac_algorithm readable" do
      expect(transport.outgoing_mac_algorithm).to be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::None
    end

    it "initializes outgoing_compression_algorithm readable" do
      expect(transport.outgoing_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
    end

    it "initializes v_c readable" do
      expect(transport.v_c).to be nil
    end

    it "initializes v_s readable" do
      expect(transport.v_s).to be nil
    end
  end

  context "when mode is server" do
    let(:io){ MockSocket.new }
    let(:mode){ HrrRbSsh::Transport::Mode::SERVER }

    describe "#exchange_version" do
      let(:transport){ described_class.new io, mode }
      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      it "sends SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION} || CR || LF" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(io.remote_read 24).to eq (local_version_string + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
      end

      it "receives remote version string and updates v_c" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_c).to eq remote_version_string
      end

      it "updates v_s" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_s).to eq local_version_string
      end

      it "skips data before remote version string" do
        io.remote_write ("initial data" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_c).to eq remote_version_string
      end
    end

    describe "#exchange_key" do
      let(:transport){ described_class.new io, mode }
      let(:remote_kexinit_packet){
        [
          "0000010c" "06145855" "3f58552c" "8ed18b59" \
          "ad2d7ea1" "0d250000" "00366469" "66666965" \
          "2d68656c" "6c6d616e" "2d67726f" "75703134" \
          "2d736861" "312c6469" "66666965" "2d68656c" \
          "6c6d616e" "2d67726f" "7570312d" "73686131" \
          "0000000f" "7373682d" "7273612c" "7373682d" \
          "64737300" "00001561" "65733132" "382d6362" \
          "632c6165" "73323536" "2d636263" "00000015" \
          "61657331" "32382d63" "62632c61" "65733235" \
          "362d6362" "63000000" "12686d61" "632d7368" \
          "61312c68" "6d61632d" "6d643500" "00001268" \
          "6d61632d" "73686131" "2c686d61" "632d6d64" \
          "35000000" "1a6e6f6e" "652c7a6c" "6962406f" \
          "70656e73" "73682e63" "6f6d2c7a" "6c696200" \
          "00001a6e" "6f6e652c" "7a6c6962" "406f7065" \
          "6e737368" "2e636f6d" "2c7a6c69" "62000000" \
          "00000000" "00000000" "00000000" "00000000"
        ].pack("H*")
      }
      let(:remote_kexinit_payload){
        [
          "1458553f" "58552c8e" "d18b59ad" "2d7ea10d" \
          "25000000" "36646966" "6669652d" "68656c6c" \
          "6d616e2d" "67726f75" "7031342d" "73686131" \
          "2c646966" "6669652d" "68656c6c" "6d616e2d" \
          "67726f75" "70312d73" "68613100" "00000f73" \
          "73682d72" "73612c73" "73682d64" "73730000" \
          "00156165" "73313238" "2d636263" "2c616573" \
          "3235362d" "63626300" "00001561" "65733132" \
          "382d6362" "632c6165" "73323536" "2d636263" \
          "00000012" "686d6163" "2d736861" "312c686d" \
          "61632d6d" "64350000" "0012686d" "61632d73" \
          "6861312c" "686d6163" "2d6d6435" "0000001a" \
          "6e6f6e65" "2c7a6c69" "62406f70" "656e7373" \
          "682e636f" "6d2c7a6c" "69620000" "001a6e6f" \
          "6e652c7a" "6c696240" "6f70656e" "7373682e" \
          "636f6d2c" "7a6c6962" "00000000" "00000000" \
          "00000000" "00"
        ].pack("H*")
      }

      it "sends kexinit" do
        io.remote_write remote_kexinit_packet
        transport.exchange_key
        io.remote_read 4  # skip packet length field
        io.remote_read 1  # skip padding length field
        expect(io.remote_read 1).to eq [20].pack("C")
      end

      it "updates i_c" do
        io.remote_write remote_kexinit_packet
        transport.exchange_key
        expect(transport.i_c).to eq remote_kexinit_payload
      end

      it "updates i_s" do
        io.remote_write remote_kexinit_packet
        transport.exchange_key
        i_s = StringIO.new transport.i_s, 'r'
        expect(i_s.read(1).unpack("C")[0]).to eq 20
        16.times do
          expect(i_s.read(1).unpack("C")[0]).to be_between(0x00, 0xff).inclusive
        end
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::KexAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::EncryptionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::EncryptionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::MacAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::MacAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::CompressionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq HrrRbSsh::Transport::CompressionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq []
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_s).to eq []
        expect(HrrRbSsh::Transport::DataType::Boolean.decode i_s).to eq false
        expect(HrrRbSsh::Transport::DataType::Uint32.decode i_s).to eq 0
        expect(i_s.read).to eq ""
      end
    end
  end

  context "when mode is client" do
    let(:io){ MockSocket.new }
    let(:mode){ HrrRbSsh::Transport::Mode::CLIENT }

    describe "#exchange_version" do
      let(:transport){ described_class.new io, mode }
      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      it "sends SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION} || CR || LF" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(io.remote_read 24).to eq (local_version_string + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
      end

      it "receives remote version string and updates v_c" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_s).to eq remote_version_string
      end

      it "updates v_s" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_c).to eq local_version_string
      end

      it "skips data before remote version string" do
        io.remote_write ("initial data" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_s).to eq remote_version_string
      end
    end

    describe "#exchange_key" do
      let(:transport){ described_class.new io, mode }
      let(:remote_kexinit_packet){
        [
          "0000010c" "06145855" "3f58552c" "8ed18b59" \
          "ad2d7ea1" "0d250000" "00366469" "66666965" \
          "2d68656c" "6c6d616e" "2d67726f" "75703134" \
          "2d736861" "312c6469" "66666965" "2d68656c" \
          "6c6d616e" "2d67726f" "7570312d" "73686131" \
          "0000000f" "7373682d" "7273612c" "7373682d" \
          "64737300" "00001561" "65733132" "382d6362" \
          "632c6165" "73323536" "2d636263" "00000015" \
          "61657331" "32382d63" "62632c61" "65733235" \
          "362d6362" "63000000" "12686d61" "632d7368" \
          "61312c68" "6d61632d" "6d643500" "00001268" \
          "6d61632d" "73686131" "2c686d61" "632d6d64" \
          "35000000" "1a6e6f6e" "652c7a6c" "6962406f" \
          "70656e73" "73682e63" "6f6d2c7a" "6c696200" \
          "00001a6e" "6f6e652c" "7a6c6962" "406f7065" \
          "6e737368" "2e636f6d" "2c7a6c69" "62000000" \
          "00000000" "00000000" "00000000" "00000000"
        ].pack("H*")
      }
      let(:remote_kexinit_payload){
        [
          "1458553f" "58552c8e" "d18b59ad" "2d7ea10d" \
          "25000000" "36646966" "6669652d" "68656c6c" \
          "6d616e2d" "67726f75" "7031342d" "73686131" \
          "2c646966" "6669652d" "68656c6c" "6d616e2d" \
          "67726f75" "70312d73" "68613100" "00000f73" \
          "73682d72" "73612c73" "73682d64" "73730000" \
          "00156165" "73313238" "2d636263" "2c616573" \
          "3235362d" "63626300" "00001561" "65733132" \
          "382d6362" "632c6165" "73323536" "2d636263" \
          "00000012" "686d6163" "2d736861" "312c686d" \
          "61632d6d" "64350000" "0012686d" "61632d73" \
          "6861312c" "686d6163" "2d6d6435" "0000001a" \
          "6e6f6e65" "2c7a6c69" "62406f70" "656e7373" \
          "682e636f" "6d2c7a6c" "69620000" "001a6e6f" \
          "6e652c7a" "6c696240" "6f70656e" "7373682e" \
          "636f6d2c" "7a6c6962" "00000000" "00000000" \
          "00000000" "00"
        ].pack("H*")
      }

      it "sends kexinit" do
        io.remote_write remote_kexinit_packet
        transport.exchange_key
        io.remote_read 4  # skip packet length field
        io.remote_read 1  # skip padding length field
        expect(io.remote_read 1).to eq [20].pack("C")
      end

      it "updates i_s" do
        io.remote_write remote_kexinit_packet
        transport.exchange_key
        expect(transport.i_s).to eq remote_kexinit_payload
      end

      it "updates i_c" do
        io.remote_write remote_kexinit_packet
        transport.exchange_key
        i_c = StringIO.new transport.i_c, 'r'
        expect(i_c.read(1).unpack("C")[0]).to eq 20
        16.times do
          expect(i_c.read(1).unpack("C")[0]).to be_between(0x00, 0xff).inclusive
        end
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::KexAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::EncryptionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::EncryptionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::MacAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::MacAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::CompressionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq HrrRbSsh::Transport::CompressionAlgorithm.name_list
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq []
        expect(HrrRbSsh::Transport::DataType::NameList.decode i_c).to eq []
        expect(HrrRbSsh::Transport::DataType::Boolean.decode i_c).to eq false
        expect(HrrRbSsh::Transport::DataType::Uint32.decode i_c).to eq 0
        expect(i_c.read).to eq ""
      end
    end
  end
end
