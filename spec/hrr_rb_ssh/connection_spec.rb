# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection do
  describe '.new' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }

    it "can take one argument: authentication" do
      expect { described_class.new(authentication) }.not_to raise_error
    end

    it "can take two arguments: authentication and options" do
      expect { described_class.new(authentication, options) }.not_to raise_error
    end
  end

  describe '#send' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }
    let(:payload){ "testing" }

    context "when connection is closed" do
      before :example do
        connection.instance_variable_set('@closed', true)
      end

      it "raises ClosedConnectionError" do
        expect { connection.send payload }.to raise_error HrrRbSsh::ClosedConnectionError
      end
    end

    context "when connection is not closed, but authentication is closed" do
      before :example do
        connection.instance_variable_set('@closed', false)
        authentication.instance_variable_set('@closed', true)
      end

      it "raises ClosedConnectionError" do
        expect { connection.send payload }.to raise_error HrrRbSsh::ClosedConnectionError
      end
    end

    context "when connection and authentication are not closed" do
      before :example do
        connection.instance_variable_set('@closed', false)
        authentication.instance_variable_set('@closed', false)
      end

      it "calls authentication.send" do
        expect(transport).to receive(:send).with(payload).once
        connection.send payload
      end
    end
  end

  describe '#assign_channel' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    context "when @channels is empty" do
      it "returns 0" do
        expect(connection.assign_channel).to eq 0
      end
    end

    context "when @channels has 0" do
      before :example do
        connection.instance_variable_get('@channels')[0] = 'dummy channel'
      end

      it "returns 1" do
        expect(connection.assign_channel).to eq 1
      end
    end

    context "when @channels has 1" do
      before :example do
        connection.instance_variable_get('@channels')[1] = 'dummy channel'
      end

      it "returns 0" do
        expect(connection.assign_channel).to eq 0
      end
    end
  end

  describe '#start' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    it "calls authentication.start and connection_loop" do
      expect(authentication).to receive(:start).with(no_args).once
      expect(connection).to receive(:connection_loop).with(no_args).once
      connection.start
    end
  end

  describe '#close' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }
    let(:channel0){ double("channel0") }
    let(:channel1){ double("channel1") }
    let(:channels){
      {
        0 => channel0,
        1 => channel1,
      }
    }

    before :example do
      connection.instance_variable_set('@channels', channels)
    end

    context "when connection is not closed" do
      before :example do
        connection.instance_variable_set('@closed', false)
      end

      it "closes channels" do
        expect(channel0).to receive(:close).with(no_args).once
        expect(channel1).to receive(:close).with(no_args).once
        connection.close
      end

      it "does not raise error even though channel.close raises some error" do
        expect(channel0).to receive(:close).with(no_args).once
        expect(channel1).to receive(:close).with(no_args).and_raise(RuntimeError).once
        expect { connection.close }.not_to raise_error
      end

      it "clears channels" do
        expect(channel0).to receive(:close).with(no_args).once
        expect(channel1).to receive(:close).with(no_args).and_raise(RuntimeError).once
        connection.close
        expect(channels).to eq( {} )
      end
    end
  end

  describe '#closed?' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    context "when connection is closed" do
      before :example do
        connection.instance_variable_set('@closed', true)
      end

      it "returns true" do
        expect(connection.closed?).to be true
      end
    end

    context "when connection is not closed" do
      before :example do
        connection.instance_variable_set('@closed', false)
      end

      it "returns false" do
        expect(connection.closed?).to be false
      end
    end
  end

  describe '#connection_loop' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    context "when receives global request message" do
      let(:global_request_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_GLOBAL_REQUEST::VALUE,
          :'request name'   => 'dummy',
          :'want reply'     => true,
        }
      }
      let(:global_request_payload){
        HrrRbSsh::Message::SSH_MSG_GLOBAL_REQUEST.encode global_request_message
      }

      it "calls global_request and sends resuest failure" do
        expect(authentication).to receive(:receive).with(no_args).and_return(global_request_payload).once
        expect(authentication).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedAuthenticationError).once
        expect(connection).to receive(:global_request).with(global_request_payload).once
        expect(connection).to receive(:close).with(no_args).once
        connection.connection_loop
      end
    end

    context "when receives channel open message" do
      let(:channel_open_message){
        {
          :'message number'      => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::VALUE,
          :'channel type'        => "session",
          :'sender channel'      => 0,
          :'initial window size' => 2097152,
          :'maximum packet size' => 32768,
        }
      }
      let(:channel_open_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN.encode channel_open_message
      }

      it "calls channel_open" do
        expect(authentication).to receive(:receive).with(no_args).and_return(channel_open_payload).once
        expect(authentication).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedAuthenticationError).once
        expect(connection).to receive(:channel_open).with(channel_open_payload).once
        expect(connection).to receive(:close).with(no_args).once
        connection.connection_loop
      end
    end

    context "when receives channel open confirmation message" do
      let(:channel_open_confirmation_message){
        {
          :'message number'      => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION::VALUE,
          :'channel type'        => "forwarded-tcpip",
          :'sender channel'      => 0,
          :'recipient channel'   => 0,
          :'initial window size' => 2097152,
          :'maximum packet size' => 32768,
        }
      }
      let(:channel_open_confirmation_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION.encode channel_open_confirmation_message
      }

      it "calls channel_open_confirmation" do
        expect(authentication).to receive(:receive).with(no_args).and_return(channel_open_confirmation_payload).once
        expect(authentication).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedAuthenticationError).once
        expect(connection).to receive(:channel_open_confirmation).with(channel_open_confirmation_payload).once
        expect(connection).to receive(:close).with(no_args).once
        connection.connection_loop
      end
    end

    context "when receives channel request message" do
      let(:channel_request_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel' => 0,
          :'request type'      => 'shell',
          :'want reply'        => true,
        }
      }
      let(:channel_request_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST.encode channel_request_message
      }

      it "calls channel_request" do
        expect(authentication).to receive(:receive).with(no_args).and_return(channel_request_payload).once
        expect(authentication).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedAuthenticationError).once
        expect(connection).to receive(:channel_request).with(channel_request_payload).once
        expect(connection).to receive(:close).with(no_args).once
        connection.connection_loop
      end
    end

    context "when receives channel window adjust message" do
      let(:channel_window_adjust_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE,
          :'recipient channel' => 0,
          :'bytes to add'      => 12345,
        }
      }
      let(:channel_window_adjust_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST.encode channel_window_adjust_message
      }

      it "calls channel_window_adjust" do
        expect(authentication).to receive(:receive).with(no_args).and_return(channel_window_adjust_payload).once
        expect(authentication).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedAuthenticationError).once
        expect(connection).to receive(:channel_window_adjust).with(channel_window_adjust_payload).once
        expect(connection).to receive(:close).with(no_args).once
        connection.connection_loop
      end
    end

    context "when receives channel data message" do
      let(:channel_data_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE,
          :'recipient channel' => 0,
          :'data'              => "testing",
        }
      }
      let(:channel_data_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA.encode channel_data_message
      }

      it "calls channel_data" do
        expect(authentication).to receive(:receive).with(no_args).and_return(channel_data_payload).once
        expect(authentication).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedAuthenticationError).once
        expect(connection).to receive(:channel_data).with(channel_data_payload).once
        expect(connection).to receive(:close).with(no_args).once
        connection.connection_loop
      end
    end

    context "when receives channel eof message" do
      let(:channel_eof_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF::VALUE,
          :'recipient channel' => 0,
        }
      }
      let(:channel_eof_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF.encode channel_eof_message
      }

      let(:channel0){ double('channel0') }
      let(:channel0_receive_message_queue){ double('channel0_receive_message_queue') }

      before :example do
        connection.instance_variable_get('@channels')[0] = channel0
      end

      it "calls channel_eof" do
        expect(authentication).to receive(:receive).with(no_args).and_return(channel_eof_payload).once
        expect(authentication).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedAuthenticationError).once
        expect(connection).to receive(:channel_eof).with(channel_eof_payload).once
        expect(connection).to receive(:close).with(no_args).once
        connection.connection_loop
      end
    end

    context "when receives channel close message" do
      let(:channel_close_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE::VALUE,
          :'recipient channel' => 0,
        }
      }
      let(:channel_close_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE.encode channel_close_message
      }

      it "calls channel_close" do
        expect(authentication).to receive(:receive).with(no_args).and_return(channel_close_payload).once
        expect(authentication).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedAuthenticationError).once
        expect(connection).to receive(:channel_close).with(channel_close_payload).once
        expect(connection).to receive(:close).with(no_args).once
        connection.connection_loop
      end
    end

    context "when receives unknown message" do
      let(:unknown_message){
        {
          :'message number'      => 123,
          :'channel type'        => "session",
          :'sender channel'      => 0,
          :'initial window size' => 2097152,
          :'maximum packet size' => 32768,
        }
      }
      let(:unknown_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN.encode unknown_message
      }

      it "does nothing" do
        expect(authentication).to receive(:receive).with(no_args).and_return(unknown_payload).once
        expect(authentication).to receive(:receive).with(no_args).and_raise(HrrRbSsh::ClosedAuthenticationError).once
        expect(connection).to receive(:close).with(no_args).once
        connection.connection_loop
      end
    end
  end

  describe '#global_request' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    context "when receives supported global request message" do
      let(:global_request_message){
        {
          :'message number'      => HrrRbSsh::Message::SSH_MSG_GLOBAL_REQUEST::VALUE,
          :'request name'        => 'tcpip-forward',
          :'want reply'          => true,
          :'address to bind'     => 'localhost',
          :'port number to bind' => 12345,
        }
      }
      let(:global_request_payload){
        HrrRbSsh::Message::SSH_MSG_GLOBAL_REQUEST.encode global_request_message
      }
      let(:request_success_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_REQUEST_SUCCESS::VALUE,
        }
      }
      let(:request_success_payload){
        HrrRbSsh::Message::SSH_MSG_REQUEST_SUCCESS.encode request_success_message
      }

      it "calls global_request" do
        expect(connection.instance_variable_get('@global_request_handler')).to receive(:request).with(global_request_message).once
        expect(authentication).to receive(:send).with(request_success_payload).once
        connection.global_request global_request_payload
      end
    end

    context "when receives unsupported global request message" do
      let(:global_request_message){
        {
          :'message number'      => HrrRbSsh::Message::SSH_MSG_GLOBAL_REQUEST::VALUE,
          :'request name'        => 'unsupported',
          :'want reply'          => true,
        }
      }
      let(:global_request_payload){
        HrrRbSsh::Message::SSH_MSG_GLOBAL_REQUEST.encode global_request_message
      }
      let(:request_failure_message){
        {
          :'message number' => HrrRbSsh::Message::SSH_MSG_REQUEST_FAILURE::VALUE,
        }
      }
      let(:request_failure_payload){
        HrrRbSsh::Message::SSH_MSG_REQUEST_FAILURE.encode request_failure_message
      }

      it "calls global_request" do
        expect(authentication).to receive(:send).with(request_failure_payload).once
        connection.global_request global_request_payload
      end
    end
  end

  describe '#channel_open_start' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }
    let(:address){ 'localhost' }
    let(:port){ 12345 }
    let(:remote_address){ double('mock remote_address') }
    let(:socket){ double('mock socket') }

    let(:channel_open_message){
      {
        :'message number'             => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::VALUE,
        :'channel type'               => "forwarded-tcpip",
        :'sender channel'             => 0,
        :'initial window size'        => HrrRbSsh::Connection::Channel::INITIAL_WINDOW_SIZE,
        :'maximum packet size'        => HrrRbSsh::Connection::Channel::MAXIMUM_PACKET_SIZE,
        :'address that was connected' => address,
        :'port that was connected'    => port,
        :'originator IP address'      => socket.remote_address.ip_address,
        :'originator port'            => socket.remote_address.ip_port, 
      }
    }
    let(:channel_open_payload){
      HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN.encode channel_open_message
    }

    it "calls send_channel_open" do
      expect(remote_address).to receive(:ip_address).and_return(address).twice
      expect(remote_address).to receive(:ip_port).and_return(port).twice
      expect(socket).to receive(:remote_address).and_return(remote_address).exactly(4).times
      expect(authentication).to receive(:send).with(channel_open_payload).once
      connection.channel_open_start address, port, socket
      expect(connection.instance_variable_get('@channels')).to include(channel_open_message[:'sender channel'])
    end
  end

  describe '#channel_open' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    context "when receives valid channel open message" do
      let(:channel_open_message){
        {
          :'message number'      => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::VALUE,
          :'channel type'        => "session",
          :'sender channel'      => 0,
          :'initial window size' => 2097152,
          :'maximum packet size' => 32768,
        }
      }
      let(:channel_open_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN.encode channel_open_message
      }
      let(:channel_open_confirmation_message){
        {
          :'message number'      => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION::VALUE,
          :'channel type'        => "session",
          :'recipient channel'   => 0,
          :'sender channel'      => 0,
          :'initial window size' => HrrRbSsh::Connection::Channel::INITIAL_WINDOW_SIZE,
          :'maximum packet size' => HrrRbSsh::Connection::Channel::MAXIMUM_PACKET_SIZE,
        }
      }
      let(:channel_open_confirmation_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION.encode channel_open_confirmation_message
      }

      it "calls channel_open" do
        expect(authentication).to receive(:send).with(channel_open_confirmation_payload).once
        connection.channel_open channel_open_payload
        expect(connection.instance_variable_get('@channels')).to include(channel_open_message[:'sender channel'])
      end
    end
  end

  describe '#channel_open_confirmation' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    context "when receives valid channel open confirmation message" do
      let(:channel_open_confirmation_message){
        {
          :'message number'      => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION::VALUE,
          :'recipient channel'   => 0,
          :'sender channel'      => 0,
          :'initial window size' => HrrRbSsh::Connection::Channel::INITIAL_WINDOW_SIZE,
          :'maximum packet size' => HrrRbSsh::Connection::Channel::MAXIMUM_PACKET_SIZE,
        }
      }
      let(:channel_open_confirmation_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN_CONFIRMATION.encode channel_open_confirmation_message
      }

      let(:channel){ double('mock channel') }

      before :example do
        connection.instance_variable_get('@channels')[0] = channel
      end

      it "updates channel and starts channel" do
        expect(channel).to receive(:set_remote_parameters).with(channel_open_confirmation_message).once
        expect(channel).to receive(:start).with(no_args).once
        connection.channel_open_confirmation channel_open_confirmation_payload
      end
    end
  end

  describe '#channel_request' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    context "when receives valid channel request message" do
      let(:channel_request_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel' => 0,
          :'request type'      => 'shell',
          :'want reply'        => true,
        }
      }
      let(:channel_request_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST.encode channel_request_message
      }

      let(:channel){ double('channel') }
      let(:receive_message_queue){ Queue.new }

      before :example do
        connection.instance_variable_get('@channels')[0] = channel
      end

      it "calls channel_request" do
        allow(channel).to receive(:receive_message_queue).and_return(receive_message_queue)
        connection.channel_request channel_request_payload
        expect(connection.instance_variable_get('@channels')[0].receive_message_queue.pop).to eq channel_request_message
      end
    end
  end

  describe '#channel_window_adjust' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    context "when receives valid channel window adjust message" do
      let(:channel_window_adjust_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE,
          :'recipient channel' => 0,
          :'bytes to add'      => 12345,
        }
      }
      let(:channel_window_adjust_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST.encode channel_window_adjust_message
      }

      let(:channel){ double('channel') }
      let(:receive_message_queue){ Queue.new }

      before :example do
        connection.instance_variable_get('@channels')[0] = channel
      end

      it "calls channel_window_adjust" do
        allow(channel).to receive(:receive_message_queue).and_return(receive_message_queue)
        connection.channel_window_adjust channel_window_adjust_payload
        expect(connection.instance_variable_get('@channels')[0].receive_message_queue.pop).to eq channel_window_adjust_message
      end
    end
  end

  describe '#channel_data' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    context "when receives valid channel data message" do
      let(:channel_data_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE,
          :'recipient channel' => 0,
          :'data'              => "testing",
        }
      }
      let(:channel_data_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA.encode channel_data_message
      }

      let(:channel){ double('channel') }
      let(:receive_message_queue){ Queue.new }

      before :example do
        connection.instance_variable_get('@channels')[0] = channel
      end

      it "calls channel_data" do
        allow(channel).to receive(:receive_message_queue).and_return(receive_message_queue)
        connection.channel_data channel_data_payload
        expect(connection.instance_variable_get('@channels')[0].receive_message_queue.pop).to eq channel_data_message
      end
    end
  end

  describe '#channel_eof' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    let(:channel0){ double('channel0') }
    let(:channel0_receive_message_queue){ double('channel0_receive_message_queue') }

    before :example do
      connection.instance_variable_get('@channels')[0] = channel0
    end

    context "when receives valid channel eof message" do
      let(:channel_eof_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF::VALUE,
          :'recipient channel' => 0,
        }
      }
      let(:channel_eof_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF.encode channel_eof_message
      }

      it "eofs the channel and delete the channel from channels" do
        expect(channel0).to receive(:receive_message_queue).with(no_args).and_return(channel0_receive_message_queue).once
        expect(channel0_receive_message_queue).to receive(:close).with(no_args).once
        connection.channel_eof channel_eof_payload
      end
    end
  end

  describe '#channel_close' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }
    let(:channel0){ double("channel0") }
    let(:channel1){ double("channel1") }
    let(:channels){
      {
        0 => channel0,
        1 => channel1,
      }
    }

    before :example do
      connection.instance_variable_set('@channels', channels)
    end

    context "when receives valid channel close message" do
      let(:channel_close_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE::VALUE,
          :'recipient channel' => 0,
        }
      }
      let(:channel_close_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE.encode channel_close_message
      }

      it "closes the channel and delete the channel from channels" do
        expect(channel0).to receive(:close).with(no_args).once
        connection.channel_close channel_close_payload
        expect(channels).to eq( { 1 => channel1 } )
      end
    end
  end

  describe '#send_request_success' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ described_class.new authentication, options }

    let(:request_success_message){
      {
        :'message number' => HrrRbSsh::Message::SSH_MSG_REQUEST_SUCCESS::VALUE,
      }
    }
    let(:request_success_payload){
      HrrRbSsh::Message::SSH_MSG_REQUEST_SUCCESS.encode request_success_message
    }

    it "calls global_request" do
      expect(authentication).to receive(:send).with(request_success_payload).once
      connection.send_request_success
    end
  end
end
