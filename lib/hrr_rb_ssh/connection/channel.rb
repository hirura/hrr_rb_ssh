# coding: utf-8
# vim: et ts=2 sw=2

require 'socket'
require 'thread'
require 'monitor'
require 'hrr_rb_ssh/loggable'
require 'hrr_rb_ssh/connection/channel/channel_type'

module HrrRbSsh
  class Connection
    class Channel
      include Loggable

      INITIAL_WINDOW_SIZE = 100000
      MAXIMUM_PACKET_SIZE = 100000

      attr_reader \
        :channel_type,
        :local_channel,
        :remote_channel,
        :local_window_size,
        :local_maximum_packet_size,
        :remote_window_size,
        :remote_maximum_packet_size,
        :receive_message_queue,
        :exit_status

      def initialize connection, message, socket=nil, logger: nil
        self.logger = logger

        @connection = connection

        @channel_type = message[:'channel type']
        @local_channel  = connection.assign_channel
        @remote_channel = message[:'sender channel']
        @local_window_size          = INITIAL_WINDOW_SIZE
        @local_maximum_packet_size  = MAXIMUM_PACKET_SIZE
        @remote_window_size         = message[:'initial window size']
        @remote_maximum_packet_size = message[:'maximum packet size']

        @channel_type_instance = ChannelType[@channel_type].new connection, self, message, socket, logger: logger

        @receive_message_queue = Queue.new
        @receive_data_queue = Queue.new
        @receive_extended_data_queue = Queue.new

        @r_io_in,  @w_io_in  = IO.pipe
        @r_io_out, @w_io_out = IO.pipe
        @r_io_err, @w_io_err = IO.pipe

        @channel_closing_monitor = Monitor.new

        @closed = nil
        @exit_status = nil
      end

      def set_remote_parameters message
        @remote_channel = message[:'sender channel']
        @remote_window_size = message[:'initial window size']
        @remote_maximum_packet_size = message[:'maximum packet size']
      end

      def io
        case @connection.mode
        when Mode::SERVER
          [@r_io_in, @w_io_out, @w_io_err]
        when Mode::CLIENT
          [@w_io_in, @r_io_out, @r_io_err]
        end
      end

      def start
        @channel_loop_thread = channel_loop_thread
        case @connection.mode
        when Mode::SERVER
          @out_sender_thread   = out_sender_thread
          @err_sender_thread   = err_sender_thread
          @receiver_thread     = receiver_thread
          @channel_type_instance.start
        when Mode::CLIENT
          @out_receiver_thread = out_receiver_thread
          @err_receiver_thread = err_receiver_thread
          @sender_thread       = sender_thread
          @channel_type_instance.start
        end
        @closed = false
        log_debug { "in start: #{@waiting_thread.inspect}" }
        @waiting_thread.wakeup if @waiting_thread
      end

      def wait_until_started
        @waiting_thread = Thread.current
        log_debug { "in wait_until_started: #{@waiting_thread.inspect}" }
        Thread.stop
      end

      def wait_until_senders_closed
        [
          @out_sender_thread,
          @err_sender_thread,
        ].each{ |t|
          begin
            t.join if t.instance_of? Thread
          rescue => e
            log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
          end
        }
      end

      def close from=:outside, exitstatus=0
        @channel_closing_monitor.synchronize {
          return if @closed
          log_info { "close channel" }
          @closed = true
        }
        unless from == :channel_type_instance
          @channel_type_instance.close
        end
        @receive_message_queue.close
        begin
          if from == :channel_type_instance
            send_channel_eof
            case exitstatus
            when Integer
              send_channel_request_exit_status exitstatus
            else
              log_warn { "skip sending exit-status because exitstatus is not an instance of Integer" }
            end
          elsif from == :sender_thread
            send_channel_eof
          end
          send_channel_close
        rescue Error::ClosedConnection => e
          Thread.pass
        rescue => e
          log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        end
        log_info { "channel closed" }
      end

      def wait_until_closed
        [
          @out_sender_thread,
          @err_sender_thread,
          @receiver_thread,
          @out_receiver_thread,
          @err_receiver_thread,
          @sender_thread,
          @channel_loop_thread
        ].each{ |t|
          begin
            t.join if t.instance_of? Thread
          rescue => e
            log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
          end
        }
      end

      def closed?
        @closed
      end

      def channel_loop_thread
        Thread.start do
          log_info { "start channel loop thread" }
          begin
            loop do
              begin
                message = @receive_message_queue.deq
                if message.nil? && @receive_message_queue.closed?
                  break
                end
                case message[:'message number']
                when Message::SSH_MSG_CHANNEL_EOF::VALUE
                  @receive_data_queue.close
                  @receive_extended_data_queue.close
                when Message::SSH_MSG_CHANNEL_REQUEST::VALUE
                  log_info { "received channel request: #{message[:'request type']}" }
                  case @connection.mode
                  when Mode::SERVER
                    begin
                      @channel_type_instance.request message
                    rescue => e
                      log_warn { "request failed: #{e.message}" }
                      send_channel_failure if message[:'want reply']
                    else
                      send_channel_success if message[:'want reply']
                    end
                  when Mode::CLIENT
                    case message[:'request type']
                    when "exit-status"
                      log_info { "exit status: #{message[:'exit status']}" }
                      @exit_status = message[:'exit status'].to_i
                    end
                  end
                when Message::SSH_MSG_CHANNEL_DATA::VALUE
                  log_info { "received channel data" }
                  local_channel = message[:'recipient channel']
                  @receive_data_queue.enq message[:'data']
                when Message::SSH_MSG_CHANNEL_EXTENDED_DATA::VALUE
                  log_info { "received channel extended data" }
                  local_channel = message[:'recipient channel']
                  @receive_extended_data_queue.enq message[:'data']
                when Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE
                  log_info { "received channel window adjust" }
                  @remote_window_size = [@remote_window_size + message[:'bytes to add'], 0xffff_ffff].min
                else
                  log_warn { "received unsupported message: #{message.inspect}" }
                end
              rescue => e
                log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
                close from=:channel_loop_thread
                break
              end
            end
          ensure
            log_info { "closing channel loop thread" }
            @receive_data_queue.close
            @receive_extended_data_queue.close
          end
          log_info { "channel loop thread closed" }
        end
      end

      def out_sender_thread
        Thread.start {
          log_info { "start out sender thread" }
          loop do
            if @r_io_out.closed?
              log_info { "closing out sender thread" }
              break
            end
            begin
              data = @r_io_out.readpartial(10240)
              sendable_size = [data.size, @remote_window_size].min
              sending_data = data[0, sendable_size]
              send_channel_data sending_data if sendable_size > 0
              @remote_window_size -= sendable_size
            rescue EOFError, IOError => e
              @r_io_out.close rescue nil
            rescue => e
              log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
              @r_io_out.close rescue nil
              close
            end
          end
          log_info { "out sender thread closed" }
        }
      end

      def err_sender_thread
        Thread.start {
          log_info { "start err sender thread" }
          loop do
            if @r_io_err.closed?
              log_info { "closing err sender thread" }
              break
            end
            begin
              data = @r_io_err.readpartial(10240)
              sendable_size = [data.size, @remote_window_size].min
              sending_data = data[0, sendable_size]
              send_channel_extended_data sending_data if sendable_size > 0
              @remote_window_size -= sendable_size
            rescue EOFError, IOError => e
              @r_io_err.close rescue nil
            rescue => e
              log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
              @r_io_err.close rescue nil
              close
            end
          end
          log_info { "err sender thread closed" }
        }
      end

      def receiver_thread
        Thread.start {
          log_info { "start receiver thread" }
          loop do
            begin
              data = @receive_data_queue.deq
              if data.nil? && @receive_data_queue.closed?
                log_info { "closing receiver thread" }
                log_info { "closing w_io_in" }
                @w_io_in.close
                log_info { "w_io_in closed" }
                break
              end
              @w_io_in.write data
              @local_window_size -= data.size
              if @local_window_size < INITIAL_WINDOW_SIZE/2
                log_info { "send channel window adjust" }
                send_channel_window_adjust
                @local_window_size += INITIAL_WINDOW_SIZE
              end
            rescue Errno::EPIPE, IOError => e
              close
              break
            rescue => e
              log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
              close
              break
            end
          end
          log_info { "receiver thread closed" }
        }
      end

      def out_receiver_thread
        Thread.start {
          log_info { "start out receiver thread" }
          loop do
            begin
              data = @receive_data_queue.deq
              if data.nil? && @receive_data_queue.closed?
                log_info { "closing out receiver thread" }
                log_info { "closing w_io_out" }
                @w_io_out.close
                log_info { "w_io_out closed" }
                break
              end
              @w_io_out.write data
              @local_window_size -= data.size
              if @local_window_size < INITIAL_WINDOW_SIZE/2
                log_info { "send channel window adjust" }
                send_channel_window_adjust
                @local_window_size += INITIAL_WINDOW_SIZE
              end
            rescue Errno::EPIPE, IOError => e
              close
              break
            rescue => e
              log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
              close
              break
            end
          end
          log_info { "out receiver thread closed" }
        }
      end

      def err_receiver_thread
        Thread.start {
          log_info { "start err receiver thread" }
          loop do
            begin
              data = @receive_extended_data_queue.deq
              if data.nil? && @receive_extended_data_queue.closed?
                log_info { "closing err receiver thread" }
                log_info { "closing w_io_err" }
                @w_io_err.close
                log_info { "w_io_err closed" }
                break
              end
              @w_io_err.write data
              @local_window_size -= data.size
              if @local_window_size < INITIAL_WINDOW_SIZE/2
                log_info { "send channel window adjust" }
                send_channel_window_adjust
                @local_window_size += INITIAL_WINDOW_SIZE
              end
            rescue Error::EPIPE, IOError => e
              close
              break
            rescue => e
              log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
              close
              break
            end
          end
          log_info { "err receiver thread closed" }
        }
      end

      def sender_thread
        Thread.start {
          log_info { "start sender thread" }
          loop do
            if @r_io_in.closed?
              log_info { "closing sender thread" }
              break
            end
            begin
              data = @r_io_in.readpartial(10240)
              sendable_size = [data.size, @remote_window_size].min
              sending_data = data[0, sendable_size]
              send_channel_data sending_data if sendable_size > 0
              @remote_window_size -= sendable_size
            rescue EOFError, IOError => e
              @r_io_in.close rescue nil
            rescue => e
              log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
              @r_io_in.close rescue nil
            end
          end
          close from=:sender_thread
          log_info { "sender thread closed" }
        }
      end

      def send_channel_success
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_SUCCESS::VALUE,
          :'recipient channel' => @remote_channel,
        }
        payload = Message::SSH_MSG_CHANNEL_SUCCESS.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_failure
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_FAILURE::VALUE,
          :'recipient channel' => @remote_channel,
        }
        payload = Message::SSH_MSG_CHANNEL_FAILURE.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_window_adjust
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_WINDOW_ADJUST::VALUE,
          :'recipient channel' => @remote_channel,
          :'bytes to add'      => INITIAL_WINDOW_SIZE,
        }
        payload = Message::SSH_MSG_CHANNEL_WINDOW_ADJUST.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_data data
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_DATA::VALUE,
          :'recipient channel' => @remote_channel,
          :'data'              => data,
        }
        payload = Message::SSH_MSG_CHANNEL_DATA.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_extended_data data, code=Message::SSH_MSG_CHANNEL_EXTENDED_DATA::DataTypeCode::SSH_EXTENDED_DATA_STDERR
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_EXTENDED_DATA::VALUE,
          :'recipient channel' => @remote_channel,
          :'data type code'    => code,
          :'data'              => data,
        }
        payload = Message::SSH_MSG_CHANNEL_EXTENDED_DATA.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_request_pty_req term_env_var_val, term_width_chars, term_height_rows, term_width_pixel, term_height_pixel, encoded_term_modes
        message = {
          :'message number'                  => Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel'               => @remote_channel,
          :'request type'                    => "pty-req",
          :'want reply'                      => false,
          :'TERM environment variable value' => term_env_var_val,
          :'terminal width, characters'      => term_width_chars,
          :'terminal height, rows'           => term_height_rows,
          :'terminal width, pixels'          => term_width_pixel,
          :'terminal height, pixels'         => term_height_pixel,
          :'encoded terminal modes'          => encoded_term_modes,
        }
        payload = Message::SSH_MSG_CHANNEL_REQUEST.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_request_env variable_name, variable_value
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel' => @remote_channel,
          :'request type'      => "env",
          :'want reply'        => false,
          :'variable name'     => variable_name,
          :'variable value'    => variable_value,
        }
        payload = Message::SSH_MSG_CHANNEL_REQUEST.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_request_shell
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel' => @remote_channel,
          :'request type'      => "shell",
          :'want reply'        => false,
        }
        payload = Message::SSH_MSG_CHANNEL_REQUEST.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_request_exec command
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel' => @remote_channel,
          :'request type'      => "exec",
          :'want reply'        => false,
          :'command'           => command,
        }
        payload = Message::SSH_MSG_CHANNEL_REQUEST.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_request_subsystem subsystem_name
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel' => @remote_channel,
          :'request type'      => "subsystem",
          :'want reply'        => false,
          :'subsystem name'    => subsystem_name,
        }
        payload = Message::SSH_MSG_CHANNEL_REQUEST.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_request_window_change term_width_cols, term_height_rows, term_width_pixel, term_height_pixel
        message = {
          :'message number'          => Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel'       => @remote_channel,
          :'request type'            => "window-change",
          :'want reply'              => false,
          :'terminal width, columns' => term_width_cols,
          :'terminal height, rows'   => term_height_rows,
          :'terminal width, pixels'  => term_width_pixel,
          :'terminal height, pixels' => term_height_pixel,
        }
        payload = Message::SSH_MSG_CHANNEL_REQUEST.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_request_signal signal_name
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel' => @remote_channel,
          :'request type'      => "signal",
          :'want reply'        => false,
          :'signal name'       => signal_name,
        }
        payload = Message::SSH_MSG_CHANNEL_REQUEST.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_request_exit_status exitstatus
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_REQUEST::VALUE,
          :'recipient channel' => @remote_channel,
          :'request type'      => "exit-status",
          :'want reply'        => false,
          :'exit status'       => exitstatus,
        }
        payload = Message::SSH_MSG_CHANNEL_REQUEST.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_eof
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_EOF::VALUE,
          :'recipient channel' => @remote_channel,
        }
        payload = Message::SSH_MSG_CHANNEL_EOF.new(logger: logger).encode message
        @connection.send payload
      end

      def send_channel_close
        message = {
          :'message number'    => Message::SSH_MSG_CHANNEL_CLOSE::VALUE,
          :'recipient channel' => @remote_channel,
        }
        payload = Message::SSH_MSG_CHANNEL_CLOSE.new(logger: logger).encode message
        @connection.send payload
      end
    end
  end
end
