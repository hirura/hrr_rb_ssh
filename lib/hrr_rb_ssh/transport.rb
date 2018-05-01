# coding: utf-8
# vim: et ts=2 sw=2

require 'monitor'
require 'hrr_rb_ssh/version'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/data_type'
require 'hrr_rb_ssh/message'
require 'hrr_rb_ssh/closed_transport_error'
require 'hrr_rb_ssh/transport/constant'
require 'hrr_rb_ssh/transport/mode'
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
    include Constant

    attr_reader \
      :io,
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

    def initialize io, mode, options={}
      @io = io
      @mode = mode

      @logger = HrrRbSsh::Logger.new self.class.name

      @closed = nil
      @disconnected = nil

      @in_kex = false

      @sender   = HrrRbSsh::Transport::Sender.new
      @receiver = HrrRbSsh::Transport::Receiver.new

      @sender_monitor   = Monitor.new
      @receiver_monitor = Monitor.new

      @local_version  = "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}".force_encoding(Encoding::ASCII_8BIT)
      @remote_version = "".force_encoding(Encoding::ASCII_8BIT)

      @incoming_sequence_number = HrrRbSsh::Transport::SequenceNumber.new
      @outgoing_sequence_number = HrrRbSsh::Transport::SequenceNumber.new

      @acceptable_services = Array.new

      update_supported_algorithms
      update_preferred_algorithms options
      initialize_local_algorithms
      initialize_algorithms
    end

    def register_acceptable_service service_name
      @acceptable_services.push service_name
    end

    def send payload
      @sender_monitor.synchronize do
        begin
          @sender.send self, payload
        rescue Errno::EPIPE => e
          @logger.warn { "IO is Broken PIPE" }
          close
          raise HrrRbSsh::ClosedTransportError
        rescue => e
          @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
          close
          raise HrrRbSsh::ClosedTransportError
        end
      end
    end

    def receive
      raise ClosedTransportError if @closed
      @receiver_monitor.synchronize do
        begin
          payload = @receiver.receive self
          case payload[0,1].unpack("C")[0]
          when HrrRbSsh::Message::SSH_MSG_DISCONNECT::VALUE
            message = HrrRbSsh::Message::SSH_MSG_DISCONNECT.decode payload
            @logger.debug { "received disconnect message: #{message.inspect}" }
            @disconnected = true
            close
            raise ClosedTransportError
          when HrrRbSsh::Message::SSH_MSG_IGNORE::VALUE
            message = HrrRbSsh::Message::SSH_MSG_IGNORE.decode payload
            @logger.debug { "received ignore message: #{message.inspect}" }
            receive
          when HrrRbSsh::Message::SSH_MSG_UNIMPLEMENTED::VALUE
            message = HrrRbSsh::Message::SSH_MSG_UNIMPLEMENTED.decode payload
            @logger.debug { "received unimplemented message: #{message.inspect}" }
            receive
          when HrrRbSsh::Message::SSH_MSG_DEBUG::VALUE
            message = HrrRbSsh::Message::SSH_MSG_DEBUG.decode payload
            @logger.debug { "received debug message: #{message.inspect}" }
            receive
          when HrrRbSsh::Message::SSH_MSG_KEXINIT::VALUE
            @logger.debug { "received kexinit message" }
            if @in_kex
              payload
            else
              exchange_key payload
              receive
            end
          else
            payload
          end
        rescue ClosedTransportError
          raise ClosedTransportError
        rescue EOFError => e
          close
          raise ClosedTransportError
        rescue IOError => e
          @logger.warn { "IO is closed" }
          close
          raise ClosedTransportError
        rescue Errno::ECONNRESET => e
          @logger.warn { "IO is RESET" }
          close
          raise ClosedTransportError
        rescue => e
          @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
          close
          raise ClosedTransportError
        end
      end
    end

    def start
      @logger.info { "start transport" }

      begin
        exchange_version
        exchange_key

        case @mode
        when HrrRbSsh::Transport::Mode::SERVER
          verify_service_request
        end

        @closed = false
      rescue EOFError => e
        close
      rescue => e
        @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
        close
      else
        @logger.info { "transport started" }
      end
    end

    def close
      return if @closed
      @logger.info { "close transport" }
      @closed = true
      disconnect
      @logger.info { "transport closed" }
    end

    def closed?
      @closed
    end

    def disconnect
      return if @disconnected
      @logger.info { "disconnect transport" }
      @disconnected = true
      begin
        send_disconnect
      rescue IOError
        @logger.warn { "IO is closed" }
      rescue => e
        @logger.error { [e.backtrace[0], ": ", e.message, " (", e.class.to_s, ")\n\t", e.backtrace[1..-1].join("\n\t")].join }
      end
      @logger.info { "transport disconnected" }
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
      @kex_algorithm.start self, @mode
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
      @supported_kex_algorithms             = HrrRbSsh::Transport::KexAlgorithm.list_supported
      @supported_server_host_key_algorithms = HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_supported
      @supported_encryption_algorithms      = HrrRbSsh::Transport::EncryptionAlgorithm.list_supported
      @supported_mac_algorithms             = HrrRbSsh::Transport::MacAlgorithm.list_supported
      @supported_compression_algorithms     = HrrRbSsh::Transport::CompressionAlgorithm.list_supported
    end

    def update_preferred_algorithms options
      @preferred_kex_algorithms             = options['transport_preferred_kex_algorithms']             || HrrRbSsh::Transport::KexAlgorithm.list_preferred
      @preferred_server_host_key_algorithms = options['transport_preferred_server_host_key_algorithms'] || HrrRbSsh::Transport::ServerHostKeyAlgorithm.list_preferred
      @preferred_encryption_algorithms      = options['transport_preferred_encryption_algorithms']      || HrrRbSsh::Transport::EncryptionAlgorithm.list_preferred
      @preferred_mac_algorithms             = options['transport_preferred_mac_algorithms']             || HrrRbSsh::Transport::MacAlgorithm.list_preferred
      @preferred_compression_algorithms     = options['transport_preferred_compression_algorithms']     || HrrRbSsh::Transport::CompressionAlgorithm.list_preferred

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
      @incoming_encryption_algorithm  = HrrRbSsh::Transport::EncryptionAlgorithm['none'].new
      @incoming_mac_algorithm         = HrrRbSsh::Transport::MacAlgorithm['none'].new
      @incoming_compression_algorithm = HrrRbSsh::Transport::CompressionAlgorithm['none'].new

      @outgoing_encryption_algorithm  = HrrRbSsh::Transport::EncryptionAlgorithm['none'].new
      @outgoing_mac_algorithm         = HrrRbSsh::Transport::MacAlgorithm['none'].new
      @outgoing_compression_algorithm = HrrRbSsh::Transport::CompressionAlgorithm['none'].new
    end

    def send_version
      @io.write (@local_version + CR + LF)
    end

    def receive_version
      tmp_str = String.new
      loop do
        tmp_str << @io.read(1)
        if tmp_str =~ /#{CR}#{LF}/
          if tmp_str =~ /^SSH-/
            @remote_version = tmp_str.match( /(:?SSH-.+)#{CR}#{LF}/ )[1]
            break
          else
            tmp_str.clear
          end
        end
      end
    end

    def update_version_strings
      case @mode
      when HrrRbSsh::Transport::Mode::SERVER
        @v_c = @remote_version
        @v_s = @local_version
      when HrrRbSsh::Transport::Mode::CLIENT
        @v_c = @local_version
        @v_s = @remote_version
      end
    end

    def send_disconnect
      message = {
        :'message number' => HrrRbSsh::Message::SSH_MSG_DISCONNECT::VALUE,
        :'reason code'    => HrrRbSsh::Message::SSH_MSG_DISCONNECT::ReasonCode::SSH_DISCONNECT_BY_APPLICATION,
        :'description'    => "disconnected by user",
        :'language tag'   => ""
      }
      payload = HrrRbSsh::Message::SSH_MSG_DISCONNECT.encode message
      send payload
    end

    def send_kexinit
      message = {
        :'message number'                          => HrrRbSsh::Message::SSH_MSG_KEXINIT::VALUE,
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
      payload = HrrRbSsh::Message::SSH_MSG_KEXINIT.encode message
      send payload

      case @mode
      when HrrRbSsh::Transport::Mode::SERVER
        @i_s = payload
      when HrrRbSsh::Transport::Mode::CLIENT
        @i_c = payload
      end
    end

    def receive_kexinit payload
      case @mode
      when HrrRbSsh::Transport::Mode::SERVER
        @i_c = payload
      when HrrRbSsh::Transport::Mode::CLIENT
        @i_s = payload
      end
      message = HrrRbSsh::Message::SSH_MSG_KEXINIT.decode payload
      update_remote_algorithms message
    end

    def send_newkeys
        message = {
          :'message number' => HrrRbSsh::Message::SSH_MSG_NEWKEYS::VALUE,
        }
        payload = HrrRbSsh::Message::SSH_MSG_NEWKEYS.encode message
        send payload
    end

    def receive_newkeys payload
      message = HrrRbSsh::Message::SSH_MSG_NEWKEYS.decode payload
    end

    def receive_service_request
      payload = @receiver.receive self
      message = HrrRbSsh::Message::SSH_MSG_SERVICE_REQUEST.decode payload

      message
    end

    def send_service_accept service_name
        message = {
          :'message number' => HrrRbSsh::Message::SSH_MSG_SERVICE_ACCEPT::VALUE,
          :'service name'   => service_name,
        }
        payload = HrrRbSsh::Message::SSH_MSG_SERVICE_ACCEPT.encode message
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
      when HrrRbSsh::Transport::Mode::SERVER
        kex_algorithm_name             = @remote_kex_algorithms.find{ |a| @local_kex_algorithms.include? a } or raise
        server_host_key_algorithm_name = @remote_server_host_key_algorithms.find{ |a| @local_server_host_key_algorithms.include? a } or raise
      when HrrRbSsh::Transport::Mode::CLIENT
        kex_algorithm_name             = @local_kex_algorithms.find{ |a| @remote_kex_algorithms.include? a } or raise
        server_host_key_algorithm_name = @local_server_host_key_algorithms.find{ |a| @remote_server_host_key_algorithms.include? a } or raise
      end

      @kex_algorithm             = HrrRbSsh::Transport::KexAlgorithm[kex_algorithm_name].new
      @server_host_key_algorithm = HrrRbSsh::Transport::ServerHostKeyAlgorithm[server_host_key_algorithm_name].new
    end

    def update_encryption_mac_compression_algorithms
      @session_id ||= @kex_algorithm.hash(self)
      update_encryption_algorithm
      update_mac_algorithm
      update_compression_algorithm
    end

    def update_encryption_algorithm
      case @mode
      when HrrRbSsh::Transport::Mode::SERVER
        encryption_algorithm_c_to_s_name = @remote_encryption_algorithms_client_to_server.find{ |a| @local_encryption_algorithms_client_to_server.include? a } or raise
        encryption_algorithm_s_to_c_name = @remote_encryption_algorithms_server_to_client.find{ |a| @local_encryption_algorithms_server_to_client.include? a } or raise
        incoming_encryption_algorithm_name = encryption_algorithm_c_to_s_name
        outgoing_encryption_algorithm_name = encryption_algorithm_s_to_c_name
        incoming_crpt_iv = @kex_algorithm.iv_c_to_s self, incoming_encryption_algorithm_name
        outgoing_crpt_iv = @kex_algorithm.iv_s_to_c self, outgoing_encryption_algorithm_name
        incoming_crpt_key = @kex_algorithm.key_c_to_s self, incoming_encryption_algorithm_name
        outgoing_crpt_key = @kex_algorithm.key_s_to_c self, outgoing_encryption_algorithm_name
      end
      @incoming_encryption_algorithm = HrrRbSsh::Transport::EncryptionAlgorithm[incoming_encryption_algorithm_name].new Direction::INCOMING, incoming_crpt_iv, incoming_crpt_key
      @outgoing_encryption_algorithm = HrrRbSsh::Transport::EncryptionAlgorithm[outgoing_encryption_algorithm_name].new Direction::OUTGOING, outgoing_crpt_iv, outgoing_crpt_key
    end

    def update_mac_algorithm
      case @mode
      when HrrRbSsh::Transport::Mode::SERVER
        mac_algorithm_c_to_s_name = @remote_mac_algorithms_client_to_server.find{ |a| @local_mac_algorithms_client_to_server.include? a } or raise
        mac_algorithm_s_to_c_name = @remote_mac_algorithms_server_to_client.find{ |a| @local_mac_algorithms_server_to_client.include? a } or raise
        incoming_mac_algorithm_name = mac_algorithm_c_to_s_name
        outgoing_mac_algorithm_name = mac_algorithm_s_to_c_name
        incoming_mac_key = @kex_algorithm.mac_c_to_s self, incoming_mac_algorithm_name
        outgoing_mac_key = @kex_algorithm.mac_s_to_c self, outgoing_mac_algorithm_name
      end
      @incoming_mac_algorithm = HrrRbSsh::Transport::MacAlgorithm[incoming_mac_algorithm_name].new incoming_mac_key
      @outgoing_mac_algorithm = HrrRbSsh::Transport::MacAlgorithm[outgoing_mac_algorithm_name].new outgoing_mac_key
    end

    def update_compression_algorithm
      case @mode
      when HrrRbSsh::Transport::Mode::SERVER
        compression_algorithm_c_to_s_name = @remote_compression_algorithms_client_to_server.find{ |a| @local_compression_algorithms_client_to_server.include? a } or raise
        compression_algorithm_s_to_c_name = @remote_compression_algorithms_server_to_client.find{ |a| @local_compression_algorithms_server_to_client.include? a } or raise
        incoming_compression_algorithm_name = compression_algorithm_c_to_s_name
        outgoing_compression_algorithm_name = compression_algorithm_s_to_c_name
      end
      @incoming_compression_algorithm = HrrRbSsh::Transport::CompressionAlgorithm[incoming_compression_algorithm_name].new Direction::INCOMING
      @outgoing_compression_algorithm = HrrRbSsh::Transport::CompressionAlgorithm[outgoing_compression_algorithm_name].new Direction::OUTGOING
    end
  end
end
