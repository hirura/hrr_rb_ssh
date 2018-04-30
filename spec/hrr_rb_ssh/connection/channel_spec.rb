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
  let(:channel_open_message){
    {
      :'message number'      => HrrRbSsh::Message::SSH_MSG_CHANNEL_OPEN::VALUE,
      :'channel type'        => channel_type,
      :'sender channel'      => remote_channel,
      :'initial window size' => initial_window_size,
      :'maximum packet size' => maximum_packet_size,
    }
  }
  let(:channel){ described_class.new(connection, channel_open_message) }

  describe '::INITIAL_WINDOW_SIZE' do
    it "is defined" do
      expect(described_class::INITIAL_WINDOW_SIZE).to be > 0
    end
  end

  describe '::MAXIMUM_PACKET_SIZE' do
    it "is defined" do
      expect(described_class::MAXIMUM_PACKET_SIZE).to be > 0
    end
  end

  describe '.new' do
    it "takes two arguments: connection, channel_open_message" do
      expect { channel }.not_to raise_error
    end

    it "initializes receive_message_queue readable" do
      expect(channel.receive_message_queue).to be_an_instance_of ::Queue
      expect(channel.receive_message_queue.size).to eq 0
    end

    it "instantiate an instance of ChannelType" do
      expect(channel.instance_variable_get('@channel_type_instance')).to be_an_instance_of HrrRbSsh::Connection::Channel::ChannelType::Session
    end
  end

  describe "#start" do
    let(:mock_channel_type_instance){ double('channel type instance') }

    before :example do
      channel.instance_variable_set('@channel_type_instance', mock_channel_type_instance)
    end

    it "starts threads and becomes not closed" do
      expect(channel).to receive(:channel_loop_thread).with(no_args).once
      expect(channel).to receive(:out_sender_thread).with(no_args).once
      expect(channel).to receive(:err_sender_thread).with(no_args).once
      expect(channel).to receive(:receiver_thread).with(no_args).once
      expect(mock_channel_type_instance).to receive(:start).with(no_args).once
      channel.start
      expect(channel.instance_variable_get('@closed')).to be false
    end
  end

  describe "#close" do
    context "when closed" do
      before :example do
        channel.instance_variable_set('@closed', true)
      end

      it "does nothing" do
        expect { channel.close }.not_to raise_error
      end
    end

    context "when not closed" do
      before :example do
        channel.instance_variable_set('@closed', false)
      end

      context "from channel_type_instance" do
        context "when connection is not closed" do
          let(:channel_eof_message){
            {
              :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF::VALUE,
              :'recipient channel' => 0,
            }
          }
          let(:channel_eof_payload){
            HrrRbSsh::Message::SSH_MSG_CHANNEL_EOF.encode channel_eof_message
          }
          let(:channel_request_exit_status_message){
            {
              :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
              :'recipient channel' => 0,
              :'request type'      => 'exit-status',
              :'want reply'        => false,
              :'exit status'       => exitstatus,
            }
          }
          let(:channel_request_exit_status_payload){
            HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST.encode channel_request_exit_status_message
          }
          let(:channel_close_message){
            {
              :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE::VALUE,
              :'recipient channel' => 0,
            }
          }
          let(:channel_close_payload){
            HrrRbSsh::Message::SSH_MSG_CHANNEL_CLOSE.encode channel_close_message
          }

          context "when exit-status is an instance of Integer" do
            let(:exitstatus){ 0 }
            it "updates closed with true, closes queues and IOs, and send EOF, exit-status, and CLOSE" do
              expect(connection).to receive(:send).with(channel_eof_payload).once
              expect(connection).to receive(:send).with(channel_request_exit_status_payload).once
              expect(connection).to receive(:send).with(channel_close_payload).once
              channel.close from=:channel_type_instance, exitstatus
              expect(channel.instance_variable_get('@closed')).to be true
              expect(channel.instance_variable_get('@receive_message_queue').closed?).to be true
              expect(channel.instance_variable_get('@receive_data_queue').closed?).to be true
              expect(channel.instance_variable_get('@r_io_in' ).closed?).to be true
              expect(channel.instance_variable_get('@w_io_in' ).closed?).to be true
              expect(channel.instance_variable_get('@r_io_out').closed?).to be true
              expect(channel.instance_variable_get('@w_io_out').closed?).to be true
              expect(channel.instance_variable_get('@r_io_err').closed?).to be true
              expect(channel.instance_variable_get('@w_io_err').closed?).to be true
            end
          end

          context "when exit-status is not an instance of Integer" do
            let(:exitstatus){ 'string' }
            it "updates closed with true, closes queues and IOs, and send EOF, exit-status, and CLOSE" do
              expect(connection).to receive(:send).with(channel_eof_payload).once
              expect(connection).to receive(:send).with(channel_close_payload).once
              channel.close from=:channel_type_instance, exitstatus
              expect(channel.instance_variable_get('@closed')).to be true
              expect(channel.instance_variable_get('@receive_message_queue').closed?).to be true
              expect(channel.instance_variable_get('@receive_data_queue').closed?).to be true
              expect(channel.instance_variable_get('@r_io_in' ).closed?).to be true
              expect(channel.instance_variable_get('@w_io_in' ).closed?).to be true
              expect(channel.instance_variable_get('@r_io_out').closed?).to be true
              expect(channel.instance_variable_get('@w_io_out').closed?).to be true
              expect(channel.instance_variable_get('@r_io_err').closed?).to be true
              expect(channel.instance_variable_get('@w_io_err').closed?).to be true
            end
          end
        end

        context "when connection is closed" do
          it "updates closed with true, closes queues and IOs, and send EOF and CLOSE" do
            expect(channel).to receive(:send_channel_eof).with(no_args).and_raise(HrrRbSsh::ClosedConnectionError).once
            expect { channel.close from=:channel_type_instance }.not_to raise_error
            expect(channel.instance_variable_get('@closed')).to be true
            expect(channel.instance_variable_get('@receive_message_queue').closed?).to be true
            expect(channel.instance_variable_get('@receive_data_queue').closed?).to be true
            expect(channel.instance_variable_get('@r_io_in' ).closed?).to be true
            expect(channel.instance_variable_get('@w_io_in' ).closed?).to be true
            expect(channel.instance_variable_get('@r_io_out').closed?).to be true
            expect(channel.instance_variable_get('@w_io_out').closed?).to be true
            expect(channel.instance_variable_get('@r_io_err').closed?).to be true
            expect(channel.instance_variable_get('@w_io_err').closed?).to be true
          end
        end

        context "when send raises unexpected error" do
          it "updates closed with true, closes queues and IOs, and send EOF and CLOSE" do
            expect(channel).to receive(:send_channel_eof).with(no_args).and_raise(RuntimeError).once
            expect { channel.close from=:channel_type_instance }.not_to raise_error
            expect(channel.instance_variable_get('@closed')).to be true
            expect(channel.instance_variable_get('@receive_message_queue').closed?).to be true
            expect(channel.instance_variable_get('@receive_data_queue').closed?).to be true
            expect(channel.instance_variable_get('@r_io_in' ).closed?).to be true
            expect(channel.instance_variable_get('@w_io_in' ).closed?).to be true
            expect(channel.instance_variable_get('@r_io_out').closed?).to be true
            expect(channel.instance_variable_get('@w_io_out').closed?).to be true
            expect(channel.instance_variable_get('@r_io_err').closed?).to be true
            expect(channel.instance_variable_get('@w_io_err').closed?).to be true
          end
        end
      end

      context "from others" do
        context "when connection is not closed" do
          let(:mock_channel_type_instance){ double('channel type instance') }

          before :example do
            channel.instance_variable_set('@channel_type_instance', mock_channel_type_instance)
          end

          it "updates closed with true, closes queues and IOs, and send EOF and CLOSE" do
            expect(channel).to receive(:send_channel_close).with(no_args).once
            expect(mock_channel_type_instance).to receive(:close).with(no_args).once
            channel.close
            expect(channel.instance_variable_get('@closed')).to be true
            expect(channel.instance_variable_get('@receive_message_queue').closed?).to be true
            expect(channel.instance_variable_get('@receive_data_queue').closed?).to be true
            expect(channel.instance_variable_get('@r_io_in' ).closed?).to be true
            expect(channel.instance_variable_get('@w_io_in' ).closed?).to be true
            expect(channel.instance_variable_get('@r_io_out').closed?).to be true
            expect(channel.instance_variable_get('@w_io_out').closed?).to be true
            expect(channel.instance_variable_get('@r_io_err').closed?).to be true
            expect(channel.instance_variable_get('@w_io_err').closed?).to be true
          end
        end
      end
    end
  end

  describe '#closed?' do
    context "when channel is closed" do
      before :example do
        channel.instance_variable_set('@closed', true)
      end

      it "returns true" do
        expect(channel.closed?).to be true
      end
    end

    context "when channel is not closed" do
      before :example do
        channel.instance_variable_set('@closed', false)
      end

      it "returns false" do
        expect(channel.closed?).to be false
      end
    end
  end

  describe '#channel_loop_thread' do
    context "when channel receives channel request" do
      context "when request is supported" do
        let(:channel_request_message){
          {
            :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
            :'recipient channel' => 0,
            :'request type'      => 'shell',
            :'want reply'        => want_reply,
          }
        }

        let(:channel_success_message){
          {
            :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_SUCCESS::VALUE,
            :'recipient channel' => 0,
          }
        }
        let(:channel_success_payload){
          HrrRbSsh::Message::SSH_MSG_CHANNEL_SUCCESS.encode channel_success_message
        }

        context "with want reply true" do
          let(:want_reply){ true }

          before :example do
            channel.receive_message_queue.enq channel_request_message
          end

          it "calls #request and returns channel success" do
            expect(channel.instance_variable_get('@channel_type_instance')).to receive(:request).with(channel_request_message).once
            expect(connection).to receive(:send).with(channel_success_payload).once
            allow(connection).to receive(:send).with(any_args)
            t = channel.channel_loop_thread
            channel.receive_message_queue.close
            channel.close
            t.join
          end
        end

        context "with want reply false" do
          let(:want_reply){ false }

          before :example do
            channel.receive_message_queue.enq channel_request_message
          end

          it "calls #request and returns channel success" do
            expect(channel.instance_variable_get('@channel_type_instance')).to receive(:request).with(channel_request_message).once
            allow(connection).to receive(:send).with(any_args)
            t = channel.channel_loop_thread
            channel.receive_message_queue.close
            channel.close
            t.join
          end
        end
      end

      context "when request is not supported" do
        let(:channel_request_message){
          {
            :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
            :'recipient channel' => 0,
            :'request type'      => 'unsupported',
            :'want reply'        => want_reply,
          }
        }

        let(:channel_failure_message){
          {
            :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_FAILURE::VALUE,
            :'recipient channel' => 0,
          }
        }
        let(:channel_failure_payload){
          HrrRbSsh::Message::SSH_MSG_CHANNEL_FAILURE.encode channel_failure_message
        }

        context "with want reply true" do
          let(:want_reply){ true }

          before :example do
            channel.receive_message_queue.enq channel_request_message
          end

          it "calls #request and returns channel failure" do
            expect(channel.instance_variable_get('@channel_type_instance')).to receive(:request).with(channel_request_message).and_raise(NoMethodError, "undefined method `new' for nil:NilClass").once
            expect(connection).to receive(:send).with(channel_failure_payload).once
            allow(connection).to receive(:send).with(any_args)
            t = channel.channel_loop_thread
            channel.receive_message_queue.close
            channel.close
            t.join
          end
        end

        context "with want reply false" do
          let(:want_reply){ false }

          before :example do
            channel.receive_message_queue.enq channel_request_message
          end

          it "calls #request and returns channel success" do
            expect(channel.instance_variable_get('@channel_type_instance')).to receive(:request).with(channel_request_message).once
            allow(connection).to receive(:send).with(any_args)
            t = channel.channel_loop_thread
            channel.receive_message_queue.close
            channel.close
            t.join
          end
        end
      end
    end

    context "when channel receives channel data" do
      let(:channel_data_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE,
          :'recipient channel' => 0,
          :'data'              => "testing",
        }
      }

      before :example do
        channel.receive_message_queue.enq channel_data_message
      end

      it "enqueues data into @receive_data" do
        allow(connection).to receive(:send).with(any_args)
        t = channel.channel_loop_thread
        expect(channel.instance_variable_get('@receive_data_queue').deq).to be channel_data_message[:'data']
        channel.receive_message_queue.close
        channel.close
        t.join
      end
    end

    context "when channel receives channel window adjust" do
      let(:channel_window_adjust_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE,
          :'recipient channel' => 0,
          :'bytes to add'      => 12345,
        }
      }

      before :example do
        channel.receive_message_queue.enq channel_window_adjust_message
      end

      it "updates remote window size" do
        allow(connection).to receive(:send).with(any_args)
        t = channel.channel_loop_thread
        channel.receive_message_queue.close
        channel.close
        t.join
        expect(channel.instance_variable_get('@remote_window_size')).to eq (2097152 + 12345)
      end
    end

    context "when channel receives unknown message" do
      let(:unknown_message){
        {
          "UNKNOWN_MESSAGE" => 123,
        }
      }

      before :example do
        channel.receive_message_queue.enq unknown_message
      end

      it "do nothing" do
        allow(connection).to receive(:send).with(any_args)
        t = channel.channel_loop_thread
        channel.receive_message_queue.close
        channel.close
        t.join
      end
    end

    context "when error occurs" do
      let(:channel_data_message){
        {
          :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE,
          :'recipient channel' => 0,
          :'data'              => "testing",
        }
      }

      before :example do
        channel.instance_variable_get('@receive_data_queue').close
        channel.receive_message_queue.enq channel_data_message
        channel.receive_message_queue.close
      end

      it "enqueues data into @receive_data_queue" do
        expect(channel).to receive(:close).with(:channel_loop_thread).once
        t = channel.channel_loop_thread
        expect { t.join }.not_to raise_error
      end
    end
  end

  describe '#out_sender_thread' do
    let(:send_data){ 'send data' }

    let(:channel_data_message){
      {
        :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA::VALUE,
        :'recipient channel' => 0,
        :'data'              => send_data,
      }
    }
    let(:channel_data_payload){
      HrrRbSsh::Message::SSH_MSG_CHANNEL_DATA.encode channel_data_message
    }

    before :example do
      channel.instance_variable_set('@closed', false)
      channel.instance_variable_get('@w_io_out').write send_data
    end

    context "when no error occurs" do
      it "receives data from UNIX socket pair and send the data, and updates remote window size" do
        expect(connection).to receive(:send).with(channel_data_payload).once
        allow(channel).to receive(:send_channel_eof).with(no_args).once
        allow(channel).to receive(:send_channel_close).with(no_args).once
        t = channel.out_sender_thread
        channel.instance_variable_get('@w_io_out').close
        t.join
        expect(channel.closed?).to be false
        channel.close
        expect(channel.closed?).to be true
        expect(channel.instance_variable_get('@remote_window_size')).to eq (2097152 - send_data.size)
      end
    end

    context "when IOError occurs" do
      it "receives data from UNIX socket pair and send the data" do
        expect(connection).to receive(:send).with(channel_data_payload).and_raise(IOError).once
        allow(channel).to receive(:send_channel_eof).with(no_args).once
        allow(channel).to receive(:send_channel_close).with(no_args).once
        t = channel.out_sender_thread
        t.join
        expect(channel.closed?).to be true
      end
    end

    context "when unexpected error occurs" do
      it "closes itself" do
        expect(channel).to receive(:send_channel_data).with(send_data).and_raise(RuntimeError).once
        t = channel.out_sender_thread
        t.join
        expect(channel.closed?).to be true
      end
    end
  end

  describe '#err_sender_thread' do
    let(:send_data){ 'send err data' }

    let(:channel_extended_data_message){
      {
        :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_EXTENDED_DATA::VALUE,
        :'recipient channel' => 0,
        :'data type code'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_EXTENDED_DATA::DataTypeCode::SSH_EXTENDED_DATA_STDERR,
        :'data'              => send_data,
      }
    }
    let(:channel_extended_data_payload){
      HrrRbSsh::Message::SSH_MSG_CHANNEL_EXTENDED_DATA.encode channel_extended_data_message
    }

    before :example do
      channel.instance_variable_set('@closed', false)
      channel.instance_variable_get('@w_io_err').write send_data
    end

    context "when no error occurs" do
      it "receives data from UNIX socket pair and send the data, and updates remote window size" do
        expect(connection).to receive(:send).with(channel_extended_data_payload).once
        allow(channel).to receive(:send_channel_eof).with(no_args).once
        allow(channel).to receive(:send_channel_close).with(no_args).once
        t = channel.err_sender_thread
        channel.instance_variable_get('@w_io_err').close
        t.join
        expect(channel.closed?).to be false
        channel.close
        expect(channel.closed?).to be true
        expect(channel.instance_variable_get('@remote_window_size')).to eq (2097152 - send_data.size)
      end
    end

    context "when IOError occurs" do
      it "receives data from UNIX socket pair and send the data" do
        expect(connection).to receive(:send).with(channel_extended_data_payload).and_raise(IOError).once
        allow(channel).to receive(:send_channel_eof).with(no_args).once
        allow(channel).to receive(:send_channel_close).with(no_args).once
        t = channel.err_sender_thread
        t.join
        expect(channel.closed?).to be true
      end
    end

    context "when unexpected error occurs" do
      it "closes itself" do
        expect(channel).to receive(:send_channel_extended_data).with(send_data).and_raise(RuntimeError).once
        t = channel.err_sender_thread
        t.join
        expect(channel.closed?).to be true
      end
    end
  end

  describe '#receiver_thread' do
    let(:receive_data){ 'receive data' }

    before :example do
      channel.instance_variable_set('@closed', false)
    end

    context "when no error occurs" do
      context "when local window size is large enough" do
        before :example do
          channel.instance_variable_get('@receive_data_queue').enq receive_data
          channel.instance_variable_get('@receive_data_queue').close
        end

        it "receives data from receive_data_queue and and writes the data into UNIX socket" do
          allow(channel).to receive(:send_channel_eof).with(no_args).once
          allow(channel).to receive(:send_channel_close).with(no_args).once
          t = channel.receiver_thread
          expect(channel.instance_variable_get('@r_io_in').read(receive_data.length)).to eq receive_data
          t.join
          expect(channel.closed?).to be false
          channel.close
          expect(channel.closed?).to be true
        end
      end

      context "when local window size is not enough" do
        let(:channel_window_adjust_message){
          {
            :'message number'    => HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE,
            :'recipient channel' => 0,
            :'bytes to add'      => described_class::INITIAL_WINDOW_SIZE,
          }
        }
        let(:channel_window_adjust_payload){
          HrrRbSsh::Message::SSH_MSG_CHANNEL_WINDOW_ADJUST.encode channel_window_adjust_message
        }

        before :example do
          channel.instance_variable_set('@local_window_size', 1000)
          channel.instance_variable_get('@receive_data_queue').enq receive_data
          channel.instance_variable_get('@receive_data_queue').close
        end

        it "receives data from receive_data_queue and and writes the data into UNIX socket, and updates local window size" do
          allow(channel).to receive(:send_channel_eof).with(no_args).once
          allow(channel).to receive(:send_channel_close).with(no_args).once
          expect(connection).to receive(:send).with(channel_window_adjust_payload).once
          t = channel.receiver_thread
          expect(channel.instance_variable_get('@r_io_in').read(receive_data.length)).to eq receive_data
          t.join
          expect(channel.closed?).to be false
          channel.close
          expect(channel.closed?).to be true
          expect(channel.instance_variable_get('@local_window_size')).to eq (1000 - receive_data.size + described_class::INITIAL_WINDOW_SIZE)
        end
      end
    end

    context "when IOError occurs" do
      before :example do
        channel.instance_variable_get('@receive_data_queue').enq receive_data
        channel.instance_variable_get('@w_io_in').close
      end

      it "receives data from UNIX socket pair and send the data" do
        allow(channel).to receive(:send_channel_eof).with(no_args).once
        allow(channel).to receive(:send_channel_close).with(no_args).once
        t = channel.receiver_thread
        t.join
        expect(channel.closed?).to be true
      end
    end

    context "when unexpected error occurs" do
      let(:mock_receive_data_queue){ double('receive_data_queue') }

      before :example do
        channel.instance_variable_set('@receive_data_queue', mock_receive_data_queue)
      end

      it "closes itself" do
        expect(mock_receive_data_queue).to receive(:deq).with(no_args).and_raise(RuntimeError).once
        expect(channel).to receive(:close).with(no_args).once
        t = channel.receiver_thread
        t.join
      end
    end
  end
end
