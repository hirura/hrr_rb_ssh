module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class Shell
              class Context
                include Loggable

                attr_reader \
                  :username,
                  :io,
                  :variables,
                  :vars

                def initialize proc_chain, username, io, variables, message, session, logger: nil
                  self.logger = logger

                  @proc_chain = proc_chain
                  @username   = username
                  @io         = io
                  @variables  = variables
                  @vars       = variables
                  @session    = session
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
