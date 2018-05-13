# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class Exec
              class Context
                attr_reader \
                  :logger,
                  :username,
                  :io,
                  :variables,
                  :vars,
                  :command

                def initialize proc_chain, username, io, variables, message
                  @logger = Logger.new self.class.name

                  @proc_chain = proc_chain
                  @username   = username
                  @io         = io
                  @variables  = variables
                  @vars       = variables

                  @command = message[:'command']
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
