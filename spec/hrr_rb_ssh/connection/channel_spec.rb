# coding: utf-8
# vim: et ts=2 sw=2

RSpec.describe HrrRbSsh::Connection::Channel do
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
  let(:channel){ described_class.new(connection, channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size) }

  describe '.new' do
    it "takes six arguments: connection, channel_type, local_channel, remote_channel, initial_window_size, maximum_packet_size" do
      expect { channel }.not_to raise_error
    end

    it "initializes receive_queue readable" do
      expect(channel.receive_queue).to be_an_instance_of ::Queue
      expect(channel.receive_queue.size).to eq 0
    end
  end

  describe "#start" do
    it "calls #channel_loop_thread" do
      expect(channel).to receive(:channel_loop_thread).with(no_args).once
      channel.start
    end

    it "calls #io_threads" do
      expect(channel).to receive(:io_threads).with(no_args).once
      channel.start
    end

    it "calls #proc_chain_thread" do
      expect(channel).to receive(:proc_chain_thread).with(no_args).once
      channel.start
    end
  end

  describe '#channel_loop_thread' do
    context "when channel receives channel request" do
      let(:channel_request_message){
        {
          "SSH_MSG_CHANNEL_REQUEST" => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          "recipient channel"       => 0,
          "request type"            => 'shell',
          "want reply"              => want_reply,
        }
      }
      let(:variables){ Hash.new }

      let(:channel_success_message){
        {
          "SSH_MSG_CHANNEL_SUCCESS" => HrrRbSsh::Message::SSH_MSG_CHANNEL_SUCCESS::VALUE,
          "recipient channel"       => 0,
        }
      }
      let(:channel_success_payload){
        HrrRbSsh::Message::SSH_MSG_CHANNEL_SUCCESS.encode channel_success_message
      }

      context "with want reply true" do
        let(:want_reply){ true }

        before :example do
          channel.receive_queue.enq channel_request_message
          channel.receive_queue.close
        end

        it "calls #request and returns channel success" do
          expect(channel).to receive(:request).with(channel_request_message, variables).once
          expect(connection).to receive(:send).with(channel_success_payload).once
          t = channel.channel_loop_thread
          t.join
        end
      end

      context "with want reply false" do
        let(:want_reply){ false }

        before :example do
          channel.receive_queue.enq channel_request_message
          channel.receive_queue.close
        end

        it "calls #request and returns channel success" do
          expect(channel).to receive(:request).with(channel_request_message, variables).once
          t = channel.channel_loop_thread
          t.join
        end
      end
    end

    context "when channel receives channel data" do
      let(:channel_data_message){
        {
          "SSH_MSG_CHANNEL_DATA" => HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE,
          "recipient channel"    => 0,
          "data"                 => "testing",
        }
      }

      before :example do
        channel.receive_queue.enq channel_data_message
        channel.receive_queue.close
      end

      it "enqueues data into @receive_data" do
        t = channel.channel_loop_thread
        t.join
        expect(channel.instance_variable_get('@receive_data').deq).to be channel_data_message['data']
      end
    end
  end

  describe '#io_threads' do
    let(:send_data){ 'send data' }
    let(:receive_data){ 'receive data' }

    let(:channel_data_message){
      {
        'SSH_MSG_CHANNEL_DATA' => HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE,
        'recipient channel'    => 0,
        'data'                 => send_data,
      }
    }
    let(:channel_data_payload){
      HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA.encode channel_data_message
    }

    before :example do
      channel.instance_variable_get('@request_handler_io').write send_data
      channel.instance_variable_get('@receive_data').enq receive_data
    end

    it "starts two threads using UNIX socket pair to bridge to request handler" do
      expect(connection).to receive(:send).with(channel_data_payload).once
      threads = channel.io_threads
      expect(channel.instance_variable_get('@request_handler_io').recv(12)).to eq receive_data
      channel.instance_variable_get('@receive_data').close
      channel.instance_variable_get('@request_handler_io').close
      threads.each(&:join)
      channel.instance_variable_get('@channel_io').close
    end
  end

  describe '#proc_chain_thread' do
    it "calls @proc_chain.call_next with no arguments" do
      expect(channel.instance_variable_get('@proc_chain')).to receive(:call_next).with(no_args).once
      t = channel.proc_chain_thread
      t.join
    end
  end

  describe "#request" do
    let(:channel_request_message){
      {
        "SSH_MSG_CHANNEL_REQUEST" => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
        "recipient channel"       => 0,
        "request type"            => 'shell',
        "want reply"              => true,
      }
    }
    let(:variables){ Hash.new }
    let(:arguments){
      [
        channel.instance_variable_get('@proc_chain'),
        channel.instance_variable_get('@username'),
        channel.instance_variable_get('@request_handler_io'),
        variables,
        channel_request_message,
        channel.instance_variable_get('@connection').options,
      ]
    }

    it "calls @@type_list['session']['shell'].run" do
      expect(HrrRbSsh::Connection::Channel::Session::Shell).to receive(:run).with(*arguments).once
      channel.request(channel_request_message, variables)
    end
  end
end
