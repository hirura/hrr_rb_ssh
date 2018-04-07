# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/request_handler'
require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/request_type'

module HrrRbSsh
  class Connection
    class Channel
      module ChannelType
        class Session
          module RequestType
            class PtyReq < RequestType
              NAME = 'pty-req'

              def self.run proc_chain, username, io, variables, message, options
                logger = HrrRbSsh::Logger.new self.class.name

                context = Context.new proc_chain, username, io, variables, message
                handler = options.fetch('connection_channel_request_pty_req', RequestHandler.new {})
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

require 'hrr_rb_ssh/connection/channel/channel_type/session/request_type/pty_req/context'
