# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class Exec
              class Context
                include Loggable

                attr_reader \
                  :username,
                  :io,
                  :variables,
                  :vars,
                  :command

                def initialize proc_chain, username, io, variables, message, session, logger: nil
                  self.logger = logger

                  @proc_chain = proc_chain
                  @username   = username
                  @io         = io
                  @variables  = variables
                  @vars       = variables
                  @session    = session

                  @command = message[:'command']
                end

                def chain_proc &block
                  @proc = block || @proc
                end

                def close_session
                  @session.close
                end
              end
            end
          end
        end
      end
    end
  end
end
