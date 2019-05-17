# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/transport'
require 'hrr_rb_ssh/authentication'
require 'hrr_rb_ssh/connection'

module HrrRbSsh
  class Server
    def self.start io, options={}
      server = self.new options
      server.start io
    end

    def initialize options={}
      @logger = Logger.new self.class.name
      @options = options
    end

    def start io
      @logger.info { "start server service" }
      transport      = HrrRbSsh::Transport.new      io, HrrRbSsh::Mode::SERVER, @options
      authentication = HrrRbSsh::Authentication.new transport, @options
      connection     = HrrRbSsh::Connection.new     authentication, @options
      connection.start
    end
  end
end
