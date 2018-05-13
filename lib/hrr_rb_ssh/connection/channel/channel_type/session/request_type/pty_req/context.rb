# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class PtyReq
              class Context
                attr_reader \
                  :logger,
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

                def initialize proc_chain, username, io, variables, message
                  @logger = Logger.new self.class.name

                  @proc_chain = proc_chain
                  @username   = username
                  @io         = io
                  @variables  = variables
                  @vars       = variables

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
              end
            end
          end
        end
      end
    end
  end
end
