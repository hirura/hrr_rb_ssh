# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel do
  describe '.new' do
    let(:io){ 'dummy' }
    let(:mode){ 'dummy' }
    let(:transport){ HrrRbSsh::Transport.new io, mode }
    let(:authentication){ HrrRbSsh::Authentication.new transport }
    let(:options){ Hash.new }
    let(:connection){ HrrRbSsh::Connection.new authentication, options }
    let(:channel_type){ "session" }
    let(:local_channel){ 0 }
    let(:remote_channel){ 0 }
    let(:initial_window_size){ 2097152 }
    let(:maximum_packet_size){ 32768 }

    it "takes six arguments: connection, channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size" do
      expect { described_class.new(connection, channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size) }.not_to raise_error
    end
  end
end
