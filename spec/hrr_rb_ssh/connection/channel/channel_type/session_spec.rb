# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel::ChannelType::Session do
  let(:name){ 'session' }
  let(:io){ 'dummy' }
  let(:mode){ HrrRbSsh::Mode::SERVER }
  let(:transport){ HrrRbSsh::Transport.new io, mode }
  let(:authentication){ HrrRbSsh::Authentication.new transport, mode }
  let(:options){ Hash.new }
  let(:connection){ HrrRbSsh::Connection.new authentication, mode, options }
  let(:channel_type){ "session" }
  let(:remote_channel){ 0 }
  let(:initial_window_size){ 2097152 }
  let(:maximum_packet_size){ 32768 }
  let(:channel_open_message){
    {
      :'message number'      => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::VALUE,
      :'channel type'        => channel_type,
      :'sender channel'      => remote_channel,
      :'initial window size' => initial_window_size,
      :'maximum packet size' => maximum_packet_size,
    }
  }
  let(:channel){ HrrRbSsh::Connection::Channel.new(connection, channel_open_message) }
  let(:session){ channel.instance_variable_get('@channel_type_instance') }

  it "can be looked up in HrrRbSsh::Connection::Channel::ChannelType dictionary" do
    expect( HrrRbSsh::Connection::Channel::ChannelType[name] ).to be described_class
  end

  describe '#start' do
    it "calls proc_chain_thread" do
      expect(session).to receive(:proc_chain_thread).with(no_args).once
      session.start
    end
  end

  describe '#close' do
    let('mock_proc_chain_thread'){ double('proc chain thread') }
    before :example do
      session.instance_variable_set('@proc_chain_thread', mock_proc_chain_thread)
    end

    it "finishes proc_chain_thread" do
      expect(mock_proc_chain_thread).to receive(:exit).with(no_args).once
      session.close
    end
  end

  describe '#proc_chain_thread' do
    context "when no error occurs" do
      it "calls @proc_chain.call_next with no arguments, and closes itself" do
        expect(session.instance_variable_get('@proc_chain')).to receive(:call_next).with(no_args).and_return(0).once
        expect(channel).to receive(:close).with(:channel_type_instance, 0).once
        t = session.proc_chain_thread
        t.join
      end
    end

    context "when error occurs" do
      it "closes itself as well" do
        expect(session.instance_variable_get('@proc_chain')).to receive(:call_next).with(no_args).and_raise(RuntimeError).once
        expect(channel).to receive(:close).with(:channel_type_instance, 1).once
        t = session.proc_chain_thread
        t.join
      end
    end
  end

  describe "#request" do
    let(:request_type){ 'shell' }
    let(:channel_request_message){
      {
        :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
        :'recipient channel' => 0,
        :'request type'      => request_type,
        :'want reply'        => true,
      }
    }
    let(:variables){ Hash.new }
    let(:arguments){
      [
        session.instance_variable_get('@proc_chain'),
        session.instance_variable_get('@connection').username,
        session.instance_variable_get('@channel').io,
        session.instance_variable_get('@variables'),
        channel_request_message,
        session.instance_variable_get('@connection').options,
        session,
      ]
    }

    it "calls RequestType['shell'].run" do
      expect(HrrRbSsh::Connection::Channel::ChannelType::Session::RequestType::Shell).to receive(:run).with(*arguments).once
      session.request(channel_request_message)
    end
  end
end
