# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message'
require 'hrr_rb_ssh/error/closed_authentication'
require 'hrr_rb_ssh/authentication/constant'
require 'hrr_rb_ssh/authentication/authenticator'
require 'hrr_rb_ssh/authentication/method'

module HrrRbSsh
  class Authentication
    include Constant

    def initialize transport, options={}
      @transport = transport
      @options = options

      @logger = Logger.new self.class.name

      @transport.register_acceptable_service SERVICE_NAME

      @closed = nil

      @username = nil
      @variables = {}
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

    def variables
      raise Error::ClosedAuthentication if @closed
      @variables
    end

    def authenticate
      authentication_methods = (@options['authentication_preferred_authentication_methods'].dup rescue nil) || Method.list_preferred # rescue nil.dup for Ruby version < 2.4
      @logger.info { "preferred authentication methods: #{authentication_methods}" }
      loop do
        payload = @transport.receive
        case payload[0,1].unpack("C")[0]
        when Message::SSH_MSG_USERAUTH_REQUEST::VALUE
          userauth_request_message = Message::SSH_MSG_USERAUTH_REQUEST.decode payload
          method_name = userauth_request_message[:'method name']
          @logger.info { "authentication method: #{method_name}" }
          method = Method[method_name].new(@transport, {'session id' => @transport.session_id}.merge(@options), @variables, authentication_methods)
          result = method.authenticate(userauth_request_message)
          case result
          when true, SUCCESS
            @logger.info { "verified" }
            send_userauth_success
            @username = userauth_request_message[:'user name']
            @closed = false
            break
          when PARTIAL_SUCCESS
            @logger.info { "partially verified" }
            authentication_methods.delete method_name
            @logger.debug { "authentication methods that can continue: #{authentication_methods}" }
            if authentication_methods.empty?
              @logger.info { "verified" }
              send_userauth_success
              @username = userauth_request_message[:'user name']
              @closed = false
              break
            else
              @logger.info { "continue" }
              send_userauth_failure authentication_methods, true
            end
          when String
            @logger.info { "send method specific message to continue" }
            send_method_specific_message result
          else # when false, FAILURE
            @logger.info { "verify failed" }
            send_userauth_failure authentication_methods, false
          end
        else
          @closed = true
          raise
        end
      end
    end

    def send_userauth_failure authentication_methods, partial_success
      message = {
        :'message number'                    => Message::SSH_MSG_USERAUTH_FAILURE::VALUE,
        :'authentications that can continue' => authentication_methods,
        :'partial success'                   => partial_success,
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
