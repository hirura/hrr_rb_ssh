# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'
require 'hrr_rb_ssh/authentication/method/keyboard_interactive/info_request'
require 'hrr_rb_ssh/authentication/method/keyboard_interactive/info_response'

module HrrRbSsh
  class Authentication
    class Method
      class KeyboardInteractive
        class Context
          include Loggable

          attr_reader \
            :username,
            :submethods,
            :info_response,
            :variables,
            :vars,
            :authentication_methods

          def initialize transport, username, submethods, variables, authentication_methods, logger: nil
            self.logger = logger
            @transport = transport
            @username = username
            @submethods = submethods
            @variables = variables
            @vars = variables
            @authentication_methods = authentication_methods
          end

          def info_request name, instruction, language_tag, prompts
            log_info { "send userauth info request" }
            @transport.send InfoRequest.new(name, instruction, language_tag, prompts, logger: logger).to_payload
            log_info { "receive userauth info response" }
            @info_response = InfoResponse.new @transport.receive, logger: logger
          end
        end
      end
    end
  end
end
