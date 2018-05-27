# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message'
require 'hrr_rb_ssh/error/closed_authentication'
require 'hrr_rb_ssh/authentication/authenticator'
require 'hrr_rb_ssh/authentication/method'

module HrrRbSsh
  class Authentication
    SERVICE_NAME = 'ssh-userauth'

    def initialize transport, options={}
      @transport = transport
      @options = options

      @logger = Logger.new self.class.name

      @transport.register_acceptable_service SERVICE_NAME

      @closed = nil

      @username = nil
    end

    def send payload
      raise Error::ClosedAuthentication if @closed
      begin
        @transport.send payload
      rescue Error::ClosedTransport
        raise Error::ClosedAuthentication
      end
    end

    def receive
      raise Error::ClosedAuthentication if @closed
      begin
        @transport.receive
      rescue Error::ClosedTransport
        raise Error::ClosedAuthentication
      end
    end

    def start
      @transport.start
      authenticate
    end

    def close
      return if @closed
      @closed = true
      @transport.close
    end

    def closed?
      @closed
    end

    def username
      raise Error::ClosedAuthentication if @closed
      @username
    end

    def authenticate
      loop do
        payload = @transport.receive
        case payload[0,1].unpack("C")[0]
        when Message::SSH_MSG_USERAUTH_REQUEST::VALUE
          userauth_request_message = Message::SSH_MSG_USERAUTH_REQUEST.decode payload
          method_name = userauth_request_message[:'method name']
          method = Method[method_name].new(@transport, {'session id' => @transport.session_id}.merge(@options))
          result = method.authenticate(userauth_request_message)
          case result
          when TrueClass
            @logger.info { "verified" }
            send_userauth_success
            @username = userauth_request_message[:'user name']
            @closed = false
            break
          when FalseClass
            @logger.info { "verify failed" }
            send_userauth_failure
          when String
            @logger.info { "send method specific message to continue" }
            send_method_specific_message result
          end
        else
          @closed = true
          raise
        end
      end
    end

    def send_userauth_failure
      message = {
        :'message number'                    => Message::SSH_MSG_USERAUTH_FAILURE::VALUE,
        :'authentications that can continue' => Method.list_preferred,
        :'partial success'                   => false,
      }
      payload = Message::SSH_MSG_USERAUTH_FAILURE.encode message
      @transport.send payload
    end

    def send_userauth_success
      message = {
        :'message number' => Message::SSH_MSG_USERAUTH_SUCCESS::VALUE,
      }
      payload = Message::SSH_MSG_USERAUTH_SUCCESS.encode message
      @transport.send payload
    end

    def send_method_specific_message payload
      @transport.send payload
    end
  end
end
