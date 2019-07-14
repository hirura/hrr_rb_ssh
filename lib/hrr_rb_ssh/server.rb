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
      transport      = Transport.new      io, Mode::SERVER, @options
      authentication = Authentication.new transport, Mode::SERVER, @options
      connection     = Connection.new     authentication, Mode::SERVER, @options
      connection.start
    end
  end
end
