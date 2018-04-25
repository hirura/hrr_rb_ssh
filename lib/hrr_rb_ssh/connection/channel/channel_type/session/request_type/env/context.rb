# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class Env
              class Context
                attr_reader \
                  :logger,
                  :username,
                  :io,
                  :variables,
                  :vars,
                  :variable_name,
                  :variable_value

                def initialize proc_chain, username, io, variables, message
                  @logger = HrrRbSsh::Logger.new self.class.name

                  @proc_chain = proc_chain
                  @username   = username
                  @io         = io
                  @variables  = variables
                  @vars       = variables

                  @variable_name  = message[:'variable name']
                  @variable_value = message[:'variable value']
                end

                def chain_proc &block
                  @proc = block || @proc
                end
              end
            end
          end
        end
      end
    end
  end
end
