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

    it "can take two arguments: io and mode" do
      expect { transport }.not_to raise_error
    end

    context "when options is specified" do
      context "when options has valid algorithm list" do
        it "can take three arguments: io, mode, and options" do
          expect { described_class.new io, mode, {}, logger: nil }.not_to raise_error
        end
      end

      context "when options has invalid algorithm list" do
        it "raises ArgumentError" do
          expect { described_class.new io, mode, {'transport_preferred_mac_algorithms' => ['invalid algorithm']} }.to raise_error ArgumentError
        end
      end
    end

    it "initializes incoming_sequence_number readable" do
      expect(transport.incoming_sequence_number).to be_an_instance_of HrrRbSsh::Transport::SequenceNumber
      expect(transport.incoming_sequence_number.sequence_number).to eq 0
    end

    it "initializes outgoing_sequence_number readable" do
      expect(transport.outgoing_sequence_number).to be_an_instance_of HrrRbSsh::Transport::SequenceNumber
      expect(transport.outgoing_sequence_number.sequence_number).to eq 0
    end

    it "initializes server_host_key_algorithm readable" do
      expect(transport.server_host_key_algorithm).to be nil
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

    it "initializes i_c readable" do
      expect(transport.i_c).to be nil
    end

    it "initializes i_s readable" do
      expect(transport.i_s).to be nil
    end
  end

  describe "supported_encryption_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::EncryptionAlgorithm.list_supported" do
      expect(transport.supported_encryption_algorithms).to eq HrrRbSsh::Transport::EncryptionAlgorithm.list_supported
    end
  end

  describe "supported_server_host_key_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported" do
      expect(transport.supported_server_host_key_algorithms).to eq HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported
    end
  end

  describe "supported_kex_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::KexAlgorithm.list_supported" do
      expect(transport.supported_kex_algorithms).to eq HrrRbSsh::Transport::KexAlgorithm.list_supported
    end
  end

  describe "supported_mac_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::MacAlgorithm.list_supported" do
      expect(transport.supported_mac_algorithms).to eq HrrRbSsh::Transport::MacAlgorithm.list_supported
    end
  end

  describe "supported_compression_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::CompressionAlgorithm.list_supported" do
      expect(transport.supported_compression_algorithms).to eq HrrRbSsh::Transport::CompressionAlgorithm.list_supported
    end
  end

  describe "preferred_encryption_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred" do
      expect(transport.preferred_encryption_algorithms).to eq HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred
    end
  end

  describe "preferred_server_host_key_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred" do
      expect(transport.preferred_server_host_key_algorithms).to eq HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred
    end
  end

  describe "preferred_kex_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::KexAlgorithm.list_preferred" do
      expect(transport.preferred_kex_algorithms).to eq HrrRbSsh::Transport::KexAlgorithm.list_preferred
    end
  end

  describe "preferred_mac_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::MacAlgorithm.list_preferred" do
      expect(transport.preferred_mac_algorithms).to eq HrrRbSsh::Transport::MacAlgorithm.list_preferred
    end
  end

  describe "preferred_compression_algorithms" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }

    it "returns HrrRbSsh::Transport::CompressionAlgorithm.list_preferred" do
      expect(transport.preferred_compression_algorithms).to eq HrrRbSsh::Transport::CompressionAlgorithm.list_preferred
    end
  end

  describe "#send" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }
    let(:mock_sender){ double("mock sender") }
    let(:payload){ "testing" }

    before :example do
      transport.instance_variable_set('@sender', mock_sender)
    end

    context "when sender can send payload" do
      it "sends payload" do
        expect(mock_sender).to receive(:send).with(transport, payload)
        expect(transport.send payload).to be nil
      end
    end

    context "when sender raises Errno::EPIPE error" do
      it "closes transport and raises HrrRbSsh::Error::ClosedTransport" do
        expect(mock_sender).to receive(:send).with(transport, payload).and_raise(Errno::EPIPE)
        expect(transport).to receive(:close).with(no_args)
        expect { transport.send payload }.to raise_error HrrRbSsh::Error::ClosedTransport
      end
    end

    context "when sender raises unexpected error" do
      it "closes transport and raises HrrRbSsh::Error::ClosedTransport" do
        expect(mock_sender).to receive(:send).with(transport, payload).and_raise(RuntimeError)
        expect(transport).to receive(:close).with(no_args)
        expect { transport.send payload }.to raise_error HrrRbSsh::Error::ClosedTransport
      end
    end
  end

  describe "#receive" do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ described_class.new io, mode }
    let(:mock_receiver){ double("mock receiver") }
    let(:payload){ "testing" }

    before :example do
      transport.instance_variable_set('@receiver', mock_receiver)
    end

    context "when transport is closed" do
      before :example do
        transport.instance_variable_set('@closed', true)
      end

      it "raises HrrRbSsh::Error::ClosedTransport" do
        expect { transport.receive }.to raise_error HrrRbSsh::Error::ClosedTransport
      end
    end

    context "when transport is not closed" do
      before :example do
        transport.instance_variable_set('@closed', false)
      end

      context "when receives disconnect message" do
        let(:disconnect_message){
          {
            :'message number' => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::VALUE,
            :'reason code'    => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_BY_APPLICATION,
            :'description'    => 'disconnected by user',
            :'language tag'   => '',
          }
        }
        let(:disconnect_payload){
          HrrRbSsh::Messages::SSH_MSG_DISCONNECT.new.encode disconnect_message
        }

        it "closes transport and raises Error::ClosedTransport" do
          expect(mock_receiver).to receive(:receive).with(transport).and_return(disconnect_payload).once
          expect(transport).to receive(:close).with(no_args)
          expect { transport.receive }.to raise_error HrrRbSsh::Error::ClosedTransport
        end
      end

      context "when receives ignore message and then some message" do
        let(:ignore_message){
          {
            :'message number' => HrrRbSsh::Messages::SSH_MSG_IGNORE::VALUE,
            :'data'           => 'ignored',
          }
        }
        let(:ignore_payload){
          HrrRbSsh::Messages::SSH_MSG_IGNORE.new.encode ignore_message
        }

        it "ignores message" do
          expect(mock_receiver).to receive(:receive).with(transport).and_return(ignore_payload).once
          expect(mock_receiver).to receive(:receive).with(transport).and_return(payload).once
          expect(transport.receive).to eq payload
        end
      end

      context "when receives unimplemented message and then some message" do
        let(:unimplemented_message){
          {
            :'message number'                             => HrrRbSsh::Messages::SSH_MSG_UNIMPLEMENTED::VALUE,
            :'packet sequence number of rejected message' => 123,
          }
        }
        let(:unimplemented_payload){
          HrrRbSsh::Messages::SSH_MSG_UNIMPLEMENTED.new.encode unimplemented_message
        }

        it "receives unimplemented message and is finished" do
          expect(mock_receiver).to receive(:receive).with(transport).and_return(unimplemented_payload).once
          expect(mock_receiver).to receive(:receive).with(transport).and_return(payload).once
          expect(transport.receive).to eq payload
        end
      end

      context "when receives debug message and then some message" do
        let(:debug_message){
          {
            :'message number' => HrrRbSsh::Messages::SSH_MSG_DEBUG::VALUE,
            :'always_display' => true,
            :'message'        => 'message',
            :'language tag'   => 'language tag',
          }
        }
        let(:debug_payload){
          HrrRbSsh::Messages::SSH_MSG_DEBUG.new.encode debug_message
        }

        it "receive debug message and is finished" do
          expect(mock_receiver).to receive(:receive).with(transport).and_return(debug_payload).once
          expect(mock_receiver).to receive(:receive).with(transport).and_return(payload).once
          expect(transport.receive).to eq payload
        end
      end

      context "when receives other message" do
        let(:service_request_message){
          {
            :'message number' => HrrRbSsh::Messages::SSH_MSG_SERVICE_REQUEST::VALUE,
            :'service name'   => 'service name',
          }
        }
        let(:service_request_payload){
          HrrRbSsh::Messages::SSH_MSG_SERVICE_REQUEST.new.encode service_request_message
        }

        it "receive service_request message and is finished" do
          expect(mock_receiver).to receive(:receive).with(transport).and_return(service_request_payload).once
          expect(transport.receive).to eq service_request_payload
        end
      end

      context "when @receiver.receive returns EOFError" do
        it "closes transport" do
          expect(mock_receiver).to receive(:receive).with(transport).and_raise(EOFError).once
          expect(transport).to receive(:close).with(no_args)
          expect { transport.receive }.to raise_error HrrRbSsh::Error::ClosedTransport
        end
      end

      context "when @receiver.receive returns IOError" do
        it "closes transport" do
          expect(mock_receiver).to receive(:receive).with(transport).and_raise(IOError).once
          expect(transport).to receive(:close).with(no_args)
          expect { transport.receive }.to raise_error HrrRbSsh::Error::ClosedTransport
        end
      end

      context "when @receiver.receive returns Errno::ECONNRESET" do
        it "closes transport" do
          expect(mock_receiver).to receive(:receive).with(transport).and_raise(Errno::ECONNRESET).once
          expect(transport).to receive(:close).with(no_args)
          expect { transport.receive }.to raise_error HrrRbSsh::Error::ClosedTransport
        end
      end

      context "when @receiver.receive returns RuntimeError" do
        it "closes transport" do
          expect(mock_receiver).to receive(:receive).with(transport).and_raise(RuntimeError).once
          expect(transport).to receive(:close).with(no_args)
          expect { transport.receive }.to raise_error HrrRbSsh::Error::ClosedTransport
        end
      end
    end
  end

  context "when mode is server" do
    let(:io){ MockSocket.new }
    let(:mode){ HrrRbSsh::Mode::SERVER }

    describe "#start" do
      let(:transport){ described_class.new io, mode }

      it "calls #exchange_version, #exchange_key, #verify_service_request" do
        expect(transport).to receive(:exchange_version).with(no_args).once
        expect(transport).to receive(:exchange_key).with(no_args).once
        expect(transport).to receive(:verify_service_request).with(no_args).once
        transport.start
      end
    end

    describe "#close" do
      let(:transport){ described_class.new io, mode }

      before :example do
        transport.instance_variable_set('@closed', false)
      end

      it "updates @closed with true, and calls disconnect" do
        expect(transport).to receive(:disconnect).with(no_args).once
        transport.close
        expect(transport.instance_variable_get('@closed')).to be true
      end
    end

    describe "#closed?" do
      let(:transport){ described_class.new io, mode }

      context "when opened" do
        before :example do
          transport.instance_variable_set('@closed', false)
        end

        it "returns false" do
          expect(transport.closed?).to be false
        end
      end

      context "when closed" do
        before :example do
          transport.instance_variable_set('@closed', true)
        end

        it "returns true" do
          expect(transport.closed?).to be true
        end
      end
    end

    describe "#disconnect" do
      let(:transport){ described_class.new io, mode }

      let(:disconnect_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::VALUE,
          :'reason code'    => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_BY_APPLICATION,
          :'description'    => "disconnected by user",
          :'language tag'   => ""
        }
      }
      let(:disconnect_payload){
        HrrRbSsh::Messages::SSH_MSG_DISCONNECT.new.encode disconnect_message
      }
      let(:mock_sender  ){ double("mock sender") }

      before :example do
        transport.instance_variable_set('@sender', mock_sender)
      end

      context "when disconnect message can be sent" do
        it "sends disconnect" do
          expect(mock_sender).to receive(:send).with(transport, disconnect_payload).once
          expect { transport.disconnect }.not_to raise_error
        end
      end

      context "when disconnect message can not be sent" do
        it "can not send disconnect" do
          expect(mock_sender).to receive(:send).with(transport, disconnect_payload).and_raise(StandardError).once
          expect { transport.disconnect }.not_to raise_error
        end
      end
    end

    describe "#exchange_version" do
      let(:transport){ described_class.new io, mode }
      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      it "sends SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION} || CR || LF" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        buf = StringIO.new
        10240.times do
          buf.write io.remote_read(1)
          break if buf.string[-2,2] == HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF
        end
        expect(buf.string).to eq (local_version_string + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
      end

      it "receives remote version string and updates v_c" do
        expect(transport.v_c).to be nil
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_c).to eq remote_version_string
      end

      it "updates v_s" do
        expect(transport.v_s).to be nil
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_s).to eq local_version_string
      end

      it "skips data before remote version string" do
        expect(transport.v_c).to be nil
        io.remote_write ("initial data" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_c).to eq remote_version_string
      end
    end

    describe "#exchange_key" do
      let(:transport){ described_class.new io, mode }

      let(:mock_sender  ){ double("mock sender") }
      let(:mock_receiver){ double("mock receiver") }

      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      let(:remote_kexinit_message){
        {
          :'message number'                          => HrrRbSsh::Messages::SSH_MSG_KEXINIT::VALUE,
          :'cookie (random byte)'                    => 0,
          :'kex_algorithms'                          => ["diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1"],
          :'server_host_key_algorithms'              => ["ssh-rsa", "ssh-dss"],
          :'encryption_algorithms_client_to_server'  => ["aes128-cbc", "aes256-cbc"],
          :'encryption_algorithms_server_to_client'  => ["aes128-cbc", "aes256-cbc"],
          :'mac_algorithms_client_to_server'         => ["hmac-sha1", "hmac-md5"],
          :'mac_algorithms_server_to_client'         => ["hmac-sha1", "hmac-md5"],
          :'compression_algorithms_client_to_server' => ["none", "zlib@openssh.com", "zlib"],
          :'compression_algorithms_server_to_client' => ["none", "zlib@openssh.com", "zlib"],
          :'languages_client_to_server'              => [],
          :'languages_server_to_client'              => [],
          :'first_kex_packet_follows'                => false,
          :'0 (reserved for future extension)'       => 0
        }
      }
      let(:remote_kexinit_payload){ HrrRbSsh::Messages::SSH_MSG_KEXINIT.new.encode remote_kexinit_message }
      let(:remote_newkeys_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_NEWKEYS::VALUE,
        }
      }
      let(:remote_newkeys_payload){ HrrRbSsh::Messages::SSH_MSG_NEWKEYS.new.encode remote_newkeys_message }

      before :example do
        transport.instance_variable_set('@sender',   mock_sender)
        transport.instance_variable_set('@receiver', mock_receiver)

        transport.instance_variable_set('@v_c', remote_version_string)
        transport.instance_variable_set('@v_s', local_version_string )
      end

      it "updates i_c and i_s" do
        expect(transport.i_c).to be nil
        expect(transport.i_s).to be nil

        expect(transport).to receive(:start_kex_algorithm).with(no_args).once
        expect(transport).to receive(:update_encryption_mac_compression_algorithms).with(no_args).once
        expect(mock_sender).to   receive(:send).with(transport, anything).exactly(2).times
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload, remote_newkeys_payload).exactly(2).times

        transport.exchange_key

        expect(transport.i_c).to eq remote_kexinit_payload

        i_s = StringIO.new transport.i_s, 'r'
        expect(i_s.read(1).unpack("C")[0]).to eq 20
        16.times do
          expect(i_s.read(1).unpack("C")[0]).to be_between(0x00, 0xff).inclusive
        end
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq HrrRbSsh::Transport::KexAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq HrrRbSsh::Transport::MacAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq HrrRbSsh::Transport::MacAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq HrrRbSsh::Transport::CompressionAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq HrrRbSsh::Transport::CompressionAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq []
        expect(HrrRbSsh::DataTypes::NameList.decode i_s).to eq []
        expect(HrrRbSsh::DataTypes::Boolean.decode i_s).to eq false
        expect(HrrRbSsh::DataTypes::Uint32.decode i_s).to eq 0
        expect(i_s.read).to eq ""
      end

      it "updates kex_algorithm" do
        expect(transport).to receive(:start_kex_algorithm).with(no_args).once
        expect(transport).to receive(:update_encryption_mac_compression_algorithms).with(no_args).once
        expect(mock_sender).to   receive(:send).with(transport, anything).exactly(2).times
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload, remote_newkeys_payload).exactly(2).times

        transport.exchange_key

        expect(transport.server_host_key_algorithm).to be_an_instance_of HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa
        expect(transport.instance_variable_get('@kex_algorithm')).to be_an_instance_of HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup14Sha1
      end
    end

    describe "#start_kex_algorithm" do
      let(:transport){ described_class.new io, mode }
      let(:mock_kex_algorithm){ double('kex algorithm') }

      before :example do
        transport.instance_variable_set('@kex_algorithm', mock_kex_algorithm)
      end

      it "calls kex_algorithm#start" do
        expect(mock_kex_algorithm).to receive(:start).with(transport).once
        transport.start_kex_algorithm
      end
    end

    describe "#update_encryption_mac_compression_algorithms" do
      let(:transport){ described_class.new io, mode }
      let(:mock_kex_algorithm){ double('kex algorithm') }

      let(:hash){ 'dummy hash' }
      let(:iv_c_to_s ){ '1234567890123456'  }
      let(:iv_s_to_c ){ '1234567890123456'  }
      let(:key_c_to_s){ '1234567890123456' }
      let(:key_s_to_c){ '1234567890123456' }
      let(:mac_c_to_s){ '12345678901234567890' }
      let(:mac_s_to_c){ '12345678901234567890' }

      let(:remote_kex_algorithms                         ){ ["diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1"] }
      let(:remote_server_host_key_algorithms             ){ ["ssh-rsa", "ssh-dss"]                                        }
      let(:remote_encryption_algorithms_client_to_server ){ ["aes128-cbc", "aes256-cbc"]                                  }
      let(:remote_encryption_algorithms_server_to_client ){ ["aes128-cbc", "aes256-cbc"]                                  }
      let(:remote_mac_algorithms_client_to_server        ){ ["hmac-sha1", "hmac-md5"]                                     }
      let(:remote_mac_algorithms_server_to_client        ){ ["hmac-sha1", "hmac-md5"]                                     }
      let(:remote_compression_algorithms_client_to_server){ ["none", "zlib@openssh.com", "zlib"]                          }
      let(:remote_compression_algorithms_server_to_client){ ["none", "zlib@openssh.com", "zlib"]                          }

      before :example do
        transport.instance_variable_set('@kex_algorithm', mock_kex_algorithm)
        transport.instance_variable_set('@remote_kex_algorithms',                          remote_kex_algorithms                         )
        transport.instance_variable_set('@remote_server_host_key_algorithms',              remote_server_host_key_algorithms             )
        transport.instance_variable_set('@remote_encryption_algorithms_client_to_server',  remote_encryption_algorithms_client_to_server )
        transport.instance_variable_set('@remote_encryption_algorithms_server_to_client',  remote_encryption_algorithms_server_to_client )
        transport.instance_variable_set('@remote_mac_algorithms_client_to_server',         remote_mac_algorithms_client_to_server        )
        transport.instance_variable_set('@remote_mac_algorithms_server_to_client',         remote_mac_algorithms_server_to_client        )
        transport.instance_variable_set('@remote_compression_algorithms_client_to_server', remote_compression_algorithms_client_to_server)
        transport.instance_variable_set('@remote_compression_algorithms_server_to_client', remote_compression_algorithms_server_to_client)
      end

      it "updates encryption, mac, and compression algorithms" do
        expect(mock_kex_algorithm).to receive(:hash).with(transport).and_return(hash).once

        expect(mock_kex_algorithm).to receive(:iv_c_to_s ).with(transport, 'aes128-cbc').and_return(iv_c_to_s).once
        expect(mock_kex_algorithm).to receive(:iv_s_to_c ).with(transport, 'aes128-cbc').and_return(iv_s_to_c).once
        expect(mock_kex_algorithm).to receive(:key_c_to_s).with(transport, 'aes128-cbc').and_return(key_c_to_s).once
        expect(mock_kex_algorithm).to receive(:key_s_to_c).with(transport, 'aes128-cbc').and_return(key_s_to_c).once
        expect(mock_kex_algorithm).to receive(:mac_c_to_s).with(transport, 'hmac-sha1' ).and_return(mac_c_to_s).once
        expect(mock_kex_algorithm).to receive(:mac_s_to_c).with(transport, 'hmac-sha1' ).and_return(mac_s_to_c).once

        transport.update_encryption_mac_compression_algorithms

        expect(transport.session_id).to be hash

        expect(transport.incoming_encryption_algorithm).to  be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::Aes128Cbc
        expect(transport.outgoing_encryption_algorithm).to  be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::Aes128Cbc
        expect(transport.incoming_mac_algorithm).to         be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::HmacSha1
        expect(transport.outgoing_mac_algorithm).to         be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::HmacSha1
        expect(transport.incoming_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
        expect(transport.outgoing_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
      end
    end

    describe "#verify_service_request" do
      let(:transport){ described_class.new io, mode }

      let(:mock_sender  ){ double("mock sender") }
      let(:mock_receiver){ double("mock receiver") }

      let(:service_request_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_SERVICE_REQUEST::VALUE,
          :'service name'   => 'ssh-userauth',
        }
      }
      let(:service_request_payload){
        HrrRbSsh::Messages::SSH_MSG_SERVICE_REQUEST.new.encode service_request_message
      }

      let(:service_accept_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_SERVICE_ACCEPT::VALUE,
          :'service name'   => 'ssh-userauth',
        }
      }
      let(:service_accept_payload){
        HrrRbSsh::Messages::SSH_MSG_SERVICE_ACCEPT.new.encode service_accept_message
      }

      before :example do
        transport.instance_variable_set('@sender',   mock_sender  )
        transport.instance_variable_set('@receiver', mock_receiver)
      end

      context "when 'ssh-userauth' is registered as acceptable service" do
        let(:acceptable_service){ 'ssh-userauth' }

        it "receives service request and service accept" do
          expect(mock_receiver).to receive(:receive).with(transport).and_return(service_request_payload).once
          expect(mock_sender).to   receive(:send).with(transport, service_accept_payload).once

          transport.register_acceptable_service acceptable_service
          transport.verify_service_request
        end
      end

      context "when 'ssh-userauth' is not registered as acceptable service" do
        let(:disconnect_message){
          {
            :'message number' => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::VALUE,
            :'reason code'        => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_BY_APPLICATION,
            :'description'        => 'disconnected by user',
            :'language tag'       => '',
          }
        }
        let(:disconnect_payload){
          HrrRbSsh::Messages::SSH_MSG_DISCONNECT.new.encode disconnect_message
        }

        before :example do
          transport.instance_variable_set('@closed', false)
          transport.instance_variable_set('@disconnected', false)
        end

        it "receives service request and sends disconnect and close" do
          expect(mock_receiver).to receive(:receive).with(transport).and_return(service_request_payload).once
          expect(mock_sender).to   receive(:send).with(transport, disconnect_payload).once

          transport.verify_service_request
        end
      end
    end
  end

  context "when mode is client" do
    let(:io){ MockSocket.new }
    let(:mode){ HrrRbSsh::Mode::CLIENT }

    describe "#start" do
      let(:transport){ described_class.new io, mode }

      it "calls #exchange_version, #exchange_key, #verify_service_request" do
        expect(transport).to receive(:exchange_version).with(no_args).once
        expect(transport).to receive(:exchange_key).with(no_args).once
        expect(transport).to receive(:send_service_request).with(no_args).once
        transport.start
      end
    end

    describe "#close" do
      let(:transport){ described_class.new io, mode }

      before :example do
        transport.instance_variable_set('@closed', false)
      end

      it "updates @closed with true, and calls disconnect" do
        expect(transport).to receive(:disconnect).with(no_args).once
        transport.close
        expect(transport.instance_variable_get('@closed')).to be true
      end
    end

    describe "#closed?" do
      let(:transport){ described_class.new io, mode }

      context "when opened" do
        before :example do
          transport.instance_variable_set('@closed', false)
        end

        it "returns false" do
          expect(transport.closed?).to be false
        end
      end

      context "when closed" do
        before :example do
          transport.instance_variable_set('@closed', true)
        end

        it "returns true" do
          expect(transport.closed?).to be true
        end
      end
    end

    describe "#disconnect" do
      let(:transport){ described_class.new io, mode }

      let(:disconnect_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::VALUE,
          :'reason code'    => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_BY_APPLICATION,
          :'description'    => "disconnected by user",
          :'language tag'   => ""
        }
      }
      let(:disconnect_payload){
        HrrRbSsh::Messages::SSH_MSG_DISCONNECT.new.encode disconnect_message
      }
      let(:mock_sender  ){ double("mock sender") }

      before :example do
        transport.instance_variable_set('@sender', mock_sender  )
      end

      context "when disconnect message can be sent" do
        it "sends disconnect" do
          expect(mock_sender).to receive(:send).with(transport, disconnect_payload).once
          expect { transport.disconnect }.not_to raise_error
        end
      end

      context "when disconnect message can not be sent" do
        it "can not send disconnect" do
          expect(mock_sender).to receive(:send).with(transport, disconnect_payload).and_raise(RuntimeError).once
          expect { transport.disconnect }.not_to raise_error
        end
      end
    end

    describe "#exchange_version" do
      let(:transport){ described_class.new io, mode }
      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      it "sends SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION} || CR || LF" do
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        buf = StringIO.new
        10240.times do
          buf.write io.remote_read(1)
          break if buf.string[-2,2] == HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF
        end
        expect(buf.string).to eq (local_version_string + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
      end

      it "receives remote version string and updates v_s" do
        expect(transport.v_s).to be nil
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_s).to eq remote_version_string
      end

      it "updates v_c" do
        expect(transport.v_c).to be nil
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_c).to eq local_version_string
      end

      it "skips data before remote version string" do
        expect(transport.v_s).to be nil
        io.remote_write ("initial data" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        io.remote_write ("SSH-2.0-dummy_ssh_1.2.3" + HrrRbSsh::Transport::Constant::CR + HrrRbSsh::Transport::Constant::LF)
        transport.exchange_version
        expect(transport.v_s).to eq remote_version_string
      end
    end

    describe "#exchange_key" do
      let(:transport){ described_class.new io, mode }

      let(:mock_sender  ){ double("mock sender") }
      let(:mock_receiver){ double("mock receiver") }

      let(:local_version_string){ "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}" }
      let(:remote_version_string){ "SSH-2.0-dummy_ssh_1.2.3" }

      let(:remote_kexinit_message){
        {
          :'message number'                          => HrrRbSsh::Messages::SSH_MSG_KEXINIT::VALUE,
          :'cookie (random byte)'                    => 37,
          :'kex_algorithms'                          => ["diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1"],
          :'server_host_key_algorithms'              => ["ssh-rsa", "ssh-dss"],
          :'encryption_algorithms_client_to_server'  => ["aes128-cbc", "aes256-cbc"],
          :'encryption_algorithms_server_to_client'  => ["aes128-cbc", "aes256-cbc"],
          :'mac_algorithms_client_to_server'         => ["hmac-sha1", "hmac-md5"],
          :'mac_algorithms_server_to_client'         => ["hmac-sha1", "hmac-md5"],
          :'compression_algorithms_client_to_server' => ["none", "zlib@openssh.com", "zlib"],
          :'compression_algorithms_server_to_client' => ["none", "zlib@openssh.com", "zlib"],
          :'languages_client_to_server'              => [],
          :'languages_server_to_client'              => [],
          :'first_kex_packet_follows'                => false,
          :'0 (reserved for future extension)'       => 0
        }
      }
      let(:remote_kexinit_payload){ HrrRbSsh::Messages::SSH_MSG_KEXINIT.new.encode remote_kexinit_message }
      let(:remote_newkeys_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_NEWKEYS::VALUE,
        }
      }
      let(:remote_newkeys_payload){ HrrRbSsh::Messages::SSH_MSG_NEWKEYS.new.encode remote_newkeys_message }

      before :example do
        transport.instance_variable_set('@sender',   mock_sender  )
        transport.instance_variable_set('@receiver', mock_receiver)

        transport.instance_variable_set('@v_s', remote_version_string)
        transport.instance_variable_set('@v_c', local_version_string )
      end

      it "updates i_c and i_s" do
        local_kexinit_message = {
          :'message number'                          => HrrRbSsh::Messages::SSH_MSG_KEXINIT::VALUE,
          :'cookie (random byte)'                    => lambda { rand(0x01_00) },
          :'kex_algorithms'                          => ["diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1"],
          :'server_host_key_algorithms'              => ["ssh-rsa", "ssh-dss"],
          :'encryption_algorithms_client_to_server'  => ["aes128-cbc", "aes256-cbc"],
          :'encryption_algorithms_server_to_client'  => ["aes128-cbc", "aes256-cbc"],
          :'mac_algorithms_client_to_server'         => ["hmac-sha1", "hmac-md5"],
          :'mac_algorithms_server_to_client'         => ["hmac-sha1", "hmac-md5"],
          :'compression_algorithms_client_to_server' => ["none", "zlib@openssh.com", "zlib"],
          :'compression_algorithms_server_to_client' => ["none", "zlib@openssh.com", "zlib"],
          :'languages_client_to_server'              => [],
          :'languages_server_to_client'              => [],
          :'first_kex_packet_follows'                => false,
          :'0 (reserved for future extension)'       => 0
        }
        local_kexinit_payload = HrrRbSsh::Messages::SSH_MSG_KEXINIT.new.encode(local_kexinit_message)

        expect(transport.i_c).to be nil
        expect(transport.i_s).to be nil

        expect(transport).to receive(:start_kex_algorithm).with(no_args).once
        expect(transport).to receive(:update_encryption_mac_compression_algorithms).with(no_args).once
        expect(mock_sender).to   receive(:send).with(transport, anything).twice
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload).twice

        transport.exchange_key

        expect(transport.i_s).to eq remote_kexinit_payload

        i_c = StringIO.new transport.i_c, 'r'
        expect(i_c.read(1).unpack("C")[0]).to eq 20
        16.times do
          expect(i_c.read(1).unpack("C")[0]).to be_between(0x00, 0xff).inclusive
        end
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq HrrRbSsh::Transport::KexAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq HrrRbSsh::Transport::MacAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq HrrRbSsh::Transport::MacAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq HrrRbSsh::Transport::CompressionAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq HrrRbSsh::Transport::CompressionAlgorithm.list_preferred
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq []
        expect(HrrRbSsh::DataTypes::NameList.decode i_c).to eq []
        expect(HrrRbSsh::DataTypes::Boolean.decode i_c).to eq false
        expect(HrrRbSsh::DataTypes::Uint32.decode i_c).to eq 0
        expect(i_c.read).to eq ""
      end

      it "updates kex_algorithm" do
        expect(transport).to receive(:start_kex_algorithm).with(no_args).once
        expect(transport).to receive(:update_encryption_mac_compression_algorithms).with(no_args).once
        expect(mock_sender).to   receive(:send).with(transport, anything).twice
        expect(mock_receiver).to receive(:receive).with(transport).with(transport).and_return(remote_kexinit_payload).twice

        transport.exchange_key

        expect(transport.server_host_key_algorithm).to be_an_instance_of HrrRbSsh::Transport::ServerHostKeyAlgorithm::SshRsa
        expect(transport.instance_variable_get('@kex_algorithm')).to be_an_instance_of HrrRbSsh::Transport::KexAlgorithm::DiffieHellmanGroup14Sha1
      end
    end

    describe "#start_kex_algorithm" do
      let(:transport){ described_class.new io, mode }
      let(:mock_kex_algorithm){ double('kex algorithm') }

      before :example do
        transport.instance_variable_set('@kex_algorithm', mock_kex_algorithm)
      end

      it "calls kex_algorithm#start" do
        expect(mock_kex_algorithm).to receive(:start).with(transport).once
        transport.start_kex_algorithm
      end
    end

    describe "#update_encryption_mac_compression_algorithms" do
      let(:transport){ described_class.new io, mode }
      let(:mock_kex_algorithm){ double('kex algorithm') }

      let(:hash){ 'dummy hash' }
      let(:iv_c_to_s ){ '1234567890123456'  }
      let(:iv_s_to_c ){ '1234567890123456'  }
      let(:key_c_to_s){ '1234567890123456' }
      let(:key_s_to_c){ '1234567890123456' }
      let(:mac_c_to_s){ '12345678901234567890' }
      let(:mac_s_to_c){ '12345678901234567890' }

      let(:remote_kex_algorithms                         ){ ["diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1"] }
      let(:remote_server_host_key_algorithms             ){ ["ssh-rsa", "ssh-dss"]                                        }
      let(:remote_encryption_algorithms_client_to_server ){ ["aes128-cbc", "aes256-cbc"]                                  }
      let(:remote_encryption_algorithms_server_to_client ){ ["aes128-cbc", "aes256-cbc"]                                  }
      let(:remote_mac_algorithms_client_to_server        ){ ["hmac-sha1", "hmac-md5"]                                     }
      let(:remote_mac_algorithms_server_to_client        ){ ["hmac-sha1", "hmac-md5"]                                     }
      let(:remote_compression_algorithms_client_to_server){ ["none", "zlib@openssh.com", "zlib"]                          }
      let(:remote_compression_algorithms_server_to_client){ ["none", "zlib@openssh.com", "zlib"]                          }

      before :example do
        transport.instance_variable_set('@kex_algorithm',                                  mock_kex_algorithm                            )
        transport.instance_variable_set('@remote_kex_algorithms',                          remote_kex_algorithms                         )
        transport.instance_variable_set('@remote_server_host_key_algorithms',              remote_server_host_key_algorithms             )
        transport.instance_variable_set('@remote_encryption_algorithms_client_to_server',  remote_encryption_algorithms_client_to_server )
        transport.instance_variable_set('@remote_encryption_algorithms_server_to_client',  remote_encryption_algorithms_server_to_client )
        transport.instance_variable_set('@remote_mac_algorithms_client_to_server',         remote_mac_algorithms_client_to_server        )
        transport.instance_variable_set('@remote_mac_algorithms_server_to_client',         remote_mac_algorithms_server_to_client        )
        transport.instance_variable_set('@remote_compression_algorithms_client_to_server', remote_compression_algorithms_client_to_server)
        transport.instance_variable_set('@remote_compression_algorithms_server_to_client', remote_compression_algorithms_server_to_client)
      end

      it "updates encryption, mac, and compression algorithms" do
        expect(mock_kex_algorithm).to receive(:hash).with(transport).and_return(hash).once

        expect(mock_kex_algorithm).to receive(:iv_c_to_s ).with(transport, 'aes128-cbc').and_return(iv_c_to_s).once
        expect(mock_kex_algorithm).to receive(:iv_s_to_c ).with(transport, 'aes128-cbc').and_return(iv_s_to_c).once
        expect(mock_kex_algorithm).to receive(:key_c_to_s).with(transport, 'aes128-cbc').and_return(key_c_to_s).once
        expect(mock_kex_algorithm).to receive(:key_s_to_c).with(transport, 'aes128-cbc').and_return(key_s_to_c).once
        expect(mock_kex_algorithm).to receive(:mac_c_to_s).with(transport, 'hmac-sha1' ).and_return(mac_c_to_s).once
        expect(mock_kex_algorithm).to receive(:mac_s_to_c).with(transport, 'hmac-sha1' ).and_return(mac_s_to_c).once

        transport.update_encryption_mac_compression_algorithms

        expect(transport.session_id).to be hash

        expect(transport.incoming_encryption_algorithm).to  be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::Aes128Cbc
        expect(transport.outgoing_encryption_algorithm).to  be_an_instance_of HrrRbSsh::Transport::EncryptionAlgorithm::Aes128Cbc
        expect(transport.incoming_mac_algorithm).to         be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::HmacSha1
        expect(transport.outgoing_mac_algorithm).to         be_an_instance_of HrrRbSsh::Transport::MacAlgorithm::HmacSha1
        expect(transport.incoming_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
        expect(transport.outgoing_compression_algorithm).to be_an_instance_of HrrRbSsh::Transport::CompressionAlgorithm::None
      end
    end

    describe "#send_service_request" do
      let(:transport){ described_class.new io, mode }

      let(:mock_sender  ){ double("mock sender") }
      let(:mock_receiver){ double("mock receiver") }

      let(:service_request_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_SERVICE_REQUEST::VALUE,
          :'service name'   => 'ssh-userauth',
        }
      }
      let(:service_request_payload){
        HrrRbSsh::Messages::SSH_MSG_SERVICE_REQUEST.new.encode service_request_message
      }

      let(:service_accept_message){
        {
          :'message number' => HrrRbSsh::Messages::SSH_MSG_SERVICE_ACCEPT::VALUE,
          :'service name'   => 'ssh-userauth',
        }
      }
      let(:service_accept_payload){
        HrrRbSsh::Messages::SSH_MSG_SERVICE_ACCEPT.new.encode service_accept_message
      }

      before :example do
        transport.instance_variable_set('@sender',   mock_sender  )
        transport.instance_variable_set('@receiver', mock_receiver)
      end

      context "when 'ssh-userauth' is accepted" do
        it "sends service request and receives service accept" do
          expect(mock_sender).to   receive(:send).with(transport, service_request_payload).once
          expect(mock_receiver).to receive(:receive).with(transport).and_return(service_accept_payload).once

          transport.send_service_request
        end
      end

      context "when 'ssh-userauth' is not accepted" do
        let(:disconnect_message){
          {
            :'message number' => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::VALUE,
            :'reason code'    => HrrRbSsh::Messages::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_BY_APPLICATION,
            :'description'    => 'disconnected by user',
            :'language tag'   => '',
          }
        }
        let(:disconnect_payload){
          HrrRbSsh::Messages::SSH_MSG_DISCONNECT.new.encode disconnect_message
        }

        before :example do
          transport.instance_variable_set('@closed',       false)
        end

        it "sends service request and receives disconnect and close" do
          expect(mock_sender).to   receive(:send).with(transport, service_request_payload).once
          expect(mock_receiver).to receive(:receive).with(transport).and_return(disconnect_payload).once

          transport.send_service_request
        end
      end
    end
  end
end
