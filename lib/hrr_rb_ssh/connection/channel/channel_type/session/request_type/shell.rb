require 'hrr_rb_ssh/connection/request_handler'

module HrrRbSsh
  class Connection
    class Channel
      class ChannelType
        class Session
          class RequestType
            class Shell < RequestType
              NAME = 'shell'

              def self.run proc_chain, username, io, variables, message, options, session, logger: nil
                context = Context.new proc_chain, username, io, variables, message, session, logger: logger
                handler = options.fetch('connection_channel_request_shell', RequestHandler.new {})
                handler.run context

                proc_chain.connect context.chain_proc
              end
            end
          end
        end
      end
    end
  end
end

require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/shell/context'
