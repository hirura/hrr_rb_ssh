# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/version'
require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message'
require 'hrr_rb_ssh/transport/mode'
require 'hrr_rb_ssh/transport/data_type'
require 'hrr_rb_ssh/transport/sequence_number'
require 'hrr_rb_ssh/transport/sender'
require 'hrr_rb_ssh/transport/kex_algorithm'
require 'hrr_rb_ssh/transport/server_host_key_algorithm'
require 'hrr_rb_ssh/transport/encryption_algorithm'
require 'hrr_rb_ssh/transport/mac_algorithm'
require 'hrr_rb_ssh/transport/compression_algorithm'

module HrrRbSsh
  class Transport
    attr_reader \
      :io,
      :incoming_sequence_number,
      :outgoing_sequence_number,
      :incoming_encryption_algorithm,
      :incoming_mac_algorithm,
      :incoming_compression_algorithm,
      :outgoing_encryption_algorithm,
      :outgoing_mac_algorithm,
      :outgoing_compression_algorithm

    def initialize io, mode
      @io = io
      @mode = mode

      @logger = HrrRbSsh::Logger.new self.class.name

      @sender = HrrRbSsh::Transport::Sender.new self

      @incoming_sequence_number = HrrRbSsh::Transport::SequenceNumber.new
      @outgoing_sequence_number = HrrRbSsh::Transport::SequenceNumber.new

      @incoming_encryption_algorithm  = HrrRbSsh::Transport::EncryptionAlgorithm['none'].new
      @incoming_mac_algorithm         = HrrRbSsh::Transport::MacAlgorithm['none'].new
      @incoming_compression_algorithm = HrrRbSsh::Transport::CompressionAlgorithm['none'].new

      @outgoing_encryption_algorithm  = HrrRbSsh::Transport::EncryptionAlgorithm['none'].new
      @outgoing_mac_algorithm         = HrrRbSsh::Transport::MacAlgorithm['none'].new
      @outgoing_compression_algorithm = HrrRbSsh::Transport::CompressionAlgorithm['none'].new
    end
  end
end
