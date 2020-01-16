# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::ChannelType::DirectTcpip do
  let(:name){ 'direct-tcpip' }
  let(:io){ 'dummy' }
  let(:mode){ HrrRbSsh::Mode::SERVER }
  let(:transport){ HrrRbSsh::Transport.new io, mode }
  let(:authentication){ HrrRbSsh::Authentication.new transport, mode }
  let(:options){ Hash.new }
  let(:connection){ HrrRbSsh::Connection.new authentication, mode, options, logger: nil }
  let(:channel_type){ "direct-tcpip" }
  let(:remote_channel){ 0 }
  let(:initial_window_size){ 2097152 }
  let(:maximum_packet_size){ 32768 }
  let(:host_to_connect){ '127.0.0.1' }
  let(:port_to_connect){ '12345' }
  let(:originator_IP_address){ '192.168.0.1' }
  let(:originator_port){ '54321' }

  let(:channel_open_message){
    {
      :'message number'        => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::VALUE,
      :'channel type'          => channel_type,
      :'sender channel'        => remote_channel,
      :'initial window size'   => initial_window_size,
      :'maximum packet size'   => maximum_packet_size,
      :'host to connect'       => host_to_connect,
      :'port to connect'       => port_to_connect,
      :'originator IP address' => originator_IP_address,
      :'originator port'       => originator_port,
    }
  }
  let(:channel){ HrrRbSsh::Connection::Channel.new(connection, channel_open_message) }
  let(:channel_type_instance){ channel.instance_variable_get('@channel_type_instance') }

  it "can be looked up in HrrRbSsh::Connection::Channel::ChannelType dictionary" do
    expect( HrrRbSsh::Connection::Channel::ChannelType[name] ).to be described_class
  end

  describe '#start' do
    let(:server){ TCPServer.new(port_to_connect) }
    before :example do
      server
    end
    after :example do
      channel_type_instance.instance_variable_get('@sender_thread').exit
      channel_type_instance.instance_variable_get('@receiver_thread').exit
      channel_type_instance.instance_variable_get('@socket').close
      server.close
    end

    it "starts a tcp socket and starts sender and receiver threads" do
      allow(channel.instance_variable_get('@w_io_out')).to receive(:write).with(any_args)
      allow(channel.instance_variable_get('@r_io_in' )).to receive(:readpartial).with(any_args).and_return('dummy')
      channel_type_instance.start
      expect(channel_type_instance.instance_variable_get('@socket').closed?).to be false
      expect(channel_type_instance.instance_variable_get('@sender_thread').alive?).to be true
      expect(channel_type_instance.instance_variable_get('@receiver_thread').alive?).to be true
    end
  end

  describe '#close' do
    let(:server){ TCPServer.new(port_to_connect) }
    before :example do
      server
      channel_type_instance.start
    end
    after :example do
      channel_type_instance.instance_variable_get('@sender_thread').exit
      channel_type_instance.instance_variable_get('@receiver_thread').exit
      server.close
    end

    it "finishes the threads and the socket, and calls channel#close" do
      allow(channel.instance_variable_get('@w_io_out')).to receive(:write).with(any_args)
      allow(channel.instance_variable_get('@r_io_in' )).to receive(:readpartial).with(any_args).and_return('dummy')
      allow(channel).to receive(:close).with(:channel_type_instance)
      channel_type_instance.instance_variable_set('@sender_thread_finished', true)
      channel_type_instance.instance_variable_set('@receiver_thread_finished', true)
      channel_type_instance.close
      channel_type_instance.instance_variable_get('@sender_thread').exit
      channel_type_instance.instance_variable_get('@receiver_thread').exit
      channel_type_instance.instance_variable_get('@sender_thread').join
      channel_type_instance.instance_variable_get('@receiver_thread').join
      expect(channel_type_instance.instance_variable_get('@sender_thread').alive?).to be false
      expect(channel_type_instance.instance_variable_get('@receiver_thread').alive?).to be false
    end
  end
end
