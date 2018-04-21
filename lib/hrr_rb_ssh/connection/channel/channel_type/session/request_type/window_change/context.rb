# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class WindowChange
              class Context
                attr_reader \
                  :logger,
                  :username,
                  :io,
                  :variables,
                  :vars,
                  :terminal_width_columns,
                  :terminal_height_rows,
                  :terminal_width_pixels,
                  :terminal_height_pixels

                def initialize proc_chain, username, io, variables, message
                  @logger = HrrRbSsh::Logger.new self.class.name

                  @proc_chain = proc_chain
                  @username   = username
                  @io         = io
                  @variables  = variables
                  @vars       = variables

                  @terminal_width_columns = message['terminal width, columns']
                  @terminal_height_rows   = message['terminal height, rows']
                  @terminal_width_pixels  = message['terminal width, pixels']
                  @terminal_height_pixels = message['terminal height, pixels']
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
