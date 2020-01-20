# coding: utf-8
# vim: et ts=2 sw=2

require 'monitor'
require 'hrr_rb_ssh/version'
require 'hrr_rb_ssh/loggable'
require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/message'
require 'hrr_rb_ssh/error/closed_transport'
require 'hrr_rb_ssh/transport/constant'
require 'hrr_rb_ssh/transport/direction'
require 'hrr_rb_ssh/transport/sequence_number'
require 'hrr_rb_ssh/transport/sender'
require 'hrr_rb_ssh/transport/receiver'
require 'hrr_rb_ssh/transport/kex_algorithm'
require 'hrr_rb_ssh/transport/server_host_key_algorithm'
require 'hrr_rb_ssh/transport/encryption_algorithm'
require 'hrr_rb_ssh/transport/mac_algorithm'
require 'hrr_rb_ssh/transport/compression_algorithm'

module HrrRbSsh
  class Transport
    include Loggable
    include Constant

    attr_reader \
      :io,
      :mode,
      :supported_encryption_algorithms,
      :supported_server_host_key_algorithms,
      :supported_kex_algorithms,
      :supported_mac_algorithms,
      :supported_compression_algorithms,
      :preferred_encryption_algorithms,
      :preferred_server_host_key_algorithms,
      :preferred_kex_algorithms,
      :preferred_mac_algorithms,
      :preferred_compression_algorithms,
      :incoming_sequence_number,
      :outgoing_sequence_number,
      :server_host_key_algorithm,
      :incoming_encryption_algorithm,
      :incoming_mac_algorithm,
      :incoming_compression_algorithm,
      :outgoing_encryption_algorithm,
      :outgoing_mac_algorithm,
      :outgoing_compression_algorithm,
      :v_c,
      :v_s,
      :i_c,
      :i_s,
      :session_id

    def initialize io, mode, options={}, logger: nil
      self.logger = logger

      @io = io
      @mode = mode
      @options = options

      @closed = nil

      @in_kex = false

      @sender   = Sender.new logger: logger
      @receiver = Receiver.new logger: logger

      @sender_monitor   = Monitor.new
      @receiver_monitor = Monitor.new

      @local_version  = @options.delete('local_version') || "SSH-2.0-HrrRbSsh-#{VERSION}".force_encoding(Encoding::ASCII_8BIT)
      @remote_version = "".force_encoding(Encoding::ASCII_8BIT)

      @incoming_sequence_number = SequenceNumber.new
      @outgoing_sequence_number = SequenceNumber.new

      @acceptable_services = Array.new

      update_supported_algorithms
      update_preferred_algorithms
      initialize_local_algorithms
      initialize_algorithms
    end

    def register_acceptable_service service_name
      @acceptable_services.push service_name
    end

    def send payload
      raise Error::ClosedTransport if @closed
      @sender_monitor.synchronize do
        begin
          @sender.send self, payload
        rescue IOError, SystemCallError => e
          log_info { "#{e.message} (#{e.class})" }
          close
          raise Error::ClosedTransport
        rescue => e
          log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
          close
          raise Error::ClosedTransport
        end
      end
    end

    def receive
      raise Error::ClosedTransport if @closed
      @receiver_monitor.synchronize do
        begin
          payload = @receiver.receive self
          case payload[0,1].unpack("C")[0]
          when Message::SSH_MSG_DISCONNECT::VALUE
            log_info { "received disconnect message" }
            message = Message::SSH_MSG_DISCONNECT.new(logger: logger).decode payload
            close
            raise Error::ClosedTransport
          when Message::SSH_MSG_IGNORE::VALUE
            log_info { "received ignore message" }
            message = Message::SSH_MSG_IGNORE.new(logger: logger).decode payload
            receive
          when Message::SSH_MSG_UNIMPLEMENTED::VALUE
            log_info { "received unimplemented message" }
            message = Message::SSH_MSG_UNIMPLEMENTED.new(logger: logger).decode payload
            receive
          when Message::SSH_MSG_DEBUG::VALUE
            log_info { "received debug message" }
            message = Message::SSH_MSG_DEBUG.new(logger: logger).decode payload
            receive
          when Message::SSH_MSG_KEXINIT::VALUE
            log_info { "received kexinit message" }
            if @in_kex
              payload
            else
              exchange_key payload
              receive
            end
          else
            payload
          end
        rescue Error::ClosedTransport
          raise
        rescue EOFError, IOError, SystemCallError => e
          log_info { "#{e.message} (#{e.class})" }
          close
          raise Error::ClosedTransport
        rescue => e
          log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
          close
          raise Error::ClosedTransport
        end
      end
    end

    def start
      log_info { "start transport" }
      begin
        exchange_version
        exchange_key
        case @mode
        when Mode::SERVER
          verify_service_request
        when Mode::CLIENT
          send_service_request
        end
        @closed = false
      rescue Error::ClosedTransport
        raise
      rescue EOFError, IOError, SystemCallError => e
        log_info { "#{e.message} (#{e.class})" }
        close
        raise Error::ClosedTransport
      rescue => e
        log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        close
        raise Error::ClosedTransport
      else
        log_info { "transport started" }
      end
    end

    def close
      @sender_monitor.synchronize do
        return if @closed
        log_info { "close transport" }
        begin
          disconnect
          @incoming_compression_algorithm.close
          @outgoing_compression_algorithm.close
        rescue => e
          log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        ensure
          @closed = true
          log_info { "transport closed" }
        end
      end
    end

    def closed?
      @closed
    end

    def disconnect
      log_info { "disconnect transport" }
      send_disconnect
      log_info { "transport disconnected" }
    end

    def exchange_version
      send_version
      receive_version
      update_version_strings
    end

    def exchange_key payload=nil
      @in_kex = true
      @sender_monitor.synchronize do
        @receiver_monitor.synchronize do
          send_kexinit
          if payload
            receive_kexinit payload
          else
            receive_kexinit receive
          end
          update_kex_and_server_host_key_algorithms
          start_kex_algorithm
          send_newkeys
          receive_newkeys receive
          update_encryption_mac_compression_algorithms
        end
      end
      @in_kex = false
    end

    def start_kex_algorithm
      @kex_algorithm.start self
    end

    def verify_service_request
      service_request_message = receive_service_request
      service_name = service_request_message[:'service name']
      if @acceptable_services.include? service_name
        send_service_accept service_name
      else
        close
      end
    end

    def update_supported_algorithms
      @supported_kex_algorithms             = KexAlgorithm.list_supported
      @supported_server_host_key_algorithms = ServerHostKeyAlgorithm.list_supported
      @supported_encryption_algorithms      = EncryptionAlgorithm.list_supported
      @supported_mac_algorithms             = MacAlgorithm.list_supported
      @supported_compression_algorithms     = CompressionAlgorithm.list_supported
    end

    def update_preferred_algorithms
      @preferred_kex_algorithms             = @options['transport_preferred_kex_algorithms']             || KexAlgorithm.list_preferred
      @preferred_server_host_key_algorithms = @options['transport_preferred_server_host_key_algorithms'] || ServerHostKeyAlgorithm.list_preferred
      @preferred_encryption_algorithms      = @options['transport_preferred_encryption_algorithms']      || EncryptionAlgorithm.list_preferred
      @preferred_mac_algorithms             = @options['transport_preferred_mac_algorithms']             || MacAlgorithm.list_preferred
      @preferred_compression_algorithms     = @options['transport_preferred_compression_algorithms']     || CompressionAlgorithm.list_preferred

      check_if_preferred_algorithms_are_supported
    end

    def check_if_preferred_algorithms_are_supported
      [
        ['kex',             @preferred_kex_algorithms,             @supported_kex_algorithms            ],
        ['server host key', @preferred_server_host_key_algorithms, @supported_server_host_key_algorithms],
        ['encryption',      @preferred_encryption_algorithms,      @supported_encryption_algorithms     ],
        ['mac',             @preferred_mac_algorithms,             @supported_mac_algorithms            ],
        ['compression',     @preferred_compression_algorithms,     @supported_compression_algorithms    ],
      ].each{ |algorithm_name, list_preferred, list_supported|
        list_preferred.each{ |a|
          unless list_supported.include? a
            raise ArgumentError, "#{algorithm_name} algorithm #{a} is not supported"
          end
        }
      }
    end

    def initialize_local_algorithms
      @local_kex_algorithms                          = @preferred_kex_algorithms
      @local_server_host_key_algorithms              = @preferred_server_host_key_algorithms
      @local_encryption_algorithms_client_to_server  = @preferred_encryption_algorithms
      @local_encryption_algorithms_server_to_client  = @preferred_encryption_algorithms
      @local_mac_algorithms_client_to_server         = @preferred_mac_algorithms
      @local_mac_algorithms_server_to_client         = @preferred_mac_algorithms
      @local_compression_algorithms_client_to_server = @preferred_compression_algorithms
      @local_compression_algorithms_server_to_client = @preferred_compression_algorithms
    end

    def initialize_algorithms
      @incoming_encryption_algorithm  = EncryptionAlgorithm['none'].new
      @incoming_mac_algorithm         = MacAlgorithm['none'].new
      @incoming_compression_algorithm = CompressionAlgorithm['none'].new

      @outgoing_encryption_algorithm  = EncryptionAlgorithm['none'].new
      @outgoing_mac_algorithm         = MacAlgorithm['none'].new
      @outgoing_compression_algorithm = CompressionAlgorithm['none'].new
    end

    def send_version
      @io.write (@local_version + CR + LF)
    end

    def receive_version
      str_io = StringIO.new
      loop do
        str_io.write @io.read(1)
        if str_io.string[-2..-1] == "#{CR}#{LF}"
          if str_io.string[0..3] == "SSH-"
            @remote_version = str_io.string[0..-3]
            log_info { "received remote version string: #{@remote_version}" }
            break
          else
            log_info { "received message before remote version string: #{str_io.string}" }
            str_io.rewind
            str_io.truncate(0)
          end
        end
      end
    end

    def update_version_strings
      case @mode
      when Mode::SERVER
        @v_c = @remote_version
        @v_s = @local_version
      when Mode::CLIENT
        @v_c = @local_version
        @v_s = @remote_version
      end
    end

    def send_disconnect
      message = {
        :'message number' => Message::SSH_MSG_DISCONNECT::VALUE,
        :'reason code'    => Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_BY_APPLICATION,
        :'description'    => "disconnected by user",
        :'language tag'   => ""
      }
      payload = Message::SSH_MSG_DISCONNECT.new(logger: logger).encode message
      @sender_monitor.synchronize do
        begin
          @sender.send self, payload
        rescue IOError, SystemCallError => e
          log_info { "#{e.message} (#{e.class})" }
        rescue => e
          log_error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        end
      end
    end

    def send_kexinit
      message = {
        :'message number'                          => Message::SSH_MSG_KEXINIT::VALUE,
        :'cookie (random byte)'                    => lambda { rand(0x01_00) },
        :'kex_algorithms'                          => @local_kex_algorithms,
        :'server_host_key_algorithms'              => @local_server_host_key_algorithms,
        :'encryption_algorithms_client_to_server'  => @local_encryption_algorithms_client_to_server,
        :'encryption_algorithms_server_to_client'  => @local_encryption_algorithms_server_to_client,
        :'mac_algorithms_client_to_server'         => @local_mac_algorithms_client_to_server,
        :'mac_algorithms_server_to_client'         => @local_mac_algorithms_server_to_client,
        :'compression_algorithms_client_to_server' => @local_compression_algorithms_client_to_server,
        :'compression_algorithms_server_to_client' => @local_compression_algorithms_server_to_client,
        :'languages_client_to_server'              => [],
        :'languages_server_to_client'              => [],
        :'first_kex_packet_follows'                => false,
        :'0 (reserved for future extension)'       => 0,
      }
      payload = Message::SSH_MSG_KEXINIT.new(logger: logger).encode message
      send payload

      case @mode
      when Mode::SERVER
        @i_s = payload
      when Mode::CLIENT
        @i_c = payload
      end
    end

    def receive_kexinit payload
      case @mode
      when Mode::SERVER
        @i_c = payload
      when Mode::CLIENT
        @i_s = payload
      end
      message = Message::SSH_MSG_KEXINIT.new(logger: logger).decode payload
      update_remote_algorithms message
    end

    def send_newkeys
        message = {
          :'message number' => Message::SSH_MSG_NEWKEYS::VALUE,
        }
        payload = Message::SSH_MSG_NEWKEYS.new(logger: logger).encode message
        send payload
    end

    def receive_newkeys payload
      message = Message::SSH_MSG_NEWKEYS.new(logger: logger).decode payload
    end

    def send_service_request
      message = {
        :'message number' => Message::SSH_MSG_SERVICE_REQUEST::VALUE,
        :'service name' => 'ssh-userauth',
      }
      payload = Message::SSH_MSG_SERVICE_REQUEST.new(logger: logger).encode message
      send payload

      payload = @receiver.receive self
      message = Message::SSH_MSG_SERVICE_ACCEPT.new(logger: logger).decode payload
    end

    def receive_service_request
      payload = @receiver.receive self
      message = Message::SSH_MSG_SERVICE_REQUEST.new(logger: logger).decode payload
    end

    def send_service_accept service_name
      message = {
        :'message number' => Message::SSH_MSG_SERVICE_ACCEPT::VALUE,
        :'service name'   => service_name,
      }
      payload = Message::SSH_MSG_SERVICE_ACCEPT.new(logger: logger).encode message
      send payload
    end

    def update_remote_algorithms message
      @remote_kex_algorithms                          = message[:'kex_algorithms']
      @remote_server_host_key_algorithms              = message[:'server_host_key_algorithms']
      @remote_encryption_algorithms_client_to_server  = message[:'encryption_algorithms_client_to_server']
      @remote_encryption_algorithms_server_to_client  = message[:'encryption_algorithms_server_to_client']
      @remote_mac_algorithms_client_to_server         = message[:'mac_algorithms_client_to_server']
      @remote_mac_algorithms_server_to_client         = message[:'mac_algorithms_server_to_client']
      @remote_compression_algorithms_client_to_server = message[:'compression_algorithms_client_to_server']
      @remote_compression_algorithms_server_to_client = message[:'compression_algorithms_server_to_client']
    end

    def update_kex_and_server_host_key_algorithms
      case @mode
      when Mode::SERVER
        kex_algorithm_name             = @remote_kex_algorithms.find{ |a| @local_kex_algorithms.include? a } or raise
        server_host_key_algorithm_name = @remote_server_host_key_algorithms.find{ |a| @local_server_host_key_algorithms.include? a } or raise
        server_secret_host_key         = @options.fetch('transport_server_secret_host_keys', {}).fetch(server_host_key_algorithm_name, nil)
      when Mode::CLIENT
        kex_algorithm_name             = @local_kex_algorithms.find{ |a| @remote_kex_algorithms.include? a } or raise
        server_host_key_algorithm_name = @local_server_host_key_algorithms.find{ |a| @remote_server_host_key_algorithms.include? a } or raise
        server_secret_host_key         = nil
      end
      @server_host_key_algorithm = ServerHostKeyAlgorithm[server_host_key_algorithm_name].new server_secret_host_key
      @kex_algorithm             = KexAlgorithm[kex_algorithm_name].new
    end

    def update_encryption_mac_compression_algorithms
      @session_id ||= @kex_algorithm.hash(self)
      update_encryption_algorithm
      update_mac_algorithm
      update_compression_algorithm
    end

    def update_encryption_algorithm
      case @mode
      when Mode::SERVER
        encryption_algorithm_c_to_s_name = @remote_encryption_algorithms_client_to_server.find{ |a| @local_encryption_algorithms_client_to_server.include? a } or raise
        encryption_algorithm_s_to_c_name = @remote_encryption_algorithms_server_to_client.find{ |a| @local_encryption_algorithms_server_to_client.include? a } or raise
        incoming_encryption_algorithm_name = encryption_algorithm_c_to_s_name
        outgoing_encryption_algorithm_name = encryption_algorithm_s_to_c_name
        incoming_crpt_iv = @kex_algorithm.iv_c_to_s self, incoming_encryption_algorithm_name
        outgoing_crpt_iv = @kex_algorithm.iv_s_to_c self, outgoing_encryption_algorithm_name
        incoming_crpt_key = @kex_algorithm.key_c_to_s self, incoming_encryption_algorithm_name
        outgoing_crpt_key = @kex_algorithm.key_s_to_c self, outgoing_encryption_algorithm_name
      when Mode::CLIENT
        encryption_algorithm_s_to_c_name = @local_encryption_algorithms_server_to_client.find{ |a| @remote_encryption_algorithms_server_to_client.include? a } or raise
        encryption_algorithm_c_to_s_name = @local_encryption_algorithms_client_to_server.find{ |a| @remote_encryption_algorithms_client_to_server.include? a } or raise
        incoming_encryption_algorithm_name = encryption_algorithm_s_to_c_name
        outgoing_encryption_algorithm_name = encryption_algorithm_c_to_s_name
        incoming_crpt_iv = @kex_algorithm.iv_s_to_c self, incoming_encryption_algorithm_name
        outgoing_crpt_iv = @kex_algorithm.iv_c_to_s self, outgoing_encryption_algorithm_name
        incoming_crpt_key = @kex_algorithm.key_s_to_c self, incoming_encryption_algorithm_name
        outgoing_crpt_key = @kex_algorithm.key_c_to_s self, outgoing_encryption_algorithm_name
      end
      @incoming_encryption_algorithm = EncryptionAlgorithm[incoming_encryption_algorithm_name].new Direction::INCOMING, incoming_crpt_iv, incoming_crpt_key
      @outgoing_encryption_algorithm = EncryptionAlgorithm[outgoing_encryption_algorithm_name].new Direction::OUTGOING, outgoing_crpt_iv, outgoing_crpt_key
    end

    def update_mac_algorithm
      case @mode
      when Mode::SERVER
        mac_algorithm_c_to_s_name = @remote_mac_algorithms_client_to_server.find{ |a| @local_mac_algorithms_client_to_server.include? a } or raise
        mac_algorithm_s_to_c_name = @remote_mac_algorithms_server_to_client.find{ |a| @local_mac_algorithms_server_to_client.include? a } or raise
        incoming_mac_algorithm_name = mac_algorithm_c_to_s_name
        outgoing_mac_algorithm_name = mac_algorithm_s_to_c_name
        incoming_mac_key = @kex_algorithm.mac_c_to_s self, incoming_mac_algorithm_name
        outgoing_mac_key = @kex_algorithm.mac_s_to_c self, outgoing_mac_algorithm_name
      when Mode::CLIENT
        mac_algorithm_s_to_c_name = @local_mac_algorithms_server_to_client.find{ |a| @remote_mac_algorithms_server_to_client.include? a } or raise
        mac_algorithm_c_to_s_name = @local_mac_algorithms_client_to_server.find{ |a| @remote_mac_algorithms_client_to_server.include? a } or raise
        incoming_mac_algorithm_name = mac_algorithm_s_to_c_name
        outgoing_mac_algorithm_name = mac_algorithm_c_to_s_name
        incoming_mac_key = @kex_algorithm.mac_s_to_c self, incoming_mac_algorithm_name
        outgoing_mac_key = @kex_algorithm.mac_c_to_s self, outgoing_mac_algorithm_name
      end
      @incoming_mac_algorithm = MacAlgorithm[incoming_mac_algorithm_name].new incoming_mac_key
      @outgoing_mac_algorithm = MacAlgorithm[outgoing_mac_algorithm_name].new outgoing_mac_key
    end

    def update_compression_algorithm
      case @mode
      when Mode::SERVER
        compression_algorithm_c_to_s_name = @remote_compression_algorithms_client_to_server.find{ |a| @local_compression_algorithms_client_to_server.include? a } or raise
        compression_algorithm_s_to_c_name = @remote_compression_algorithms_server_to_client.find{ |a| @local_compression_algorithms_server_to_client.include? a } or raise
        incoming_compression_algorithm_name = compression_algorithm_c_to_s_name
        outgoing_compression_algorithm_name = compression_algorithm_s_to_c_name
      when Mode::CLIENT
        compression_algorithm_s_to_c_name = @local_compression_algorithms_server_to_client.find{ |a| @remote_compression_algorithms_server_to_client.include? a } or raise
        compression_algorithm_c_to_s_name = @local_compression_algorithms_client_to_server.find{ |a| @remote_compression_algorithms_client_to_server.include? a } or raise
        incoming_compression_algorithm_name = compression_algorithm_s_to_c_name
        outgoing_compression_algorithm_name = compression_algorithm_c_to_s_name
      end
      @incoming_compression_algorithm.close
      @outgoing_compression_algorithm.close
      @incoming_compression_algorithm = CompressionAlgorithm[incoming_compression_algorithm_name].new Direction::INCOMING
      @outgoing_compression_algorithm = CompressionAlgorithm[outgoing_compression_algorithm_name].new Direction::OUTGOING
    end
  end
end
