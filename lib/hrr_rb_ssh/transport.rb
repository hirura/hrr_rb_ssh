# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/version'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message'
require 'hrr_rb_ssh/transport/constant'
require 'hrr_rb_ssh/transport/mode'
require 'hrr_rb_ssh/transport/data_type'
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
      :incoming_sequence_number,
      :outgoing_sequence_number,
      :incoming_encryption_algorithm,
      :incoming_mac_algorithm,
      :incoming_compression_algorithm,
      :outgoing_encryption_algorithm,
      :outgoing_mac_algorithm,
      :outgoing_compression_algorithm,
      :v_c,
      :v_s,
      :i_c,
      :i_s


    def initialize io, mode
      @io = io
      @mode = mode

      @logger = HrrRbSsh::Logger.new self.class.name

      @sender   = HrrRbSsh::Transport::Sender.new
      @receiver = HrrRbSsh::Transport::Receiver.new

      @local_version  = "SSH-2.0-HrrRbSsh-#{HrrRbSsh::VERSION}".force_encoding(Encoding::ASCII_8BIT)
      @remote_version = "".force_encoding(Encoding::ASCII_8BIT)

      @incoming_sequence_number = HrrRbSsh::Transport::SequenceNumber.new
      @outgoing_sequence_number = HrrRbSsh::Transport::SequenceNumber.new

      initialize_local_algorithms
      initialize_algorithms
    end

    def exchange_version
      send_version
      receive_version

      update_version_strings
    end

    def exchange_key
      send_kexinit
      receive_kexinit
    end

    def initialize_local_algorithms
      @local_kex_algorithms                          = HrrRbSsh::Transport::KexAlgorithm.name_list
      @local_server_host_key_algorithms              = HrrRbSsh::Transport::ServerHostKeyAlgorithm.name_list
      @local_encryption_algorithms_client_to_server  = HrrRbSsh::Transport::EncryptionAlgorithm.name_list
      @local_encryption_algorithms_server_to_client  = HrrRbSsh::Transport::EncryptionAlgorithm.name_list
      @local_mac_algorithms_client_to_server         = HrrRbSsh::Transport::MacAlgorithm.name_list
      @local_mac_algorithms_server_to_client         = HrrRbSsh::Transport::MacAlgorithm.name_list
      @local_compression_algorithms_client_to_server = HrrRbSsh::Transport::CompressionAlgorithm.name_list
      @local_compression_algorithms_server_to_client = HrrRbSsh::Transport::CompressionAlgorithm.name_list
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

    def send_kexinit
      message = {
        'SSH_MSG_KEXINIT'                         => HrrRbSsh::Message::SSH_MSG_KEXINIT::VALUE,
        'cookie (random byte)'                    => lambda { rand(0x01_00) },
        'kex_algorithms'                          => @local_kex_algorithms,
        'server_host_key_algorithms'              => @local_server_host_key_algorithms,
        'encryption_algorithms_client_to_server'  => @local_encryption_algorithms_client_to_server,
        'encryption_algorithms_server_to_client'  => @local_encryption_algorithms_server_to_client,
        'mac_algorithms_client_to_server'         => @local_mac_algorithms_client_to_server,
        'mac_algorithms_server_to_client'         => @local_mac_algorithms_server_to_client,
        'compression_algorithms_client_to_server' => @local_compression_algorithms_client_to_server,
        'compression_algorithms_server_to_client' => @local_compression_algorithms_server_to_client,
        'languages_client_to_server'              => [],
        'languages_server_to_client'              => [],
        'first_kex_packet_follows'                => false,
        '0 (reserved for future extension)'       => 0,
      }
      payload = HrrRbSsh::Message::SSH_MSG_KEXINIT.encode message
      @sender.send self, payload

      case @mode
      when HrrRbSsh::Transport::Mode::SERVER
        @i_s = payload
      when HrrRbSsh::Transport::Mode::CLIENT
        @i_c = payload
      end
    end

    def receive_kexinit
      payload = @receiver.receive self

      case @mode
      when HrrRbSsh::Transport::Mode::SERVER
        @i_c = payload
      when HrrRbSsh::Transport::Mode::CLIENT
        @i_s = payload
      end

      message = HrrRbSsh::Message::SSH_MSG_KEXINIT.decode payload

      update_remote_algorithms message
    end

    def update_remote_algorithms message
      @remote_kex_algorithms                          = message['kex_algorithms']
      @remote_server_host_key_algorithms              = message['server_host_key_algorithms']
      @remote_encryption_algorithms_client_to_server  = message['encryption_algorithms_client_to_server']
      @remote_encryption_algorithms_server_to_client  = message['encryption_algorithms_server_to_client']
      @remote_mac_algorithms_client_to_server         = message['mac_algorithms_client_to_server']
      @remote_mac_algorithms_server_to_client         = message['mac_algorithms_server_to_client']
      @remote_compression_algorithms_client_to_server = message['compression_algorithms_client_to_server']
      @remote_compression_algorithms_server_to_client = message['compression_algorithms_server_to_client']
    end
  end
end
