# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class WindowChange
              class Context
                include Loggable

                attr_reader \
                  :username,
                  :io,
                  :variables,
                  :vars,
                  :terminal_width_columns,
                  :terminal_height_rows,
                  :terminal_width_pixels,
                  :terminal_height_pixels

                def initialize proc_chain, username, io, variables, message, session, logger: nil
                  self.logger = logger

                  @proc_chain = proc_chain
                  @username   = username
                  @io         = io
                  @variables  = variables
                  @vars       = variables
                  @session    = session

                  @terminal_width_columns = message[:'terminal width, columns']
                  @terminal_height_rows   = message[:'terminal height, rows']
                  @terminal_width_pixels  = message[:'terminal width, pixels']
                  @terminal_height_pixels = message[:'terminal height, pixels']
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
