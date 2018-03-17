# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/message'
require 'hrr_rb_ssh/authentication/authenticator'
require 'hrr_rb_ssh/authentication/method'

module HrrRbSsh
  class Authentication
    SERVICE_NAME = 'ssh-userauth'

    def initialize transport, options={}
      @transport = transport
      @options = options

      @logger = HrrRbSsh::Logger.new self.class.name

      @transport.register_acceptable_service SERVICE_NAME
    end

    def start
      @transport.start

      authenticate
    end

    def authenticate
      loop do
        payload = @transport.receive
        case payload[0,1].unpack("C")[0]
        when HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST::VALUE
          userauth_request_message = HrrRbSsh::Message::SSH_MSG_USERAUTH_REQUEST.decode payload
          method_name = userauth_request_message['method name']
          method = Method[method_name].new(@options)
          if method.authenticate(userauth_request_message)
            send_userauth_success
            break
          else
            send_userauth_failure
          end

        else
          raise
        end
      end
    end

    def send_userauth_failure
      message = {
        'SSH_MSG_USERAUTH_FAILURE'          => HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE::VALUE,
        'authentications that can continue' => Method.name_list,
        'partial success'                   => false,
      }
      payload = HrrRbSsh::Message::SSH_MSG_USERAUTH_FAILURE.encode message
      @transport.send payload
    end

    def send_userauth_success
      message = {
        'SSH_MSG_USERAUTH_SUCCESS' => HrrRbSsh::Message::SSH_MSG_USERAUTH_SUCCESS::VALUE,
      }
      payload = HrrRbSsh::Message::SSH_MSG_USERAUTH_SUCCESS.encode message
      @transport.send payload
    end
  end
end
