# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'
require 'hrr_rb_ssh/transport'
require 'hrr_rb_ssh/authentication'
require 'hrr_rb_ssh/connection'

module HrrRbSsh
  class Server
    include Loggable

    def self.start io, options={}, logger: nil
      server = self.new options, logger: logger
      server.start io
    end

    def initialize options={}, logger: nil
      self.logger = logger
      @options = options
    end

    def start io
      log_info { "start server service" }
      transport      = Transport.new      io, Mode::SERVER, @options, logger: logger
      authentication = Authentication.new transport, Mode::SERVER, @options, logger: logger
      connection     = Connection.new     authentication, Mode::SERVER, @options, logger: logger
      begin
        connection.start
      rescue Error::ClosedConnection
      end
      log_info { "server service finished" }
    end
  end
end
