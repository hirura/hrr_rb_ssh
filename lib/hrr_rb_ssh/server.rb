# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport'
require 'hrr_rb_ssh/authentication'
require 'hrr_rb_ssh/connection'

module HrrRbSsh
  class Server
    def initialize io, options={}
      @logger = Logger.new self.class.name
      @transport      = HrrRbSsh::Transport.new      io, HrrRbSsh::Mode::SERVER, options
      @authentication = HrrRbSsh::Authentication.new @transport, options
      @connection     = HrrRbSsh::Connection.new     @authentication, options
    end

    def start
      @logger.info { "start server service" }
      @connection.start
    end
  end
end
