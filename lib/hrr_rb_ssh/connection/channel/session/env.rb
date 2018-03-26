# coding: utf-8
# vim: et ts=2 sw=2

require 'hrr_rb_ssh/logger'
require 'hrr_rb_ssh/connection/request_handler'
require 'hrr_rb_ssh/connection/channel/session/env/context'

module HrrRbSsh
  class Connection
    class Channel
      module Session
        request_type = 'env'

        class Env
          def self.run proc_chain, io, variables, message, options
            logger = HrrRbSsh::Logger.new self.class.name

            context = Context.new proc_chain, io, variables, message
            handler = options.fetch('connection_channel_request_env', RequestHandler.new {})
            handler.run context

            proc_chain.connect context.chain_proc
          end
        end

        @@request_type_list ||= Hash.new
        @@request_type_list[request_type] = Env
      end
    end
  end
end
