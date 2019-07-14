# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Authentication
    class Method
      class KeyboardInteractive < Method
        NAME = 'keyboard-interactive'
        PREFERENCE = 30

        def initialize transport, options, variables, authentication_methods
          @logger = Logger.new(self.class.name)
          @transport = transport
          @options = options
          @authenticator = options.fetch( 'authentication_keyboard_interactive_authenticator', Authenticator.new { false } )
          @variables = variables
          @authentication_methods = authentication_methods
        end

        def authenticate userauth_request_message
          @logger.info { "authenticate" }
          @logger.debug { "userauth request: " + userauth_request_message.inspect }
          username = userauth_request_message[:'user name']
          submethods = userauth_request_message[:'submethods']
          context = Context.new(@transport, username, submethods, @variables, @authentication_methods)
          @authenticator.authenticate context
        end

        def request_authentication username, service_name
          message = {
            :'message number' => Message::SSH_MSG_USERAUTH_REQUEST::VALUE,
            :"user name"      => username,
            :"service name"   => service_name,
            :"method name"    => NAME,
            :"language tag"   => "",
            :'submethods'     => "",
          }
          payload = Message::SSH_MSG_USERAUTH_REQUEST.encode message
          @transport.send payload

          payload = @transport.receive
          case payload[0,1].unpack("C")[0]
          when Message::SSH_MSG_USERAUTH_INFO_REQUEST::VALUE
            message = Message::SSH_MSG_USERAUTH_INFO_REQUEST.decode payload
            num_responses = @options['client_authentication_keyboard_interactive'].size
            message = {
              :'message number' => Message::SSH_MSG_USERAUTH_INFO_RESPONSE::VALUE,
              :'num-responses'  => num_responses,
            }
            message_responses = @options['client_authentication_keyboard_interactive'].map.with_index{ |response, i|
              {:"response[#{i+1}]" => response}
            }.inject(Hash.new){ |a, b| a.merge(b) }
            message.update(message_responses)
            payload = Message::SSH_MSG_USERAUTH_INFO_RESPONSE.encode message
            @transport.send payload
            @transport.receive
          else
            payload
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/authentication/method/keyboard_interactive/context'
