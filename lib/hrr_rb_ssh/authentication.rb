# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'
require 'hrr_rb_ssh/message'
require 'hrr_rb_ssh/error/closed_authentication'
require 'hrr_rb_ssh/authentication/constant'
require 'hrr_rb_ssh/authentication/authenticator'
require 'hrr_rb_ssh/authentication/method'

module HrrRbSsh
  class Authentication
    include Loggable
    include Constant

    def initialize transport, mode, options={}, logger: nil
      self.logger = logger

      @transport = transport
      @mode = mode
      @options = options

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
        close
        raise Error::ClosedAuthentication
      end
    end

    def receive
      raise Error::ClosedAuthentication if @closed
      begin
        @transport.receive
      rescue Error::ClosedTransport
        close
        raise Error::ClosedAuthentication
      end
    end

    def start
      log_info { "start authentication" }
      begin
        @transport.start
        authenticate
      rescue Error::ClosedTransport
        close
        raise Error::ClosedAuthentication
      end
    end

    def close
      return if @closed
      log_info { "close authentication" }
      @closed = true
      @transport.close
      log_info { "authentication closed" }
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
      case @mode
      when Mode::SERVER
        respond_to_authentication
      when Mode::CLIENT
        request_authentication
      end
    end

    def respond_to_authentication
      authentication_methods = (@options['authentication_preferred_authentication_methods'].dup rescue nil) || Method.list_preferred # rescue nil.dup for Ruby version < 2.4
      log_info { "preferred authentication methods: #{authentication_methods}" }
      loop do
        payload = @transport.receive
        case payload[0,1].unpack("C")[0]
        when Message::SSH_MSG_USERAUTH_REQUEST::VALUE
          userauth_request_message = Message::SSH_MSG_USERAUTH_REQUEST.new(logger: logger).decode payload
          method_name = userauth_request_message[:'method name']
          log_info { "authentication method: #{method_name}" }
          method = Method[method_name].new(@transport, {'session id' => @transport.session_id}.merge(@options), @variables, authentication_methods, logger: logger)
          result = method.authenticate(userauth_request_message)
          case result
          when true, SUCCESS
            log_info { "verified" }
            send_userauth_success
            @username = userauth_request_message[:'user name']
            @closed = false
            break
          when PARTIAL_SUCCESS
            log_info { "partially verified" }
            authentication_methods.delete method_name
            log_info { "authentication methods that can continue: #{authentication_methods}" }
            if authentication_methods.empty?
              log_info { "verified" }
              send_userauth_success
              @username = userauth_request_message[:'user name']
              @closed = false
              break
            else
              log_info { "continue" }
              send_userauth_failure authentication_methods, true
            end
          when String
            log_info { "send method specific message to continue" }
            send_method_specific_message result
          else # when false, FAILURE
            log_info { "verify failed" }
            send_userauth_failure authentication_methods, false
          end
        else
          close
          raise Error::ClosedAuthentication
        end
      end
    end

    def request_authentication
      authentication_methods = (@options['authentication_preferred_authentication_methods'].dup rescue nil) || Method.list_preferred # rescue nil.dup for Ruby version < 2.4
      log_info { "preferred authentication methods: #{authentication_methods}" }
      next_method_name = "none"
      log_info { "authentication request begins with none method" }
      loop do
        log_info { "authentication method: #{next_method_name}" }
        method = Method[next_method_name].new(@transport, {'session id' => @transport.session_id}.merge(@options), @variables, authentication_methods, logger: logger)
        payload = method.request_authentication @options['username'], "ssh-connection"
        case payload[0,1].unpack("C")[0]
        when Message::SSH_MSG_USERAUTH_SUCCESS::VALUE
          log_info { "verified" }
          @username = @options['username']
          @closed = false
          break
        when Message::SSH_MSG_USERAUTH_FAILURE::VALUE
          message = Message::SSH_MSG_USERAUTH_FAILURE.new(logger: logger).decode payload
          partial_success = message[:'partial success']
          if partial_success
            log_info { "partially verified" }
          end
          authentication_methods_that_can_continue = message[:'authentications that can continue']
          log_info { "authentication methods that can continue: #{authentication_methods_that_can_continue}" }
          next_method_name = authentication_methods.find{ |local_m| authentication_methods_that_can_continue.find{ |remote_m| local_m == remote_m } }
          if next_method_name
            authentication_methods.delete next_method_name
            log_info { "continue" }
          else
            log_info { "no more available authentication methods" }
            @closed = true
            raise "failed authentication"
          end
        end
      end
    end

    def send_userauth_failure authentication_methods, partial_success
      message = {
        :'message number'                    => Message::SSH_MSG_USERAUTH_FAILURE::VALUE,
        :'authentications that can continue' => authentication_methods,
        :'partial success'                   => partial_success,
      }
      payload = Message::SSH_MSG_USERAUTH_FAILURE.new(logger: logger).encode message
      @transport.send payload
    end

    def send_userauth_success
      message = {
        :'message number' => Message::SSH_MSG_USERAUTH_SUCCESS::VALUE,
      }
      payload = Message::SSH_MSG_USERAUTH_SUCCESS.new(logger: logger).encode message
      @transport.send payload
    end

    def send_method_specific_message payload
      @transport.send payload
    end
  end
end
