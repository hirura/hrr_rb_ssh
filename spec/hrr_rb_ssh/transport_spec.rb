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
  end
end
