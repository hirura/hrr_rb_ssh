# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::ChannelType::ForwardedTcpip do
  let(:name){ 'forwarded-tcpip' }
  let(:io){ 'dummy' }
  let(:mode){ 'dummy' }
  let(:transport){ HrrRbSsh::Transport.new io, mode }
  let(:authentication){ HrrRbSsh::Authentication.new transport }
  let(:options){ Hash.new }
  let(:connection){ HrrRbSsh::Connection.new authentication, options }
  let(:channel_type){ "forwarded-tcpip" }
  let(:remote_channel){ 0 }
  let(:address){ '127.0.0.1' }
  let(:port){ '12345' }
  let(:originator_IP_address){ '192.168.0.1' }
  let(:originator_port){ '54321' }

  let(:channel){ HrrRbSsh::Connection::Channel.new(connection, {:'channel type' => "forwarded-tcpip"}, socket) }
  let(:channel_open_message){
    {
      :'message number'             => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::VALUE,
      :'channel type'               => channel_type,
      :'sender channel'             => remote_channel,
      :'initial window size'        => HrrRbSsh::Connection::Channel::INITIAL_WINDOW_SIZE,
      :'maximum packet size'        => HrrRbSsh::Connection::Channel::MAXIMUM_PACKET_SIZE,
      :'address that was connected' => address,
      :'port that was connected'    => port,
      :'originator IP address'      => originator_IP_address,
      :'originator port'            => originator_port,
    }
  }
  let(:channel_type_instance){ channel.instance_variable_get('@channel_type_instance') }

  it "can be looked up in HrrRbSsh::Connection::Channel::ChannelType dictionary" do
    expect( HrrRbSsh::Connection::Channel::ChannelType[name] ).to be described_class
  end

  describe '#start' do
    let(:socket_pair){ UNIXSocket.pair }
    let(:socket){ socket_pair[0] }
    let(:socket_remote){ socket_pair[1] }

    after :example do
      channel_type_instance.instance_variable_get('@sender_thread').exit
      channel_type_instance.instance_variable_get('@receiver_thread').exit
      begin
        channel_type_instance.instance_variable_get('@socket').close
      rescue IOError # for compatibility for Ruby version < 2.3
        Thread.pass
      end
      socket_pair.each{ |s|
        begin
          s.close
        rescue IOError # for compatibility for Ruby version < 2.3
          Thread.pass
        end
      }
    end

    it "starts sender and receiver threads" do
      allow(channel.instance_variable_get('@w_io_out')).to receive(:write).with(any_args)
      allow(channel.instance_variable_get('@r_io_in' )).to receive(:readpartial).with(any_args).and_return('dummy')
      channel_type_instance.start
      expect(channel_type_instance.instance_variable_get('@socket').closed?).to be false
      expect(channel_type_instance.instance_variable_get('@sender_thread').alive?).to be true
      expect(channel_type_instance.instance_variable_get('@receiver_thread').alive?).to be true
    end
  end

  describe '#close' do
    let(:socket_pair){ UNIXSocket.pair }
    let(:socket){ socket_pair[0] }
    let(:socket_remote){ socket_pair[1] }

    before :example do
      channel_type_instance.start
    end
    after :example do
      channel_type_instance.instance_variable_get('@sender_thread').exit
      channel_type_instance.instance_variable_get('@receiver_thread').exit
      begin
        channel_type_instance.instance_variable_get('@socket').close
      rescue IOError # for compatibility for Ruby version < 2.3
        Thread.pass
      end
      socket_pair.each{ |s|
        begin
          s.close
        rescue IOError # for compatibility for Ruby version < 2.3
          Thread.pass
        end
      }
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
