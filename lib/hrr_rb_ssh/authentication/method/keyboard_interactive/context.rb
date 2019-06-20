# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/authentication/method/keyboard_interactive/info_request'
require 'hrr_rb_ssh/authentication/method/keyboard_interactive/info_response'

module HrrRbSsh
  class Authentication
    class Method
      class KeyboardInteractive
        class Context
          attr_reader \
            :username,
            :submethods,
            :info_response,
            :variables,
            :vars

          def initialize transport, username, submethods, variables
            @transport = transport
            @username = username
            @submethods = submethods
            @variables = variables
            @vars = variables

            @logger = Logger.new self.class.name
          end

          def info_request name, instruction, language_tag, prompts
            @logger.info { "send userauth info request" }
            @transport.send InfoRequest.new(name, instruction, language_tag, prompts).to_payload
            @logger.info { "receive userauth info response" }
            @info_response = InfoResponse.new @transport.receive
          end
        end
      end
    end
  end
end
