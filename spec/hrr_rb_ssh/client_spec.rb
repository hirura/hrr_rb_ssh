RSpec.describe HrrRbSsh::Client do
  describe '.new' do
    let(:address){ '0.0.0.0' }
    let(:port){ 22 }
    let(:username){ 'username' }
    let(:options){ Hash.new }
    let(:tcpsocket){ 'tcpsocket' }
    let(:transport){ double('transport') }
    let(:authentication){ double('authentication') }
    let(:connection){ double('connection') }

    it "must take at least one argument: address" do
      options['username'] = nil
      options['authentication_preferred_authentication_methods'] = nil
      options['client_authentication_password']                  = nil
      options['client_authentication_publickey']                 = nil
      options['client_authentication_keyboard_interactive']      = nil
      options['transport_preferred_encryption_algorithms']       = nil
      options['transport_preferred_server_host_key_algorithms']  = nil
      options['transport_preferred_kex_algorithms']              = nil
      options['transport_preferred_mac_algorithms']              = nil
      options['transport_preferred_compression_algorithms']      = nil

      expect(TCPSocket).to receive(:new).with(address, port).and_return(tcpsocket)
      expect(HrrRbSsh::Transport).to receive(:new).with(tcpsocket, HrrRbSsh::Mode::CLIENT, options, logger: nil).and_return(transport)
      expect(HrrRbSsh::Authentication).to receive(:new).with(transport, HrrRbSsh::Mode::CLIENT, options, logger: nil).and_return(authentication)
      expect(HrrRbSsh::Connection).to receive(:new).with(authentication, HrrRbSsh::Mode::CLIENT, options, logger: nil).and_return(connection)
      expect { described_class.new([address, port]) }.not_to raise_error
    end

    it "can take optional arguments" do
      options['username'] = username
      options['authentication_preferred_authentication_methods'] = nil
      options['client_authentication_password']                  = nil
      options['client_authentication_publickey']                 = nil
      options['client_authentication_keyboard_interactive']      = nil
      options['transport_preferred_encryption_algorithms']       = nil
      options['transport_preferred_server_host_key_algorithms']  = nil
      options['transport_preferred_kex_algorithms']              = nil
      options['transport_preferred_mac_algorithms']              = nil
      options['transport_preferred_compression_algorithms']      = nil

      expect(TCPSocket).to receive(:new).with(address, port).and_return(tcpsocket)
      expect(HrrRbSsh::Transport).to receive(:new).with(tcpsocket, HrrRbSsh::Mode::CLIENT, options, logger: nil).and_return(transport)
      expect(HrrRbSsh::Authentication).to receive(:new).with(transport, HrrRbSsh::Mode::CLIENT, options, logger: nil).and_return(authentication)
      expect(HrrRbSsh::Connection).to receive(:new).with(authentication, HrrRbSsh::Mode::CLIENT, options, logger: nil).and_return(connection)
      expect { described_class.new([address, port], username: username) }.not_to raise_error
    end
  end
end
