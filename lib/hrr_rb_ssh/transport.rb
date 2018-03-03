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
      :v_s


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
  end
end
