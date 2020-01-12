# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/loggable'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class PtyReq
              class Context
                include Loggable

                attr_reader \
                  :username,
                  :io,
                  :variables,
                  :vars,
                  :term_environment_variable_value,
                  :terminal_width_characters,
                  :terminal_height_rows,
                  :terminal_width_pixels,
                  :terminal_height_pixels,
                  :encoded_terminal_modes

                def initialize proc_chain, username, io, variables, message, session, logger: nil
                  self.logger = logger

                  @proc_chain = proc_chain
                  @username   = username
                  @io         = io
                  @variables  = variables
                  @vars       = variables
                  @session    = session

                  @term_environment_variable_value = message[:'TERM environment variable value']
                  @terminal_width_characters       = message[:'terminal width, characters']
                  @terminal_height_rows            = message[:'terminal height, rows']
                  @terminal_width_pixels           = message[:'terminal width, pixels']
                  @terminal_height_pixels          = message[:'terminal height, pixels']
                  @encoded_terminal_modes          = message[:'encoded terminal modes']
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
